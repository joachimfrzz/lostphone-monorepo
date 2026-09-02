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

**Fiches de vérification détaillées des 28 apps** : `FICHES-VERIFICATION-APPS.md` (fichier unique, 02/09). Le dossier `fiches-verification/` (01/09) est remplacé — conservé une itération, suppression sur arbitrage.

## Ordre & état (à jour du 02/09/2026)
| # | App | État |
|---|---|---|
| 1 | Coque (verrouillage+accueil) | ✅ VALIDÉE 30/08 18h02 (v3 : « c'est parfait ») |
| 2 | Messages | ✅ VALIDÉE 02/09 16h43 (build 272) |
| 3 | WhatsApp | 🛠 1 bug restant (tap rangée → infos au lieu de la conv) CORRIGÉ 02/09 dans le repo — au build du lot session 2 |
| 4 | Téléphone + Contacts | ✅ VALIDÉE 02/09 16h43 (build 272) |
| 5 | Photos | ✅ VALIDÉE 02/09 16h43 (build 272) |
| 6 | Mail | ✅ VALIDÉE 02/09 16h43 (build 272) |
| 7 | Safari | 🛠 CORRIGÉE 31/08 (5 retours session 2 : zone BarreHome, onglets réels, aA, recherche contrôlée, sites étoffés) — build au LOT session 2 |
| 8-15 | Notes, Rappels, Calendrier, Réglages, Horloge, Météo, Calculatrice, Dictaphone | à vérifier (sessions 2-3) |
| 16-20 | Fichiers, Localiser, Santé, Cartes, Ma Banque | à vérifier |
| 21-28 | Messenger, Instagram, Snapchat, Facebook, X, ChatGPT, Spotify, YouTube | à vérifier |

Ensuite : création des nouvelles apps (chacune naît avec ce niveau d'exigence).
