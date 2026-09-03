# Instagram — livraison v3 (D91, 03/09/2026)

**Fichier** : `src/InstagramApp.swift` — 3 656 lignes, 94 types racine, tous préfixés `Ig…`
(sauf `InstagramVue`, nom imposé par la coque, et `DonneesInsta`, conservé pour le contenu Sarah).
**Vérificateur** : `src/verif_insta.py` → **0 erreur**, 9 avertissements tous levés à la main
(`ForEach` sans `id:` sur des collections d'éléments `Identifiable`, ce qui est licite).
**Source de vérité** : `audit/instagram.md` + `refs/c2/instagram/*.jpg` (239 frames, 1 pt = 1,5 px).

> **Architecture décidée** : aucun `.sheet`, aucun `.fullScreenCover`, aucun `NavigationStack`
> dans cette app. Toute la navigation secondaire passe par `IgEtat.pile` (overlays plein cadre)
> et `IgEtat.feuille` (bottom sheets maison), dessinés dans la `ZStack` racine **sous
> `BarreHome`**. Conséquence directe : le blocage « story ouverte = enfermé dans Instagram »
> (§4.2 de l'audit) est structurellement impossible. Il n'y a donc **aucun**
> `navigationDestination` à déclarer — la contrainte « une seule fois par `NavigationStack` »
> est respectée par absence de `NavigationStack`.

---

## 1. État écran par écran

| Écran | Statut | Frames de référence | TODO tournage |
|---|---|---|---|
| **Racine + barre d'onglets** (`InstagramVue`, `IgBarreOnglets`) | ✅ fait | e001, e072, e197 | — |
| Capsule flottante 370×52 pt r 26, 16 pt de marge, 26 pt du bas, pastille active 78×41 pt `#2E3236`, ordre maison · reels · DM · loupe · avatar | | | |
| **En-tête du feed** (`IgEnteteFeed`) | ✅ fait | e001 | menu « ⌄ » réel (§5-4) |
| « + » 20 pt à gauche · **« Pour vous ⌄ » centré 24 pt gras** · cœur 21 pt + pastille rouge. **Avion + badge « 3 » supprimés** (point Joachim §4.4) | | | |
| **Rangée de stories** (`IgRangeeStories`) | ✅ fait | e001 | story LIVE d'un tiers (§5-2) |
| Cellule unique 104,5 pt, avatar 79 pt, anneau ext. 93 pt, libellé 12 pt à 9 pt sous l'avatar, marge 13 pt, badge « + » **noir bordé de blanc**, dégradé décalé de 135° (jaune `#D8BA00` en bas-gauche) | | | |
| **Publication** (`IgPostVue` et ses 4 sous-vues) | ✅ fait | e001, e003, e197 | double-tap animé validé (§5-8) |
| 5 slots dont **repost**, compteurs **inline**, menu **2 traits inégaux**, pile de mini-avatars « Aimé par », suffixe « plus », date `#6E7176`, carrousel grille 2×2 + pastille « n/n » + points bleus `#4D6CFF`, variante sponsorisée (Suivre + bandeau CTA) | | | |
| **Feuille Commentaires** (`IgFeuilleCommentaires`, `IgLigneCommentaire`) | ✅ **nouveau** | **e013**, e014–e016, **e176**–e180 | filtre « Pour vous ⌄ » des commentaires |
| Fond `#15191C`, coins hauts r 18, poignée, titre gras 17 centré, bouton rond de partage (triangle) — **•••** sur une publication de Sarah, comme e176 · filtre « Pour vous ⌄ » gris · lignes avatar 30 pt / pseudo gras + durée grise collée / texte 15 pt / « Répondre » + « Masquer » / cœur à droite + compteur dessous · **8 emojis rapides** ❤️ 🙌 🔥 👏 🥹 😍 😮 😂 · composer « Qu'en pensez-vous ? » (e013) ou « Ajoutez un commentaire… » (e176) + bouton **GIF** | | | |
| **Feuille de partage** (`IgFeuillePartage`) | ✅ **nouveau** | **e019**, e020, **e021** | défilement complet de la liste (§5-9) |
| Capsule « Rechercher » + bouton rond « nouveau groupe » · grille 3 colonnes d'avatars 74 pt avec **pastille verte de dernière activité** · rangée basse : Ajouter à la story · Copier le lien · **WhatsApp** (rond vert, bulle + combiné) · **Snapchat** (rond jaune, `IgFantomeForme` maison) · Partager dans… | | | |
| **Détail publication** (`IgDetailPostVue`) | ✅ fait | **e170**, e169–e175 | — |
| ‹ dans un bouton rond · titre « Publications » + sous-titre pseudo · pastille « 4/4 » · points sous l'image, actif **bleu** · **pas d'icône repost** · aperçu de 2 commentaires + « Voir les n commentaires » | | | |
| **Visionneuse de story** (`IgStoryVue`) | ✅ fait | **e105**–e112, e113–e120 | variante LIVE (§5-2) |
| Barre **segmentée réelle** + minuteur 5 s/segment + auto-fermeture · média pleine largeur, coins bas r 8, bande noire 96 pt · en-tête avatar 23 pt + date **gras** + piste audio · **✕ dans une cible 44×44 pt** · **glissé vers le bas** · taps latéraux · 5 icônes de réponse · **overlay, jamais `fullScreenCover` → `BarreHome` reste atteignable** | | | |
| **DM — liste** (`IgDMListeVue`) | ✅ fait | **e072**, e089–e091 | onglet « Demandes » réel (§5-10) |
| Titre « sarah.lvsr ⌄ » centré + composer · recherche `#1F2229` « Recherchez ou demandez à Meta AI » · **rangée Notes** · **onglets Messages / Demandes** · lignes avatar 50 pt, aperçu « texte · durée », pastille `#4D6CFF` · **aucun bouton caméra en fin de ligne** (point Joachim §4.6) | | | |
| **DM — conversation** (`IgFilVue`, `IgBulleFil`, `IgCarteProfilFil`) | ✅ fait | **e073**, e081–e088 | réactions par appui long (§5-10) |
| En-tête à boutons ronds + téléphone/vidéo · carte profil + « Voir le profil » · séparateur date majuscules · bulles reçues `#21242B` r 20 avec avatar 29 pt sur le **dernier du groupe** · bulles envoyées **dégradé vertical `#AD29D5`→`#6B30FE` calculé à l'échelle du fil** · composer caméra ronde indigo `#5249FF` à gauche · **« Vu » sous la dernière bulle ENVOYÉE uniquement** (point Joachim §4.3) | | | |
| **DM — réglages de fil** (`IgReglagesFilVue`) | ✅ fait | e097, e101 | contenu de chaque sous-écran |
| **Recherche / Explore** (`IgRechercheVue`, `IgMosaiqueExplore`) | ✅ fait | e145–e147, e153–e160 | rythme des tuiles (§5-7) |
| Mosaïque à **tuiles inégales** : blocs de 5, une tuile 2:3 double hauteur alternée gauche/droite, badge de vues | | | |
| **Reels** (`IgReelsVue`, `IgRailReels`) | ✅ fait | e041–e070, e193–e239 | commentaires de reel |
| En-tête **« + \| Pour vous ⌄ \| Ami(e)s »** · rail cœur/bulle/repost/send/≡ + vignette audio · **défilement vertical réel** entre 3 reels | | | |
| **Profil de Sarah** (`IgProfilVue`) | ✅ fait | e169, e185–e188 | onglets Reels/Identifications remplis (§5-6) |
| Nom **à droite de l'avatar** au-dessus des stats · 3 colonnes alignées à gauche · avatar 87 pt · **stories à la une** · soulignement d'onglet **court 63 pt** · états vides aux libellés réels (« Partagez un moment avec le monde entier » + « Créer votre premier reel », e178) | | | |
| **Profil tiers / privé** (`IgProfilTiersVue`) | ✅ fait | **e148**, e149, e097–e104 | — |
| Cadenas Ø 85 pt trait 1,5 · « Ce profil est privé » **21 pt** · lien `#4D6CFF` · bouton Suivre pleine largeur `#3C51FC` · **2 onglets** si privé · variante « c'est moi » (Modifier / Partager le profil) quand la cible est `sarah.lvsr` | | | |
| **Notifications** (`IgNotificationsVue`) | ⚠️ rendu sobre | **jamais filmé** | **§5-1 : priorité 1** |
| Correctif D82 : **chaque ligne ouvre le profil concerné** (point Joachim §4.7). Aucune invention de chrome au-delà des tokens mesurés | | | |
| **Menu du flux « ⌄ »** (`IgFeuilleMenuFlux`) | ✅ **nouveau**, D82-A | jamais filmé | **§5-4** : confirmer les entrées |
| Pour vous / Suivi(e)s / Favoris avec coche `#4D6CFF` — et le feed **change réellement** (`IgFeedVue.postsFiltres`) : le chevron est donc tenu, pas décoratif | | | |
| **Menu « ≡ » d'une publication** (`IgFeuilleOptions`) | ✅ **nouveau**, sobre | jamais filmé | **§5-5** |
| Deux jeux d'entrées (publication / profil-story). Enregistrer bascule vraiment l'état ; les autres rendent un message crédible | | | |
| **Création « + »** (`IgFeuilleCreation`) | ✅ **nouveau**, sobre | jamais filmé | **§5-3** |
| Publication / Story / Reel ouvrent la **pellicule de Sarah** ; « Message » bascule sur l'onglet DM. Aucun `NavigationStack` iOS générique (l'ancien `InstaCreationPostVue` est supprimé) | | | |
| **Picker de pellicule** (`IgFeuillePellicule`) | ✅ **nouveau** | jamais filmé | §5-3 |
| Grille 3 colonnes des photos de Sarah, sélection à cocher, « Annuler / Envoyer ». Depuis une conversation, envoie réellement un message dans le fil | | | |
| **Feuille « ≡ » du profil** (`IgFeuilleActionsProfil`) | ✅ **nouveau**, sobre | jamais filmé | §5-6 |

---

## 2. Les six points de Joachim — où ils sont traités

| Point | Traitement | Emplacement |
|---|---|---|
| « Stories mal centrées ; anneau de la mauvaise couleur » | Gabarit **unique** de 104,5 pt pour « Votre story » comme pour les autres (même `VStack(spacing: 9)`, même `.frame(width: 104.5)`), `HStack(spacing: 0)` ; `AngularGradient` avec `angle: .degrees(135)` et les 9 arrêts échantillonnés | `IgCelluleStory`, `IgCelluleVotreStory`, `IgTheme.anneau` |
| « Story ouverte = bloqué » | Overlay (pas de `fullScreenCover`) **sous `BarreHome`** · minuteur 5 s/segment + auto-fermeture · ✕ dans 44×44 pt · `DragGesture` vers le bas (> 110 pt) · taps latéraux | `IgStoryVue`, `IgCoucheOverlays`, `InstagramVue` |
| « Vu / pas encore de réponse incompréhensible » | Le mot « Vu » n'apparaît **que** sous `dernierEnvoye` (dernière bulle `deMoi == true`). Aucun aperçu générique : chaque fil a sa grammaire relevée en e072 | `IgFilVue.dernierEnvoye`, `IgBulleFil.vu`, `DonneesInsta.conversations` |
| « Petite flèche à côté du mot Instagram : retirer » | Le mot « Instagram » **n'existe plus**. En-tête = « Pour vous ⌄ » centré, et le chevron ouvre un menu qui marche | `IgEnteteFeed`, `IgFeuilleMenuFlux` |
| « Icônes sous les publications pas fidèles » | 8 formes maison en `Path` : `IgCoeurForme`, `IgBulleForme` (cercle + queue), `IgRepostForme`, `IgEnvoyerForme` (triangle inversé), `IgSignetForme`, `IgMenuDeuxTraits`, `IgFlipForme`, `IgComposerForme`. Aucun SF Symbol sur ces rôles ; compteurs inline | §1 du fichier, `IgRangeeIconesPost` |
| « Bouton caméra à droite d'une ligne DM : retirer » | Retiré (D82-C), `InstaCameraSheetVue` supprimé. L'accessoire droit est la pastille `#4D6CFF` de non-lu, ou rien. Le seul bouton caméra est le rond indigo à gauche du composer | `IgLigneConversation`, `IgFilVue.composerBarre` |
| « Une notif de profil doit ouvrir ce profil » | `onTapGesture { etat.ouvrir(.profil(l.compte.id)) }` sur **chaque** ligne | `IgNotificationsVue.vue(_:)` |

---

## 3. D82 — inventaire des boutons non triviaux

**(A) marche réellement** : likes (posts, reels, commentaires), enregistrements, suivis,
commentaire posté, emoji rapide posté, message envoyé, photo envoyée depuis la pellicule,
changement de flux, changement d'onglet DM, ouverture de profil / story / détail / fil /
notifications / réglages de fil, recherche filtrante, navigation de carrousel, segments de story,
défilement des reels, ouverture de Safari sur les liens de bio (via `Routeur.partage`).

**(B) message iOS crédible** (rare, 12 occurrences, toutes en `IgToast`) :
« Lien indisponible hors connexion » (CTA sponsorisé), « Partage vers WhatsApp / Snapchat
indisponible sans connexion », « Aucune application disponible pour ce partage »,
« Bibliothèque de GIF indisponible sans connexion », « Appel audio / vidéo indisponible »,
« Un seul compte connecté sur cet iPhone », « Aucune suggestion pour le moment »,
« Blocage indisponible dans cette version », « Choisissez d'abord une photo ».

**(C) retiré** : bouton caméra des lignes DM, `InstaCameraSheetVue`, `InstaAjoutStoryVue`,
`InstaCreationPostVue`, le mot « Instagram » et son chevron, l'avion + badge « 3 » de l'en-tête,
les libellés d'états vides inventés (« Aucun reel », « Photos et vidéos de vous » sur le reel).

Les libellés portant explicitement « — TODO tournage » (17 occurrences, messages et commentaires de code) marquent les surfaces
que l'audit demande de filmer avant de les coder : filtre des commentaires, nouveau message,
nouveau groupe, Notes, options de recherche, historique de recherche, commentaires de reel,
caméra de story, sous-écrans des réglages de fil, entrées de la feuille profil.

---

## 4. Risques de compilation évités (règles projet)

| Règle | Ce qui a été fait |
|---|---|
| Ternaires de couleur toujours typés | 8 occurrences corrigées (`? .white : .white.opacity(…)` → `? Color.white : Color.white.opacity(…)`, `: .white` → `: Color.white`). Le vérificateur refuse tout `?` suivi d'un membre implicite dans un contexte `foregroundStyle / fill / stroke / strokeBorder / tint / background / shadow`. **0 restant.** Les ternaires de `Font.Weight` (`.bold : .regular`) et d'`Alignment` (`.trailing : .leading`) sont laissés : ils ne passent jamais par `HierarchicalShapeStyle` |
| Pas de `.background(Color…, in:)` ambigu avec opacité | Aucune occurrence : toutes les surfaces passent par `Shape().fill(...)` en `background`/`overlay` |
| `navigationDestination` unique | Aucun `NavigationStack`, donc aucun `navigationDestination` (voir l'encadré d'architecture) |
| Pas de `.scaledToFill()` direct sur une `Image` en cellule | `IgPhoto` enveloppe systématiquement : `Color.clear.overlay(Image…resizable().scaledToFill()).clipped()` |
| Vues courtes, pas d'expression géante | 94 types ; chaque écran est éclaté en sous-vues et en propriétés `private var` / `private func` — la plus longue expression enchaîne 8 modificateurs |
| Pas de clé dupliquée dans un dictionnaire | Aucun littéral de dictionnaire multi-clés dans le fichier (contrôlé) |
| `@Published` sur `ObservableObject` | `IgEtat` : 15 propriétés, toutes `@Published` |
| Pas d'API iOS 18+ | Contrôle sur 18 motifs (`glassEffect`, `onScrollGeometryChange`, `MeshGradient`, `@Entry`, `scrollEdgeEffect`, `safeAreaBar`…). `UnevenRoundedRectangle` est iOS 17, donc autorisé |
| Pas de doublon de type | Croisé avec `LPProto.swift`, `MessengerApp.swift`, `SnapchatApp.swift`, `NotesApp.swift` et `parts/fb_*.swift`, `parts/snap_*.swift` : **0 collision**. Tout est préfixé `Ig…` |
| Pas de force-unwrap dans les captures | `IgCatalogue.post/conversation/reel` rendent des valeurs non optionnelles avec repli ; aucune occurrence de `!` de déballage |
| Chaînes fermées, accolades/parenthèses équilibrées | Contrôlé caractère par caractère après retrait des commentaires et des littéraux |
| `ForEach` avec `id` | Tous les `ForEach` sur `enumerated()`, `Range` ou `[String]` portent un `id:` ; les 9 sans `id:` portent sur des collections d'éléments `Identifiable` (`IgPost`, `IgCompte`, `IgConversation`, `IgNote`, `IgCommentaire`, et deux structs locales) |
| `Color(hex:)` entiers | Toutes les valeurs sont des littéraux `0xRRGGBB` ou des constantes nommées |

**Piège structurel évité** : la fonction d'aide de la rangée de partage a d'abord été nommée
`action(libelle:fond:icone:action:)` — un nom de méthode identique à l'étiquette de son dernier
paramètre, appelé en double closure terminale (`} action: {`) à l'intérieur d'un `ViewBuilder`.
Renommée en `celluleAction(libelle:fond:icone:faire:)` pour retirer toute ambiguïté de
résolution.

---

## 5. Ce qui reste à faire (hors périmètre de ce lot)

1. **Appliquer `src/patches/instagram-lpproto.md`** dans `LPProto.swift` — sans lui le projet ne
   compile pas (les 5 types v1 cités par l'ancien `ecransInstagram()` n'existent plus).
2. Ajouter les 16 lignes de `src/patches/instagram-ecrans.txt` à `outils/ecrans.txt`.
3. Tournage Joachim, par priorité décroissante : notifications (§5-1), story LIVE d'un tiers
   avec sa fermeture (§5-2), « Votre story » + menu du « + » (§5-3), menu « ⌄ » (§5-4),
   menu « ≡ » d'une publication (§5-5), profil perso complet (§5-6), Explore au repos (§5-7),
   double-tap et like de commentaire (§5-8), feuille de partage complète (§5-9), onglet
   « Demandes » et réactions par appui long (§5-10).
4. Passage Codemagic (Xcode 26, iOS 17+) puis boucle miroir sur les 16 clés.
