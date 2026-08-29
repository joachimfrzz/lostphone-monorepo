# Fiche de référence — COQUE iOS 26 (session S1, 2026-08-29, vidéo 4min40 @60fps)

Source : enregistrement d'écran natif 1206×2622 (SwissTransfer ea31d300, valable 30 j) → 560 frames 2fps → 226 états distincts (transitions incluses). Couche XML : à compléter en passe 2 (tunnel mort pendant la session). Planches contact archivées.

## Couverture checklist S1
| Item | État |
|---|---|
| Verrouillage + notifications (piles, dépliées, « En afficher moins », compteur « 32 notifications ») | ✅ très riche |
| Déverrouillage (animation) | ✅ (frames de transition) |
| Accueil toutes pages + dock + widgets | ✅ (~8 pages) |
| Bibliothèque d'apps (catégories dépliées, recherche alphabétique + clavier) | ✅ |
| Spotlight (suggestions Siri + saisie) | ✅ |
| Centre de contrôle | ✅ vue principale — appuis longs des blocs À VÉRIFIER en passe 2 |
| Centre de notifications | ✅ |
| Multitâche (switcher) | ✅ |
| Animations ouverture/fermeture d'apps | ✅ |

## Observations structurantes (pixels)
- **Verrouillage** : date « Sam. 29 août » au-dessus de l'heure massive ; notifications empilées EN BAS de l'écran (remontent en liste au scroll) ; lampe + appareil photo en coins bas ; compteur « N notifications » sous la pile ; dépliage par app ; « En afficher moins » en tête de groupe déplié.
- **Accueil** : dock 4 (Téléphone, Messages, Safari, Musique) ; widgets moyens (Météo géolocalisée + pile Photos) ; pilule « Recherche » au-dessus du dock ; badges non lus réalistes (Mail affiche 53 775 !).
- **Bibliothèque** : 2 tuiles hautes (Suggestions / Ajouts récents) puis catégories auto (Réseaux sociaux, Utilitaires, Productivité, Divertissement…) ; barre « Bibliothèque d'apps » → liste alphabétique avec index latéral + clavier.
- **Multitâche** : cartes plein écran légèrement réduites, nom+icône d'app au-dessus, étiquette **Handoff « De "iPad de Joachim" »** sous certaines cartes.
- **Spotlight** : 8 suggestions Siri en grille + « New chat »/actions d'app + clavier.

## Possibilités narratives repérées (cartographie D79)
- Le **compteur de notifications** du verrouillage (« 32 notifications ») : premier plan de tension d'une ouverture d'histoire (la vie qui déborde / l'absence qui s'accumule).
- **Badges extrêmes** (Mail 53 775) : caractérisation instantanée d'un personnage négligent/débordé.
- **Étiquette Handoff** « De "l'iPad de…" » : révèle l'existence d'un AUTRE appareil hors-champ — indice d'écosystème, piste d'enquête (« où est l'iPad ? »).
- **Suggestions Siri** de Spotlight : trahissent les habitudes réelles (apps « souvent lues à cette heure »).
- **Widget Météo géolocalisé** : position du propriétaire sans ouvrir aucune app.
- Pile **Photos** du verrouillage/accueil : des visages en rotation = casting passif de l'histoire.

## Implications pour LPProto (diff P5 coque — chantier D76)
1. Notre verrouillage n'a ni compteur de notifications, ni piles dépliables → à construire.
2. Bibliothèque d'apps absente de notre coque → écran + catégories + recherche à créer.
3. Multitâche absent → cartes + étiquette Handoff (or narratif gratuit).
4. Spotlight absent (litige interactions déjà ouvert) → suggestions Siri + clavier.
5. Badges : autoriser des valeurs à 5 chiffres (test de mise en page).
6. Animations à mesurer sur la vidéo 60 fps à la construction (durées/courbes réelles).

## Passe 2 (XML, ~3 min, tunnel requis)
Pose de 2 s sur : verrouillage, accueil p.1, bibliothèque racine, liste alphabétique, Spotlight, CC replié, CC blocs dépliés (appui long connectivité PUIS audio, sans toucher les boutons), centre de notifications, une pile dépliée, multitâche.
