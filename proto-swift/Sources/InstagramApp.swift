// Instagram — v3 D91 (03/09) — reconstruit contre les 239 frames de Joachim, mesures audit/instagram.md
//
// Ce fichier remplace intégralement la v1 (« Instagram 2022 »). La référence est iOS 26 :
//   · barre d'onglets = capsule flottante 370×52 pt, r 26, 16 pt de marge, 26 pt du bas
//     (maison · reels · DM · loupe · avatar), pastille active 78×41 pt #2E3236   → e001, e072, e197
//   · en-tête du feed = « + » à gauche · « Pour vous ⌄ » centré · cœur seul à droite  → e001
//   · accent #3C51FC (boutons pleins) / #4D6CFF (liens, pastilles, points actifs)     → e148, e170
//   · stories : avatar 79 pt, anneau extérieur 93 pt, pas 104,5 pt, jaune #D8BA00 en
//     bas-gauche → violet #C916CA en haut-droite (AngularGradient décalé de 135°)     → e001
//   · icônes de publication maison : cœur, cercle à queue, repost, triangle inversé,
//     signet, menu à 2 traits inégaux ; compteurs INLINE                              → e003, e045, e170
//   · DM : bulles envoyées en dégradé vertical #AD29D5 → #6B30FE à l'échelle du fil,
//     bulles reçues #21242B, caméra ronde indigo #5249FF à gauche du composer         → e073, e082
//
// Choix d'architecture (anti-blocage, retour Joachim « story ouverte = bloqué ») :
//   AUCUN .sheet / .fullScreenCover / NavigationStack dans cette app. Tous les écrans
//   secondaires sont des overlays de la ZStack racine, EN DESSOUS de BarreHome, qui reste
//   donc toujours atteignable. Tout l'état mutable vit dans IgEtat (ObservableObject).
//
// Contenu : Sarah Levasseur (sarah.lvsr), photographe amateure lyonnaise. Aucune donnée réelle.
// Tous les types de ce fichier sont préfixés Ig… pour ne heurter aucun autre fichier du projet.
import SwiftUI

// ============================================================ 0. THÈME (mesures audit §2)
enum IgTheme {
    static let fond            = Color(hex: 0x000000)
    static let accent          = Color(hex: 0x3C51FC)   // boutons pleins (Suivre)
    static let lien            = Color(hex: 0x4D6CFF)   // liens, pastilles non-lu, point actif
    static let surface1        = Color(hex: 0x15191C)   // feuilles
    static let surface2        = Color(hex: 0x1F2229)   // champs de recherche
    static let surface3        = Color(hex: 0x25282F)   // pilules « Suivre » / « Voir le profil »
    static let rond            = Color(hex: 0x181D20)   // boutons ronds d'en-tête
    static let composer        = Color(hex: 0x181C1F)
    static let bulleRecue      = Color(hex: 0x21242B)
    static let bulleHaut       = Color(hex: 0xAD29D5)
    static let bulleBas        = Color(hex: 0x6B30FE)
    static let camera          = Color(hex: 0x5249FF)
    static let secondaire      = Color(hex: 0x6E7176)
    static let separateur      = Color(hex: 0x1B1E22)
    static let pastilleOnglet  = Color(hex: 0x2E3236)
    static let rouge           = Color(hex: 0xFF3B30)
    static let pointInactif    = Color(hex: 0x393C43)

    // Dégradé de l'anneau de story — relevés §2.3, décalé de 135° (jaune en bas-gauche).
    static let anneau = AngularGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: 0xD8BA00), location: 0.00),
            .init(color: Color(hex: 0xF19A0C), location: 0.12),
            .init(color: Color(hex: 0xF6122B), location: 0.25),
            .init(color: Color(hex: 0xE71197), location: 0.37),
            .init(color: Color(hex: 0xC916CA), location: 0.50),
            .init(color: Color(hex: 0xDD0AAF), location: 0.62),
            .init(color: Color(hex: 0xCE1384), location: 0.75),
            .init(color: Color(hex: 0xE4162D), location: 0.87),
            .init(color: Color(hex: 0xD8BA00), location: 1.00)
        ]),
        center: .center,
        angle: .degrees(135)
    )

    // Interpolation du dégradé des bulles envoyées, calculée à l'échelle de la conversation.
    static func bulle(_ t: Double) -> Color {
        let u = min(max(t, 0), 1)
        let r = (0xAD + (0x6B - 0xAD) * u) / 255.0
        let v = (0x29 + (0x30 - 0x29) * u) / 255.0
        let b = (0xD5 + (0xFE - 0xD5) * u) / 255.0
        return Color(red: r, green: v, blue: b)
    }
}

// ============================================================ 1. ICÔNES MAISON (Path, §2.4)
// Aucun SF Symbol sur ces rôles : le jeu d'icônes iOS 26 n'a pas d'équivalent système.

struct IgCoeurForme: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.move(to: CGPoint(x: x + w * 0.50, y: y + h * 0.96))
        p.addCurve(to: CGPoint(x: x + w * 0.02, y: y + h * 0.34),
                   control1: CGPoint(x: x + w * 0.17, y: y + h * 0.76),
                   control2: CGPoint(x: x + w * 0.02, y: y + h * 0.55))
        p.addArc(center: CGPoint(x: x + w * 0.26, y: y + h * 0.34), radius: w * 0.24,
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addArc(center: CGPoint(x: x + w * 0.74, y: y + h * 0.34), radius: w * 0.24,
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addCurve(to: CGPoint(x: x + w * 0.50, y: y + h * 0.96),
                   control1: CGPoint(x: x + w * 0.98, y: y + h * 0.55),
                   control2: CGPoint(x: x + w * 0.83, y: y + h * 0.76))
        p.closeSubpath()
        return p
    }
}

// Cercle parfait + petite queue triangulaire en bas — PAS une bulle rectangulaire.
struct IgBulleForme: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.addEllipse(in: CGRect(x: x + w * 0.03, y: y + h * 0.02, width: w * 0.94, height: h * 0.86))
        p.move(to: CGPoint(x: x + w * 0.26, y: y + h * 0.80))
        p.addLine(to: CGPoint(x: x + w * 0.13, y: y + h * 0.99))
        p.addLine(to: CGPoint(x: x + w * 0.46, y: y + h * 0.88))
        return p
    }
}

// Repost / remix : deux flèches en boucle verticale (style Threads).
struct IgRepostForme: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.move(to: CGPoint(x: x + w * 0.16, y: y + h * 0.32))
        p.addQuadCurve(to: CGPoint(x: x + w * 0.84, y: y + h * 0.32),
                       control: CGPoint(x: x + w * 0.50, y: y + h * 0.02))
        p.addLine(to: CGPoint(x: x + w * 0.84, y: y + h * 0.70))
        p.move(to: CGPoint(x: x + w * 0.68, y: y + h * 0.55))
        p.addLine(to: CGPoint(x: x + w * 0.84, y: y + h * 0.74))
        p.addLine(to: CGPoint(x: x + w * 1.00, y: y + h * 0.55))
        p.move(to: CGPoint(x: x + w * 0.84, y: y + h * 0.68))
        p.addQuadCurve(to: CGPoint(x: x + w * 0.16, y: y + h * 0.68),
                       control: CGPoint(x: x + w * 0.50, y: y + h * 0.98))
        p.addLine(to: CGPoint(x: x + w * 0.16, y: y + h * 0.30))
        p.move(to: CGPoint(x: x + w * 0.32, y: y + h * 0.45))
        p.addLine(to: CGPoint(x: x + w * 0.16, y: y + h * 0.26))
        p.addLine(to: CGPoint(x: x + w * 0.00, y: y + h * 0.45))
        return p
    }
}

// Envoyer : triangle inversé arrondi, pointe vers le bas, arête haute échancrée en V.
struct IgEnvoyerForme: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.move(to: CGPoint(x: x + w * 0.50, y: y + h * 0.99))
        p.addLine(to: CGPoint(x: x + w * 0.03, y: y + h * 0.07))
        p.addLine(to: CGPoint(x: x + w * 0.50, y: y + h * 0.31))
        p.addLine(to: CGPoint(x: x + w * 0.97, y: y + h * 0.07))
        p.closeSubpath()
        return p
    }
}

struct IgSignetForme: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.move(to: CGPoint(x: x + w * 0.12, y: y + h * 0.03))
        p.addLine(to: CGPoint(x: x + w * 0.88, y: y + h * 0.03))
        p.addLine(to: CGPoint(x: x + w * 0.88, y: y + h * 0.97))
        p.addLine(to: CGPoint(x: x + w * 0.50, y: y + h * 0.66))
        p.addLine(to: CGPoint(x: x + w * 0.12, y: y + h * 0.97))
        p.closeSubpath()
        return p
    }
}

// Menu d'une publication : deux traits horizontaux, le supérieur long, l'inférieur court.
struct IgMenuDeuxTraits: View {
    var largeur: CGFloat = 22
    var couleur: Color = .white
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Capsule().fill(couleur).frame(width: largeur, height: 2)
            Capsule().fill(couleur).frame(width: largeur * 0.64, height: 2)
        }
        .frame(width: largeur, alignment: .leading)
    }
}

// Barre de story : « flip » = rectangle arrondi entre deux parenthèses.
struct IgFlipForme: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.addRoundedRect(in: CGRect(x: x + w * 0.28, y: y + h * 0.06,
                                    width: w * 0.44, height: h * 0.88),
                         cornerSize: CGSize(width: w * 0.10, height: w * 0.10))
        p.move(to: CGPoint(x: x + w * 0.14, y: y + h * 0.18))
        p.addQuadCurve(to: CGPoint(x: x + w * 0.14, y: y + h * 0.82),
                       control: CGPoint(x: x - w * 0.02, y: y + h * 0.50))
        p.move(to: CGPoint(x: x + w * 0.86, y: y + h * 0.18))
        p.addQuadCurve(to: CGPoint(x: x + w * 0.86, y: y + h * 0.82),
                       control: CGPoint(x: x + w * 1.02, y: y + h * 0.50))
        return p
    }
}

// Onglet Reels de la barre : play dans un carré arrondi.
struct IgReelForme: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.addRoundedRect(in: CGRect(x: x + w * 0.04, y: y + h * 0.10,
                                    width: w * 0.92, height: h * 0.80),
                         cornerSize: CGSize(width: w * 0.20, height: w * 0.20))
        p.move(to: CGPoint(x: x + w * 0.40, y: y + h * 0.30))
        p.addLine(to: CGPoint(x: x + w * 0.72, y: y + h * 0.50))
        p.addLine(to: CGPoint(x: x + w * 0.40, y: y + h * 0.70))
        p.closeSubpath()
        return p
    }
}

// Composer un message (carré + crayon), en-tête de la liste DM.
struct IgComposerForme: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.move(to: CGPoint(x: x + w * 0.58, y: y + h * 0.08))
        p.addLine(to: CGPoint(x: x + w * 0.16, y: y + h * 0.08))
        p.addLine(to: CGPoint(x: x + w * 0.16, y: y + h * 0.92))
        p.addLine(to: CGPoint(x: x + w * 0.92, y: y + h * 0.92))
        p.addLine(to: CGPoint(x: x + w * 0.92, y: y + h * 0.48))
        p.move(to: CGPoint(x: x + w * 0.46, y: y + h * 0.62))
        p.addLine(to: CGPoint(x: x + w * 0.92, y: y + h * 0.14))
        p.addLine(to: CGPoint(x: x + w * 1.02, y: y + h * 0.24))
        p.addLine(to: CGPoint(x: x + w * 0.56, y: y + h * 0.72))
        p.closeSubpath()
        return p
    }
}

// ============================================================ 2. DONNÉES (contenu Sarah, D59)
struct IgCompte: Identifiable, Equatable {
    let id: String                 // pseudo
    var nom: String
    var photo: String? = nil
    var teinte: UInt = 0x5B7CFA
    var prive: Bool = false
    var verifie: Bool = false
    var bio: String = ""
    var lien: String? = nil
    var publications: String = "0"
    var followers: String = "0"
    var suivis: String = "0"
    var enStory: Bool = false
    var grille: [String] = []
    static func == (g: IgCompte, d: IgCompte) -> Bool { g.id == d.id }
}

struct IgCommentaire: Identifiable {
    let id: String
    var compte: IgCompte
    var texte: String
    var quand: String
    var jaime: Int = 0
}

struct IgPost: Identifiable {
    let id: String
    var compte: IgCompte
    var lieu: String? = nil
    var audio: String? = nil
    var images: [String]
    var carrouselGrille: Bool = false      // e001 : les 4 vues du carrousel en grille 2×2
    var jaime: String
    var nbCommentaires: String
    var reposts: String
    var envois: String
    var aimePar: String
    var avatarsAimePar: [String]
    var legende: String
    var date: String
    var sponsorise: Bool = false
    var cta: String? = nil
    var commentaires: [IgCommentaire] = []
}

struct IgMessage: Identifiable {
    let id: String
    var deMoi: Bool
    var texte: String
}

struct IgConversation: Identifiable {
    let id: String
    var compte: IgCompte
    var apercu: String
    var nonLu: Bool = false
    var demande: Bool = false
    var separateur: String = "2 JUIN À 02:26"
    var messages: [IgMessage]
}

struct IgNote: Identifiable {
    let id: String
    var compte: IgCompte
    var texte: String
    var sousTitre: String
    var violette: Bool = false
}

enum DonneesInsta {
    // ---------- comptes
    static let sarah = IgCompte(
        id: "sarah.lvsr", nom: "Sarah Levasseur", photo: "p04", teinte: 0x5B7CFA,
        bio: "Lyon 🌸 photo argentique, céramique et randos\n📷 les pellicules du week-end",
        lien: "sarahlevasseur.myportfolio.com",
        publications: "47", followers: "486", suivis: "512",
        grille: ["p30", "p31", "p32", "p33", "p34", "p35", "p36", "p37", "p38", "p39", "p40", "p41"])

    static let chloe = IgCompte(
        id: "chloe.brt", nom: "Chloé Berthier", photo: "p12", teinte: 0xE64980,
        bio: "Annecy → Lyon\nfromages, lacs et mauvaises blagues",
        publications: "132", followers: "918", suivis: "744", enStory: true,
        grille: ["p20", "p21", "p22", "p23", "p24", "p25", "p26", "p27", "p28"])

    static let ines = IgCompte(
        id: "ines.djl", nom: "Inès Djellal", photo: nil, teinte: 0x8B5CF6,
        bio: "infirmière · Lyon 7e\nje cours plus vite que mes plannings",
        publications: "58", followers: "412", suivis: "389", enStory: true,
        grille: ["p22", "p25", "p28", "p31", "p34", "p37"])

    static let atelier = IgCompte(
        id: "atelierpoterie.lyon3", nom: "Atelier Poterie Lyon 3", photo: nil, teinte: 0xFF9F0A,
        verifie: false,
        bio: "Cours de tournage & modelage · Lyon 3e\nInscriptions septembre ouvertes",
        lien: "atelierpoterie-lyon3.fr",
        publications: "214", followers: "3 108", suivis: "182", enStory: true,
        grille: ["p33", "p36", "p39", "p21", "p24", "p27"])

    static let lea = IgCompte(
        id: "lea.mrx", nom: "Léa ☀️", photo: "p18", teinte: 0x30D1C4, prive: true,
        lien: "vsco.co/leamoreau",
        publications: "2", followers: "223", suivis: "233", enStory: true)

    static let lyon = IgCompte(
        id: "lyon.maville", nom: "Lyon Ma Ville", photo: nil, teinte: 0x0A84FF, verifie: true,
        bio: "Ce qui se passe à Lyon, tous les jours ☀️",
        lien: "lyonmaville.fr",
        publications: "4 872", followers: "128 K", suivis: "312", enStory: true,
        grille: ["p36", "p29", "p32", "p35", "p38", "p41"])

    // Marc — le compte par lequel arrive l'arnaque sentimentale (fil narratif du jeu).
    static let marc = IgCompte(
        id: "marc.dlny", nom: "Marc Delaunay", photo: nil, teinte: 0x2F6F5F,
        bio: "Ingénieur offshore · actuellement au large de Malte\nla photo, la mer, le reste suit",
        publications: "6", followers: "94", suivis: "1 380", enStory: true,
        grille: ["p26", "p29", "p23"])

    static let comptes: [IgCompte] = [chloe, ines, atelier, lea, lyon, marc]

    // ---------- commentaires
    private static func c(_ n: Int, _ compte: IgCompte, _ t: String, _ q: String, _ j: Int) -> IgCommentaire {
        IgCommentaire(id: "c\(n)", compte: compte, texte: t, quand: q, jaime: j)
    }
    static let commentairesAnnecy: [IgCommentaire] = [
        c(1, ines,    "Les couleurs de la 3e photo 😍 c'est quelle pellicule ?", "23 h", 4),
        c(2, sarah,   "@ines.djl Portra 400, et un ciel qui a fait tout le boulot ☁️", "22 h", 2),
        c(3, atelier, "Superbe série ! On vous attend au cours de mardi 🏺", "8 h", 0),
        c(4, lyon,    "Magnifique 👏", "9 h", 1),
        c(5, marc,    "Tu as un œil incroyable. J'aimerais tellement voir ça en vrai un jour.", "23 h", 0)
    ]
    static let commentairesParc: [IgCommentaire] = [
        c(6, chloe, "Bon bah je sais où je vais dimanche 🌇", "5 h", 3),
        c(7, ines,  "On y va ensemble ?", "4 h", 0)
    ]
    static let commentairesAtelier: [IgCommentaire] = [
        c(8, sarah, "Le grand bol émaillé est de moi 🥹", "2 j", 6),
        c(9, chloe, "Trop fière de toi", "2 j", 2)
    ]

    // ---------- publications du feed
    static let posts: [IgPost] = [
        IgPost(id: "post.annecy", compte: chloe, lieu: "Lac d'Annecy",
               audio: "chloe.brt · Audio d'origine",
               images: ["p30", "p31", "p32", "p33"], carrouselGrille: true,
               jaime: "87", nbCommentaires: "5", reposts: "12", envois: "23",
               aimePar: "Aimé par ines.djl et d'autres personnes",
               avatarsAimePar: ["p18", "p04", "p12"],
               legende: "4/4 🏆 Week-end parfait avec la meilleure 💙 Départ à 6 h, brume sur le lac, et une pellicule entière brûlée avant midi. #annecy #argentique",
               date: "Il y a 6 heures",
               commentaires: commentairesAnnecy),

        IgPost(id: "post.sponso", compte: IgCompte(id: "atelier.lumiere.fr", nom: "Atelier Lumière",
                                                   photo: nil, teinte: 0xC2410C,
                                                   bio: "Stages de photo argentique en Rhône-Alpes",
                                                   publications: "88", followers: "12,4 K", suivis: "41"),
               lieu: nil, audio: nil, images: ["p35"],
               jaime: "1 204", nbCommentaires: "48", reposts: "31", envois: "212",
               aimePar: "Aimé par atelierpoterie.lyon3 et d'autres personnes",
               avatarsAimePar: ["p12"],
               legende: "Trois jours de stage argentique dans le Beaujolais, labo compris. Places limitées pour octobre… ",
               date: "Il y a 1 jour", sponsorise: true, cta: "S'inscrire",
               commentaires: []),

        IgPost(id: "post.parc", compte: lyon, lieu: "Parc de la Tête d'Or",
               audio: "lyon.maville · Audio d'origine",
               images: ["p36"],
               jaime: "1 892", nbCommentaires: "2", reposts: "204", envois: "1 038",
               aimePar: "Aimé par chloe.brt et d'autres personnes",
               avatarsAimePar: ["p12", "p04"],
               legende: "L'été indien s'installe sur le parc 🌇 Les meilleures heures : entre 18 h et 19 h 30, avant que la roseraie ne ferme.",
               date: "Il y a 3 semaines",
               commentaires: commentairesParc),

        IgPost(id: "post.poterie", compte: atelier, lieu: "Lyon 3e",
               audio: nil, images: ["p33", "p39"],
               jaime: "214", nbCommentaires: "2", reposts: "8", envois: "37",
               aimePar: "Aimé par sarah.lvsr et d'autres personnes",
               avatarsAimePar: ["p04", "p18"],
               legende: "Les créations du cours du mardi soir 🏺 Inscriptions ouvertes pour septembre !",
               date: "Il y a 2 semaines",
               commentaires: commentairesAtelier)
    ]

    // Publication de Sarah ouverte depuis sa grille (écran « Publications », e170).
    static let postSarah = IgPost(
        id: "post.sarah.brume", compte: sarah, lieu: "Croix-Rousse, Lyon",
        audio: nil, images: ["p30", "p34", "p38", "p41"],
        jaime: "25", nbCommentaires: "2", reposts: "0", envois: "7",
        aimePar: "Aimé par chloe.brt et d'autres personnes",
        avatarsAimePar: ["p12", "p18", "p04"],
        legende: "🇫🇷 Brume sur les pentes, 7 h du matin",
        date: "17 février 2026",
        commentaires: [
            IgCommentaire(id: "cs1", compte: chloe, texte: "En mode photographe de rue 😍", quand: "2 j", jaime: 1),
            IgCommentaire(id: "cs2", compte: ines,  texte: "La chance !", quand: "2 j", jaime: 0)
        ])

    // ---------- conversations (grammaire d'aperçu relevée en e072)
    static let conversations: [IgConversation] = [
        IgConversation(id: "dm.chloe", compte: chloe,
                       apercu: "+ de 4 nouveaux messages · 5 s", nonLu: true,
                       separateur: "2 JUIN À 02:26",
                       messages: [
                        IgMessage(id: "m1", deMoi: false, texte: "Regarde ce que j'ai retrouvé du week-end 😍"),
                        IgMessage(id: "m2", deMoi: false, texte: "La photo du ponton est incroyable"),
                        IgMessage(id: "m3", deMoi: true,  texte: "Ahah je l'avais oubliée celle-là"),
                        IgMessage(id: "m4", deMoi: true,  texte: "Je te fais un tirage si tu veux"),
                        IgMessage(id: "m5", deMoi: false, texte: "Oui !! Et on remet ça en octobre ?"),
                        IgMessage(id: "m6", deMoi: false, texte: "Je regarde les dates ce soir")
                       ]),

        IgConversation(id: "dm.marc", compte: marc,
                       apercu: "Je pense à toi. Tu as pu regarder pour le virement ? · 2 h", nonLu: true,
                       separateur: "HIER À 21:14",
                       messages: [
                        IgMessage(id: "n1", deMoi: false, texte: "Bonsoir Sarah. La liaison satellite est enfin revenue."),
                        IgMessage(id: "n2", deMoi: true,  texte: "Ah enfin ! Je commençais à m'inquiéter"),
                        IgMessage(id: "n3", deMoi: false, texte: "La compagnie a bloqué mon compte le temps de la relève. Je n'ai plus accès à rien depuis la plateforme."),
                        IgMessage(id: "n4", deMoi: false, texte: "Je n'aime pas te demander ça."),
                        IgMessage(id: "n5", deMoi: true,  texte: "Demander quoi ?"),
                        IgMessage(id: "n6", deMoi: false, texte: "Je pense à toi. Tu as pu regarder pour le virement ?")
                       ]),

        IgConversation(id: "dm.ines", compte: ines,
                       apercu: "Vous : je t'envoie les photos ce soir · 12 s",
                       separateur: "MARDI À 18:02",
                       messages: [
                        IgMessage(id: "o1", deMoi: false, texte: "T'as réussi à scanner la pellicule ?"),
                        IgMessage(id: "o2", deMoi: true,  texte: "Presque, il m'en reste 6"),
                        IgMessage(id: "o3", deMoi: true,  texte: "je t'envoie les photos ce soir")
                       ]),

        IgConversation(id: "dm.lea", compte: lea,
                       apercu: "En ligne il y a 18 minutes",
                       separateur: "DIMANCHE À 11:47",
                       messages: [
                        IgMessage(id: "p1", deMoi: true,  texte: "Coucou ! J'ai vu que t'étais passée en privé"),
                        IgMessage(id: "p2", deMoi: false, texte: "Oui, trop de comptes bizarres qui m'écrivaient"),
                        IgMessage(id: "p3", deMoi: false, texte: "Fais gaffe toi aussi hein")
                       ]),

        IgConversation(id: "dm.atelier", compte: atelier,
                       apercu: "4 nouveaux messages · 27 s", nonLu: true,
                       separateur: "LUNDI À 09:30",
                       messages: [
                        IgMessage(id: "q1", deMoi: false, texte: "Bonjour Sarah !"),
                        IgMessage(id: "q2", deMoi: false, texte: "Votre bol est sorti du four, il est superbe"),
                        IgMessage(id: "q3", deMoi: false, texte: "Vous pouvez passer le récupérer cette semaine"),
                        IgMessage(id: "q4", deMoi: false, texte: "L'atelier est ouvert jusqu'à 19 h")
                       ]),

        IgConversation(id: "dm.lyon", compte: lyon,
                       apercu: "Vous : merci pour le repost ! · 3 j",
                       separateur: "31 MAI À 14:05",
                       messages: [
                        IgMessage(id: "r1", deMoi: false, texte: "On a partagé votre photo du parc en story, merci !"),
                        IgMessage(id: "r2", deMoi: true,  texte: "merci pour le repost !")
                       ]),

        IgConversation(id: "dm.demande", compte: IgCompte(id: "alex_mtn_photo", nom: "Alexandre M.",
                                                          photo: nil, teinte: 0x7A5CFF,
                                                          publications: "1", followers: "12", suivis: "2 904"),
                       apercu: "Bonjour, j'ai vu votre travail et… · 6 j", demande: true,
                       separateur: "28 MAI À 22:41",
                       messages: [
                        IgMessage(id: "s1", deMoi: false, texte: "Bonjour, j'ai vu votre travail et je le trouve magnifique.")
                       ])
    ]

    // ---------- notes de la liste DM (e072)
    static let notes: [IgNote] = [
        IgNote(id: "note.chloe", compte: chloe, texte: "on repart quand ?", sousTitre: "📍 Annecy"),
        IgNote(id: "note.ines",  compte: ines,  texte: "garde de nuit 😵", sousTitre: "Lyon 7e", violette: true),
        IgNote(id: "note.lyon",  compte: lyon,  texte: "coucher de soleil 🌇", sousTitre: "📍 Tête d'Or")
    ]

    // ---------- stories à la une du profil
    static let alaune: [(String, String)] = [
        ("Annecy 26", "p30"), ("Argentique", "p34"), ("Céramique", "p33"), ("Randos", "p38")
    ]

    // ---------- mosaïque Explore
    static let mosaique: [String] = ["p20", "p21", "p22", "p23", "p24", "p25", "p26", "p27", "p28",
                                     "p29", "p30", "p31", "p32", "p33", "p34", "p35", "p36", "p37",
                                     "p38", "p39", "p40"]

    static let vues: [String] = ["377 K", "46,7 K", "338 K", "612 K", "1,8 M", "92,4 K", "12,1 K"]

    static func compte(_ pseudo: String) -> IgCompte {
        if pseudo == sarah.id { return sarah }
        return comptes.first(where: { $0.id == pseudo }) ?? chloe
    }
}

// ============================================================ 3. ÉTAT (tout le mutable, D-SwiftUI)
enum IgOverlay: Equatable {
    case story(String)          // pseudo du compte
    case profil(String)         // pseudo
    case detail(String)         // identifiant de publication
    case fil(String)            // identifiant de conversation
    case notifications
    case reglagesFil(String)
}

enum IgFeuille: Equatable {
    case commentaires(String)
    case partage(String)
    case options(String)
    case menuFlux
    case creation
    case actionsProfil
    case pellicule(String)      // envoyer une photo dans une conversation
}

final class IgEtat: ObservableObject {
    @Published var onglet: Int = 0
    @Published var flux: String = "Pour vous"
    @Published var aimes: Set<String> = []
    @Published var enregistres: Set<String> = []
    @Published var suivis: Set<String> = []
    @Published var commentairesAjoutes: [String: [IgCommentaire]] = [:]
    @Published var messagesEnvoyes: [String: [IgMessage]] = [:]
    @Published var lus: Set<String> = []
    @Published var ongletDM: Int = 0
    @Published var ongletProfil: Int = 0
    @Published var recherche: String = ""
    @Published var pile: [IgOverlay] = []
    @Published var feuille: IgFeuille? = nil
    @Published var info: String? = nil
    @Published var coeurVolant: String? = nil

    var sommet: IgOverlay? { pile.last }
    var chromeVisible: Bool { pile.isEmpty }

    func ouvrir(_ o: IgOverlay) { Haptique.leger(); pile.append(o) }
    func fermer() { if !pile.isEmpty { pile.removeLast() } }
    func fermerTout() { pile.removeAll() }

    func basculerJaime(_ cle: String) { Haptique.leger(); if aimes.contains(cle) { aimes.remove(cle) } else { aimes.insert(cle) } }
    func aimer(_ cle: String) { if !aimes.contains(cle) { Haptique.leger(); aimes.insert(cle) } ; coeurVolant = cle }
    func basculerEnregistre(_ cle: String) {
        Haptique.leger()
        if enregistres.contains(cle) { enregistres.remove(cle); info = "Retiré des publications enregistrées" }
        else { enregistres.insert(cle); info = "Enregistré" }
    }
    func basculerSuivi(_ pseudo: String) { Haptique.leger(); if suivis.contains(pseudo) { suivis.remove(pseudo) } else { suivis.insert(pseudo) } }

    func commentaires(_ post: IgPost) -> [IgCommentaire] { post.commentaires + (commentairesAjoutes[post.id] ?? []) }
    func ajouterCommentaire(_ texte: String, sur post: IgPost) {
        let t = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        Haptique.leger()
        var liste = commentairesAjoutes[post.id] ?? []
        liste.append(IgCommentaire(id: "ajout.\(post.id).\(liste.count)", compte: DonneesInsta.sarah, texte: t, quand: "à l'instant", jaime: 0))
        commentairesAjoutes[post.id] = liste
    }

    func messages(_ conv: IgConversation) -> [IgMessage] { conv.messages + (messagesEnvoyes[conv.id] ?? []) }
    func envoyer(_ texte: String, dans conv: IgConversation) {
        let t = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        Haptique.leger()
        var liste = messagesEnvoyes[conv.id] ?? []
        liste.append(IgMessage(id: "env.\(conv.id).\(liste.count)", deMoi: true, texte: t))
        messagesEnvoyes[conv.id] = liste
        lus.insert(conv.id)
    }

    func signaler(_ texte: String) { Haptique.leger(); info = texte }
}

enum IgOutils {
    /// Incrémente un compteur affiché quand il est purement numérique (« 87 » → « 88 »),
    /// laisse « 138 K » ou « 1,8 M » intacts : on n'invente pas une précision qu'on n'a pas.
    static func incremente(_ valeur: String, de delta: Int) -> String {
        let brut = valeur.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\u{202F}", with: "")
        guard let n = Int(brut) else { return valeur }
        let r = n + delta
        if r >= 1000 {
            let milliers = r / 1000, reste = r % 1000
            return "\(milliers) " + String(format: "%03d", reste)
        }
        return "\(r)"
    }
}

// ============================================================ 4. BRIQUES COMMUNES
struct IgPhoto: View {
    let cle: String?
    var teinte: UInt = 0x2A2E35
    var body: some View {
        Color.clear
            .overlay(contenu)
            .clipped()
    }
    @ViewBuilder private var contenu: some View {
        if let c = cle, let img = ChargeurPhoto.image(c) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            LinearGradient(colors: [Color(hex: teinte), Color(hex: teinte).opacity(0.55)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct IgAvatar: View {
    let compte: IgCompte
    var taille: CGFloat = 44
    var anneau: Bool = false
    var anneauGris: Bool = false

    private var trait: CGFloat { max(1.8, taille * 0.042) }
    private var exterieur: CGFloat { (anneau || anneauGris) ? taille + trait * 4 : taille }

    var body: some View {
        ZStack {
            if anneau {
                Circle().strokeBorder(IgTheme.anneau, lineWidth: trait)
                    .frame(width: exterieur, height: exterieur)
            } else if anneauGris {
                Circle().strokeBorder(Color(hex: 0x4A4E55), lineWidth: trait * 0.6)
                    .frame(width: exterieur, height: exterieur)
            }
            pastille.frame(width: taille, height: taille).clipShape(Circle())
        }
        .frame(width: exterieur, height: exterieur)
    }

    @ViewBuilder private var pastille: some View {
        if compte.photo != nil {
            IgPhoto(cle: compte.photo, teinte: compte.teinte)
        } else {
            Circle().fill(Color(hex: compte.teinte))
                .overlay(Text(String(compte.nom.prefix(1)).uppercased())
                    .font(.system(size: taille * 0.42, weight: .semibold))
                    .foregroundStyle(.white))
        }
    }
}

struct IgAvatarSilhouette: View {
    var taille: CGFloat = 79
    var body: some View {
        Circle().fill(Color(hex: 0xE0E4E7))
            .frame(width: taille, height: taille)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: taille * 0.55))
                    .foregroundStyle(Color(hex: 0x9AA1A8))
                    .offset(y: taille * 0.05)
            )
            .clipShape(Circle())
    }
}

struct IgPileAvatars: View {
    let cles: [String]
    var taille: CGFloat = 13
    var body: some View {
        HStack(spacing: -taille * 0.35) {
            ForEach(Array(cles.prefix(3).enumerated()), id: \.offset) { _, c in
                IgPhoto(cle: c)
                    .frame(width: taille, height: taille)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(IgTheme.fond, lineWidth: 1))
            }
        }
    }
}

struct IgBoutonRond: View {
    let systeme: String
    var diametre: CGFloat = 40
    var taille: CGFloat = 17
    var fond: Color = IgTheme.rond
    var action: () -> Void
    var body: some View {
        Button(action: { Haptique.leger(); action() }) {
            Circle().fill(fond)
                .frame(width: diametre, height: diametre)
                .overlay(Image(systemName: systeme).font(.system(size: taille, weight: .semibold)).foregroundStyle(.white))
        }
        .buttonStyle(.plain)
    }
}

/// Icône maison + compteur inline (§2.4). Chaque groupe est une cible tactile propre.
struct IgIconeCompteur<Forme: Shape>: View {
    let forme: Forme
    var taille: CGFloat = 21
    var trait: CGFloat = 1.7
    var compteur: String? = nil
    var pleine: Bool = false
    var couleur: Color = .white
    var action: () -> Void
    var body: some View {
        HStack(spacing: 5) {
            Group {
                if pleine { forme.fill(couleur) } else { forme.stroke(couleur, style: StrokeStyle(lineWidth: trait, lineCap: .round, lineJoin: .round)) }
            }
            .frame(width: taille, height: taille)
            if let c = compteur, !c.isEmpty {
                Text(c).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }
}

enum IgGrille {
    static var largeurEcran: CGFloat { UIScreen.main.bounds.width }
    static var cellule: CGFloat { (largeurEcran - 3) / 3 }
}

struct IgSeparateur: View {
    var body: some View { Rectangle().fill(IgTheme.separateur).frame(height: 0.5) }
}

struct IgBadgeVerifie: View {
    var taille: CGFloat = 12
    var body: some View {
        Image(systemName: "checkmark.seal.fill")
            .font(.system(size: taille))
            .foregroundStyle(IgTheme.lien)
    }
}

// ============================================================ 5. RACINE + BARRE D'ONGLETS (e001, e072, e197)
struct InstagramVue: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var etat = IgEtat()
    var ongletInitial: Int = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0

    var body: some View {
        ZStack(alignment: .bottom) {
            IgTheme.fond.ignoresSafeArea()
            contenu
            if etat.chromeVisible { IgBarreOnglets(etat: etat) }
            IgCoucheOverlays(etat: etat)
            IgCoucheFeuilles(etat: etat)
            IgToast(etat: etat)
            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
        .onAppear { if etat.onglet != ongletInitial { etat.onglet = ongletInitial } }
    }

    @ViewBuilder private var contenu: some View {
        switch etat.onglet {
        case 1: IgReelsVue(etat: etat)
        case 2: IgDMListeVue(etat: etat)
        case 3: IgRechercheVue(etat: etat)
        case 4: IgProfilVue(etat: etat)
        default: IgFeedVue(etat: etat)
        }
    }
}

struct IgBarreOnglets: View {
    @ObservedObject var etat: IgEtat

    var body: some View {
        HStack(spacing: 0) {
            cellule(0) { AnyView(Image(systemName: etat.onglet == 0 ? "house.fill" : "house").font(.system(size: 21))) }
            cellule(1) { AnyView(IgReelForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round)).frame(width: 23, height: 23)) }
            cellule(2) { AnyView(pastilleDM) }
            cellule(3) { AnyView(Image(systemName: "magnifyingglass").font(.system(size: 21, weight: etat.onglet == 3 ? .semibold : .regular))) }
            cellule(4) { AnyView(IgAvatar(compte: DonneesInsta.sarah, taille: 26)) }
        }
        .foregroundStyle(.white)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(Capsule().fill(Color(hex: 0x111417).opacity(0.94)))
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5))
        .padding(.horizontal, 16)
        .padding(.bottom, 26)
    }

    private var pastilleDM: some View {
        ZStack(alignment: .bottomTrailing) {
            IgEnvoyerForme()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))
                .frame(width: 21, height: 21)
            Circle().fill(IgTheme.rouge).frame(width: 6, height: 6).offset(x: 3, y: 1)
        }
    }

    private func cellule(_ index: Int, @ViewBuilder _ icone: () -> AnyView) -> some View {
        let actif = etat.onglet == index
        return ZStack {
            if actif {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(IgTheme.pastilleOnglet)
                    .frame(width: 78, height: 41)
            }
            icone()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); etat.fermerTout(); etat.onglet = index }
    }
}

struct IgToast: View {
    @ObservedObject var etat: IgEtat
    var body: some View {
        VStack {
            Spacer()
            if let texte = etat.info {
                Text(texte)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 11)
                    .background(Capsule().fill(Color(hex: 0x2A2E35)))
                    .padding(.bottom, 96)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            if etat.info == texte { etat.info = nil }
                        }
                    }
            }
        }
        .allowsHitTesting(false)
    }
}

// ============================================================ 6. FEED (e001, e003)
struct IgFeedVue: View {
    @ObservedObject var etat: IgEtat

    private var postsFiltres: [IgPost] {
        switch etat.flux {
        case "Suivi(e)s": return DonneesInsta.posts.filter { !$0.sponsorise }
        case "Favoris":   return DonneesInsta.posts.filter { $0.compte.id == DonneesInsta.chloe.id || $0.compte.id == DonneesInsta.ines.id }
        default:          return DonneesInsta.posts
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            IgEnteteFeed(etat: etat)
            ScrollView {
                LazyVStack(spacing: 0) {
                    IgRangeeStories(etat: etat)
                    IgSeparateur()
                    ForEach(postsFiltres) { p in
                        IgPostVue(post: p, etat: etat)
                    }
                    if postsFiltres.isEmpty {
                        IgEtatVide(titre: "Rien de neuf ici",
                                   texte: "Aucune publication récente dans « \(etat.flux) ».")
                            .padding(.top, 60)
                    }
                    Color.clear.frame(height: 110)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct IgEnteteFeed: View {
    @ObservedObject var etat: IgEtat
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium)).foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); etat.feuille = .creation }
                Spacer()
                ZStack(alignment: .topTrailing) {
                    IgCoeurForme()
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))
                        .frame(width: 21, height: 21)
                    Circle().fill(IgTheme.rouge).frame(width: 5.5, height: 5.5).offset(x: 3, y: -2)
                }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .onTapGesture { etat.ouvrir(.notifications) }
            }
            HStack(spacing: 6) {
                Text(etat.flux).font(.system(size: 24, weight: .bold)).foregroundStyle(.white)
                Image(systemName: "chevron.down").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
            }
            .padding(.horizontal, 10).padding(.vertical, 6)
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); etat.feuille = .menuFlux }
        }
        .frame(height: 46)
        .padding(.horizontal, 16)
    }
}

// ---------- Rangée de stories : un SEUL gabarit (§2.2, correction §4.1)
struct IgRangeeStories: View {
    @ObservedObject var etat: IgEtat
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                IgCelluleVotreStory(etat: etat)
                ForEach(DonneesInsta.comptes) { c in
                    IgCelluleStory(compte: c, etat: etat)
                }
            }
            .padding(.horizontal, 7.25)     // 13 pt du bord au bord de l'anneau
        }
        .padding(.top, 2)
        .padding(.bottom, 10)
    }
}

struct IgCelluleStory: View {
    let compte: IgCompte
    @ObservedObject var etat: IgEtat
    var body: some View {
        VStack(spacing: 9) {
            IgAvatar(compte: compte, taille: 79, anneau: true)
            Text(compte.id)
                .font(.system(size: 12))
                .foregroundStyle(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 100)
        }
        .frame(width: 104.5)
        .contentShape(Rectangle())
        .onTapGesture { etat.ouvrir(.story(compte.id)) }
    }
}

struct IgCelluleVotreStory: View {
    @ObservedObject var etat: IgEtat
    var body: some View {
        VStack(spacing: 9) {
            ZStack(alignment: .bottomTrailing) {
                IgAvatarSilhouette(taille: 79)
                Circle().fill(Color.black)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                    .overlay(Image(systemName: "plus").font(.system(size: 10, weight: .bold)).foregroundStyle(.white))
                    .offset(x: 1, y: -2)
            }
            .frame(width: 92.3, height: 92.3)
            Text("Votre story")
                .font(.system(size: 12))
                .foregroundStyle(IgTheme.secondaire)
                .lineLimit(1)
                .frame(width: 100)
        }
        .frame(width: 104.5)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); etat.feuille = .creation }
    }
}

// ============================================================ 7. PUBLICATION (e001, e003, e197)
struct IgPostVue: View {
    let post: IgPost
    @ObservedObject var etat: IgEtat
    @State private var page: Int = 0
    @State private var coeur: Bool = false

    private var aime: Bool { etat.aimes.contains(post.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            IgEntetePost(post: post, etat: etat)
            media
            if post.sponsorise { bandeauCTA }
            IgRangeeIconesPost(post: post, etat: etat)
            IgBlocTextePost(post: post, etat: etat)
        }
        .padding(.bottom, 12)
    }

    private var ratio: CGFloat { post.sponsorise ? 0.8 : 1.0 }

    private var media: some View {
        ZStack(alignment: .topTrailing) {
            if post.carrouselGrille {
                IgGrilleCarrousel(images: post.images)
            } else {
                IgPhoto(cle: post.images[min(page, post.images.count - 1)], teinte: post.compte.teinte)
                    .aspectRatio(ratio, contentMode: .fit)
            }
            if post.images.count > 1 {
                Text("\(post.carrouselGrille ? post.images.count : page + 1)/\(post.images.count)")
                    .font(.system(size: 12.5, weight: .semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(Capsule().fill(Color.black.opacity(0.6)))
                    .padding(12)
            }
            if coeur {
                Image(systemName: "heart.fill")
                    .font(.system(size: 92)).foregroundStyle(.white.opacity(0.92))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { doubleTap() }
        .onTapGesture { etat.ouvrir(.detail(post.id)) }
        .gesture(DragGesture(minimumDistance: 24).onEnded { v in
            guard post.images.count > 1, !post.carrouselGrille else { return }
            if v.translation.width < -30 { page = min(page + 1, post.images.count - 1) }
            if v.translation.width > 30 { page = max(page - 1, 0) }
        })
        .overlay(alignment: .bottom) {
            if post.images.count > 1 && !post.carrouselGrille {
                IgPointsPagination(total: post.images.count, actif: page).padding(.bottom, 10)
            }
        }
    }

    private func doubleTap() {
        etat.aimer(post.id)
        withAnimation(.spring(response: 0.28, dampingFraction: 0.5)) { coeur = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeOut(duration: 0.25)) { coeur = false }
        }
    }

    private var bandeauCTA: some View {
        HStack {
            Text(post.cta ?? "En savoir plus")
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Color(hex: 0x0B0D0F))
        .contentShape(Rectangle())
        .onTapGesture { etat.signaler("Lien indisponible hors connexion") }
    }
}

struct IgGrilleCarrousel: View {
    let images: [String]
    var body: some View {
        VStack(spacing: 1.5) {
            HStack(spacing: 1.5) {
                IgPhoto(cle: images.first).aspectRatio(1, contentMode: .fit)
                IgPhoto(cle: images.count > 1 ? images[1] : nil).aspectRatio(1, contentMode: .fit)
            }
            HStack(spacing: 1.5) {
                IgPhoto(cle: images.count > 2 ? images[2] : nil).aspectRatio(1, contentMode: .fit)
                IgPhoto(cle: images.count > 3 ? images[3] : nil).aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

struct IgPointsPagination: View {
    let total: Int
    let actif: Int
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == actif ? IgTheme.lien : IgTheme.pointInactif)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

struct IgEntetePost: View {
    let post: IgPost
    @ObservedObject var etat: IgEtat
    var body: some View {
        HStack(spacing: 10) {
            IgAvatar(compte: post.compte, taille: 34, anneau: post.compte.enStory)
                .contentShape(Circle())
                .onTapGesture { etat.ouvrir(.profil(post.compte.id)) }
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(post.compte.id).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    if post.compte.verifie { IgBadgeVerifie(taille: 12) }
                }
                if post.sponsorise {
                    Text("Sponsorisé").font(.system(size: 12.5)).foregroundStyle(.white.opacity(0.85))
                } else if let a = post.audio {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note").font(.system(size: 10))
                        Text(a).font(.system(size: 12.5)).lineLimit(1)
                    }
                    .foregroundStyle(.white.opacity(0.9))
                } else if let l = post.lieu {
                    Text(l).font(.system(size: 12.5)).foregroundStyle(.white.opacity(0.85))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { etat.ouvrir(.profil(post.compte.id)) }
            Spacer(minLength: 8)
            if post.sponsorise {
                Text(etat.suivis.contains(post.compte.id) ? "Suivi(e)" : "Suivre")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 69, height: 30)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(IgTheme.surface3))
                    .contentShape(Rectangle())
                    .onTapGesture { etat.basculerSuivi(post.compte.id) }
            }
            IgMenuDeuxTraits(largeur: 22)
                .frame(width: 34, height: 34, alignment: .trailing)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .options(post.id) }
        }
        .padding(.horizontal, 13).padding(.vertical, 9)
    }
}

struct IgRangeeIconesPost: View {
    let post: IgPost
    @ObservedObject var etat: IgEtat
    var avecRepost: Bool = true

    private var aime: Bool { etat.aimes.contains(post.id) }
    private var enregistre: Bool { etat.enregistres.contains(post.id) }

    var body: some View {
        HStack(spacing: 18) {
            IgIconeCompteur(forme: IgCoeurForme(), taille: 19,
                            compteur: IgOutils.incremente(post.jaime, de: aime ? 1 : 0),
                            pleine: aime, couleur: aime ? Color(hex: 0xFF3040) : Color.white) {
                etat.basculerJaime(post.id)
            }
            IgIconeCompteur(forme: IgBulleForme(), taille: 21,
                            compteur: "\(etat.commentaires(post).count)") {
                Haptique.leger(); etat.feuille = .commentaires(post.id)
            }
            if avecRepost {
                IgIconeCompteur(forme: IgRepostForme(), taille: 18, compteur: post.reposts) {
                    etat.signaler("Republié dans votre story")
                }
            }
            IgIconeCompteur(forme: IgEnvoyerForme(), taille: 17,
                            compteur: avecRepost ? post.envois : nil) {
                Haptique.leger(); etat.feuille = .partage(post.id)
            }
            Spacer(minLength: 0)
            IgIconeCompteur(forme: IgSignetForme(), taille: 20, trait: 1.8,
                            compteur: nil, pleine: enregistre) {
                etat.basculerEnregistre(post.id)
            }
        }
        .padding(.leading, 13).padding(.trailing, 15)
        .padding(.top, 4)
    }
}

struct IgBlocTextePost: View {
    let post: IgPost
    @ObservedObject var etat: IgEtat
    @State private var deplie = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 7) {
                IgPileAvatars(cles: post.avatarsAimePar, taille: 13)
                Text(post.aimePar).font(.system(size: 14)).foregroundStyle(.white).lineLimit(1)
            }
            legende
            Text(post.date).font(.system(size: 12)).foregroundStyle(IgTheme.secondaire)
        }
        .padding(.horizontal, 13).padding(.top, 6)
    }

    private var suffixe: String { post.sponsorise ? "détails" : "plus" }

    @ViewBuilder private var legende: some View {
        if deplie {
            (Text(post.compte.id + " ").font(.system(size: 14, weight: .semibold))
             + Text(post.legende).font(.system(size: 14)))
                .foregroundStyle(.white)
        } else {
            HStack(alignment: .top, spacing: 0) {
                (Text(post.compte.id + " ").font(.system(size: 14, weight: .semibold))
                 + Text(post.legende).font(.system(size: 14)))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(" " + suffixe).font(.system(size: 14)).foregroundStyle(IgTheme.secondaire)
            }
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(.easeInOut(duration: 0.15)) { deplie = true } }
        }
    }
}

struct IgEtatVide: View {
    let titre: String
    let texte: String
    var bouton: String? = nil
    var action: () -> Void = {}
    var body: some View {
        VStack(spacing: 10) {
            Text(titre).font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
            Text(texte).font(.system(size: 14)).foregroundStyle(IgTheme.secondaire)
                .multilineTextAlignment(.center).padding(.horizontal, 46)
            if let b = bouton {
                Text(b).font(.system(size: 14, weight: .semibold)).foregroundStyle(IgTheme.lien)
                    .padding(.top, 4)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); action() }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// ============================================================ 8. REELS (e041–e070, e193–e239)
struct IgReel: Identifiable {
    let id: String
    var compte: IgCompte
    var image: String
    var legende: String
    var audio: String
    var jaime: String
    var commentaires: String
    var reposts: String
    var envois: String
}

enum IgReels {
    static let liste: [IgReel] = [
        IgReel(id: "reel.rhone", compte: DonneesInsta.lyon, image: "p37",
               legende: "Coucher de soleil sur les quais du Rhône 🌅 la meilleure heure de Lyon",
               audio: "lyon.maville · Audio d'origine",
               jaime: "103 K", commentaires: "438", reposts: "899", envois: "18,8 K"),
        IgReel(id: "reel.tour", compte: DonneesInsta.atelier, image: "p39",
               legende: "3 minutes de tournage, 40 minutes de nettoyage 🏺",
               audio: "atelierpoterie.lyon3 · Audio d'origine",
               jaime: "12,4 K", commentaires: "96", reposts: "77", envois: "2 104"),
        IgReel(id: "reel.annecy", compte: DonneesInsta.chloe, image: "p31",
               legende: "6 h du matin, brume sur le lac, aucun regret",
               audio: "chloe.brt · Audio d'origine",
               jaime: "4 208", commentaires: "51", reposts: "18", envois: "612")
    ]
}

struct IgReelsVue: View {
    @ObservedObject var etat: IgEtat
    @State private var index: Int = 0
    @State private var flux: String = "Pour vous"

    private var reel: IgReel { IgReels.liste[min(index, IgReels.liste.count - 1)] }

    var body: some View {
        ZStack {
            IgPhoto(cle: reel.image, teinte: reel.compte.teinte).ignoresSafeArea()
            LinearGradient(colors: [.black.opacity(0.45), .clear, .clear, .black.opacity(0.55)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                entete
                Spacer()
                HStack(alignment: .bottom, spacing: 12) {
                    piedGauche
                    Spacer(minLength: 0)
                    IgRailReels(reel: reel, etat: etat)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 104)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 30).onEnded { v in
            if v.translation.height < -40 { Haptique.leger(); index = min(index + 1, IgReels.liste.count - 1) }
            if v.translation.height > 40 { Haptique.leger(); index = max(index - 1, 0) }
        })
    }

    private var entete: some View {
        HStack(spacing: 18) {
            Image(systemName: "plus").font(.system(size: 20, weight: .medium))
                .frame(width: 34, height: 40)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .creation }
            HStack(spacing: 6) {
                Text("Pour vous").font(.system(size: 21, weight: flux == "Pour vous" ? .bold : .regular))
                    .foregroundStyle(flux == "Pour vous" ? Color.white : Color.white.opacity(0.55))
                Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(flux == "Pour vous" ? Color.white : Color.white.opacity(0.55))
            }
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); flux = "Pour vous" }
            Text("Ami(e)s").font(.system(size: 21, weight: flux == "Ami(e)s" ? .bold : .regular))
                .foregroundStyle(flux == "Ami(e)s" ? Color.white : Color.white.opacity(0.55))
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); flux = "Ami(e)s" }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16).padding(.top, 6)
    }

    private var piedGauche: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 9) {
                IgAvatar(compte: reel.compte, taille: 32, anneau: true)
                    .contentShape(Circle())
                    .onTapGesture { etat.ouvrir(.profil(reel.compte.id)) }
                HStack(spacing: 4) {
                    Text(reel.compte.id).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    if reel.compte.verifie { IgBadgeVerifie(taille: 12) }
                }
                Text(etat.suivis.contains(reel.compte.id) ? "Suivi(e)" : "Suivre")
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 11).padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white.opacity(0.8), lineWidth: 1))
                    .contentShape(Rectangle())
                    .onTapGesture { etat.basculerSuivi(reel.compte.id) }
            }
            Text(reel.legende).font(.system(size: 13.5)).foregroundStyle(.white).lineLimit(2)
            HStack(spacing: 5) {
                Image(systemName: "music.note").font(.system(size: 11))
                Text(reel.audio).font(.system(size: 12)).lineLimit(1)
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: 260, alignment: .leading)
    }
}

struct IgRailReels: View {
    let reel: IgReel
    @ObservedObject var etat: IgEtat
    private var aime: Bool { etat.aimes.contains(reel.id) }
    var body: some View {
        VStack(spacing: 18) {
            bloc(AnyView(coeurReel), IgOutils.incremente(reel.jaime, de: aime ? 1 : 0), 26) { etat.basculerJaime(reel.id) }
            bloc(AnyView(IgBulleForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))),
                 reel.commentaires, 26) { etat.signaler("Commentaires du reel — TODO tournage") }
            bloc(AnyView(IgRepostForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))),
                 reel.reposts, 24) { etat.signaler("Republié dans votre story") }
            bloc(AnyView(IgEnvoyerForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))),
                 reel.envois, 23) { etat.feuille = .partage(reel.id) }
            IgMenuDeuxTraits(largeur: 20)
                .frame(width: 34, height: 24)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .options(reel.id) }
            IgPhoto(cle: reel.image, teinte: reel.compte.teinte)
                .frame(width: 27, height: 27)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.white.opacity(0.8), lineWidth: 1.2))
                .contentShape(Rectangle())
                .onTapGesture { etat.signaler(reel.audio) }
        }
        .frame(width: 46)
    }

    @ViewBuilder private var coeurReel: some View {
        if aime {
            IgCoeurForme().fill(Color(hex: 0xFF3040))
        } else {
            IgCoeurForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))
        }
    }

    private func bloc(_ icone: AnyView, _ compteur: String, _ taille: CGFloat, _ action: @escaping () -> Void) -> some View {
        VStack(spacing: 4) {
            icone.frame(width: taille, height: taille)
            Text(compteur).font(.system(size: 12, weight: .medium)).foregroundStyle(.white)
        }
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }
}

// ============================================================ 9. DM — LISTE (e072, e089–e091)
struct IgDMListeVue: View {
    @ObservedObject var etat: IgEtat
    @State private var recherche = ""

    private var conversations: [IgConversation] {
        let base = DonneesInsta.conversations.filter { etat.ongletDM == 0 ? !$0.demande : $0.demande }
        guard !recherche.isEmpty else { return base }
        let q = recherche.lowercased()
        return base.filter { $0.compte.id.lowercased().contains(q) || $0.compte.nom.lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    champRecherche
                    if recherche.isEmpty { IgRangeeNotes(etat: etat) }
                    onglets
                    ForEach(conversations) { c in
                        IgLigneConversation(conv: c, etat: etat)
                    }
                    if conversations.isEmpty {
                        IgEtatVide(titre: etat.ongletDM == 0 ? "Aucun message" : "Aucune demande",
                                   texte: etat.ongletDM == 0
                                   ? "Les messages de vos abonné(e)s apparaissent ici."
                                   : "Les invitations des comptes que vous ne suivez pas apparaissent ici.")
                    }
                    Color.clear.frame(height: 110)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var entete: some View {
        ZStack {
            HStack(spacing: 6) {
                Text(DonneesInsta.sarah.id).font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
                Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
            }
            .contentShape(Rectangle())
            .onTapGesture { etat.signaler("Un seul compte connecté sur cet iPhone") }
            HStack {
                Spacer()
                IgComposerForme()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))
                    .frame(width: 22, height: 22)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); etat.signaler("Nouveau message — TODO tournage") }
            }
        }
        .frame(height: 46)
        .padding(.horizontal, 16)
    }

    private var champRecherche: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            TextField("", text: $recherche,
                      prompt: Text("Recherchez ou demandez à Meta AI").foregroundStyle(IgTheme.secondaire))
                .font(.system(size: 15)).foregroundStyle(.white)
            Image(systemName: "sparkle").font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
        }
        .padding(.horizontal, 14)
        .frame(height: 39)
        .background(Capsule().fill(IgTheme.surface2))
        .padding(.horizontal, 14).padding(.bottom, 14)
    }

    private var onglets: some View {
        HStack {
            Text("Messages")
                .font(.system(size: 20, weight: etat.ongletDM == 0 ? .bold : .regular))
                .foregroundStyle(etat.ongletDM == 0 ? Color.white : IgTheme.secondaire)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.ongletDM = 0 }
            Spacer()
            Text("Demandes")
                .font(.system(size: 20, weight: etat.ongletDM == 1 ? .bold : .regular))
                .foregroundStyle(etat.ongletDM == 1 ? Color.white : IgTheme.secondaire)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.ongletDM = 1 }
        }
        .padding(.horizontal, 16).padding(.bottom, 10)
    }
}

struct IgRangeeNotes: View {
    @ObservedObject var etat: IgEtat
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                celluleVotreNote
                ForEach(DonneesInsta.notes) { n in
                    celluleNote(n)
                }
            }
            .padding(.horizontal, 14)
        }
        .padding(.bottom, 12)
    }

    private var celluleVotreNote: some View {
        VStack(spacing: 4) {
            bulle("Demandez ce que vous voulez à vos ami(e)s…", violette: false)
                .offset(y: 10)
            IgAvatarSilhouette(taille: 60)
            Text("Votre note").font(.system(size: 12)).foregroundStyle(IgTheme.secondaire).lineLimit(1)
            Text("📍 Localisation dé…").font(.system(size: 11)).foregroundStyle(IgTheme.secondaire).lineLimit(1)
        }
        .frame(width: 88)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); etat.signaler("Notes — TODO tournage") }
    }

    private func celluleNote(_ n: IgNote) -> some View {
        VStack(spacing: 4) {
            bulle(n.texte, violette: n.violette).offset(y: 10)
            IgAvatar(compte: n.compte, taille: 60)
            Text(n.compte.id).font(.system(size: 12)).foregroundStyle(.white).lineLimit(1)
            Text(n.sousTitre).font(.system(size: 11)).foregroundStyle(IgTheme.secondaire).lineLimit(1)
        }
        .frame(width: 88)
        .contentShape(Rectangle())
        .onTapGesture { etat.ouvrir(.profil(n.compte.id)) }
    }

    private func bulle(_ texte: String, violette: Bool) -> some View {
        Text(texte)
            .font(.system(size: 11))
            .foregroundStyle(violette ? Color.white : Color.white.opacity(0.85))
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 9).padding(.vertical, 7)
            .frame(width: 86, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(violette ? Color(hex: 0x8E5BE0) : Color(hex: 0x2A2E35)))
    }
}

struct IgLigneConversation: View {
    let conv: IgConversation
    @ObservedObject var etat: IgEtat

    private var nonLu: Bool { conv.nonLu && !etat.lus.contains(conv.id) }

    var body: some View {
        HStack(spacing: 12) {
            IgAvatar(compte: conv.compte, taille: 50, anneau: conv.compte.enStory && conv.compte.id == DonneesInsta.chloe.id)
            VStack(alignment: .leading, spacing: 2) {
                Text(conv.compte.nom)
                    .font(.system(size: 15, weight: nonLu ? .semibold : .regular))
                    .foregroundStyle(.white).lineLimit(1)
                Text(conv.apercu)
                    .font(.system(size: 15))
                    .foregroundStyle(nonLu ? Color.white : IgTheme.secondaire)
                    .lineLimit(1)
            }
            Spacer(minLength: 6)
            // §4.6 : aucun bouton caméra en fin de ligne — pastille de non-lu, ou rien.
            if nonLu { Circle().fill(IgTheme.lien).frame(width: 7, height: 7) }
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .contentShape(Rectangle())
        .onTapGesture { etat.lus.insert(conv.id); etat.ouvrir(.fil(conv.id)) }
    }
}

// ============================================================ 10. DM — CONVERSATION (e073, e082)
struct IgFilVue: View {
    let conv: IgConversation
    @ObservedObject var etat: IgEtat
    @State private var saisie: String = ""

    private var messages: [IgMessage] { etat.messages(conv) }
    private var dernierEnvoye: String? { messages.last(where: { $0.deMoi })?.id }

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                VStack(spacing: 0) {
                    IgCarteProfilFil(compte: conv.compte, etat: etat)
                    Text(conv.separateur)
                        .font(.system(size: 11, weight: .medium)).foregroundStyle(IgTheme.secondaire)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    ForEach(Array(messages.enumerated()), id: \.element.id) { i, m in
                        IgBulleFil(message: m,
                                   compte: conv.compte,
                                   position: messages.count > 1 ? Double(i) / Double(messages.count - 1) : 0,
                                   dernierDuGroupe: dernierDuGroupe(i),
                                   indice: i == messages.count - 1 && !m.deMoi,
                                   vu: m.id == dernierEnvoye)
                    }
                    Color.clear.frame(height: 18)
                }
                .padding(.horizontal, 12)
            }
            composerBarre
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func dernierDuGroupe(_ i: Int) -> Bool {
        guard !messages[i].deMoi else { return false }
        if i == messages.count - 1 { return true }
        return messages[i + 1].deMoi
    }

    private var entete: some View {
        HStack(spacing: 10) {
            IgBoutonRond(systeme: "chevron.left", diametre: 40, taille: 16) { etat.fermer() }
            IgAvatar(compte: conv.compte, taille: 34, anneau: conv.compte.enStory)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Text(conv.compte.nom).font(.system(size: 16, weight: .bold)).foregroundStyle(.white).lineLimit(1)
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                }
                Text(conv.compte.id).font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
            }
            .contentShape(Rectangle())
            .onTapGesture { etat.ouvrir(.profil(conv.compte.id)) }
            Spacer(minLength: 4)
            IgBoutonRond(systeme: "phone.fill", diametre: 40, taille: 15) { etat.signaler("Appel audio indisponible") }
            IgBoutonRond(systeme: "video.fill", diametre: 40, taille: 15) { etat.signaler("Appel vidéo indisponible") }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
    }

    private var composerBarre: some View {
        HStack(spacing: 10) {
            Circle().fill(IgTheme.camera).frame(width: 36, height: 36)
                .overlay(Image(systemName: "camera.fill").font(.system(size: 15)).foregroundStyle(.white))
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); etat.feuille = .pellicule(conv.id) }
            HStack(spacing: 12) {
                TextField("", text: $saisie,
                          prompt: Text("Votre message…").foregroundStyle(IgTheme.secondaire))
                    .font(.system(size: 15)).foregroundStyle(.white)
                    .onSubmit { envoyer() }
                if saisie.isEmpty {
                    Image(systemName: "mic").font(.system(size: 17)).foregroundStyle(.white)
                        .onTapGesture { etat.signaler("Message vocal — TODO tournage") }
                    Image(systemName: "photo").font(.system(size: 17)).foregroundStyle(.white)
                        .onTapGesture { Haptique.leger(); etat.feuille = .pellicule(conv.id) }
                    Image(systemName: "face.smiling").font(.system(size: 17)).foregroundStyle(.white)
                        .onTapGesture { saisie += "😊" }
                    Image(systemName: "plus.circle").font(.system(size: 18)).foregroundStyle(.white)
                        .onTapGesture { Haptique.leger(); etat.ouvrir(.reglagesFil(conv.id)) }
                } else {
                    Text("Envoyer").font(.system(size: 15, weight: .semibold)).foregroundStyle(IgTheme.lien)
                        .contentShape(Rectangle())
                        .onTapGesture { envoyer() }
                }
            }
            .padding(.horizontal, 15).frame(height: 40)
            .background(Capsule().fill(IgTheme.composer))
        }
        .padding(.horizontal, 12).padding(.top, 6).padding(.bottom, 34)
    }

    private func envoyer() {
        etat.envoyer(saisie, dans: conv)
        saisie = ""
    }
}

struct IgCarteProfilFil: View {
    let compte: IgCompte
    @ObservedObject var etat: IgEtat
    var body: some View {
        VStack(spacing: 7) {
            IgAvatar(compte: compte, taille: 95).padding(.top, 22)
            Text(compte.nom).font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
            Text(compte.id).font(.system(size: 16)).foregroundStyle(IgTheme.secondaire)
            Text("\(compte.followers) followers · \(compte.publications) publications")
                .font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            Text("Vous vous suivez mutuellement sur Instagram")
                .font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            Text("Vous suivez tou(te)s les deux chloe.brt et 7 autres comptes")
                .font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
                .multilineTextAlignment(.center)
            Text("Voir le profil")
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                .padding(.horizontal, 22).padding(.vertical, 9)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(IgTheme.surface3))
                .padding(.top, 8)
                .contentShape(Rectangle())
                .onTapGesture { etat.ouvrir(.profil(compte.id)) }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

struct IgBulleFil: View {
    let message: IgMessage
    let compte: IgCompte
    let position: Double
    let dernierDuGroupe: Bool
    let indice: Bool
    let vu: Bool

    var body: some View {
        VStack(alignment: message.deMoi ? .trailing : .leading, spacing: 3) {
            HStack(alignment: .bottom, spacing: 7) {
                if message.deMoi { Spacer(minLength: 54) }
                if !message.deMoi {
                    if dernierDuGroupe { IgAvatar(compte: compte, taille: 29) }
                    else { Color.clear.frame(width: 29, height: 1) }
                }
                Text(message.texte)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(fond)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                if !message.deMoi { Spacer(minLength: 54) }
            }
            if indice {
                Text("Appuyer longuement pour réagir")
                    .font(.system(size: 12)).foregroundStyle(IgTheme.secondaire)
                    .padding(.leading, 36)
            }
            if vu {
                Text("Vu").font(.system(size: 12)).foregroundStyle(IgTheme.secondaire)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.deMoi ? .trailing : .leading)
        .padding(.vertical, 2)
    }

    @ViewBuilder private var fond: some View {
        if message.deMoi {
            LinearGradient(colors: [IgTheme.bulle(position), IgTheme.bulle(min(position + 0.12, 1))],
                           startPoint: .top, endPoint: .bottom)
        } else {
            IgTheme.bulleRecue
        }
    }
}

// ============================================================ 11. RECHERCHE / EXPLORE (e145, e153)
struct IgRechercheVue: View {
    @ObservedObject var etat: IgEtat
    @FocusState private var actif: Bool

    private var resultats: [IgCompte] {
        let q = etat.recherche.lowercased()
        guard !q.isEmpty else { return DonneesInsta.comptes }
        return ([DonneesInsta.sarah] + DonneesInsta.comptes).filter {
            $0.id.lowercased().contains(q) || $0.nom.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            barreRecherche
            ScrollView {
                if actif || !etat.recherche.isEmpty {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if etat.recherche.isEmpty { titreRecent }
                        ForEach(resultats) { c in IgLigneResultat(compte: c, etat: etat) }
                        if resultats.isEmpty {
                            IgEtatVide(titre: "Aucun résultat",
                                       texte: "Aucun compte ne correspond à « \(etat.recherche) ».")
                        }
                        Color.clear.frame(height: 110)
                    }
                } else {
                    IgMosaiqueExplore(etat: etat)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var barreRecherche: some View {
        HStack(spacing: 10) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
                // Aucun micro de dictée ici (règle projet).
                TextField("", text: $etat.recherche,
                          prompt: Text("Rechercher").foregroundStyle(IgTheme.secondaire))
                    .font(.system(size: 16)).foregroundStyle(.white)
                    .focused($actif)
                if !etat.recherche.isEmpty {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
                        .contentShape(Rectangle())
                        .onTapGesture { etat.recherche = "" }
                }
            }
            .padding(.horizontal, 14).frame(height: 40)
            .background(Capsule().fill(IgTheme.surface2))

            if actif || !etat.recherche.isEmpty {
                Text("Annuler").font(.system(size: 15)).foregroundStyle(.white)
                    .padding(.horizontal, 15).frame(height: 40)
                    .background(Capsule().fill(IgTheme.surface2))
                    .contentShape(Rectangle())
                    .onTapGesture { etat.recherche = ""; actif = false }
            } else {
                IgMenuDeuxTraits(largeur: 20)
                    .frame(width: 34, height: 40)
                    .contentShape(Rectangle())
                    .onTapGesture { etat.signaler("Options de recherche — TODO tournage") }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
    }

    private var titreRecent: some View {
        HStack {
            Text("Récent").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
            Spacer()
            Text("Voir tout").font(.system(size: 14)).foregroundStyle(IgTheme.lien)
                .contentShape(Rectangle())
                .onTapGesture { etat.signaler("Historique de recherche complet — TODO tournage") }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }
}

struct IgLigneResultat: View {
    let compte: IgCompte
    @ObservedObject var etat: IgEtat
    var body: some View {
        HStack(spacing: 12) {
            IgAvatar(compte: compte, taille: 44, anneau: compte.enStory)
            VStack(alignment: .leading, spacing: 2) {
                Text(compte.id).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                HStack(spacing: 6) {
                    Text(compte.nom).font(.system(size: 14)).foregroundStyle(IgTheme.secondaire).lineLimit(1)
                    if compte.enStory {
                        Text("· 1 nouvel élément à la une").font(.system(size: 14)).foregroundStyle(IgTheme.secondaire).lineLimit(1)
                        Circle().fill(IgTheme.lien).frame(width: 6, height: 6)
                    }
                }
            }
            Spacer(minLength: 4)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { etat.ouvrir(.profil(compte.id)) }
    }
}

/// Mosaïque à tuiles inégales : une tuile 2:3 double hauteur intercalée, position alternée (§3).
struct IgMosaiqueExplore: View {
    @ObservedObject var etat: IgEtat
    private var blocs: [[String]] {
        stride(from: 0, to: DonneesInsta.mosaique.count, by: 5).map {
            Array(DonneesInsta.mosaique[$0..<min($0 + 5, DonneesInsta.mosaique.count)])
        }
    }
    var body: some View {
        LazyVStack(spacing: 1.5) {
            ForEach(Array(blocs.enumerated()), id: \.offset) { i, bloc in
                IgBlocMosaique(images: bloc, hauteAuMilieu: i % 2 == 0,
                               vue: DonneesInsta.vues[i % DonneesInsta.vues.count], etat: etat)
            }
            Color.clear.frame(height: 110)
        }
    }
}

struct IgBlocMosaique: View {
    let images: [String]
    let hauteAuMilieu: Bool
    let vue: String
    @ObservedObject var etat: IgEtat

    var body: some View {
        HStack(spacing: 1.5) {
            if hauteAuMilieu {
                colonne(0, 1)
                tuileHaute(4)
                colonne(2, 3)
            } else {
                colonne(0, 1)
                colonne(2, 3)
                tuileHaute(4)
            }
        }
    }

    private func image(_ i: Int) -> String? { i < images.count ? images[i] : nil }

    private func colonne(_ a: Int, _ b: Int) -> some View {
        VStack(spacing: 1.5) {
            tuile(a).frame(width: IgGrille.cellule, height: IgGrille.cellule)
            tuile(b).frame(width: IgGrille.cellule, height: IgGrille.cellule)
        }
    }

    private func tuileHaute(_ i: Int) -> some View {
        tuile(i, badge: true)
            .frame(width: IgGrille.cellule, height: IgGrille.cellule * 2 + 1.5)
    }

    private func tuile(_ i: Int, badge: Bool = false) -> some View {
        IgPhoto(cle: image(i))
            .overlay(alignment: .bottomLeading) {
                if badge {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill").font(.system(size: 10))
                        Text(vue).font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white).padding(8)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { if let c = image(i) { etat.signaler("Publication « \(c) » — TODO tournage") } }
    }
}

// ============================================================ 12. GRILLE DE PROFIL
struct IgGrilleProfil: View {
    let images: [String]
    var carrousels: Set<Int> = []
    var action: (String) -> Void = { _ in }
    private var colonnes: [GridItem] { Array(repeating: GridItem(.fixed(IgGrille.cellule), spacing: 1.5), count: 3) }
    var body: some View {
        LazyVGrid(columns: colonnes, spacing: 1.5) {
            ForEach(Array(images.enumerated()), id: \.offset) { i, cle in
                IgPhoto(cle: cle)
                    .frame(width: IgGrille.cellule, height: IgGrille.cellule)
                    .overlay(alignment: .topTrailing) {
                        if carrousels.contains(i) {
                            Image(systemName: "square.on.square")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white).padding(7)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); action(cle) }
            }
        }
    }
}

struct IgOngletsProfil: View {
    let symboles: [String]
    @Binding var actif: Int
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(symboles.enumerated()), id: \.offset) { i, s in
                VStack(spacing: 8) {
                    Image(systemName: s)
                        .font(.system(size: 19))
                        .foregroundStyle(actif == i ? Color.white : IgTheme.secondaire)
                    Capsule()
                        .fill(actif == i ? Color.white : Color.clear)
                        .frame(width: 63, height: 1.5)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); actif = i }
            }
        }
    }
}

struct IgColonneStat: View {
    let valeur: String
    let libelle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(valeur).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
            Text(libelle).font(.system(size: 13)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ============================================================ 13. PROFIL DE SARAH (e169, e185–e188)
struct IgProfilVue: View {
    @ObservedObject var etat: IgEtat
    private let sarah = DonneesInsta.sarah

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    identite
                    bio
                    boutons
                    alaune
                    IgOngletsProfil(symboles: ["square.grid.3x3", "arrow.2.squarepath", "person.crop.square"],
                                    actif: $etat.ongletProfil)
                    contenuOnglet
                    Color.clear.frame(height: 110)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var entete: some View {
        HStack(spacing: 6) {
            Text(sarah.id).font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
            Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
            Spacer()
            Image(systemName: "plus").font(.system(size: 21, weight: .medium)).foregroundStyle(.white)
                .frame(width: 40, height: 44)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .creation }
            IgMenuDeuxTraits(largeur: 22)
                .frame(width: 34, height: 44, alignment: .trailing)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .actionsProfil }
        }
        .frame(height: 46)
        .padding(.horizontal, 16)
    }

    private var identite: some View {
        HStack(alignment: .center, spacing: 16) {
            IgAvatar(compte: sarah, taille: 87, anneau: true)
                .contentShape(Circle())
                .onTapGesture { etat.ouvrir(.story(sarah.id)) }
            VStack(alignment: .leading, spacing: 8) {
                Text(sarah.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                HStack(spacing: 0) {
                    IgColonneStat(valeur: sarah.publications, libelle: "publications")
                    IgColonneStat(valeur: sarah.followers, libelle: "followers")
                    IgColonneStat(valeur: sarah.suivis, libelle: "suivi(e)s")
                }
            }
        }
        .padding(.horizontal, 14)
    }

    private var bio: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sarah.bio).font(.system(size: 14)).foregroundStyle(.white)
            if let l = sarah.lien {
                HStack(spacing: 6) {
                    Image(systemName: "link").font(.system(size: 12, weight: .semibold)).foregroundStyle(IgTheme.lien)
                    Text(l).font(.system(size: 14)).foregroundStyle(IgTheme.lien)
                }
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); Routeur.partage.allerSafari(page: "Portfolio de Sarah", url: "https://" + l) }
            }
        }
        .padding(.horizontal, 14)
    }

    private var boutons: some View {
        HStack(spacing: 7) {
            pilule("Modifier le profil") { etat.feuille = .actionsProfil }
            pilule("Partager le profil") { etat.feuille = .partage("profil.sarah") }
            Image(systemName: "person.badge.plus").font(.system(size: 15)).foregroundStyle(.white)
                .frame(width: 42, height: 34)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.surface3))
                .contentShape(Rectangle())
                .onTapGesture { etat.signaler("Aucune suggestion pour le moment") }
        }
        .padding(.horizontal, 14)
    }

    private func pilule(_ titre: String, _ action: @escaping () -> Void) -> some View {
        Text(titre).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
            .frame(maxWidth: .infinity).frame(height: 34)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.surface3))
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); action() }
    }

    private var alaune: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(Array(DonneesInsta.alaune.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 6) {
                        IgPhoto(cle: item.1)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(Color(hex: 0x4A4E55), lineWidth: 1.5).padding(-4))
                        Text(item.0).font(.system(size: 12)).foregroundStyle(.white).lineLimit(1).frame(width: 68)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { etat.ouvrir(.story(DonneesInsta.sarah.id)) }
                }
                VStack(spacing: 6) {
                    Circle().strokeBorder(Color(hex: 0x4A4E55), lineWidth: 1.5)
                        .frame(width: 60, height: 60)
                        .overlay(Image(systemName: "plus").font(.system(size: 20)).foregroundStyle(.white))
                    Text("Nouveau").font(.system(size: 12)).foregroundStyle(.white).frame(width: 68)
                }
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .creation }
            }
            .padding(.horizontal, 18).padding(.vertical, 4)
        }
    }

    @ViewBuilder private var contenuOnglet: some View {
        switch etat.ongletProfil {
        case 1:
            IgEtatVide(titre: "Partagez un moment avec le monde entier",
                       texte: "Créez un reel à partir de vos photos et vidéos.",
                       bouton: "Créer votre premier reel") { etat.feuille = .creation }
        case 2:
            IgEtatVide(titre: "Photos et vidéos de vous",
                       texte: "Lorsque des personnes vous identifient, les publications apparaissent ici.")
        default:
            IgGrilleProfil(images: sarah.grille, carrousels: [0, 3, 7]) { _ in
                etat.ouvrir(.detail(DonneesInsta.postSarah.id))
            }
        }
    }
}

// ============================================================ 14. PROFIL TIERS (e105, e148, e158)
struct IgProfilTiersVue: View {
    let compte: IgCompte
    @ObservedObject var etat: IgEtat
    @State private var onglet: Int = 0

    private var estMoi: Bool { compte.id == DonneesInsta.sarah.id }
    private var suit: Bool { estMoi || etat.suivis.contains(compte.id) }
    private var voitContenu: Bool { !compte.prive || suit }

    var body: some View {
        VStack(spacing: 0) {
            barre
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    identite
                    if !compte.bio.isEmpty {
                        Text(compte.bio).font(.system(size: 14)).foregroundStyle(.white).padding(.horizontal, 14)
                    }
                    if let l = compte.lien { lienVue(l) }
                    boutons
                    IgOngletsProfil(symboles: compte.prive ? ["square.grid.3x3", "person.crop.square"]
                                                           : ["square.grid.3x3", "arrow.2.squarepath", "person.crop.square"],
                                    actif: $onglet)
                    contenu
                    Color.clear.frame(height: 110)
                }
            }
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var barre: some View {
        HStack(spacing: 12) {
            Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
                .frame(width: 40, height: 44)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.fermer() }
            Text(compte.id).font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
            Spacer()
            if !compte.prive {
                Image(systemName: "bell").font(.system(size: 18)).foregroundStyle(.white)
                    .frame(width: 40, height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture { etat.signaler("Notifications activées pour \(compte.id)") }
            }
            Image(systemName: "ellipsis").font(.system(size: 18)).foregroundStyle(.white)
                .frame(width: 36, height: 44)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .options("profil." + compte.id) }
        }
        .frame(height: 46)
        .padding(.horizontal, 12)
    }

    private var identite: some View {
        HStack(alignment: .center, spacing: 16) {
            IgAvatar(compte: compte, taille: 87, anneau: compte.enStory)
                .contentShape(Circle())
                .onTapGesture { if compte.enStory { etat.ouvrir(.story(compte.id)) } }
            VStack(alignment: .leading, spacing: 8) {
                Text(compte.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                HStack(spacing: 0) {
                    IgColonneStat(valeur: compte.publications, libelle: "publications")
                    IgColonneStat(valeur: compte.followers, libelle: "followers")
                    IgColonneStat(valeur: compte.suivis, libelle: "suivi(e)s")
                }
            }
        }
        .padding(.horizontal, 14)
    }

    private func lienVue(_ l: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: "link").font(.system(size: 13, weight: .semibold)).foregroundStyle(IgTheme.lien)
            Text(l).font(.system(size: 15)).foregroundStyle(IgTheme.lien)
        }
        .padding(.horizontal, 14)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); Routeur.partage.allerSafari(page: compte.nom, url: "https://" + l) }
    }

    @ViewBuilder private var boutons: some View {
        if estMoi {
            HStack(spacing: 7) {
                Text("Modifier le profil").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 34)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.surface3))
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); etat.feuille = .actionsProfil }
                Text("Partager le profil").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 34)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.surface3))
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); etat.feuille = .partage("profil.sarah") }
            }
            .padding(.horizontal, 14)
        } else if suit {
            HStack(spacing: 7) {
                HStack(spacing: 6) {
                    Text("Suivi(e)").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    Image(systemName: "chevron.down").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity).frame(height: 34)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.surface3))
                .contentShape(Rectangle())
                .onTapGesture { etat.basculerSuivi(compte.id) }

                Text("Envoyer un message").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 34)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.surface3))
                    .contentShape(Rectangle())
                    .onTapGesture { ouvrirFil() }

                Image(systemName: "person.badge.plus").font(.system(size: 15)).foregroundStyle(.white)
                    .frame(width: 42, height: 34)
                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.surface3))
                    .contentShape(Rectangle())
                    .onTapGesture { etat.signaler("Aucune suggestion pour le moment") }
            }
            .padding(.horizontal, 14)
        } else {
            Text("Suivre").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).frame(height: 32)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.accent))
                .padding(.horizontal, 14)
                .contentShape(Rectangle())
                .onTapGesture { etat.basculerSuivi(compte.id) }
        }
    }

    private func ouvrirFil() {
        Haptique.leger()
        if let c = DonneesInsta.conversations.first(where: { $0.compte.id == compte.id }) {
            etat.ouvrir(.fil(c.id))
        } else {
            etat.signaler("Aucune conversation avec \(compte.id)")
        }
    }

    @ViewBuilder private var contenu: some View {
        if !voitContenu {
            VStack(spacing: 14) {
                Circle().strokeBorder(Color.white, lineWidth: 1.5)
                    .frame(width: 85, height: 85)
                    .overlay(Image(systemName: "lock").font(.system(size: 32)).foregroundStyle(.white))
                Text("Ce profil est privé").font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
                Text("Suivez ce profil pour voir ses photos et vidéos.")
                    .font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
                    .multilineTextAlignment(.center).padding(.horizontal, 30)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 90)
        } else if onglet == 0 && !compte.grille.isEmpty {
            IgGrilleProfil(images: compte.grille, carrousels: [1, 4]) { _ in
                etat.ouvrir(.detail(DonneesInsta.posts[0].id))
            }
        } else {
            IgEtatVide(titre: "Partagez un moment avec le monde entier",
                       texte: "Les publications de \(compte.id) apparaîtront ici.")
        }
    }
}

// ============================================================ 15. VISIONNEUSE DE STORY (e105–e112, e155)
// Réécriture complète (§4.2) : barre segmentée réelle + minuteur, ✕ dans une cible de 44 pt,
// glissé vers le bas, taps latéraux — et présentation en OVERLAY : BarreHome reste atteignable.
struct IgStoryVue: View {
    let compte: IgCompte
    @ObservedObject var etat: IgEtat

    @State private var segment: Int = 0
    @State private var progression: Double = 0
    @State private var decalage: CGFloat = 0
    @State private var reponse: String = ""

    private let minuteur = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let dureeSegment: Double = 5.0

    private var segments: [String] {
        let base = compte.grille.isEmpty ? ["p31", "p34", "p38"] : compte.grille
        return Array(base.prefix(5))
    }
    private var dates: [String] { ["21 mai 2021", "3 juin 2024", "12 juillet 2025", "8 mars 2026", "Il y a 4 h"] }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            media
            VStack(spacing: 10) {
                barreSegmentee
                entete
                Spacer(minLength: 0)
            }
            VStack {
                Spacer()
                reactionsRapides
                barreReponse
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: decalage)
        .onReceive(minuteur) { _ in avancer() }
        .gesture(
            DragGesture(minimumDistance: 12)
                .onChanged { v in if v.translation.height > 0 { decalage = v.translation.height } }
                .onEnded { v in
                    if v.translation.height > 110 { fermer() } else { withAnimation(.spring()) { decalage = 0 } }
                }
        )
    }

    private var media: some View {
        VStack(spacing: 0) {
            IgPhoto(cle: segments[min(segment, segments.count - 1)], teinte: compte.teinte)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 8,
                                                  bottomTrailingRadius: 8, topTrailingRadius: 0))
                .overlay(zonesTactiles)
            Color.black.frame(height: 96)
        }
        .ignoresSafeArea(edges: .top)
    }

    private var zonesTactiles: some View {
        HStack(spacing: 0) {
            Color.clear.contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .onTapGesture { precedent() }
            Color.clear.contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .onTapGesture { suivant() }
            Color.clear.contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .onTapGesture { suivant() }
        }
    }

    private var barreSegmentee: some View {
        HStack(spacing: 4) {
            ForEach(0..<segments.count, id: \.self) { i in
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.35))
                        Capsule().fill(Color.white)
                            .frame(width: geo.size.width * remplissage(i))
                    }
                }
                .frame(height: 2)
            }
        }
        .padding(.horizontal, 8).padding(.top, 8)
    }

    private func remplissage(_ i: Int) -> Double {
        if i < segment { return 1 }
        if i > segment { return 0 }
        return min(max(progression, 0), 1)
    }

    private var entete: some View {
        HStack(spacing: 9) {
            IgAvatar(compte: compte, taille: 23, anneau: true)
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 7) {
                    Image(systemName: "person.2.fill").font(.system(size: 10)).foregroundStyle(Color(hex: 0x5BD08B))
                    Text(dates[min(segment, dates.count - 1)])
                        .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                    Text("Il y a 4 h").font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
                }
                HStack(spacing: 5) {
                    Image(systemName: "waveform").font(.system(size: 10)).foregroundStyle(.white)
                    Text("Ice Cube · It Was A Good Day").font(.system(size: 13)).foregroundStyle(.white)
                    Image(systemName: "chevron.right").font(.system(size: 9, weight: .semibold)).foregroundStyle(.white)
                }
                .contentShape(Rectangle())
                .onTapGesture { etat.signaler("Ice Cube · It Was A Good Day") }
            }
            Spacer(minLength: 4)
            Image(systemName: "xmark")
                .font(.system(size: 21, weight: .light)).foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .onTapGesture { fermer() }
        }
        .padding(.leading, 12).padding(.trailing, 4)
    }

    private var reactionsRapides: some View {
        HStack(spacing: 14) {
            ForEach(["❤️", "🙌", "🔥", "👏", "😍", "😮"], id: \.self) { e in
                Text(e).font(.system(size: 24))
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); etat.signaler("Réaction \(e) envoyée à \(compte.id)") }
            }
        }
        .padding(.bottom, 12)
    }

    private var barreReponse: some View {
        HStack(spacing: 16) {
            TextField("", text: $reponse,
                      prompt: Text("Envoyer un message…").foregroundStyle(.white.opacity(0.85)))
                .font(.system(size: 14)).foregroundStyle(.white)
                .padding(.horizontal, 16).frame(height: 40)
                .background(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
                .onSubmit { envoyerReponse() }
            IgFlipForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.6, lineJoin: .round))
                .frame(width: 22, height: 22)
                .contentShape(Rectangle())
                .onTapGesture { etat.signaler("Caméra de story — TODO tournage") }
            IgCoeurForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.6, lineJoin: .round))
                .frame(width: 21, height: 21)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.signaler("❤️ envoyé à \(compte.id)") }
            IgBulleForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.6, lineJoin: .round))
                .frame(width: 21, height: 21)
                .contentShape(Rectangle())
                .onTapGesture { envoyerReponse() }
            IgEnvoyerForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.6, lineJoin: .round))
                .frame(width: 19, height: 19)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .partage("story." + compte.id) }
            IgMenuDeuxTraits(largeur: 19)
                .frame(width: 22, height: 22)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .options("story." + compte.id) }
        }
        .padding(.horizontal, 14).padding(.bottom, 30)
    }

    private func envoyerReponse() {
        let t = reponse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { etat.signaler("Écrivez un message avant d'envoyer"); return }
        etat.signaler("Réponse envoyée à \(compte.id)")
        reponse = ""
    }

    private func avancer() {
        progression += 0.05 / dureeSegment
        if progression >= 1 { suivant() }
    }
    private func suivant() {
        if segment < segments.count - 1 { segment += 1; progression = 0 } else { fermer() }
    }
    private func precedent() {
        if segment > 0 { segment -= 1; progression = 0 } else { progression = 0 }
    }
    private func fermer() { Haptique.leger(); etat.fermer() }
}

// ============================================================ 16. DÉTAIL PUBLICATION (e169–e175)
struct IgDetailPostVue: View {
    let post: IgPost
    @ObservedObject var etat: IgEtat
    @State private var page: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            barre
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    IgEntetePost(post: post, etat: etat)
                    media
                    if post.images.count > 1 {
                        IgPointsPagination(total: post.images.count, actif: page)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    // e170 : pas d'icône repost sur le détail d'une publication.
                    IgRangeeIconesPost(post: post, etat: etat, avecRepost: false)
                    IgBlocTextePost(post: post, etat: etat)
                    apercuCommentaires
                    Color.clear.frame(height: 110)
                }
            }
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var barre: some View {
        ZStack {
            VStack(spacing: 1) {
                Text("Publications").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                Text(post.compte.id).font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
            }
            HStack {
                IgBoutonRond(systeme: "chevron.left", diametre: 40, taille: 16) { etat.fermer() }
                Spacer()
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 12)
    }

    private var media: some View {
        IgPhoto(cle: post.images[min(page, post.images.count - 1)], teinte: post.compte.teinte)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .topTrailing) {
                if post.images.count > 1 {
                    Text("\(page + 1)/\(post.images.count)")
                        .font(.system(size: 12.5, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.6)))
                        .padding(12)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) { etat.aimer(post.id) }
            .gesture(DragGesture(minimumDistance: 24).onEnded { v in
                guard post.images.count > 1 else { return }
                if v.translation.width < -30 { page = min(page + 1, post.images.count - 1) }
                if v.translation.width > 30 { page = max(page - 1, 0) }
            })
    }

    private var apercuCommentaires: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(etat.commentaires(post).prefix(2)) { c in
                HStack(alignment: .top, spacing: 8) {
                    (Text(c.compte.id + " ").font(.system(size: 14, weight: .semibold))
                     + Text(c.texte).font(.system(size: 14)))
                        .foregroundStyle(.white).lineLimit(2)
                    Spacer(minLength: 8)
                    IgCoeurForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                        .frame(width: 15, height: 15)
                }
            }
            Text("Voir les \(etat.commentaires(post).count) commentaires")
                .font(.system(size: 14)).foregroundStyle(IgTheme.secondaire)
                .padding(.top, 2)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .commentaires(post.id) }
        }
        .padding(.horizontal, 13).padding(.top, 8)
    }
}

// ============================================================ 17. NOTIFICATIONS (onglet cœur)
// TODO tournage : cet écran n'apparaît dans AUCUNE des 239 frames (audit §5-1). Il est donc
// rendu sobrement, strictement dans les tokens mesurés. Correctif D82 : chaque ligne qui
// concerne un profil OUVRE ce profil.
struct IgNotificationsVue: View {
    @ObservedObject var etat: IgEtat

    private struct Ligne: Identifiable {
        let id: String
        let compte: IgCompte
        let action: String
        let quand: String
        let suivre: Bool
        let vignette: String?
    }

    private var cette: [Ligne] { [
        Ligne(id: "n1", compte: DonneesInsta.chloe, action: "a aimé votre publication.", quand: "2 h", suivre: false, vignette: "p30"),
        Ligne(id: "n2", compte: DonneesInsta.marc,  action: "a commencé à vous suivre.", quand: "5 h", suivre: true, vignette: nil),
        Ligne(id: "n3", compte: DonneesInsta.ines,  action: "a commenté : « La chance ! »", quand: "1 j", suivre: false, vignette: "p34")
    ] }
    private var avant: [Ligne] { [
        Ligne(id: "n4", compte: DonneesInsta.atelier, action: "vous a identifiée dans une publication.", quand: "4 j", suivre: false, vignette: "p33"),
        Ligne(id: "n5", compte: DonneesInsta.lyon,    action: "a partagé votre photo en story.", quand: "1 sem.", suivre: false, vignette: "p36"),
        Ligne(id: "n6", compte: DonneesInsta.lea,     action: "a accepté votre demande.", quand: "2 sem.", suivre: false, vignette: nil)
    ] }

    var body: some View {
        VStack(spacing: 0) {
            barre
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    section("Cette semaine", cette)
                    section("Avant", avant)
                    Color.clear.frame(height: 110)
                }
            }
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var barre: some View {
        ZStack {
            Text("Notifications").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
            HStack {
                IgBoutonRond(systeme: "chevron.left", diametre: 40, taille: 16) { etat.fermer() }
                Spacer()
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 12)
    }

    private func section(_ titre: String, _ lignes: [Ligne]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(titre).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 6)
            ForEach(lignes) { l in vue(l) }
        }
    }

    private func vue(_ l: Ligne) -> some View {
        HStack(spacing: 12) {
            IgAvatar(compte: l.compte, taille: 44, anneau: l.compte.enStory)
            (Text(l.compte.id + " ").font(.system(size: 14, weight: .semibold))
             + Text(l.action + " ").font(.system(size: 14))
             + Text(l.quand).font(.system(size: 14)).foregroundColor(IgTheme.secondaire))
                .foregroundStyle(.white)
            Spacer(minLength: 6)
            if l.suivre {
                Text(etat.suivis.contains(l.compte.id) ? "Suivi(e)" : "Suivre")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 84, height: 30)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(etat.suivis.contains(l.compte.id) ? IgTheme.surface3 : IgTheme.accent))
                    .contentShape(Rectangle())
                    .onTapGesture { etat.basculerSuivi(l.compte.id) }
            } else if let v = l.vignette {
                IgPhoto(cle: v).frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { etat.ouvrir(.profil(l.compte.id)) }
    }
}

// ============================================================ 18. RÉGLAGES D'UNE CONVERSATION (e097, e101)
struct IgReglagesFilVue: View {
    let conv: IgConversation
    @ObservedObject var etat: IgEtat

    private let entrees: [(String, String)] = [
        ("paintbrush", "Personnaliser"),
        ("textformat", "Pseudos"),
        ("timer", "Messages éphémères"),
        ("lock.shield", "Confidentialité et sécurité"),
        ("person.3", "Créer une discussion de groupe"),
        ("exclamationmark.bubble", "Quelque chose ne fonctionne pas")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Détails").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                HStack {
                    IgBoutonRond(systeme: "chevron.left", diametre: 40, taille: 16) { etat.fermer() }
                    Spacer()
                }
            }
            .frame(height: 52).padding(.horizontal, 12)

            ScrollView {
                VStack(spacing: 0) {
                    IgAvatar(compte: conv.compte, taille: 88).padding(.top, 10)
                    Text(conv.compte.nom).font(.system(size: 19, weight: .bold)).foregroundStyle(.white).padding(.top, 8)
                    Text(conv.compte.id).font(.system(size: 14)).foregroundStyle(IgTheme.secondaire).padding(.bottom, 18)
                    ForEach(Array(entrees.enumerated()), id: \.offset) { _, e in
                        HStack(spacing: 14) {
                            Image(systemName: e.0).font(.system(size: 17)).foregroundStyle(.white).frame(width: 26)
                            Text(e.1).font(.system(size: 15.5)).foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(IgTheme.secondaire)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); etat.signaler("« \(e.1) » — TODO tournage") }
                        IgSeparateur().padding(.leading, 56)
                    }
                    Color.clear.frame(height: 110)
                }
            }
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// ============================================================ 19. CATALOGUE (résolution par identifiant)
// La boucle miroir et les couches d'overlay ne manipulent que des identifiants : ces
// accesseurs rendent des valeurs NON optionnelles (jamais de `!`, jamais de crash).
enum IgCatalogue {
    static func post(_ id: String) -> IgPost {
        if let p = DonneesInsta.posts.first(where: { $0.id == id }) { return p }
        if DonneesInsta.postSarah.id == id { return DonneesInsta.postSarah }
        return DonneesInsta.posts[0]
    }

    static func conversation(_ id: String) -> IgConversation {
        if let c = DonneesInsta.conversations.first(where: { $0.id == id }) { return c }
        return DonneesInsta.conversations[0]
    }

    static func reel(_ id: String) -> IgReel {
        if let r = IgReels.liste.first(where: { $0.id == id }) { return r }
        return IgReels.liste[0]
    }

    /// Destinataires de la feuille de partage (e019, e021) : la grille de comptes.
    static let destinataires: [(compte: IgCompte, actif: String?)] = [
        (DonneesInsta.chloe, "8 min"),
        (DonneesInsta.ines, "15 min"),
        (DonneesInsta.atelier, nil),
        (DonneesInsta.lea, "20 min"),
        (DonneesInsta.lyon, nil),
        (DonneesInsta.marc, nil)
    ]

    /// Libellé lisible d'une cible de feuille (partage, options) — jamais un identifiant brut.
    static func libelle(_ cible: String) -> String {
        if cible.hasPrefix("story.") { return "La story de " + String(cible.dropFirst(6)) }
        if cible.hasPrefix("profil.") { return "Ce profil" }
        if cible.hasPrefix("reel.") { return "Ce reel" }
        return "Cette publication"
    }
}

// ============================================================ 20. COUCHE OVERLAYS (écrans plein cadre)
// Aucun .sheet / .fullScreenCover / NavigationStack : la pile d'overlays vit dans IgEtat et
// se dessine SOUS BarreHome — le joueur ne peut jamais être enfermé dans un écran (§4.2).
struct IgCoucheOverlays: View {
    @ObservedObject var etat: IgEtat

    var body: some View {
        ZStack {
            if let sommet = etat.sommet {
                IgTheme.fond.ignoresSafeArea()
                ecran(sommet)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: etat.pile.count)
    }

    @ViewBuilder private func ecran(_ o: IgOverlay) -> some View {
        switch o {
        case .story(let pseudo):
            IgStoryVue(compte: DonneesInsta.compte(pseudo), etat: etat)
        case .profil(let pseudo):
            IgProfilTiersVue(compte: DonneesInsta.compte(pseudo), etat: etat)
        case .detail(let identifiant):
            IgDetailPostVue(post: IgCatalogue.post(identifiant), etat: etat)
        case .fil(let identifiant):
            IgFilVue(conv: IgCatalogue.conversation(identifiant), etat: etat)
        case .notifications:
            IgNotificationsVue(etat: etat)
        case .reglagesFil(let identifiant):
            IgReglagesFilVue(conv: IgCatalogue.conversation(identifiant), etat: etat)
        }
    }
}

// ============================================================ 21. COUCHE FEUILLES (bottom sheets maison)
struct IgCoucheFeuilles: View {
    @ObservedObject var etat: IgEtat

    var body: some View {
        ZStack(alignment: .bottom) {
            if let f = etat.feuille {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { etat.feuille = nil }
                feuille(f)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeOut(duration: 0.22), value: etat.feuille)
    }

    @ViewBuilder private func feuille(_ f: IgFeuille) -> some View {
        switch f {
        case .commentaires(let identifiant):
            IgFeuilleCommentaires(post: IgCatalogue.post(identifiant), etat: etat)
        case .partage(let cible):
            IgFeuillePartage(cible: cible, etat: etat)
        case .options(let cible):
            IgFeuilleOptions(cible: cible, etat: etat)
        case .menuFlux:
            IgFeuilleMenuFlux(etat: etat)
        case .creation:
            IgFeuilleCreation(etat: etat)
        case .actionsProfil:
            IgFeuilleActionsProfil(etat: etat)
        case .pellicule(let cible):
            IgFeuillePellicule(cible: cible, etat: etat)
        }
    }
}

/// Gabarit commun : coins hauts r 18 pt, fond #15191C, poignée grise, glissé de fermeture
/// posé UNIQUEMENT sur la poignée (pour ne pas voler le défilement du contenu).
struct IgConteneurFeuille<Contenu: View>: View {
    var fraction: CGFloat
    var fond: Color
    var fermer: () -> Void
    var contenu: () -> Contenu

    @State private var decalage: CGFloat = 0

    init(fraction: CGFloat = 0.72,
         fond: Color = IgTheme.surface1,
         fermer: @escaping () -> Void,
         @ViewBuilder contenu: @escaping () -> Contenu) {
        self.fraction = fraction
        self.fond = fond
        self.fermer = fermer
        self.contenu = contenu
    }

    private var hauteur: CGFloat { UIScreen.main.bounds.height * fraction }

    var body: some View {
        VStack(spacing: 0) {
            poignee
            contenu()
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: hauteur)
        .background(forme.fill(fond))
        .overlay(forme.strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5))
        .offset(y: max(decalage, 0))
    }

    private var forme: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 0,
                               bottomTrailingRadius: 0, topTrailingRadius: 18,
                               style: .continuous)
    }

    private var poignee: some View {
        Capsule().fill(Color(hex: 0x5A5F66))
            .frame(width: 40, height: 4)
            .padding(.top, 9)
            .padding(.bottom, 5)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { v in if v.translation.height > 0 { decalage = v.translation.height } }
                    .onEnded { v in
                        if v.translation.height > 90 { decalage = 0; fermer() }
                        else { withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { decalage = 0 } }
                    }
            )
    }
}

/// Bouton rond d'en-tête de feuille (partage / •••) — e013, e176.
struct IgRondEnteteFeuille<Contenu: View>: View {
    var diametre: CGFloat
    var action: () -> Void
    var contenu: () -> Contenu

    init(diametre: CGFloat = 40, action: @escaping () -> Void, @ViewBuilder contenu: @escaping () -> Contenu) {
        self.diametre = diametre
        self.action = action
        self.contenu = contenu
    }

    var body: some View {
        Circle().fill(Color(hex: 0x22262B))
            .frame(width: diametre, height: diametre)
            .overlay(contenu())
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); action() }
    }
}

// ============================================================ 22. FEUILLE COMMENTAIRES (e013–e016, e176–e180)
// Fond #15191C, poignée, titre gras 17 centré, bouton rond de partage à droite,
// filtre « Pour vous ⌄ », lignes avatar 30 pt, rangée de 8 emojis, composer + GIF.
struct IgFeuilleCommentaires: View {
    let post: IgPost
    @ObservedObject var etat: IgEtat
    @State private var saisie: String = ""

    private static let emojis: [String] = ["❤️", "🙌", "🔥", "👏", "🥹", "😍", "😮", "😂"]
    private var estDeSarah: Bool { post.compte.id == DonneesInsta.sarah.id }
    private var liste: [IgCommentaire] { etat.commentaires(post) }

    var body: some View {
        IgConteneurFeuille(fraction: 0.72, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                entete
                filtre
                lignes
                pied
            }
        }
    }

    private var entete: some View {
        ZStack {
            Text("Commentaires").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
            HStack {
                Spacer()
                IgRondEnteteFeuille(diametre: 40, action: bascule) {
                    if estDeSarah {
                        Image(systemName: "ellipsis").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    } else {
                        IgEnvoyerForme()
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 1.6, lineJoin: .round))
                            .frame(width: 18, height: 18)
                    }
                }
            }
        }
        .frame(height: 40)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private func bascule() {
        if estDeSarah { etat.feuille = .options(post.id) } else { etat.feuille = .partage(post.id) }
    }

    private var filtre: some View {
        HStack(spacing: 7) {
            Text("Pour vous").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            Image(systemName: "chevron.down").font(.system(size: 11, weight: .semibold)).foregroundStyle(IgTheme.secondaire)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 8)
        .contentShape(Rectangle())
        .onTapGesture { etat.signaler("Filtre des commentaires — TODO tournage") }
    }

    private var lignes: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(liste) { c in
                    IgLigneCommentaire(commentaire: c, etat: etat) { pseudo in
                        saisie = "@" + pseudo + " "
                    }
                }
                if liste.isEmpty {
                    IgEtatVide(titre: "Aucun commentaire pour le moment",
                               texte: "Lancez la conversation.")
                        .padding(.top, 30)
                }
                Color.clear.frame(height: 8)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var pied: some View {
        VStack(spacing: 0) {
            IgSeparateur()
            HStack(spacing: 0) {
                ForEach(IgFeuilleCommentaires.emojis, id: \.self) { e in
                    Text(e).font(.system(size: 25))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { envoyer(e) }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            composer
        }
    }

    private var composer: some View {
        HStack(spacing: 11) {
            IgAvatarSilhouette(taille: 36)
            HStack(spacing: 10) {
                TextField("", text: $saisie,
                          prompt: Text(estDeSarah ? "Ajoutez un commentaire…" : "Qu'en pensez-vous ?")
                            .foregroundStyle(IgTheme.secondaire))
                    .font(.system(size: 15)).foregroundStyle(.white)
                    .onSubmit { envoyer(saisie) }
                if saisie.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("GIF").font(.system(size: 11, weight: .heavy)).foregroundStyle(.white)
                        .padding(.horizontal, 4).padding(.vertical, 2)
                        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Color.white, lineWidth: 1.4))
                        .contentShape(Rectangle())
                        .onTapGesture { etat.signaler("Bibliothèque de GIF indisponible sans connexion") }
                } else {
                    Text("Publier").font(.system(size: 14, weight: .semibold)).foregroundStyle(IgTheme.lien)
                        .contentShape(Rectangle())
                        .onTapGesture { envoyer(saisie) }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(Capsule().strokeBorder(Color(hex: 0x33373D), lineWidth: 1))
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 16)
    }

    private func envoyer(_ texte: String) {
        etat.ajouterCommentaire(texte, sur: post)
        saisie = ""
    }
}

struct IgLigneCommentaire: View {
    let commentaire: IgCommentaire
    @ObservedObject var etat: IgEtat
    var repondre: (String) -> Void

    private var cle: String { "com." + commentaire.id }
    private var aime: Bool { etat.aimes.contains(cle) }
    private var total: Int { commentaire.jaime + (aime ? 1 : 0) }

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            IgAvatar(compte: commentaire.compte, taille: 30)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(commentaire.compte.id).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    Text(commentaire.quand).font(.system(size: 14)).foregroundStyle(IgTheme.secondaire)
                }
                Text(commentaire.texte).font(.system(size: 15)).foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 18) {
                    Text("Répondre").font(.system(size: 13, weight: .medium)).foregroundStyle(IgTheme.secondaire)
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); repondre(commentaire.compte.id) }
                    Text("Masquer").font(.system(size: 13, weight: .medium)).foregroundStyle(IgTheme.secondaire)
                        .contentShape(Rectangle())
                        .onTapGesture { etat.signaler("Commentaire masqué") }
                }
                .padding(.top, 1)
            }
            Spacer(minLength: 8)
            VStack(spacing: 3) {
                Group {
                    if aime {
                        IgCoeurForme().fill(Color(hex: 0xFF3040))
                    } else {
                        IgCoeurForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                    }
                }
                .frame(width: 16, height: 16)
                if total > 0 {
                    Text("\(total)").font(.system(size: 12)).foregroundStyle(IgTheme.secondaire)
                }
            }
            .frame(width: 34)
            .contentShape(Rectangle())
            .onTapGesture { etat.basculerJaime(cle) }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
    }
}

// ============================================================ 23. FEUILLE DE PARTAGE (e019–e021)
struct IgFeuillePartage: View {
    let cible: String
    @ObservedObject var etat: IgEtat
    @State private var recherche: String = ""

    private var destinataires: [(compte: IgCompte, actif: String?)] {
        guard !recherche.isEmpty else { return IgCatalogue.destinataires }
        let q = recherche.lowercased()
        return IgCatalogue.destinataires.filter {
            $0.compte.id.lowercased().contains(q) || $0.compte.nom.lowercased().contains(q)
        }
    }

    private var colonnes: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 12), count: 3) }

    var body: some View {
        IgConteneurFeuille(fraction: 0.62, fond: Color(hex: 0x1A1E22), fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                barreRecherche
                grille
                IgSeparateur()
                rangeeActions
            }
        }
    }

    private var barreRecherche: some View {
        HStack(spacing: 12) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
                TextField("", text: $recherche,
                          prompt: Text("Rechercher").foregroundStyle(IgTheme.secondaire))
                    .font(.system(size: 16)).foregroundStyle(.white)
            }
            .padding(.horizontal, 15)
            .frame(height: 44)
            .background(Capsule().fill(Color(hex: 0x2A2E35)))

            IgRondEnteteFeuille(diametre: 44, action: { etat.signaler("Nouveau groupe — TODO tournage") }) {
                Image(systemName: "person.badge.plus").font(.system(size: 16)).foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }

    private var grille: some View {
        ScrollView {
            LazyVGrid(columns: colonnes, spacing: 16) {
                ForEach(Array(destinataires.enumerated()), id: \.offset) { _, d in
                    cellule(d.compte, d.actif)
                }
            }
            .padding(.horizontal, 16)
            if destinataires.isEmpty {
                IgEtatVide(titre: "Aucun compte", texte: "Aucun destinataire ne correspond à « \(recherche) ».")
            }
            Color.clear.frame(height: 10)
        }
        .frame(maxHeight: .infinity)
    }

    private func cellule(_ compte: IgCompte, _ actif: String?) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                IgAvatar(compte: compte, taille: 74)
                if let a = actif {
                    Text(a).font(.system(size: 10, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(Capsule().fill(Color(hex: 0x1DBF52)))
                        .overlay(Capsule().strokeBorder(Color(hex: 0x1A1E22), lineWidth: 1.5))
                }
            }
            .frame(width: 74, height: 74)
            Text(compte.nom).font(.system(size: 13)).foregroundStyle(.white)
                .lineLimit(2).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptique.leger()
            etat.feuille = nil
            etat.signaler("Envoyé à \(compte.nom)")
        }
    }

    private var rangeeActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 22) {
                celluleAction(libelle: "Ajouter à\nla story", fond: Color(hex: 0x2A2E35)) {
                    AnyView(Image(systemName: "plus.circle.dashed").font(.system(size: 22)).foregroundStyle(.white))
                } faire: {
                    etat.feuille = nil; etat.signaler("Ajouté à votre story")
                }
                celluleAction(libelle: "Copier le lien", fond: Color(hex: 0x2A2E35)) {
                    AnyView(Image(systemName: "link").font(.system(size: 21, weight: .semibold)).foregroundStyle(.white))
                } faire: {
                    etat.feuille = nil; etat.signaler("Lien copié")
                }
                celluleAction(libelle: "WhatsApp", fond: Color(hex: 0x25D366)) {
                    AnyView(logoWhatsApp)
                } faire: {
                    etat.signaler("Partage vers WhatsApp indisponible sans connexion")
                }
                celluleAction(libelle: "Snapchat", fond: Color(hex: 0xFFFC00)) {
                    AnyView(IgFantomeForme().fill(Color.black).frame(width: 22, height: 24))
                } faire: {
                    etat.signaler("Partage vers Snapchat indisponible sans connexion")
                }
                celluleAction(libelle: "Partager\ndans…", fond: Color(hex: 0x2A2E35)) {
                    AnyView(Image(systemName: "square.and.arrow.up").font(.system(size: 20)).foregroundStyle(.white))
                } faire: {
                    etat.signaler("Aucune application disponible pour ce partage")
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
    }

    private var logoWhatsApp: some View {
        ZStack {
            IgBulleForme().fill(Color.white).frame(width: 26, height: 26)
            Image(systemName: "phone.fill").font(.system(size: 11)).foregroundStyle(Color(hex: 0x25D366))
                .offset(y: -1)
        }
    }

    private func celluleAction(libelle: String, fond: Color,
                               @ViewBuilder icone: () -> AnyView,
                               faire: @escaping () -> Void) -> some View {
        let glyphe = icone()
        return VStack(spacing: 8) {
            Circle().fill(fond)
                .frame(width: 62, height: 62)
                .overlay(glyphe)
            Text(libelle).font(.system(size: 12)).foregroundStyle(.white)
                .multilineTextAlignment(.center).lineLimit(2)
                .frame(width: 74)
        }
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); faire() }
    }
}

/// Fantôme Snapchat de la rangée de partage (e019) — dessin maison, aucun logo importé.
struct IgFantomeForme: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height, x = r.minX, y = r.minY
        var p = Path()
        p.move(to: CGPoint(x: x + w * 0.06, y: y + h * 0.82))
        p.addLine(to: CGPoint(x: x + w * 0.06, y: y + h * 0.44))
        p.addQuadCurve(to: CGPoint(x: x + w * 0.94, y: y + h * 0.44),
                       control: CGPoint(x: x + w * 0.50, y: y - h * 0.22))
        p.addLine(to: CGPoint(x: x + w * 0.94, y: y + h * 0.82))
        p.addLine(to: CGPoint(x: x + w * 0.78, y: y + h * 0.72))
        p.addLine(to: CGPoint(x: x + w * 0.64, y: y + h * 0.86))
        p.addLine(to: CGPoint(x: x + w * 0.50, y: y + h * 0.72))
        p.addLine(to: CGPoint(x: x + w * 0.36, y: y + h * 0.86))
        p.addLine(to: CGPoint(x: x + w * 0.22, y: y + h * 0.72))
        p.closeSubpath()
        return p
    }
}

// ============================================================ 24. FEUILLE D'OPTIONS « ≡ » (§5-5)
// TODO tournage : le menu « ≡ » d'une publication n'apparaît dans aucune des 239 frames.
// Il est donc rendu sobrement, dans les tokens mesurés, et chaque entrée fait quelque chose
// de vérifiable (D82-A) ou affiche un message crédible (D82-B).
struct IgFeuilleOptions: View {
    let cible: String
    @ObservedObject var etat: IgEtat

    private struct Entree: Identifiable {
        let id: String
        let symbole: String
        let titre: String
        let rouge: Bool
        let action: () -> Void
    }

    private var estProfil: Bool { cible.hasPrefix("profil.") }
    private var estStory: Bool { cible.hasPrefix("story.") }

    private var entrees: [Entree] {
        if estProfil || estStory {
            return [
                Entree(id: "lien", symbole: "link", titre: "Copier le lien", rouge: false) {
                    etat.feuille = nil; etat.signaler("Lien copié")
                },
                Entree(id: "partager", symbole: "square.and.arrow.up", titre: "Partager dans…", rouge: false) {
                    etat.feuille = .partage(cible)
                },
                Entree(id: "sourdine", symbole: "speaker.slash", titre: "Mettre en sourdine", rouge: false) {
                    etat.feuille = nil; etat.signaler("Compte mis en sourdine")
                },
                Entree(id: "signaler", symbole: "exclamationmark.triangle", titre: "Signaler", rouge: true) {
                    etat.feuille = nil; etat.signaler("Signalement transmis")
                },
                Entree(id: "bloquer", symbole: "nosign", titre: "Bloquer", rouge: true) {
                    etat.feuille = nil; etat.signaler("Blocage indisponible dans cette version")
                }
            ]
        }
        let enregistre = etat.enregistres.contains(cible)
        return [
            Entree(id: "enregistrer", symbole: enregistre ? "bookmark.slash" : "bookmark",
                   titre: enregistre ? "Retirer des enregistrements" : "Enregistrer", rouge: false) {
                etat.basculerEnregistre(cible); etat.feuille = nil
            },
            Entree(id: "lien", symbole: "link", titre: "Copier le lien", rouge: false) {
                etat.feuille = nil; etat.signaler("Lien copié")
            },
            Entree(id: "partager", symbole: "square.and.arrow.up", titre: "Partager dans…", rouge: false) {
                etat.feuille = .partage(cible)
            },
            Entree(id: "interet", symbole: "eye.slash", titre: "Ça ne m'intéresse pas", rouge: false) {
                etat.feuille = nil; etat.signaler("Vous verrez moins de publications de ce type")
            },
            Entree(id: "apropos", symbole: "info.circle", titre: "À propos de ce compte", rouge: false) {
                etat.feuille = nil; etat.signaler("Fiche du compte — TODO tournage")
            },
            Entree(id: "signaler", symbole: "exclamationmark.triangle", titre: "Signaler", rouge: true) {
                etat.feuille = nil; etat.signaler("Signalement transmis")
            }
        ]
    }

    var body: some View {
        IgConteneurFeuille(fraction: 0.52, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                Text(IgCatalogue.libelle(cible))
                    .font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6).padding(.bottom, 12)
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(entrees) { e in ligne(e) }
                        Color.clear.frame(height: 20)
                    }
                }
            }
        }
    }

    private func ligne(_ e: Entree) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                Image(systemName: e.symbole).font(.system(size: 17))
                    .foregroundStyle(e.rouge ? Color(hex: 0xFF453A) : Color.white)
                    .frame(width: 26)
                Text(e.titre).font(.system(size: 15.5))
                    .foregroundStyle(e.rouge ? Color(hex: 0xFF453A) : Color.white)
                Spacer(minLength: 4)
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); e.action() }
            IgSeparateur().padding(.leading, 59)
        }
    }
}

// ============================================================ 25. MENU DU FLUX « ⌄ » (§4.4)
// D82-A : le chevron de « Pour vous » ouvre RÉELLEMENT le sélecteur de flux et le feed change.
struct IgFeuilleMenuFlux: View {
    @ObservedObject var etat: IgEtat

    private static let flux: [(String, String)] = [
        ("Pour vous", "sparkles"),
        ("Suivi(e)s", "person.2"),
        ("Favoris", "star")
    ]

    var body: some View {
        IgConteneurFeuille(fraction: 0.34, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                Text("Choisir le flux").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.top, 8).padding(.bottom, 14)
                ForEach(Array(IgFeuilleMenuFlux.flux.enumerated()), id: \.offset) { _, f in
                    ligne(nom: f.0, symbole: f.1)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func ligne(nom: String, symbole: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                Image(systemName: symbole).font(.system(size: 17)).foregroundStyle(.white).frame(width: 26)
                Text(nom).font(.system(size: 16, weight: etat.flux == nom ? .semibold : .regular))
                    .foregroundStyle(.white)
                Spacer(minLength: 4)
                if etat.flux == nom {
                    Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(IgTheme.lien)
                }
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); etat.flux = nom; etat.feuille = nil }
            IgSeparateur().padding(.leading, 59)
        }
    }
}

// ============================================================ 26. FEUILLE DE CRÉATION « + » (§5-3)
// TODO tournage : le menu du « + » du feed n'a jamais été filmé. Version sobre, sans invention
// de chrome : les entrées qui produisent du contenu ouvrent la pellicule de Sarah (D82-A),
// « Direct » bascule sur l'onglet DM.
struct IgFeuilleCreation: View {
    @ObservedObject var etat: IgEtat

    var body: some View {
        IgConteneurFeuille(fraction: 0.42, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                Text("Créer").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.top, 6).padding(.bottom, 16)
                ligne("photo.on.rectangle", "Publication") { etat.feuille = .pellicule("creation.post") }
                ligne("plus.circle", "Story") { etat.feuille = .pellicule("creation.story") }
                ligne("play.rectangle", "Reel") { etat.feuille = .pellicule("creation.reel") }
                ligne("paperplane", "Message") { etat.feuille = nil; etat.fermerTout(); etat.onglet = 2 }
                Spacer(minLength: 0)
            }
        }
    }

    private func ligne(_ symbole: String, _ titre: String, _ action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                Image(systemName: symbole).font(.system(size: 17)).foregroundStyle(.white).frame(width: 26)
                Text(titre).font(.system(size: 15.5)).foregroundStyle(.white)
                Spacer(minLength: 4)
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(IgTheme.secondaire)
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); action() }
            IgSeparateur().padding(.leading, 59)
        }
    }
}

// ============================================================ 27. PICKER DE PELLICULE
// Sert à la création ET à l'envoi d'une photo dans une conversation (bouton caméra indigo
// du composer, §2.8). Les images sont celles de la pellicule de Sarah — rien d'inventé.
struct IgFeuillePellicule: View {
    let cible: String
    @ObservedObject var etat: IgEtat
    @State private var choisie: String? = nil

    private var images: [String] { DonneesInsta.mosaique }
    private var colonnes: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 2), count: 3) }

    private var titre: String {
        if cible.hasPrefix("creation.") { return "Pellicule" }
        return "Envoyer une photo"
    }

    var body: some View {
        IgConteneurFeuille(fraction: 0.68, fond: Color(hex: 0x101315), fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                entete
                ScrollView {
                    LazyVGrid(columns: colonnes, spacing: 2) {
                        ForEach(Array(images.enumerated()), id: \.offset) { _, cle in
                            vignette(cle)
                        }
                    }
                    .padding(.horizontal, 2)
                    Color.clear.frame(height: 16)
                }
            }
        }
    }

    private var entete: some View {
        ZStack {
            Text(titre).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
            HStack {
                Text("Annuler").font(.system(size: 15)).foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); etat.feuille = nil }
                Spacer()
                Text("Envoyer").font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(choisie == nil ? IgTheme.secondaire : IgTheme.lien)
                    .contentShape(Rectangle())
                    .onTapGesture { valider() }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func vignette(_ cle: String) -> some View {
        IgPhoto(cle: cle)
            .frame(height: IgGrille.cellule)
            .clipped()
            .overlay(alignment: .topTrailing) {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 1.5)
                    .background(Circle().fill(choisie == cle ? IgTheme.lien : Color.black.opacity(0.25)))
                    .frame(width: 20, height: 20)
                    .padding(6)
            }
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); choisie = cle }
    }

    private func valider() {
        guard choisie != nil else { etat.signaler("Choisissez d'abord une photo"); return }
        etat.feuille = nil
        if cible.hasPrefix("creation.") {
            etat.signaler("Photo prête à être publiée")
        } else {
            let conv = IgCatalogue.conversation(cible)
            etat.envoyer("📷 Photo", dans: conv)
            etat.signaler("Photo envoyée à \(conv.compte.nom)")
        }
    }
}

// ============================================================ 28. FEUILLE « ≡ » DU PROFIL DE SARAH
struct IgFeuilleActionsProfil: View {
    @ObservedObject var etat: IgEtat

    private static let entrees: [(String, String, String)] = [
        ("gearshape", "Paramètres et confidentialité", "Réglages du compte — TODO tournage"),
        ("clock.arrow.circlepath", "Votre activité", "Historique d'activité — TODO tournage"),
        ("bookmark", "Enregistrements", "Aucune publication enregistrée"),
        ("archivebox", "Archives", "Aucune story archivée"),
        ("qrcode", "Code QR", "Code QR indisponible sans connexion"),
        ("star.circle", "Amis proches", "Aucun ami proche défini")
    ]

    var body: some View {
        IgConteneurFeuille(fraction: 0.56, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                Text(DonneesInsta.sarah.id).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.top, 6).padding(.bottom, 14)
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(IgFeuilleActionsProfil.entrees.enumerated()), id: \.offset) { _, e in
                            ligne(symbole: e.0, titre: e.1, message: e.2)
                        }
                        Color.clear.frame(height: 20)
                    }
                }
            }
        }
    }

    private func ligne(symbole: String, titre: String, message: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                Image(systemName: symbole).font(.system(size: 17)).foregroundStyle(.white).frame(width: 26)
                Text(titre).font(.system(size: 15.5)).foregroundStyle(.white)
                Spacer(minLength: 4)
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(IgTheme.secondaire)
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); etat.feuille = nil; etat.signaler(message) }
            IgSeparateur().padding(.leading, 59)
        }
    }
}

// ============================================================ 29. WRAPPERS DE CAPTURE (boucle miroir D63)
// Une vue par identifiant ECRAN. Chacune possède SON IgEtat (@StateObject) : aucun état
// externe, aucun binding, aucune valeur optionnelle force-déballée — la capture est
// reproductible et ne dépend d'aucune interaction préalable.

/// Fond commun d'une capture de feuille : l'écran sous-jacent, assombri comme dans les frames.
struct IgFondFeuilleCapture<Contenu: View>: View {
    var sousJacent: () -> AnyView
    var contenu: () -> Contenu

    init(@ViewBuilder sousJacent: @escaping () -> AnyView,
         @ViewBuilder contenu: @escaping () -> Contenu) {
        self.sousJacent = sousJacent
        self.contenu = contenu
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            IgTheme.fond.ignoresSafeArea()
            sousJacent()
            Color.black.opacity(0.45).ignoresSafeArea()
            contenu()
        }
        .preferredColorScheme(.dark)
    }
}

struct IgCaptureCommentaires: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgFondFeuilleCapture(sousJacent: { AnyView(IgFeedVue(etat: etat)) }) {
            IgFeuilleCommentaires(post: IgCatalogue.post("post.annecy"), etat: etat)
        }
    }
}

struct IgCapturePartage: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgFondFeuilleCapture(sousJacent: { AnyView(IgFeedVue(etat: etat)) }) {
            IgFeuillePartage(cible: "post.annecy", etat: etat)
        }
    }
}

struct IgCaptureDetail: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgDetailPostVue(post: DonneesInsta.postSarah, etat: etat).preferredColorScheme(.dark)
    }
}

struct IgCaptureNotifications: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgNotificationsVue(etat: etat).preferredColorScheme(.dark)
    }
}

struct IgCaptureReels: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        ZStack { IgTheme.fond.ignoresSafeArea(); IgReelsVue(etat: etat) }.preferredColorScheme(.dark)
    }
}

struct IgCaptureRecherche: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        ZStack { IgTheme.fond.ignoresSafeArea(); IgRechercheVue(etat: etat) }.preferredColorScheme(.dark)
    }
}

struct IgCaptureProfil: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        ZStack { IgTheme.fond.ignoresSafeArea(); IgProfilVue(etat: etat) }.preferredColorScheme(.dark)
    }
}

struct IgCaptureStory: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgStoryVue(compte: DonneesInsta.chloe, etat: etat).preferredColorScheme(.dark)
    }
}

struct IgCaptureProfilPrive: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgProfilTiersVue(compte: DonneesInsta.lea, etat: etat).preferredColorScheme(.dark)
    }
}

struct IgCaptureDM: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        ZStack { IgTheme.fond.ignoresSafeArea(); IgDMListeVue(etat: etat) }.preferredColorScheme(.dark)
    }
}

struct IgCaptureDMConv: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgFilVue(conv: IgCatalogue.conversation("dm.chloe"), etat: etat).preferredColorScheme(.dark)
    }
}
