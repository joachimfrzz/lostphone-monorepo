# PASSATION — Lost Phone (lire en premier par tout nouvel agent)

> Ce repo contient TOUT ce qu'il faut pour reprendre le projet sans perte,
> y compris après un changement de compte Hyperagent. Dernière passation préparée le 2026-08-28 (soir, avant migration de compte).

## Qui tu es
Le partenaire de réflexion critique et d'exécution de Joachim sur **Lost Phone**
(jeu narratif d'investigation sur smartphone simulé). Ton rôle détaillé, le contrat
de collaboration et le calibrage de communication sont dans `project_memory.json`
→ section `amorcage_nouvel_agent`. Règle d'or de communication : terminer chaque
réponse par LA seule action concrète qui incombe à Joachim (une étape à la fois,
chemin exact), séparée de ce que tu fais de ton côté.

## Démarrage en 4 étapes
1. **Lis `project_memory.json`** (racine de ce repo, ~440 Ko). Ordre de lecture utile :
   `amorcage_nouvel_agent` → `etat_conversation` → `point_de_reprise_migration_v3`
   → `decisions` (surtout D70 et D71) → `feuille_de_route_2026_08_28` → le reste.
   S'il est trop gros pour un seul appel : télécharge-le en local (raw) et lis-le par sections.
2. **Résume l'état du projet à Joachim** et ce qu'il faut recréer (liste ci-dessous) — c'est ton test d'embauche.
3. **Applique D15** : ce fichier est la mémoire vivante — mets-le à jour à chaque décision/avancée,
   ET re-pousse-le dans ce repo à chaque mise à jour (commit).
4. Reprends le travail là où `etat_conversation` s'est arrêté.

## À recréer sur un nouveau compte Hyperagent (rien d'autre n'est perdu)
- Intégration **GitHub** connectée (tu lis ce fichier, donc c'est fait ✔)
- Compétence **pilote-codemagic-lostphone** : API Codemagic, credential `CODEMAGIC_API_TOKEN`
  (Joachim l'a). App id : voir `etat_technique` / commentaires du script dans `project_memory.json`.
- (Optionnel, plans B) **pilote-testmu-lostphone** et **pilote-browserstack-lostphone** — schémas
  de credentials dans `point_de_reprise_migration_v3`.
- Mémoires : la préférence de communication de Joachim (ci-dessus) + le piège SwiftUI
  `scaledToFill` → pattern `Color.clear.overlay(image).clipped().ignoresSafeArea()`.

## Le régime D71 en bref (capture de références sur l'iPhone RÉEL de Joachim)
- **SideTap** (github.com/ucsandman/SideTap) tourne sur le PC Windows de Joachim,
  WebDriverAgent signé sur son iPhone (Apple ID jetable), déjà installé — RIEN à refaire côté PC.
- **Rituel de session** (côté Joachim) : iPhone branché USB + déverrouillé + app WebDriverAgent
  ouverte une fois, puis double-clic `Demarrer-LostPhone.cmd` (Bureau) → il te donne l'URL
  `https://….trycloudflare.com` (change à chaque fois).
- **Toi** : tu pilotes par HTTP via cette URL (WDA : `/status`, `/screenshot`, `/source`,
  sessions W3C, éléments par predicate). Capture systématique : **PNG + XML par écran**,
  livrées en zip + journal, poussées dans `references/`.
- **CHARTE DE PILOTAGE OBLIGATOIRE** (détail dans D71) : lecture seule ; jamais d'envoi/appel/
  paiement/suppression ; pas de conversation non lue ; pas de story vue ; pas de saisie dans un
  champ d'envoi ; chat Snapchat interdit ; Ma Banque interdite ; STOP = Joachim débranche le câble.
- **Plan en 4 vagues** (A zéro-risque → D identité réelle) et protocole de session : voir D71.
- Dépannages connus (certificat Apple, encodage Windows FR, Python 3.12, openssl…) :
  D71 → `setup_pieges_resolus`.

## État au moment de la passation (2026-08-28 soir)
- **Cadre d'analyse D72** (3 principes : fidélité au vrai iPhone, compréhension réelle
  avec dossier de référence par app, séparation stricte des conséquences réelles) et
  **D73** (esprit critique proactif ; l'analyse ne reprend QUE sur le nouveau compte) : à lire en premier.
- **Session 1 partielle** : coque OK (7 écrans), sauvée dans `references/session1-2026-08-28/`
  (PNG en base64 — reconstituer avec `python3 DECODER.py`). Réglages À REFAIRE avec
  `tools/session1b_driver.py` (correctif retour-racine inclus ; mettre à jour l'URL tunnel en tête de script).
- **Moniteur tablette VALIDÉ** : `tools/phone_monitor.py` sur le PC (port 8781, règle pare-feu déjà créée),
  Joachim le lance avec `python phone_monitor.py` et surveille sur `http://192.168.1.25:8781`.
  Il doit être actif pendant TOUTE session de pilotage.
- **Rituel complet d'une session** : iPhone branché+déverrouillé, app WebDriverAgent ouverte une fois,
  `Demarrer-LostPhone.cmd`, moniteur tablette lancé, Joachim donne l'URL tunnel → l'agent annonce
  l'objectif de la session (D72) puis exécute, et livre le dossier de référence.

## Échéances
- Re-signature WDA hebdomadaire : `fix-input` (prochaine : 2026-09-04).
- Reprise : terminer la Session 1 (Réglages depuis la racine + reprendre 4 XML défectueux
  de la coque : 02/03 et 05/06 identiques), puis fiche Réglages, puis suite de la vague A.
