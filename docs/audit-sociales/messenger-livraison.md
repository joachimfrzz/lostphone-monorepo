# Messenger v3 — livraison (03/09/2026)

Fichiers livrés :

- `/agent/workspace/src/MessengerApp.swift` — 4 353 lignes, remplace intégralement l'ancien (58 Ko → 175 Ko).
- `/agent/workspace/src/LPProto.swift` — copie de `audit/src/LPProto.swift` + 4 modifications ciblées.
- `/agent/workspace/src/patches/lpproto-messenger.diff` — diff unifié lisible des 4 modifications.
- `/agent/workspace/src/patches/messenger-ecrans.txt` — registre ECRAN (22 clés) pour la boucle miroir.

Racine inchangée : **`MessengerVue()`**. Aucun `typealias` n'a été nécessaire — la coque
(`LPProto.swift`, `.fullScreenCover(isPresented: $messengerOuvert) { MessengerVue().coquilleSarah(claire: true) }`,
et `actionPour("Messenger")`) appelle toujours le bon type. `CoqueV2.swift` ne référence
Messenger que par la chaîne `"Messenger"` (table d'icônes `IconeAccueilV2.assets` + `NavV2.partage.ouvrir`),
donc rien à y changer.

---

## 1. Écran par écran

Légende « État » : **A** = reconstruit aux mesures de l'audit ; **B** = créé, jamais filmé (sobre, à retoucher après tournage).

| Clé ECRAN | Vue | Frames de référence | État | Ce qui est implémenté |
|---|---|---|---|---|
| `messenger#0` | `MessengerVue()` → `MsgrDiscussionsVue` | e001–e006, e023, e024, e073, e074, e079, e106 | A | Wordmark 29 pt, ✎, logo Facebook + badge 8 (ouvre RÉELLEMENT Facebook, §4.3), champ Meta AI qui filtre pour de vrai, rangée haute Notes + Stories, rangées de conversation au pas 76 pt, avatar 58 pt, cluster 2 photos pour les groupes, accusé de lecture à droite. Ouvrir une non-lue la marque lue dans le store (§4.2). Pastille flottante « Demander à Meta AI » (e001) / FAB fleur seule sur les autres onglets (e075, e080). |
| `messenger#1` | `MsgrStoriesVue` | e075 | A | Titre `Stories`, tuile « Ajouter à la story » (ouvre la pellicule), grille des stories d'amis quand il y en a. |
| `messenger#2` | `MsgrNotificationsVue` | e076–e078 | A | État vide + section « Vous connaissez peut-être ⓘ », bouton `Ajouter comme ami(e)` réellement actif (§4.11) qui bascule en `Invitation envoyée`, tap sur une suggestion → profil. Marc Delorme retiré des suggestions (§4.1). |
| `messenger#3` / `messenger.menuplus` | `MsgrMenuVue` | e080, e085, e089, e097, e100, e105 | A | Libellés et ordre exacts de §2.5, carte profil Sarah, une seule `navigationDestination(item:)` en amont pour les 6 sous-écrans. Icône « 4 carrés » supprimée (C, §4.12). |
| `messenger.chloe` | `MsgrConversationVue(conv: chloe)` | e007–e010, e014–e016, e021, e022 | A | Fil 1-à-1 : bulles 17 pt / rayon 18, horodatages centrés, avatars 28 pt en fin de rafale, espacements 3 / 13 / 17. Bloc « Appel vocal manqué » (rond rouge, `9:04 PM`) avec `Rappeler` qui lance vraiment l'appel (§4.4). Barre de saisie complète (6 éléments, tous câblés, §2.4). Appui long → barre de réactions + menu contextuel (e012, e013). |
| `messenger.filles` | `MsgrConversationVue(conv: filles)` | e025–e032 | A | Groupe : nom d'auteur au-dessus de la bulle, cluster d'avatars en en-tête, messages système centrés (e027, e030), réaction avec compteur `❤️ 8` + rangée d'accusés (e026, e027, e029), message vocal waveform `0:25` (e017–e020), message photo avec flèche de téléchargement (e019–e022). |
| `messenger.fiche` | `MsgrFicheVue(conv: filles)` | e033–e040, e052, e053, e062 | A | Structure exacte de §2.6 : en-tête, 4 ronds d'action, sections Infos / Actions / Confidentialité, cartes `#1F2326` + séparateurs `#303437`, motif « Activé › ». 14 sous-écrans réels via `MsgrSousEcranFiche`. |
| `messenger.membres` | `MsgrMembresVue(conv: filles)` | e038, e041, e042, e057, e059–e061 | A | Onglets Tous / Admins, `+`, et **feuille d'action sur un membre** (e058) : Voir le profil Facebook (ouvre Facebook) / Message / Bloquer / Annuler. |
| `messenger.medias` | `MsgrMediasVue(conv: filles)` | e043, e044, e053–e056 | A | Pilules `Partagé par ▾ / Photos / Vidéos`, `Sélectionner`, encart Albums, grille 3 colonnes (gouttière 2), sous-onglets Contenu / Fichiers / Liens, aperçu plein écran. État vide (e044) pour les fils sans média. |
| `messenger.appel` | `MsgrAppelVue(conv: chloe, mode: .vocal)` | *jamais filmé* — §5-2 | B | Appel vocal plein écran : avatar, minuteur, micro / haut-parleur / raccrocher. |
| `messenger.appelvideo` | `MsgrAppelVue(conv: chloe, mode: .video)` | *jamais filmé* — §5-2 | B | Appel **vidéo** visuellement distinct (§4.7) : plein cadre photo du contact, vignette locale, bascule caméra. |
| `messenger.parametres` | `MsgrParametresVue` | e081–e084 | A | Profil, `Statut En ligne` (bascule réelle), 6 lignes de préférences, Aide, Mentions légales. |
| `messenger.invitations` | `MsgrInvitationsFacebookVue` | e099–e104 | A | Confirmer / Supprimer par invitation (persistés dans le store), « Vous connaissez peut-être… Voir plus ». |
| `messenger.invitationsmessage` | `MsgrInvitationsMessageVue` | e086–e088 | A | Onglets `VOUS CONNAISSEZ PEUT-ÊTRE` / `SPAM`, encart « Recevez uniquement… », état « Aucun message ». |
| `messenger.archive` | `MsgrArchiveVue` | e090, e098, e106 | A | Titre + `Modifier`, ligne « Idée cadeau papa » qui **s'ouvre** réellement. |
| `messenger.nouveau` | `MsgrNouveauMessageVue(ouvrir:)` | *jamais filmé* — §5-9 | B | Champ « À : », liste de suggestions filtrée à la frappe. En capture, `ouvrir` est un no-op. |
| `messenger.notifications` | `MsgrNotificationsVue` | e076–e078 | A | Identique à l'onglet 2, capturable seul. |
| `messenger.communautes` | `MsgrCommunautesVue` | *jamais filmé* — §5-6 | B | Deux communautés plausibles + `Rejoindre` actif. |
| `messenger.story` | `MsgrVisionneuseStoryVue(story:)` | e067–e072 | A | Barres de progression animées, `auteur · 23 h`, ✕, champ « Envoyer un message » + ❤️😆😮 avec confirmation d'envoi. |
| `messenger.note` | `MsgrNoteAmieVue(note:)` | e001 (bulle) ; viewer §5-8 | B | Note d'une amie plein écran + champ de réponse. |
| `messenger.reactions` | `MsgrFeuilleReactionsVue` | e011 | A | Feuille `.medium` « Réactions » : qui a réagi, « Appuyez pour supprimer ». |

Écran couvert mais non capturable seul (atteint par navigation) : conversation archivée à thème
personnalisé (e048–e051, e089–e096) — `MsgrConversationVue` avec `conv.theme == true` et
`conv.quitte == true` : fond dégradé violet, bulles reçues `#1E1F3B`, chevron corail `#F2606B`,
bandeau bas « Vous ne pouvez plus écrire » + `Supprimer la conversation` rouge. Accessible depuis
`messenger.archive`.

---

## 2. TODO tournage (marqués dans le code)

| Ligne `src/MessengerApp.swift` | Sujet | Renvoi audit |
|---|---|---|
| 1055 | Rangée **non lue** de la liste (gras + pastille) — rendu minimal, jamais filmé | §5-7 |
| 1161 | Écran de **rédaction d'une note** — feuille minimale, sans chrome inventé | §5-10 |
| 1846 | **Panneau d'emojis** du champ `Aa` | §5-1 |
| 2616 | `MsgrEcranSobreVue`, écran générique des lignes jamais filmées (Sons, Moments, Restreindre, Signaler, Personnaliser, Mode sombre, Accessibilité, Confidentialité, Notifications, Photos, Aide, Mentions légales, Discuter avec des IA) | §5-12 |
| §25 (l. 4083) | **Appels vocal et vidéo** plein écran : entièrement inventés | §5-2 |
| §21 (l. 3790) | **Communautés** | §5-6 |
| §24 (l. 3993) | **Nouveau message** (✎) | §5-9 |

Reste bloqué sur tournage et **non implémenté** : le **menu `+` du composeur** détaillé (§5-1) — le
code se limite à un `confirmationDialog` de 4 entrées réelles (Appareil photo, Galerie, Localisation,
Annuler) plutôt qu'à une grille inventée.

---

## 3. Modifications de LPProto.swift (et rien d'autre)

Diff complet : `src/patches/lpproto-messenger.diff` (4 hunks, aucune autre ligne touchée).

1. **`ecransMessenger()`** (l. ~104) réécrit : 18 clés `case` + `default: MessengerVue()`.
   Les données proviennent d'accesseurs **non optionnels** ajoutés en fin de `MessengerApp.swift`
   (`MessengerStore.convCapture(_:)`, `noteCapture()`, `storyCapture()`, `messageCapture()`), qui lisent
   le store vivant et retombent sur les données initiales — aucun `!`, aucun état externe, aucun binding.
   Les clés `messenger#0..3` tombent dans le `default` et sélectionnent l'onglet via `ONGLET`,
   conformément au commentaire l. 30 du registre.
2. **`enum CibleRouteur`** (l. ~493) : `case telephone, safari, plans, mail, messages, facebook, messenger`.
3. **`Routeur`** (l. ~495) : ajout de `func allerFacebook() { cible = .facebook; demande += 1 }` et
   `func allerMessenger() { cible = .messenger; demande += 1 }`, calqués exactement sur `allerPlans()` / `allerMail()`.
4. **Consommateur** (`.onChange(of: routeur.demande)`, l. ~1184) : ajout de
   `case .facebook: facebookOuvert = true` et `case .messenger: messengerOuvert = true`.
   Les états `facebookOuvert` / `messengerOuvert` et leurs `fullScreenCover` (`FacebookVue()`, `MessengerVue()`)
   existaient déjà et sont bien remis à `false` par `fermerToutesLesApps()`.

`Routeur.partage.allerFacebook()` est appelé en 3 endroits du nouveau Messenger : logo `f` de la liste
(l. 945, §4.3), feuille d'action sur un membre (l. 3016) et profil de suggestion (l. 3507).

---

## 4. Vérifications passées

- Accolades équilibrées (analyseur ignorant chaînes, interpolations et commentaires) : `MessengerApp.swift` **0**, `LPProto.swift` **0**.
- Les **18 clés** du registre construisent des vues qui existent, avec les **bons labels d'init** (contrôle automatique des propriétés stockées sans valeur par défaut) : aucun argument manquant ni inconnu.
- Les 4 helpers `MessengerStore.*Capture` référencés par LPProto existent bien dans `MessengerApp.swift`.
- **Aucune collision de nom de type** : les 80 types du fichier sont tous préfixés `Msgr…` / `Messenger…`, et aucun n'existe dans `LPProto.swift`, `CoqueV2.swift` ni `NotesApp.swift`. Recherche de code GitHub : `Msgr` n'apparaît hors `MessengerApp.swift` que dans `LPProto.swift` (registre) et comme sous-chaîne fortuite `msgRecu` dans `MessagesApp.swift` — pas un type.
- Toutes les vues déclarent un `body`.
- `Color(hex:)` : tous les arguments sont des littéraux `0x…` ou des `UInt` (`teinte`), jamais une chaîne.
- Aucun `Toggle` sans binding (les bascules passent par `MsgrLigne` + action, ou `MsgrBasculeVue` qui écrit dans le store).
- Aucune API iOS 18+ : pas de `.onScrollGeometryChange`, `@Entry`, `Tab(...)`, transitions `.zoom`, `MeshGradient`, `onScrollPhaseChange`, `ScrollPosition`. Les modificateurs utilisés (`onChange(of:) { _, _ in }`, `navigationDestination(item:)`, `presentationDetents`, `safeAreaInset`, `confirmationDialog`, `sheet(item:)`) sont tous iOS 17.
- Pièges connus du projet : **une seule** `navigationDestination(item:)` par pile (`MsgrFicheVue` l. 2417, `MsgrMenuVue` l. 3546), jamais dans une rangée ni dans un `switch` ; `.scaledToFill()` n'est jamais nu — les 9 occurrences sont dans des `@ViewBuilder` consommés par le motif `Color.clear.frame(...).overlay(...).clipped()/clipShape(...)` ; aucun `.background(Color…, in:)` ambigu (le code utilise `.background(Shape().fill(...))`) ; le dictionnaire des fils est construit clé par clé (`table["chloe"] = …`), donc pas de littéral à clés dupliquées.

## 5. Risques de compilation résiduels

1. `MsgrEnTetePile<Droite: View>` a un init mémberwise (avec `@ViewBuilder let droite: Droite`) **et** un init d'extension `where Droite == EmptyView`. Les 11 appels utilisent tous la forme à trailing closure `MsgrEnTetePile(titre: …) { dismiss() }`, qui ne peut correspondre qu'à l'init d'extension (l'init mémberwise exigerait `retour:`). Risque faible, mais c'est le point le plus subtil du fichier.
2. `MsgrBarreSaisie` prend `var focus: FocusState<Bool>.Binding` : correct depuis iOS 15, mais l'appelant doit passer `$champActif` (et non `champActif`). Vérifié au seul site d'appel (`MsgrConversationVue`).
3. `MsgrSousEcranFiche.body` et `MsgrSousEcranMenu.body` retournent un `switch` nu ; cela ne compile que grâce au `@ViewBuilder` implicite de `View.body` — comportement standard, mais sensible si quelqu'un transforme `body` en fonction.
4. Symboles externes attendus, présents dans le socle : `Color(hex:)` et `BarreHome` (`LPProto.swift`), `coquilleSarah()` (`LPProto.swift`), `Haptique.leger()` et `ChargeurPhoto.image(_:)` (fichiers partagés du projet). Si l'un d'eux change de signature, Messenger casse.
5. Le fichier fait 4 353 lignes ; les corps les plus longs (`MsgrConversationVue`, `MsgrDiscussionsVue`) sont découpés en propriétés calculées, ce qui évite l'explosion du vérificateur de types — à ne pas re-fusionner.
