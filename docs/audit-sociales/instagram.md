# Audit Instagram — Lost Phone

**Date** : 03/09/2026
**Source de vérité (D67)** : `/agent/workspace/refs/c2/instagram/` — 239 frames, 603×1311 px.
**Code audité** : `proto-swift/Sources/InstagramApp.swift` (SHA `8900c5c`), + `InteractionsPartagees.swift` (SHA `e76aad7`).
**Conversion** : 1 pt = 1,5 px (facteur réel relevé 603/393 = 1,534 → les valeurs pt ci-dessous sont à ±2 %).
**Verdict Joachim** : « beaucoup de choses à revoir ; il faut le revoir de manière globale ».

> **Conclusion en une phrase** : l'app codée reproduit Instagram *2022*. Les enregistrements montrent Instagram *iOS 26*, qui a changé de barre d'onglets, d'en-tête, de jeu d'icônes, de couleur d'accent et de présentation des DM. Ce n'est pas une liste de retouches : **c'est une réécriture de la coquille (chrome) + 8 écrans manquants**, avec conservation du contenu Sarah.

---

## 0. Le choc principal : la coquille n'est pas la bonne

| Élément | Vidéo (iOS 26) | Code | Gravité |
|---|---|---|---|
| Barre d'onglets | **Capsule flottante** ~370×52 pt, centrée, 16 pt de marge latérale, 26 pt du bas, fond noir translucide flouté, coins = h/2. 5 items : maison, reels, **DM (triangle send + pastille rouge)**, loupe, avatar | Barre **pleine largeur opaque** collée en bas, filet `#262626`, 5 items : maison, loupe, **plus.app**, reels, avatar | 🔴 bloquant |
| Onglet actif | Pastille claire arrondie ~78×41 pt (r≈20 pt), fond ≈ `#2E3236`, sous l'icône | Icône `.fill` uniquement | 🔴 |
| Le « + » | **En haut à gauche du feed**, glyphe 20 pt | Dans la barre d'onglets (3ᵉ position) | 🔴 |
| Les DM | **Onglet n°3 de la barre**, écran plein (pas une feuille) | Feuille (`.sheet`) ouverte depuis l'avion en en-tête | 🔴 |
| Titre du feed | **« Pour vous ⌄ »** centré, ~24 pt gras | **« Instagram »** aligné à gauche + chevron | 🔴 |
| Couleur d'accent | **`#3C51FC`** (boutons pleins) / **`#4D6CFF`** (liens, pastilles, points actifs) | `#0095F6` (le bleu d'avant iOS 26) partout | 🔴 |
| Fond | `#000000` pur | `#000000` ✅ | ✅ |

Frames témoins : `e001` (feed), `e072` (DM liste, barre flottante bien visible), `e170` (détail publication).

---

## 1. Inventaire des écrans filmés

| # | Écran | Frames repères | Dans le code ? |
|---|---|---|---|
| A | **Feed « Pour vous »** : en-tête + rangée de stories + publications | `e001`–`e012`, `e025`–`e032` | Partiel, dévie fortement |
| B | **Publication carrousel dans le feed** (grille 2×2, compteur `4/4`) | `e001`, `e002` | ❌ absent |
| C | **Publication sponsorisée** (« Sponsorisé », CTA « S'inscrire › », « …détails ») | `e003`, `e004` | ❌ absent |
| D | **Feuille Commentaires** (poignée, titre, filtre « Pour vous ⌄», rangée d'emojis, champ « Qu'en pensez-vous ? », GIF) | `e013`–`e016`, `e176`–`e180` | ❌ absent |
| E | **Feuille de partage** (« Rechercher », grille de destinataires, rangée Ajouter à la story / Copier le lien / WhatsApp / Snapchat / Partager dans…) | `e019`–`e021` | ❌ absent |
| F | **Reels plein écran** (« + | Pour vous ⌄ | Ami(e)s » en haut, colonne d'actions à droite) | `e041`–`e070`, `e193`–`e239` | Partiel, dévie |
| G | **Recherche / Explore** (loupe, clavier, « Récent / Voir tout », résultats comptes, mosaïque à tuiles inégales) | `e017`–`e018`, `e145`–`e147`, `e153`–`e160` | Partiel, dévie |
| H | **Profil tiers public** (stats en ligne, à la une, 3 onglets) | `e097`–`e104`, `e121`–`e128` | Partiel, dévie |
| I | **Profil tiers privé** (« Ce profil est privé ») | `e148`, `e149` | Présent, dévie |
| J | **Profil perso** (« Modifier / Partager le profil » + icône personne) | `e169`, `e185`–`e188` | Présent, dévie |
| K | **Détail publication** (« Publications » + sous-titre, carrousel, points bleus) | `e169`–`e175` | ❌ absent |
| L | **Onglet Identifications** (+ bouton « Gérer ») | `e189`–`e196` | Vide/faux |
| M | **Visionneuse de story** (archive / à la une : barre segmentée, date, piste audio, ✕) | `e105`–`e112`, `e113`–`e120` | Présent, dévie très fortement |
| N | **DM — liste** (titre pseudo ⌄, compose, recherche Meta AI, **Notes**, onglets Messages/Demandes) | `e072`, `e089`–`e091` | Présent, dévie très fortement |
| O | **DM — conversation** (en-tête à 2 boutons ronds, carte profil, bulles dégradées, composer indigo) | `e073`, `e081`–`e088` | Présent, dévie très fortement |
| P | **DM — réglages de conversation** (Personnaliser, Pseudos, Messages éphémères, Confidentialité et sécurité, Créer une discussion de groupe, Quelque chose ne fonctionne pas) | `e097`, `e101` | ❌ absent |
| Q | **Mini-carte profil dans un fil** (« Voir le profil ») | `e057`, `e073` | ❌ absent |
| R | **États vides** (« Aucune publication », « Partagez un moment avec le monde entier » + « Créer votre premier reel ») | `e097`–`e099`, `e178` | Faux libellés |
| S | **Cartes « Comptes populaires suggérés » / « Suggestions pour vous »** dans le feed et le profil | `e026`, `e197`–`e199` | ❌ absent |
| — | **Notifications (onglet cœur)** | **JAMAIS FILMÉ** | Présent dans le code |

---

## 2. Mesures relevées au pixel

### 2.1 En-tête du feed (`e001`)
| Élément | px | pt |
|---|---|---|
| « + » (glyphe), centre x | 42→72, cy 131 | Ø 20 pt, centre à 38 pt du bord |
| « Pour vous » | x 210→398 (**centré**, cx 304 ≈ centre écran 301,5) ; hauteur de casse 120→146 | ~24–25 pt, gras |
| Chevron ⌄ | juste après le texte, ~9 pt | |
| Cœur (activité) | x 530→562, y 118→146 | Ø ~21 pt ; marge droite 27 pt |
| Pastille rouge | coin sup. droit du cœur | Ø ~5 pt, `#FF3B30` |

### 2.2 Rangée de stories (`e001`) — **la mesure la plus importante**
| Grandeur | px | pt | Code |
|---|---|---|---|
| Ø photo de l'avatar | 118–119 | **79 pt** | 62 pt ❌ |
| Ø extérieur de l'anneau | 139 | **93 pt** | ~68 pt ❌ |
| Épaisseur de l'anneau | 5 | **3,3 pt** | 2,5 pt |
| Écart anneau/photo (noir) | 5 | **3,3 pt** | 3 pt ✅ |
| **Pas entre 2 stories (centre à centre)** | 156,5 | **104,5 pt** | 72 + 14 = 86 pt ❌ |
| Marge gauche (bord écran → bord avatar) | 19 | **13 pt** | 14 pt ✅ |
| Libellé, ligne de base | y 328→335 | ~12 pt regular | 11,5 pt ✅ |
| Écart avatar ↔ libellé | ~13 | ~9 pt | 4 pt ❌ |
| « Votre story » | avatar gris `#E0E4E7` **sans anneau**, badge « + » en bas à droite, cercle **noir** bordé de blanc | code : badge bleu `#0095F6` ❌ |

### 2.3 Dégradé de l'anneau de story — échantillonné à r = 67 px, centre (235, 241) de `e001`
| Angle (0° = droite, sens horaire) | Hex |
|---|---|
| 0° (droite) | `#E71197` |
| 45° (bas-droite) | `#F6122B` |
| 90° (bas) | `#F19A0C` |
| **135° (bas-gauche)** | **`#D8BA00`** ← le jaune est ici |
| 180° (gauche) | `#F09A09` |
| 225° (haut-gauche) | `#E4162D` |
| 270° (haut) | `#CE1384` |
| **315–330° (haut-droite)** | **`#DD0AAF` → `#C916CA`** ← le violet est ici |

**Lecture** : dégradé quasi **symétrique par rapport à l'axe bas-gauche / haut-droite** — jaune `#D8BA00` à 135°, puis orange `#F19A0C`, rouge `#F6122B`, magenta `#E71197`, violet `#C916CA` à 315°. **Aucun bleu-violet profond n'apparaît nulle part** : le maximum de violet relevé est `#C916CA`.

> **Cause du défaut « mauvaises couleurs de cerclage »** : le code fait
> `AngularGradient(colors: [0xF9CE34, 0xEE2A7B, 0x6228D7, 0xF9CE34], center: .center)`.
> `AngularGradient` démarre à **0° = droite** et tourne dans le sens horaire → il place **le jaune à droite**, le rose en bas, **le violet à gauche**. La référence a **le magenta à droite et le jaune en bas-gauche** : le dégradé est **décalé d'environ 135°**. En plus `#6228D7` (violet-bleu) est ~2× trop foncé et trop bleu par rapport au `#C916CA` relevé.

### 2.4 Rangée d'icônes d'une publication (`e003`, y ≈ 148)
| Slot | x (px) | Taille | Forme relevée (agrandissement ×3) |
|---|---|---|---|
| 1. Cœur | 20→48 | Ø 19 pt, trait ~1,7 pt | Cœur outline **large et rond**, creux central profond, pointe basse courte |
| — « 138 K » | 52→113 | ~14 pt semibold blanc | compteur **inline à droite de l'icône** |
| 2. Commentaire | 140→172 | Ø 21 pt | **Cercle parfait** + petite queue triangulaire en bas-droite. **PAS** une bulle rectangulaire arrondie |
| — « 318 » | 186→216 | | |
| 3. **Repost / Remix** | 243→270 | Ø 18 pt | **Deux flèches en boucle verticale** (⇅ recyclage, style Threads/X) |
| — « 2023 » | 288→335 | | |
| 4. Envoyer | 366→390 | Ø 17 pt | **Triangle inversé arrondi, pointe vers le bas**, avec un pli intérieur du coin haut-gauche vers la pointe. **PAS** un `paperplane` (avion incliné vers le haut-droite) |
| — « 3 238 » | 405→455 | | |
| 5. Signet | 553→581 | Ø 20 pt | Marque-page, encoche en V, coins arrondis, marge droite 15 pt |

Écart entre deux groupes (fin du compteur → icône suivante) : **18–20 pt**.
Menu de la publication = **deux traits horizontaux, le supérieur long, l'inférieur court**, alignés à gauche (relevé `e003` x 553–590, y 330–350) — **ni `ellipsis` (•••) ni un hamburger à 3 traits égaux**.

### 2.5 Bloc texte sous une publication (`e003`)
- Ligne « Aimé par » : **pile de 1 à 3 mini-avatars ronds superposés** (Ø ~19 px = 13 pt) puis `Aimé par **enzofusiller** et d'autres personnes`, ~14 pt, y 199.
- Légende : `**equipedefrance** 4/4 🏆 …` + suffixe **« plus »** en gris cliquable, y 231.
- Date : « Il y a 6 heures », gris relevé `#5A5D64` (≈ `#6E7176` réel), ~12 pt, y 263.
- Interligne : 32 px = **21 pt**.
- Bouton « Suivre » (post sponsorisé) : rect. arrondi `#25282F`, 69 pt de large, texte blanc 14 pt semibold.

### 2.6 Visionneuse de story (`e105`–`e112`)
| Élément | Relevé |
|---|---|
| Barre de progression | **Segmentée en tirets** (un tiret par story, ici ~14), y ≈ 106, épaisseur ~2 px (1,3 pt), marge latérale 8 px, segments vus = blanc opaque / à venir = blanc 35 % |
| Média | **Pleine largeur** (x 0→603), du haut de l'écran jusqu'à **y = 1164**, **coins bas arrondis r ≈ 8 pt** ; bande noire en dessous |
| En-tête | avatar Ø 34 px (23 pt), icône « amis proches », **date en gras** (« 12 mai 2021 »), 2ᵉ ligne = barres ♪ + « Ice Cube · It Was A Good Day › » |
| Fermeture | **✕ fin (trait ~1,7 pt), Ø ~22 pt, x ≈ 573, y ≈ 144** — **pas de •••** sur ce variant |
| Barre de réponse | capsule outline « Envoyer un message… » (x 24→265) puis 5 icônes : **flip (rectangle entre parenthèses)**, cœur, bulle ronde, triangle send, menu 2 traits |

### 2.7 DM — liste (`e072`)
| Élément | Relevé |
|---|---|
| Titre | « joachim_frz ⌄ » **centré**, gras ~21 pt. **Pas de bouton de fermeture** (c'est un onglet) |
| Droite | icône **composer** (carré + crayon), Ø ~22 pt |
| Recherche | capsule pleine largeur, h ≈ 39 pt, fond **`#1F2229`**, placeholder **« Recherchez ou demandez à Meta AI »**, icône loupe + étincelle |
| **Notes** | rangée horizontale : bulle de note (fond gris/violet, coins arrondis, texte 11 pt) **au-dessus** d'un avatar Ø ~90 px (60 pt), pseudo dessous, sous-libellé avec épingle (« 📍 Preignan ») |
| Onglets | **« Messages »** (blanc gras ~20 pt, à gauche) / **« Demandes »** (gris, à droite) |
| Lignes | avatar Ø 76 px (**50 pt**), nom blanc semibold 15 pt, aperçu gris 15 pt avec **« · 5 s » collé à la fin de l'aperçu** |
| Accessoire droit | **pastille ronde `#4D6CFF`** Ø ~7 pt si non lu, **sinon rien** |

### 2.8 DM — conversation (`e073`, `e082`)
| Élément | Relevé |
|---|---|
| En-tête | ‹ dans un **bouton rond** `#181D20` Ø 40 pt · avatar Ø 34 pt (avec anneau si story) · « Matis Blondel **›** » gras 16 pt + pseudo gris 13 pt dessous · à droite **2 boutons ronds** : téléphone, caméra vidéo |
| Carte de tête | avatar Ø 95 pt · nom gras 21 pt · pseudo gris 16 pt · « 255 followers · 18 publications » · « Vous vous suivez mutuellement sur Instagram » · « Vous suivez tou(te)s les deux X et 7 autres comptes » · bouton **« Voir le profil »** (pilule `#25282F`, r 8 pt) |
| Séparateur | « 2 JUIN À 02:26 » **majuscules**, gris, centré, 11 pt |
| Bulle reçue | fond **`#21242B`**, r ≈ 20 pt, texte 15 pt ; **avatar Ø 29 pt à gauche uniquement sur le dernier message du groupe** |
| **Bulle envoyée** | **dégradé vertical à l'échelle de la conversation** — relevés du haut vers le bas : `#AD29D5` (y 195) → `#A128DB` (y 355) → `#7D2DF0` (y 635) → **`#6B30FE`** (y 715). Magenta en haut, violet pur en bas |
| Indice | « Appuyer longuement pour réagir », gris 12 pt, sous la bulle |
| Composer | **bouton caméra rond indigo `#5249FF`** Ø 36 pt **à gauche** · capsule `#181C1F` « Votre message… » · à droite dans la capsule : micro, image, sticker, ⊕ |

### 2.9 Profil tiers privé (`e148`)
| Élément | Relevé | Code |
|---|---|---|
| Barre | ‹ nu (pas de rond) · pseudo gras 19 pt · **•••** à droite | ✅ proche |
| Avatar | Ø 130 px = **87 pt**, à gauche | 82 pt ✅ |
| Nom affiché | « Charlotte ☀️ » **à droite de l'avatar, au-dessus des stats** | sous le bloc ❌ |
| Stats | **3 colonnes à droite de l'avatar**, chiffre gras 17 pt sur libellé 13 pt, **alignées à gauche** dans leur colonne | réparties par `Spacer()` ❌ |
| Lien | icône chaîne + `vsco.co/…` en **`#4D6CFF`** | absent ❌ |
| Bouton Suivre | **pleine largeur**, fond **`#3C51FC`**, r ≈ 10 pt, h ≈ 32 pt, texte blanc gras 15 pt | `#0095F6` ❌ |
| Onglets | **2 seulement** (grille 3×3 en points, identifications) + **soulignement court sous l'icône** (~63 pt) | 3 onglets, soulignement pleine colonne ❌ |
| Cadenas | **cercle Ø 128 px (85 pt), trait 1,5 px**, cadenas dedans | Ø 64 pt ❌ |
| Textes | « Ce profil est privé » gras **21 pt** ; « Suivez ce profil pour voir ses photos et vidéos. » gris 15 pt | 15 pt / 13 pt ❌ (trop petits) |

### 2.10 Détail publication (`e170`)
Barre : ‹ **dans un bouton rond** · titre « Publications » gras centré · **sous-titre = pseudo** en gris.
Pastille carrousel « 4/4 » en haut à droite de l'image (capsule noire 60 %).
Points de pagination **sous** l'image : gris `#393C43`, **actif = bleu `#4D6CFF`** (pas blanc).
Rangée d'icônes : cœur 25 · bulle 7 · send **sans compteur** · signet à droite. **Pas d'icône repost ici** (le repost n'apparaît que sur les publications du feed).

### 2.11 Feuille Commentaires (`e013`)
Fond **`#15191C`**, coins hauts r ≈ 18 pt, poignée grise centrée.
Titre « Commentaires » gras 17 pt centré · **bouton rond de partage** (triangle send) à droite.
Filtre « Pour vous ⌄ » gris à gauche.
Lignes : avatar Ø 30 pt · `pseudo` gras + **« 23 h » en gris collé** · texte 15 pt · **« Répondre »** gris · **cœur à droite** + compteur de likes dessous.
Bas : **rangée de 8 emojis rapides** ❤️ 🙌 🔥 👏 🥹 😍 😮 😂 puis avatar + capsule « Qu'en pensez-vous ? » + bouton **GIF**.

---

## 3. Verdict écran par écran

| Écran | Statut | Détail |
|---|---|---|
| **Coquille / barre d'onglets** | 🔴 **DÉVIE** | Voir §0. Barre pleine largeur au lieu de la capsule flottante ; ordre des onglets faux ; « + » mal placé ; DM en feuille au lieu d'onglet |
| **En-tête feed** | 🔴 **DÉVIE** | « Instagram » + chevron au lieu de « Pour vous ⌄ » centré ; avion + badge « 3 » **inexistants** dans la référence (les DM ne sont plus en en-tête) |
| **Rangée de stories** | 🔴 **DÉVIE** | Avatars 62 pt au lieu de 79 ; pas 86 pt au lieu de 104,5 ; dégradé décalé de 135° ; badge « + » bleu au lieu de noir ; **mauvais alignement** (§4.1) |
| **Publication (feed)** | 🔴 **DÉVIE** | Icônes fausses (§2.4) ; **repost absent** ; compteurs sous forme de texte séparé au lieu d'inline sur 3 des 4 ; `ellipsis` au lieu du menu 2 traits ; hauteur d'image figée à 380 pt alors que la référence montre du carrousel 1:1 et du 4:5 ; pile d'avatars « Aimé par » absente ; suffixe « plus » absent |
| **Carrousel de publication** | ⚫ **ABSENT** | Filmé (`e001`, `e170`), pastille « n/n », points de pagination bleus |
| **Publication sponsorisée** | ⚫ **ABSENT** | Filmé (`e003`) : « Sponsorisé », bouton « Suivre », bandeau CTA « S'inscrire › », « …détails » |
| **Commentaires** | ⚫ **ABSENT** | Filmé abondamment (`e013`–`e016`) — c'est l'écran le plus visité de l'enregistrement après le feed |
| **Partage** | ⚫ **ABSENT** | Filmé (`e019`–`e021`) |
| **Détail publication** | ⚫ **ABSENT** | Filmé (`e169`–`e175`) |
| **Story ouverte** | 🔴 **DÉVIE** + 🐞 **bloque** | Barre de progression **factice** (capsule blanche pleine, non segmentée, jamais animée) ; ✕ de 19 pt non atteignable ; pas d'auto-fermeture ; en-tête faux (« Il y a 4 h » + ••• au lieu de date + piste audio) ; barre de réponse à 3 icônes au lieu de 5 ; **couvre `BarreHome`** → piège le joueur (§4.2) |
| **Recherche** | 🟠 **DÉVIE** | Placeholder OK, mais mosaïque à cellules égales de 128 pt alors que la référence a des tuiles **2:3 doubles hauteur** intercalées ; état « Récent » sans clavier ; « Voir tout » présent ✅ |
| **Reels** | 🔴 **DÉVIE** | Le vrai a **« + | Pour vous ⌄ | Ami(e)s »** en haut, pas un titre « Reels » + caméra ; la colonne d'actions a **cœur/bulle/send/•••** mais aussi la vignette audio en bas ; un seul reel statique, pas de défilement vertical |
| **Profil Sarah** | 🟠 **DÉVIE** | Stats mal disposées (voir §2.9) ; **stories à la une absentes** (filmées `e121`–`e128`) ; onglets vides avec libellés jamais filmés ; « Modifier / Partager le profil » ✅ ; soulignement d'onglet pleine largeur au lieu de court |
| **Profil tiers / privé** | 🟠 **DÉVIE** | Voir §2.9 ; bleu faux ; nom mal placé ; lien absent ; 3 onglets au lieu de 2 |
| **DM liste** | 🔴 **DÉVIE** | Feuille + « OK » au lieu d'un onglet ; **Notes absentes** ; **onglets Messages/Demandes absents** ; recherche Meta AI absente ; **caméra à droite de chaque ligne = à retirer** ; libellés « Vu · 1 sem. » incompréhensibles (§4.3) |
| **DM conversation** | 🔴 **DÉVIE** | `FilGeneriqueVue` générique : en-tête `navigationTitle` + « OK », bulles `#262626`/`#0095F6` à r 18, composer minimal. La référence a l'en-tête à boutons ronds, la carte profil, les bulles **dégradées magenta→violet**, le composer indigo (§2.8) |
| **DM réglages** | ⚫ **ABSENT** | Filmé (`e097`) |
| **Notifications** | ⚠️ **PRÉSENT, JAMAIS FILMÉ** | `InstaActiviteVue` est une invention. Rien dans les 239 frames. De plus **aucune ligne n'est cliquable** → viole D82 |
| **Ajouter à votre story** | ⚠️ **PRÉSENT, JAMAIS FILMÉ** | `InstaAjoutStoryVue` : écran maison à 3 boutons, aucun équivalent réel |
| **Nouveau post** | ⚠️ **PRÉSENT, JAMAIS FILMÉ** | `InstaCreationPostVue` : `NavigationStack` iOS générique, jamais vu |
| **Caméra DM** | ⚠️ **PRÉSENT, JAMAIS FILMÉ** | `InstaCameraSheetVue` : cercle blanc + « Appuyez pour prendre une photo », inventé |
| **États vides profil** | ⚠️ **PRÉSENT, JAMAIS FILMÉ** | « Aucun reel » / « Photos et vidéos de vous » — le vrai dit **« Partagez un moment avec le monde entier »** + bouton **« Créer votre premier reel »** (`e178`) |

---

## 4. Les points de Joachim : cause exacte dans le code

### 4.1 « Stories mal centrées »
```
VStack(spacing: 4) { InstaAvatar(sarah, taille: 62); Text("Votre story") }   // ← PAS de .frame(width:)
...
ForEach(comptes) { VStack { InstaAvatar(c, taille: 62, anneau: true); Text(c.id) }.frame(width: 72) }
```
Trois causes cumulées :
1. **La cellule « Votre story » n'a pas de `.frame(width: 72)`** : sa largeur = celle du texte « Votre story » (~62 pt) alors que les suivantes font 72 pt → **la première colonne est décalée** par rapport aux autres.
2. `InstaAvatar(anneau: true)` applique `.padding(3)` → l'avatar cerclé fait **68 pt** de large dans un cadre de **72 pt**, tandis que « Votre story » (sans anneau) fait **62 pt** : deux gabarits différents dans le même `HStack(spacing: 14)` → **l'avatar et son libellé ne partagent pas le même axe** d'une cellule à l'autre.
3. Le libellé `Text(c.id).lineLimit(1)` peut être plus large que 72 pt et se faire tronquer/étirer, ce qui déplace visuellement le centre.

**Correction** : une cellule unique de **largeur fixe 104,5 pt**, avatar **79 pt** + anneau **3,3 pt** + écart **3,3 pt** (Ø extérieur 93 pt), libellé centré à **9 pt** sous l'avatar, `HStack(spacing: 0)` et padding horizontal 13 pt. Le badge « + » de « Votre story » : cercle **noir** Ø 20 pt bordé de blanc 2 pt, glyphe « + » blanc — pas un rond bleu.

### 4.2 « Story ouverte, impossible de revenir en arrière (bloqué) »
Quatre causes, la 4ᵉ est la vraie :
1. `InstaStoryVue` n'a **aucun minuteur** : contrairement à `VisualiseurContenuVue` (qui s'auto-ferme via `progression`), la story du feed affiche une `Capsule().fill(.white.opacity(0.9))` **statique et pleine** — la story ne se termine jamais toute seule.
2. La seule sortie est `Image(systemName:"xmark").onTapGesture { dismiss() }` : la cible tactile est **le glyphe de 19 pt** (`contentShape` posé sur l'`Image`, pas sur un cadre de 44 pt) — sous le minimum d'accessibilité, et **collée à l'`ellipsis`** juste à sa gauche sans espacement.
3. Aucun geste de secours : ni `.gesture(DragGesture)` de fermeture vers le bas, ni tap sur le fond.
4. **`.fullScreenCover` recouvre `BarreHome`**, qui est le seul moyen de quitter l'app dans le jeu (`InstagramVue` la place dans le `ZStack` racine, sous le cover). Si le joueur rate le ✕, **il est enfermé dans Instagram**, sans même pouvoir revenir à l'écran d'accueil du téléphone. C'est ça, « bloqué ».

**Correction** : barre de progression **segmentée réelle** avec minuteur (≈ 5 s/segment) et auto-fermeture ; ✕ dans un cadre de 44×44 pt ; `DragGesture` vers le bas ; tap sur le tiers gauche/droit pour segment précédent/suivant ; et **maintenir `BarreHome` accessible** (présentation en overlay dans le `ZStack` de `InstagramVue` plutôt qu'en `fullScreenCover`).

### 4.3 « Logique Vu / Pas encore de réponse incompréhensible »
```swift
Text(c.id == "chloe.brt" ? "A envoyé une publication · 2 j" : "Vu · 1 sem.")   // liste
...
messages: (filOuvert?.id == "chloe.brt") ? [ … ] : [(false, "Vu · pas encore de réponse")]   // fil
```
Deux fautes :
- **4 conversations sur 5 affichent exactement le même aperçu « Vu · 1 sem. »** — un état, pas un message.
- Surtout : en ouvrant l'une d'elles, la chaîne **« Vu · pas encore de réponse » est rendue comme une bulle grise émise par le contact**. Le joueur lit littéralement un message dont le texte est un statut. C'est le « pas naturel ».

**Correction** : chaque fil a son propre contenu Sarah. L'aperçu suit la grammaire relevée : `"<dernier message> · <durée>"`, ou `"Vous : <message> · <durée>"`, ou `"+ de 4 nouveaux messages · <durée>"`, ou `"En ligne il y a 18 minutes"`. Le statut « Vu » ne s'affiche **que sous la dernière bulle envoyée**, jamais dans une bulle, jamais comme aperçu générique.

### 4.4 « Petite flèche à côté du mot Instagram : RETIRER »
Le chevron n'est pas superflu — **le titre l'est**. La référence n'affiche jamais le mot « Instagram » : le titre est **« Pour vous ⌄ »**, centré, et le chevron ouvre le sélecteur de flux. Donc : remplacer `Text("Instagram") + chevron.down` aligné à gauche par **« Pour vous ⌄ » centré**, et — D82 — soit le chevron ouvre réellement un menu (Pour vous / Suivi(e)s / Favoris), soit on retire le chevron. **Filmer ce menu avant de le coder.**
Dans la foulée : `paperplane` + badge « 3 » de l'en-tête doivent **disparaître** (les DM sont dans la barre d'onglets), et le cœur reste seul à droite avec sa pastille rouge.

### 4.5 « Icônes sous les publications pas fidèles »
Correspondance code → référence :
| Code | Référence | Verdict |
|---|---|---|
| `heart` | cœur plus large, creux marqué | à redessiner (Path maison) |
| `bubble.right` (bulle rectangulaire) | **cercle + queue** | ❌ faux, à redessiner |
| — | **repost (2 flèches en boucle)** | ❌ **manquant** |
| `paperplane` (avion incliné haut-droite) | **triangle inversé pointe en bas** | ❌ faux, à redessiner |
| `bookmark` | proche mais plus large | retouche |
| `ellipsis` (•••) | **2 traits horizontaux inégaux** | ❌ faux |
De plus : le compteur est **inline à droite de chaque icône** (cœur, bulle, repost, send) — le code n'en met que sur le cœur et la bulle, et pas de compteur sur send.

### 4.6 « Bouton photo/caméra à droite d'une conversation : RETIRER »
`InstaDMVue` place `Image(systemName:"camera")` en fin de chaque ligne, ouvrant `InstaCameraSheetVue` (écran inventé). Dans `e072`, **l'accessoire droit d'une ligne est une pastille bleue `#4D6CFF` de non-lu, ou rien**. → **Retirer (C)**, et supprimer `InstaCameraSheetVue`. Le seul bouton caméra réel est **le rond indigo `#5249FF` à gauche du composer, à l'intérieur d'une conversation** (`e073`, `e082`).

### 4.7 « Une notif concernant un profil doit ouvrir ce profil »
`InstaActiviteVue` : les lignes n'ont **ni `contentShape` ni `onTapGesture`** → boutons morts, violation D82. Mais **l'écran n'a jamais été filmé** : avant de le rendre cliquable, il faut la référence (§5).

---

## 5. Écrans / états à filmer par Joachim

Priorité décroissante — le code prétend les connaître sans référence :

| # | À filmer | Pourquoi |
|---|---|---|
| 1 | **Onglet cœur (Notifications)** : liste complète, en-tête, sections temporelles, boutons « Suivre » en ligne, et **le tap d'une notification vers le profil** | Écran entier codé sans une seule frame |
| 2 | **Une story LIVE d'un tiers ouverte depuis la rangée du feed** : barre segmentée qui s'anime, « il y a 4 h », menu •••, réactions rapides, passage au segment suivant, **et la fermeture (✕ + glissé vers le bas)** | Seules des **archives / à la une** ont été filmées (`e105`–`e128`) — le chrome n'est pas le même |
| 3 | **Tap sur « Votre story »** (caméra Instagram) et **tap sur le « + » en haut à gauche** (menu de création) | Deux entrées du feed, actuellement inventées |
| 4 | **Menu « ⌄ » de « Pour vous »** (Pour vous / Suivi(e)s / Favoris ?) | Détermine si le chevron reste ou part |
| 5 | **Menu « ≡ » d'une publication** (feuille d'options) | Actuellement `ellipsis` mort |
| 6 | **Profil perso complet** : onglets Reels et Identifications (remplis **et** vides), stories à la une, tap sur « Modifier » et « Partager le profil » | Libellés d'états vides inventés |
| 7 | **Explore / mosaïque au repos** en défilement lent | Confirmer le rythme des tuiles doubles hauteur |
| 8 | **Double-tap « j'aime »** sur une publication (animation) et **like d'un commentaire** | Retours d'interaction |
| 9 | **Feuille de partage complète** : défilement de la liste de destinataires, tap sur une destination | Écran filmé mais court |
| 10 | **Onglet « Demandes »** des DM et **réactions emoji** sur une bulle (appui long) | Vus en passant seulement |

---

## 6. Plan de refonte priorisé

Contenu Sarah conservé intégralement (`DonneesInsta`) — c'est la **coquille** qui change.

### Lot 0 — Fondations (à faire avant tout, ~½ journée)
| Action | Détail |
|---|---|
| **Créer `InstaIcones.swift`** | 8 `Shape`/`Path` maison : `CoeurInsta`, `BulleRondeInsta`, `RepostInsta`, `EnvoyerInsta` (triangle inversé), `SignetInsta`, `MenuDeuxTraits`, `FlipStory`, `ComposerInsta`. **Aucun SF Symbol** sur ces 8 rôles |
| **Créer `InstaTheme.swift`** | `fond #000000` · `accent #3C51FC` · `lien/pastille #4D6CFF` · `surface1 #15191C` · `surface2 #1F2229` · `bulleRecue #21242B` · `bulleEnvoyeeHaut #C13AD6` · `bulleEnvoyeeBas #6B30FE` · `camera #5249FF` · `secondaire #6E7176` |
| **`AnneauStory`** | `AngularGradient` **avec `angle: .degrees(135)`** et arrêts relevés §2.3 : `#D8BA00` (0,00) → `#F19A0C` (0,12) → `#F6122B` (0,25) → `#E71197` (0,37) → `#C916CA` (0,50) → `#DD0AAF` (0,62) → `#CE1384` (0,75) → `#E4162D` (0,87) → `#D8BA00` (1,00). Trait 3,3 pt, écart 3,3 pt |
| **Purger** | `#0095F6` (36 occurrences) → `#3C51FC` / `#4D6CFF` selon le rôle |

### Lot 1 — 🔴 RÉÉCRIRE (le chrome est faux, retoucher ne sert à rien)
| Cible | Action |
|---|---|
| `InstagramVue` | Barre d'onglets **capsule flottante** 370×52 pt, r = 26 pt, `.ultraThinMaterial` assombri, 16 pt de marge, 26 pt du bas. Ordre : **maison · reels · DM (send + pastille rouge) · loupe · avatar**. Onglet actif = pastille 78×41 pt r 20 pt `#2E3236`. **Les DM deviennent un onglet**, plus une feuille. `BarreHome` **au-dessus** de tout |
| En-tête feed | « + » (20 pt) à gauche · **« Pour vous ⌄ » centré 24 pt gras** · cœur 21 pt + pastille rouge à droite. **Supprimer** l'avion + badge « 3 » |
| Rangée de stories | Cellule fixe **104,5 pt**, avatar **79 pt**, anneau ext. 93 pt, libellé 12 pt à 9 pt sous l'avatar, marge 13 pt, badge « + » **noir bordé de blanc** |
| `InstaPostVue` | Rangée d'icônes à **5 slots** dont **repost**, compteurs **inline**, marges 13/15 pt, écarts 18–20 pt · menu 2 traits · pile de mini-avatars « Aimé par » · suffixe « plus » · date 12 pt `#6E7176` · support carrousel (pastille « n/n » + points, actif `#4D6CFF`) |
| `InstaStoryVue` | **Réécriture complète** : barre **segmentée** + minuteur 5 s/segment + auto-fermeture · média pleine largeur, coins bas r 8 pt, bande noire de 98 pt en bas · en-tête avatar 23 pt + date/pseudo gras + ligne audio · **✕ dans une cible de 44 pt** · glissé vers le bas · taps latéraux · barre à **5 icônes** · **présentation en overlay pour ne pas masquer `BarreHome`** |
| `InstaDMVue` | Écran d'onglet (pas de feuille, pas de « OK ») : titre « sarah.lvsr ⌄ » centré + compose · recherche `#1F2229` « Recherchez ou demandez à Meta AI » · **rangée Notes** · **onglets Messages / Demandes** · lignes avatar 50 pt + aperçu « texte · durée » + **pastille `#4D6CFF`**. **Supprimer la caméra de ligne et `InstaCameraSheetVue`** |
| Conversation | **Nouveau `InstaFilVue`** dédié (ne plus utiliser `FilGeneriqueVue`) : en-tête à boutons ronds + appel/vidéo · carte profil + « Voir le profil » · séparateur date majuscules · bulles reçues `#21242B` r 20 pt avec avatar 29 pt sur le dernier du groupe · **bulles envoyées en dégradé vertical `#C13AD6`→`#6B30FE` calculé sur la hauteur totale du fil** · « Appuyer longuement pour réagir » · composer caméra indigo + micro/photo/sticker/⊕ |

### Lot 2 — ⚫ AJOUTER (écrans filmés, absents du code)
1. **`InstaCommentairesVue`** (feuille, `#15191C`, r 18 pt) — le plus visité après le feed.
2. **`InstaPartageVue`** (feuille : recherche, grille de destinataires, rangée d'actions Ajouter à la story / Copier le lien / WhatsApp / Snapchat / Partager dans…).
3. **`InstaDetailPostVue`** (« Publications » + sous-titre pseudo, carrousel, points bleus).
4. **Stories à la une** sur le profil (rangée d'avatars 60 pt + libellés) et leur visionneuse (variante archive : date en gras, pas de •••).
5. **`InstaReglagesFilVue`** (Personnaliser · Pseudos · Messages éphémères · Confidentialité et sécurité · Créer une discussion de groupe · Quelque chose ne fonctionne pas).
6. En-tête Reels **« + | Pour vous ⌄ | Ami(e)s »**.

### Lot 3 — 🟠 RETOUCHER
- `InstaProfilVue` / `InstaProfilTiersVue` : nom **à droite de l'avatar**, stats en 3 colonnes alignées à gauche, avatar 87 pt, bouton pleine largeur `#3C51FC`, soulignement d'onglet **court** (63 pt), cadenas Ø 85 pt, « Ce profil est privé » **21 pt**, ligne de lien `#4D6CFF`.
- `InstaRechercheVue` : mosaïque à tuiles inégales (cellules 2:3 doubles hauteur intercalées) au lieu de cellules égales de 128 pt.
- Reels : défilement vertical réel entre 2–3 reels Sarah plutôt qu'une image figée.

### Lot 4 — 🚮 SUPPRIMER (D82-C : jamais filmé, promesse non tenable)
- `InstaAjoutStoryVue` → remplacer par le comportement réel une fois filmé ; en attendant, **retirer le tap sur « Votre story »**.
- `InstaCreationPostVue` → le « + » du feed reste inerte tant que le menu n'est pas filmé, ou affiche un message iOS crédible (D82-B, à utiliser avec parcimonie).
- `InstaCameraSheetVue` → supprimer.
- Libellés d'états vides inventés (« Aucun reel », « Photos et vidéos de vous ») → **« Partagez un moment avec le monde entier »** + bouton **« Créer votre premier reel »** (`e178`).
- `InstaActiviteVue` → **geler** jusqu'au tournage (§5-1) ; en attendant, rendre au minimum chaque ligne cliquable vers `InstaProfilTiersVue` pour lever la violation D82 signalée par Joachim.

### Ordre d'exécution recommandé
**Lot 0 → Lot 1 (barre d'onglets + en-tête + stories) → Lot 1 (post + story ouverte) → Lot 1 (DM) → Lot 2 (commentaires, partage, détail post) → Lot 3 → Lot 4.**
Le Lot 0 + les trois premiers postes du Lot 1 corrigent à eux seuls 5 des 6 points de Joachim et l'impression de « manque de fidélité générale ».
