# Audit Messenger — Lost Phone

Date : 2026-09-03 · Auditeur : agent d'audit · Doctrine : D67 (référence = les enregistrements de Joachim), D82 (aucun bouton mort), D59 (contenu Sarah).

- Références : `/agent/workspace/refs/c2/messenger/e001.jpg` → `e106.jpg` (603×1311 px, **1 pt = 1,5 px**)
- Planches : `messenger_1.jpg` (e001–e048), `messenger_2.jpg` (e049–e096), `messenger_3.jpg` (e097–e106)
- Code audité : `/agent/workspace/audit/src/MessengerApp.swift` (1178 lignes, SHA de311f5, branche `main`)
- Aucun fichier Swift n'a été modifié.

> Note importante sur le référentiel : le code actuel porte en en-tête « construit contre les références vidéo du 26/08 (106 écrans mesurés) ». **Les mesures ci-dessous montrent que ce n'est pas vrai** : la quasi-totalité des couleurs, tailles et hiérarchies de la vidéo ne se retrouvent pas dans le code. Le fichier a été écrit « de mémoire Messenger », pas contre les frames. C'est la racine du verdict de Joachim.

---

## 1. Inventaire des écrans filmés (106 frames)

| # | Écran / état | Frames représentatives | Dans le code ? |
|---|---|---|---|
| 1 | **Liste Discussions** (wordmark `messenger`, ✎, logo f + badge 8, champ Meta AI, rangée Note, liste) | e001–e006, e023, e024, e073, e074, e079, e106 | Oui (`MsgrDiscussionsVue`) |
| 2 | Pastille flottante **« Demander à Meta AI »** / FAB fleur violette bas-droite | e001, e075, e080, e097 | **ABSENT** |
| 3 | **Conversation 1-à-1** (Mathieu Clos-versailles) : bulles, horodatages centrés, avatars à gauche | e007–e010, e014, e015, e016, e021, e022 | Oui (`MsgrConversationVue`) |
| 4 | **Bloc « Appel vocal » terminé** (durée + bouton Rappeler) | e009, e010, e014 | Oui, mais faux (cf. §3) |
| 5 | **Bloc « Appel vocal manqué »** (rond rouge, heure `5:09 PM`, bouton Rappeler) | e015, e016 | Partiel |
| 6 | **Appui long → barre de réactions + menu contextuel** (Répondre / Copier / Traduire / Plus) | e012, e013 | **ABSENT** |
| 7 | **Feuille « Réactions »** (qui a réagi, « Appuyez pour supprimer ») | e011 | **ABSENT** |
| 8 | **Réaction avec compteur** (`❤️ 8`) + rangée d'avatars « vu » | e026, e027, e029 | Partiel (réaction sans compteur) |
| 9 | **Messages vocaux** (bulle waveform + play + 0:25) | e017–e020 | **ABSENT** |
| 10 | **Messages photo/vidéo** (image dans le fil, flèche téléchargement, réactions dessous) | e019–e022 | **ABSENT** |
| 11 | **Conversation de groupe** (« 25 ans Corey ») : nom d'auteur au-dessus, avatar cluster en-tête | e025–e032 | Partiel |
| 12 | **Messages système centrés** (« Thomas Zrsk vous a ajouté(e)… », « X a quitté le groupe ») | e027, e030, e091 | **ABSENT** |
| 13 | **Clavier ouvert** dans la conversation (barre d'icônes conservée, curseur dans `Aa`) | e026, e027, e029, e030, e049–e051 | n/a (TextField) |
| 14 | **Fiche de discussion** (groupe) | e033–e037, e039, e040, e052, e053, e062 | Oui (`MsgrFicheVue`), fortes dérives |
| 15 | **Membres · N personnes** (onglets Tous / Admins, `+`) | e038, e041, e042, e057, e059–e061 | Oui (`MsgrMembresVue`) |
| 16 | **Feuille d'action sur un membre** (Voir le profil Facebook / Message / Bloquer / Annuler) | e058 | **ABSENT** |
| 17 | **Contenu multimédia** (Partagé par ▾ / Photos / Vidéos, Sélectionner, Albums, grille 4 col., sous-onglets Contenu/Fichiers/Liens) | e043, e044, e053–e056 | Oui, très divergent |
| 18 | **Contenu multimédia vide** (« Aucun contenu multimédia ») | e044 | Oui ✔ |
| 19 | **Conversation à thème personnalisé** (fond ballons violets, accent corail) | e048–e051, e089–e096 | **ABSENT** |
| 20 | **Story viewer** (barres de progression, `Manon Saint-Jean · 23h`, ✕, champ « Envoyer un message » + ❤️😆😮) | e067–e072 | **ABSENT** |
| 21 | **Onglet Stories** (titre `Stories`, une seule tuile « Ajouter à la story ») | e075 | Oui, presque ✔ |
| 22 | **Onglet Notifications** (vide + « Vous connaissez peut-être ⓘ … » + Ajouter comme ami(e)) | e076–e078 | Oui ✔ (structure) |
| 23 | **Onglet Menu** | e080, e085, e089, e097, e100, e105 | Oui, dérives |
| 24 | **Paramètres** | e081–e084 | Oui ✔ (structure) |
| 25 | **Invitations par message** (onglets VOUS CONNAISSEZ PEUT-ÊTRE / SPAM, encart « Recevez uniquement… », « Aucun message ») | e086–e088 | Partiel |
| 26 | **Archive** (titre + `Modifier`, 1 ligne `cadeau thomas`) | e090, e098, e106 | Oui, ligne morte |
| 27 | **Conversation archivée ouverte** (thème, messages système, bandeau « Vous ne pouvez pas envoyer de message à ce groupe » + bouton rouge « Supprimer la conversation ») | e091–e096 | **ABSENT** |
| 28 | **Invitations Facebook** (Confirmer / Supprimer, « Vous connaissez peut-être… Voir plus ») | e099–e104 | **ABSENT** |

**Jamais filmé** (donc aucune référence) : menu `+` du composeur, écran d'appel plein écran, appel vidéo, Communautés, « Discuter avec des IA », nouvelle discussion (✎), publication d'une note, ligne non lue, recherche active.

---

## 2. Mesures relevées sur les frames (px → pt ÷1,5)

### 2.1 Palette (mode sombre, échantillonnée au pixel, mode statistique sur zone)

| Rôle | Hex mesuré | Frame | Valeur dans le code | Verdict |
|---|---|---|---|---|
| Fond global | `#000000` | e001/e009 | `.black` | ✔ |
| Bulle **envoyée** | `#1260FF` | e009 (y 250-270) | `0x0084FF` | **DÉVIE** (bleu Meta 2025, pas le vieux cyan) |
| Bulle **reçue** | `#2C2B30` | e009 (y 395-420) | `0x26262B` | DÉVIE (léger) |
| Icônes composeur / accents | `#3454FF` | e009 (pouce) | `0x0084FF` | **DÉVIE** |
| Bouton plein bleu (Ajouter comme ami(e), Confirmer) | `#0F5BFC` | e076 | `0x0084FF` | DÉVIE |
| Champ de saisie `Aa` / champ recherche | `#2C2B30` | e009, e001 | `0x1C1C1E` | DÉVIE |
| Bloc appel | `#2C2B30` | e009 | `0x1C1C1E` | DÉVIE |
| Bouton « Rappeler » | `#515055` | e009 | *(inexistant : texte bleu)* | **DÉVIE** |
| Carte de réglages / fiche / menu | `#1F2326` | e035, e080 | `0x141414` | **DÉVIE** |
| Séparateur interne de carte | `#303437` | e035, e080 | `0x2C2C2E` | DÉVIE |
| Barre d'onglets (fond) | `#090909` | e001 | `0x111111` opacity .98 | DÉVIE (léger) |
| Onglet inactif | `#A4A7AE` | e001 | `.secondary` | ≈ |
| Rouge (appel manqué, badge) | `#FF3B36` | e015 | `0xFF3B30` | ✔ |
| Rouge destructif (Supprimer la conversation) | `#FD3D3C` | e091 | n/a | ABSENT |
| Bulle reçue thème personnalisé | `#1E1F3B` | e091 | n/a | ABSENT |

### 2.2 Géométrie — Liste des discussions (e001)

| Élément | Mesure px | → pt | Code | Verdict |
|---|---|---|---|---|
| Marge latérale | 26 | **17** | 16 | ✔ |
| Avatar liste | ⌀ 88 | **58** | 52 | DÉVIE |
| Pas de rangée (row pitch) | 114 | **76** | ≈ 68 | DÉVIE |
| Nom (cap-height 19 px) | — | **17–18** | 15,5 | DÉVIE |
| Aperçu | — | **15,5–16** | 13,5 | DÉVIE |
| Wordmark `messenger` | — | **≈ 29** bold | 26 | DÉVIE |
| Champ Meta AI (hauteur) | 56 | **37** | 38 | ✔ |
| Placeholder Meta AI | — | **≈ 16** | 14,5 | DÉVIE |
| Avatar « Votre note » | ⌀ 87 | **58** | 58 | ✔ |
| Labels d'onglet | h 11 | **≈ 10** | 10 | ✔ |

### 2.3 Géométrie — Conversation (e009, e014, e015)

| Élément | Mesure px | → pt | Code | Verdict |
|---|---|---|---|---|
| Avatar en-tête | ⌀ 53 | **35** | 36 | ✔ |
| Titre en-tête | h 20 | **17** semibold | 16 | ≈ |
| Avatar dans le fil (message reçu) | ⌀ 42, x 18→59 | **28**, marge 12 | 28 (groupes **uniquement**) | **DÉVIE** : la vidéo montre l'avatar aussi en 1-à-1 (e009) |
| Bord gauche bulle reçue | x 79 | **53** | — | à respecter |
| Marge droite bulle envoyée | 14 | **9,5** | — | ≈ 10 |
| Texte de message (asc→desc 24 px) | — | **17** | 15,5 | DÉVIE |
| Interligne dans une bulle | 30 | **20** | défaut | ≈ |
| Padding bulle H / V | 16 / 13 | **11 / 8,7** | 13 / 8 | ≈ |
| Bulle 1 ligne (hauteur) | 50–53 | **34–35** | ≈ 33 | ✔ |
| Rayon de coin | ≈ 27 | **18** | 19 | ✔ |
| **Espacement intra-rafale** (même auteur, même minute) | 4 | **≈ 3** | 3 | ✔ |
| **Espacement entre blocs / changement d'auteur** | 20–21 | **13–14** | 3 | ❌ **cause du « messages trop collés »** |
| Bloc autour d'un horodatage centré | 76 total | **≈ 17 pt au-dessus et en dessous** | 10 | DÉVIE |
| Horodatage (`1 AOÛT À 18:37`, capitales) | h 18 | **12–13** | 11 | ≈ |
| Bloc appel (hauteur totale) | 512→672 = 160 | **107** | ≈ 58 | **DÉVIE** |
| Bouton « Rappeler » dans le bloc | pleine largeur du bloc, h 40 | **27**, radius ≈ 8 | texte bleu 12,5 | **DÉVIE** |
| Accusé de lecture | avatar ⌀ 20 (1-à-1) / rangée de 3 (groupe) | **13** | 14, 1 seul | ≈ / DÉVIE en groupe |

### 2.4 Barre de saisie — ordre exact relevé (e009, e014, e015, e027)

De gauche à droite, **6 éléments**, tous conservés clavier ouvert (e027) :

1. `+` — **rond plein bleu** `#3454FF`, ⌀ ≈ 21 pt, glyphe `+` blanc
2. **Appareil photo** — glyphe plein bleu, ≈ 20 pt
3. **Image / galerie** — glyphe plein bleu, ≈ 20 pt
4. **Micro** — glyphe plein bleu, ≈ 19 pt
5. **Champ `Aa`** — capsule `#2C2B30`, hauteur 39 pt (59 px), placeholder `Aa`, **smiley bleu ⌀ 20 pt collé à droite À L'INTÉRIEUR du champ**
6. **Pouce 👍** — glyphe plein bleu, ≈ 22 pt

Code actuel : `+`, appareil photo, image, champ, pouce → **micro absent, smiley intra-champ absent**, et le `+` n'est pas un rond plein.

### 2.5 Menu (e080) — libellés et ordre exacts

`Menu` (titre 29 pt bold) + icône 4 carrés en haut à droite → **à supprimer (choix C de Joachim)**.
- Carte 1 : `Joachim Fourez` / `Changer de profil` — puis `Paramètres ›`
- Carte 2 : `Communautés ›`, `Invitations par message ›`, `Archive ›`
- Carte 3 : `Invitations ›`, `Discuter avec des IA ›` ← **les deux manquent dans le code**
- Titre `Aussi de Meta` + carte `Facebook Reels`, `Évènements Facebook`, `Facebook Rencontres` → **à supprimer (C)**
- FAB fleur Meta AI bas-droite → absent du code

### 2.6 Fiche de discussion (e035, e037) — structure exacte

Chevron `‹` seul en haut à gauche (**pas de bouton « OK »**, pas de titre tant qu'on n'a pas scrollé ; le titre apparaît en scrollant, e037). Puis : avatar (cluster 2 photos en groupe) → nom 22 pt bold → `Modifier le nom ou l'image` (lien bleu, 15 pt) → **4 ronds** `Ajouter` / `Pseudos` (glyphe `Aa`) / `Rechercher` / `Personnaliser` (⌀ 44, fond `#1F2326`).

| Section | Lignes de la vidéo | État du code |
|---|---|---|
| `Informations sur la discussion` | Contenus multimédias, liens et fichiers › · Voir les membres de la discussion › | ✔ |
| `Actions` | Mettre X en sourdine (**ligne simple, pas de switch**) · Sons et notifications › · Créer une nouvelle discussion de groupe › · **Paramètres des moments ›** · **Messages épinglés ›** | 3/5, + un `Toggle` inventé |
| `Confidentialité et assistance` | Confirmations de lecture **`Activé ›`** · Indicateur de saisie **`Activé ›`** · **Bloquer un membre ›** · Restreindre › · Signaler + sous-titre *« Donnez votre avis ou signalez la conversation »* · **Quitter la discussion** (rouge) | switches à la place de `Activé ›`, Bloquer absent, sous-titre absent |

---

## 3. Verdict écran par écran (FIDÈLE / DÉVIE / ABSENT / INVENTÉ)

| Écran | Verdict | Détail |
|---|---|---|
| Liste Discussions | **DÉVIE** | Métriques (§2.2), noms non-Facebook, non-lu non persistant, logo f mort, rangée de notes détournée en raccourcis de conversation, FAB Meta AI absent, badge rouge « 2 » sur l'onglet Menu **inventé** (la vidéo n'en montre aucun), icônes d'onglets fausses (`bubble.left.and.bubble.right.fill` au lieu d'une bulle simple ; `rectangle.stack.person.crop.fill` au lieu des 2 rectangles verticaux) |
| Conversation | **DÉVIE fortement** | Espacements (§2.3), bleu, avatars 1-à-1 manquants, aucun appui long, aucune réaction avec compteur, aucun média, aucun vocal, aucun message système, bloc d'appel faux, barre de saisie incomplète et mal câblée |
| Bloc appel / Rappeler | **DÉVIE** | Voir §4.4 |
| Fiche discussion | **DÉVIE** | Voir §2.6 ; présentée en `sheet` avec « OK », la vidéo montre une pile de navigation avec chevron |
| Membres | **DÉVIE (léger)** | Titre correct (`Membres · N personnes`) mais pas de `+` en haut à droite ; les `…` par ligne sont morts ; onglet `Admins` filtre arbitrairement au 1er membre (**inventé**) ; la feuille d'action membre (e058) est absente |
| Contenu multimédia | **DÉVIE** | Pilules blanches inventées ; la vidéo montre `Partagé par ▾` `Photos` `Vidéos` en pilules grises, un bouton `Sélectionner` en haut à droite, une section `Albums` (« Créer des albums pour cette discussion »), un compteur `Tous les contenus multimédias (22)`, une grille **4 colonnes** et 3 sous-onglets en bas (Contenu multimédia / Fichiers / Liens). Le code fait une grille 3 colonnes sans rien de tout ça |
| Stories (onglet) | **≈ FIDÈLE** | Tuile 150×220 vs ref ≈ 178×250 px (≈ 119×167 pt) ; le `+` est un **rond blanc à glyphe noir** en haut à gauche de la tuile dans la vidéo (e075), pas un rond bleu en bas |
| Story viewer | **ABSENT** | e067–e072 non implémenté ; c'est le point « aucune story affichée » de Joachim |
| Notifications | **FIDÈLE (structure)** | Libellés exacts ✔. `Ajouter comme ami(e)` mort ; radius du bouton 8 alors que la vidéo montre une capsule ; icône `questionmark.circle` au lieu du `ⓘ` |
| Menu | **DÉVIE** | 2 lignes manquantes, 4 éléments à supprimer, `Communautés` mort |
| Paramètres | **≈ FIDÈLE** | Ordre et libellés conformes à e081–e084 ; 9 lignes sur 11 mortes |
| Invitations par message | **DÉVIE (léger)** | L'encart bleu « Recevez uniquement les messages que vous souhaitez » + boutons `Voir qui peut vous envoyer un message` / `Plus tard` (e088) manque |
| Archive | **DÉVIE** | Bouton `Modifier` absent, ligne non cliquable, avatar en initiale au lieu d'une photo |
| Conversation archivée | **ABSENT** | e091–e096 : thème, messages système, bandeau + bouton rouge |
| Invitations Facebook | **ABSENT** | e099–e104 |
| **Écran d'appel plein écran** (`MsgrAppelVue`) | **INVENTÉ** | Aucune frame ne montre un appel Messenger. Dégradé `#1B2735→#090A0F`, 3 boutons : pure invention |
| **Menu Pièces jointes** (`MsgrMenuPJVue`) | **INVENTÉ** | « Photo / Vidéo, Appareil photo, Localisation, GIF » dans une `List` iOS standard : aucune référence, et les 4 lignes ne font que `dismiss()` |
| **Ajouter à votre story** (`MsgrAjoutStoryVue`) | **INVENTÉ** | Écran de choix à 2 boutons : aucune référence |
| **Publier une note** (`MsgrSaisieNoteVue`) | **INVENTÉ** | Barre de nav « Publier une note / Annuler / Publier » : aucune référence |
| **Nouveau message** (`MsgrNouvelleDiscussionVue`) | **INVENTÉ** | « À : » + « Suggestions » : le ✎ n'est jamais ouvert dans la vidéo |
| **Alerte « Ouvrir dans Facebook ? »** | **INVENTÉ** | Disparaît de toute façon avec la suppression de « Aussi de Meta » |
| **État vide de recherche** (« Aucun résultat pour « … » ») | **INVENTÉ** | La recherche n'est jamais utilisée dans la vidéo |

**C'est le principal défaut reproché** : ~25 % du code (5 écrans complets) n'a aucune contrepartie filmée, pendant que 8 écrans réellement filmés manquent.

---

## 4. Les points de Joachim, un par un, avec la cause dans le code

### 4.1 « Noms de la liste = noms Facebook, jamais “Maman” »
`DonneesMessenger.conversations` (l. 33-50) contient `"Maman"` (l. 36) et `"Julie Kiné Villeurbanne"` (l. 42) — des libellés de carnet d'adresses, pas des profils Facebook.
**Correctif** : `Maman` → **`Sylvie Lavisse`** ; `Julie Kiné Villeurbanne` → **`Julie Ferrand`** (le contexte « kiné » passe par l'aperçu du message, pas par le nom). Conserver `Chloé Berthier`, `Thomas Levasseur`, `Nadia Benkacem`, `Léa Moreau`, les groupes `Les filles 💃` et `Idée cadeau papa`. **Marc n'apparaît pas** : il faut aussi le retirer de `DonneesMessenger.suggestions` (l. 86, `"Marc Delorme"`).

### 4.2 « Ouvrir une non-lue → au retour elle n'est plus non lue »
`conversations` est un `static let` dans un `enum` (l. 33) : la donnée est **immuable**. `nonLu` (l. 17) n'est jamais écrit nulle part dans le fichier.
**Correctif** : passer par un `final class MessengerStore: ObservableObject` (`@Published var conversations`) injecté en `@EnvironmentObject`, et marquer `nonLu = false` à l'ouverture (`onAppear` de `MsgrConversationVue`). Même store pour le compteur de badge.

### 4.3 « Tap sur le logo Facebook → ouvre Facebook »
Lignes 195-202 : le `ZStack` du logo `f` et du badge « 8 » n'a **ni `contentShape` ni `onTapGesture`** → bouton mort (violation D82).
**Correctif** : router vers l'app Facebook de la coque (navigation inter-apps interne), pas un `alert`.

### 4.4 « Appel vocal manqué → Rappeler doit fonctionner »
Lignes 462-482 : le bloc d'appel est **purement décoratif**. « Rappeler » est un simple `Text(...)` bleu 12,5 pt sur la 2ᵉ ligne (l. 473-474), sans `Button`, sans geste. En plus c'est structurellement faux : la vidéo (e009, e015) montre un **bouton gris plein `#515055`, pleine largeur du bloc, sous le titre**, avec le titre + la durée (`47 s`) ou l'heure (`5:09 PM`) sur deux lignes à droite d'un rond de 23 pt.
**Correctif** : reconstruire le bloc (⌀ rond 23 pt, rouge `#FF3B36` si manqué / gris `#3A3A3F` sinon), + vrai bouton `Rappeler` déclenchant l'écran d'appel.

### 4.5 « L'action photo lance un appel » — trouvé
```
l. 388-390 : Image(systemName: "camera.fill") … .onTapGesture { appelVisible = true }
```
L'icône **appareil photo** de la barre de saisie ouvre `MsgrAppelVue`. Copier-coller depuis le bouton téléphone de l'en-tête (l. 353-355).
Autres câblages fautifs de la même barre :
| Icône | Ligne | État actuel | Correctif D82 |
|---|---|---|---|
| `+` | 385-387 | ouvre `MsgrMenuPJVue` (écran inventé, lignes mortes) | soit A) menu réel filmé, soit C) retirer jusqu'au tournage |
| Appareil photo | 388-390 | **lance un appel** | A) ouvre la caméra de la coque, ou B) refus iOS crédible |
| Image | 391 | **aucun geste** | A) sélecteur pellicule (`ChargeurPhoto` existe déjà) |
| Micro | — | **absent** | à ajouter (présent dans toutes les frames) |
| Smiley (dans le champ) | — | **absent** | à ajouter |
| Pouce 👍 | 397 | **aucun geste** | A) envoie un 👍 dans le fil (trivial, à faire) |
| Avion papier | 399-404 | fonctionne ✔ | conserver |

### 4.6 « Menu + s'ouvre mais ses éléments ne font rien »
`MsgrMenuPJVue` l. 419-450 : les 4 `Button` appellent uniquement `dismiss()` (l. 424, 427, 430, 433). Et l'écran lui-même est inventé (`List.insetGrouped`, barre « Pièces jointes / Fermer ») : rien de tel dans les 106 frames.

### 4.7 « Appel vidéo visuellement différencié »
Lignes 353-358 : `phone.fill` **et** `video.fill` déclenchent tous deux `appelVisible = true` → la même `MsgrAppelVue` audio. Aucun paramètre de mode.
**Correctif** : `enum ModeAppel { case vocal, video }` ; UI vidéo distincte (aperçu caméra, boutons Retourner / Caméra off). Mais **aucune référence filmée** → à tourner avant d'écrire (§5).

### 4.8 « Réactions emoji sur appui long »
Aucun `.onLongPressGesture` / `.contextMenu` dans tout le fichier. `MsgrMessage.reaction` (l. 28) est une donnée statique affichée en pastille (l. 501-506) sans compteur ni interaction.
**Correctif** : appui long → barre de réactions (❤️ 😆 😮 😢 😠 👍 + appareil photo bleu + `+`, pilule `#2C2B30`, ⌀ emoji ≈ 22 pt) puis menu contextuel `Répondre / Copier / Traduire / Plus` (carte `#2A2A2E`, 4 lignes 30 pt, glyphe à droite). Tap sur une pastille existante → feuille « Réactions » (e011).

### 4.9 « Rangée d'avatars = Stories ET Notes »
Lignes 239-247 : la rangée affiche `conversations.prefix(4)` et le tap **ouvre la conversation** (`conv = c`). Ce n'est ni une note, ni une story. Le seul élément conforme est « Votre note » (l. 219-238).
**Correctif** : modèle `MsgrNote { auteur, texte, expiration }` + `MsgrStory` ; bulle de note grise `#2C2B30` ancrée `-16 pt` au-dessus de l'avatar ⌀ 58 pt ; anneau dégradé pour les stories non vues ; tap → viewer (e067-e072) ou feuille de note.

### 4.10 Stories « aucune story affichée »
`MsgrStoriesVue` (l. 791-822) n'affiche que la tuile « Ajouter à la story » — ce qui est **conforme à e075**, mais Joachim veut du contenu. Il faut donc des stories Sarah + un viewer (à filmer d'abord, §5).

### 4.11 Notifications « Ajouter comme ami(e) doit fonctionner »
Lignes 895-898 : `Text("Ajouter comme ami(e)")` sans geste. Bouton mort.
**Correctif** : état local `@State var ajoutes: Set<String>` → le bouton devient `Demande envoyée` grisé (comportement Messenger réel), et la suggestion disparaît au bout d'un instant.

### 4.12 Menu — suppressions demandées (C)
À retirer : `square.grid.2x2` (l. 924), et tout le bloc `Aussi de Meta` (l. 955-970 : Facebook Reels, Évènements Facebook, Facebook Rencontres) **et** l'`alert` associée (l. 978-983) + les états `alerteFacebook`/`alerteFacebookTitre` (l. 915-916).
À **ajouter** (présents dans e080, absents du code) : `Invitations ›` et `Discuter avec des IA ›`.

### 4.13 Archives & Communautés
- `MsgrArchiveVue` l. 1102-1111 : la ligne « Idée cadeau papa » n'a **ni `contentShape` ni `onTapGesture`**. Bouton mort. Il manque aussi `Modifier` en haut à droite (e090).
- `MsgrMenuVue` l. 949 : `MsgrLigne(symbole: "person.3", titre: "Communautés") {}` → **fermeture vide**. Bouton mort.

### 4.14 Recensement complet des boutons morts (violations D82)
| Ligne(s) | Élément | Type |
|---|---|---|
| 195-202 | Logo Facebook + badge 8 | aucun geste |
| 391 | Icône image (composeur) | aucun geste |
| 397 | Pouce 👍 | aucun geste |
| 473-474 | « Rappeler » | texte, pas bouton |
| 424-435 | 4 lignes du menu Pièces jointes | `dismiss()` seul |
| 570 | « Modifier le nom ou l'image » | `Text` |
| 573-576 | Ajouter / Pseudos / Rechercher / Personnaliser | `MsgrActionRonde` n'a **aucun paramètre d'action** |
| 594, 595 | Sons et notifications, Créer une nouvelle discussion | `{}` |
| 613, 614, 616 | Restreindre, Signaler, Quitter la discussion | `{}` |
| 711 | `…` de chaque membre | aucun geste |
| 743-749 | Pilules Partagé par / Photos / Vidéos | changent l'onglet mais l'onglet 0 et 1 rendent la même grille |
| 895-898 | Ajouter comme ami(e) | aucun geste |
| 949 | Communautés | `{}` |
| 1007, 1025-1028, 1031-1033 | 9 lignes de Paramètres | `{}` |
| 1017-1023 | Mode sombre | aucun geste |
| 1102-1111 | Ligne d'archive | aucun geste |
**Total : ≈ 35 boutons morts.**

---

## 5. Ce que Joachim doit filmer en plus (tournage complémentaire)

Par ordre d'utilité. Filmer lentement, 1 action par prise, en restant sur chaque état ≥ 2 s.

1. **Menu `+` du composeur** : l'ouvrir, filmer la grille/liste complète, **puis ouvrir chaque sous-écran** (Appareil photo, Galerie, GIF, Autocollants, Fichier, Localisation, Sondage…) et revenir. C'est le trou de référence le plus grave (écran entièrement inventé).
2. **Appel vocal sortant** : appuyer sur le combiné, filmer l'écran d'appel (sonnerie, en cours, boutons du bas), puis raccrocher — et **l'appel vidéo** séparément (même parcours) pour la différenciation demandée.
3. **Bouton « Rappeler »** dans un bloc d'appel manqué : le presser, filmer ce qui se passe.
4. **Appui long sur un message** : reçu **et** envoyé (les menus diffèrent — le message envoyé doit proposer Supprimer / Retirer l'envoi), puis **poser une réaction**, puis la **retirer**, puis ouvrir la feuille « Réactions », puis `Répondre` (aperçu de citation) et `Plus`.
5. **Conversation archivée** : depuis Menu → Archive → **ouvrir** la conversation, scroller, montrer le bandeau bas.
6. **Communautés** : ouvrir la ligne du Menu et filmer l'écran (même s'il est vide).
7. **Ligne non lue** : recevoir/simuler un message non lu, filmer la liste **avant** (gras + pastille) et **après** ouverture.
8. **Rangée du haut** : une story d'un ami (anneau), une **note** d'un ami (bulle de texte au-dessus de l'avatar), le tap sur les deux, et le viewer de story complet (barres de progression, réponse, ❤️).
9. **Icône ✎ (nouvelle discussion)** : ouvrir, filmer la liste de suggestions, taper une lettre.
10. **Publier une note** : tap sur « Votre note » → écran de rédaction → publier.
11. **Recherche Meta AI** : taper dans le champ, filmer les résultats et l'état « aucun résultat ».
12. **`Discuter avec des IA`**, **`Invitations`** (Menu) et les toggles de la fiche (`Confirmations de lecture` → écran `Activé/Désactivé`).
13. **Personnalisation d'un fil** (fiche → `Personnaliser`) : c'est ce qui produit le thème violet de e091 ; utile pour « Idée cadeau papa ».
14. **Envoi réel** : taper un texte, envoyer, filmer l'animation et l'accusé de lecture qui remonte.

---

## 6. Plan de refonte priorisé

### P0 — Réécriture (le socle ; sans ça le reste ne tient pas)

| # | Chantier | Contenu |
|---|---|---|
| P0-1 | **Store d'état** | `MessengerStore: ObservableObject` remplaçant `enum DonneesMessenger` : conversations mutables (`nonLu`), messages par conversation, réactions, envois du joueur, archives. Débloque 4.2, 4.8, 4.11, 4.13. |
| P0-2 | **Jeton de style** | `enum MsgrStyle` : `bulleEnvoi #1260FF`, `bulleRecue #2C2B30`, `accent #3454FF`, `boutonPlein #0F5BFC`, `carte #1F2326`, `sepCarte #303437`, `champ #2C2B30`, `barreOnglets #090909`, `inactif #A4A7AE`, `rouge #FF3B36`, `destructif #FD3D3C`. Supprimer `let msgrBleu = 0x0084FF`. |
| P0-3 | **Moteur de fil** (`MsgrBulle` + conteneur) | Espacement conditionnel **3 pt intra-rafale / 13 pt inter-bloc / 17 pt autour d'un horodatage** ; texte **17 pt**, padding **11/9**, radius **18** ; **avatar 28 pt à gauche de tout message reçu, y compris en 1-à-1**, marge gauche 12 pt, bord de bulle à 53 pt ; marge droite 10 pt ; accusé de lecture ⌀ 13 pt (rangée de 3 en groupe). |
| P0-4 | **Barre de saisie** | 6 éléments dans l'ordre `+ (rond plein 21 pt) · appareil photo · image · micro · champ 39 pt avec smiley intégré · pouce` ; recâblage un par un (§4.5). Aucun geste orphelin. |
| P0-5 | **Bloc d'appel + Rappeler** | Refonte selon §4.4 ; `Rappeler` fonctionnel. |
| P0-6 | **Purge D82** | Les ~35 boutons morts de §4.14 : A) câbler, B) message iOS crédible (à réserver à 2-3 cas maximum), C) retirer. Supprimer `MsgrMenuPJVue`, `MsgrAjoutStoryVue`, `MsgrSaisieNoteVue`, `MsgrNouvelleDiscussionVue` et `MsgrAppelVue` **tant que le tournage §5 n'a pas eu lieu** (mieux vaut un ✎ absent qu'un écran inventé). |

### P1 — Retouches lourdes (écrans existants à remettre aux mesures)

| # | Chantier |
|---|---|
| P1-1 | **Liste** : avatar 58, pas 76, nom 17, aperçu 15,5, wordmark 29, placeholder 16 ; noms Facebook (§4.1) ; logo `f` cliquable ; badge « 2 » de l'onglet Menu **supprimé** ; icônes d'onglets corrigées (bulle simple pleine / 2 rectangles verticaux / cloche / 3 traits). |
| P1-2 | **Rangée Notes + Stories** (§4.9). |
| P1-3 | **Fiche discussion** : passage en pile de navigation (chevron, pas de « OK ») ; ajouter `Paramètres des moments`, `Messages épinglés`, `Bloquer un membre` ; remplacer les 3 `Toggle` par des lignes `Activé ›` ; sous-titre de `Signaler` ; carte `#1F2326`, séparateur `#303437`. |
| P1-4 | **Menu** : +`Invitations`, +`Discuter avec des IA`, −QR, −`Aussi de Meta` (§4.12) ; FAB Meta AI. |
| P1-5 | **Contenu multimédia** : pilules grises `Partagé par ▾ / Photos / Vidéos`, `Sélectionner`, section `Albums`, compteur `(22)`, grille **4 colonnes** espacement 2 px, sous-onglets bas. |
| P1-6 | **Membres** : bouton `+`, feuille d'action membre (Voir le profil Facebook / Message / Bloquer / Annuler). |
| P1-7 | **Archive** : bouton `Modifier`, ligne cliquable → conversation archivée. |
| P1-8 | **Notifications** : bouton en capsule, `ⓘ`, `Ajouter comme ami(e)` fonctionnel, retirer `Marc Delorme` des suggestions. |

### P2 — Écrans à créer (référence disponible, contenu Sarah à écrire)

- **Conversation archivée** « Idée cadeau papa » : thème personnalisé (fond image + bulles `#1E1F3B`), messages système centrés, bandeau `Vous ne pouvez pas envoyer de message à ce groupe` + bouton `Supprimer la conversation` `#FD3D3C` (h 44 pt, radius 12).
- **Appui long** : barre de réactions + menu contextuel + feuille « Réactions ».
- **Messages riches** : vocal (waveform + play + durée), photo (bulle image radius 18 + flèche de téléchargement), messages système.
- **Réaction avec compteur** (`❤️ 8`) + rangée de lecteurs.
- **Invitations Facebook** (Confirmer/Supprimer) accessible depuis `Invitations`.
- **Story viewer**.
- **Invitations par message** : encart bleu + 2 boutons (e088).

### P3 — Bloqué sur tournage (§5)
Menu `+`, appel vocal, appel vidéo différencié, nouvelle discussion, publication de note, Communautés, recherche Meta AI, écrans des toggles.

### Contenu Sarah à conserver / corriger

| Actuel | Action |
|---|---|
| Chloé Berthier | conserver |
| **Maman** | → **Sylvie Lavisse** |
| Les filles 💃 (groupe) | conserver |
| Thomas Levasseur | conserver |
| **Julie Kiné Villeurbanne** | → **Julie Ferrand** |
| Nadia Benkacem | conserver |
| Léa Moreau | conserver |
| Idée cadeau papa (archivé) | conserver, + ouvrir réellement |
| **Marc Delorme** (suggestions) | **retirer** (Marc n'est pas sur Messenger) |
| Inès Djellal, Camille Roussel (membres) | conserver |
| Sarah Levasseur (profil Menu/Paramètres) | conserver |
