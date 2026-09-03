// Instagram — v3 D91 (03/09) — reconstruit contre les 239 frames de Joachim, mesures audit/instagram.md
// v3.1 D92 (03/09 soir) — retours 279
//
// Ce fichier remplace intégralement la v1 (« Instagram 2022 »). La référence est iOS 26 :
//   · barre d'onglets = capsule flottante 370×52 pt, r 26, 16 pt de marge, 26 pt du bas
//     (maison · reels · DM · loupe · avatar), pastille active 78×41 pt #2E3236   → e001, e072, e197
//   · en-tête du feed = « + » à gauche · « Pour vous ⌄ » centré · cœur seul à droite  → e001
//   · accent #3C51FC (boutons pleins) / #4D6CFF (liens, pastilles, points actifs)     → e148, e170
//   · stories : avatar 79 pt, anneau extérieur 93 pt, pas 104,5 pt, jaune #D8BA00 en
//     bas-gauche → violet #C916CA en haut-droite (AngularGradient décalé de 135°)     → e001
//   · icônes de publication maison : cœur, cercle à queue, repost, triangle inversé,
//     signet ; compteurs INLINE                                                       → e003, e045, e170
//   · DM : bulles envoyées en dégradé vertical #AD29D5 → #6B30FE à l'échelle du fil,
//     bulles reçues #21242B, caméra ronde indigo #5249FF à gauche du composer         → e073, e082
//
// Choix d'architecture (anti-blocage, retour Joachim « story ouverte = bloqué ») :
//   AUCUN .sheet / .fullScreenCover / NavigationStack dans cette app. Tous les écrans
//   secondaires sont des overlays de la ZStack racine, EN DESSOUS de BarreHome, qui reste
//   donc toujours atteignable. Tout l'état mutable vit dans IgEtat (ObservableObject).
//
// ---------------------------------------------------------------------------------------
// LOT 280 — application du cahier des charges D92 « juste milieu » (audit/retours-279.md §3).
// Principe : toute affordance affichée a une conséquence réelle et persistante, sinon elle
// est RETIRÉE. Plus aucun message « TODO tournage » dans l'app.
//
//   · Relations RÉELLES : IgReseau.abonnements ne décrit QUE « qui suit qui ». Les followers
//     sont obtenus par INVERSION de cette table : un compteur ne peut donc jamais contredire
//     sa liste. Tap sur « N followers » / « N suivi(e)s » ouvre la liste, chaque ligne ouvre
//     le profil. Les compteurs de publications valent le nombre de vignettes de la grille.
//   · DM : ouverture sur le dernier message (ScrollViewReader), appui long → réactions
//     retirables, appels audio/vidéo réels, composer = champ + caméra indigo UNIQUEMENT
//     (vocal / emoji / + retirés, plus aucun état vocal global), aperçu de liste recalculé
//     depuis le dernier message, « nouveau message » → suggestions qui ouvrent ou CRÉENT
//     une conversation.
//   · Partage : choisir un destinataire dépose une CARTE (publication / story / profil / reel)
//     dans la conversation correspondante. « Republier dans votre story » retiré partout.
//   · Création minimale : une photo de la pellicule → publication en tête du fil ET dans la
//     grille du profil ; story → « Votre story » et visionneuse.
//   · Liens de bio : navigateur INTERNE à Instagram (comme le vrai Instagram). Voir la note
//     « pourquoi pas le Safari du jeu » au-dessus de IgPagesWeb.
//   · Retirés : ≡ des publications / reels / recherche / story, « personne + », onglet
//     Republications des profils, caméra + like + commentaire de la visionneuse de story,
//     « Votre activité » / « Code QR » / « Amis proches » du menu profil, écran de réglages
//     de conversation, dictaphone. Détail dans audit/instagram-lot280.md.
//
// Contenu : Sarah Levasseur (sarah.lvsr), photographe amateure lyonnaise. Aucune donnée réelle.
// Tous les types de ce fichier sont préfixés Ig… pour ne heurter aucun autre fichier du projet.
import SwiftUI
import UIKit

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
    static let coeurPlein      = Color(hex: 0xFF3040)
    static let pointInactif    = Color(hex: 0x393C43)
    static let vert            = Color(hex: 0x1DBF52)

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

// ============================================================ 2. DONNÉES
// D92 : plus aucun compteur STOCKÉ pour les relations et les publications — ils sont
// calculés depuis les listes réelles (IgReseau + grille). Un compteur ne peut donc pas
// mentir sur ce qui est accessible.

struct IgCompte: Identifiable, Equatable {
    let id: String                 // pseudo
    var nom: String
    var photo: String? = nil
    var teinte: UInt = 0x5B7CFA
    var prive: Bool = false
    var verifie: Bool = false
    var estPro: Bool = false       // compte pro / lieu / média (sert au filtre Reels « Ami(e)s »)
    var bio: String = ""
    var lien: String? = nil
    var enStory: Bool = false
    var grille: [String] = []
    static func == (g: IgCompte, d: IgCompte) -> Bool { g.id == d.id }
}

struct IgCommentaire: Identifiable, Equatable {
    let id: String
    var compte: IgCompte
    var texte: String
    var quand: String
    var jaime: Int = 0
    static func == (g: IgCommentaire, d: IgCommentaire) -> Bool { g.id == d.id }
}

struct IgPost: Identifiable, Equatable {
    let id: String
    var compte: IgCompte
    var lieu: String? = nil
    var audio: String? = nil
    var images: [String]
    var carrouselGrille: Bool = false      // e001 : les 4 vues du carrousel en grille 2×2
    var estVideo: Bool = false             // D92 : prévu pour les publications vidéo, NON utilisé pour l'instant
    var jaime: String
    var reposts: String
    var envois: String
    var aimePar: String
    var avatarsAimePar: [String]
    var legende: String
    var date: String
    var sponsorise: Bool = false
    var cta: String? = nil
    var commentaires: [IgCommentaire] = []
    // Comptes identifiés sur la publication (onglet « identifications » des profils).
    var identifies: [String] = []
    static func == (g: IgPost, d: IgPost) -> Bool { g.id == d.id }
}

// ---------- contenu d'un message : texte, photo, ou CARTE de partage (D92)
struct IgCarteJointe: Equatable {
    var image: String
    var auteur: String
    var legende: String
    var entete: String? = nil      // « Story de chloe.brt », « a répondu à votre story »…
    var cible: String? = nil       // identifiant à ouvrir au tap (post / profil), nil = rien
    var profil: String? = nil      // pseudo si la carte est un profil partagé
}

enum IgContenuMessage: Equatable {
    case texte(String)
    case photo(String)
    case carte(IgCarteJointe)
}

struct IgMessage: Identifiable, Equatable {
    let id: String
    var deMoi: Bool
    var contenu: IgContenuMessage

    init(id: String, deMoi: Bool, texte: String) {
        self.id = id; self.deMoi = deMoi; self.contenu = .texte(texte)
    }
    init(id: String, deMoi: Bool, contenu: IgContenuMessage) {
        self.id = id; self.deMoi = deMoi; self.contenu = contenu
    }

    /// Résumé d'une ligne pour l'aperçu de la liste des conversations.
    var resume: String {
        switch contenu {
        case .texte(let t): return t
        case .photo: return "Photo"
        case .carte(let c):
            if c.profil != nil { return "Profil partagé" }
            if let e = c.entete, e.contains("story") { return "A répondu à une story" }
            return "Publication partagée"
        }
    }
    static func == (g: IgMessage, d: IgMessage) -> Bool { g.id == d.id && g.contenu == d.contenu }
}

struct IgConversation: Identifiable, Equatable {
    let id: String
    var compte: IgCompte
    var apercuInitial: String
    var quand: String = ""
    var nonLu: Bool = false
    var demande: Bool = false
    var separateur: String = "2 JUIN À 02:26"
    var messages: [IgMessage]
    static func == (g: IgConversation, d: IgConversation) -> Bool {
        g.id == d.id && g.messages.count == d.messages.count
    }
}

struct IgNote: Identifiable {
    let id: String
    var compte: IgCompte
    var texte: String
    var sousTitre: String
    var violette: Bool = false
}

// Menu « ≡ » conservé UNIQUEMENT pour le menu du profil de Sarah (D92 : Paramètres,
// Enregistrements, Archives). Retiré des publications, des reels, de la recherche et
// de la visionneuse de story.
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

// ============================================================ 2b. PERSONNAGES DE L'UNIVERS
enum DonneesInsta {
    // ---------- comptes (tous ouvrables : toute ligne de liste mène à un vrai profil)
    static let sarah = IgCompte(
        id: "sarah.lvsr", nom: "Sarah Levasseur", photo: "p04", teinte: 0x5B7CFA,
        bio: "Lyon 🌸 photo argentique, céramique et randos\n📷 les pellicules du week-end",
        lien: "sarahlevasseur.myportfolio.com",
        grille: ["p30", "p31", "p32", "p33", "p34", "p35", "p36", "p37", "p38", "p39", "p40", "p41"])

    static let chloe = IgCompte(
        id: "chloe.brt", nom: "Chloé Berthier", photo: "p12", teinte: 0xE64980,
        bio: "Annecy → Lyon\nfromages, lacs et mauvaises blagues",
        enStory: true,
        grille: ["p20", "p21", "p22", "p23", "p24", "p25", "p26", "p27", "p28"])

    static let ines = IgCompte(
        id: "ines.djl", nom: "Inès Djellal", photo: nil, teinte: 0x8B5CF6,
        bio: "infirmière · Lyon 7e\nje cours plus vite que mes plannings",
        enStory: true,
        grille: ["p22", "p25", "p28", "p31", "p34", "p37"])

    static let atelier = IgCompte(
        id: "atelierpoterie.lyon3", nom: "Atelier Poterie Lyon 3", photo: nil, teinte: 0xFF9F0A,
        estPro: true,
        bio: "Cours de tournage & modelage · Lyon 3e\nInscriptions septembre ouvertes",
        lien: "atelierpoterie-lyon3.fr",
        enStory: true,
        grille: ["p33", "p36", "p39", "p21", "p24", "p27"])

    static let lea = IgCompte(
        id: "lea.mrx", nom: "Léa ☀️", photo: "p18", teinte: 0x30D1C4, prive: true,
        lien: "vsco.co/leamoreau",
        enStory: true,
        grille: ["p23", "p26"])

    static let lyon = IgCompte(
        id: "lyon.maville", nom: "Lyon Ma Ville", photo: nil, teinte: 0x0A84FF,
        verifie: true, estPro: true,
        bio: "Ce qui se passe à Lyon, tous les jours ☀️",
        lien: "lyonmaville.fr",
        enStory: true,
        grille: ["p36", "p29", "p32", "p35", "p38", "p41"])

    // Marc — le compte par lequel arrive l'arnaque sentimentale (fil narratif du jeu).
    // Signal volontairement conservé : il SUIT tout le monde et n'est suivi que par 2 comptes
    // (asymétrie visible dans les listes réelles, plus dans un compteur inventé).
    static let marc = IgCompte(
        id: "marc.dlny", nom: "Marc Delaunay", photo: nil, teinte: 0x2F6F5F,
        bio: "Ingénieur offshore · actuellement au large de Malte\nla photo, la mer, le reste suit",
        enStory: true,
        grille: ["p26", "p29", "p23"])

    // Compte à l'origine d'une demande de message (onglet « Demandes »).
    static let alex = IgCompte(
        id: "alex_mtn_photo", nom: "Alexandre M.", photo: nil, teinte: 0x7A5CFF,
        bio: "photographe · dispo pour shooting",
        grille: ["p20"])

    static let lumiere = IgCompte(
        id: "atelier.lumiere.fr", nom: "Atelier Lumière", photo: nil, teinte: 0xC2410C,
        estPro: true,
        bio: "Stages de photo argentique en Rhône-Alpes",
        lien: "atelier-lumiere.fr",
        grille: ["p35", "p30", "p37"])

    static let thomas = IgCompte(
        id: "thomas.brn", nom: "Thomas Bernard", photo: nil, teinte: 0x4C6EF5,
        bio: "vélo, bricolage, pizzas maison · Villeurbanne",
        grille: ["p29", "p32", "p35", "p38"])

    static let julie = IgCompte(
        id: "julie.pnt", nom: "Julie Pinault", photo: nil, teinte: 0xD6336C,
        bio: "libraire à la Croix-Rousse 📚",
        enStory: true,
        grille: ["p21", "p24", "p27", "p30", "p33"])

    static let camille = IgCompte(
        id: "camille.rss", nom: "Camille Rousseau", photo: nil, teinte: 0x0CA678,
        bio: "prof de SVT · jardin partagé Lyon 7e 🌱",
        grille: ["p22", "p25", "p28", "p31"])

    static let maxime = IgCompte(
        id: "maxime.gtr", nom: "Maxime Gauthier", photo: nil, teinte: 0x845EF7,
        bio: "trail & montagne · 4 saisons par an",
        grille: ["p34", "p37", "p40"])

    static let cafe = IgCompte(
        id: "cafe.voyageurs.lyon", nom: "Café des Voyageurs", photo: nil, teinte: 0x8D6E4A,
        estPro: true,
        bio: "Torréfaction sur place · Lyon 1er\nDu mardi au dimanche",
        lien: "cafe-voyageurs-lyon.fr",
        grille: ["p23", "p26", "p29", "p32"])

    static let rando = IgCompte(
        id: "rando.rhonealpes", nom: "Rando Rhône-Alpes", photo: nil, teinte: 0x2B8A3E,
        estPro: true,
        bio: "Itinéraires, refuges et bons plans en Rhône-Alpes",
        lien: "rando-rhonealpes.fr",
        grille: ["p38", "p41", "p36", "p39", "p35"])

    /// Le casting complet. TOUTE liste de l'app pointe dans ce tableau : aucune ligne
    /// n'affiche un compte qui n'aurait pas de profil ouvrable.
    static let tous: [IgCompte] = [sarah, chloe, ines, lea, atelier, lyon, marc, alex,
                                   lumiere, thomas, julie, camille, maxime, cafe, rando]

    /// Les comptes autres que Sarah (rangée de stories, recherche, suggestions…).
    static let comptes: [IgCompte] = tous.filter { $0.id != sarah.id }

    static func compte(_ pseudo: String) -> IgCompte {
        tous.first(where: { $0.id == pseudo }) ?? chloe
    }
    static func comptes(_ pseudos: [String]) -> [IgCompte] {
        pseudos.compactMap { p in tous.first(where: { $0.id == p }) }
    }
}

// ============================================================ 2c. RÉSEAU (D92 : listes réelles)
// Une SEULE table : « qui suit qui ». Les followers d'un compte sont obtenus par inversion,
// donc un compteur de followers ne peut JAMAIS contredire la liste affichée.
// Les abonnements de Sarah ne sont PAS ici : ils vivent dans IgEtat.suivis, pour que les
// boutons « Suivre / Suivi(e) » modifient réellement les deux listes.
enum IgReseau {
    static let abonnementsSarah: [String] = [
        "chloe.brt", "ines.djl", "lea.mrx", "atelierpoterie.lyon3", "lyon.maville",
        "marc.dlny", "atelier.lumiere.fr", "thomas.brn", "julie.pnt", "camille.rss",
        "cafe.voyageurs.lyon", "rando.rhonealpes"
    ]

    /// Comptes marqués « Favoris » par Sarah (sélecteur du fil).
    static let favorisSarah: [String] = ["chloe.brt", "ines.djl", "atelierpoterie.lyon3"]

    static let abonnements: [String: [String]] = [
        "chloe.brt": ["sarah.lvsr", "ines.djl", "lea.mrx", "lyon.maville", "atelierpoterie.lyon3",
                      "thomas.brn", "julie.pnt", "camille.rss", "maxime.gtr", "rando.rhonealpes"],
        "ines.djl": ["sarah.lvsr", "chloe.brt", "lea.mrx", "lyon.maville",
                     "cafe.voyageurs.lyon", "julie.pnt"],
        "lea.mrx": ["sarah.lvsr", "chloe.brt", "ines.djl"],
        "atelierpoterie.lyon3": ["sarah.lvsr", "chloe.brt", "lyon.maville", "cafe.voyageurs.lyon"],
        "lyon.maville": ["cafe.voyageurs.lyon", "atelierpoterie.lyon3", "rando.rhonealpes"],
        // Marc et Alexandre suivent tout le monde et ne sont presque pas suivis en retour.
        "marc.dlny": ["sarah.lvsr", "chloe.brt", "ines.djl", "lea.mrx", "atelierpoterie.lyon3",
                      "lyon.maville", "alex_mtn_photo", "atelier.lumiere.fr", "thomas.brn",
                      "julie.pnt", "camille.rss", "maxime.gtr", "cafe.voyageurs.lyon",
                      "rando.rhonealpes"],
        "alex_mtn_photo": ["sarah.lvsr", "chloe.brt", "ines.djl", "lea.mrx", "julie.pnt",
                           "camille.rss", "maxime.gtr", "marc.dlny", "lyon.maville",
                           "atelierpoterie.lyon3", "atelier.lumiere.fr", "thomas.brn"],
        "atelier.lumiere.fr": ["sarah.lvsr", "atelierpoterie.lyon3", "lyon.maville"],
        "thomas.brn": ["sarah.lvsr", "chloe.brt", "lyon.maville", "maxime.gtr"],
        "julie.pnt": ["sarah.lvsr", "chloe.brt", "ines.djl", "camille.rss", "lyon.maville"],
        "camille.rss": ["sarah.lvsr", "chloe.brt", "julie.pnt", "atelierpoterie.lyon3"],
        "maxime.gtr": ["sarah.lvsr", "chloe.brt", "thomas.brn", "rando.rhonealpes", "lyon.maville"],
        "cafe.voyageurs.lyon": ["lyon.maville", "atelierpoterie.lyon3"],
        "rando.rhonealpes": ["lyon.maville", "cafe.voyageurs.lyon"]
    ]
}

// ============================================================ 2d. PAGES WEB INTERNES (liens de bio)
// Pourquoi PAS le Safari du jeu : SafariApp.PageRendueVue ne sait rendre que des clés connues
// (« servicepublic », « victimes », « cyber », « forum », « fonfon », « vessel », « google:… »,
// « article:… », « site:… »). Un domaine inconnu retombe sur son `default`, c'est-à-dire la
// fiche service-public « escroquerie sentimentale » — absurde pour un portfolio ; et
// « site:… » rend une vitrine de commerce « Lyon 1er — depuis 1987 ». Aucune page de Safari
// ne peut donc représenter honnêtement ces liens, et SafariApp.swift n'est pas modifiable
// depuis ce lot. Le lien ouvre donc le navigateur INTERNE d'Instagram — ce que fait le vrai
// Instagram. Si Joachim veut le Safari du jeu, il faudra y ajouter une page « portfolio ».
struct IgPageWeb {
    var domaine: String
    var titre: String
    var sousTitre: String
    var paragraphes: [String]
    var images: [String] = []
    var pied: String = ""
}

enum IgPagesWeb {
    static func page(_ domaine: String) -> IgPageWeb {
        switch domaine {
        case "sarahlevasseur.myportfolio.com":
            return IgPageWeb(
                domaine: domaine,
                titre: "Sarah Levasseur",
                sousTitre: "Photographie argentique — Lyon",
                paragraphes: [
                    "Je photographie surtout le matin, en argentique, autour de Lyon et dans les massifs alentour. Portra 400 la plupart du temps, parfois de la HP5 quand la lumière ne veut rien donner.",
                    "Séries en cours : les pentes de la Croix-Rousse dans la brume, le lac d'Annecy hors saison, et un travail plus lent sur les mains des potiers de l'atelier du 3e.",
                    "Tirages disponibles sur demande. Pour un projet ou une commande, le plus simple reste un message."
                ],
                images: ["p30", "p34", "p38", "p41", "p31", "p36"],
                pied: "© Sarah Levasseur — tous droits réservés")
        case "atelierpoterie-lyon3.fr":
            return IgPageWeb(
                domaine: domaine,
                titre: "Atelier Poterie Lyon 3",
                sousTitre: "Cours de tournage et de modelage",
                paragraphes: [
                    "L'atelier accueille douze personnes par séance, débutants compris. Le matériel, les terres et les émaux sont fournis ; les pièces sont cuites sur place et récupérables environ trois semaines après le cours.",
                    "Créneaux hebdomadaires : mardi 18 h – 21 h, jeudi 18 h – 21 h, samedi 10 h – 13 h. Inscriptions ouvertes pour le trimestre de septembre.",
                    "34 rue Feuillat, 69003 Lyon — à cinq minutes du métro Grange Blanche."
                ],
                images: ["p33", "p39", "p24"],
                pied: "Atelier Poterie Lyon 3 — association loi 1901")
        case "lyonmaville.fr":
            return IgPageWeb(
                domaine: domaine,
                titre: "Lyon Ma Ville",
                sousTitre: "L'actualité lyonnaise au quotidien",
                paragraphes: [
                    "À la une : la roseraie du parc de la Tête d'Or prolonge ses horaires jusqu'au 30 septembre, avec fermeture des grilles à 20 h 30.",
                    "Également : réouverture de la passerelle Saint-Vincent après six semaines de travaux, et retour des marchés nocturnes sur les quais tous les jeudis.",
                    "Circulation : la montée de la Grande-Côte reste fermée aux véhicules jusqu'à la fin du mois."
                ],
                images: ["p36", "p29", "p32"],
                pied: "Lyon Ma Ville — rédaction indépendante")
        case "vsco.co/leamoreau":
            return IgPageWeb(
                domaine: domaine,
                titre: "leamoreau",
                sousTitre: "Journal visuel",
                paragraphes: [
                    "Peu de photos, choisies lentement. Surtout des fins de journée et des fenêtres.",
                    "Ce profil est volontairement discret : rien n'est indexé, rien n'est commenté."
                ],
                images: ["p23", "p26"],
                pied: "vsco.co")
        case "atelier-lumiere.fr":
            return IgPageWeb(
                domaine: domaine,
                titre: "Atelier Lumière",
                sousTitre: "Stages de photographie argentique en Rhône-Alpes",
                paragraphes: [
                    "Trois jours dans le Beaujolais : prise de vue le matin, développement et tirage l'après-midi dans un labo installé sur place. Groupes de huit personnes maximum.",
                    "Le stage comprend l'hébergement, les repas, deux pellicules noir et blanc et l'ensemble des consommables de laboratoire.",
                    "Prochaines dates : 11-13 octobre, puis 8-10 novembre. Places limitées."
                ],
                images: ["p35", "p30", "p37"],
                pied: "Atelier Lumière — organisme de formation")
        case "cafe-voyageurs-lyon.fr":
            return IgPageWeb(
                domaine: domaine,
                titre: "Café des Voyageurs",
                sousTitre: "Torréfaction sur place — Lyon 1er",
                paragraphes: [
                    "Nous torréfions deux fois par semaine, en petites quantités. La carte change selon les arrivages ; il y a toujours un filtre du moment et un espresso plus rond.",
                    "Ouvert du mardi au dimanche, de 8 h à 18 h. Fermé le lundi.",
                    "Vente de grains au comptoir, moulus sur demande."
                ],
                images: ["p23", "p26", "p29"],
                pied: "Café des Voyageurs")
        case "rando-rhonealpes.fr":
            return IgPageWeb(
                domaine: domaine,
                titre: "Rando Rhône-Alpes",
                sousTitre: "Itinéraires, refuges et conditions du moment",
                paragraphes: [
                    "Conditions de la semaine : neige résiduelle au-dessus de 2 400 m sur les itinéraires nord, sentiers secs ailleurs. Les torrents du Vercors restent hauts après les orages.",
                    "Nouveautés : quatre boucles ajoutées dans les Bauges, dont deux accessibles en train depuis Lyon.",
                    "Chaque fiche indique le dénivelé, la durée réelle relevée et les points d'eau."
                ],
                images: ["p38", "p41", "p36"],
                pied: "Rando Rhône-Alpes — contributions bénévoles")
        default:
            return IgPageWeb(
                domaine: domaine,
                titre: domaine,
                sousTitre: "Page indisponible",
                paragraphes: [
                    "Cette page n'a pas pu être chargée. Le serveur n'a pas répondu.",
                    "Vérifiez l'adresse ou réessayez plus tard."
                ],
                pied: "")
        }
    }
}

// ============================================================ 2e. PUBLICATIONS
extension DonneesInsta {
    // ---------- pool de commentaires (chaque publication générée en reçoit 1 à 3 :
    // le compteur affiché vaut TOUJOURS le nombre de commentaires réellement lisibles)
    private static let modelesCommentaires: [(String, String)] = [
        ("chloe.brt", "Magnifique 😍"),
        ("ines.djl", "La lumière !!"),
        ("julie.pnt", "Tu me le tires en grand format ?"),
        ("camille.rss", "Ça donne envie d'y aller"),
        ("thomas.brn", "Très beau cadrage"),
        ("maxime.gtr", "On y retourne quand ?"),
        ("atelierpoterie.lyon3", "Merci du partage 🏺"),
        ("lyon.maville", "Superbe 👏"),
        ("sarah.lvsr", "Ahh merci 🥹"),
        ("cafe.voyageurs.lyon", "On l'imprime pour le comptoir ?")
    ]

    private static let quandCommentaires: [String] = ["2 h", "5 h", "1 j", "3 j", "1 sem."]

    private static func commentairesGeneres(_ identifiant: String, _ graine: Int,
                                            _ auteur: String) -> [IgCommentaire] {
        let combien = 1 + graine % 3
        var sortie: [IgCommentaire] = []
        var n = 0
        var essai = 0
        while n < combien && essai < modelesCommentaires.count {
            let m = modelesCommentaires[(graine + essai) % modelesCommentaires.count]
            essai += 1
            if m.0 == auteur { continue }          // on ne se commente pas soi-même
            sortie.append(IgCommentaire(id: "c.\(identifiant).\(n)",
                                        compte: compte(m.0),
                                        texte: m.1,
                                        quand: quandCommentaires[(graine + n) % quandCommentaires.count],
                                        jaime: (graine + n) % 4))
            n += 1
        }
        return sortie
    }

    private static let legendesGenerees: [String] = [
        "Fin de journée sur les quais.",
        "Deux pellicules, une seule vraiment bonne.",
        "Le silence du matin, avant tout le monde.",
        "Test de la nouvelle pellicule — je garde.",
        "Il a fallu attendre une heure pour cette lumière.",
        "Rien de prévu, et c'était très bien comme ça.",
        "Croix-Rousse, toujours les mêmes escaliers.",
        "Le vent s'est levé juste après.",
        "Un dimanche qui ne ressemblait à rien d'autre.",
        "Repérage pour la série de cet automne.",
        "Petite série sans prétention.",
        "Celle-là, je l'aime beaucoup."
    ]

    private static let lieuxGeneres: [String?] = [
        "Lyon 1er", nil, "Croix-Rousse, Lyon", nil, "Parc de la Tête d'Or",
        "Lyon 7e", nil, "Lac d'Annecy", "Vieux Lyon", nil
    ]

    private static let datesGenerees: [String] = [
        "Il y a 2 jours", "Il y a 1 semaine", "Il y a 2 semaines", "Il y a 3 semaines",
        "12 août 2026", "28 juillet 2026", "3 juillet 2026", "19 juin 2026"
    ]

    private static func suitStatiquement(_ qui: String, _ cible: String) -> Bool {
        if qui == sarah.id { return IgReseau.abonnementsSarah.contains(cible) }
        return (IgReseau.abonnements[qui] ?? []).contains(cible)
    }

    /// Un compte qui suit `compte` — sert au texte « Aimé par … ». Balayage déterministe
    /// de `tous` : aucune dépendance à l'ordre d'un dictionnaire, la capture est stable.
    private static func aimeur(_ compte: IgCompte) -> IgCompte {
        for c in tous where c.id != compte.id {
            if suitStatiquement(c.id, compte.id) { return c }
        }
        return sarah
    }

    /// Publications d'un compte, une par vignette de sa grille. Toute vignette de grille
    /// ouvre donc une publication cohérente (bon auteur, bonne image).
    static func postsDe(_ compte: IgCompte) -> [IgPost] {
        let grille = compte.grille
        let fan = aimeur(compte)
        return grille.enumerated().map { paire -> IgPost in
            let i = paire.offset
            let cle = paire.element
            let graine = i * 7 + compte.id.count
            let deux = (i % 4 == 3) && (i + 1 < grille.count)
            let images: [String] = deux ? [cle, grille[i + 1]] : [cle]
            let identifiant = "pub.\(compte.id).\(i)"
            return IgPost(
                id: identifiant,
                compte: compte,
                lieu: lieuxGeneres[graine % lieuxGeneres.count],
                audio: nil,
                images: images,
                jaime: "\(14 + (graine * 13) % 260)",
                reposts: "0",
                envois: "\(1 + graine % 21)",
                aimePar: "Aimé par \(fan.id) et d'autres personnes",
                avatarsAimePar: [fan.photo, compte.photo, sarah.photo].compactMap { $0 },
                legende: legendesGenerees[graine % legendesGenerees.count],
                date: datesGenerees[i % datesGenerees.count],
                commentaires: commentairesGeneres(identifiant, graine, compte.id))
        }
    }

    // ---------- commentaires écrits à la main des publications du fil
    private static func c(_ n: Int, _ compte: IgCompte, _ t: String, _ q: String, _ j: Int) -> IgCommentaire {
        IgCommentaire(id: "feed.c\(n)", compte: compte, texte: t, quand: q, jaime: j)
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
    static let commentairesStage: [IgCommentaire] = [
        c(10, julie,  "Il reste des places pour octobre ?", "6 h", 1),
        c(11, lumiere, "@julie.pnt oui, deux places sur la session du 11 !", "5 h", 0),
        c(12, maxime, "J'ai fait celui de mai, franchement top", "3 h", 4)
    ]

    // ---------- publications du fil
    static let feed: [IgPost] = [
        IgPost(id: "post.annecy", compte: chloe, lieu: "Lac d'Annecy",
               audio: "chloe.brt · Audio d'origine",
               images: ["p30", "p31", "p32", "p33"], carrouselGrille: true,
               jaime: "87", reposts: "12", envois: "23",
               aimePar: "Aimé par ines.djl et d'autres personnes",
               avatarsAimePar: ["p18", "p04", "p12"],
               legende: "4/4 🏆 Week-end parfait avec la meilleure 💙 Départ à 6 h, brume sur le lac, et une pellicule entière brûlée avant midi. #annecy #argentique",
               date: "Il y a 6 heures",
               commentaires: commentairesAnnecy,
               identifies: ["sarah.lvsr"]),

        IgPost(id: "post.sponso", compte: lumiere,
               lieu: nil, audio: nil, images: ["p35"],
               jaime: "1 204", reposts: "31", envois: "212",
               aimePar: "Aimé par atelierpoterie.lyon3 et d'autres personnes",
               avatarsAimePar: ["p12"],
               legende: "Trois jours de stage argentique dans le Beaujolais, labo compris. Places limitées pour octobre…",
               date: "Il y a 1 jour", sponsorise: true, cta: "S'inscrire",
               commentaires: commentairesStage),

        IgPost(id: "post.parc", compte: lyon, lieu: "Parc de la Tête d'Or",
               audio: "lyon.maville · Audio d'origine",
               images: ["p36"],
               jaime: "1 892", reposts: "204", envois: "1 038",
               aimePar: "Aimé par chloe.brt et d'autres personnes",
               avatarsAimePar: ["p12", "p04"],
               legende: "L'été indien s'installe sur le parc 🌇 Les meilleures heures : entre 18 h et 19 h 30, avant que la roseraie ne ferme.",
               date: "Il y a 3 semaines",
               commentaires: commentairesParc),

        IgPost(id: "post.poterie", compte: atelier, lieu: "Lyon 3e",
               audio: nil, images: ["p33", "p39"],
               jaime: "214", reposts: "8", envois: "37",
               aimePar: "Aimé par sarah.lvsr et d'autres personnes",
               avatarsAimePar: ["p04", "p18"],
               legende: "Les créations du cours du mardi soir 🏺 Inscriptions ouvertes pour septembre !",
               date: "Il y a 2 semaines",
               commentaires: commentairesAtelier,
               identifies: ["sarah.lvsr"])
    ]

    /// Toutes les publications connues : le fil + une par vignette de grille de chaque compte.
    /// C'est le registre unique de résolution (IgCatalogue.post) : aucun identifiant ne peut
    /// pointer dans le vide.
    static let publications: [IgPost] = feed + tous.flatMap { postsDe($0) }

    /// Mosaïque « Explore » : de VRAIES publications d'autres comptes, entrelacées pour ne pas
    /// afficher un compte après l'autre. Chaque tuile ouvre donc son détail (D92 : tuiles
    /// cliquables), avec le bon auteur et le bon nombre de commentaires.
    static let mosaique: [IgPost] = {
        let sources = tous.filter { $0.id != sarah.id && !$0.prive }
        var listes = sources.map { postsDe($0) }
        var sortie: [IgPost] = []
        var rang = 0
        while sortie.count < 21 {
            var ajoute = false
            for i in listes.indices where rang < listes[i].count {
                sortie.append(listes[i][rang])
                ajoute = true
                if sortie.count >= 21 { break }
            }
            if !ajoute { break }
            rang += 1
        }
        return sortie
    }()

    /// Publications où un compte est identifié (2e onglet des profils).
    static func identifications(_ pseudo: String) -> [IgPost] {
        publications.filter { $0.identifies.contains(pseudo) }
    }

    static let vues: [String] = ["377 K", "46,7 K", "338 K", "612 K", "1,8 M", "92,4 K", "12,1 K"]

    // ---------- stories à la une du profil (servent aussi à l'écran Archives)
    static let alaune: [(titre: String, image: String)] = [
        (titre: "Annecy 26", image: "p30"), (titre: "Argentique", image: "p34"),
        (titre: "Céramique", image: "p33"), (titre: "Randos", image: "p38")
    ]

    // ---------- notes de la liste DM (e072)
    static let notes: [IgNote] = [
        IgNote(id: "note.chloe", compte: chloe, texte: "on repart quand ?", sousTitre: "📍 Annecy"),
        IgNote(id: "note.ines",  compte: ines,  texte: "garde de nuit 😵", sousTitre: "Lyon 7e", violette: true),
        IgNote(id: "note.lyon",  compte: lyon,  texte: "coucher de soleil 🌇", sousTitre: "📍 Tête d'Or")
    ]

    // ---------- conversations (grammaire d'aperçu relevée en e072)
    static let conversations: [IgConversation] = [
        IgConversation(id: "dm.chloe", compte: chloe,
                       apercuInitial: "+ de 4 nouveaux messages", quand: "5 s", nonLu: true,
                       separateur: "2 JUIN À 02:26",
                       messages: [
                        IgMessage(id: "dm.chloe.1", deMoi: false, texte: "Regarde ce que j'ai retrouvé du week-end 😍"),
                        IgMessage(id: "dm.chloe.2", deMoi: false, texte: "La photo du ponton est incroyable"),
                        IgMessage(id: "dm.chloe.3", deMoi: true,  texte: "Ahah je l'avais oubliée celle-là"),
                        IgMessage(id: "dm.chloe.4", deMoi: true,  texte: "Je te fais un tirage si tu veux"),
                        IgMessage(id: "dm.chloe.5", deMoi: false, texte: "Oui !! Et on remet ça en octobre ?"),
                        IgMessage(id: "dm.chloe.6", deMoi: false, texte: "Je regarde les dates ce soir")
                       ]),

        IgConversation(id: "dm.marc", compte: marc,
                       apercuInitial: "Je pense à toi. Tu as pu regarder pour le virement ?",
                       quand: "2 h", nonLu: true,
                       separateur: "HIER À 21:14",
                       messages: [
                        IgMessage(id: "dm.marc.1", deMoi: false, texte: "Bonsoir Sarah. La liaison satellite est enfin revenue."),
                        IgMessage(id: "dm.marc.2", deMoi: true,  texte: "Ah enfin ! Je commençais à m'inquiéter"),
                        IgMessage(id: "dm.marc.3", deMoi: false, texte: "La compagnie a bloqué mon compte le temps de la relève. Je n'ai plus accès à rien depuis la plateforme."),
                        IgMessage(id: "dm.marc.4", deMoi: false, texte: "Je n'aime pas te demander ça."),
                        IgMessage(id: "dm.marc.5", deMoi: true,  texte: "Demander quoi ?"),
                        IgMessage(id: "dm.marc.6", deMoi: false, texte: "Je pense à toi. Tu as pu regarder pour le virement ?")
                       ]),

        IgConversation(id: "dm.ines", compte: ines,
                       apercuInitial: "Vous : je t'envoie les photos ce soir", quand: "12 s",
                       separateur: "MARDI À 18:02",
                       messages: [
                        IgMessage(id: "dm.ines.1", deMoi: false, texte: "T'as réussi à scanner la pellicule ?"),
                        IgMessage(id: "dm.ines.2", deMoi: true,  texte: "Presque, il m'en reste 6"),
                        IgMessage(id: "dm.ines.3", deMoi: true,  texte: "je t'envoie les photos ce soir")
                       ]),

        IgConversation(id: "dm.lea", compte: lea,
                       apercuInitial: "En ligne il y a 18 minutes", quand: "",
                       separateur: "DIMANCHE À 11:47",
                       messages: [
                        IgMessage(id: "dm.lea.1", deMoi: true,  texte: "Coucou ! J'ai vu que t'étais passée en privé"),
                        IgMessage(id: "dm.lea.2", deMoi: false, texte: "Oui, trop de comptes bizarres qui m'écrivaient"),
                        IgMessage(id: "dm.lea.3", deMoi: false, texte: "Fais gaffe toi aussi hein")
                       ]),

        IgConversation(id: "dm.atelier", compte: atelier,
                       apercuInitial: "4 nouveaux messages", quand: "27 s", nonLu: true,
                       separateur: "LUNDI À 09:30",
                       messages: [
                        IgMessage(id: "dm.atelier.1", deMoi: false, texte: "Bonjour Sarah !"),
                        IgMessage(id: "dm.atelier.2", deMoi: false, texte: "Votre bol est sorti du four, il est superbe"),
                        IgMessage(id: "dm.atelier.3", deMoi: false, texte: "Vous pouvez passer le récupérer cette semaine"),
                        IgMessage(id: "dm.atelier.4", deMoi: false, texte: "L'atelier est ouvert jusqu'à 19 h")
                       ]),

        IgConversation(id: "dm.lyon", compte: lyon,
                       apercuInitial: "Vous : merci pour le repost !", quand: "3 j",
                       separateur: "31 MAI À 14:05",
                       messages: [
                        IgMessage(id: "dm.lyon.1", deMoi: false, texte: "On a partagé votre photo du parc en story, merci !"),
                        IgMessage(id: "dm.lyon.2", deMoi: true,  texte: "merci pour le repost !")
                       ]),

        IgConversation(id: "dm.demande", compte: alex,
                       apercuInitial: "Bonjour, j'ai vu votre travail et…", quand: "6 j", demande: true,
                       separateur: "28 MAI À 22:41",
                       messages: [
                        IgMessage(id: "dm.demande.1", deMoi: false, texte: "Bonjour, j'ai vu votre travail et je le trouve magnifique.")
                       ])
    ]
}

// ============================================================ 2f. REELS
struct IgReel: Identifiable, Equatable {
    let id: String
    var compte: IgCompte
    var image: String
    var legende: String
    var audio: String
    var jaime: String
    var envois: String
    var commentaires: [IgCommentaire]
    static func == (g: IgReel, d: IgReel) -> Bool { g.id == d.id }
}

enum IgReels {
    static let liste: [IgReel] = [
        IgReel(id: "reel.rhone", compte: DonneesInsta.lyon, image: "p37",
               legende: "Coucher de soleil sur les quais du Rhône 🌅 la meilleure heure de Lyon",
               audio: "lyon.maville · Audio d'origine",
               jaime: "103 K", envois: "18,8 K",
               commentaires: [
                IgCommentaire(id: "reel.rhone.c1", compte: DonneesInsta.chloe,
                              texte: "C'est exactement ça 😍", quand: "3 h", jaime: 12),
                IgCommentaire(id: "reel.rhone.c2", compte: DonneesInsta.thomas,
                              texte: "Le meilleur spot pour courir aussi", quand: "5 h", jaime: 3),
                IgCommentaire(id: "reel.rhone.c3", compte: DonneesInsta.sarah,
                              texte: "J'y étais hier, la lumière était dingue", quand: "1 j", jaime: 8)
               ]),
        IgReel(id: "reel.tour", compte: DonneesInsta.atelier, image: "p39",
               legende: "3 minutes de tournage, 40 minutes de nettoyage 🏺",
               audio: "atelierpoterie.lyon3 · Audio d'origine",
               jaime: "12,4 K", envois: "2 104",
               commentaires: [
                IgCommentaire(id: "reel.tour.c1", compte: DonneesInsta.camille,
                              texte: "Tellement vrai pour le nettoyage 😂", quand: "1 j", jaime: 21),
                IgCommentaire(id: "reel.tour.c2", compte: DonneesInsta.sarah,
                              texte: "Le mardi soir me manque déjà", quand: "2 j", jaime: 4)
               ]),
        IgReel(id: "reel.annecy", compte: DonneesInsta.chloe, image: "p31",
               legende: "6 h du matin, brume sur le lac, aucun regret",
               audio: "chloe.brt · Audio d'origine",
               jaime: "4 208", envois: "612",
               commentaires: [
                IgCommentaire(id: "reel.annecy.c1", compte: DonneesInsta.sarah,
                              texte: "La meilleure idée du week-end 💙", quand: "6 h", jaime: 9),
                IgCommentaire(id: "reel.annecy.c2", compte: DonneesInsta.ines,
                              texte: "Vous m'emmenez la prochaine fois", quand: "4 h", jaime: 5)
               ])
    ]

    /// Un reel se lit aussi comme une publication : cela permet de réutiliser la feuille
    /// de commentaires et la feuille de partage, donc d'avoir un compteur = liste réelle.
    static func commePost(_ r: IgReel) -> IgPost {
        IgPost(id: r.id, compte: r.compte, lieu: nil, audio: r.audio,
               images: [r.image], estVideo: true,
               jaime: r.jaime, reposts: "0", envois: r.envois,
               aimePar: "Aimé par \(DonneesInsta.chloe.id) et d'autres personnes",
               avatarsAimePar: ["p12", "p04"],
               legende: r.legende, date: "Il y a 1 jour",
               commentaires: r.commentaires)
    }
}

// ============================================================ 3. ÉTAT (tout le mutable, D-SwiftUI)
enum IgGenreRelation: Equatable { case followers, suivis }
enum IgModeAppel: Equatable { case audio, video }

enum IgOverlay: Equatable {
    case story(String)                       // pseudo du compte
    case profil(String)                      // pseudo
    case detail(String)                      // identifiant de publication
    case fil(String)                         // identifiant de conversation
    case notifications
    case relations(String, IgGenreRelation)   // pseudo + followers / suivi(e)s
    case appel(String, IgModeAppel)           // conversation + audio / vidéo
    case navigateur(String)                   // domaine de la page ouverte
    case modifierProfil
    case enregistrements
    case archives
    case parametres
}

enum IgFeuille: Equatable {
    case commentaires(String)
    case partage(String)
    case options(String)
    case menuFlux
    case creation
    case actionsProfil
    case pellicule(String)      // envoyer une photo dans une conversation / créer un contenu
    case reactions(String)      // identifiant de message (appui long)
    case nouveauMessage
}

final class IgEtat: ObservableObject {
    // ---- navigation
    @Published var onglet: Int = 0
    @Published var pile: [IgOverlay] = []
    @Published var feuille: IgFeuille? = nil
    @Published var info: String? = nil

    // ---- fil
    @Published var flux: String = "Pour vous"
    @Published var fluxReels: String = "Pour vous"

    // ---- interactions persistantes
    @Published var aimes: Set<String> = []
    @Published var enregistres: Set<String> = []
    @Published var suivis: Set<String> = Set(IgReseau.abonnementsSarah)
    @Published var favoris: Set<String> = Set(IgReseau.favorisSarah)
    @Published var sourdine: Set<String> = []
    @Published var commentairesAjoutes: [String: [IgCommentaire]] = [:]

    // ---- messagerie
    @Published var conversations: [IgConversation] = DonneesInsta.conversations
    @Published var reactions: [String: String] = [:]        // identifiant de message → emoji
    @Published var lus: Set<String> = []
    @Published var modifiees: Set<String> = []              // conversations touchées à l'exécution
    @Published var ongletDM: Int = 0

    // ---- profil de Sarah
    @Published var sarah: IgCompte = DonneesInsta.sarah
    @Published var postsPerso: [IgPost] = []                // publications créées dans la session
    @Published var storyPerso: String? = nil                // « Votre story »
    @Published var ongletProfil: Int = 0
    @Published var recherche: String = ""

    // ---- réglages réels (écran Paramètres)
    @Published var notificationsActives: Bool = true

    private var compteurPerso: Int = 0

    static let emojisReaction: [String] = ["❤️", "😂", "😮", "😢", "😡", "👍"]

    var sommet: IgOverlay? { pile.last }
    var chromeVisible: Bool { pile.isEmpty }

    // ---------- navigation : D92 « un message / une feuille ne doit JAMAIS rester affiché
    // après avoir quitté l'écran » → tout changement d'écran purge le toast ET la feuille.
    private func purger() { info = nil; feuille = nil }

    func ouvrir(_ o: IgOverlay) { Haptique.leger(); purger(); pile.append(o) }
    func fermer() { purger(); if !pile.isEmpty { pile.removeLast() } }
    func fermerTout() { purger(); pile.removeAll() }
    func allerOnglet(_ i: Int) { Haptique.leger(); fermerTout(); onglet = i }

    func signaler(_ texte: String) { Haptique.leger(); info = texte }

    // ---------- j'aime / enregistrements / abonnements
    func basculerJaime(_ cle: String) {
        Haptique.leger()
        if aimes.contains(cle) { aimes.remove(cle) } else { aimes.insert(cle) }
    }
    func aimer(_ cle: String) { if !aimes.contains(cle) { Haptique.leger(); aimes.insert(cle) } }
    func basculerEnregistre(_ cle: String) {
        Haptique.leger()
        if enregistres.contains(cle) {
            enregistres.remove(cle); info = "Retiré des publications enregistrées"
        } else {
            enregistres.insert(cle); info = "Enregistré"
        }
    }
    func basculerSuivi(_ pseudo: String) {
        Haptique.leger()
        if suivis.contains(pseudo) {
            suivis.remove(pseudo)
            favoris.remove(pseudo)
        } else {
            suivis.insert(pseudo)
        }
    }
    func basculerFavori(_ pseudo: String) {
        Haptique.leger()
        if favoris.contains(pseudo) { favoris.remove(pseudo) }
        else if suivis.contains(pseudo) { favoris.insert(pseudo) }
        else { info = "Suivez d'abord ce compte pour l'ajouter aux favoris" }
    }
    func basculerSourdine(_ pseudo: String) {
        Haptique.leger()
        if sourdine.contains(pseudo) {
            sourdine.remove(pseudo); info = "\(pseudo) n'est plus en sourdine"
        } else {
            sourdine.insert(pseudo); info = "\(pseudo) est en sourdine"
        }
    }

    // ---------- RELATIONS RÉELLES (D92)
    /// Les comptes que `pseudo` suit. Pour Sarah, c'est l'état vivant des boutons « Suivre ».
    func abonnementsDe(_ pseudo: String) -> [String] {
        if pseudo == sarah.id {
            return DonneesInsta.tous.map { $0.id }.filter { suivis.contains($0) }
        }
        return IgReseau.abonnements[pseudo] ?? []
    }
    func suivisDe(_ pseudo: String) -> [IgCompte] {
        DonneesInsta.comptes(abonnementsDe(pseudo))
    }
    /// Followers = INVERSION de la table d'abonnements : le compteur ne peut pas mentir.
    func followersDe(_ pseudo: String) -> [IgCompte] {
        DonneesInsta.tous.filter { $0.id != pseudo && abonnementsDe($0.id).contains(pseudo) }
    }
    func relations(_ pseudo: String, _ genre: IgGenreRelation) -> [IgCompte] {
        genre == .followers ? followersDe(pseudo) : suivisDe(pseudo)
    }
    /// Comptes suivis à la fois par Sarah et par `pseudo` (carte d'en-tête de conversation).
    func abonnementsCommuns(_ pseudo: String) -> [IgCompte] {
        let siens = Set(abonnementsDe(pseudo))
        return DonneesInsta.comptes(abonnementsDe(sarah.id).filter { siens.contains($0) })
    }

    // ---------- publications
    func compteAffiche(_ pseudo: String) -> IgCompte {
        pseudo == sarah.id ? sarah : DonneesInsta.compte(pseudo)
    }
    /// Grille d'un profil : pour Sarah, les créations de la session viennent en tête.
    func grilleDe(_ pseudo: String) -> [IgPost] {
        if pseudo == sarah.id { return postsPerso + DonneesInsta.postsDe(sarah) }
        return DonneesInsta.postsDe(DonneesInsta.compte(pseudo))
    }
    func nbPublications(_ pseudo: String) -> Int { grilleDe(pseudo).count }

    func commentaires(_ post: IgPost) -> [IgCommentaire] {
        post.commentaires + (commentairesAjoutes[post.id] ?? [])
    }
    func ajouterCommentaire(_ texte: String, sur post: IgPost) {
        let t = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        Haptique.leger()
        var liste = commentairesAjoutes[post.id] ?? []
        liste.append(IgCommentaire(id: "ajout.\(post.id).\(liste.count)",
                                   compte: sarah, texte: t, quand: "à l'instant", jaime: 0))
        commentairesAjoutes[post.id] = liste
    }

    /// Fil filtré : sélecteur RÉEL (D92) + comptes en sourdine écartés.
    var postsDuFil: [IgPost] {
        let base = postsPerso + DonneesInsta.feed
        return base.filter { p in
            if p.compte.id == sarah.id { return true }
            if sourdine.contains(p.compte.id) { return false }
            switch flux {
            case "Suivi(e)s": return suivis.contains(p.compte.id) && !p.sponsorise
            case "Favoris":   return favoris.contains(p.compte.id) && !p.sponsorise
            default:          return true
            }
        }
    }

    /// Reels filtrés : « Ami(e)s » = comptes suivis qui ne sont pas des comptes pro.
    var reelsDuFil: [IgReel] {
        IgReels.liste.filter { r in
            if sourdine.contains(r.compte.id) { return false }
            if fluxReels == "Ami(e)s" { return suivis.contains(r.compte.id) && !r.compte.estPro }
            return true
        }
    }

    /// Comptes dont la story est affichée dans la rangée du fil.
    var storiesVisibles: [IgCompte] {
        DonneesInsta.comptes.filter { $0.enStory && !sourdine.contains($0.id) }
    }

    /// Segments d'une story : la story créée par Sarah, sinon les images du compte.
    func segmentsStory(_ pseudo: String) -> [String] {
        if pseudo == sarah.id {
            if let s = storyPerso { return [s] }
            return Array(sarah.grille.prefix(3))
        }
        let c = DonneesInsta.compte(pseudo)
        let base = c.grille.isEmpty ? ["p31", "p34", "p38"] : c.grille
        return Array(base.prefix(4))
    }

    // ---------- CRÉATION MINIMALE (D92)
    func publier(image: String, legende: String) {
        Haptique.leger()
        compteurPerso += 1
        let t = legende.trimmingCharacters(in: .whitespacesAndNewlines)
        let post = IgPost(
            id: "perso.\(compteurPerso)",
            compte: sarah, lieu: nil, audio: nil, images: [image],
            jaime: "0", reposts: "0", envois: "0",
            aimePar: "Soyez la première personne à aimer cette publication",
            avatarsAimePar: [],
            legende: t.isEmpty ? "📷" : t,
            date: "À l'instant",
            commentaires: [])
        postsPerso.insert(post, at: 0)
        info = "Publication ajoutée à votre profil"
    }
    func publierStory(image: String) {
        Haptique.leger()
        storyPerso = image
        info = "Story ajoutée à « Votre story »"
    }

    // ---------- MESSAGERIE
    func conv(_ identifiant: String) -> IgConversation {
        conversations.first(where: { $0.id == identifiant }) ?? conversations[0]
    }
    private func index(_ identifiant: String) -> Int? {
        conversations.firstIndex(where: { $0.id == identifiant })
    }

    /// Aperçu affiché dans la liste : recalculé depuis le DERNIER message dès que la
    /// conversation a bougé pendant la session (D92 : « la liste doit montrer le dernier
    /// message mis à jour »), sinon aperçu d'origine (formulations non lues d'Instagram).
    func apercu(_ conv: IgConversation) -> String {
        guard modifiees.contains(conv.id), let dernier = conv.messages.last else {
            return conv.apercuInitial
        }
        return (dernier.deMoi ? "Vous : " : "") + dernier.resume
    }
    func quand(_ conv: IgConversation) -> String {
        modifiees.contains(conv.id) ? "à l'instant" : conv.quand
    }

    private func ajouter(_ contenu: IgContenuMessage, dans identifiant: String) {
        guard let i = index(identifiant) else { return }
        let n = conversations[i].messages.count
        let message = IgMessage(id: "\(identifiant).env.\(n)", deMoi: true, contenu: contenu)
        conversations[i].messages.append(message)
        modifiees.insert(identifiant)
        lus.insert(identifiant)
        // La conversation la plus récente remonte en tête, comme dans le vrai Instagram.
        let conv = conversations.remove(at: i)
        conversations.insert(conv, at: 0)
    }

    func envoyer(_ texte: String, dans identifiant: String) {
        let t = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        Haptique.leger()
        ajouter(.texte(t), dans: identifiant)
    }
    func envoyerPhoto(_ cle: String, dans identifiant: String) {
        Haptique.leger()
        ajouter(.photo(cle), dans: identifiant)
    }
    func envoyerCarte(_ carte: IgCarteJointe, dans identifiant: String) {
        Haptique.leger()
        ajouter(.carte(carte), dans: identifiant)
    }

    /// Trouve la conversation d'un compte, ou la CRÉE (bouton « nouveau message », partage
    /// vers un compte avec lequel Sarah n'a jamais discuté).
    func conversationAvec(_ compte: IgCompte) -> String {
        if let existante = conversations.first(where: { $0.compte.id == compte.id }) {
            return existante.id
        }
        let identifiant = "dm.neuve.\(compte.id)"
        let neuve = IgConversation(id: identifiant, compte: compte,
                                   apercuInitial: "Nouvelle conversation", quand: "",
                                   nonLu: false, demande: false,
                                   separateur: "AUJOURD'HUI",
                                   messages: [])
        conversations.insert(neuve, at: 0)
        return identifiant
    }

    // ---------- réactions (appui long, retirables)
    func reagir(_ emoji: String, sur identifiant: String) {
        Haptique.leger()
        if reactions[identifiant] == emoji { reactions.removeValue(forKey: identifiant) }
        else { reactions[identifiant] = emoji }
        feuille = nil
    }
    func retirerReaction(_ identifiant: String) {
        Haptique.leger()
        reactions.removeValue(forKey: identifiant)
    }

    // ---------- PARTAGE RÉEL : la cible devient une CARTE dans la conversation (D92)
    func partager(_ cible: String, vers compte: IgCompte) {
        let identifiant = conversationAvec(compte)
        envoyerCarte(carte(pour: cible), dans: identifiant)
        feuille = nil
        info = "Envoyé à \(compte.nom)"
    }

    /// Construit la carte correspondant à une cible de partage.
    func carte(pour cible: String) -> IgCarteJointe {
        if cible.hasPrefix("story.") {
            let pseudo = String(cible.dropFirst(6))
            let c = compteAffiche(pseudo)
            let image = segmentsStory(pseudo).first ?? "p30"
            return IgCarteJointe(image: image, auteur: c.id,
                                 legende: c.nom, entete: "Story de \(c.id)",
                                 cible: nil, profil: c.id)
        }
        if cible.hasPrefix("reponsestory.") {
            let pseudo = String(cible.dropFirst(13))
            let c = compteAffiche(pseudo)
            let image = segmentsStory(pseudo).first ?? "p30"
            return IgCarteJointe(image: image, auteur: c.id,
                                 legende: c.nom, entete: "A répondu à votre story",
                                 cible: nil, profil: c.id)
        }
        if cible.hasPrefix("profil.") {
            let pseudo = String(cible.dropFirst(7))
            let c = compteAffiche(pseudo)
            let image = grilleDe(pseudo).first?.images.first ?? (c.photo ?? "p30")
            return IgCarteJointe(image: image, auteur: c.id,
                                 legende: c.nom, entete: "Profil Instagram",
                                 cible: nil, profil: c.id)
        }
        let post = IgCatalogue.post(cible)
        return IgCarteJointe(image: post.images.first ?? "p30",
                             auteur: post.compte.id,
                             legende: post.legende,
                             entete: nil,
                             cible: post.id, profil: nil)
    }

    /// Réponse envoyée DEPUIS une story : le message porte la story (D92).
    func repondreAStory(_ pseudo: String, texte: String) {
        let t = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { info = "Écrivez un message avant d'envoyer"; return }
        let compte = compteAffiche(pseudo)
        let identifiant = conversationAvec(compte)
        var carteStory = carte(pour: "story." + pseudo)
        carteStory.entete = "Vous avez répondu à sa story"
        envoyerCarte(carteStory, dans: identifiant)
        envoyer(t, dans: identifiant)
        info = "Réponse envoyée à \(compte.id)"
    }
    func reagirAStory(_ pseudo: String, emoji: String) {
        let compte = compteAffiche(pseudo)
        let identifiant = conversationAvec(compte)
        var carteStory = carte(pour: "story." + pseudo)
        carteStory.entete = "Vous avez répondu à sa story"
        envoyerCarte(carteStory, dans: identifiant)
        envoyer(emoji, dans: identifiant)
        info = "\(emoji) envoyé à \(compte.id)"
    }

    // ---------- presse-papiers réel
    func copier(_ texte: String) {
        UIPasteboard.general.string = texte
        Haptique.leger()
        feuille = nil
        info = "Lien copié"
    }
}

enum IgOutils {
    /// Incrémente un compteur affiché quand il est purement numérique (« 87 » → « 88 »),
    /// laisse « 138 K » ou « 1,8 M » intacts : on n'invente pas une précision qu'on n'a pas.
    static func incremente(_ valeur: String, de delta: Int) -> String {
        let brut = valeur.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\u{202F}", with: "")
        guard let n = Int(brut) else { return valeur }
        let r = n + delta
        if r >= 1000 {
            let milliers = r / 1000, reste = r % 1000
            return "\(milliers) " + String(format: "%03d", reste)
        }
        return "\(r)"
    }

    /// Met en forme un compteur de relations : la valeur vient TOUJOURS d'une liste réelle.
    static func compteur(_ n: Int) -> String {
        if n >= 1000 {
            let milliers = n / 1000, reste = n % 1000
            return "\(milliers) " + String(format: "%03d", reste)
        }
        return "\(n)"
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
                .overlay(Image(systemName: systeme)
                    .font(.system(size: taille, weight: .semibold))
                    .foregroundStyle(.white))
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
    var couleur: Color = Color.white
    var action: () -> Void
    var body: some View {
        HStack(spacing: 5) {
            Group {
                if pleine {
                    forme.fill(couleur)
                } else {
                    forme.stroke(couleur, style: StrokeStyle(lineWidth: trait, lineCap: .round, lineJoin: .round))
                }
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

/// Pilule d'action d'un profil (Modifier / Partager / Suivre / Message).
struct IgPilule: View {
    let titre: String
    var pleine: Bool = false
    var action: () -> Void
    var body: some View {
        Text(titre)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(pleine ? IgTheme.accent : IgTheme.surface3))
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); action() }
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

    private var nonLus: Int {
        etat.conversations.filter { $0.nonLu && !etat.lus.contains($0.id) }.count
    }

    var body: some View {
        HStack(spacing: 0) {
            cellule(0) { AnyView(Image(systemName: etat.onglet == 0 ? "house.fill" : "house").font(.system(size: 21))) }
            cellule(1) { AnyView(IgReelForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round)).frame(width: 23, height: 23)) }
            cellule(2) { AnyView(pastilleDM) }
            cellule(3) { AnyView(Image(systemName: "magnifyingglass").font(.system(size: 21, weight: etat.onglet == 3 ? Font.Weight.semibold : Font.Weight.regular))) }
            cellule(4) { AnyView(IgAvatar(compte: etat.sarah, taille: 26)) }
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
            if nonLus > 0 {
                Circle().fill(IgTheme.rouge).frame(width: 6, height: 6).offset(x: 3, y: 1)
            }
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
        .onTapGesture { etat.allerOnglet(index) }
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

    var body: some View {
        VStack(spacing: 0) {
            IgEnteteFeed(etat: etat)
            ScrollView {
                LazyVStack(spacing: 0) {
                    IgRangeeStories(etat: etat)
                    IgSeparateur()
                    ForEach(etat.postsDuFil) { p in
                        IgPostVue(post: p, etat: etat)
                    }
                    if etat.postsDuFil.isEmpty {
                        IgEtatVide(titre: "Rien de neuf ici",
                                   texte: "Aucune publication récente dans « \(etat.flux) ».",
                                   bouton: "Revenir à « Pour vous »") { etat.flux = "Pour vous" }
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
                ForEach(etat.storiesVisibles) { c in
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

/// « Votre story » : silhouette + « + » tant que Sarah n'a rien publié ; dès qu'une story
/// existe (création réelle, D92), la cellule montre l'aperçu cerclé et l'ouvre.
struct IgCelluleVotreStory: View {
    @ObservedObject var etat: IgEtat
    var body: some View {
        VStack(spacing: 9) {
            ZStack(alignment: .bottomTrailing) {
                if let s = etat.storyPerso {
                    ZStack {
                        Circle().strokeBorder(IgTheme.anneau, lineWidth: 3.3)
                            .frame(width: 92.3, height: 92.3)
                        IgPhoto(cle: s, teinte: etat.sarah.teinte)
                            .frame(width: 79, height: 79)
                            .clipShape(Circle())
                    }
                } else {
                    IgAvatarSilhouette(taille: 79)
                    Circle().fill(Color.black)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                        .overlay(Image(systemName: "plus").font(.system(size: 10, weight: .bold)).foregroundStyle(.white))
                        .offset(x: 1, y: -2)
                }
            }
            .frame(width: 92.3, height: 92.3)
            Text("Votre story")
                .font(.system(size: 12))
                .foregroundStyle(etat.storyPerso == nil ? IgTheme.secondaire : Color.white)
                .lineLimit(1)
                .frame(width: 100)
        }
        .frame(width: 104.5)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptique.leger()
            if etat.storyPerso == nil { etat.feuille = .creation } else { etat.ouvrir(.story(etat.sarah.id)) }
        }
    }
}

// ============================================================ 7. PUBLICATION (e001, e003, e197)
// D92 : plus de « ≡ » sur les publications ; plus d'icône « repost ».
struct IgPostVue: View {
    let post: IgPost
    @ObservedObject var etat: IgEtat
    @State private var page: Int = 0
    @State private var coeur: Bool = false

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
            if post.estVideo {
                Image(systemName: "play.fill")
                    .font(.system(size: 34)).foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
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

    // D92 : le CTA d'une publication sponsorisée ouvre la VRAIE page du compte (navigateur interne).
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
        .onTapGesture {
            if let l = post.compte.lien { etat.ouvrir(.navigateur(l)) }
            else { etat.ouvrir(.profil(post.compte.id)) }
        }
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
            // D92 : les « deux petits traits » sont retirés des publications. Le seul bouton
            // conservé ici est « Suivre » d'une publication sponsorisée, qui bascule réellement.
            if post.sponsorise {
                Text(etat.suivis.contains(post.compte.id) ? "Suivi(e)" : "Suivre")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 69, height: 30)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(IgTheme.surface3))
                    .contentShape(Rectangle())
                    .onTapGesture { etat.basculerSuivi(post.compte.id) }
            }
        }
        .padding(.horizontal, 13).padding(.vertical, 9)
    }
}

struct IgRangeeIconesPost: View {
    let post: IgPost
    @ObservedObject var etat: IgEtat

    private var aime: Bool { etat.aimes.contains(post.id) }
    private var enregistre: Bool { etat.enregistres.contains(post.id) }

    var body: some View {
        HStack(spacing: 18) {
            IgIconeCompteur(forme: IgCoeurForme(), taille: 19,
                            compteur: IgOutils.incremente(post.jaime, de: aime ? 1 : 0),
                            pleine: aime, couleur: aime ? IgTheme.coeurPlein : Color.white) {
                etat.basculerJaime(post.id)
            }
            IgIconeCompteur(forme: IgBulleForme(), taille: 21,
                            compteur: "\(etat.commentaires(post).count)") {
                Haptique.leger(); etat.feuille = .commentaires(post.id)
            }
            IgIconeCompteur(forme: IgEnvoyerForme(), taille: 17, compteur: post.envois) {
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

// ============================================================ 8. REELS (e041–e070, e193–e239)
// D92 : plus de « ≡ », plus de « Republier dans ma story ». Le sélecteur Pour vous / Ami(e)s
// filtre RÉELLEMENT (IgEtat.reelsDuFil), les commentaires ouvrent la vraie feuille (le compteur
// vaut le nombre de commentaires lisibles), le partage dépose une carte dans une conversation.
struct IgReelsVue: View {
    @ObservedObject var etat: IgEtat
    @State private var index: Int = 0

    private var liste: [IgReel] { etat.reelsDuFil }
    private var reel: IgReel? { liste.isEmpty ? nil : liste[min(index, liste.count - 1)] }

    var body: some View {
        ZStack {
            IgTheme.fond.ignoresSafeArea()
            if let r = reel {
                IgPhoto(cle: r.image, teinte: r.compte.teinte).ignoresSafeArea()
                LinearGradient(colors: [.black.opacity(0.45), .clear, .clear, .black.opacity(0.55)],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            }
            VStack(spacing: 0) {
                entete
                Spacer()
                if let r = reel {
                    HStack(alignment: .bottom, spacing: 12) {
                        piedGauche(r)
                        Spacer(minLength: 0)
                        IgRailReels(reel: r, etat: etat)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 104)
                } else {
                    IgEtatVide(titre: "Aucun reel ici",
                               texte: "Aucun reel d'ami(e) pour le moment.",
                               bouton: "Revenir à « Pour vous »") { etat.fluxReels = "Pour vous" }
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 30).onEnded { v in
            guard !liste.isEmpty else { return }
            if v.translation.height < -40 { Haptique.leger(); index = min(index + 1, liste.count - 1) }
            if v.translation.height > 40 { Haptique.leger(); index = max(index - 1, 0) }
        })
    }

    private var entete: some View {
        HStack(spacing: 18) {
            Image(systemName: "plus").font(.system(size: 20, weight: .medium))
                .frame(width: 34, height: 40)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .creation }
            onglet("Pour vous")
            onglet("Ami(e)s")
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16).padding(.top, 6)
    }

    private func onglet(_ nom: String) -> some View {
        let actif = etat.fluxReels == nom
        return Text(nom)
            .font(.system(size: 21, weight: actif ? Font.Weight.bold : Font.Weight.regular))
            .foregroundStyle(actif ? Color.white : Color.white.opacity(0.55))
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); etat.fluxReels = nom; index = 0 }
    }

    private func piedGauche(_ reel: IgReel) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 9) {
                IgAvatar(compte: reel.compte, taille: 32, anneau: reel.compte.enStory)
                    .contentShape(Circle())
                    .onTapGesture { etat.ouvrir(.profil(reel.compte.id)) }
                HStack(spacing: 4) {
                    Text(reel.compte.id).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    if reel.compte.verifie { IgBadgeVerifie(taille: 12) }
                }
                .contentShape(Rectangle())
                .onTapGesture { etat.ouvrir(.profil(reel.compte.id)) }
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
    private var post: IgPost { IgReels.commePost(reel) }

    var body: some View {
        VStack(spacing: 18) {
            bloc(AnyView(coeurReel), IgOutils.incremente(reel.jaime, de: aime ? 1 : 0), 26) {
                etat.basculerJaime(reel.id)
            }
            bloc(AnyView(IgBulleForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))),
                 "\(etat.commentaires(post).count)", 26) {
                Haptique.leger(); etat.feuille = .commentaires(reel.id)
            }
            bloc(AnyView(IgEnvoyerForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))),
                 reel.envois, 23) {
                Haptique.leger(); etat.feuille = .partage(reel.id)
            }
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
            IgCoeurForme().fill(IgTheme.coeurPlein)
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
        let base = etat.conversations.filter { etat.ongletDM == 0 ? !$0.demande : $0.demande }
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
            Text(etat.sarah.id).font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
            HStack {
                Spacer()
                IgComposerForme()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 1.8, lineJoin: .round))
                    .frame(width: 22, height: 22)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); etat.feuille = .nouveauMessage }
            }
        }
        .frame(height: 46)
        .padding(.horizontal, 16)
    }

    private var champRecherche: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            TextField("", text: $recherche,
                      prompt: Text("Rechercher").foregroundStyle(IgTheme.secondaire))
                .font(.system(size: 15)).foregroundStyle(.white)
            if !recherche.isEmpty {
                Image(systemName: "xmark.circle.fill").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
                    .contentShape(Rectangle())
                    .onTapGesture { recherche = "" }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 39)
        .background(Capsule().fill(IgTheme.surface2))
        .padding(.horizontal, 14).padding(.bottom, 14)
    }

    private var onglets: some View {
        HStack {
            Text("Messages")
                .font(.system(size: 20, weight: etat.ongletDM == 0 ? Font.Weight.bold : Font.Weight.regular))
                .foregroundStyle(etat.ongletDM == 0 ? Color.white : IgTheme.secondaire)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.ongletDM = 0 }
            Spacer()
            Text("Demandes")
                .font(.system(size: 20, weight: etat.ongletDM == 1 ? Font.Weight.bold : Font.Weight.regular))
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
                ForEach(DonneesInsta.notes) { n in
                    celluleNote(n)
                }
            }
            .padding(.horizontal, 14)
        }
        .padding(.bottom, 12)
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
            IgAvatar(compte: conv.compte, taille: 50, anneau: conv.compte.enStory)
            VStack(alignment: .leading, spacing: 2) {
                Text(conv.compte.nom)
                    .font(.system(size: 15, weight: nonLu ? Font.Weight.semibold : Font.Weight.regular))
                    .foregroundStyle(.white).lineLimit(1)
                HStack(spacing: 6) {
                    Text(etat.apercu(conv))
                        .font(.system(size: 15))
                        .foregroundStyle(nonLu ? Color.white : IgTheme.secondaire)
                        .lineLimit(1)
                    if !etat.quand(conv).isEmpty {
                        Text("· " + etat.quand(conv))
                            .font(.system(size: 14)).foregroundStyle(IgTheme.secondaire).lineLimit(1)
                    }
                }
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
// D92 : ouverture SUR LE DERNIER MESSAGE (ScrollViewReader), appui long → réactions,
// appels audio/vidéo réels, composer = champ + caméra indigo (aucun vocal, aucun emoji, aucun +).
struct IgFilVue: View {
    let identifiant: String
    @ObservedObject var etat: IgEtat
    @State private var saisie: String = ""

    private var conv: IgConversation { etat.conv(identifiant) }
    private var messages: [IgMessage] { conv.messages }
    private var dernierEnvoye: String? { messages.last(where: { $0.deMoi })?.id }

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollViewReader { lecteur in
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
                                       etat: etat,
                                       position: messages.count > 1 ? Double(i) / Double(messages.count - 1) : 0,
                                       dernierDuGroupe: dernierDuGroupe(i),
                                       vu: m.id == dernierEnvoye)
                                .id(m.id)
                        }
                        Color.clear.frame(height: 18).id("igBas")
                    }
                    .padding(.horizontal, 12)
                }
                .onAppear { descendre(lecteur) }
                .onChange(of: messages.count) { _, _ in descendre(lecteur) }
            }
            composerBarre
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func descendre(_ lecteur: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.2)) { lecteur.scrollTo("igBas", anchor: .bottom) }
        }
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
            IgBoutonRond(systeme: "phone.fill", diametre: 40, taille: 15) {
                etat.ouvrir(.appel(conv.id, .audio))
            }
            IgBoutonRond(systeme: "video.fill", diametre: 40, taille: 15) {
                etat.ouvrir(.appel(conv.id, .video))
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
    }

    // D92 : champ + caméra indigo, RIEN d'autre. Aucun état vocal, nulle part.
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
                if !saisie.trimmingCharacters(in: .whitespaces).isEmpty {
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
        etat.envoyer(saisie, dans: identifiant)
        saisie = ""
    }
}

struct IgCarteProfilFil: View {
    let compte: IgCompte
    @ObservedObject var etat: IgEtat

    private var communs: [IgCompte] { etat.abonnementsCommuns(compte.id) }

    private var phraseCommuns: String {
        guard let premier = communs.first else { return "Aucun compte suivi en commun" }
        if communs.count == 1 { return "Vous suivez tou(te)s les deux \(premier.id)" }
        return "Vous suivez tou(te)s les deux \(premier.id) et \(communs.count - 1) autre(s) compte(s)"
    }

    private var phraseRelation: String {
        let elleMeSuit = etat.abonnementsDe(compte.id).contains(etat.sarah.id)
        let jeLaSuis = etat.suivis.contains(compte.id)
        if elleMeSuit && jeLaSuis { return "Vous vous suivez mutuellement sur Instagram" }
        if elleMeSuit { return "\(compte.id) vous suit sur Instagram" }
        if jeLaSuis { return "Vous suivez \(compte.id) sur Instagram" }
        return "Vous ne vous suivez pas sur Instagram"
    }

    var body: some View {
        VStack(spacing: 7) {
            IgAvatar(compte: compte, taille: 95).padding(.top, 22)
            Text(compte.nom).font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
            Text(compte.id).font(.system(size: 16)).foregroundStyle(IgTheme.secondaire)
            Text("\(etat.texteFollowers(compte.id)) followers · \(etat.nbPublications(compte.id)) publications")
                .font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            Text(phraseRelation)
                .font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            Text(phraseCommuns)
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
    @ObservedObject var etat: IgEtat
    let position: Double
    let dernierDuGroupe: Bool
    let vu: Bool

    private var reaction: String? { etat.reactions[message.id] }

    var body: some View {
        VStack(alignment: message.deMoi ? HorizontalAlignment.trailing : HorizontalAlignment.leading, spacing: 3) {
            HStack(alignment: .bottom, spacing: 7) {
                if message.deMoi { Spacer(minLength: 54) }
                if !message.deMoi {
                    if dernierDuGroupe { IgAvatar(compte: compte, taille: 29) }
                    else { Color.clear.frame(width: 29, height: 1) }
                }
                corps
                    .overlay(alignment: message.deMoi ? Alignment.bottomLeading : Alignment.bottomTrailing) {
                        if let r = reaction {
                            Text(r).font(.system(size: 14))
                                .padding(3)
                                .background(Circle().fill(IgTheme.fond))
                                .offset(y: 9)
                                .contentShape(Circle())
                                .onTapGesture { etat.retirerReaction(message.id) }
                        }
                    }
                    .contentShape(Rectangle())
                    .onLongPressGesture(minimumDuration: 0.35) {
                        Haptique.leger(); etat.feuille = .reactions(message.id)
                    }
                if !message.deMoi { Spacer(minLength: 54) }
            }
            if vu {
                Text("Vu").font(.system(size: 12)).foregroundStyle(IgTheme.secondaire)
                    .padding(.top, reaction == nil ? 0 : 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.deMoi ? Alignment.trailing : Alignment.leading)
        .padding(.vertical, reaction == nil ? 2 : 7)
    }

    @ViewBuilder private var corps: some View {
        switch message.contenu {
        case .texte(let t):
            Text(t)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(fond)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        case .photo(let cle):
            IgPhoto(cle: cle, teinte: compte.teinte)
                .frame(width: 176, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        case .carte(let c):
            IgCarteMessage(carte: c, etat: etat)
        }
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

/// Carte déposée par un partage RÉEL (publication, reel, story, profil) — D92.
struct IgCarteMessage: View {
    let carte: IgCarteJointe
    @ObservedObject var etat: IgEtat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let e = carte.entete {
                Text(e).font(.system(size: 12)).foregroundStyle(IgTheme.secondaire)
                    .padding(.horizontal, 10).padding(.top, 8).padding(.bottom, 6)
            }
            IgPhoto(cle: carte.image)
                .frame(width: 200, height: 200)
                .clipped()
            VStack(alignment: .leading, spacing: 2) {
                Text(carte.auteur).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                Text(carte.legende).font(.system(size: 13)).foregroundStyle(IgTheme.secondaire).lineLimit(2)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
        }
        .frame(width: 200, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(hex: 0x1B1F25)))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            if let c = carte.cible { etat.ouvrir(.detail(c)) }
            else if let p = carte.profil { etat.ouvrir(.profil(p)) }
        }
    }
}

// ============================================================ 11. APPEL AUDIO / VIDÉO (D92)
// Deux écrans DISTINCTS : l'appel audio reste sur un fond sombre avec l'avatar au centre ;
// l'appel vidéo affiche l'image du correspondant plein cadre + la vignette de Sarah.
struct IgAppelVue: View {
    let conv: IgConversation
    let mode: IgModeAppel
    @ObservedObject var etat: IgEtat

    @State private var secondes: Int = 0
    @State private var micro: Bool = true
    @State private var hautParleur: Bool = false
    @State private var camera: Bool = true
    private let horloge = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var duree: String {
        String(format: "%02d:%02d", secondes / 60, secondes % 60)
    }
    private var imageFond: String? {
        DonneesInsta.postsDe(conv.compte).first?.images.first ?? conv.compte.photo
    }

    var body: some View {
        ZStack {
            Color(hex: 0x0A0C0F).ignoresSafeArea()
            if mode == .video && camera {
                IgPhoto(cle: imageFond, teinte: conv.compte.teinte).ignoresSafeArea()
                LinearGradient(colors: [.black.opacity(0.55), .clear, .black.opacity(0.7)],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            }
            VStack(spacing: 0) {
                enteteAppel
                Spacer()
                if mode == .audio { avatarCentral }
                Spacer()
                commandes
            }
            if mode == .video && camera { vignetteSarah }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(horloge) { _ in secondes += 1 }
    }

    private var enteteAppel: some View {
        VStack(spacing: 5) {
            Text(conv.compte.nom).font(.system(size: 24, weight: .bold)).foregroundStyle(.white)
            Text(mode == .audio ? "Appel audio · \(duree)" : "Appel vidéo · \(duree)")
                .font(.system(size: 15)).foregroundStyle(.white.opacity(0.75))
        }
        .padding(.top, 54)
    }

    private var avatarCentral: some View {
        VStack(spacing: 14) {
            IgAvatar(compte: conv.compte, taille: 132)
            Text(conv.compte.id).font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
        }
    }

    private var vignetteSarah: some View {
        VStack {
            HStack {
                Spacer()
                IgAvatar(compte: etat.sarah, taille: 96)
                    .frame(width: 104, height: 140)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(hex: 0x15181D)))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.trailing, 16)
            }
            .padding(.top, 128)
            Spacer()
        }
    }

    private var commandes: some View {
        HStack(spacing: 22) {
            rond(micro ? "mic.fill" : "mic.slash.fill", actif: !micro) { micro.toggle() }
            if mode == .video {
                rond(camera ? "video.fill" : "video.slash.fill", actif: !camera) { camera.toggle() }
            } else {
                rond(hautParleur ? "speaker.wave.2.fill" : "speaker.fill", actif: hautParleur) { hautParleur.toggle() }
            }
            Circle().fill(IgTheme.rouge)
                .frame(width: 64, height: 64)
                .overlay(Image(systemName: "phone.down.fill").font(.system(size: 24)).foregroundStyle(.white))
                .contentShape(Circle())
                .onTapGesture { raccrocher() }
        }
        .padding(.bottom, 74)
    }

    private func rond(_ symbole: String, actif: Bool, _ action: @escaping () -> Void) -> some View {
        Circle().fill(actif ? Color.white : Color.white.opacity(0.18))
            .frame(width: 58, height: 58)
            .overlay(Image(systemName: symbole).font(.system(size: 21))
                .foregroundStyle(actif ? Color.black : Color.white))
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); action() }
    }

    private func raccrocher() {
        Haptique.leger()
        let texte = mode == .audio ? "Appel audio · \(duree)" : "Appel vidéo · \(duree)"
        etat.envoyer(texte, dans: conv.id)
        etat.fermer()
        etat.signaler("Appel terminé — \(duree)")
    }
}

// ============================================================ 12. RECHERCHE / EXPLORE (e145, e153)
// D92 : plus de bouton « deux barres » ; chaque tuile de la mosaïque ouvre SA publication.
struct IgRechercheVue: View {
    @ObservedObject var etat: IgEtat
    @FocusState private var actif: Bool

    private var resultats: [IgCompte] {
        let q = etat.recherche.lowercased()
        guard !q.isEmpty else { return DonneesInsta.comptes }
        return DonneesInsta.tous.filter {
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
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
    }

    private var titreRecent: some View {
        HStack {
            Text("Comptes").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
            Spacer()
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
                        Text("· story en cours").font(.system(size: 14)).foregroundStyle(IgTheme.secondaire).lineLimit(1)
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
    private var blocs: [[IgPost]] {
        stride(from: 0, to: DonneesInsta.mosaique.count, by: 5).map {
            Array(DonneesInsta.mosaique[$0..<min($0 + 5, DonneesInsta.mosaique.count)])
        }
    }
    var body: some View {
        LazyVStack(spacing: 1.5) {
            ForEach(Array(blocs.enumerated()), id: \.offset) { i, bloc in
                IgBlocMosaique(posts: bloc, hauteAuMilieu: i % 2 == 0,
                               vue: DonneesInsta.vues[i % DonneesInsta.vues.count], etat: etat)
            }
            Color.clear.frame(height: 110)
        }
    }
}

struct IgBlocMosaique: View {
    let posts: [IgPost]
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

    private func post(_ i: Int) -> IgPost? { i < posts.count ? posts[i] : nil }

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
        let p = post(i)
        return IgPhoto(cle: p?.images.first)
            .overlay(alignment: .topTrailing) {
                if let q = p, q.images.count > 1 {
                    Image(systemName: "square.on.square")
                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(.white).padding(6)
                }
            }
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
            .onTapGesture { if let q = p { etat.ouvrir(.detail(q.id)) } }
    }
}

// ============================================================ 13. GRILLE DE PROFIL
// La grille reçoit de VRAIES publications : chaque vignette ouvre son détail (bon auteur,
// bonne image, bon nombre de commentaires). Le compteur « N publications » vaut sa taille.
struct IgGrilleProfil: View {
    let posts: [IgPost]
    var action: (IgPost) -> Void = { _ in }
    private var colonnes: [GridItem] { Array(repeating: GridItem(.fixed(IgGrille.cellule), spacing: 1.5), count: 3) }
    var body: some View {
        LazyVGrid(columns: colonnes, spacing: 1.5) {
            ForEach(posts) { p in
                IgPhoto(cle: p.images.first)
                    .frame(width: IgGrille.cellule, height: IgGrille.cellule)
                    .overlay(alignment: .topTrailing) { badge(p) }
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); action(p) }
            }
        }
    }

    @ViewBuilder private func badge(_ p: IgPost) -> some View {
        if p.estVideo {
            Image(systemName: "play.fill")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white).padding(7)
        } else if p.images.count > 1 {
            Image(systemName: "square.on.square")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white).padding(7)
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
    var action: () -> Void = {}
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(valeur).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
            Text(libelle).font(.system(size: 13)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); action() }
    }
}

// ============================================================ 14. PROFIL DE SARAH (e169, e185–e188)
// D92 : deux onglets (publications · identifications), plus de bouton « personne + »,
// followers / suivi(e)s ouvrent de vraies listes, Modifier et Partager font quelque chose.
struct IgProfilVue: View {
    @ObservedObject var etat: IgEtat

    private var sarah: IgCompte { etat.sarah }
    private var grille: [IgPost] { etat.grilleDe(sarah.id) }

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    identite
                    bio
                    boutons
                    alaune
                    IgOngletsProfil(symboles: ["square.grid.3x3", "person.crop.square"],
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
            Spacer()
            Image(systemName: "plus").font(.system(size: 21, weight: .medium)).foregroundStyle(.white)
                .frame(width: 40, height: 44)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .creation }
            // Seul « ≡ » conservé de toute l'app : le menu du profil (Paramètres, Enregistrements, Archives).
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
            IgAvatar(compte: sarah, taille: 87, anneau: etat.storyPerso != nil)
                .contentShape(Circle())
                .onTapGesture {
                    if etat.storyPerso != nil { etat.ouvrir(.story(sarah.id)) }
                    else { Haptique.leger(); etat.feuille = .creation }
                }
            VStack(alignment: .leading, spacing: 8) {
                Text(sarah.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                HStack(spacing: 0) {
                    IgColonneStat(valeur: "\(grille.count)", libelle: "publications") {
                        etat.ongletProfil = 0
                    }
                    IgColonneStat(valeur: etat.texteFollowers(sarah.id), libelle: "followers") {
                        etat.ouvrir(.relations(sarah.id, .followers))
                    }
                    IgColonneStat(valeur: etat.texteSuivis(sarah.id), libelle: "suivi(e)s") {
                        etat.ouvrir(.relations(sarah.id, .suivis))
                    }
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
                .onTapGesture { etat.ouvrir(.navigateur(l)) }
            }
        }
        .padding(.horizontal, 14)
    }

    private var boutons: some View {
        HStack(spacing: 7) {
            IgPilule(titre: "Modifier le profil") { etat.ouvrir(.modifierProfil) }
            IgPilule(titre: "Partager le profil") { Haptique.leger(); etat.feuille = .partage("profil." + sarah.id) }
        }
        .padding(.horizontal, 14)
    }

    private var alaune: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(Array(DonneesInsta.alaune.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 6) {
                        IgPhoto(cle: item.image)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(Color(hex: 0x4A4E55), lineWidth: 1.5).padding(-4))
                        Text(item.titre).font(.system(size: 12)).foregroundStyle(.white).lineLimit(1).frame(width: 68)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { etat.ouvrir(.archives) }
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

    private var identifiees: [IgPost] { DonneesInsta.identifications(sarah.id) }

    @ViewBuilder private var contenuOnglet: some View {
        if etat.ongletProfil == 1 {
            if identifiees.isEmpty {
                IgEtatVide(titre: "Photos et vidéos de vous",
                           texte: "Lorsque des personnes vous identifient, les publications apparaissent ici.")
            } else {
                IgGrilleProfil(posts: identifiees) { p in etat.ouvrir(.detail(p.id)) }
            }
        } else {
            IgGrilleProfil(posts: grille) { p in etat.ouvrir(.detail(p.id)) }
        }
    }
}

// ============================================================ 15. PROFIL TIERS (e105, e148, e158)
struct IgProfilTiersVue: View {
    let pseudo: String
    @ObservedObject var etat: IgEtat
    @State private var onglet: Int = 0

    private var compte: IgCompte { etat.compteAffiche(pseudo) }
    private var estMoi: Bool { pseudo == etat.sarah.id }
    private var suit: Bool { estMoi || etat.suivis.contains(pseudo) }
    private var voitContenu: Bool { !compte.prive || suit }
    private var grille: [IgPost] { etat.grilleDe(pseudo) }
    private var identifiees: [IgPost] { DonneesInsta.identifications(pseudo) }

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
                    IgOngletsProfil(symboles: ["square.grid.3x3", "person.crop.square"], actif: $onglet)
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
            Image(systemName: "ellipsis").font(.system(size: 18)).foregroundStyle(.white)
                .frame(width: 36, height: 44)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .options("profil." + pseudo) }
        }
        .frame(height: 46)
        .padding(.horizontal, 12)
    }

    private var identite: some View {
        HStack(alignment: .center, spacing: 16) {
            IgAvatar(compte: compte, taille: 87, anneau: compte.enStory)
                .contentShape(Circle())
                .onTapGesture { if compte.enStory { etat.ouvrir(.story(pseudo)) } }
            VStack(alignment: .leading, spacing: 8) {
                Text(compte.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                HStack(spacing: 0) {
                    IgColonneStat(valeur: "\(grille.count)", libelle: "publications") { onglet = 0 }
                    IgColonneStat(valeur: etat.texteFollowers(pseudo), libelle: "followers") {
                        etat.ouvrir(.relations(pseudo, .followers))
                    }
                    IgColonneStat(valeur: etat.texteSuivis(pseudo), libelle: "suivi(e)s") {
                        etat.ouvrir(.relations(pseudo, .suivis))
                    }
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
        .onTapGesture { etat.ouvrir(.navigateur(l)) }
    }

    @ViewBuilder private var boutons: some View {
        if estMoi {
            HStack(spacing: 7) {
                IgPilule(titre: "Modifier le profil") { etat.ouvrir(.modifierProfil) }
                IgPilule(titre: "Partager le profil") { Haptique.leger(); etat.feuille = .partage("profil." + pseudo) }
            }
            .padding(.horizontal, 14)
        } else {
            HStack(spacing: 7) {
                IgPilule(titre: suit ? "Suivi(e)" : "Suivre", pleine: !suit) { etat.basculerSuivi(pseudo) }
                IgPilule(titre: "Envoyer un message") { ouvrirFil() }
            }
            .padding(.horizontal, 14)
        }
    }

    private func ouvrirFil() {
        Haptique.leger()
        etat.ouvrir(.fil(etat.conversationAvec(compte)))
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
        } else if onglet == 1 {
            if identifiees.isEmpty {
                IgEtatVide(titre: "Aucune identification",
                           texte: "\(compte.id) n'est identifié(e) dans aucune publication visible.")
            } else {
                IgGrilleProfil(posts: identifiees) { p in etat.ouvrir(.detail(p.id)) }
            }
        } else if grille.isEmpty {
            IgEtatVide(titre: "Aucune publication",
                       texte: "Les publications de \(compte.id) apparaîtront ici.")
        } else {
            IgGrilleProfil(posts: grille) { p in etat.ouvrir(.detail(p.id)) }
        }
    }
}

// ============================================================ 16. LISTES DE RELATIONS (D92)
// Liste RÉELLE des personnages : chaque ligne ouvre un profil. Pour les comptes médias, une
// dernière ligne NON cliquable « et N autres » explicite la foule anonyme : le compteur du
// profil vaut donc exactement « personnages listés + N autres ».
struct IgRelationsVue: View {
    let pseudo: String
    let genre: IgGenreRelation
    @ObservedObject var etat: IgEtat
    @State private var recherche: String = ""

    private var compte: IgCompte { etat.compteAffiche(pseudo) }
    private var base: [IgCompte] { etat.relations(pseudo, genre) }
    private var autres: Int { genre == .followers ? IgFoule.autres(pseudo) : 0 }

    private var liste: [IgCompte] {
        guard !recherche.isEmpty else { return base }
        let q = recherche.lowercased()
        return base.filter { $0.id.lowercased().contains(q) || $0.nom.lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            barre
            champ
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(liste) { c in ligne(c) }
                    if liste.isEmpty {
                        IgEtatVide(titre: "Aucun compte",
                                   texte: recherche.isEmpty
                                   ? "Cette liste est vide."
                                   : "Aucun compte ne correspond à « \(recherche) ».")
                    }
                    if autres > 0 && recherche.isEmpty { ligneAutres }
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
                Text(genre == .followers ? "Followers" : "Suivi(e)s")
                    .font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                Text(compte.id).font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
            }
            HStack {
                IgBoutonRond(systeme: "chevron.left", diametre: 40, taille: 16) { etat.fermer() }
                Spacer()
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 12)
    }

    private var champ: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            TextField("", text: $recherche,
                      prompt: Text("Rechercher").foregroundStyle(IgTheme.secondaire))
                .font(.system(size: 15)).foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .frame(height: 39)
        .background(Capsule().fill(IgTheme.surface2))
        .padding(.horizontal, 14).padding(.bottom, 8)
    }

    private func ligne(_ c: IgCompte) -> some View {
        HStack(spacing: 12) {
            IgAvatar(compte: c, taille: 44, anneau: c.enStory)
            VStack(alignment: .leading, spacing: 2) {
                Text(c.id).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                Text(c.nom).font(.system(size: 14)).foregroundStyle(IgTheme.secondaire).lineLimit(1)
            }
            Spacer(minLength: 6)
            if c.id != etat.sarah.id {
                Text(etat.suivis.contains(c.id) ? "Suivi(e)" : "Suivre")
                    .font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 86, height: 30)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(etat.suivis.contains(c.id) ? IgTheme.surface3 : IgTheme.accent))
                    .contentShape(Rectangle())
                    .onTapGesture { etat.basculerSuivi(c.id) }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { etat.ouvrir(.profil(c.id)) }
    }

    /// Ligne NON cliquable : la foule anonyme d'un compte média, annoncée honnêtement.
    private var ligneAutres: some View {
        HStack(spacing: 12) {
            Circle().fill(IgTheme.surface3)
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "person.2.fill").font(.system(size: 16)).foregroundStyle(IgTheme.secondaire))
            Text("et \(IgOutils.compteur(autres)) autres")
                .font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            Spacer(minLength: 6)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }
}

// ============================================================ 17. VISIONNEUSE DE STORY (e105–e112, e155)
// D92, version ÉPURÉE : plus de caméra, plus de cœur, plus d'icône commentaire, plus de « ≡ ».
// Restent : la barre segmentée, le ✕ 44 pt, les réactions rapides (qui envoient RÉELLEMENT un
// message), le champ « Envoyer un message » (le message part avec la story intégrée) et l'envoi
// de la story à quelqu'un (feuille de partage → carte dans sa conversation).
struct IgStoryVue: View {
    let pseudo: String
    @ObservedObject var etat: IgEtat

    @State private var segment: Int = 0
    @State private var progression: Double = 0
    @State private var decalage: CGFloat = 0
    @State private var reponse: String = ""

    private let minuteur = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let dureeSegment: Double = 5.0

    private var compte: IgCompte { etat.compteAffiche(pseudo) }
    private var segments: [String] { etat.segmentsStory(pseudo) }
    private var estMoi: Bool { pseudo == etat.sarah.id }

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
                if !estMoi { reactionsRapides }
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
            IgPhoto(cle: segments[min(segment, max(segments.count - 1, 0))], teinte: compte.teinte)
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
            IgAvatar(compte: compte, taille: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text(compte.id).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                Text("Il y a 4 h").font(.system(size: 12.5)).foregroundStyle(.white.opacity(0.75))
            }
            .contentShape(Rectangle())
            .onTapGesture { if !estMoi { etat.ouvrir(.profil(pseudo)) } }
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
                    .onTapGesture { Haptique.leger(); etat.reagirAStory(pseudo, emoji: e) }
            }
        }
        .padding(.bottom, 12)
    }

    private var barreReponse: some View {
        HStack(spacing: 16) {
            if estMoi {
                Text("Votre story · visible par vos abonné(e)s")
                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                TextField("", text: $reponse,
                          prompt: Text("Envoyer un message…").foregroundStyle(.white.opacity(0.85)))
                    .font(.system(size: 14)).foregroundStyle(.white)
                    .padding(.horizontal, 16).frame(height: 40)
                    .background(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
                    .onSubmit { envoyerReponse() }
            }
            IgEnvoyerForme().stroke(Color.white, style: StrokeStyle(lineWidth: 1.6, lineJoin: .round))
                .frame(width: 20, height: 20)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.feuille = .partage("story." + pseudo) }
        }
        .padding(.horizontal, 14).padding(.bottom, 30)
    }

    private func envoyerReponse() {
        etat.repondreAStory(pseudo, texte: reponse)
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

// ============================================================ 18. DÉTAIL PUBLICATION (e169–e175)
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
                    IgRangeeIconesPost(post: post, etat: etat)
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
            .overlay(alignment: .center) {
                if post.estVideo {
                    Image(systemName: "play.fill").font(.system(size: 34))
                        .foregroundStyle(.white.opacity(0.85)).allowsHitTesting(false)
                }
            }
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
                (Text(c.compte.id + " ").font(.system(size: 14, weight: .semibold))
                 + Text(c.texte).font(.system(size: 14)))
                    .foregroundStyle(.white).lineLimit(2)
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

// ============================================================ 19. NOTIFICATIONS (onglet cœur)
// Chaque ligne ouvre RÉELLEMENT sa destination : le profil concerné, ou la publication citée.
struct IgNotificationsVue: View {
    @ObservedObject var etat: IgEtat

    private struct Ligne: Identifiable {
        let id: String
        let compte: IgCompte
        let action: String
        let quand: String
        let suivre: Bool
        let post: String?
    }

    private var cette: [Ligne] { [
        Ligne(id: "notif.1", compte: DonneesInsta.chloe, action: "a aimé votre publication.",
              quand: "2 h", suivre: false, post: "pub.sarah.lvsr.0"),
        Ligne(id: "notif.2", compte: DonneesInsta.marc, action: "a commencé à vous suivre.",
              quand: "5 h", suivre: true, post: nil),
        Ligne(id: "notif.3", compte: DonneesInsta.ines, action: "a commenté votre publication.",
              quand: "1 j", suivre: false, post: "pub.sarah.lvsr.4")
    ] }
    private var avant: [Ligne] { [
        Ligne(id: "notif.4", compte: DonneesInsta.atelier, action: "vous a identifiée dans une publication.",
              quand: "4 j", suivre: false, post: "post.poterie"),
        Ligne(id: "notif.5", compte: DonneesInsta.lyon, action: "a aimé votre publication.",
              quand: "1 sem.", suivre: false, post: "pub.sarah.lvsr.8"),
        Ligne(id: "notif.6", compte: DonneesInsta.lea, action: "a accepté votre demande.",
              quand: "2 sem.", suivre: false, post: nil)
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
                .contentShape(Circle())
                .onTapGesture { etat.ouvrir(.profil(l.compte.id)) }
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
            } else if let p = l.post {
                IgPhoto(cle: IgCatalogue.post(p).images.first)
                    .frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            if let p = l.post { etat.ouvrir(.detail(p)) } else { etat.ouvrir(.profil(l.compte.id)) }
        }
    }
}

// ============================================================ 20. NAVIGATEUR INTERNE (liens de bio, D92)
// Le vrai Instagram n'envoie pas vers Safari : il ouvre sa propre vue web. On fait pareil.
// Barre d'adresse figée (le domaine réel du lien), page rendue depuis IgPagesWeb.
struct IgNavigateurVue: View {
    let domaine: String
    @ObservedObject var etat: IgEtat
    @State private var chargement: Double = 0

    private var page: IgPageWeb { IgPagesWeb.page(domaine) }
    private let horloge = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            barre
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        entete
                        ForEach(Array(page.paragraphes.enumerated()), id: \.offset) { _, p in
                            Text(p).font(.system(size: 15.5)).foregroundStyle(Color(hex: 0x1C1C1E))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        if !page.images.isEmpty { planche }
                        if !page.pied.isEmpty {
                            Text(page.pied).font(.system(size: 12.5)).foregroundStyle(Color(hex: 0x8A8A8E))
                                .padding(.top, 6)
                        }
                        Color.clear.frame(height: 110)
                    }
                    .padding(.horizontal, 20).padding(.top, 22)
                }
                if chargement < 1 {
                    GeometryReader { geo in
                        Rectangle().fill(IgTheme.lien)
                            .frame(width: geo.size.width * chargement, height: 2.5)
                    }
                    .frame(height: 2.5)
                }
            }
            .background(Color.white)
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(horloge) { _ in if chargement < 1 { chargement = min(chargement + 0.06, 1) } }
    }

    private var barre: some View {
        HStack(spacing: 10) {
            Image(systemName: "xmark").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                .frame(width: 40, height: 44)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); etat.fermer() }
            HStack(spacing: 7) {
                Image(systemName: "lock.fill").font(.system(size: 11)).foregroundStyle(IgTheme.secondaire)
                Text(domaine).font(.system(size: 14)).foregroundStyle(.white).lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 13)
            .frame(height: 34)
            .background(Capsule().fill(IgTheme.surface2))
            Image(systemName: "arrow.clockwise").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                .frame(width: 40, height: 44)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); chargement = 0 }
        }
        .padding(.horizontal, 10)
        .frame(height: 50)
    }

    private var entete: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(page.titre).font(.system(size: 27, weight: .bold)).foregroundStyle(Color(hex: 0x0B0B0C))
            Text(page.sousTitre).font(.system(size: 15)).foregroundStyle(Color(hex: 0x6B6B70))
            Rectangle().fill(Color(hex: 0xE3E3E8)).frame(height: 1).padding(.top, 8)
        }
    }

    private var planche: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 2), spacing: 6) {
            ForEach(Array(page.images.enumerated()), id: \.offset) { _, cle in
                IgPhoto(cle: cle)
                    .frame(height: 118)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
    }
}

// ============================================================ 21. ÉCRANS DU MENU « ≡ » (D92)
// Paramètres, Enregistrements, Archives — et rien d'autre. Chacun affiche un contenu RÉEL.
struct IgParametresVue: View {
    @ObservedObject var etat: IgEtat

    var body: some View {
        VStack(spacing: 0) {
            IgBarreEcran(titre: "Paramètres") { etat.fermer() }
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    section("Compte")
                    ligneTexte("Nom", etat.sarah.nom)
                    ligneTexte("Nom d'utilisateur", etat.sarah.id)
                    ligneTexte("Type de compte", "Compte personnel")
                    section("Notifications")
                    bascule
                    section("Confidentialité")
                    ligneTexte("Compte privé", "Non")
                    ligneTexte("Comptes en sourdine", "\(etat.sourdine.count)")
                    section("À propos")
                    ligneTexte("Version", "Instagram 312.0 (iOS)")
                    Color.clear.frame(height: 110)
                }
            }
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func section(_ titre: String) -> some View {
        Text(titre).font(.system(size: 13, weight: .semibold)).foregroundStyle(IgTheme.secondaire)
            .padding(.horizontal, 16).padding(.top, 20).padding(.bottom, 8)
    }

    private func ligneTexte(_ titre: String, _ valeur: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(titre).font(.system(size: 15.5)).foregroundStyle(.white)
                Spacer()
                Text(valeur).font(.system(size: 15)).foregroundStyle(IgTheme.secondaire).lineLimit(1)
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
            IgSeparateur().padding(.leading, 16)
        }
    }

    private var bascule: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $etat.notificationsActives) {
                Text("Notifications Instagram").font(.system(size: 15.5)).foregroundStyle(.white)
            }
            .tint(IgTheme.accent)
            .padding(.horizontal, 16).padding(.vertical, 8)
            IgSeparateur().padding(.leading, 16)
        }
    }
}

struct IgEnregistrementsVue: View {
    @ObservedObject var etat: IgEtat

    private var posts: [IgPost] {
        DonneesInsta.publications.filter { etat.enregistres.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            IgBarreEcran(titre: "Enregistrements") { etat.fermer() }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if posts.isEmpty {
                        IgEtatVide(titre: "Aucune publication enregistrée",
                                   texte: "Appuyez sur le signet d'une publication pour la retrouver ici.")
                            .padding(.top, 60)
                    } else {
                        Text("\(posts.count) publication(s)")
                            .font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
                            .padding(.horizontal, 14)
                        IgGrilleProfil(posts: posts) { p in etat.ouvrir(.detail(p.id)) }
                    }
                    Color.clear.frame(height: 110)
                }
            }
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct IgArchivesVue: View {
    @ObservedObject var etat: IgEtat

    var body: some View {
        VStack(spacing: 0) {
            IgBarreEcran(titre: "Archives") { etat.fermer() }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Stories à la une")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.top, 10)
                    ForEach(Array(DonneesInsta.alaune.enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 12) {
                            IgPhoto(cle: item.image)
                                .frame(width: 54, height: 54)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.titre).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                                Text("Story archivée").font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 5)
                        .contentShape(Rectangle())
                        .onTapGesture { etat.ouvrir(.story(etat.sarah.id)) }
                    }
                    Color.clear.frame(height: 110)
                }
            }
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Modifier le profil : simple et RÉEL — le nom, la bio et le lien changent partout.
struct IgModifierProfilVue: View {
    @ObservedObject var etat: IgEtat
    @State private var nom: String = ""
    @State private var bio: String = ""
    @State private var lien: String = ""
    @State private var charge: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            barre
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    IgAvatar(compte: etat.sarah, taille: 92)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                    champ("Nom", texte: $nom)
                    champMulti("Bio", texte: $bio)
                    champ("Lien", texte: $lien)
                    Text("Le nom d'utilisateur (\(etat.sarah.id)) ne peut pas être modifié depuis cet appareil.")
                        .font(.system(size: 12.5)).foregroundStyle(IgTheme.secondaire)
                    Color.clear.frame(height: 110)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(IgTheme.fond)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            guard !charge else { return }
            charge = true
            nom = etat.sarah.nom
            bio = etat.sarah.bio
            lien = etat.sarah.lien ?? ""
        }
    }

    private var barre: some View {
        ZStack {
            Text("Modifier le profil").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
            HStack {
                Text("Annuler").font(.system(size: 15)).foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); etat.fermer() }
                Spacer()
                Text("OK").font(.system(size: 15, weight: .semibold)).foregroundStyle(IgTheme.lien)
                    .contentShape(Rectangle())
                    .onTapGesture { enregistrer() }
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
    }

    private func champ(_ titre: String, texte: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titre).font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
            TextField("", text: texte)
                .font(.system(size: 15.5)).foregroundStyle(.white)
                .padding(.horizontal, 14).frame(height: 42)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.surface2))
        }
    }

    private func champMulti(_ titre: String, texte: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titre).font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
            TextEditor(text: texte)
                .font(.system(size: 15.5))
                .foregroundStyle(.white)
                .scrollContentBackground(.hidden)
                .frame(height: 92)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IgTheme.surface2))
        }
    }

    private func enregistrer() {
        Haptique.leger()
        let l = lien.trimmingCharacters(in: .whitespacesAndNewlines)
        etat.sarah.nom = nom.trimmingCharacters(in: .whitespacesAndNewlines)
        etat.sarah.bio = bio
        etat.sarah.lien = l.isEmpty ? nil : l
        etat.fermer()
        etat.signaler("Profil mis à jour")
    }
}

/// Barre de titre commune des écrans secondaires simples.
struct IgBarreEcran: View {
    let titre: String
    var retour: () -> Void
    var body: some View {
        ZStack {
            Text(titre).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
            HStack {
                IgBoutonRond(systeme: "chevron.left", diametre: 40, taille: 16) { retour() }
                Spacer()
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 12)
    }
}

// ============================================================ 22. CATALOGUE + FOULE ANONYME
// La boucle miroir et les couches d'overlay ne manipulent que des identifiants : ces
// accesseurs rendent des valeurs NON optionnelles (jamais de `!`, jamais de crash).
enum IgCatalogue {
    static func post(_ id: String) -> IgPost {
        if let p = DonneesInsta.publications.first(where: { $0.id == id }) { return p }
        if let r = IgReels.liste.first(where: { $0.id == id }) { return IgReels.commePost(r) }
        return DonneesInsta.feed[0]
    }

    static func conversation(_ id: String) -> IgConversation {
        if let c = DonneesInsta.conversations.first(where: { $0.id == id }) { return c }
        return DonneesInsta.conversations[0]
    }

    static func reel(_ id: String) -> IgReel {
        if let r = IgReels.liste.first(where: { $0.id == id }) { return r }
        return IgReels.liste[0]
    }

    /// Destinataires de la feuille de partage : de VRAIS personnages, tous ouvrables (e019, e021).
    static let destinataires: [IgCompte] = DonneesInsta.comptes

    /// Libellé lisible d'une cible de feuille (partage, options) — jamais un identifiant brut.
    static func libelle(_ cible: String) -> String {
        if cible.hasPrefix("story.") { return "La story de " + String(cible.dropFirst(6)) }
        if cible.hasPrefix("profil.") { return "Le profil de " + String(cible.dropFirst(7)) }
        if cible.hasPrefix("reel.") { return "Ce reel" }
        return "Cette publication"
    }
}

// D92, arbitrage « compteurs » : pour les comptes MÉDIAS / PRO, la liste des personnages est
// suivie d'une ligne non cliquable « et N autres ». Le compteur affiché vaut donc EXACTEMENT
// « personnages listés + N ». Aucun compte personnel n'a de foule anonyme : chez Chloé, Inès,
// Marc… le compteur est le nombre exact de profils qu'on peut ouvrir.
enum IgFoule {
    static let anonymes: [String: Int] = [
        "lyon.maville": 127985,
        "rando.rhonealpes": 9420,
        "atelierpoterie.lyon3": 3142,
        "atelier.lumiere.fr": 2478,
        "cafe.voyageurs.lyon": 1836
    ]
    static func autres(_ pseudo: String) -> Int { anonymes[pseudo] ?? 0 }
}

extension IgEtat {
    /// Compteur de followers = liste réelle + foule anonyme éventuelle (comptes médias).
    func texteFollowers(_ pseudo: String) -> String {
        IgOutils.compteur(followersDe(pseudo).count + IgFoule.autres(pseudo))
    }
    /// Compteur d'abonnements = liste réelle, sans exception.
    func texteSuivis(_ pseudo: String) -> String {
        IgOutils.compteur(suivisDe(pseudo).count)
    }
    /// Résolution d'une publication en tenant compte des créations de la session.
    func publication(_ identifiant: String) -> IgPost {
        postsPerso.first(where: { $0.id == identifiant }) ?? IgCatalogue.post(identifiant)
    }
}

// ============================================================ 23. COUCHE OVERLAYS (écrans plein cadre)
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
            IgStoryVue(pseudo: pseudo, etat: etat)
        case .profil(let pseudo):
            IgProfilTiersVue(pseudo: pseudo, etat: etat)
        case .detail(let identifiant):
            IgDetailPostVue(post: etat.publication(identifiant), etat: etat)
        case .fil(let identifiant):
            IgFilVue(identifiant: identifiant, etat: etat)
        case .notifications:
            IgNotificationsVue(etat: etat)
        case .relations(let pseudo, let genre):
            IgRelationsVue(pseudo: pseudo, genre: genre, etat: etat)
        case .appel(let identifiant, let mode):
            IgAppelVue(conv: etat.conv(identifiant), mode: mode, etat: etat)
        case .navigateur(let domaine):
            IgNavigateurVue(domaine: domaine, etat: etat)
        case .modifierProfil:
            IgModifierProfilVue(etat: etat)
        case .enregistrements:
            IgEnregistrementsVue(etat: etat)
        case .archives:
            IgArchivesVue(etat: etat)
        case .parametres:
            IgParametresVue(etat: etat)
        }
    }
}

// ============================================================ 24. COUCHE FEUILLES (bottom sheets maison)
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
            IgFeuilleCommentaires(post: etat.publication(identifiant), etat: etat)
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
        case .reactions(let identifiant):
            IgFeuilleReactions(message: identifiant, etat: etat)
        case .nouveauMessage:
            IgFeuilleNouveauMessage(etat: etat)
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

// ============================================================ 25. FEUILLE COMMENTAIRES (e013–e016, e176–e180)
// Fond #15191C, poignée, titre gras 17 centré, bouton rond de partage à droite,
// lignes avatar 30 pt, rangée de 8 emojis, composer. Le compteur affiché ailleurs dans
// l'app vaut TOUJOURS le nombre de lignes de cette feuille.
struct IgFeuilleCommentaires: View {
    let post: IgPost
    @ObservedObject var etat: IgEtat
    @State private var saisie: String = ""

    private static let emojis: [String] = ["❤️", "🙌", "🔥", "👏", "🥹", "😍", "😮", "😂"]
    private var liste: [IgCommentaire] { etat.commentaires(post) }

    var body: some View {
        IgConteneurFeuille(fraction: 0.72, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                entete
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
                IgRondEnteteFeuille(diametre: 40, action: { etat.feuille = .partage(post.id) }) {
                    IgEnvoyerForme()
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 1.6, lineJoin: .round))
                        .frame(width: 18, height: 18)
                }
            }
        }
        .frame(height: 40)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 10)
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
            IgAvatar(compte: etat.sarah, taille: 36)
            HStack(spacing: 10) {
                TextField("", text: $saisie,
                          prompt: Text("Ajoutez un commentaire…").foregroundStyle(IgTheme.secondaire))
                    .font(.system(size: 15)).foregroundStyle(.white)
                    .onSubmit { envoyer(saisie) }
                if !saisie.trimmingCharacters(in: .whitespaces).isEmpty {
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
                .contentShape(Circle())
                .onTapGesture { etat.feuille = nil; etat.ouvrir(.profil(commentaire.compte.id)) }
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(commentaire.compte.id).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    Text(commentaire.quand).font(.system(size: 14)).foregroundStyle(IgTheme.secondaire)
                }
                Text(commentaire.texte).font(.system(size: 15)).foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Répondre").font(.system(size: 13, weight: .medium)).foregroundStyle(IgTheme.secondaire)
                    .padding(.top, 1)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); repondre(commentaire.compte.id) }
            }
            Spacer(minLength: 8)
            VStack(spacing: 3) {
                Group {
                    if aime {
                        IgCoeurForme().fill(IgTheme.coeurPlein)
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

// ============================================================ 26. FEUILLE DE PARTAGE (e019–e021)
// D92 : le partage MARCHE. Choisir un destinataire dépose une carte dans SA conversation
// (créée si elle n'existe pas). « Republier dans votre story » est retiré ; il ne reste que
// « Copier le lien », qui écrit réellement dans le presse-papiers.
struct IgFeuillePartage: View {
    let cible: String
    @ObservedObject var etat: IgEtat
    @State private var recherche: String = ""

    private var destinataires: [IgCompte] {
        guard !recherche.isEmpty else { return IgCatalogue.destinataires }
        let q = recherche.lowercased()
        return IgCatalogue.destinataires.filter {
            $0.id.lowercased().contains(q) || $0.nom.lowercased().contains(q)
        }
    }

    private var colonnes: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 12), count: 3) }

    var body: some View {
        IgConteneurFeuille(fraction: 0.62, fond: Color(hex: 0x1A1E22), fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                titre
                barreRecherche
                grille
                IgSeparateur()
                rangeeActions
            }
        }
    }

    private var titre: some View {
        Text(IgCatalogue.libelle(cible))
            .font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
            .frame(maxWidth: .infinity)
            .padding(.top, 4).padding(.bottom, 10)
    }

    private var barreRecherche: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            TextField("", text: $recherche,
                      prompt: Text("Rechercher").foregroundStyle(IgTheme.secondaire))
                .font(.system(size: 16)).foregroundStyle(.white)
        }
        .padding(.horizontal, 15)
        .frame(height: 44)
        .background(Capsule().fill(Color(hex: 0x2A2E35)))
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    private var grille: some View {
        ScrollView {
            LazyVGrid(columns: colonnes, spacing: 16) {
                ForEach(destinataires) { c in cellule(c) }
            }
            .padding(.horizontal, 16)
            if destinataires.isEmpty {
                IgEtatVide(titre: "Aucun compte", texte: "Aucun destinataire ne correspond à « \(recherche) ».")
            }
            Color.clear.frame(height: 10)
        }
        .frame(maxHeight: .infinity)
    }

    private func cellule(_ compte: IgCompte) -> some View {
        VStack(spacing: 8) {
            IgAvatar(compte: compte, taille: 74)
                .frame(width: 74, height: 74)
            Text(compte.nom).font(.system(size: 13)).foregroundStyle(.white)
                .lineLimit(2).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); etat.partager(cible, vers: compte) }
    }

    private var rangeeActions: some View {
        HStack(spacing: 22) {
            celluleAction(libelle: "Copier le lien") {
                AnyView(Image(systemName: "link").font(.system(size: 21, weight: .semibold)).foregroundStyle(.white))
            } faire: {
                etat.copier("https://instagram.com/" + cible)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 18)
    }

    private func celluleAction(libelle: String,
                               @ViewBuilder icone: () -> AnyView,
                               faire: @escaping () -> Void) -> some View {
        let glyphe = icone()
        return VStack(spacing: 8) {
            Circle().fill(Color(hex: 0x2A2E35))
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

// ============================================================ 27. FEUILLE D'OPTIONS (••• d'un profil)
// Seul point d'entrée conservé : le « ••• » d'un profil tiers. Chaque entrée a un effet RÉEL
// et persistant (sourdine, presse-papiers, partage, abonnement).
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

    private var pseudo: String {
        cible.hasPrefix("profil.") ? String(cible.dropFirst(7)) : cible
    }
    private var estSarah: Bool { pseudo == etat.sarah.id }

    private var entrees: [Entree] {
        var sortie: [Entree] = [
            Entree(id: "opt.lien", symbole: "link", titre: "Copier le lien du profil", rouge: false) {
                etat.copier("https://instagram.com/" + pseudo)
            },
            Entree(id: "opt.partage", symbole: "paperplane", titre: "Partager ce profil", rouge: false) {
                etat.feuille = .partage("profil." + pseudo)
            }
        ]
        if !estSarah {
            sortie.append(Entree(id: "opt.sourdine",
                                 symbole: etat.sourdine.contains(pseudo) ? "speaker.wave.2" : "speaker.slash",
                                 titre: etat.sourdine.contains(pseudo) ? "Réactiver ce compte" : "Mettre en sourdine",
                                 rouge: false) {
                etat.basculerSourdine(pseudo); etat.feuille = nil
            })
            sortie.append(Entree(id: "opt.favori",
                                 symbole: etat.favoris.contains(pseudo) ? "star.fill" : "star",
                                 titre: etat.favoris.contains(pseudo) ? "Retirer des favoris" : "Ajouter aux favoris",
                                 rouge: false) {
                etat.basculerFavori(pseudo); etat.feuille = nil
            })
            if etat.suivis.contains(pseudo) {
                sortie.append(Entree(id: "opt.suivi", symbole: "person.badge.minus",
                                     titre: "Se désabonner", rouge: true) {
                    etat.basculerSuivi(pseudo); etat.feuille = nil
                })
            }
        }
        return sortie
    }

    var body: some View {
        IgConteneurFeuille(fraction: 0.44, fermer: { etat.feuille = nil }) {
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

// ============================================================ 28. MENU DU FLUX « ⌄ » (§4.4)
// Le sélecteur filtre RÉELLEMENT le fil (IgEtat.postsDuFil).
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
                Text(nom).font(.system(size: 16, weight: etat.flux == nom ? Font.Weight.semibold : Font.Weight.regular))
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

// ============================================================ 29. FEUILLE DE CRÉATION « + »
// D92, création MINIMALE mais réelle : une photo de la pellicule devient une publication
// (fil + grille du profil) ou « Votre story ». Rien d'autre n'est proposé.
struct IgFeuilleCreation: View {
    @ObservedObject var etat: IgEtat

    var body: some View {
        IgConteneurFeuille(fraction: 0.34, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                Text("Créer").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.top, 6).padding(.bottom, 16)
                ligne("photo.on.rectangle", "Publication") { etat.feuille = .pellicule("creation.post") }
                ligne("plus.circle", "Story") { etat.feuille = .pellicule("creation.story") }
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

// ============================================================ 30. PICKER DE PELLICULE
// Sert à la création ET à l'envoi d'une photo dans une conversation (caméra indigo du composer).
// Les images sont celles de la pellicule de Sarah — rien d'inventé.
struct IgFeuillePellicule: View {
    let cible: String
    @ObservedObject var etat: IgEtat
    @State private var choisie: String? = nil
    @State private var legende: String = ""

    private var images: [String] { DonneesInsta.sarah.grille + DonneesInsta.mosaique.compactMap { $0.images.first } }
    private var colonnes: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 2), count: 3) }

    private var estPublication: Bool { cible == "creation.post" }
    private var estStory: Bool { cible == "creation.story" }
    private var titre: String {
        if estPublication { return "Nouvelle publication" }
        if estStory { return "Nouvelle story" }
        return "Envoyer une photo"
    }
    private var actionTitre: String { estPublication || estStory ? "Partager" : "Envoyer" }

    var body: some View {
        IgConteneurFeuille(fraction: 0.68, fond: Color(hex: 0x101315), fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                entete
                if estPublication { champLegende }
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
                Text(actionTitre).font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(choisie == nil ? IgTheme.secondaire : IgTheme.lien)
                    .contentShape(Rectangle())
                    .onTapGesture { valider() }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var champLegende: some View {
        TextField("", text: $legende,
                  prompt: Text("Écrire une légende…").foregroundStyle(IgTheme.secondaire))
            .font(.system(size: 15)).foregroundStyle(.white)
            .padding(.horizontal, 14).frame(height: 40)
            .background(Capsule().fill(IgTheme.surface2))
            .padding(.horizontal, 14).padding(.bottom, 10)
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
        guard let cle = choisie else { etat.signaler("Choisissez d'abord une photo"); return }
        etat.feuille = nil
        if estPublication {
            etat.publier(image: cle, legende: legende)
        } else if estStory {
            etat.publierStory(image: cle)
        } else {
            etat.envoyerPhoto(cle, dans: cible)
            etat.signaler("Photo envoyée à \(etat.conv(cible).compte.nom)")
        }
    }
}

// ============================================================ 31. FEUILLE « ≡ » DU PROFIL DE SARAH
// D92 : Paramètres, Enregistrements, Archives — « Votre activité », « Code QR » et
// « Amis proches » sont retirés. Chaque entrée ouvre un écran réel.
struct IgFeuilleActionsProfil: View {
    @ObservedObject var etat: IgEtat

    var body: some View {
        IgConteneurFeuille(fraction: 0.34, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                Text(etat.sarah.id).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.top, 6).padding(.bottom, 14)
                ligne("gearshape", "Paramètres") { etat.ouvrir(.parametres) }
                ligne("bookmark", "Enregistrements") { etat.ouvrir(.enregistrements) }
                ligne("archivebox", "Archives") { etat.ouvrir(.archives) }
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

// ============================================================ 32. FEUILLE DE RÉACTIONS (appui long)
struct IgFeuilleReactions: View {
    let message: String
    @ObservedObject var etat: IgEtat

    var body: some View {
        IgConteneurFeuille(fraction: 0.24, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                Text("Réagir au message")
                    .font(.system(size: 13)).foregroundStyle(IgTheme.secondaire)
                    .frame(maxWidth: .infinity).padding(.top, 6).padding(.bottom, 16)
                HStack(spacing: 0) {
                    ForEach(IgEtat.emojisReaction, id: \.self) { e in
                        Text(e).font(.system(size: 30))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .background(Circle().fill(etat.reactions[message] == e
                                                      ? IgTheme.surface3 : Color.clear))
                            .contentShape(Rectangle())
                            .onTapGesture { etat.reagir(e, sur: message) }
                    }
                }
                .padding(.horizontal, 10)
                if etat.reactions[message] != nil {
                    Text("Retirer la réaction")
                        .font(.system(size: 14, weight: .medium)).foregroundStyle(IgTheme.lien)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        .contentShape(Rectangle())
                        .onTapGesture { etat.retirerReaction(message); etat.feuille = nil }
                }
                Spacer(minLength: 0)
            }
        }
    }
}

// ============================================================ 33. FEUILLE « NOUVEAU MESSAGE »
// D92 : le bouton MARCHE — chaque suggestion ouvre la conversation existante, ou la CRÉE.
struct IgFeuilleNouveauMessage: View {
    @ObservedObject var etat: IgEtat
    @State private var recherche: String = ""

    private var suggestions: [IgCompte] {
        let base = DonneesInsta.comptes
        guard !recherche.isEmpty else { return base }
        let q = recherche.lowercased()
        return base.filter { $0.id.lowercased().contains(q) || $0.nom.lowercased().contains(q) }
    }

    var body: some View {
        IgConteneurFeuille(fraction: 0.72, fermer: { etat.feuille = nil }) {
            VStack(spacing: 0) {
                entete
                champ
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        Text("Suggestions").font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(IgTheme.secondaire)
                            .padding(.horizontal, 16).padding(.bottom, 6)
                        ForEach(suggestions) { c in ligne(c) }
                        if suggestions.isEmpty {
                            IgEtatVide(titre: "Aucun compte",
                                       texte: "Aucun compte ne correspond à « \(recherche) ».")
                        }
                        Color.clear.frame(height: 20)
                    }
                }
            }
        }
    }

    private var entete: some View {
        ZStack {
            Text("Nouveau message").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
            HStack {
                Text("Annuler").font(.system(size: 15)).foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); etat.feuille = nil }
                Spacer()
            }
        }
        .frame(height: 42)
        .padding(.horizontal, 16)
    }

    private var champ: some View {
        HStack(spacing: 9) {
            Text("À :").font(.system(size: 15)).foregroundStyle(IgTheme.secondaire)
            TextField("", text: $recherche,
                      prompt: Text("Rechercher").foregroundStyle(IgTheme.secondaire))
                .font(.system(size: 15)).foregroundStyle(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .overlay(alignment: .bottom) { IgSeparateur() }
        .padding(.bottom, 12)
    }

    private func ligne(_ c: IgCompte) -> some View {
        HStack(spacing: 12) {
            IgAvatar(compte: c, taille: 44, anneau: c.enStory)
            VStack(alignment: .leading, spacing: 2) {
                Text(c.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                Text(c.id).font(.system(size: 13.5)).foregroundStyle(IgTheme.secondaire)
            }
            Spacer(minLength: 6)
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                .foregroundStyle(IgTheme.secondaire)
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptique.leger()
            let identifiant = etat.conversationAvec(c)
            etat.ouvrir(.fil(identifiant))
        }
    }
}

// ============================================================ 34. WRAPPERS DE CAPTURE (boucle miroir D63)
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
        IgDetailPostVue(post: IgCatalogue.post("post.annecy"), etat: etat).preferredColorScheme(.dark)
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
        IgStoryVue(pseudo: DonneesInsta.chloe.id, etat: etat).preferredColorScheme(.dark)
    }
}

struct IgCaptureProfilPrive: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgProfilTiersVue(pseudo: DonneesInsta.lea.id, etat: etat).preferredColorScheme(.dark)
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
        IgFilVue(identifiant: "dm.chloe", etat: etat).preferredColorScheme(.dark)
    }
}

struct IgCaptureRelations: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgRelationsVue(pseudo: DonneesInsta.lyon.id, genre: .followers, etat: etat)
            .preferredColorScheme(.dark)
    }
}

struct IgCaptureNavigateur: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgNavigateurVue(domaine: "sarahlevasseur.myportfolio.com", etat: etat)
            .preferredColorScheme(.dark)
    }
}

struct IgCaptureAppel: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgAppelVue(conv: IgCatalogue.conversation("dm.chloe"), mode: .audio, etat: etat)
            .preferredColorScheme(.dark)
    }
}

struct IgCaptureAppelVideo: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgAppelVue(conv: IgCatalogue.conversation("dm.marc"), mode: .video, etat: etat)
            .preferredColorScheme(.dark)
    }
}

struct IgCaptureNouveauMessage: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgFondFeuilleCapture(sousJacent: { AnyView(IgDMListeVue(etat: etat)) }) {
            IgFeuilleNouveauMessage(etat: etat)
        }
    }
}

struct IgCaptureEnregistrements: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgEnregistrementsVue(etat: etat).preferredColorScheme(.dark)
    }
}

struct IgCaptureArchives: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgArchivesVue(etat: etat).preferredColorScheme(.dark)
    }
}

struct IgCaptureParametres: View {
    @StateObject private var etat = IgEtat()
    var body: some View {
        IgParametresVue(etat: etat).preferredColorScheme(.dark)
    }
}
