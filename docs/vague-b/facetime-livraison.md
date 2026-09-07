# FaceTime — livraison (vague B, 07/09/2026)

- Fichier : `src/FaceTimeApp.swift` (1 seul fichier, `import SwiftUI` + `import UIKit`, 1841 lignes)
- Vue racine : `FaceTimeVue()` — déjà attendue par `LPProto.swift` (l. 450, `ecransFacetime()`)
- Préfixe de types : **Ft** (35 types, aucun en collision — vérifié)
- Vérificateur : `src/verif_facetime.py` → **VERT**

---

## 1. Sources utilisées (D67 / D93)

Joachim n'a **aucun** enregistrement de FaceTime. Seule la 2e source D93 a été utilisée :
les captures officielles Apple de `refs/officiel/facetime/` (9) et `refs/officiel2/facetime/` (11,
cf. `SOURCES.md` : support.apple.com fr-fr/en-us + 9to5mac). Toutes ont été regardées en grand.
**Aucun écran n'a été inventé de mémoire.**

| Écran livré | Capture de référence | Ce qui en est repris |
|---|---|---|
| Liste des récents (`FtListeVue`) | `02_appleguide_recents_remplie.png`, `01_..._annotee.png`, `03_..._en.jpg` | fond noir, capsule « Modifier » à gauche, rond de filtre à droite, titre « FaceTime » centré (03), grille 2 colonnes de tuiles-affiches, nom en haut (rouge = non abouti), pastille verte = message enregistré (sémantique de 01 annotée), statut 2 lignes en bas à gauche (« ↗ Vidéo » / « Hier », « ▶ 0:22 » / « Hier », « Suggestions »), bouton rond translucide en bas à droite, bouton vert flottant « Nouvel appel » |
| Feuille « Nouveau FaceTime » (`FtNouveauVue`) | `04_appleguide_nouveau_facetime_sheet.png` | poignée + titre + croix, ligne « À : » avec **jetons verts**, bouton « + » à droite, section « Suggestions » avec avatars ronds + prénoms, rangée basse : rond lien / capsule verte « FaceTime » / rond téléphone vert |
| Appel sortant (`FtAppelVue`, phase 1) | `05_appleguide_appel_sortant_indisponible.png` | fond noir, grand avatar rond centré, nom, sous-titre gris, un seul bouton rouge en bas |
| « X est indisponible » (`FtAppelVue`, phase 2) | `05_...` | libellé exact « Marc est indisponible » + « FaceTime vidéo », **Rappeler** (vert, icône caméra) / **Enregistrer une vidéo** (blanc, point rouge, 2 lignes) / **Fermer** (gris, pleine largeur) |
| Enregistrement d'un message vidéo (`FtEnregistrementVue`) | `08_appleguide_message_video_enregistrement.png` | barre haute « Annuler » / « À Marc » / capsule « Enregistrer », grand rond blanc avec **flèche verte** en bas, « Reprendre » à droite, bouton lecture au centre en relecture |
| Viseur sombre granuleux | `06_appleguide_appel_en_cours_portrait.png`, `11_9to5mac_controles_appel_en.jpg` | rendu « retour caméra » (pas de caméra réelle), même langage que `AppelVideoVue` du fichier partagé |
| Fiche détail (`FtDetailVue`) | *aucune source FaceTime* | construite dans la langue de l'app **Téléphone validée** (`TelFicheVue`) : avatar, nom, identifiant, 3 ronds d'action, cartes sombres arrondies |
| Lien FaceTime (`FtLienVue`) | *aucune source* (SOURCES.md §3) | on ne reproduit **pas** l'écran d'Apple : feuille minimale maison, sobre |

### Écrans NON faits (D82-C — l'affordance qui y mène a été retirée)
- **Appel entrant plein écran** et **bannière d'appel entrant** : non trouvés (SOURCES.md §5 et §6). Aucun appel entrant n'est jouable dans FaceTime.
- **Appel de groupe en cours** (`10_...`) : la grille à 4 n'est pas reproduite — l'app permet plusieurs destinataires mais l'appel n'aboutit jamais, donc l'écran de groupe en cours n'existe pas.
- **Appel FaceTime en cours** (`06_...`) : personne ne décroche (règle du 16/08), donc aucun appel ne se connecte ; l'écran « en cours » n'est jamais atteint. Seul son **viseur** est réutilisé pour l'enregistrement.
- **Effets / menu caméra** (Studio Light, filtres) : non trouvés (SOURCES.md §4) — bouton « ⋯ » absent.
- **Réglages FaceTime** (`07_...`) : hors périmètre (c'est l'app Réglages). L'icône de filtre n'ouvre donc PAS des réglages mais un menu **Tous / Manqués** réel.
- **Bannière « Permuter l'appareil »** (`09_...`) : bonus sans usage narratif — non fait.
- **Liste vide** : non trouvée en capture, mais l'état vide est atteignable après suppressions ; rendu sobre maison (icône + une ligne), assumé.

---

## 2. Contenu narratif de Sarah (D59) et pourquoi

Aujourd'hui dans le jeu ≈ **lundi 17 août 2026** ; « Hier » = dimanche 16 août.
Tout est dans `enum DonneesFt` (remplaçable) — aucune donnée de gabarit.

### Le journal (`DonneesFt.appels()`, ordre chronologique inverse)

| # | Contact | Type | Sens | Issue | Date | Heure | Durée |
|---|---|---|---|---|---|---|---|
| 1 | Marc ❤️ | vidéo | sortant | **Sans réponse** | 16 août | 22:05 | — |
| 2 | Chloé | vidéo | sortant | abouti | 16 août | 21:12 | 38 min |
| 3 | Maman | audio | entrant | abouti | 16 août | 11:02 | 27 min |
| 4 | Julie | vidéo | entrant | **Manqué** | 15 août | 18:47 | — |
| 5 | Chloé | vidéo | entrant | abouti | 14 août | 22:40 | 1 h 04 |
| 6 | Chloé | vidéo | sortant | abouti | 9 août | 20:05 | 22 min |
| 7 | Maman | audio | sortant | abouti | 9 août | 11:15 | 31 min |
| 8 | Maman | audio | entrant | abouti | 2 août | 10:58 | 24 min |
| 9 | Thomas | vidéo | entrant | abouti | 30 juil. | 19:22 | 12 min |
| 10 | Marc ❤️ | vidéo | sortant | **Annulé** | 17 juil. | 21:48 | — |
| 11 | Marc ❤️ | vidéo | sortant | **Sans réponse** | 5 juil. | 20:31 | — |
| 12 | Marc ❤️ | **audio** | **entrant** | abouti | 10 mai | 22:14 | **4 min** |
| 13 | Marc ❤️ | vidéo | sortant | **Sans réponse** | 6 mai | 21:03 | — |
| 14 | Marc ❤️ | vidéo | sortant | **Annulé** | 20 avr. | 22:37 | — |
| 15 | Marc ❤️ | vidéo | sortant | **Sans réponse** | 12 mars | 23:19 | — |

**L'indice** : 6 tentatives vidéo sortantes vers Marc (12 mars, 20 avr., 6 mai, 5 juil., 17 juil.,
16 août), **aucune** aboutie ; un seul contact réel, en **audio**, 4 min, le 10 mai. Marc ne montre
jamais son visage. En face, Chloé (3 vidéos abouties, dont 1 h 04), Maman (3 audios du dimanche) et
Thomas se voient sans difficulté : la comparaison est le raisonnement que le joueur doit faire.

Cohérences inter-apps volontaires :
- **5 juil. 20:31** : la tentative FaceTime échoue ; c'est ce soir-là que Téléphone enregistre une
  visio **WhatsApp de 19 secondes** (`DonneesTel.recents`, « Marc ❤️ · WhatsApp vidéo · 5 juil. »).
  Le joueur qui recoupe voit que la seule « visio » de 19 s n'a jamais eu lieu sur FaceTime.
- **6 mai** : Téléphone a déjà un « WhatsApp vidéo manqué · 6 mai » — même soir, même échec.
- Identifiants FaceTime = les numéros de `DonneesTel.contacts` ; Camille Roux réutilise l'e-mail de
  PayPal (`camille.roux69@gmail.com`).

### Message vidéo
- **Chloé → Sarah, 0:22, hier** : seul message enregistré. Sa tuile porte la pastille verte (non
  écouté) et la vignette « ▶ 0:22 ». À la lecture : **pas de fausse vidéo** — lecteur sombre, avatar,
  chrono, et la transcription qui se déroule en 3 temps :
  « Sarah, rappelle-moi, faut qu'on parle de Marc, sérieux… » /
  « J'ai regardé ses photos, celle du bateau, elle traîne partout sur Internet. » /
  « Je t'embête pas pour rien, promis. Rappelle-moi ce soir. »
  Une fois lancé, le message est marqué écouté et la pastille verte disparaît (persistant).
- **Marc → Sarah : AUCUN**, ni vidéo ni vocal (voir « retraits à arbitrer »).

### Tuile « Suggestions »
`Camille Roux` (jamais appelée en FaceTime) fournit la tuile « Suggestions » vue sur la capture 02,
sans mentir sur l'historique. Elle est placée en fin de grille pour ne pas casser l'ordre
chronologique inverse.

---

## 3. Ce qui marche vraiment (D92)

| Affordance | Conséquence réelle |
|---|---|
| Tap sur une tuile / sur son bouton rond | lance l'appel, dans le **mode du dernier appel** de ce contact (vidéo ou audio) |
| Appui long sur une tuile / bouton ⓘ | pousse `FtDetailVue` (NavigationStack, chevron de retour) |
| ⓘ → 3 ronds | FaceTime vidéo / FaceTime audio / **Message** → `Routeur.partage.allerMessages()` (l'app Messages s'ouvre pour de bon) |
| ⓘ → carte « Tous les appels FaceTime » | **tout** l'historique du contact, issue par issue — le mur de « Sans réponse » de Marc |
| Filtre (rond en haut à droite) | menu **Tous / Manqués** ; « Manqués » = tout appel non abouti (manqué, sans réponse, annulé) → il ne reste que **Marc et Julie**. Le rond devient vert quand le filtre est actif |
| « Modifier » | mode suppression réel : pastille rouge sur chaque tuile → **alerte de confirmation** → tout l'historique du contact disparaît, **persistant** (`FtEtat.partage`) |
| « Nouvel appel » | feuille « Nouveau FaceTime » (recouvrement interne, monte du bas) |
| Champ « À : » | **filtrage réel** sur les 7 contacts de Sarah (nom **et** identifiant), jetons verts retirables, `+` déplie la liste complète, Entrée ajoute le premier résultat |
| FaceTime / téléphone (feuille) | grisés tant qu'aucun destinataire, puis lancent l'appel vidéo / audio (plusieurs destinataires acceptés → « Chloé et Julie sont indisponibles ») |
| Bouton lien | feuille « Lien FaceTime » + **Copier** → presse-papiers RÉEL, le bouton devient « Lien copié » |
| Écran d'appel | « Appel FaceTime vidéo… » (0-2 s) → « sonnerie… » (2-7 s) → **« X est indisponible »**. Croix rouge = raccrocher |
| Rappeler | relance vraiment la séquence |
| Enregistrer une vidéo | écran d'enregistrement : décompte 3-2-1, chrono, arrêt, relecture, **flèche verte = Envoyer** |
| Envoi du message vidéo | le message **et** l'appel sortant sont insérés dans `FtEtat.partage` : la tuile du contact remonte en tête avec « ↗ Vidéo · À l'instant », et la fiche détail affiche « Message vidéo envoyé ». **Persistant.** |

Contraintes de coque respectées : `BarreHome` dessinée par l'app et toujours au-dessus de tout ;
**aucun** `.sheet` / `.fullScreenCover` / `.confirmationDialog` (toutes les feuilles sont des
recouvrements de la ZStack racine) ; un seul `.navigationDestination` ; pas de status bar ; pas de
micro de dictée ; retour = chevron ; aucun état de feuille ne survit à la sortie de l'écran.

---

## 4. Cas de registre pour LPProto

À injecter à la place du marqueur `//@@FACETIME@@` dans `ecransFacetime()` (`LPProto.swift`, l. 449) :

```swift
case "facetime#0":
    FaceTimeVue().coquilleSarah()
case "facetime.nouveau":
    FtEcranCapture { FtNouveauVue() }
case "facetime.appel":
    FtEcranCapture { FtAppelVue(noms: ["Marc ❤️"], mode: .video) }
case "facetime.indisponible":
    FtEcranCapture { FtAppelVue(noms: ["Marc ❤️"], mode: .video, indisponibleInitiale: true) }
case "facetime.enregistrement":
    FtEcranCapture { FtEnregistrementVue(destinataire: "Marc ❤️", phaseInitiale: .relecture) }
case "facetime.messagevideo":
    FtEcranCapture { FtLecteurMessageVue(message: FtCapture.message()) }
case "facetime.detail":
    FtEcranCapture { FtDetailVue(appel: FtCapture.appel()) }
case "facetime.lien":
    FtEcranCapture { FtLienVue() }
case "facetime.modifier":
    FtEcranCapture { FtListeVue(chemin: .constant([]), editionInitiale: true) }
```

`FtCapture.etat()`, `FtCapture.appel()` (le dernier appel vers Marc), `FtCapture.message()` (le
message de Chloé) et `FtCapture.contact()` (Chloé) sont des accesseurs **non optionnels**, sans
force-unwrap ni indice nu. `FtEcranCapture` restitue la `BarreHome` sur les captures isolées.

---

## 5. Retraits à arbitrer (utilité narrative possible)

1. **Message VOCAL FaceTime de Marc** — demandé explicitement de ne pas l'implémenter. Il serait
   pourtant la pièce la plus forte de l'app (entendre sa voix sans jamais voir son visage, et une
   tuile « Messagerie · … » comme celle d'Elton sur la capture 02, qui existe donc en source).
   Coût : un mp3 + 8 lignes. **À arbitrer avec Joachim.**
2. **Appel FaceTime entrant de Marc** (bannière ou plein écran) : aucune capture officielle → non
   fait. Si Joachim veut un jour un appel « histoire » entrant (le seul que Sarah décrocherait), il
   faudra d'abord une source, ou réutiliser la structure de `AppelTelVue` déjà validée.
3. **Appel de groupe** (« Les filles ») : la grille à 4 existe en source (`10_...`). Non faite parce
   qu'aucun appel n'aboutit ; deviendrait pertinente si un appel « histoire » était autorisé.
4. **Réglages FaceTime** (`07_...`) : source disponible, mais l'écran appartient à l'app Réglages.
   Si le scénario a besoin de « Marc a été bloqué » ou « FaceTime désactivé », c'est là qu'il faudra
   le mettre.
5. **Bouton « ⋯ » / effets caméra** de l'appel en cours : retiré faute de source.
6. **Partage du lien FaceTime** vers Messages/WhatsApp : la feuille ne fait que copier. Un vrai
   partage (via `FeuillePartage`) serait possible si un scénario en a besoin.

---

## 6. Points de vigilance

- **Pas de compilateur ici.** `src/verif_facetime.py` couvre : accolades/parenthèses/crochets
  équilibrés hors chaînes et commentaires, `.sheet`/`.fullScreenCover`/`.confirmationDialog`/
  `.popover`, APIs iOS 18+/26 (`@Entry`, `Tab(`, `.glassEffect`, `.presentationSizing`,
  `.tabViewStyle(.sidebarAdaptable)`…), `.foregroundColor` et `NavigationView` dépréciés,
  `Task.sleep` sans `try?`, ternaires de style non typés (`? .a : .b`),
  `.background(Color.opacity(…), in:)` ambigu, un seul `navigationDestination`, préfixe `Ft` sur
  tous les types / fonctions / variables globales, redéfinition d'un helper partagé
  (`BarreHome`, `AvatarSilhouette`, `Haptique`, `ErreurLambda`, `LecteurAudio`, `AppelVue`,
  `AppelVideoVue`, `RondAppel`, `Routeur`, `extension Color`), clés de dictionnaire en double,
  `body` de plus de 60 lignes, `@Published` hors `ObservableObject`, imports non autorisés,
  et gabarits D59 dans les textes affichés. Le script a été **auto-testé** sur une copie mutée
  (accolade en trop, `.sheet`, ternaire non typé, préfixe manquant) : les 4 mutations sont détectées.
- **Helpers partagés réutilisés, jamais redéfinis** : `BarreHome`, `AvatarSilhouette(taille:image:)`
  (avec l'image `AvatarMarc`), `Haptique.leger()`, `Color(hex:)`, `Routeur.partage.allerMessages()`.
  `AppelVue` / `AppelVideoVue` / `RondAppel` / `LecteurAudio` n'ont **pas** été réutilisés : ils sont
  écrits pour `.fullScreenCover` (ils appellent `dismiss()`), ce qui est interdit ici, et leur habillage
  est celui de WhatsApp, pas de FaceTime. Les écrans d'appel FaceTime sont donc des recouvrements
  `Ft…` autonomes, mais ils suivent exactement le même minutage que `AppelTelVue` (D52/D53).
- **Aucun fichier audio** n'est requis : le message vidéo de Chloé est un lecteur + transcription.
  Si un mp3 est ajouté plus tard, brancher `LecteurAudio.partage.bascule(_:)` dans
  `FtLecteurMessageVue.controles` suffira.
- **`Routeur.partage.allerMessages()`** ouvre l'app Messages sans cibler la conversation : il
  n'existe pas de méthode `allerMessages(conversation:)` dans `LPProto.swift`. Si elle est ajoutée,
  un seul appel à changer (`FtDetailVue.actions`).
- Le titre « FaceTime » centré vient de la capture **en-us** (`03`) ; la capture fr (`02`) n'en montre
  pas. Si Joachim préfère la barre fr stricte, supprimer les deux lignes du `Text("FaceTime")` dans
  `FtListeVue.barreHaut`.
- Le bouton rond des tuiles est translucide partout (majorité des cas de la capture 02) ; le vert est
  réservé au bouton flottant « Nouvel appel ».
- La grille utilise un ratio de tuile uniforme (0,74) ; la capture 02 montre des hauteurs légèrement
  décalées d'une rangée à l'autre — écart assumé pour la robustesse du `LazyVGrid`.
