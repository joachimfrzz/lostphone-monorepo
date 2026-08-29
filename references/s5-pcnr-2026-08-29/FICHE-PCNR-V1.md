# Fiche de référence — PHOTOS / CALENDRIER / NOTES / RAPPELS (S5, 2026-08-29)

Sources : vidéo 17 min 28 @60fps → 902 états distincts + 200 arbres XML. Apps construites : PhotosApp (validée 18/08, 69 photos), CalendrierApp, NotesApp, RappelsApp (cercle 1, 9,8).

## Couverture
- **Photos** : phototèque (PXCuratedLibrary), Collections, Recherche, Personnes, Albums, Types de média, plein écran (PUOneUpView) + menus contextuels, **éditeur AJUSTER** (retouche)
- **Calendrier** : mois (MonthViewContainer), jour (DayViewContainer), recherche (AdaptiveSearch), **création d'événement (EKEventEditView)**, listes de calendriers iCloud
- **Notes** : listes/dossiers, éditeur (ICTK2NoteEditorView)
- **Rappels** : comptes/listes (TTRIAccountsLists), liste Courses, saisie rapide (TTRIQuickEntry)

## Or narratif (cartographie D79)
- **Éditeur de photo (AJUSTER)** : une photo RETOUCHÉE est un acte — recadrer quelqu'un hors du champ = indice
- **Personnes** (reconnaissance faciale) : le jeu des visages nommés/non nommés (déjà exploité : Marc non nommé)
- **Création d'événement** : les champs par défaut (calendrier cible, invités, alerte) caractérisent
- **Saisie rapide Rappels** : la todo brute = pensée non filtrée du personnage

## Implications diff P5
1. PhotosApp : ajouter l'éditeur AJUSTER (au moins l'écran, D51-2 composant avant besoin), menus contextuels réels du plein écran
2. CalendrierApp : notre création d'événement à confronter à EKEventEditView réel (champs exacts)
3. NotesApp/RappelsApp : éditeurs à densifier (barres d'outils réelles)
