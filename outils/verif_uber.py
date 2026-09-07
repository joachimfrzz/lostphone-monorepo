#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Vérificateur statique de src/UberApp.swift (vague B — app Uber, préfixe Ub).

Contrôles :
  1. accolades / parenthèses / crochets équilibrés (hors chaînes et commentaires)
  2. préfixe Ub sur TOUS les types déclarés (struct / enum / class / protocol)
     + les deux dérogations documentées (UberVue, DonneesUb)
  3. APIs interdites (iOS 18+/26, MapKit, réseau, UIApplication.shared.open…)
  4. .sheet / .fullScreenCover / .confirmationDialog absents
  5. clés dupliquées dans les dictionnaires littéraux
  6. ternaires de style non typés (`? .rouge : .blanc`)
  7. redéfinition des helpers partagés de la coque
  8. `Task.sleep` sans `try?`
  9. présence des écrans attendus par le registre LPProto

Sortie : VERT si aucun problème, sinon la liste des anomalies (code de retour 1).
"""

import re
import sys
import os

CHEMIN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "UberApp.swift")

PREFIXE = "Ub"
DEROGATIONS = {"UberVue"}          # vue racine imposée par la mission

APIS_INTERDITES = [
    (r"\bimport\s+MapKit\b", "MapKit interdit (cartes dessinées)"),
    (r"\bMap\s*\(", "MapKit Map() interdit"),
    (r"\.tabViewStyle\(\s*\.sidebarAdaptable", "API iOS 18+"),
    (r"@Entry\b", "API iOS 18+"),
    (r"\bTab\s*\(\s*\"", "Tab(...) = API iOS 18+"),
    (r"\.glassEffect", "API iOS 26"),
    (r"\.presentationSizing", "API iOS 17.1+/18"),
    (r"\.scrollEdgeEffect", "API iOS 26"),
    (r"\bNavigationSplitView\b", "non utilisé dans la coque"),
    (r"UIApplication\.shared\.open", "ouverture d'URL interdite"),
    (r"\bURLSession\b", "réseau interdit"),
    (r"\bonAppear\s*\{\s*UIApplication", "réseau/URL interdit"),
    (r"\.onGeometryChange", "API iOS 18+"),
    (r"\bScrollView\(.*\)\s*\.scrollTargetBehavior\(\s*\.viewAligned", "API iOS 17 ok mais non utilisée ici"),
]

FEUILLES_INTERDITES = [
    (r"\.sheet\s*\(", ".sheet interdit (masque BarreHome — bug Facebook 279)"),
    (r"\.fullScreenCover\s*\(", ".fullScreenCover interdit dans une app"),
    (r"\.confirmationDialog\s*\(", ".confirmationDialog interdit"),
    (r"\.popover\s*\(", ".popover interdit"),
]

HELPERS_PARTAGES = [
    "struct BarreHome", "struct AvatarSilhouette", "enum Haptique",
    "enum ErreurLambda", "struct ErreurLambda", "extension Color",
    "func chargerPellicule", "func coquilleSarah",
]

ECRANS_ATTENDUS = [
    "UberVue", "UbDestinationVue", "UbCoursesVue", "UbReserveVue", "UbHeureVue",
    "UbConfirmationVue", "UbActiviteVue", "UbCourseVue", "UbReservationVue",
    "UbCompteVue", "UbWalletVue", "UbParametresVue", "UbAideVue", "UbSecuriteVue",
    "UbMessagesVue", "UbServicesVue", "UbEcranCapture",
]


def sans_chaines_ni_commentaires(source: str) -> str:
    """Remplace le contenu des chaînes et des commentaires par des espaces."""
    sortie = []
    i = 0
    n = len(source)
    while i < n:
        c = source[i]
        if c == '"':
            # chaîne multi-lignes ?
            if source.startswith('"""', i):
                fin = source.find('"""', i + 3)
                fin = n if fin == -1 else fin + 3
                sortie.append(" " * (fin - i))
                i = fin
                continue
            j = i + 1
            while j < n:
                if source[j] == "\\":
                    j += 2
                    continue
                if source[j] == '"':
                    j += 1
                    break
                if source[j] == "\n":
                    break
                j += 1
            sortie.append(" " * (j - i))
            i = j
            continue
        if source.startswith("//", i):
            j = source.find("\n", i)
            j = n if j == -1 else j
            sortie.append(" " * (j - i))
            i = j
            continue
        if source.startswith("/*", i):
            j = source.find("*/", i + 2)
            j = n if j == -1 else j + 2
            sortie.append(" " * (j - i))
            i = j
            continue
        sortie.append(c)
        i += 1
    return "".join(sortie)


def verifier():
    anomalies = []
    if not os.path.exists(CHEMIN):
        return ["Fichier introuvable : " + CHEMIN]
    source = open(CHEMIN, encoding="utf-8").read()
    lignes = source.splitlines()
    propre = sans_chaines_ni_commentaires(source)
    lignes_propres = propre.splitlines()

    # 1 — équilibrage
    for ouvrant, fermant, nom in [("{", "}", "accolades"), ("(", ")", "parenthèses"),
                                  ("[", "]", "crochets")]:
        pile = 0
        ligne_defaut = None
        for numero, ligne in enumerate(lignes_propres, 1):
            for caractere in ligne:
                if caractere == ouvrant:
                    pile += 1
                elif caractere == fermant:
                    pile -= 1
                    if pile < 0 and ligne_defaut is None:
                        ligne_defaut = numero
        if pile != 0:
            anomalies.append("Déséquilibre de %s : solde %+d (première ligne suspecte : %s)"
                             % (nom, pile, ligne_defaut))

    # 2 — préfixe des types
    for numero, ligne in enumerate(lignes_propres, 1):
        for motif in (r"^\s*(?:public\s+|private\s+|fileprivate\s+|internal\s+|final\s+)*"
                      r"(struct|class|enum|protocol|actor)\s+([A-Za-z_][A-Za-z0-9_]*)",):
            trouve = re.match(motif, ligne)
            if not trouve:
                continue
            nom = trouve.group(2)
            if nom in DEROGATIONS or nom == "DonneesUb":
                continue
            if not nom.startswith(PREFIXE):
                anomalies.append("l.%d : type « %s » sans préfixe %s" % (numero, nom, PREFIXE))

    # 3 — APIs interdites
    for motif, raison in APIS_INTERDITES:
        for numero, ligne in enumerate(lignes_propres, 1):
            if re.search(motif, ligne):
                anomalies.append("l.%d : %s → %s" % (numero, raison, lignes[numero - 1].strip()[:70]))

    # 4 — feuilles interdites
    for motif, raison in FEUILLES_INTERDITES:
        for numero, ligne in enumerate(lignes_propres, 1):
            if re.search(motif, ligne):
                anomalies.append("l.%d : %s" % (numero, raison))

    # 5 — clés dupliquées dans les dictionnaires littéraux d'une même ligne
    for numero, ligne in enumerate(lignes, 1):
        paires = re.findall(r'"([^"]+)"\s*:', ligne)
        if len(paires) > 1 and len(set(paires)) != len(paires):
            anomalies.append("l.%d : clé dupliquée dans un dictionnaire littéral" % numero)

    # 6 — ternaires de style non typés : « ? .xxx : » ou « : .xxx » après un ?
    for numero, ligne in enumerate(lignes_propres, 1):
        if re.search(r"\?\s*\.[A-Za-z]", ligne) and re.search(r":\s*\.[A-Za-z]", ligne):
            anomalies.append("l.%d : ternaire de style non typé → %s"
                             % (numero, lignes[numero - 1].strip()[:70]))

    # 7 — redéfinition des helpers de la coque
    for helper in HELPERS_PARTAGES:
        for numero, ligne in enumerate(lignes_propres, 1):
            if ligne.strip().startswith(helper):
                anomalies.append("l.%d : redéfinition interdite de « %s »" % (numero, helper))

    # 8 — Task.sleep sans try?
    for numero, ligne in enumerate(lignes_propres, 1):
        if "Task.sleep" in ligne and "try?" not in ligne and "try " not in ligne:
            anomalies.append("l.%d : Task.sleep sans try?" % numero)

    # 9 — écrans attendus
    declares = set(re.findall(r"(?:struct|enum|class)\s+([A-Za-z_][A-Za-z0-9_]*)", propre))
    for ecran in ECRANS_ATTENDUS:
        if ecran not in declares:
            anomalies.append("écran manquant pour le registre LPProto : %s" % ecran)

    # 10 — garde-fous de la coque
    if "BarreHome { quitter() }" not in source:
        anomalies.append("UberVue ne dessine pas BarreHome { quitter() }")
    if "import SwiftUI" not in source:
        anomalies.append("import SwiftUI manquant")
    if "navigationDestination" in propre:
        anomalies.append("navigationDestination présent (règle 5 : navigation par NavigationLink direct)")
    if "static let partage" not in source:
        anomalies.append("magasin UbEtat.partage manquant")

    return anomalies


if __name__ == "__main__":
    problemes = verifier()
    if problemes:
        print("ROUGE — %d anomalie(s) :" % len(problemes))
        for probleme in problemes:
            print("  • " + probleme)
        sys.exit(1)
    source = open(CHEMIN, encoding="utf-8").read()
    print("VERT — UberApp.swift : %d lignes, %d types Ub*, aucune anomalie."
          % (len(source.splitlines()),
             len(set(re.findall(r"(?:struct|enum|class)\s+(Ub[A-Za-z0-9_]*)", source)))))
