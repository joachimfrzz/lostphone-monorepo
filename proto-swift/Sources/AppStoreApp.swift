// App Store v1 D92 (06/09) — construit contre les 226 frames de Joachim
//
// Écrans FILMÉS reproduits : Aujourd'hui (e001-e004, e225-e226), Jeux (e045-e052, e076),
// Apps (e077-e079), Arcade (e101-e113), Recherche + résultats (e114-e121, e135),
// fiche d'app (e018-e040, e053-e060, e091-e093, e122-e128, e196),
// Compte Apple (e139, e197, e201, e212, e224), Réglages du compte (e141-e143, e181-e190),
// Historique d'achats (e147-e151, e164), Détails de la commande (e153-e155),
// Abonnements (e159, e169-e177, e200), Mises à jour d'apps (e191-e195),
// Apps et achats → Apps « Tout / Pas sur cet iPhone » (e202-e211), Notifications (e213),
// Notes et avis (e183-e184, e215-e217), Recommandations personnalisées (e219-e220).
//
// D67 : mesures relevées sur les frames 603x1311 px (1 pt = 1,5 px), thème SOMBRE (Joachim est en sombre).
// D82 : chaque bouton affiché agit (A) ; les rares impasses donnent un message iOS crédible (B) ;
//       tout le reste a été RETIRÉ (C — voir audit/appstore-livraison.md).
// D92 : moins de fonctions mais cohérentes — les compteurs annoncent du contenu réellement accessible,
//       aucun état ne survit à son écran (les alertes sont locales), pas d'usine à gaz.
// D59 : le compte de Joachim est un gabarit → remplacé par Sarah Levasseur ; ses apps installées sont
//       celles du téléphone du jeu, ses mises à jour et son historique d'achats sont ceux de son histoire
//       (appli photo, kiné, SNCF…) — deux abonnements inattendus sont des INDICES.

import SwiftUI

// ============================================================ PALETTE (échantillonnée sur les frames)
enum AsPalette {
    static let fond = Color.black                       // 0x000000 — fond des 5 onglets
    static let carte = Color(hex: 0x1C1C1E)             // cartes éditoriales / listes sur fond noir
    static let fondFeuille = Color(hex: 0x1C1C1E)       // fond des feuilles (Compte Apple)
    static let carteFeuille = Color(hex: 0x2C2C2E)      // cartes groupées dans les feuilles
    static let bouton = Color(hex: 0x2C2C2E)            // capsule « Ouvrir » / « Mettre à jour »
    static let separateur = Color(hex: 0x38383A)
    static let bleu = Color(hex: 0x0A84FF)
    static let gris = Color(hex: 0x8E8E93)
    static let grisClair = Color(hex: 0xAEAEB2)
    static let rouge = Color(hex: 0xFF453A)
}

// Un symbole SF absent du système de déploiement retombe sur un repli sûr (aucune API iOS 18+).
func asSymbole(_ nom: String, repli: String) -> String {
    let choix: String = UIImage(systemName: nom) != nil ? nom : repli
    return choix
}

// ============================================================ MODÈLE
struct AsApp: Identifiable, Hashable {
    let id: String                 // = nom, clé unique (aucun doublon dans AsCatalogue)
    let editeur: String
    let accroche: String
    let categorie: String
    let note: Double
    let nbNotes: String
    let age: String
    let taille: String
    let prix: String?              // nil = gratuit
    let achatsIntegres: Bool
    let asset: String?             // pellicule « ic-… » quand l'icône réelle existe
    let fond: UInt
    let symbole: String
    let teinte: UInt
    let appDuJeu: String?          // nom exact d'une app de la coque (actionPour) ou nil
    let version: String
    let nouveautes: String
    let resume: String
    let classement: String?
    let arcade: Bool

    var nom: String { id }
    var couleur: Color { Color(hex: fond) }

    init(_ id: String, editeur: String, accroche: String, categorie: String,
         note: Double = 4.5, nbNotes: String = "1,2 k notes", age: String = "4+",
         taille: String = "148,2 Mo", prix: String? = nil, achatsIntegres: Bool = false,
         asset: String? = nil, fond: UInt = 0x3A3A3C, symbole: String = "app.fill",
         teinte: UInt = 0xFFFFFF, appDuJeu: String? = nil, version: String = "1.0.0",
         nouveautes: String = "Diverses corrections et améliorations.",
         resume: String = "", classement: String? = nil, arcade: Bool = false) {
        self.id = id; self.editeur = editeur; self.accroche = accroche; self.categorie = categorie
        self.note = note; self.nbNotes = nbNotes; self.age = age; self.taille = taille
        self.prix = prix; self.achatsIntegres = achatsIntegres; self.asset = asset
        self.fond = fond; self.symbole = symbole; self.teinte = teinte; self.appDuJeu = appDuJeu
        self.version = version; self.nouveautes = nouveautes
        self.resume = resume.isEmpty ? accroche : resume
        self.classement = classement; self.arcade = arcade
    }
}

struct AsAchat: Identifiable, Hashable {
    let id: String
    let titre: String
    let type: String
    let prix: String
    let app: String              // nom d'app du catalogue (icône)
    let numeroCommande: String
    let dateCommande: String
}

struct AsAbonnement: Identifiable, Hashable {
    let id: String
    let app: String
    let offre: String
    let prix: String
    let echeance: String
    let actif: Bool
    let alerte: String?
}

struct AsMaj: Identifiable, Hashable {
    let id: String               // = nom d'app
    let quand: String
    let version: String
    let notes: String
}

struct AsAvis: Identifiable, Hashable {
    let id: String
    let app: String
    let quand: String
    let etoiles: Int
}

// ============================================================ CATALOGUE (fixe, à faible densité — piège de coût évité)
enum AsCatalogue {

    // ---- Les apps du téléphone de Sarah (D59) + le petit catalogue de la boutique.
    static let apps: [AsApp] = [
        // — Apps installées sur le téléphone du jeu (tierces) —
        AsApp("Instagram", editeur: "Instagram, Inc.", accroche: "Photos et vidéos entre amis",
              categorie: "Réseaux sociaux", note: 4.7, nbNotes: "1,4 M notes", age: "12+", taille: "312,6 Mo",
              asset: "ic-instagram", fond: 0xE1306C, symbole: "camera.circle", appDuJeu: "Instagram",
              version: "391.0", nouveautes: "Nouveaux effets pour les stories et corrections de stabilité.",
              resume: "Partagez vos photos, vos stories et vos reels avec vos proches, et suivez ce qui compte pour vous.",
              classement: "N°3"),
        AsApp("Snapchat", editeur: "Snap, Inc.", accroche: "Partagez l'instant présent",
              categorie: "Réseaux sociaux", note: 4.3, nbNotes: "986 k notes", age: "12+", taille: "428,1 Mo",
              asset: "ic-snapchat", fond: 0xFFFC00, symbole: "bubble.left.fill", teinte: 0x000000,
              appDuJeu: "Snapchat", version: "13.12.0",
              nouveautes: "La carte affiche à nouveau la position de vos ami·e·s en temps réel.",
              resume: "Snapchat, c'est la façon la plus rapide de partager un moment. Discutez, envoyez des snaps, retrouvez vos ami·e·s sur la carte.",
              classement: "N°7"),
        AsApp("Facebook", editeur: "Meta Platforms, Inc.", accroche: "Retrouvez vos proches",
              categorie: "Réseaux sociaux", note: 3.9, nbNotes: "2,1 M notes", age: "12+", taille: "391,4 Mo",
              asset: "ic-facebook", fond: 0x0866FF, symbole: "f.circle.fill", appDuJeu: "Facebook",
              version: "512.1", nouveautes: "Le fil charge plus vite et les groupes se mettent à jour en direct.",
              resume: "Restez en contact avec vos amis et votre famille, suivez les groupes qui vous intéressent et partagez ce que vous vivez."),
        AsApp("Messenger", editeur: "Meta Platforms, Inc.", accroche: "Messages et appels vidéo",
              categorie: "Réseaux sociaux", note: 4.1, nbNotes: "1,1 M notes", age: "12+", taille: "268,9 Mo",
              asset: "ic-messenger", fond: 0x0084FF, symbole: "bolt.horizontal.circle.fill",
              appDuJeu: "Messenger", version: "487.0",
              nouveautes: "Réactions plus rapides et confirmations de lecture plus fiables.",
              resume: "Discutez gratuitement avec toutes vos relations Facebook, en tête-à-tête ou en groupe."),
        AsApp("WhatsApp", editeur: "WhatsApp Inc.", accroche: "Messagerie simple et fiable",
              categorie: "Réseaux sociaux", note: 4.6, nbNotes: "3,4 M notes", age: "12+", taille: "251,7 Mo",
              asset: "ic-whatsapp", fond: 0x25D366, symbole: "phone.fill", appDuJeu: "WhatsApp",
              version: "25.18.74", nouveautes: "Les brouillons de message sont conservés d'un appareil à l'autre.",
              resume: "Envoyez des messages, des photos et des messages vocaux à vos proches, où qu'ils soient."),
        AsApp("X", editeur: "X Corp.", accroche: "L'actualité en direct",
              categorie: "Actualités", note: 3.6, nbNotes: "412 k notes", age: "17+", taille: "196,3 Mo",
              asset: "ic-x", fond: 0x000000, symbole: "xmark", appDuJeu: "X", version: "11.4",
              resume: "Suivez ce qui se passe en direct, partout dans le monde."),
        AsApp("ChatGPT", editeur: "OpenAI OpCo, LLC", accroche: "Votre assistant IA quotidien",
              categorie: "Productivité", note: 4.8, nbNotes: "1,8 M notes", age: "12+", taille: "212,4 Mo",
              achatsIntegres: true, asset: "ic-chatgpt", fond: 0xFFFFFF, symbole: "circle.hexagongrid.fill",
              teinte: 0x000000, appDuJeu: "ChatGPT", version: "1.2026.240",
              nouveautes: "Réponses plus rapides et historique de conversation amélioré.",
              resume: "Posez vos questions, faites relire un texte, obtenez des idées : ChatGPT répond en quelques secondes.",
              classement: "N°1"),
        AsApp("Spotify", editeur: "Spotify AB", accroche: "Musique et podcasts",
              categorie: "Musique", note: 4.7, nbNotes: "1,6 M notes", age: "12+", taille: "184,0 Mo",
              achatsIntegres: true, asset: "ic-spotify", fond: 0x000000, symbole: "circle.circle.fill",
              teinte: 0x1ED760, appDuJeu: "Spotify", version: "9.0.42",
              resume: "Des millions de titres et de podcasts, gratuitement."),
        AsApp("YouTube", editeur: "Google LLC", accroche: "Vidéos, musique et direct",
              categorie: "Photo et vidéo", note: 4.6, nbNotes: "2,9 M notes", age: "17+", taille: "342,8 Mo",
              achatsIntegres: true, asset: "ic-youtube", fond: 0xFFFFFF, symbole: "play.rectangle.fill",
              teinte: 0xFF0000, appDuJeu: "YouTube", version: "20.33.4",
              resume: "Regardez les vidéos et les chaînes que vous aimez, et découvrez-en de nouvelles."),
        AsApp("PayPal", editeur: "PayPal, Inc.", accroche: "Payez et envoyez de l'argent",
              categorie: "Finance", note: 4.7, nbNotes: "742 k notes", age: "4+", taille: "168,9 Mo",
              fond: 0x003087, symbole: "p.circle.fill", version: "8.62.0",
              nouveautes: "Les virements entre proches s'affichent immédiatement dans l'activité.",
              resume: "Payez en ligne, envoyez de l'argent à vos proches et suivez toutes vos opérations."),
        AsApp("LCL Mes Comptes", editeur: "Crédit Lyonnais", accroche: "Votre banque au quotidien",
              categorie: "Finance", note: 4.4, nbNotes: "128 k notes", age: "4+", taille: "96,4 Mo",
              fond: 0x123E6B, symbole: "building.columns.fill", appDuJeu: "Ma Banque", version: "12.7.1",
              nouveautes: "Virements plus rapides et nouvelle vue des plafonds de carte.",
              resume: "Consultez vos comptes, effectuez vos virements et gérez vos cartes depuis votre iPhone."),

        // — Achetées mais retirées du téléphone (« Pas sur cet iPhone ») : cohérence D59 —
        AsApp("Doctolib", editeur: "Doctolib SAS", accroche: "Rendez-vous médicaux",
              categorie: "Médecine", note: 4.8, nbNotes: "418 k notes", age: "4+", taille: "82,1 Mo",
              fond: 0x0596DE, symbole: "cross.case.fill", version: "26.7.0",
              resume: "Prenez rendez-vous avec un professionnel de santé en quelques secondes et retrouvez vos ordonnances."),
        AsApp("SNCF Connect", editeur: "SNCF Voyageurs", accroche: "Billets de train et trafic",
              categorie: "Voyages", note: 4.6, nbNotes: "296 k notes", age: "4+", taille: "121,3 Mo",
              fond: 0x6E1E78, symbole: "tram.fill", version: "8.14.2",
              resume: "Achetez vos billets, suivez votre train en temps réel et gardez vos trajets à portée de main."),
        AsApp("Darkroom : Photo & Vidéo", editeur: "Bergen Co.", accroche: "Retouche photo de studio",
              categorie: "Photo et vidéo", note: 4.7, nbNotes: "34 k notes", age: "4+", taille: "142,6 Mo",
              achatsIntegres: true, fond: 0x1B1B1F, symbole: "camera.aperture", teinte: 0xFF9F0A,
              version: "7.4.1", nouveautes: "Nouveaux profils de couleur et export plus rapide.",
              resume: "Un éditeur photo et vidéo complet, pensé pour aller vite : courbes, calques de couleur, export sans perte."),
        AsApp("Kiné+ Suivi", editeur: "Espace Kiné", accroche: "Vos séances et vos exercices",
              categorie: "Forme et santé", note: 4.2, nbNotes: "2,1 k notes", age: "4+", taille: "54,7 Mo",
              achatsIntegres: true, fond: 0x2FB4A6, symbole: "figure.walk", version: "3.9.0",
              resume: "Retrouvez le programme d'exercices donné par votre kinésithérapeute et notez votre douleur séance après séance."),
        AsApp("Vinted", editeur: "Vinted UAB", accroche: "Vendez ce que vous ne portez plus",
              categorie: "Shopping", note: 4.7, nbNotes: "512 k notes", age: "12+", taille: "134,2 Mo",
              fond: 0x09B1BA, symbole: "tshirt.fill", version: "26.30.1",
              resume: "Achetez et vendez des vêtements de seconde main, en direct entre particuliers."),
        AsApp("BlaBlaCar", editeur: "Comuto SA", accroche: "Covoiturage et bus",
              categorie: "Voyages", note: 4.5, nbNotes: "184 k notes", age: "4+", taille: "112,8 Mo",
              fond: 0x00AFF5, symbole: "car.fill", version: "6.42.0",
              resume: "Trouvez un trajet en covoiturage ou en bus, partout en France."),

        // — INDICES : deux abonnements que Sarah n'a plus sur son téléphone, mais qui sont toujours prélevés —
        AsApp("GoldTrade Pro", editeur: "GTP Markets Ltd", accroche: "Signaux Or & devises en temps réel",
              categorie: "Finance", note: 3.1, nbNotes: "412 notes", age: "17+", taille: "78,4 Mo",
              achatsIntegres: true, fond: 0x0E1116, symbole: "chart.line.uptrend.xyaxis", teinte: 0xD4AF37,
              version: "4.2.7", nouveautes: "Nouvelle salle de marché privée pour les membres Premium.",
              resume: "Recevez les signaux de nos analystes sur l'or, les devises et les matières premières. Accompagnement individuel pour les membres Premium. Investir comporte un risque de perte en capital."),
        AsApp("Cœur à Cœur", editeur: "Rencontres Éditions SAS", accroche: "Rencontres sérieuses après 40 ans",
              categorie: "Style de vie", note: 3.4, nbNotes: "8,6 k notes", age: "17+", taille: "96,1 Mo",
              achatsIntegres: true, fond: 0xB3123F, symbole: "heart.fill",
              version: "5.11.0", nouveautes: "Le badge « profil vérifié » est de retour.",
              resume: "Des rencontres sincères, à votre rythme. Discutez sans limite avec l'abonnement Premium."),

        // — Jamais achetées (bouton « Obtenir » réel) —
        AsApp("TikTok", editeur: "TikTok Ltd.", accroche: "Vidéos, musiques et LIVE",
              categorie: "Divertissement", note: 4.6, nbNotes: "3,1 M notes", age: "12+", taille: "486,2 Mo",
              achatsIntegres: true, asset: "ic-tiktok", fond: 0x000000, symbole: "music.note",
              version: "40.1.0", resume: "Découvrez des vidéos courtes qui vous ressemblent.", classement: "N°2"),
        AsApp("Duolingo : Langues", editeur: "Duolingo, Inc.", accroche: "Anglais, espagnol et plus",
              categorie: "Éducation", note: 4.8, nbNotes: "1,2 M notes", age: "4+", taille: "142,9 Mo",
              achatsIntegres: true, fond: 0x58CC02, symbole: "graduationcap.fill",
              version: "8.14.0", resume: "Apprenez une langue en cinq minutes par jour, gratuitement."),
        AsApp("leboncoin", editeur: "leboncoin SAS", accroche: "Annonces près de chez vous",
              categorie: "Shopping", note: 4.6, nbNotes: "612 k notes", age: "12+", taille: "128,4 Mo",
              fond: 0xFF6E14, symbole: "tag.fill", version: "9.28.0",
              resume: "Achetez et vendez tout, près de chez vous."),
        AsApp("Adobe Acrobat Reader", editeur: "Adobe Inc.", accroche: "Lire, signer, convertir un PDF",
              categorie: "Utilitaires", note: 4.7, nbNotes: "204 k notes", age: "4+", taille: "312,1 Mo",
              achatsIntegres: true, fond: 0xB30B00, symbole: "doc.fill", version: "26.7.2",
              resume: "Ouvrez, annotez et signez vos PDF depuis votre iPhone."),
        AsApp("Telegram", editeur: "Telegram FZ-LLC", accroche: "Messagerie rapide et chiffrée",
              categorie: "Réseaux sociaux", note: 4.6, nbNotes: "482 k notes", age: "17+", taille: "146,7 Mo",
              asset: "ic-telegram", fond: 0x2AABEE, symbole: "paperplane.fill", version: "11.9.1",
              resume: "Messages, groupes et canaux, sur tous vos appareils."),
        AsApp("Google Chrome", editeur: "Google LLC", accroche: "Navigateur web rapide",
              categorie: "Utilitaires", note: 4.5, nbNotes: "398 k notes", age: "17+", taille: "224,3 Mo",
              fond: 0xFFFFFF, symbole: "globe", teinte: 0x1A73E8, version: "141.0",
              resume: "Naviguez vite, avec vos favoris synchronisés."),

        // — Jeux (onglet Jeux, contenu réduit et fixe) —
        AsApp("Clash Royale", editeur: "Supercell", accroche: "Combat de cartes multijoueur",
              categorie: "Stratégie", note: 4.5, nbNotes: "1,24 M notes", age: "9+", taille: "612,4 Mo",
              achatsIntegres: true, fond: 0x1C63B8, symbole: "crown.fill", version: "72.0.4",
              resume: "Collectionnez les cartes, montez votre deck et affrontez des joueurs du monde entier en duels de deux minutes.",
              classement: "N°4"),
        AsApp("MONOPOLY GO!", editeur: "Scopely, Inc.", accroche: "Lancez les dés et rêvez !",
              categorie: "Jeux de société", note: 4.7, nbNotes: "864 k notes", age: "4+", taille: "486,1 Mo",
              achatsIntegres: true, fond: 0xE01B22, symbole: "die.face.5.fill", version: "1.68.0",
              resume: "Le MONOPOLY que vous connaissez, en version express : lancez, construisez, dévalisez vos amis.",
              classement: "N°1"),
        AsApp("Roblox", editeur: "Roblox Corporation", accroche: "Des millions d'expériences",
              categorie: "Aventure", note: 4.5, nbNotes: "2,4 M notes", age: "13+", taille: "412,7 Mo",
              achatsIntegres: true, fond: 0xE2231A, symbole: "cube.fill", version: "2.687.0",
              resume: "Explorez des millions d'expériences créées par la communauté, seul ou avec vos amis.",
              classement: "N°2"),
        AsApp("Block Blast!", editeur: "Hungry Studio", accroche: "Casse-tête de blocs",
              categorie: "Casse-tête", note: 4.8, nbNotes: "1,1 M notes", age: "4+", taille: "212,6 Mo",
              achatsIntegres: true, fond: 0x6C4BF6, symbole: "square.grid.3x3.fill", version: "6.4.1",
              resume: "Faites tomber les blocs, videz la grille, battez votre record.", classement: "N°3"),
        AsApp("2048 : Number Puzzle", editeur: "erkay uzun", accroche: "Casse-tête de nombres",
              categorie: "Casse-tête", note: 4.7, nbNotes: "377 notes", age: "4+", taille: "38,2 Mo",
              achatsIntegres: true, fond: 0xEDC22E, symbole: "square.grid.2x2.fill", version: "2.9.0",
              resume: "Glissez, fusionnez, atteignez 2048. Une partie dure le temps d'un café."),

        // — Apple Arcade (onglet Arcade, fidèle mais fixe) —
        AsApp("Sneaky Sasquatch", editeur: "RAC7 Games", accroche: "Vivez la vie d'un sasquatch",
              categorie: "Aventure", note: 4.7, nbNotes: "42 k notes", age: "9+", taille: "1,2 Go",
              fond: 0x2E7D4F, symbole: "leaf.fill", version: "1.9.2",
              resume: "Fouillez les glacières, déguisez-vous en humain et explorez un parc entier. Sans pubs ni achats intégrés.",
              arcade: true),
        AsApp("NFL Retro Bowl '27", editeur: "New Star Games", accroche: "Football américain rétro",
              categorie: "Sports", note: 4.6, nbNotes: "18 k notes", age: "4+", taille: "312,0 Mo",
              fond: 0x1D3A5F, symbole: "football.fill", version: "1.4.0",
              resume: "Gérez votre franchise et jouez les phases décisives. Sans pubs ni achats intégrés.",
              arcade: true),
        AsApp("Water Sort Puzzle+", editeur: "IEC Global", accroche: "Triez les couleurs",
              categorie: "Casse-tête", note: 4.5, nbNotes: "9,4 k notes", age: "4+", taille: "96,8 Mo",
              fond: 0x1B87C9, symbole: "drop.fill", version: "2.2.1",
              resume: "Versez, triez, respirez. Sans pubs ni achats intégrés.", arcade: true),
    ]

    static func app(_ nom: String) -> AsApp? { apps.first { $0.id == nom } }

    // ---- D59 : les apps INSTALLÉES sont celles du téléphone du jeu (31 apps annoncées par Réglages).
    // Les apps intégrées d'Apple sont datées de la mise en service de l'iPhone.
    static let installeesInitiales: [String] = [
        "Instagram", "Snapchat", "Facebook", "Messenger", "WhatsApp", "X",
        "ChatGPT", "Spotify", "YouTube", "PayPal", "LCL Mes Comptes",
    ]

    // Les 31 apps du téléphone, telles qu'elles apparaissent dans « Apps et achats → Apps ».
    static let vosApps: [(String, String)] = [
        ("Instagram", "14 août 2026"), ("WhatsApp", "12 août 2026"), ("Snapchat", "9 août 2026"),
        ("Messenger", "7 août 2026"), ("Facebook", "2 août 2026"), ("PayPal", "28 juil. 2026"),
        ("ChatGPT", "21 juil. 2026"), ("LCL Mes Comptes", "3 juil. 2026"), ("Spotify", "19 juin 2026"),
        ("YouTube", "11 juin 2026"), ("X", "4 mai 2026"),
        ("Mail", "9 nov. 2024"), ("Messages", "9 nov. 2024"), ("Téléphone", "9 nov. 2024"),
        ("Safari", "9 nov. 2024"), ("Photos", "9 nov. 2024"), ("Musique", "9 nov. 2024"),
        ("App Store", "9 nov. 2024"), ("Réglages", "9 nov. 2024"), ("Plans", "9 nov. 2024"),
        ("Notes", "9 nov. 2024"), ("Rappels", "9 nov. 2024"), ("Calendrier", "9 nov. 2024"),
        ("Horloge", "9 nov. 2024"), ("Météo", "9 nov. 2024"), ("Calculatrice", "9 nov. 2024"),
        ("Dictaphone", "9 nov. 2024"), ("Fichiers", "9 nov. 2024"), ("Cartes", "9 nov. 2024"),
        ("Santé", "9 nov. 2024"), ("Localiser", "9 nov. 2024"),
    ]

    // « Pas sur cet iPhone » — achetées puis supprimées (le nuage propose de les retélécharger).
    static let appsAbsentes: [(String, String)] = [
        ("GoldTrade Pro", "3 juil. 2026"), ("Cœur à Cœur", "9 juin 2026"),
        ("Darkroom : Photo & Vidéo", "28 juil. 2026"), ("Doctolib", "22 juil. 2026"),
        ("SNCF Connect", "11 juil. 2026"), ("Kiné+ Suivi", "6 mars 2026"),
        ("Vinted", "18 févr. 2026"), ("BlaBlaCar", "12 janv. 2026"),
    ]

    // Les apps du jeu qui ne sont pas des apps de l'App Store (icône seule, pas de fiche).
    static let iconesSysteme: [String: (String, UInt, String, UInt)] = [
        "Mail": ("ic-mail", 0x0A84FF, "envelope.fill", 0xFFFFFF),
        "Messages": ("ic-messages", 0x30D158, "message.fill", 0xFFFFFF),
        "Téléphone": ("ic-telephone", 0x30D158, "phone.fill", 0xFFFFFF),
        "Safari": ("ic-safari", 0xFFFFFF, "safari.fill", 0x0A84FF),
        "Photos": ("ic-photos", 0xFFFFFF, "photo.on.rectangle.angled", 0xE64980),
        "Musique": ("ic-musique", 0xFA2D48, "music.note", 0xFFFFFF),
        "App Store": ("ic-app-store", 0x0A84FF, "square.stack.3d.up.fill", 0xFFFFFF),
        "Réglages": ("ic-reglages", 0x8E8E93, "gearshape.fill", 0xFFFFFF),
        "Plans": ("ic-plans", 0x34C3FF, "location.north.circle.fill", 0xFFFFFF),
        "Notes": ("ic-notes", 0xFFCC00, "note.text", 0xFFFFFF),
        "Rappels": ("ic-rappels", 0xFFFFFF, "checklist", 0x0A84FF),
        "Calendrier": ("ic-calendrier", 0xFFFFFF, "calendar", 0xFF3B30),
        "Horloge": ("ic-horloge", 0x1C1C1E, "clock", 0xFFFFFF),
        "Météo": ("ic-meteo", 0x54C7FC, "sun.max.fill", 0xFFD60A),
        "Calculatrice": ("", 0x2C2C2E, "plus.slash.minus", 0xFF9F0A),
        "Dictaphone": ("", 0x1C1C1E, "waveform", 0xFF3B30),
        "Fichiers": ("ic-fichiers", 0xFFFFFF, "folder.fill", 0x0A84FF),
        "Cartes": ("ic-cartes", 0x000000, "wallet.pass.fill", 0xFFFFFF),
        "Santé": ("ic-sante", 0xFFFFFF, "heart.fill", 0xFA5252),
        "Localiser": ("ic-localiser", 0x32D74B, "dot.radiowaves.left.and.right", 0xFFFFFF),
        "iCloud+": ("", 0xFFFFFF, "icloud.fill", 0x3AA9F0),
        "Apple Music": ("ic-musique", 0xFA2D48, "music.note", 0xFFFFFF),
    ]

    // Le nom de l'app de la coque à ouvrir (identique à actionPour dans LPProto).
    static let appDuJeuSysteme: [String: String] = [
        "Mail": "Mail", "Messages": "Messages", "Téléphone": "Téléphone", "Safari": "Safari",
        "Photos": "Photos", "Réglages": "Réglages", "Plans": "Plans", "Notes": "Notes",
        "Rappels": "Rappels", "Calendrier": "Calendrier", "Horloge": "Horloge", "Météo": "Météo",
        "Calculatrice": "Calculatrice", "Dictaphone": "Dictaphone", "Fichiers": "Fichiers",
        "Cartes": "Cartes", "Santé": "Santé", "Localiser": "Localiser",
    ]

    // ---- Mises à jour d'apps de Sarah (D82-A : « Mettre à jour » retire réellement la ligne).
    static let majs: [AsMaj] = [
        AsMaj(id: "Instagram", quand: "Hier", version: "391.0",
              notes: "Nouveaux effets pour les stories et corrections de stabilité."),
        AsMaj(id: "Snapchat", quand: "Il y a 2 jours", version: "13.12.0",
              notes: "La carte affiche à nouveau la position de vos ami·e·s en temps réel."),
        AsMaj(id: "PayPal", quand: "Il y a 3 jours", version: "8.62.0",
              notes: "Les virements entre proches s'affichent immédiatement dans l'activité."),
        AsMaj(id: "GoldTrade Pro", quand: "Il y a 4 jours", version: "4.2.7",
              notes: "Nouvelle salle de marché privée pour les membres Premium."),
        AsMaj(id: "LCL Mes Comptes", quand: "Il y a 6 jours", version: "12.7.1",
              notes: "Virements plus rapides et nouvelle vue des plafonds de carte."),
        AsMaj(id: "Facebook", quand: "Il y a 1 semaine", version: "512.1",
              notes: "Le fil charge plus vite et les groupes se mettent à jour en direct."),
    ]

    // ---- Historique d'achats (canon : lundi 17 août 2026). Groupé par date, dates uniques.
    static let achats: [(String, [AsAchat])] = [
        ("14 août 2026", [
            AsAchat(id: "a1", titre: "GoldTrade Pro — Accès Signaux Premium", type: "Abonnement",
                    prix: "39,99 €", app: "GoldTrade Pro", numeroCommande: "MX8QLD24R1",
                    dateCommande: "14 août 2026 06:12"),
        ]),
        ("9 août 2026", [
            AsAchat(id: "a2", titre: "Cœur à Cœur — Premium 1 mois", type: "Abonnement",
                    prix: "24,99 €", app: "Cœur à Cœur", numeroCommande: "MX7KPB90V4",
                    dateCommande: "9 août 2026 21:47"),
        ]),
        ("2 août 2026", [
            AsAchat(id: "a3", titre: "Abonnement Apple Music", type: "Abonnement",
                    prix: "10,99 €", app: "Apple Music", numeroCommande: "MX6RTN18C7",
                    dateCommande: "2 août 2026 08:03"),
        ]),
        ("28 juil. 2026", [
            AsAchat(id: "a4", titre: "Darkroom — Déblocage complet", type: "Achat intégré",
                    prix: "8,99 €", app: "Darkroom : Photo & Vidéo", numeroCommande: "MX5JHV72K3",
                    dateCommande: "28 juil. 2026 14:26"),
        ]),
        ("21 juil. 2026", [
            AsAchat(id: "a5", titre: "iCloud+ 200 Go de stockage", type: "Abonnement",
                    prix: "2,99 €", app: "iCloud+", numeroCommande: "MX4DGS40B9",
                    dateCommande: "21 juil. 2026 07:15"),
        ]),
        ("14 juil. 2026", [
            AsAchat(id: "a6", titre: "GoldTrade Pro — Accès Signaux Premium", type: "Abonnement",
                    prix: "39,99 €", app: "GoldTrade Pro", numeroCommande: "MX3WQE61L2",
                    dateCommande: "14 juil. 2026 06:11"),
        ]),
        ("9 juil. 2026", [
            AsAchat(id: "a7", titre: "Cœur à Cœur — Premium 1 mois", type: "Abonnement",
                    prix: "24,99 €", app: "Cœur à Cœur", numeroCommande: "MX2ZAX55N8",
                    dateCommande: "9 juil. 2026 21:44"),
            AsAchat(id: "a8", titre: "Kiné+ Suivi — Programme 3 mois", type: "Achat intégré",
                    prix: "14,99 €", app: "Kiné+ Suivi", numeroCommande: "MX2ZAX55N9",
                    dateCommande: "9 juil. 2026 10:02"),
        ]),
        ("2 juil. 2026", [
            AsAchat(id: "a9", titre: "Abonnement Apple Music", type: "Abonnement",
                    prix: "10,99 €", app: "Apple Music", numeroCommande: "MX1BFC33H5",
                    dateCommande: "2 juil. 2026 08:02"),
        ]),
    ]

    // ---- Abonnements (l'indice : deux prélèvements que Sarah n'a plus sur son téléphone).
    static let abonnements: [AsAbonnement] = [
        AsAbonnement(id: "s1", app: "GoldTrade Pro", offre: "Accès Signaux Premium", prix: "39,99 €",
                     echeance: "Renouv. le 14 septembre", actif: true, alerte: nil),
        AsAbonnement(id: "s2", app: "Cœur à Cœur", offre: "Premium 1 mois", prix: "24,99 €",
                     echeance: "Renouv. le 9 septembre", actif: true, alerte: nil),
        AsAbonnement(id: "s3", app: "Apple Music", offre: "Individuel", prix: "10,99 €",
                     echeance: "Renouv. le 2 septembre", actif: true, alerte: nil),
        AsAbonnement(id: "s4", app: "iCloud+", offre: "iCloud+ 200 Go de stockage", prix: "2,99 €",
                     echeance: "Renouv. le 21 août", actif: true, alerte: nil),
        AsAbonnement(id: "s5", app: "Spotify", offre: "Premium Individuel", prix: "11,99 €",
                     echeance: "Expire le 24 août", actif: true, alerte: "Expire le 24 août"),
        AsAbonnement(id: "s6", app: "Kiné+ Suivi", offre: "Programme 3 mois", prix: "14,99 €",
                     echeance: "Expiré le 9 octobre", actif: false, alerte: nil),
    ]

    // ---- Notes et avis laissés par Sarah (contenu réellement accessible — D92).
    static let avis: [AsAvis] = [
        AsAvis(id: "v1", app: "Doctolib", quand: "Publié le 22/07/2026", etoiles: 5),
        AsAvis(id: "v2", app: "Darkroom : Photo & Vidéo", quand: "Publié le 28/07/2026", etoiles: 5),
        AsAvis(id: "v3", app: "SNCF Connect", quand: "Publié le 11/07/2026", etoiles: 4),
        AsAvis(id: "v4", app: "GoldTrade Pro", quand: "Publié le 05/07/2026", etoiles: 2),
        AsAvis(id: "v5", app: "Kiné+ Suivi", quand: "Publié le 06/03/2026", etoiles: 4),
    ]

    // ---- Contenu éditorial fixe (Aujourd'hui / Jeux / Apps / Arcade) — quelques cartes, densité réduite.
    static let favoris: [String] = ["ChatGPT", "Duolingo : Langues", "TikTok", "Snapchat", "Telegram"]
    static let jeuxIncontournables: [String] = ["Roblox", "MONOPOLY GO!", "Clash Royale", "Block Blast!"]
    static let appsIndispensables: [String] = ["Adobe Acrobat Reader", "Google Chrome", "Vinted", "leboncoin"]
    static let jeuxArcade: [String] = ["Sneaky Sasquatch", "NFL Retro Bowl '27", "Water Sort Puzzle+"]
    static let suggestions: [String] = ["Clash Royale", "MONOPOLY GO!", "Doctolib"]
    static let parcourir: [(String, UInt)] = [
        ("Apps les plus téléchargées", 0x3A6FF7), ("Jeux les plus téléchargés", 0xF07A22),
        ("Apps les plus vendues", 0x2FA84F), ("Jeux les plus vendus", 0x8A4BE0),
    ]
}

// ============================================================ ÉTAT (persistant : un téléchargement est une conséquence réelle)
final class MagasinAppStore: ObservableObject {
    static let partage = MagasinAppStore()

    @Published var installees: Set<String> = Set(AsCatalogue.installeesInitiales)
    @Published var majEnAttente: [String] = AsCatalogue.majs.map { $0.id }
    @Published var enCours: [String: Double] = [:]

    private init() {}

    func estInstallee(_ nom: String) -> Bool { installees.contains(nom) }
    func majDisponible(_ nom: String) -> Bool { majEnAttente.contains(nom) }

    func obtenir(_ nom: String) {
        guard enCours[nom] == nil, !installees.contains(nom) else { return }
        enCours[nom] = 0.03
    }

    func mettreAJour(_ nom: String) {
        majEnAttente.removeAll { $0 == nom }
    }

    func toutMettreAJour() {
        majEnAttente.removeAll()
    }

    // Un seul minuteur (dans AppStoreVue) fait avancer tous les téléchargements en cours.
    func avancer() {
        guard !enCours.isEmpty else { return }
        var termines: [String] = []
        for (nom, valeur) in enCours {
            let suite = valeur + 0.045
            if suite >= 1 { termines.append(nom) } else { enCours[nom] = suite }
        }
        for nom in termines {
            enCours.removeValue(forKey: nom)
            installees.insert(nom)
        }
    }
}

// Pont vers la coque : « Ouvrir » ouvre RÉELLEMENT l'app du jeu (câblage dans AccueilView, voir le patch).
final class PontAppStore: ObservableObject {
    static let partage = PontAppStore()
    @Published var demande: Int = 0
    var appAOuvrir: String? = nil
    private init() {}
    func ouvrir(_ nom: String) { appAOuvrir = nom; demande += 1 }
    func consommer() -> String? { let n = appAOuvrir; appAOuvrir = nil; return n }
}

// ============================================================ BRIQUES VISUELLES
struct AsIcone: View {
    let nom: String
    var taille: CGFloat = 62
    var rayon: CGFloat = 14

    private var visuel: (String, UInt, String, UInt) {
        if let a = AsCatalogue.app(nom) {
            return (a.asset ?? "", a.fond, a.symbole, a.teinte)
        }
        if let s = AsCatalogue.iconesSysteme[nom] { return s }
        return ("", 0x3A3A3C, "app.fill", 0xFFFFFF)
    }

    var body: some View {
        let v = visuel
        let image: UIImage? = v.0.isEmpty ? nil : chargerPellicule(v.0)
        Group {
            if let ui = image {
                Color.clear
                    .overlay(Image(uiImage: ui).resizable().scaledToFill())
                    .clipped()
            } else {
                Color(hex: v.1)
                    .overlay(
                        Image(systemName: v.2)
                            .font(.system(size: taille * 0.46))
                            .foregroundStyle(Color(hex: v.3))
                    )
            }
        }
        .frame(width: taille, height: taille)
        .clipShape(RoundedRectangle(cornerRadius: rayon, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: rayon, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }
}

// Anneau de progression (frames e123-e127 : le rond de téléchargement remplace le bouton).
struct AsAnneau: View {
    let progression: Double
    var taille: CGFloat = 28
    var body: some View {
        ZStack {
            Circle().strokeBorder(AsPalette.gris.opacity(0.45), lineWidth: 2)
            Circle()
                .trim(from: 0, to: progression)
                .stroke(AsPalette.bleu, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
            RoundedRectangle(cornerRadius: 1.5)
                .fill(AsPalette.bleu)
                .frame(width: taille * 0.26, height: taille * 0.26)
        }
        .frame(width: taille, height: taille)
        .animation(.linear(duration: 0.1), value: progression)
    }
}

// Bouton d'action d'une ligne / d'une fiche. D82-A : chaque état a une conséquence réelle.
struct AsBoutonAction: View {
    @ObservedObject private var magasin = MagasinAppStore.partage
    let app: AsApp
    var grand: Bool = false
    var ouvrirApp: (AsApp) -> Void

    var body: some View {
        let installee = magasin.estInstallee(app.nom)
        let maj = magasin.majDisponible(app.nom)
        let progression = magasin.enCours[app.nom]

        Group {
            if let p = progression {
                AsAnneau(progression: p, taille: grand ? 34 : 28)
            } else if app.arcade && !installee {
                Text("Arcade")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AsPalette.grisClair)
            } else if installee && maj {
                capsule("Mettre à jour") { magasin.mettreAJour(app.nom) }
            } else if installee {
                capsule("Ouvrir") { ouvrirApp(app) }
            } else if let prix = app.prix {
                capsule(prix) { magasin.obtenir(app.nom) }
            } else {
                capsule("Obtenir") { magasin.obtenir(app.nom) }
            }
        }
    }

    @ViewBuilder
    private func capsule(_ titre: String, action: @escaping () -> Void) -> some View {
        if grand {
            Text(titre)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(minWidth: 100)
                .padding(.horizontal, 18).padding(.vertical, 8)
                .background(Capsule().fill(AsPalette.bleu))
                .contentShape(Capsule())
                .onTapGesture { action() }
        } else {
            Text(titre)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AsPalette.bleu)
                .lineLimit(1)
                .padding(.horizontal, 16).padding(.vertical, 6)
                .background(Capsule().fill(AsPalette.bouton))
                .contentShape(Capsule())
                .onTapGesture { action() }
        }
    }
}

// Nuage de retéléchargement (frames e205-e211 : les apps « Pas sur cet iPhone »).
struct AsNuage: View {
    @ObservedObject private var magasin = MagasinAppStore.partage
    let nom: String
    var body: some View {
        Group {
            if let p = magasin.enCours[nom] {
                AsAnneau(progression: p)
            } else if magasin.estInstallee(nom) {
                Text("Ouvrir")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AsPalette.bleu)
                    .padding(.horizontal, 16).padding(.vertical, 6)
                    .background(Capsule().fill(AsPalette.bouton))
            } else {
                Image(systemName: "icloud.and.arrow.down")
                    .font(.system(size: 22))
                    .foregroundStyle(AsPalette.bleu)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { magasin.obtenir(nom) }
    }
}

// Ligne d'app d'une liste éditoriale (e007, e115) : icône 62, titre 17, accroche 14, bouton à droite.
struct AsLigneApp: View {
    @ObservedObject private var magasin = MagasinAppStore.partage
    let app: AsApp
    var sousTitre: String? = nil
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    var body: some View {
        HStack(spacing: 12) {
            AsIcone(nom: app.nom)
            VStack(alignment: .leading, spacing: 1) {
                Text(app.nom)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                Text(sousTitre ?? app.accroche)
                    .font(.system(size: 14))
                    .foregroundStyle(AsPalette.gris)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(spacing: 3) {
                AsBoutonAction(app: app, ouvrirApp: ouvrirApp)
                if app.achatsIntegres && !MagasinAppStore.partage.estInstallee(app.nom) {
                    Text("Achats intégrés")
                        .font(.system(size: 10))
                        .foregroundStyle(AsPalette.gris)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { ouvrirFiche(app) }
    }
}

struct AsSeparateur: View {
    var retrait: CGFloat = 0
    var body: some View {
        Rectangle()
            .fill(AsPalette.separateur)
            .frame(height: 0.5)
            .padding(.leading, retrait)
    }
}

// Carte éditoriale d'Aujourd'hui (e001-e004) : visuel plein cadre, chapeau, titre, résumé, pied d'app.
struct AsCarteEditoriale: View {
    let chapeau: String
    let titre: String
    let resume: String
    let teintes: [UInt]
    let sombre: Bool
    let app: AsApp?
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    var body: some View {
        let texte: Color = sombre ? .white : .black
        let secondaire: Color = sombre ? AsPalette.grisClair : Color(hex: 0x5B5B60)
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Spacer(minLength: 150)
                Text(chapeau.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(secondaire)
                Text(titre)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(texte)
                    .fixedSize(horizontal: false, vertical: true)
                Text(resume)
                    .font(.system(size: 15))
                    .foregroundStyle(secondaire)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                LinearGradient(colors: teintes.map { Color(hex: $0) },
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            if let a = app {
                HStack(spacing: 12) {
                    AsIcone(nom: a.nom, taille: 46, rayon: 11)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(a.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.white).lineLimit(1)
                        Text(a.accroche).font(.system(size: 13)).foregroundStyle(AsPalette.gris).lineLimit(1)
                    }
                    Spacer(minLength: 6)
                    AsBoutonAction(app: a, ouvrirApp: ouvrirApp)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(AsPalette.carte)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { if let a = app { ouvrirFiche(a) } }
    }
}

// Barre d'onglets flottante iOS 26 (e001 / e128 : capsule unique, 5 onglets, pilule sur l'onglet actif).
struct AsBarreOnglets: View {
    @Binding var onglet: Int
    private let items: [(String, String, String)] = [
        ("Aujourd'hui", "doc.text.image", "doc.text.image"),
        ("Jeux", "rocket.fill", "gamecontroller.fill"),
        ("Apps", "square.stack.3d.up.fill", "square.stack.3d.up.fill"),
        ("Arcade", "arcade.stick.console.fill", "gamecontroller"),
        ("Recherche", "magnifyingglass", "magnifyingglass"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                let actif: Bool = index == onglet
                let teinte: Color = actif ? AsPalette.bleu : Color.white
                VStack(spacing: 3) {
                    Image(systemName: asSymbole(item.1, repli: item.2))
                        .font(.system(size: 19, weight: .medium))
                    Text(item.0)
                        .font(.system(size: 10.5, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(teinte)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(actif ? Color.white.opacity(0.14) : Color.clear)
                )
                .contentShape(Rectangle())
                .onTapGesture { onglet = index }
            }
        }
        .padding(.horizontal, 4)
        .background(
            Capsule().fill(.ultraThinMaterial)
        )
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.10), lineWidth: 0.5))
        .padding(.horizontal, 10)
    }
}

// Titre large + avatar du compte (e001, e115).
struct AsEnteteOnglet: View {
    let titre: String
    var ouvrirCompte: () -> Void
    var body: some View {
        HStack(alignment: .center) {
            Text(titre)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.white)
            Spacer()
            AsAvatarSarah(taille: 38)
                .contentShape(Circle())
                .onTapGesture { ouvrirCompte() }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 8)
    }
}

// Avatar du compte : Memoji de Joachim remplacé par Sarah (D59) — initiales sur fond gris, comme iOS
// quand la fiche de contact n'a pas de photo.
struct AsAvatarSarah: View {
    var taille: CGFloat = 38
    var body: some View {
        let image: UIImage? = chargerPellicule("avatar-sarah")
        Group {
            if let ui = image {
                Color.clear.overlay(Image(uiImage: ui).resizable().scaledToFill()).clipped()
            } else {
                Color(hex: 0x5A5A5F)
                    .overlay(
                        Text("SL")
                            .font(.system(size: taille * 0.4, weight: .medium))
                            .foregroundStyle(Color.white)
                    )
            }
        }
        .frame(width: taille, height: taille)
        .clipShape(Circle())
    }
}

// ============================================================ RACINE
struct AppStoreVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinAppStore.partage
    @State private var onglet: Int
    @State private var fiche: AsApp? = nil
    @State private var compteOuvert = false
    @State private var recherche = ""
    // État LOCAL à l'écran (D92 : rien ne survit à son écran).
    @State private var nomIndispo: String? = nil

    private let minuteur = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    // Onglet initial : paramètre explicite (registre de capture) puis variable ONGLET, sinon Aujourd'hui.
    init(onglet: Int? = nil) {
        let env = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "")
        _onglet = State(initialValue: onglet ?? env ?? 0)
    }

    var body: some View {
        ZStack {
            AsPalette.fond.ignoresSafeArea()

            VStack(spacing: 0) {
                contenu
                AsBarreOnglets(onglet: $onglet)
                    .padding(.bottom, 2)
                BarreHome(action: { dismiss() }, sombre: false)
            }

            if let f = fiche {
                AsFicheVue(app: f,
                           fermer: { fiche = nil },
                           ouvrirFiche: { a in fiche = a },
                           ouvrirApp: ouvrirApp)
                    .background(AsPalette.fond.ignoresSafeArea())
                    .transition(.move(edge: .trailing))
                    .zIndex(2)
            }

            VStack(spacing: 0) {
                Spacer()
                BarreHome(action: { dismiss() }, sombre: false)
            }
            .zIndex(3)
            .allowsHitTesting(fiche != nil)
            .opacity(opaciteBarreFiche)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $compteOuvert) {
            AsCompteVue(ouvrirFiche: { a in compteOuvert = false; fiche = a },
                        ouvrirApp: { a in compteOuvert = false; ouvrirApp(a) })
        }
        .alert(nomIndispo ?? "App Store", isPresented: Binding<Bool>(
            get: { nomIndispo != nil },
            set: { if !$0 { nomIndispo = nil } })) {
            Button("OK", role: .cancel) { nomIndispo = nil }
        } message: {
            Text(ErreurLambda.reponse("app.attente"))
        }
        .onReceive(minuteur) { _ in magasin.avancer() }
    }

    // Ternaire de style typé (règle du projet).
    private var opaciteBarreFiche: Double {
        let valeur: Double = fiche != nil ? 1 : 0
        return valeur
    }

    @ViewBuilder
    private var contenu: some View {
        switch onglet {
        case 1:
            AsJeuxVue(ouvrirCompte: { compteOuvert = true },
                      ouvrirFiche: { a in fiche = a }, ouvrirApp: ouvrirApp)
        case 2:
            AsAppsVue(ouvrirCompte: { compteOuvert = true },
                      ouvrirFiche: { a in fiche = a }, ouvrirApp: ouvrirApp)
        case 3:
            AsArcadeVue(ouvrirCompte: { compteOuvert = true },
                        ouvrirFiche: { a in fiche = a }, ouvrirApp: ouvrirApp)
        case 4:
            AsRechercheVue(texte: $recherche, ouvrirCompte: { compteOuvert = true },
                           ouvrirFiche: { a in fiche = a }, ouvrirApp: ouvrirApp)
        default:
            AsAujourdhuiVue(ouvrirCompte: { compteOuvert = true },
                            ouvrirFiche: { a in fiche = a }, ouvrirApp: ouvrirApp)
        }
    }

    // D82 : « Ouvrir » ouvre RÉELLEMENT l'app du jeu quand elle existe ; sinon message iOS crédible (B).
    private func ouvrirApp(_ app: AsApp) {
        if let cible = app.appDuJeu {
            PontAppStore.partage.ouvrir(cible)
            dismiss()
        } else {
            nomIndispo = app.nom
        }
    }
}

// ============================================================ ONGLET 1 — AUJOURD'HUI (e001-e004, e225-e226)
struct AsAujourdhuiVue: View {
    var ouvrirCompte: () -> Void
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteOnglet(titre: "Aujourd'hui", ouvrirCompte: ouvrirCompte)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    if let a = AsCatalogue.app("Darkroom : Photo & Vidéo") {
                        AsCarteEditoriale(chapeau: "App du jour",
                                          titre: "Vos photos, comme en studio",
                                          resume: "Trois réglages suffisent pour transformer une photo prise sur le vif.",
                                          teintes: [0xF3EFE7, 0xE7DCC8], sombre: false, app: a,
                                          ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                    }

                    // « NOS FAVORIS / Indispensables pour l'iPhone » (e005-e007)
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("NOS FAVORIS")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AsPalette.gris)
                            Text("Indispensables\npour l'iPhone")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                        VStack(spacing: 0) {
                            ForEach(Array(AsCatalogue.favoris.enumerated()), id: \.offset) { index, nom in
                                if let a = AsCatalogue.app(nom) {
                                    AsLigneApp(app: a, ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                                    if index < AsCatalogue.favoris.count - 1 { AsSeparateur(retrait: 74) }
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous).fill(AsPalette.carte)
                    )

                    if let a = AsCatalogue.app("Snapchat") {
                        AsCarteEditoriale(chapeau: "Mise à jour",
                                          titre: "La carte retrouve vos ami·e·s",
                                          resume: "La position en temps réel fonctionne de nouveau, même en arrière-plan.",
                                          teintes: [0xFFFC00, 0xFFE066], sombre: false, app: a,
                                          ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                    }

                    if let a = AsCatalogue.app("Doctolib") {
                        AsCarteEditoriale(chapeau: "Découvrir",
                                          titre: "Un rendez-vous en trois gestes",
                                          resume: "Kiné, généraliste, dentiste : trouvez un créneau près de chez vous.",
                                          teintes: [0x0E4E77, 0x0596DE], sombre: true, app: a,
                                          ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
        }
    }
}

// ============================================================ ONGLET 2 — JEUX (e045-e052, e076)
struct AsJeuxVue: View {
    var ouvrirCompte: () -> Void
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    private let filtres: [String] = ["Quiz", "Mots", "Action", "Indé", "Course", "Casse-tête"]

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteOnglet(titre: "Jeux", ouvrirCompte: ouvrirCompte)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filtres, id: \.self) { f in
                                Text(f)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 14).padding(.vertical, 7)
                                    .background(Capsule().fill(AsPalette.carte))
                            }
                        }
                        .padding(.horizontal, 14)
                    }

                    if let a = AsCatalogue.app("MONOPOLY GO!") {
                        AsCarteEditoriale(chapeau: "Maintenant disponible",
                                          titre: "Lancez les dés, prenez la rue",
                                          resume: "La saison d'août ouvre trois nouveaux plateaux.",
                                          teintes: [0xE01B22, 0x8E0F14], sombre: true, app: a,
                                          ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                            .padding(.horizontal, 14)
                    }

                    AsSectionListe(titre: "Jeux incontournables", noms: AsCatalogue.jeuxIncontournables,
                                   ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)

                    AsSectionListe(titre: "Nos jeux du moment", noms: ["2048 : Number Puzzle", "Block Blast!"],
                                   ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                }
                .padding(.bottom, 24)
            }
        }
    }
}

// ============================================================ ONGLET 3 — APPS (e077-e079)
struct AsAppsVue: View {
    var ouvrirCompte: () -> Void
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    private let filtres: [String] = ["Réseaux sociaux", "Musique", "Finance", "Voyages", "Utilitaires"]

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteOnglet(titre: "Apps", ouvrirCompte: ouvrirCompte)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filtres, id: \.self) { f in
                                Text(f)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 14).padding(.vertical, 7)
                                    .background(Capsule().fill(AsPalette.carte))
                            }
                        }
                        .padding(.horizontal, 14)
                    }

                    if let a = AsCatalogue.app("ChatGPT") {
                        AsCarteEditoriale(chapeau: "Sélection", titre: "Poser la bonne question",
                                          resume: "Cinq façons d'utiliser un assistant IA au quotidien.",
                                          teintes: [0x1F2A2E, 0x0E1517], sombre: true, app: a,
                                          ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                            .padding(.horizontal, 14)
                    }

                    AsSectionListe(titre: "Les apps indispensables", noms: AsCatalogue.appsIndispensables,
                                   ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)

                    AsSectionListe(titre: "Vos apps mises à jour", noms: ["Instagram", "Snapchat", "PayPal"],
                                   ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                }
                .padding(.bottom, 24)
            }
        }
    }
}

// ============================================================ ONGLET 4 — ARCADE (e101-e113)
struct AsArcadeVue: View {
    var ouvrirCompte: () -> Void
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteOnglet(titre: "Arcade", ouvrirCompte: ouvrirCompte)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Bandeau Arcade : contenu fidèle, SANS bouton d'offre (D82-C — aucun paiement à simuler).
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            Image(systemName: asSymbole("arcade.stick.console.fill", repli: "gamecontroller"))
                                .font(.system(size: 13, weight: .semibold))
                            Text("Arcade").font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color.white.opacity(0.9))
                        Text("Plus de 200 jeux, sans pubs\nni achats intégrés")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.white)
                        Text("Inclus dans l'abonnement Apple Arcade.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LinearGradient(colors: [Color(hex: 0x2E5C8A), Color(hex: 0x14243A)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .padding(.horizontal, 14)

                    AsSectionListe(titre: "Classement des jeux Arcade", noms: AsCatalogue.jeuxArcade,
                                   ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)

                    Text("Les jeux Apple Arcade nécessitent un abonnement actif.")
                        .font(.system(size: 13))
                        .foregroundStyle(AsPalette.gris)
                        .padding(.horizontal, 18)
                }
                .padding(.bottom, 24)
            }
        }
    }
}

// Section « titre > » + carte de lignes (motif e007, e048, e078).
struct AsSectionListe: View {
    let titre: String
    let noms: [String]
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titre)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 18)
            VStack(spacing: 0) {
                ForEach(Array(noms.enumerated()), id: \.offset) { index, nom in
                    if let a = AsCatalogue.app(nom) {
                        AsLigneApp(app: a, ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                        if index < noms.count - 1 { AsSeparateur(retrait: 74) }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AsPalette.carte)
            )
            .padding(.horizontal, 14)
        }
    }
}

// ============================================================ ONGLET 5 — RECHERCHE (e114-e121, e135)
struct AsRechercheVue: View {
    @Binding var texte: String
    var ouvrirCompte: () -> Void
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    // Recherche RÉELLE sur le petit catalogue : nom, éditeur, catégorie, accroche.
    private var resultats: [AsApp] {
        let q = texte.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return [] }
        return AsCatalogue.apps.filter { a in
            a.nom.lowercased().contains(q) || a.editeur.lowercased().contains(q)
                || a.categorie.lowercased().contains(q) || a.accroche.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteOnglet(titre: "Recherche", ouvrirCompte: ouvrirCompte)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AsPalette.gris)
                TextField("", text: $texte,
                          prompt: Text("Jeux, apps, articles et plus encore").foregroundStyle(AsPalette.gris))
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                if texte.isEmpty {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(AsPalette.gris)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AsPalette.gris)
                        .contentShape(Circle())
                        .onTapGesture { texte = "" }
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 9)
            .background(Capsule().fill(AsPalette.carte))
            .padding(.horizontal, 14)

            if texte.trimmingCharacters(in: .whitespaces).isEmpty {
                accueilRecherche
            } else {
                listeResultats
            }
        }
    }

    private var accueilRecherche: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                AsSectionListe(titre: "Suggestions", noms: AsCatalogue.suggestions,
                               ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Parcourir")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 18)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())],
                              spacing: 10) {
                        ForEach(Array(AsCatalogue.parcourir.enumerated()), id: \.offset) { _, tuile in
                            Text(tuile.0)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 74, alignment: .topLeading)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color(hex: tuile.1))
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    let requete: String = tuile.0.contains("Jeux") ? "Jeux" : "Apps"
                                    texte = requete
                                }
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    private var listeResultats: some View {
        ScrollView(showsIndicators: false) {
            if resultats.isEmpty {
                VStack(spacing: 6) {
                    Text("Aucun résultat")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Text("Aucun résultat pour « \(texte) ».")
                        .font(.system(size: 15))
                        .foregroundStyle(AsPalette.gris)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 70)
            } else {
                VStack(spacing: 0) {
                    ForEach(resultats, id: \.id) { a in
                        AsLigneApp(app: a, ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
                        AsSeparateur(retrait: 74)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
        }
    }
}

// ============================================================ FICHE D'APP (e018-e040, e053-e060, e091-e093, e122-e128, e196)
struct AsFicheVue: View {
    @ObservedObject private var magasin = MagasinAppStore.partage
    let app: AsApp
    var fermer: () -> Void
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    @State private var deplie = false

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    identite
                    statistiques
                    captures
                    nouveautes
                    description
                    notesEtAvis
                    informations
                    autresApps
                }
                .padding(.bottom, 60)
            }
        }
    }

    private var entete: some View {
        HStack {
            Image(systemName: "chevron.backward")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 34, height: 34)
                .background(Circle().fill(AsPalette.carte))
                .contentShape(Circle())
                .onTapGesture { fermer() }
            Spacer()
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.white)
                .frame(width: 34, height: 34)
                .background(Circle().fill(AsPalette.carte))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var identite: some View {
        HStack(alignment: .top, spacing: 14) {
            AsIcone(nom: app.nom, taille: 112, rayon: 25)
            VStack(alignment: .leading, spacing: 3) {
                Text(app.nom)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(app.editeur)
                    .font(.system(size: 15))
                    .foregroundStyle(AsPalette.gris)
                Spacer(minLength: 6)
                HStack(spacing: 10) {
                    AsBoutonAction(app: app, grand: true, ouvrirApp: ouvrirApp)
                    if app.achatsIntegres && !magasin.estInstallee(app.nom) {
                        Text("Achats\nintégrés")
                            .font(.system(size: 11))
                            .foregroundStyle(AsPalette.gris)
                    }
                }
            }
            .frame(height: 112, alignment: .topLeading)
        }
        .padding(.horizontal, 16)
    }

    private var statistiques: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                colonne(titre: app.nbNotes.uppercased(),
                        valeur: String(format: "%.1f", app.note).replacingOccurrences(of: ".", with: ","),
                        pied: "etoiles")
                diviseur
                colonne(titre: "CATÉGORIE D'ÂGE", valeur: app.age, pied: "Âge")
                if let c = app.classement {
                    diviseur
                    colonne(titre: "CLASSEMENT", valeur: c, pied: app.categorie)
                }
                diviseur
                colonne(titre: "CRÉATEUR", valeur: "", pied: app.editeur)
            }
            .padding(.horizontal, 16)
        }
    }

    private var diviseur: some View {
        Rectangle().fill(AsPalette.separateur).frame(width: 0.5, height: 54)
    }

    @ViewBuilder
    private func colonne(titre: String, valeur: String, pied: String) -> some View {
        VStack(spacing: 4) {
            Text(titre)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AsPalette.gris)
                .lineLimit(1)
            if valeur.isEmpty {
                Image(systemName: "person.crop.square")
                    .font(.system(size: 20))
                    .foregroundStyle(AsPalette.grisClair)
            } else {
                Text(valeur)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AsPalette.grisClair)
            }
            if pied == "etoiles" {
                HStack(spacing: 1) {
                    ForEach(0..<5, id: \.self) { i in
                        let plein: String = Double(i) < app.note ? "star.fill" : "star"
                        Image(systemName: plein)
                            .font(.system(size: 9))
                            .foregroundStyle(AsPalette.gris)
                    }
                }
            } else {
                Text(pied)
                    .font(.system(size: 12))
                    .foregroundStyle(AsPalette.gris)
                    .lineLimit(1)
            }
        }
        .frame(width: 118)
    }

    private var captures: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(colors: [app.couleur.opacity(0.95 - Double(i) * 0.18),
                                                      app.couleur.opacity(0.35)],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 196, height: 348)
                        .overlay(
                            Text(app.nom)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.85))
                                .padding(12),
                            alignment: .bottomLeading
                        )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var nouveautes: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Nouveautés")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
            HStack {
                Text("Version \(app.version)")
                    .font(.system(size: 14))
                    .foregroundStyle(AsPalette.gris)
                Spacer()
                Text("Il y a 4 j")
                    .font(.system(size: 14))
                    .foregroundStyle(AsPalette.gris)
            }
            Text(app.nouveautes)
                .font(.system(size: 15))
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
    }

    private var description: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(app.resume)
                .font(.system(size: 15))
                .foregroundStyle(Color.white)
                .lineLimit(deplie ? nil : 4)
                .fixedSize(horizontal: false, vertical: true)
            Text(deplie ? "moins" : "plus")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AsPalette.bleu)
                .contentShape(Rectangle())
                .onTapGesture { deplie.toggle() }
            Text(app.editeur)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AsPalette.bleu)
                .padding(.top, 4)
        }
        .padding(.horizontal, 16)
    }

    private var notesEtAvis: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notes et avis")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
            HStack(alignment: .bottom, spacing: 12) {
                Text(String(format: "%.1f", app.note).replacingOccurrences(of: ".", with: ","))
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(Color.white)
                Text("sur 5")
                    .font(.system(size: 15))
                    .foregroundStyle(AsPalette.gris)
                    .padding(.bottom, 10)
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { i in
                            let plein: String = Double(i) < app.note ? "star.fill" : "star"
                            Image(systemName: plein)
                                .font(.system(size: 13))
                                .foregroundStyle(AsPalette.grisClair)
                        }
                    }
                    Text(app.nbNotes)
                        .font(.system(size: 13))
                        .foregroundStyle(AsPalette.gris)
                }
                .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 16)
    }

    private var informations: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Informations")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
            VStack(spacing: 0) {
                ForEach(Array(infos.enumerated()), id: \.offset) { index, info in
                    ligneInfo(info.0, info.1)
                    if index < infos.count - 1 { AsSeparateur() }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(AsPalette.carte)
            )
        }
        .padding(.horizontal, 16)
    }

    private var infos: [(String, String)] {
        let integres: String = app.achatsIntegres ? "Oui" : "Non"
        return [("Fournisseur", app.editeur),
                ("Taille", app.taille),
                ("Catégorie", app.categorie),
                ("Compatibilité", "iPhone"),
                ("Langues", "Français et 8 autres"),
                ("Âge", app.age),
                ("Achats intégrés", integres)]
    }

    @ViewBuilder
    private func ligneInfo(_ cle: String, _ valeur: String) -> some View {
        HStack(alignment: .top) {
            Text(cle).font(.system(size: 15)).foregroundStyle(Color.white)
            Spacer(minLength: 12)
            Text(valeur)
                .font(.system(size: 15))
                .foregroundStyle(AsPalette.gris)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
    }

    private var autresApps: some View {
        let voisines = AsCatalogue.apps.filter { $0.categorie == app.categorie && $0.id != app.id }
        return Group {
            if !voisines.isEmpty {
                AsSectionListe(titre: "Vous aimerez peut-être aussi",
                               noms: Array(voisines.prefix(3)).map { $0.id },
                               ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
            }
        }
    }
}

// ============================================================ COMPTE APPLE (feuille — e139, e197, e201, e212, e224)
enum AsRouteCompte: Hashable {
    case reglages
    case achats
    case commande(String)
    case abonnements
    case abonnement(String)
    case maj
    case vosApps
    case notifications
    case avis
    case reco
}

struct AsCompteVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinAppStore.partage
    @State private var chemin: [AsRouteCompte] = []
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void

    var body: some View {
        NavigationStack(path: $chemin) {
            racine
                .navigationDestination(for: AsRouteCompte.self) { route in
                    destination(route)
                }
        }
        .preferredColorScheme(.dark)
    }

    // ---- Racine : Compte Apple (e139)
    private var racine: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Compte Apple", avecRetour: false, pomme: true,
                            retour: {}, fermer: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    // Identité (D59 : Sarah remplace Joachim)
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            AsAvatarSarah(taille: 56)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sarah Levasseur")
                                    .font(.system(size: 19, weight: .semibold))
                                    .foregroundStyle(Color.white)
                                Text("Informations du compte, paiements et réglages")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AsPalette.gris)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 6)
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AsPalette.gris)
                        }
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .onTapGesture { chemin.append(.reglages) }
                        AsSeparateur(retrait: 68)
                        HStack(spacing: 12) {
                            Circle().fill(Color(hex: 0x1F4E79)).frame(width: 34, height: 34)
                                .overlay(
                                    Image(systemName: asSymbole("arcade.stick.console.fill", repli: "gamecontroller"))
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.white)
                                )
                            Text("Game Center").font(.system(size: 17)).foregroundStyle(Color.white)
                            Spacer()
                            Text("sarahlvs").font(.system(size: 15)).foregroundStyle(AsPalette.gris)
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AsPalette.gris)
                        }
                        .padding(.vertical, 12)
                    }
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AsPalette.carteFeuille)
                    )

                    // Menu principal (piloté par une table : évite tout dépassement du constructeur de vues)
                    VStack(spacing: 0) {
                        ForEach(Array(menu.enumerated()), id: \.offset) { index, entree in
                            let accessoire: String? = entree.0 == "Mises à jour d'apps"
                                ? majEnAttenteTexte : nil
                            ligne(entree.0, accessoire: accessoire) { chemin.append(entree.1) }
                            if index < menu.count - 1 { AsSeparateur() }
                        }
                    }
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AsPalette.carteFeuille)
                    )

                    Text("Compte Apple : sarah.levasseur@icloud.com")
                        .font(.system(size: 13))
                        .foregroundStyle(AsPalette.gris)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var menu: [(String, AsRouteCompte)] {
        [("Mises à jour d'apps", .maj),
         ("Abonnements", .abonnements),
         ("Apps et historique des achats", .vosApps),
         ("Notifications", .notifications),
         ("Notes et avis", .avis),
         ("Recommandations personnalisées", .reco)]
    }

    private var majEnAttenteTexte: String? {
        let texte: String? = magasin.majEnAttente.isEmpty ? nil : "\(magasin.majEnAttente.count)"
        return texte
    }

    @ViewBuilder
    private func ligne(_ titre: String, accessoire: String? = nil, action: @escaping () -> Void) -> some View {
        HStack {
            Text(titre).font(.system(size: 17)).foregroundStyle(Color.white)
            Spacer()
            if let a = accessoire {
                Text(a).font(.system(size: 16)).foregroundStyle(AsPalette.gris)
            }
            Image(systemName: "chevron.forward")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AsPalette.gris)
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }

    @ViewBuilder
    private func destination(_ route: AsRouteCompte) -> some View {
        switch route {
        case .reglages:
            AsReglagesCompteVue(aller: { chemin.append($0) }, retour: { retirer() }, fermer: { dismiss() })
        case .achats:
            AsAchatsVue(aller: { chemin.append($0) }, retour: { retirer() }, fermer: { dismiss() })
        case .commande(let id):
            AsCommandeVue(achatId: id, retour: { retirer() }, fermer: { dismiss() })
        case .abonnements:
            AsAbonnementsVue(aller: { chemin.append($0) }, retour: { retirer() }, fermer: { dismiss() })
        case .abonnement(let id):
            AsAbonnementVue(abonnementId: id, retour: { retirer() }, fermer: { dismiss() })
        case .maj:
            AsMajVue(retour: { retirer() }, fermer: { dismiss() })
        case .vosApps:
            AsVosAppsVue(aller: { chemin.append($0) }, retour: { retirer() }, fermer: { dismiss() },
                         ouvrirFiche: ouvrirFiche, ouvrirApp: ouvrirApp)
        case .notifications:
            AsNotifsVue(retour: { retirer() }, fermer: { dismiss() })
        case .avis:
            AsAvisVue(retour: { retirer() }, fermer: { dismiss() }, ouvrirFiche: ouvrirFiche)
        case .reco:
            AsRecoVue(retour: { retirer() }, fermer: { dismiss() })
        }
    }

    private func retirer() {
        if !chemin.isEmpty { chemin.removeLast() }
    }
}

// En-tête des écrans de compte (e141, e150, e192, e200) : rond de retour, titre centré, rond de fermeture.
struct AsEnteteFeuille: View {
    let titre: String
    var avecRetour: Bool = true
    var pomme: Bool = false
    var retour: () -> Void
    var fermer: () -> Void

    var body: some View {
        ZStack {
            if pomme {
                HStack(spacing: 8) {
                    Image(systemName: "applelogo").font(.system(size: 17)).foregroundStyle(Color.white)
                    Text(titre).font(.system(size: 20, weight: .bold)).foregroundStyle(Color.white)
                    Spacer()
                }
            } else {
                Text(titre)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
            HStack {
                if avecRetour {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(AsPalette.carteFeuille))
                        .contentShape(Circle())
                        .onTapGesture { retour() }
                }
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(AsPalette.carteFeuille))
                    .contentShape(Circle())
                    .onTapGesture { fermer() }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// Carte groupée d'un écran de réglages.
struct AsGroupe<Contenu: View>: View {
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        VStack(spacing: 0) { contenu() }
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AsPalette.carteFeuille)
            )
    }
}

struct AsLigneReglage: View {
    let titre: String
    var valeur: String? = nil
    var chevron: Bool = true
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top) {
            Text(titre)
                .font(.system(size: 17))
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 12)
            if let v = valeur {
                Text(v)
                    .font(.system(size: 16))
                    .foregroundStyle(AsPalette.gris)
                    .multilineTextAlignment(.trailing)
            }
            if chevron {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AsPalette.gris)
                    .padding(.top, 3)
            }
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
        .onTapGesture { action?() }
    }
}

// ---------- Réglages du compte (e141-e143, e181, e185-e190)
struct AsReglagesCompteVue: View {
    var aller: (AsRouteCompte) -> Void
    var retour: () -> Void
    var fermer: () -> Void
    // États LOCAUX à l'écran (D92) : ils ne survivent pas à la sortie.
    @State private var localiser = true
    @State private var lettres = false
    @State private var reco = true

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Réglages du compte", retour: retour, fermer: fermer)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    AsGroupe {
                        AsLigneReglage(titre: "Compte Apple", valeur: "sarah.levasseur@icloud.com")
                        AsSeparateur()
                        AsLigneReglage(titre: "Modes de paiement", valeur: "Visa")
                        AsSeparateur()
                        AsLigneReglage(titre: "Adresse de facturation", valeur: "14 rue de Marseille\n69007 Lyon")
                        AsSeparateur()
                        AsLigneReglage(titre: "Pays/Région", valeur: "France")
                    }

                    AsGroupe {
                        AsLigneReglage(titre: "Historique des achats") { aller(.achats) }
                        AsSeparateur()
                        AsLigneReglage(titre: "Abonnements") { aller(.abonnements) }
                        AsSeparateur()
                        AsLigneReglage(titre: "Notes et avis") { aller(.avis) }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ACCÈS AU COMPTE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AsPalette.gris)
                            .padding(.leading, 16)
                        AsGroupe {
                            interrupteur("Autorisez vos amis à vous trouver", valeur: $localiser)
                        }
                        Text("Les personnes qui connaissent votre numéro de téléphone ou votre adresse e-mail pourront vous trouver sur Game Center.")
                            .font(.system(size: 13))
                            .foregroundStyle(AsPalette.gris)
                            .padding(.horizontal, 16)
                    }

                    AsGroupe {
                        interrupteur("Newsletters et offres spéciales", valeur: $lettres)
                        AsSeparateur()
                        interrupteur("Recomm. personnalisées", valeur: $reco)
                    }

                    AsGroupe {
                        AsLigneReglage(titre: "Conditions générales")
                        AsSeparateur()
                        AsLigneReglage(titre: "Confidentialité")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 30)
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func interrupteur(_ titre: String, valeur: Binding<Bool>) -> some View {
        HStack {
            Text(titre)
                .font(.system(size: 17))
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 10)
            Toggle("", isOn: valeur).labelsHidden().tint(Color(hex: 0x30D158))
        }
        .padding(.vertical, 10)
    }
}

// ---------- Historique d'achats (e147-e151, e164)
struct AsAchatsVue: View {
    var aller: (AsRouteCompte) -> Void
    var retour: () -> Void
    var fermer: () -> Void
    @State private var filtre = ""

    private var groupes: [(String, [AsAchat])] {
        let q = filtre.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return AsCatalogue.achats }
        var sortie: [(String, [AsAchat])] = []
        for groupe in AsCatalogue.achats {
            let lignes = groupe.1.filter {
                $0.titre.lowercased().contains(q) || $0.prix.lowercased().contains(q)
                    || $0.numeroCommande.lowercased().contains(q)
            }
            if !lignes.isEmpty { sortie.append((groupe.0, lignes)) }
        }
        return sortie
    }

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Historique d'achats", retour: retour, fermer: fermer)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Affichage : Ces 90 derniers jours, Payant")
                        .font(.system(size: 13))
                        .foregroundStyle(AsPalette.gris)
                        .frame(maxWidth: .infinity)

                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15)).foregroundStyle(AsPalette.gris)
                        TextField("", text: $filtre,
                                  prompt: Text("Nom, prix ou n° de commande").foregroundStyle(AsPalette.gris))
                            .font(.system(size: 16)).foregroundStyle(Color.white)
                            .autocorrectionDisabled(true)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 9)
                    .background(Capsule().fill(AsPalette.carteFeuille))

                    if groupes.isEmpty {
                        VStack(spacing: 6) {
                            Text("Aucun résultat")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundStyle(Color.white)
                            Text("Modifiez votre recherche ou vos achats.")
                                .font(.system(size: 14))
                                .foregroundStyle(AsPalette.gris)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    } else {
                        ForEach(groupes, id: \.0) { groupe in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(groupe.0)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(AsPalette.gris)
                                    .padding(.leading, 4)
                                AsGroupe {
                                    ForEach(groupe.1, id: \.id) { achat in
                                        ligneAchat(achat)
                                        AsSeparateur()
                                    }
                                    total(groupe.1)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func ligneAchat(_ achat: AsAchat) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AsIcone(nom: achat.app, taille: 44, rayon: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(achat.titre)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(achat.type)
                    .font(.system(size: 14))
                    .foregroundStyle(AsPalette.gris)
            }
            Spacer(minLength: 8)
            Text(achat.prix)
                .font(.system(size: 16))
                .foregroundStyle(AsPalette.gris)
        }
        .padding(.vertical, 11)
    }

    @ViewBuilder
    private func total(_ lignes: [AsAchat]) -> some View {
        let somme = lignes.reduce(0.0) { partiel, ligne in
            partiel + (Double(ligne.prix.replacingOccurrences(of: " €", with: "")
                .replacingOccurrences(of: ",", with: ".")) ?? 0)
        }
        HStack {
            Text("Total").font(.system(size: 16)).foregroundStyle(Color.white)
            Spacer()
            Text(String(format: "%.2f €", somme).replacingOccurrences(of: ".", with: ","))
                .font(.system(size: 16))
                .foregroundStyle(AsPalette.gris)
            Image(systemName: "chevron.forward")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AsPalette.gris)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { if let premier = lignes.first { aller(.commande(premier.id)) } }
    }
}

// ---------- Détails de la commande (e153-e155)
struct AsCommandeVue: View {
    let achatId: String
    var retour: () -> Void
    var fermer: () -> Void

    private var achat: AsAchat? {
        AsCatalogue.achats.flatMap { $0.1 }.first { $0.id == achatId }
    }

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Détails de la commande", retour: retour, fermer: fermer)
            ScrollView(showsIndicators: false) {
                if let a = achat {
                    VStack(alignment: .leading, spacing: 18) {
                        AsGroupe {
                            HStack(alignment: .top, spacing: 12) {
                                AsIcone(nom: a.app, taille: 44, rayon: 10)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(a.titre).font(.system(size: 16)).foregroundStyle(Color.white)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(a.type).font(.system(size: 14)).foregroundStyle(AsPalette.gris)
                                    Text("iPhone de Sarah").font(.system(size: 14)).foregroundStyle(AsPalette.gris)
                                    Text(a.dateCommande).font(.system(size: 14)).foregroundStyle(AsPalette.gris)
                                }
                                Spacer(minLength: 8)
                                Text(a.prix).font(.system(size: 16)).foregroundStyle(AsPalette.gris)
                            }
                            .padding(.vertical, 12)
                            AsSeparateur()
                            AsLigneReglage(titre: "TVA facturée à 20 %", valeur: tva(a.prix), chevron: false)
                            AsSeparateur()
                            AsLigneReglage(titre: "Total", valeur: a.prix, chevron: false)
                            AsSeparateur()
                            AsLigneReglage(titre: "Visa •••• 4417", valeur: a.prix, chevron: false)
                        }

                        AsGroupe {
                            AsLigneReglage(titre: "Date de la commande", valeur: a.dateCommande, chevron: false)
                            AsSeparateur()
                            AsLigneReglage(titre: "N° de commande", valeur: a.numeroCommande, chevron: false)
                            AsSeparateur()
                            AsLigneReglage(titre: "Compte Apple", valeur: "sarah.levasseur@icloud.com", chevron: false)
                            AsSeparateur()
                            AsLigneReglage(titre: "Adresse de facturation",
                                           valeur: "14 rue de Marseille\n69007 Lyon\nFrance", chevron: false)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func tva(_ prix: String) -> String {
        let valeur = Double(prix.replacingOccurrences(of: " €", with: "")
            .replacingOccurrences(of: ",", with: ".")) ?? 0
        return String(format: "%.2f €", valeur / 6).replacingOccurrences(of: ".", with: ",")
    }
}

// ---------- Abonnements (e159, e169-e177, e200)
struct AsAbonnementsVue: View {
    var aller: (AsRouteCompte) -> Void
    var retour: () -> Void
    var fermer: () -> Void

    var body: some View {
        let actifs = AsCatalogue.abonnements.filter { $0.actif }
        let expires = AsCatalogue.abonnements.filter { !$0.actif }
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Abonnements", retour: retour, fermer: fermer)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    section("Actif", abonnements: actifs)
                    section("Expiré", abonnements: expires)
                    Text("À propos des abonnements et de la confidentialité")
                        .font(.system(size: 13))
                        .foregroundStyle(AsPalette.bleu)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func section(_ titre: String, abonnements: [AsAbonnement]) -> some View {
        if !abonnements.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(titre)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AsPalette.gris)
                    .padding(.leading, 4)
                AsGroupe {
                    ForEach(Array(abonnements.enumerated()), id: \.element.id) { index, ab in
                        ligne(ab)
                        if index < abonnements.count - 1 { AsSeparateur(retrait: 56) }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func ligne(_ ab: AsAbonnement) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AsIcone(nom: ab.app, taille: 44, rayon: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(ab.app).font(.system(size: 16)).foregroundStyle(Color.white)
                Text(ab.offre).font(.system(size: 14)).foregroundStyle(AsPalette.gris)
                if let alerte = ab.alerte {
                    Text(alerte).font(.system(size: 14)).foregroundStyle(AsPalette.rouge)
                } else {
                    Text(ab.echeance).font(.system(size: 14)).foregroundStyle(AsPalette.gris)
                }
            }
            Spacer(minLength: 8)
            Text(ab.prix).font(.system(size: 16)).foregroundStyle(AsPalette.gris)
            Image(systemName: "chevron.forward")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AsPalette.gris)
                .padding(.top, 3)
        }
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture { aller(.abonnement(ab.id)) }
    }
}

// ---------- Détail d'un abonnement (e171-e176)
struct AsAbonnementVue: View {
    let abonnementId: String
    var retour: () -> Void
    var fermer: () -> Void
    @State private var resilie = false

    private var abonnement: AsAbonnement? {
        AsCatalogue.abonnements.first { $0.id == abonnementId }
    }

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Abonnements", retour: retour, fermer: fermer)
            ScrollView(showsIndicators: false) {
                if let ab = abonnement {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(spacing: 8) {
                            AsIcone(nom: ab.app, taille: 74, rayon: 17)
                            Text(ab.app).font(.system(size: 22, weight: .semibold)).foregroundStyle(Color.white)
                            Text(ab.offre).font(.system(size: 15)).foregroundStyle(AsPalette.gris)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        AsGroupe {
                            AsLigneReglage(titre: ab.offre, valeur: "\(ab.prix) par mois", chevron: false)
                            AsSeparateur()
                            AsLigneReglage(titre: resilie ? "Prend fin le 14 septembre" : ab.echeance,
                                           chevron: false)
                        }

                        if ab.actif {
                            VStack(spacing: 0) {
                                Text(resilie ? "Abonnement résilié" : "Résilier l'abonnement")
                                    .font(.system(size: 17))
                                    .foregroundStyle(resilie ? AsPalette.gris : AsPalette.rouge)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .contentShape(Rectangle())
                                    .onTapGesture { resilie = true }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AsPalette.carteFeuille)
                            )
                            Text(resilie
                                 ? "Vous conservez l'accès jusqu'au 14 septembre. Aucun nouveau prélèvement ne sera effectué."
                                 : "Si vous résiliez maintenant, vous continuez à bénéficier de l'abonnement jusqu'à sa prochaine échéance.")
                                .font(.system(size: 13))
                                .foregroundStyle(AsPalette.gris)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ---------- Mises à jour d'apps (e191-e195) — D82-A : la ligne disparaît réellement
struct AsMajVue: View {
    @ObservedObject private var magasin = MagasinAppStore.partage
    var retour: () -> Void
    var fermer: () -> Void
    @State private var depliees: Set<String> = []

    private var enAttente: [AsMaj] {
        AsCatalogue.majs.filter { magasin.majEnAttente.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Mises à jour d'apps", retour: retour, fermer: fermer)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    if enAttente.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 42))
                                .foregroundStyle(AsPalette.gris)
                            Text("Tout est à jour")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.white)
                            Text("Toutes les apps de cet iPhone utilisent leur dernière version.")
                                .font(.system(size: 14))
                                .foregroundStyle(AsPalette.gris)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 70)
                    } else {
                        AsGroupe {
                            HStack {
                                Text("Tout mettre à jour")
                                    .font(.system(size: 17))
                                    .foregroundStyle(AsPalette.bleu)
                                Spacer()
                                Text("\(enAttente.count)")
                                    .font(.system(size: 16))
                                    .foregroundStyle(AsPalette.gris)
                            }
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                            .onTapGesture { magasin.toutMettreAJour() }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mises à jour automatiques à venir")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AsPalette.gris)
                                .padding(.leading, 4)
                            AsGroupe {
                                ForEach(Array(enAttente.enumerated()), id: \.element.id) { index, maj in
                                    ligne(maj)
                                    if index < enAttente.count - 1 { AsSeparateur() }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func ligne(_ maj: AsMaj) -> some View {
        let deplie = depliees.contains(maj.id)
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 12) {
                AsIcone(nom: maj.id, taille: 52, rayon: 12)
                VStack(alignment: .leading, spacing: 2) {
                    Text(maj.id)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(maj.quand).font(.system(size: 14)).foregroundStyle(AsPalette.gris)
                }
                Spacer(minLength: 8)
                Text("Mettre à jour")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AsPalette.bleu)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(Capsule().fill(AsPalette.bouton))
                    .contentShape(Capsule())
                    .onTapGesture { magasin.mettreAJour(maj.id) }
            }
            HStack(alignment: .top, spacing: 6) {
                Text("•").font(.system(size: 14)).foregroundStyle(Color.white)
                Text(maj.notes)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white)
                    .lineLimit(deplie ? nil : 1)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 6)
                Text(deplie ? "moins" : "plus")
                    .font(.system(size: 14))
                    .foregroundStyle(AsPalette.bleu)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if deplie { depliees.remove(maj.id) } else { depliees.insert(maj.id) }
                    }
            }
        }
        .padding(.vertical, 11)
    }
}

// ---------- Apps et historique des achats → Apps (e202-e211)
struct AsVosAppsVue: View {
    @ObservedObject private var magasin = MagasinAppStore.partage
    var aller: (AsRouteCompte) -> Void
    var retour: () -> Void
    var fermer: () -> Void
    var ouvrirFiche: (AsApp) -> Void
    var ouvrirApp: (AsApp) -> Void
    @State private var segment = 0
    @State private var nomIndispo: String? = nil

    private var lignes: [(String, String)] {
        segment == 0 ? AsCatalogue.vosApps : AsCatalogue.appsAbsentes
    }

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Apps", retour: retour, fermer: fermer)

            HStack(spacing: 0) {
                onglet("Tout", index: 0)
                onglet("Pas sur cet iPhone", index: 1)
            }
            .padding(3)
            .background(Capsule().fill(AsPalette.carteFeuille))
            .padding(.horizontal, 16)
            .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(lignes.enumerated()), id: \.offset) { index, ligne in
                        contenuLigne(nom: ligne.0, date: ligne.1)
                        if index < lignes.count - 1 { AsSeparateur(retrait: 66) }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 30)
            }

            AsGroupe {
                AsLigneReglage(titre: "Historique des achats") { aller(.achats) }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .alert(nomIndispo ?? "App Store", isPresented: Binding<Bool>(
            get: { nomIndispo != nil }, set: { if !$0 { nomIndispo = nil } })) {
            Button("OK", role: .cancel) { nomIndispo = nil }
        } message: {
            Text(ErreurLambda.reponse("app.attente"))
        }
    }

    @ViewBuilder
    private func onglet(_ titre: String, index: Int) -> some View {
        let actif: Bool = segment == index
        Text(titre)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.white)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Capsule().fill(actif ? Color.white.opacity(0.16) : Color.clear))
            .contentShape(Rectangle())
            .onTapGesture { segment = index }
    }

    @ViewBuilder
    private func contenuLigne(nom: String, date: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            AsIcone(nom: nom, taille: 54, rayon: 12)
            VStack(alignment: .leading, spacing: 2) {
                Text(nom)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(date).font(.system(size: 14)).foregroundStyle(AsPalette.gris)
            }
            Spacer(minLength: 8)
            if segment == 1 {
                AsNuage(nom: nom)
            } else if magasin.majDisponible(nom) {
                Text("Mettre à jour")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AsPalette.bleu)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(Capsule().fill(AsPalette.bouton))
                    .contentShape(Capsule())
                    .onTapGesture { magasin.mettreAJour(nom) }
            } else {
                Text("Ouvrir")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AsPalette.bleu)
                    .padding(.horizontal, 16).padding(.vertical, 6)
                    .background(Capsule().fill(AsPalette.bouton))
                    .contentShape(Capsule())
                    .onTapGesture { ouvrir(nom) }
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { if let a = AsCatalogue.app(nom) { ouvrirFiche(a) } }
    }

    private func ouvrir(_ nom: String) {
        if let a = AsCatalogue.app(nom) {
            ouvrirApp(a)
            return
        }
        if let cible = AsCatalogue.appDuJeuSysteme[nom] {
            PontAppStore.partage.ouvrir(cible)
            return
        }
        nomIndispo = nom
    }
}

// ---------- Notifications (e213)
struct AsNotifsVue: View {
    var retour: () -> Void
    var fermer: () -> Void
    @State private var nouveautes = true
    @State private var offres = false

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Notifications", retour: retour, fermer: fermer)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    AsGroupe {
                        interrupteur("Nouvelles fonctionnalités et mises à jour", valeur: $nouveautes)
                        AsSeparateur()
                        interrupteur("Recommandations et offres", valeur: $offres)
                    }
                    Text("Vous recevrez ces notifications sur les appareils connectés à votre compte Apple.")
                        .font(.system(size: 13))
                        .foregroundStyle(AsPalette.gris)
                        .padding(.horizontal, 16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func interrupteur(_ titre: String, valeur: Binding<Bool>) -> some View {
        HStack {
            Text(titre)
                .font(.system(size: 17))
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 10)
            Toggle("", isOn: valeur).labelsHidden().tint(Color(hex: 0x30D158))
        }
        .padding(.vertical, 10)
    }
}

// ---------- Notes et avis (e183-e184, e215-e217)
struct AsAvisVue: View {
    var retour: () -> Void
    var fermer: () -> Void
    var ouvrirFiche: (AsApp) -> Void

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Notes et avis", retour: retour, fermer: fermer)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(AsCatalogue.avis, id: \.id) { avis in
                        AsGroupe {
                            HStack(alignment: .top, spacing: 12) {
                                AsIcone(nom: avis.app, taille: 46, rayon: 11)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(avis.app)
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.white)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(avis.quand).font(.system(size: 13)).foregroundStyle(AsPalette.gris)
                                    HStack(spacing: 2) {
                                        ForEach(0..<5, id: \.self) { i in
                                            let plein: String = i < avis.etoiles ? "star.fill" : "star"
                                            Image(systemName: plein)
                                                .font(.system(size: 11))
                                                .foregroundStyle(AsPalette.grisClair)
                                        }
                                    }
                                }
                                Spacer(minLength: 6)
                                Image(systemName: "chevron.forward")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AsPalette.gris)
                            }
                            .padding(.vertical, 12)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { if let a = AsCatalogue.app(avis.app) { ouvrirFiche(a) } }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ---------- Recommandations personnalisées (e219-e220)
struct AsRecoVue: View {
    var retour: () -> Void
    var fermer: () -> Void
    @State private var efface = false

    var body: some View {
        VStack(spacing: 0) {
            AsEnteteFeuille(titre: "Recommandations", retour: retour, fermer: fermer)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Apple s'engage à personnaliser votre expérience tout en garantissant la sécurité de vos données personnelles.")
                        .font(.system(size: 14))
                        .foregroundStyle(AsPalette.gris)
                        .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("VOTRE UTILISATION DES APPS")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AsPalette.gris)
                            .padding(.leading, 16)
                        AsGroupe {
                            Text(efface ? "Données effacées" : "Effacer les données d'utilisation des apps")
                                .font(.system(size: 17))
                                .foregroundStyle(efface ? AsPalette.gris : AsPalette.bleu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 14)
                                .contentShape(Rectangle())
                                .onTapGesture { efface = true }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("VOS INTERACTIONS AVEC L'APP STORE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AsPalette.gris)
                            .padding(.leading, 16)
                        AsGroupe {
                            AsLigneReglage(titre: "Apps et jeux achetés", valeur: "19", chevron: false)
                            AsSeparateur()
                            AsLigneReglage(titre: "Abonnements", valeur: "6", chevron: false)
                            AsSeparateur()
                            AsLigneReglage(titre: "Notes et avis", valeur: "5", chevron: false)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ============================================================ REGISTRE DE CAPTURE (famille « appstore »)
struct AsCapture: View {
    let cle: String
    var body: some View {
        switch cle {
        case "appstore.fiche":
            fiche("Instagram")
        case "appstore.fichejeu":
            fiche("Clash Royale")
        case "appstore.recherche":
            AppStoreVue()
        case "appstore.compte", "appstore.maj", "appstore.achats", "appstore.abonnements",
             "appstore.reglages", "appstore.vosapps", "appstore.commande", "appstore.avis":
            AsCaptureCompte(cle: cle)
        default:
            AppStoreVue()
        }
    }

    // La capture doit montrer la BarreHome comme dans l'app (la fiche est un calque d'AppStoreVue).
    @ViewBuilder
    private func fiche(_ nom: String) -> some View {
        if let a = AsCatalogue.app(nom) {
            VStack(spacing: 0) {
                AsFicheVue(app: a, fermer: {}, ouvrirFiche: { _ in }, ouvrirApp: { _ in })
                BarreHome(action: {}, sombre: false)
            }
            .background(AsPalette.fond.ignoresSafeArea())
            .preferredColorScheme(.dark)
        } else {
            AppStoreVue()
        }
    }
}

// Les écrans de compte capturés hors feuille (la feuille masquerait la coquille sur la capture).
struct AsCaptureCompte: View {
    let cle: String
    var body: some View {
        Group {
            switch cle {
            case "appstore.maj":
                AsMajVue(retour: {}, fermer: {})
            case "appstore.achats":
                AsAchatsVue(aller: { _ in }, retour: {}, fermer: {})
            case "appstore.abonnements":
                AsAbonnementsVue(aller: { _ in }, retour: {}, fermer: {})
            case "appstore.reglages":
                AsReglagesCompteVue(aller: { _ in }, retour: {}, fermer: {})
            case "appstore.vosapps":
                AsVosAppsVue(aller: { _ in }, retour: {}, fermer: {},
                             ouvrirFiche: { _ in }, ouvrirApp: { _ in })
            case "appstore.commande":
                AsCommandeVue(achatId: "a1", retour: {}, fermer: {})
            case "appstore.avis":
                AsAvisVue(retour: {}, fermer: {}, ouvrirFiche: { _ in })
            default:
                AsCompteVue(ouvrirFiche: { _ in }, ouvrirApp: { _ in })
            }
        }
        .background(AsPalette.fondFeuille.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}
