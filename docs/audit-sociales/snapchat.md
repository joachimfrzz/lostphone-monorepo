# Audit Snapchat — Lost Phone

**Date** : 03/09/2026
**Référence** (D67) : `/agent/workspace/refs/c2/snapchat/` — 114 frames JPEG 603×1311 px (mi‑résolution iPhone 16, **1 pt = 1,5 px**).
**Code audité** : `proto-swift/Sources/SnapchatApp.swift` (33 538 o, branche `main`, SHA `f61e806`) + `InteractionsPartagees.swift` (composant `VisualiseurContenuVue`).
**Aucun fichier Swift n'a été modifié.**

> Convention : toutes les mesures sont données `px (pt)`. Les hex sont relevés au pixel avec PIL sur les frames citées.

---

## 0. Verdict en une phrase

L'app reproduit **5 écrans sur ~9 filmés**, et sur ces 5 elle reproduit une *idée* de l'écran plutôt que l'écran : le **Profil** (le plus riche, 3 frames) est totalement absent, le **Spotlight** est une image figée alors que 45 frames montrent un fil vertical, la **Caméra** n'a aucun des trois étages d'UI filmés, et **28 boutons sur 41 sont morts**. C'est bien le défaut global que Joachim reproche : l'app *ressemble* à Snapchat en vignette, mais s'effondre dès qu'on la touche.

---

## 1. Inventaire des écrans filmés

### 1.1 Répartition des 114 frames

| Frames | Écran / état | Planche |
|---|---|---|
| e001–e002 | **Caméra** — viseur réel, colonne d'outils droite, anneau de capture, carrousel de Lenses, onglets de Lenses | `snapchat_1` r1 |
| e003–e009 | **Chat (liste)** — e003 = haut de liste avec la rangée de filtres ; e004‑e009 = défilement | `snapchat_1` r1‑r2 |
| e010–e017 | **Conversation** « Sacha Fourez » — e010‑e011 état vide (« VOUS AVEZ ENREGISTRÉ L'ÉCRAN DU CHAT ! »), e012‑e016 fil + photos + stickers, e014/e017 avec clavier iOS | `snapchat_1` r2‑r3 |
| e018–e022 | **Chat (liste)** — retours et défilements, e022 haut de liste | `snapchat_1` r3 |
| e023–e032 | **Snap Map** — Fleurance / Dép. du Gers / Auch / Roquelaure ; chips, colonne droite, pilule « % exploré(s) », rangée d'amis | `snapchat_1` r3‑r4 |
| e033–e034 | **Snap Map → Bitmoji 3D plein écran** + feuille « Moi et mes amis·es » + boutons « Chat à plusieurs » / « Carte Snap » | `snapchat_1` r5 |
| e035–e042 | **Snap Map** — dézoom progressif, heatmap, Toulouse → Haute‑Garonne → France → Europe | `snapchat_1` r5‑r6 |
| e043–e048 | **Snap Map — GLOBE** « Terre », « 0,0003 % exploré(s) » | `snapchat_1` r6 |
| e049–e051 | **Snap Map** — Nouvelle‑Calédonie | `snapchat_2` r1 |
| e052–e054 | **Stories** — bandeau « Amis·es › » + grille « Découvrir › » | `snapchat_2` r1 |
| e055–e062 | **Visionneuse Découvrir** (éditeur « Closer ») — « + Ajouter », rail droit, barre « Voir le profil » | `snapchat_2` r1‑r2 |
| e063–e064 | **Stories** — tuiles sponsorisées avec bouton « Installer » | `snapchat_2` r2 |
| e065–e107 | **Spotlight** — fil vertical, ~43 frames de défilement continu | `snapchat_2` r3‑r6 / `snapchat_3` r1‑r2 |
| e108–e109 | **Stories** — retour | `snapchat_3` r2 |
| e110–e111 | **Caméra** — viseur réel, carrousel de Lenses | `snapchat_3` r2 |
| e112–e114 | **Profil** — héros vert, Bitmoji 3D, « Mon compte / Profil public », chips, Snapchat+, « Publier sur… », « Amis·es ». e113 = modale « Utiliser la photo de profil de vos contacts » | `snapchat_3` r2‑r3 |

**Poids relatif du tournage** : Spotlight 45 frames (39 %), Snap Map 30 (26 %), Chat liste 12, Conversation 8, Stories 7, Visionneuse Découvrir 8, Caméra 4, Profil 3.
→ Le code consacre ~40 lignes au Spotlight (39 % du tournage) et **0 ligne au Profil**.

### 1.2 Écrans JAMAIS filmés mais présents dans le code

- Recherche de lieu sur la carte (`SnapRechercheCarteVue`)
- Feuille « Envoyer à… » (`SnapEnvoiSnapVue`)
- Visionneuse de story d'ami (aucune story d'ami n'est ouverte dans la vidéo — seule la visionneuse **Découvrir** l'est)

---

## 2. Mesures et couleurs de référence

### 2.1 Barre d'onglets (constante, tous écrans)

| Élément | Mesure | Source |
|---|---|---|
| Filet séparateur | y = 1159 px | e003 |
| Hauteur totale (filet → bas) | 152 px (**101 pt**), indicateur home inclus | e003 |
| Centre vertical des icônes | y = 1222 px, soit **41 pt** au‑dessus du filet | e003 |
| Centres horizontaux | x = 79 / 190 / 301 / 412 / 523 px → **53 / 127 / 201 / 275 / 349 pt** ; pas = 111 px (**74 pt**) | e003 |
| Taille glyphe | ≈ 34 px (**23 pt**) | e003 |
| Fond thème clair | `#FFFFFF` pur | e003, e026, e053 |
| Fond thème sombre | **`#1B1B1B`** (pas noir pur) | e075 |
| Couleur onglet actif (clair) | **`#252733`** (pas `#000000`) | e005 |

**Ordre et formes des 5 onglets** (identiques partout) :
1. **Carte** — épingle *contour* ; active = épingle *pleine* (e026)
2. **Chat** — bulle carrée arrondie *contour* ; active = *pleine* (e005)
3. **Caméra** — appareil photo *contour* ; **sur l'onglet Caméra, le glyphe est remplacé par la vignette de la Lens active + un chevron ▲** (e001)
4. **Stories** — deux personnages *contour* ; actif = *plein* (e053)
5. **Spotlight** — triangle play dans une bulle *contour* ; actif = triangle *plein* (e075)

**Badges** : rouge `#FF1B3F` (relevé `#FF0D3A` / `#FE0336`).
- Onglet 4 : badge rose‑fuchsia « TOP » + pastille rouge « 3 » (e005) — **présent sur Chat/Caméra, absent sur Carte et Stories**.
- Onglet 5 : pastille rouge « 3 » — **présente partout sauf quand Spotlight est actif** (e075).

### 2.2 En‑tête (Chat / Stories / Caméra / Spotlight)

Ordre gauche → droite, **strictement identique sur les 4 écrans** :
`[Bitmoji + pastille rouge] [loupe] ······ TITRE ······ [cloche] [ajout d'ami + badge 47] [•••]`

| Élément | Mesure / couleur | Note |
|---|---|---|
| Cercles gris | ⌀ 52 px (**35 pt**), fond **`#E7EAF1`** | e003 |
| Bouton « ajout d'ami » | ⌀ 60 px (**40 pt**) | e003 |
| — sur **Chat** | fond **jaune `#FFFC00`**, glyphe noir | e003 |
| — sur **Stories** | fond **gris `#E7EAF1`** | e053 |
| — sur **Caméra / Spotlight** | **sans fond**, glyphe blanc | e001, e075 |
| Badge « 47 » | `#FF1B3F`, texte blanc | e003 |
| Titre | ≈ 20 pt gras noir (clair) / blanc (sombre) ; « Chat » large 59 px | e003, e075 |
| Bitmoji d'en‑tête | ⌀ ~52 px (**35 pt**) + **pastille rouge** en haut à droite | e003 |
| **Spotlight uniquement** | la cloche et le « ••• » sont remplacés par **un « + » dans un carré arrondi** (créer) | e075 |

### 2.3 Chat — liste

| Élément | Mesure | Couleur |
|---|---|---|
| Rangée de filtres, y ≈ 200 px | **texte nu, AUCUNE pilule de fond** ; écarts 34–39 px (**23–26 pt**) | noir |
| Libellés exacts | `My AI` (précédé d'un avatar ⌀ 32 px) · `Groupes` · `Près de moi` · `Meilleurs·es amis·es` | |
| Pas des lignes | 90 px (**60 pt**) | |
| Avatar de ligne | ⌀ 68 px (**45 pt**), marge gauche 16 px (11 pt) | Bitmoji avec **décor de fond** |
| Colonne texte | x = 98 px (**65 pt**) | nom ≈ 16 pt medium |
| Statut | ≈ 12,5 pt | gris **`#7B7F86`** |
| Accessoire droit | icône **appareil photo contour NOIR, sans cercle de fond** ; sur certaines lignes un **« × »** à la place | `#000000` |
| **FAB « nouveau Chat »** | ⌀ 89×90 px (**60 pt**), jaune `#FFFC00`, glyphe crayon‑dans‑bulle noir ; marge droite 24 px (**16 pt**), 23 px (**15 pt**) au‑dessus du filet | e003, e005 |

**Vocabulaire et pictogrammes de statut relevés** (e003, e005) :

| Libellé | Pictogramme | Couleur |
|---|---|---|
| `Reçu · 104sem` | bulle carrée **contour** | bleu `#1CA0F0` |
| `Reçu de Sarah · 160sem` | bulle carrée contour | bleu |
| `Ouvert · 167sem` | triangle/avion **contour** | bleu |
| `Remis · 21sem` | triangle/avion **plein** | bleu |
| `Appuyer pour Chatter` | bulle carrée contour | **gris** |
| `Appuyez 2x pour répondre` (Team Snapchat) | **carré contour** | **violet ≈ `#9B4DFF`** |
| `A réagi à un Chat. · 13sem` | triangle contour | bleu |
| `Bastien a réagi à un Chat. · 6sem` | bulle contour | bleu |
| `Bressols, Département de Tarn-et-Garonne…` | épingle contour | gris |
| `À proximité · maintenant` | épingle contour | gris |
| `Jouer à un jeu de culture générale ?` (My AI) | *aucun* | — |

### 2.4 Conversation (e014)

| Élément | Mesure / couleur |
|---|---|
| En‑tête | `‹` fin, avatar ⌀ 44 px (29 pt), **nom gras + sous‑titre gris « À proximité · 1min »**, puis **téléphone PLEIN noir** et **caméra vidéo PLEINE noire** ; filet inférieur |
| Nom d'émetteur | ≈ 11 pt gras, **coloré** : « Moi » **`#E63455`** (relevé `#D6345B`/`#DE2F56`), « Sacha » **`#1CA0F0`** (relevé `#259FF2`) |
| Horodatage | aligné à droite sur la ligne du nom, gris **`#898989`** |
| Corps du message | **bandeau gris pleine largeur `#E7EBEE`** + **barre verticale colorée** ≈ 4 px (2,5 pt) à gauche |
| Séparateur de date | `17 AOÛT` centré, ≈ 11 pt gras, gris, majuscules |
| Composeur | **cercle NOIR plein ⌀ 54 px (36 pt)** + appareil photo blanc · champ capsule contour gris, placeholder « Envoyer un Chat », **curseur rouge**, **icône forme d'onde À L'INTÉRIEUR du champ à droite** · puis **3 glyphes hors champ : smiley, autocollant/découpe, manette de jeu** |
| Pas de barre d'onglets | ✔ |

### 2.5 Snap Map (e026, e033)

| Élément | Mesure / couleur |
|---|---|
| Fond de carte | **style Snapchat propriétaire** : vert `#D7EDC9` → `#E7F6E3`, routes blanches, pas de POI Apple |
| Chips (haut) | **capsules blanches avec ICÔNE + libellé** : `Souvenirs` (pile photo) · `Tendance` (flèche ↗) · `Footsteps` (empreintes) · `Visité` (horloge) — défilement horizontal, alignées à gauche |
| Pilule de lieu | en haut à **droite** (pas centrée) : `Roquelaure` gras + **météo `☀ 33 °C`** en dessous |
| **Colonne droite** | 4 boutons ronds blancs ⌀ 56 px (**37 pt**), x 527–599, y 762–1049 (192 pt) : **[Bitmoji + pastille rouge] [engrenage] [calques] [recentrer]** |
| Pilule « exploré » | bas‑gauche, **lavande translucide** (≈ `#B9A9D6` @ ~60 %), texte blanc, icône empreintes : `10,3 % exploré(s)` |
| Rangée d'amis | **pleine largeur, x 12→602**, ⌀ 64 px (**43 pt**), bord bas à 21 px du filet ; **premier élément = bouton rond blanc « recherche d'ami »** |
| Épingles | **Bitmoji corps entier posés sur la carte** (pas de cercle), capsule blanche du nom en dessous : `Sacha et moi`, `Bastien il y a 1h` |
| POI | libellés colorés + pastille : orange `#ED5019` (`Broc et Troc`, `Royal de Pavie / Le plus sélectionné`), violet `#8A48CC` (`Câline / Habitué·e des lieux`) |
| Vue 3D (e033) | plein écran, `×` blanc en haut‑gauche, pilule bleue `3D`, capsule `😊 Sacha 🔋 📍il y a 1min`, boutons flottants `Chat à plusieurs` / `Carte Snap`, feuille blanche **« Moi et mes amis·es »** : ligne `Moi` + pilule grise `Mettre à jour Bitmoji`, ligne `Sacha Fourez / Ici il y a 1min` + bouton **jaune** de chat |
| Dézoom | continu jusqu'au **globe « Terre »** avec heatmap (e043‑e048) |

### 2.6 Stories (e053)

- En‑tête standard, titre `Stories`, bouton d'ajout d'ami **gris**.
- Section **`Amis·es ›`** (chevron) : anneaux ⌀ ~62 px, contour dégradé violet/rose, **badge rouge « +N » en bas à gauche**, pseudo en dessous (`anais_clems`, `oce-chass`, `n1.queen2`, `florian32800`).
- Section **`Découvrir ›`** (chevron), en **deux registres** :
  1. **rangée horizontale** de tuiles étroites ≈ 178×290 px (119×193 pt), titre en bas ;
  2. **grille 2 colonnes** de grandes tuiles ≈ 292×480 px (195×320 pt), coins ~12 pt, **icône « OO » (abonnement) en haut à droite**, dégradé bas ; les sponsorisées portent `Sponsorisé` + **bouton blanc `Installer`**.
- Le code ne connaît que le second registre.

### 2.7 Visionneuse Découvrir (e057)

Fond **noir**, carte vidéo insérée avec coins arrondis (haut à y ≈ 88 px), filet de progression tout en haut.
- Haut‑gauche : logo éditeur rond + `Closer ★` + `sam.`
- Haut‑droite : **pilule jaune `+ Ajouter`** (⌀ ~50 px de haut, 33 pt)
- Rail droit, aligné en bas : **cœur plein** (sans compteur) · **bulle avec pastille rouge + « 3 »** · **flèche de partage + « 49 »**
- Barre du bas : `[rond lens]` `[capsule contour large « Voir le profil »]` `[rond contour « ••• »]`
- **Ni croix de fermeture, ni champ de saisie.**

### 2.8 Spotlight (e075)

- Vidéo plein écran, sous‑titres incrustés, **fil vertical** (43 frames de défilement).
- Vignette éditeur ronde en haut‑gauche sous l'en‑tête.
- Rail droit, de haut en bas : **ampoule jaune `#FFFC00` dans un rond blanc + badge « + »** (Lens) · **cœur `741`** · **bulle + pastille rouge `108`** · **boucle `49`** · **flèche `143`**
- Bas : bandeau **noir `#010008`** hors vidéo contenant `•••`, pseudo `GG` gras, `♪ Son original · dribble97tk`, et à droite une **vignette musicale carrée verte/teal**.
- Barre de progression fine sous la vidéo.
- Barre d'onglets `#1B1B1B`.

### 2.9 Caméra (e001, e110)

Trois étages superposés au viseur réel :
1. **En‑tête** : Bitmoji + loupe (glyphes blancs, sans fond) à gauche ; cloche + ajout d'ami « 47 » au centre‑droit.
2. **Colonne droite verticale, glyphes blancs LIBRES (pas de capsule)** : retournement, **flash barré**, **note de musique**, **carré‑dans‑cercle (mode)**, **lune**, puis **chevron ▼ dans un rond sombre**. → **6 éléments.**
3. **Rangée de capture** : `[Ai ✨ / « AI »]` `[Souvenirs + pastille rouge]` — libellés texte sous le glyphe, **pas de cercles** — puis **anneau blanc ⌀ 128 px (85 pt)**, puis **carrousel horizontal de vignettes de Lenses rondes ⌀ ~54 px**.
4. **Rangée d'onglets de Lenses** : `[manette]` `…ents` `Favoris` **`Pour vous`** (pilule sombre = actif) `Rentrée` `Es…` `[smiley d'ajout]`.
5. Au centre du viseur : petit glyphe **⤢** (plein écran).

---

## 3. Écran par écran : FIDÈLE / DÉVIE / ABSENT / JAMAIS FILMÉ

### 3.1 Coquille et navigation (`SnapchatVue`)

| Point | Verdict | Détail |
|---|---|---|
| 5 onglets, bon ordre | **FIDÈLE** | Carte, Chat, Caméra, Stories, Spotlight ✔ |
| Thème par onglet | **FIDÈLE** | clair sur 0/1/3, sombre sur 2/4 ✔ (conforme à la vidéo) |
| Formes des glyphes | **DÉVIE** | code = `.fill` systématique (`location.fill`, `bubble.left.fill`, `camera.fill`, `person.2.fill`, `play.rectangle.fill`). Réel = **contour** pour l'inactif, **plein** pour l'actif seulement. |
| Onglet Caméra | **DÉVIE** | doit afficher la **vignette de Lens + chevron ▲**, pas un glyphe d'appareil photo. |
| Couleur actif | **DÉVIE** | code `.black` / `.white` → réel `#252733` (clair). |
| Fond sombre | **DÉVIE** | code `Color.black` → réel `#1B1B1B`. |
| Badges | **DÉVIE** | code : un seul badge « 3 » sur l'onglet 5. Réel : **badge « TOP » rose + « 3 » sur l'onglet 4** *et* « 3 » sur l'onglet 5, avec disparition du badge sur l'onglet actif. Couleur `#FF3B30` → `#FF1B3F`. |
| Géométrie | **DÉVIE** | code `padding(.top,10)/.bottom,26` ; réel = 101 pt de haut, glyphes à 41 pt du filet, pas de 74 pt. Aucun filet séparateur dans le code. |

### 3.2 Chat — liste (`SnapChatListeVue`)

| Point | Verdict | Détail |
|---|---|---|
| Composition d'en‑tête | **FIDÈLE** | ordre avatar/loupe/titre/cloche/jaune+47/••• ✔ — la meilleure partie de l'app. |
| Bouton jaune | **DÉVIE** | code = texte `"C+"` ; réel = glyphe **silhouette + « + »**. ⌀ 34 pt → **40 pt**. Cercles gris 34 pt → **35 pt**, `#F0F0F0` → **`#E7EAF1`**. |
| Pastille rouge sur le Bitmoji d'en‑tête | **ABSENT** | présente sur **toutes** les frames. |
| Filtres | **DÉVIE (grave)** | code = **capsules grises/noires** ; réel = **texte nu sans fond**, écart 24 pt, et `My AI` porte un **avatar**. |
| Pas des lignes | **DÉVIE** | code ≈ 64 pt effectifs (avatar 50 + padding 7) → réel **60 pt** avec avatar **45 pt**. |
| Pictogrammes de statut | **DÉVIE (grave)** | code : `square.fill` bleu / `paperplane.fill` **violet** / `location.fill` **vert**. Réel : **bulle carrée contour bleue** (Reçu), **triangle plein bleu** (Remis), **triangle contour bleu** (Ouvert), **carré contour violet** (Snap non ouvert), **bulle contour grise** (Appuyer pour Chatter), **épingle contour grise** (lieu — jamais verte). |
| Accessoire droit | **DÉVIE** | code = appareil photo **gris dans un cercle `#F0F0F0`** ; réel = **contour noir sans fond**, et **« × »** sur certaines lignes. |
| **FAB « nouveau Chat »** | **ABSENT** | jaune ⌀ 60 pt, présent sur **12 frames sur 12**. Manque criant. |
| Avatars Bitmoji → émoji (D55) | *cohérent* | acceptable ; mais le réel a un **décor de fond** dans le cercle, l'émoji sur aplat pastel reste lisible. |

### 3.3 Conversation (`SnapConversationVue`)

| Point | Verdict | Détail |
|---|---|---|
| Nom coloré + barre verticale | **FIDÈLE (principe)** | bonne intuition, bonnes largeurs (2,5 pt). |
| **Fond gris du message** | **ABSENT** | le réel pose chaque bloc sur un **bandeau `#E7EBEE` pleine largeur**. Sans lui l'écran paraît « nu » — c'est ce qui fait le plus « pas Snapchat ». |
| **Horodatages** | **ABSENT** | `12:49` gris `#898989` aligné à droite sur la ligne du nom, sur **chaque** bloc. |
| Sous‑titre d'en‑tête | **ABSENT** | `À proximité · 1min` sous le nom. |
| Couleur « Moi » | **DÉVIE** | `#FF3B30` → **`#E63455`** (rose‑rouge Snapchat, pas le rouge iOS). |
| Icônes d'appel | **DÉVIE** | code gris → réel **noir plein**. |
| Bouton caméra du composeur | **DÉVIE** | code = cercle `#F0F0F0` glyphe noir → réel **cercle NOIR plein, glyphe blanc**. |
| Barre d'outils du composeur | **DÉVIE / ABSENT** | code = 1 seul `🙂`. Réel = **forme d'onde dans le champ** + **smiley + autocollant + manette** hors champ. |
| Séparateur de date | **FIDÈLE** | `7 AOÛT` / `HIER` ✔ (le réel utilise `17 AOÛT`, même registre). |
| État vide | **ABSENT** | e010‑e011 montrent un fil vide avec la mention centrée `AUJOURD'HUI / VOUS AVEZ ENREGISTRÉ L'ÉCRAN DU CHAT !`. |
| Contenu de fil identique pour tous les amis | **DÉVIE** | `SnapConversationVue` sert le **même** dialogue (lunettes éclipse) quel que soit l'ami, avec `ami.nom.uppercased()` — incohérent dès qu'on ouvre 2 conversations (le joueur fouille : il ouvrira les 7). |

### 3.4 Snap Map (`SnapCarteVue`)

| Point | Verdict | Détail |
|---|---|---|
| Libellés des chips | **FIDÈLE** | `Souvenirs / Tendance / Footsteps / Visité` ✔ |
| Icônes des chips | **ABSENT** | chaque chip porte une icône dans le réel. |
| Fond de carte | **DÉVIE (grave)** | MapKit standard → le réel est un **style vert propriétaire** sans POI Apple. Reconnaissable au premier coup d'œil. |
| Épingles | **DÉVIE** | code = cercle blanc 42 pt + émoji + micro‑libellé 9 pt. Réel = **Bitmoji corps entier posé sur la carte** + capsule blanche du nom. |
| **Colonne droite (4 boutons)** | **ABSENT** | Bitmoji / engrenage / calques / recentrer. Le code n'a qu'un engrenage isolé en haut à droite. |
| Pilule de lieu | **DÉVIE** | code : pilule **centrée** `Lyon` ouvrant une recherche. Réel : **en haut à droite**, `Roquelaure` + **`☀ 33 °C`**, non tapée. |
| Pilule « % exploré » | **DÉVIE** | `#B84DFF` opaque + `map.fill` → **lavande translucide + empreintes**. Libellé `2,4 % exploré(s)` correct dans la forme. |
| Rangée d'amis | **DÉVIE** | code : indentée 14 pt, remontée de 108 pt, avatars 44 pt. Réel : **pleine largeur, collée au filet (21 px), 43 pt, avec bouton de recherche en tête**. |
| **Vue Bitmoji 3D** | **ABSENT** | e033‑e034 : plein écran, pilule `3D`, capsule de statut. |
| **Feuille « Moi et mes amis·es »** | **ABSENT** | avec `Mettre à jour Bitmoji` et bouton jaune de chat. |
| **Boutons `Chat à plusieurs` / `Carte Snap`** | **ABSENT** | |
| **Dézoom jusqu'au globe** | **ABSENT** | 6 frames y sont consacrées ; le span du code est figé à 0,05°. |
| POI colorés | **ABSENT** | orange `#ED5019` / violet `#8A48CC` avec sous‑titre. |

### 3.5 Caméra (`SnapCameraVue`)

| Point | Verdict | Détail |
|---|---|---|
| Viseur simulé (dégradé sombre) | **JAMAIS FILMÉ — invention nécessaire** | acceptable en soi (pas d'accès caméra dans la fiction), **mais** l'écran est alors *vide*, alors que le réel superpose **4 étages d'UI** au viseur. C'est l'écran le plus pauvre de l'app. |
| Colonne d'outils | **DÉVIE** | code = 4 glyphes dans une **capsule sombre** ; réel = **6 glyphes libres** (retournement, flash barré, musique, mode, lune, **chevron ▼ dans un rond**). |
| Bitmoji + loupe | **DÉVIE** | le code les met dans le même `HStack` que la colonne ; réel : en‑tête à part, **loupe sans fond**. |
| Cloche + ajout d'ami « 47 » | **ABSENT** | présents sur le viseur réel. |
| **`AI` et `Souvenirs`** | **ABSENT** | remplacés par un `photo.on.rectangle` dans un cercle sombre, qui n'existe pas. |
| **Carrousel de Lenses** | **ABSENT** | remplacé par un `face.smiling` isolé. |
| **Onglets de Lenses** (`Favoris / Pour vous / Rentrée`) | **ABSENT** | pilule sombre sur l'actif. |
| Anneau de capture | **DÉVIE** | 78 pt → **85 pt** ; le réel n'est pas centré horizontalement mais **décalé à gauche du carrousel**. |
| Glyphe ⤢ au centre | **ABSENT** | |
| Flash blanc à la capture | *invention plausible* | garder. |

### 3.6 Stories (`SnapStoriesVue`)

| Point | Verdict | Détail |
|---|---|---|
| Titres de sections | **DÉVIE** | `Amis·es` / `Découvrir` ✔ mais **le chevron `›` manque** (ce sont des en‑têtes cliquables). |
| Bouton d'ajout d'ami « 47 » | **ABSENT** | l'en‑tête Stories du code s'arrête à la cloche + `•••`. |
| Anneaux d'amis | **DÉVIE** | code : contour violet uni 2,5 pt, prénom en dessous. Réel : **contour dégradé violet→rose** + **badge rouge « +N » en bas à gauche**. |
| Grille Découvrir | **DÉVIE** | code = grille 2 colonnes uniforme, tuiles 230 pt. Réel = **rangée horizontale de tuiles 119×193 pt** *puis* **grille 2 colonnes de 195×320 pt**. |
| Icône « OO » d'abonnement | **ABSENT** | en haut à droite de chaque grande tuile. |
| Tuiles sponsorisées | **ABSENT** | mention `Sponsorisé` + bouton blanc `Installer` (e053, e063‑e064). |
| Visionneuse d'histoire d'ami | **PRÉSENT mais JAMAIS FILMÉ** | aucune story d'ami n'est ouverte dans la vidéo. |
| Visionneuse Découvrir | **DÉVIE (grave)** | le code réutilise `VisualiseurContenuVue`, qui est de facture **Instagram** : barre de progression segmentée, **croix `✕`**, **champ « Envoyer un message… » + cœur + avion**. Le réel Snapchat (e055‑e062) : fond noir, carte insérée, chip éditeur, **pilule jaune `+ Ajouter`**, rail cœur/bulle(3)/partage(49), barre basse `[lens] [Voir le profil] [•••]`, **ni croix ni champ**. |

### 3.7 Spotlight (`SnapSpotlightVue`)

| Point | Verdict | Détail |
|---|---|---|
| **Fil vertical** | **ABSENT — le plus gros écart de l'app** | 43 frames de défilement continu ; le code affiche **une seule image figée**, non défilable. Un joueur qui swipe ne se passe rien. |
| Rail de droite | **DÉVIE** | ordre et contenu partiellement bons (cœur/bulle/boucle/partage) mais il manque **l'ampoule jaune Lens + badge « + »** en tête et la **pastille rouge** sur la bulle. |
| Compteurs | **DÉVIE (contenu)** | `741 / 108 / 49 / 143` sont **exactement** les compteurs du Spotlight réel de Joachim — à changer (règle « tout est Sarah »). |
| Bandeau bas | **DÉVIE** | code : pseudo + « Son original » posés **sur la vidéo**. Réel : **bandeau noir `#010008` hors vidéo**, avec `•••` au‑dessus et **vignette musicale verte** à droite. |
| Barre de progression | **ABSENT** | filet sous la vidéo. |
| Sous‑titres incrustés | **ABSENT** | présents sur ~40 frames — signature visuelle forte. |
| En‑tête | **DÉVIE** | code : `person.badge.plus` + `square.and.arrow.up` dans des ronds sombres. Réel : **ajout d'ami avec badge « 47 » sans fond** + **« + » dans un carré arrondi**. |
| Compteur du cœur figé | **DÉVIE (D82)** | `aime.toggle()` colore le cœur mais **`741` ne bouge pas** → le bouton ment. |

### 3.8 Profil — **ABSENT en totalité**

3 frames (e112‑e114), l'écran le plus dense du tournage, **zéro ligne de code**. Contenu relevé :
- Héros dégradé **vert `#1AB64B` → noir**, Bitmoji 3D, bulle de statut (`Place au luxe discret : la simplicité fait tout ✨`)
- `‹` retour, pilule **`Partager`** avec Snapcode jaune, bouton fantôme + pastille rouge, **engrenage**
- Cercle photo + badge crayon (changer la photo)
- Nom gras + `@pseudo` gris
- Deux capsules : **`Mon compte`** (contour blanc, actif) / **`Profil public`**
- Chips : `📍 28 juil. ›` · `👻 1996` (Snapscore) · `♌ Lion`
- Chip **jaune `#FFFC00`** : `Rejoindre l'établissement scolaire`
- Carte **Snapchat+** (blanche, liseré jaune, badge `Fonctionnalités mises à jour`, chevron)
- Section **`Publier sur…`** : `Spotlight / Atteignez une large audience` + bouton `Publier` ; `Ma Story · Mes amis·es` + `Ajouter`, sous‑rangée `Nouvelle Story privée` / `Nouvelle Story partagée` ; `Ma Story · Publique / Amis·es, followers et tout le monde` + `Ajouter`
- Section **`Amis·es`** : `Ajouter des amis·es / 1 demande d'ami·e !` + badge bleu `#00A5FF` « 1 » + chevron
- Fond de page gris clair, cartes blanches, coins ~14 pt
- e113 : modale **`Utiliser la photo de profil de vos contacts`** — bouton jaune `Ok`, `Prendre un Snap`, `Choisir parmi les photos du téléphone`

**Conséquence D82** : le Bitmoji d'en‑tête est présent sur **5 écrans** et n'ouvre rien. C'est le bouton mort le plus visible du jeu.

---

## 4. Test de chaque bouton (D82)

**Bilan : 41 contrôles — 28 morts (68 %), 3 menteurs, 2 aboutissant à un écran jamais filmé, 8 corrects.**

| Écran | Contrôle | État | Verdict D82 |
|---|---|---|---|
| Coquille | 5 onglets | change de vue | ✔ A |
| Coquille | `BarreHome` | `dismiss()` | ✔ A |
| Chat | Bitmoji en‑tête | rien | **MORT** → doit ouvrir le Profil (A) |
| Chat | Loupe | rien | **MORT** → écran de recherche (A) ou message (B) |
| Chat | Cloche | rien | **MORT** |
| Chat | Bouton jaune « C+ » (47) | rien | **MORT** → « Ajouter des amis·es » (A) |
| Chat | `•••` | rien | **MORT** |
| Chat | Chip `Groupes` / `Près de moi` / `Meilleurs·es amis·es` | filtre | ⚠ jamais filmé, mais plausible |
| Chat | Chip `🤖 My AI` | **filtre et n'affiche que « Team Snapchat »** | **MENTEUR** → doit ouvrir la conversation My AI |
| Chat | Ligne d'ami | ouvre la conversation | ✔ A |
| Chat | Rond appareil photo de ligne | rien | **MORT** (× 7 lignes) |
| Chat | FAB jaune | *n'existe pas* | **ABSENT** |
| Conv. | `‹` | `dismiss()` | ✔ A |
| Conv. | Avatar / nom | rien | **MORT** → fiche ami |
| Conv. | Téléphone | rien | **MORT** |
| Conv. | Vidéo | rien | **MORT** |
| Conv. | Champ + `onSubmit` | ajoute au fil | ✔ A |
| Conv. | Rond appareil photo | rien | **MORT** |
| Conv. | `🙂` | rien | **MORT** |
| Carte | Bitmoji | rien | **MORT** |
| Carte | Pilule `Lyon` | ouvre une recherche de lieu | ⚠ **jamais filmé** ; le réel n'est pas tapable |
| Carte | Engrenage | rien | **MORT** |
| Carte | 4 chips (`Souvenirs`…) | `filtreCarteActif` bascule, **aucun effet** sur la carte | **MENTEUR** (le plus grave : 4 boutons qui s'allument pour rien) |
| Carte | Avatars de la rangée basse | rien | **MORT** (× 7) |
| Carte | Épingles | rien | **MORT** → vue 3D |
| Carte | Recherche : `Fermer` / ligne de lieu | `dismiss()` | ✔ mais écran inventé |
| Caméra | Bitmoji / loupe | rien | **MORT** (× 2) |
| Caméra | 4 glyphes de la colonne | rien | **MORT** (× 4) |
| Caméra | Galerie (gauche) | rien | **MORT** |
| Caméra | Anneau de capture | flash + feuille d'envoi | ✔ A (mais feuille inventée) |
| Caméra | Smiley (droite) | rien | **MORT** |
| Envoi | Ligne d'ami | `dismiss()` sans confirmation | ⚠ **MENTEUR** : coche jamais remplie, aucun retour |
| Envoi | `Fermer` | `dismiss()` | ✔ |
| Stories | Bitmoji / loupe / cloche / `•••` | rien | **MORT** (× 4) |
| Stories | Anneau d'ami | visionneuse | ✔ A (mauvaise visionneuse) |
| Stories | Tuile Découvrir | visionneuse | ✔ A (mauvaise visionneuse) |
| Spotlight | Bitmoji / loupe | rien | **MORT** (× 2) |
| Spotlight | Ajout d'ami | rien | **MORT** |
| Spotlight | Partage (en‑tête) | rien | **MORT** |
| Spotlight | Cœur | bascule la couleur, **compteur figé à 741** | **MENTEUR** |
| Spotlight | Bulle / boucle / partage (rail) | rien | **MORT** (× 3) |

---

## 5. Écrans et états à filmer en plus

Par ordre d'utilité pour la refonte :

1. **Profil déroulé jusqu'en bas** (sous la section `Amis·es`) + onglet **`Profil public`**.
2. **Réglages** (engrenage du Profil) — au moins la première page.
3. **Recherche** (loupe) : état vide, saisie, résultats.
4. **`Ajouter des amis·es`** (bouton jaune 47) + liste des demandes.
5. **Menu `•••`** de l'en‑tête Chat.
6. **Notifications** (cloche).
7. **Nouveau Chat** (le FAB jaune) — écran de sélection de destinataires.
8. **Appui long sur une ligne de Chat** (menu contextuel) et **action du « × »** de fin de ligne.
9. **Fiche ami** (tap sur l'avatar dans une conversation) + boutons téléphone / vidéo.
10. **Story d'un ami** (rien que du Découvrir n'a été ouvert) : anneau `Amis·es`.
11. **Après capture** : écran d'édition du Snap (texte, stickers, minuteur) puis le vrai **« Envoyer à… »**.
12. **Souvenirs**, **Lens** (tap sur une vignette du carrousel), **onglets de Lenses**.
13. **Commentaires Spotlight** (la bulle « 108 ») et **partage**.
14. **Réglages de la carte** (engrenage) et **calques**.
15. **Conversation My AI**.
16. **État vide** d'une conversation neuve (variante de e010).
17. **Thème sombre global** de Snapchat s'il est activable.

---

## 6. Plan de refonte priorisé

Contenu **Sarah** conservé intégralement (`DonneesSnap.amis`, dialogues, Lyon) ; seuls la structure, les libellés, les couleurs et les mesures changent. Exception : **remplacer les compteurs Spotlight `741/108/49/143`** et `dribble97tk`, qui viennent des données réelles de Joachim.

### P0 — À réécrire (l'app n'est pas crédible sans)

| # | Chantier | Action | Mesures à respecter |
|---|---|---|---|
| 1 | **Écran Profil** (nouveau `SnapProfilVue`) | Création complète. Point d'entrée : **le Bitmoji d'en‑tête sur les 5 écrans** + le Bitmoji de la colonne droite de la carte. Débloque à lui seul 6 boutons morts. | héros `#1AB64B`→noir ; capsules `Mon compte` / `Profil public` ; chips ; chip jaune `#FFFC00` ; carte Snapchat+ liseré jaune ; sections `Publier sur…` et `Amis·es` ; cartes blanches, coins 14 pt, fond `#F2F2F5` ; badge bleu `#00A5FF` |
| 2 | **Spotlight en fil vertical** | Passer d'une image figée à un `TabView(.page)` vertical de 4‑6 contenus Sarah. Ajouter l'ampoule Lens, la pastille rouge de la bulle, le `•••`, le bandeau noir hors vidéo, la vignette musicale, la barre de progression, les sous‑titres incrustés. Le cœur doit **incrémenter le compteur**. | bandeau bas `#010008` ; barre d'onglets `#1B1B1B` ; en‑tête `+47` + « + » carré arrondi |
| 3 | **Caméra** | Ajouter les 3 étages manquants : colonne de **6** glyphes libres, rangée `AI` / `Souvenirs` / anneau **85 pt** / **carrousel de Lenses**, rangée d'onglets `Favoris / Pour vous / Rentrée` avec pilule sombre. Onglet Caméra de la barre = **vignette de Lens + chevron ▲**. | anneau ⌀ 85 pt ; vignettes ⌀ 36 pt ; supprimer la capsule sombre de la colonne |
| 4 | **Visionneuse Découvrir Snapchat** (nouveau composant, ne plus réutiliser `VisualiseurContenuVue`) | fond noir + carte insérée, chip éditeur, **`+ Ajouter` jaune**, rail cœur/bulle+pastille/partage, barre `[lens] [Voir le profil] [•••]`. **Retirer la croix et le champ de saisie.** | pilule jaune h 33 pt ; carte à y≈59 pt |
| 5 | **Purge D82** | Traiter les **28 boutons morts** : cloche → écran de notifications ou message iOS ; `•••` → menu ; loupe → recherche ; téléphone/vidéo → « Appel Snapchat indisponible » plausible ; **sinon retirer**. Supprimer ou câbler les **4 chips menteuses de la carte** et le filtre `My AI`. | — |

### P1 — À retoucher lourdement

| # | Chantier | Action |
|---|---|---|
| 6 | **Chat — liste** | Filtres en **texte nu** (écart 24 pt, avatar sur `My AI`) ; **FAB jaune 60 pt** (marge 16 pt / 15 pt) ; pictogrammes de statut refaits (contour bleu / plein bleu / carré violet / bulle grise / épingle grise) ; accessoire droit **noir sans cercle** + variante `×` ; pas 60 pt, avatar 45 pt ; pastille rouge sur le Bitmoji ; `C+` → glyphe silhouette+ ; cercles `#E7EAF1` |
| 7 | **Conversation** | **Bandeau gris `#E7EBEE`** derrière chaque bloc ; **horodatages `#898989`** ; sous‑titre `À proximité · 1min` ; « Moi » en `#E63455` ; icônes d'appel noires pleines ; composeur : cercle **noir** + forme d'onde dans le champ + smiley/autocollant/manette ; **un fil distinct par ami** |
| 8 | **Snap Map** | Colonne droite de **4 boutons 37 pt** ; pilule de lieu **en haut à droite + météo** ; chips **avec icônes** ; rangée d'amis **pleine largeur, collée au filet, bouton de recherche en tête** ; pilule « exploré » **lavande translucide** ; épingles Bitmoji corps entier + capsule de nom ; **teinter le fond MapKit en vert** (`.mapStyle` + calque `#D7EDC9` en `multiply`) à défaut d'un style propriétaire |
| 9 | **Barre d'onglets** | Glyphes **contour/plein** selon l'état ; couleur active `#252733` ; fond sombre `#1B1B1B` ; filet séparateur ; **badges sur les onglets 4 et 5** en `#FF1B3F`, masqués quand l'onglet est actif ; géométrie 101 pt / 41 pt / pas 74 pt |
| 10 | **Stories** | Ajouter le **bouton d'ajout d'ami gris** dans l'en‑tête ; chevrons `›` sur les titres ; **badges rouges « +N »** sur les anneaux, contour dégradé ; **deux registres** de Découvrir (rangée 119×193 pt puis grille 195×320 pt) ; icône « OO » ; une tuile `Sponsorisé` + `Installer` |

### P2 — À ajouter si le temps le permet

| # | Chantier |
|---|---|
| 11 | **Vue Bitmoji 3D** de la carte + feuille **« Moi et mes amis·es »** + `Chat à plusieurs` / `Carte Snap` (e033‑e034) |
| 12 | **Dézoom jusqu'au globe** (span libre + pilule `0,0003 % exploré(s)`) |
| 13 | **POI colorés** sur la carte (`#ED5019` / `#8A48CC`) avec sous‑titre |
| 14 | **État vide** de conversation (e010‑e011) |
| 15 | **Modale « Utiliser la photo de profil de vos contacts »** (e113) — bon candidat de « détail qui trahit le vrai téléphone » |
| 16 | Refaire la feuille **« Envoyer à… »** aux couleurs Snapchat (le `NavigationStack` + `Fermer` actuel est un pattern iOS générique, hors registre) |

### À supprimer

- `SnapRechercheCarteVue` — écran inventé, jamais filmé, et la pilule de lieu n'est pas tapable dans le réel. La remplacer par la pilule `Roquelaure ☀ 33 °C` non interactive.
- Le filtre `🤖 My AI` de la liste Chat sous sa forme actuelle.
- L'usage de `VisualiseurContenuVue` dans `SnapchatApp` (composant Instagram).

---

## 7. Table de correspondance des couleurs à corriger

| Rôle | Code actuel | Relevé vidéo | Frames |
|---|---|---|---|
| Jaune Snapchat | `0xFFFC00` | `#FFFC00` ✔ | e003, e114 |
| Badge rouge | `0xFF3B30` | **`#FF1B3F`** | e003, e005 |
| Cercles gris d'en‑tête | `0xF0F0F0` | **`#E7EAF1`** | e003 |
| Onglet actif (clair) | `.black` | **`#252733`** | e005 |
| Fond de barre sombre | `.black` | **`#1B1B1B`** | e075 |
| Bleu de statut / d'émetteur | `0x0EADFF` | `#1CA0F0` ✔ (proche) | e003, e014 |
| Violet « Snap non ouvert » | `0xB84DFF` (mal employé) | **`#9B4DFF`**, réservé au **carré contour** | e003 |
| Émetteur « Moi » | `0xFF3B30` | **`#E63455`** | e014 |
| Fond de message | *aucun* | **`#E7EBEE`** | e014 |
| Horodatage | *aucun* | **`#898989`** | e014 |
| Texte de statut | `.gray` | `#7B7F86` | e005 |
| Fond de carte | MapKit | **`#D7EDC9` / `#E7F6E3`** | e026 |
| POI carte | *aucun* | **`#ED5019`** / **`#8A48CC`** | e026 |
| Pilule « exploré » | `0xB84DFF` opaque | **lavande translucide ≈ `#B9A9D6` @60 %** | e026 |
| Héros du Profil | *absent* | **`#1AB64B` → noir** | e114 |
| Badge bleu du Profil | *absent* | **`#00A5FF`** | e114 |
| Bandeau bas Spotlight | *absent* | **`#010008`** | e075 |
