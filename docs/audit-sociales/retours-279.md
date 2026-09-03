# Retours de Joachim sur le build 279 — 03/09/2026 17h38 (cahier des charges du lot 280)

## D92 — Doctrine « juste milieu » (décision Joachim, 03/09)
- Les 4 sociales doivent donner l'impression d'être de vraies apps et permettre d'explorer ce qui sert à une histoire, SANS reconstruire 100 % de Facebook / Instagram / Messenger / Snapchat.
- **Moins de fonctionnalités mais une expérience cohérente**, plutôt que beaucoup de boutons/menus dont une partie ne marche pas ou n'aura jamais d'intérêt dans le jeu.
- Toute affordance affichée doit avoir une conséquence réelle et cohérente (compteurs = contenu réellement accessible ; une action = un état qui change et persiste ; une navigation = la bonne destination). Sinon on la RETIRE (D82-C).
- Pas d'usine à gaz pour une petite interaction : préférer une représentation simple (ex. carte de post partagé dans une conversation) à une fonctionnalité complète.
- Si un élément demandé en suppression pourrait avoir une utilité importante pour les histoires/gameplay, le signaler à Joachim au lieu de le supprimer silencieusement.
- Un message d'erreur/une feuille ne doit JAMAIS rester affiché après avoir quitté l'écran (état local à l'écran, pas global).

---

## 1. Messenger — « plutôt pas mal » : simplifier et corriger des interactions
**Conversation (privée ou groupe)**
- RETIRER le dictaphone / message vocal.
- RETIRER le bouton + (doublon des photos/images).

**Profil / informations d'une conversation** (juste milieu : trop d'options non utilisables = app inachevée)
- Ajouter : RETIRER. Pseudo : garder. Rechercher : garder. Personnaliser : à trancher (retirer si non fonctionnel).
- Contenu multimédia : garder. « Créer des albums pour cette discussion » : RETIRER. Option de partage à cet endroit : RETIRER. Photos/Vidéos : garder.
- « Créer une nouvelle discussion (de groupe) » : RETIRER. « Paramètres des moments » : RETIRER. Messages épinglés : garder. Confirmation de lecture : OK. Indicateur de saisie : OK. « Modifier le nom ou l'image » : RETIRER. Le reste : bon.

**Stories (viewer)** : RETIRER les 3 points en haut à droite et le bouton son.

**Facebook ↔ Messenger**
- Notifications : bien. « Ajouter comme ami » fonctionne. « Voir le profil Facebook » ouvre Facebook : très bien — MAIS Facebook doit alors afficher RÉELLEMENT le profil de la personne concernée (cohérence Messenger → Facebook).

**Menu**
- « Changer de profil » : RETIRER. Paramètres : garder pour l'instant. Communautés : RETIRER.
- Invitations : la distinction Invitations / Vous connaissez peut-être est bien. « Voir tout » (invitations) et « Voir plus » (vous connaissez peut-être) ne fonctionnent pas → les faire fonctionner (listes complètes) ou les retirer.

## 2. Facebook — « davantage de corrections »
**BUG DE NAVIGATION IMPORTANT** : la barre home du faux téléphone est confondue avec la vraie barre système de l'iPhone → en voulant revenir au menu de Lost Phone, Joachim sort sur l'accueil de son VRAI iPhone. À corriger en priorité (comparer avec les apps claires validées : Mail, Téléphone, Notes… qui n'ont pas ce problème ; vérifier `.persistentSystemOverlays(.hidden)` / `.defersSystemGestures(on: .bottom)` / la présence et la position de `BarreHome` sur TOUS les écrans Facebook, y compris détail, Reels, tiroir, feuilles).

**Accueil / publications**
- « Quoi de neuf ? » et l'ajout d'une publication ne fonctionnent pas. Juste milieu : quelque chose de simple et cohérent (ex. composer minimal → le post apparaît en tête du fil et dans « N publications » du profil), OU retirer. Pas de fonctionnalités complexes de gestion de publications. UX crédible et fidèle à Facebook.

**Stories / suggestions**
- Story suggérée → tap sur le profil de la personne : rien ne se passe → doit ouvrir le profil.
- Sur ces stories : RETIRER la flèche vers le bas, les 3 points, le bouton Suivre avec le petit dossier.

**Publications / commentaires**
- Publications : bien. COHÉRENCE des commentaires : « 36 commentaires » mais 4 visibles → le compteur doit être égal au nombre réellement affiché (ou les commentaires réellement présents).
- « Voir les 2 réponses » → « Les réponses de ce fil ne sont pas disponibles hors connexion » : INACCEPTABLE. Les réponses annoncées doivent être visibles. Et ce message reste affiché PARTOUT dans Facebook ensuite (bug d'état global) → à supprimer.

**Partage vers Messenger**
- Partager une publication à quelqu'un sur Messenger doit la faire apparaître RÉELLEMENT dans la conversation Messenger — représentation simple (carte du post / faux lien), pas d'usine à gaz.

**Reels**
- Cohérence : seulement 2 reels ; « 65 commentaires » alors qu'il n'y en a pas 65 accessibles ; réponses aux commentaires inaccessibles ; tap sur l'auteur du reel → doit ouvrir son profil.

**Groupes** : impossible de réellement rejoindre un groupe ; le groupe rejoint n'est ensuite pas visible → Rejoindre doit basculer ET le groupe doit apparaître dans « Vos groupes ». (Page Amis : bonne. Notifications : bon.)

**Profil de Sarah** — RETIRER : le stylo « modifier le profil », la petite croix, les 3 points, la flèche à côté de « Sarah Levasseur », l'autre flèche grise, « Créer en direct », « Gérer les publications ».
- Tap « 5 amis » → voir les 5 amis. Tap « 3 publications » → voir les 3 publications.
- Profil d'une autre personne : la flèche Retour ne fonctionne pas → corriger.

## 3. Instagram — « déjà plutôt bien visuellement (stories) », cohérence et interactions à revoir
**Accueil**
- Stories : bien affichées maintenant.
- RETIRER les deux petits traits (≡) en haut à droite des publications.
- Partager : pas fidèle visuellement et ne marche pas. Juste milieu : partager un post peut servir aux histoires → soit une version simple qui marche (le post apparaît dans la DM du destinataire), soit retirer. « Republier dans votre story » : RETIRER.
- Prévoir que des publications puissent être des VIDÉOS plus tard (structure de données).
- Sélecteur Pour vous / Suivi(e)s / Favoris : ne change rien → le faire filtrer réellement ou le retirer.

**Liens** : le lien dans une bio doit ouvrir réellement la page (Safari du jeu via Routeur.allerSafari ou une vue web interne), sinon retirer.

**Création de contenu** (publication / story / reel / message) : juste milieu. Ce qui est présenté comme disponible doit avoir une conséquence visible (ce qui est créé se retrouve sur le profil / dans la liste), sinon retirer. Ne pas construire tout Instagram.

**Reels** : Pour vous / Amis ne change rien ; RETIRER les deux traits ; bouton Partager étrange ; RETIRER « Republier dans ma story ».

**Messages**
- Vraiment pas mal. Ouvrir une conversation doit arriver directement sur le DERNIER message (scroll en bas).
- Appui long → réaction (comme Messenger).
- Appel audio et appel vidéo : doivent fonctionner (écrans d'appel comme Messenger/WhatsApp).
- Barre de message : RETIRER message vocal, emoji, bouton +.
- Envoyer un message : la liste des conversations doit montrer le dernier message mis à jour.
- BUG : après le bouton de message vocal, son interface reste affichée PARTOUT dans Instagram → supprimer (et retirer le vocal).
- Bouton « nouveau message » ne fonctionne pas → faire fonctionner simplement ou retirer.

**Recherche** : plutôt bien ; les publications de la mosaïque doivent être CLIQUABLES (→ détail) ; RETIRER le bouton à deux barres.

**Profil / menu ≡** : garder Paramètres, Enregistrements, Archives. RETIRER Votre activité, Code QR, Amis proches.

**Profils (Sarah et tous les autres)**
- Tap « N followers » → liste des followers ; tap « N suivis » → liste des suivis (IMPORTANT pour enquêter dans les relations).
- « Modifier le profil » et « Partager le profil » ne marchent pas → simple et cohérent, ou retirer. RETIRER le bouton « personne + ».
- Stories à la une : bien. Publications : bien. Confusion Republications / Reels → ne garder que 2 onglets : publications, et publications où la personne est identifiée.

**Stories / stories à la une (viewer)** : RETIRER caméra, like, commentaire. Partage ne marche pas → simple ou retirer. Le bouton à deux traits peut rester s'il a une vraie fonction, sinon retirer. « Envoyer un message » reste (intéressant) mais le message envoyé depuis une story doit intégrer la story dans la DM, comme le vrai Instagram.

## 4. Snapchat — « le plus gros problème de conception : beaucoup trop de choses », à SIMPLIFIER et revoir l'ensemble
**Carte** : RETIRER Souvenirs, Tendances, Footsteps, l'indication « 3,8 % de stockage ». Affichage des personnages bizarre (Memoji + élément étrange dessous, tap qui affiche une autre personne, histoire de 3D) → pas naturel : simplifier (un avatar par ami, tap = recentrer + petite fiche). La fonction « voir où sont les amis » est intéressante mais doit marcher pour TOUS (certains ne recentrent pas).

**Discussions** : RETIRER les petits appareils photo dans la liste. La liste ne ressemble pas assez au vrai Snapchat (→ frames de référence, e0xx Chat). Dans une conversation : appel audio et vidéo doivent fonctionner ; ouvrir le profil de l'interlocuteur doit marcher ; RETIRER message audio ; caméra : garder simple (viseur sur fond gris) ; emoji : OK ; RETIRER le bouton aux deux carrés ; RETIRER jeux.

**Mon profil** : bizarre ; l'avatar ne s'affiche pas correctement ; pas besoin de pouvoir modifier le profil (complexité pour rien). « 28 juillet » → « Anniversaire de l'amitié avec Chloé » incompréhensible → retirer. RETIRER : Rejoins l'établissement scolaire, Snapchat+, Spotlight, Anniversaire, Snapcode. Éléments incompréhensibles « Lyon », « café trop cher », « bistrot long » → retirer.

**Amis** : accepter une demande d'ami puis revenir → l'app affiche encore « une demande d'ami » → état à mettre à jour. « 132 amis » → on doit voir les 132 (ou afficher le vrai nombre). Meilleurs amis : contenu cohérent avec l'annonce.

**Appareil photo** : beaucoup trop chargé (mode nuit, etc.) → SIMPLIFIER radicalement : viseur + déclencheur + retourner + quelques éléments visibles fidèles au vrai, rien qui ne serve.

**Règle Snapchat** : plus encore que les autres, revoir et simplifier l'ensemble ; signaler à Joachim tout élément supprimé qui pourrait servir plus tard.
