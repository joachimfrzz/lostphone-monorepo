# PASSATION — Lost Phone (lire en premier par tout nouvel agent)

> Ce repo contient TOUT ce qu'il faut pour reprendre le projet sans perte, y compris après
> un changement de compte Hyperagent ou Codemagic. Document refondu le 2026-09-01 (passation V4) :
> **plus aucun état de projet n'est dupliqué ici** — l'état vit dans `project_memory.json`.

## Qui tu es
Le partenaire de réflexion critique et d'exécution de Joachim sur **Lost Phone**
(jeu narratif d'investigation sur smartphone simulé). Ton rôle détaillé, le contrat
de collaboration et le calibrage de communication sont dans `project_memory.json`
→ section `amorcage_nouvel_agent`. Règle d'or de communication : terminer chaque
réponse par LA seule action concrète qui incombe à Joachim (une étape à la fois,
chemin exact), séparée de ce que tu fais de ton côté.

## Passation Hyperagent — démarrage en 4 étapes
1. **Lis `project_memory.json`** (racine de ce repo, ~400 Ko). Ordre de lecture utile :
   `amorcage_nouvel_agent` → `etat_conversation` → `point_de_reprise_migration_v3`
   → `decisions` (surtout D71, D84, D86, D87) → le reste.
   S'il est trop gros pour un seul appel : télécharge-le en local et lis-le par sections.
2. **Résume l'état du projet à Joachim** et ce qu'il faut recréer (liste ci-dessous) — c'est ton test d'embauche. Attends son GO.
3. **Applique D15** : ce fichier est la mémoire vivante — mets-le à jour à chaque décision/avancée,
   ET re-pousse-le dans ce repo à chaque mise à jour (commit).
4. Reprends le travail là où **`etat_conversation`** s'est arrêté. C'est LA section d'état :
   ce document-ci n'en tient aucune copie (elles finissent toujours par mentir).

## À recréer sur un nouveau compte Hyperagent (rien d'autre n'est perdu)
- Intégration **GitHub** connectée (tu lis ce fichier, donc c'est fait ✔)
- Compétence **pilote-codemagic-lostphone** : API Codemagic, credential `CODEMAGIC_API_TOKEN`
  (Joachim l'a ; régénérable — voir passation Codemagic ci-dessous). APP_ID : voir ci-dessous.
- (Optionnel, plans B) **pilote-testmu-lostphone** et **pilote-browserstack-lostphone** — schémas
  de credentials dans `point_de_reprise_migration_v3`.
- Mémoires : la préférence de communication de Joachim (ci-dessus) + le piège SwiftUI
  `scaledToFill` → pattern `Color.clear.overlay(image.resizable().scaledToFill()).clipped()`.
- Côté PC de Joachim : **RIEN à refaire** (SideTap, WDA signé, cloudflared, patchs = locaux).

## Passation Codemagic — si le compte Codemagic change
1. Joachim crée le compte et connecte le repo GitHub `joachimfrzz/lostphone-monorepo`
   → noter le nouvel **APP_ID** (l'agent le vérifie via `GET /apps`).
   APP_ID actuel (compte 2, depuis le 2026-08-27) : `6a8f67340674263dd88340ad`.
2. Joachim génère le token API : codemagic.io → Teams/Personal → Integrations →
   **Codemagic API** → Show token → le coller dans le credential `CODEMAGIC_API_TOKEN`
   de la skill (jamais en clair dans le chat).
3. **Prérequis TestFlight** : ajouter la clé API App Store Connect (.p8) sous le nom
   EXACT « Codemagic » : codemagic.io → Teams/Personal → Integrations →
   Developer Portal (App Store Connect) → Add key → name: `Codemagic`.
   Sans elle, `duel-swift-testflight` échoue à la signature.
4. Vérifier le quota (~500 min gratuites/mois) avant tout build non critique.
   Garde-fou D65 : un build TestFlight ne part QUE sur GO explicite de Joachim.

## Le régime D71 en bref (capture de références sur l'iPhone RÉEL de Joachim)
- **SideTap** (github.com/ucsandman/SideTap) tourne sur le PC Windows de Joachim,
  WebDriverAgent signé sur son iPhone (Apple ID jetable), déjà installé — RIEN à refaire côté PC.
- **Rituel de session** (côté Joachim) : iPhone branché USB + déverrouillé + app WebDriverAgent
  ouverte une fois, puis double-clic `Demarrer-LostPhone.cmd` (Bureau) → il te donne l'URL
  `https://….trycloudflare.com` (change à chaque fois). Moniteur tablette :
  `python tools/phone_monitor.py` (port 8781), actif pendant TOUTE session.
- **Toi** : tu pilotes par HTTP via cette URL (WDA : `/status`, `/screenshot`, `/source`,
  sessions W3C, éléments par predicate). Capture systématique : **PNG + XML par écran**,
  livrées en zip + journal, poussées dans `references/`.
- **CHARTE DE PILOTAGE OBLIGATOIRE** (détail dans D71) : lecture seule ; jamais d'envoi/appel/
  paiement/suppression ; pas de conversation non lue ; pas de story vue ; pas de saisie dans un
  champ d'envoi ; chat Snapchat interdit ; Ma Banque interdite ; STOP = Joachim débranche le câble.
- **Plan en 4 vagues** (A zéro-risque → D identité réelle) et protocole de session : voir D71.
- Dépannages connus (certificat Apple, encodage Windows FR, Python 3.12, openssl…) :
  D71 → `setup_pieges_resolus`.
- **Échéance récurrente** : re-signature WDA hebdomadaire (`fix-input`) — la prochaine
  échéance est tenue dans `etat_conversation`.

## Où est quoi
Voir la carte du repo dans `README.md`. Registre des décisions : `project_memory.json`
(les fiches `docs/decisions/` sont gelées à D27 — voir `docs/decisions/README.md`).
