# PASSATION — Lost Phone (lire en premier par tout nouvel agent)

> Ce repo contient TOUT ce qu'il faut pour reprendre le projet sans perte, y compris après
> un changement de fil, de compte Hyperagent ou de compte Codemagic. Document refondu le
> 2026-09-10 (**passation V5**) : aucun état de projet n'est dupliqué ici — l'état vit dans
> `project_memory.json` → `etat_conversation`. Ce document dit COMMENT reprendre, pas OÙ on en est.

## Qui tu es
Le partenaire de réflexion critique et d'exécution de Joachim sur **Lost Phone** (jeu narratif
d'investigation sur smartphone simulé : le joueur explore l'iPhone reproduit d'un personnage).
Rôle détaillé, contrat de collaboration et calibrage : `project_memory.json` → `amorcage_nouvel_agent`.

Règles de communication NON négociables (Joachim les a rappelées plusieurs fois) :
1. **Français uniquement**, y compris quand tu relaies le rapport d'un sous-agent (reformule-le en français).
2. **Une seule action concrète pour Joachim par réponse**, chemin exact (menu, bouton, commande), clairement
   séparée de ce que tu fais de ton côté. Jamais deux manipulations empilées.
3. Ne t'arrête pas « tout seul » : quand une tâche longue est lancée, va jusqu'au bout (boucle miroir jusqu'au vert,
   push, fiche) sans repasser par lui, sauf pour un GO TestFlight (D65) ou un arbitrage de fond.
4. Étiquettes [RECO] / [IDÉE] / [RISQUE] / [TENSION] / [QUESTION] : seule une décision de Joachim devient canon.

## Démarrage d'un nouveau fil — 5 étapes
1. **Lis `project_memory.json`** (racine, ~450 Ko — télécharge-le via l'intégration GitHub puis lis-le par sections
   avec un script ; ne tente pas de l'afficher en entier). Ordre : `amorcage_nouvel_agent` → `etat_conversation`
   → `decisions_recentes` (D93, D94) → `vague_a`, `vague_b` → `campagne_verification` → `decisions`
   (surtout D59, D63, D65, D67, D71, D82, D84, D86, D87, D89, D91, D92) → le reste.
2. **Lis `docs/PROCEDURES-AGENT.md`** : les procédures opérationnelles Hyperagent (Codemagic, miroir, vidéos
   SwissTransfer → frames, push GitHub par morceaux, sous-agents constructeurs, fiche de vérification).
3. **Résume l'état à Joachim** en français (10 lignes max : où on en est, ce qui l'attend lui, ce qui t'attend toi)
   et termine par UNE action. C'est ton test d'embauche. Attends son GO.
4. **Applique D15** : `project_memory.json` est la mémoire vivante — mets-la à jour à chaque décision/avancée
   et **re-pousse-la dans ce repo** à chaque mise à jour (le repo est la sauvegarde de survie). Ajoute ta reprise
   dans `meta_export.lignee` et `point_de_reprise_migration_v5.reprises`.
5. Reprends là où **`etat_conversation`** s'est arrêté (`dernier_evenement`, `en_attente`).

## À recréer sur un nouveau compte Hyperagent (rien d'autre n'est perdu)
- Intégration **GitHub** connectée au compte `joachimfrzz` (tu lis ce fichier → c'est fait).
- Compétence (skill) **pilote-codemagic-lostphone** : script `api.py` (une copie de secours est dans
  `tools/passation/api.py`), credential `CODEMAGIC_API_TOKEN` (Joachim le régénère : voir passation Codemagic).
  Usage : `apps`, `builds [N]`, `status <buildId>`, `start <workflow> [branche] CLE=VALEUR…`, `cancel <buildId>`.
  Toujours via RunWithCredentials ; si « credentials expired » → FetchSkillScripts puis réessayer.
- Mémoires Hyperagent utiles : (a) préférence de Joachim (une action, français, ne pas s'arrêter) ;
  (b) pièges SwiftUI (voir `docs/regles-constructeur.md`, section « Contraintes de compilation »).
- Côté PC de Joachim : **RIEN à refaire** (SideTap, WDA signé, cloudflared = locaux). Le régime D71 (pilotage de
  l'iPhone réel) n'est plus utilisé depuis début septembre : les références viennent des **enregistrements d'écran
  que Joachim envoie par SwissTransfer** (D67) — voir procédures.
- Exécution : demander à Joachim de passer le fil en mode **Auto** (pas « Ask first ») pour éviter les refus de
  permission fantômes qui interrompent les sous-agents sans rien afficher chez lui.

## Passation Codemagic — si le compte Codemagic change
1. Joachim crée le compte et connecte le repo GitHub `joachimfrzz/lostphone-monorepo` → noter le nouvel **APP_ID**
   (l'agent le vérifie via `api.py apps`). APP_ID actuel (**compte 3**, depuis le 2026-09-01) :
   `6a9454919667617e9cf9743e`. Obsolètes : compte 2 `6a8f67340674263dd88340ad`, compte 1 `6a80d5e4…`.
2. Token API : codemagic.io → Teams/Personal → Integrations → **Codemagic API** → Show token → coller dans le
   credential `CODEMAGIC_API_TOKEN` de la skill (jamais en clair dans le chat).
3. **Prérequis TestFlight** : clé API App Store Connect (.p8) sous le nom EXACT « Codemagic » :
   Integrations → Developer Portal → Add key → name `Codemagic`. Sans elle, `duel-swift-testflight` échoue.
4. Numérotation des builds TestFlight : **260 + index Codemagic** du compte (le compte 3 a démarré à l'index 1 →
   build 261 ; le build 282 = index 22). Si le compte change, adapter l'offset dans `codemagic.yaml`
   (étape « Numéro de build ») pour continuer la série sans collision.
5. Quota ~500 min/mois. Garde-fou **D65** : un build TestFlight ne part QUE sur GO explicite de Joachim.
   Le miroir (`miroir-captures`) peut être lancé librement.

## Les trois workflows Codemagic
- `miroir-captures` : compile le simulateur et capture chaque écran listé dans un registre
  (`ECRANS_FICHIER=outils/ecrans.txt` par défaut ; registres ciblés `outils/ecrans-*.txt`). Artefact `captures.zip`.
  Une erreur de compilation apparaît ~2 min après le début de « Build simulateur ».
- `duel-swift-testflight` : IPA signé + upload TestFlight (~6 min). Artefact `LPProtoSwift.ipa` (versionCode = n° build).
- `icones-sim` : extraction des icônes officielles du simulateur (rarement utile désormais).

## Où est quoi
Carte du repo : `README.md`. Fiche de vérification vivante (règle D89 : section « Dernier build » mise à jour à
chaque build) : `FICHES-VERIFICATION-APPS.md` (+ `fiches-verification.html` généré par `tools/build_fiche_html.js`).
État de la campagne : `CAMPAGNE-VERIFICATION.md`. Livraisons d'apps : `docs/audit-sociales/`, `docs/vague-a/`,
`docs/vague-b/`. Règles des constructeurs : `docs/regles-constructeur.md`. Références (frames des vidéos de Joachim)
archivées en base64 : `outils/refs-*.tar.b64.part*` (+ `outils/README-refs-*.md`).
