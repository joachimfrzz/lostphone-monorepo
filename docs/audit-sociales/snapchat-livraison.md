# Snapchat — livraison v3 (D91, 03/09/2026)

**Fichier livré** : `/agent/workspace/src/SnapchatApp.swift` — 3 148 lignes, 43 types, tous préfixés `Snap` / `DonneesSnap`.
**Patch de registre** : `/agent/workspace/src/patches/snapchat-lpproto.md` (corps exact de `ecransSnapchat()`).
**Clés de capture** : `/agent/workspace/src/patches/snapchat-ecrans.txt` (15 clés).
**Vérificateur** : `/agent/workspace/src/verif_snap.py` — **0 erreur, 0 avertissement**.

`LPProto.swift` n'a **pas** été modifié. Rien n'a été poussé.

---

## 1. Écran par écran

### 1.1 Coquille — `SnapchatVue` (e001 / e003 / e026 / e053 / e075)

| | |
|---|---|
| **Fait** | 5 onglets dans l'ordre Carte / Chat / Caméra / Stories / Spotlight. Barre `SnapBarreOnglets` : filet séparateur, hauteur 101 pt, glyphes 23 pt **contour → plein** selon l'état, actif `#252733` en clair, fond sombre `#1B1B1B`, badges `#FF1B3F` sur les onglets 4 et 5 **masqués quand l'onglet est actif**, badge « TOP » rose sur l'onglet 4, onglet Caméra = **vignette de Lens + chevron ▲**. Thème clair sur 0/1/3, sombre sur 2/4. `init(onglet:)` pour le mode capture, `ONGLET` toujours lu à défaut. |
| **Frames** | e001, e003, e005, e026, e053, e075 |
| **TODO tournage** | Thème sombre global de Snapchat (§5.17) — non filmé, non implémenté. |

### 1.2 En-tête commun — `SnapEnTete` (§2.2)

| | |
|---|---|
| **Fait** | Ordre strict `[Bitmoji + pastille rouge] [loupe] ··· TITRE ··· [cloche] [ajout d'ami + badge 47] [•••]`. Cercles ⌀35 pt `#E7EAF1`, bouton d'ajout ⌀40 pt (jaune sur Chat, gris sur Stories, sans fond sur Caméra/Spotlight), badge `47` `#FF1B3F`. Spotlight : cloche et `•••` remplacés par le **« + » carré arrondi**. Caméra : sans titre, sans `•••`. |
| **Frames** | e003, e053, e001, e075 |
| **D82** | Les 5 commandes agissent. Le **Bitmoji ouvre le Profil** sur Chat, Stories, Caméra, Spotlight ; sur la Carte c'est le Bitmoji de la colonne droite (6 points d'entrée au total). |

### 1.3 Chat — liste — `SnapChatListeVue`, `SnapLigneChat` (e003, e005, e022)

| | |
|---|---|
| **Fait** | **Filtres en texte nu**, écart 24 pt, avatar ⌀21 pt sur `My AI`. Pas de ligne **60 pt**, avatar **45 pt**, colonne texte, statut 12,5 pt `#7B7F86`. **Pictogrammes refaits** : bulle contour bleue (Reçu), triangle plein bleu (Remis), triangle contour bleu (Ouvert), carré contour violet `#9B4DFF` (Snap non ouvert), bulle contour grise (Appuyer pour Chatter), épingle contour grise (lieu), rien pour My AI. Accessoire droit **noir sans cercle**, variante `×`. **FAB jaune ⌀60 pt**, marge 16 pt / 15 pt au-dessus du filet, → `SnapNouveauChatVue`. Appui long → menu contextuel. |
| **Frames** | e003, e005, e022 |
| **D82** | `My AI` **ouvre la conversation My AI** (plus un filtre menteur). L'accessoire caméra ouvre le fil ; le `×` répond par un message. Loupe / cloche / `•••` / bouton 47 ouvrent chacun un écran. |
| **TODO tournage** | Menu `•••` (§5.5), notifications (§5.6), appui long (§5.8) : feuilles sobres annotées. |

### 1.4 Conversation — `SnapConversationVue`, `SnapBlocMessage`, `SnapComposeur` (e010–e017)

| | |
|---|---|
| **Fait** | **Bandeau gris `#E7EBEE` pleine largeur** + barre verticale colorée 2,5 pt. **Horodatage `#898989`** aligné à droite sur chaque bloc. « Moi » **`#E63455`**, l'ami en `#1CA0F0`. En-tête : `‹`, avatar 29 pt, nom gras + **sous-titre `À proximité · 1min`**, téléphone et vidéo **noirs pleins**. Séparateur `17 AOÛT`. **État vide** `AUJOURD'HUI / VOUS AVEZ ENREGISTRÉ L'ÉCRAN DU CHAT !`. Composeur : **cercle noir ⌀36 pt** + champ capsule à **curseur rouge** avec **forme d'onde à l'intérieur**, puis smiley / autocollant / manette hors champ. **Un fil distinct par ami** (12 fils dans `DonneesSnap.filsInitiaux`). Envoi réel avec passage `Envoi… → Remis`. |
| **Frames** | e010, e011, e012–e016, **e014** (toutes les mesures), e017 |
| **D82** | Avatar / nom → fiche d'ami·e ; téléphone et vidéo → message d'indisponibilité crédible ; les 3 glyphes du composeur agissent. |
| **TODO tournage** | Fiche d'ami·e (§5.9), conversation My AI (§5.15) — feuille sobre annotée. |

### 1.5 Snap Map — `SnapCarteVue`, `SnapCarte3DVue` (e023–e051)

| | |
|---|---|
| **Fait** | MapKit **sans POI Apple** (`.standard(pointsOfInterest: .excludingAll)`) + calque **`#D7EDC9` en `multiply`** → rendu vert Snapchat. **Chips avec icônes** `Souvenirs / Tendance / Footsteps / Visité` **qui filtrent réellement les épingles**. **Pilule de lieu en haut à droite** `Lyon 7e` + `☀ 24 °C`, **non tapable**. **Colonne droite de 4 boutons ⌀37 pt** : Bitmoji + pastille (→ Profil), engrenage, calques, recentrer. Pilule **lavande translucide** `3,8 % exploré(s)` avec empreintes, bas-gauche. **Rangée d'amis pleine largeur ⌀43 pt collée au filet, bouton de recherche en tête**. Épingles = **Bitmoji corps entier** (`SnapSilhouette`) + capsule blanche du nom. **POI colorés** `#ED5019` / `#8A48CC` avec sous-titre. **Vue 3D** (`SnapCarte3DVue`) : pilule bleue `3D`, capsule de statut, boutons `Chat à plusieurs` / `Carte Snap`, feuille **« Moi et mes amis·es »** avec `Mettre à jour Bitmoji` et bouton **jaune** de chat. |
| **Frames** | e023–e032 (mesures d'**e026**), **e033–e034** (vue 3D), e049–e051 |
| **Supprimé** | `SnapRechercheCarteVue` (écran inventé, §6) — la pilule de lieu n'est plus interactive. |
| **TODO tournage** | **Dézoom jusqu'au globe** (e035–e048) non implémenté : la caméra reste libre au geste mais aucune pilule `0,0003 % exploré(s)` ni heatmap. Réglages de carte et calques (§5.14) = feuilles sobres. |

### 1.6 Caméra — `SnapCameraVue`, `SnapEditionSnapVue`, `SnapEnvoyerAVue` (e001, e110)

| | |
|---|---|
| **Fait** | Les **4 étages** superposés au viseur diégétique. ① En-tête (Bitmoji, loupe, cloche, ajout 47) glyphes blancs sans fond. ② **Colonne de 6 glyphes blancs LIBRES** (retournement, flash barré, musique, mode, lune, chevron ▼ dans un rond sombre) — **plus aucune capsule sombre**. ③ Rangée `AI` / `Souvenirs` (+ pastille) avec **libellés sous le glyphe**, **anneau ⌀85 pt décalé à gauche**, **carrousel de Lenses ⌀36 pt**. ④ **Onglets de Lenses** `Récents / Favoris / Pour vous / Rentrée / Essayer` avec **pilule sombre sur l'actif**, manette à gauche, smiley d'ajout à droite. Glyphe **⤢** au centre du viseur. Flash blanc à la capture → **écran d'édition** (texte, dessin, smiley, minuteur, `Enregistrer`, `Envoyer à` jaune) → **« Envoyer à… »** aux couleurs Snapchat, avec **coche réellement remplie** et **envoi effectif du Snap dans la conversation**. |
| **Frames** | e001, e110, e111 |
| **D82** | Les 6 outils de la colonne, `AI`, `Souvenirs`, la manette et le smiley répondent tous. L'ancienne feuille d'envoi qui se fermait sans confirmation est corrigée. |
| **TODO tournage** | Écran d'édition (§5.11), Souvenirs (§5.12), tap sur une Lens (§5.12) : implémentés sobres et annotés. |

### 1.7 Stories — `SnapStoriesVue` (e052–e054, e063–e064)

| | |
|---|---|
| **Fait** | En-tête avec **bouton d'ajout d'ami gris** et badge 47. Titres `Amis·es ›` / `Découvrir ›` **avec chevron, cliquables**. Anneaux ⌀62 pt à **contour dégradé violet → rose** + **badge rouge « +N »**, pseudo sous le nom, bouton `Ajouter` en tête. **Deux registres de Découvrir** : rangée horizontale **119×193 pt** puis grille 2 colonnes **~195×300 pt**, coins 12 pt. **Icône « OO » d'abonnement** en haut à droite (bascule réelle). Tuile **`Sponsorisé` + bouton blanc `Installer`**. |
| **Frames** | e052, e053, e054, e063, e064, e108, e109 |
| **TODO tournage** | Story d'ami·e (§5.10) — jamais ouverte dans la vidéo : rendue par la visionneuse Snapchat en mode `storyAmi` (sans `+ Ajouter`, bouton `Répondre`). |

### 1.8 Visionneuse Découvrir — `SnapVisionneuseDecouvrirVue` (e055–e062)

| | |
|---|---|
| **Fait** | Composant **neuf** : fond noir, **carte insérée à coins arrondis**, filet de progression tout en haut, chip éditeur rond + `★` + accroche, **pilule jaune `+ Ajouter` h 33 pt** (bascule en `Ajouté`), rail droit aligné en bas (cœur / bulle + **pastille rouge** + `3` / partage + `62`), barre basse `[rond lens] [capsule « Voir le profil »] [rond •••]`. **Ni croix de fermeture, ni champ de saisie.** |
| **Frames** | e055–e062 (mesures d'**e057**) |
| **Supprimé** | L'usage de `VisualiseurContenuVue` (composant Instagram) dans Snapchat, y compris pour la clé de capture `snapchat.story`. |

### 1.9 Spotlight — `SnapSpotlightVue`, `SnapCartePage` (e065–e107)

| | |
|---|---|
| **Fait** | **Fil vertical réellement défilable** : `ScrollView` + `scrollTargetLayout()` + `scrollTargetBehavior(.paging)` sur **5 contenus Sarah**. Vignette éditeur ronde en haut-gauche. Rail droit complet : **ampoule jaune dans un rond blanc + badge « + »**, **cœur avec compteur qui incrémente pour de bon**, bulle + **pastille rouge** + compteur, boucle, partage. **Sous-titres incrustés** sur chaque contenu. **Barre de progression** fine sous la vidéo. **Bandeau noir `#010008` hors vidéo** : `•••` au-dessus, pseudo gras, `♪ Son original · …`, **vignette musicale verte/teal** à droite. En-tête `+47` sans fond + « + » carré arrondi. |
| **Frames** | e065–e107 (mesures d'**e075**) |
| **D82** | Le cœur **n'est plus menteur** : `SnapEtat.basculerCoeur` modifie le compteur `@Published`. Bulle, boucle, partage, `•••`, ampoule et vignette musicale répondent tous. |
| **TODO tournage** | Commentaires (§5.13) et partage : feuilles sobres annotées. |

### 1.10 Profil — `SnapProfilVue` (e112–e114) — **écran entièrement nouveau**

| | |
|---|---|
| **Fait** | Héros **`#1AB64B` → noir**, bulle de statut, `‹` retour, pilule **`Partager`** avec Snapcode jaune, bouton fantôme + pastille rouge, **engrenage**. Cercle photo + **badge crayon**. Nom gras + `@pseudo`. Deux capsules **`Mon compte` / `Profil public`** (contour blanc sur l'active). Chips `📍 28 juil. ›` / `👻 3 402` / `♓️ Poissons`. **Chip jaune `Rejoindre l'établissement scolaire`**. Carte **Snapchat+** blanche à **liseré jaune** + badge `Fonctionnalités mises à jour` + chevron. Section **`Publier sur…`** : `Spotlight / Atteignez une large audience` + `Publier` ; `Ma Story · Mes amis·es` + `Ajouter` ; sous-rangée `Nouvelle Story privée` / `Nouvelle Story partagée` ; `Ma Story · Publique` + `Ajouter`. Section **`Amis·es`** : `Ajouter des amis·es / 1 demande d'ami·e !` + **badge bleu `#00A5FF`** + chevron. Fond `#F2F2F5`, cartes blanches, coins 14 pt. **Modale e113** « Utiliser la photo de profil de vos contacts ? » avec bouton jaune `Ok`, `Prendre un Snap`, `Choisir parmi les photos du téléphone`. |
| **Frames** | e112, **e113**, e114 |
| **TODO tournage** | Le Profil n'a pas été déroulé sous `Amis·es` (§5.1) : bloc sobre de 3 lignes annoté. Onglet `Profil public` (§5.1) et Réglages (§5.2) : feuilles sobres. |

### 1.11 Écrans jamais filmés (§5) — sobres et annotés

`SnapRechercheVue` (loupe), `SnapAjoutAmisVue` (bouton 47, avec compteur de demandes qui décroît réellement), `SnapNouveauChatVue` (FAB), et 11 variantes de `SnapFeuilleSobre` (Réglages, Notifications, menu `•••`, Souvenirs, Calques, Réglages de la carte, Profil public, Commentaires, Partage, Profil éditeur, Créer). Chacune porte une note `TODO tournage : … (§5.x)` visible à l'écran et **une `BarreHome`**.

---

## 2. Bilan D82

| Avant (audit §4) | Après |
|---|---|
| 41 contrôles, **28 morts**, 3 menteurs, 2 vers un écran inventé, 8 corrects | **0 mort, 0 menteur.** Chaque contrôle ouvre un écran (A) ou répond par un message crédible via `snapAlerte` (B, ~18 cas, tous à propos). Les deux contrôles inventés (`SnapRechercheCarteVue`, filtre `My AI`) ont été **retirés** (C). |

Points spécifiquement débloqués : Bitmoji d'en-tête → Profil (× 6 écrans) · FAB jaune (× 12 frames) · chips de la carte qui filtrent vraiment · cœur Spotlight qui incrémente · coche de « Envoyer à… » qui se remplit et envoie le Snap · 4 boutons de la colonne droite de la carte · épingles → vue 3D.

---

## 3. Données (D59)

- Contenu **entièrement Sarah Marchand** (Lyon 7e, `sarah.mrchd`), 12 amis·es, 12 fils distincts, 5 Spotlight, 5 stories d'amis·es, 8 tuiles Découvrir, 7 épingles de carte.
- **Retirées** : les compteurs Spotlight `741 / 108 / 49 / 143`, le pseudo `dribble97tk`, le `49` du rail de la visionneuse Découvrir, les lieux du Gers (Fleurance, Auch, Roquelaure) → Lyon, `Sacha Fourez` conservé (déjà un nom de la fiction). Le vérificateur échoue si l'un de ces motifs réapparaît.

---

## 4. Risques de compilation évités

| Règle | Traitement |
|---|---|
| Ternaires de couleur non typés (« member 'white' in 'HierarchicalShapeStyle' ») | **7 ternaires réécrits** en `Color.x` (`SnapEnTete.teinteGlyphe`, `SnapBarreOnglets.teinte`, filtres du Chat, onglets de Lenses, chips de la carte, rails de la visionneuse et du Spotlight). Contrôle automatisé ajouté au vérificateur, y compris le cas hiérarchique. |
| Switch `@ViewBuilder` de 16 cas dans `SnapRouteVue` | Refactorisé : **5 branches de vues + 1 branche commune**, les 11 feuilles passent par une propriété **non-`@ViewBuilder`** qui retourne un `SnapFeuilleSobre`. `_ConditionalContent` profond 6 au lieu de 16. |
| `navigationDestination` déclaré plusieurs fois | **Aucun `NavigationStack`, aucun `navigationDestination`** dans le fichier. Toute la navigation secondaire passe par un `SnapRoute?` unique présenté en `fullScreenCover(item:)`. |
| `.background(Color…, in:)` ambigu | Aucune occurrence : toujours `.background(Shape().fill(…))`. |
| `.scaledToFill()` direct sur une `Image` en cellule | Uniquement dans `SnapImage`, sous enveloppe `Color.clear.overlay(…).clipped()`. |
| Clés de dictionnaire dupliquées | `DonneesSnap.filsInitiaux` : 12 clés uniques, contrôlées. |
| Doublons de noms de types | 43 types, tous préfixés `Snap`/`DonneesSnap`, **0 collision** avec `LPProto.swift`, `MessengerApp.swift`, `InstagramApp.swift`, `NotesApp.swift`, `parts/fb_01..08.swift` ni avec les composants partagés (`BarreHome`, `Haptique`, `ChargeurPhoto`, `VisualiseurContenuVue`…). |
| `Color(hex:)` non entier | Toutes les valeurs sont des littéraux `0xRRGGBB` ou des constantes ; `extension Color` **non redéclarée** (elle vit dans `LPProto.swift`). |
| `ForEach` sans `id:` | Contrôlé ligne à ligne : soit `id:`, soit `.enumerated()`, soit une collection `Identifiable` du fichier. |
| API iOS 18+ | Aucune. Le plafond utilisé est iOS 17 (`Map(position:)`, `MapCameraPosition`, `.mapStyle`, `scrollTargetLayout`, `scrollTargetBehavior(.paging)`, `onChange(of:) { _, _ in }`). |
| `@Published` hors `ObservableObject` | Le seul `@Published` est dans `final class SnapEtat: ObservableObject`. |
| Vues trop longues / expressions géantes | Chaque écran est découpé en propriétés et fonctions calculées (5 à 15 par vue) ; aucune expression de plus de ~6 modificateurs enchaînés. |
| Init mémberwise cassé par un `@State` sans valeur | `SnapchatVue` a un **`init(onglet: Int? = nil)` explicite** ; `SnapchatVue()` continue de compiler pour la coque et l'accueil. |
| `BarreHome` masquée | Contrôlée automatiquement sur les 10 vues plein écran + la barre d'onglets. |

---

## 5. À faire côté dépôt (hors de cette livraison)

1. Copier `/agent/workspace/src/SnapchatApp.swift` vers `proto-swift/Sources/SnapchatApp.swift`.
2. Appliquer le corps de `ecransSnapchat()` de `patches/snapchat-lpproto.md` (≈ ligne 167 de `LPProto.swift`). **Aucune autre ligne de `LPProto.swift` ne change.**
3. Ajouter les 15 clés de `patches/snapchat-ecrans.txt` à `outils/ecrans.txt`.
4. Vérifier que `VisualiseurContenuVue` reste utilisé par Instagram/Facebook (il n'est plus référencé par Snapchat).
