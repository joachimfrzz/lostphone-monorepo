# PayPal v1 D92 — livraison (06/09)

Source unique : **263 frames** `/refs/vagueA/paypal/e001…e263.jpg` (603×1311 px, 1 pt = 1,5 px),
lues par planches de contact puis relevées en pleine résolution écran par écran (D67).
Livrables : `src/PayPalApp.swift` (3 090 lignes, racine `PayPalVue`, préfixe `Pp`),
`src/assets/paypal-icone.png`, `src/patches/paypal-integration.md`.

---

## 1. Inventaire des frames → écrans distincts

| Frames | Écran filmé | Décision |
|---|---|---|
| e001–e043 | Spotlight, lancement, splash, Face ID, mot de passe, « Choisir une autre méthode » | **Retiré** — dans Lost Phone le téléphone est déverrouillé, PayPal s'ouvre directement (comme Ma Banque) |
| e044–e046, e106–e112, e250–e251, e263 | **Accueil** : ≡ / cloche / profil, carte Solde PayPal, carrousel « Paiement en plusieurs fois », bandeau « Ajouter les détails du compte 1/3 », « Produit phare », « Activité récente / Afficher plus » | **Implémenté** (sans le 1/3 ni le carrousel — voir §3) |
| e047–e048, e106–e107 | **Solde PayPal** : carte, onglets Activité/Devises, 1 ligne, « Tout afficher » | **Implémenté** (onglet Devises retiré) |
| e049–e077, e101–e105 | **Transactions de solde PayPal** : liste dense, avatars, date, sous-titre, montant vert/noir | **Implémenté** |
| e056–e070, e090–e100, e119–e121 | **Détail de transaction** : en-tête + montant + « Afficher l'historique », actions rondes, « De » + carte + « Afficher les informations de paiement », « Vous et X », numéro de transaction, « Comment pouvons-nous vous aider ? » | **Implémenté** |
| e063–e065 | Variante **remboursée** (« Cet achat a été remboursé le… ») + informations d'expédition + Montant/Frais/Total | **Implémenté** (bandeau de remboursement ; expédition retirée, Sarah n'a pas d'achat expédié) |
| e127 | **Détail d'un paiement marchand** : logo, « Récapitulatif de la commande », « De — Solde PayPal », « Contacter … » | **Implémenté** (récapitulatif réel : Spotify, SNCF Connect, atelier céramique) |
| e079–e089 | **Historique « Vous et X »** : double avatar, liste des échanges | **Implémenté** |
| e086–e087 | **Confirmation d'envoi** : « Vous avez envoyé à X — 30,00 € EUR », ✕ | **Implémenté** (« Afficher les messages » retiré : pas de messagerie dans l'app) |
| e090 | Feuille **Informations de paiement** | **Implémenté** |
| e113–e140, e190 | **Activité** : grand titre, recherche, filtres Tout/Achats/Envoyés et reçus, groupes par mois, recherche avec résultats | **Implémenté** (filtres et recherche réellement filtrants) |
| e141–e142 | **Notifications** | **Implémenté** (2 notifications réelles, pastille comptée, marquées lues à la visite) |
| e145–e149 | **Profil** : bandeau violet, avatar, nom/@pseudo/Membre depuis, boutons Coordonnées & Paramètres, liste, Se déconnecter, Version | **Implémenté** (liste réduite, voir §3) |
| e146, e150 | **Coordonnées** : Emails / Téléphones / Adresses, étiquette « Principal » | **Implémenté** |
| e148, e151, e164–e180 | **Paramètres** 1ʳᵉ page + Notifications + Connexion et sécurité + Données et confidentialité + Préférences marketing | **1ʳᵉ page, Notifications et Sécurité implémentés** ; marketing et confidentialité retirés (webviews) |
| e152–e154 | **Préférences de notification** (liste d'interrupteurs) | **Implémenté** (3 interrupteurs persistants) |
| e181–e189 | **Abonnements** + feuille de détail (payé avec, activité) | **Implémenté** (Spotify AB, 1 abonnement réel avec ses 2 paiements) |
| e191–e199, e211, e232–e235 | **Envoyer et demander** : titre, recherche, « Suggestions » | **Implémenté** (recherche réelle sur nom/pseudo/email) |
| e200–e231 | **Montant** : gros montant, pilule EUR, note, Demander/Envoyer, pavé numérique | **Implémenté** (pavé maison, pas de clavier système, pas de micro) |
| e226–e227 | Feuille **Type de paiement** (biens et services / vos proches) | **Implémenté** |
| e225, e229 | Feuille **Vérifier** : source, type, frais, total, date de versement, Envoyer | **Implémenté** |
| e228–e230 | Feuille **Comment voulez-vous payer ?** | **Implémenté** (2 sources : Solde PayPal, Visa LCL ••••4417) |
| e209 | **« Nous avons interrompu ce paiement pour vous protéger »** | **Implémenté — pièce maîtresse narrative** |
| e236–e250 | **Comptes** : solde, cartes bancaires, Préférences | **Implémenté** (les 4 cartes Wise/CA/Mastercard/bunq remplacées par la seule Visa LCL de Sarah — D59) |
| e243–e245 | **Détail d'une carte** | **Implémenté en lecture seule** |
| e251–e263 | **Menu** (≡) : 5 sections, ~18 rangées | **Implémenté réduit à 4 rangées réelles** |
| e096–e098 | Composition d'un mail iOS (hors app) | **Hors périmètre** |

---

## 2. Contenu de Sarah (D59 — les données des frames ne sont que des gabarits)

- **Identité** : Sarah Levasseur, `@sarahlev69`, `sarah.levasseur@icloud.com` (canon MailApp),
  14 rue des Fantasques 69001 Lyon, membre depuis 2019.
- **Solde PayPal : 12,40 €** — volontairement bas : c'est ce qui rend le refus « solde
  insuffisant » crédible et pousse vers la carte.
- **Source de paiement** : Visa **LCL ••••4417** (exactement la carte de Ma Banque), expiration 11/28.
- **Trace de l'arnaque, sobre** (3 lignes + 1 blocage + 1 demande) :
  - 16/08/2026 — **300,00 € à Marc — PAIEMENT INTERROMPU** : PayPal l'a bloqué comme arnaque
    probable. Rien débité. Le détail porte le bandeau de protection, et la notification aussi.
  - 09/08/2026 — 200,00 € envoyés à Marc « entre proches », note « connexion satellite »
    (écho du virement LCL du 08/05 « CONNEXION SATELLITE »).
  - 21/07/2026 — 150,00 € à Marc, note « avance frais de douane », payés par carte.
  - 12/06/2026 — 120,00 € à Marc, note « caution transporteur » — **la veille du Western
    Union de 850 € du 13/06** : PayPal a été la première marche, puis le canal a changé.
  - Demande d'argent **reçue et en attente** : « GLOBAL MARINE CREW SUPPORT » (480 €,
    `crew.support@marine-logistics-intl.com`), motif « frais de rapatriement d'équipage,
    dossier 7845 » — la référence 7845 est celle du bénéficiaire OKAFOR de Ma Banque.
  - Marc = `marc.dlc.officier@gmail.com` (canon `AnnuaireMail`), 3 lignes visibles côté PayPal
    + 1 bloquée : **cohérent avec le tableau de Ma Banque, jamais redondant avec lui**.
- **Vie normale** (pour que l'arnaque ne soit pas seule à l'écran) : Camille Roux +35 €
  (vente d'un objectif 50 mm, écho du mail Phox), Spotify AB 11,99 € ×2, Chloé −16,50 € et
  +20 €, Maman +50 €, SNCF Connect −47,00 € (le prix exact du billet Lyon→Marseille du mail),
  atelier céramique −24,90 € remboursé (écho du commentaire Instagram sur le bol émaillé).
- **Contacts PayPal** : Chloé, Marc, Maman, Thomas, Camille Roux, SNCF Connect, Vinted —
  tous avec les adresses canoniques de `AnnuaireMail`.

---

## 3. Ce qui a été retiré, et pourquoi (D82-C / D92)

Retiré parce que **rien derrière** ne peut exister dans le jeu sans usine à gaz :

- **Accueil** : « Ajouter les détails du compte 1/3 », carrousel « Paiement en plusieurs
  fois / jusqu'à 1 000 € ». Le bandeau **« Produit phare »** est CONSERVÉ mais son bouton
  « Démarrer » mène désormais à un écran réel (Abonnements) — une affordance de moins qui ment.
- **Solde PayPal** : onglet **Devises** (Sarah n'a qu'un solde en euros ; un onglet vide est
  pire qu'un onglet absent).
- **Menu** : sections « Acheter et économiser » (Récompenses, Paiement différé, Suivi de
  colis) et « Envoyer et payer »/« Recevez des paiements » au complet (transferts sur
  portefeuille mobile, guichet de retail, recharge de téléphones, factures, QR vendeur,
  partage de dépense, dons, entreprises liées). Il reste 4 rangées, toutes fonctionnelles :
  Abonnements, Cartes et comptes bancaires, Votre profil, Paramètres.
- **Activité** : « Suivez votre colis en direct » et le bouton de filtres avancés (curseurs).
- **Profil** : Inviter des proches / Gagnez des récompenses, Aide, Messagerie, **Se
  déconnecter**, Contrats d'utilisation, le crayon de modification de l'avatar, le sélecteur
  « Compte Particulier ▾ ». « Version 8.107.2 » reste (texte, pas un bouton).
- **Paramètres** : Préférences marketing et Données et confidentialité (des webviews dans les
  frames — e155 à e180 — qui n'ont aucun rôle d'enquête), et **Fermer votre compte**.
- **Comptes** : « Ajouter » une carte, « Mettre à jour la carte ⚠ », Achats en personne / par
  QR code, Entreprises liées. Détail de carte : Renommer / Modifier / Supprimer.
- **Envoyer et demander** : le ⓘ de chaque suggestion, le QR code d'en-tête, le ⋮.
- **Confirmation d'envoi** : « Afficher les messages ».
- **Transaction** : « Paiement divisé », « Envoyer de l'argent » depuis le détail, « Afficher
  la story », « Signaler X » / « Bloquer X » (doublons de « Signaler un problème »),
  « Partager ce paiement avec d'autres », informations d'expédition.

**À signaler à Joachim** (retiré mais potentiellement utile plus tard) : *Suivi de colis*
(un colis Vinted en cours ferait un bon détail de vie), *Bloquer un contact* (geste fort si
Sarah finit par bloquer Marc), et l'écran de **connexion Face ID / mot de passe** (e010–e043)
si un jour une app doit résister à l'intrusion du joueur.

---

## 4. Ce qui MARCHE réellement (D92 : une action = un état qui change)

1. **Envoyer de l'argent** : contact → Montant (pavé) → Type de paiement → Vérifier →
   Envoyer. Le solde est **réellement débité** si la source est le solde PayPal, une ligne
   « Argent envoyé » **apparaît en tête** de l'Activité, du Solde PayPal, de l'Accueil et de
   l'Historique du contact, et l'écran de confirmation affiche le montant.
2. **Refus crédible** : envoi > 12,40 € depuis le solde → « Solde PayPal insuffisant (12,40 €).
   Choisissez un autre mode de paiement ou réduisez le montant. » Le message est un `@State`
   local à la feuille et à l'écran Montant : il **ne survit pas** à la sortie de l'écran.
3. **Protection anti-arnaque** : tout envoi vers **Marc** déclenche l'écran e209
   « Nous avons interrompu ce paiement pour vous protéger », rien n'est débité — cohérent
   avec la ligne du 16/08 déjà présente. Idem sur « Payer » la demande GLOBAL MARINE.
4. **Demander de l'argent** : crée une ligne « Demande envoyée » dans l'Activité.
5. **Refuser la demande** reçue : l'état passe à « refusée », la pastille de la cloche
   décrémente, la carte disparaît d'« En attente » — et ça persiste.
6. **Recherche** (Activité, Envoyer/demander) et **filtres** Tout / Achats / Envoyés et reçus :
   réellement filtrants, avec un état vide écrit.
7. **Interrupteurs** (3 préférences de notification + Face ID) : persistants, et le texte
   sous Face ID change avec l'état.
8. **Compteurs = contenu accessible** : la pastille de la cloche vaut exactement le nombre de
   notifications listées ; « Afficher plus » ouvre l'onglet Activité ; « Tout afficher » ouvre
   la liste complète ; l'Historique d'un contact liste exactement ses transactions.

---

## 5. Risques évités (règles de compilation Codemagic / Xcode 26)

- Vues courtes : 60 types, chaque écran découpé en sous-vues nommées (`carteSolde`,
  `blocSource`, `etapeVerifier`…). Aucun `body` de plus de ~10 enfants directs.
- **Un seul `NavigationStack`** dans toute l'app, et **zéro `navigationDestination`**
  (navigation par `NavigationLink(destination:)` uniquement) : impossible de tomber sur le
  piège « destination déclarée par rangée ».
- **Aucun `.background(Color…, in:)`** : partout `.background { Forme().fill(…) }`.
- Aucun `.scaledToFill()` sur une `Image` en cellule (aucune image bitmap dans l'app).
- Aucune clé de dictionnaire dupliquée ; `@Published` uniquement sur `PpMagasin: ObservableObject`.
- Ternaires de style **typés** (`Font.Weight.bold : Font.Weight.regular`, `Color.a : Color.b`,
  `PpEtapeEnvoi.verifier : PpEtapeEnvoi.type`).
- Aucune API iOS 18+ (`onGeometryChange`, `glassEffect`, `ToolbarSpacer`, `MeshGradient`,
  `TabView(.sidebarAdaptable)`, `@Entry`… : vérifiés absents). Tout est iOS 16/17.
- Préfixe `Pp` : **zéro collision** de type avec `LPProto.swift`, `MessengerApp.swift`,
  `InstagramApp.swift`, `SnapchatApp.swift`, `FacebookApp.swift`, `NotesApp.swift`
  (vérification automatisée). Aucun symbole global (`let`/`var`/`func` de niveau fichier).
- Accolades/parenthèses/crochets **équilibrés** (contrôle python hors chaînes et commentaires).
- **BarreHome** : posée hors du `NavigationStack`, donc présente sur la racine, sur les 18
  écrans poussés, derrière les feuilles, et sur les deux plein-écrans — qui sont des
  `overlay` internes et **non** des `fullScreenCover` (c'est exactement le bug de navigation
  signalé sur Facebook au build 279). La barre d'onglets et toutes les barres de boutons
  bas sont posées 22 pt au-dessus de la capsule.
- Coquille claire (`coquilleSarah(claire: true)`), retour = **chevron** (`chevron.left`),
  **aucun micro de dictée** (le montant passe par un pavé numérique maison, les champs
  texte sont de simples `TextField`).
