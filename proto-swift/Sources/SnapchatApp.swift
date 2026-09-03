// Snapchat — Lost Phone (iPhone simulé de Sarah)
// v3.1 D92 (03/09 soir) — simplification, retours 279
//
// Doctrines appliquées :
//  · D92 — « juste milieu » : moins de fonctionnalités, mais une expérience cohérente.
//           Toute affordance affichée a une conséquence réelle ; sinon elle est RETIRÉE.
//           Les retraits sont annotés « (retiré D92) » et listés dans audit/snapchat-lot280.md
//           avec leur éventuel potentiel narratif, pour que Joachim tranche.
//  · D82 — aucun bouton mort. Plus aucune alerte « fourre-tout » : les états locaux ne
//           survivent jamais à leur écran (aucun modificateur d'alerte global dans ce fichier).
//  · D67 — la référence visuelle reste le tournage (refs/c2/snapchat/e001…e114, 1 pt = 1,5 px)
//           et les mesures relevées dans audit/snapchat.md §2.
//  · D59 — contenu de Sarah Levasseur (Lyon 7e), pseudo sarah.lvsr, photo p04, cohérent avec
//           Instagram / Facebook / Messenger. Aucune donnée réelle du téléphone source.
//  · D55 — Bitmoji rendus en émojis sur aplat pastel ; Sarah utilise sa photo p04.
//
// Écrans retenus : 5 onglets (Carte, Chat, Caméra, Stories, Spotlight) + 13 écrans secondaires
// — conversation, appel audio, appel vidéo, fiche d'ami·e, profil, mes amis·es / meilleurs amis,
// demandes d'ami·e, recherche, notifications, nouveau Chat, visionneuse de Story,
// caméra de Chat, « Envoyer à… », feuille ••• du Chat. Soit 15 clés de capture (+ snapchat#0..4).
//
// Point d'entrée public conservé : SnapchatVue(). Registre : src/patches/snapchat-lpproto-v31.md.
import SwiftUI
import MapKit

// ============================================================================
// MARK: - 1. JETONS DE STYLE (audit §2 — relevés au pixel sur les frames)
// ============================================================================

enum SnapPalette {
    static let jaune         = Color(hex: 0xFFFC00)   // e003, e114
    static let rougeBadge    = Color(hex: 0xFF1B3F)   // e003
    static let cercleEnTete  = Color(hex: 0xE7EAF1)   // e003
    static let ongletActif   = Color(hex: 0x252733)   // e005
    static let barreSombre   = Color(hex: 0x1B1B1B)   // e075
    static let bleu          = Color(hex: 0x1CA0F0)   // e003, e014
    static let violetSnap    = Color(hex: 0x9B4DFF)   // e003
    static let rougeMoi      = Color(hex: 0xE63455)   // e014 « Moi »
    static let fondMessage   = Color(hex: 0xE7EBEE)   // e014 bandeau de bloc
    static let horodatage    = Color(hex: 0x898989)   // e014
    static let texteStatut   = Color(hex: 0x7B7F86)   // e005
    static let carteVert     = Color(hex: 0xD7EDC9)   // e026
    static let heroProfil    = Color(hex: 0x1AB64B)   // e114
    static let bleuProfil    = Color(hex: 0x00A5FF)   // e114 badge de demandes
    static let bandeauSpot   = Color(hex: 0x010008)   // e075
    static let fondPage      = Color(hex: 0xF2F2F5)   // e114
    static let anneauStory   = Color(hex: 0xA435F0)   // e052
    static let anneauStory2  = Color(hex: 0xE0399B)   // e052
    static let filet         = Color(hex: 0xEFEFF3)
    static let filetOnglets  = Color(hex: 0xE6E6EA)
    static let placeholder   = Color(hex: 0xA9ADB4)
    static let rougeAppel    = Color(hex: 0xE8253F)
}

/// Mesures constantes converties des px des frames (1 pt = 1,5 px).
enum SnapMesure {
    static let cercleEnTete: CGFloat   = 35    // 52 px — e003
    static let boutonAjoutAmi: CGFloat = 40    // 60 px — e003
    static let pasLigneChat: CGFloat   = 60    // 90 px — e003
    static let avatarLigne: CGFloat    = 45    // 68 px — e003
    static let fab: CGFloat            = 60    // 89 px — e003
    static let anneauCapture: CGFloat  = 85    // 128 px — e001
    static let boutonCarte: CGFloat    = 37    // 56 px — e026
    static let avatarCarte: CGFloat    = 43    // 64 px — e026
    static let hauteurOnglets: CGFloat = 101   // 152 px filet → bas — e003
}

// ============================================================================
// MARK: - 2. MODÈLE DE DONNÉES (contenu de Sarah — D59)
// ============================================================================

/// Pictogrammes de statut relevés en e003 / e005 (audit §2.3).
enum SnapStatutGenre: Int {
    case recu = 0        // bulle carrée CONTOUR bleue   — « Reçu · 4sem »
    case remis = 1       // triangle PLEIN bleu          — « Remis · 21sem »
    case ouvert = 2      // triangle CONTOUR bleu        — « Ouvert · 17sem »
    case snapViolet = 3  // carré CONTOUR violet         — « Appuyez 2x pour répondre »
    case chatGris = 4    // bulle CONTOUR grise          — « Appuyer pour Chatter »
    case lieu = 5        // épingle CONTOUR grise        — « À proximité · maintenant »
    case aucun = 6       // My AI : aucun pictogramme

    var glyphe: String? {
        switch self {
        case .recu:       return "bubble.left"
        case .remis:      return "arrowtriangle.right.fill"
        case .ouvert:     return "arrowtriangle.right"
        case .snapViolet: return "square"
        case .chatGris:   return "bubble.left"
        case .lieu:       return "mappin.circle"
        case .aucun:      return nil
        }
    }

    var teinte: Color {
        switch self {
        case .recu, .remis, .ouvert: return SnapPalette.bleu
        case .snapViolet:            return SnapPalette.violetSnap
        default:                     return SnapPalette.texteStatut
        }
    }
}

struct SnapAmi: Identifiable, Hashable {
    let id: String
    var nom: String
    var pseudo: String
    var emoji: String
    var photo: String? = nil
    var teinte: UInt
    var statut: String
    var genre: SnapStatutGenre
    var presence: String            // sous-titre de la conversation (e014 : « À proximité · 1min »)
    var score: Int = 0
    var amisDepuis: String = ""
    var lat: Double = 45.7578
    var lon: Double = 4.8320
    var meilleurAmi: Bool = false
    var groupe: Bool = false
    var systeme: Bool = false       // Team Snapchat / My AI : pas comptés dans « Mes amis·es »

    var prenom: String { nom.components(separatedBy: " ").first ?? nom }
}

struct SnapMessage: Identifiable {
    let id = UUID()
    var deMoi: Bool
    var texte: String
    var heure: String
    var etat: String                // « Remis », « Ouvert », « Envoi… »
    var imageCle: String? = nil
    var sticker: String? = nil
}

/// Une seule structure de contenu ouvrable : Stories d'ami·es, cartes Découvrir, Ma Story.
struct SnapStory: Identifiable {
    let id: String
    var nom: String
    var pseudo: String
    var emoji: String
    var teinte: UInt
    var accroche: String
    var imageCle: String
    var fond: UInt
}

struct SnapSpot: Identifiable {
    let id: String
    var auteur: String
    var son: String
    var soustitre: String           // sous-titres incrustés (signature visuelle, e075)
    var imageCle: String
    var teinte1: UInt
    var teinte2: UInt
    var coeurs: Int
}

struct SnapDemande: Identifiable {
    let id: String
    var nom: String
    var pseudo: String
    var emoji: String
    var teinte: UInt
    var origine: String
    var lat: Double
    var lon: Double
}

struct SnapNotif: Identifiable {
    let id: String
    var idAmi: String
    var texte: String
    var quand: String
}

enum DonneesSnap {

    // Sarah Levasseur, 24 ans, Lyon 7e — identité commune aux 4 sociales.
    static let moiNom    = "Sarah"
    static let moiPseudo = "sarah.lvsr"
    static let moiEmoji  = "👩🏻"
    static let moiPhoto  = "p04"
    static let moiTeinte: UInt = 0x5B7CFA
    static let moiScore  = 3402

    /// 10 ami·es réel·les + 2 groupes + 2 comptes système. Coordonnées : Lyon et alentours.
    static let amisInitiaux: [SnapAmi] = [
        SnapAmi(id: "chloe", nom: "Chloé Berthier", pseudo: "chloe.brt", emoji: "👩🏻‍🦰", teinte: 0xFFE9EC,
                statut: "À proximité · maintenant", genre: .lieu, presence: "À proximité · 1min",
                score: 28640, amisDepuis: "mars 2019", lat: 45.7578, lon: 4.8320, meilleurAmi: true),
        SnapAmi(id: "ines", nom: "Inès Djellal", pseudo: "ines.djl", emoji: "👩🏽", teinte: 0xEDE7FF,
                statut: "Reçu · 4sem", genre: .recu, presence: "Lyon 3e · 2h",
                score: 19255, amisDepuis: "septembre 2020", lat: 45.7660, lon: 4.8280, meilleurAmi: true),
        SnapAmi(id: "camille", nom: "Camille Roussel", pseudo: "cam.rsl", emoji: "👱🏻‍♀️", teinte: 0xE2F4E8,
                statut: "Remis · 5sem", genre: .remis, presence: "Villeurbanne · 40min",
                score: 12080, amisDepuis: "juin 2021", lat: 45.7690, lon: 4.8830, meilleurAmi: true),
        SnapAmi(id: "lea", nom: "Léa Moreau", pseudo: "lea.mrx", emoji: "👩🏼", teinte: 0xFDEBDD,
                statut: "Ouvert · 17sem", genre: .ouvert, presence: "Oullins · hier",
                score: 9370, amisDepuis: "janvier 2022", lat: 45.7180, lon: 4.8060),
        SnapAmi(id: "thomas", nom: "Thomas Brulé", pseudo: "tom.brl", emoji: "👨🏻", teinte: 0xE3EEFF,
                statut: "Appuyer pour Chatter", genre: .chatGris, presence: "Lyon 6e · 5h",
                score: 6215, amisDepuis: "avril 2022", lat: 45.7702, lon: 4.8412),
        SnapAmi(id: "manon", nom: "Manon Decroix", pseudo: "manon.dcx", emoji: "👩🏾", teinte: 0xE8F0FF,
                statut: "Lyon 7e · 1h", genre: .lieu, presence: "Lyon 7e · 1h",
                score: 5088, amisDepuis: "octobre 2022", lat: 45.7480, lon: 4.8360),
        SnapAmi(id: "nassim", nom: "Nassim Kaci", pseudo: "nssm.k", emoji: "🧔🏽", teinte: 0xE7F1E9,
                statut: "Remis · 21sem", genre: .remis, presence: "Vaulx-en-Velin · 3j",
                score: 4460, amisDepuis: "février 2023", lat: 45.7770, lon: 4.9200),
        SnapAmi(id: "julie", nom: "Julie Ferrand", pseudo: "julie.frd", emoji: "👩🏼‍🦱", teinte: 0xFFF0E2,
                statut: "Reçu · 12sem", genre: .recu, presence: "Lyon 2e · 6h",
                score: 3925, amisDepuis: "mai 2023", lat: 45.7555, lon: 4.8455),
        SnapAmi(id: "oceane", nom: "Océane Chassaing", pseudo: "oce.chass", emoji: "👩🏻", teinte: 0xE9F3FF,
                statut: "Ouvert · 2sem", genre: .ouvert, presence: "Croix-Rousse · 30min",
                score: 3210, amisDepuis: "juillet 2023", lat: 45.7770, lon: 4.8300),
        SnapAmi(id: "florian", nom: "Florian Canel", pseudo: "florian.cnl", emoji: "👨🏼", teinte: 0xEFE9DE,
                statut: "Appuyer pour Chatter", genre: .chatGris, presence: "Bron · hier",
                score: 2755, amisDepuis: "novembre 2023", lat: 45.7350, lon: 4.9120),
        SnapAmi(id: "soiree", nom: "Soirée 30 juin", pseudo: "soiree30juin", emoji: "🥂", teinte: 0xFFF3D6,
                statut: "Inès a réagi à un Chat. · 8sem", genre: .recu, presence: "6 participants",
                groupe: true),
        SnapAmi(id: "brunch", nom: "Brunch dimanche", pseudo: "brunchdimanche", emoji: "🥐", teinte: 0xFFF0E2,
                statut: "Camille a réagi à un Chat. · 3sem", genre: .recu, presence: "4 participants",
                groupe: true),
        SnapAmi(id: "team", nom: "Team Snapchat", pseudo: "teamsnapchat", emoji: "👻", teinte: 0xFFFC00,
                statut: "Appuyez 2x pour répondre", genre: .snapViolet, presence: "Compte officiel",
                systeme: true),
        SnapAmi(id: "myai", nom: "My AI", pseudo: "myai", emoji: "🤖", teinte: 0xF0E4FF,
                statut: "Jouer à un jeu de culture générale ?", genre: .aucun, presence: "Toujours disponible",
                systeme: true),
    ]

    static func ami(_ cle: String) -> SnapAmi {
        amisInitiaux.first(where: { $0.id == cle }) ?? amisInitiaux[0]
    }

    /// Un fil DISTINCT par conversation.
    static let filsInitiaux: [String: [SnapMessage]] = [
        "chloe": [
            SnapMessage(deMoi: false, texte: "Tu es encore au parc ? je passe 😄", heure: "12:02", etat: "Ouvert"),
            SnapMessage(deMoi: true, texte: "Ouiii je suis vers la grande serre", heure: "12:04", etat: "Remis"),
            SnapMessage(deMoi: false, texte: "", heure: "12:06", etat: "Ouvert", sticker: "🌻"),
            SnapMessage(deMoi: true, texte: "", heure: "12:12", etat: "Remis", imageCle: "p24"),
            SnapMessage(deMoi: false, texte: "Trop mignonne la photo", heure: "12:15", etat: "Ouvert"),
        ],
        "ines": [
            SnapMessage(deMoi: false, texte: "On se fait la Croix-Rousse samedi ?", heure: "18:12", etat: "Ouvert"),
            SnapMessage(deMoi: true, texte: "Carrément, on part de chez toi ?", heure: "18:20", etat: "Remis"),
            SnapMessage(deMoi: false, texte: "Ça marche, 14h 🙌", heure: "18:22", etat: "Ouvert"),
        ],
        "camille": [
            SnapMessage(deMoi: true, texte: "Tu as récupéré ma veste chez Léa ?", heure: "21:03", etat: "Remis"),
            SnapMessage(deMoi: false, texte: "Oui elle est chez moi, passe quand tu veux", heure: "21:11", etat: "Ouvert"),
        ],
        "lea": [
            SnapMessage(deMoi: true, texte: "Trop belle la photo du quai 🌇", heure: "08:30", etat: "Ouvert"),
            SnapMessage(deMoi: false, texte: "Merci !! c'était dimanche matin", heure: "08:41", etat: "Ouvert"),
        ],
        "thomas": [
            SnapMessage(deMoi: false, texte: "Salut ! toujours partante pour la rando ?", heure: "10:15", etat: "Ouvert"),
        ],
        "manon": [
            SnapMessage(deMoi: false, texte: "Je suis dans ton quartier, un café ?", heure: "15:02", etat: "Ouvert"),
        ],
        "nassim": [
            SnapMessage(deMoi: true, texte: "Bien reçu pour dimanche 👍", heure: "13:58", etat: "Remis"),
        ],
        "julie": [
            SnapMessage(deMoi: false, texte: "Tu viens au vide-grenier de la Guillotière ?", heure: "09:47", etat: "Ouvert"),
        ],
        "oceane": [
            SnapMessage(deMoi: false, texte: "J'ai retrouvé ton écharpe au studio", heure: "20:05", etat: "Ouvert"),
            SnapMessage(deMoi: true, texte: "Ahh merci, je passe mardi", heure: "20:19", etat: "Remis"),
        ],
        "florian": [
            SnapMessage(deMoi: false, texte: "Bonne rentrée 💪", heure: "07:52", etat: "Ouvert"),
        ],
        "soiree": [
            SnapMessage(deMoi: false, texte: "On dit 20h chez Inès pour l'apéro", heure: "17:40", etat: "Ouvert"),
            SnapMessage(deMoi: true, texte: "Je ramène les tartes 🥧", heure: "17:44", etat: "Remis"),
            SnapMessage(deMoi: false, texte: "Parfait, j'amène la sono", heure: "17:52", etat: "Ouvert"),
        ],
        "brunch": [
            SnapMessage(deMoi: false, texte: "Réservation confirmée pour 4 à 11h30", heure: "19:05", etat: "Ouvert"),
        ],
        "team": [
            SnapMessage(deMoi: false, texte: "Bienvenue sur Snapchat ! Appuyez 2x pour répondre 👻", heure: "09:00", etat: "Ouvert"),
        ],
        "myai": [
            SnapMessage(deMoi: false, texte: "Salut Sarah ! Jouer à un jeu de culture générale ?", heure: "11:20", etat: "Ouvert"),
        ],
    ]

    /// Stories d'ami·es — chaque entrée s'ouvre réellement dans la visionneuse.
    static let storiesAmis: [SnapStory] = [
        SnapStory(id: "st.chloe", nom: "Chloé Berthier", pseudo: "chloe.brt", emoji: "👩🏻‍🦰", teinte: 0xFFE9EC,
                  accroche: "il y a 2 h", imageCle: "p12", fond: 0x2B2440),
        SnapStory(id: "st.ines", nom: "Inès Djellal", pseudo: "ines.djl", emoji: "👩🏽", teinte: 0xEDE7FF,
                  accroche: "il y a 5 h", imageCle: "p33", fond: 0x3A2436),
        SnapStory(id: "st.lea", nom: "Léa Moreau", pseudo: "lea.mrx", emoji: "👩🏼", teinte: 0xFDEBDD,
                  accroche: "il y a 9 h", imageCle: "p36", fond: 0x1F3A4C),
        SnapStory(id: "st.oceane", nom: "Océane Chassaing", pseudo: "oce.chass", emoji: "👩🏻", teinte: 0xE9F3FF,
                  accroche: "hier", imageCle: "p39", fond: 0x24382E),
    ]

    /// Découvrir — 4 cartes ouvrables, sans tuile sponsorisée ni bouton d'abonnement (retiré D92).
    static let decouvrir: [SnapStory] = [
        SnapStory(id: "dec.pont", nom: "Lyon Capitale", pseudo: "lyoncapitale", emoji: "🗞", teinte: 0xE3EEFF,
                  accroche: "3 min de lecture", imageCle: "p36", fond: 0x1F4C81),
        SnapStory(id: "dec.praline", nom: "Croqu'Lyon", pseudo: "croqulyon", emoji: "🥐", teinte: 0xFFE9EC,
                  accroche: "Épisode du jour", imageCle: "p33", fond: 0x6B2436),
        SnapStory(id: "dec.traboules", nom: "Lyon Secret", pseudo: "lyonsecret", emoji: "🏛", teinte: 0xEDE7FF,
                  accroche: "6 min", imageCle: "p28", fond: 0x2E2350),
        SnapStory(id: "dec.colocs", nom: "Studio 69", pseudo: "studio69", emoji: "🎬", teinte: 0xE2F4E8,
                  accroche: "Série", imageCle: "p24", fond: 0x24463A),
    ]

    /// Fil Spotlight — 4 cartes, compteurs de cœurs inventés (D59).
    static let spots: [SnapSpot] = [
        SnapSpot(id: "sp1", auteur: "lyon.insolite", son: "Son original · lyon.insolite",
                 soustitre: "et là, il te sort qu'il connaît pas les traboules",
                 imageCle: "p36", teinte1: 0x18324F, teinte2: 0x060A12, coeurs: 1284),
        SnapSpot(id: "sp2", auteur: "chloe.brt", son: "Son original · chloe.brt",
                 soustitre: "trois heures de queue pour CE sandwich",
                 imageCle: "p33", teinte1: 0x4A2231, teinte2: 0x0B0508, coeurs: 612),
        SnapSpot(id: "sp3", auteur: "rhone.matin", son: "Son original · rhone.matin",
                 soustitre: "le brouillard sur la Saône à 6h, personne n'y croit",
                 imageCle: "p39", teinte1: 0x1E3B33, teinte2: 0x05100C, coeurs: 3907),
        SnapSpot(id: "sp4", auteur: "ines.djl", son: "Son original · ines.djl",
                 soustitre: "ma coloc a rangé le frigo par couleur",
                 imageCle: "p28", teinte1: 0x2E2350, teinte2: 0x090615, coeurs: 845),
    ]

    /// Demandes d'ami·e réellement acceptables — le badge d'en-tête vaut leur nombre.
    static let demandesInitiales: [SnapDemande] = [
        SnapDemande(id: "karim", nom: "Karim Belkacem", pseudo: "karim.blk", emoji: "🧑🏽", teinte: 0xE3EEFF,
                    origine: "Vous avez 3 ami·es en commun", lat: 45.7605, lon: 4.8305),
        SnapDemande(id: "salome", nom: "Salomé Vidal", pseudo: "salome.vdl", emoji: "👩🏼", teinte: 0xFFE9EC,
                    origine: "Ajoutée depuis vos contacts", lat: 45.7520, lon: 4.8380),
        SnapDemande(id: "hugo", nom: "Hugo Perret", pseudo: "hugo.prt", emoji: "👨🏽", teinte: 0xE2F4E8,
                    origine: "Vous avez 1 ami·e en commun", lat: 45.7670, lon: 4.8500),
    ]

    static let notifs: [SnapNotif] = [
        SnapNotif(id: "n1", idAmi: "chloe", texte: "Chloé Berthier a ajouté à sa Story", quand: "il y a 2 h"),
        SnapNotif(id: "n2", idAmi: "ines", texte: "Inès Djellal vous a envoyé un Snap", quand: "il y a 4 h"),
        SnapNotif(id: "n3", idAmi: "camille", texte: "Camille Roussel a réagi à votre Chat", quand: "hier"),
        SnapNotif(id: "n4", idAmi: "oceane", texte: "Océane Chassaing vous a envoyé un Chat", quand: "hier"),
    ]

    static let filtresChat = ["My AI", "Groupes", "Près de moi", "Meilleurs·es amis·es"]

    // ————— Accesseurs de CAPTURE (D63) : jamais optionnels, jamais d'indice nu.
    static func convCapture() -> SnapAmi { ami("chloe") }
    static func storyCapture() -> SnapStory { storiesAmis[0] }
    static func decouvrirCapture() -> SnapStory { decouvrir[0] }
    static func maStory() -> SnapStory {
        SnapStory(id: "st.moi", nom: "Ma Story", pseudo: moiPseudo, emoji: moiEmoji, teinte: 0xFFE9EC,
                  accroche: "Ajoutée aujourd'hui · 18:04", imageCle: "p12", fond: 0x24382E)
    }
}

// ============================================================================
// MARK: - 3. ÉTAT PARTAGÉ (@Published — tout ce qui bouge dans l'app)
// ============================================================================

final class SnapEtat: ObservableObject {
    static let partage = SnapEtat()

    @Published var amis: [SnapAmi] = DonneesSnap.amisInitiaux
    @Published var fils: [String: [SnapMessage]] = DonneesSnap.filsInitiaux
    @Published var demandes: [SnapDemande] = DonneesSnap.demandesInitiales
    @Published var storiesVues: Set<String> = []
    /// Pastille de la cloche : vraie information (des notifications non lues), qui DISPARAÎT
    /// dès que l'écran Notifications a été ouvert — plus de point rouge décoratif (D82).
    @Published var notifsLues: Bool = false
    @Published var coeurs: [String: Int] = [:]
    @Published var aimes: Set<String> = []
    /// Recentrage demandé sur la Snap Map (depuis une fiche d'ami·e) — jamais un état d'écran.
    @Published var cibleCarte: String? = nil
    @Published var demandeCarte: Int = 0

    init() {
        var c: [String: Int] = [:]
        for s in DonneesSnap.spots { c[s.id] = s.coeurs }
        coeurs = c
    }

    // ————— Ami·es
    /// Ami·es réel·les : ni groupes, ni comptes système. Le compteur du Profil vaut ce nombre.
    var amisReels: [SnapAmi] { amis.filter { !$0.groupe && !$0.systeme } }
    var meilleursAmis: [SnapAmi] { amis.filter { $0.meilleurAmi } }
    var amisSurCarte: [SnapAmi] { amisReels }

    func ami(_ cle: String) -> SnapAmi {
        amis.first(where: { $0.id == cle }) ?? DonneesSnap.ami(cle)
    }

    /// Accepter une demande met l'état à jour PARTOUT : badge, liste Chat, carte, Profil.
    func accepter(_ demande: SnapDemande) {
        demandes.removeAll { $0.id == demande.id }
        guard !amis.contains(where: { $0.id == demande.id }) else { return }
        let nouveau = SnapAmi(id: demande.id, nom: demande.nom, pseudo: demande.pseudo,
                              emoji: demande.emoji, teinte: demande.teinte,
                              statut: "Appuyer pour Chatter", genre: .chatGris,
                              presence: "Nouvel·le ami·e", score: 0, amisDepuis: "aujourd'hui",
                              lat: demande.lat, lon: demande.lon)
        amis.insert(nouveau, at: 0)
        fils[demande.id] = [
            SnapMessage(deMoi: false, texte: "Salut ! merci pour l'ajout 👋",
                        heure: SnapEtat.heureCourante(), etat: "Ouvert")
        ]
    }

    func refuser(_ demande: SnapDemande) {
        demandes.removeAll { $0.id == demande.id }
    }

    /// Menu ••• de la liste Chat : action réelle sur les pictogrammes de statut.
    func marquerTousLus() {
        for i in amis.indices where amis[i].genre == .recu || amis[i].genre == .snapViolet {
            amis[i].genre = .chatGris
            amis[i].statut = "Appuyer pour Chatter"
        }
    }

    // ————— Messages
    func envoyer(_ texte: String, a idAmi: String) {
        let t = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return }
        var fil = fils[idAmi] ?? []
        fil.append(SnapMessage(deMoi: true, texte: t, heure: SnapEtat.heureCourante(), etat: "Envoi…"))
        fils[idAmi] = fil
        confirmer(idAmi, index: fil.count - 1)
    }

    func envoyerSnap(a idAmi: String, cle: String) {
        var fil = fils[idAmi] ?? []
        fil.append(SnapMessage(deMoi: true, texte: "", heure: SnapEtat.heureCourante(),
                               etat: "Envoi…", imageCle: cle))
        fils[idAmi] = fil
        confirmer(idAmi, index: fil.count - 1)
    }

    private func confirmer(_ idAmi: String, index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            guard let self else { return }
            guard var f = self.fils[idAmi], index < f.count else { return }
            f[index].etat = "Remis"
            self.fils[idAmi] = f
        }
    }

    // ————— Stories
    var storiesNonVues: Int {
        DonneesSnap.storiesAmis.filter { !storiesVues.contains($0.id) }.count
    }

    func marquerStoryVue(_ id: String) { storiesVues.insert(id) }

    // ————— Spotlight
    func basculerCoeur(_ idSpot: String) {
        if aimes.contains(idSpot) {
            aimes.remove(idSpot)
            coeurs[idSpot] = max(0, (coeurs[idSpot] ?? 1) - 1)
        } else {
            aimes.insert(idSpot)
            coeurs[idSpot] = (coeurs[idSpot] ?? 0) + 1
        }
    }

    // ————— Snap Map
    func demanderCarte(_ idAmi: String) {
        cibleCarte = idAmi
        demandeCarte += 1
    }

    static func heureCourante() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: Date())
    }

    static func nombre(_ n: Int) -> String {
        if n < 1000 { return "\(n)" }
        let milliers = Double(n) / 1000.0
        return String(format: "%.1f k", milliers).replacingOccurrences(of: ".", with: ",")
    }
}

// ============================================================================
// MARK: - 4. COMPOSANTS PARTAGÉS
// ============================================================================

/// Avatar : photo réelle si la clé existe (Sarah = p04), sinon émoji sur aplat pastel (D55).
struct SnapAvatar: View {
    let emoji: String
    var photo: String? = nil
    let teinte: UInt
    var taille: CGFloat = 45

    var body: some View {
        ZStack {
            Circle().fill(Color(hex: teinte))
            contenu
        }
        .frame(width: taille, height: taille)
        .clipShape(Circle())
    }

    @ViewBuilder private var contenu: some View {
        if let p = photo, let img = ChargeurPhoto.image(p) {
            Color.clear.overlay(Image(uiImage: img).resizable().scaledToFill()).clipped()
        } else {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: taille * 0.92, height: taille * 0.42)
                    .offset(y: taille * 0.30)
                Text(emoji).font(.system(size: taille * 0.54))
            }
        }
    }
}

/// Avatar de Sarah — un seul point de vérité pour les 6 écrans qui l'affichent.
struct SnapAvatarMoi: View {
    var taille: CGFloat = 35
    var body: some View {
        SnapAvatar(emoji: DonneesSnap.moiEmoji, photo: DonneesSnap.moiPhoto,
                   teinte: DonneesSnap.moiTeinte, taille: taille)
    }
}

struct SnapBadge: View {
    let texte: String
    var body: some View {
        Text(texte)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(Capsule().fill(SnapPalette.rougeBadge))
    }
}

struct SnapPastille: View {
    var taille: CGFloat = 10
    var body: some View {
        Circle()
            .fill(SnapPalette.rougeBadge)
            .frame(width: taille, height: taille)
            .overlay(Circle().strokeBorder(Color.white, lineWidth: 1.5))
    }
}

/// Image de contenu : jamais de .scaledToFill() direct sur une Image en cellule.
struct SnapImage: View {
    let cle: String
    let teinte1: UInt
    let teinte2: UInt
    var body: some View {
        Color.clear
            .overlay(contenu)
            .clipped()
    }
    @ViewBuilder private var contenu: some View {
        if let img = ChargeurPhoto.image(cle) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            LinearGradient(colors: [Color(hex: teinte1), Color(hex: teinte2)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

/// Filet de séparation d'une liste.
struct SnapFilet: View {
    var marge: CGFloat = 0
    var body: some View {
        Rectangle().fill(SnapPalette.filet).frame(height: 0.5).padding(.leading, marge)
    }
}

/// En-tête blanc d'un écran secondaire : titre + croix de fermeture.
struct SnapEnTeteFeuille: View {
    let titre: String
    let surFermer: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(titre).font(.system(size: 20, weight: .bold)).foregroundStyle(.black)
                Spacer()
                Circle().fill(SnapPalette.cercleEnTete).frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.black)
                    )
                    .contentShape(Circle())
                    .onTapGesture { Haptique.leger(); surFermer() }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            SnapFilet()
        }
        .background(Color.white)
    }
}

/// Viseur diégétique : pas d'accès caméra dans la fiction (D56) — fond gris, scène plausible.
struct SnapViseur: View {
    var avant: Bool = false
    var flash: Bool = false

    private var teintes: [Color] {
        if avant { return [Color(hex: 0xB9BCC4), Color(hex: 0x6E7178)] }
        return [Color(hex: 0x9EA2AA), Color(hex: 0x4E5158)]
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: teintes, startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [Color.white.opacity(flash ? 0.45 : 0.20), .clear],
                           center: .topLeading, startRadius: 12, endRadius: 340)
            Image(systemName: "viewfinder")
                .font(.system(size: 54, weight: .ultraLight))
                .foregroundStyle(Color.white.opacity(0.30))
        }
    }
}

// ============================================================================
// MARK: - 5. EN-TÊTE COMMUN (audit §2.2 — Chat / Stories / Caméra / Spotlight)
// ============================================================================

enum SnapEnTeteStyle { case clair, sombre, viseur }

struct SnapEnTete: View {
    let titre: String
    var style: SnapEnTeteStyle = .clair
    var ajoutJaune: Bool = false        // e003 : fond jaune sur Chat, gris sur Stories, nu ailleurs
    var sansTitre: Bool = false         // e001 : la caméra n'affiche pas de titre
    var avecPlus: Bool = false          // le ••• n'existe que sur la liste Chat (menu réel)
    var demandes: Int = 0
    var notifsNonLues: Bool = false     // pastille de la cloche, effacée par l'écran Notifications

    let surProfil: () -> Void
    let surRecherche: () -> Void
    let surCloche: () -> Void
    let surAjout: () -> Void
    var surPlus: () -> Void = {}

    private var teinteGlyphe: Color { style == .clair ? Color.black : Color.white }
    private var fondCercle: Color { style == .clair ? SnapPalette.cercleEnTete : Color.clear }

    var body: some View {
        HStack(spacing: 10) {
            bitmoji
            cercle("magnifyingglass", action: surRecherche)
            Spacer(minLength: 4)
            if !sansTitre {
                Text(titre)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(teinteGlyphe)
                Spacer(minLength: 4)
            }
            cloche
            boutonAjout
            if avecPlus { cercle("ellipsis", action: surPlus) }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
    }

    /// Avatar de Sarah, sans point rouge : il ouvre le Profil, il n'annonce rien d'autre.
    private var bitmoji: some View {
        SnapAvatarMoi(taille: SnapMesure.cercleEnTete)
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); surProfil() }
    }

    /// La pastille est portée par la cloche, le seul bouton qui la fait disparaître.
    private var cloche: some View {
        ZStack(alignment: .topTrailing) {
            cercle("bell", action: surCloche)
            if notifsNonLues {
                SnapPastille(taille: 11).offset(x: 1, y: -1).allowsHitTesting(false)
            }
        }
    }

    private func cercle(_ glyphe: String, action: @escaping () -> Void) -> some View {
        Circle()
            .fill(fondCercle)
            .frame(width: SnapMesure.cercleEnTete, height: SnapMesure.cercleEnTete)
            .overlay(
                Image(systemName: glyphe)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(teinteGlyphe)
            )
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); action() }
    }

    private var boutonAjout: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(ajoutJaune ? SnapPalette.jaune : fondCercle)
                .frame(width: SnapMesure.boutonAjoutAmi, height: SnapMesure.boutonAjoutAmi)
                .overlay(
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(ajoutJaune ? Color.black : teinteGlyphe)
                )
            if demandes > 0 { SnapBadge(texte: "\(demandes)").offset(x: 8, y: -4) }
        }
        .contentShape(Circle())
        .onTapGesture { Haptique.leger(); surAjout() }
    }
}

// ============================================================================
// MARK: - 6. BARRE D'ONGLETS (audit §2.1 — 101 pt, contour inactif / plein actif)
// ============================================================================

struct SnapBarreOnglets: View {
    @Binding var onglet: Int
    let clair: Bool
    let badgeStories: Int
    let surAccueil: () -> Void

    private let glyphes: [(String, String)] = [
        ("mappin.and.ellipse", "mappin.circle.fill"),
        ("bubble.left", "bubble.left.fill"),
        ("camera", "camera.fill"),
        ("person.2", "person.2.fill"),
        ("play.rectangle", "play.rectangle.fill"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(clair ? SnapPalette.filetOnglets : Color(hex: 0x2A2A2A))
                .frame(height: 0.5)
            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { i in
                    bouton(i).frame(maxWidth: .infinity)
                }
            }
            .frame(height: 56)
            BarreHome(action: surAccueil, sombre: clair)
        }
        .background(clair ? Color.white : SnapPalette.barreSombre)
    }

    @ViewBuilder
    private func bouton(_ i: Int) -> some View {
        let actif = onglet == i
        ZStack(alignment: .topTrailing) {
            Image(systemName: actif ? glyphes[i].1 : glyphes[i].0)
                .font(.system(size: 23, weight: actif ? Font.Weight.semibold : Font.Weight.regular))
                .foregroundStyle(teinte(actif))
            if i == 3 && badgeStories > 0 {
                SnapBadge(texte: "\(badgeStories)").offset(x: 14, y: -6)
            }
        }
        .frame(height: 40)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); onglet = i }
    }

    private func teinte(_ actif: Bool) -> Color {
        if actif { return clair ? SnapPalette.ongletActif : Color.white }
        return clair ? Color(hex: 0x8A8D95) : Color(hex: 0x9A9A9E)
    }
}

// ============================================================================
// MARK: - 7. ROUTES (écrans secondaires — un seul point de présentation)
// ============================================================================

enum SnapRoute: String, Identifiable {
    case profil, recherche, notifications, demandes, nouveauChat
    case mesAmis, meilleursAmis, maStory
    var id: String { rawValue }
}

struct SnapRouteVue: View {
    let route: SnapRoute

    var body: some View {
        switch route {
        case .profil:        SnapProfilVue()
        case .recherche:     SnapRechercheVue()
        case .notifications: SnapNotificationsVue()
        case .demandes:      SnapDemandesVue()
        case .nouveauChat:   SnapNouveauChatVue()
        case .mesAmis:       SnapListeAmisVue(titre: "Mes amis·es", meilleurs: false)
        case .meilleursAmis: SnapListeAmisVue(titre: "Meilleurs amis", meilleurs: true)
        case .maStory:       SnapVisionneuseVue(story: DonneesSnap.maStory())
        }
    }
}

// ============================================================================
// MARK: - 8. COQUILLE — 5 onglets (e001 / e003 / e026 / e053 / e075)
// ============================================================================

struct SnapchatVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    @State private var onglet: Int
    @State private var route: SnapRoute? = nil

    /// `SnapchatVue()` reste le point d'entrée de la coque (LPProto).
    /// `SnapchatVue(onglet:)` sert au mode capture (snapchat.camera / snapchat.spotlight).
    init(onglet: Int? = nil) {
        var depart = 1
        if let brut = ProcessInfo.processInfo.environment["ONGLET"], let n = Int(brut) { depart = n }
        if let o = onglet { depart = o }
        _onglet = State(initialValue: depart)
    }

    private var clair: Bool { onglet == 0 || onglet == 1 || onglet == 3 }

    var body: some View {
        ZStack(alignment: .bottom) {
            (clair ? Color.white : SnapPalette.barreSombre).ignoresSafeArea()
            contenu
            SnapBarreOnglets(onglet: $onglet, clair: clair,
                             badgeStories: etat.storiesNonVues,
                             surAccueil: { dismiss() })
        }
        .fullScreenCover(item: $route) { r in SnapRouteVue(route: r) }
        .onChange(of: etat.demandeCarte) { _, _ in onglet = 0 }
        .preferredColorScheme(clair ? ColorScheme.light : ColorScheme.dark)
    }

    @ViewBuilder
    private var contenu: some View {
        switch onglet {
        case 0: SnapCarteVue(route: $route)
        case 2: SnapCameraVue(route: $route)
        case 3: SnapStoriesVue(route: $route)
        case 4: SnapSpotlightVue(route: $route)
        default: SnapChatListeVue(route: $route)
        }
    }
}

// ============================================================================
// MARK: - 9. CHAT — LISTE (e003, e005, e022) — sans accessoire de fin de ligne
// ============================================================================

struct SnapChatListeVue: View {
    @Binding var route: SnapRoute?
    @ObservedObject private var etat = SnapEtat.partage
    @State private var conversation: SnapAmi? = nil
    @State private var filtre: String? = nil
    @State private var menuVisible = false

    /// `filtre ?? ""` : on compare des String NON optionnelles (aucune promotion d'optionnel
    /// dans un motif de `switch` — le compilateur n'a rien à inférer).
    private var amisVisibles: [SnapAmi] {
        switch filtre ?? "" {
        case "Groupes":              return etat.amis.filter { $0.groupe }
        case "Près de moi":          return etat.amis.filter { $0.genre == .lieu }
        case "Meilleurs·es amis·es": return etat.amis.filter { $0.meilleurAmi }
        default:                     return etat.amis
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                enTete
                rangeeFiltres
                liste
            }
            fab
        }
        .background(Color.white)
        .fullScreenCover(item: $conversation) { a in SnapConversationVue(ami: a) }
        .sheet(isPresented: $menuVisible) { menu }
    }

    private var enTete: some View {
        SnapEnTete(titre: "Chat", style: .clair, ajoutJaune: true, avecPlus: true,
                   demandes: etat.demandes.count, notifsNonLues: !etat.notifsLues,
                   surProfil: { route = .profil },
                   surRecherche: { route = .recherche },
                   surCloche: { route = .notifications },
                   surAjout: { route = .demandes },
                   surPlus: { menuVisible = true })
    }

    // ————— Filtres : TEXTE NU, aucune pilule de fond (audit §2.3)
    private var rangeeFiltres: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(DonneesSnap.filtresChat, id: \.self) { f in
                    HStack(spacing: 6) {
                        if f == "My AI" {
                            SnapAvatar(emoji: "🤖", teinte: 0xF0E4FF, taille: 21)
                        }
                        Text(f)
                            .font(.system(size: 16,
                                          weight: filtre == f ? Font.Weight.bold : Font.Weight.semibold))
                            .foregroundStyle(filtre == f ? SnapPalette.bleu : Color.black)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { toucheFiltre(f) }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
        }
    }

    /// « My AI » n'est pas un filtre menteur : il ouvre la conversation My AI.
    private func toucheFiltre(_ f: String) {
        Haptique.leger()
        if f == "My AI" {
            conversation = etat.ami("myai")
        } else {
            filtre = (filtre == f ? nil : f)
        }
    }

    private var liste: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(amisVisibles) { a in
                    SnapLigneChat(ami: a, surOuvrir: { conversation = a })
                }
                Spacer(minLength: SnapMesure.hauteurOnglets + 12)
            }
        }
    }

    /// Menu ••• : deux actions réelles seulement (D82) — pas de liste d'options décoratives.
    private var menu: some View {
        SnapMenuChatVue(surMesAmis: { route = .mesAmis })
    }

    // ————— FAB jaune ⌀60 pt, marge droite 16 pt, 15 pt au-dessus du filet (e003)
    private var fab: some View {
        Circle()
            .fill(SnapPalette.jaune)
            .frame(width: SnapMesure.fab, height: SnapMesure.fab)
            .overlay(
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.black)
            )
            .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); route = .nouveauChat }
            .padding(.trailing, 16)
            .padding(.bottom, SnapMesure.hauteurOnglets + 15)
    }
}

/// Rangée de la liste Chat : avatar 45 pt, nom, pictogramme + statut. Aucun appareil photo
/// à droite (retiré à la demande de Joachim — retours 279 §4).
struct SnapLigneChat: View {
    let ami: SnapAmi
    let surOuvrir: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            SnapAvatar(emoji: ami.emoji, photo: ami.photo, teinte: ami.teinte,
                       taille: SnapMesure.avatarLigne)
            VStack(alignment: .leading, spacing: 3) {
                Text(ami.nom)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                ligneStatut
            }
            Spacer(minLength: 8)
        }
        .padding(.horizontal, 11)
        .frame(height: SnapMesure.pasLigneChat)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); surOuvrir() }
    }

    private var ligneStatut: some View {
        HStack(spacing: 5) {
            if let g = ami.genre.glyphe {
                Image(systemName: g)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ami.genre.teinte)
            }
            Text(ami.statut)
                .font(.system(size: 12.5))
                .foregroundStyle(SnapPalette.texteStatut)
                .lineLimit(1)
        }
    }
}

/// Feuille du ••• : « Marquer tout comme lu » agit vraiment sur les pictogrammes,
/// « Mes amis·es · N » ouvre la liste réelle. Rien d'autre (D92).
struct SnapMenuChatVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    let surMesAmis: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SnapEnTeteFeuille(titre: "Chat", surFermer: { dismiss() })
            ligne("checkmark.circle", "Marquer tout comme lu") {
                etat.marquerTousLus()
                dismiss()
            }
            SnapFilet(marge: 16)
            ligne("person.2", "Mes amis·es · \(etat.amisReels.count)") {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { surMesAmis() }
            }
            SnapFilet(marge: 16)
            Spacer(minLength: 0)
            BarreHome(action: { dismiss() }, sombre: true)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }

    private func ligne(_ glyphe: String, _ titre: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 14) {
            Image(systemName: glyphe).font(.system(size: 18)).foregroundStyle(.black).frame(width: 26)
            Text(titre).font(.system(size: 16)).foregroundStyle(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(SnapPalette.texteStatut)
        }
        .padding(.horizontal, 16).frame(height: 56)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); action() }
    }
}

// ============================================================================
// MARK: - 10. CONVERSATION (e010–e017, mesures d'e014)
// ============================================================================

/// Plein écran ouvert DEPUIS la conversation : un seul point de présentation
/// (plusieurs `.fullScreenCover` empilés sur la même vue ne se déclenchent pas de façon fiable).
enum SnapPleinConversation: String, Identifiable {
    case camera, appelAudio, appelVideo
    var id: String { rawValue }
}

struct SnapConversationVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    let ami: SnapAmi
    @State private var saisie = ""
    @State private var ficheVisible = false
    @State private var plein: SnapPleinConversation? = nil

    private var messages: [SnapMessage] { etat.fils[ami.id] ?? [] }

    var body: some View {
        VStack(spacing: 0) {
            entete
            fil
            composeur
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .sheet(isPresented: $ficheVisible) { fiche }
        .fullScreenCover(item: $plein) { p in contenuPlein(p) }
        // « Voir sur la Snap Map » : cet écran se ferme pour laisser voir la carte recentrée.
        .onChange(of: etat.demandeCarte) { _, _ in dismiss() }
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private func contenuPlein(_ p: SnapPleinConversation) -> some View {
        switch p {
        case .camera:     SnapCameraChatVue(ami: ami)
        case .appelAudio: SnapAppelAudioVue(ami: ami)
        case .appelVideo: SnapAppelVideoVue(ami: ami)
        }
    }

    // ————— En-tête : ‹ fin, avatar 29 pt, nom + sous-titre, téléphone et vidéo NOIRS PLEINS
    private var entete: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(.black)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); dismiss() }
                identite
                Spacer()
                Image(systemName: "phone.fill")
                    .font(.system(size: 19)).foregroundStyle(.black)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); plein = .appelAudio }
                Image(systemName: "video.fill")
                    .font(.system(size: 21)).foregroundStyle(.black)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); plein = .appelVideo }
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            SnapFilet()
        }
        .background(Color.white)
    }

    /// Tap sur l'avatar OU sur le nom : ouvre vraiment la fiche d'ami·e.
    private var identite: some View {
        HStack(spacing: 10) {
            SnapAvatar(emoji: ami.emoji, photo: ami.photo, teinte: ami.teinte, taille: 29)
            VStack(alignment: .leading, spacing: 1) {
                Text(ami.nom).font(.system(size: 17, weight: .bold)).foregroundStyle(.black)
                Text(ami.presence).font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); ficheVisible = true }
    }

    private var fil: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    Text("17 AOÛT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(SnapPalette.texteStatut)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    ForEach(messages) { m in
                        SnapBlocMessage(message: m, nomAmi: ami.prenom).id(m.id)
                    }
                    Spacer(minLength: 12).id("bas")
                }
                .padding(.top, 8)
            }
            .background(Color.white)
            .onAppear { proxy.scrollTo("bas", anchor: .bottom) }
            .onChange(of: messages.count) { _, _ in
                withAnimation { proxy.scrollTo("bas", anchor: .bottom) }
            }
        }
    }

    /// Barre de saisie simplifiée (retours 279) : caméra + champ + emoji.
    /// Retirés : forme d'onde (message audio), autocollants « deux carrés », manette de jeu.
    private var composeur: some View {
        SnapComposeur(saisie: $saisie,
                      surEnvoyer: { envoyer() },
                      surCamera: { plein = .camera },
                      surSmiley: { saisie += " 🙂" })
    }

    private var fiche: some View {
        SnapFicheAmiVue(ami: ami, surCarte: { etat.demanderCarte(ami.id) })
    }

    private func envoyer() {
        let t = saisie
        saisie = ""
        etat.envoyer(t, a: ami.id)
        Haptique.leger()
    }
}

/// Bloc de message : bandeau gris #E7EBEE pleine largeur + barre verticale colorée (e014).
struct SnapBlocMessage: View {
    let message: SnapMessage
    let nomAmi: String

    private var teinte: Color { message.deMoi ? SnapPalette.rougeMoi : SnapPalette.bleu }
    private var nom: String { message.deMoi ? "Moi" : nomAmi }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(nom).font(.system(size: 12, weight: .bold)).foregroundStyle(teinte)
                Spacer()
                Text(message.heure).font(.system(size: 12)).foregroundStyle(SnapPalette.horodatage)
            }
            .padding(.horizontal, 14)
            corps
            if message.deMoi && message.etat != "Ouvert" {
                Text(message.etat)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(SnapPalette.texteStatut)
                    .padding(.horizontal, 14)
            }
        }
    }

    @ViewBuilder
    private var corps: some View {
        if let s = message.sticker {
            Text(s).font(.system(size: 54)).padding(.horizontal, 22).padding(.vertical, 2)
        } else if let cle = message.imageCle {
            HStack(spacing: 0) {
                Rectangle().fill(teinte).frame(width: 2.5)
                SnapImage(cle: cle, teinte1: 0x8A8F98, teinte2: 0x4A4E55)
                    .frame(width: 140, height: 180)
                Spacer(minLength: 0)
            }
            .background(SnapPalette.fondMessage)
        } else {
            HStack(spacing: 0) {
                Rectangle().fill(teinte).frame(width: 2.5)
                Text(message.texte)
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
                    .padding(.leading, 10).padding(.vertical, 7)
                Spacer(minLength: 0)
            }
            .background(SnapPalette.fondMessage)
        }
    }
}

/// Composeur d'e014 réduit à trois commandes réelles : caméra, champ, emoji.
struct SnapComposeur: View {
    @Binding var saisie: String
    let surEnvoyer: () -> Void
    let surCamera: () -> Void
    let surSmiley: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.black)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                )
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); surCamera() }
            champ
            Image(systemName: "face.smiling")
                .font(.system(size: 21))
                .foregroundStyle(.black)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); surSmiley() }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color.white)
    }

    private var champ: some View {
        HStack(spacing: 8) {
            TextField("", text: $saisie,
                      prompt: Text("Envoyer un Chat").foregroundStyle(SnapPalette.placeholder))
                .font(.system(size: 16))
                .foregroundStyle(.black)
                .tint(SnapPalette.rougeMoi)              // e014 : curseur rouge
                .submitLabel(.send)
                .onSubmit { surEnvoyer() }
            if !saisie.isEmpty {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(SnapPalette.bleu)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); surEnvoyer() }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .background(Capsule().strokeBorder(Color(hex: 0xD6D9DE), lineWidth: 1))
    }
}

// ============================================================================
// MARK: - 11. FICHE D'AMI·E (simple — s'ouvre depuis la conversation et depuis la carte)
// ============================================================================

struct SnapFicheAmiVue: View {
    @Environment(\.dismiss) private var dismiss
    let ami: SnapAmi
    let surCarte: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SnapEnTeteFeuille(titre: "Fiche d'ami·e", surFermer: { dismiss() })
            ScrollView {
                VStack(spacing: 0) {
                    identite
                    infos
                    boutonCarte
                }
                .padding(.top, 18)
            }
            Spacer(minLength: 0)
            BarreHome(action: { dismiss() }, sombre: true)
        }
        .background(SnapPalette.fondPage)
        .preferredColorScheme(.light)
    }

    private var identite: some View {
        VStack(spacing: 8) {
            SnapAvatar(emoji: ami.emoji, photo: ami.photo, teinte: ami.teinte, taille: 108)
            Text(ami.nom).font(.system(size: 23, weight: .bold)).foregroundStyle(.black)
            Text("@\(ami.pseudo)").font(.system(size: 15)).foregroundStyle(SnapPalette.texteStatut)
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
    }

    private var infos: some View {
        VStack(spacing: 0) {
            ligne("👻", "Snapscore", "\(ami.score)")
            SnapFilet(marge: 16)
            ligne("🤝", "Amis depuis", ami.amisDepuis)
            SnapFilet(marge: 16)
            ligne("📍", "Position", ami.presence)
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .padding(.horizontal, 16)
    }

    private func ligne(_ emoji: String, _ titre: String, _ valeur: String) -> some View {
        HStack(spacing: 12) {
            Text(emoji).font(.system(size: 15))
            Text(titre).font(.system(size: 16)).foregroundStyle(.black)
            Spacer()
            Text(valeur).font(.system(size: 15)).foregroundStyle(SnapPalette.texteStatut)
        }
        .padding(.horizontal, 14).frame(height: 52)
    }

    private var boutonCarte: some View {
        HStack(spacing: 8) {
            Image(systemName: "map.fill").font(.system(size: 15))
            Text("Voir sur la Snap Map").font(.system(size: 16, weight: .bold))
        }
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity).frame(height: 50)
        .background(Capsule().fill(SnapPalette.jaune))
        .padding(.horizontal, 16).padding(.top, 18)
        .contentShape(Capsule())
        .onTapGesture {
            Haptique.leger()
            dismiss()
            surCarte()
        }
    }
}

// ============================================================================
// MARK: - 12. APPELS (deux écrans simples et DISTINCTS : sonne dans le vide, raccrocher)
// ============================================================================

struct SnapAppelAudioVue: View {
    @Environment(\.dismiss) private var dismiss
    let ami: SnapAmi
    @State private var sansReponse = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x2A2D34), Color(hex: 0x0B0C10)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                SnapAvatar(emoji: ami.emoji, photo: ami.photo, teinte: ami.teinte, taille: 132)
                Text(ami.nom)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 20)
                Text(sansReponse ? "Pas de réponse" : "Sonnerie…")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .padding(.top, 6)
                Text("Appel audio Snapchat")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(SnapPalette.jaune)
                    .padding(.top, 14)
                Spacer()
                boutonRaccrocher
                BarreHome(action: { dismiss() }, sombre: false)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) { sansReponse = true }
        }
        .preferredColorScheme(.dark)
    }

    private var boutonRaccrocher: some View {
        Circle()
            .fill(SnapPalette.rougeAppel)
            .frame(width: 68, height: 68)
            .overlay(
                Image(systemName: "phone.down.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
            )
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); dismiss() }
            .padding(.bottom, 28)
    }
}

struct SnapAppelVideoVue: View {
    @Environment(\.dismiss) private var dismiss
    let ami: SnapAmi
    @State private var sansReponse = false
    @State private var avant = true

    var body: some View {
        ZStack {
            SnapViseur(avant: avant).ignoresSafeArea()
            VStack(spacing: 0) {
                carteCorrespondant
                Spacer()
                barreBasse
                BarreHome(action: { dismiss() }, sombre: false)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) { sansReponse = true }
        }
        .preferredColorScheme(.dark)
    }

    private var carteCorrespondant: some View {
        HStack(spacing: 12) {
            SnapAvatar(emoji: ami.emoji, photo: ami.photo, teinte: ami.teinte, taille: 52)
            VStack(alignment: .leading, spacing: 3) {
                Text(ami.nom).font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                Text(sansReponse ? "Pas de réponse" : "Appel vidéo · sonnerie…")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.85))
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.45)))
        .padding(.horizontal, 14).padding(.top, 14)
    }

    private var barreBasse: some View {
        HStack(spacing: 34) {
            rond("arrow.triangle.2.circlepath", fond: Color.black.opacity(0.45)) { avant.toggle() }
            rond("phone.down.fill", fond: SnapPalette.rougeAppel) { dismiss() }
        }
        .padding(.bottom, 24)
    }

    private func rond(_ glyphe: String, fond: Color, action: @escaping () -> Void) -> some View {
        Circle()
            .fill(fond)
            .frame(width: 64, height: 64)
            .overlay(
                Image(systemName: glyphe)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            )
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); action() }
    }
}

// ============================================================================
// MARK: - 13. CAMÉRA (e001 — viseur + déclencheur + retourner + 2 glyphes fidèles)
// ============================================================================

struct SnapCameraVue: View {
    @Binding var route: SnapRoute?
    @ObservedObject private var etat = SnapEtat.partage
    @State private var avant = false
    @State private var flashCoupe = true
    @State private var eclair = false
    @State private var envoiVisible = false

    var body: some View {
        ZStack {
            SnapViseur(avant: avant, flash: !flashCoupe).ignoresSafeArea()
            if eclair { Color.white.ignoresSafeArea().zIndex(10) }
            VStack(spacing: 0) {
                enTeteEtOutils
                Spacer()
                anneau
                Spacer().frame(height: SnapMesure.hauteurOnglets + 18)
            }
        }
        .fullScreenCover(isPresented: $envoiVisible) { SnapEnvoyerAVue(cleImage: "p12") }
    }

    private var enTeteEtOutils: some View {
        HStack(alignment: .top, spacing: 0) {
            SnapEnTete(titre: "", style: .viseur, sansTitre: true,
                       demandes: etat.demandes.count, notifsNonLues: !etat.notifsLues,
                       surProfil: { route = .profil },
                       surRecherche: { route = .recherche },
                       surCloche: { route = .notifications },
                       surAjout: { route = .demandes })
            colonneOutils.padding(.trailing, 12).padding(.top, 8)
        }
    }

    /// Deux glyphes seulement, tous deux à effet visible : retournement et flash (e001).
    /// Retirés : note de musique, mode, lune (mode nuit), chevron d'outils, carrousel de Lenses,
    /// onglets de Lenses, AI, Souvenirs (retirés D92 — voir audit/snapchat-lot280.md).
    private var colonneOutils: some View {
        VStack(spacing: 20) {
            outil("arrow.triangle.2.circlepath") { avant.toggle() }
            outil(flashCoupe ? "bolt.slash.fill" : "bolt.fill") { flashCoupe.toggle() }
        }
    }

    private func outil(_ glyphe: String, action: @escaping () -> Void) -> some View {
        Image(systemName: glyphe)
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 36, height: 30)
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); action() }
    }

    private var anneau: some View {
        Circle()
            .strokeBorder(Color.white, lineWidth: 5)
            .frame(width: SnapMesure.anneauCapture, height: SnapMesure.anneauCapture)
            .contentShape(Circle())
            .onTapGesture { capturer() }
    }

    private func capturer() {
        Haptique.leger()
        withAnimation(.easeOut(duration: 0.1)) { eclair = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation { eclair = false }
            envoiVisible = true
        }
    }
}

/// Caméra ouverte depuis une conversation : viseur, fermer, retourner, déclencheur.
/// La capture part DIRECTEMENT dans le fil de la conversation.
struct SnapCameraChatVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    let ami: SnapAmi
    @State private var avant = false
    @State private var eclair = false

    var body: some View {
        ZStack {
            SnapViseur(avant: avant).ignoresSafeArea()
            if eclair { Color.white.ignoresSafeArea().zIndex(10) }
            VStack(spacing: 0) {
                barreHaute
                Spacer()
                Text("Snap à \(ami.prenom)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(Capsule().fill(Color.black.opacity(0.4)))
                    .padding(.bottom, 16)
                anneau
                BarreHome(action: { dismiss() }, sombre: false)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var barreHaute: some View {
        HStack {
            rond("xmark") { dismiss() }
            Spacer()
            rond("arrow.triangle.2.circlepath") { avant.toggle() }
        }
        .padding(.horizontal, 16).padding(.top, 12)
    }

    private func rond(_ glyphe: String, action: @escaping () -> Void) -> some View {
        Circle()
            .fill(Color.black.opacity(0.4))
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: glyphe)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            )
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); action() }
    }

    private var anneau: some View {
        Circle()
            .strokeBorder(Color.white, lineWidth: 5)
            .frame(width: SnapMesure.anneauCapture, height: SnapMesure.anneauCapture)
            .contentShape(Circle())
            .onTapGesture { capturer() }
            .padding(.bottom, 14)
    }

    private func capturer() {
        Haptique.leger()
        withAnimation(.easeOut(duration: 0.1)) { eclair = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            etat.envoyerSnap(a: ami.id, cle: "p12")
            dismiss()
        }
    }
}

/// « Envoyer à… » simple : sélection, envoi RÉEL dans les conversations choisies.
struct SnapEnvoyerAVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    let cleImage: String
    @State private var choisis: Set<String> = []

    private var destinataires: [SnapAmi] { etat.amis.filter { !$0.systeme } }

    var body: some View {
        VStack(spacing: 0) {
            SnapEnTeteFeuille(titre: "Envoyer à…", surFermer: { dismiss() })
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(destinataires) { a in
                        ligne(a)
                    }
                    Spacer(minLength: 40)
                }
            }
            if !choisis.isEmpty { boutonEnvoyer }
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }

    private func ligne(_ a: SnapAmi) -> some View {
        let choisi = choisis.contains(a.id)
        return HStack(spacing: 12) {
            SnapAvatar(emoji: a.emoji, photo: a.photo, teinte: a.teinte, taille: 40)
            Text(a.nom).font(.system(size: 15, weight: .medium)).foregroundStyle(.black)
            Spacer()
            Image(systemName: choisi ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 21))
                .foregroundStyle(choisi ? SnapPalette.bleu : Color(hex: 0xC7CAD1))
        }
        .padding(.horizontal, 16).frame(height: 56)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptique.leger()
            if choisi { choisis.remove(a.id) } else { choisis.insert(a.id) }
        }
    }

    private var boutonEnvoyer: some View {
        HStack {
            Text("\(choisis.count) destinataire\(choisis.count > 1 ? "s" : "")")
                .font(.system(size: 14, weight: .semibold)).foregroundStyle(.black)
            Spacer()
            HStack(spacing: 7) {
                Text("Envoyer").font(.system(size: 15, weight: .bold))
                Image(systemName: "paperplane.fill").font(.system(size: 14))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 18).padding(.vertical, 11)
            .background(Capsule().fill(SnapPalette.jaune))
            .contentShape(Capsule())
            .onTapGesture { envoyer() }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Color.white)
    }

    private func envoyer() {
        Haptique.leger()
        for id in choisis { etat.envoyerSnap(a: id, cle: cleImage) }
        dismiss()
    }
}

// ============================================================================
// MARK: - 14. SNAP MAP (e026) — un avatar par ami·e, tap = recentrer + fiche
// ============================================================================

struct SnapCarteVue: View {
    @Binding var route: SnapRoute?
    @ObservedObject private var etat = SnapEtat.partage

    private static let regionLyon = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.7578, longitude: 4.8320),
        span: MKCoordinateSpan(latitudeDelta: 0.030, longitudeDelta: 0.030))

    @State private var camera: MapCameraPosition = .region(SnapCarteVue.regionLyon)
    @State private var fiche: SnapAmi? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            carte
            VStack(spacing: 0) {
                piluleLieu
                Spacer()
            }
            boutonRecentrer
            rangeeAmis
        }
        .sheet(item: $fiche) { a in
            SnapFicheAmiVue(ami: a, surCarte: { centrerSur(a) })
        }
        .onAppear { ouvrirCible() }
        .onChange(of: etat.demandeCarte) { _, _ in ouvrirCible() }
    }

    // Fond de carte : MapKit sans POI Apple + teinte verte Snapchat (#D7EDC9, audit §2.5)
    private var carte: some View {
        Map(position: $camera) {
            ForEach(etat.amisSurCarte) { a in
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: a.lat, longitude: a.lon)) {
                    epingle(a)
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .overlay(teinteVerte)
        .ignoresSafeArea()
    }

    private var teinteVerte: some View {
        SnapPalette.carteVert
            .opacity(0.55)
            .blendMode(.multiply)
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }

    /// Un SEUL rendu par ami·e : avatar rond + prénom. Tap = recentrer + petite fiche.
    private func epingle(_ a: SnapAmi) -> some View {
        VStack(spacing: 2) {
            SnapAvatar(emoji: a.emoji, photo: a.photo, teinte: a.teinte, taille: 44)
                .overlay(Circle().strokeBorder(Color.white, lineWidth: 2.5))
                .shadow(color: .black.opacity(0.18), radius: 2, y: 1)
            Text(a.prenom)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 7).padding(.vertical, 3)
                .background(Capsule().fill(Color.white))
        }
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); centrerSur(a); fiche = a }
    }

    /// Étiquette de lieu (e026) — libellé, pas une commande.
    private var piluleLieu: some View {
        HStack(alignment: .top) {
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Lyon 7e").font(.system(size: 21, weight: .bold)).foregroundStyle(.black)
                HStack(spacing: 5) {
                    Image(systemName: "sun.max.fill").font(.system(size: 12))
                    Text("24 °C").font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.black)
            }
        }
        .padding(.horizontal, 14).padding(.top, 8)
    }

    /// Colonne droite réduite au bouton « recentrer sur moi » (retraits D92 : Bitmoji,
    /// engrenage, calques, vue 3D, chips Souvenirs/Tendance/Footsteps/Visité, pilule de stockage).
    private var boutonRecentrer: some View {
        Circle()
            .fill(Color.white)
            .frame(width: SnapMesure.boutonCarte, height: SnapMesure.boutonCarte)
            .overlay(
                Image(systemName: "location.north.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
            )
            .shadow(color: .black.opacity(0.10), radius: 3, y: 1)
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); recentrerSurMoi() }
            .padding(.trailing, 12)
            .padding(.bottom, SnapMesure.hauteurOnglets + 70)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }

    /// Rangée d'amis pleine largeur (e026) — même action que les épingles, pour TOUS les ami·es.
    private var rangeeAmis: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Circle().fill(Color.white)
                    .frame(width: SnapMesure.avatarCarte, height: SnapMesure.avatarCarte)
                    .overlay(
                        Image(systemName: "person.fill.viewfinder")
                            .font(.system(size: 18))
                            .foregroundStyle(.black)
                    )
                    .contentShape(Circle())
                    .onTapGesture { Haptique.leger(); route = .recherche }
                ForEach(etat.amisSurCarte) { a in
                    SnapAvatar(emoji: a.emoji, photo: a.photo, teinte: a.teinte,
                               taille: SnapMesure.avatarCarte)
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                        .contentShape(Circle())
                        .onTapGesture { Haptique.leger(); centrerSur(a); fiche = a }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.bottom, SnapMesure.hauteurOnglets + 14)
    }

    private func recentrerSurMoi() {
        withAnimation(.easeInOut(duration: 0.5)) {
            camera = .region(SnapCarteVue.regionLyon)
        }
    }

    private func centrerSur(_ a: SnapAmi) {
        let coord = CLLocationCoordinate2D(latitude: a.lat, longitude: a.lon)
        withAnimation(.easeInOut(duration: 0.5)) {
            camera = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.010, longitudeDelta: 0.010)))
        }
    }

    /// Recentrage demandé depuis une fiche ouverte ailleurs (conversation, liste d'ami·es).
    /// La demande est consommée : la carte ne se recentre pas indéfiniment sur le même ami·e.
    private func ouvrirCible() {
        guard let cle = etat.cibleCarte else { return }
        etat.cibleCarte = nil
        guard let a = etat.amisSurCarte.first(where: { $0.id == cle }) else { return }
        centrerSur(a)
    }
}

// ============================================================================
// MARK: - 15. STORIES (e052–e053) — rangée Amis·es + quelques cartes Découvrir
// ============================================================================

struct SnapStoriesVue: View {
    @Binding var route: SnapRoute?
    @ObservedObject private var etat = SnapEtat.partage
    @State private var story: SnapStory? = nil

    var body: some View {
        VStack(spacing: 0) {
            SnapEnTete(titre: "Stories", style: .clair, ajoutJaune: false,
                       demandes: etat.demandes.count, notifsNonLues: !etat.notifsLues,
                       surProfil: { route = .profil },
                       surRecherche: { route = .recherche },
                       surCloche: { route = .notifications },
                       surAjout: { route = .demandes })
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    titreSection("Amis·es")
                    rangeeAmis
                    titreSection("Découvrir")
                    grilleDecouvrir
                    Spacer(minLength: SnapMesure.hauteurOnglets + 10)
                }
                .padding(.top, 4)
            }
        }
        .background(Color.white)
        .fullScreenCover(item: $story) { s in SnapVisionneuseVue(story: s) }
    }

    private func titreSection(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 21, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 14)
    }

    private var rangeeAmis: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                boutonAjout
                ForEach(DonneesSnap.storiesAmis) { s in
                    vignetteAmi(s)
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private func vignetteAmi(_ s: SnapStory) -> some View {
        let vue = etat.storiesVues.contains(s.id)
        return VStack(spacing: 5) {
            SnapAvatar(emoji: s.emoji, teinte: s.teinte, taille: 62)
                .overlay(anneau(vue: vue))
                .frame(height: 70)
            Text(s.nom).font(.system(size: 13, weight: .bold)).foregroundStyle(.black).lineLimit(1)
            Text(s.accroche).font(.system(size: 11.5)).foregroundStyle(SnapPalette.texteStatut).lineLimit(1)
        }
        .frame(width: 86)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); story = s }
    }

    private func anneau(vue: Bool) -> some View {
        Circle().strokeBorder(
            LinearGradient(colors: vue ? [Color(hex: 0xD3D6DC), Color(hex: 0xD3D6DC)]
                                       : [SnapPalette.anneauStory, SnapPalette.anneauStory2],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            lineWidth: 3)
    }

    private var boutonAjout: some View {
        VStack(spacing: 5) {
            Circle().fill(SnapPalette.cercleEnTete).frame(width: 62, height: 62)
                .overlay(
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 24))
                        .foregroundStyle(.black)
                )
                .frame(height: 70)
            Text("Ajouter").font(.system(size: 13, weight: .bold)).foregroundStyle(.black)
        }
        .frame(width: 86)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); route = .demandes }
    }

    /// Découvrir : 4 cartes, toutes ouvrables. Retirés : tuiles sponsorisées + bouton
    /// « Installer », icône d'abonnement « OO », double registre de tailles (D92).
    private var grilleDecouvrir: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 9), GridItem(.flexible(), spacing: 9)],
                  spacing: 9) {
            ForEach(DonneesSnap.decouvrir) { d in
                tuile(d)
            }
        }
        .padding(.horizontal, 14)
    }

    private func tuile(_ d: SnapStory) -> some View {
        ZStack(alignment: .bottomLeading) {
            SnapImage(cle: d.imageCle, teinte1: d.fond, teinte2: 0x0C0E12)
                .frame(height: 250)
            LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text(d.nom).font(.system(size: 16, weight: .bold)).foregroundStyle(.white).lineLimit(2)
                Text(d.accroche).font(.system(size: 12)).foregroundStyle(Color.white.opacity(0.85))
            }
            .padding(10)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); story = d }
    }
}

/// Visionneuse simple : progression, auteur, contenu, fermeture. Ni caméra, ni like,
/// ni commentaire, ni partage (alignée sur la consigne Instagram des retours 279).
struct SnapVisionneuseVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    let story: SnapStory
    @State private var progression: CGFloat = 0.02
    private let minuteur = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                barreProgression
                contenu
                BarreHome(action: { dismiss() }, sombre: false)
            }
        }
        .onAppear { etat.marquerStoryVue(story.id) }
        .onReceive(minuteur) { _ in
            if progression < 1 { progression += 0.0022 } else { dismiss() }
        }
        .preferredColorScheme(.dark)
    }

    private var barreProgression: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.30)).frame(height: 2.5)
                Capsule().fill(Color.white).frame(width: geo.size.width * progression, height: 2.5)
            }
        }
        .frame(height: 2.5)
        .padding(.horizontal, 8).padding(.top, 6)
    }

    private var contenu: some View {
        ZStack(alignment: .top) {
            SnapImage(cle: story.imageCle, teinte1: story.fond, teinte2: 0x0A0C10)
            LinearGradient(colors: [.black.opacity(0.4), .clear], startPoint: .top, endPoint: .center)
            entete
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 4).padding(.top, 6)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); progression = min(progression + 0.3, 0.999) }
    }

    private var entete: some View {
        HStack(spacing: 10) {
            SnapAvatar(emoji: story.emoji, teinte: story.teinte, taille: 34)
            VStack(alignment: .leading, spacing: 1) {
                Text(story.nom).font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                Text(story.accroche).font(.system(size: 12)).foregroundStyle(Color.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "xmark")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); dismiss() }
        }
        .padding(.horizontal, 12).padding(.top, 12)
    }
}

// ============================================================================
// MARK: - 16. SPOTLIGHT (e075) — fil vertical de 4 cartes, cœur qui incrémente
// ============================================================================

struct SnapSpotlightVue: View {
    @Binding var route: SnapRoute?
    @ObservedObject private var etat = SnapEtat.partage

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                GeometryReader { geo in
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 0) {
                            ForEach(DonneesSnap.spots) { s in
                                SnapCartePage(spot: s)
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.hidden)
                }
                Spacer().frame(height: SnapMesure.hauteurOnglets)
            }
            enTete
        }
    }

    private var enTete: some View {
        SnapEnTete(titre: "Spotlight", style: .sombre,
                   demandes: etat.demandes.count, notifsNonLues: !etat.notifsLues,
                   surProfil: { route = .profil },
                   surRecherche: { route = .recherche },
                   surCloche: { route = .notifications },
                   surAjout: { route = .demandes })
    }
}

/// Une carte de Spotlight. Rail réduit au cœur (retirés D92 : ampoule Lens, commentaires,
/// boucles, partage, ••• et vignette musicale — tous sans destination réelle).
struct SnapCartePage: View {
    let spot: SnapSpot
    @ObservedObject private var etat = SnapEtat.partage

    private var aime: Bool { etat.aimes.contains(spot.id) }
    private var coeurs: Int { etat.coeurs[spot.id] ?? spot.coeurs }

    var body: some View {
        VStack(spacing: 0) {
            zoneVideo
            bandeauBas
        }
        .background(Color.black)
    }

    private var zoneVideo: some View {
        ZStack {
            SnapImage(cle: spot.imageCle, teinte1: spot.teinte1, teinte2: spot.teinte2)
            Color.black.opacity(0.12)
            VStack {
                Spacer().frame(height: 58)
                Spacer()
                HStack(alignment: .bottom) {
                    Spacer()
                    coeur
                }
                .padding(.horizontal, 14)
                sousTitres
            }
        }
        .clipped()
    }

    // Sous-titres incrustés — signature visuelle relevée sur ~40 frames
    private var sousTitres: some View {
        Text(spot.soustitre)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.8), radius: 3)
            .padding(.horizontal, 26).padding(.bottom, 16)
    }

    private var coeur: some View {
        VStack(spacing: 4) {
            Image(systemName: aime ? "heart.fill" : "heart")
                .font(.system(size: 30))
                .foregroundStyle(aime ? SnapPalette.rougeMoi : Color.white)
            Text(SnapEtat.nombre(coeurs))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); etat.basculerCoeur(spot.id) }
    }

    // Bandeau NOIR #010008 hors vidéo (e075)
    private var bandeauBas: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(spot.auteur).font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
            HStack(spacing: 5) {
                Image(systemName: "music.note").font(.system(size: 11))
                Text(spot.son).font(.system(size: 13))
            }
            .foregroundStyle(Color.white.opacity(0.92))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 12)
        .background(SnapPalette.bandeauSpot)
    }
}

// ============================================================================
// MARK: - 17. PROFIL (e112–e114) — simple et lisible
// ============================================================================

struct SnapProfilVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    @State private var route: SnapRoute? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            SnapPalette.fondPage.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    hero
                    corps
                    Spacer(minLength: 70)
                }
            }
            BarreHome(action: { dismiss() }, sombre: true)
        }
        .fullScreenCover(item: $route) { r in SnapRouteVue(route: r) }
        .onChange(of: etat.demandeCarte) { _, _ in dismiss() }
        .preferredColorScheme(.light)
    }

    // ————— Héros vert #1AB64B → noir (e114), avatar VISIBLE, nom, pseudo, score
    private var hero: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [SnapPalette.heroProfil, .black], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 0) {
                barreHero
                Spacer(minLength: 6)
                SnapAvatarMoi(taille: 118)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.85), lineWidth: 3))
                Text(DonneesSnap.moiNom)
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 12)
                Text("@\(DonneesSnap.moiPseudo)")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .padding(.top, 2)
                puceScore
            }
            .padding(.bottom, 18)
        }
        .frame(height: 340)
    }

    /// Seule commande de l'en-tête : le retour. Retirés (retours 279) : Partager/Snapcode,
    /// engrenage de réglages, crayon de modification, capsules « Mon compte / Profil public ».
    private var barreHero: some View {
        HStack {
            Circle().fill(Color.white.opacity(0.16)).frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                )
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); dismiss() }
            Spacer()
        }
        .padding(.horizontal, 14).padding(.top, 8)
    }

    private var puceScore: some View {
        HStack(spacing: 7) {
            Text("👻").font(.system(size: 14))
            Text("\(DonneesSnap.moiScore)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Capsule().fill(Color.white))
        .padding(.top, 14)
    }

    private var corps: some View {
        VStack(alignment: .leading, spacing: 12) {
            titre("Amis·es")
            carteAmis
            titre("Stories")
            carteStories
        }
        .padding(.top, 18)
    }

    private func titre(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
    }

    /// Chaque compteur affiché correspond au nombre réel d'éléments de la liste ouverte.
    private var carteAmis: some View {
        VStack(spacing: 0) {
            ligne(glyphe: "person.2.fill", titre: "Mes amis·es",
                  valeur: "\(etat.amisReels.count)", bleu: false) { route = .mesAmis }
            SnapFilet(marge: 16)
            ligne(glyphe: "star.fill", titre: "Meilleurs amis",
                  valeur: "\(etat.meilleursAmis.count)", bleu: false) { route = .meilleursAmis }
            SnapFilet(marge: 16)
            ligne(glyphe: "person.badge.plus", titre: "Ajouter des amis·es",
                  valeur: "\(etat.demandes.count)", bleu: true) { route = .demandes }
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .padding(.horizontal, 16)
    }

    private var carteStories: some View {
        VStack(spacing: 0) {
            ligne(glyphe: "play.circle.fill", titre: "Ma Story",
                  valeur: "1", bleu: false) { route = .maStory }
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .padding(.horizontal, 16)
    }

    private func ligne(glyphe: String, titre: String, valeur: String, bleu: Bool,
                       action: @escaping () -> Void) -> some View {
        HStack(spacing: 14) {
            Image(systemName: glyphe).font(.system(size: 18)).foregroundStyle(.black).frame(width: 26)
            Text(titre).font(.system(size: 16.5, weight: .semibold)).foregroundStyle(.black)
            Spacer()
            Text(valeur)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(bleu ? Color.white : SnapPalette.texteStatut)
                .padding(.horizontal, bleu ? 11 : 0).padding(.vertical, bleu ? 4 : 0)
                .background(pastille(bleu))
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(SnapPalette.texteStatut)
        }
        .padding(.horizontal, 14).frame(height: 58)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); action() }
    }

    @ViewBuilder
    private func pastille(_ bleu: Bool) -> some View {
        if bleu { Capsule().fill(SnapPalette.bleuProfil) } else { Color.clear }
    }
}

// ============================================================================
// MARK: - 18. LISTES D'AMI·ES, DEMANDES, RECHERCHE, NOTIFICATIONS, NOUVEAU CHAT
// ============================================================================

/// « Mes amis·es » et « Meilleurs amis » : le nombre annoncé = le nombre de lignes.
struct SnapListeAmisVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    let titre: String
    let meilleurs: Bool
    @State private var conversation: SnapAmi? = nil
    @State private var fiche: SnapAmi? = nil

    private var liste: [SnapAmi] { meilleurs ? etat.meilleursAmis : etat.amisReels }

    var body: some View {
        VStack(spacing: 0) {
            SnapEnTeteFeuille(titre: "\(titre) · \(liste.count)", surFermer: { dismiss() })
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(liste) { a in
                        ligne(a)
                        SnapFilet(marge: 16)
                    }
                    Spacer(minLength: 30)
                }
            }
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .fullScreenCover(item: $conversation) { a in SnapConversationVue(ami: a) }
        .sheet(item: $fiche) { a in
            SnapFicheAmiVue(ami: a, surCarte: { etat.demanderCarte(a.id) })
        }
        .onChange(of: etat.demandeCarte) { _, _ in dismiss() }
        .preferredColorScheme(.light)
    }

    private func ligne(_ a: SnapAmi) -> some View {
        HStack(spacing: 12) {
            SnapAvatar(emoji: a.emoji, photo: a.photo, teinte: a.teinte, taille: 44)
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); fiche = a }
            VStack(alignment: .leading, spacing: 2) {
                Text(a.nom).font(.system(size: 16, weight: .medium)).foregroundStyle(.black)
                Text("@\(a.pseudo)").font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
            }
            Spacer()
            Capsule().fill(SnapPalette.jaune).frame(width: 54, height: 36)
                .overlay(
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                )
                .contentShape(Capsule())
                .onTapGesture { Haptique.leger(); conversation = a }
        }
        .padding(.horizontal, 16).frame(height: 64)
    }
}

/// Demandes d'ami·e : Accepter met l'état à jour PARTOUT (badge, liste Chat, carte, Profil).
struct SnapDemandesVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage

    var body: some View {
        VStack(spacing: 0) {
            SnapEnTeteFeuille(titre: "Ajouter des amis·es", surFermer: { dismiss() })
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if etat.demandes.isEmpty {
                        vide
                    } else {
                        Text("Demandes reçues · \(etat.demandes.count)")
                            .font(.system(size: 15, weight: .bold)).foregroundStyle(.black)
                            .padding(.horizontal, 16).padding(.vertical, 12)
                        ForEach(etat.demandes) { d in
                            ligne(d)
                            SnapFilet(marge: 16)
                        }
                    }
                    Text("Mes amis·es · \(etat.amisReels.count)")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(.black)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    ForEach(etat.amisReels) { a in
                        ligneAmi(a)
                        SnapFilet(marge: 16)
                    }
                    Spacer(minLength: 30)
                }
            }
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }

    private var vide: some View {
        Text("Aucune demande d'ami·e en attente.")
            .font(.system(size: 15))
            .foregroundStyle(SnapPalette.texteStatut)
            .padding(.horizontal, 16).padding(.vertical, 18)
    }

    private func ligne(_ d: SnapDemande) -> some View {
        HStack(spacing: 12) {
            SnapAvatar(emoji: d.emoji, teinte: d.teinte, taille: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(d.nom).font(.system(size: 16, weight: .medium)).foregroundStyle(.black)
                Text(d.origine).font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
            }
            Spacer(minLength: 6)
            Text("Accepter")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.black)
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(Capsule().fill(SnapPalette.jaune))
                .contentShape(Capsule())
                .onTapGesture { Haptique.leger(); etat.accepter(d) }
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(SnapPalette.texteStatut)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.refuser(d) }
        }
        .padding(.horizontal, 16).frame(height: 66)
    }

    private func ligneAmi(_ a: SnapAmi) -> some View {
        HStack(spacing: 12) {
            SnapAvatar(emoji: a.emoji, photo: a.photo, teinte: a.teinte, taille: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(a.nom).font(.system(size: 15.5, weight: .medium)).foregroundStyle(.black)
                Text("@\(a.pseudo)").font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
            }
            Spacer()
            Text("Ami·e")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(SnapPalette.texteStatut)
        }
        .padding(.horizontal, 16).frame(height: 58)
    }
}

struct SnapRechercheVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    @State private var saisie = ""
    @State private var conversation: SnapAmi? = nil

    private var resultats: [SnapAmi] {
        if saisie.isEmpty { return etat.amis }
        return etat.amis.filter {
            $0.nom.localizedCaseInsensitiveContains(saisie)
                || $0.pseudo.localizedCaseInsensitiveContains(saisie)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            barreRecherche
            if resultats.isEmpty {
                Spacer()
                Text("Aucun résultat pour « \(saisie) »")
                    .font(.system(size: 15)).foregroundStyle(SnapPalette.texteStatut)
                Spacer()
            } else {
                liste
            }
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .fullScreenCover(item: $conversation) { a in SnapConversationVue(ami: a) }
        .preferredColorScheme(.light)
    }

    private var barreRecherche: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(SnapPalette.texteStatut)
                    TextField("", text: $saisie,
                              prompt: Text("Rechercher des amis·es").foregroundStyle(SnapPalette.placeholder))
                        .font(.system(size: 16)).foregroundStyle(.black)
                }
                .padding(.horizontal, 13).frame(height: 40)
                .background(Capsule().fill(SnapPalette.cercleEnTete))
                Text("Annuler").font(.system(size: 16, weight: .semibold)).foregroundStyle(.black)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); dismiss() }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            SnapFilet()
        }
    }

    private var liste: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(resultats) { a in
                    HStack(spacing: 12) {
                        SnapAvatar(emoji: a.emoji, photo: a.photo, teinte: a.teinte, taille: 42)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.nom).font(.system(size: 16, weight: .medium)).foregroundStyle(.black)
                            Text("@\(a.pseudo)").font(.system(size: 12.5))
                                .foregroundStyle(SnapPalette.texteStatut)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14).frame(height: 58)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); conversation = a }
                }
            }
        }
    }
}

/// Cloche de l'en-tête : chaque notification ouvre RÉELLEMENT la conversation concernée.
struct SnapNotificationsVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    @State private var conversation: SnapAmi? = nil

    var body: some View {
        VStack(spacing: 0) {
            SnapEnTeteFeuille(titre: "Notifications", surFermer: { dismiss() })
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(DonneesSnap.notifs) { n in
                        ligne(n)
                        SnapFilet(marge: 16)
                    }
                    Spacer(minLength: 30)
                }
            }
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .fullScreenCover(item: $conversation) { a in SnapConversationVue(ami: a) }
        .onAppear { etat.notifsLues = true }        // la pastille de la cloche s'efface ici
        .preferredColorScheme(.light)
    }

    private func ligne(_ n: SnapNotif) -> some View {
        let a = etat.ami(n.idAmi)
        return HStack(spacing: 12) {
            SnapAvatar(emoji: a.emoji, photo: a.photo, teinte: a.teinte, taille: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text(n.texte).font(.system(size: 15)).foregroundStyle(.black).lineLimit(2)
                Text(n.quand).font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
            }
            Spacer(minLength: 6)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); conversation = a }
    }
}

struct SnapNouveauChatVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    @State private var saisie = ""
    @State private var conversation: SnapAmi? = nil

    private var resultats: [SnapAmi] {
        if saisie.isEmpty { return etat.amis }
        return etat.amis.filter { $0.nom.localizedCaseInsensitiveContains(saisie) }
    }

    var body: some View {
        VStack(spacing: 0) {
            SnapEnTeteFeuille(titre: "Nouveau Chat", surFermer: { dismiss() })
            champ
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(resultats) { a in
                        ligne(a)
                        SnapFilet(marge: 16)
                    }
                    Spacer(minLength: 30)
                }
                .padding(.top, 6)
            }
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .fullScreenCover(item: $conversation) { a in SnapConversationVue(ami: a) }
        .preferredColorScheme(.light)
    }

    private var champ: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").font(.system(size: 15))
                .foregroundStyle(SnapPalette.texteStatut)
            TextField("", text: $saisie,
                      prompt: Text("À : nom ou pseudo").foregroundStyle(SnapPalette.placeholder))
                .font(.system(size: 16)).foregroundStyle(.black)
        }
        .padding(.horizontal, 13).frame(height: 40)
        .background(Capsule().fill(SnapPalette.cercleEnTete))
        .padding(.horizontal, 16).padding(.top, 12)
    }

    private func ligne(_ a: SnapAmi) -> some View {
        HStack(spacing: 12) {
            SnapAvatar(emoji: a.emoji, photo: a.photo, teinte: a.teinte, taille: 42)
            Text(a.nom).font(.system(size: 16, weight: .medium)).foregroundStyle(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(SnapPalette.texteStatut)
        }
        .padding(.horizontal, 16).frame(height: 58)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); conversation = a }
    }
}
