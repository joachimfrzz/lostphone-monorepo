#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Vérificateur statique de src/FaceTimeApp.swift (Lost Phone — vague B, app FaceTime).

Il n'y a PAS de compilateur Swift ici : ce script attrape les erreurs qui ont
réellement coûté des builds rouges à Joachim (accolades, ternaires non typés,
`.sheet` qui masque la BarreHome, clés de dictionnaire en double, APIs iOS 18+/26,
redéfinition d'un helper partagé, collision de préfixe).

Usage :  python3 src/verif_facetime.py
Sortie :  VERT (code 0) ou liste d'erreurs (code 1).
"""

import os
import re
import sys

RACINE = os.path.dirname(os.path.abspath(__file__))
CIBLE = os.path.join(RACINE, "FaceTimeApp.swift")
PREFIXE = "Ft"
RACINE_VUE = "FaceTimeVue"

erreurs = []
avertissements = []


def erreur(msg):
    erreurs.append(msg)


def avert(msg):
    avertissements.append(msg)


# ------------------------------------------------------------------ lecture
if not os.path.exists(CIBLE):
    print("ERREUR : %s introuvable" % CIBLE)
    sys.exit(1)

with open(CIBLE, encoding="utf-8") as f:
    source = f.read()
lignes = source.split("\n")


# ------------------------------------------------------------------ 1. nettoyage (hors chaînes / commentaires)
def sans_chaines_ni_commentaires(texte):
    """Remplace le contenu des chaînes et des commentaires par des espaces,
    en conservant la longueur et les retours à la ligne (numéros de ligne exacts)."""
    sortie = []
    i = 0
    n = len(texte)
    etat = "code"  # code | chaine | ligne | bloc
    profondeur_bloc = 0
    while i < n:
        c = texte[i]
        suivant = texte[i + 1] if i + 1 < n else ""
        if etat == "code":
            if c == '"':
                etat = "chaine"
                sortie.append(" ")
            elif c == "/" and suivant == "/":
                etat = "ligne"
                sortie.append("  ")
                i += 2
                continue
            elif c == "/" and suivant == "*":
                etat = "bloc"
                profondeur_bloc = 1
                sortie.append("  ")
                i += 2
                continue
            else:
                sortie.append(c)
        elif etat == "chaine":
            if c == "\\":
                sortie.append("  ")
                i += 2
                continue
            if c == '"':
                etat = "code"
            sortie.append("\n" if c == "\n" else " ")
        elif etat == "ligne":
            if c == "\n":
                etat = "code"
                sortie.append("\n")
            else:
                sortie.append(" ")
        elif etat == "bloc":
            if c == "/" and suivant == "*":
                profondeur_bloc += 1
                sortie.append("  ")
                i += 2
                continue
            if c == "*" and suivant == "/":
                profondeur_bloc -= 1
                sortie.append("  ")
                i += 2
                if profondeur_bloc == 0:
                    etat = "code"
                continue
            sortie.append("\n" if c == "\n" else " ")
        i += 1
    return "".join(sortie)


propre = sans_chaines_ni_commentaires(source)
lignes_propres = propre.split("\n")

# NB : l'interpolation "\(x)" est neutralisée avec le reste de la chaîne — c'est
# volontaire : on ne veut pas d'analyse de code à l'intérieur des littéraux.

# ------------------------------------------------------------------ 2. équilibre des délimiteurs
paires = {"{": "}", "(": ")", "[": "]"}
fermantes = {v: k for k, v in paires.items()}
pile = []
for numero, ligne in enumerate(lignes_propres, start=1):
    for c in ligne:
        if c in paires:
            pile.append((c, numero))
        elif c in fermantes:
            if not pile:
                erreur("l.%d : '%s' fermant sans ouvrant" % (numero, c))
            elif pile[-1][0] != fermantes[c]:
                ouvrant, l_ouvrant = pile[-1]
                erreur("l.%d : '%s' ferme un '%s' ouvert l.%d" % (numero, c, ouvrant, l_ouvrant))
                pile.pop()
            else:
                pile.pop()
if pile:
    for ouvrant, numero in pile[:6]:
        erreur("l.%d : '%s' jamais fermé" % (numero, ouvrant))

n_ouvrantes = propre.count("{")
n_fermantes = propre.count("}")
if n_ouvrantes != n_fermantes:
    erreur("accolades déséquilibrées : %d '{' pour %d '}'" % (n_ouvrantes, n_fermantes))

# ------------------------------------------------------------------ 3. APIs interdites (règle 8 / 10 / 12)
INTERDITS = [
    (r"\.sheet\s*\(", ".sheet — interdit (bug Facebook 279 : masque la BarreHome)"),
    (r"\.fullScreenCover\s*\(", ".fullScreenCover — interdit (masque la BarreHome)"),
    (r"\.confirmationDialog\s*\(", ".confirmationDialog — interdit (plein écran)"),
    (r"\.popover\s*\(", ".popover — interdit"),
    (r"\.tabViewStyle\s*\(\s*\.sidebarAdaptable", "API iOS 18+ : .tabViewStyle(.sidebarAdaptable)"),
    (r"@Entry\b", "API iOS 18+ : @Entry"),
    (r"\.glassEffect\b", "API iOS 26 : .glassEffect"),
    (r"\.presentationSizing\b", "API iOS 18+ : .presentationSizing"),
    (r"\bTab\s*\(", "API iOS 18+ : Tab(...)"),
    (r"\.scrollEdgeEffect\b", "API iOS 26 : .scrollEdgeEffect"),
    (r"\.symbolColorRenderingMode\b", "API iOS 26 : .symbolColorRenderingMode"),
    (r"UIApplication\.shared\.open", "UIApplication.shared.open — interdit"),
    (r"\bimport\s+MapKit\b", "MapKit réel — interdit"),
    (r"\bURLSession\b", "réseau — interdit"),
    (r"\bMap\s*\(\s*coordinateRegion", "MapKit réel — interdit"),
    (r"\bNavigationView\b", "NavigationView déprécié — utiliser NavigationStack"),
    (r"\.foregroundColor\s*\(", ".foregroundColor déprécié — utiliser .foregroundStyle"),
]
for motif, libelle in INTERDITS:
    for numero, ligne in enumerate(lignes_propres, start=1):
        if re.search(motif, ligne):
            erreur("l.%d : %s" % (numero, libelle))

# Task.sleep doit toujours être précédé d'un try?
for numero, ligne in enumerate(lignes_propres, start=1):
    if "Task.sleep" in ligne and "try?" not in ligne:
        erreur("l.%d : Task.sleep sans try?" % numero)

# ------------------------------------------------------------------ 4. ternaires de style non typés
# `cond ? .rouge : .blanc` : Swift n'arrive pas à inférer le type → erreur réelle rencontrée.
motif_ternaire = re.compile(r"\?\s*\.[A-Za-z_][A-Za-z0-9_]*\s*:\s*\.[A-Za-z_]")
for numero, ligne in enumerate(lignes_propres, start=1):
    if motif_ternaire.search(ligne):
        erreur("l.%d : ternaire de style NON typé (`? .a : .b`) — préfixer par le type" % numero)

# `.background(Color.x.opacity(...), in: Shape)` : surcharge ambiguë
motif_fond = re.compile(r"\.background\([^)]*opacity\([^)]*\)[^)]*,\s*in:")
for numero, ligne in enumerate(lignes_propres, start=1):
    if motif_fond.search(ligne):
        erreur("l.%d : .background(Color.opacity(...), in: Shape) ambigu — utiliser Shape().fill(...)" % numero)

# `.scaledToFill()` nu dans une cellule : doit être encapsulé
for numero, ligne in enumerate(lignes_propres, start=1):
    if ".scaledToFill()" in ligne and "resizable()" not in ligne:
        avert("l.%d : .scaledToFill() sans .resizable() sur la même ligne — à vérifier" % numero)

# ------------------------------------------------------------------ 5. un seul navigationDestination
n_dest = len(re.findall(r"\.navigationDestination\s*\(", propre))
if n_dest > 1:
    erreur("%d `.navigationDestination` — la règle en autorise UN SEUL par NavigationStack" % n_dest)
if n_dest == 0:
    avert("aucun `.navigationDestination` — vérifier que la fiche détail est atteignable")

# ------------------------------------------------------------------ 6. déclarations : préfixe unique
motif_decl = re.compile(
    r"^\s*(?:public\s+|private\s+|fileprivate\s+|internal\s+|final\s+)*"
    r"(struct|class|enum|protocol|actor)\s+([A-Za-z_][A-Za-z0-9_]*)"
)
TOLERES = {RACINE_VUE, "DonneesFt"}   # convention imposée : `DonneesXx` (cf. DonneesTel, DonneesMsg)
declares = []
for numero, ligne in enumerate(lignes_propres, start=1):
    m = motif_decl.match(ligne)
    if not m:
        continue
    nom = m.group(2)
    declares.append(nom)
    if nom in TOLERES:
        continue
    if not nom.startswith(PREFIXE):
        erreur("l.%d : type `%s` sans le préfixe `%s`" % (numero, nom, PREFIXE))

# extensions et fonctions globales
for numero, ligne in enumerate(lignes_propres, start=1):
    if re.match(r"^\s*extension\s+", ligne):
        erreur("l.%d : `extension` au niveau du fichier — risque de collision inter-apps" % numero)
    m = re.match(r"^(?:public\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)", ligne)
    if m and not m.group(1).startswith(PREFIXE):
        erreur("l.%d : fonction globale `%s` sans préfixe `%s`" % (numero, m.group(1), PREFIXE))
    m = re.match(r"^(?:public\s+)?(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)", ligne)
    if m and not m.group(1).startswith(PREFIXE):
        erreur("l.%d : variable globale `%s` sans préfixe `%s`" % (numero, m.group(1), PREFIXE))

# doublons de déclaration dans le fichier
vus = set()
for nom in declares:
    if nom in vus:
        erreur("type `%s` déclaré deux fois dans le fichier" % nom)
    vus.add(nom)

# ------------------------------------------------------------------ 7. helpers partagés jamais redéfinis
HELPERS = [
    "BarreHome", "AvatarSilhouette", "Haptique", "ErreurLambda", "LecteurAudio",
    "AppelVue", "AppelVideoVue", "RondAppel", "Routeur", "FeuillePartage",
    "ModeAppel", "coquilleSarah", "chargerPellicule", "SousReglageVue",
]
for helper in HELPERS:
    motif = re.compile(r"^\s*(?:public\s+|private\s+|final\s+)*(struct|class|enum|func)\s+%s\b" % helper)
    for numero, ligne in enumerate(lignes_propres, start=1):
        if motif.match(ligne):
            erreur("l.%d : redéfinition du helper partagé `%s`" % (numero, helper))
if re.search(r"extension\s+Color\s*\{", propre):
    erreur("redéfinition de `Color(hex:)` (extension Color) — déjà dans LPProto")

# ------------------------------------------------------------------ 8. clés de dictionnaire en double
# Crash fatal Swift (build 274). On inspecte chaque littéral `[ "..." : ... ]`.
for m in re.finditer(r"=\s*\[", source):
    debut = m.end() - 1
    profondeur = 0
    fin = debut
    for i in range(debut, len(source)):
        if source[i] == "[":
            profondeur += 1
        elif source[i] == "]":
            profondeur -= 1
            if profondeur == 0:
                fin = i
                break
    bloc = source[debut:fin + 1]
    cles = re.findall(r'"([^"\\]*)"\s*:', bloc)
    doublons = set(c for c in cles if cles.count(c) > 1)
    if doublons:
        numero = source[:debut].count("\n") + 1
        erreur("l.%d : clés de dictionnaire en double : %s" % (numero, ", ".join(sorted(doublons))))

# ------------------------------------------------------------------ 9. longueur des `body`
numero = 0
while numero < len(lignes_propres):
    ligne = lignes_propres[numero]
    if re.search(r"\bvar\s+body\s*:\s*some\s+View\s*\{", ligne):
        profondeur = 0
        debut = numero
        for j in range(numero, len(lignes_propres)):
            profondeur += lignes_propres[j].count("{") - lignes_propres[j].count("}")
            if profondeur <= 0 and j > numero:
                longueur = j - debut + 1
                if longueur > 60:
                    erreur("l.%d : `body` de %d lignes (> 60) — découper en sous-vues" % (debut + 1, longueur))
                numero = j
                break
    numero += 1

# ------------------------------------------------------------------ 10. contrat de la coque et du registre
ATTENDUS = [
    (r"struct\s+%s\s*:\s*View" % RACINE_VUE, "vue racine `%s`" % RACINE_VUE),
    (r"@Environment\(\\\.dismiss\)", "`@Environment(\\.dismiss)` de la racine"),
    (r"BarreHome\s*\{", "BarreHome dessinée par l'app"),
    (r"enum\s+FtTeinte", "palette `FtTeinte`"),
    (r"enum\s+DonneesFt", "données remplaçables `DonneesFt` (D59)"),
    (r"final\s+class\s+FtEtat\s*:\s*ObservableObject", "magasin `FtEtat: ObservableObject`"),
    (r"static\s+let\s+partage\s*=\s*FtEtat\(\)", "`FtEtat.static let partage`"),
    (r"enum\s+FtCapture", "`FtCapture`"),
    (r"static\s+func\s+etat\(\)\s*->\s*FtEtat", "`FtCapture.etat()`"),
    (r"struct\s+FtEcranCapture", "enveloppe `FtEcranCapture`"),
    (r"NavigationStack", "NavigationStack"),
    (r"\.toolbar\(\.hidden,\s*for:\s*\.navigationBar\)", "`.toolbar(.hidden, for: .navigationBar)`"),
]
for motif, libelle in ATTENDUS:
    if not re.search(motif, propre):
        erreur("manquant : %s" % libelle)

# @Published uniquement dans un ObservableObject
for numero, ligne in enumerate(lignes_propres, start=1):
    if "@Published" in ligne:
        contexte = "\n".join(lignes_propres[max(0, numero - 60):numero])
        if "ObservableObject" not in contexte:
            erreur("l.%d : @Published hors d'un ObservableObject" % numero)

# les écrans annoncés au registre doivent exister
ECRANS = [
    "FtListeVue", "FtNouveauVue", "FtAppelVue", "FtEnregistrementVue",
    "FtLecteurMessageVue", "FtDetailVue", "FtLienVue",
]
for nom in ECRANS:
    if not re.search(r"struct\s+%s\s*:\s*View" % nom, propre):
        erreur("écran du registre manquant : `%s`" % nom)

# ------------------------------------------------------------------ 11. D59 — aucune donnée de Joachim
INTERDITS_D59 = ["Joachim", "Fourez", "Colomiers", "Auch", "BlackHatWorld", "Qamify",
                 "Star Academy", "Telegram", "Jolien", "Jean Bertin"]
# On ne regarde que le TEXTE AFFICHÉ (littéraux de chaîne) : les commentaires de
# conception ont le droit de citer Joachim, l'écran non.
litteraux = re.findall(r'"((?:[^"\\\n]|\\.)*)"', source)
texte_affiche = " | ".join(litteraux)
for mot in INTERDITS_D59:
    if re.search(r"\b%s\b" % re.escape(mot), texte_affiche, flags=re.I):
        erreur("D59 : le gabarit « %s » apparaît dans un texte affiché" % mot)

# ------------------------------------------------------------------ 12. imports
imports = re.findall(r"^import\s+(\w+)", source, flags=re.M)
autorises = {"SwiftUI", "UIKit", "AVFoundation"}
for nom in imports:
    if nom not in autorises:
        erreur("import non autorisé : %s" % nom)
if "SwiftUI" not in imports:
    erreur("`import SwiftUI` manquant")

# ------------------------------------------------------------------ rapport
print("Vérification de %s" % os.path.relpath(CIBLE, os.path.dirname(RACINE)))
print("  %d lignes, %d types déclarés, %d '{' / %d '}'"
      % (len(lignes), len(declares), n_ouvrantes, n_fermantes))

for a in avertissements:
    print("  ~ %s" % a)

if erreurs:
    print("")
    print("ROUGE — %d erreur(s) :" % len(erreurs))
    for e in erreurs:
        print("  x %s" % e)
    sys.exit(1)

print("")
print("VERT — aucune erreur détectée.")
sys.exit(0)
