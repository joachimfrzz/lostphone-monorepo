#!/usr/bin/env python3
"""Mesure de captures (D95, méthode BAMA « measure ») — Python pur, sans Pillow.

Coordonnées en PIXELS de la capture (iPhone 17 : 1206×2622, échelle ×3 → points = px / 3).

  info     <png>                         taille, échelle supposée
  couleur  <png> x y [w h]               couleur moyenne d'une zone (hex) — zones unies : robuste à la compression
  hligne   <png> y [x0 x1]               segments de couleur le long d'une ligne horizontale
  vligne   <png> x [y0 y1]               segments de couleur le long d'une ligne verticale (pas des rangées, bords)
  texte    <png> x0 x1 [y0 y1]           bandes horizontales contenant de l'« encre » (texte/icônes) entre x0 et x1
  rayon    <png> x y_haut                rayon d'angle d'une carte : bord gauche x, bord haut y_haut (px)

Tolérance de segmentation : --tol (défaut 6, distance max entre pixels voisins d'un même segment).
"""
import struct
import sys
import zlib


def lire_png(chemin):
    data = open(chemin, "rb").read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", "pas un PNG"
    pos, idat, w = 8, [], None
    while pos < len(data):
        n = struct.unpack(">I", data[pos:pos + 4])[0]
        t = data[pos + 4:pos + 8]
        c = data[pos + 8:pos + 8 + n]
        if t == b"IHDR":
            w, h, prof, typ = struct.unpack(">IIBB", c[:10])
            assert prof == 8, "profondeur 8 bits seulement"
            canaux = {2: 3, 6: 4, 0: 1, 4: 2}[typ]
        elif t == b"IDAT":
            idat.append(c)
        pos += 12 + n
    brut = zlib.decompress(b"".join(idat))
    bpp, stride = canaux, w * canaux
    lignes, prec, i = [], bytearray(stride), 0
    for _ in range(h):
        f = brut[i]
        ligne = bytearray(brut[i + 1:i + 1 + stride])
        i += 1 + stride
        if f == 1:
            for x in range(bpp, stride):
                ligne[x] = (ligne[x] + ligne[x - bpp]) & 255
        elif f == 2:
            for x in range(stride):
                ligne[x] = (ligne[x] + prec[x]) & 255
        elif f == 3:
            for x in range(stride):
                g = ligne[x - bpp] if x >= bpp else 0
                ligne[x] = (ligne[x] + ((g + prec[x]) >> 1)) & 255
        elif f == 4:
            for x in range(stride):
                a = ligne[x - bpp] if x >= bpp else 0
                b = prec[x]
                c_ = prec[x - bpp] if x >= bpp else 0
                p = a + b - c_
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c_)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c_)
                ligne[x] = (ligne[x] + pr) & 255
        lignes.append(ligne)
        prec = ligne
    return Image(w, h, canaux, lignes)


class Image:
    def __init__(self, w, h, canaux, lignes):
        self.w, self.h, self.c, self.l = w, h, canaux, lignes

    def px(self, x, y):
        l, k = self.l[y], x * self.c
        if self.c >= 3:
            return l[k], l[k + 1], l[k + 2]
        return l[k], l[k], l[k]


def hexa(rgb):
    return "#%02X%02X%02X" % tuple(int(round(v)) for v in rgb)


def dist(a, b):
    return max(abs(a[0] - b[0]), abs(a[1] - b[1]), abs(a[2] - b[2]))


def segments(pixels, tol, depart=0):
    segs, debut, ref = [], 0, pixels[0]
    for i in range(1, len(pixels)):
        if dist(pixels[i], pixels[i - 1]) > tol:
            segs.append((depart + debut, depart + i - 1, pixels[(debut + i - 1) // 2]))
            debut = i
    segs.append((depart + debut, depart + len(pixels) - 1, pixels[(debut + len(pixels) - 1) // 2]))
    return segs


def afficher_segments(segs, mini=3):
    for a, b, c in segs:
        if b - a + 1 >= mini:
            print(f"  {a:5d}–{b:5d}  ({b - a + 1:4d} px = {(b - a + 1) / 3:6.1f} pt)  {hexa(c)}")


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    tol = 6
    for a in sys.argv[1:]:
        if a.startswith("--tol="):
            tol = int(a.split("=")[1])
    if len(args) < 2:
        print(__doc__)
        return
    cmd, img = args[0], lire_png(args[1])
    n = [int(v) for v in args[2:]]
    if cmd == "info":
        print(f"{img.w}×{img.h} px = {img.w / 3:.0f}×{img.h / 3:.0f} pt (×3)")
    elif cmd == "couleur":
        x, y = n[0], n[1]
        w, h = (n[2], n[3]) if len(n) >= 4 else (1, 1)
        s = [0, 0, 0]
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                p = img.px(xx, yy)
                for k in range(3):
                    s[k] += p[k]
        print(hexa([v / (w * h) for v in s]))
    elif cmd == "hligne":
        y = n[0]
        x0, x1 = (n[1], n[2]) if len(n) >= 3 else (0, img.w - 1)
        afficher_segments(segments([img.px(x, y) for x in range(x0, x1 + 1)], tol, x0))
    elif cmd == "vligne":
        x = n[0]
        y0, y1 = (n[1], n[2]) if len(n) >= 3 else (0, img.h - 1)
        afficher_segments(segments([img.px(x, y) for y in range(y0, y1 + 1)], tol, y0))
    elif cmd == "texte":
        x0, x1 = n[0], n[1]
        y0, y1 = (n[2], n[3]) if len(n) >= 4 else (0, img.h - 1)
        bandes, debut = [], None
        for y in range(y0, y1 + 1):
            fond = img.px(x0, y)
            encre = any(dist(img.px(x, y), fond) > 40 for x in range(x0, x1 + 1, 2))
            if encre and debut is None:
                debut = y
            elif not encre and debut is not None:
                bandes.append((debut, y - 1))
                debut = None
        if debut is not None:
            bandes.append((debut, y1))
        for a, b in bandes:
            print(f"  {a:5d}–{b:5d}  hauteur {b - a + 1:4d} px = {(b - a + 1) / 3:5.1f} pt   centre {(a + b) / 2:7.1f}")
        if len(bandes) > 1:
            pas = [((bandes[i + 1][0] + bandes[i + 1][1]) - (bandes[i][0] + bandes[i][1])) / 2 for i in range(len(bandes) - 1)]
            print("  pas entre centres (px) :", " ".join(f"{p:.0f}" for p in pas))
    elif cmd == "rayon":
        # Le long du bord haut de la carte, trouver où la couleur de la carte commence à chaque ligne :
        # le décalage horizontal à y_haut donne le rayon (approximation d'un quart de cercle).
        x, y = n[0], n[1]
        carte = img.px(x + 200, y + 200)
        for dy in range(0, 120):
            xx = x
            while xx < x + 200 and dist(img.px(xx, y + dy), carte) > 12:
                xx += 1
            if xx - x <= 1:
                print(f"  bord vertical atteint à dy={dy} px → rayon ≈ {dy} px = {dy / 3:.1f} pt")
                break
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
