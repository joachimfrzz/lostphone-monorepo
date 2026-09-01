#!/usr/bin/env python3
"""Session 1b — Réglages (protocole D75).

Usage :
  python3 session1b_driver.py <URL_TUNNEL>              # exécute toute la checklist
  python3 session1b_driver.py <URL_TUNNEL> --ligne 12   # rejoue UNIQUEMENT la ligne 12
  python3 session1b_driver.py <URL_TUNNEL> --lignes 12,14,19

Règles D75 : checklist fermée (aucune capture hors liste) ; une ligne ratée se
rejoue individuellement (--ligne), jamais en exploration libre ; chaque ligne
part de la RACINE de Réglages (to_root) pour être autonome ; le script continue
après un échec et liste les lignes à rejouer en fin de run.
Checklist validée : tools/archives/session1b-checklist.md
"""
import base64, json, os, sys, time, urllib.request

if len(sys.argv) < 2:
    sys.exit("Usage: session1b_driver.py <URL_TUNNEL> [--ligne N | --lignes a,b,c]")
BASE = sys.argv[1].rstrip("/")
SEUL = []
if "--ligne" in sys.argv:
    SEUL = [int(sys.argv[sys.argv.index("--ligne") + 1])]
if "--lignes" in sys.argv:
    SEUL = [int(x) for x in sys.argv[sys.argv.index("--lignes") + 1].split(",")]

OUT = "/agent/workspace/session1"
os.makedirs(OUT + "/reglages", exist_ok=True)
JOURNAL, ECHECS = [], []


def req(method, path, body=None, timeout=45):
    r = urllib.request.Request(BASE + path,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"Content-Type": "application/json"}, method=method)
    with urllib.request.urlopen(r, timeout=timeout) as resp:
        return json.loads(resp.read().decode())


def log(m):
    JOURNAL.append(m); print(m, flush=True)


s = req("POST", "/session", {"capabilities": {}})
SID = s.get("sessionId") or s["value"]["sessionId"]
log(f"session WDA: {SID}")
size = req("GET", f"/session/{SID}/window/size")["value"]
W, H = size["width"], size["height"]


def find(pred, must=True):
    try:
        el = req("POST", f"/session/{SID}/element", {"using": "predicate string", "value": pred})
        return el["value"].get("ELEMENT") or list(el["value"].values())[0]
    except Exception:
        if must:
            raise
        return None


def tap_el(eid):
    req("POST", f"/session/{SID}/element/{eid}/click", {})
    time.sleep(1.4)


def find_tap(label_part, must=True):
    eid = find(f"label CONTAINS '{label_part}' AND visible == 1", must=False)
    if eid:
        tap_el(eid); log(f"  [tap] {label_part}"); return True
    log(f"  [tap ÉCHEC] {label_part}")
    if must:
        raise RuntimeError(label_part)
    return False


def swipe(x1, y1, x2, y2, dur=0.35):
    a = {"actions": [{"type": "pointer", "id": "f1", "parameters": {"pointerType": "touch"}, "actions": [
        {"type": "pointerMove", "duration": 0, "x": x1, "y": y1},
        {"type": "pointerDown", "button": 0},
        {"type": "pointerMove", "duration": int(dur * 1000), "x": x2, "y": y2},
        {"type": "pointerUp", "button": 0}]}]}
    req("POST", f"/session/{SID}/actions", a)
    time.sleep(1.0)


def fermer_popup():
    """Ferme une alerte éventuelle (OK / Autoriser plus tard / Fermer) sans rien accepter d'engageant."""
    for lbl in ("OK", "Plus tard", "Fermer", "Ignorer", "Pas maintenant"):
        eid = find(f"label == '{lbl}' AND visible == 1", must=False)
        if eid:
            tap_el(eid); log(f"  [popup fermée] {lbl}"); return True
    return False


def back():
    eid = find("name == 'BackButton'", must=False)
    if eid:
        tap_el(eid)
    else:
        swipe(2, H // 2, int(W * 0.6), H // 2, 0.3); time.sleep(0.8)


def to_root():
    for _ in range(6):
        eid = find("name == 'BackButton'", must=False)
        if not eid:
            break
        tap_el(eid)
    for _ in range(4):
        swipe(W // 2, int(H * 0.3), W // 2, int(H * 0.85), 0.25)
    time.sleep(0.5)


def capture(nom):
    fermer_popup()
    shot = req("GET", "/screenshot")
    png = base64.b64decode(shot["value"])
    if len(png) < 20000:
        raise RuntimeError(f"capture suspecte ({len(png)} o) : {nom}")
    with open(f"{OUT}/{nom}.png", "wb") as f:
        f.write(png)
    src = req("GET", "/source?format=xml")
    with open(f"{OUT}/{nom}.xml", "w", encoding="utf-8") as f:
        f.write(src["value"])
    log(f"  [capture] {nom} ({len(png)//1024} Ko png + xml)")


def scrolls_racine():
    capture("reglages/08-racine-haut")
    for i, suf in enumerate(("b", "c", "d"), 1):
        swipe(W // 2, int(H * 0.8), W // 2, int(H * 0.25))
        capture(f"reglages/08{suf}-racine-scroll{i}")


def sous_page(label, nom, sous=None):
    def run():
        if not find_tap(label, must=False):
            # l'entrée peut être plus bas dans la liste
            swipe(W // 2, int(H * 0.8), W // 2, int(H * 0.35))
            if not find_tap(label, must=False):
                raise RuntimeError(f"entrée introuvable : {label}")
        capture(nom)
        if sous:
            sl, sn = sous
            if find_tap(sl, must=False):
                capture(sn)
    return run


# ——— CHECKLIST FERMÉE (tools/archives/session1b-checklist.md) ———
LIGNES = [
    (10, "racine + 3 scrolls", scrolls_racine),
    (11, "Wi-Fi", sous_page("Wi-Fi", "reglages/10-wifi")),
    (12, "Bluetooth", sous_page("Bluetooth", "reglages/11-bluetooth")),
    (13, "Général + Informations", sous_page("Général", "reglages/12-general", ("Informations", "reglages/13-general-informations"))),
    (14, "Luminosité et affichage", sous_page("Luminosité", "reglages/14-luminosite")),
    (15, "Fond d'écran", sous_page("Fond d'écran", "reglages/15-fond-ecran")),
    (16, "Batterie", sous_page("Batterie", "reglages/16-batterie")),
    (17, "Confidentialité et sécurité", sous_page("Confidentialité", "reglages/17-confidentialite")),
    (18, "Notifications", sous_page("Notifications", "reglages/18-notifications")),
    (19, "Sons et vibrations", sous_page("Sons", "reglages/19-sons")),
]

try:
    for num, nom, action in LIGNES:
        if SEUL and num not in SEUL:
            continue
        log(f"— ligne {num} : {nom}")
        try:
            req("POST", f"/session/{SID}/wda/apps/launch", {"bundleId": "com.apple.Preferences"})
            time.sleep(2.0)
            fermer_popup()
            to_root()
            action()
        except Exception as e:
            ECHECS.append(num)
            log(f"  [LIGNE {num} ÉCHOUÉE] {e} — à rejouer : --ligne {num}")
    req("POST", "/wda/homescreen", {})
    log("— FIN : retour accueil —")
finally:
    with open(f"{OUT}/journal-1b.txt", "a", encoding="utf-8") as f:
        f.write("\n".join(JOURNAL) + "\n")
    try:
        req("DELETE", f"/session/{SID}")
    except Exception:
        pass
    n = sum(1 for r, _, fs in os.walk(OUT) for x in fs if x.endswith(".png"))
    print(f"TOTAL captures cumulées: {n}")
    if ECHECS:
        print(f"LIGNES À REJOUER: --lignes {','.join(map(str, ECHECS))}")
