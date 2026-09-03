# Audit des 4 apps sociales — synthèse (D91, 03/09/2026)

Quatre audits indépendants, un par app, menés contre **tes enregistrements** archivés dans le repo (Messenger 106 écrans, Instagram 239, Snapchat 114, Facebook 159 — mi-résolution, 1 pt = 1,5 px), avec mesures au pixel (couleurs, tailles, espacements) et test de chaque bouton du code (D82). Les rapports complets sont ci-dessous ; voici ce qu'il faut en retenir.

## Le diagnostic en une phrase

Ton verdict est confirmé, et la cause est commune aux quatre : **le code reproduit un souvenir générique de chaque app, pas ta vidéo.** Les écrans que tu as filmés le plus longuement sont souvent absents ; à l'inverse, des écrans jamais filmés ont été inventés. Les couleurs, tailles et espacements ne correspondent presque jamais aux mesures. C'est exactement le problème D70 (« construire depuis des vidéos partielles et inventer le reste »), sauf que là, même ce qui était filmé n'a pas été respecté.

## Chiffres clés

| App | Écrans filmés | Absents du code | Inventés (jamais filmés) | Boutons morts (D82) | Écart le plus grave |
|---|---|---|---|---|---|
| **Messenger** | 28 types | 8 | 5 (menu +, appel, story, note, nouveau message) | ≈ 35 | Aucun état : `nonLu` jamais écrit (static let) ; moteur de fil sans avatars ni espacement par blocs |
| **Instagram** | 20+ types | 9 (commentaires, partage, détail post, notes DM…) | 6 (dont Notifications entier et la barre d'onglets) | nombreux | **Mauvaise coquille** : Instagram ~2022 (barre pleine largeur, « Instagram » en titre) vs iOS 26 (capsule flottante, « Pour vous ⌄ ») |
| **Snapchat** | 9 | 4 (Profil entier, fil Spotlight, étages de la Caméra, Découvrir) | 2 | 28 / 41 (68 %) | Le Profil (écran le plus dense filmé) n'existe pas ; Spotlight = image figée |
| **Facebook** | 24 | 14 (dont le **post en détail + commentaires**, l'écran le plus filmé) | 5 | 23 | Architecture fausse : 6ᵉ onglet = Profil, Menu = tiroir ☰ ; bug : une notification piège le joueur dans un 2ᵉ fil sans sortie |

## Mesures qui changent tout (extraits)

- **Messenger** : bulle envoyée `#1260FF` (code `#0084FF`), bulle reçue / champ `#2C2B30`, cartes `#1F2326` ; avatar de liste 58 pt (code 52), texte de bulle 17 pt (code 15,5), **espacement 3 pt intra-rafale mais 13-14 pt entre blocs** (le code met 3 partout → « trop collé ») ; avatar 28 pt à gauche de *tout* message reçu.
- **Instagram** : accent `#3C51FC` / `#4D6CFF` (code `#0095F6`, 36 occurrences) ; avatar de story 79 pt, anneau 93 pt, pas 104,5 pt (code 62/86) ; **dégradé de l'anneau relevé sur 24 angles** : jaune `#D8BA00` en bas-gauche → violet `#C916CA` en haut-droite (le code est décalé de 135° et utilise un violet inexistant) ; bulles DM envoyées = dégradé vertical `#AD29D5` → `#6B30FE` ; barre d'onglets = capsule 370×52 pt à 26 pt du bas.
- **Snapchat** : FAB jaune ⌀ 60 pt absent ; statuts = bulle contour bleue / triangle plein bleu / carré contour violet (le code : carré plein, avion, épingle) ; « Moi » = `#E63455` ; carte = vert `#D7EDC9` ; bandeau conversation `#E7EBEE`.
- **Facebook** : bleu `#0C59FD` (code `#0866FF`) ; séparateur inter-blocs = bande 4 pt `#C1C0C6` ; wordmark 30 pt (26), avatar notif 60 pt + badge de type ; « Rejoindre » bleu plein / texte blanc (inversé dans le code) ; filet bleu 1,5 pt au-dessus de l'onglet actif ; badge rouge sur Reels, pas sur Notifications.

## Tes points, un par un — tous localisés dans le code

- Messenger : « la photo lance un appel » = copier-coller du bouton téléphone (`camera.fill → appelVisible = true`) ; « non-lu qui reste » = données `static let`, impossible à muter ; « Rappeler » n'est qu'un `Text` ; logo Facebook, archives, Communautés, Ajouter comme ami : aucun geste ; menu + = écran inventé à 4 lignes mortes ; aucun appui long dans toute l'app.
- Instagram : stories mal centrées = deux gabarits dans le même HStack (« Votre story » sans `frame(width:)`, anneau avec `padding(3)`) ; story bloquante = `fullScreenCover` qui masque aussi la BarreHome, ✕ de 19 pt sans zone de 44 ; « Vu · pas encore de réponse » rendu comme une bulle *reçue* ; icônes de post = symboles SF génériques alors que les vraies sont un cercle à queue, un triangle inversé, deux traits inégaux, plus l'icône repost manquante.

## Ce que je propose (RECO)

**Refonte en lot, quatre apps, dans cet ordre : Messenger → Instagram → Facebook → Snapchat**, chacune en deux temps :
1. **Socle** : jetons de style mesurés (couleurs/tailles/espacements ci-dessus), vraie coquille de navigation, store d'état observable (lu/non-lu, likes, réactions persistants), purge D82 (chaque bouton marche ou disparaît).
2. **Écrans filmés absents** recréés depuis tes frames (commentaires Facebook/Instagram, Profil Snapchat, fil Spotlight, archives Messenger…), contenu Sarah conservé et corrigé (`Maman` → nom Facebook, vraies données de Joachim retirées de Snapchat).

Vérification par la **boucle miroir simulateur** (compilation + captures) écran par écran contre tes frames, avant un seul build TestFlight de lot (avec Notes v3). Ce qui dépend d'un écran jamais filmé attend ton tournage complémentaire — voir ci-dessous — et n'est **pas inventé** entre-temps (retiré ou en B crédible).

**TENSION** à signaler : « au niveau du reste du téléphone » sur quatre apps de cette taille = une réécriture quasi complète de ~170 Ko de Swift. C'est le bon choix (retoucher ne sert à rien quand la coquille est fausse), mais c'est un chantier de plusieurs boucles, pas un build.

## Tournage complémentaire — UNE session, ~25 minutes

Filme lentement, une action par prise, en restant ≥ 2 s sur chaque état. Uniquement les écrans que le code prétend connaître sans référence — le reste, je l'ai déjà.

**Messenger (≈ 8 min)**
1. Menu **+** du composeur : l'ouvrir, puis ouvrir **chaque** sous-écran et revenir.
2. Appel **vocal** sortant (écran d'appel, boutons, raccrocher), puis appel **vidéo** — séparément.
3. Un bloc « Appel vocal manqué » → presser **Rappeler**.
4. **Appui long** sur un message reçu puis sur un message envoyé ; poser une réaction, la retirer, ouvrir la feuille « Réactions », `Répondre`, `Plus`.
5. Menu → **Archive** → ouvrir la conversation archivée. Menu → **Communautés**.
6. Une **story** d'ami et une **note** d'ami dans la rangée du haut : tap sur chacune, viewer complet.
7. Une conversation **non lue** : liste avant, ouverture, liste après.

**Instagram (≈ 6 min)**
8. Onglet **cœur (notifications)** : liste, sections, boutons Suivre, tap d'une notif vers le profil.
9. Une **story live d'un tiers** depuis la rangée du feed : progression, •••, réactions rapides, segment suivant, **fermeture** (✕ et glissé vers le bas).
10. Tap sur **« Votre story »** et sur le **+** en haut à gauche ; menu **⌄** de « Pour vous » ; menu **≡** d'une publication.
11. **Profil perso** complet : onglets Reels et Identifications, Modifier, Partager le profil.

**Facebook (≈ 6 min)**
12. Onglet **Profil** en entier (scroll jusqu'en bas) et le chevron ▾ à côté du nom.
13. **☰ Menu** : ouverture, « Aide et assistance » et « Paramètres et confidentialité » dépliés, bas du tiroir, « Voir plus ».
14. **Recherche** : vide, saisie, résultats.
15. Tap sur un **post** lui-même, sur son **compteur de réactions**, sur son **…** et son **✕**.
16. Tap sur une **notification** → l'écran qui s'ouvre.

**Snapchat (≈ 5 min)**
17. **Profil** déroulé jusqu'en bas + onglet Profil public ; **Réglages** (engrenage), première page.
18. **Recherche** (loupe) : vide, saisie, résultats ; **Ajouter des amis·es** ; **Nouveau Chat** (bouton jaune).
19. **Fiche d'un ami** (tap sur l'avatar dans une conversation) ; **story d'un ami** (anneau Amis·es).
20. Après une **capture** : écran d'édition du Snap puis « Envoyer à… ».

Envoi : SwissTransfer, vidéo brute, une vidéo par app si possible.
