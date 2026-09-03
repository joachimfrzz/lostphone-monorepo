# Messenger — lot 280 (v3.1 D92, 03/09 soir)

Fichier livré : `src/MessengerApp.swift` (4 346 lignes, en-tête « v3.1 D92 (03/09 soir) — retours 279 de Joachim : simplification + cohérence »).
Patch registre : `src/patches/messenger-lpproto-v31.md` + `src/patches/messenger-ecrans.txt`.
Vérificateur : `src/verif_msgr.py` (0 erreur).
`LPProto.swift` et les trois autres apps sociales **n'ont pas été touchés**.

---

## 1. Points du cahier des charges traités

### Conversation (privée ou groupe)
- ✔ **Dictaphone / message vocal RETIRÉ** de la barre de saisie : bouton micro, appui-long
  d'enregistrement, indice « Maintenez le micro… », `envoyerVocal()` et les paramètres
  `vocal:` / `indiceMicro:` de `MsgrBarreSaisie` sont supprimés.
- ✔ **Bouton « + » RETIRÉ** : rond bleu, `ouvrirPlus:`, l'état `menuPlus` et le
  `confirmationDialog` « Ajouter à la discussion » (`boutonsMenuPlus`) sont supprimés.
- La barre ne contient plus que : appareil photo · pellicule · champ « Aa » + emojis · pouce/envoi.

### Profil / informations d'une conversation
- ✔ Rond **« Ajouter » RETIRÉ** ; le « + » d'ajout de membre de l'écran Membres aussi
  (il renvoyait vers un rond qui n'existe plus).
- ✔ **Pseudos** et **Rechercher** conservés (les deux ronds restants).
- ✔ **« Personnaliser » RETIRÉ** : il ouvrait « Personnalisation indisponible » → non fonctionnel,
  donc retiré comme demandé (cas `.personnaliser` supprimé de `MsgrDestinationFiche`).
- ✔ **Contenu multimédia conservé**, mais **« Créer des albums pour cette discussion » RETIRÉ**
  et **l'option de partage RETIRÉE** (bouton « Sélectionner » + pilule-filtre « Partagé par »,
  toutes deux sans effet). Pilules **Photos / Vidéos conservées**.
- ✔ **« Créer une nouvelle discussion de groupe » RETIRÉ** (ligne, écran `MsgrNouveauGroupeVue`
  et méthode `MessengerStore.creerGroupe` supprimés).
- ✔ **« Paramètres des moments » RETIRÉ**.
- ✔ **« Modifier le nom ou l'image » RETIRÉ**.
- ✔ Messages épinglés / Confirmation de lecture / Indicateur de saisie : inchangés.
- ✔ Feuille d'action d'un membre : **« Message » RETIRÉ** (il affichait « Discussion ouverte
  depuis la liste. » sans rien ouvrir). Restent « Voir le profil Facebook » et « Bloquer ».

### Stories (viewer)
- ✔ **3 points et bouton son RETIRÉS** de l'en-tête de `MsgrVisionneuseStoryVue`.

### Facebook ↔ Messenger
- ✔ « Voir le profil Facebook » appelle désormais `Routeur.partage.allerFacebook(profil: nomAffiché)`
  aux deux endroits : feuille d'action d'un membre (`MsgrMembresVue`) et fiche de suggestion
  (`MsgrProfilSuggestionVue`, atteinte depuis les notifications).
  Le nom transmis est le nom Facebook exact affiché (ex. « Vincent Berthier »).
- ✔ Le logo « f » de l'en-tête Discussions garde `allerFacebook()` (sans profil).
- ⚠️ **À faire côté Facebook** (autre lot) : consommer `Routeur.partage.consommerProfilFacebook()`
  à l'apparition de `FacebookVue` et ouvrir réellement ce profil.

### Menu
- ✔ **« Changer de profil » RETIRÉ** (la carte n'affiche plus que « Sarah Levasseur »).
- ✔ **Paramètres conservé.**
- ✔ **Communautés RETIRÉ** : ligne, cas `.communautes` et écran `MsgrCommunautesVue` supprimés.
- ✔ **« Voir tout » (invitations) et « Voir plus » (suggestions) FONCTIONNENT** :
  nouvel écran `MsgrListeCompleteVue(genre:)` (plein écran, état local) qui liste
  **toutes** les invitations / **toutes** les suggestions, chaque rangée portant des boutons
  réels (Confirmer / Supprimer pour les invitations, Ajouter comme ami(e) / Supprimer pour
  les suggestions). Rangées factorisées en `MsgrRangeeInvitation` / `MsgrRangeeSuggestion`
  pour éviter la divergence entre l'écran résumé et la liste complète.

---

## 2. Contrats inter-apps (D92)

- ✔ `MessengerStore.recevoirPartagePost(titre:sousTitre:imageCle:destinataire:)` — signature
  publique exacte. Elle trouve (ou crée) la conversation dont le `nom == destinataire`,
  y ajoute un message **envoyé** `.postPartage`, et met l'aperçu de la liste à
  **« Vous : a partagé une publication »**.
- ✔ Nouveau cas de modèle `MsgrContenu.postPartage(titre:sousTitre:imageCle:)` + carte
  `MsgrBullePost` : image via `ChargeurPhoto.image(imageCle)` (omise si `imageCle` est vide),
  titre en gras, sous-titre gris, petit libellé « facebook.com ». Carte **non tapable**
  (option « rien » du cahier des charges) : pas de faux écran de publication.
- ✔ `MessengerVue` observe `Routeur.partage` (`@ObservedObject private var routeur`) et consomme
  `consommerConversationMessenger()` **à l'apparition** (`.onAppear`) **et à chaque changement**
  de `routeur.demande` (`.onChange(of: routeur.demande)`) ; si un nom est présent, l'onglet passe
  à Discussions et la conversation s'ouvre en plein écran. Même motif que `LPProto.swift` l. 1035/1297.

Appel attendu côté Facebook :
```swift
MessengerStore.partage.recevoirPartagePost(titre: …, sousTitre: …, imageCle: …, destinataire: "Chloé Berthier")
Routeur.partage.allerMessenger(conversation: "Chloé Berthier")
```

---

## 3. Autres points de cohérence D92

- ✔ **Compteurs = contenu accessible** : `store.invitationsEnAttente` et
  `store.suggestionsVisibles` filtrent les personnes déjà traitées ; le titre affiche
  « Invitations (N) » avec le N réel, et la liste complète affiche « N personnes ».
  Confirmer/Supprimer/Ajouter font disparaître la personne **partout** (écran Invitations,
  liste complète, onglet Notifications) — avant, « Supprimer » sur une suggestion ne
  faisait rien de visible.
- ✔ Le jeu de données a été étendu pour que les listes complètes aient un sens :
  6 invitations (3 mises en avant) et 8 suggestions (4 mises en avant).
- ✔ Contenu multimédia : « Tous les contenus multimédias (N) » = nombre réellement affiché ;
  les états vides disent la vérité (« Aucune vidéo n'a été échangée… ») au lieu du
  « Réinitialisez ou ajustez vos filtres » trompeur.
- ✔ **Aucune feuille/alerte globale** : tous les messages (`indice`, `confirmation`,
  `listeComplete`, `apercu`…) sont des `@State` locaux à leur écran, détruits à la fermeture.
  Aucun état de type « message d'erreur » n'est stocké dans `MessengerStore`.

---

## 4. Éléments retirés qui pourraient servir plus tard — à valider par Joachim

1. **Partage de position** (`MsgrContenu.localisation`) : le menu « + » était le seul moyen
   d'en envoyer une. Le cas de modèle et la carte `MsgrBulleLocalisation` sont **conservés**
   (le fil de Julie Ferrand affiche toujours l'adresse du cabinet), mais Sarah ne peut plus
   en envoyer. Utile si une histoire demande « Sarah a partagé sa position à 21 h ».
2. **Autocollants** (`MsgrContenu.autocollant`) : idem, plus envoyables depuis l'interface.
3. **Message vocal envoyé** : le composeur ne peut plus en produire. En revanche le
   **message vocal reçu d'Inès Djellal** (0:25, groupe « Les filles ») est **conservé** :
   c'est du contenu, pas une commande, et un vocal reçu peut porter un indice sonore.
   Dis-moi si tu veux qu'on le retire aussi.
4. **Communautés** : l'écran et ses deux communautés (« Kinés de Lyon »,
   « Vide-dressing Lyon 3 ») sont supprimés. Le vide-dressing pouvait servir de piste
   « Sarah revend ses affaires » — récupérable en une dizaine de lignes si besoin.
5. **Création de groupe** : Sarah ne peut plus créer de groupe depuis la fiche.
   Si une histoire a besoin d'un groupe créé en cours de partie, il faudra le remettre.
6. **« Personnaliser » (thème de conversation)** : retiré parce que non fonctionnel. Le moteur
   de thème existe toujours (`MsgrConversation.theme`, fil « Idée cadeau papa » violet) —
   seul le réglage utilisateur a disparu.
7. **Badge rouge « 8 » sur le logo Facebook** de l'en-tête Discussions : **conservé**. Ce n'est
   pas un compteur Messenger mais le badge de l'app Facebook, qui a de vraies notifications.
   À retirer si tu préfères l'appliquer strictement.

---

## 5. Risques de compilation évités (Codemagic, Xcode 26, iOS 17+)

- `MsgrContenu` gagne un cas : les **quatre** `switch` exhaustifs
  (`texteBrut`, `MessengerStore.resume`, `MsgrRangeeMessage.contenu`) ont été complétés ;
  le vérificateur contrôle l'exhaustivité automatiquement.
- **Aucun `navigationDestination` ajouté** : les listes complètes passent par
  `.fullScreenCover(item:)`, donc toujours **une seule** `navigationDestination` par
  `NavigationStack` (fiche de discussion, menu).
- **Aucun `.background(Color…, in:)`** ; toutes les formes passent par
  `RoundedRectangle(...).fill(...)` / `Capsule().fill(...)`.
- **Aucun `.scaledToFill()` nu** : `MsgrBullePost` utilise le motif imposé
  `Color.clear → .overlay(image) → .clipShape(...)`.
- **Ternaires de style typés** : le seul nouveau (`elements`) porte sur deux `[MsgrSuggestion]` ;
  aucun `cond ? .a : .b` dans un modificateur de couleur/forme.
- **Pas de doublon de nom de type** : les 83 types de portée globale du fichier sont préfixés
  `Msgr` (sauf `MessengerVue` / `MessengerStore`) et ne collisionnent avec aucun type de
  `LPProto.swift`, `InstagramApp.swift`, `SnapchatApp.swift`, `FacebookApp.swift`, `NotesApp.swift`.
- **Pas de clé de dictionnaire dupliquée** dans `filsInitiaux()` (8 clés uniques, inchangées).
- **Pas d'API iOS 18+/26** (`onScrollGeometryChange`, `glassEffect`, `@Entry`, `MeshGradient`… absents) ;
  `onChange` reste en signature iOS 17 à deux paramètres.
- **Vues courtes** : les nouveaux écrans sont découpés en propriétés `@ViewBuilder`
  (`sectionInvitations`, `sectionSuggestions`, `liste`, `visuel`, `texte`) — aucune expression géante.
- `ForEach` : sources `Identifiable` (`[MsgrSuggestion]`, `[MsgrConversation]`) ou `id:` explicite.
- Équilibre des accolades/parenthèses/crochets vérifié, profondeur nulle avant chaque
  déclaration de portée globale, un seul `var body: some View` par vue.

## 6. Registre de captures

Deux clés supprimées (`messenger.communautes`, `messenger.menuplus` — cette dernière était
un doublon exact de `messenger#3`), deux ajoutées (`messenger.invitationstout`,
`messenger.suggestionstout`). Corps exact de `ecransMessenger()` dans
`src/patches/messenger-lpproto-v31.md`.
