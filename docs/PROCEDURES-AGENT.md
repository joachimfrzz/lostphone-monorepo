# Procédures opérationnelles de l'agent — Lost Phone sur Hyperagent (10/09/2026)

Tout ce qu'un nouvel agent doit savoir FAIRE (le QUOI et l'ÉTAT sont dans `project_memory.json`).
Chaque procédure a été éprouvée entre le 26/08 et le 10/09/2026 ; les pièges listés ont tous été rencontrés.

## 1. Cycle standard d'un lot d'apps
1. Joachim envoie un lien **SwissTransfer** (vidéos d'enregistrement d'écran de son iPhone, une par app).
2. Télécharger et extraire les frames (§2), regarder les planches, archiver dans le repo (§3).
3. Lancer des **sous-agents constructeurs** (§4), un par app, avec `docs/regles-constructeur.md` + `PayPalApp.swift`
   comme modèle. Ils livrent `src/<App>App.swift`, `docs/vague-x/<app>-livraison.md` (avec les cas de registre),
   `verif_<app>.py`.
4. **Intégrer dans `LPProto.swift`** : état `xxxOuvert`, icône (page 1/2, `AppIcone.assets` si vraie icône),
   `fermerToutesLesApps`, `actionPour`, `.fullScreenCover`, famille + registre `ecransXxx()`, clés dans
   `outils/ecrans.txt` et un registre ciblé `outils/ecrans-<lot>.txt`. Vérifier accolades et types référencés par script.
5. Pousser (§5) puis **miroir ciblé** : `api.py start miroir-captures main ECRANS_FICHIER=outils/ecrans-<lot>.txt`.
   Boucler jusqu'au vert (corriger → pousser → relancer) SANS repasser par Joachim.
6. Récupérer `captures.zip` (curl avec header `x-auth-token`), faire des planches (PIL), les REGARDER : contenu de Sarah,
   absence de données de Joachim (D59), aucune capture noire/blanche.
7. Mettre à jour `FICHES-VERIFICATION-APPS.md` (section « Dernier build » + checklist, D89), `CAMPAGNE-VERIFICATION.md`,
   `project_memory.json`, régénérer `fiches-verification.html`, pousser, republier la page.
8. Demander le **GO** de Joachim → `api.py start duel-swift-testflight main` → suivre → consigner.
9. Ses retours arrivent en vrac → cahier des charges du lot correctif (D92 : moins de fonctions mais cohérentes ;
   D94 : juger l'utilité pour TOUTES les histoires ; lister les retraits à potentiel narratif au lieu de supprimer).

## 2. Vidéos SwissTransfer → frames de référence
- Métadonnées : `GET https://www.swisstransfer.com/api/links/{linkUUID}` → `data.downloadHost`, `data.container.files[]`
  (`UUID`, `fileName`, `fileSizeInBytes`).
- Téléchargement : `https://{downloadHost}/api/download/{linkUUID}/{fileUUID}` (curl -L, User-Agent quelconque, pas de token).
  Fichiers de 150-600 Mo : c'est normal (1206×2622, 60 i/s).
- Extraction : `ffmpeg -i v.mp4 -vf "fps=1,scale=603:-1" f/%04d.png` puis déduplication PIL (différence moyenne en
  niveaux de gris sur 60×130 < 3,5 → doublon) → renommer `e001.jpg…` (qualité 88). **603×1311 px = 1 pt × 1,5.**
- Planches de contrôle : grilles 6-8 colonnes, nom de frame en jaune ; les lire pour repérer les données personnelles
  de Joachim (à ne JAMAIS reproduire — D59) et les écrans clés à donner aux constructeurs.

## 3. Pousser des binaires dans le repo (limite MCP GitHub)
- `github__push_files` refuse un corps > ~3 Mo (« request body too large »). Règle : **un fichier de 2,8 Mo par commit**.
- Frames : `tar -cf refs.tar refs/<lot> && base64 -w0 refs.tar > refs.tar.b64 && split -b 2800000 -d -a 2 refs.tar.b64 refs.tar.b64.part`
  → `outils/refs-<lot>.tar.b64.partNN`, un commit par part (déléguer à un sous-agent sonnet « archiviste », séquentiel).
  Ajouter `outils/README-refs-<lot>.md` (reconstitution : `cat part* | base64 -d | tar -x`).
- Icônes d'apps (180×180, sans alpha) : petit tar b64 `outils/icones-<lot>.tar.b64` + bloc dans `outils/decode-binaires.sh`
  qui les copie vers `proto-swift/Ressources/ic-<cle>.png` ; déclarer `AppIcone.assets["Nom"] = "cle"`.
- Toujours écrire le JSON de paramètres avec un script (python) et passer `paramsFile` — jamais le contenu dans le chat.
- Lire un fichier du repo : `github__get_file_contents` ; si la réponse est externalisée, parser
  `content[type=resource].resource.text` et retirer l'enveloppe `<mcp-tool-result vendor="github">`.

## 4. Sous-agents (Agent tool)
- Constructeurs d'apps : modèle **opus**, un par app, en parallèle, en arrière-plan. Prompt = mission précise (fichier,
  préfixe de types unique, vue racine), chemins des frames, contenu narratif à produire, liste des cas de registre attendus,
  + l'ordre de lire `docs/regles-constructeur.md` et `PayPalApp.swift` d'abord. Durée 20-45 min.
- Archiviste / pousseur : modèle **sonnet**, séquentiel.
- Chercheurs de captures officielles (D93) : sonnet, un par app, avec la liste de sources autorisées et le test de récence.
- Après livraison : relire le registre proposé, vérifier par script que chaque type référencé existe dans le fichier,
  exécuter `verif_<app>.py`, contrôler `.sheet`/`.fullScreenCover` (interdits), APIs iOS 18+, ternaires non typés.
- Les rapports de sous-agents arrivent en anglais ou en français : **toujours relayer en français** à Joachim.

## 5. Push standard (code + docs)
Un seul `github__push_files` avec tous les fichiers texte du lot (700 Ko OK) : `proto-swift/Sources/*.swift`,
`outils/ecrans*.txt`, `outils/decode-binaires.sh`, `docs/**`, `outils/verif_*.py`, `project_memory.json`,
`FICHES-VERIFICATION-APPS.md`, `CAMPAGNE-VERIFICATION.md`, `fiches-verification.html`. Message de commit en français.

## 6. Pièges de compilation (résumé — détail dans `docs/regles-constructeur.md`)
Ternaire de style typé (`Color.a : Color.b`), pas de `.background(x.opacity(), in:)`, `scaledToFill` via
`Color.clear.overlay(...).clipped()`, un seul `navigationDestination`, pas de clés dupliquées dans un dictionnaire
(crash runtime), pas d'API iOS 18+, préfixes de types uniques, aucun `.sheet`/`.fullScreenCover` dans une app
(la BarreHome doit rester visible — bug Facebook build 279), vues courtes.

## 7. Fiche de vérification et page publiée
`FICHES-VERIFICATION-APPS.md` → `node tools/build_fiche_html.js` → `fiches-verification.html` → publiée comme page
Hyperagent (republier le même artefact à chaque build). Section « Dernier build » : n°, heure, ce qui est nouveau,
checklist à cocher (10-15 points), rappel de la checklist précédente si non faite. Tableau « Sessions et builds ».

## 8. Le canon des décisions récentes à connaître par cœur
- **D59** données de Joachim = gabarits ; tout est remplacé par le personnage (Sarah Levasseur, Lyon).
- **D63/D65** boucle miroir libre ; TestFlight uniquement sur GO explicite.
- **D67** références = les enregistrements de Joachim, jamais la mémoire du web. **D93** : à défaut, captures officielles
  de l'éditeur (App Store, guide Apple), datées 2025-2026.
- **D82** chaque bouton : A marche / B message iOS crédible (rare) / C retiré. **D92** juste milieu : moins de
  fonctionnalités mais cohérentes ; compteurs = contenu accessible ; lister les retraits à potentiel narratif.
- **D89** fiche mise à jour à chaque build. **D91** refonte des 4 sociales sur les vidéos (faite, builds 279-280).
- **D94** le téléphone est une plateforme pour TOUTES les histoires : une fonctionnalité se juge sur son utilité pour
  une histoire plausible, pas pour l'histoire de Sarah seule.

## 9. Bibliothèque de fichiers de travail (dans le repo)
`docs/regles-constructeur.md` (règles des constructeurs), `docs/vague-a/*`, `docs/vague-b/*` (livraisons, relecture D94),
`docs/audit-sociales/*` (audit + lots 279/280), `outils/README-refs-vagueA.md`, `outils/README-refs-vagueB.md`,
`refs-officiel/*/SOURCES.md` (sources des captures officielles), `tools/build_fiche_html.js`, `tools/passation/api.py`
(copie du script de la skill Codemagic), `liste-apps.yaml` (catalogue des 70 apps, cercles 1-3).
