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

## Ordre & état (à jour du 06/09/2026 20h15 — 14/28 validées + 3 apps vague A quasi-validées (281))
| # | App | État |
|---|---|---|
| 1 | Coque (verrouillage+accueil) | ✅ VALIDÉE 30/08 18h02 (v3 : « c'est parfait ») |
| 2 | Messages | ✅ VALIDÉE 02/09 16h43 (build 272) |
| 3 | WhatsApp | 🔄 RE-TEST build 275 (+278) (tap rangée → conversation) |
| 4 | Téléphone + Contacts | ✅ VALIDÉE 02/09 16h43 (build 272) |
| 5 | Photos | ✅ VALIDÉE 02/09 16h43 (build 272) |
| 6 | Mail | ✅ VALIDÉE 02/09 16h43 (build 272) |
| 7 | Safari | 🔄 RE-TEST build 275 (+278) |
| 8-10 | Notes, Rappels, Calendrier | 🔄 RE-TEST build 275 (+278) |
| 11 | Réglages | ⏸ REPORTÉE en passe dédiée FINALE (demande Joachim 02/09 : app trop vaste) |
| 12 | Horloge | ✅ VALIDÉE 02/09 18h29 (build 274) — reste le mot anglais « Delete », corrigé au 275 |
| 13 | Météo | ✅ VALIDÉE 02/09 17h29 (build 272) |
| 14 | Calculatrice | ✅ VALIDÉE 02/09 17h29 (build 272) |
| 15 | Dictaphone | ✅ VALIDÉE 02/09 18h29 (build 274) |
| 16 | Fichiers | ✅ VALIDÉE 02/09 20h10 (build 278) |
| 17 | Localiser | ✅ VALIDÉE 02/09 20h10 (build 278) |
| 18 | Santé | ✅ VALIDÉE 02/09 18h50 (build 274) — à enrichir selon les histoires |
| 19 | Cartes (Wallet) | ✅ VALIDÉE 02/09 20h10 (build 278) |
| 20 | Ma Banque | ✅ VALIDÉE 02/09 20h10 (build 278) |
| 21-24 | Messenger, Instagram, Snapchat, Facebook | 🔄 RE-TEST build 280 (lot D92 « juste milieu » sur la refonte D91) |
| 25-28 | X, ChatGPT, Spotify, YouTube | à vérifier |
| A1-A3 | PayPal, App Store, Musique (vague A) | ✅ QUASI-VALIDÉES 06/09 21h17 (build 281 : « quasi parfait ») — petits fixs reportés, à lister |

Builds 276-277 rouges (corrigés) ; **278 VERT, validé 16/16 (02/09 20h10)** ; **279 (03/09 15h08) = refonte D91 des 4 sociales + Notes v3** ; **280 (03/09 18h45) = lot D92 juste milieu** (retours 279) ; **281 (06/09 20h12) = vague A : PayPal, App Store, Musique**.

Ensuite : création des nouvelles apps (chacune naît avec ce niveau d'exigence).
