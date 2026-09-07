# SNCF Connect — livraison v1 (vague B, 07/09/2026)

Fichier : `src/SncfApp.swift` (5 655 lignes, 1 seul fichier, `import SwiftUI` seul).
Préfixe de types : **Sn** — 88 types, tous en `Sn*`, y compris la vue racine `SncfVue`.
Vue racine : `SncfVue(onglet: Int = 0)`, construite exactement comme `PayPalVue`
(`ZStack(alignment: .bottom) { NavigationStack { … }.toolbar(.hidden, for: .navigationBar) ; BarreHome { quitter() } }`).
Vérificateur : `src/verif_sncf.py` → **VERT** (0 erreur, 0 avertissement).

Aucun `.sheet`, `.fullScreenCover`, `.confirmationDialog`, `.popover`. Aucun
`navigationDestination` (toute la navigation passe par `NavigationLink { … } label: { … }`,
donc la règle « un seul `navigationDestination` par `NavigationStack` » est respectée par
construction). Aucun MapKit, aucun réseau, aucune API iOS 18+/26, aucun micro de dictée.
Deux `.alert` simples seulement (D82-B, voir §5).

---

## 1. Palette mesurée au pixel (D67)

`enum SnTeinte`, chaque constante commente sa frame source :

| Constante | Valeur | Mesure |
|---|---|---|
| `fond` | `#0E1420` | e001/e109/e145 — (14, 20, 32), couleur dominante de toutes les frames |
| `carte` | `#1F2535` | e001 cartes « Utile au quotidien » — (31, 37, 53) |
| `grille` | `#1B1E2D` | e001 bloc pleine largeur de la grille de services — (27, 30, 45) |
| `accent` | `#7FE3FB` | e021/e027 boutons, chips sélectionnées, onglet actif — (127, 227, 251) |
| `bleuDoux` | `#6FB5FB` | e021 bandeau « Trajet recommandé », e194 bulle utilisateur — (111, 181, 251) |
| `gris` | `#9195A0` | e021 « Nos offres sont présentées… » — (145, 149, 160) |
| `teal` | `#396D85` | e027 bandeau « 2de classe », e042 bandeau du billet — (57, 109, 133) |
| `orange` | `#E27C3C` | e109 « Retard estimé », e042 « Prix valable jusqu'à » — (226, 124, 60) |
| `rouge` | `#FF5572` | e138 pastille « Perturbations » — (255, 85, 114) |
| `violet` | `#B58DFF` | e030 ligne du trajet et pastilles d'heures — (181, 141, 255) |
| `texte` | `#FDFDFD` | blanc des titres |
| `sombre` | `#151B27` | sous-cartes internes (bloc « Aller » d'e042) |

Mesures faites avec PIL sur les frames brutes (comptage des pixels dominants + sondes
ponctuelles), pas d'après une charte publiée.

---

## 2. Écrans FILMÉS reproduits (D67)

| Écran | Type | Frames |
|---|---|---|
| **Accueil / Voyager** — « Bonjour Sarah ! » + cloche, champ blanc en capsule « Où souhaitez-vous aller ? » (sans micro), grille de services pleine largeur avec séparateurs, « Utile au quotidien » ×2 avec pastille `+` cyan | `SnAccueilVue` | e001, e100, e136, e183, e196 |
| **Rechercher une destination** — titre + « Fermer », champ blanc à loupe cyan, « Villes, Gares et Stations », pictos ville/gare, nom en gras + région en gris, pastilles de lignes de réseau | `SnDestinationVue` | e002, e004, e005, e105, e133 |
| **Recherche** — carte Départ / Arrivée avec bouton d'inversion rond, ligne « Aller : 18 août, 10h », « Filtrer par : Trajets directs », « Qui voyage ? », carte voyageur (avatar + carte de réduction), « Voir les prix », bloc « Besoin d'aide ? » avec suggestions | `SnRechercheVue`, `SnBlocAide` | e009, e013, e015, e016, e019, e086 |
| **Calendrier** — deux mois, grille L M M J V S D, jour sélectionné cerclé cyan, bandeau d'heures, « Confirmer » | `SnCalendrierVue` | e011, e017, e018, e025, e093 |
| **Résultats** — onglets Train / Bus ou covoit. soulignés cyan, bandeau de jours avec prix mini (chip cyan à texte sombre), mention + « Voir conditions », « Afficher les trajets précédents / suivants », cartes de trajet (heures, gares, dès X €, pilule durée · Direct · logo · chevron, picto vélo), bandeau bleu « Trajet recommandé » | `SnResultatsVue`, `SnCarteTrajet` | e020, e021, e022, e024, e063, e070, e097 |
| **Aucun trajet trouvé** (état vide filmé) | `SnAucunTrajet` | e092 |
| **Choisissez un tarif** (= détail du trajet) — récap « Aller : … », heures/gares + `x1`, ligne durée/Direct/logo, bloc tarif à bandeau teal « 2de classe / Modifiable sous conditions » + prix, bouton cyan « Choisir cet aller à X € », « Conditions tarifaires », ligne du trajet violette, fiche « Train … n° … / Opéré par SNCF Voyageurs », « Espace vélo gratuit », « Voir + de détails » | `SnTarifVue`, `SnLigneTemps` | e027, e028, e033, e036, e065, e072 |
| **Conditions tarifaires** | `SnConditionsVue` | e029 (libellé), e044 |
| **Fiche train** — « Train court / long », silhouette de rame dessinée, « Services à bord de ce train » + pictos, « 1 rame … - n voitures - n places », « Destination … / Opéré par SNCF Voyageurs », liste des arrêts avec heures et « n min d'arrêt » | `SnTrainVue`, `SnDessinTrain` | e030, e031, e034, e037 |
| **Panier** — « Détail de la commande (n produits) » dépliable, « Total commande », « Poser une option gratuitement », carte du billet à bandeau teal (logo, gares, `x1`, prix, « Prix valable jusqu'à 21:23 », bloc « Aller » + « Placement libre »), « Souhaitez-vous assurer votre voyage ? » Oui 1,05 € / Non, « Bagages à bord », « Billet sur votre téléphone », « Valider et payer », « Ajouter un autre billet », « Retirer du panier », « Besoin d'aide ? » | `SnPanierVue`, `SnCarteArticle` | e041, e042, e043, e047, e048, e050, e055, e057, e077, e079 |
| **Horaires en gare — accueil** — grande illustration/onboarding « Consultez les horaires de tous les trains et transports en commun » + 3 explications | `SnGareRechercheVue` | e102, e103, e135 |
| **Recherche de gare** — champ + résultats gare/région + pastilles de lignes | `SnGareRechercheVue` | e104, e105, e106, e133 |
| **Tableau des départs / arrivées** — chips « Grandes lignes » / « Bus », onglets Départs / Arrivées, champ « Vers Toutes les gares », lignes heure + destination + logo/n° + « Train court », voie encadrée, « +20 min » et « Retard estimé », « Supprimé », « Parcours modifié » | `SnHorairesVue`, `SnLigneHoraire` | e107 → e132 |
| **Infos trafic et réseaux** — onglets, grille de pastilles de lignes avec badge d'état, « Perturbations » avec pastille rouge, cartes de perturbation | `SnTraficVue`, `SnCartePerturbation`, `SnPerturbationVue` | e137, e138, e139 |
| **Billets** — grand titre, « Vos cartes et titres urbains » (tuile QR), « Vos voyages » À venir / Passés, cartes de voyage, « Numéro d'alerte 3117 », « Besoin d'aide ? » | `SnBilletsVue`, `SnCarteVoyage` | e142, e145, e146, e147, e148, e150, e165 |
| **État vide « Aucun voyage prévu pour le moment »** (conservé comme repli) | `SnBilletsVue.vide` | e145, e150 |
| **Numéro d'alerte 3117** | `SnAlerteVue` | e147, e168 |
| **Offres** — grand titre, champ blanc « Carte, abonnement, région », « Cartes et abonnements SNCF » en cartes illustrées avec prix | `SnOffresVue`, `SnOffreVue` | e153, e154 |
| **Compte** — roue crantée, avatar rond à initiales + nom + « Infos de votre compte, préférences… », « Cartes de réduction et fidélité », « Préférences de voyage / Vos compagnons », « Besoin d'aide ? », « Achats » (titres de transport, moyens de paiement, alertes billets) | `SnCompteVue` | e155, e162, e163, e165, e167, e169 |
| **Vos coordonnées** — « Coordonnées perso », fiche nom/date/téléphone, adresse, e-mail, « Votre compte / Mot de passe » | `SnCoordonneesVue` | e156, e157, e161, e171 |
| **Identité** — feuille « Identité » + « Fermer », `*champs obligatoires`, champs encadrés à étiquette flottante, « Enregistrer » | `SnIdentiteVue` | e158, e159, e160 |
| **Paramètres** — « Consentements » (2 interrupteurs), « Paramètres avancés » (Préférences d'affichage, Langue de l'application, « Afficher le numéro de circulation de tous les trains », « Annonces à bord »), « Version 20260730.0.0-2026 » | `SnParametresVue`, `SnInterrupteur`, `SnAffichageVue`, `SnLangueVue`, `SnListeChoix` | e172, e173, e174, e175, e176, e177 |
| **Notifications — état vide** « Retrouvez vos notifications ici / Infos sur vos trajets, n° de quai, bons plans… » | `SnNotificationsVue` | e185 |
| **Chatbot d'aide** — « Fermer », charte de confidentialité, bulle grise du bot « Bonjour, je suis le bot SNCF Connect ! », bulle bleue de l'utilisateur, champ « Écrivez votre message… » + bouton rond cyan | `SnAideVue`, `SnBulle` | e189 → e195 |
| **Barre d'onglets** Voyager / Billets / Offres / Compte, soulignée cyan, posée au-dessus de `BarreHome` (marge basse 22 pt) | `SnBarreOnglets` | e001, e145, e154, e155 |

---

## 3. Écrans issus des captures officielles (D93)

| Écran | Type | Source |
|---|---|---|
| **Paiement sécurisé** — « Payez en toute sécurité », « Sélectionnez un moyen de paiement », Apple Pay (radio, mention « éligible aux marques : CB, Visa et Mastercard »), Carte bancaire, « Voyage (n) », « Total commande », case « J'ai pris connaissance des conditions ci-après et je les accepte » | `SnPaiementVue` | `refs/officiel/sncf/03_06_CPP_FR_1284x2778.jpg` |
| **Poser une option gratuitement** — libellé et promesse (« à payer avant le … ») | `SnPanierVue.blocOption` | `refs/officiel/sncf/09_07_CPP_FR_1284x2778.jpg` |
| **Cartes et abonnements SNCF** — Carte Avantage Adulte / Jeune / Senior, Carte Liberté, tranches d'âge et prix | `SnOffresVue`, `SnCartesReductionVue` | `refs/officiel/sncf/05_04_CPP_FR_1284x2778.jpg` |
| **Alertes billets disponibles** — Alertes petits prix / réservation / train complet | `SnAlertesBilletsVue` | `refs/officiel/sncf/06_05_CPP_FR_1284x2778.jpg` |

---

## 4. Écrans ASSEMBLÉS à partir de briques filmées (aucun écran inventé de mémoire)

Joachim n'avait **aucun billet dans son compte** : son onglet Billets est vide dans toute la
vidéo (e145, e150, e165) et l'écran « billet ouvert » n'existe ni dans les frames ni dans les
captures officielles (le `SOURCES.md` d'officiel2 le liste explicitement comme non trouvé).
La mission impose pourtant un e-billet Lyon → Marseille du 28 août (l'indice narratif central).
Ces deux écrans sont donc **composés uniquement de briques documentées**, jamais de mémoire :

- `SnCarteVoyage` : c'est **exactement** la carte du panier d'e042 (bandeau teal avec logo +
  gares + flèche, corps sombre avec heures, prix et mention), réutilisée telle quelle.
- `SnVoyageVue` : la même carte + un `SnGroupe` de rangées clé/valeur (gabarit d'e175/e156).
- `SnBilletVue` : bandeau teal d'e042, colonne de gares d'e027, QR code **dessiné** (gabarit
  du QR filmé en e143/e144), rangées Train / Voiture / Place au gabarit d'e027, bouton cyan
  au gabarit d'e027.
- `SnQrCode` : QR **dessiné en `Canvas`**, matrice 25×25 déterministe (hachage de la graine
  + motifs de repérage aux 3 coins). Aucune image, aucune bibliothèque, aucun réseau.
- `SnDessinTrain` : silhouette de rame dessinée en formes SwiftUI (e030 montrait une image
  bitmap de rame liO ; on ne peut pas l'embarquer, on la redessine sobrement).

À arbitrer avec Joachim s'il refilme l'app avec un billet réel dans le compte.

---

## 5. D82-B — les deux seuls messages « iOS crédibles »

1. **Paiement** (`SnPaiementVue`) : `.alert("Paiement refusé")` → « Le paiement n'a pas pu être
   finalisé. Réessayez plus tard. » Aucun billet n'est émis, **le panier est conservé**
   (on peut réessayer, ou poser une option à la place).
2. **Apple Wallet** (`SnBilletVue`) : `.alert("Impossible d'ajouter à Apple Wallet")` → « Ce
   billet n'a pas pu être ajouté pour le moment. Réessayez plus tard. »

Ce sont les deux seuls `.alert` du fichier. Les messages sont écrits en dur (et non via
`ErreurLambda`) pour que le fichier reste auto-suffisant.

---

## 6. D59 — contenu narratif choisi

- **Identité** : Sarah Levasseur, née le 03/04/1991, 06 •• •• •• 42,
  sarah.levasseur@icloud.com, 14 rue des Fantasques 69001 Lyon, avatar rose « SL ».
  Modifiable pour de vrai depuis Compte › Vos coordonnées › Identité (persistant).
- **Gare de référence** : Lyon Part-Dieu (départ pré-rempli partout, tableau des départs par
  défaut, gare « Votre gare » dans Horaires en gare).
- **Carte de réduction** : Carte Avantage Adulte, n° 29 04 1991 5507 218, valable jusqu'au
  14/02/2027. Elle est **réellement appliquée** : `SnMoteur` multiplie le prix plein par 0,70
  quand elle est présente, et l'écran Recherche l'affiche sur la carte voyageur.
- **Moyen de paiement** : Visa LCL •••• 4417, 11/28 (cohérent avec Ma Banque et PayPal).
- **Vos voyages › À venir** : un e-billet **Ven. 28 août 2026, Lyon Part-Dieu 06:44 →
  Marseille Saint-Charles 08:31, TGV INOUI 6171, voiture 12 place 58, 2de classe, 39 €
  (Carte Avantage), acheté le 14 août 2026, dossier QKPXRJ**. C'est le voyage pour rejoindre
  « Marc », qui « arrive à Marseille le 28 » (playlist « Marseille — le 28 ⚓️ »).
  *Correction de date assumée* : la mission écrivait « Jeu. 28 août 2026 » ; le 28 août 2026
  est un **vendredi**. Tout le calendrier de l'app est cohérent (origine : mardi 18 août 2026).
- **Vos voyages › Passés** : Lyon → Paris Gare de Lyon (dim. 21 juin, TGV INOUI 6620, 52 €),
  Lyon → Valence Ville (dim. 10 mai, TER, 13 €), Lyon → Annecy (dim. 12 avril, TER, 19 € —
  ses parents).
- **Destinations récentes** (remplacent les vignettes « Ajouter Maison / Travail » d'e002,
  qui n'avaient aucune conséquence) : Marseille Saint-Charles, Paris Gare de Lyon, Annecy.
- **Info trafic** : région **Auvergne-Rhône-Alpes** (remplace l'Île-de-France filmée) —
  métro TCL A/B/C/D, trams T1 → T7, et 2 perturbations crédibles : métro B interrompu
  Part-Dieu ↔ Oullins, travaux de nuit TER Lyon ↔ Saint-Étienne du 24 au 28 août.
- **Chatbot** : 5 réponses scriptées déterministes (mots-clés `remboursement`, `retard`,
  `option`, `carte avantage`, `paiement`, + les variantes `rembours`, `avantage`,
  `réduction`, `payer`, `carte bancaire`), sinon la réponse générique du bot. La réponse
  « option » explique la mécanique réellement implémentée dans le panier.
- **Notifications** : état vide conservé (aucune bannière étrangère, D59).

### Moteur déterministe (`SnMoteur`)

Aucun aléa, aucune date système, aucun réseau : les mêmes (origine, destination, jour)
donnent toujours les mêmes horaires, durées, numéros de train et prix.
20 liaisons au départ de Lyon Part-Dieu sont tabulées (durée, prix plein, transporteur,
matériel, escales) ; toute autre paire est dérivée d'un hachage stable de la chaîne.
Exemples produits : Lyon → Marseille TGV INOUI **1h47**, prix **39 → 59 €** selon l'horaire et
le jour, avec deux **OUIGO à 19 €** dans la journée ; Lyon → Saint-Étienne TER 0h48 ~13 € ;
Lyon → Annecy TER 1h52 ~27 €. Le prix mini de chaque jour affiché dans le bandeau de
résultats est calculé sur la même fonction — il ne peut donc pas mentir.
Le tableau des départs/arrivées est généré de la même façon (11 destinations pour Lyon
Part-Dieu, 1 à 2 retards, 1 supprimé, 1 parcours modifié selon la graine).

---

## 7. D92 — chaque affordance a une conséquence réelle

| Affordance | Conséquence |
|---|---|
| Champ « Où souhaitez-vous aller ? » | Écran de recherche de destination, filtrage **réel** sur la frappe parmi 25 villes/gares (insensible aux accents), puis écran Recherche pré-rempli |
| Bouton d'inversion ⇅ | Échange réellement Départ et Arrivée |
| « Aller : … » | Calendrier réel (août + septembre 2026), le jour et l'heure choisis pilotent les résultats |
| « Trajets directs » | Filtre réellement la liste (les trajets avec correspondance disparaissent) |
| Compteur « Voyageur » (1 à 6) | Multiplie réellement le prix affiché, le récap et le panier |
| Carte voyageur | Ouvre la Carte Avantage, dont la réduction est appliquée aux prix |
| Bandeau de jours | Change réellement la date et donc les horaires et les prix |
| « Afficher les trajets précédents / suivants » | Déplie réellement la liste des 10 circulations |
| Onglet « Bus ou covoit. » | Jeu de résultats BlaBlaCar réel (véhicule, conducteur, classe unique) |
| « Choisir cet aller à X € » | **Ajoute au panier partagé** (`SnEtat.partage`, persistant tant qu'on ne le vide pas) et pousse le panier |
| « Poser une option gratuitement » | **Crée réellement** un voyage « Option à payer avant le … » dans Billets › Vos voyages › À venir, et vide le panier. Persistant. Annulable depuis le détail du voyage |
| Assurance Oui / Non | Modifie réellement le total (1,05 € par voyageur) |
| « Retirer du panier » | Vide réellement le panier (état vide dédié) |
| « Valider et payer » | Écran Paiement réel → alerte D82-B, panier conservé |
| Pastille cyan sur l'onglet Billets | Apparaît uniquement quand le panier n'est pas vide, et l'onglet Billets affiche alors un rappel cliquable vers le panier |
| Recherche de gare | Filtre réellement les 22 gares ; « Vers … » filtre réellement le tableau des départs |
| Chips Grandes lignes / Bus, Départs / Arrivées | Quatre jeux de données réellement distincts |
| Interrupteurs des Paramètres et des Alertes billets | Écrivent dans `SnEtat.partage` (persistants), et Préférences d'affichage / Langue affichent la valeur choisie sur la ligne de Paramètres |
| « Enregistrer » (Identité) | Met réellement à jour le nom, la date de naissance et le téléphone partout dans l'app |
| Suggestions du bloc « Besoin d'aide ? » | Ouvrent le chatbot **avec la question déjà posée** et la réponse scriptée affichée |
| « Voir vos titres de transport » (Compte) | Bascule réellement sur l'onglet Billets |

---

## 8. Retraits (D92 / D82-C) — à arbitrer

Retirés parce qu'ils n'ont **aucune conséquence possible** ici. Rien n'est mort à l'écran :
l'affordance elle-même a disparu.

**Grille de services de l'accueil** (8 tuiles filmées → 4 conservées)
- `Itinéraires urbains` — nécessiterait une carte ; pas de MapKit, et aucune source ne
  documente le rendu SNCF de l'itinéraire pas-à-pas. *Utilité narrative possible : montrer
  un trajet Lyon intra-muros. À arbitrer.*
- `Titres urbains et régionaux` — aucun titre TCL dans le compte de Sarah, aucun écran filmé
  au-delà de la tuile.
- `Location de voiture` (lien externe dans les frames) et `Hôtels`.
- `+ de services` — page non filmée.

**Accueil / Billets / Offres**
- Bannière publicitaire de l'accueil (e001, e141, e196) et carrousels « Voyager moins cher »,
  « Les promos de la rentrée », « Bien plus que du train ! » (location, hôtel, titres urbains).
- Bouton `Importer` de l'onglet Billets — nécessiterait un import de fichier.
- Tuiles `Cartes et abos régionaux`, `Taxi et VTC`, `Paris et IDF` de « Vos cartes et titres
  urbains » — Sarah n'en possède aucun ; seule la tuile QR code cartes SNCF est réelle.
- `Offres régionales` et `Trouver l'offre faite pour vous` (e154) — parcours non filmé.
- Achat d'une carte (« Acheter une carte », e143/e144) — pas de tunnel d'achat de carte filmé.

**Recherche**
- `Ajouter le retour` — impliquerait un second jeu de résultats et un panier aller-retour.
  *Utilité narrative possible : un retour de Marseille. À arbitrer.*
- `Trajets via`, `Code de réduction`, `Motif du voyage`, `Réserver pour 10+ voyageurs`,
  `Voir les horaires uniquement`.
- `Animal` et `Vélo` dans « Qui voyage ? » — n'auraient modifié ni le prix ni le billet.
- Vignettes `Ajouter Maison` / `Ajouter Travail` — remplacées par les destinations récentes.
- `Activer la géolocalisation` (e007) — pas de localisation dans le prototype.

**Horaires en gare / Info trafic**
- `Enregistrer ce tableau des départs` — aucune destination de persistance crédible.
- `Plans des réseaux et lignes` (carte) et `Calendrier des travaux`.
- Onglet `Île-de-France` — remplacé par la région de Sarah (D59).

**Compte / Paramètres**
- `Espace pro`, `Agent SNCF, retraité, ayant-droit`, `Coordonnées pro`.
- `Communauté Connect & Vous` (lien externe), `Gestion des consentements` (page CMP),
  `Informations légales` (10 liens externes), `Changer le mot de passe`,
  `Ajouter une adresse` / `Modifier votre adresse e-mail` (l'adresse et l'e-mail sont
  affichés en lecture seule ; seule l'Identité est modifiable).
- `Ma Rétrainspective 2025` (officiel2, 21 → 23c) — hors période du jeu (août 2026).

**Paiement**
- `Chèque-Vacances Connect` et `Paiement en 3x avec Alma` (officiel/03_06) — Sarah n'a ni
  l'un ni l'autre ; seuls Apple Pay et sa Visa LCL restent.

**Covoiturage**
- Bouton `Réserver sur Blablacar` (e065) — sortie vers une app tierce. Remplacé par un
  encart explicatif sur l'écran de tarif : la liste et le détail restent réels, la
  réservation est décrite et non simulée.

---

## 9. Cas de registre pour LPProto

À insérer dans `LPProto.swift` : `case "sncf": ecransSncf()` dans le routeur principal,
puis la fonction suivante. Les clés `sncf#0` … `sncf#3` retombent sur le `default`, qui
instancie la racine `SncfVue(onglet:)` (Voyager / Billets / Offres / Compte) pour que la
barre d'onglets et `BarreHome` restent visibles.

```swift
@ViewBuilder
private func ecransSncf() -> some View {
    switch cle {
    case "sncf.recherche":
        SnEcranCapture {
            SnRechercheVue(depart: "Lyon Part-Dieu",
                           arrivee: "Marseille Saint-Charles", mode: .train)
        }
    case "sncf.destination":
        SnEcranCapture {
            SnDestinationVue(titre: "Rechercher", versRecherche: true, choisir: { _ in })
        }
    case "sncf.calendrier":
        SnEcranCapture { SnCalendrierVue(offset: 0, heure: 10) { _, _ in } }
    case "sncf.resultats":
        SnEcranCapture {
            SnResultatsVue(depart: "Lyon Part-Dieu", arrivee: "Marseille Saint-Charles",
                           offset: 0, voyageurs: 1, directs: false, mode: .train)
        }
    case "sncf.trajet":
        SnEcranCapture { SnTarifVue(trajet: SnCapture.trajet(), voyageurs: 1) }
    case "sncf.tarif":
        SnEcranCapture { SnConditionsVue() }
    case "sncf.train":
        SnEcranCapture { SnTrainVue(trajet: SnCapture.trajet()) }
    case "sncf.panier":
        SnEcranCapture { SnPanierVue() }
            .onAppear { SnCapture.preparerPanier() }
    case "sncf.paiement":
        SnEcranCapture { SnPaiementVue() }
            .onAppear { SnCapture.preparerPanier() }
    case "sncf.billet":
        SnEcranCapture { SnBilletVue(voyage: SnCapture.voyage()) }
    case "sncf.voyages":
        SnEcranCapture { SnVoyageVue(voyage: SnCapture.voyage()) }
    case "sncf.horaires":
        SnEcranCapture { SnHorairesVue(gare: "Lyon Part-Dieu") }
    case "sncf.gare":
        SnEcranCapture { SnGareRechercheVue() }
    case "sncf.trafic":
        SnEcranCapture { SnTraficVue() }
    case "sncf.perturbation":
        SnEcranCapture { SnPerturbationVue(perturbation: SnCapture.perturbation()) }
    case "sncf.compte":
        SnEcranCapture { SnCompteVue(onglet: .constant(3)) }
    case "sncf.coordonnees":
        SnEcranCapture { SnCoordonneesVue() }
    case "sncf.identite":
        SnEcranCapture { SnIdentiteVue { } }
    case "sncf.parametres":
        SnEcranCapture { SnParametresVue() }
    case "sncf.affichage":
        SnEcranCapture { SnAffichageVue() }
    case "sncf.cartes":
        SnEcranCapture { SnCartesReductionVue() }
    case "sncf.qr":
        SnEcranCapture { SnQrCartesVue() }
    case "sncf.paiements":
        SnEcranCapture { SnMoyensPaiementVue() }
    case "sncf.alertes":
        SnEcranCapture { SnAlertesBilletsVue() }
    case "sncf.compagnons":
        SnEcranCapture { SnCompagnonsVue() }
    case "sncf.offre":
        SnEcranCapture { SnOffreVue(offre: SnCapture.offre()) }
    case "sncf.alerte3117":
        SnEcranCapture { SnAlerteVue() }
    case "sncf.notifications":
        SnEcranCapture { SnNotificationsVue() }
    case "sncf.aide":
        SnEcranCapture { SnAideVue(question: "Comment fonctionne une option ?") }
    default:
        SncfVue(onglet: SnCapture.ongletDemande)
    }
}
```

`SnCapture` fournit les accesseurs NON optionnels (`etat()`, `trajet()`, `article()`,
`voyage()`, `perturbation()`, `offre()`, `ongletDemande`, `preparerPanier()`) : aucun indice
nu, aucune force-unwrap dans le registre.

---

## 10. Points de vigilance

1. **`.simultaneousGesture` sur le bouton « Choisir cet aller »** : c'est le seul endroit où
   une action (ajout au panier) et une poussée de navigation sont combinées. Si Joachim
   observe un ajout en double sur un double-tap, remplacer par un `Button` + carte de
   confirmation avec `NavigationLink` « Voir le panier ».
2. **Calendrier** : l'origine est codée en dur (mardi 18 août 2026 = offset 0, plage 0 → 43,
   soit jusqu'au 30 septembre 2026). Si l'époque du jeu bouge, une seule constante à revoir
   (`SnAgenda.date` / `SnAgenda.indexJour`).
3. **`SnBilletsVue.body`** contient exactement 10 vues dans son `VStack` : c'est la limite
   d'un `ViewBuilder`. Toute addition doit passer par un sous-groupe.
4. **`UnevenRoundedRectangle`** (silhouette de rame) est iOS 16+ : conforme à la cible iOS 17,
   mais c'est la seule API un peu récente du fichier.
5. **`Canvas`** est utilisé pour les deux QR codes ; s'il posait problème en capture
   simulateur, il se remplace par une grille de `Rectangle` (25 × 25).
6. **Prix « valable jusqu'à 21:23 »** est repris tel quel des frames (e042) : c'est un
   libellé fixe, non recalculé, pour rester conforme au filmé.
7. **Toulouse Matabiau** figure dans la liste des 25 gares recherchables : c'est une gare
   nationale que Sarah peut légitimement chercher, pas un reste du gabarit de Joachim
   (dont la gare par défaut était Auch). Le vérificateur documente cette exception.
8. **Aucun `navigationDestination`** : si un écran devait un jour être poussé depuis une
   `List` avec valeur, il faudra en ajouter **un seul**, au niveau du `NavigationStack` de
   `SncfVue`.
