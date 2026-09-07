# Uber — livraison v1 (vague B, 07/09/2026)

Fichier : `src/UberApp.swift` (3 269 lignes, 1 seul fichier, `import SwiftUI` seul).
Préfixe de types : **Ub** (70 types `Ub*`, + la vue racine `UberVue` et l'énumération de
données `DonneesUb`, dérogations documentées dans le vérificateur).
Vérificateur : `src/verif_uber.py` → **VERT**.

---

## 1. Écrans FILMÉS reproduits (D67)

| Écran | Type | Frames de référence |
|---|---|---|
| Accueil (volet Uber) — champ « Où allez-vous ? », pilule « Plus tard », 2 adresses récentes, « Pour vous » | `UbAccueilVue` | e001, e030, e033, e055, e056 |
| Accueil (volet Uber Eats) — « Passez commande sur Uber Eats », « Commandez à nouveau » | `UbAccueilVue` | e001, e034, e035, e037 |
| « Planifiez votre course » — pilules Prise en charge / Pour moi, champ départ + destination, raccourcis, suggestions avec distance | `UbDestinationVue` | e002, e014, e015, e026, e027, e029, e040, e041 |
| Choix de course — carte + itinéraire noir, pastille « n MIN » + adresse, « Générez 5 % en crédit », UberX / Wait & Save / Priority (« Plus rapide ») / Uber Pet, Apple Pay, bouton noir « Choisissez X » + bouton calendrier | `UbCoursesVue`, `UbLigneOption`, `UbPastilleDestination` | e004 → e013, e017 → e021, e025, e031, e032 |
| Accroches « Les courses que vous pourriez apprécier » (Économique rapide et fiable / Économisez en attendant / Moins de temps d'attente / Courses adaptées aux animaux) | `UbLigneOption` | e009, e010, e020, e023 |
| « Choisissez une heure » — segment Prise en charge à / Dépose à, 3 roues, « Heure de dépose : … CEST · Trajet d'environ n min », politique d'annulation, Continuer | `UbHeureVue` | e022, e042 |
| Page **Reserve** — bannière illustrée, titre, 2 puces, « Réservez une course » | `UbReserveVue` | e039 |
| **Services** — « Allez n'importe où », « Faites-vous livrer ce que vous voulez » | `UbServicesVue`, `UbTuileService` | e038, e044 |
| **Activité** — grand titre, « À venir » (état vide filmé conservé), « Passées » | `UbActiviteVue` | e045, e046, e047, e049 |
| **Compte** — nom + note + avatar, 4 tuiles Aide/Wallet/Sécurité/Messages, cartes Uber One / Contrôle de sécurité n/4 / Économies de CO₂ 0 g / Paramètres, liste, numéro de version | `UbCompteVue` | e050, e051, e052 |
| Barre d'onglets flottante en capsule blanche Accueil / Services / Activité / Compte | `UbBarreOnglets` | e001, e045, e050 |

**Palette mesurée au pixel** (`UbTeinte`, chaque constante commente sa frame source) :
fond `#FFFFFF` (e001 254,254,254) · tuiles `#F0F0F0` (e050 240,240,240) · bord de carte
`#EDEDED` (e001 237,237,237) · fond du sélecteur `#E7E7E7` (e022) · bleu « Plus rapide »
`#276EF1` (e004 35,98,239) · rouge « Générez 5 % » `#C00609` (e004 192,6,9) · fond de carte
`#E1E5E8` (e004 225,229,232).

## 2. Écrans issus des captures officielles (D93)

| Écran | Type | Source |
|---|---|---|
| « Confirmez votre point de prise en charge » — carte, pilule bleue « Point de prise en charge », marqueur carré bleu, feuille + bouton noir | `UbConfirmationVue` | `refs/officiel2/uber/21_appstore_gb.jpg` |
| « Boîte à outils de sécurité » — Gérez les contacts autorisés / Vérifiez votre course (NIP) / RideCheck | `UbSecuriteVue` | `refs/officiel2/uber/30_appstore_cafr.jpg` |
| Uber One — bannière dorée, logo « 1 », 4 avantages | `UbUberOneVue` | `refs/officiel2/uber/26_appstore_cafr.jpg` |

## 3. Écrans ASSEMBLÉS à partir de briques filmées (aucun écran inventé de mémoire)

Joachim n'avait **aucune course dans son historique** (son onglet Activité ne contient que
des commandes Uber Eats) : le détail d'une course passée et le détail d'une réservation
n'existent donc dans aucune source. Plutôt que de les inventer OU de retirer l'affordance
(ce qui aurait vidé l'indice narratif du 17 juillet), ils sont **composés uniquement de
briques documentées** :

- `UbCourseVue` : carte + itinéraire noir (e004/e017), colonne départ→arrivée avec les jalons
  rond/carré du champ d'itinéraire (e002), typographie de prix (e004), rangées de reçu
  (gabarit des rangées clé/valeur d'e052), bouton « Obtenir de l'aide » (rangée d'e052).
- `UbReservationVue` : mêmes briques + bouton contour noir « Annuler la réservation ».

À arbitrer avec Joachim s'il refilme l'app avec un historique de courses.

## 4. Écrans NON faits

- Course en direct (chauffeur en approche, suivi, plaque, annulation) : hors périmètre — on ne
  simule pas une course en cours (choix de mission). Le parcours s'arrête sur l'alerte
  « Aucun chauffeur disponible » (D82-B).
- Notation de fin de course / pourboire (`19_appstore_gb`) : sans course en direct, l'écran
  n'a pas d'amont.
- Transport en commun, Location de voiture (partenaires Avis/Hertz), Uber pour ados, Famille,
  Uber for Business, Groupes enregistrés : aucune donnée de Sarah, aucune conséquence possible.

## 5. Retraits D92 (à arbitrer si une histoire en a besoin)

| Retiré | Où c'était | Pourquoi |
|---|---|---|
| Onglet haut « Courses » (épicerie) | e001 | aucun catalogue de courses alimentaires ne peut exister ici |
| « Pour vous » : Location, Alcool, et le carrousel complet | e001 | rien derrière ; Repas est conservé et déclenche le message Eats |
| Services : Seniors, Teens, Location, Courses, Boutique, Hygiène, Animaux | e038 | 7 tuiles mortes ; Course / Réserver / Repas / Alcool conservées |
| « En faire plus avec Uber » (Taxis à la demande, Confort), « Restaurants populaires à proximité », « Location de voiture facile » | e035, e036 | bandeaux publicitaires sans destination |
| Compte : « Vérif. de confidentialité » (visite guidée), Uber pour ados, Famille, Mode simplifié, Envoi de cadeau | e050, e051 | remplacés par une carte **Paramètres** réelle ; la confidentialité existe dans Paramètres |
| Compte, liste : « Générez des revenus », Groupes enregistrés, profil professionnel, Uber for Business, Promotions sur Eats, Articles préférés sur Eats, Gérer le compte Uber, Applications et site Web, Informations sur l'entreprise | e052 | ne laissent que « Uber One » et « Mentions légales », tous deux réels |
| Chevrons « ▾ » des pilules « Prise en charge immédiate » / « Pour moi » | e002 | un chevron promet un menu ; les pilules restent en affichage d'état |
| Bouton d'abonnement Uber One | 26_appstore_cafr | souscrire n'aurait aucune conséquence ; la page indique « Vous n'êtes pas abonnée » |
| Bouton rond « + » (ajout d'un arrêt) à droite du champ d'itinéraire | e002 | RETIRÉ (D82-C) : un arrêt intermédiaire n'a aucune conséquence possible ici |
| Écran de chargement « Recherche de réservations en cours » | e043 | état transitoire, sans intérêt de jeu |

## 6. Contenu narratif choisi (D59) et pourquoi

- **Domicile** 14 rue des Fantasques, 69001 Lyon. **Travail** : *6 rue de la République, 69002*
  — adresse de bureau crédible en Presqu'île, cohérente avec une employée administrative.
- **Adresses récentes de l'accueil** : Gare Lyon Part-Dieu et LCL Agence Lyon Terreaux — les
  deux lieux de l'arnaque (départ vers Marseille, agence du virement).
- **12 lieux lyonnais** dans la recherche, filtrés RÉELLEMENT sur la frappe (insensible à la
  casse et aux accents) : Part-Dieu, LCL Terreaux, Chez Chloé (12 rue Burdeau), Le resto des
  quais (Quai Saint-Antoine), 6 rue de la République, Perrache, Saint-Exupéry, Tête d'Or,
  Hôpital Croix-Rousse, Bellecour, Vieux Lyon, CC Part-Dieu.
- **Courses passées** (Activité › Passées), toutes en 2026 :
  - 12 août 19:05 — Domicile → Gare Part-Dieu — 14,20 €
  - 28 juillet 22:10 — Quai Saint-Antoine → Domicile — 10,10 €
  - **17 juillet 11:35 — Place des Terreaux → Gare Part-Dieu — 13,05 €**
  - **17 juillet 10:52 — Domicile → LCL Agence Terreaux — 8,55 €**
  - 5 juillet 23:40 — Chez Chloé → Domicile — 8,20 €
  Les deux courses du 17 juillet sont l'**indice** : Sarah va à son agence LCL le matin (le jour
  du virement de 4 850 €), puis file à Part-Dieu (le bureau Western Union de la gare). Le
  recoupement se fait avec Ma Banque et Mail.
- **Commandes Uber Eats passées** : Pizzeria Nonna (9 août, 23,40 €), Sushi Croix-Rousse
  (23 juillet, 18,90 €), Le Bouchon des Pentes (2 juillet, 15,60 €).
- **Activité › À venir** : UNE course planifiée, **« Ven. 28 août · 05:40 — 14 rue des
  Fantasques → Gare Lyon Part-Dieu, UberX, 14,20 € »**. *Correction de calendrier* : le
  28 août 2026 tombe un **vendredi**, pas un jeudi ; la brief disait « Jeu. 28 août ». C'est
  le trajet vers Marseille (« Marseille — le 28 ⚓️ »), cohérent avec le billet SNCF.
  Tap → `UbReservationVue` → « Annuler la réservation » → alerte de confirmation
  (« Conserver » / « Annuler la course ») → la réservation **disparaît réellement** et
  l'onglet Activité bascule sur l'état vide filmé. **Irréversible**, comme demandé.
- **Compte** : Sarah Levasseur, note **4,92**, avatar silhouette. Wallet : Visa LCL •••• 4417
  (par défaut) + Apple Pay, crédit Uber 0,00 €. Uber One : non abonnée, bannière promo
  conservée. Économies de CO₂ : 0 g. Version **v3.741.10002**.
- **Messages (2)** : « 5 % en crédit Uber sur vos courses cet été » (non lu, pastille rouge sur
  la tuile Messages) et « Vos reçus sont désormais envoyés par e-mail » (lu). Aucun contenu
  d'arnaque : Uber est un **témoin neutre** du récit, sa valeur est le journal de déplacements.

## 7. Ce qui a une conséquence réelle (D92)

- Champ « Où allez-vous ? » → saisie **réellement filtrante** → écran de choix de course avec
  **prix déterministes** : `prix UberX = (6,20 + 1,95 × km)` arrondi au dixième, Wait & Save
  ×0,88, Priority ×1,17, Uber Pet ×1,28 ; horaires = heure de jeu 19:42 + `6 + 1,9 × km` min.
  Part-Dieu (4,1 km) → 14,20 € · Saint-Exupéry (29 km) → 62,75 €. Le même lieu redonne
  toujours le même prix (aucun aléa).
- Sélection d'une option → le libellé du bouton noir change (« Choisissez Wait & Save »…).
- « Choisissez X » → **Confirmez votre point de prise en charge** → « Confirmer la prise en
  charge » → alerte iOS **« Aucun chauffeur disponible à proximité pour le moment »**
  (D82-B, message local qui disparaît en quittant l'écran). Aucune course simulée en direct.
- « Plus tard » (accueil), « Réserver » (Pour vous / Services), page Reserve, bouton calendrier
  de l'écran de course → **`UbHeureVue`** : segment Prise en charge/Dépose fonctionnel (le
  résumé recalcule l'heure inverse), 14 jours réels du 17 au 30 août → Continuer → destination
  → course → **« Réservez UberX » CRÉE une réservation** dans `UbEtat.partage`, immédiatement
  visible dans Activité › À venir, et persistante pour toute la session.
- Ligne Apple Pay → Wallet. Tuiles Aide / Wallet / Sécurité / Messages → 4 écrans réels.
- Sécurité : les deux interrupteurs (contacts autorisés, code de vérification) **font varier le
  compteur « n/4 »** affiché sur la carte du Compte — compteur = contenu réellement acquis.
- Paramètres : Coordonnées (valeurs de Sarah), Confidentialité, 2 interrupteurs de notifications,
  sélecteur d'apparence — tous persistants dans `UbEtat.partage`.
- Messages : la pastille rouge disparaît quand le message est ouvert.
- **Uber Eats** : choix **D82-B** (message crédible) plutôt que le retrait du bouton
  « Commander ». Justification : la section Eats et les commandes passées sont une *donnée
  narrative* (Sarah commande seule tard le soir — 9 août 23:40 chez elle) qu'il ne faut pas
  perdre ; supprimer le bouton « Commander » aurait déformé la maquette filmée sans rien
  gagner, alors qu'une alerte sobre (« Uber Eats indisponible dans cette zone pour le
  moment ») ferme proprement la porte. Le même message couvre Repas et Alcool.

## 8. Cartes

Aucun MapKit, aucune image embarquée. `UbCarteVue` dessine la carte dans un `Canvas` :
pâtés de maisons `#D8DCE0` sur fond `#E1E5E8`, fleuve `#C9D6E8` (Saône/Rhône), trame de rues
blanches, itinéraire noir cerné de blanc, pastille ronde de départ et carré d'arrivée — le
tout produit par un générateur pseudo-aléatoire **déterministe** (`UbAlea`, LCG 64 bits) : une
graine = toujours la même carte, donc des captures Miroir stables.

## 9. Cas du registre LPProto (à coller tels quels)

```swift
case "uber#0": UberVue(onglet: 0).coquilleSarah(claire: true)
case "uber#1": UberVue(onglet: 1).coquilleSarah(claire: true)
case "uber#2": UberVue(onglet: 2).coquilleSarah(claire: true)
case "uber#3": UberVue(onglet: 3).coquilleSarah(claire: true)
case "uber.destination": UbEcranCapture { UbDestinationVue(quand: "") }
case "uber.courses": UbEcranCapture { UbCoursesVue(destination: UbCapture.lieu(), quand: "") }
case "uber.reserver": UbEcranCapture { UbReserveVue() }
case "uber.heure": UbEcranCapture { UbHeureVue(destination: UbCapture.lieu()) }
case "uber.confirmation": UbEcranCapture { UbConfirmationVue(destination: UbCapture.lieu(), option: UbCapture.option()) }
case "uber.activite": UbEcranCapture { UbActiviteVue() }
case "uber.course": UbEcranCapture { UbCourseVue(course: UbCapture.course()) }
case "uber.reservation": UbEcranCapture { UbReservationVue(reservation: UbCapture.reservation()) }
case "uber.compte": UbEcranCapture { UbCompteVue() }
case "uber.wallet": UbEcranCapture { UbWalletVue() }
case "uber.parametres": UbEcranCapture { UbParametresVue() }
case "uber.coordonnees": UbEcranCapture { UbCoordonneesVue() }
case "uber.aide": UbEcranCapture { UbAideVue() }
case "uber.securite": UbEcranCapture { UbSecuriteVue() }
case "uber.messages": UbEcranCapture { UbMessagesVue() }
case "uber.message": UbEcranCapture { UbMessageVue(message: UbCapture.message()) }
case "uber.uberone": UbEcranCapture { UbUberOneVue() }
case "uber.services": UbEcranCapture { UbServicesVue() }
default: UberVue(onglet: UbCapture.ongletDemande).coquilleSarah(claire: true)
```

Note : `uber#0..3` passent par la coquille (barre d'onglets flottante + BarreHome visibles).
`uber.activite`, `uber.compte`, `uber.services` capturent le **contenu** de l'onglet sans la
barre d'onglets — utiliser `uber#1/#2/#3` pour la vue complète.
`UbCapture` expose `etat()`, `lieu()`, `course()`, `reservation()`, `option()`, `message()`,
`ongletDemande` — tous NON optionnels (aucun indice nu, aucune force-unwrap).

## 10. Points de vigilance

1. **`UbHeureVue` utilise trois `Picker` en `.pickerStyle(.wheel)`** dans un `HStack`
   (180 + 80 + 80 pt, `.labelsHidden()`, hauteur 190). Si le rendu déborde sur un petit écran,
   réduire à 170/70/70.
2. **`UnevenRoundedRectangle`** (feuilles basses des écrans de course et de confirmation) est
   une API **iOS 17.0** — conforme à la cible, mais à ne pas rétroporter en iOS 16.
3. Le `Canvas` est redessiné à chaque changement de taille ; il y en a jusqu'à 8 simultanés
   dans Activité (vignettes 56×56). Si un ralentissement apparaît sur appareil ancien,
   ajouter `.drawingGroup()` sur `UbCarteVue`.
4. **Aucun `.sheet` / `.fullScreenCover` / `.confirmationDialog`** : tout est en navigation
   poussée ou en `.alert` simple, la BarreHome reste visible partout (bug Facebook 279).
5. **Aucun `navigationDestination`** : toute la navigation passe par des `NavigationLink`
   à destination directe — donc aucun risque de conflit avec la règle « un seul
   `navigationDestination` par `NavigationStack` ».
6. L'heure de jeu est figée à **19:42** (`UbTarifs.heureBase`) et le calendrier de réservation
   démarre à « Aujourd'hui = lun. 17 août ». Si la date de jeu bouge, ce sont les deux seuls
   points à modifier (plus la liste `jours` de `UbHeureVue`).
7. Aucun élément purement décoratif ne subsiste : chaque bouton, pilule ou rangée visible mène
   à un écran réel, change un état persistant, ou déclenche l'un des deux messages D82-B
   (Uber Eats indisponible / Aucun chauffeur disponible).
