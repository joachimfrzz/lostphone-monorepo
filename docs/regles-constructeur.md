# Règles communes aux constructeurs d'apps — Lost Phone (vague B, 07/09/2026)

## Le projet en 5 lignes
Lost Phone est un jeu narratif SwiftUI (iOS 17+, compilé par Codemagic/Xcode 26 — PAS de compilateur ici) qui reproduit
tout l'iPhone de **Sarah Levasseur** (Lyon, 14 rue des Fantasques 69001, @sarahlev69, sarah.levasseur@icloud.com, LCL Visa •••• 4417).
Le joueur fouille son téléphone : Sarah est victime d'une arnaque sentimentale par « **Marc** » (Marc Delacroix, « 54 ans, officier
de marine marchande », rencontré sur Meetic le 12/03/2026, photos volées d'un coach milanais). Escalade : 300 € (connexion satellite),
800 € (colis), virement 4 850 € le 17/07, Western Union 850 €, paiement PayPal de 300 € interrompu le 16/08, demande « GLOBAL MARINE
CREW SUPPORT » 480 € le 15/08 ; il « arrive à Marseille le 28 août » (playlist « Marseille — le 28 ⚓️ ») ; rendez-vous banque
« lundi 11h30 » pour 3 000 €. Entourage : **Chloé** (meilleure amie, s'inquiète), **Maman**, **Thomas** (ami hésitant), **Camille Roux**,
**Julie**, groupe « Les filles ». Marc ne montre JAMAIS son visage : les appels vidéo sont toujours annulés/manqués — c'est un indice.
Époque du jeu : août 2026 (aujourd'hui dans le jeu ≈ 17-20 août 2026).

## D67 — Référence = les enregistrements de Joachim, jamais la mémoire du web
- Frames 603×1311 px (1 pt = 1,5 px) dans le dossier de refs indiqué. Reproduire la STRUCTURE au pixel : couleurs mesurées,
  typo, espacements, barres, enchaînement des écrans, états vides.
- D93 (vague B) : pour les écrans que Joachim n'a pas pu filmer, une 2e source AUTORISÉE = captures officielles de l'éditeur
  (dossiers refs/officiel et refs/officiel2, avec SOURCES.md). Aucun écran inventé « de mémoire ». Si un écran n'existe dans aucune
  source → on ne le fait pas (on retire l'affordance qui y mène).

## D59 — Les données de Joachim sont des gabarits
Nom « Joachim Fourez », dates de naissance, téléphones, adresses (Auch, Colomiers, Toulouse…), notifications qui passent
(Telegram, BlackHatWorld, Qamify, Star Academy…) : RIEN de tout ça ne doit apparaître. Tout est remplacé par le contenu de Sarah
(Lyon, ses proches, l'arnaque). Aucune bannière de notification étrangère.

## D92 — « Juste milieu » (doctrine Joachim, 03/09)
Moins de fonctionnalités mais une expérience cohérente. Chaque affordance visible a une conséquence réelle : compteur = contenu
réellement accessible ; action = état qui change et PERSISTE (ObservableObject partagé) ; navigation = la bonne destination.
Pas d'usine à gaz. Ce qui ne peut pas exister est RETIRÉ (D82-C) plutôt que mort. Si un retrait pourrait servir aux histoires,
le LISTER dans la livraison (« retraits à arbitrer ») au lieu de le supprimer en silence. Un message/feuille ne reste jamais affiché
après avoir quitté l'écran (état local). D82 : A = faire marcher ; B (rare) = message crédible façon iOS via `ErreurLambda` ;
C = retirer.

## Contraintes de compilation (ZÉRO erreur possible — pas de compilateur ici, un rouge coûte 15 min à Joachim)
1. Vues COURTES (body < 60 lignes ; découper en sous-vues). Pas d'expressions géantes.
2. Ternaire de style TYPÉ : `cond ? Color.a : Color.b` (jamais `.secondary : .white` — erreur réelle rencontrée).
3. Pas de `.background(Color.x.opacity(…), in: Shape)` ambigu → `.background(Shape().fill(Color.x.opacity(…)))`.
4. Images dans cellules/grilles : `Color.clear.overlay(Image(...).resizable().scaledToFill()).clipped()` — jamais `.scaledToFill()` nu.
5. UN SEUL `navigationDestination` par NavigationStack, jamais dans une rangée ni dans une branche de switch démontée.
6. Dictionnaires littéraux : AUCUNE clé en double (crash fatal au runtime).
7. `@Published` uniquement dans des `ObservableObject` ; `static let partage` pour les magasins.
8. Aucune API iOS 18+/26 (pas de `.tabViewStyle(.sidebarAdaptable)`, pas de `@Entry`, pas de `Tab(...)`, pas de `.glassEffect`, pas de `.presentationSizing`). Cible iOS 17.
9. Préfixe de types UNIQUE par app (donné dans la mission) sur TOUS les types publics/privés (struct, enum, class, func globales),
   pour éviter toute collision avec LPProto / les 30 autres apps. Ne redéfinir AUCUN helper existant (`Color(hex:)`, `chargerPellicule`,
   `AvatarSilhouette`, `Haptique`, `ErreurLambda`, `BarreHome`, `coquilleSarah` existent déjà).
10. JAMAIS de `.sheet`, `.fullScreenCover`, `.confirmationDialog` plein écran qui masquerait BarreHome (bug Facebook build 279) :
    les feuilles = overlays internes (ZStack) dans la vue racine. `.alert` simple autorisé.
11. Aucun `Task.sleep` sans `try?`, pas de `async` inutile ; timers via `Timer.publish(...).autoconnect()`.
12. Pas de `UIApplication.shared.open`, pas de `MapKit` réel (cartes = images statiques ou dessins), pas de réseau.
13. Le fichier doit être auto-suffisant : 1 seul fichier .swift, `import SwiftUI` (+ `AVFoundation` si besoin).
14. Accolades équilibrées — vérifier avec un script (compter `{` et `}` hors chaînes) avant de livrer.

## Conventions de la coque (voir src/PayPalApp.swift comme modèle — le lire en entier d'abord)
- Vue racine `XxxVue(onglet: Int = 0)` construite EXACTEMENT comme `PayPalVue` (PayPalApp.swift l. 681-706) :
  `ZStack(alignment: .bottom) { NavigationStack { … }.toolbar(.hidden, for: .navigationBar) ; BarreHome { quitter() } }`
  avec `@Environment(\.dismiss) private var quitter`. La BarreHome est donc dessinée PAR L'APP, en bas, au-dessus de tout ;
  les barres d'onglets se posent au-dessus d'elle (voir `PpBarreOnglets`, marge basse 22 pt, l. 719).
- Écrans poussés (NavigationLink) : lire l'enveloppe de capture de PayPalApp.swift l. 344-360 et la reproduire (préfixée).
- Recouvrements internes (feuilles, menus) = overlays dans la ZStack racine, jamais `.sheet` (PayPalApp.swift l. 1737).
- Retour = chevron gauche. Aucun micro de dictée dans les champs. Heure/batterie = fournies par la coque (ne pas dessiner de status bar).
- Fournir un `XxCapture` (enum avec `static func etat()` et un état statique injectable) pour que la boucle miroir (captures simulateur)
  puisse instancier chaque écran directement, et LISTER dans la livraison les cas du registre sous la forme exacte :
  `case "uber.activite": UbActiviteVue(etat: UbCapture.etat())` — un cas par écran, clés en minuscules `app.ecran`.
- Palette : constantes `enum XxTeinte` mesurées sur les frames (commenter la frame source : `// e044 : (237,237,247)`).
- Données : `enum DonneesXx` remplaçable (D59), magasin `final class XxEtat: ObservableObject { static let partage }` pour la persistance.

## Livraison attendue
1. `src/<App>App.swift` (complet, prêt à compiler).
2. `docs_vague-b/<app>-livraison.md` : écrans filmés reproduits (avec n° de frames), écrans issus des captures officielles,
   écrans NON faits, retraits à arbitrer (utilité narrative possible), liste exacte des cas de registre pour LPProto,
   contenu narratif choisi (et pourquoi), points de vigilance.
3. `src/verif_<app>.py` : vérificateur statique (accolades, préfixes, APIs interdites, clés dupliquées, `.sheet`/`.fullScreenCover`
   absents, ternaires non typés) — l'exécuter et livrer VERT.
4. Rapport final en FRANÇAIS, concis. Ne pas pousser sur git, ne pas lancer de build : l'orchestrateur s'en charge.
