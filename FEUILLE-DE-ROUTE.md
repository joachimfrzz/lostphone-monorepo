# FEUILLE DE ROUTE — LOST PHONE (v5.2, validée par Joachim le 31/08/2026)

PRINCIPES : Lost Phone = MOTEUR de jeux « téléphone trouvé » portant n'importe quelle histoire.
Coches bleues = histoire DÉMO de développement (sortie non garantie), banc d'essai.
On grave aussi une MÉTHODE D'ÉCRITURE reproductible, automatisable par IA. Testeur unique : Joachim.

## PHASE T — TRANSVERSALE : outillage & efficacité (court sur tout le projet)
- Passation CODEMAGIC en 5 min : runbook dans le skill, script de pré-vol (jeton/app/intégration ASC/certificats) avant tout build, alerte quota proactive, fallback GitHub Actions à l'étude.
- Passation HYPERAGENT en 3 gestes : PASSATION.md au repo avec prompt d'amorçage prêt à coller (lire project_memory.json + feuille de route, recréer le skill depuis le repo, demander le jeton) ; tout document clé vit AU REPO ; test de passation à blanc.
- Exploitation totale d'Hyperagent : multi-fils parallèles (ATELIER = codeur ; CI-BUILDS = agent Codemagic ; HISTOIRE = écrivain ; plus tard PROMO), project_memory.json = source de vérité commune entre fils, builds surveillés en tâche de fond, sous-agents pour les gros lots, runs planifiés (état du matin, veille quota), navigateur automatisé pour App Store Connect, diffs visuels automatiques. Livrable : OUTILLAGE.md tenu à jour.

## PHASE 0 — Infra (immédiat)
Clé App Store Connect rôle ADMIN dans Codemagic 3 → build session 1 vert. Stratégie quota CI.

## PHASE 1 — Vérification des 29 apps existantes (campagne D84, en cours)
Sessions 1-4, boucle listes→correctifs→1 build/session. Sortie : 29 apps parfaites.

## PHASE 2 — Catalogue d'apps COMPLET et GÉNÉRIQUE
Toutes les apps d'un iPhone crédible, contenu lu depuis les DONNÉES d'une histoire (zéro contenu en dur).
Vague A (décidée) : Tinder, SNCF Connect, PayPal, FaceTime, LinkedIn, Uber, App Store, Musique.
Vague B (inventaire à arbitrer) : Doctolib, Vinted, Leboncoin, Deliveroo, Booking, Airbnb, Amazon, Netflix, banque paramétrable, podcasts, TV, jeux…
DÉCISION d'ouverture : vrais logos vs marques stylisées (conditionne la phase 6).

## PHASE 3 — MOTEUR narratif générique
Format d'histoire en données (contacts, fils, médias, historiques, horloge narrative, dates relatives) ; progression paramétrable (indices, déclencheurs, codes, verrouillages, fins multiples) ; SAUVEGARDE PERSISTANTE par histoire ; écran titre + sélection d'histoire.

## PHASE 3bis — MÉTHODE D'ÉCRITURE
Template d'histoire complet (titre, pitch, genre, personnages avec voix et tics, chronologie, cartographie des indices par app, fausses pistes, texture du quotidien, fins, durée, checklist de cohérence dates/montants/noms) + manuel de méthode + PIPELINE IA (brief → histoire complète au format moteur, contrôles de cohérence automatiques — l'IA génère, Joachim tranche).
PREUVE moteur+méthode : Coches bleues migrée en pur contenu + une mini-histoire neuve écrite via la méthode qui tourne SANS toucher au code.

## PHASE 4 — Histoire(s) de lancement
DÉCISION Joachim : étendre Coches bleues ou histoire neuve. Écriture complète VIA la méthode, implémentation 100 % en données, équilibrage. L'écriture peut démarrer en parallèle dès maintenant.

## PHASE 5 — Polish & médias
Animations 60 fps, sons, haptique, icônes restantes, wallpaper, perfs ; voix des vocaux, photos libres de droits, musiques licenciées.

## PHASE 6 — Conformité & légal (RISQUE N°1)
Imitation UI iOS + marques tierces (mitigé dès P2), fiction affichée, politique de confidentialité (zéro donnée), classification d'âge, RGPD, licences, nom et bundle définitifs.

## PHASE 7 — Fiche App Store
DÉCISIONS : nom définitif (dispo vérifiée) + modèle (premium 3,99-5,99 € vs app gratuite + histoires en achat intégré). Captures mises en scène, vidéo preview, description, ASO.

## PHASE 8 — Soumission & review
Notes reviewer préparées, PLAN B anti-rejet écrit, tampon 2-3 allers-retours.

## PHASE 9 — Promo pré-lancement
Trailer 60-90 s, kit presse + page web, presse FR/int., streamers narratif, teasers TikTok/Reels, date annoncée.

## PHASE 10 — Lancement
Jour J, réponses aux avis, suivi ASO, hotfix 1.0.1 sous 7 jours.

## PHASE 11 — Post-lancement
Localisation EN, promos, PRODUCTION EN SÉRIE d'histoires via méthode+IA en achat intégré (le vrai modèle), étude Android.

## DÉCISIONS JOACHIM EN ROUTE
Marques (P2) · inventaire apps (P2) · histoire de lancement (P4) · nom (P7) · prix/modèle (P7) · budget promo (P9).

## RISQUES SUIVIS
Rejet Apple UI/marques (n°1) · chantier moteur/sauvegarde (P3) · qualité des histoires IA · sur-généralisation vs finition pixel-perfect · droits médias · dépendance CI (mitigée phase T).
