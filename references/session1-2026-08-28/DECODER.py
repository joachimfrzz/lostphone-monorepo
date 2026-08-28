#!/usr/bin/env python3
"""Reconstitue les PNG de cette session : python3 DECODER.py (a lancer dans ce dossier).
Concatene les .part* dans l'ordre puis decode le base64."""
import base64, os, re
for root, _, files in os.walk("."):
    groups = {}
    for f in files:
        m = re.match(r"(.+\.png)\.b64(?:\.part(\d+))?$", f)
        if m:
            groups.setdefault(m.group(1), []).append((int(m.group(2) or 1), f))
    for png, parts in groups.items():
        data = "".join(open(os.path.join(root, f)).read() for _, f in sorted(parts))
        with open(os.path.join(root, png), "wb") as o:
            o.write(base64.b64decode(data))
        print("OK", os.path.join(root, png))
