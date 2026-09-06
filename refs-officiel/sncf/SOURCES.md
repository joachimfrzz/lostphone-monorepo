# Captures d'écran SNCF Connect (iPhone) — récentes, sources officielles

Complément à la collection déjà présente dans `/agent/workspace/refs/officiel/sncf/`
(10 fichiers `00_..._FR_1284x2778` à `09_..._FR_1284x2778`, fiche App Store FR,
NON re-téléchargés ici).

## Fichiers téléchargés dans ce dossier (officiel2/sncf)

| Fichier | Écran représenté | Source (URL) | Date estimée | Dimensions |
|---|---|---|---|---|
| 10_CH_01.jpg | Accueil ("Guten Tag!" — équivalent DE de "Bonjour !"), barre de recherche, grille de services (Trains/Titres urbains/Horaires/Info trafic/Cartes/Location/Hôtels/+services), bandeau bas Reisen/Fahrkarten/Angebote/Konto | apps.apple.com/ch (fiche App Store Suisse, capture DE) | UI actuelle 2025-2026 | 600×1298 |
| 11_CH_02.jpg | Résultats de recherche Paris→Berlin (prix, horaires, filtres) | apps.apple.com/ch | UI actuelle 2025-2026 | 600×1298 |
| 12_CH_03.jpg | Itinéraire / carte (Google Maps intégré) vers Gare de l'Est | apps.apple.com/ch | UI actuelle 2025-2026 | 600×1298 |
| 13_CH_04.jpg | Cartes et abonnements SNCF (Carte Liberté, Carte Avantage) | apps.apple.com/ch | UI actuelle 2025-2026 | 600×1298 |
| 14_CH_05.jpg | Réglages des alertes billets (petits prix, réservation, train complet) | apps.apple.com/ch | UI actuelle 2025-2026 | 600×1298 |
| 16_CH_traffic.jpg | Info trafic et réseaux (Île-de-France), statuts par ligne, RER | apps.apple.com/ch | UI actuelle 2025-2026 | 600×1298 |
| 21_retrainspective_1.jpg | Fonctionnalité "Ma Rétrainspective 2025" — écran récap trajets (17:20, 24 trajets) | https://numerique.sncf.com/wp-content/uploads/2025/12/R2025_1.jpg (article numerique.sncf.com, 16/12/2025) | 2025-12-16 | 960×570 |
| 22_retrainspective_2.jpg | "Ma Rétrainspective 2025" — écran CO2 économisé (1176 kg) | https://numerique.sncf.com/wp-content/uploads/2025/12/R2025_2.jpg | 2025-12-16 | 960×570 |
| 23a_retrainspective_screen1.png | "Ma Rétrainspective 2025" — badge "#TEAMTRAIN EXPERT" | https://numerique.sncf.com/wp-content/uploads/2025/12/4.png (recadré) | 2025-12-16 | 640×1080 |
| 23b_retrainspective_screen2.png | "Ma Rétrainspective 2025" — km cumulés / déblocage avatar | idem (recadré) | 2025-12-16 | 640×1080 |
| 23c_retrainspective_screen3.png | "Ma Rétrainspective 2025" — écran final logo + partage avatar | idem (recadré) | 2025-12-16 | 640×1080 |

## Sources explorées sans nouveau contenu exploitable

- **Google Play (fr-FR)**, `com.vsct.vsc.mobile.horaireetresa.android` : le carrousel de captures est identique (mêmes visuels marketing) à celui déjà récupéré sur l'App Store FR — aucune capture supplémentaire distincte trouvée.
- **App Store BE et CA** : jeux de captures identiques entre eux, mêmes visuels que la fiche CH ou FR (déduplication par hash) — pas de contenu nouveau.
- **App Store fr-CA** : page rendue en JavaScript (SPA Vite/Svelte), non extractible via curl ; non traité par navigateur faute de temps disponible.
- **vous.sncf-connect.com / blog SNCF Connect & Tech** : lien mort, redirige vers `connect-et-vous.sncf-connect.com/hub`, page communautaire nécessitant une connexion — abandonné.
- **aide.sncf-connect.com** : non exploré (temps limité).
- **Presse (Numerama, Frandroid, 01net, Clubic, Le Parisien, BFM, Capital, iGeneration)** : non explorée (temps limité).

## Écrans recherchés mais NON trouvés (en français, UI actuelle)

- Saisie de la destination + suggestions d'autocomplétion
- Sélection de la date et du nombre de voyageurs (calendrier / stepper passagers)
- Détail d'un trajet (fiche horaires détaillée avant ajout au panier)
- Écran de confirmation de commande (après paiement)
- Onglet "Billets" / "Mes voyages" à vide (aucun trajet)
- Onglet "Billets" / "Mes voyages" avec un billet
- Billet ouvert avec QR code / e-billet
- Onglet "Offres"
- Onglet "Compte" (profil, cartes enregistrées, réglages)
- Écran de connexion / inscription (login/signup)

Ces écrans n'ont pas été localisés dans les sources autorisées avec une date
2025-2026 confirmée ou une UI manifestement récente. Le panier (Panier/Poser une
option) et le paiement (Paiement sécurisé/Apple Pay) sont en revanche déjà
couverts par le jeu FR préexistant (`08_03_CPP_FR` et `06_05_CPP_FR` — à vérifier
selon la numérotation locale du dossier `officiel/sncf/`).
