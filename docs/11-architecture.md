# Architecture — Lost Phone (titre interne)

> Phase ouverte le 2026-07-21 (D28 ayant levé l'interdiction D01). Cible : construire le socle CONTRE
> « Coches bleues » (P03 — structure tôt, généralisation tardive). ARCH-1 acté en D44 ; ARCH-2 à ARCH-7
> proposés en bloc (validation D45).

## ARCH-1 — La forme du moteur (ACTÉ — D44)

**Une histoire = un dossier de données déclaratives, lu par un moteur générique. Zéro code par histoire.**
Le socle s'étend quand une histoire a besoin d'une capacité nouvelle ; les histoires ne programment jamais.
Conséquences : gel = tag de version ; compatibilité = test automatique ; outils = éditeurs de données ;
production IA = écrire des fichiers, pas du code ; le débit (« une histoire en quelques jours ») devient
structurellement possible.

## ARCH-2 — La plateforme applicative [RECO : Flutter]

**Besoins** : une seule base de code pour iOS puis Android (D11, solo) ; interface ENTIÈREMENT custom quasi
pixel-perfect (on dessine un OS fictif et des clones structurels — D26) identique sur tous les téléphones
(le téléphone de Sarah est LE téléphone de Sarah) ; texte massif fluide (messageries) ; 100 % hors ligne ;
inférence ML locale embarquable (D18) ; notifications locales ; audio (vocaux) ; productivité solo + IA.

**Choix recommandé : Flutter.**
- Rendu custom intégral (le « pas de look natif » — faiblesse ailleurs — est ici LA force : nous dessinons
  notre propre OS, au pixel près, identique iOS/Android).
- Une base de code, deux plateformes ; golden tests d'interface (le pixel-perfect D26 devient testable).
- Excellent texte/scroll ; plugins mûrs pour inférence locale (ONNX Runtime / TFLite), notifications, audio.
- Corpus énorme pour les IA productrices de code (productivité) ; écosystème installé et durable.

**Alternatives écartées** : React Native (composants natifs — l'inverse du besoin ; rendu non identique entre
plateformes) ; Unity/Godot (moteurs 3D, médiocres en UI textuelle native-feel, lourds) ; double natif
SwiftUI+Compose (deux bases de code = le débit divisé, l'identité visuelle dupliquée) ; PWA/hybride web
(hors-ligne, stores et ML locaux plus fragiles).
**Coûts** : Dart (un langage de plus — mitigé par l'IA) ; ~15 Mo de base app + modèle d'interprétation
(budget Q-POIDS ≤ 50 Mo v1) ; un peu de glue native par plateforme (notifications, stockage sécurisé).

## ARCH-3 — Le format des histoires [RECO]

**Un dossier auto-contenu par histoire (D23)** :

```
histoires/coches-bleues/
├── histoire.yaml          # manifest : id, titre, version, format_version, déclarations D32-1
│                          # (posture, porteur, mix temporel, ton, format, multi-fins, politique vu/lu)
├── personnages/           # fiches + signatures d'écriture (D36 art.6)
├── conversations/         # par contact : messages horodatés, branches, choix, vocaux (+transcriptions D22)
├── apps/                  # contenu par app : photos+métadonnées, agenda, notes, banque, navigateur
├── evenements.yaml        # moteur vivant D10 : déclencheurs (état de croyance, scène) → effets, délais variables
├── checkpoints.yaml       # fenêtres, intentions, formulations-prototypes, suites d'évaluation,
│                          # sorties de secours, poids des preuves
├── fins.yaml              # conditions (épaisseur du dossier, conclusion) → épilogues
├── medias/                # images, audio
└── conception/            # toile de faits, graphe — docs d'auteur, EXCLUS du bundle joueur
```

- **YAML + schéma JSON de validation** ; `format_version` versionné — le moteur maintient la
  rétro-compatibilité (contrat D20) ; textes en clés localisables, fichiers par langue (D22, FR seul en v1).
- **Couche d'assets de marque (D40)** : `marques.yaml` global (app.messagerie.nom…) ; toute mention d'app
  simulée dans les contenus = variable `{{app.messagerie.nom}}`.
- **IDs stables** pour chaque source (épinglage joueur D17, références du graphe).
**Coûts** : discipline de schéma (linter obligatoire) ; toute évolution du format = ADR.

## ARCH-4 — L'interpréteur local [RECO]

- **Interface remplaçable (D18)** : `interpreter(checkpoint, texte_joueur) → {intention, confiance}`.
  Implémentations interchangeables ; aucune dépendance de conception au fournisseur.
- **v1 (tranche)** : embeddings sémantiques compacts SUR L'APPAREIL (classe MiniLM multilingue, export ONNX,
  20-50 Mo) : similarité entre le texte du joueur et les formulations-prototypes de chaque intention +
  seuils + règles lexicales d'appoint (marqueurs négatifs : « je sais pas » ; pièges : « thomas » → intention
  fausse-piste). Pure correspondance — jamais de génération (« interprète, jamais auteur »). Latence cible
  < 100 ms.
- **Évolution possible** : petit LLM local quantisé si la porte de qualité l'exige — l'interface absorbe le
  changement sans refonte.
- **Le banc d'évaluation (D18/D31)** : runner exécutant les suites de chaque checkpoint (DOIVENT PASSER /
  DOIVENT ÉCHOUER) ; porte de qualité chiffrée : ≥ 95 % de passes, 0 faux positif critique (une fausse piste
  validée comme conclusion = échec critique). Intégré à la CI.
**Coûts** : la qualité réelle reste à prouver (c'est LA mesure n°3 de la tranche) ; réglage des seuils.

## ARCH-5 — Le moteur d'état [RECO]

- **État de croyance (D30)** : révélations acquises + conclusion courante + pièces transmises + poids du
  dossier. Consulté par le moteur événementiel, les checkpoints et les fins.
- **Moteur événementiel (D10)** : règles déclaratives (conditions → événements), délais variables
  (brouillage anti « monde qui t'attend »), battements scénarisés ; DÉTERMINISTE à graine fixée → parties
  rejouables par script (« golden playthroughs ») pour la non-régression D20.
- **Sauvegardes** : locales uniquement (vie privée D24), liées à la version gelée de l'histoire (D20 rend
  cela trivial) ; schéma de sauvegarde versionné — les mises à jour du moteur relisent les anciennes parties.
- **Marquage joueur (D17)** : couche séparée (IDs stables), purement additive — le contenu ne mute jamais (D12).
**Coûts** : rigueur des IDs et du déterminisme ; tests dédiés.

## ARCH-6 — Le pipeline de production [RECO]

1. **Écriture** : les IA productrices génèrent les fichiers du format à partir de la toile de faits, avec la
   grammaire (D29-D32) et les chartes (D34-D36) embarquées dans leurs prompts. Curation = relecture de
   fichiers lisibles.
2. **Vérificateurs automatiques** (la QA de cohérence R3, outillée) : linter de schéma ; vérificateur
   d'horodatages (chronologie) ; vérificateur de graphe (chaque vérité majeure atteignable — la table de
   fair-play D13 exécutée en machine) ; banc d'évaluation des checkpoints ; checklist D32 partiellement
   machine-vérifiable.
3. **Pour la tranche** : pipeline volontairement semi-manuel (règle de trois P03 avant d'outiller plus).
**Coûts** : écrire les vérificateurs — mais chacun tue une classe entière de fissures d'immersion.

## ARCH-7 — Le dépôt et l'intégration [RECO]

```
lost-phone/                    # monorepo Git (hébergeur remplaçable — D23)
├── moteur/                    # app Flutter (socle : OS fictif, apps structurelles, moteurs)
├── histoires/coches-bleues/   # premier dossier d'histoire
├── outils/                    # vérificateurs, banc d'évaluation, runner de playthroughs
├── marques.yaml               # couche d'assets D40
└── docs/                      # LE SOCLE DOCUMENTAIRE (44 fichiers) — la connaissance projet emménage ici
```

- **CI** : à chaque changement du moteur → linters + banc d'évaluation + golden playthroughs de toutes les
  histoires publiées (le contrat de compatibilité D20, automatisé). Versionnage : moteur en semver ;
  histoire = `format_version` + tag de gel.
**Coûts** : quelques jours de mise en place ; discipline verte-avant-fusion.

## L'ordre de construction de la tranche (jalons)

- **M1** — Squelette : app Flutter, OS fictif minimal, écran verrouillé → WhatsApp lisible (contenu statique).
- **M2** — Le format : moteur de lecture du dossier d'histoire ; Coches bleues actes 0-1 explorables.
  **→ la mesure du débit commence ici.**
- **M3** — Le vivant : moteur d'état + événements (battements B1-B4), notifications.
- **M4** — La parole : checkpoints, interpréteur local, banc d'évaluation (porte de qualité), prototype
  « dire autre chose ».
- **M5** — Les fins : les trois épilogues, marquage joueur, polish « niveau suffisant » (D26), mesures
  complètes des 6 objectifs du jalon zéro.

Chaque jalon livre quelque chose de JOUABLE. Le feedback utilisateur (D43) commence dès M1.
