#!/usr/bin/env python3
"""Session 1 — Coque iOS + Réglages. Capture PNG + arbre UI (XML) pour chaque cible.
Doctrine : zone verte uniquement, aucune modification, aucun envoi."""
import base64, json, os, sys, time, urllib.request

BASE = "https://citation-laboratories-back-wider.trycloudflare.com"
OUT = "/agent/workspace/session1"
os.makedirs(OUT, exist_ok=True)
JOURNAL = []

def req(method, path, body=None, timeout=45):
    r = urllib.request.Request(BASE + path,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"Content-Type": "application/json"}, method=method)
    with urllib.request.urlopen(r, timeout=timeout) as resp:
        return json.loads(resp.read().decode())

def log(msg):
    JOURNAL.append(msg)
    print(msg, flush=True)

def capture(nom):
    shot = req("GET", "/screenshot")
    with open(f"{OUT}/{nom}.png", "wb") as f:
        f.write(base64.b64decode(shot["value"]))
    src = req("GET", "/source?format=xml")
    with open(f"{OUT}/{nom}.xml", "w", encoding="utf-8") as f:
        f.write(src["value"])
    log(f"  [capture] {nom} (png+xml)")

# ---- session WDA ----
s = req("POST", "/session", {"capabilities": {}})
SID = s.get("sessionId") or s["value"]["sessionId"]
log(f"session WDA: {SID}")
size = req("GET", f"/session/{SID}/window/size")["value"]
W, H = size["width"], size["height"]
log(f"écran: {W}x{H} points")

def home():
    req("POST", "/wda/homescreen", {})
    time.sleep(1.2)

def swipe(x1, y1, x2, y2, dur=0.35, pause_ms=0):
    actions = {"actions": [{"type": "pointer", "id": "f1", "parameters": {"pointerType": "touch"}, "actions": [
        {"type": "pointerMove", "duration": 0, "x": x1, "y": y1},
        {"type": "pointerDown", "button": 0},
        {"type": "pointerMove", "duration": int(dur*1000), "x": x2, "y": y2},
    ] + ([{"type": "pause", "duration": pause_ms}] if pause_ms else []) + [
        {"type": "pointerUp", "button": 0}]}]}
    req("POST", f"/session/{SID}/actions", actions)
    time.sleep(1.0)

def find_tap(label_part, must=True):
    try:
        el = req("POST", f"/session/{SID}/element",
                 {"using": "predicate string", "value": f"label CONTAINS '{label_part}' AND visible == 1"})
        eid = el["value"].get("ELEMENT") or list(el["value"].values())[0]
        req("POST", f"/session/{SID}/element/{eid}/click", {})
        time.sleep(1.3)
        log(f"  [tap] {label_part}")
        return True
    except Exception as e:
        log(f"  [tap ÉCHEC] {label_part}: {str(e)[:80]}")
        if must: raise
        return False

def back():
    swipe(2, H//2, int(W*0.6), H//2, 0.3)  # balayage bord gauche = retour
    time.sleep(0.8)

try:
    # ---------- COQUE ----------
    log("— COQUE —")
    home(); capture("coque/02-accueil-page1")
    swipe(int(W*0.85), H//2, int(W*0.15), H//2); capture("coque/03-accueil-page2")
    swipe(int(W*0.85), H//2, int(W*0.15), H//2); capture("coque/04-page-suivante-ou-bibliotheque")
    swipe(int(W*0.85), H//2, int(W*0.15), H//2); capture("coque/04b-bibliotheque-apps")
    home()
    # centre de contrôle : glisser depuis coin haut droit
    swipe(int(W*0.92), 2, int(W*0.92), int(H*0.55)); capture("coque/05-centre-de-controle")
    home(); time.sleep(0.8)
    # centre de notifications : glisser depuis haut gauche/centre
    swipe(int(W*0.35), 2, int(W*0.35), int(H*0.6)); capture("coque/06-centre-notifications")
    home(); time.sleep(0.8)
    # multitâche : glisser du bas avec pause
    swipe(W//2, H-2, W//2, int(H*0.5), 0.5, pause_ms=700); capture("coque/07-multitache")
    home()

    # ---------- RÉGLAGES ----------
    log("— RÉGLAGES —")
    req("POST", f"/session/{SID}/wda/apps/launch", {"bundleId": "com.apple.Preferences"})
    time.sleep(2.0)
    capture("reglages/08-racine-haut")
    swipe(W//2, int(H*0.8), W//2, int(H*0.25)); capture("reglages/08b-racine-scroll1")
    swipe(W//2, int(H*0.8), W//2, int(H*0.25)); capture("reglages/08c-racine-scroll2")
    # remonter en haut
    for _ in range(3): swipe(W//2, int(H*0.25), W//2, int(H*0.85), 0.25)
    time.sleep(0.5)

    cibles = [
        ("Wi-Fi", "reglages/10-wifi"),
        ("Bluetooth", "reglages/11-bluetooth"),
        ("Général", "reglages/12-general"),
    ]
    for label, nom in cibles:
        if find_tap(label, must=False):
            capture(nom)
            if label == "Général":
                if find_tap("Informations", must=False):
                    capture("reglages/13-general-informations"); back()
            back()

    # cibles plus bas dans la liste
    swipe(W//2, int(H*0.8), W//2, int(H*0.35))
    for label, nom in [("Luminosité", "reglages/14-luminosite"), ("Fond d'écran", "reglages/15-fond-ecran"), ("Batterie", "reglages/16-batterie")]:
        if find_tap(label, must=False):
            capture(nom); back()
    swipe(W//2, int(H*0.8), W//2, int(H*0.35))
    for label, nom in [("Confidentialité", "reglages/17-confidentialite"), ("Notifications", "reglages/18-notifications"), ("Sons", "reglages/19-sons")]:
        if find_tap(label, must=False):
            capture(nom); back()

    home()
    log("— FIN : retour accueil —")
finally:
    with open(f"{OUT}/journal.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(JOURNAL))
    try:
        req("DELETE", f"/session/{SID}")
    except Exception:
        pass
    n = sum(1 for r, _, fs in os.walk(OUT) for x in fs if x.endswith(".png"))
    print(f"TOTAL captures: {n}")
