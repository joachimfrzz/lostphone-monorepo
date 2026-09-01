# Fiche de vérification — Météo (campagne D84, session 3)

**Protocole (≤5 min)** : fais le tour ci-dessous sur le VRAI iPhone puis sur Lost Phone.
Pour chaque écart : une paire de photos (vrai / jeu) OU une ligne de frustration (vocal ou texte).
Les 5 axes : pixel · touchers (D82 : A faire-marcher > B message crédible > C retirer) · navigation & gestes · contenu Sarah · animations.

## Tour de l'app
1. Page DOMICILE Lyon : température, condition, ↑↓, bande horaire scrollable (avec Coucher de soleil), prévisions 10 jours (barres de température + point du jour + % pluie), qualité de l'air, 8 tuiles
2. Pagination : points + flèche localisation → Théizé, Marseille (le port du 28 !)
3. Feuille CONDITIONS MÉTÉO : sélecteur de jours, graphe de courbe, bascule Réelle/Ressentie
4. LISTE DES VILLES : cartes dégradées, recherche réelle — l'AJOUT échoue en réseau après spinner (~1,4 s) : c'est VOULU (app en ligne, anneau 3)
5. CARTE plein écran : pastilles de température des 3 villes
6. Footer « Météo pour le domicile 14 rue des Capucins »

## Boutons à tester
- « Signaler un problème » → alerte réseau (voulu)
- Tap sur chaque tuile (détail s'il existe sur le vrai)

## Pièges connus
- Icônes météo SF multicolores proches mais pas identiques aux glyphes Apple (chantier assets si besoin)
- Îlot dynamique visible en noir sur fond bleu : artefact simulateur, vérifier si absent sur device
