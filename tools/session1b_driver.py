#!/usr/bin/env python3
"""Session 1b — Réglages depuis la RACINE cette fois.
Correctif : Réglages s'était rouvert sur une sous-page (VPN et gestion de l'appareil).
On remonte à la racine via le bouton BackButton avant de capturer."""
import base64, json, os, sys, time, urllib.request

BASE = "https://citation-laboratories-back-wider.trycloudflare.com"
OUT = "/agent/workspace/session1"
os.makedirs(OUT + "/reglages", exist_ok=True)
JOURNAL = []

def req(method, path, body=None, timeout=45):
    r = urllib.request.Request(BASE + path,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"Content-Type": "application/json"}, method=method)
    with urllib.request.urlopen(r, timeout=timeout) as resp:
        return json.loads(resp.read().decode())

def log(msg):
    JOURNAL.append(msg); print(msg, flush=True)

def capture(nom):
    shot = req("GET", "/screenshot")
    with open(f"{OUT}/{nom}.png", "wb") as f:
        f.write(base64.b64decode(shot["value"]))
    src = req("GET", "/source?format=xml")
    with open(f"{OUT}/{nom}.xml", "w", encoding="utf-8") as f:
        f.write(src["value"])
    log(f"  [capture] {nom} (png+xml)")

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
        if must: raise
        return None

def tap_el(eid):
    req("POST", f"/session/{SID}/element/{eid}/click", {})
    time.sleep(1.4)

def find_tap(label_part, must=True):
    eid = find(f"label CONTAINS '{label_part}' AND visible == 1", must=False)
    if eid:
        tap_el(eid); log(f"  [tap] {label_part}"); return True
    log(f"  [tap ÉCHEC] {label_part}")
    if must: raise RuntimeError(label_part)
    return False

def swipe(x1, y1, x2, y2, dur=0.35):
    actions = {"actions": [{"type": "pointer", "id": "f1", "parameters": {"pointerType": "touch"}, "actions": [
        {"type": "pointerMove", "duration": 0, "x": x1, "y": y1},
        {"type": "pointerDown", "button": 0},
        {"type": "pointerMove", "duration": int(dur*1000), "x": x2, "y": y2},
        {"type": "pointerUp", "button": 0}]}]}
    req("POST", f"/session/{SID}/actions", actions)
    time.sleep(1.0)

def back():
    eid = find("name == 'BackButton'", must=False)
    if eid: tap_el(eid)
    else: swipe(2, H//2, int(W*0.6), H//2, 0.3); time.sleep(0.8)

def to_root():
    """Remonte Réglages à sa racine (tape BackButton tant qu'il existe)."""
    for _ in range(6):
        eid = find("name == 'BackButton'", must=False)
        if not eid:
            return
        tap_el(eid)

try:
    req("POST", f"/session/{SID}/wda/apps/launch", {"bundleId": "com.apple.Preferences"})
    time.sleep(2.0)
    to_root()
    # remonter en haut de la liste
    for _ in range(3): swipe(W//2, int(H*0.3), W//2, int(H*0.85), 0.25)
    time.sleep(0.5)
    capture("reglages/08-racine-haut")
    swipe(W//2, int(H*0.8), W//2, int(H*0.25)); capture("reglages/08b-racine-scroll1")
    swipe(W//2, int(H*0.8), W//2, int(H*0.25)); capture("reglages/08c-racine-scroll2")
    swipe(W//2, int(H*0.8), W//2, int(H*0.25)); capture("reglages/08d-racine-scroll3")
    for _ in range(4): swipe(W//2, int(H*0.25), W//2, int(H*0.85), 0.25)
    time.sleep(0.5)

    for label, nom in [("Wi-Fi", "reglages/10-wifi"), ("Bluetooth", "reglages/11-bluetooth"), ("Général", "reglages/12-general")]:
        if find_tap(label, must=False):
            capture(nom)
            if label == "Général" and find_tap("Informations", must=False):
                capture("reglages/13-general-informations"); back()
            back()

    swipe(W//2, int(H*0.8), W//2, int(H*0.35))
    for label, nom in [("Luminosité", "reglages/14-luminosite"), ("Fond d'écran", "reglages/15-fond-ecran"), ("Batterie", "reglages/16-batterie")]:
        if find_tap(label, must=False):
            capture(nom); back()
    swipe(W//2, int(H*0.8), W//2, int(H*0.35))
    for label, nom in [("Confidentialité", "reglages/17-confidentialite"), ("Notifications", "reglages/18-notifications"), ("Sons", "reglages/19-sons")]:
        if find_tap(label, must=False):
            capture(nom); back()

    req("POST", "/wda/homescreen", {})
    log("— FIN : retour accueil —")
finally:
    with open(f"{OUT}/journal-1b.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(JOURNAL))
    try: req("DELETE", f"/session/{SID}")
    except Exception: pass
    n = sum(1 for r, _, fs in os.walk(OUT) for x in fs if x.endswith(".png"))
    print(f"TOTAL captures cumulées: {n}")
