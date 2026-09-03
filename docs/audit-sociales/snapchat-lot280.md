# Snapchat — lot 280 (v3.1 D92, 03/09/2026 soir)

Fichier livré : `src/SnapchatApp.swift` (2 606 lignes, en-tête « v3.1 D92 (03/09 soir) — simplification, retours 279 »).
Patch registre : `src/patches/snapchat-lpproto-v31.md` (corps de `ecransSnapchat()` uniquement) + `src/patches/snapchat-ecrans.txt` (20 clés).
Vérificateur : `src/verif_snap.py` — **0 erreur**, 1 avertissement inoffensif (le nombre `108` d'une taille d'avatar).
`LPProto.swift` et les trois autres apps sociales **n'ont pas été touchés**. Rien n'a été poussé.

Structure retenue : 5 onglets (Carte · Chat · Caméra · Stories · Spotlight) + 13 écrans secondaires,
un seul état partagé `SnapEtat` (`@Published`), 49 types tous préfixés `Snap`/`DonneesSnap`.

---

## 1. Points du cahier des charges (retours-279.md §4) traités

### Carte (Snap Map)
- ✔ **Souvenirs, Tendances, Footsteps, Visité RETIRÉS** (les 4 chips à icônes), ainsi que la
  **pilule « 3,8 % exploré(s) »** et son empreinte : plus aucune donnée de stockage/exploration.
- ✔ **Affichage des personnages simplifié** : plus de Bitmoji corps entier (`SnapSilhouette`), plus de
  vue 3D (`SnapCarte3DVue`), plus de POI colorés à sous-titre. **Un seul rendu par ami·e** :
  avatar rond 44 pt à liseré blanc + capsule du prénom (`SnapCarteVue.epingle`).
- ✔ **Tap = recentrer + petite fiche** (`centrerSur(_:)` puis `SnapFicheAmiVue`), et cela vaut pour
  **TOUS** les ami·es : les épingles **et** la rangée du bas parcourent la même source
  `etat.amisSurCarte` (= `amisReels`, groupes et comptes système exclus). Plus d'ami·e « qui ne recentre pas ».
- ✔ Colonne droite réduite à **un seul bouton** (recentrer sur moi). Bitmoji, engrenage et calques retirés.
- ✔ La pilule de lieu (`Lyon 7e` · `24 °C`) reste un **libellé**, non tapable — donc non menteur.

### Discussions
- ✔ **Petits appareils photo RETIRÉS de la liste** : `SnapLigneChat` n'a plus d'accessoire de fin de
  ligne (ni caméra, ni variante `×`). Contrôlé automatiquement (aucun « camera » dans ce type).
- ✔ **Appel audio et appel vidéo distincts et fonctionnels** : `SnapAppelAudioVue` (fond dégradé,
  avatar 132 pt, « Sonnerie… » → « Pas de réponse » après 7 s, raccrocher) et `SnapAppelVideoVue`
  (viseur, carte du correspondant, retourner + raccrocher). Présentés par un **point de présentation
  unique** (`SnapPleinConversation`), jamais deux `fullScreenCover` empilés.
- ✔ **Ouvrir le profil de l'interlocuteur marche** : avatar **et** nom de l'en-tête ouvrent
  `SnapFicheAmiVue` (Snapscore, ami·es depuis, position, bouton « Voir sur la Snap Map »).
- ✔ **Message audio RETIRÉ** (forme d'onde du champ + méthode d'envoi vocal).
- ✔ **Bouton aux deux carrés (autocollants) et jeux (manette) RETIRÉS.**
- ✔ **Composeur = caméra + champ + emoji**, rien d'autre (`SnapComposeur`, 3 commandes).
- ✔ **Caméra de conversation simple** : viseur gris diégétique, fermer, retourner, déclencheur ; la
  capture part **réellement** dans le fil (`envoyerSnap`, passage `Envoi… → Remis`).
- ✔ Emoji : conservé (ajoute ` 🙂` dans le champ).

### Mon profil
- ✔ **Avatar visible** : `SnapAvatarMoi` (photo `p04`, repli émoji sur aplat pastel), 118 pt, liseré blanc.
- ✔ **Aucune modification de profil** : ni crayon, ni modale « Utiliser la photo de vos contacts ? »,
  ni capsules « Mon compte / Profil public ». La seule commande de l'en-tête est le retour.
- ✔ **RETIRÉS** : Snapchat+, « Publier sur… Spotlight », Snapcode / pilule « Partager », engrenage de
  réglages, chip « Rejoindre l'établissement scolaire », chip astro, et le chip
  **« 📍 28 juil. » (anniversaire d'amitié avec Chloé)** jugé incompréhensible.
- ✔ Aucun libellé « Lyon », « café trop cher », « bistrot long ».
- ✔ **Compteurs = listes réelles** : « Mes amis·es » vaut `etat.amisReels.count` (10) et ouvre ces
  10 lignes ; « Meilleurs amis » vaut `etat.meilleursAmis.count` (3) et ouvre ces 3 lignes ;
  « Ajouter des amis·es » porte le badge bleu `etat.demandes.count` (3) ; « Ma Story » = 1 story ouvrable.
- ✔ Pseudo `sarah.lvsr`, Snapscore `3 402` — cohérent avec Instagram / Facebook / Messenger (D59).

### Amis
- ✔ **Accepter une demande met l'état à jour PARTOUT** : `SnapEtat.accepter(_:)` retire la demande,
  insère l'ami·e en tête de la liste Chat, crée son fil de conversation et le place sur la carte.
  Le badge de l'en-tête et le compteur du Profil lisent la même source → plus de « une demande
  d'ami » fantôme au retour. Refuser retire aussi réellement la demande.
- ✔ **Le nombre annoncé est le vrai nombre** : titre « Mes amis·es · N » calculé sur la liste
  affichée (fini « 132 amis » pour 10 lignes ; le badge « 47 » devient 3 demandes réelles).
- ✔ **Meilleurs amis cohérents** : 3 annoncés, 3 affichés (Chloé, Inès, Camille).

### Appareil photo
- ✔ **Radicalement simplifié** : viseur + anneau de déclenchement 85 pt + **2 outils seulement**
  (retourner, flash — tous deux à effet visible). **RETIRÉS** : mode nuit (lune), note de musique,
  « mode », chevron d'outils, `AI`, `Souvenirs`, carrousel de Lenses, onglets de Lenses, manette,
  glyphe ⤢, écran d'édition (texte/dessin/minuteur). La capture ouvre « Envoyer à… », qui envoie
  **vraiment** le Snap aux conversations cochées.

### Doctrines transversales
- ✔ **D82 / aucun bouton mort** : le fichier ne contient **aucun `.alert(` ni `confirmationDialog`**
  (donc aucun message d'erreur ne peut survivre à un écran, contrairement au bug Facebook/Instagram).
  Toute commande restante a une destination ou change un état persistant.
- ✔ **Point rouge du Bitmoji corrigé** : il était permanent (donc menteur). La pastille est passée sur
  **la cloche**, alimentée par `etat.notifsLues`, et **s'efface** dès que l'écran Notifications est ouvert.
- ✔ **Badge de l'onglet Stories** = `storiesNonVues`, il décroît réellement à chaque story regardée.
- ✔ Filtres du Chat : « Groupes » (2), « Près de moi » (2), « Meilleurs·es amis·es » (3) filtrent
  vraiment ; « My AI » **ouvre** la conversation My AI au lieu de faire semblant de filtrer.
- ✔ Notifications : chaque ligne ouvre la conversation concernée.
- ✔ **Aucune donnée réelle de Joachim** : ni 741/108/49/143, ni `dribble97tk` ; ami·es, fils, stories,
  cartes Découvrir, Spotlight et coordonnées (Lyon et alentours) sont inventés (D59).

---

## 2. Éléments retirés qui pourraient servir aux histoires — **à trancher, Joachim**

Ils sont supprimés du code (D92), mais réintroductibles ; ils sont listés ici parce qu'ils ont
un potentiel narratif réel, contrairement au reste des retraits (Lenses, jeux, tuiles sponsorisées,
bouton d'abonnement « OO », ampoule Lens, boucles, vignette musicale, chip astro, Snapchat+…).

| Élément retiré | Pourquoi il pourrait servir |
|---|---|
| **Souvenirs** (archive de Snaps) | Une réserve de photos anciennes = pièce à conviction idéale (retrouver un Snap daté, une personne, un lieu). C'est le retrait le plus lourd narrativement. |
| **Historique d'exploration de la carte** (Footsteps / Visité / « % exploré ») | « Où cette personne est-elle allée » est un ressort d'enquête direct. Aujourd'hui la carte ne montre que des positions **actuelles**. |
| **Anniversaire d'amitié « 28 juil. » avec Chloé** | Incompréhensible tel quel, mais une **date** liant Sarah à une amie peut servir de repère chronologique. Réintroductible sous un libellé explicite (« Ami·es depuis le 28 juillet 2019 »), la fiche d'ami·e portant déjà « Amis depuis ». |
| **Réglages Snapchat** (écran `snapchat.reglages`, supprimé du registre) | Un écran de compte (appareils connectés, « Mes données », numéro/mail associés) est un lieu d'indices classique. |
| **Répondre à une Story** depuis la visionneuse | Instagram garde « Envoyer un message » depuis une story ; ici la visionneuse est purement passive (progression, auteur, contenu, fermer). |
| **Commentaires Spotlight** (bulle + compteur) | Un fil de commentaires publics peut porter un indice ou un pseudo. Le rail ne garde que le cœur. |
| **Appui long sur une conversation** (épingler / supprimer) | Supprimer une conversation peut être un geste d'intrigue (effacer des traces). |
| **Snapcode / « Partager le profil »** | Un Snapcode photographié ailleurs (Photos, Notes) pourrait être une passerelle inter-apps. |
| **Édition d'un Snap avant envoi** (texte, dessin, minuteur) | Permettrait à la joueuse d'écrire un message sur une photo — utile si une histoire demande d'envoyer une preuve annotée. |
| **47 demandes d'ami·e** (ramenées à 3 réelles) | Un grand nombre de demandes racontait quelque chose (notoriété, harcèlement). Le nombre est désormais vrai mais petit ; il suffit d'ajouter des entrées à `DonneesSnap.demandesInitiales` pour le remonter **en restant honnête**. |

---

## 3. Risques évités (relecture + `src/verif_snap.py`)

**Compilation** (pas de compilateur local : 19 contrôles statiques, chacun validé par un test négatif
qui injecte volontairement la faute pour vérifier que le contrôle la détecte) :
- Équilibrage `{} () []` et chaînes fermées (analyse après dénudage des commentaires, chaînes et interpolations).
- **Aucun doublon de type** interne et **aucune collision** avec `LPProto.swift`, `MessengerApp.swift`,
  `InstagramApp.swift`, `FacebookApp.swift`, `NotesApp.swift` (tous les types sont préfixés `Snap`).
- Chaque `struct X: View` possède un `var body` ; `@Published` uniquement dans `SnapEtat: ObservableObject`.
- `ForEach` : `id:` sur les plages, collections d'éléments `Identifiable` ailleurs ; aucune clé `id:` dupliquée.
- `Color(hex:)` toujours avec un **entier** (jamais de chaîne : l'init du projet n'accepte qu'un `UInt`).
- **Ternaires de style typés** (`cond ? Color.a : Color.b`) ; les 3 raccourcis restants ont été typés
  par prudence (`Font.Weight.semibold`, `ColorScheme.light`).
- **Aucune API iOS 18+** (`Tab(`, `@Entry`, `onScrollGeometryChange`, `navigationTransition`, `.zoom(`,
  `MeshGradient`, `ScrollPosition`…). MapKit reste sur les API iOS 17 (`Map(position:)`, `Annotation`,
  `MapCameraPosition`, `mapStyle(.standard(pointsOfInterest:))`), **sans position réelle de l'utilisateur**
  (pas d'autorisation de localisation demandée au lancement).
- `scaledToFill()` seulement dans le gabarit `Color.clear.overlay(Image…).clipped()` (`SnapAvatar`, `SnapImage`).
- Aucun `.background(Color…, in:)` ambigu ; aucun `NavigationStack` ni `navigationDestination` dans le fichier.
- `switch filtre ?? ""` : on ne fait plus filtrer un `String?` par des motifs littéraux.
- Énumérations de navigation : chaque `route = .x` / `plein = .x` existe, et `SnapRouteVue` (8 cas) comme
  `contenuPlein` (3 cas) sont **exhaustifs**.
- Ordre de l'init mémberwise respecté : le nouveau paramètre `notifsNonLues` de `SnapEnTete` est
  déclaré **après** `demandes` et passé dans cet ordre par les 4 appels.

**Registre / captures** :
- `SnapchatVue` garde `init(onglet: Int? = nil)` : `SnapchatVue().coquilleSarah()` (LPProto L1293)
  et `SnapchatVue(onglet: 2/4)` compilent tous les deux.
- Les 15 cas de `ecransSnapchat()` n'instancient que des types existants, avec les **bons labels**
  (vérifié en comparant chaque appel à l'init mémberwise réel de la vue).
- La clé **`snapchat.reglages` est supprimée** : laissée en place, elle aurait référencé
  `SnapRoute.reglages`, un cas qui n'existe plus → **erreur de compilation**.
- `src/patches/snapchat-ecrans.txt` contient **exactement** les 15 clés du registre + `snapchat#0..4`.
- `ecrans-sociales.txt` (liste de captures partagée) a été recalé sur ces 20 clés — les autres apps
  n'ont pas été touchées. Sinon la capture `snapchat.reglages` serait retombée silencieusement sur
  l'accueil Chat, et 5 écrans neufs (appels, fiche, amis, demandes, notifications) n'auraient jamais été photographiés.

**UX / bug de navigation du lot 279** :
- **`BarreHome` présente sur les 15 écrans pleins** (barre d'onglets pour la coque, `BarreHome(...)`
  explicite dans chaque écran secondaire, feuilles comprises) — contrôle automatisé. C'est la cause du
  bug Facebook (sortie vers l'accueil du vrai iPhone) : aucun écran Snapchat n'en est dépourvu.
- Aucun état d'écran promu en global : les seuls `@Published` partagés sont des **données**
  (ami·es, fils, demandes, stories vues, cœurs, cible de carte, notifications lues), jamais un
  message d'erreur ni une feuille ouverte.
- Le recentrage inter-écrans (`demanderCarte`) est **consommé** par la carte (`cibleCarte` remis à `nil`),
  donc la carte ne se recentre pas indéfiniment sur le même ami·e.

---

## 4. Reste à faire / non traité

- « La liste ne ressemble pas assez au vrai Snapchat » : les mesures d'e003/e005 sont respectées
  (pas de 60 pt, avatar 45 pt, pictogrammes de statut, filtres en texte nu, FAB jaune), mais la
  ressemblance devra être rejugée **sur capture** du lot 280.
- MapKit sans réseau sur le CI peut rendre un fond de carte pauvre : les avatars, la teinte verte et
  la pilule de lieu restent lisibles, à confirmer sur la capture `snapchat#0`.
- Thème sombre global de Snapchat : toujours non filmé, toujours non implémenté.
