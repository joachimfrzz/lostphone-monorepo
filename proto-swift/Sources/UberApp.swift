// Uber v1 D92 (07/09) — construit contre les 56 frames de Joachim (vague B)
//
// D67 : la référence est /refs/vagueB/uber/e001…e056.jpg (603×1311 px, 1 pt = 1,5 px).
//   Écrans FILMÉS reproduits : Accueil (e001/e030/e034/e035), saisie de destination
//   « Planifiez votre course » (e002/e014/e015/e026/e027/e029), choix de course
//   (e004…e013/e017…e021/e031), « Les courses que vous pourriez apprécier » (e009/e020),
//   « Choisissez une heure » (e022/e042), page Reserve (e039), Services (e038/e044),
//   Activité vide + Passées (e045/e046/e047/e049), Compte (e050/e051/e052).
//   D93 (2e source autorisée) : « Confirmez votre point de prise en charge »
//   (refs/officiel2/uber/21_appstore_gb.jpg), « Boîte à outils de sécurité »
//   (30_appstore_cafr.jpg), « Uber One » (26_appstore_cafr.jpg).
//   Aucun écran inventé de mémoire : le détail d'une course passée est un ASSEMBLAGE de
//   briques filmées (carte + itinéraire d'e004, rangées d'adresse d'e002, prix, bouton noir).
//
// D59 : le contenu de Joachim (Auch, Colomiers, Toulouse, « Joachim Fourez », Pizzeria
//   L'Olivette, Crousty Rice, notifications BlackHatWorld) n'est qu'un gabarit. Tout est
//   remplacé par Sarah Levasseur (Lyon, 14 rue des Fantasques 69001), cohérente avec
//   Ma Banque (Visa LCL •••• 4417), PayPal et WhatsApp (« Marc ❤️ »).
//
// D92 : chaque affordance a une conséquence réelle. Ce qui ne pouvait pas exister ici est
//   RETIRÉ (liste complète dans docs_vague-b/uber-livraison.md), jamais laissé mort.
//
// Pas de MapKit : les cartes sont DESSINÉES (Canvas déterministe, style Uber désaturé).
// Aucun micro de dictée. Retour = chevron. Barres au-dessus de BarreHome.
// Préfixe de types : Ub — aucune collision avec LPProto / PayPal / App Store / Musique…
import SwiftUI

// ============================================================ PALETTE (mesurée au pixel)
enum UbTeinte {
    static let fond = Color.white                    // e001 : (254,254,254)
    static let tuile = Color(hex: 0xF0F0F0)          // e050/e038 : tuiles et cartes grises (240,240,240)
    static let tuileVive = Color(hex: 0xF6F6F6)      // e047 : pilules « Commander »
    static let bord = Color(hex: 0xEDEDED)           // e001 : contour des cartes (237,237,237)
    static let texte = Color(hex: 0x000000)
    static let gris = Color(hex: 0x6B6B6B)           // sous-titres
    static let grisClair = Color(hex: 0x9A9A9A)      // chevrons, distances
    static let segment = Color(hex: 0xE7E7E7)        // e022 : fond du sélecteur
    static let squelette = Color(hex: 0xE3E3E3)      // e045 : blocs de chargement
    static let noir = Color(hex: 0x000000)
    static let bleu = Color(hex: 0x276EF1)           // e004 : badge « Plus rapide » (35,98,239)
    static let bleuClair = Color(hex: 0xEBF2FE)
    static let rouge = Color(hex: 0xC00609)          // e004 : « Générez 5 % en crédit » (192,6,9)
    static let or = Color(hex: 0xE8A33D)             // Uber One (26_appstore_cafr)
    static let orClair = Color(hex: 0xF7E2BC)
    static let vert = Color(hex: 0x11875B)           // « 0 g » de CO₂ (e051)
    static let carteFond = Color(hex: 0xE1E5E8)      // e004 : fond de carte (225,229,232)
    static let carteBloc = Color(hex: 0xD8DCE0)      // pâtés de maisons
    static let carteEau = Color(hex: 0xC9D6E8)       // Saône / Rhône
}

// ============================================================ DONNÉES (remplaçables — D59)

enum UbIcone {
    case recent
    case favori
    case domicile
    case travail
    case gare
    case lieu
}

struct UbLieu: Identifiable, Equatable {
    let id = UUID()
    var nom: String
    var detail: String
    var km: Double
    var icone: UbIcone = .lieu

    static func == (a: UbLieu, b: UbLieu) -> Bool { a.id == b.id }

    var symbole: String {
        switch icone {
        case .recent: return "clock"
        case .favori: return "star"
        case .domicile: return "house"
        case .travail: return "briefcase"
        case .gare: return "tram"
        case .lieu: return "mappin"
        }
    }
    var distance: String {
        if km < 10 { return String(format: "%.1f km", km).replacingOccurrences(of: ".", with: ",") }
        return String(format: "%.0f km", km)
    }
}

struct UbCourse: Identifiable {
    let id = UUID()
    var date: String            // « 17 juil. 2026 »
    var heure: String           // « 10:52 »
    var depart: String
    var arrivee: String
    var departDetail: String
    var arriveeDetail: String
    var prix: Double
    var categorie: String
    var chauffeur: String
    var vehicule: String
    var plaque: String
    var noteChauffeur: String
    var duree: String
    var km: Double
    var graine: UInt64
}

struct UbCommandeEats: Identifiable {
    let id = UUID()
    var enseigne: String
    var date: String
    var heure: String
    var montant: Double
    var articles: Int
    var emoji: String
    var teinte: UInt
}

struct UbReservation: Identifiable {
    let id = UUID()
    var jour: String            // « Ven. 28 août »
    var heure: String           // « 05:40 »
    var depart: String
    var arrivee: String
    var categorie: String
    var prix: Double
    var km: Double
}

struct UbMessage: Identifiable {
    let id = UUID()
    var titre: String
    var date: String
    var corps: String
    var lu: Bool
}

struct UbOption: Identifiable {
    let id = UUID()
    var nom: String
    var capacite: Int
    var prix: Double
    var arrivee: String
    var duree: String
    var accroche: String
    var rapide: Bool
    var symbole: String
}

enum DonneesUb {
    static let nom = "Sarah Levasseur"
    static let note = "4,92"
    static let telephone = "+33 6 71 44 08 92"
    static let email = "sarah.levasseur@icloud.com"
    static let version = "v3.741.10002"

    static let domicile = UbLieu(nom: "Domicile", detail: "14 rue des Fantasques, 69001 Lyon",
                                 km: 0, icone: .domicile)
    static let travail = UbLieu(nom: "Travail", detail: "6 rue de la République, 69002 Lyon",
                                km: 1.9, icone: .travail)

    /// Les deux adresses récentes de l'accueil (e001) + les lieux proposés à la saisie (e002).
    static let recents: [UbLieu] = [
        UbLieu(nom: "Gare Lyon Part-Dieu", detail: "5 place Charles Béraudier, 69003 Lyon",
               km: 4.1, icone: .recent),
        UbLieu(nom: "LCL Agence Lyon Terreaux", detail: "9 place des Terreaux, 69001 Lyon",
               km: 1.2, icone: .recent)
    ]

    static let lieux: [UbLieu] = [
        UbLieu(nom: "Gare Lyon Part-Dieu", detail: "5 place Charles Béraudier, 69003 Lyon",
               km: 4.1, icone: .gare),
        UbLieu(nom: "LCL Agence Lyon Terreaux", detail: "9 place des Terreaux, 69001 Lyon",
               km: 1.2, icone: .recent),
        UbLieu(nom: "Chez Chloé", detail: "12 rue Burdeau, 69001 Lyon", km: 0.6, icone: .favori),
        UbLieu(nom: "Le resto des quais", detail: "Quai Saint-Antoine, 69002 Lyon",
               km: 2.0, icone: .recent),
        UbLieu(nom: "6 rue de la République", detail: "69002 Lyon", km: 1.9, icone: .travail),
        UbLieu(nom: "Gare de Lyon-Perrache", detail: "Cours de Verdun, 69002 Lyon",
               km: 3.4, icone: .gare),
        UbLieu(nom: "Aéroport Lyon-Saint-Exupéry", detail: "69125 Colombier-Saugnieu",
               km: 29.0, icone: .lieu),
        UbLieu(nom: "Parc de la Tête d'Or", detail: "Boulevard des Belges, 69006 Lyon",
               km: 3.2, icone: .lieu),
        UbLieu(nom: "Hôpital de la Croix-Rousse", detail: "103 grande rue de la Croix-Rousse, 69004 Lyon",
               km: 1.1, icone: .lieu),
        UbLieu(nom: "Place Bellecour", detail: "69002 Lyon", km: 2.3, icone: .lieu),
        UbLieu(nom: "Vieux Lyon — Saint-Jean", detail: "Place Saint-Jean, 69005 Lyon",
               km: 2.6, icone: .lieu),
        UbLieu(nom: "Centre commercial La Part-Dieu", detail: "17 rue du Docteur Bouchut, 69003 Lyon",
               km: 4.3, icone: .lieu)
    ]

    /// Courses passées (D59) — la paire du 17 juillet est l'indice : agence LCL puis Part-Dieu,
    /// le jour du virement de 4 850 € et du mandat Western Union.
    static func coursesPassees() -> [UbCourse] {
        [
            UbCourse(date: "12 août 2026", heure: "19:05",
                     depart: "14 rue des Fantasques", arrivee: "Gare Lyon Part-Dieu",
                     departDetail: "69001 Lyon", arriveeDetail: "5 place Charles Béraudier, 69003 Lyon",
                     prix: 14.20, categorie: "UberX", chauffeur: "Karim",
                     vehicule: "Peugeot 508 grise", plaque: "FT-482-QL",
                     noteChauffeur: "4,89", duree: "14 min", km: 4.1, graine: 31),
            UbCourse(date: "28 juillet 2026", heure: "22:10",
                     depart: "Quai Saint-Antoine", arrivee: "14 rue des Fantasques",
                     departDetail: "69002 Lyon", arriveeDetail: "69001 Lyon",
                     prix: 10.10, categorie: "UberX", chauffeur: "Nadia",
                     vehicule: "Toyota Corolla blanche", plaque: "GH-119-BR",
                     noteChauffeur: "4,95", duree: "9 min", km: 2.0, graine: 17),
            UbCourse(date: "17 juillet 2026", heure: "11:35",
                     depart: "9 place des Terreaux", arrivee: "Gare Lyon Part-Dieu",
                     departDetail: "69001 Lyon", arriveeDetail: "5 place Charles Béraudier, 69003 Lyon",
                     prix: 13.05, categorie: "UberX", chauffeur: "Mehdi",
                     vehicule: "Renault Talisman noire", plaque: "EJ-905-VD",
                     noteChauffeur: "4,91", duree: "13 min", km: 3.5, graine: 23),
            UbCourse(date: "17 juillet 2026", heure: "10:52",
                     depart: "14 rue des Fantasques", arrivee: "LCL Agence Lyon Terreaux",
                     departDetail: "69001 Lyon", arriveeDetail: "9 place des Terreaux, 69001 Lyon",
                     prix: 8.55, categorie: "UberX", chauffeur: "Sofiane",
                     vehicule: "Skoda Octavia grise", plaque: "DR-337-TK",
                     noteChauffeur: "4,87", duree: "7 min", km: 1.2, graine: 9),
            UbCourse(date: "5 juillet 2026", heure: "23:40",
                     depart: "12 rue Burdeau", arrivee: "14 rue des Fantasques",
                     departDetail: "69001 Lyon", arriveeDetail: "69001 Lyon",
                     prix: 8.20, categorie: "UberX", chauffeur: "Laurent",
                     vehicule: "Citroën C4 bleue", plaque: "CQ-728-MF",
                     noteChauffeur: "4,78", duree: "6 min", km: 0.6, graine: 5)
        ]
    }

    static func commandesEats() -> [UbCommandeEats] {
        [
            UbCommandeEats(enseigne: "Pizzeria Nonna", date: "9 août", heure: "20:36",
                           montant: 23.40, articles: 2, emoji: "🍕", teinte: 0xE2664A),
            UbCommandeEats(enseigne: "Sushi Croix-Rousse", date: "23 juillet", heure: "21:12",
                           montant: 18.90, articles: 1, emoji: "🍣", teinte: 0x3E6E8E),
            UbCommandeEats(enseigne: "Le Bouchon des Pentes", date: "2 juillet", heure: "12:47",
                           montant: 15.60, articles: 1, emoji: "🥗", teinte: 0x7A8B3A)
        ]
    }

    /// Uber Eats, section d'accueil (e001/e034) — restaurants de la Croix-Rousse.
    static let restaurants: [(String, String, String, String, UInt)] = [
        ("Pizzeria Nonna", "Pizzas", "4,7 ★ (470+)", "🍕", 0xE2664A),
        ("Sushi Croix-Rousse", "Japonais", "4,6 ★ (310+)", "🍣", 0x3E6E8E),
        ("Le Bouchon des Pentes", "Lyonnais", "4,8 ★ (820+)", "🥘", 0x9A6B3A)
    ]

    static func messages() -> [UbMessage] {
        [
            UbMessage(titre: "5 % en crédit Uber sur vos courses cet été",
                      date: "11 août 2026",
                      corps: "Jusqu'au 31 août, chaque course UberX effectuée à Lyon vous rapporte 5 % de son montant en crédit Uber, utilisable sur vos prochains trajets. Le crédit est ajouté à votre compte sous 48 heures après la fin de la course.\n\nOffre réservée aux comptes personnels, non cumulable avec une autre promotion.",
                      lu: false),
            UbMessage(titre: "Vos reçus sont désormais envoyés par e-mail",
                      date: "3 juillet 2026",
                      corps: "À partir de ce mois-ci, le reçu de chacune de vos courses vous est envoyé automatiquement à l'adresse sarah.levasseur@icloud.com, en plus d'être disponible dans l'onglet Activité.\n\nVous pouvez modifier l'adresse de réception dans Compte › Paramètres › Coordonnées.",
                      lu: true)
        ]
    }
}

// ============================================================ TARIFS (déterministes)
// Barème unique : le prix ne dépend QUE de la destination et de la catégorie, jamais du hasard.
enum UbTarifs {
    static let heureBase = 19 * 60 + 42        // 19:42, heure de jeu (17-20 août 2026)

    static func prixUberX(_ km: Double) -> Double {
        ((6.20 + 1.95 * km) * 10).rounded() / 10
    }
    static func minutesTrajet(_ km: Double) -> Int {
        max(5, Int((6.0 + 1.9 * km).rounded()))
    }
    static func horaire(_ minutes: Int) -> String {
        let t = (heureBase + minutes) % (24 * 60)
        return String(format: "%02d:%02d", t / 60, t % 60)
    }

    /// Les quatre offres filmées (e004) — mêmes libellés, prix dérivés du barème.
    static func options(km: Double) -> [UbOption] {
        let base = prixUberX(km)
        let duree = minutesTrajet(km)
        return [
            UbOption(nom: "UberX", capacite: 4, prix: base,
                     arrivee: horaire(duree + 4), duree: "\(duree) min",
                     accroche: "Économique, rapide et fiable", rapide: false, symbole: "car.fill"),
            UbOption(nom: "Wait & Save", capacite: 4, prix: (base * 0.88 * 10).rounded() / 10,
                     arrivee: horaire(duree + 15), duree: "\(duree) - \(duree + 9) min",
                     accroche: "Économisez en attendant", rapide: false, symbole: "car.fill"),
            UbOption(nom: "Priority", capacite: 4, prix: (base * 1.17 * 10).rounded() / 10,
                     arrivee: horaire(duree + 2), duree: "\(duree - 1) min",
                     accroche: "Moins de temps d'attente", rapide: true, symbole: "bolt.car.fill"),
            UbOption(nom: "Uber Pet", capacite: 4, prix: (base * 1.28 * 10).rounded() / 10,
                     arrivee: horaire(duree + 7), duree: "\(duree + 2) min",
                     accroche: "Courses adaptées aux animaux de compagnie",
                     rapide: false, symbole: "pawprint.fill")
        ]
    }
}

enum UbFormat {
    static func euro(_ v: Double) -> String {
        String(format: "%.2f €", v).replacingOccurrences(of: ".", with: ",")
    }
}

// ============================================================ MAGASIN (état réel et persistant)
final class UbEtat: ObservableObject {
    static let partage = UbEtat()

    /// UNE course planifiée : Sarah part rejoindre « Marc » à Marseille le 28 août.
    @Published var reservations: [UbReservation] = [
        UbReservation(jour: "Ven. 28 août", heure: "05:40",
                      depart: "14 rue des Fantasques, 69001 Lyon",
                      arrivee: "Gare Lyon Part-Dieu",
                      categorie: "UberX", prix: 14.20, km: 4.1)
    ]
    @Published var courses: [UbCourse] = DonneesUb.coursesPassees()
    @Published var commandes: [UbCommandeEats] = DonneesUb.commandesEats()
    @Published var messages: [UbMessage] = DonneesUb.messages()

    // Paramètres réellement modifiables (Compte › Paramètres)
    @Published var notifCourses = true
    @Published var notifPromotions = false
    @Published var partageTrajet = false
    @Published var codeVerification = false
    @Published var apparence = 0            // 0 = Système, 1 = Clair, 2 = Sombre

    var messagesNonLus: Int { messages.filter { !$0.lu }.count }

    /// Contrôle de sécurité : 1 étape acquise (numéro vérifié) + les outils réellement activés.
    var etapesSecurite: Int { 1 + (partageTrajet ? 1 : 0) + (codeVerification ? 1 : 0) }

    func annuler(_ reservation: UbReservation) {
        reservations.removeAll { $0.id == reservation.id }
    }

    func reserver(vers lieu: UbLieu, jour: String, heure: String, categorie: String, prix: Double) {
        reservations.append(UbReservation(jour: jour, heure: heure,
                                          depart: DonneesUb.domicile.detail,
                                          arrivee: lieu.nom, categorie: categorie,
                                          prix: prix, km: lieu.km))
    }

    func marquerLu(_ message: UbMessage) {
        guard let i = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[i].lu = true
    }
}

// ============================================================ CAPTURE (pipeline Miroir)
// Accesseurs NON optionnels : aucun indice nu dans le registre d'écrans de LPProto.
enum UbCapture {
    static func etat() -> UbEtat { UbEtat.partage }

    static func lieu() -> UbLieu {
        DonneesUb.lieux.first ?? DonneesUb.travail
    }
    static func course() -> UbCourse {
        UbEtat.partage.courses.first ?? DonneesUb.coursesPassees()[0]
    }
    static func reservation() -> UbReservation {
        UbEtat.partage.reservations.first
            ?? UbReservation(jour: "Ven. 28 août", heure: "05:40",
                             depart: "14 rue des Fantasques, 69001 Lyon",
                             arrivee: "Gare Lyon Part-Dieu",
                             categorie: "UberX", prix: 14.20, km: 4.1)
    }
    static func option() -> UbOption {
        UbTarifs.options(km: lieu().km).first
            ?? UbOption(nom: "UberX", capacite: 4, prix: 14.20, arrivee: "20:00",
                        duree: "14 min", accroche: "Économique, rapide et fiable",
                        rapide: false, symbole: "car.fill")
    }
    static func message() -> UbMessage {
        UbEtat.partage.messages.first
            ?? UbMessage(titre: "Uber", date: "11 août 2026", corps: "", lu: true)
    }
    static var ongletDemande: Int {
        Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "0") ?? 0
    }
}

/// Enveloppe de capture d'un écran POUSSÉ : dans le jeu la BarreHome est portée par
/// `UberVue` (hors NavigationStack). En capture isolée, cette enveloppe la restitue.
struct UbEcranCapture<Contenu: View>: View {
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack { contenu() }
                .tint(UbTeinte.noir)
            BarreHome { }
        }
        .background(UbTeinte.fond)
    }
}

// ============================================================ CARTES DESSINÉES (pas de MapKit)
// Générateur pseudo-aléatoire déterministe : la même graine redonne toujours la même carte,
// donc les captures du pipeline Miroir sont stables d'une exécution à l'autre.
struct UbAlea {
    private var etat: UInt64
    init(_ graine: UInt64) {
        etat = graine &* 2862933555777941757 &+ 3037000493
    }
    mutating func suivant() -> CGFloat {
        etat = etat &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat((etat >> 33) & 0xFFFF) / 65535.0
    }
}

enum UbDessin {
    static func chemin(_ points: [CGPoint]) -> Path {
        var trace = Path()
        guard let debut = points.first else { return trace }
        trace.move(to: debut)
        for point in points.dropFirst() { trace.addLine(to: point) }
        return trace
    }

    /// Pâtés de maisons + fleuve + trame de rues blanches, façon carte Uber désaturée.
    static func fond(_ ctx: inout GraphicsContext, _ taille: CGSize, _ graine: UInt64) {
        var alea = UbAlea(graine)
        let largeur = taille.width
        let hauteur = taille.height
        for _ in 0..<30 {
            let x = alea.suivant() * largeur
            let y = alea.suivant() * hauteur
            let l = 24 + alea.suivant() * 78
            let h = 18 + alea.suivant() * 56
            let cadre = CGRect(x: x, y: y, width: l, height: h)
            ctx.fill(Path(roundedRect: cadre, cornerRadius: 3), with: .color(UbTeinte.carteBloc))
        }
        let biais = 0.12 + alea.suivant() * 0.14
        let fleuve = chemin([
            CGPoint(x: largeur * biais, y: -10),
            CGPoint(x: largeur * (biais + 0.06), y: hauteur * 0.42),
            CGPoint(x: largeur * (biais + 0.02), y: hauteur + 10)
        ])
        ctx.stroke(fleuve, with: .color(UbTeinte.carteEau),
                   style: StrokeStyle(lineWidth: max(16, largeur * 0.055), lineCap: .round))
        rues(&ctx, taille, graine)
    }

    private static func rues(_ ctx: inout GraphicsContext, _ taille: CGSize, _ graine: UInt64) {
        var alea = UbAlea(graine &+ 77)
        let largeur = taille.width
        let hauteur = taille.height
        for i in 0..<8 {
            let y = hauteur * (CGFloat(i) + 0.4) / 8.0
            let ecart = (alea.suivant() - 0.5) * hauteur * 0.09
            let voie = chemin([CGPoint(x: -8, y: y),
                               CGPoint(x: largeur * 0.5, y: y + ecart),
                               CGPoint(x: largeur + 8, y: y - ecart * 0.6)])
            ctx.stroke(voie, with: .color(Color.white),
                       style: StrokeStyle(lineWidth: i % 3 == 0 ? 7 : 4, lineCap: .round))
        }
        for i in 0..<7 {
            let x = largeur * (CGFloat(i) + 0.35) / 7.0
            let ecart = (alea.suivant() - 0.5) * largeur * 0.08
            let voie = chemin([CGPoint(x: x, y: -8),
                               CGPoint(x: x + ecart, y: hauteur * 0.55),
                               CGPoint(x: x - ecart * 0.5, y: hauteur + 8)])
            ctx.stroke(voie, with: .color(Color.white),
                       style: StrokeStyle(lineWidth: i % 3 == 1 ? 7 : 4, lineCap: .round))
        }
    }

    /// Itinéraire noir + pastille ronde de départ et carré d'arrivée (e004 / e017).
    static func trace(_ ctx: inout GraphicsContext, _ taille: CGSize, _ graine: UInt64) {
        var alea = UbAlea(graine &+ 401)
        let largeur = taille.width
        let hauteur = taille.height
        let depart = CGPoint(x: largeur * 0.20, y: hauteur * 0.74)
        let arrivee = CGPoint(x: largeur * 0.82, y: hauteur * 0.26)
        var points: [CGPoint] = [depart]
        for i in 1...5 {
            let part = CGFloat(i) / 6.0
            let x = depart.x + (arrivee.x - depart.x) * part
            let y = depart.y + (arrivee.y - depart.y) * part + (alea.suivant() - 0.5) * hauteur * 0.18
            points.append(CGPoint(x: x, y: min(max(y, hauteur * 0.08), hauteur * 0.92)))
        }
        points.append(arrivee)
        let route = chemin(points)
        ctx.stroke(route, with: .color(Color.white),
                   style: StrokeStyle(lineWidth: 11, lineCap: .round, lineJoin: .round))
        ctx.stroke(route, with: .color(UbTeinte.noir),
                   style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
        let rond = CGRect(x: depart.x - 8, y: depart.y - 8, width: 16, height: 16)
        ctx.fill(Path(ellipseIn: rond.insetBy(dx: -3, dy: -3)), with: .color(Color.white))
        ctx.fill(Path(ellipseIn: rond), with: .color(UbTeinte.noir))
        let carre = CGRect(x: arrivee.x - 8, y: arrivee.y - 8, width: 16, height: 16)
        ctx.fill(Path(roundedRect: carre.insetBy(dx: -3, dy: -3), cornerRadius: 5),
                 with: .color(Color.white))
        ctx.fill(Path(roundedRect: carre, cornerRadius: 3), with: .color(UbTeinte.noir))
    }
}

struct UbCarteVue: View {
    var graine: UInt64 = 11
    var itineraire: Bool = true

    var body: some View {
        Canvas { contexte, taille in
            UbDessin.fond(&contexte, taille, graine)
            if itineraire {
                UbDessin.trace(&contexte, taille, graine)
            }
        }
        .background(UbTeinte.carteFond)
        .clipped()
        .accessibilityHidden(true)
    }
}

// ============================================================ BRIQUES VISUELLES

/// Barre de titre des écrans poussés : chevron de retour à gauche (e022 / e029).
struct UbBarreTitre: View {
    var titre: String = ""
    var gros: Bool = false
    @Environment(\.dismiss) private var revenir

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    revenir()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(UbTeinte.texte)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if !gros && !titre.isEmpty {
                    Spacer()
                    Text(titre)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(UbTeinte.texte)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
            }
            if gros && !titre.isEmpty {
                Text(titre)
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(UbTeinte.texte)
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 10)
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}

/// Bouton rond blanc posé sur la carte (e004 / e039).
struct UbRetourRond: View {
    @Environment(\.dismiss) private var revenir
    var body: some View {
        Button {
            revenir()
        } label: {
            Circle()
                .fill(Color.white)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(UbTeinte.texte)
                }
                .shadow(color: Color.black.opacity(0.14), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }
}

/// Bouton noir pleine largeur (e004 « Choisissez UberX », e022 « Continuer »).
struct UbBoutonNoir: View {
    let titre: String
    var actif: Bool = true
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(titre)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(actif ? UbTeinte.noir : Color(hex: 0xB4B4B4))
                }
        }
        .buttonStyle(.plain)
        .disabled(!actif)
    }
}

/// Grand titre d'onglet : « Activité », « Services » (e038 / e045).
struct UbGrandTitre: View {
    let texte: String
    var body: some View {
        Text(texte)
            .font(.system(size: 31, weight: .bold))
            .foregroundStyle(UbTeinte.texte)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 6)
    }
}

/// Titre de section : « Pour vous », « Passées » (e001 / e046).
struct UbTitreSection: View {
    let texte: String
    var chevron: Bool = false
    var body: some View {
        HStack(spacing: 6) {
            Text(texte)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(UbTeinte.texte)
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(UbTeinte.gris)
                    .frame(width: 18, height: 18)
                    .background { Circle().fill(UbTeinte.tuile) }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 22)
        .padding(.bottom, 10)
    }
}

/// Pilule grise à pictogramme : « Prise en charge immédiate », « Pour moi » (e002).
struct UbPilule: View {
    let systeme: String
    let texte: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systeme)
                .font(.system(size: 14, weight: .medium))
            Text(texte)
                .font(.system(size: 15, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(UbTeinte.texte)
        .padding(.horizontal, 14)
        .frame(height: 40)
        .background { Capsule().fill(UbTeinte.tuile) }
    }
}

/// Rangée de lieu proposée à la saisie (e002) : distance à gauche, nom, détail.
struct UbLigneLieu: View {
    let lieu: UbLieu
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(spacing: 3) {
                Image(systemName: lieu.symbole)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(UbTeinte.texte)
                if lieu.km > 0 {
                    Text(lieu.distance)
                        .font(.system(size: 10))
                        .foregroundStyle(UbTeinte.grisClair)
                }
            }
            .frame(width: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(lieu.nom)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(UbTeinte.texte)
                    .multilineTextAlignment(.leading)
                Text(lieu.detail)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }
            Spacer(minLength: 6)
        }
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

/// Rangée de réglage / de compte (e052).
struct UbLigneListe: View {
    let systeme: String
    let titre: String
    var detail: String = ""
    var valeur: String = ""
    var badge: String = ""
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systeme)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(UbTeinte.texte)
                .frame(width: 26, alignment: .leading)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 3) {
                Text(titre)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(UbTeinte.texte)
                    .multilineTextAlignment(.leading)
                if !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 13))
                        .foregroundStyle(UbTeinte.gris)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer(minLength: 8)
            if !valeur.isEmpty {
                Text(valeur)
                    .font(.system(size: 15))
                    .foregroundStyle(UbTeinte.gris)
            }
            if !badge.isEmpty {
                Text(badge)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 9)
                    .frame(height: 24)
                    .background { RoundedRectangle(cornerRadius: 5).fill(UbTeinte.bleu) }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}

/// Vignette carrée d'un restaurant / d'une commande : pas de photo embarquée, une tuile
/// colorée à emoji (les visuels des frames appartiennent aux enseignes de Joachim — D59).
struct UbVignette: View {
    let emoji: String
    let teinte: UInt
    var largeur: CGFloat = 56
    var hauteur: CGFloat = 56
    var coin: CGFloat = 10
    var body: some View {
        RoundedRectangle(cornerRadius: coin, style: .continuous)
            .fill(
                LinearGradient(colors: [Color(hex: teinte).opacity(0.92), Color(hex: teinte).opacity(0.62)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .frame(width: largeur, height: hauteur)
            .overlay {
                Text(emoji)
                    .font(.system(size: min(largeur, hauteur) * 0.44))
            }
    }
}

/// Séparateur fin des listes (e047).
struct UbTrait: View {
    var marge: CGFloat = 16
    var body: some View {
        Rectangle()
            .fill(Color(hex: 0xEBEBEB))
            .frame(height: 1)
            .padding(.leading, marge)
    }
}

// ============================================================ RACINE

struct UberVue: View {
    @Environment(\.dismiss) private var quitter
    @State private var onglet: Int

    init(onglet: Int = 0) {
        _onglet = State(initialValue: onglet)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    UbTeinte.fond.ignoresSafeArea()
                    contenuOnglet
                    UbBarreOnglets(onglet: $onglet)
                }
                .toolbar(.hidden, for: .navigationBar)
            }
            .tint(UbTeinte.noir)
            BarreHome { quitter() }
        }
        .background(UbTeinte.fond)
    }

    @ViewBuilder
    private var contenuOnglet: some View {
        switch onglet {
        case 1: UbServicesVue()
        case 2: UbActiviteVue()
        case 3: UbCompteVue()
        default: UbAccueilVue()
        }
    }
}

/// Barre d'onglets flottante en capsule blanche (e001 / e045) — posée au-dessus de BarreHome.
struct UbBarreOnglets: View {
    @Binding var onglet: Int
    private let items: [(String, String)] = [
        ("Accueil", "house"),
        ("Services", "square.grid.3x3.fill"),
        ("Activité", "bookmark"),
        ("Compte", "person.crop.circle")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { paire in
                bouton(index: paire.offset, titre: paire.element.0, systeme: paire.element.1)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.14), radius: 10, y: 3)
        }
        .padding(.horizontal, 44)
        .padding(.bottom, 22)
    }

    private func bouton(index: Int, titre: String, systeme: String) -> some View {
        Button {
            onglet = index
        } label: {
            VStack(spacing: 3) {
                Image(systemName: systeme)
                    .font(.system(size: 18,
                                  weight: onglet == index ? Font.Weight.semibold : Font.Weight.regular))
                Text(titre)
                    .font(.system(size: 11,
                                  weight: onglet == index ? Font.Weight.semibold : Font.Weight.regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(onglet == index ? UbTeinte.texte : UbTeinte.gris)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background {
                Capsule().fill(onglet == index ? UbTeinte.tuile : Color.white)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================ ONGLET 1 — ACCUEIL (e001 / e030 / e034)

struct UbAccueilVue: View {
    @ObservedObject private var etat = UbEtat.partage
    @State private var volet = 0                    // 0 = Uber, 1 = Uber Eats
    @State private var alerteEats = false

    var body: some View {
        VStack(spacing: 0) {
            UbVoletsHaut(volet: $volet)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if volet == 0 {
                        blocCourses
                    }
                    blocEats
                    Spacer(minLength: 110)
                }
            }
        }
        .alert("Uber Eats indisponible dans cette zone pour le moment",
               isPresented: $alerteEats) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Aucun restaurant ne livre à l'adresse 14 rue des Fantasques ce soir. Réessayez plus tard.")
        }
    }

    // --- Partie « course » : recherche, adresses récentes, raccourcis
    @ViewBuilder
    private var blocCourses: some View {
        UbChampDestination()
        UbCarteRecents(recents: DonneesUb.recents)
        UbTitreSection(texte: "Pour vous", chevron: false)
        UbPourVous(surRepas: { alerteEats = true })
    }

    // --- Partie « Uber Eats » : conservée en structure (e001/e034), sans commande possible
    @ViewBuilder
    private var blocEats: some View {
        UbTitreSection(texte: "Passez commande sur Uber Eats")
        UbBandeEats(surTap: { alerteEats = true })
        UbTitreSection(texte: "Commandez à nouveau")
        VStack(spacing: 0) {
            ForEach(etat.commandes) { commande in
                UbLigneCommande(commande: commande, surCommander: { alerteEats = true })
                UbTrait(marge: 86)
            }
        }
    }
}

/// Sélecteur haut « Uber / Uber Eats » (e001). L'onglet « Courses » des frames est retiré
/// (aucun contenu de courses alimentaires n'existe ici — D82-C, listé dans la livraison).
struct UbVoletsHaut: View {
    @Binding var volet: Int
    private let items: [(String, String)] = [("Uber", "car.fill"), ("Uber Eats", "takeoutbag.and.cup.and.straw.fill")]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 26) {
                ForEach(Array(items.enumerated()), id: \.offset) { paire in
                    Button {
                        volet = paire.offset
                    } label: {
                        VStack(spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: paire.element.1)
                                    .font(.system(size: 17))
                                Text(paire.element.0)
                                    .font(.system(size: 21,
                                                  weight: volet == paire.offset ? Font.Weight.bold : Font.Weight.regular))
                            }
                            .foregroundStyle(volet == paire.offset ? UbTeinte.texte : UbTeinte.gris)
                            Rectangle()
                                .fill(volet == paire.offset ? UbTeinte.noir : Color.clear)
                                .frame(height: 2)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            Rectangle().fill(Color(hex: 0xEEEEEE)).frame(height: 1)
        }
    }
}

/// Champ « Où allez-vous ? » + pilule « Plus tard » (e001).
struct UbChampDestination: View {
    var body: some View {
        HStack(spacing: 10) {
            NavigationLink {
                UbDestinationVue(quand: "")
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(UbTeinte.texte)
                    Text("Où allez-vous ?")
                        .font(.system(size: 17))
                        .foregroundStyle(UbTeinte.texte)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            NavigationLink {
                UbHeureVue(destination: nil)
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .medium))
                    Text("Plus tard")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(UbTeinte.texte)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background { Capsule().fill(UbTeinte.tuile) }
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 20)
        .padding(.trailing, 8)
        .frame(height: 62)
        .background {
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.10), radius: 8, y: 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }
}

/// Carte des deux adresses récentes (e001) — tap = écran de choix de course.
struct UbCarteRecents: View {
    let recents: [UbLieu]
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(recents.enumerated()), id: \.element.id) { paire in
                NavigationLink {
                    UbCoursesVue(destination: paire.element, quand: "")
                } label: {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(UbTeinte.tuile)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "clock")
                                    .font(.system(size: 17))
                                    .foregroundStyle(UbTeinte.texte)
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(paire.element.nom)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(UbTeinte.texte)
                            Text(paire.element.detail)
                                .font(.system(size: 14))
                                .foregroundStyle(UbTeinte.gris)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 6)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(UbTeinte.grisClair)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if paire.offset < recents.count - 1 {
                    UbTrait(marge: 68)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UbTeinte.bord, lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }
}

/// Rangée « Pour vous » (e001) — Course / Réserver / Repas. Location, Alcool, Seniors et
/// Teens sont retirés : rien derrière eux ne pouvait exister (D82-C).
struct UbPourVous: View {
    let surRepas: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            NavigationLink {
                UbDestinationVue(quand: "")
            } label: {
                UbPastilleService(systeme: "car.fill", titre: "Course", promo: false)
            }
            .buttonStyle(.plain)
            NavigationLink {
                UbReserveVue()
            } label: {
                UbPastilleService(systeme: "calendar", titre: "Réserver", promo: false)
            }
            .buttonStyle(.plain)
            Button(action: surRepas) {
                UbPastilleService(systeme: "fork.knife", titre: "Repas", promo: true)
            }
            .buttonStyle(.plain)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
    }
}

struct UbPastilleService: View {
    let systeme: String
    let titre: String
    let promo: Bool
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(UbTeinte.tuile)
                .frame(width: 84, height: 84)
                .overlay {
                    Image(systemName: systeme)
                        .font(.system(size: 30))
                        .foregroundStyle(UbTeinte.texte)
                }
                .overlay(alignment: .top) {
                    if promo {
                        Text("Promo")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 8)
                            .frame(height: 22)
                            .background { RoundedRectangle(cornerRadius: 5).fill(UbTeinte.rouge) }
                            .offset(y: -8)
                    }
                }
            Text(titre)
                .font(.system(size: 14))
                .foregroundStyle(UbTeinte.texte)
        }
        .frame(width: 84)
        .contentShape(Rectangle())
    }
}

/// Bande horizontale de restaurants (e001/e034) — mêmes gabarits, enseignes lyonnaises.
struct UbBandeEats: View {
    let surTap: () -> Void
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                ForEach(Array(DonneesUb.restaurants.enumerated()), id: \.offset) { paire in
                    Button(action: surTap) {
                        VStack(alignment: .leading, spacing: 7) {
                            UbVignette(emoji: paire.element.3, teinte: paire.element.4,
                                       largeur: 276, hauteur: 150, coin: 12)
                            Text(paire.element.0)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(UbTeinte.texte)
                            Text(paire.element.1)
                                .font(.system(size: 14))
                                .foregroundStyle(UbTeinte.gris)
                            Text(paire.element.2)
                                .font(.system(size: 14))
                                .foregroundStyle(UbTeinte.gris)
                        }
                        .frame(width: 276, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct UbLigneCommande: View {
    let commande: UbCommandeEats
    let surCommander: () -> Void
    var body: some View {
        HStack(spacing: 14) {
            UbVignette(emoji: commande.emoji, teinte: commande.teinte)
            VStack(alignment: .leading, spacing: 3) {
                Text(commande.enseigne)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(UbTeinte.texte)
                Text(commande.date + " • " + commande.heure)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                Text(UbFormat.euro(commande.montant) + " • \(commande.articles) article"
                     + (commande.articles > 1 ? "s" : ""))
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
            }
            Spacer(minLength: 6)
            Button(action: surCommander) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Commander")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(UbTeinte.texte)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background { Capsule().fill(UbTeinte.tuileVive) }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// ============================================================ ONGLET 2 — SERVICES (e038 / e044)

struct UbServicesVue: View {
    @State private var alerteEats = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                UbGrandTitre(texte: "Services")
                UbTitreSection(texte: "Allez n'importe où")
                HStack(spacing: 14) {
                    NavigationLink {
                        UbDestinationVue(quand: "")
                    } label: {
                        UbTuileService(systeme: "car.fill", titre: "Course", hauteur: 120)
                    }
                    .buttonStyle(.plain)
                    NavigationLink {
                        UbReserveVue()
                    } label: {
                        UbTuileService(systeme: "calendar", titre: "Réserver", hauteur: 120)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                Rectangle().fill(UbTeinte.tuile).frame(height: 6).padding(.top, 24)
                UbTitreSection(texte: "Faites-vous livrer ce que vous voulez")
                HStack(spacing: 14) {
                    Button { alerteEats = true } label: {
                        UbTuileService(systeme: "fork.knife", titre: "Repas", hauteur: 120)
                    }
                    .buttonStyle(.plain)
                    Button { alerteEats = true } label: {
                        UbTuileService(systeme: "wineglass.fill", titre: "Alcool", hauteur: 120)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 130)
            }
        }
        .alert("Uber Eats indisponible dans cette zone pour le moment",
               isPresented: $alerteEats) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Aucun commerce ne livre à l'adresse 14 rue des Fantasques ce soir. Réessayez plus tard.")
        }
    }
}

struct UbTuileService: View {
    let systeme: String
    let titre: String
    var hauteur: CGFloat = 120
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(UbTeinte.tuile)
            Image(systemName: systeme)
                .font(.system(size: 34))
                .foregroundStyle(UbTeinte.texte.opacity(0.82))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)
                .padding(.bottom, 30)
            Text(titre)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(UbTeinte.texte)
                .padding(.leading, 14)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: hauteur)
        .contentShape(Rectangle())
    }
}

// ============================================================ SAISIE DE DESTINATION (e002 / e026 / e029)

struct UbDestinationVue: View {
    let quand: String                        // "" = prise en charge immédiate
    @State private var saisie = ""
    @FocusState private var focusDestination: Bool

    private var suggestions: [UbLieu] {
        let requete = UbRecherche.normaliser(saisie)
        if requete.isEmpty { return DonneesUb.lieux }
        return DonneesUb.lieux.filter {
            UbRecherche.normaliser($0.nom).contains(requete)
                || UbRecherche.normaliser($0.detail).contains(requete)
        }
    }

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Planifiez votre course")
                pilules
                champs
                raccourcis
                liste
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { focusDestination = true }
    }

    private var pilules: some View {
        HStack(spacing: 10) {
            UbPilule(systeme: "clock",
                     texte: quand.isEmpty ? "Prise en charge immédiate" : quand)
            UbPilule(systeme: "person", texte: "Pour moi")
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }

    private var champs: some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    UbJalon(carre: false)
                    Text(DonneesUb.domicile.detail)
                        .font(.system(size: 16))
                        .foregroundStyle(UbTeinte.texte)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .frame(height: 44)
                Rectangle().fill(UbTeinte.bord).frame(height: 1).padding(.leading, 34)
                HStack(spacing: 12) {
                    UbJalon(carre: true)
                    TextField("Où allez-vous ?", text: $saisie)
                        .font(.system(size: 16))
                        .foregroundStyle(UbTeinte.texte)
                        .autocorrectionDisabled(true)
                        .focused($focusDestination)
                    Spacer(minLength: 0)
                }
                .frame(height: 44)
            }
            .padding(.horizontal, 14)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(UbTeinte.noir, lineWidth: 2)
            }
        }
        .padding(.horizontal, 16)
    }

    // Sarah a déjà enregistré son domicile et son travail : les pastilles « Ajoutez… » des
    // frames deviennent deux raccourcis qui mènent réellement à la course (D59).
    private var raccourcis: some View {
        HStack(spacing: 10) {
            NavigationLink {
                UbCoursesVue(destination: DonneesUb.travail, quand: quand)
            } label: {
                UbRaccourci(systeme: "briefcase", titre: "Travail")
            }
            .buttonStyle(.plain)
            NavigationLink {
                UbCoursesVue(destination: DonneesUb.lieux[2], quand: quand)
            } label: {
                UbRaccourci(systeme: "star", titre: "Chez Chloé")
            }
            .buttonStyle(.plain)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 4)
    }

    private var liste: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(suggestions) { lieu in
                    NavigationLink {
                        UbCoursesVue(destination: lieu, quand: quand)
                    } label: {
                        UbLigneLieu(lieu: lieu)
                    }
                    .buttonStyle(.plain)
                    UbTrait(marge: 58)
                }
                if suggestions.isEmpty {
                    Text("Aucun lieu ne correspond à « \(saisie) ».")
                        .font(.system(size: 15))
                        .foregroundStyle(UbTeinte.gris)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                }
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16)
        }
    }
}

enum UbRecherche {
    static func normaliser(_ texte: String) -> String {
        texte.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
            .trimmingCharacters(in: .whitespaces)
    }
}

/// Pastille de départ (ronde) / d'arrivée (carrée) du champ d'itinéraire (e002).
struct UbJalon: View {
    let carre: Bool
    var body: some View {
        ZStack {
            Circle()
                .fill(UbTeinte.noir)
                .frame(width: 22, height: 22)
            if carre {
                RoundedRectangle(cornerRadius: 1.5).fill(Color.white).frame(width: 8, height: 8)
            } else {
                Circle().fill(Color.white).frame(width: 8, height: 8)
            }
        }
        .frame(width: 22)
    }
}

struct UbRaccourci: View {
    let systeme: String
    let titre: String
    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: systeme)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(UbTeinte.bleu)
                .frame(width: 28, height: 28)
                .background { RoundedRectangle(cornerRadius: 7).fill(UbTeinte.bleuClair) }
            Text(titre)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(UbTeinte.texte)
        }
        .padding(.horizontal, 10)
        .frame(height: 44)
        .background { Capsule().stroke(UbTeinte.bord, lineWidth: 1) }
        .contentShape(Rectangle())
    }
}

// ============================================================ CHOIX DE LA COURSE (e004 … e013)

struct UbCoursesVue: View {
    let destination: UbLieu
    let quand: String
    @Environment(\.dismiss) private var revenir
    @ObservedObject private var etat = UbEtat.partage
    @State private var choix = 0
    @State private var reservee = false

    private var options: [UbOption] { UbTarifs.options(km: destination.km) }
    private var selection: UbOption { options[min(choix, options.count - 1)] }
    private var reservation: Bool { !quand.isEmpty }

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                carte
                feuille
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("Course réservée", isPresented: $reservee) {
            Button("OK") { revenir() }
        } message: {
            Text("Votre \(selection.nom) du \(quand) est enregistré. Retrouvez-le dans Activité, section À venir.")
        }
    }

    private var carte: some View {
        ZStack(alignment: .top) {
            UbCarteVue(graine: UInt64(destination.nom.count * 13 + 7), itineraire: true)
            HStack(alignment: .top, spacing: 10) {
                UbRetourRond()
                Spacer(minLength: 0)
                UbPastilleDestination(destination: destination,
                                      minutes: UbTarifs.minutesTrajet(destination.km))
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var feuille: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color(hex: 0xD9D9D9)).frame(width: 40, height: 5).padding(.top, 8)
            bandeauCredit
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(options.enumerated()), id: \.element.id) { paire in
                        Button {
                            choix = paire.offset
                        } label: {
                            UbLigneOption(option: paire.element, choisie: choix == paire.offset)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 6)
            }
            .frame(maxHeight: 300)
            ligneApplePay
            barreAction
        }
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 0,
                                   bottomTrailingRadius: 0, topTrailingRadius: 14,
                                   style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 8, y: -3)
        }
    }

    private var bandeauCredit: some View {
        HStack(spacing: 7) {
            Image(systemName: "u.circle.fill")
                .font(.system(size: 15))
                .foregroundStyle(UbTeinte.rouge)
            Text("Générez 5 % en crédit")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(UbTeinte.rouge)
            Image(systemName: "info.circle")
                .font(.system(size: 13))
                .foregroundStyle(UbTeinte.grisClair)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color(hex: 0xEEEEEE)).frame(height: 1)
        }
    }

    private var ligneApplePay: some View {
        NavigationLink {
            UbWalletVue()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "applelogo")
                    .font(.system(size: 13))
                    .foregroundStyle(UbTeinte.texte)
                    .frame(width: 34, height: 24)
                    .background { RoundedRectangle(cornerRadius: 4).stroke(UbTeinte.bord, lineWidth: 1) }
                Text("Apple Pay")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(UbTeinte.texte)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(UbTeinte.grisClair)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            Rectangle().fill(Color(hex: 0xEEEEEE)).frame(height: 1)
        }
    }

    @ViewBuilder
    private var barreAction: some View {
        HStack(spacing: 12) {
            if reservation {
                UbBoutonNoir(titre: "Réservez \(selection.nom)") {
                    let morceaux = quand.components(separatedBy: ", ")
                    etat.reserver(vers: destination,
                                  jour: morceaux.first ?? quand,
                                  heure: morceaux.count > 1 ? morceaux[1] : "",
                                  categorie: selection.nom, prix: selection.prix)
                    reservee = true
                }
            } else {
                NavigationLink {
                    UbConfirmationVue(destination: destination, option: selection)
                } label: {
                    Text("Choisissez \(selection.nom)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(UbTeinte.noir)
                        }
                }
                .buttonStyle(.plain)
                NavigationLink {
                    UbHeureVue(destination: destination)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 19))
                        .foregroundStyle(UbTeinte.texte)
                        .frame(width: 58, height: 54)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(UbTeinte.tuile)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 30)
    }
}

/// Pilule noire « 16 MIN » + adresse, posée sur la carte (e004).
struct UbPastilleDestination: View {
    let destination: UbLieu
    let minutes: Int
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: -2) {
                Text("\(minutes)")
                    .font(.system(size: 15, weight: .semibold))
                Text("MIN")
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundStyle(Color.white)
            .frame(width: 46, height: 48)
            .background(UbTeinte.noir)
            VStack(alignment: .leading, spacing: 1) {
                Text(destination.nom)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(UbTeinte.texte)
                    .lineLimit(1)
                Text(destination.detail)
                    .font(.system(size: 13))
                    .foregroundStyle(UbTeinte.gris)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: 190, alignment: .leading)
        }
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color.black.opacity(0.14), radius: 5, y: 2)
    }
}

struct UbLigneOption: View {
    let option: UbOption
    let choisie: Bool
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: option.symbole)
                .font(.system(size: 25))
                .foregroundStyle(UbTeinte.texte)
                .frame(width: 62)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(option.nom)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(UbTeinte.texte)
                    Image(systemName: "person.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(UbTeinte.gris)
                    Text("\(option.capacite)")
                        .font(.system(size: 13))
                        .foregroundStyle(UbTeinte.gris)
                }
                Text(option.arrivee + " · " + option.duree)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                Text(option.accroche)
                    .font(.system(size: 13))
                    .foregroundStyle(UbTeinte.grisClair)
                    .multilineTextAlignment(.leading)
                if option.rapide {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill").font(.system(size: 10))
                        Text("Plus rapide").font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 9)
                    .frame(height: 24)
                    .background { RoundedRectangle(cornerRadius: 5).fill(UbTeinte.bleu) }
                    .padding(.top, 2)
                }
            }
            Spacer(minLength: 6)
            HStack(spacing: 5) {
                Image(systemName: "u.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(UbTeinte.rouge)
                Text(UbFormat.euro(option.prix))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UbTeinte.texte)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(choisie ? UbTeinte.noir : Color.clear, lineWidth: 2)
        }
        .contentShape(Rectangle())
    }
}

// ==================================== CONFIRMATION DU POINT DE PRISE EN CHARGE (D93 : 21_appstore_gb)

struct UbConfirmationVue: View {
    let destination: UbLieu
    let option: UbOption
    @State private var aucunChauffeur = false

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                carte
                feuille
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("Aucun chauffeur disponible à proximité pour le moment",
               isPresented: $aucunChauffeur) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Réessayez dans quelques minutes ou choisissez une autre option de course.")
        }
    }

    private var carte: some View {
        ZStack(alignment: .top) {
            UbCarteVue(graine: 41, itineraire: false)
            VStack(spacing: 0) {
                Text("Point de prise en charge")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background { Capsule().fill(UbTeinte.bleu) }
                Rectangle().fill(UbTeinte.noir).frame(width: 3, height: 26)
                Circle()
                    .fill(UbTeinte.bleu)
                    .frame(width: 30, height: 30)
                    .overlay {
                        RoundedRectangle(cornerRadius: 2).fill(Color.white).frame(width: 11, height: 11)
                    }
            }
            .padding(.top, 92)
            HStack {
                UbRetourRond()
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var feuille: some View {
        VStack(spacing: 0) {
            VStack(spacing: 3) {
                Text("Confirmez votre point de prise en charge")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UbTeinte.texte)
                Text(option.nom + " · " + UbFormat.euro(option.prix)
                     + " · vers " + destination.nom)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            Rectangle().fill(Color(hex: 0xEEEEEE)).frame(height: 1)
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("14 rue des Fantasques")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(UbTeinte.texte)
                    Text("Retrouvez votre chauffeur devant le n° 14")
                        .font(.system(size: 14))
                        .foregroundStyle(UbTeinte.gris)
                }
                Spacer(minLength: 6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            UbBoutonNoir(titre: "Confirmer la prise en charge") {
                aucunChauffeur = true
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 0,
                                   bottomTrailingRadius: 0, topTrailingRadius: 14,
                                   style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 8, y: -3)
        }
    }
}

// ============================================================ CHOISISSEZ UNE HEURE (e022 / e042)

struct UbHeureVue: View {
    let destination: UbLieu?
    @State private var mode = 0                 // 0 = prise en charge à, 1 = dépose à
    @State private var jour = 0
    @State private var heure = 20
    @State private var minute = 6               // index dans les minutes (6 → 30)

    private let jours: [String] = [
        "Aujourd'hui", "Mar. 18 août", "Mer. 19 août", "Jeu. 20 août", "Ven. 21 août",
        "Sam. 22 août", "Dim. 23 août", "Lun. 24 août", "Mar. 25 août", "Mer. 26 août",
        "Jeu. 27 août", "Ven. 28 août", "Sam. 29 août", "Dim. 30 août"
    ]
    private let minutes: [Int] = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]

    private var trajet: Int { UbTarifs.minutesTrajet(destination?.km ?? 4.1) }
    private var horaireChoisi: String { String(format: "%02d:%02d", heure, minutes[minute]) }
    private var texteQuand: String { jours[jour] + ", " + horaireChoisi }

    private var horaireCalcule: String {
        let base = heure * 60 + minutes[minute]
        let decale = mode == 0 ? base + trajet : max(0, base - trajet)
        return String(format: "%02d:%02d", (decale / 60) % 24, decale % 60)
    }

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Choisissez une heure", gros: true)
                segment
                roues
                resume
                Spacer(minLength: 12)
                politique
                lienContinuer
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var segment: some View {
        HStack(spacing: 0) {
            ForEach(Array(["Prise en charge à", "Dépose à"].enumerated()), id: \.offset) { paire in
                Button {
                    mode = paire.offset
                } label: {
                    Text(paire.element)
                        .font(.system(size: 15,
                                      weight: mode == paire.offset ? Font.Weight.semibold : Font.Weight.regular))
                        .foregroundStyle(UbTeinte.texte)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(mode == paire.offset ? Color.white : Color.clear)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .stroke(mode == paire.offset ? UbTeinte.noir : Color.clear, lineWidth: 2)
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 11, style: .continuous).fill(UbTeinte.segment)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private var roues: some View {
        HStack(spacing: 0) {
            Picker("", selection: $jour) {
                ForEach(Array(jours.enumerated()), id: \.offset) { paire in
                    Text(paire.element).tag(paire.offset)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 180)
            .clipped()
            Picker("", selection: $heure) {
                ForEach(0..<24, id: \.self) { valeur in
                    Text("\(valeur)").tag(valeur)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            .clipped()
            Picker("", selection: $minute) {
                ForEach(Array(minutes.enumerated()), id: \.offset) { paire in
                    Text(String(format: "%02d", paire.element)).tag(paire.offset)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            .clipped()
        }
        .labelsHidden()
        .frame(height: 190)
        .padding(.top, 6)
    }

    private var resume: some View {
        VStack(spacing: 4) {
            Text((mode == 0 ? "Heure de dépose : " : "Heure de prise en charge : ")
                 + horaireCalcule + " CEST")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(UbTeinte.texte)
            Text("Trajet d'environ \(trajet) min")
                .font(.system(size: 15))
                .foregroundStyle(UbTeinte.gris)
        }
        .padding(.top, 14)
    }

    private var politique: some View {
        Text("Politique d'annulation standard d'Uber Reserve : aucuns frais d'annulation jusqu'à une heure avant la prise en charge ou à tout moment avant qu'un chauffeur ne vous soit attribué.")
            .font(.system(size: 13))
            .foregroundStyle(UbTeinte.gris)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
    }

    private var lienContinuer: some View {
        NavigationLink {
            suite
        } label: {
            Text("Continuer")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(UbTeinte.noir)
                }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var suite: some View {
        if let lieu = destination {
            UbCoursesVue(destination: lieu, quand: texteQuand)
        } else {
            UbDestinationVue(quand: texteQuand)
        }
    }
}

// ============================================================ PAGE RESERVE (e039)

struct UbReserveVue: View {
    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                illustration
                Text("Reserve")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(UbTeinte.texte)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 18)
                puce(systeme: "calendar",
                     texte: "Possibilité de choisir l'heure de prise en charge exacte jusqu'à 90 jours à l'avance")
                Rectangle().fill(Color(hex: 0xEEEEEE)).frame(height: 1)
                    .padding(.horizontal, 20)
                puce(systeme: "hourglass",
                     texte: "Le chauffeur patientera jusqu'à l'heure de prise en charge que vous aurez définie, après quoi des frais d'annulation pourront vous être facturés.")
                Spacer(minLength: 10)
                NavigationLink {
                    UbHeureVue(destination: nil)
                } label: {
                    Text("Réservez une course")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(UbTeinte.noir)
                        }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 28)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // Illustration dessinée (aucun visuel de l'app n'est embarqué) : ciel de fin de journée,
    // soleil bas, silhouette de berline — même cadrage que la bannière filmée.
    private var illustration: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(colors: [Color(hex: 0x3A2140), Color(hex: 0x8E4A3C), Color(hex: 0xE0A05E)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(Color(hex: 0xF6D6A0).opacity(0.85))
                .frame(width: 90, height: 90)
                .offset(x: -60, y: -70)
            Image(systemName: "car.side.fill")
                .font(.system(size: 78))
                .foregroundStyle(Color(hex: 0x1B2430).opacity(0.9))
                .padding(.trailing, 18)
                .padding(.bottom, 22)
        }
        .frame(height: 300)
        .clipped()
        .overlay(alignment: .topLeading) {
            UbRetourRond()
                .padding(.leading, 14)
                .padding(.top, 10)
        }
    }

    private func puce(systeme: String, texte: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systeme)
                .font(.system(size: 20))
                .foregroundStyle(UbTeinte.texte)
                .frame(width: 30)
            Text(texte)
                .font(.system(size: 16))
                .foregroundStyle(UbTeinte.texte)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// ============================================================ ONGLET 3 — ACTIVITÉ (e045 / e046 / e049)

struct UbActiviteVue: View {
    @ObservedObject private var etat = UbEtat.partage
    @State private var alerteEats = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                UbGrandTitre(texte: "Activité")
                UbTitreSection(texte: "À venir")
                aVenir
                UbTitreSection(texte: "Passées")
                passees
                Spacer(minLength: 130)
            }
        }
        .alert("Uber Eats indisponible dans cette zone pour le moment",
               isPresented: $alerteEats) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Cette commande ne peut pas être renouvelée pour le moment.")
        }
    }

    @ViewBuilder
    private var aVenir: some View {
        if etat.reservations.isEmpty {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Vous n'avez aucune course planifiée.")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(UbTeinte.texte)
                        .multilineTextAlignment(.leading)
                    NavigationLink {
                        UbReserveVue()
                    } label: {
                        HStack(spacing: 6) {
                            Text("Réservez votre course")
                                .font(.system(size: 15))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(UbTeinte.texte)
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 6)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 30))
                    .foregroundStyle(UbTeinte.gris)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(UbTeinte.bord, lineWidth: 1)
            }
            .padding(.horizontal, 16)
        } else {
            VStack(spacing: 12) {
                ForEach(etat.reservations) { reservation in
                    NavigationLink {
                        UbReservationVue(reservation: reservation)
                    } label: {
                        UbCarteReservation(reservation: reservation)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var passees: some View {
        VStack(spacing: 0) {
            ForEach(etat.courses) { course in
                NavigationLink {
                    UbCourseVue(course: course)
                } label: {
                    UbLigneCourse(course: course)
                }
                .buttonStyle(.plain)
                UbTrait(marge: 86)
            }
            ForEach(etat.commandes) { commande in
                UbLigneCommande(commande: commande, surCommander: { alerteEats = true })
                UbTrait(marge: 86)
            }
        }
    }
}

struct UbCarteReservation: View {
    let reservation: UbReservation
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 2) {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundStyle(UbTeinte.texte)
            }
            .frame(width: 44, height: 44)
            .background { Circle().fill(UbTeinte.tuile) }
            VStack(alignment: .leading, spacing: 3) {
                Text(reservation.jour + " · " + reservation.heure)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(UbTeinte.texte)
                Text(reservation.depart)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                    .lineLimit(1)
                Text("→ " + reservation.arrivee)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                    .lineLimit(1)
                Text(reservation.categorie + " · env. " + UbFormat.euro(reservation.prix))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(UbTeinte.texte)
                    .padding(.top, 2)
            }
            Spacer(minLength: 6)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(UbTeinte.grisClair)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(UbTeinte.bord, lineWidth: 1)
        }
        .contentShape(Rectangle())
    }
}

struct UbLigneCourse: View {
    let course: UbCourse
    var body: some View {
        HStack(spacing: 14) {
            UbCarteVue(graine: course.graine, itineraire: true)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(course.arrivee)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(UbTeinte.texte)
                    .lineLimit(1)
                Text(course.date + " • " + course.heure)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                Text(UbFormat.euro(course.prix) + " • " + course.categorie)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
            }
            Spacer(minLength: 6)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(UbTeinte.grisClair)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// ------------------------------------------------------------ Détail d'une réservation

struct UbReservationVue: View {
    let reservation: UbReservation
    @Environment(\.dismiss) private var revenir
    @ObservedObject private var etat = UbEtat.partage
    @State private var demandeAnnulation = false

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Course planifiée")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        UbCarteVue(graine: 61, itineraire: true)
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.horizontal, 16)
                        entete
                        UbTrajet(depart: reservation.depart, arrivee: reservation.arrivee,
                                 heureDepart: reservation.heure, heureArrivee: "")
                        UbBlocInfo(titre: "Type de course", valeur: reservation.categorie)
                        UbBlocInfo(titre: "Prix estimé", valeur: UbFormat.euro(reservation.prix))
                        UbBlocInfo(titre: "Moyen de paiement", valeur: "Visa LCL •••• 4417")
                        Spacer(minLength: 20)
                    }
                }
                Button {
                    demandeAnnulation = true
                } label: {
                    Text("Annuler la réservation")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(UbTeinte.texte)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(UbTeinte.noir, lineWidth: 1.5)
                        }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 28)
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("Annuler cette réservation ?", isPresented: $demandeAnnulation) {
            Button("Conserver", role: .cancel) { }
            Button("Annuler la course", role: .destructive) {
                etat.annuler(reservation)
                revenir()
            }
        } message: {
            Text("La course du \(reservation.jour) à \(reservation.heure) sera définitivement supprimée. Aucun frais ne vous sera facturé.")
        }
    }

    private var entete: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(reservation.jour + " · " + reservation.heure)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(UbTeinte.texte)
            Text("Prise en charge garantie — Uber Reserve")
                .font(.system(size: 15))
                .foregroundStyle(UbTeinte.gris)
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 6)
    }
}

// ------------------------------------------------------------ Détail d'une course passée

struct UbCourseVue: View {
    let course: UbCourse
    @State private var aide = false

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Détails de la course")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        UbCarteVue(graine: course.graine, itineraire: true)
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.horizontal, 16)
                        entete
                        UbTrajet(depart: course.depart + ", " + course.departDetail,
                                 arrivee: course.arrivee + ", " + course.arriveeDetail,
                                 heureDepart: course.heure, heureArrivee: "")
                        chauffeur
                        recu
                        boutonAide
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("Signalement enregistré", isPresented: $aide) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Notre équipe revient vers vous à l'adresse \(DonneesUb.email) sous 48 heures au sujet de la course du \(course.date).")
        }
    }

    private var entete: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(UbFormat.euro(course.prix))
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(UbTeinte.texte)
            Text(course.date + " • " + course.heure + " • " + course.duree)
                .font(.system(size: 15))
                .foregroundStyle(UbTeinte.gris)
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 6)
    }

    private var chauffeur: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(UbTeinte.tuile)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 21))
                        .foregroundStyle(UbTeinte.gris)
                }
            VStack(alignment: .leading, spacing: 3) {
                Text(course.chauffeur)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(UbTeinte.texte)
                Text(course.vehicule + " · " + course.plaque)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
            }
            Spacer(minLength: 6)
            HStack(spacing: 4) {
                Image(systemName: "star.fill").font(.system(size: 12))
                Text(course.noteChauffeur).font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(UbTeinte.texte)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .overlay(alignment: .top) {
            Rectangle().fill(Color(hex: 0xEEEEEE)).frame(height: 1).padding(.horizontal, 16)
        }
    }

    private var recu: some View {
        VStack(spacing: 0) {
            UbLigneRecu(cle: "Prix de la course \(course.categorie)",
                        valeur: UbFormat.euro(course.prix - 1.20))
            UbLigneRecu(cle: "Frais de réservation", valeur: UbFormat.euro(1.20))
            UbLigneRecu(cle: "Total", valeur: UbFormat.euro(course.prix), fort: true)
            UbLigneRecu(cle: "Payé avec", valeur: "Visa LCL •••• 4417")
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    private var boutonAide: some View {
        Button {
            aide = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 19))
                Text("Obtenir de l'aide")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(UbTeinte.grisClair)
            }
            .foregroundStyle(UbTeinte.texte)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            Rectangle().fill(Color(hex: 0xEEEEEE)).frame(height: 1).padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }
}

/// Colonne départ → arrivée avec jalons (même dessin que le champ d'itinéraire, e002).
struct UbTrajet: View {
    let depart: String
    let arrivee: String
    let heureDepart: String
    let heureArrivee: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                UbJalon(carre: false)
                Rectangle().fill(UbTeinte.bord).frame(width: 2, height: 34)
                UbJalon(carre: true)
            }
            .padding(.top, 3)
            VStack(alignment: .leading, spacing: 0) {
                ligne(texte: depart, heure: heureDepart)
                Spacer(minLength: 12)
                ligne(texte: arrivee, heure: heureArrivee)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func ligne(texte: String, heure: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(texte)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(UbTeinte.texte)
                .multilineTextAlignment(.leading)
            if !heure.isEmpty {
                Text(heure)
                    .font(.system(size: 13))
                    .foregroundStyle(UbTeinte.gris)
            }
        }
        .frame(height: 40, alignment: .top)
    }
}

struct UbBlocInfo: View {
    let titre: String
    let valeur: String
    var body: some View {
        HStack {
            Text(titre)
                .font(.system(size: 15))
                .foregroundStyle(UbTeinte.gris)
            Spacer(minLength: 10)
            Text(valeur)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(UbTeinte.texte)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .top) {
            Rectangle().fill(Color(hex: 0xEEEEEE)).frame(height: 1).padding(.horizontal, 16)
        }
    }
}

struct UbLigneRecu: View {
    let cle: String
    let valeur: String
    var fort: Bool = false
    var body: some View {
        HStack {
            Text(cle)
                .font(.system(size: 15, weight: fort ? Font.Weight.semibold : Font.Weight.regular))
                .foregroundStyle(fort ? UbTeinte.texte : UbTeinte.gris)
            Spacer(minLength: 10)
            Text(valeur)
                .font(.system(size: 15, weight: fort ? Font.Weight.bold : Font.Weight.medium))
                .foregroundStyle(UbTeinte.texte)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .top) {
            Rectangle().fill(Color(hex: 0xF2F2F2)).frame(height: 1)
        }
    }
}

// ============================================================ ONGLET 4 — COMPTE (e050 / e051 / e052)

struct UbCompteVue: View {
    @ObservedObject private var etat = UbEtat.partage

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                entete
                tuiles
                carteUberOne
                carteSecurite
                carteCO2
                carteParametres
                liste
                Text(DonneesUb.version)
                    .font(.system(size: 13))
                    .foregroundStyle(UbTeinte.gris)
                    .padding(.horizontal, 16)
                    .padding(.top, 22)
                Spacer(minLength: 130)
            }
        }
    }

    private var entete: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(DonneesUb.nom)
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(UbTeinte.texte)
                HStack(spacing: 5) {
                    Image(systemName: "star.fill").font(.system(size: 11))
                    Text(DonneesUb.note).font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(UbTeinte.texte)
                .padding(.horizontal, 9)
                .frame(height: 26)
                .background { RoundedRectangle(cornerRadius: 6).fill(UbTeinte.tuile) }
            }
            Spacer(minLength: 10)
            Circle()
                .fill(UbTeinte.tuile)
                .frame(width: 74, height: 74)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Color(hex: 0xB6B6B6))
                }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    private var tuiles: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                NavigationLink { UbAideVue() } label: {
                    UbTuileCompte(systeme: "lifepreserver", titre: "Aide", pastille: false)
                }
                .buttonStyle(.plain)
                NavigationLink { UbWalletVue() } label: {
                    UbTuileCompte(systeme: "creditcard", titre: "Wallet", pastille: false)
                }
                .buttonStyle(.plain)
            }
            HStack(spacing: 12) {
                NavigationLink { UbSecuriteVue() } label: {
                    UbTuileCompte(systeme: "shield", titre: "Sécurité", pastille: false)
                }
                .buttonStyle(.plain)
                NavigationLink { UbMessagesVue() } label: {
                    UbTuileCompte(systeme: "envelope", titre: "Messages",
                                  pastille: etat.messagesNonLus > 0)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private var carteUberOne: some View {
        NavigationLink { UbUberOneVue() } label: {
            UbCarteCompte(titre: "Économisez 16 % sur Uber One",
                          detail: "Lorsque vous passez à un abonnement annuel",
                          systeme: "tag.fill", teinte: UbTeinte.rouge)
        }
        .buttonStyle(.plain)
        .padding(.top, 14)
    }

    private var carteSecurite: some View {
        NavigationLink { UbSecuriteVue() } label: {
            UbCarteCompte(titre: "Contrôle de sécurité",
                          detail: "Découvrez comment rendre les trajets plus sûrs",
                          systeme: "shield.lefthalf.filled", teinte: UbTeinte.bleu,
                          valeur: "\(etat.etapesSecurite)/4")
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    private var carteCO2: some View {
        HStack {
            Text("Économies de CO₂ estimées")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(UbTeinte.texte)
            Spacer(minLength: 8)
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(UbTeinte.vert)
                Text("0 g")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(UbTeinte.texte)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(UbTeinte.tuile)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var carteParametres: some View {
        NavigationLink { UbParametresVue() } label: {
            UbCarteCompte(titre: "Paramètres",
                          detail: "Coordonnées, confidentialité, notifications, apparence",
                          systeme: "gearshape.fill", teinte: UbTeinte.gris)
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    private var liste: some View {
        VStack(spacing: 0) {
            NavigationLink { UbUberOneVue() } label: {
                UbLigneListe(systeme: "u.circle", titre: "Uber One",
                             detail: "Gagnez 10 % de crédits Uber One sur les trajets")
            }
            .buttonStyle(.plain)
            UbTrait(marge: 16)
            NavigationLink { UbMentionsVue() } label: {
                UbLigneListe(systeme: "info.circle", titre: "Mentions légales")
            }
            .buttonStyle(.plain)
            UbTrait(marge: 16)
        }
        .padding(.top, 18)
    }
}

struct UbTuileCompte: View {
    let systeme: String
    let titre: String
    let pastille: Bool
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systeme)
                .font(.system(size: 20))
                .foregroundStyle(UbTeinte.texte)
            Text(titre)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(UbTeinte.texte)
            if pastille {
                Circle().fill(UbTeinte.rouge).frame(width: 8, height: 8)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 66)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(UbTeinte.tuile)
        }
        .contentShape(Rectangle())
    }
}

struct UbCarteCompte: View {
    let titre: String
    let detail: String
    let systeme: String
    let teinte: Color
    var valeur: String = ""
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(titre)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(UbTeinte.texte)
                    .multilineTextAlignment(.leading)
                Text(detail)
                    .font(.system(size: 15))
                    .foregroundStyle(UbTeinte.gris)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 8)
            if valeur.isEmpty {
                Image(systemName: systeme)
                    .font(.system(size: 26))
                    .foregroundStyle(teinte)
            } else {
                Text(valeur)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(teinte)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Circle().stroke(teinte.opacity(0.35), lineWidth: 4)
                    }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(UbTeinte.tuile)
        }
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}

// ------------------------------------------------------------ Wallet

struct UbWalletVue: View {
    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Wallet", gros: true)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        UbTitreSection(texte: "Crédit Uber")
                        HStack {
                            Text("Solde")
                                .font(.system(size: 16))
                                .foregroundStyle(UbTeinte.texte)
                            Spacer()
                            Text("0,00 €")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(UbTeinte.texte)
                        }
                        .padding(16)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(UbTeinte.tuile)
                        }
                        .padding(.horizontal, 16)
                        UbTitreSection(texte: "Moyens de paiement")
                        UbLigneListe(systeme: "creditcard.fill", titre: "Visa LCL",
                                     detail: "•••• 4417 — expire 09/28", valeur: "Par défaut")
                        UbTrait(marge: 16)
                        UbLigneListe(systeme: "applelogo", titre: "Apple Pay",
                                     detail: "Visa LCL •••• 4417")
                        UbTrait(marge: 16)
                        Text("Les reçus de vos courses sont envoyés à \(DonneesUb.email).")
                            .font(.system(size: 13))
                            .foregroundStyle(UbTeinte.gris)
                            .padding(.horizontal, 16)
                            .padding(.top, 18)
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ------------------------------------------------------------ Paramètres

struct UbParametresVue: View {
    @ObservedObject private var etat = UbEtat.partage

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Paramètres", gros: true)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        NavigationLink { UbCoordonneesVue() } label: {
                            UbLigneListe(systeme: "person.text.rectangle", titre: "Coordonnées",
                                         detail: DonneesUb.email)
                        }
                        .buttonStyle(.plain)
                        UbTrait(marge: 16)
                        NavigationLink { UbConfidentialiteVue() } label: {
                            UbLigneListe(systeme: "hand.raised", titre: "Confidentialité",
                                         detail: "Position partagée pendant les courses uniquement")
                        }
                        .buttonStyle(.plain)
                        UbTrait(marge: 16)
                        UbTitreSection(texte: "Notifications")
                        interrupteur(titre: "Courses et réservations",
                                     detail: "Rappels avant la prise en charge",
                                     valeur: $etat.notifCourses)
                        UbTrait(marge: 16)
                        interrupteur(titre: "Promotions et actualités",
                                     detail: "Offres Uber et Uber Eats",
                                     valeur: $etat.notifPromotions)
                        UbTrait(marge: 16)
                        UbTitreSection(texte: "Apparence")
                        apparence
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func interrupteur(titre: String, detail: String, valeur: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(titre)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(UbTeinte.texte)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(UbTeinte.gris)
            }
            Spacer(minLength: 8)
            Toggle("", isOn: valeur)
                .labelsHidden()
                .tint(UbTeinte.noir)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var apparence: some View {
        HStack(spacing: 0) {
            ForEach(Array(["Système", "Clair", "Sombre"].enumerated()), id: \.offset) { paire in
                Button {
                    etat.apparence = paire.offset
                } label: {
                    Text(paire.element)
                        .font(.system(size: 15,
                                      weight: etat.apparence == paire.offset ? Font.Weight.semibold : Font.Weight.regular))
                        .foregroundStyle(UbTeinte.texte)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(etat.apparence == paire.offset ? Color.white : Color.clear)
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(UbTeinte.segment)
        }
        .padding(.horizontal, 16)
    }
}

struct UbCoordonneesVue: View {
    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Coordonnées", gros: true)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        UbBlocInfo(titre: "Nom", valeur: DonneesUb.nom)
                        UbBlocInfo(titre: "Téléphone", valeur: DonneesUb.telephone)
                        UbBlocInfo(titre: "E-mail", valeur: DonneesUb.email)
                        UbBlocInfo(titre: "Adresse enregistrée", valeur: "14 rue des Fantasques")
                        UbBlocInfo(titre: "Travail", valeur: "6 rue de la République")
                        Text("Ces informations sont utilisées pour vos reçus et pour vous contacter en cas d'objet oublié.")
                            .font(.system(size: 13))
                            .foregroundStyle(UbTeinte.gris)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct UbConfidentialiteVue: View {
    var body: some View {
        UbPageTexte(titre: "Confidentialité", paragraphes: [
            "Votre position n'est partagée avec Uber que pendant une course et jusqu'à cinq minutes après son arrivée.",
            "L'historique de vos courses est conservé 36 mois puis anonymisé. Vous pouvez demander son export depuis Compte › Paramètres › Coordonnées.",
            "Aucun contact de votre répertoire n'est importé : les contacts autorisés du partage de trajet sont saisis manuellement."
        ])
    }
}

struct UbMentionsVue: View {
    var body: some View {
        UbPageTexte(titre: "Mentions légales", paragraphes: [
            "Uber France SAS, 5 rue Pleyel, 93200 Saint-Denis. Service de mise en relation avec des chauffeurs professionnels partenaires (VTC).",
            "Les prix affichés avant la commande sont estimés. Le montant définitif peut varier en fonction du trajet réellement effectué et des conditions de circulation.",
            "Conditions générales, politique de confidentialité et politique d'annulation Uber Reserve applicables à la présente application.",
            DonneesUb.version
        ])
    }
}

struct UbPageTexte: View {
    let titre: String
    let paragraphes: [String]
    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: titre, gros: true)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(paragraphes.enumerated()), id: \.offset) { paire in
                            Text(paire.element)
                                .font(.system(size: 15))
                                .foregroundStyle(UbTeinte.texte)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ------------------------------------------------------------ Aide

struct UbAideVue: View {
    @State private var ouverte: Int? = nil

    private let sujets: [(String, String)] = [
        ("J'ai oublié un objet dans la voiture",
         "Ouvrez la course concernée dans Activité, puis « Obtenir de l'aide ». Le chauffeur est contacté et vous êtes prévenue par e-mail à sarah.levasseur@icloud.com."),
        ("Le prix facturé ne correspond pas à l'estimation",
         "Le prix affiché avant la commande est une estimation. Un détour, un arrêt supplémentaire ou un trafic dense peuvent modifier le montant final. Le détail figure sur le reçu de la course."),
        ("Comment annuler une course réservée ?",
         "Dans Activité › À venir, ouvrez la course planifiée puis touchez « Annuler la réservation ». Aucun frais n'est facturé jusqu'à une heure avant l'heure de prise en charge."),
        ("Je ne reconnais pas un paiement",
         "Vérifiez d'abord la liste des courses passées dans Activité. Si un montant reste inexpliqué, signalez-le depuis la course concernée : notre équipe répond sous 48 heures.")
    ]

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Aide", gros: true)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(sujets.enumerated()), id: \.offset) { paire in
                            rangee(index: paire.offset, titre: paire.element.0, reponse: paire.element.1)
                            UbTrait(marge: 16)
                        }
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func rangee(index: Int, titre: String, reponse: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                ouverte = ouverte == index ? nil : index
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Text(titre)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(UbTeinte.texte)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 8)
                    Image(systemName: ouverte == index ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(UbTeinte.grisClair)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if ouverte == index {
                Text(reponse)
                    .font(.system(size: 15))
                    .foregroundStyle(UbTeinte.gris)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// ------------------------------------------------------------ Sécurité (D93 : 30_appstore_cafr)

struct UbSecuriteVue: View {
    @ObservedObject private var etat = UbEtat.partage

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Sécurité", gros: true)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        progression
                        UbTitreSection(texte: "Boîte à outils de sécurité")
                        outilContacts
                        UbTrait(marge: 16)
                        outilCode
                        UbTrait(marge: 16)
                        outilRideCheck
                        Text("La quatrième étape du contrôle de sécurité — ajouter un second contact de confiance — n'est pas encore effectuée.")
                            .font(.system(size: 13))
                            .foregroundStyle(UbTeinte.gris)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var progression: some View {
        HStack(spacing: 14) {
            Text("\(etat.etapesSecurite)/4")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(UbTeinte.bleu)
                .frame(width: 58, height: 58)
                .overlay { Circle().stroke(UbTeinte.bleu.opacity(0.35), lineWidth: 4) }
            VStack(alignment: .leading, spacing: 4) {
                Text("Contrôle de sécurité")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UbTeinte.texte)
                Text("Numéro de téléphone vérifié. Activez les outils ci-dessous pour aller plus loin.")
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(UbTeinte.tuile)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    private var outilContacts: some View {
        outil(systeme: "person.wave.2.fill", titre: "Gérez les contacts autorisés",
              detail: etat.partageTrajet
                ? "Chloé (06 12 55 40 83) reçoit le statut de vos courses."
                : "Partagez le statut de votre course avec vos proches en touchant simplement l'écran.",
              valeur: $etat.partageTrajet)
    }

    private var outilCode: some View {
        outil(systeme: "circle.grid.3x3.fill", titre: "Vérifiez votre course",
              detail: "Utilisez un code à 4 chiffres pour vous assurer d'entrer dans la bonne voiture.",
              valeur: $etat.codeVerification)
    }

    private var outilRideCheck: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 20))
                .foregroundStyle(UbTeinte.texte)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text("RideCheck")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(UbTeinte.texte)
                Text("Uber vous contacte si un arrêt inhabituel est détecté pendant une course. Toujours actif.")
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func outil(systeme: String, titre: String, detail: String,
                       valeur: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systeme)
                .font(.system(size: 20))
                .foregroundStyle(UbTeinte.texte)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text(titre)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(UbTeinte.texte)
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundStyle(UbTeinte.gris)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 8)
            Toggle("", isOn: valeur)
                .labelsHidden()
                .tint(UbTeinte.noir)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// ------------------------------------------------------------ Messages

struct UbMessagesVue: View {
    @ObservedObject private var etat = UbEtat.partage

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Messages", gros: true)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(etat.messages) { message in
                            NavigationLink {
                                UbMessageVue(message: message)
                            } label: {
                                rangee(message)
                            }
                            .buttonStyle(.plain)
                            UbTrait(marge: 16)
                        }
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func rangee(_ message: UbMessage) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(message.lu ? Color.clear : UbTeinte.rouge)
                .frame(width: 8, height: 8)
                .padding(.top, 7)
            VStack(alignment: .leading, spacing: 4) {
                Text(message.titre)
                    .font(.system(size: 16, weight: message.lu ? Font.Weight.regular : Font.Weight.semibold))
                    .foregroundStyle(UbTeinte.texte)
                    .multilineTextAlignment(.leading)
                Text(message.date)
                    .font(.system(size: 13))
                    .foregroundStyle(UbTeinte.gris)
            }
            Spacer(minLength: 6)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(UbTeinte.grisClair)
                .padding(.top, 3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}

struct UbMessageVue: View {
    let message: UbMessage
    @ObservedObject private var etat = UbEtat.partage

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Message")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(message.titre)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(UbTeinte.texte)
                            .multilineTextAlignment(.leading)
                        Text(message.date)
                            .font(.system(size: 14))
                            .foregroundStyle(UbTeinte.gris)
                        Text(message.corps)
                            .font(.system(size: 16))
                            .foregroundStyle(UbTeinte.texte)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 6)
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { etat.marquerLu(message) }
    }
}

// ------------------------------------------------------------ Uber One (D93 : 26_appstore_cafr)

struct UbUberOneVue: View {
    private let avantages: [(String, String)] = [
        ("bag.fill", "Frais de livraison à 0 € illimités"),
        ("tag.fill", "Prix garantis pour les membres"),
        ("trophy.fill", "Service prioritaire"),
        ("star.fill", "Avantages exclusifs")
    ]

    var body: some View {
        ZStack {
            UbTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                UbBarreTitre(titre: "Uber One")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        banniere
                        Text("Uber One")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(UbTeinte.texte)
                            .padding(.horizontal, 16)
                            .padding(.top, 18)
                            .padding(.bottom, 8)
                        ForEach(Array(avantages.enumerated()), id: \.offset) { paire in
                            HStack(spacing: 16) {
                                Image(systemName: paire.element.0)
                                    .font(.system(size: 20))
                                    .foregroundStyle(UbTeinte.or)
                                    .frame(width: 34)
                                Text(paire.element.1)
                                    .font(.system(size: 16))
                                    .foregroundStyle(UbTeinte.texte)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        Text("Vous n'êtes pas abonnée à Uber One. L'abonnement ne peut pas être souscrit depuis cet appareil.")
                            .font(.system(size: 13))
                            .foregroundStyle(UbTeinte.gris)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 26)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var banniere: some View {
        ZStack {
            LinearGradient(colors: [UbTeinte.orClair, UbTeinte.or],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(Color.white.opacity(0.92))
                .frame(width: 120, height: 120)
                .overlay {
                    Text("1")
                        .font(.system(size: 62, weight: .bold))
                        .foregroundStyle(Color(hex: 0x8A6208))
                }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }
}
