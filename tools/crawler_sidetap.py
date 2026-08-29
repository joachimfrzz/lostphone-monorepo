#!/usr/bin/env python3
"""Crawler exhaustif SideTap (D77) — v1 : exploration systématique d'une app.

Usage : python3 crawler_sidetap.py <URL_TUNNEL> <bundleId> <dossier_sortie> [minutes_max]

Principe : l'arbre XML de chaque écran fournit la liste COMPLÈTE de ses lignes.
BFS borné en profondeur : capture -> énumération -> visite de chaque ligne de
navigation -> vérification -> retour. Chaque élément est VISITÉ ou ÉCARTÉ avec
raison. Frontière persistée (reprise possible). Couverture vérifiable.

GARDE-FOUS (codés) :
- Taps uniquement sur Cell/Button de navigation ; JAMAIS Switch/TextField/Slider.
- Blacklist de libellés d'action (supprimer, réinitialiser, déconnecter, payer,
  envoyer, appeler, effacer, ajouter, rejoindre, activer, éteindre...).
- Pages-feuilles à risque (Wi-Fi, Bluetooth, VPN, Face ID, SIM...) : capturées,
  jamais explorées en profondeur (un tap sur un réseau = tentative de connexion).
- Jamais hors de l'app (retour auto si l'app change).
- Profondeur max 3, budget temps par run (reprise ensuite).
"""
import base64, hashlib, json, os, re, sys, time, urllib.request

BASE = sys.argv[1].rstrip("/")
BUNDLE = sys.argv[2]
OUT = sys.argv[3]
BUDGET_MIN = float(sys.argv[4]) if len(sys.argv) > 4 else 8.0
os.makedirs(OUT, exist_ok=True)
ETAT_F = os.path.join(OUT, "_etat_crawler.json")
DEPTH_MAX = 3
DEBUT = time.time()

# NOYAU DUR D77 (2026-08-29, arbitrage Joachim « liberté maximale, garde-fous minimaux ») :
# paiements/achats, envois sociaux, destructions irréversibles, coupure de liaison. Le reste est libre.
BLACKLIST = re.compile(
    r"supprim|réinitialis|reinitialis|effacer|déconnect|deconnect|éteindre|eteindre|"
    r"payer|paiement|acheter|achat|apple\s?pay|commander|"
    r"envoyer|publier|poster|partager|partage|airdrop|"
    r"enregistrer|sauvegarder|valider|confirmer|terminé|termine|"
    r"transférer ou réinitialiser|restaurer|mettre à jour|mettre a jour|installer|"
    r"appeler|facetime|urgence|sos|"
    r"mode avion", re.I)
PAGES_FEUILLES = re.compile(r"wi-?fi|bluetooth|vpn|face\s?id|sim|données cellulaires|partage de connexion|batterie externe", re.I)
TYPES_TAP = ("XCUIElementTypeCell", "XCUIElementTypeButton")
TYPES_INTERDITS = ("Switch", "TextField", "SecureTextField", "Slider", "Toggle")


def req(m, p, b=None, t=45):
    r = urllib.request.Request(BASE + p,
        data=json.dumps(b).encode() if b is not None else None,
        headers={"Content-Type": "application/json"}, method=m)
    with urllib.request.urlopen(r, timeout=t) as resp:
        return json.loads(resp.read().decode())


S = req("POST", "/session", {"capabilities": {}})
SID = S.get("sessionId") or S["value"]["sessionId"]
sz = req("GET", f"/session/{SID}/window/size")["value"]
W, H = sz["width"], sz["height"]


def source():
    return req("GET", "/source?format=xml")["value"]


def find(pred):
    try:
        el = req("POST", f"/session/{SID}/element", {"using": "predicate string", "value": pred})
        return el["value"].get("ELEMENT") or list(el["value"].values())[0]
    except Exception:
        return None


def app_active():
    try:
        return req("GET", f"/session/{SID}/wda/activeAppInfo")["value"].get("bundleId", "")
    except Exception:
        return ""


def garde_app(contexte=""):
    """GARDE ANTI-DÉRIVE : si on n'est plus dans l'app cible (notification tapée,
    lien externe...), retour accueil + relance de l'app cible, incident journalisé."""
    b = app_active()
    if b and b != BUNDLE:
        print(f"  [!! DÉRIVE] app active = {b} ({contexte}) -> retour {BUNDLE}", flush=True)
        etat["ecartes"][f"INCIDENT dérive {time.strftime('%H:%M:%S')}"] = f"tap parti dans {b} ({contexte})"
        req("POST", "/wda/homescreen", {}); time.sleep(1.0)
        req("POST", f"/session/{SID}/wda/apps/launch", {"bundleId": BUNDLE}); time.sleep(2.0)
        return False
    return True


def tap(eid):
    req("POST", f"/session/{SID}/element/{eid}/click", {})
    time.sleep(1.5)
    garde_app("après tap")


def swipe(y1, y2, d=0.45):
    a = {"actions": [{"type": "pointer", "id": "f1", "parameters": {"pointerType": "touch"}, "actions": [
        {"type": "pointerMove", "duration": 0, "x": W // 2, "y": y1},
        {"type": "pointerDown", "button": 0},
        {"type": "pointerMove", "duration": int(d * 1000), "x": W // 2, "y": y2},
        {"type": "pointerUp", "button": 0}]}]}
    req("POST", f"/session/{SID}/actions", a)
    time.sleep(1.4)


def back():
    e = find("name == 'BackButton'")
    if e:
        tap(e); return True
    swipe2 = {"actions": [{"type": "pointer", "id": "f1", "parameters": {"pointerType": "touch"}, "actions": [
        {"type": "pointerMove", "duration": 0, "x": 2, "y": H // 2},
        {"type": "pointerDown", "button": 0},
        {"type": "pointerMove", "duration": 300, "x": int(W * 0.6), "y": H // 2},
        {"type": "pointerUp", "button": 0}]}]}
    req("POST", f"/session/{SID}/actions", swipe2); time.sleep(1.2)
    return False


def header(src):
    m = re.findall(r'NavigationBar[^>]*name="([^"]*)"', src)
    return m[0] if m else ""


def ecran_id(src):
    hdr = header(src)
    labels = sorted(set(re.findall(r'label="([^"]{2,40})"', src)))[:40]
    return hashlib.sha1((hdr + "|" + "|".join(labels)).encode()).hexdigest()[:12], hdr


def lignes_navigation(src):
    """Énumère les candidats de navigation + les écartés avec raison."""
    cands, ecartes = [], []
    for m in re.finditer(r'<(XCUIElementType\w+)[^>]*?label="([^"]{2,60})"[^>]*?visible="true"[^>]*?>', src):
        t, l = m.group(1), m.group(2)
        if any(x in t for x in TYPES_INTERDITS):
            ecartes.append((l, "type interdit " + t)); continue
        if t not in TYPES_TAP:
            continue
        if BLACKLIST.search(l):
            ecartes.append((l, "blacklist action")); continue
        if l in ("BackButton", "Réglages", "chevron.forward"):
            continue
        cands.append(l)
    # dédoublonner en gardant l'ordre
    vus, out = set(), []
    for l in cands:
        if l not in vus:
            vus.add(l); out.append(l)
    return out, ecartes


def capturer(nom, src=None):
    if not garde_app("avant capture"):
        raise RuntimeError("dérive hors app — capture annulée")
    src = src or source()
    shot = req("GET", "/screenshot")
    png = base64.b64decode(shot["value"])
    safe = re.sub(r"[^A-Za-z0-9_-]", "_", nom)[:60]
    with open(f"{OUT}/{safe}.png", "wb") as f:
        f.write(png)
    with open(f"{OUT}/{safe}.xml", "w", encoding="utf-8") as f:
        f.write(src)
    return len(png)


def scroll_haut():
    for _ in range(5):
        swipe(int(H * 0.3), int(H * 0.85), 0.25)


# ——— état persistant ———
etat = {"visites": {}, "ecartes": {}, "afaire": [], "fait": []}
if os.path.exists(ETAT_F):
    etat = json.load(open(ETAT_F))


def sauver():
    json.dump(etat, open(ETAT_F, "w"), ensure_ascii=False, indent=1)


def explorer(chemin, profondeur):
    """chemin = liste de labels à taper depuis la racine pour arriver ici."""
    if time.time() - DEBUT > BUDGET_MIN * 60:
        return False
    cle = " > ".join(chemin) or "(racine)"
    # navigation depuis la racine
    req("POST", f"/session/{SID}/wda/apps/launch", {"bundleId": BUNDLE}); time.sleep(2)
    for _ in range(8):
        if not find("name == 'BackButton'"):
            break
        back()
    scroll_haut()
    for lab in chemin:
        e = None
        for _ in range(8):
            e = find(f"label == '{lab}' AND visible == 1")
            if e:
                r = req("GET", f"/session/{SID}/element/{e}/rect")["value"]
                if r["y"] + r["height"] / 2 > H * 0.72:
                    swipe(int(H * 0.7), int(H * 0.45)); e = None; continue
                break
            swipe(int(H * 0.8), int(H * 0.35))
        if not e:
            etat["ecartes"][cle] = "navigation impossible vers " + lab
            return True
        tap(e)
    src = source()
    eid_, hdr = ecran_id(src)
    if eid_ in etat["visites"]:
        return True
    # capture écran + scrolls pour tout énumérer
    n = capturer(f"{len(etat['visites']):03d}-{cle}", src)
    tous, ecartes = lignes_navigation(src)
    for i in range(1, 4):
        avant = eid_
        swipe(int(H * 0.8), int(H * 0.25))
        src2 = source()
        e2, _ = ecran_id(src2)
        if e2 == avant:
            break
        capturer(f"{len(etat['visites']):03d}-{cle}-scroll{i}", src2)
        plus, ec2 = lignes_navigation(src2)
        for l in plus:
            if l not in tous:
                tous.append(l)
        ecartes += ec2
        eid_ = e2
    etat["visites"][eid_] = {"chemin": cle, "header": hdr, "lignes": len(tous), "png": n}
    for l, raison in ecartes:
        etat["ecartes"][f"{cle} :: {l}"] = raison
    print(f"[{len(etat['visites']):3d}] {cle}  ({len(tous)} lignes, header={hdr[:30]})", flush=True)
    # planifier les enfants
    if profondeur < DEPTH_MAX and not PAGES_FEUILLES.search(hdr or (chemin[-1] if chemin else "")):
        for l in tous:
            if PAGES_FEUILLES.search(l):
                enfant = chemin + [l]
                # page feuille : capture seule, pas d'exploration
                etat["afaire"].append({"chemin": enfant, "prof": DEPTH_MAX})
            else:
                etat["afaire"].append({"chemin": chemin + [l], "prof": profondeur + 1})
    sauver()
    return True


# amorçage
if not etat["fait"] and not etat["afaire"]:
    etat["afaire"].append({"chemin": [], "prof": 0})
while etat["afaire"]:
    if time.time() - DEBUT > BUDGET_MIN * 60:
        print("BUDGET TEMPS ATTEINT — reprise possible (état sauvegardé)")
        break
    item = etat["afaire"].pop(0)
    try:
        ok = explorer(item["chemin"], item["prof"])
    except Exception as ex:
        etat["ecartes"][" > ".join(item["chemin"])] = f"erreur: {ex}"
        try:
            S = req("POST", "/session", {"capabilities": {}})
            SID = S.get("sessionId") or S["value"]["sessionId"]
        except Exception:
            print("session perdue — arrêt propre"); break
    etat["fait"].append(item)
    sauver()
sauver()
req("POST", "/wda/homescreen", {})
try: req("DELETE", f"/session/{SID}")
except Exception: pass
print(f"\nBILAN : {len(etat['visites'])} écrans visités, {len(etat['ecartes'])} écartés/erreurs, {len(etat['afaire'])} restants en frontière")
