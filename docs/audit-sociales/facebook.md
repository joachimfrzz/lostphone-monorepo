# AUDIT — Facebook (proto-swift/Sources/FacebookApp.swift)

**Date** : 03/09/2026 · **Références** : `/agent/workspace/refs/t2/facebook/` (159 frames, 603×1311 px, **1 pt = 1,5 px**), planches `refs/sheets/facebook_1..4.jpg`
**Code audité** : `joachimfrzz/lostphone-monorepo@main:proto-swift/Sources/FacebookApp.swift` (SHA f287fc1) — ~700 lignes, 12 vues.
**Doctrines appliquées** : D67 (la référence = les enregistrements de Joachim, jamais une connaissance générale de Facebook), D82 (aucun bouton mort), D59 (contenu Sarah conservé).
**Vérification** : `MediaComposants.swift` récupéré → contenu 100 % WhatsApp, **aucun composant partagé n'est utilisé par Facebook**. FacebookApp ne dépend que de `ChargeurPhoto`, `Haptique`, `BarreHome`, `VisualiseurContenuVue`, `Color(hex:)`.

---

## 0. VERDICT EN UNE PHRASE

Le code reproduit un Facebook **de mémoire, pas de la vidéo** : l'architecture de navigation est fausse à la racine (le 6ᵉ onglet filmé est **Profil**, pas *Menu* ; le Menu filmé est un **tiroir latéral gauche** ouvert par un **hamburger en haut à gauche** que le code n'a pas du tout), et **l'écran le plus filmé de tout le corpus — le post en détail avec ses commentaires en pleine page — n'existe pas dans le code**. À l'inverse, 4 écrans/composants inventés (composeur plein écran, 3 feuilles « bientôt disponible », grille de raccourcis Menu) n'ont **jamais été filmés**. C'est exactement le reproche de Joachim.

---

## 1. INVENTAIRE DES ÉCRANS FILMÉS

Grille des planches : 8 colonnes × 6 rangées (planche 1 = e001-e048, 2 = e049-e096, 3 = e097-e144, 4 = e145-e159).

| # | Écran filmé | Frames clés | Occurrences | Dans le code ? |
|---|---|---|---|---|
| 1 | **Fil d'actualité** (barre haute + composer + stories + posts) | e001, e006, e102, e159 | très nombreux | Oui (dévie fortement) |
| 2 | **Post en détail + commentaires (pleine page, push)** | **e015**, e013, e017-e024 (avec clavier), e025-e028 | ~25 frames | **ABSENT** |
| 3 | **Feuille de partage** (composeur + Messenger + « Partager sur ») | **e021**, e029-e032, e037-e038 | ~8 frames | **ABSENT** |
| 4 | **Reels plein écran** (onglet) | **e112**, e109-e128 | ~20 frames | Oui (dévie fortement) |
| 5 | **Carrousel Reels dans le fil** (« Accéder à Reels › ») | e049-e058, e065 | ~12 frames | **ABSENT** |
| 6 | **Commentaires de Reel** (feuille basse « Plus pertinents ») | e129 (rangée 4 pl.3), e137-e140 | ~5 frames | **ABSENT** |
| 7 | **Onglet Ami(e)s** (Invitations + Vous connaissez peut-être) | **e130**, e129-e136, e145 | ~12 frames | Oui (dévie) |
| 8 | **Ami(e)s → Vos ami(e)s** (recherche + liste) | e146 | 1 | **ABSENT** |
| 9 | **Ami(e)s → Suggestions / état vide** (« Aucun(e) ami(e) avec des points communs ? ») | e098, e099, e144 | 3 | **ABSENT** |
| 10 | **Onglet Groupes** (Découvrir → Suggestions, grille) | **e147**, e148-e151 | 5 | Oui (dévie) |
| 11 | **Onglet Notifications** | **e152**, e153, e154 | 3 | Oui (dévie) |
| 12 | **Menu = tiroir latéral gauche** | **e103**, e104, e105-e108 | ~6 | **Structure ABSENTE** |
| 13 | **Menu → Autres produits Meta + Déconnexion** | e104, e105 | 2 | **ABSENT** |
| 14 | **Profil de Sarah (onglet Profil)** | e155-e158, e100, e101 | ~8 | Partiel (feuille bricolée) |
| 15 | **Profil d'une autre personne** (Francis Baron, Enzo Culin) | e040, e042-e044, e075 | ~6 | **ABSENT** |
| 16 | **Profil de Page** (Gossip Room : Suivre/Message, Liens, Coordonnées) | e085-e096 | ~10 | **ABSENT** |
| 17 | **Visionneuse photo** (« 1 de 2 », compteur, réactions) | e041, e042, e043 | 3 | Partiel (`VisualiseurContenuVue`) |
| 18 | **« Personnes qui ont partagé ça »** | e045-e048, e039 | ~5 | **ABSENT** |
| 19 | **Liste d'ami(e)s avec onglets** (Amis / Suivi(e)s / Suggestions / En commun) | e079-e084, e097 | ~8 | **ABSENT** |
| 20 | **Recherche** (champ vide, plein écran) | e067, e074 | 2 | **ABSENT** (icône morte) |
| 21 | **Post sponsorisé** (« Sponsorisé » + CTA *Installer* / *Accepter*) | e003, e004, e011, e068 | ~6 | **ABSENT** |
| 22 | **Carrousel de suggestions d'ami(e)s dans le fil** (cartes + *Ajouter* + ✕) | e006, e069-e073, e159 | ~10 | **ABSENT** |
| 23 | **Carte de groupe suggérée dans le fil** (« Retouches photos GRA… · Rejoindre ») | e049-e060 | ~12 | **ABSENT** |
| 24 | **Notification push système par-dessus l'app** (Zalando) | e155 | 1 | Hors périmètre |

**Jamais filmé** (donc à ne PAS inventer) : Marketplace, Watch/Vidéo, Souvenirs, Enregistrements, Fils, Meta AI, Paramètres, création de publication plein écran, création de story, création de groupe.

---

## 2. MESURES DE RÉFÉRENCE (relevées au pixel, PIL)

### 2.1 Couleurs

| Élément | Réf. mesurée | Code actuel | Écart |
|---|---|---|---|
| **Bleu Facebook** (boutons pleins, liens « Suivre », onglet actif) | **#0C59FD** (e147 : 20 103 px ; e130 : 20 077 px) | `#0866FF` | canal vert 102 vs **89** → le code est nettement plus azur/cyan. **À corriger** |
| Badge rouge (compteur Reels) | **#DF1C2D** (e001) | `#FF3B30` | trop orangé |
| Gris bouton secondaire (*Supprimer*, *Voir plus*) | **#DCE0E3** (e130, e103) | `#E4E6EB` | acceptable (garder #E4E6EB ou aligner) |
| Pill sélectionnée (*Découvrir*) fond | **#D2E7FC** (e147) | `#E7F0FF` | trop clair |
| Fond notification non lue | **#E2EEFE** (e152) | `#E7F0FF` | acceptable |
| Séparateur inter-blocs du fil | bande **6 px = 4 pt**, cœur **#C1C0C6** (e001 y=267-272 et y=613-619) | `Rectangle #F0F2F5, height 6` **pt** = 9 px | **2× trop épais et beaucoup trop clair** |
| Fond général (tous onglets, Menu inclus) | **#FEFEFE** blanc | Groupes et Menu forcés à `#F7F8FA` | dévie |
| Barre d'onglets — fil/listes | **#FEFEFE** | `.white.opacity(0.98)` | ok |
| Barre d'onglets — **Reels** | **#202020 (sombre)** (e112) | reste blanche | dévie |
| Icône Messenger (haut droite) | cercle **#000000** plein, éclair blanc | `message.circle.fill` noir | glyphe faux (bulle ≠ éclair) |

### 2.2 Géométrie

| Élément | Réf. (px) | Réf. (pt) | Code | Écart |
|---|---|---|---|---|
| Safe area haute | 95 | 63 | — | ok |
| Barre haute (hauteur utile) | ~70 | ~47 | implicite | ok |
| Hamburger ☰ (haut **gauche**) | 29×25, x=18 | 19×17, x=12 | **inexistant** | **manquant** |
| Wordmark « facebook » | x 66→255, ascendantes 34 | largeur 126 pt, corps ≈ **30 pt heavy** | `26 pt heavy` | trop petit |
| Titres d'onglet (« Ami(e)s », « Groupes », « Notifications ») | x=67, cap 30 | x=45 pt, corps ≈ **28 pt bold** | `24 pt bold`, x=14 pt | trop petit, mal indenté |
| Barre d'onglets | y 1195→1311 = 116 | **77 pt**, 6 onglets | `padding top 8 + bottom 26` | à recaler |
| Indicateur d'onglet actif | filet bleu 2 px au-dessus de l'onglet, largeur 61-85 px | **1,5 pt × ~41-57 pt** | **absent** | **manquant** |
| Icônes d'onglet | 30 px | **20 pt** | 20 pt | ok |
| Labels d'onglet | — | ~9,5 pt | 9 pt | ok |
| **Ami(e)s** — avatar | 136 | **90 pt** | 76 pt | trop petit |
| **Ami(e)s** — colonne texte | x=174 | **116 pt** | ~dépend du HStack | à figer |
| **Ami(e)s** — boutons *Confirmer*/*Supprimer* | 200×54, écart 12 | **133×36 pt**, gap 8 pt, r≈8 pt | `maxWidth .infinity`, `padding .vertical 8` (≈32 pt), r=7 | à recaler |
| **Ami(e)s** — pas de rangée | 163 | **109 pt** | — | à figer |
| **Ami(e)s** — badge horaire sur avatar (« 2 h », « 33 min », texte vert) | pill bas-droite | ~20 pt | **absent** | manquant |
| **Groupes** — carte | 278 large, gutter 12, marge 19 | **185 pt**, gutter **8 pt**, marge **13 pt** | grid spacing 10, padding 14 | proche, à recaler |
| **Groupes** — image de carte | 177 | **118 pt** | 96 pt | trop courte |
| **Groupes** — bouton *Rejoindre* | 245×52, inset 17 | **163×35 pt**, inset 11 pt, r≈5 pt | hauteur ≈29 pt | trop court |
| **Groupes** — ✕ de rejet sur l'image | cercle sombre 50 %, haut droite | ~24 pt | **absent** | manquant |
| **Groupes** — pill *Découvrir* | 139×46 | **93×31 pt** | 2 pills grises 13 pt | faux |
| **Notifications** — avatar | 90 + badge type 30 | **60 pt** + badge **20 pt** bleu bas-droite | 52 pt, pas de badge | trop petit, badge manquant |
| **Notifications** — colonne texte | x=128 | **85 pt** | — | à figer |
| **Notifications** — fond non lu | bloc **#E2EEFE continu** y 213→1193, **aucun séparateur** | — | fond par rangée + rangées blanches alternées | dévie |
| **Commentaires** — avatar | 61 | **41 pt** | 34 pt | trop petit |
| **Menu (tiroir)** — largeur | 537 | **358 pt** sur 402 (≈ 89 %), fil visible et assombri à droite | plein écran d'onglet | **structure fausse** |
| **Menu** — pas de rangée | 90 | **60 pt** | grille 2 colonnes | **structure fausse** |
| **Menu** — bouton *Voir plus* | pleine largeur, 50 h | **33 pt**, r≈10 pt, #DCE0E3 | **absent** | manquant |

---

## 3. AUDIT ÉCRAN PAR ÉCRAN

### 3.1 Barre d'onglets (`FacebookVue`) — **DÉVIE (structurel, priorité 1)**

Référence (e001, e112, e130, e147, e152) : **Accueil · Reels · Ami(e)s · Groupes · Notifications · Profil**.

| Onglet réf. | Icône réf. | Code | Verdict |
|---|---|---|---|
| Accueil | maison (pleine si actif) | `house.fill` | ok |
| Reels | rectangle vidéo type « play.tv » + **badge rouge 1** | `play.rectangle.on.rectangle`, badge absent | icône approximative, badge manquant |
| Ami(e)s | 2 silhouettes | `person.2` | ok |
| Groupes | **3 silhouettes DANS un cercle** | `person.3` (sans cercle) | dévie |
| Notifications | cloche | `bell` + badge « 3 » | badge **non filmé** sur la cloche (le badge filmé est sur **Reels**) → badge au mauvais onglet |
| **Profil** | **avatar/`person.circle`** | **« Menu » + `line.3.horizontal`** | **FAUX ONGLET** |

Autres écarts : indicateur bleu (filet 1,5 pt au-dessus de l'onglet actif) absent ; barre non assombrie sur Reels ; le code teste `o.2 == onglet && o.2 == 0 ? "house.fill" : o.0` — logique inutile (l'icône est déjà `house.fill`), et **aucun autre onglet n'a de variante pleine/active** alors que la référence montre l'icône remplie en bleu quand active (e130 Ami(e)s, e147 Groupes, e152 cloche).

**Le hamburger ☰ en haut à gauche est absent de TOUS les écrans** (il est présent dans la référence sur le fil, Reels, Ami(e)s, Groupes, Notifications) — c'est lui qui ouvre le Menu.

### 3.2 Fil (`FbFilVue`) — **DÉVIE**

| Point | Référence (e001, e006, e102) | Code | Verdict |
|---|---|---|---|
| Barre haute, ordre | **☰** · « facebook » 30 pt · **⊞ (plus dans carré arrondi, contour)** · **🔍 (loupe simple)** · **⬤ Messenger (cercle noir, éclair blanc)** | « facebook » 26 pt · `plus.circle.fill` · `magnifyingglass.circle.fill` · `message.circle.fill` + badge « 8 » | ☰ manquant, 3 glyphes faux, badge inventé |
| Composer | avatar 32 pt · « Quoi de neuf ? » gris 17 pt · icône **galerie photo grise** à droite | avatar 36 · texte 15 · `photo.on.rectangle` **vert #45BD62** | couleur inventée (la réf est grise), texte trop petit |
| Stories | tuiles **h≈208 px = 139 pt**, l≈104 px≈69 pt ; 1ʳᵉ tuile « **Créer une story** » avec avatar en haut + ⊕ bleu ; les autres sont des **suggestions de Pages** avec badge rond de la page en haut-gauche, titre 2 lignes + sous-titre « **Suggestions** » | tuile Créer 104×170, autres 104×**232** (hauteurs incohérentes entre elles), noms d'amis en bas-gauche sur dégradé | hauteurs fausses et incohérentes, libellé « Suggestions » absent, badge de page absent |
| Cartes intercalaires | **carrousel Reels** (« Reels » + … + ✕ + vignettes + « Accéder à Reels › »), **carrousel suggestions d'ami(e)s** (cartes + bouton *Ajouter* bleu clair + ✕), **carte de groupe suggéré** (*Rejoindre*), **posts sponsorisés** (« Sponsorisé » + CTA *Installer*) | aucun | **4 composants de fil absents** |
| Séparateur | bande 4 pt #C1C0C6 | 6 pt #F0F2F5 | dévie |

### 3.3 Post (`FbPostVue`) — **DÉVIE (priorité 1)**

| Point | Référence (e001, e006, e010, e015) | Code |
|---|---|---|
| En-tête ligne 1 | `Nom` **bold + badge vérifié bleu** + « **· Suivre** » (**lien bleu #0C59FD**) | nom seul ; « Suivre » noyé dans `meta` |
| En-tête ligne 2 | « 5 h **· 🌐** » (globe **icône**, 12 pt gris) | `"5 h · Suivre"` — inversion complète |
| Boutons d'en-tête | `…` puis `✕` (gris, 22 pt) | présents mais **morts** |
| Texte | tronqué à 3 lignes + « **Afficher la suite** » (gris bold) ; paragraphes séparés par une ligne vide | pas de troncature, `lineLimit` absent |
| Média | pleine largeur, **hauteur libre selon ratio** (e006 : ~660 px) ; lien d'article avec **bandeau titre blanc sur l'image** (e010) | `height: 300` fixe |
| Barre de stats | **pastille de réactions ronde** (👍 blanc sur cercle bleu, ou cluster 😢👍😮 superposé) + **compte bold noir** ; à droite « 36 commentaires  1 partage » **bold noir 14 pt** | `Text("👍❤️ 597")` en **emoji gris 13 pt** — dévie visuellement de façon très visible |
| Barre d'actions | **3 boutons** (J'aime · Commenter · Partager) sur post normal ; **4 boutons** (+ **Enregistrer**, glyphe marque-page) sur post de lien/Page (e010, e015, e021) | 3 boutons, jamais 4 ; icônes SF génériques ; libellés ok |
| Position de la barre | **collante en haut** quand on est en détail de post (e015) | n/a |

### 3.4 Commentaires (`FbCommentairesVue`) — **DÉVIE massivement (priorité 1)**

Référence e015 (pleine page poussée, pas une feuille) :
1. Barre haute : `‹` retour · avatar de l'auteur · « La Dépêche du Gers **· Suivre** » · « 3 j · 🌐 » · `…` à droite.
2. Média du post, puis **barre d'actions collante** (J'aime/Commenter/Partager/Enregistrer).
3. Ligne de résumé : **cluster de réactions** + « **118** » bold, à droite « **23 partages** » bold.
4. **Sélecteur de tri « Plus pertinents ⌄ »**.
5. Commentaires : avatar **41 pt** · « **Nom** · 3 j » sur **une seule ligne** (nom semibold noir, date gris) · texte **à plat sur fond blanc, SANS bulle grise** · ligne d'actions « **Répondre** » + **pastille de likes** (cercle bleu 👍 + « 3 ») ; à droite **👍 / 👎 en contour**.
   Les mentions de personnes sont en **bleu** dans le texte (« **Mathieu Guerin** il y a eu ça aussi »).
   Réponses imbriquées : « **Voir les 13 réponses** » (e137-e140).
6. Composer : capsule gris #EFEFEF pleine largeur « **Commentez…** » avec **icône appareil photo** et **⊕** À L'INTÉRIEUR de la capsule, **pas d'avion en papier**.

Code : feuille modale `navigationTitle("Commentaires")` + bouton « **OK** » (n'existe pas), bulles `RoundedRectangle(14)` #F0F2F5 autour du texte (n'existe pas), ligne « date · J'aime · Répondre » (mauvais libellés/ordre), `paperplane.fill` bleu (n'existe pas), pas de tri, pas de résumé de réactions, pas de 👍/👎, pas de réponses. → **à réécrire intégralement**.

### 3.5 Reels (`FbReelsVue`) — **DÉVIE**

| Point | Référence (e112, e109-e128) | Code |
|---|---|---|
| Barre haute | **☰** · « Reels » **28 pt bold blanc** · 🔍 · `…` (les deux dans des **cercles sombres translucides**) | « Reels » 22 pt · `camera` seule à droite |
| Rail droit | 👍 **959** / 💬 **65** / ↗ **42** / 🔖 **37** — **4 items, tous avec compteur**, glyphes en **contour blanc épais** | 👍 959 / 💬 66 / ↗ sans compteur / `…` ; **marque-page absent** |
| Bas | avatar · « Radio Cool Direct **🌐** » · **pill « Suivre » (capsule contour)** · légende · **bandeau audio défilant** (« ♪ Créé avec Edits… ») | « · Suivre » en texte simple, pas de pill, pas de bandeau audio |
| Barre d'onglets | **présente et sombre #202020** | reste blanche, contenu masqué derrière |
| Commentaires de Reel | **feuille basse** « Plus pertinents » sur la vidéo (e137-e140) | absent |
| Contenu | vidéo verticale plein cadre | image statique `p27` — acceptable en proto, mais aucune illusion de lecture |

### 3.6 Ami(e)s (`FbAmisVue`) — **DÉVIE**

| Point | Référence (e130, e145, e146, e098) | Code |
|---|---|---|
| Barre haute | ☰ · « Ami(e)s » 28 pt · 🔍 | « Ami(e)s » 24 pt · 🔍 (morte) |
| Pills | **« Suggestions » et « Vos ami(e)s »** — la sélectionnée est **bleu clair #D2E7FC / texte bleu**, l'autre grise | 2 pills **identiques** grises, aucune sélection, **mortes** |
| Section | « **Invitations** » + « **Voir tout** » (bleu, à droite) | « Demandes d'ami(e)s · 4 » (libellé inventé), pas de « Voir tout » |
| Rangée | avatar **90 pt** + **badge horaire vert** ; nom 17 pt à x=116 pt ; ancienneté (« 4 a », « 1 a ») **gris à droite sur la ligne du nom** ; **PAS de ligne « X amis en commun »** dans les invitations ; boutons 133×36 pt côte à côte | avatar 76 ; « 4 amis en commun » / « Suivi(e) par 191 personnes » sur une 2ᵉ ligne + une 3ᵉ ligne dupliquée à droite (« 4 sem. ») ; logique `d.1.contains("min")` bancale |
| 2ᵉ section | « **Vous connaissez peut-être…** » avec boutons **« Ajouter ami(e) » / « Supprimer »** | absente |
| Vue « Vos ami(e)s » | écran dédié : `‹` + « Vos ami(e)s » + 🔍 + champ « Rechercher des ami(e)s » + liste avec 💬 et `…` | absente |
| État vide | « **Aucun(e) ami(e) avec des points communs ?** » + illustration + bouton bleu « **Mettre à jour le profil** » | absent |

### 3.7 Groupes (`FbGroupesVue`) — **DÉVIE**

| Point | Référence (e147-e151) | Code |
|---|---|---|
| Barre haute | ☰ · « Groupes » 28 pt · **⊞** · 🔍 · **`…` dans un cercle** | « Groupes » 24 · `plus` · `magnifyingglass` (morte) ; pas de `…` |
| Pill | **une seule** pill « **Découvrir** » 93×31 pt, **#D2E7FC / texte bleu** | aucune |
| Titre de section | « **Suggestions** » ~19 pt bold | « **Découvrir** » — **libellé au mauvais endroit** |
| Carte | image **118 pt** + **✕ de rejet** en haut-droite + titre 2 lignes bold 15 pt + « Groupe (Privé) · 2,2 K membres » **sur 2 lignes** + **bouton *Rejoindre* BLEU PLEIN, texte blanc, 35 pt** | image 96 pt, pas de ✕, sous-titre `lineLimit(1)`, bouton **bleu clair #E7F0FF avec texte bleu** → **inversion complète du bouton principal**, hauteur 29 pt |
| Fond | blanc | `#F7F8FA` |
| Contenu | groupes réels lyonnais conservés (Sarah) ✓ | ✓ garder |

### 3.8 Notifications (`FbNotificationsVue`) — **DÉVIE**

| Point | Référence (e152-e154) | Code |
|---|---|---|
| Barre haute | ☰ · « Notifications » 28 pt · 🔍 · **`…` cerclé** | titre 24 pt seul |
| Section | « **Nouveau** » (bold, sur fond blanc) | absente |
| Fond | **bloc #E2EEFE continu** sur toute la zone non lue, **sans séparateur ni alternance** | fond par rangée, blanc/bleu alterné |
| Avatar | **60 pt** + **badge circulaire bleu 20 pt** en bas-droite indiquant le TYPE (silhouette+loupe = suggestions d'ami(e)s ; « f » = souvenir) | 52 pt, pas de badge |
| Texte | 1 bloc, **noms en bold** dans la phrase, **horodatage gris EN FIN DE PHRASE** (« … et 40 autres personnes. **5 sem.** ») | horodatage sur une 2ᵉ ligne séparée |
| Libellés | « Vous avez de nouvelles suggestions d'ami(e)s : … », « Remaniez votre souvenir de septembre 2021 », « Comme vous avez interagi avec …, ces Creators similaires pourraient vous int… » | « a commenté votre photo. », « a publié une nouvelle vidéo. » — **plausibles mais aucun n'est de la forme filmée** |
| `…` par rangée | oui, **aligné en haut** de la rangée | oui, aligné en haut ✓ |

### 3.9 Menu (`FbMenuVue`) — **STRUCTURE ABSENTE (priorité 1)**

Le code en fait un **6ᵉ onglet plein écran** avec une **grille 2×3 de raccourcis** et **4 rangées à chevron descendant**. La référence (e103-e108) montre un **tiroir latéral gauche** (358 pt de large, le fil reste visible et assombri à droite), ouvert par le **☰**, contenant, dans l'ordre :

1. **Carte blanche** (r≈14 pt, filet) : `avatar 32 pt` + « Sarah Levasseur » 19 pt + **chevron bas dans un cercle gris** ; hairline ; « **+** » (cercle noir) + « **Créer une Page Facebook** » (gris).
2. **Liste verticale, pas de 60 pt, icônes noires en contour à x=32 pt** : **Meta AI** (fleur) · **Enregistrements** (marque-page) · **Souvenirs** (horloge-flèche) · **Marketplace** (devanture) · **Fils** (rss).
3. Bouton pleine largeur « **Voir plus** » (#DCE0E3, 33 pt, r 10 pt).
4. Rangées pleine largeur séparées par hairlines, **icône à gauche + chevron à droite** : « **Aide et assistance** » (?) · « **Paramètres et confidentialité** » (engrenage) · « **Mises à niveau** » (**chevron HAUT = déployée**) → révèle une **grille 2 colonnes de cartes promo** (« Présence publique », « Facebook Plus »).
5. « **Autres produits Meta** » (chevron) → grille de cartes : Meta Quest 3S, Ray-Ban Meta, Edits, Meta AI, Threads, Instagram, WhatsApp, Meta Horizon.
6. Bouton « **Déconnexion** ».

Écarts du code : mauvais conteneur (onglet ≠ tiroir), grille 2 colonnes inventée, icônes **bleues pleines** au lieu de noires en contour, ordre faux, libellés faux (« Aide et assistance » ok, mais « Paramètres et confidentialité » ≠ « Réglages et confidentialité » du titre de feuille, « **Mentions légales et politiques** » **jamais filmé**, « Groupes » et « Reels » en raccourcis **jamais filmés dans le menu**), **« Voir plus », « Autres produits Meta », « Déconnexion », les cartes promo : tous absents**, fond `#F7F8FA` au lieu de blanc.

### 3.10 Profil (`FbProfilVue`) — **DÉVIE / mauvais conteneur**

Référence (e155-e158) : **onglet** (pas une feuille), barre haute « **Sarah Levasseur ▾** » + ✏️ + 🔍 + `…`, puis :
avatar **~100 pt** + nom 24 pt + sous-titre « **1 amis · 1 publication** » (une ligne, pas de colonnes de stats) + **2 boutons côte à côte** : « **Ajouter à la story** » (bleu plein, icône +) et « **Modifier le profil** » (gris, icône crayon) + **onglets « Tous / Photos / Reels »** (soulignement bleu sur l'actif) + « **Informations personnelles** » + ✏️ + rangées à icônes (📍 Lyon, 🎂 date, 👤 Femme) + « **Ami(e)s** » + « **Voir tout** » + grille d'avatars + « **Toutes les publications** » + « **Filtres** » + composer « Quoi de neuf ? » + chips « **📹 Réel** » / « **🔴 En direct** » + bouton « **Gérer les publications** ».

Code : feuille `navigationTitle("Profil")` + « Fermer », bannière grise 130, avatar 96, **2 colonnes de stats « 247 Ami(e)s / 5 Publications » qui n'existent pas dans la référence**, aucun bouton, aucun onglet, aucune section. → à réécrire comme onglet.

### 3.11 Composeur (`FbComposeurVue`) — **PRÉSENT mais JAMAIS FILMÉ**

Aucune frame ne montre l'ouverture de « Quoi de neuf ? ». Le seul composeur filmé est celui **de la feuille de partage** (e021) : carte blanche, avatar, nom, pill « **Fil ▾** », pill « **👥 Ami(e)s ▾** », placeholder « **Dites quelque chose à propos de ceci…** », icônes 😊 et 🏷, bouton bleu « **Partager maintenant** ». Le code invente à la place un plein écran « Créer une publication » avec « Annuler »/« Publier » et le placeholder « Quoi de neuf, Sarah ? ». → **à remplacer par le composeur de partage filmé**, ou à supprimer.

### 3.12 `FbFeuilleSimpleVue` — **INVENTÉE, 3 usages, D82-B abusif**

« La création de Reels sera disponible prochainement. » / « Choisissez un nom et invitez vos amis pour commencer. » / « Gérez vos paramètres Facebook ici. » — aucune n'est un message iOS crédible ; ce sont des placeholders d'app en chantier, avec en plus une icône `play.rectangle.fill` incongrue sur les trois. **À supprimer** (les 3 boutons déclencheurs ne sont pas filmés → catégorie C).

---

## 4. TEST D82 — CHAQUE BOUTON DU CODE

| # | Contrôle | Fichier / vue | Comportement actuel | Verdict D82 |
|---|---|---|---|---|
| 1 | `plus.circle.fill` (barre haute) | FbFilVue | ouvre `FbComposeurVue` (écran inventé) | **B→C** : glyphe faux + écran non filmé |
| 2 | `magnifyingglass.circle.fill` (barre haute) | FbFilVue | **rien** | **MORT** → A (écran Recherche filmé e067/e074) |
| 3 | `message.circle.fill` + badge « 8 » | FbFilVue | **rien** | **MORT — le plus grave** : c'est le pont vers Messenger demandé par Joachim |
| 4 | Icône galerie verte du composer | FbFilVue | **rien** | **MORT** → C (et la réf la montre grise) |
| 5 | Ligne « Quoi de neuf ? » | FbFilVue | **rien** (seul le `+` ouvre le composeur) | **MORT** → A |
| 6 | Tuile « Créer une story » | FbFilVue | **rien** (`onTapGesture` seulement sur les 3 stories d'amis) | **MORT** → C (création de story jamais filmée) |
| 7 | Stories Chloé / Inès / Léa | FbFilVue | `VisualiseurContenuVue` | **OK (A)** ✓ |
| 8 | `…` en-tête de post | FbPostVue | **rien** | **MORT** → A (menu contextuel) ou C |
| 9 | `✕` en-tête de post | FbPostVue | **rien** | **MORT** → A (masquer le post, c'est trivial) |
| 10 | Image du post | FbPostVue | **rien** | **MORT** → A (visionneuse « 1 de 2 » filmée e041-e043) |
| 11 | « J'aime » | FbPostVue | bascule locale + haptique | **OK (A)** ✓ mais l'état n'est pas persistant hors du fil |
| 12 | « Commenter » | FbPostVue | ouvre `FbCommentairesVue` — **mais les MÊMES 3 commentaires pour les 3 posts** (« Courage à la famille » etc. sous un post de poterie) | **A cassé** : incohérence narrative |
| 13 | « Partager » | FbPostVue | **rien** | **MORT** → A (feuille de partage filmée e021, très documentée) |
| 14 | Compteur de réactions / « 36 commentaires » | FbPostVue | **rien** (`Text` inerte) | **MORT** → A (ouvre commentaires / « Personnes qui ont partagé ça ») |
| 15 | « OK » (commentaires) | FbCommentairesVue | ferme | fonctionne mais **libellé/placement non filmés** |
| 16 | Envoi de commentaire (`paperplane`) | FbCommentairesVue | ajoute « Sarah Levasseur » | **OK (A)** ✓ mais glyphe inexistant en réf |
| 17 | « J'aime · Répondre » sous un commentaire | FbCommentaire | `Text` inerte | **MORT** → A (« Répondre » + 👍/👎 filmés) |
| 18 | 👍 (Reels) | FbReelsVue | bascule + haptique | **OK (A)** ✓ |
| 19 | 💬 66 (Reels) | FbReelsVue | **rien** | **MORT** → A (feuille de commentaires de Reel filmée) |
| 20 | ↗ (Reels) | FbReelsVue | **rien** | **MORT** → A |
| 21 | `…` (Reels) | FbReelsVue | **rien** | **MORT** → C |
| 22 | `camera` (Reels) | FbReelsVue | feuille « bientôt disponible » | **B abusif → C** |
| 23 | « · Suivre » (Reels) | FbReelsVue | `Text` inerte | **MORT** → A (pill *Suivre* → *Suivi(e)*) |
| 24 | Pills « Suggestions » / « Vos ami(e)s » | FbAmisVue | **rien**, aucune sélection | **MORTES** → A |
| 25 | 🔍 (Ami(e)s) | FbAmisVue | **rien** | **MORT** → A ou C |
| 26 | « Confirmer » / « Supprimer » | FbAmisVue | état + haptique + message « Demande acceptée/supprimée » | **OK (A)** ✓ le meilleur point du fichier |
| 27 | Avatar / nom d'un demandeur | FbAmisVue | **rien** | **MORT** → A (profil d'une autre personne filmé e040-e044) |
| 28 | `plus` (Groupes) | FbGroupesVue | feuille « Créer un groupe » | **B abusif → C** |
| 29 | 🔍 (Groupes) | FbGroupesVue | **rien** | **MORT** |
| 30 | « Rejoindre » | FbGroupesVue | → « Demande envoyée » + haptique | **OK (A)** ✓ (mais style inversé) |
| 31 | Carte de groupe (image/titre) | FbGroupesVue | **rien** | **MORT** → C (écran de groupe jamais filmé) ou A minimal |
| 32 | Rangée de notification | FbNotificationsVue | `fullScreenCover { FbFilVue() }` → **un 2ᵉ fil, plein écran, SANS retour, SANS barre d'onglets, SANS `BarreHome`** | **BUG BLOQUANT** : le joueur est piégé, il doit tuer l'app |
| 33 | `…` de notification | FbNotificationsVue | **rien** | **MORT** → A/C |
| 34 | `gearshape.fill` (Menu) | FbMenuVue | feuille « Réglages… » | **B abusif → C** |
| 35 | 🔍 (Menu) | FbMenuVue | **rien** | **MORT** |
| 36 | Carte « Sarah Levasseur / Voir votre profil » | FbMenuVue | ouvre `FbProfilVue` | fonctionne, mais **conteneur faux** |
| 37 | Chevron bas de la carte profil | FbMenuVue | inerte (dans la zone du tap parent) | ambigu |
| 38 | **6 raccourcis** (Souvenirs, Enregistrements, Groupes, Reels, Marketplace, Fils) | FbMenuVue | **rien × 6** | **6 BOUTONS MORTS** → C (grille non filmée ; la liste filmée, oui) |
| 39 | **4 rangées** (Aide, Paramètres, Meta AI, Mentions légales) avec `chevron.down` | FbMenuVue | **rien × 4**, alors que le chevron promet un dépliage | **4 BOUTONS MORTS** → A (dépliage réel filmé sur « Mises à niveau ») |
| 40 | « Fermer » (Profil) | FbProfilVue | ferme | ok, non filmé |
| 41 | Onglets de la barre basse | FacebookVue | changent d'onglet | **OK (A)** ✓ ; mais **l'onglet Menu doit devenir Profil** et l'état de chaque onglet est **remis à zéro** à chaque bascule (`@State` local) |
| 42 | `BarreHome` | FacebookVue | `dismiss()` | ok ✓ |

**Bilan D82 : 23 contrôles morts, 4 « bientôt disponible » abusifs, 1 bug bloquant (n° 32), 1 incohérence narrative (n° 12).** Sur ~42 contrôles, **9 seulement** répondent correctement.

---

## 5. LIEN AVEC MESSENGER

- **Facebook → Messenger** : la référence ne montre **qu'un seul** point d'entrée, le **cercle noir à éclair blanc en haut à droite du fil** (e001, e006, e102, e159) — sans badge de compteur dans les frames disponibles. Dans le code, cette icône existe mais **ne fait rien** et porte un badge « 8 » inventé. C'est la contrepartie exacte de la demande de Joachim (logo Facebook dans Messenger → ouvre Facebook) : **il faut câbler les deux sens**, avec le même mécanisme d'ouverture d'app.
- Second point de contact filmé : la feuille de partage (e021) expose « **Envoyer dans Messenger** » (rangée d'avatars de conversations) puis « Partager sur → **Messenger** ». Les noms qui y apparaissent doivent être **les contacts Messenger de Sarah** (Chloé, Maman, Marc…) pour que les deux apps se répondent.
- **Rien dans Facebook ne mentionne Marc** dans le corpus filmé : c'est cohérent avec la narration (Marc n'est pas « ami Facebook » de Sarah) et **doit rester ainsi** — l'absence de Marc sur Facebook est un indice en soi. Ne pas l'ajouter en post/notification ; en revanche la feuille de partage vers Messenger peut le faire apparaître comme conversation, ce qui est un point d'accroche narratif fort.

---

## 6. ÉCRANS / ÉTATS À FILMER EN PLUS (demande à Joachim)

Priorité haute (bloquent une refonte fidèle) :
1. **Onglet Profil** en entier, scrollé jusqu'en bas (sections après « Toutes les publications »), et le **menu du chevron ▾** à côté du nom.
2. **Menu (tiroir)** : ouverture par ☰ (le geste + l'animation), état **replié** de « Mises à niveau », dépliage de « **Aide et assistance** » et de « **Paramètres et confidentialité** », bas du tiroir (« Autres produits Meta » déplié + « Déconnexion »), et l'écran atteint par « **Voir plus** ».
3. **Écran Recherche** : champ vide (e067 seul), **saisie en cours**, **résultats**, historique/suggestions.
4. **Post en détail** ouvert par un **tap sur le post lui-même** (le corpus ne montre que l'arrivée par le bouton Commenter) et par un tap sur le **compteur de réactions**.
5. **Ouverture du `…` d'un post** et du **`✕`** (que se passe-t-il après ?).
6. **Notification tapée** → quel écran s'ouvre réellement (indispensable pour corriger le bug n° 32).

Priorité moyenne :
7. **Visionneuse photo** : le passage 1→2, le geste de fermeture, la barre d'actions en bas.
8. **Feuille de partage** scrollée jusqu'en bas (la 2ᵉ rangée « Groupes / Messages / Threads / Instagram / Plus » n'est visible qu'en partie, e037-e038) et le résultat de « **Partager maintenant** ».
9. **Reels** : ouverture des **commentaires** (e137-e140 sont partiels), le **`…`**, le tap sur l'avatar, la 🔍 de Reels.
10. **Groupes** : tap sur une carte, l'**⊞** de la barre haute, le **`…`** cerclé, l'état après « Rejoindre » (rechargement ?).
11. **Ami(e)s** : la pill « **Vos ami(e)s** » sélectionnée, « **Voir tout** » des Invitations, le badge horaire vert sur avatar (à quoi correspond-il ?).
12. **Post sponsorisé** : tap sur le CTA « Installer » / « Accepter ».
13. **États de chargement** (spinners) et **pull-to-refresh** du fil.
14. **Story ouverte** (aucune frame ne montre une story Facebook en lecture).

---

## 7. PLAN DE REFONTE PRIORISÉ

Principe : **réécrire la navigation et les 2 écrans les plus vus, retoucher le reste**. Tout le contenu Sarah (Lyon Ma Ville, Atelier Poterie Lyon 3, Chloé Berthier, les 4 demandes d'ami(e)s, les 4 groupes lyonnais, les commentaires de Gaëlle/Aurore/Francis) est **conservé tel quel** ; seules la structure, les libellés, les couleurs et les mesures changent.

### Lot 1 — Charte et architecture (RÉÉCRITURE, ~1 j)
1. Constantes : `fbBleu = 0x0C59FD`, `fbRouge = 0xDF1C2D`, `fbGris = 0xDCE0E3`, `fbPillBleu = 0xD2E7FC`, `fbNonLu = 0xE2EEFE`, `fbFiletBloc = 0xC1C0C6`, fond **blanc partout** (supprimer `#F7F8FA` de Groupes et Menu).
2. Séparateur inter-blocs : `Rectangle().fill(Color(hex: 0xC1C0C6)).frame(height: 4)` (au lieu de 6 pt #F0F2F5).
3. Barre d'onglets : **Accueil · Reels · Ami(e)s · Groupes · Notifications · Profil**, hauteur **77 pt**, icônes 20 pt, labels 9,5 pt, **variante pleine + bleue quand actif**, **filet bleu 1,5 pt × ~48 pt au-dessus de l'onglet actif**, badge rouge **#DF1C2D sur Reels** (supprimer celui de Notifications), **fond #202020 sur l'onglet Reels**.
4. **`FbBarreHaute`** réutilisable : `☰` (19×17 pt, x=12 pt) + titre 28 pt bold à x=45 pt (ou wordmark 30 pt heavy) + slot d'actions à droite. Utilisée par les 5 onglets.
5. **`FbMenuTiroir`** : `overlay` glissant de gauche, **358 pt**, fil visible et assombri à droite, fermeture par tap sur le voile ou glissement. Le ☰ l'ouvre depuis n'importe quel onglet. Contenu = la liste filmée (carte profil, 5 rangées 60 pt à icônes noires en contour, « Voir plus », 3 sections à chevron dont « Mises à niveau » **déployée par défaut** avec ses 2 cartes promo, « Autres produits Meta », « Déconnexion »). **Supprimer la grille 2×3 et les 4 rangées inventées.**
6. Remonter l'état des onglets dans `FacebookVue` (`@StateObject` ou `@State` parent) pour que les likes / demandes traitées / groupes rejoints **survivent** aux bascules d'onglet.

### Lot 2 — Post + détail + commentaires (RÉÉCRITURE, ~1,5 j) — *le plus rentable*
7. Enrichir `FbPost` : `verifie: Bool`, `suivre: Bool`, `metaHoraire: String` (« 5 h »), `confidentialite` (globe / 👥), `reactionsCluster: [String]`, `nbReactions: Int`, `nbCommentaires: Int`, `nbPartages: Int`, `estLien: Bool`, `ratioImage: CGFloat`, `commentaires: [FbCommentaire]` (**propres à chaque post** — corrige le n° 12).
8. `FbPostVue` : en-tête « Nom ✓ · **Suivre** » / « 5 h · 🌐 » ; texte `lineLimit(3)` + « **Afficher la suite** » ; média à ratio libre ; **pastille de réactions ronde** + compte bold ; « N commentaires  N partages » bold à droite ; barre d'actions **3 ou 4 boutons** selon `estLien` (+ **Enregistrer**).
9. **`FbPostDetailVue`** (nouveau, **push** `NavigationLink`, pas une feuille) : `‹` + en-tête auteur + `…`, média, barre d'actions collante, résumé de réactions, « **Plus pertinents ⌄** », commentaires **sans bulle**, « Nom · 3 j » sur une ligne, mentions en bleu, ligne « **Répondre** » + pastille de likes + **👍/👎**, « Voir les N réponses », composer capsule « **Commentez…** » avec 📷 et ⊕ **dans** la capsule. **Supprimer `FbCommentairesVue`.**
10. **`FbPartageVue`** (nouveau, feuille basse) : grabber, carte composeur (avatar, nom, pills « Fil ▾ » / « 👥 Ami(e)s ▾ », « Dites quelque chose à propos de ceci… », 😊 🏷, bouton bleu « **Partager maintenant** »), « **Envoyer dans Messenger** » (contacts Messenger de Sarah), « **Partager sur** » (Votre story, Messenger, WhatsApp, Copier le lien, Statut WhatsApp, Groupes, Messages, Threads, Instagram, Plus). Câblée sur le bouton **Partager** (n° 13).
11. **`FbVisionneusePhotoVue`** : compteur « 1 de 2 », `✕`, réactions et « N commentaires » en bas — câblée sur le tap image (n° 10). Peut réutiliser `VisualiseurContenuVue` en l'habillant.

### Lot 3 — Correctifs bloquants et D82 (RETOUCHE, ~0,5 j)
12. **Bug n° 32** : remplacer `fullScreenCover { FbFilVue() }` par une navigation **push vers `FbPostDetailVue`** (ou, en attendant les frames demandées au § 6.6, par un simple retour à l'onglet Accueil).
13. Câbler : `✕` du post (masque le post + rangée « Publication masquée · Annuler »), 🔍 (→ écran Recherche, cf. lot 5), **icône Messenger → ouverture de l'app Messenger** (pont bidirectionnel, cf. § 5), compteur de réactions → détail, « Répondre » → composer préremplie, 💬/↗ de Reels, « Suivre » de Reels (pill → « Suivi(e) »).
14. **Supprimer** : `FbFeuilleSimpleVue` et ses 3 appels, `FbComposeurVue` (ou le remplacer par la carte de partage filmée), le badge « 8 » de Messenger, les 6 raccourcis morts et les 4 rangées mortes du Menu, l'icône galerie verte du composer (ou la passer en gris et la câbler sur le composeur), le `…` de Reels, le `…` de notification.
15. Corriger les glyphes de la barre haute : `plus.app` / plus dans carré arrondi contour · `magnifyingglass` simple · **logo Messenger (éclair) sur cercle noir**.

### Lot 4 — Onglets Ami(e)s / Groupes / Notifications / Profil (RETOUCHE, ~1 j)
16. **Ami(e)s** : pills fonctionnelles avec sélection (#D2E7FC/bleu), titre « **Invitations** » + « **Voir tout** », rangée à avatar **90 pt** + badge horaire, nom 17 pt à x=116 pt, ancienneté à droite, boutons **133×36 pt r8**, pas de rangée **109 pt**, 2ᵉ section « **Vous connaissez peut-être…** » (*Ajouter ami(e)* / *Supprimer*), sous-écran « **Vos ami(e)s** » (recherche + liste), état vide « Aucun(e) ami(e) avec des points communs ? ».
17. **Groupes** : pill « **Découvrir** », titre « **Suggestions** », image de carte **118 pt**, **✕ de rejet**, sous-titre 2 lignes, **bouton *Rejoindre* bleu plein 35 pt** (inverser), carte 185 pt / gutter 8 pt / marge 13 pt, fond blanc.
18. **Notifications** : « **Nouveau** », **bloc #E2EEFE continu**, avatar **60 pt** + **badge de type bleu 20 pt**, texte en un bloc avec **noms en bold** et **horodatage en fin de phrase**, libellés reformulés à la forme filmée (ex. « Vous avez de nouvelles suggestions d'ami(e)s : **Chloé Berthier**, **Inès Djellal** et 12 autres personnes. 2 j »).
19. **Profil** : transformer en **onglet** (`FbProfilVue` → contenu de l'onglet 5), barre haute « Sarah Levasseur ▾ » + ✏️ 🔍 `…`, avatar 100 pt, sous-titre « **247 ami(e)s · 5 publications** » (**une ligne**, supprimer les colonnes de stats), boutons « **Ajouter à la story** » (bleu) / « **Modifier le profil** » (gris), onglets **Tous / Photos / Reels**, « Informations personnelles » (Lyon 3ᵉ, date, Femme), « Ami(e)s » + « Voir tout » + grille, « Toutes les publications » + « Filtres ».

### Lot 5 — Composants de fil manquants (AJOUT, ~1 j)
20. **Barre haute du fil** : wordmark **30 pt**, ☰, 3 bonnes icônes.
21. **Stories** : tuiles **69 × 139 pt** uniformes, 1ʳᵉ = « Créer une story » (avatar + ⊕ bleu), suivantes = **suggestions de Pages** (badge rond en haut-gauche, titre 2 lignes, sous-titre « **Suggestions** ») — les stories d'amies de Sarah (Chloé, Inès, Léa) restent, en gardant le format filmé.
22. **Carrousel Reels dans le fil** (« Reels » + `…` + `✕` + vignettes + « **Accéder à Reels ›** »).
23. **Carrousel de suggestions d'ami(e)s** (cartes avatar + nom 2 lignes + bouton « **Ajouter** » bleu clair + `✕`).
24. **Carte de groupe suggéré** (« Lyon 3e — Entre voisins · **Rejoindre** »).
25. **Post sponsorisé** (« Sponsorisé » + CTA plein bleu) — utile narrativement : c'est le vecteur de l'arnaque type de la référence (« Un gain de 500 € vous appelle », « Déblock — Application bancaire », e003-e004). **À exploiter pour Marc/l'arnaque sans nommer Marc.**
26. **Écran Recherche** (après réception des frames du § 6.3).

**Charge estimée : 5 à 5,5 j.** Ordre de valeur décroissante : **Lot 1 → Lot 2 → Lot 3 → Lot 4 → Lot 5**. Les lots 1 à 3 (≈3 j) suffisent à faire disparaître le reproche « moins abouti, moins fidèle » : ils corrigent l'architecture de navigation, l'écran le plus vu du corpus et les 23 boutons morts.
