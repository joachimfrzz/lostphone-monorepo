# App Store v1 D92 — livraison du 06/09/2026

Source de vérité : **226 frames** de Joachim (`refs/vagueA/appstore/e001.jpg … e226.jpg`, 603×1311 px,
1 pt = 1,5 px), thème **sombre** (Joachim est en sombre — la coque force le schéma via
`.preferredColorScheme(.dark)` sur `AppStoreVue`). Planches de contact : `planches/appstore/planche1..4.jpg`.

Livrables : `src/AppStoreApp.swift` (2 696 lignes, 44 types, tous préfixés `As` sauf
`AppStoreVue` / `MagasinAppStore` / `PontAppStore`), `src/patches/appstore-integration.md`,
`src/verif_appstore.py` (0 erreur, 0 avertissement).

---

## 1. Inventaire des frames → décisions

### Écrans FILMÉS reproduits fidèlement

| Écran | Frames | Implémentation | Ce qui a été relevé au pixel |
|---|---|---|---|
| Barre d'onglets flottante iOS 26 | e001, e128 | `AsBarreOnglets` | **une seule capsule** en `.ultraThinMaterial`, 5 onglets `Aujourd'hui · Jeux · Apps · Arcade · Recherche`, pilule blanche 14 % derrière l'onglet actif + libellé/glyphe bleus. Le « bouton loupe séparé » du brief **n'existe pas** dans les frames de Joachim : la loupe est le 5ᵉ onglet, dans la même capsule (e128 le montre sans ambiguïté). |
| Aujourd'hui | e001-e004, e225-e226 | `AsAujourdhuiVue` | titre large 34 pt gras + avatar 38 pt ; cartes rayon 20 pt, visuel plein cadre, chapeau 13 pt semibold majuscules, titre 26 pt gras, résumé 15 pt, **pied d'app** (icône 46 + nom + bouton) sur fond `#1C1C1E`. |
| « NOS FAVORIS / Indispensables pour l'iPhone » | e005-e007 | carte-liste d'`AsAujourdhuiVue` | icône 62, titre 16, accroche 14 gris `#8E8E93`, boutons capsule `#2C2C2E` texte bleu `#0A84FF`, séparateurs en retrait de 74. |
| Jeux | e045-e052, e076 | `AsJeuxVue` | chips horizontales, carte héros, sections « Jeux incontournables » / « Nos jeux du moment ». |
| Apps | e077-e079 | `AsAppsVue` | mêmes motifs, chips de catégories, « Les apps indispensables ». |
| Arcade | e101-e113 | `AsArcadeVue` | bandeau dégradé + classement des jeux Arcade. |
| Recherche (repos) | e114-e115, e135 | `AsRechercheVue` | pilule de recherche `#1C1C1E` avec loupe + placeholder « Jeux, apps, articles et plus encore » + micro ; « Suggestions › » ; « Parcourir › » en 4 tuiles colorées. |
| Recherche (résultats) | e116-e121 | `AsRechercheVue.listeResultats` | liste plate + séparateurs, croix de effacement. |
| Fiche d'app | e018-e040, e091-e093, e196 | `AsFicheVue` | rond de retour + rond de partage ; icône **112 pt** rayon 25 ; titre 22 gras ; éditeur 15 gris ; **« Obtenir » capsule bleue pleine, texte blanc gras 17** + « Achats intégrés » 11 gris ; bandeau de stats **défilant** avec filets verticaux (`21 K NOTES / 4,7 / ★★★★★`, `CATÉGORIE D'ÂGE / 9+`, `CLASSEMENT / N°34`, `CRÉATEUR`) ; carrousel de captures 196×348 ; « Nouveautés » + version + « plus » ; description repliée à 4 lignes ; « Notes et avis » 4,7 en 54 pt ; « Informations » en carte ; « Vous aimerez peut-être aussi ». |
| Fiche de jeu | e053-e060, e122-e128 | `AsFicheVue` (mêmes vues, données de jeu) | idem + classement. |
| Compte Apple (feuille) | e139, e197, e201, e212, e224 | `AsCompteVue.racine` | feuille `#1C1C1E`, logo Apple + « Compte Apple » 20 gras, rond ✕ ; carte identité (avatar 56 + nom + « Informations du compte, paiements et réglages » + filet + Game Center + pseudo + ↗) ; carte de menu 6 lignes. |
| Réglages du compte | e141-e143, e181, e185-e190 | `AsReglagesCompteVue` | rond ‹ + titre centré 17 semibold + rond ✕ ; groupes rayon 18 sur `#2C2C2E` ; valeurs à droite en gris ; en-têtes de section majuscules 13 ; interrupteurs verts `#30D158`. |
| Historique d'achats | e147-e151, e164 | `AsAchatsVue` | ligne « Affichage : Ces 90 derniers jours, Payant » ; champ « Nom, prix ou n° de commande » ; **groupes datés** (date 15 semibold gris) ; ligne = icône 44 + titre + type + prix ; filet ; **ligne « Total … › »**. |
| Détails de la commande | e153-e155 | `AsCommandeVue` | appareil, date, TVA 20 %, total, moyen de paiement, n° de commande, compte Apple, adresse de facturation. |
| Abonnements | e159, e169-e177, e200 | `AsAbonnementsVue` / `AsAbonnementVue` | sections « Actif » / « Expiré », ligne = icône 44 + nom + offre + « Renouv. le … » + prix + › ; alerte d'expiration en **rouge `#FF453A`** ; détail avec « Résilier l'abonnement » rouge. |
| Mises à jour d'apps | e191-e195 | `AsMajVue` | carte « Tout mettre à jour  N » (bleu à gauche, compteur gris à droite) ; en-tête « Mises à jour automatiques à venir » ; ligne = icône 52 + nom + « Hier » + capsule « Mettre à jour » ; puce « • notes … plus ». |
| Apps et achats → Apps | e202-e211 | `AsVosAppsVue` | segment capsule **« Tout / Pas sur cet iPhone »** ; ligne = icône 54 + nom + date + (`Ouvrir` / `Mettre à jour` / nuage ↓). |
| Notifications | e213 | `AsNotifsVue` | 2 interrupteurs + note explicative. |
| Notes et avis | e183-e184, e215-e217 | `AsAvisVue` | icône 46 + app + « Publié le … » + étoiles. |
| Recommandations personnalisées | e219-e220 | `AsRecoVue` | texte Apple, « Effacer les données d'utilisation des apps », compteurs. |
| Anneau de téléchargement | e123-e127 | `AsAnneau` | cercle gris 45 %, arc bleu, carré d'arrêt central — remplace le bouton pendant le téléchargement. |

### Écrans filmés NON reproduits (contenu réduit — piège de coût assumé)

Le brief le dit : l'App Store est une surface chère à faible densité d'indices. Les écrans
**de navigation marchande** sont donc fidèles de forme mais à contenu réduit et fixe :

- **Classements / Top téléchargements** (e064-e075, e084-e100) : les écrans « Top téléchargements »
  avec les sous-segments « Jeux gratuits / Jeux payants » et les catégories (Utilitaires…) sont
  **résumés** par les sections `AsSectionListe` des onglets Jeux/Apps et par les tuiles « Parcourir »
  de la Recherche (qui, elles, déclenchent une VRAIE recherche). Aucun écran de classement dédié :
  ces frames n'apportent aucun indice et coûtent 10 vues.
- **Bandeau d'offre Arcade « Obtenez 3 mois pour le prix d'un » + « Acceptez l'offre »** (e101-e113) :
  le visuel est conservé (texte Arcade), **le bouton a été RETIRÉ (D82-C)** — aucun paiement
  ni abonnement Apple Arcade n'est simulable de façon cohérente dans le jeu. Les jeux Arcade
  affichent l'étiquette non tactile « Arcade » au lieu d'un bouton d'achat.
- **Feuille de confirmation d'achat « Appuyez deux fois pour installer / Confirmez avec le bouton
  latéral »** (e125-e128) : retirée — on ne peut pas simuler le double-appui du bouton latéral sans
  mentir sur l'affordance. `Obtenir` déclenche directement l'anneau (comportement d'une app déjà
  achetée, ce qui est le cas pour la plupart des apps de Sarah).
- **Écrans « À propos du développeur », « Confidentialité de l'app », « Données utilisées pour vous
  suivre »** (e031-e038) : réduits à la carte « Informations » de la fiche. Sobres, non cliquables.
- **Micro / dictée de la Recherche** (e117) : icône présente (fidèle), inerte — le clavier système
  réel prend le relais pour la saisie.
- **Jeu 2048 lancé depuis l'App Store** (e129-e134) : hors périmètre (c'est l'app tierce, pas l'App Store).
- **Multitâche / bascule d'app** (e086-e090) : appartient à la coque, pas à l'App Store.
- **« Supprimer cet appareil » / « Se déconnecter » / « Configurer la famille » / « Ajouter de
  l'argent » / « Utiliser un code » / « Envoyer une carte cadeau »** (e187-e190, e201) :
  **RETIRÉS (D82-C)** — se déconnecter du compte d'un téléphone perdu détruirait le contenu du jeu,
  et les trois boutons de crédit n'ont aucune conséquence possible. À signaler à Joachim si
  « Se déconnecter » devait devenir un ressort de scénario.
- **Précommandes / Articles masqués** : retirés du menu de réglages (toujours vides → compteurs
  mensongers, D92).

---

## 2. Ce qui MARCHE réellement (D82-A)

1. **`Obtenir` → téléchargement crédible → `Ouvrir`.** `MagasinAppStore.obtenir(_:)` crée une
   progression, un seul minuteur (0,1 s) dans `AppStoreVue` la fait avancer, l'`AsAnneau` remplace
   le bouton, puis l'app **entre dans `installees`** : elle apparaît alors dans « Tout » de
   « Apps et achats » et son bouton devient `Ouvrir`. L'état persiste pendant toute la partie.
2. **`Ouvrir` ouvre VRAIMENT l'app du jeu.** `PontAppStore.partage.ouvrir(nom)` + `dismiss()` ;
   `AccueilView` consomme la demande et appelle `actionPour(nom)?()` (patch 4). Fonctionne pour
   Instagram, Snapchat, Facebook, Messenger, WhatsApp, X, ChatGPT, Spotify, YouTube, LCL Mes Comptes
   (→ `Ma Banque`), Mail, Messages, Téléphone, Safari, Photos, Notes, Plans, Fichiers, Cartes, Santé,
   Localiser, Réglages, Calendrier, Horloge, Météo, Calculatrice, Rappels, Dictaphone.
3. **`Mettre à jour` est réel** : la ligne **disparaît** de « Mises à jour d'apps », le compteur du
   menu Compte se décrémente, et la même app cesse d'afficher « Mettre à jour » partout ailleurs
   (fiche, listes éditoriales, « Vos apps »). `Tout mettre à jour` vide la liste → état
   « Tout est à jour ».
4. **Recherche réelle** : filtrage sur nom + éditeur + catégorie + accroche des 32 apps du catalogue,
   avec un vrai écran « Aucun résultat pour « … » ». Les tuiles « Parcourir » lancent une recherche.
5. **Historique d'achats filtrable** (nom, prix, n° de commande) avec écran « Aucun résultat » ;
   les **totaux sont calculés** à partir des lignes réellement affichées (D92 : jamais un total
   qui ne correspond pas au contenu) ; `Total ›` ouvre les **détails de la commande**.
6. **Résiliation d'un abonnement** : bascule vers « Abonnement résilié » + « Prend fin le … » avec
   le texte Apple correspondant.
7. **Segment « Tout / Pas sur cet iPhone »** : filtre réellement les deux listes ; le nuage ↓ lance
   un vrai retéléchargement (même anneau) et la ligne devient `Ouvrir`.
8. **Compteurs = contenu accessible** (D92, vérifié par le script) : « Apps et jeux achetés 19 »
   = 11 installées + 8 absentes ; « Abonnements 6 » = 6 abonnements listés ; « Notes et avis 5 »
   = 5 avis listés ; le badge de mises à jour = le nombre de lignes réellement présentes.

### Les rares B (message iOS crédible)

`Ouvrir` sur **PayPal**, **Musique** et **App Store** (apps du téléphone sans écran construit) et sur
les apps du catalogue qui n'existent pas dans le jeu (TikTok, Duolingo, leboncoin, Telegram, Chrome,
Adobe, Doctolib, SNCF Connect, Darkroom, Vinted, BlaBlaCar, GoldTrade Pro, Cœur à Cœur, les 5 jeux,
les 3 jeux Arcade) affiche `ErreurLambda.reponse("app.attente")` — **exactement le même message que
l'accueil du jeu** pour les apps pas encore construites. Alerte **locale à l'écran** : elle ne
survit pas à la sortie (correctif du bug d'état global signalé sur Facebook/Instagram).

---

## 3. Contenu Sarah (D59) — le gabarit de Joachim est intégralement remplacé

| Élément | Joachim (frames) | Sarah (livré) |
|---|---|---|
| Compte | Joachim Fourez, Memoji, `joachim.fourez@gmail.com`, Game Center `joachimfrz` | **Sarah Levasseur**, rond « SL » (ou pellicule `avatar-sarah`), `sarah.levasseur@icloud.com`, Game Center `sarahlvs` |
| Paiement / adresse | Mastercard, 260 Chemin d'Empeyrouton, Roquelaure 32810 | **Visa •••• 4417**, **14 rue de Marseille, 69007 Lyon**, France (canon lyonnais) |
| Apps installées | 40 mises à jour, apps de dev / musique | **les 31 apps du téléphone du jeu** (Réglages annonce 31) : 11 tierces (Instagram, WhatsApp, Snapchat, Messenger, Facebook, PayPal, ChatGPT, LCL Mes Comptes, Spotify, YouTube, X) + 20 apps intégrées datées du 9 nov. 2024 (mise en service) |
| Mises à jour | 40 apps inconnues | **6** : Instagram, Snapchat, PayPal, GoldTrade Pro, LCL Mes Comptes, Facebook |
| « Pas sur cet iPhone » | — | **8** achetées puis supprimées : GoldTrade Pro, Cœur à Cœur, Darkroom, Doctolib, SNCF Connect, Kiné+ Suivi, Vinted, BlaBlaCar |
| Historique d'achats | Telegram Premium, iCloud+, Onoff, Tomplay… (déc. 2025) | 8 groupes datés de **juil.-août 2026** (canon : lundi 17 août 2026) : appli photo (**Darkroom, déblocage complet 8,99 €**), **kiné (Kiné+ Suivi 14,99 €)**, Apple Music 10,99 €, iCloud+ 2,99 €, et **GoldTrade Pro 39,99 € ×2** + **Cœur à Cœur 24,99 € ×2** |
| Abonnements | Apple Music, ChatGPT Plus, iCloud+, Onoff, Smarters Pro, Telegram, Tomplay, YouTube Music | **6** : GoldTrade Pro 39,99 €, Cœur à Cœur 24,99 €, Apple Music 10,99 €, iCloud+ 2,99 €, Spotify 11,99 € (expire le 24 août), Kiné+ Suivi (expiré) |
| Notes et avis | Lovetale, Google Sheets, Apple Wallet, ChatGPT, Quizlet, BlaBlaCar | **5** : Doctolib ★5, Darkroom ★5, SNCF Connect ★4, **GoldTrade Pro ★2**, Kiné+ Suivi ★4 |
| Aujourd'hui / Jeux / Apps / Arcade | Claude by Anthropic, Google Gemini, Roblox, Madden 27… | contenu éditorial **fixe et réduit** (3 cartes + 2 sections par onglet), cohérent avec le catalogue de Sarah |

### Les indices (D92 : un abonnement inattendu est un indice)

1. **GoldTrade Pro — « Signaux Or & devises », GTP Markets Ltd, 39,99 €/mois**, prélevé le 3 juil.,
   le 14 juil. et le 14 août 2026, **renouv. le 14 septembre**, note ★2 laissée par Sarah,
   mise à jour en attente dont les notes de version disent *« Nouvelle salle de marché privée pour
   les membres Premium »* — et l'app **n'est plus sur le téléphone**. Le pattern est complet :
   app d'investissement poussée par « Marc », prélèvement toujours actif, app supprimée.
2. **Cœur à Cœur — « Rencontres sérieuses après 40 ans », 24,99 €/mois**, prélevé le 9 juin,
   le 9 juil. et le 9 août 2026, **renouv. le 9 septembre**, également supprimée du téléphone :
   c'est là que la rencontre a commencé. Le joueur peut relier Cœur à Cœur → Marc → GoldTrade Pro →
   le rendez-vous bancaire du 17 août 11 h 30 (widget Calendrier « Agence Bellecour »).
3. Contre-indice de cohérence : la vie « normale » de Sarah est bien là (Darkroom, kiné, SNCF,
   Doctolib, Vinted, BlaBlaCar) — les deux abonnements détonnent d'autant plus.

---

## 4. Risques évités (compilation à froid, sans compilateur)

- **Aucune collision de type** avec `LPProto` + Messenger + Instagram + Snapchat + Facebook + Notes :
  44 types, tous préfixés `As` sauf `AppStoreVue` / `MagasinAppStore` / `PontAppStore` (vérifié).
- **Dépassement du constructeur de vues** : deux piles littérales dépassaient 10 enfants
  (menu du Compte : 11 ; « Informations » de la fiche : 13) → réécrites en `ForEach` sur une table.
- **`navigationDestination` une seule fois par `NavigationStack`** : un seul `NavigationStack`
  dans tout le fichier (la feuille Compte) et un seul `navigationDestination(for: AsRouteCompte.self)`.
  Les autres navigations sont des **calques** (`fiche`) — pas de pile imbriquée.
- **Pas de `.background(Color…, in:)` ambigu** : toujours
  `.background(RoundedRectangle(...).fill(...))` ou `.background(Capsule().fill(...))`.
- **Pas de `.scaledToFill()` nu en cellule** : les icônes passent par
  `Color.clear.overlay(Image(uiImage:).resizable().scaledToFill()).clipped()` + `clipShape`.
- **Ternaires de style typés** : `let plein: String = …`, `let texte: Color = …`,
  `let accessoire: String? = …`, `let actif: Bool = …`, `let requete: String = …`.
- **`ErreurLambda.reponse` n'est jamais stocké dans un `String`** (son type de retour n'est pas
  vérifiable ici) : il est passé directement à `Text(...)`, qui accepte `String` comme
  `LocalizedStringKey`. L'état d'alerte ne porte que le nom de l'app.
- **`@Published` sur `ObservableObject`** : `MagasinAppStore` (`installees`, `majEnAttente`,
  `enCours`) et `PontAppStore` (`demande`).
- **Aucune API iOS 18+** : pas de `Tab(...)`, `TabSection`, `MeshGradient`, `@Entry`,
  `navigationTransition`, `onScrollGeometryChange`… `onChange(of:) { _, _ in }` (iOS 17),
  `toolbar(.hidden, for:)` (iOS 16), `Timer.publish` (Foundation).
- **Symboles SF incertains** (`rocket.fill`, `arcade.stick.console.fill` de la barre d'onglets) passés
  par `asSymbole(_:repli:)`, qui teste `UIImage(systemName:)` et retombe sur `gamecontroller` :
  aucun glyphe vide possible sur une cible iOS 17.
- **Pas de clés dupliquées** : identifiants d'apps, d'achats, d'abonnements et d'avis uniques
  (vérifié) ; tous les `ForEach` portent un `id` explicite (ou une plage constante).
- **Bug de la BarreHome (retour Facebook)** : `BarreHome` est présente sur les 5 onglets **et** sur
  le calque « fiche d'app », et la coque applique `persistentSystemOverlays(.hidden)` +
  `defersSystemGestures(on: .bottom)`. Les captures de fiche embarquent aussi la BarreHome.
- **Aucun état global rémanent** : toutes les alertes / feuilles sont des `@State` locaux ; seuls
  les téléchargements et les mises à jour (conséquences réelles voulues) vivent dans le magasin.

## 5. À trancher avec Joachim

1. **« Se déconnecter » du Compte Apple** a été retiré : conserver, ou en faire un ressort
   (déconnexion = perte d'accès aux achats, donc un indice de plus) ?
2. **Feuille de confirmation d'achat** (double-appui du bouton latéral, e125-e128) : retirée faute
   d'affordance simulable. À rétablir si Joachim tient à ce moment très reconnaissable.
3. **Bandeau d'offre Apple Arcade** : le bouton « Acceptez l'offre » est retiré. Si Arcade doit
   compter dans l'histoire, il faut décider ce que l'abonnement change réellement.
4. **`avatar-sarah`** : pellicule optionnelle à ajouter au pack d'icônes ; sans elle, le rond
   « SL » s'affiche (comportement iOS normal).
