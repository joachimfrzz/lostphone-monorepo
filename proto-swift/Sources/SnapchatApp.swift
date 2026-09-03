// Snapchat — v3 D91 (03/09) — reconstruit contre les 114 frames du tournage, mesures audit/snapchat.md
//
// Doctrines appliquées :
//  · D67 — la référence est l'enregistrement du tournage (refs/c2/snapchat/e001…e114, 1 pt = 1,5 px).
//           Chaque écran codé ci-dessous cite les frames qui l'ont servi de modèle.
//  · D82 — aucun bouton mort : chaque commande agit (A), répond par un message crédible (B, rare),
//           ou a été retirée (C). Les retraits sont annotés « (C) » dans le code.
//  · D59 — tout le contenu est celui de Sarah (Lyon). Aucune donnée réelle du téléphone source :
//           les compteurs du Spotlight et le pseudo du son original ont tous été réinventés.
//  · D55 — Bitmoji rendus en émojis, dans l'esprit du réel : silhouette + émoji pour les épingles
//           de la Snap Map (corps entier posé sur la carte), pastille pastel pour les avatars.
//  · Les états jamais filmés (§5 de l'audit) sont implémentés SOBRES, dans les jetons mesurés,
//    et signalés par « TODO tournage : … ».
//
// Point d'entrée public conservé : SnapchatVue() (racine instanciée par la coque, LPProto).
// Registre EcranCapture.ecransSnapchat() mis à jour — voir src/patches/snapchat-lpproto.md.
import SwiftUI
import MapKit

// ============================================================================
// MARK: - 1. JETONS DE STYLE (§2 et §7 de l'audit — relevés au pixel sur les frames)
// ============================================================================

enum SnapPalette {
    static let jaune          = Color(hex: 0xFFFC00)   // e003, e114
    static let rougeBadge     = Color(hex: 0xFF1B3F)   // e003, e005
    static let cercleEnTete   = Color(hex: 0xE7EAF1)   // e003
    static let ongletActif    = Color(hex: 0x252733)   // e005
    static let barreSombre    = Color(hex: 0x1B1B1B)   // e075
    static let bleu           = Color(hex: 0x1CA0F0)   // e003, e014
    static let violetSnap     = Color(hex: 0x9B4DFF)   // e003 (carré contour)
    static let rougeMoi       = Color(hex: 0xE63455)   // e014 « Moi »
    static let fondMessage    = Color(hex: 0xE7EBEE)   // e014 bandeau de bloc
    static let horodatage     = Color(hex: 0x898989)   // e014
    static let texteStatut    = Color(hex: 0x7B7F86)   // e005
    static let carteVert      = Color(hex: 0xD7EDC9)   // e026
    static let carteVertClair = Color(hex: 0xE7F6E3)   // e026
    static let poiOrange      = Color(hex: 0xED5019)   // e026
    static let poiViolet      = Color(hex: 0x8A48CC)   // e026
    static let lavande        = Color(hex: 0xB9A9D6)   // e026 pilule « exploré(s) »
    static let heroProfil     = Color(hex: 0x1AB64B)   // e114
    static let bleuProfil     = Color(hex: 0x00A5FF)   // e114 badge « 1 »
    static let bandeauSpot    = Color(hex: 0x010008)   // e075
    static let fondPage       = Color(hex: 0xF2F2F5)   // e114 fond du Profil
    static let anneauStory    = Color(hex: 0xA435F0)   // e052 contour des anneaux Amis·es
    static let anneauStory2   = Color(hex: 0xE0399B)   // e052 fin du dégradé
    static let noir           = Color(hex: 0x000000)
}

// Mesures constantes (converties des px des frames : 1 pt = 1,5 px)
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
// MARK: - 2. MODÈLE DE DONNÉES (contenu Sarah — D59)
// ============================================================================

/// Pictogrammes de statut relevés en e003 / e005 (§2.3).
enum SnapStatutGenre: Int {
    case recu = 0        // bulle carrée CONTOUR bleue      — « Reçu · 4sem »
    case remis = 1       // triangle PLEIN bleu             — « Remis · 21sem »
    case ouvert = 2      // triangle CONTOUR bleu           — « Ouvert · 167sem »
    case snapViolet = 3  // carré CONTOUR violet            — « Appuyez 2x pour répondre »
    case chatGris = 4    // bulle CONTOUR grise             — « Appuyer pour Chatter »
    case lieu = 5        // épingle CONTOUR grise           — « À proximité · maintenant »
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

/// Accessoire de fin de ligne (e003 : appareil photo contour noir, « × », viseur pour My AI).
enum SnapAccessoire: Int {
    case camera = 0, croix = 1, viseur = 2

    var glyphe: String {
        switch self {
        case .camera: return "camera"
        case .croix:  return "xmark"
        case .viseur: return "dot.viewfinder"
        }
    }
}

struct SnapAmi: Identifiable, Hashable {
    let id: String
    var nom: String
    var pseudo: String
    var emoji: String
    var teinte: UInt
    var statut: String
    var genre: SnapStatutGenre
    var accessoire: SnapAccessoire
    var presence: String            // sous-titre de la conversation (e014 : « À proximité · 1min »)
    var meilleurAmi: Bool = false
    var groupe: Bool = false
    var proche: Bool = false
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

struct SnapDecouverte: Identifiable {
    let id: String
    var titre: String
    var editeur: String
    var accroche: String
    var imageCle: String
    var teinte: UInt
    var sponsorise: Bool = false
}

struct SnapStoryAmi: Identifiable {
    let id: String
    var pseudo: String
    var nom: String
    var emoji: String
    var teinte: UInt
    var nouvelles: Int
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
    var commentaires: Int
    var boucles: Int
    var partages: Int
}

enum DonneesSnap {

    // Sarah Marchand, 24 ans, Lyon 7e. Pseudo cohérent avec le reste du téléphone.
    static let moiNom = "Sarah"
    static let moiPseudo = "sarah.mrchd"
    static let moiEmoji = "👩🏻"
    static let moiTeinte: UInt = 0xFFE9EC
    static let moiStatut = "Lyon, cafés trop chers et playlists trop longues ✨"

    static let amis: [SnapAmi] = [
        SnapAmi(id: "chloe", nom: "Chloé 💛", pseudo: "chloe.brt", emoji: "👩🏻‍🦰", teinte: 0xFFE9EC,
                statut: "À proximité · maintenant", genre: .lieu, accessoire: .camera,
                presence: "À proximité · 1min", meilleurAmi: true, proche: true),
        SnapAmi(id: "sacha", nom: "Sacha Fourez", pseudo: "sachafrz", emoji: "🧑🏻", teinte: 0xE3EEFF,
                statut: "Reçu · 4sem", genre: .recu, accessoire: .camera,
                presence: "À proximité · 1min", meilleurAmi: true, proche: true),
        SnapAmi(id: "ines", nom: "Inès", pseudo: "ines.lyon", emoji: "👩🏽", teinte: 0xEDE7FF,
                statut: "Reçu · 12sem", genre: .recu, accessoire: .camera,
                presence: "Lyon 3e · 2h", meilleurAmi: true),
        SnapAmi(id: "team", nom: "Team Snapchat", pseudo: "teamsnapchat", emoji: "👻", teinte: 0xFFFC00,
                statut: "Appuyez 2x pour répondre", genre: .snapViolet, accessoire: .camera,
                presence: "Officiel"),
        SnapAmi(id: "camille", nom: "Camille", pseudo: "cam.mtt", emoji: "👱🏻‍♀️", teinte: 0xE2F4E8,
                statut: "Remis · 5sem", genre: .remis, accessoire: .croix,
                presence: "Villeurbanne · 40min", meilleurAmi: true),
        SnapAmi(id: "soiree", nom: "Soirée 30 juin", pseudo: "soiree30juin", emoji: "🥂", teinte: 0xFFF3D6,
                statut: "Inès a réagi à un Chat. · 8sem", genre: .recu, accessoire: .camera,
                presence: "6 participants", groupe: true),
        SnapAmi(id: "thomas", nom: "Thomas", pseudo: "tom.brl", emoji: "👨🏻", teinte: 0xE3EEFF,
                statut: "Appuyer pour Chatter", genre: .chatGris, accessoire: .camera,
                presence: "Lyon 6e · 5h"),
        SnapAmi(id: "lea", nom: "Léa 🌻", pseudo: "lea.trn", emoji: "👩🏼", teinte: 0xFDEBDD,
                statut: "Ouvert · 17sem", genre: .ouvert, accessoire: .camera,
                presence: "Oullins · hier"),
        SnapAmi(id: "myai", nom: "My AI", pseudo: "myai", emoji: "🤖", teinte: 0xF0E4FF,
                statut: "Jouer à un jeu de culture générale ?", genre: .aucun, accessoire: .viseur,
                presence: "Toujours disponible"),
        SnapAmi(id: "brunch", nom: "Brunch dimanche", pseudo: "brunchdimanche", emoji: "🥐", teinte: 0xFFF0E2,
                statut: "Camille a réagi à un Chat. · 3sem", genre: .recu, accessoire: .camera,
                presence: "4 participants", groupe: true),
        SnapAmi(id: "manon", nom: "Manon", pseudo: "manon.dcx", emoji: "👩🏾", teinte: 0xE8F0FF,
                statut: "Lyon 7e, Rhône · 1h", genre: .lieu, accessoire: .croix,
                presence: "Lyon 7e · 1h", proche: true),
        SnapAmi(id: "nassim", nom: "Nassim", pseudo: "nssm.k", emoji: "🧔🏽", teinte: 0xE7F1E9,
                statut: "Remis · 21sem", genre: .remis, accessoire: .croix,
                presence: "Vaulx-en-Velin · 3j"),
    ]

    static func ami(_ cle: String) -> SnapAmi {
        amis.first(where: { $0.id == cle }) ?? amis[0]
    }

    /// Un fil DISTINCT par ami (l'audit §3.3 reprochait le même dialogue partout).
    static let filsInitiaux: [String: [SnapMessage]] = [
        "chloe": [
            SnapMessage(deMoi: false, texte: "Tu es encore au parc ? je passe 😄", heure: "12:02", etat: "Ouvert"),
            SnapMessage(deMoi: true, texte: "Ouiii je suis vers la grande serre", heure: "12:04", etat: "Remis"),
            SnapMessage(deMoi: false, texte: "", heure: "12:06", etat: "Ouvert", sticker: "🌻"),
        ],
        "sacha": [
            SnapMessage(deMoi: false, texte: "Tu les donneras à ta copine plutôt", heure: "12:47", etat: "Ouvert"),
            SnapMessage(deMoi: true, texte: "Vazy on fait comme ça", heure: "12:49", etat: "Remis"),
            SnapMessage(deMoi: true, texte: "", heure: "12:50", etat: "Remis", sticker: "🕺"),
            SnapMessage(deMoi: false, texte: "Tu peux m'envoyer la photo de Vanda stp", heure: "12:23", etat: "Ouvert"),
            SnapMessage(deMoi: true, texte: "", heure: "12:33", etat: "Remis", imageCle: "p24"),
        ],
        "ines": [
            SnapMessage(deMoi: false, texte: "On se fait la Croix-Rousse samedi ?", heure: "18:12", etat: "Ouvert"),
            SnapMessage(deMoi: true, texte: "Carrément, on part de chez toi ?", heure: "18:20", etat: "Remis"),
            SnapMessage(deMoi: false, texte: "Ça marche, 14h 🙌", heure: "18:22", etat: "Ouvert"),
        ],
        "team": [
            SnapMessage(deMoi: false, texte: "Bienvenue sur Snapchat ! Appuyez 2x pour répondre 👻", heure: "09:00", etat: "Ouvert"),
        ],
        "camille": [
            SnapMessage(deMoi: true, texte: "Tu as récupéré ma veste chez Léa ?", heure: "21:03", etat: "Remis"),
            SnapMessage(deMoi: false, texte: "Oui elle est chez moi, passe quand tu veux", heure: "21:11", etat: "Ouvert"),
        ],
        "soiree": [
            SnapMessage(deMoi: false, texte: "On dit 20h chez Inès pour l'apéro", heure: "17:40", etat: "Ouvert"),
            SnapMessage(deMoi: true, texte: "Je ramène les tartes 🥧", heure: "17:44", etat: "Remis"),
            SnapMessage(deMoi: false, texte: "Parfait, j'amène la sono", heure: "17:52", etat: "Ouvert"),
        ],
        "thomas": [
            SnapMessage(deMoi: false, texte: "Salut ! toujours partante pour la rando ?", heure: "10:15", etat: "Ouvert"),
        ],
        "lea": [
            SnapMessage(deMoi: true, texte: "Trop belle la photo du quai 🌇", heure: "08:30", etat: "Ouvert"),
            SnapMessage(deMoi: false, texte: "Merci !! c'était dimanche matin", heure: "08:41", etat: "Ouvert"),
        ],
        "myai": [
            SnapMessage(deMoi: false, texte: "Salut Sarah ! Jouer à un jeu de culture générale ?", heure: "11:20", etat: "Ouvert"),
        ],
        "brunch": [
            SnapMessage(deMoi: false, texte: "Réservation confirmée pour 4 à 11h30", heure: "19:05", etat: "Ouvert"),
        ],
        "manon": [
            SnapMessage(deMoi: false, texte: "Je suis dans ton quartier, un café ?", heure: "15:02", etat: "Ouvert"),
        ],
        "nassim": [
            SnapMessage(deMoi: true, texte: "Bien reçu pour dimanche 👍", heure: "13:58", etat: "Remis"),
        ],
    ]

    /// Registre horizontal de Découvrir (tuiles étroites 119×193 pt — e052 r1).
    static let decouvrirRangee: [SnapDecouverte] = [
        SnapDecouverte(id: "d1", titre: "Le pont de la Guillotière rouvre enfin", editeur: "Lyon Capitale",
                       accroche: "3 min de lecture", imageCle: "p36", teinte: 0x2C6EBF),
        SnapDecouverte(id: "d2", titre: "Ils testent la meilleure praline de la ville", editeur: "Croqu'Lyon",
                       accroche: "Épisode 12", imageCle: "p33", teinte: 0xE8557A),
        SnapDecouverte(id: "d3", titre: "Bouchon ou piège à touristes ?", editeur: "Table Ronde",
                       accroche: "Nouveau", imageCle: "p39", teinte: 0xC7883A),
        SnapDecouverte(id: "d4", titre: "La vérité sur les colocs lyonnaises", editeur: "Studio 69",
                       accroche: "Série", imageCle: "p28", teinte: 0x3D3A6B),
    ]

    /// Grille 2 colonnes de grandes tuiles (195×320 pt — e053 r2).
    static let decouvrirGrille: [SnapDecouverte] = [
        SnapDecouverte(id: "g1", titre: "« Elle a repeint tout l'appart en une nuit »", editeur: "Caméléon",
                       accroche: "Épisode du jour", imageCle: "p24", teinte: 0x9B4DFF),
        SnapDecouverte(id: "g2", titre: "Deviens la reine du potager urbain", editeur: "Verger",
                       accroche: "Sponsorisé", imageCle: "p33", teinte: 0x1F6B3A, sponsorise: true),
        SnapDecouverte(id: "g3", titre: "Les secrets des traboules", editeur: "Lyon Secret",
                       accroche: "6 min", imageCle: "p36", teinte: 0x1F4C81),
        SnapDecouverte(id: "g4", titre: "Astro : ta semaine, sans filtre", editeur: "Astro du jour",
                       accroche: "Hebdo", imageCle: "p39", teinte: 0x6C3DBF),
    ]

    static let storiesAmis: [SnapStoryAmi] = [
        SnapStoryAmi(id: "s1", pseudo: "chloe.brt", nom: "Chloé 💛", emoji: "👩🏻‍🦰", teinte: 0xFFE9EC, nouvelles: 3),
        SnapStoryAmi(id: "s2", pseudo: "ines.lyon", nom: "Inès", emoji: "👩🏽", teinte: 0xEDE7FF, nouvelles: 1),
        SnapStoryAmi(id: "s3", pseudo: "cam.mtt", nom: "Camille", emoji: "👱🏻‍♀️", teinte: 0xE2F4E8, nouvelles: 5),
        SnapStoryAmi(id: "s4", pseudo: "lea.trn", nom: "Léa 🌻", emoji: "👩🏼", teinte: 0xFDEBDD, nouvelles: 2),
        SnapStoryAmi(id: "s5", pseudo: "tom.brl", nom: "Thomas", emoji: "👨🏻", teinte: 0xE3EEFF, nouvelles: 1),
    ]

    /// Fil Spotlight — compteurs et pseudos INVENTÉS (ceux du téléphone source ont été retirés, D59).
    static let spots: [SnapSpot] = [
        SnapSpot(id: "sp1", auteur: "lyon.insolite", son: "Son original · lyon.insolite",
                 soustitre: "et là, il te sort qu'il connaît pas les traboules",
                 imageCle: "p36", teinte1: 0x18324F, teinte2: 0x060A12,
                 coeurs: 1284, commentaires: 96, boucles: 37, partages: 58),
        SnapSpot(id: "sp2", auteur: "chloe.brt", son: "Son original · chloe.brt",
                 soustitre: "trois heures de queue pour CE sandwich",
                 imageCle: "p33", teinte1: 0x4A2231, teinte2: 0x0B0508,
                 coeurs: 612, commentaires: 41, boucles: 22, partages: 19),
        SnapSpot(id: "sp3", auteur: "rhone.matin", son: "Son original · rhone.matin",
                 soustitre: "le brouillard sur la Saône à 6h, personne n'y croit",
                 imageCle: "p39", teinte1: 0x1E3B33, teinte2: 0x05100C,
                 coeurs: 3907, commentaires: 214, boucles: 88, partages: 176),
        SnapSpot(id: "sp4", auteur: "camille.mtt", son: "Son original · camille.mtt",
                 soustitre: "ma coloc a rangé le frigo par couleur",
                 imageCle: "p28", teinte1: 0x2E2350, teinte2: 0x090615,
                 coeurs: 845, commentaires: 73, boucles: 31, partages: 44),
        SnapSpot(id: "sp5", auteur: "ines.lyon", son: "Son original · ines.lyon",
                 soustitre: "on a retrouvé le meilleur spot de la Croix-Rousse",
                 imageCle: "p24", teinte1: 0x3A2A18, teinte2: 0x0D0805,
                 coeurs: 2160, commentaires: 128, boucles: 54, partages: 97),
    ]

    /// Vignettes du carrousel de Lenses (e001) — libellé + émoji + teinte.
    static let lenses: [(String, String, UInt)] = [
        ("Pour vous", "✨", 0xFFB4C6),
        ("Chien", "🐶", 0xB4D8FF),
        ("Vintage", "📼", 0xE0C9A6),
        ("Néon", "💜", 0xC7B4FF),
        ("Miroir", "🪞", 0xB9E7D6),
        ("Été", "🌴", 0xFFE39B),
    ]

    static let ongletsLenses = ["Récents", "Favoris", "Pour vous", "Rentrée", "Essayer"]

    // ————— Accesseurs de CAPTURE (D63) : jamais optionnels, jamais d'indice nu.
    /// Conversation d'e014 (« Sacha Fourez »).
    static func convCapture() -> SnapAmi { ami("sacha") }
    /// Carte Découvrir ouverte par la visionneuse (e055–e062).
    static func decouvrirCapture() -> SnapDecouverte {
        decouvrirGrille.first(where: { $0.id == "g3" }) ?? decouvrirGrille[0]
    }
    /// Story d'ami·e (jamais filmée : registre Snapchat, pas le composant Instagram).
    static func storyCapture() -> SnapDecouverte {
        let s = storiesAmis.first ?? SnapStoryAmi(id: "s1", pseudo: "chloe.brt", nom: "Chloé 💛",
                                                  emoji: "👩🏻‍🦰", teinte: 0xFFE9EC, nouvelles: 3)
        return SnapDecouverte(id: s.id, titre: s.nom, editeur: s.pseudo,
                              accroche: "Story · il y a 3 h", imageCle: "p12", teinte: 0x9B4DFF)
    }
}

// ============================================================================
// MARK: - 3. ÉTAT PARTAGÉ (@Published — tout ce qui bouge dans l'app)
// ============================================================================

final class SnapEtat: ObservableObject {
    static let partage = SnapEtat()

    @Published var fils: [String: [SnapMessage]] = DonneesSnap.filsInitiaux
    @Published var coeurs: [String: Int] = [:]
    @Published var aimes: Set<String> = []
    @Published var abonnements: Set<String> = []      // éditeurs Découvrir suivis
    @Published var amisAjoutes: Set<String> = []
    @Published var demandesRestantes: Int = 47
    @Published var derniersSnapsEnvoyes: [String] = []

    init() {
        var c: [String: Int] = [:]
        for s in DonneesSnap.spots { c[s.id] = s.coeurs }
        coeurs = c
    }

    func envoyer(_ texte: String, a idAmi: String) {
        let t = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return }
        var fil = fils[idAmi] ?? []
        fil.append(SnapMessage(deMoi: true, texte: t, heure: SnapEtat.heureCourante(), etat: "Envoi…"))
        fils[idAmi] = fil
        let index = fil.count - 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            guard let self else { return }
            guard var f = self.fils[idAmi], index < f.count else { return }
            f[index].etat = "Remis"
            self.fils[idAmi] = f
        }
    }

    func envoyerSnap(a idAmi: String, cle: String) {
        var fil = fils[idAmi] ?? []
        fil.append(SnapMessage(deMoi: true, texte: "", heure: SnapEtat.heureCourante(), etat: "Envoi…", imageCle: cle))
        fils[idAmi] = fil
        let index = fil.count - 1
        derniersSnapsEnvoyes.append(idAmi)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            guard let self else { return }
            guard var f = self.fils[idAmi], index < f.count else { return }
            f[index].etat = "Remis"
            self.fils[idAmi] = f
        }
    }

    func basculerCoeur(_ idSpot: String) {
        if aimes.contains(idSpot) {
            aimes.remove(idSpot)
            coeurs[idSpot] = max(0, (coeurs[idSpot] ?? 1) - 1)
        } else {
            aimes.insert(idSpot)
            coeurs[idSpot] = (coeurs[idSpot] ?? 0) + 1
        }
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

/// Avatar Bitmoji « à la maison » (D55) : émoji sur aplat pastel, décor de fond léger comme le réel.
struct SnapAvatar: View {
    let emoji: String
    let teinte: UInt
    var taille: CGFloat = 45
    var body: some View {
        ZStack {
            Circle().fill(Color(hex: teinte))
            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: taille * 0.92, height: taille * 0.42)
                .offset(y: taille * 0.30)
            Text(emoji).font(.system(size: taille * 0.54))
        }
        .frame(width: taille, height: taille)
        .clipShape(Circle())
    }
}

/// Bitmoji « corps entier » posé sur la carte (e026) — silhouette + émoji (D55).
struct SnapSilhouette: View {
    let emoji: String
    let teinte: UInt
    var taille: CGFloat = 46
    var body: some View {
        VStack(spacing: -taille * 0.10) {
            Text(emoji).font(.system(size: taille * 0.60))
            Capsule()
                .fill(Color(hex: teinte))
                .frame(width: taille * 0.58, height: taille * 0.62)
            Capsule()
                .fill(Color(hex: teinte).opacity(0.85))
                .frame(width: taille * 0.42, height: taille * 0.20)
        }
        .frame(width: taille, height: taille * 1.35)
        .shadow(color: .black.opacity(0.18), radius: 2, y: 1)
    }
}

/// Petite pastille rouge (badge numérique) — #FF1B3F (§7).
struct SnapBadge: View {
    let texte: String
    var teinte: Color = SnapPalette.rougeBadge
    var body: some View {
        Text(texte)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(Capsule().fill(teinte))
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

// ————— Alerte iOS crédible (D82, cas B — usage rare)
struct SnapAlerteMod: ViewModifier {
    @Binding var message: String?
    func body(content: Content) -> some View {
        let visible = Binding<Bool>(get: { message != nil }, set: { if !$0 { message = nil } })
        return content.alert("Snapchat", isPresented: visible) {
            Button("OK", role: .cancel) { message = nil }
        } message: {
            Text(message ?? "")
        }
    }
}

extension View {
    func snapAlerte(_ message: Binding<String?>) -> some View {
        modifier(SnapAlerteMod(message: message))
    }
}

// ————— Feuille sobre : structure d'un écran jamais filmé (§5). Registre Snapchat, pas iOS générique.
struct SnapFeuilleSobre: View {
    @Environment(\.dismiss) private var dismiss
    let titre: String
    var sousTitre: String = ""
    var lignes: [String] = []
    var note: String = ""

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(lignes.enumerated()), id: \.offset) { _, l in
                        HStack {
                            Text(l).font(.system(size: 15)).foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(SnapPalette.texteStatut)
                        }
                        .padding(.horizontal, 18).padding(.vertical, 14)
                        Rectangle().fill(Color(hex: 0xEFEFF3)).frame(height: 0.5).padding(.leading, 18)
                    }
                    if !note.isEmpty {
                        Text(note)
                            .font(.system(size: 12.5))
                            .foregroundStyle(SnapPalette.texteStatut)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28).padding(.top, 22)
                    }
                }
            }
            Spacer(minLength: 0)
            BarreHome(action: { dismiss() }, sombre: true)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }

    private var entete: some View {
        VStack(spacing: 6) {
            Capsule().fill(Color(hex: 0xD9D9DE)).frame(width: 40, height: 5).padding(.top, 8)
            HStack {
                Text(titre).font(.system(size: 20, weight: .bold)).foregroundStyle(.black)
                Spacer()
                Circle().fill(SnapPalette.cercleEnTete)
                    .frame(width: 30, height: 30)
                    .overlay(Image(systemName: "xmark").font(.system(size: 13, weight: .bold)).foregroundStyle(.black))
                    .contentShape(Circle())
                    .onTapGesture { dismiss() }
            }
            .padding(.horizontal, 18).padding(.top, 6)
            if !sousTitre.isEmpty {
                Text(sousTitre)
                    .font(.system(size: 13))
                    .foregroundStyle(SnapPalette.texteStatut)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
            }
            Rectangle().fill(Color(hex: 0xEFEFF3)).frame(height: 0.5).padding(.top, 10)
        }
        .background(Color.white)
    }
}

// ============================================================================
// MARK: - 5. EN-TÊTE COMMUN (§2.2 — strictement identique sur Chat / Stories / Caméra / Spotlight)
// ============================================================================

enum SnapEnTeteStyle { case clair, sombre, viseur }

struct SnapEnTete: View {
    let titre: String
    var style: SnapEnTeteStyle = .clair
    var ajoutJaune: Bool = false        // e003 : fond jaune sur Chat, gris sur Stories, nu ailleurs
    var boutonPlus: Bool = false        // e075 : Spotlight remplace cloche + ••• par un « + » carré
    var sansTitre: Bool = false         // e001 : la caméra n'affiche pas de titre
    var sansPlus: Bool = false          // e001 : pas de ••• sur le viseur
    var demandes: Int = 47

    let surProfil: () -> Void
    let surRecherche: () -> Void
    let surCloche: () -> Void
    let surAjout: () -> Void
    let surPlus: () -> Void

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
            if !boutonPlus { cercle("bell", action: surCloche) }
            boutonAjout
            if boutonPlus {
                carrePlus
            } else if !sansPlus {
                cercle("ellipsis", action: surPlus)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
    }

    private var bitmoji: some View {
        ZStack(alignment: .topTrailing) {
            SnapAvatar(emoji: DonneesSnap.moiEmoji, teinte: DonneesSnap.moiTeinte,
                       taille: SnapMesure.cercleEnTete)
            SnapPastille(taille: 11).offset(x: 1, y: -1)
        }
        .contentShape(Circle())
        .onTapGesture { Haptique.leger(); surProfil() }     // D82 : le Bitmoji ouvre enfin le Profil
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
            SnapBadge(texte: "\(demandes)").offset(x: 8, y: -4)
        }
        .contentShape(Circle())
        .onTapGesture { Haptique.leger(); surAjout() }
    }

    private var carrePlus: some View {
        RoundedRectangle(cornerRadius: 9)
            .strokeBorder(Color.white.opacity(0.9), lineWidth: 1.6)
            .frame(width: SnapMesure.cercleEnTete, height: SnapMesure.cercleEnTete)
            .overlay(Image(systemName: "plus").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white))
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); surPlus() }
    }
}

// ============================================================================
// MARK: - 6. BARRE D'ONGLETS (§2.1 — 101 pt, glyphes à 41 pt du filet, pas de 74 pt)
// ============================================================================

struct SnapBarreOnglets: View {
    @Binding var onglet: Int
    let clair: Bool
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
                .fill(clair ? Color(hex: 0xE6E6EA) : Color(hex: 0x2A2A2A))
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
            if i == 2 {
                vignetteLens(actif: actif)
            } else {
                Image(systemName: actif ? glyphes[i].1 : glyphes[i].0)
                    .font(.system(size: 23, weight: actif ? .semibold : .regular))
                    .foregroundStyle(teinte(actif))
            }
            if i == 3 && !actif { badgeTop }
            if i == 4 && !actif { SnapBadge(texte: "3").offset(x: 12, y: -6) }
        }
        .frame(height: 40)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); onglet = i }
    }

    private func teinte(_ actif: Bool) -> Color {
        if actif { return clair ? SnapPalette.ongletActif : Color.white }
        return clair ? Color(hex: 0x8A8D95) : Color(hex: 0x9A9A9E)
    }

    // e001 : sur l'onglet Caméra le glyphe cède la place à la vignette de la Lens active + chevron ▲.
    private func vignetteLens(actif: Bool) -> some View {
        VStack(spacing: 2) {
            if actif {
                Image(systemName: "chevron.up").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
            }
            RoundedRectangle(cornerRadius: 7)
                .fill(LinearGradient(colors: [Color(hex: 0xC9CBD1), Color(hex: 0x7E828B)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 30, height: 30)
                .overlay(Text("✨").font(.system(size: 15)))
                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.white.opacity(actif ? 0.9 : 0.0), lineWidth: 1.5))
        }
    }

    private var badgeTop: some View {
        HStack(spacing: -6) {
            Text("TOP")
                .font(.system(size: 7, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 4).padding(.vertical, 3)
                .background(Circle().fill(Color(hex: 0xFF2D9B)))
            SnapBadge(texte: "3")
        }
        .offset(x: 18, y: -6)
    }
}

// ============================================================================
// MARK: - 7. ROUTES (écrans secondaires — un seul point de présentation, aucun navigationDestination)
// ============================================================================

enum SnapRoute: String, Identifiable {
    case profil, reglages, recherche, notifications, menuEnTete, ajoutAmis, nouveauChat
    case souvenirs, calquesCarte, reglagesCarte, carte3D, monProfilPublic
    case commentairesSpot, partageSpot, profilEditeur, creerSpot
    var id: String { rawValue }
}

struct SnapRouteVue: View {
    let route: SnapRoute

    // 5 vues à part entière + 1 branche commune : l'arbre @ViewBuilder reste peu profond
    // (un switch de 16 cas produit un _ConditionalContent imbriqué 16 fois — coûteux à typer).
    var body: some View {
        switch route {
        case .profil:      SnapProfilVue()
        case .recherche:   SnapRechercheVue()
        case .ajoutAmis:   SnapAjoutAmisVue()
        case .nouveauChat: SnapNouveauChatVue()
        case .carte3D:     SnapCarte3DVue()
        default:           feuille
        }
    }

    /// Écrans jamais filmés (§5) : même composant, contenu paramétré. Aucun @ViewBuilder ici.
    private var feuille: SnapFeuilleSobre {
        switch route {
        case .reglages:
            return SnapFeuilleSobre(
                titre: "Réglages",
                sousTitre: "Compte de \(DonneesSnap.moiNom)",
                lignes: ["Mon compte", "Notifications", "Confidentialité", "Amis·es bloqués",
                         "Snapchat+", "Aide", "Se déconnecter"],
                note: "TODO tournage : les Réglages n'ont jamais été filmés (§5.2). Première page sobre, à remplacer dès réception de la vidéo.")
        case .notifications:
            return SnapFeuilleSobre(
                titre: "Notifications",
                sousTitre: "Aujourd'hui",
                lignes: ["Chloé 💛 a ajouté à sa Story", "Inès vous a envoyé un Snap",
                         "Camille a réagi à votre Chat", "Team Snapchat : nouveautés de la semaine"],
                note: "TODO tournage : l'écran de la cloche n'a pas été filmé (§5.6).")
        case .menuEnTete:
            return SnapFeuilleSobre(
                titre: "Chat",
                sousTitre: "Options de la liste",
                lignes: ["Marquer tout comme lu", "Conversations archivées",
                         "Trier par nom", "Gérer les meilleurs·es amis·es"],
                note: "TODO tournage : le menu ••• de l'en-tête n'a pas été filmé (§5.5).")
        case .souvenirs:
            return SnapFeuilleSobre(
                titre: "Souvenirs",
                sousTitre: "Snaps enregistrés",
                lignes: ["Aujourd'hui · 3 Snaps", "Cette semaine · 12 Snaps", "Instantanés d'appareil photo"],
                note: "TODO tournage : Souvenirs n'a pas été ouvert dans la vidéo (§5.12).")
        case .calquesCarte:
            return SnapFeuilleSobre(
                titre: "Calques",
                sousTitre: "Ce qui s'affiche sur la carte",
                lignes: ["Amis·es", "Stories de la zone", "Heatmap", "Lieux et commerces"],
                note: "TODO tournage : la feuille des calques n'a pas été filmée (§5.14).")
        case .reglagesCarte:
            return SnapFeuilleSobre(
                titre: "Réglages de la carte",
                sousTitre: "Partage de position",
                lignes: ["Mode Fantôme", "Partager ma position avec…", "Historique des lieux"],
                note: "TODO tournage : les réglages de la carte n'ont pas été filmés (§5.14).")
        case .monProfilPublic:
            return SnapFeuilleSobre(
                titre: "Profil public",
                sousTitre: "@\(DonneesSnap.moiPseudo)",
                lignes: ["Abonnés · 132", "Spotlight publiés · 5", "Lens sauvegardées · 8"],
                note: "TODO tournage : l'onglet « Profil public » n'a pas été déroulé (§5.1).")
        case .commentairesSpot:
            return SnapFeuilleSobre(
                titre: "Commentaires",
                sousTitre: "Les plus récents",
                lignes: ["chloe.brt · trop bien filmé 😍", "ines.lyon · c'est où ça ?",
                         "tom.brl · j'y étais dimanche", "cam.mtt · 🔥🔥"],
                note: "TODO tournage : les commentaires du Spotlight n'ont pas été ouverts (§5.13).")
        case .partageSpot:
            return SnapFeuilleSobre(
                titre: "Envoyer à…",
                sousTitre: "Partager ce Spotlight",
                lignes: DonneesSnap.amis.prefix(5).map { $0.nom },
                note: "TODO tournage : la feuille de partage du Spotlight n'a pas été filmée (§5.13).")
        case .profilEditeur:
            return SnapFeuilleSobre(
                titre: "Lyon Secret",
                sousTitre: "Éditeur Découvrir",
                lignes: ["S'abonner", "Voir tous les épisodes", "Signaler"],
                note: "TODO tournage : « Voir le profil » de la visionneuse Découvrir n'a pas été suivi (§5).")
        case .creerSpot:
            return SnapFeuilleSobre(
                titre: "Créer",
                sousTitre: "Publier sur Spotlight",
                lignes: ["Depuis l'appareil photo", "Depuis les Souvenirs", "Depuis la pellicule"],
                note: "TODO tournage : le « + » de l'en-tête Spotlight n'a pas été activé (§5).")
        default:
            return SnapFeuilleSobre(
                titre: "Snapchat",
                sousTitre: "",
                lignes: [],
                note: "TODO tournage : écran non filmé.")
        }
    }
}

// ============================================================================
// MARK: - 8. COQUILLE — 5 onglets (e001 / e003 / e026 / e053 / e075)
// ============================================================================

struct SnapchatVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet: Int
    @State private var route: SnapRoute? = nil

    /// `SnapchatVue()` reste le point d'entrée de la coque (LPProto).
    /// `SnapchatVue(onglet:)` sert au mode capture (clés snapchat.camera / snapchat.spotlight),
    /// pour que la BarreHome et la barre d'onglets restent présentes sur ces écrans.
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
            SnapBarreOnglets(onglet: $onglet, clair: clair, surAccueil: { dismiss() })
        }
        .fullScreenCover(item: $route) { r in SnapRouteVue(route: r) }
        .preferredColorScheme(clair ? .light : .dark)
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
// MARK: - 9. CHAT — LISTE (e003, e005, e022)
// ============================================================================

struct SnapChatListeVue: View {
    @Binding var route: SnapRoute?
    @ObservedObject private var etat = SnapEtat.partage
    @State private var conversation: SnapAmi? = nil
    @State private var filtre: String? = nil
    @State private var menuLigne: SnapAmi? = nil
    @State private var alerte: String? = nil

    private let filtres = ["My AI", "Groupes", "Près de moi", "Meilleurs·es amis·es"]

    private var amisVisibles: [SnapAmi] {
        switch filtre {
        case "Groupes":              return DonneesSnap.amis.filter { $0.groupe }
        case "Près de moi":          return DonneesSnap.amis.filter { $0.proche }
        case "Meilleurs·es amis·es": return DonneesSnap.amis.filter { $0.meilleurAmi }
        default:                     return DonneesSnap.amis
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                SnapEnTete(titre: "Chat", style: .clair, ajoutJaune: true,
                           demandes: etat.demandesRestantes,
                           surProfil: { route = .profil },
                           surRecherche: { route = .recherche },
                           surCloche: { route = .notifications },
                           surAjout: { route = .ajoutAmis },
                           surPlus: { route = .menuEnTete })
                rangeeFiltres
                liste
            }
            fab
        }
        .background(Color.white)
        .fullScreenCover(item: $conversation) { a in SnapConversationVue(ami: a) }
        .sheet(item: $menuLigne) { a in menuContextuel(a) }
        .snapAlerte($alerte)
    }

    // ————— Filtres : TEXTE NU, aucune pilule (§2.3, correctif majeur)
    private var rangeeFiltres: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(filtres, id: \.self) { f in
                    HStack(spacing: 6) {
                        if f == "My AI" {
                            SnapAvatar(emoji: "🤖", teinte: 0xF0E4FF, taille: 21)
                        }
                        Text(f)
                            .font(.system(size: 16, weight: filtre == f ? .bold : .semibold))
                            .foregroundStyle(filtre == f ? SnapPalette.bleu : Color.black)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { toucheFiltre(f) }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
        }
    }

    // D82 : « My AI » n'est plus un filtre menteur — il ouvre la conversation My AI.
    private func toucheFiltre(_ f: String) {
        Haptique.leger()
        if f == "My AI" {
            conversation = DonneesSnap.ami("myai")
        } else {
            filtre = (filtre == f ? nil : f)
        }
    }

    private var liste: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(amisVisibles) { a in
                    SnapLigneChat(ami: a,
                                  surOuvrir: { conversation = a },
                                  surAccessoire: { accessoire(a) })
                        .onLongPressGesture { Haptique.leger(); menuLigne = a }
                }
                Spacer(minLength: SnapMesure.hauteurOnglets + 12)
            }
        }
    }

    private func accessoire(_ a: SnapAmi) {
        Haptique.leger()
        switch a.accessoire {
        case .camera: conversation = a           // ouvre le fil, prêt à envoyer un Snap
        case .croix:  alerte = "La conversation avec \(a.nom) restera dans la liste tant que vous êtes amis·es."
        case .viseur: conversation = DonneesSnap.ami("myai")
        }
    }

    private func menuContextuel(_ a: SnapAmi) -> some View {
        SnapFeuilleSobre(
            titre: a.nom,
            sousTitre: "@\(a.pseudo)",
            lignes: ["Ouvrir le Chat", "Épingler la conversation", "Mettre en sourdine",
                     "Voir le profil d'ami·e", "Supprimer la conversation"],
            note: "TODO tournage : l'appui long sur une ligne de Chat n'a pas été filmé (§5.8).")
    }

    // ————— FAB jaune ⌀60 pt, marge droite 16 pt, 15 pt au-dessus du filet (e003, présent sur 12 frames)
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

struct SnapLigneChat: View {
    let ami: SnapAmi
    let surOuvrir: () -> Void
    let surAccessoire: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            SnapAvatar(emoji: ami.emoji, teinte: ami.teinte, taille: SnapMesure.avatarLigne)
            VStack(alignment: .leading, spacing: 3) {
                Text(ami.nom)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                ligneStatut
            }
            Spacer(minLength: 8)
            Image(systemName: ami.accessoire.glyphe)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(.black)
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())
                .onTapGesture { surAccessoire() }
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

// ============================================================================
// MARK: - 10. CONVERSATION (e010–e017, mesures d'e014)
// ============================================================================

struct SnapConversationVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    let ami: SnapAmi
    @State private var saisie = ""
    @State private var ficheVisible = false
    @State private var alerte: String? = nil

    private var messages: [SnapMessage] { etat.fils[ami.id] ?? [] }

    var body: some View {
        VStack(spacing: 0) {
            entete
            fil
            SnapComposeur(saisie: $saisie,
                          surEnvoyer: { envoyer() },
                          surCamera: { alerte = "L'appareil photo du Chat s'ouvre depuis l'onglet Caméra." },
                          surSmiley: { saisie += " 🙂" },
                          surAutocollant: { saisie += " ✨" },
                          surJeu: { alerte = "Aucun jeu installé dans cette conversation." })
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .sheet(isPresented: $ficheVisible) { fiche }
        .snapAlerte($alerte)
        .preferredColorScheme(.light)
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
                SnapAvatar(emoji: ami.emoji, teinte: ami.teinte, taille: 29)
                    .contentShape(Circle())
                    .onTapGesture { Haptique.leger(); ficheVisible = true }
                VStack(alignment: .leading, spacing: 1) {
                    Text(ami.nom).font(.system(size: 17, weight: .bold)).foregroundStyle(.black)
                    Text(ami.presence).font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
                }
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); ficheVisible = true }
                Spacer()
                Image(systemName: "phone.fill")
                    .font(.system(size: 19)).foregroundStyle(.black)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); alerte = "Appel audio Snapchat indisponible : \(ami.nom) n'est pas connecté·e." }
                Image(systemName: "video.fill")
                    .font(.system(size: 21)).foregroundStyle(.black)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); alerte = "Appel vidéo Snapchat indisponible : \(ami.nom) n'est pas connecté·e." }
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            Rectangle().fill(Color(hex: 0xE6E6EA)).frame(height: 0.5)
        }
        .background(Color.white)
    }

    private var fil: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    if messages.isEmpty { etatVide }
                    Text("17 AOÛT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(SnapPalette.texteStatut)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    ForEach(messages) { m in
                        SnapBlocMessage(message: m, nomAmi: ami.nom).id(m.id)
                    }
                    Spacer(minLength: 12).id("bas")
                }
                .padding(.top, 8)
            }
            .background(Color.white)
            .onChange(of: messages.count) { _, _ in
                withAnimation { proxy.scrollTo("bas", anchor: .bottom) }
            }
        }
    }

    // e010–e011 : fil vide, mention centrée
    private var etatVide: some View {
        VStack(spacing: 6) {
            Text("AUJOURD'HUI")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(SnapPalette.texteStatut)
            Text("VOUS AVEZ ENREGISTRÉ L'ÉCRAN DU CHAT !")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(SnapPalette.texteStatut)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
    }

    private var fiche: some View {
        SnapFeuilleSobre(
            titre: ami.nom,
            sousTitre: "@\(ami.pseudo) · \(ami.presence)",
            lignes: ["Envoyer un Snap", "Voir sur la carte", "Meilleurs·es amis·es",
                     "Mettre en sourdine", "Supprimer l'ami·e"],
            note: "TODO tournage : la fiche d'ami·e n'a pas été ouverte dans la vidéo (§5.9).")
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
    private var nom: String { message.deMoi ? "Moi" : (nomAmi.components(separatedBy: " ").first ?? nomAmi) }

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

/// Composeur d'e014 : cercle NOIR + champ capsule (forme d'onde à l'intérieur) + 3 glyphes.
struct SnapComposeur: View {
    @Binding var saisie: String
    let surEnvoyer: () -> Void
    let surCamera: () -> Void
    let surSmiley: () -> Void
    let surAutocollant: () -> Void
    let surJeu: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.black)
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: "camera.fill").font(.system(size: 15)).foregroundStyle(.white))
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); surCamera() }
            champ
            glyphe("face.smiling", action: surSmiley)
            glyphe("square.on.square.dashed", action: surAutocollant)
            glyphe("gamecontroller", action: surJeu)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color.white)
    }

    private var champ: some View {
        HStack(spacing: 8) {
            TextField("", text: $saisie,
                      prompt: Text("Envoyer un Chat").foregroundStyle(Color(hex: 0xA9ADB4)))
                .font(.system(size: 16))
                .foregroundStyle(.black)
                .tint(SnapPalette.rougeMoi)              // e014 : curseur rouge
                .submitLabel(.send)
                .onSubmit { surEnvoyer() }
            Image(systemName: "waveform")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(hex: 0x6E7278))
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); surEnvoyer() }
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .background(Capsule().strokeBorder(Color(hex: 0xD6D9DE), lineWidth: 1))
    }

    private func glyphe(_ nom: String, action: @escaping () -> Void) -> some View {
        Image(systemName: nom)
            .font(.system(size: 21, weight: .regular))
            .foregroundStyle(.black)
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); action() }
    }
}

// ============================================================================
// MARK: - 11. CAMÉRA (e001, e110 — les 4 étages d'UI superposés au viseur)
// ============================================================================

struct SnapCameraVue: View {
    @Binding var route: SnapRoute?
    @State private var flashActif = false
    @State private var edition = false
    @State private var lensActive = 0
    @State private var ongletLens = "Pour vous"
    @State private var flashCoupe = true
    @State private var nuit = false
    @State private var alerte: String? = nil

    var body: some View {
        ZStack {
            viseur
            if flashActif { Color.white.ignoresSafeArea().zIndex(10) }
            VStack(spacing: 0) {
                enteteEtColonne
                Spacer()
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                rangeeCapture
                rangeeOnglets
                Spacer().frame(height: SnapMesure.hauteurOnglets + 4)
            }
        }
        .fullScreenCover(isPresented: $edition) {
            SnapEditionSnapVue(cleImage: "p24")
        }
        .snapAlerte($alerte)
    }

    // Viseur diégétique : pas d'accès caméra dans la fiction (D56) — scène plausible.
    private var viseur: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x4A3B2C), Color(hex: 0x14100C)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [Color.white.opacity(0.22), .clear],
                           center: .topLeading, startRadius: 10, endRadius: 320)
            if nuit { Color(hex: 0x0A1020).opacity(0.45) }
        }
        .ignoresSafeArea()
    }

    private var enteteEtColonne: some View {
        HStack(alignment: .top, spacing: 0) {
            SnapEnTete(titre: "", style: .viseur, sansTitre: true, sansPlus: true,
                       surProfil: { route = .profil },
                       surRecherche: { route = .recherche },
                       surCloche: { route = .notifications },
                       surAjout: { route = .ajoutAmis },
                       surPlus: { route = .menuEnTete })
            colonneOutils.padding(.trailing, 12).padding(.top, 6)
        }
    }

    // Étage 2 : 6 glyphes BLANCS LIBRES (aucune capsule sombre — correctif §3.5)
    private var colonneOutils: some View {
        VStack(spacing: 18) {
            outil("arrow.triangle.2.circlepath") { alerte = "Caméra avant activée." }
            outil(flashCoupe ? "bolt.slash.fill" : "bolt.fill") { flashCoupe.toggle() }
            outil("music.note") { alerte = "Ajoutez un son après la capture." }
            outil("smallcircle.filled.circle") { alerte = "Mode Snap : photo." }
            outil(nuit ? "moon.fill" : "moon") { nuit.toggle() }
            Circle()
                .fill(Color.black.opacity(0.45))
                .frame(width: 34, height: 34)
                .overlay(Image(systemName: "chevron.down").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white))
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); alerte = "Outils supplémentaires : minuteur, grille, retardateur." }
        }
    }

    private func outil(_ glyphe: String, action: @escaping () -> Void) -> some View {
        Image(systemName: glyphe)
            .font(.system(size: 21, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 34, height: 26)
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); action() }
    }

    // Étage 3 : AI · Souvenirs · anneau 85 pt (décalé à gauche) · carrousel de Lenses
    private var rangeeCapture: some View {
        HStack(alignment: .center, spacing: 14) {
            libelleOutil("sparkles", "AI", pastille: false) { alerte = "My AI vous répond depuis le Chat." }
            libelleOutil("photo.on.rectangle.angled", "Souvenirs", pastille: true) { route = .souvenirs }
            anneau
            carrousel
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private func libelleOutil(_ glyphe: String, _ titre: String, pastille: Bool,
                              action: @escaping () -> Void) -> some View {
        VStack(spacing: 3) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: glyphe).font(.system(size: 22, weight: .medium)).foregroundStyle(.white)
                if pastille { SnapPastille(taille: 9).offset(x: 6, y: -3) }
            }
            Text(titre).font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
        }
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

    private var carrousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(DonneesSnap.lenses.enumerated()), id: \.offset) { i, l in
                    Circle()
                        .fill(Color(hex: l.2))
                        .frame(width: 36, height: 36)
                        .overlay(Text(l.1).font(.system(size: 18)))
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: lensActive == i ? 2 : 0))
                        .contentShape(Circle())
                        .onTapGesture { Haptique.leger(); lensActive = i }
                }
            }
        }
        .frame(height: 44)
    }

    // Étage 4 : onglets de Lenses, pilule sombre sur l'actif
    private var rangeeOnglets: some View {
        HStack(spacing: 10) {
            Image(systemName: "gamecontroller.fill").font(.system(size: 17)).foregroundStyle(.white)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); alerte = "Aucun jeu Snapchat installé." }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(DonneesSnap.ongletsLenses, id: \.self) { o in
                        Text(o)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(ongletLens == o ? Color.white : Color.white.opacity(0.65))
                            .padding(.horizontal, ongletLens == o ? 14 : 0)
                            .padding(.vertical, ongletLens == o ? 8 : 0)
                            .background(pilule(actif: ongletLens == o))
                            .contentShape(Rectangle())
                            .onTapGesture { Haptique.leger(); ongletLens = o }
                    }
                }
            }
            Image(systemName: "face.smiling.inverse").font(.system(size: 21)).foregroundStyle(.white)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); alerte = "Explorer les Lens : bientôt disponible." }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func pilule(actif: Bool) -> some View {
        if actif { Capsule().fill(Color.black.opacity(0.55)) } else { Color.clear }
    }

    private func capturer() {
        Haptique.leger()
        withAnimation(.easeOut(duration: 0.1)) { flashActif = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation { flashActif = false }
            edition = true
        }
    }
}

// ————— Écran d'édition du Snap (sobre — jamais filmé, §5.11)
struct SnapEditionSnapVue: View {
    @Environment(\.dismiss) private var dismiss
    let cleImage: String
    @State private var envoiVisible = false
    @State private var legende = ""

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x4A3B2C), Color(hex: 0x14100C)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack {
                enteteEdition
                Spacer()
                if !legende.isEmpty {
                    Text(legende)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Rectangle().fill(Color.black.opacity(0.45)))
                }
                Spacer()
                barreEnvoi
                BarreHome(action: { dismiss() }, sombre: false)
            }
        }
        .fullScreenCover(isPresented: $envoiVisible) { SnapEnvoyerAVue(cleImage: cleImage) }
        .preferredColorScheme(.dark)
    }

    private var enteteEdition: some View {
        HStack(spacing: 18) {
            Image(systemName: "xmark").font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); dismiss() }
            Spacer()
            outil("textformat") { legende = legende.isEmpty ? "Lyon, 18 h 🌇" : "" }
            outil("scribble") { legende = "✏️ " + legende }
            outil("face.smiling") { legende += " 😄" }
            outil("timer") { legende = "⏱ 5 s" }
        }
        .padding(.horizontal, 16).padding(.top, 10)
    }

    private func outil(_ glyphe: String, action: @escaping () -> Void) -> some View {
        Image(systemName: glyphe)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.white)
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); action() }
    }

    private var barreEnvoi: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: "arrow.down.circle").font(.system(size: 17))
                Text("Enregistrer").font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Capsule().fill(Color.white.opacity(0.18)))
            Spacer()
            HStack(spacing: 7) {
                Text("Envoyer à").font(.system(size: 15, weight: .bold)).foregroundStyle(.black)
                Image(systemName: "paperplane.fill").font(.system(size: 14)).foregroundStyle(.black)
            }
            .padding(.horizontal, 16).padding(.vertical, 11)
            .background(Capsule().fill(SnapPalette.jaune))
            .contentShape(Capsule())
            .onTapGesture { Haptique.leger(); envoiVisible = true }
        }
        .padding(.horizontal, 14).padding(.bottom, 8)
    }
}

// ————— « Envoyer à… » réhabillé aux couleurs Snapchat (envoi RÉEL dans la conversation)
struct SnapEnvoyerAVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    let cleImage: String
    @State private var choisis: Set<String> = []

    var body: some View {
        VStack(spacing: 0) {
            enteteEnvoi
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(DonneesSnap.amis.filter { $0.id != "myai" }) { a in
                        ligne(a)
                    }
                    Spacer(minLength: 90)
                }
            }
            if !choisis.isEmpty { boutonEnvoyer }
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }

    private var enteteEnvoi: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Envoyer à…").font(.system(size: 20, weight: .bold)).foregroundStyle(.black)
                Spacer()
                Circle().fill(SnapPalette.cercleEnTete).frame(width: 30, height: 30)
                    .overlay(Image(systemName: "xmark").font(.system(size: 13, weight: .bold)).foregroundStyle(.black))
                    .contentShape(Circle())
                    .onTapGesture { Haptique.leger(); dismiss() }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            Rectangle().fill(Color(hex: 0xEFEFF3)).frame(height: 0.5)
        }
    }

    private func ligne(_ a: SnapAmi) -> some View {
        HStack(spacing: 12) {
            SnapAvatar(emoji: a.emoji, teinte: a.teinte, taille: 40)
            Text(a.nom).font(.system(size: 15, weight: .medium)).foregroundStyle(.black)
            Spacer()
            Image(systemName: choisis.contains(a.id) ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 21))
                .foregroundStyle(choisis.contains(a.id) ? SnapPalette.bleu : Color(hex: 0xC7CAD1))
        }
        .padding(.horizontal, 16).frame(height: 56)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptique.leger()
            if choisis.contains(a.id) { choisis.remove(a.id) } else { choisis.insert(a.id) }
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
// MARK: - 12. SNAP MAP (e023–e051, mesures d'e026 et e033)
// ============================================================================

struct SnapEpingleCarte: Identifiable {
    let id: String
    let lat: Double
    let lon: Double
    var emoji: String
    var teinte: UInt
    var nom: String
    var categorie: String          // "amis", "souvenirs", "tendance", "footsteps", "visite"
    var poi: Bool = false
    var poiTeinte: UInt = 0xED5019
    var poiSous: String = ""
}

struct SnapCarteVue: View {
    @Binding var route: SnapRoute?

    private static let regionLyon = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.7578, longitude: 4.8320),
        span: MKCoordinateSpan(latitudeDelta: 0.030, longitudeDelta: 0.030))

    @State private var camera: MapCameraPosition = .region(SnapCarteVue.regionLyon)
    @State private var filtre: String? = nil
    @State private var alerte: String? = nil

    private let chips: [(String, String)] = [
        ("Souvenirs", "photo.stack"),
        ("Tendance", "arrow.up.right"),
        ("Footsteps", "shoeprints.fill"),
        ("Visité", "clock"),
    ]

    private let epingles: [SnapEpingleCarte] = [
        SnapEpingleCarte(id: "moi", lat: 45.7578, lon: 4.8320, emoji: "👩🏻", teinte: 0xFFE9EC,
                         nom: "Sarah et Chloé", categorie: "amis"),
        SnapEpingleCarte(id: "ines", lat: 45.7660, lon: 4.8280, emoji: "👩🏽", teinte: 0xEDE7FF,
                         nom: "Inès il y a 1h", categorie: "amis"),
        SnapEpingleCarte(id: "camille", lat: 45.7500, lon: 4.8425, emoji: "👱🏻‍♀️", teinte: 0xE2F4E8,
                         nom: "Camille il y a 40min", categorie: "amis"),
        SnapEpingleCarte(id: "halle", lat: 45.7620, lon: 4.8480, emoji: "🍽", teinte: 0xFFFFFF,
                         nom: "Halles Bocuse", categorie: "tendance", poi: true,
                         poiTeinte: 0xED5019, poiSous: "Tendance cette semaine"),
        SnapEpingleCarte(id: "traboule", lat: 45.7690, lon: 4.8330, emoji: "🏛", teinte: 0xFFFFFF,
                         nom: "Traboule des Voraces", categorie: "visite", poi: true,
                         poiTeinte: 0x8A48CC, poiSous: "Habitué·e des lieux"),
        SnapEpingleCarte(id: "quai", lat: 45.7530, lon: 4.8265, emoji: "🌇", teinte: 0xFFFFFF,
                         nom: "Quai Saint-Antoine", categorie: "souvenirs", poi: true,
                         poiTeinte: 0xED5019, poiSous: "3 Souvenirs ici"),
        SnapEpingleCarte(id: "parc", lat: 45.7715, lon: 4.8530, emoji: "🌳", teinte: 0xFFFFFF,
                         nom: "Parc de la Tête d'Or", categorie: "footsteps", poi: true,
                         poiTeinte: 0x8A48CC, poiSous: "Passée 12 fois"),
    ]

    private var epinglesVisibles: [SnapEpingleCarte] {
        guard let f = filtre else { return epingles }
        switch f {
        case "Souvenirs":  return epingles.filter { $0.categorie == "souvenirs" || $0.categorie == "amis" }
        case "Tendance":   return epingles.filter { $0.categorie == "tendance" }
        case "Footsteps":  return epingles.filter { $0.categorie == "footsteps" || $0.categorie == "amis" }
        case "Visité":     return epingles.filter { $0.categorie == "visite" }
        default:           return epingles
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            carte
            VStack(spacing: 0) {
                enteteCarte
                rangeeChips
                Spacer()
            }
            colonneDroite
            basDeCarte
        }
        .snapAlerte($alerte)
    }

    // Fond de carte : MapKit sans POI Apple + teinte verte Snapchat (#D7EDC9 en multiply, §2.5)
    private var carte: some View {
        Map(position: $camera) {
            ForEach(epinglesVisibles) { e in
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: e.lat, longitude: e.lon)) {
                    contenuEpingle(e)
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

    @ViewBuilder
    private func contenuEpingle(_ e: SnapEpingleCarte) -> some View {
        if e.poi {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Circle().fill(Color(hex: e.poiTeinte)).frame(width: 18, height: 18)
                        .overlay(Text(e.emoji).font(.system(size: 10)))
                    Text(e.nom).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color(hex: e.poiTeinte))
                }
                Text(e.poiSous).font(.system(size: 10.5)).foregroundStyle(Color(hex: e.poiTeinte))
                    .padding(.leading, 23)
            }
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); alerte = "\(e.nom) — \(e.poiSous)." }
        } else {
            VStack(spacing: 1) {
                SnapSilhouette(emoji: e.emoji, teinte: e.teinte, taille: 44)
                Text(e.nom)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(Capsule().fill(Color.white))
            }
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); route = .carte3D }
        }
    }

    // e026 : la carte n'a PAS d'en-tête ; seule la pilule de lieu + météo, en haut à DROITE,
    // non tapable (l'audit §6 supprime SnapRechercheCarteVue). Le Bitmoji est dans la colonne droite.
    private var enteteCarte: some View {
        HStack(alignment: .top) {
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Lyon 7e").font(.system(size: 21, weight: .bold)).foregroundStyle(.black)
                HStack(spacing: 5) {
                    Image(systemName: "sun.max.fill").font(.system(size: 12)).foregroundStyle(.black)
                    Text("24 °C").font(.system(size: 14, weight: .medium)).foregroundStyle(.black)
                }
            }
        }
        .padding(.horizontal, 14).padding(.top, 8)
    }

    private var rangeeChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(Array(chips.enumerated()), id: \.offset) { _, c in
                    HStack(spacing: 6) {
                        Image(systemName: c.1).font(.system(size: 13, weight: .semibold))
                        Text(c.0).font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(filtre == c.0 ? Color.white : Color.black)
                    .padding(.horizontal, 13).padding(.vertical, 9)
                    .background(Capsule().fill(filtre == c.0 ? Color.black : Color.white))
                    .contentShape(Capsule())
                    .onTapGesture { Haptique.leger(); filtre = (filtre == c.0 ? nil : c.0) }
                }
            }
            .padding(.horizontal, 12).padding(.top, 10)
        }
    }

    // Colonne droite : 4 boutons ronds blancs ⌀37 pt (e026) — chacun répond (D82)
    private var colonneDroite: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle().fill(Color.white)
                    .frame(width: SnapMesure.boutonCarte, height: SnapMesure.boutonCarte)
                    .overlay(SnapSilhouette(emoji: DonneesSnap.moiEmoji, teinte: DonneesSnap.moiTeinte, taille: 26))
                SnapPastille(taille: 11)
            }
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); route = .profil }   // D82 : 6e point d'entrée du Profil
            boutonRond("gearshape.fill") { route = .reglagesCarte }
            boutonRond("square.3.layers.3d") { route = .calquesCarte }
            boutonRond("location.north.fill") { recentrer() }
        }
        .padding(.trailing, 12)
        .padding(.bottom, SnapMesure.hauteurOnglets + 66)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }

    private func boutonRond(_ glyphe: String, action: @escaping () -> Void) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: SnapMesure.boutonCarte, height: SnapMesure.boutonCarte)
            .overlay(Image(systemName: glyphe).font(.system(size: 16, weight: .semibold)).foregroundStyle(.black))
            .shadow(color: .black.opacity(0.10), radius: 3, y: 1)
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); action() }
    }

    private func recentrer() {
        withAnimation(.easeInOut(duration: 0.5)) {
            camera = .region(SnapCarteVue.regionLyon)
        }
    }

    private var basDeCarte: some View {
        VStack(alignment: .leading, spacing: 10) {
            piluleExploree
            rangeeAmis
        }
        .padding(.bottom, SnapMesure.hauteurOnglets + 14)
    }

    private var piluleExploree: some View {
        HStack(spacing: 6) {
            Image(systemName: "shoeprints.fill").font(.system(size: 12))
            Text("3,8 % exploré(s)").font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Capsule().fill(SnapPalette.lavande.opacity(0.6)))
        .padding(.leading, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Rangée d'amis PLEINE LARGEUR, bouton de recherche d'ami en tête (e026)
    private var rangeeAmis: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Circle().fill(Color.white)
                    .frame(width: SnapMesure.avatarCarte, height: SnapMesure.avatarCarte)
                    .overlay(Image(systemName: "person.fill.viewfinder").font(.system(size: 18)).foregroundStyle(.black))
                    .contentShape(Circle())
                    .onTapGesture { Haptique.leger(); route = .recherche }
                ForEach(DonneesSnap.amis.filter { $0.id != "myai" && !$0.groupe }) { a in
                    SnapAvatar(emoji: a.emoji, teinte: a.teinte, taille: SnapMesure.avatarCarte)
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                        .contentShape(Circle())
                        .onTapGesture { centrerSur(a) }
                }
            }
            .padding(.horizontal, 8)
        }
    }

    private func centrerSur(_ a: SnapAmi) {
        Haptique.leger()
        let cible = epingles.first(where: { $0.id == a.id })
        let coord = CLLocationCoordinate2D(latitude: cible?.lat ?? 45.7578, longitude: cible?.lon ?? 4.8320)
        withAnimation(.easeInOut(duration: 0.5)) {
            camera = .region(MKCoordinateRegion(center: coord,
                                                span: MKCoordinateSpan(latitudeDelta: 0.010, longitudeDelta: 0.010)))
        }
        alerte = "\(a.nom) · \(a.presence)"
    }
}

// ————— Bitmoji 3D plein écran + feuille « Moi et mes amis·es » (e033–e034)
struct SnapCarte3DVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var alerte: String? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [SnapPalette.carteVertClair, SnapPalette.carteVert],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            scene
            feuilleAmis
            VStack {
                enteteVue3D
                Spacer()
            }
        }
        .snapAlerte($alerte)
        .preferredColorScheme(.light)
    }

    private var enteteVue3D: some View {
        HStack(alignment: .top) {
            Circle().fill(Color.white).frame(width: 40, height: 40)
                .overlay(Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).foregroundStyle(.black))
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); dismiss() }
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
        .padding(.horizontal, 14).padding(.top, 10)
    }

    private var scene: some View {
        VStack(spacing: 6) {
            Spacer().frame(height: 70)
            HStack(spacing: 8) {
                Capsule().fill(Color.white).frame(width: 46, height: 30)
                    .overlay(Image(systemName: "figure.wave").font(.system(size: 15)).foregroundStyle(.black))
                Text("3D").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                    .padding(.horizontal, 13).padding(.vertical, 6)
                    .background(Capsule().fill(SnapPalette.bleu))
            }
            SnapSilhouette(emoji: "🧑🏻", teinte: 0xE3EEFF, taille: 120)
            HStack(spacing: 6) {
                Text("😊").font(.system(size: 13))
                Text("Sacha").font(.system(size: 14, weight: .bold)).foregroundStyle(.black)
                Image(systemName: "battery.75").font(.system(size: 12)).foregroundStyle(Color(hex: 0x2FB84A))
                Text("📍 il y a 1min").font(.system(size: 12)).foregroundStyle(.black)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(Color.white))
            Spacer()
            HStack {
                boutonFlottant("bubble.left.fill", "Chat à plusieurs") {
                    alerte = "Chat à plusieurs : créez un groupe depuis la liste Chat."
                }
                Spacer()
                boutonFlottant("camera.fill", "Carte Snap") {
                    alerte = "Publiez un Snap sur la carte depuis l'onglet Caméra."
                }
            }
            .padding(.horizontal, 14)
            Spacer().frame(height: 300)
        }
    }

    private func boutonFlottant(_ glyphe: String, _ titre: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 7) {
            Image(systemName: glyphe).font(.system(size: 13))
            Text(titre).font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Capsule().fill(Color.white))
        .contentShape(Capsule())
        .onTapGesture { Haptique.leger(); action() }
    }

    private var feuilleAmis: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Moi et mes amis·es").font(.system(size: 19, weight: .bold)).foregroundStyle(.black)
                .padding(.horizontal, 18).padding(.top, 16)
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    SnapAvatar(emoji: DonneesSnap.moiEmoji, teinte: DonneesSnap.moiTeinte, taille: 44)
                    Text("Moi").font(.system(size: 17, weight: .medium)).foregroundStyle(.black)
                    Spacer()
                    Text("Mettre à jour Bitmoji")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(.black)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Capsule().fill(Color(hex: 0xE7EAF1)))
                        .contentShape(Capsule())
                        .onTapGesture { Haptique.leger(); alerte = "Bitmoji mis à jour à partir de votre dernier Snap." }
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                Rectangle().fill(Color(hex: 0xEFEFF3)).frame(height: 0.5).padding(.leading, 14)
                HStack(spacing: 12) {
                    SnapAvatar(emoji: "🧑🏻", teinte: 0xE3EEFF, taille: 44)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Sacha Fourez").font(.system(size: 16, weight: .medium)).foregroundStyle(.black)
                        Text("Ici il y a 1min").font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
                    }
                    Spacer()
                    Capsule().fill(SnapPalette.jaune).frame(width: 58, height: 38)
                        .overlay(Image(systemName: "bubble.left.fill").font(.system(size: 15)).foregroundStyle(.black))
                        .contentShape(Capsule())
                        .onTapGesture { Haptique.leger(); alerte = "Conversation avec Sacha Fourez ouverte dans l'onglet Chat." }
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
            }
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            .padding(.horizontal, 12)
            BarreHome(action: { dismiss() }, sombre: true)
        }
        .background(RoundedRectangle(cornerRadius: 22).fill(Color(hex: 0xF7F7F9)))
        .padding(.horizontal, 8)
    }
}

// ============================================================================
// MARK: - 13. STORIES (e052–e054, e063–e064)
// ============================================================================

struct SnapStoriesVue: View {
    @Binding var route: SnapRoute?
    @ObservedObject private var etat = SnapEtat.partage
    @State private var visionneuse: SnapDecouverte? = nil
    @State private var storyAmi: SnapStoryAmi? = nil
    @State private var alerte: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            SnapEnTete(titre: "Stories", style: .clair, ajoutJaune: false,
                       demandes: etat.demandesRestantes,
                       surProfil: { route = .profil },
                       surRecherche: { route = .recherche },
                       surCloche: { route = .notifications },
                       surAjout: { route = .ajoutAmis },
                       surPlus: { route = .menuEnTete })
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    titreSection("Amis·es") { alerte = "Toutes les Stories de vos amis·es sont déjà affichées." }
                    rangeeAmis
                    titreSection("Découvrir") { alerte = "Découvrir affiche déjà l'ensemble des chaînes suivies." }
                    rangeeDecouvrir
                    grilleDecouvrir
                    Spacer(minLength: SnapMesure.hauteurOnglets + 10)
                }
                .padding(.top, 4)
            }
        }
        .background(Color.white)
        .fullScreenCover(item: $visionneuse) { d in SnapVisionneuseDecouvrirVue(carte: d) }
        .fullScreenCover(item: $storyAmi) { s in
            SnapVisionneuseDecouvrirVue(carte: SnapDecouverte(id: s.id, titre: s.nom, editeur: s.pseudo,
                                                              accroche: "Story · il y a 3 h",
                                                              imageCle: "p12", teinte: 0x9B4DFF),
                                        storyAmi: true)
        }
        .snapAlerte($alerte)
    }

    private func titreSection(_ t: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 5) {
            Text(t).font(.system(size: 21, weight: .bold)).foregroundStyle(.black)
            Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundStyle(Color(hex: 0x9A9DA4))
        }
        .padding(.horizontal, 14)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); action() }
    }

    private var rangeeAmis: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                boutonAjoutAmi
                ForEach(DonneesSnap.storiesAmis) { s in
                    VStack(spacing: 5) {
                        ZStack(alignment: .bottom) {
                            SnapAvatar(emoji: s.emoji, teinte: s.teinte, taille: 62)
                                .overlay(anneau)
                            badgeNouvelles(s.nouvelles)
                        }
                        .frame(height: 74)
                        Text(s.nom).font(.system(size: 13, weight: .bold)).foregroundStyle(.black).lineLimit(1)
                        Text(s.pseudo).font(.system(size: 11.5)).foregroundStyle(SnapPalette.texteStatut).lineLimit(1)
                    }
                    .frame(width: 82)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); storyAmi = s }
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private var anneau: some View {
        Circle().strokeBorder(
            LinearGradient(colors: [SnapPalette.anneauStory, SnapPalette.anneauStory2],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            lineWidth: 3)
    }

    private func badgeNouvelles(_ n: Int) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "person.fill.badge.plus").font(.system(size: 9, weight: .bold))
            Text("+\(n)").font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 7).padding(.vertical, 3)
        .background(Capsule().fill(SnapPalette.anneauStory))
        .offset(y: 2)
    }

    private var boutonAjoutAmi: some View {
        VStack(spacing: 5) {
            Circle().fill(SnapPalette.cercleEnTete).frame(width: 62, height: 62)
                .overlay(Image(systemName: "person.badge.plus").font(.system(size: 24)).foregroundStyle(.black))
                .frame(height: 74)
            Text("Ajouter").font(.system(size: 13, weight: .bold)).foregroundStyle(.black)
        }
        .frame(width: 82)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); route = .ajoutAmis }
    }

    // Registre 1 : rangée horizontale de tuiles étroites 119×193 pt
    private var rangeeDecouvrir: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(DonneesSnap.decouvrirRangee) { d in
                    ZStack(alignment: .bottomLeading) {
                        SnapImage(cle: d.imageCle, teinte1: d.teinte, teinte2: 0x101216)
                            .frame(width: 119, height: 193)
                        LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
                        Text(d.titre)
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(3)
                            .padding(8)
                    }
                    .frame(width: 119, height: 193)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); visionneuse = d }
                }
            }
            .padding(.horizontal, 14)
        }
    }

    // Registre 2 : grille 2 colonnes de grandes tuiles 195×320 pt, icône « OO », tuile sponsorisée
    private var grilleDecouvrir: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 9), GridItem(.flexible(), spacing: 9)], spacing: 9) {
            ForEach(DonneesSnap.decouvrirGrille) { d in
                grandeTuile(d)
            }
        }
        .padding(.horizontal, 14)
    }

    private func grandeTuile(_ d: SnapDecouverte) -> some View {
        ZStack(alignment: .bottomLeading) {
            SnapImage(cle: d.imageCle, teinte1: d.teinte, teinte2: 0x0C0E12)
                .frame(height: 300)
            LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 7) {
                Text(d.titre).font(.system(size: 16, weight: .bold)).foregroundStyle(.white).lineLimit(3)
                if d.sponsorise {
                    Text("Sponsorisé").font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
                    Text("Installer")
                        .font(.system(size: 14, weight: .bold)).foregroundStyle(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(Capsule().fill(Color.white))
                }
            }
            .padding(10)
            iconeAbonnement(d)
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); visionneuse = d }
    }

    private func iconeAbonnement(_ d: SnapDecouverte) -> some View {
        HStack(spacing: 2) {
            Image(systemName: etat.abonnements.contains(d.id) ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12, weight: .bold))
            Image(systemName: "circle").font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptique.leger()
            if etat.abonnements.contains(d.id) { etat.abonnements.remove(d.id) } else { etat.abonnements.insert(d.id) }
        }
    }
}

// ————— Visionneuse Découvrir fidèle à e055–e062 (ni croix, ni champ de saisie)
struct SnapVisionneuseDecouvrirVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage
    let carte: SnapDecouverte
    var storyAmi: Bool = false

    @State private var progression: CGFloat = 0.05
    @State private var aime = false
    @State private var route: SnapRoute? = nil
    private let minuteur = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                barreProgression
                cartePrincipale
                barreBasse
                BarreHome(action: { dismiss() }, sombre: false)
            }
        }
        .fullScreenCover(item: $route) { r in SnapRouteVue(route: r) }
        .onReceive(minuteur) { _ in
            if progression < 1 { progression += 0.0016 } else { dismiss() }
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

    private var cartePrincipale: some View {
        ZStack(alignment: .top) {
            SnapImage(cle: carte.imageCle, teinte1: carte.teinte, teinte2: 0x0A0C10)
            LinearGradient(colors: [.black.opacity(0.35), .clear], startPoint: .top, endPoint: .center)
            VStack {
                enteteCarte
                Spacer()
                Text(carte.titre)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(radius: 4)
                    .padding(.horizontal, 26)
                Spacer()
                rail
            }
            .padding(.vertical, 10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 4).padding(.top, 6)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); progression = min(progression + 0.25, 0.999) }
    }

    private var enteteCarte: some View {
        HStack(alignment: .top) {
            HStack(spacing: 8) {
                Circle().fill(Color.white).frame(width: 34, height: 34)
                    .overlay(Text(String(carte.editeur.prefix(1)).uppercased())
                        .font(.system(size: 15, weight: .heavy)).foregroundStyle(Color(hex: carte.teinte)))
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        Text(carte.editeur).font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                        Image(systemName: "star.circle.fill").font(.system(size: 12)).foregroundStyle(SnapPalette.jaune)
                    }
                    Text(carte.accroche).font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
                }
            }
            Spacer()
            if !storyAmi { piluleAjouter }
        }
        .padding(.horizontal, 10)
    }

    private var piluleAjouter: some View {
        HStack(spacing: 7) {
            Image(systemName: etat.abonnements.contains(carte.id) ? "checkmark" : "plus")
                .font(.system(size: 15, weight: .bold))
            Text(etat.abonnements.contains(carte.id) ? "Ajouté" : "Ajouter")
                .font(.system(size: 16, weight: .bold))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 18)
        .frame(height: 33)
        .background(Capsule().fill(SnapPalette.jaune))
        .contentShape(Capsule())
        .onTapGesture {
            Haptique.leger()
            if etat.abonnements.contains(carte.id) { etat.abonnements.remove(carte.id) }
            else { etat.abonnements.insert(carte.id) }
        }
    }

    private var rail: some View {
        VStack(alignment: .trailing, spacing: 18) {
            Image(systemName: aime ? "heart.fill" : "heart")
                .font(.system(size: 28))
                .foregroundStyle(aime ? SnapPalette.rougeMoi : Color.white)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); aime.toggle() }
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bubble.left.fill").font(.system(size: 24)).foregroundStyle(.white)
                    SnapPastille(taille: 9).offset(x: 3, y: -2)
                }
                Text("3").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
            }
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); route = .commentairesSpot }
            VStack(spacing: 3) {
                Image(systemName: "arrowshape.turn.up.right.fill").font(.system(size: 25)).foregroundStyle(.white)
                Text("62").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
            }
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); route = .partageSpot }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 12).padding(.bottom, 10)
    }

    private var barreBasse: some View {
        HStack(spacing: 12) {
            Circle().strokeBorder(Color.white.opacity(0.6), lineWidth: 1.2)
                .frame(width: 52, height: 52)
                .overlay(Image(systemName: "camera.filters").font(.system(size: 20)).foregroundStyle(.white))
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); dismiss() }
            Text(storyAmi ? "Répondre" : "Voir le profil")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Capsule().strokeBorder(Color.white.opacity(0.6), lineWidth: 1.2))
                .contentShape(Capsule())
                .onTapGesture { Haptique.leger(); route = .profilEditeur }
            Circle().strokeBorder(Color.white.opacity(0.6), lineWidth: 1.2)
                .frame(width: 52, height: 52)
                .overlay(Image(systemName: "ellipsis").font(.system(size: 20)).foregroundStyle(.white))
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); route = .partageSpot }
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
    }
}

// ============================================================================
// MARK: - 14. SPOTLIGHT — FIL VERTICAL DÉFILABLE (e065–e107, mesures d'e075)
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
                                SnapCartePage(spot: s, route: $route)
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
            enteteSpotlight
        }
    }

    private var enteteSpotlight: some View {
        SnapEnTete(titre: "Spotlight", style: .sombre, boutonPlus: true,
                   demandes: etat.demandesRestantes,
                   surProfil: { route = .profil },
                   surRecherche: { route = .recherche },
                   surCloche: { route = .notifications },
                   surAjout: { route = .ajoutAmis },
                   surPlus: { route = .creerSpot })
    }
}

struct SnapCartePage: View {
    let spot: SnapSpot
    @Binding var route: SnapRoute?
    @ObservedObject private var etat = SnapEtat.partage
    @State private var alerte: String? = nil

    private var aime: Bool { etat.aimes.contains(spot.id) }
    private var coeurs: Int { etat.coeurs[spot.id] ?? spot.coeurs }

    var body: some View {
        VStack(spacing: 0) {
            zoneVideo
            barreProgression
            bandeauBas
        }
        .background(Color.black)
        .snapAlerte($alerte)
    }

    private var zoneVideo: some View {
        ZStack {
            SnapImage(cle: spot.imageCle, teinte1: spot.teinte1, teinte2: spot.teinte2)
            Color.black.opacity(0.12)
            VStack {
                Spacer().frame(height: 58)
                HStack {
                    SnapAvatar(emoji: "🎥", teinte: 0xE7EAF1, taille: 46)
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: 1.5))
                        .contentShape(Circle())
                        .onTapGesture { Haptique.leger(); route = .profilEditeur }
                    Spacer()
                }
                .padding(.horizontal, 14)
                Spacer()
                HStack(alignment: .bottom) {
                    Spacer()
                    rail
                }
                .padding(.horizontal, 12)
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

    private var rail: some View {
        VStack(spacing: 16) {
            ampouleLens
            compteur(aime ? "heart.fill" : "heart", SnapEtat.nombre(coeurs),
                     teinte: aime ? SnapPalette.rougeMoi : Color.white) {
                etat.basculerCoeur(spot.id)
            }
            ZStack(alignment: .topTrailing) {
                compteur("bubble.left.fill", "\(spot.commentaires)", teinte: .white) {
                    route = .commentairesSpot
                }
                SnapPastille(taille: 9).offset(x: 4, y: -2)
            }
            compteur("arrow.2.squarepath", "\(spot.boucles)", teinte: .white) {
                alerte = "Ce Spotlight est déjà en lecture en boucle."
            }
            compteur("arrowshape.turn.up.right.fill", "\(spot.partages)", teinte: .white) {
                route = .partageSpot
            }
        }
    }

    private var ampouleLens: some View {
        ZStack(alignment: .bottom) {
            Circle().fill(Color.white).frame(width: 44, height: 44)
                .overlay(Image(systemName: "lightbulb.fill").font(.system(size: 21)).foregroundStyle(SnapPalette.jaune))
            Circle().fill(SnapPalette.jaune).frame(width: 18, height: 18)
                .overlay(Image(systemName: "plus").font(.system(size: 11, weight: .bold)).foregroundStyle(.black))
                .offset(y: 6)
        }
        .frame(height: 50)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); alerte = "Lens ajoutée à vos favoris." }
    }

    private func compteur(_ glyphe: String, _ valeur: String, teinte: Color,
                          action: @escaping () -> Void) -> some View {
        VStack(spacing: 3) {
            Image(systemName: glyphe).font(.system(size: 26)).foregroundStyle(teinte)
            Text(valeur).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
        }
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); action() }
    }

    private var barreProgression: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(Color.white.opacity(0.25)).frame(height: 2)
            Rectangle().fill(Color.white).frame(width: 90, height: 2)
        }
    }

    // Bandeau NOIR #010008 hors vidéo (e075)
    private var bandeauBas: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Spacer()
                Image(systemName: "ellipsis").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); route = .partageSpot }
            }
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.auteur).font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    HStack(spacing: 5) {
                        Image(systemName: "music.note").font(.system(size: 11))
                        Text(spot.son).font(.system(size: 13))
                    }
                    .foregroundStyle(.white.opacity(0.92))
                }
                Spacer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [Color(hex: 0x1E7A5A), Color(hex: 0x0E3D2E)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "waveform").font(.system(size: 18)).foregroundStyle(SnapPalette.jaune))
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); alerte = "Son original de \(spot.auteur) — 3 Spotlight l'utilisent." }
            }
        }
        .padding(.horizontal, 14).padding(.top, 8).padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(SnapPalette.bandeauSpot)
    }
}

// ============================================================================
// MARK: - 15. PROFIL (e112–e114) — destination du Bitmoji d'en-tête, présent sur 5 écrans
// ============================================================================

struct SnapProfilVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ongletCompte = 0           // 0 = Mon compte, 1 = Profil public
    @State private var modalePhoto = false
    @State private var route: SnapRoute? = nil
    @State private var alerte: String? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            SnapPalette.fondPage.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    hero
                    corps
                    Spacer(minLength: 60)
                }
            }
            BarreHome(action: { dismiss() }, sombre: true)
        }
        .fullScreenCover(item: $route) { r in SnapRouteVue(route: r) }
        .sheet(isPresented: $modalePhoto) { modaleContacts }
        .snapAlerte($alerte)
        .preferredColorScheme(.light)
    }

    // ————— Héros vert #1AB64B → noir, Bitmoji, bulle de statut
    private var hero: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [SnapPalette.heroProfil, .black], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 0) {
                barreHero
                bulleStatut
                Spacer(minLength: 0)
                identite
                capsulesCompte
            }
            .padding(.bottom, 12)
        }
        .frame(height: 340)
    }

    private var barreHero: some View {
        HStack(spacing: 10) {
            rondSombre("chevron.left") { dismiss() }
            Spacer()
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 5).fill(SnapPalette.jaune).frame(width: 24, height: 24)
                    .overlay(Image(systemName: "qrcode").font(.system(size: 13)).foregroundStyle(.black))
                Text("Partager").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
            }
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(Capsule().fill(Color.white.opacity(0.16)))
            .contentShape(Capsule())
            .onTapGesture { Haptique.leger(); alerte = "Votre Snapcode a été copié : @\(DonneesSnap.moiPseudo)" }
            Spacer()
            ZStack(alignment: .topTrailing) {
                rondSombre("person.crop.circle") { route = .ajoutAmis }
                SnapPastille(taille: 11)
            }
            rondSombre("gearshape.fill") { route = .reglages }
        }
        .padding(.horizontal, 14).padding(.top, 8)
    }

    private func rondSombre(_ glyphe: String, action: @escaping () -> Void) -> some View {
        Circle().fill(Color.white.opacity(0.16)).frame(width: 42, height: 42)
            .overlay(Image(systemName: glyphe).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white))
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); action() }
    }

    private var bulleStatut: some View {
        HStack {
            Spacer()
            Text(DonneesSnap.moiStatut)
                .font(.system(size: 15))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color(hex: 0xE7EAF1)))
                .frame(maxWidth: 240)
        }
        .padding(.horizontal, 14).padding(.top, 12)
    }

    private var identite: some View {
        HStack(alignment: .bottom, spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Circle().fill(Color.white.opacity(0.18)).frame(width: 100, height: 100)
                    .overlay(Image(systemName: "photo").font(.system(size: 30)).foregroundStyle(.white.opacity(0.85)))
                Circle().fill(Color.white).frame(width: 32, height: 32)
                    .overlay(Image(systemName: "pencil").font(.system(size: 14, weight: .semibold)).foregroundStyle(.black))
            }
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); modalePhoto = true }
            VStack(alignment: .leading, spacing: 2) {
                Text(DonneesSnap.moiNom).font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                Text(DonneesSnap.moiPseudo).font(.system(size: 16)).foregroundStyle(.white.opacity(0.75))
            }
            Spacer()
        }
        .padding(.horizontal, 18)
    }

    private var capsulesCompte: some View {
        HStack(spacing: 12) {
            capsule("Mon compte", index: 0)
            capsule("Profil public", index: 1)
        }
        .padding(.horizontal, 16).padding(.top, 14)
    }

    private func capsule(_ titre: String, index: Int) -> some View {
        Text(titre)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Capsule().fill(Color.white.opacity(0.16)))
            .overlay(Capsule().strokeBorder(Color.white.opacity(ongletCompte == index ? 0.95 : 0.0), lineWidth: 1.5))
            .contentShape(Capsule())
            .onTapGesture {
                Haptique.leger()
                ongletCompte = index
                if index == 1 { route = .monProfilPublic }
            }
    }

    // ————— Corps : chips, chip jaune, carte Snapchat+, « Publier sur… », « Amis·es »
    private var corps: some View {
        VStack(alignment: .leading, spacing: 14) {
            rangeeChips
            chipJaune
            carteSnapchatPlus
            Text("Publier sur…").font(.system(size: 22, weight: .bold)).foregroundStyle(.black)
                .padding(.horizontal, 16)
            cartePublier
            Text("Amis·es").font(.system(size: 22, weight: .bold)).foregroundStyle(.black)
                .padding(.horizontal, 16)
            carteAmis
            sousAmis
        }
        .padding(.top, 14)
    }

    private var rangeeChips: some View {
        HStack(spacing: 9) {
            chip("❤️", "28 juil.", chevron: true) { alerte = "Anniversaire de l'amitié avec Chloé 💛 : 28 juillet." }
            chip("👻", "3 402", chevron: false) { alerte = "Votre Snapscore est de 3 402." }
            chip("♓️", "Poissons", chevron: false) { alerte = "Signe astrologique : Poissons." }
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private func chip(_ emoji: String, _ texte: String, chevron: Bool, action: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Text(emoji).font(.system(size: 13))
            Text(texte).font(.system(size: 15, weight: .medium)).foregroundStyle(.black)
            if chevron {
                Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold))
                    .foregroundStyle(SnapPalette.texteStatut)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Capsule().fill(Color.white))
        .contentShape(Capsule())
        .onTapGesture { Haptique.leger(); action() }
    }

    private var chipJaune: some View {
        Text("Rejoindre l'établissement scolaire")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.black)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(SnapPalette.jaune))
            .padding(.horizontal, 16)
            .contentShape(Capsule())
            .onTapGesture { Haptique.leger(); alerte = "Ajoutez votre établissement depuis Réglages › Mon compte." }
    }

    private var carteSnapchatPlus: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10).fill(Color.black).frame(width: 54, height: 54)
                .overlay(Image(systemName: "bolt.horizontal.fill").font(.system(size: 21)).foregroundStyle(SnapPalette.jaune))
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text("Snapchat+").font(.system(size: 17, weight: .bold)).foregroundStyle(.black)
                    Text("Fonctionnalités mises à jour")
                        .font(.system(size: 10, weight: .bold)).foregroundStyle(.black)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Capsule().fill(SnapPalette.jaune))
                }
                Text("Fonctionnalités exclusives et expérimentales en avant-première")
                    .font(.system(size: 13)).foregroundStyle(Color(hex: 0x4A4E55)).lineLimit(2)
            }
            Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold))
                .foregroundStyle(SnapPalette.texteStatut)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(SnapPalette.jaune, lineWidth: 1.5))
        )
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); alerte = "Snapchat+ : abonnement non actif sur ce compte." }
    }

    private var cartePublier: some View {
        VStack(spacing: 12) {
            lignePublier(emoji: "▶️", teinte: 0xFFE1E8, titre: "Spotlight",
                         sous: "Atteignez une large audience", bouton: "Publier") {
                alerte = "Choisissez un Snap dans Souvenirs pour le publier sur Spotlight."
            }
            VStack(spacing: 0) {
                lignePublier(emoji: DonneesSnap.moiEmoji, teinte: DonneesSnap.moiTeinte,
                             titre: "Ma Story · Mes amis·es", sous: "", bouton: "Ajouter") {
                    alerte = "Ajoutez à votre Story depuis l'onglet Caméra."
                }
                Rectangle().fill(Color(hex: 0xEFEFF3)).frame(height: 0.5)
                HStack(spacing: 0) {
                    sousBouton("lock.fill", "Nouvelle Story privée")
                    Rectangle().fill(Color(hex: 0xEFEFF3)).frame(width: 0.5, height: 34)
                    sousBouton("person.2.fill", "Nouvelle Story partagée")
                }
                .padding(.vertical, 8)
            }
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            lignePublier(emoji: DonneesSnap.moiEmoji, teinte: DonneesSnap.moiTeinte,
                         titre: "Ma Story · Publique", sous: "Amis·es, followers et tout le monde",
                         bouton: "Ajouter") {
                alerte = "Story publique désactivée dans vos réglages de confidentialité."
            }
        }
        .padding(.horizontal, 16)
    }

    private func lignePublier(emoji: String, teinte: UInt, titre: String, sous: String,
                              bouton: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            SnapAvatar(emoji: emoji, teinte: teinte, taille: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(titre).font(.system(size: 17, weight: .semibold)).foregroundStyle(.black)
                if !sous.isEmpty {
                    Text(sous).font(.system(size: 13.5)).foregroundStyle(Color(hex: 0x6A6E75))
                }
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "camera").font(.system(size: 13))
                Text(bouton).font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 13).padding(.vertical, 9)
            .background(Capsule().fill(Color(hex: 0xE7EAF1)))
            .contentShape(Capsule())
            .onTapGesture { Haptique.leger(); action() }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
    }

    private func sousBouton(_ glyphe: String, _ titre: String) -> some View {
        HStack(spacing: 8) {
            Circle().fill(Color(hex: 0xE7EAF1)).frame(width: 30, height: 30)
                .overlay(Image(systemName: glyphe).font(.system(size: 13)).foregroundStyle(.black))
            Text(titre).font(.system(size: 13.5)).foregroundStyle(.black).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); alerte = "\(titre) : créez-la depuis l'onglet Stories." }
    }

    private var carteAmis: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.badge.plus").font(.system(size: 22)).foregroundStyle(.black)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text("Ajouter des amis·es").font(.system(size: 17, weight: .bold)).foregroundStyle(.black)
                Text("1 demande d'ami·e !").font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(SnapPalette.bleuProfil)
            }
            Spacer()
            Text("1").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Capsule().fill(SnapPalette.bleuProfil))
            Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold))
                .foregroundStyle(SnapPalette.texteStatut)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); route = .ajoutAmis }
    }

    // TODO tournage : sous la section « Amis·es », le Profil n'a pas été déroulé (§5.1) — bloc sobre.
    private var sousAmis: some View {
        VStack(spacing: 0) {
            ForEach(["Mes amis·es · 132", "Meilleurs·es amis·es · 4", "Anniversaires"], id: \.self) { l in
                HStack {
                    Text(l).font(.system(size: 16)).foregroundStyle(.black)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(SnapPalette.texteStatut)
                }
                .padding(.horizontal, 14).padding(.vertical, 14)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); alerte = "\(l) — section non filmée, à compléter." }
                Rectangle().fill(Color(hex: 0xEFEFF3)).frame(height: 0.5).padding(.leading, 14)
            }
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .padding(.horizontal, 16)
    }

    // e113 : modale « Utiliser la photo de profil de vos contacts »
    private var modaleContacts: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Circle().fill(SnapPalette.cercleEnTete).frame(width: 32, height: 32)
                    .overlay(Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundStyle(.black))
                    .contentShape(Circle())
                    .onTapGesture { Haptique.leger(); modalePhoto = false }
            }
            .padding(.horizontal, 16).padding(.top, 16)
            Spacer()
            SnapAvatar(emoji: DonneesSnap.moiEmoji, teinte: 0xC9E6E8, taille: 180)
            Text("Utiliser la photo de profil de vos contacts ?")
                .font(.system(size: 21, weight: .bold)).foregroundStyle(.black)
                .multilineTextAlignment(.center).padding(.horizontal, 30)
            Text("Vos amis·es vous reconnaîtront plus facilement dans le Chat.")
                .font(.system(size: 14)).foregroundStyle(SnapPalette.texteStatut)
                .multilineTextAlignment(.center).padding(.horizontal, 34)
            Spacer()
            Text("Ok").font(.system(size: 17, weight: .bold)).foregroundStyle(.black)
                .frame(maxWidth: .infinity).frame(height: 50)
                .background(Capsule().fill(SnapPalette.jaune))
                .padding(.horizontal, 24)
                .contentShape(Capsule())
                .onTapGesture { Haptique.leger(); modalePhoto = false }
            Text("Prendre un Snap").font(.system(size: 16, weight: .semibold)).foregroundStyle(.black)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); modalePhoto = false }
            Text("Choisir parmi les photos du téléphone")
                .font(.system(size: 16, weight: .semibold)).foregroundStyle(.black)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); modalePhoto = false }
            BarreHome(action: { modalePhoto = false }, sombre: true)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}

// ============================================================================
// MARK: - 16. RECHERCHE, AJOUT D'AMIS, NOUVEAU CHAT (états jamais filmés — sobres, §5)
// ============================================================================

struct SnapRechercheVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var saisie = ""
    @State private var conversation: SnapAmi? = nil

    private var resultats: [SnapAmi] {
        if saisie.isEmpty { return DonneesSnap.amis }
        return DonneesSnap.amis.filter {
            $0.nom.localizedCaseInsensitiveContains(saisie) || $0.pseudo.localizedCaseInsensitiveContains(saisie)
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
                    Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(SnapPalette.texteStatut)
                    TextField("", text: $saisie,
                              prompt: Text("Rechercher des amis·es").foregroundStyle(Color(hex: 0xA9ADB4)))
                        .font(.system(size: 16)).foregroundStyle(.black)
                }
                .padding(.horizontal, 13).frame(height: 40)
                .background(Capsule().fill(SnapPalette.cercleEnTete))
                Text("Annuler").font(.system(size: 16, weight: .semibold)).foregroundStyle(.black)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); dismiss() }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            Rectangle().fill(Color(hex: 0xEFEFF3)).frame(height: 0.5)
        }
    }

    private var liste: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(resultats) { a in
                    HStack(spacing: 12) {
                        SnapAvatar(emoji: a.emoji, teinte: a.teinte, taille: 42)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.nom).font(.system(size: 16, weight: .medium)).foregroundStyle(.black)
                            Text("@\(a.pseudo)").font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
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

struct SnapAjoutAmisVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = SnapEtat.partage

    private let suggestions: [(String, String, String, UInt)] = [
        ("Julie Ferrand", "julie.frd", "👩🏼‍🦱", 0xFFE9EC),
        ("Karim B.", "karim.b", "🧑🏽", 0xE3EEFF),
        ("Océane", "oce.chass", "👩🏻", 0xEDE7FF),
        ("Florian", "florian.cnl", "👨🏼", 0xE2F4E8),
    ]

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Demandes reçues")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(.black)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    ligne(nom: "Manon", pseudo: "manon.dcx", emoji: "👩🏾", teinte: 0xE8F0FF, demande: true)
                    Text("Suggestions rapides")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(.black)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    ForEach(Array(suggestions.enumerated()), id: \.offset) { _, s in
                        ligne(nom: s.0, pseudo: s.1, emoji: s.2, teinte: s.3, demande: false)
                    }
                    Text("TODO tournage : la liste complète des demandes (§5.4) n'a pas été filmée.")
                        .font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
                        .padding(.horizontal, 20).padding(.top, 20)
                }
            }
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }

    private var entete: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Ajouter des amis·es").font(.system(size: 20, weight: .bold)).foregroundStyle(.black)
                Spacer()
                Circle().fill(SnapPalette.cercleEnTete).frame(width: 30, height: 30)
                    .overlay(Image(systemName: "xmark").font(.system(size: 13, weight: .bold)).foregroundStyle(.black))
                    .contentShape(Circle())
                    .onTapGesture { Haptique.leger(); dismiss() }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            Rectangle().fill(Color(hex: 0xEFEFF3)).frame(height: 0.5)
        }
    }

    private func ligne(nom: String, pseudo: String, emoji: String, teinte: UInt, demande: Bool) -> some View {
        let ajoute = etat.amisAjoutes.contains(pseudo)
        return HStack(spacing: 12) {
            SnapAvatar(emoji: emoji, teinte: teinte, taille: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(nom).font(.system(size: 16, weight: .medium)).foregroundStyle(.black)
                Text(demande ? "vous a ajouté·e" : "@\(pseudo)")
                    .font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
            }
            Spacer()
            Text(ajoute ? "Ajouté·e" : "Ajouter")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.black)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(ajoute ? Color(hex: 0xE7EAF1) : SnapPalette.jaune))
                .contentShape(Capsule())
                .onTapGesture {
                    Haptique.leger()
                    if ajoute {
                        etat.amisAjoutes.remove(pseudo)
                        etat.demandesRestantes += 1
                    } else {
                        etat.amisAjoutes.insert(pseudo)
                        etat.demandesRestantes = max(0, etat.demandesRestantes - 1)
                    }
                }
        }
        .padding(.horizontal, 16).frame(height: 64)
    }
}

struct SnapNouveauChatVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var saisie = ""
    @State private var conversation: SnapAmi? = nil

    private var resultats: [SnapAmi] {
        if saisie.isEmpty { return DonneesSnap.amis }
        return DonneesSnap.amis.filter { $0.nom.localizedCaseInsensitiveContains(saisie) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Nouveau Chat").font(.system(size: 20, weight: .bold)).foregroundStyle(.black)
                Spacer()
                Circle().fill(SnapPalette.cercleEnTete).frame(width: 30, height: 30)
                    .overlay(Image(systemName: "xmark").font(.system(size: 13, weight: .bold)).foregroundStyle(.black))
                    .contentShape(Circle())
                    .onTapGesture { Haptique.leger(); dismiss() }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(SnapPalette.texteStatut)
                TextField("", text: $saisie,
                          prompt: Text("À : nom ou pseudo").foregroundStyle(Color(hex: 0xA9ADB4)))
                    .font(.system(size: 16)).foregroundStyle(.black)
            }
            .padding(.horizontal, 13).frame(height: 40)
            .background(Capsule().fill(SnapPalette.cercleEnTete))
            .padding(.horizontal, 16)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(resultats) { a in
                        HStack(spacing: 12) {
                            SnapAvatar(emoji: a.emoji, teinte: a.teinte, taille: 42)
                            Text(a.nom).font(.system(size: 16, weight: .medium)).foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(SnapPalette.texteStatut)
                        }
                        .padding(.horizontal, 16).frame(height: 58)
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); conversation = a }
                    }
                    Text("TODO tournage : l'écran du FAB jaune (§5.7) n'a pas été filmé.")
                        .font(.system(size: 12.5)).foregroundStyle(SnapPalette.texteStatut)
                        .padding(.top, 18)
                }
                .padding(.top, 8)
            }
            BarreHome(action: { dismiss() }, sombre: true).background(Color.white)
        }
        .background(Color.white)
        .fullScreenCover(item: $conversation) { a in SnapConversationVue(ami: a) }
        .preferredColorScheme(.light)
    }
}
