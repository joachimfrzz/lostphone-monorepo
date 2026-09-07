#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Vérificateur statique de src/SncfApp.swift (Lost Phone — vague B, app SNCF Connect).

Contrôle, sans compilateur :
  1. équilibre des accolades / parenthèses / crochets (hors chaînes et commentaires) ;
  2. préfixe de types Sn sur TOUS les types déclarés ;
  3. APIs interdites (iOS 18+/26, MapKit, réseau, UIApplication.open, Task.sleep nu…) ;
  4. absence de .sheet / .fullScreenCover / .confirmationDialog ;
  5. clés dupliquées dans les switch du registre et dans les dictionnaires littéraux ;
  6. ternaires de style non typés (`? .x : .y`) ;
  7. redéfinition de helpers déjà fournis par LPProto ;
  8. présence de la vue racine, de l'enveloppe de capture et de la palette mesurée ;
  9. absence de micro de dictée et de contenu « gabarit » de Joachim (D59).
Sortie : VERT (code 0) ou liste des erreurs (code 1).
"""
import re
import sys
import os

CHEMIN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "SncfApp.swift")
PREFIXE = "Sn"
erreurs = []
avertissements = []


def lire():
    with open(CHEMIN, encoding="utf-8") as f:
        return f.read()


def sans_chaines_ni_commentaires(src):
    """Remplace le contenu des chaînes et des commentaires par des espaces."""
    sortie = []
    i = 0
    n = len(src)
    while i < n:
        c = src[i]
        if c == '"':
            # chaîne (pas de multi-lignes """ dans ce fichier, mais on gère quand même)
            if src.startswith('"""', i):
                j = src.find('"""', i + 3)
                j = n if j == -1 else j + 3
                sortie.append(" " * (j - i))
                i = j
                continue
            j = i + 1
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == '"':
                    j += 1
                    break
                if src[j] == "\n":
                    break
                j += 1
            sortie.append(" " * (j - i))
            i = j
            continue
        if src.startswith("//", i):
            j = src.find("\n", i)
            j = n if j == -1 else j
            sortie.append(" " * (j - i))
            i = j
            continue
        if src.startswith("/*", i):
            j = src.find("*/", i + 2)
            j = n if j == -1 else j + 2
            sortie.append(" " * (j - i))
            i = j
            continue
        sortie.append(c)
        i += 1
    return "".join(sortie)


def verifier_equilibre(nu):
    paires = {"{": "}", "(": ")", "[": "]"}
    fermantes = {v: k for k, v in paires.items()}
    pile = []
    ligne = 1
    for ch in nu:
        if ch == "\n":
            ligne += 1
        elif ch in paires:
            pile.append((ch, ligne))
        elif ch in fermantes:
            if not pile:
                erreurs.append("Ligne %d : « %s » fermant sans ouvrant." % (ligne, ch))
                return
            ouvrant, l0 = pile.pop()
            if paires[ouvrant] != ch:
                erreurs.append(
                    "Ligne %d : « %s » ferme un « %s » ouvert ligne %d."
                    % (ligne, ch, ouvrant, l0))
                return
    if pile:
        ouvrant, l0 = pile[-1]
        erreurs.append("« %s » ouvert ligne %d jamais fermé (%d en attente)."
                       % (ouvrant, l0, len(pile)))


def verifier_prefixes(nu):
    motif = re.compile(r"\b(?:struct|class|enum|protocol|actor)\s+([A-Za-z_][A-Za-z0-9_]*)")
    for m in motif.finditer(nu):
        nom = m.group(1)
        if not nom.startswith(PREFIXE):
            ligne = nu[:m.start()].count("\n") + 1
            erreurs.append("Ligne %d : type « %s » sans le préfixe « %s »."
                           % (ligne, nom, PREFIXE))
    # fonctions globales (colonne 0)
    for i, l in enumerate(nu.split("\n"), 1):
        if re.match(r"^func\s+([A-Za-z_][A-Za-z0-9_]*)", l):
            nom = re.match(r"^func\s+([A-Za-z_][A-Za-z0-9_]*)", l).group(1)
            if not nom.startswith(PREFIXE.lower()) and not nom.startswith(PREFIXE):
                erreurs.append("Ligne %d : fonction globale « %s » sans préfixe." % (i, nom))


INTERDITS = [
    (r"\.tabViewStyle\(\s*\.sidebarAdaptable", "tabViewStyle(.sidebarAdaptable) — iOS 18+"),
    (r"@Entry\b", "@Entry — iOS 18+"),
    (r"\bTab\s*\(", "Tab(...) — iOS 18+"),
    (r"\.glassEffect", "glassEffect — iOS 26"),
    (r"\.presentationSizing", "presentationSizing — iOS 17.1+/18"),
    (r"\bimport\s+MapKit\b", "MapKit interdit"),
    (r"\bMap\s*\(\s*coordinateRegion", "MapKit interdit"),
    (r"UIApplication\.shared\.open", "UIApplication.shared.open interdit"),
    (r"\bURLSession\b", "réseau interdit"),
    (r"\bimport\s+Combine\b", "import Combine inutile"),
    (r"\bscrollTargetBehavior\b", "scrollTargetBehavior — iOS 17 partiel, éviter"),
    (r"\bonScrollGeometryChange\b", "onScrollGeometryChange — iOS 18+"),
    (r"\.symbolEffect\(", "symbolEffect — iOS 17 mais instable en capture"),
    (r"\bContentUnavailableView\b", "ContentUnavailableView — éviter (iOS 17, style système)"),
    (r"\bAnyLayout\b", "AnyLayout — éviter"),
]

FEUILLES = [
    (r"\.sheet\s*\(", ".sheet interdit (masque BarreHome) — overlay interne obligatoire"),
    (r"\.fullScreenCover\s*\(", ".fullScreenCover interdit"),
    (r"\.confirmationDialog\s*\(", ".confirmationDialog interdit"),
    (r"\.popover\s*\(", ".popover interdit"),
]

HELPERS_EXISTANTS = ["BarreHome", "AvatarSilhouette", "ErreurLambda", "Haptique",
                     "CoquilleSarah", "Routeur"]


def verifier_interdits(nu):
    for motif, msg in INTERDITS + FEUILLES:
        for m in re.finditer(motif, nu):
            ligne = nu[:m.start()].count("\n") + 1
            erreurs.append("Ligne %d : %s." % (ligne, msg))


def verifier_helpers(nu):
    for h in HELPERS_EXISTANTS:
        for m in re.finditer(r"\b(?:struct|class|enum)\s+%s\b" % h, nu):
            ligne = nu[:m.start()].count("\n") + 1
            erreurs.append("Ligne %d : redéfinition du helper existant « %s »." % (ligne, h))
    if re.search(r"extension\s+Color\s*\{", nu):
        erreurs.append("Redéfinition de « extension Color » (Color(hex:) existe déjà).")


def verifier_ternaires(nu):
    """Ternaire de style non typé : `? .foo : .bar` (erreur de compilation réelle)."""
    for m in re.finditer(r"\?\s*\.[A-Za-z_][A-Za-z0-9_]*\s*:\s*\.[A-Za-z_]", nu):
        ligne = nu[:m.start()].count("\n") + 1
        erreurs.append("Ligne %d : ternaire de style non typé (`? .x : .y`)." % ligne)


def verifier_task_sleep(nu):
    for m in re.finditer(r"(?<!try\?\s)(?<!try\s)Task\.sleep", nu):
        ligne = nu[:m.start()].count("\n") + 1
        contexte = nu[max(0, m.start() - 20):m.start()]
        if "try" not in contexte:
            erreurs.append("Ligne %d : Task.sleep sans try?." % ligne)


def verifier_cles_switch(src):
    """Aucune clé de chaîne dupliquée dans un même bloc `switch` / dictionnaire."""
    cles = re.findall(r'case\s+"([a-z0-9._#]+)"', src)
    vus = {}
    for c in cles:
        vus[c] = vus.get(c, 0) + 1
    for c, n in vus.items():
        if n > 1:
            erreurs.append("Clé de registre dupliquée : « %s » (%d fois)." % (c, n))


def verifier_dictionnaires(src):
    """Clés littérales dupliquées dans un dictionnaire Swift `[... : ...]`."""
    for bloc in re.finditer(r"\[\s*((?:\"[^\"]*\"\s*:\s*[^,\[\]]+,\s*){2,}[^\[\]]*)\]", src):
        cles = re.findall(r'"([^"]*)"\s*:', bloc.group(1))
        if len(cles) != len(set(cles)):
            ligne = src[:bloc.start()].count("\n") + 1
            erreurs.append("Ligne %d : clé dupliquée dans un dictionnaire littéral." % ligne)


def verifier_presence(src, nu):
    attendus = [
        (r"struct\s+SncfVue\s*:\s*View", "vue racine SncfVue"),
        (r"init\(onglet:\s*Int\s*=\s*0\)", "init(onglet: Int = 0) de la racine"),
        (r"struct\s+SnEcranCapture", "enveloppe de capture SnEcranCapture"),
        (r"enum\s+SnCapture", "enum SnCapture"),
        (r"static\s+func\s+etat\(\)\s*->\s*SnEtat", "SnCapture.etat()"),
        (r"enum\s+SnTeinte", "palette SnTeinte"),
        (r"final\s+class\s+SnEtat\s*:\s*ObservableObject", "magasin SnEtat"),
        (r"static\s+let\s+partage\s*=\s*SnEtat\(\)", "SnEtat.partage"),
        (r"BarreHome\s*\{\s*quitter\(\)\s*\}", "BarreHome pilotée par la racine"),
        (r"enum\s+SnDonneesSncf", "données remplaçables SnDonneesSncf"),
        (r"import\s+SwiftUI", "import SwiftUI"),
    ]
    for motif, quoi in attendus:
        if not re.search(motif, nu if "BarreHome" not in motif else nu):
            erreurs.append("Élément attendu manquant : %s." % quoi)
    # un seul navigationDestination au maximum, et aucun ici (tout passe par NavigationLink)
    n = len(re.findall(r"\.navigationDestination\(", nu))
    if n > 1:
        erreurs.append("%d navigationDestination : un seul par NavigationStack." % n)
    # @Published hors ObservableObject
    for m in re.finditer(r"@Published", nu):
        ligne = nu[:m.start()].count("\n") + 1
        avant = nu[:m.start()]
        derniere_classe = avant.rfind("final class SnEtat")
        derniere_struct = max(avant.rfind("\nstruct "), avant.rfind("\nenum "))
        if derniere_classe < derniere_struct:
            erreurs.append("Ligne %d : @Published hors ObservableObject." % ligne)


# « Toulouse Matabiau » reste autorisé : c'est une gare nationale que Sarah peut
# rechercher, pas le contenu par défaut de Joachim (dont la gare était Auch).
D59_INTERDITS = ["Joachim", "Fourez", "Auch", "Colomiers", "Telegram",
                 "Qamify", "BlackHatWorld", "Star Academy", "28/07/2003", "0643491426",
                 "06 43 49 14 26"]


def verifier_d59(src):
    for mot in D59_INTERDITS:
        for m in re.finditer(re.escape(mot), src):
            ligne = src[:m.start()].count("\n") + 1
            # les commentaires d'en-tête citent les gabarits : on ne les compte pas
            debut = src.rfind("\n", 0, m.start()) + 1
            if src[debut:m.start()].lstrip().startswith("//"):
                continue
            erreurs.append("Ligne %d : contenu gabarit de Joachim resté dans le code "
                           "(« %s ») — D59." % (ligne, mot))


def verifier_micro(src):
    for motif in [r'"mic\b', r'systemName:\s*"mic', r"Micro de dictée"]:
        for m in re.finditer(motif, src):
            ligne = src[:m.start()].count("\n") + 1
            erreurs.append("Ligne %d : micro de dictée interdit." % ligne)


def verifier_longueur_body(src):
    """body de plus de 60 lignes → risque de « expression too complex »."""
    lignes = src.split("\n")
    i = 0
    while i < len(lignes):
        if re.search(r"var body:\s*some View\s*\{", lignes[i]):
            profondeur = 0
            debut = i
            j = i
            while j < len(lignes):
                profondeur += lignes[j].count("{") - lignes[j].count("}")
                if profondeur <= 0 and j > debut:
                    break
                j += 1
            if j - debut > 60:
                avertissements.append("Ligne %d : body de %d lignes (> 60)."
                                      % (debut + 1, j - debut))
            i = j
        i += 1


def main():
    src = lire()
    nu = sans_chaines_ni_commentaires(src)
    verifier_equilibre(nu)
    verifier_prefixes(nu)
    verifier_interdits(nu)
    verifier_helpers(nu)
    verifier_ternaires(nu)
    verifier_task_sleep(nu)
    verifier_cles_switch(src)
    verifier_dictionnaires(src)
    verifier_presence(src, nu)
    verifier_d59(src)
    verifier_micro(src)
    verifier_longueur_body(src)

    print("Vérification de %s (%d lignes)" % (os.path.basename(CHEMIN),
                                              src.count("\n") + 1))
    for a in avertissements:
        print("  ~ AVERTISSEMENT : %s" % a)
    if erreurs:
        print("")
        for e in erreurs:
            print("  X %s" % e)
        print("\nROUGE — %d erreur(s)." % len(erreurs))
        return 1
    print("  . accolades / parenthèses / crochets équilibrés")
    print("  . tous les types portent le préfixe « Sn »")
    print("  . aucune API iOS 18+/26, aucun MapKit, aucun réseau")
    print("  . aucun .sheet / .fullScreenCover / .confirmationDialog")
    print("  . aucune clé de registre ni de dictionnaire dupliquée")
    print("  . aucun ternaire de style non typé")
    print("  . aucun helper LPProto redéfini")
    print("  . racine SncfVue(onglet:), SnCapture, SnEcranCapture, SnEtat.partage présents")
    print("  . aucun contenu gabarit de Joachim (D59), aucun micro de dictée")
    print("\nVERT.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
