# CAMPAGNE VÉRIFICATION TOTALE (D84 — 30/08/2026)

Objectif : chaque app existante validée « à l'image de Joachim » — pixel, touchers,
navigation, contenu, animations — AVANT toute création de nouvelle app.

## Protocole par app (toujours identique)
1. Agent : fiche de vérification (écrans, boutons, comportements attendus)
2. Joachim (≤5 min) : paires de photos « vrai iPhone vs Lost Phone » + liste des boutons qui frustrent (vocal/texte)
3. Agent : correctifs + build TestFlight + consignes de re-test
4. Joachim : re-test éclair → « validée » → suivante. Une app validée = on n'y revient plus.

Méthode pipeline D86 : builds GROUPÉS par session de 4-5 apps ; Joachim teste
l'app suivante pendant que l'agent code le lot précédent.

## Les 5 axes
pixel (vs références S1-S6 + photos) · touchers (D82 : A faire-marcher > B message crédible > C retirer) ·
navigation & gestes · contenu narratif Sarah · animations.

## Ordre & état (à jour du 01/09/2026)
| # | App | État |
|---|---|---|
| 1 | Coque (verrouillage+accueil) | ✅ VALIDÉE 30/08 18h02 (v3 : « c'est parfait ») |
| 2 | Messages | 🔄 RE-TEST build 272 (6 corr. étape 2 + 2 corr. retest 271 codées) |
| 3 | WhatsApp | 🔄 RE-TEST build 272 (gros lot étape 3 + CRASHS navigation réparés) |
| 4 | Téléphone + Contacts | 🔄 RE-TEST build 272 (5 corr. retest 271 : tri Récents, Mail préadressé, partage fiche…) |
| 5 | Photos | 🔄 RE-TEST build 272 (11 corr. étape 5 + 4 corr. retest 271 : années cliquables, filtres…) |
| 6 | Mail | 🔄 RE-TEST build 272 (13 corr. étape 6 + bug critique « mails ne s'ouvrent plus » réparé) |
| 7 | Safari | 🛠 CORRIGÉE 31/08 (5 retours session 2 : zone BarreHome, onglets réels, aA, recherche contrôlée, sites étoffés) — build au LOT session 2 |
| 8-15 | Notes, Rappels, Calendrier, Réglages, Horloge, Météo, Calculatrice, Dictaphone | à vérifier (sessions 2-3) |
| 16-20 | Fichiers, Localiser, Santé, Cartes, Ma Banque | à vérifier |
| 21-28 | Messenger, Instagram, Snapchat, Facebook, X, ChatGPT, Spotify, YouTube | à vérifier |

Ensuite : création des nouvelles apps (chacune naît avec ce niveau d'exigence).
