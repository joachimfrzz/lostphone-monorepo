#!/usr/bin/env python3
"""Planches de contrôle (D95) : une grille d'images par groupe, nom de fichier en tête.

Usage : python3 outils/planches.py <dossier_images> <dossier_sortie> [--groupe prefixe|dossier] [--colonnes 8]
  --groupe prefixe : groupe par préfixe de nom (« reglages.general.png » → « reglages »), pour le miroir
  --groupe dossier : une planche par sous-dossier (sortie du robot explorateur)
Chaque planche fait au plus 40 images ; au-delà, planches numérotées.
"""
import argparse
import os
from PIL import Image, ImageDraw

LARGEUR, HAUTEUR, BANDEAU = 201, 437, 18


def planche(fichiers, sortie, colonnes):
    lignes = (len(fichiers) + colonnes - 1) // colonnes
    img = Image.new("RGB", (colonnes * LARGEUR, lignes * (HAUTEUR + BANDEAU)), "white")
    d = ImageDraw.Draw(img)
    for i, f in enumerate(fichiers):
        x, y = (i % colonnes) * LARGEUR, (i // colonnes) * (HAUTEUR + BANDEAU)
        try:
            vignette = Image.open(f).convert("RGB").resize((LARGEUR, HAUTEUR))
        except Exception:
            continue
        img.paste(vignette, (x, y + BANDEAU))
        d.text((x + 3, y + 3), os.path.basename(f)[:34], fill=(200, 0, 0))
    img.save(sortie, quality=82)


def main():
    a = argparse.ArgumentParser()
    a.add_argument("source")
    a.add_argument("sortie")
    a.add_argument("--groupe", default="prefixe", choices=["prefixe", "dossier"])
    a.add_argument("--colonnes", type=int, default=8)
    o = a.parse_args()
    os.makedirs(o.sortie, exist_ok=True)
    groupes = {}
    for racine, _, noms in os.walk(o.source):
        for n in sorted(noms):
            if not n.lower().endswith((".png", ".jpg")):
                continue
            chemin = os.path.join(racine, n)
            if o.groupe == "dossier":
                cle = os.path.relpath(racine, o.source).replace(os.sep, "_")
            else:
                cle = n.split(".")[0].split("#")[0]
            groupes.setdefault(cle, []).append(chemin)
    for cle, fichiers in sorted(groupes.items()):
        fichiers.sort()
        for k in range(0, len(fichiers), 40):
            suffixe = "" if len(fichiers) <= 40 else f"-{k // 40 + 1}"
            planche(fichiers[k:k + 40], os.path.join(o.sortie, f"planche-{cle}{suffixe}.jpg"), o.colonnes)
        print(f"{cle} : {len(fichiers)} images")


if __name__ == "__main__":
    main()
