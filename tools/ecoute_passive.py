#!/usr/bin/env python3
"""Enregistreur passif D78 — « toi aux doigts, moi à l'écoute ».

Usage : python3 ecoute_passive.py <URL_TUNNEL> <dossier_sortie> [minutes=15]

Lit l'arbre XML (~1x/s) et un instantané JPEG à chaque CHANGEMENT d'écran,
pendant que Joachim navigue physiquement. AUCUNE commande envoyée au
téléphone : lecture pure (/source et /screenshot, sans session).
Sortie : NNN-HHMMSS.xml + NNN-HHMMSS.jpg par état d'écran distinct + journal.
"""
import base64, hashlib, io, json, os, re, sys, time, urllib.request
from PIL import Image

BASE = sys.argv[1].rstrip("/")
OUT = sys.argv[2]
MINUTES = float(sys.argv[3]) if len(sys.argv) > 3 else 15.0
os.makedirs(OUT, exist_ok=True)


def req(path, t=20):
    with urllib.request.urlopen(BASE + path, timeout=t) as r:
        return json.loads(r.read().decode())


def empreinte(src):
    hdr = "|".join(re.findall(r'NavigationBar[^>]*name="([^"]*)"', src)[:2])
    labels = sorted(set(re.findall(r'label="([^"]{2,40})"', src)))[:60]
    return hashlib.sha1((hdr + "§" + "|".join(labels)).encode()).hexdigest()[:12]


n, derniere, debut, erreurs = 0, None, time.time(), 0
dernier_changement, noirs = time.time(), 0
journal = []
print(f"ÉCOUTE PASSIVE démarrée ({MINUTES:.0f} min max) — CLAP DE FIN : verrouille le téléphone (ou 90 s immobile).", flush=True)
while time.time() - debut < MINUTES * 60:
    t0 = time.time()
    try:
        # clap de fin 1 : écran verrouillé/noir
        try:
            png_probe = base64.b64decode(req("/screenshot", t=25)["value"])
            im = Image.open(io.BytesIO(png_probe)).convert("L").resize((10, 22))
            if sum(im.getdata()) / 220 < 12:
                noirs += 1
                if noirs >= 2 and n > 0:
                    print("CLAP DE FIN détecté (téléphone verrouillé) — arrêt.", flush=True)
                    break
            else:
                noirs = 0
        except Exception:
            pass
        # clap de fin 2 : immobilité prolongée
        if n > 0 and time.time() - dernier_changement > 90:
            print("90 s sans changement — arrêt automatique.", flush=True)
            break
        src = req("/source?format=xml")["value"]
        e = empreinte(src)
        if e != derniere:
            dernier_changement = time.time()
            derniere = e
            n += 1
            ts = time.strftime("%H%M%S")
            png = base64.b64decode(req("/screenshot", t=25)["value"])
            Image.open(io.BytesIO(png)).convert("RGB").save(f"{OUT}/{n:03d}-{ts}.jpg", "JPEG", quality=85)
            with open(f"{OUT}/{n:03d}-{ts}.xml", "w", encoding="utf-8") as f:
                f.write(src)
            hdr = re.findall(r'NavigationBar[^>]*name="([^"]*)"', src)
            journal.append(f"{n:03d} {ts} {hdr[0] if hdr else '?'}")
            print(f"  [{n:03d}] {ts} {hdr[0] if hdr else '(sans header)'}", flush=True)
        erreurs = 0
    except Exception as ex:
        erreurs += 1
        if erreurs >= 6:
            print(f"LIAISON PERDUE ({ex}) — arrêt.", flush=True)
            break
        time.sleep(2)
    # cadence ~1 Hz
    reste = 1.0 - (time.time() - t0)
    if reste > 0:
        time.sleep(reste)
with open(f"{OUT}/journal.txt", "a", encoding="utf-8") as f:
    f.write("\n".join(journal) + "\n")
print(f"FIN : {n} états d'écran distincts capturés en {int(time.time()-debut)} s.")
