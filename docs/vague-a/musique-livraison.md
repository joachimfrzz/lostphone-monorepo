# Musique (Apple Music) — livraison v1 D92, 06/09/2026

**Fichier** : `src/MusiqueApp.swift` — 3 115 lignes, 51 vues, racine `MusiqueVue`.
**Patch** : `src/patches/musique-integration.md` + `src/patches/musique-ecrans.txt`.
**Références** : `refs/vagueA/musique/e001.jpg … e180.jpg` (603×1311 px, 1 pt = 1,5 px).
Planches de contact lues : `planches/musique/pl0.jpg`, `pl1.jpg`, `pl2.jpg` (60 frames chacune),
puis frames en pleine taille (×2) pour les mesures : **e001** (Accueil), **e026** (lecteur),
**e055** (Radio), **e072** (Bibliothèque), **e078** (playlist ouverte), **e102** (album ouvert),
**e131** (Rechercher).

---

## 1. Inventaire des 180 frames → écrans distincts

| Frames | Écran | Statut v1 |
|---|---|---|
| e001-e022, e037, e178-e180 | Accueil « Pour vous » (cartes, Écoutés récemment, indispensables, playlists sur mesure, radios personnalisées) | **reproduit** |
| e008-e012 | Écoutés récemment (plein écran) | **reproduit** |
| e023-e031 | Lecteur plein écran + « Poursuivre la lecture » | **reproduit** |
| e032-e036 | Menu « … » du lecteur | **reproduit, allégé** (§ 4) |
| e038-e042, e051-e052 | Nouveautés (album vedette, Titres du moment, Sorties récentes) | **reproduit** |
| e043-e054 | Titres du moment (liste) | **reproduit** |
| e055-e071 | Radio (6 stations, À l'antenne, À l'écoute) | **reproduit** |
| e068-e130 | Bibliothèque (5 rubriques + Ajouts récents) | **reproduit** |
| e077, e082, e126-e127 | Playlists (liste) | **reproduit** |
| e078-e081 | Playlist ouverte | **reproduit** |
| e084-e086, e123-e124 | Artistes (liste + index alphabétique) | **reproduit** |
| e087-e101 | Artiste ouvert | **reproduit** |
| e102-e115 | Album ouvert (pochette, Lecture, description PLUS, pistes, crédits) | **reproduit** |
| e116-e122 | Morceaux / Albums / Téléchargements | **reproduit** |
| e131-e139 | Rechercher (tuiles de catégories) | **reproduit** |
| e140-e161 | Recherche active + résultats segmentés | **reproduit** (§ 3) |
| e134-e137 | Page de catégorie (« Pop ») | **reproduit** en page de genre |
| e162-e179 | Compte Apple, Réglages Musique, Réglages iOS → Musique, Apps par défaut | **retiré (D82-C)** |
| — | « Concerts près de chez vous », « Trouvez la musique selon vos humeurs », Classements, Replay mensuel, Clips vidéo, Paroles synchronisées | **retiré (D82-C)** : bandeaux publicitaires ou contenus inexistants |

Chartes relevées : fond `#000000`, accent Apple Music `#FA2D48`, gris libellés `#8E8E93`,
séparateurs `#2C2C2E`, cartes `#1C1C1E`, tuiles de station `#F2F2F5`.
Barre d'onglets iOS 26 = **capsule flottante** de 4 onglets + **capsule ronde séparée** (loupe) ;
mini-lecteur = capsule `.ultraThinMaterial` juste au-dessus. Sur l'onglet Rechercher, la barre
d'onglets est remplacée par le champ « Artistes, morceaux, paroles… » + pastille maison (e131).

## 2. Contenu de Sarah (D59) — le gabarit de Joachim est intégralement remplacé

Disparus : « Station de : Joachim Fourez », playlist « 1 » de Joachim, « AirPods de Joachim »,
The Swiss, Notion, Patrick Swayze, N.Fostell, Opus, Niska, Maëlle, Bad Bunny en tête d'affiche.

**Catalogue : 127 morceaux exactement**, ce que Réglages annonce — vérifié par script.
Ils sont répartis sur **13 albums / 13 artistes**, tous atteignables :

| Album | Artiste | Genre | Pistes |
|---|---|---|---|
| Nonante-Cinq | Angèle | Pop française | 12 |
| Back to Black | Amy Winehouse | Soul | 11 |
| DeBÍ TiRAR MáS FOToS | Bad Bunny | Latin | 10 |
| Le Fléau | GIMS | Rap français | 10 |
| La Machine | Jul | Rap français | 12 |
| Jefe | Ninho | Rap français | 10 |
| After Hours | The Weeknd | R&B | 11 |
| Cœur | Clara Luciani | Pop française | 10 |
| Chris | Christine and the Queens | Pop | 11 |
| Dissidænce | Vitalic | Électronique | 9 |
| Tricheur | Marine | Pop française | 6 |
| Inner Light | Elderbrook & Bob Moses | Électronique | 5 |
| Fantôme | Rim'K | Rap français | 10 |

Cohérence avec `SpotifyApp.swift` : Jul, Ninho, Rim'K, GIMS, Angèle, Marine, Bad Bunny,
Amy Winehouse, The Weeknd, Elderbrook & Bob Moses, la playlist « Randonnée 🥾 » et les mixes
« sur mesure » sont repris d'un univers à l'autre.

**Playlists de Sarah** (le nombre de titres affiché est TOUJOURS calculé, jamais écrit en dur) :

- **« Marseille — le 28 ⚓️ »**, 9 titres — *« Pour la route du 28. Il a dit qu'il mettrait la
  même de son côté en partant. »* → **l'indice** : écho direct à la note
  « Idées week-end Marseille » (`NotesApp.swift`, « ⚓️ Le 28 !!! ») et au rendez-vous avec Marc.
  Elle est aussi la 3ᵉ carte de « Pour vous » et la source de la lecture en cours à l'ouverture.
- « Labo photo — nuit », 8 titres (Sarah est photographe : ce qui tourne pendant les tirages).
- « Randonnée 🥾 », 7 titres (Monts d'Or, Pilat, une fois les Calanques).
- « Terrasses de la Croix-Rousse », 6 titres (Lyon).
- « Kiné / respirer », 5 titres (l'épaule droite — cohérent avec les notes Santé).
- « Morceaux préférés » : **dynamique**, alimentée par l'étoile du lecteur et le menu « … »
  (12 titres au départ, dont Marine — Tricheur et Jul — La Machine).

État d'ouverture : Sarah a laissé « Tricheur » de Marine **en pause à 0:41**, lue depuis
« Marseille — le 28 ⚓️ » — visible au premier coup d'œil dans le mini-lecteur.

## 3. Ce qui marche réellement (D82-A, D92)

- **Lecture = un seul état** (`MuLecture.partage`, `@Published`) : mini-lecteur ↔ lecteur plein
  écran ↔ file d'attente montrent toujours le même morceau, la même progression, le même favori.
  Progression animée par un `Timer` d'1 s à la racine, enchaînement automatique en fin de piste.
- Lecteur plein écran : pochette, étoile (favori **persistant**, il alimente « Morceaux
  préférés »), menu « … », barre de progression **déplaçable**, ⏪ / ⏸ / ⏩ (⏪ revient au début
  puis passe au précédent, comme iOS), curseur de volume déplaçable, sortie « AirPods de Sarah »,
  bouton file d'attente.
- File d'attente : « En cours » + « À suivre » réels ; taper un titre saute dessus.
- Bibliothèque navigable : les 5 rubriques ouvrent des **listes réelles** — 127 morceaux
  (avec champ de recherche local), 13 albums, 13 artistes (index alphabétique), 5 playlists
  + Morceaux préférés, 4 albums téléchargés. Chaque compteur = ce qui est réellement affiché.
- Album ouvert : Lecture / aléatoire / télécharger (bascule en ✓), description repliable « PLUS »,
  pistes numérotées, crédits calculés (« N morceaux, M minutes ») ; l'artiste est cliquable.
- Artiste ouvert : Lecture / Aléatoire, ses albums, tous ses morceaux.
- Radio : 6 stations Apple Music (vraies stations, conservées du gabarit), chacune ouvre une page
  qui **joue vraiment** dans le catalogue de Sarah ; « À l'écoute » lance l'émission.
- **Rechercher réellement filtrante** : le texte filtre titres / artistes / albums / genres /
  playlists / stations et les résultats sont groupés (Artistes, Albums, Playlists, Émissions de
  radio, Morceaux), tous cliquables. Segment « Apple Music / Bibliothèque » : la bascule change
  la portée pour de vrai (les émissions de radio ne sortent qu'en « Apple Music »).
- Les 8 tuiles de catégories ouvrent chacune un genre **peuplé** (vérifié par script : aucune
  tuile ne mène à une liste vide).
- Menu « … » d'un morceau : Ajouter / Retirer des morceaux préférés, Lire ensuite, Ajouter à la
  fin de la file, Lire maintenant — 4 actions qui modifient l'état visible immédiatement.
- Rien ne survit à son écran : le menu « … » et les paroles sont des `sheet` à état **local**
  (`@State` de la cellule / du lecteur), jamais un drapeau global.

## 4. Retiré, et pourquoi (D82-C / D92) — à signaler à Joachim

Du menu « … » filmé (e032-e036) : **Épingler le morceau** (aucune surface d'épingles dans
l'app), **Créer une station** (une station de plus, vide), **Afficher les crédits** (les crédits
utiles sont déjà en bas de l'album), **Partager les paroles** (pas de paroles dans le jeu),
**Supprimer de la bibliothèque** (casserait les 127 morceaux annoncés par Réglages).
Ailleurs : **Compte Apple** et **Réglages Musique** (e162-e179 — pas d'histoire dedans, et
Réglages du jeu existe déjà), **Concerts / humeurs / Classements / Replay mensuel** (bandeaux
promotionnels sans contenu), **Clips vidéo** (aucune vidéo dans le catalogue),
**Paroles synchronisées** (D51 : pas d'audio, une synchronisation serait fausse) — remplacé par
un message iOS crédible (D82-B) : « Les paroles de ce morceau ne sont pas incluses dans le
téléchargement. »

**Si l'un de ces éléments doit servir à une histoire, dis-le** : « Partager les paroles » vers
WhatsApp/Messenger et « Créer une station » sont les deux plus faciles à rebrancher.

## 5. Audio (D51)

Aucun `AVAudioPlayer`, aucune forme d'onde, aucun composant audio réutilisable n'existe dans
`LPProto.swift` / `SpotifyApp.swift` (grep `AVAudioPlayer`, `Lecteur`, `waveform` : seule
l'icône SF `waveform` du Dictaphone ressort), et aucune ressource musicale libre de droits n'est
présente dans le dépôt. La lecture est donc **un état** : progression animée, enchaînement,
pause, saut, volume. Les pochettes sont **dessinées** (dégradé de la teinte de l'album +
monogramme + titre gravé) : aucun asset d'image n'est requis, donc aucun `.scaledToFill()`.

## 6. Vérification (script `src/verif_musique.py`, sortie ✓)

`python3 src/verif_musique.py` :

- accolades / parenthèses / crochets équilibrés (hors chaînes et commentaires) ;
- 0 collision de type ou de globale avec `LPProto.swift`, `MessengerApp.swift`,
  `InstagramApp.swift`, `SnapchatApp.swift`, `FacebookApp.swift`, `NotesApp.swift` ;
- les 51 vues ont un `body`, aucun nom déclaré deux fois ;
- tous les `ForEach` ont un `id:` explicite ou portent sur un type `Identifiable` du fichier ;
- aucun ternaire de style en ligne (couleurs, `lineLimit`, tailles : tous passés par une
  variable typée `let x: Color / Int? / CGFloat`) ;
- aucune API iOS 18+/26, aucun `.scaledToFill()`, aucun `.background(Color…, in:)` ambigu ;
- **un seul** `navigationDestination` dans le fichier (dans `MuPile`), donc un par
  `NavigationStack` ;
- aucune clé de `switch` dupliquée ; `@Published` uniquement dans `MuLecture: ObservableObject` ;
- **cohérence D92 des compteurs** : 127 morceaux déclarés pour 127 annoncés, 13 albums pour
  13 listes de pistes, 100 % des références de playlists / favoris / titres du moment résolues
  (9/9, 8/8, 7/7, 6/6, 5/5, 12/12, 10/10), 0 catégorie de recherche sans contenu ;
- tous les types `Mu*` utilisés sont déclarés.

## 7. Reste à faire (v2)

- Une seule pochette « photo » possible si Joachim fournit des visuels d'albums (le composant
  `MuPochette` accepterait un `ChargeurPhoto.image(...)` en surcouche, pattern
  `Color.clear.overlay(...).clipped()`).
- Éventuel branchement Musique → Messages/WhatsApp (partager un morceau) si l'histoire l'exige.
- « Écouté récemment » pourrait devenir un véritable historique alimenté par la lecture
  (aujourd'hui c'est une liste fixe de 10 albums, cohérente avec ce que Sarah possède).
