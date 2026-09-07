// SNCF Connect v1 D92 (07/09) — construit contre les 196 frames de Joachim
//
// D67 : la référence est /refs/vagueB/sncf/e001…e196.jpg (603×1311 px, 1 pt = 1,5 px).
//   Écrans FILMÉS reproduits : Accueil (e001/e100/e183), Rechercher une destination
//   (e002/e005), Recherche Départ/Arrivée (e009/e086), Calendrier (e011/e017),
//   Résultats train (e021/e024) et Bus ou covoit. (e063/e070), « Choisissez un tarif »
//   (e027/e065), Fiche train (e030/e034), Panier (e042/e057/e077), Horaires en gare
//   (e102/e105/e109/e123), Info trafic et réseaux (e138), Billets (e145/e147),
//   Offres (e154), Compte (e155/e167), Vos coordonnées (e156), Identité (e158),
//   Paramètres (e173/e175), Notifications — état vide (e185), Chatbot d'aide
//   (e190/e194).
//   D93 (secondaire, captures officielles) : Paiement sécurisé (officiel/03_06),
//   Cartes et abonnements SNCF (officiel/05_04), Alertes billets (officiel/06_05),
//   « Poser une option gratuitement » (officiel/09_07).
//   Aucun écran inventé : ce qui n'existe dans aucune source a été retiré.
//
// D59 : le contenu de Joachim (Auch/Toulouse, « Joachim Fourez », 28/07/2003,
//   06 43 49 14 26, liO/TER Occitanie, Île-de-France) n'est qu'un GABARIT. Tout est
//   remplacé par Sarah Levasseur : Lyon Part-Dieu, 14 rue des Fantasques 69001 Lyon,
//   née le 03/04/1991, 06 •• •• •• 42, sarah.levasseur@icloud.com, Carte Avantage
//   Adulte, Visa LCL •••• 4417, et le voyage « Marseille le 28 » (l'arnaque « Marc »).
//
// D92 : chaque affordance a une conséquence réelle (panier partagé et persistant,
//   option réellement posée dans Vos voyages, filtres qui filtrent, recherche de gare
//   qui cherche). Tout le reste est RETIRÉ — liste dans docs_vague-b/sncf-livraison.md.
//   Pas de micro de dictée. Pas de MapKit. Pas de .sheet / .fullScreenCover : les
//   recouvrements sont des overlays internes. Retour = chevron dans un rond blanc.
//
// Préfixe de types : Sn — aucune collision avec LPProto ni les autres apps.
import SwiftUI

// ============================================================ PALETTE (mesurée au pixel)
enum SnTeinte {
    static let fond = Color(hex: 0x0E1420)        // e001/e109/e145 : (14,20,32)
    static let carte = Color(hex: 0x1F2535)       // e001 cartes « Utile au quotidien » : (31,37,53)
    static let grille = Color(hex: 0x1B1E2D)      // e001 bloc de la grille de services : (27,30,45)
    static let accent = Color(hex: 0x7FE3FB)      // e021/e027 boutons et onglet actif : (127,227,251)
    static let bleuDoux = Color(hex: 0x6FB5FB)    // e021 bandeau « Trajet recommandé », e194 bulle : (111,181,251)
    static let texte = Color(hex: 0xFDFDFD)
    static let gris = Color(hex: 0x9195A0)        // e021 « Nos offres sont présentées… » : (145,149,160)
    static let teal = Color(hex: 0x396D85)        // e027 bandeau « 2de classe », e042 bandeau du billet
    static let orange = Color(hex: 0xE27C3C)      // e109 « Retard estimé » : (226,124,60)
    static let rouge = Color(hex: 0xFF5572)       // e138 pastille « Perturbations », e167 carte expirée
    static let violet = Color(hex: 0xB58DFF)      // e030 ligne du trajet : (181,141,255)
    static let separateur = Color(hex: 0x2C3345)
    static let sombre = Color(hex: 0x151B27)      // sous-cartes internes (e042 bloc « Aller »)
}

// ============================================================ MODÈLES

enum SnMode {
    case train
    case covoit
}

enum SnGenreLieu {
    case ville
    case gare
}

struct SnLigneReseau: Identifiable {
    let id = UUID()
    var code: String
    var fond: UInt
}

struct SnLieu: Identifiable {
    let id = UUID()
    var nom: String
    var genre: SnGenreLieu
    var region: String
    var reseaux: [SnLigneReseau] = []
}

struct SnArret: Identifiable {
    let id = UUID()
    var heure: String
    var nom: String
    var arret: String = ""
}

struct SnTrajet: Identifiable {
    let id = UUID()
    var depart: String
    var arrivee: String
    var heureDepart: String
    var heureArrivee: String
    var duree: String
    var direct: Bool
    var transporteur: String
    var numero: String
    var prix: Double
    var recommande: Bool
    var mode: SnMode
    var offset: Int
    var classe: String
    var materiel: String
    var arrets: [SnArret]
    var vehicule: String = ""      // covoiturage : « Renault Clio IV »
    var conducteur: String = ""
}

struct SnArticle: Identifiable {
    let id = UUID()
    var trajet: SnTrajet
    var voyageurs: Int
}

enum SnGenreVoyage {
    case billet
    case option
}

struct SnVoyage: Identifiable {
    let id = UUID()
    var genre: SnGenreVoyage
    var jour: String               // « Ven. 28 août 2026 »
    var depart: String
    var arrivee: String
    var heureDepart: String
    var heureArrivee: String
    var transporteur: String
    var numero: String
    var classe: String
    var voiture: String = ""
    var place: String = ""
    var prix: Double
    var mention: String            // « Acheté le 14 août 2026 » / « À payer avant le … »
    var dossier: String
    var passe: Bool = false
}

enum SnEtatDepart {
    case normal
    case retard
    case supprime
    case modifie
}

struct SnDepartGare: Identifiable {
    let id = UUID()
    var heure: String
    var lieu: String
    var transporteur: String
    var numero: String
    var voie: String
    var etat: SnEtatDepart
    var minutes: Int = 0
    var materiel: String = "Train court"
}

struct SnPerturbation: Identifiable {
    let id = UUID()
    var ligne: String
    var fond: UInt
    var niveau: String             // « Information » / « Perturbation »
    var titre: String
    var corps: String
    var grave: Bool
}

struct SnCarteReduction: Identifiable {
    let id = UUID()
    var nom: String
    var detail: String
    var validite: String
    var numero: String
}

struct SnOffre: Identifiable {
    let id = UUID()
    var nom: String
    var tranche: String
    var prix: String
    var corps: String
    var teinte: UInt
}

struct SnMessageBot: Identifiable {
    let id = UUID()
    var texte: String
    var duBot: Bool
}

struct SnIdentite {
    var prenom: String
    var nom: String
    var naissance: String
    var telephone: String
    var email: String
    var adresse: String
}

// ============================================================ AGENDA (déterministe, sans Calendar)
// Origine : mardi 18 août 2026 = offset 0. Août compte 31 jours, septembre 30.
enum SnAgenda {
    static let joursCourts = ["Lun.", "Mar.", "Mer.", "Jeu.", "Ven.", "Sam.", "Dim."]
    static let joursMini = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"]

    static func indexJour(_ offset: Int) -> Int {
        let v = (1 + offset) % 7
        return v < 0 ? v + 7 : v
    }
    /// (jour du mois, numéro de mois)
    static func date(_ offset: Int) -> (Int, Int) {
        let j = 18 + offset
        if j <= 31 { return (j, 8) }
        let k = j - 31
        if k <= 30 { return (k, 9) }
        return (k - 30, 10)
    }
    static func nomMois(_ m: Int) -> String {
        switch m {
        case 8: return "août"
        case 9: return "septembre"
        default: return "octobre"
        }
    }
    static func moisCourt(_ m: Int) -> String {
        switch m {
        case 8: return "août"
        case 9: return "sept."
        default: return "oct."
        }
    }
    /// « Mar. 18 août »
    static func court(_ offset: Int) -> String {
        let d = date(offset)
        return joursCourts[indexJour(offset)] + " \(d.0) " + moisCourt(d.1)
    }
    /// « Mar. 18 août 2026 »
    static func long(_ offset: Int) -> String {
        let d = date(offset)
        return joursCourts[indexJour(offset)] + " \(d.0) " + nomMois(d.1) + " 2026"
    }
    /// « 18 août, 10h »
    static func avecHeure(_ offset: Int, _ heure: Int) -> String {
        let d = date(offset)
        return "\(d.0) " + moisCourt(d.1) + ", \(heure)h"
    }
    /// « Mar 18 » pour le bandeau de jours des résultats
    static func mini(_ offset: Int) -> String {
        let d = date(offset)
        return joursMini[indexJour(offset)] + " \(d.0)"
    }
}

// ============================================================ FORMATS
enum SnFormat {
    static func prix(_ v: Double) -> String {
        let entier = v.rounded()
        if abs(v - entier) < 0.005 { return String(format: "%.0f €", v) }
        return String(format: "%.2f €", v).replacingOccurrences(of: ".", with: ",")
    }
    static func heure(_ minutes: Int) -> String {
        let m = ((minutes % 1440) + 1440) % 1440
        return String(format: "%02d:%02d", m / 60, m % 60)
    }
    static func duree(_ minutes: Int) -> String {
        String(format: "%dh%02d", minutes / 60, minutes % 60)
    }
    static func dossier(_ graine: Int) -> String {
        let lettres = Array("ABCDEFGHJKLMNPQRSTUVWXYZ")
        var s = ""
        var g = graine
        for _ in 0..<6 {
            g = (g &* 1103515245 &+ 12345) & 0x7FFFFFFF
            s.append(lettres[g % lettres.count])
        }
        return s
    }
}

// ============================================================ DONNÉES (remplaçables — D59)

struct SnLiaison {
    var arrivee: String
    var minutes: Int
    var prix: Double
    var transporteur: String
    var ouigo: Bool
    var materiel: String
    var escales: [String]
}

enum SnDonneesSncf {

    static let moi = SnIdentite(prenom: "Sarah", nom: "Levasseur",
                                naissance: "03/04/1991",
                                telephone: "06 •• •• •• 42",
                                email: "sarah.levasseur@icloud.com",
                                adresse: "14 rue des Fantasques\n69001 Lyon")

    static let gareOrigine = "Lyon Part-Dieu"

    // Les 25 villes et gares réellement proposées par le champ de recherche.
    static let lieux: [SnLieu] = [
        SnLieu(nom: "Lyon Part-Dieu", genre: .gare, region: "Auvergne-Rhône-Alpes",
               reseaux: [SnLigneReseau(code: "B", fond: 0x0071BC),
                         SnLigneReseau(code: "T1", fond: 0x0091C9),
                         SnLigneReseau(code: "T3", fond: 0xE94E1B),
                         SnLigneReseau(code: "T4", fond: 0x9C4B9C)]),
        SnLieu(nom: "Lyon Perrache", genre: .gare, region: "Auvergne-Rhône-Alpes",
               reseaux: [SnLigneReseau(code: "A", fond: 0xE2001A),
                         SnLigneReseau(code: "T1", fond: 0x0091C9),
                         SnLigneReseau(code: "T2", fond: 0xE6007E)]),
        SnLieu(nom: "Lyon", genre: .ville, region: "Auvergne-Rhône-Alpes"),
        SnLieu(nom: "Marseille Saint-Charles", genre: .gare, region: "Provence-Alpes-Côte d'Azur",
               reseaux: [SnLigneReseau(code: "M1", fond: 0x0068B3),
                         SnLigneReseau(code: "M2", fond: 0xE73A2E),
                         SnLigneReseau(code: "T2", fond: 0xF39200)]),
        SnLieu(nom: "Marseille", genre: .ville, region: "Provence-Alpes-Côte d'Azur"),
        SnLieu(nom: "Paris Gare de Lyon", genre: .gare, region: "Île-de-France",
               reseaux: [SnLigneReseau(code: "1", fond: 0xFFCD00),
                         SnLigneReseau(code: "14", fond: 0x62259D),
                         SnLigneReseau(code: "A", fond: 0xE2231A),
                         SnLigneReseau(code: "D", fond: 0x00814F)]),
        SnLieu(nom: "Paris", genre: .ville, region: "Île-de-France"),
        SnLieu(nom: "Annecy", genre: .gare, region: "Auvergne-Rhône-Alpes"),
        SnLieu(nom: "Grenoble", genre: .gare, region: "Auvergne-Rhône-Alpes",
               reseaux: [SnLigneReseau(code: "A", fond: 0x0091C9),
                         SnLigneReseau(code: "B", fond: 0x00A651)]),
        SnLieu(nom: "Valence Ville", genre: .gare, region: "Auvergne-Rhône-Alpes"),
        SnLieu(nom: "Valence TGV", genre: .gare, region: "Auvergne-Rhône-Alpes"),
        SnLieu(nom: "Saint-Étienne Châteaucreux", genre: .gare, region: "Auvergne-Rhône-Alpes",
               reseaux: [SnLigneReseau(code: "T1", fond: 0x00A0E3),
                         SnLigneReseau(code: "T3", fond: 0xE94E1B)]),
        SnLieu(nom: "Chambéry", genre: .gare, region: "Auvergne-Rhône-Alpes"),
        SnLieu(nom: "Genève", genre: .gare, region: "Suisse"),
        SnLieu(nom: "Dijon Ville", genre: .gare, region: "Bourgogne-Franche-Comté"),
        SnLieu(nom: "Avignon TGV", genre: .gare, region: "Provence-Alpes-Côte d'Azur"),
        SnLieu(nom: "Montpellier Saint-Roch", genre: .gare, region: "Occitanie",
               reseaux: [SnLigneReseau(code: "1", fond: 0x0086C9),
                         SnLigneReseau(code: "4", fond: 0xF9B233)]),
        SnLieu(nom: "Nîmes Centre", genre: .gare, region: "Occitanie"),
        SnLieu(nom: "Toulouse Matabiau", genre: .gare, region: "Occitanie",
               reseaux: [SnLigneReseau(code: "A", fond: 0xE2001A),
                         SnLigneReseau(code: "B", fond: 0xF9B233)]),
        SnLieu(nom: "Bordeaux Saint-Jean", genre: .gare, region: "Nouvelle-Aquitaine"),
        SnLieu(nom: "Nice-Ville", genre: .gare, region: "Provence-Alpes-Côte d'Azur"),
        SnLieu(nom: "Nantes", genre: .gare, region: "Pays de la Loire"),
        SnLieu(nom: "Strasbourg", genre: .gare, region: "Grand Est"),
        SnLieu(nom: "Lille Europe", genre: .gare, region: "Hauts-de-France"),
        SnLieu(nom: "Clermont-Ferrand", genre: .gare, region: "Auvergne-Rhône-Alpes")
    ]

    // Liaisons au départ de Lyon Part-Dieu (durées et prix cohérents avec le réseau réel).
    static let liaisons: [SnLiaison] = [
        SnLiaison(arrivee: "Marseille Saint-Charles", minutes: 107, prix: 59,
                  transporteur: "TGV INOUI", ouigo: true,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Valence TGV", "Avignon TGV", "Aix-en-Provence TGV"]),
        SnLiaison(arrivee: "Paris Gare de Lyon", minutes: 117, prix: 79,
                  transporteur: "TGV INOUI", ouigo: true,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Le Creusot TGV"]),
        SnLiaison(arrivee: "Annecy", minutes: 112, prix: 27,
                  transporteur: "TER Auvergne-Rhône-Alpes", ouigo: false,
                  materiel: "1 rame « Regio 2N » - 4 voitures - 372 places",
                  escales: ["Ambérieu-en-Bugey", "Culoz", "Aix-les-Bains-Le Revard"]),
        SnLiaison(arrivee: "Grenoble", minutes: 82, prix: 23,
                  transporteur: "TER Auvergne-Rhône-Alpes", ouigo: false,
                  materiel: "1 rame « Regio 2N » - 4 voitures - 372 places",
                  escales: ["Bourgoin-Jallieu", "La Verpillière", "Rives"]),
        SnLiaison(arrivee: "Saint-Étienne Châteaucreux", minutes: 48, prix: 13,
                  transporteur: "TER Auvergne-Rhône-Alpes", ouigo: false,
                  materiel: "1 rame « Regio 2N » - 3 voitures - 285 places",
                  escales: ["Givors-Ville", "Rive-de-Gier"]),
        SnLiaison(arrivee: "Valence Ville", minutes: 65, prix: 19,
                  transporteur: "TER Auvergne-Rhône-Alpes", ouigo: false,
                  materiel: "1 rame « Regiolis » - 4 voitures - 228 places",
                  escales: ["Vienne", "Saint-Rambert-d'Albon", "Tain-l'Hermitage"]),
        SnLiaison(arrivee: "Valence TGV", minutes: 33, prix: 25,
                  transporteur: "TGV INOUI", ouigo: false,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: []),
        SnLiaison(arrivee: "Genève", minutes: 115, prix: 37,
                  transporteur: "TGV Lyria", ouigo: false,
                  materiel: "1 rame « Duplex » - 8 voitures - 507 places",
                  escales: ["Ambérieu-en-Bugey", "Bellegarde"]),
        SnLiaison(arrivee: "Chambéry", minutes: 88, prix: 21,
                  transporteur: "TER Auvergne-Rhône-Alpes", ouigo: false,
                  materiel: "1 rame « Regio 2N » - 4 voitures - 372 places",
                  escales: ["Ambérieu-en-Bugey", "Aix-les-Bains-Le Revard"]),
        SnLiaison(arrivee: "Dijon Ville", minutes: 98, prix: 33,
                  transporteur: "TER Bourgogne-Franche-Comté", ouigo: false,
                  materiel: "1 rame « Regiolis » - 4 voitures - 228 places",
                  escales: ["Mâcon-Ville", "Chalon-sur-Saône", "Beaune"]),
        SnLiaison(arrivee: "Avignon TGV", minutes: 65, prix: 39,
                  transporteur: "TGV INOUI", ouigo: true,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Valence TGV"]),
        SnLiaison(arrivee: "Montpellier Saint-Roch", minutes: 100, prix: 45,
                  transporteur: "TGV INOUI", ouigo: true,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Valence TGV", "Nîmes Pont-du-Gard"]),
        SnLiaison(arrivee: "Nîmes Centre", minutes: 92, prix: 41,
                  transporteur: "TGV INOUI", ouigo: false,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Valence TGV"]),
        SnLiaison(arrivee: "Toulouse Matabiau", minutes: 250, prix: 62,
                  transporteur: "INTERCITÉS", ouigo: false,
                  materiel: "1 rame « Corail » - 7 voitures - 402 places",
                  escales: ["Valence Ville", "Nîmes Centre", "Narbonne", "Carcassonne"]),
        SnLiaison(arrivee: "Bordeaux Saint-Jean", minutes: 380, prix: 68,
                  transporteur: "TGV INOUI", ouigo: false,
                  materiel: "1 rame « Océane » - 8 voitures - 556 places",
                  escales: ["Montpellier Saint-Roch", "Toulouse Matabiau", "Agen"]),
        SnLiaison(arrivee: "Nice-Ville", minutes: 285, prix: 79,
                  transporteur: "TGV INOUI", ouigo: false,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Avignon TGV", "Marseille Saint-Charles", "Toulon", "Cannes"]),
        SnLiaison(arrivee: "Nantes", minutes: 265, prix: 72,
                  transporteur: "TGV INOUI", ouigo: false,
                  materiel: "1 rame « Atlantique » - 8 voitures - 485 places",
                  escales: ["Massy TGV", "Angers-Saint-Laud"]),
        SnLiaison(arrivee: "Strasbourg", minutes: 225, prix: 65,
                  transporteur: "TGV INOUI", ouigo: false,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Mulhouse-Ville", "Colmar", "Sélestat"]),
        SnLiaison(arrivee: "Lille Europe", minutes: 180, prix: 79,
                  transporteur: "TGV INOUI", ouigo: false,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Marne-la-Vallée-Chessy", "Charles-de-Gaulle TGV"]),
        SnLiaison(arrivee: "Clermont-Ferrand", minutes: 152, prix: 29,
                  transporteur: "TER Auvergne-Rhône-Alpes", ouigo: false,
                  materiel: "1 rame « Regiolis » - 4 voitures - 228 places",
                  escales: ["Saint-Étienne Châteaucreux", "Roanne", "Vichy"]),
        SnLiaison(arrivee: "Paris", minutes: 117, prix: 79,
                  transporteur: "TGV INOUI", ouigo: true,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Le Creusot TGV"]),
        SnLiaison(arrivee: "Marseille", minutes: 107, prix: 59,
                  transporteur: "TGV INOUI", ouigo: true,
                  materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                  escales: ["Valence TGV", "Avignon TGV"])
    ]

    static let recentes = ["Marseille Saint-Charles", "Paris Gare de Lyon", "Annecy"]

    // Le voyage de Sarah : elle part rejoindre « Marc » qui « arrive à Marseille le 28 ».
    static let voyagesAVenir: [SnVoyage] = [
        SnVoyage(genre: .billet, jour: "Ven. 28 août 2026",
                 depart: "Lyon Part-Dieu", arrivee: "Marseille Saint-Charles",
                 heureDepart: "06:44", heureArrivee: "08:31",
                 transporteur: "TGV INOUI", numero: "6171",
                 classe: "2de classe", voiture: "12", place: "58",
                 prix: 39, mention: "Acheté le 14 août 2026", dossier: "QKPXRJ")
    ]

    static let voyagesPasses: [SnVoyage] = [
        SnVoyage(genre: .billet, jour: "Dim. 21 juin 2026",
                 depart: "Lyon Part-Dieu", arrivee: "Paris Gare de Lyon",
                 heureDepart: "17:02", heureArrivee: "18:59",
                 transporteur: "TGV INOUI", numero: "6620",
                 classe: "2de classe", voiture: "4", place: "112",
                 prix: 52, mention: "Acheté le 2 juin 2026", dossier: "HTMBVC", passe: true),
        SnVoyage(genre: .billet, jour: "Dim. 10 mai 2026",
                 depart: "Lyon Part-Dieu", arrivee: "Valence Ville",
                 heureDepart: "09:18", heureArrivee: "10:23",
                 transporteur: "TER Auvergne-Rhône-Alpes", numero: "886214",
                 classe: "2de classe", voiture: "—", place: "Placement libre",
                 prix: 13, mention: "Acheté le 10 mai 2026", dossier: "LDWQSN", passe: true),
        SnVoyage(genre: .billet, jour: "Dim. 12 avril 2026",
                 depart: "Lyon Part-Dieu", arrivee: "Annecy",
                 heureDepart: "08:36", heureArrivee: "10:28",
                 transporteur: "TER Auvergne-Rhône-Alpes", numero: "884502",
                 classe: "2de classe", voiture: "—", place: "Placement libre",
                 prix: 19, mention: "Acheté le 4 avril 2026", dossier: "RKZFTP", passe: true)
    ]

    static let carte = SnCarteReduction(nom: "Carte Avantage Adulte",
                                        detail: "27 - 59 ans · Jusqu'à 30 % de réduction",
                                        validite: "Valable jusqu'au 14/02/2027",
                                        numero: "29 04 1991 5507 218")

    static let offres: [SnOffre] = [
        SnOffre(nom: "Carte Avantage Adulte", tranche: "27 - 59 ans", prix: "49 €",
                corps: "Jusqu'à 30 % de réduction sur vos billets TGV INOUI et INTERCITÉS, "
                     + "prix plafonnés en 2de classe et réductions pour vos accompagnants.",
                teinte: 0x2C5F7A),
        SnOffre(nom: "Carte Avantage Jeune", tranche: "12 - 27 ans", prix: "49 €",
                corps: "Jusqu'à 30 % de réduction toute l'année, sans condition de "
                     + "réservation à l'avance.",
                teinte: 0x3E6B4A),
        SnOffre(nom: "Carte Avantage Senior", tranche: "+ 60 ans", prix: "49 €",
                corps: "Jusqu'à 30 % de réduction et prix plafonnés sur toutes vos "
                     + "destinations en France.",
                teinte: 0x6A4A6E),
        SnOffre(nom: "Carte Liberté", tranche: "Voyageurs fréquents", prix: "349 €",
                corps: "45 % de réduction en 2de classe, 60 % en 1re, échange et "
                     + "remboursement sans frais jusqu'au départ.",
                teinte: 0x4A4270)
    ]

    // Info trafic — région de Sarah (D59 : remplace l'Île-de-France filmée).
    static let lignesRegion: [SnLigneReseau] = [
        SnLigneReseau(code: "A", fond: 0xE2001A),
        SnLigneReseau(code: "B", fond: 0x0071BC),
        SnLigneReseau(code: "C", fond: 0xF39200),
        SnLigneReseau(code: "D", fond: 0x00933B),
        SnLigneReseau(code: "T1", fond: 0x0091C9),
        SnLigneReseau(code: "T2", fond: 0xE6007E),
        SnLigneReseau(code: "T3", fond: 0xE94E1B),
        SnLigneReseau(code: "T4", fond: 0x9C4B9C),
        SnLigneReseau(code: "T5", fond: 0xA3C400),
        SnLigneReseau(code: "T6", fond: 0x00A19A),
        SnLigneReseau(code: "T7", fond: 0x8C6239)
    ]

    static let perturbations: [SnPerturbation] = [
        SnPerturbation(ligne: "B", fond: 0x0071BC, niveau: "Perturbation",
                       titre: "Métro B — trafic interrompu entre Part-Dieu et Oullins",
                       corps: "Suite à un incident technique sur un train, le trafic est "
                            + "interrompu entre Gare Part-Dieu Vivier Merle et Gare d'Oullins "
                            + "jusqu'à 22h00. Un service de bus relais est mis en place au "
                            + "départ de Jean Macé.",
                       grave: true),
        SnPerturbation(ligne: "TER", fond: 0x00A0A0, niveau: "Information",
                       titre: "TER Lyon ↔ Saint-Étienne — travaux de nuit",
                       corps: "Du 24 au 28 août 2026, des travaux de renouvellement de voie "
                            + "entre Givors-Ville et Rive-de-Gier entraînent la suppression "
                            + "des circulations après 21h30. Substitution routière assurée.",
                       grave: false)
    ]

    // Chatbot : réponses scriptées déterministes (mot-clé → réponse).
    static let repliques: [(String, String)] = [
        ("remboursement",
         "Un billet TER est remboursable sans frais jusqu'au départ. Un billet TGV INOUI à "
         + "tarif « Modifiable sous conditions » est échangeable jusqu'à 3 jours avant le "
         + "départ sans frais, puis moyennant 19 €. Rendez-vous dans Billets › Vos voyages, "
         + "puis « Échanger ou annuler »."),
        ("retard",
         "Si votre train arrive avec plus de 30 minutes de retard, la Garantie Ponctualité "
         + "vous ouvre droit à une compensation de 25 % à 75 % du prix payé. La demande se "
         + "fait dans les 60 jours suivant le voyage, dossier en main."),
        ("option",
         "Poser une option, c'est bloquer gratuitement votre prix et votre place pendant "
         + "48 heures. Vous retrouvez l'option dans Billets › Vos voyages ; passé le délai "
         + "indiqué, elle expire toute seule et rien ne vous est débité."),
        ("carte avantage",
         "Votre Carte Avantage Adulte est bien enregistrée sur votre compte et s'applique "
         + "automatiquement à toutes vos recherches. Vous pouvez la consulter dans "
         + "Compte › Vos cartes de réduction et fidélité."),
        ("paiement",
         "Si un paiement n'aboutit pas, aucun montant n'est débité et votre panier est "
         + "conservé. Vérifiez le plafond de votre carte, puis relancez le paiement depuis "
         + "le panier.")
    ]

    static let reponseGenerique =
        "Je n'ai pas trouvé de réponse à cette question. Vous pouvez reformuler, ou bien "
        + "consulter l'aide en ligne : les sujets les plus consultés sont l'échange d'un "
        + "billet, le remboursement, les cartes de réduction et le suivi d'un train."
}

// ============================================================ MOTEUR DÉTERMINISTE
// Aucun aléa : les mêmes origine / destination / jour donnent toujours les mêmes
// horaires, durées et prix. Aucun réseau, aucune date système.
enum SnMoteur {

    static func graine(_ texte: String) -> Int {
        var g = 7
        for u in texte.unicodeScalars {
            g = (g &* 31 &+ Int(u.value)) % 1_000_003
        }
        return abs(g)
    }

    static func liaison(depart: String, arrivee: String) -> SnLiaison {
        if let l = SnDonneesSncf.liaisons.first(where: { $0.arrivee == arrivee }) {
            if depart == SnDonneesSncf.gareOrigine || depart.hasPrefix("Lyon") { return l }
        }
        let g = graine(depart + "→" + arrivee)
        let transporteurs = ["TER Auvergne-Rhône-Alpes", "TGV INOUI", "INTERCITÉS"]
        return SnLiaison(arrivee: arrivee,
                         minutes: 45 + (g % 200),
                         prix: Double(17 + (g % 55)),
                         transporteur: transporteurs[g % transporteurs.count],
                         ouigo: g % 3 == 0,
                         materiel: "1 rame « Regio 2N » - 4 voitures - 372 places",
                         escales: [])
    }

    private static let facteurs: [Double] = [0.66, 1.0, 0.76, 0.83, 1.0, 0.66, 0.92, 1.0, 0.76, 1.0]
    private static let facteurJour: [Double] = [1.0, 0.92, 0.92, 1.0, 1.12, 1.18, 1.0]

    static func prixMinimum(depart: String, arrivee: String, offset: Int, avantage: Bool) -> Double {
        let l = trajets(depart: depart, arrivee: arrivee, offset: offset,
                        mode: .train, directs: false, avantage: avantage)
        return l.map { $0.prix }.min() ?? 0
    }

    static func trajets(depart: String, arrivee: String, offset: Int,
                        mode: SnMode, directs: Bool, avantage: Bool) -> [SnTrajet] {
        if arrivee.isEmpty || depart.isEmpty { return [] }
        if mode == .covoit { return covoiturages(depart: depart, arrivee: arrivee, offset: offset) }
        let l = liaison(depart: depart, arrivee: arrivee)
        let g = graine(depart + arrivee)
        let debut = 6 * 60 + 12 + (g % 5) * 6
        let pas = 78 + (g % 7) * 9
        let jour = facteurJour[SnAgenda.indexJour(offset)]
        var sortie: [SnTrajet] = []
        for i in 0..<10 {
            let depMin = debut + i * pas + ((g / (i + 3)) % 11)
            if depMin > 22 * 60 + 30 { break }
            let allonge = (i % 4 == 3 && !l.escales.isEmpty) ? 26 : 0
            let duree = l.minutes + allonge
            let direct = allonge == 0
            if directs && !direct { continue }
            let ouigo = l.ouigo && (i == 2 || i == 7)
            let base = ouigo ? 19.0 : l.prix * facteurs[(i + g) % facteurs.count] * jour
            let brut = ouigo ? base : (base * (avantage ? 0.7 : 1.0))
            let prix = (brut * 2).rounded() / 2
            let transporteur = ouigo ? "OUIGO" : l.transporteur
            let numero = numeroTrain(transporteur: transporteur, graine: g + i * 37)
            sortie.append(SnTrajet(depart: depart, arrivee: arrivee,
                                   heureDepart: SnFormat.heure(depMin),
                                   heureArrivee: SnFormat.heure(depMin + duree),
                                   duree: SnFormat.duree(duree),
                                   direct: direct,
                                   transporteur: transporteur,
                                   numero: numero,
                                   prix: prix,
                                   recommande: false,
                                   mode: .train,
                                   offset: offset,
                                   classe: "2de classe",
                                   materiel: l.materiel,
                                   arrets: arrets(depart: depart, arrivee: arrivee,
                                                  debut: depMin, duree: duree,
                                                  escales: direct ? l.escales : l.escales + ["Correspondance"])))
        }
        if sortie.isEmpty { return [] }
        var meilleur = 0
        for (i, t) in sortie.enumerated() where t.prix < sortie[meilleur].prix { meilleur = i }
        sortie[meilleur].recommande = true
        return sortie
    }

    private static func numeroTrain(transporteur: String, graine g: Int) -> String {
        if transporteur.hasPrefix("TER") { return "\(870_000 + g % 9000)" }
        if transporteur == "OUIGO" { return "\(7600 + g % 300)" }
        if transporteur == "INTERCITÉS" { return "\(4600 + g % 90)" }
        return "\(6100 + g % 90)"
    }

    static func arrets(depart: String, arrivee: String, debut: Int,
                       duree: Int, escales: [String]) -> [SnArret] {
        var liste: [SnArret] = [SnArret(heure: SnFormat.heure(debut), nom: depart)]
        let n = escales.count
        if n > 0 {
            for (i, nom) in escales.enumerated() {
                let t = debut + duree * (i + 1) / (n + 1)
                liste.append(SnArret(heure: SnFormat.heure(t), nom: nom, arret: "2 min d'arrêt"))
            }
        }
        liste.append(SnArret(heure: SnFormat.heure(debut + duree), nom: arrivee))
        return liste
    }

    private static let vehicules = ["Renault Clio IV", "Peugeot 308", "Citroën C3", "Dacia Sandero"]
    private static let conducteurs = ["Élodie", "Karim", "Mathis", "Sonia"]

    static func covoiturages(depart: String, arrivee: String, offset: Int) -> [SnTrajet] {
        let l = liaison(depart: depart, arrivee: arrivee)
        let g = graine(arrivee + depart)
        let jour = facteurJour[SnAgenda.indexJour(offset)]
        var sortie: [SnTrajet] = []
        for i in 0..<4 {
            let depMin = 7 * 60 + 30 + i * (150 + (g % 5) * 12)
            if depMin > 21 * 60 { break }
            let duree = l.minutes + 35 + (g % 20)
            let prix = ((Double(9 + (g + i * 5) % 14) * jour) * 2).rounded() / 2
            sortie.append(SnTrajet(depart: depart, arrivee: arrivee,
                                   heureDepart: SnFormat.heure(depMin),
                                   heureArrivee: SnFormat.heure(depMin + duree),
                                   duree: SnFormat.duree(duree),
                                   direct: true,
                                   transporteur: "BlaBlaCar",
                                   numero: "",
                                   prix: prix,
                                   recommande: false,
                                   mode: .covoit,
                                   offset: offset,
                                   classe: "classe unique",
                                   materiel: "",
                                   arrets: [SnArret(heure: SnFormat.heure(depMin), nom: depart),
                                            SnArret(heure: SnFormat.heure(depMin + duree), nom: arrivee)],
                                   vehicule: vehicules[(g + i) % vehicules.count],
                                   conducteur: conducteurs[(g + i) % conducteurs.count]))
        }
        return sortie
    }

    // ---- Horaires en gare (tableau des départs / arrivées) ----
    private static let voies = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "1", "2", "3", "4"]

    static func tableau(gare: String, arrivees: Bool, grandesLignes: Bool) -> [SnDepartGare] {
        let g = graine(gare + (arrivees ? "A" : "D") + (grandesLignes ? "G" : "B"))
        let destinations = destinationsPour(gare: gare, grandesLignes: grandesLignes)
        var liste: [SnDepartGare] = []
        var t = 20 * 60 + 12 + (g % 9)
        for (i, nom) in destinations.enumerated() {
            t += 6 + ((g / (i + 2)) % 11)
            let l = liaison(depart: gare, arrivee: nom)
            let transporteur = grandesLignes ? l.transporteur : "Car TER"
            var etat = SnEtatDepart.normal
            var minutes = 0
            let d = (g + i * 13) % 17
            if d == 3 { etat = .retard; minutes = 15 + ((g + i) % 4) * 5 }
            if d == 8 { etat = .retard; minutes = 20 + ((g + i) % 3) * 10 }
            if d == 11 && i > 3 { etat = .supprime }
            if d == 14 && i > 4 { etat = .modifie }
            liste.append(SnDepartGare(heure: SnFormat.heure(t),
                                      lieu: nom,
                                      transporteur: transporteur,
                                      numero: numeroTrain(transporteur: transporteur,
                                                          graine: g + i * 41),
                                      voie: voies[(g + i * 3) % voies.count],
                                      etat: etat,
                                      minutes: minutes,
                                      materiel: (g + i) % 2 == 0 ? "Train court" : "Train long"))
        }
        return liste
    }

    static func destinationsPour(gare: String, grandesLignes: Bool) -> [String] {
        if !grandesLignes {
            return ["Bourg-en-Bresse", "Villefranche-sur-Saône", "Ambérieu-en-Bugey",
                    "Vienne", "Bourgoin-Jallieu"]
        }
        if gare == SnDonneesSncf.gareOrigine || gare.hasPrefix("Lyon") {
            return ["Paris Gare de Lyon", "Marseille Saint-Charles", "Grenoble",
                    "Saint-Étienne Châteaucreux", "Genève", "Annecy", "Valence Ville",
                    "Dijon Ville", "Montpellier Saint-Roch", "Chambéry", "Clermont-Ferrand"]
        }
        let g = graine(gare)
        let bassin = SnDonneesSncf.liaisons.map { $0.arrivee }.filter { $0 != gare }
        var sortie: [String] = []
        for i in 0..<10 {
            let nom = bassin[(g + i * 5) % bassin.count]
            if !sortie.contains(nom) { sortie.append(nom) }
        }
        return sortie
    }

    // ---- Chatbot ----
    static func reponse(_ question: String) -> String {
        let q = question.lowercased()
        for paire in SnDonneesSncf.repliques where q.contains(paire.0) {
            return paire.1
        }
        if q.contains("rembours") { return SnDonneesSncf.repliques[0].1 }
        if q.contains("avantage") || q.contains("réduction") { return SnDonneesSncf.repliques[3].1 }
        if q.contains("payer") || q.contains("carte bancaire") { return SnDonneesSncf.repliques[4].1 }
        return SnDonneesSncf.reponseGenerique
    }
}

// ============================================================ MAGASIN (état réel, persistant)
final class SnEtat: ObservableObject {
    static let partage = SnEtat()

    @Published var panier: [SnArticle] = []
    @Published var assurance = false
    @Published var voyages: [SnVoyage] = SnDonneesSncf.voyagesAVenir
    @Published var passes: [SnVoyage] = SnDonneesSncf.voyagesPasses
    @Published var identite = SnDonneesSncf.moi

    // Réglages réellement pilotés par l'écran Paramètres.
    @Published var offresAccueil = true
    @Published var notificationsActives = true
    @Published var numeroCirculation = false
    @Published var annoncesBord = false
    @Published var theme = "Sombre"
    @Published var langue = "Français"
    @Published var alertePetitsPrix = true
    @Published var alerteReservation = false
    @Published var alerteTrainComplet = false

    @Published var messages: [SnMessageBot] = [
        SnMessageBot(texte: "Bonjour, je suis le bot SNCF Connect ! Posez-moi votre "
                          + "question, je ferai tout pour y répondre.", duBot: true)
    ]

    /// Sarah possède une Carte Avantage Adulte : elle s'applique à toutes les recherches.
    let carte = SnDonneesSncf.carte
    var avantage: Bool { true }

    var nombreArticles: Int { panier.count }
    var sousTotal: Double { panier.reduce(0) { $0 + $1.trajet.prix * Double($1.voyageurs) } }
    var totalAssurance: Double {
        assurance ? 1.05 * Double(panier.reduce(0) { $0 + $1.voyageurs }) : 0
    }
    var total: Double { sousTotal + totalAssurance }

    func ajouter(_ trajet: SnTrajet, voyageurs: Int) {
        panier.append(SnArticle(trajet: trajet, voyageurs: voyageurs))
    }
    func retirer(_ article: SnArticle) {
        panier.removeAll { $0.id == article.id }
        if panier.isEmpty { assurance = false }
    }
    func vider() {
        panier.removeAll()
        assurance = false
    }

    /// « Poser une option gratuitement » : conséquence RÉELLE et persistante — un voyage
    /// « Option » apparaît dans Billets › Vos voyages › À venir, et le panier se vide.
    @discardableResult
    func poserOption() -> Bool {
        guard let article = panier.first else { return false }
        let t = article.trajet
        let limite = SnAgenda.court(min(t.offset, 2)) + " à 23:59"
        let voyage = SnVoyage(genre: .option, jour: SnAgenda.long(t.offset),
                              depart: t.depart, arrivee: t.arrivee,
                              heureDepart: t.heureDepart, heureArrivee: t.heureArrivee,
                              transporteur: t.transporteur, numero: t.numero,
                              classe: t.classe, voiture: "—", place: "Placement libre",
                              prix: t.prix * Double(article.voyageurs),
                              mention: "Option à payer avant le " + limite,
                              dossier: SnFormat.dossier(SnMoteur.graine(t.numero + t.heureDepart)))
        voyages.insert(voyage, at: 0)
        vider()
        return true
    }

    func annuler(_ voyage: SnVoyage) {
        voyages.removeAll { $0.id == voyage.id }
    }

    func envoyer(_ texte: String) {
        let propre = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        if propre.isEmpty { return }
        messages.append(SnMessageBot(texte: propre, duBot: false))
        messages.append(SnMessageBot(texte: SnMoteur.reponse(propre), duBot: true))
    }
}

// ============================================================ CAPTURE (pipeline Miroir)
// Accesseurs NON optionnels : aucun indice nu, aucune force-unwrap dans le registre.
enum SnCapture {
    static func etat() -> SnEtat { SnEtat.partage }

    static func trajet() -> SnTrajet {
        let l = SnMoteur.trajets(depart: SnDonneesSncf.gareOrigine,
                                 arrivee: "Marseille Saint-Charles",
                                 offset: 0, mode: .train, directs: false, avantage: true)
        return l.first ?? SnTrajet(depart: SnDonneesSncf.gareOrigine,
                                   arrivee: "Marseille Saint-Charles",
                                   heureDepart: "06:44", heureArrivee: "08:31",
                                   duree: "1h47", direct: true,
                                   transporteur: "TGV INOUI", numero: "6171",
                                   prix: 39, recommande: true, mode: .train, offset: 0,
                                   classe: "2de classe",
                                   materiel: "1 rame « Duplex » - 8 voitures - 556 places",
                                   arrets: [])
    }

    static func article() -> SnArticle {
        SnEtat.partage.panier.first ?? SnArticle(trajet: trajet(), voyageurs: 1)
    }

    static func voyage() -> SnVoyage {
        SnEtat.partage.voyages.first ?? SnDonneesSncf.voyagesAVenir[0]
    }

    static func perturbation() -> SnPerturbation {
        SnDonneesSncf.perturbations[0]
    }

    static func offre() -> SnOffre {
        SnDonneesSncf.offres[0]
    }

    static var ongletDemande: Int {
        Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "0") ?? 0
    }

    /// Un panier non vide pour capturer l'écran Panier et l'écran Paiement.
    static func preparerPanier() {
        if SnEtat.partage.panier.isEmpty {
            SnEtat.partage.ajouter(trajet(), voyageurs: 1)
        }
    }
}

/// Enveloppe de capture d'un écran POUSSÉ : dans le jeu, la BarreHome est portée par
/// `SncfVue` (hors NavigationStack). En capture isolée, cette enveloppe la restitue.
struct SnEcranCapture<Contenu: View>: View {
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack { contenu() }
                .tint(SnTeinte.accent)
            BarreHome { }
        }
        .background(SnTeinte.fond)
    }
}

// ============================================================ BRIQUES VISUELLES

/// Barre de titre des écrans poussés : chevron dans un rond blanc + titre centré (e009/e027/e109).
struct SnBarreTitre: View {
    let titre: String
    var action: String = ""
    var surAction: () -> Void = {}
    @Environment(\.dismiss) private var revenir

    var body: some View {
        ZStack {
            Text(titre)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 64)
            HStack {
                Button {
                    revenir()
                } label: {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 38, height: 38)
                        .overlay {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color(hex: 0x0E1420))
                        }
                }
                .buttonStyle(.plain)
                Spacer()
                if !action.isEmpty {
                    Button(action: surAction) {
                        Text(action)
                            .font(.system(size: 16))
                            .foregroundStyle(SnTeinte.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
    }
}

/// Barre de titre sans rond (feuilles internes : Identité, chatbot) — « Fermer » à droite.
struct SnBarreFeuille: View {
    let titre: String
    let fermer: () -> Void
    var body: some View {
        ZStack {
            Text(titre)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            HStack {
                Spacer()
                Button(action: fermer) {
                    Text("Fermer")
                        .font(.system(size: 16))
                        .foregroundStyle(SnTeinte.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
    }
}

/// Grand titre d'onglet : « Billets », « Offres » (e145/e154).
struct SnGrandTitre: View {
    let texte: String
    var body: some View {
        Text(texte)
            .font(.system(size: 28, weight: .heavy))
            .foregroundStyle(SnTeinte.texte)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }
}

/// Titre de section hors carte : « Vos voyages », « Cartes de réduction et fidélité ».
struct SnTitreSection: View {
    let texte: String
    var haut: CGFloat = 22
    var body: some View {
        Text(texte)
            .font(.system(size: 21, weight: .bold))
            .foregroundStyle(SnTeinte.texte)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, haut)
            .padding(.bottom, 10)
    }
}

/// Carte sombre à coins arrondis (e001 « Utile au quotidien », e021 trajets).
struct SnCarte<Contenu: View>: View {
    var marge: CGFloat = 14
    var teinte: Color = SnTeinte.carte
    var rayon: CGFloat = 12
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { contenu() }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(marge)
            .background {
                RoundedRectangle(cornerRadius: rayon, style: .continuous).fill(teinte)
            }
            .padding(.horizontal, 16)
    }
}

/// Rangée « libellé + chevron » d'une carte (e155/e167).
struct SnLigneChevron: View {
    let titre: String
    var detail: String = ""
    var systeme: String = ""
    var alerte: Bool = false
    var body: some View {
        HStack(spacing: 14) {
            if !systeme.isEmpty {
                Image(systemName: systeme)
                    .font(.system(size: 19))
                    .foregroundStyle(SnTeinte.texte)
                    .frame(width: 28)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(titre)
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.leading)
                if !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 14))
                        .foregroundStyle(alerte ? SnTeinte.rouge : SnTeinte.gris)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(SnTeinte.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .contentShape(Rectangle())
    }
}

/// Groupe de rangées dans une seule carte, avec séparateurs (e175).
struct SnGroupe<Contenu: View>: View {
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        VStack(spacing: 0) { contenu() }
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(SnTeinte.carte)
            }
            .padding(.horizontal, 16)
    }
}

struct SnSeparateur: View {
    var body: some View {
        Rectangle().fill(SnTeinte.separateur).frame(height: 1)
    }
}

/// Bouton cyan pleine largeur à texte sombre (e027 « Choisir cet aller à 8,50 € »).
struct SnBoutonCyan: View {
    let titre: String
    var actif: Bool = true
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(titre)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(actif ? Color(hex: 0x0E1420) : Color(hex: 0x5A6270))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background {
                    Capsule().fill(actif ? SnTeinte.accent : Color(hex: 0x243044))
                }
        }
        .buttonStyle(.plain)
        .disabled(!actif)
    }
}

/// Même bouton, en habillage de NavigationLink.
struct SnPiluleCyan: View {
    let titre: String
    var body: some View {
        Text(titre)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Color(hex: 0x0E1420))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background { Capsule().fill(SnTeinte.accent) }
    }
}

/// Bouton cerclé cyan (e154 « Trouver l'offre faite pour vous »).
struct SnPiluleCreuse: View {
    let titre: String
    var body: some View {
        Text(titre)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(SnTeinte.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .overlay { Capsule().stroke(SnTeinte.accent, lineWidth: 1) }
    }
}

/// Onglets soulignés cyan (e109 Départs/Arrivées, e145 À venir/Passés, e021 Train/Bus).
struct SnSegment: View {
    let items: [String]
    @Binding var selection: Int
    var symboles: [String] = []

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { paire in
                bouton(index: paire.offset, titre: paire.element)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(SnTeinte.separateur).frame(height: 1)
        }
        .overlay(alignment: .bottomLeading) {
            GeometryReader { geo in
                Rectangle()
                    .fill(SnTeinte.accent)
                    .frame(width: geo.size.width / CGFloat(max(items.count, 1)), height: 3)
                    .offset(x: geo.size.width / CGFloat(max(items.count, 1)) * CGFloat(selection),
                            y: geo.size.height - 3)
            }
        }
        .frame(height: 46)
        .padding(.horizontal, 16)
    }

    private func bouton(index: Int, titre: String) -> some View {
        Button {
            selection = index
        } label: {
            HStack(spacing: 8) {
                if index < symboles.count {
                    Image(systemName: symboles[index])
                        .font(.system(size: 15))
                }
                Text(titre)
                    .font(.system(size: 16, weight: selection == index ? Font.Weight.semibold : Font.Weight.regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(selection == index ? SnTeinte.accent : SnTeinte.texte)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Pastille de ligne de réseau (e005 / e138).
struct SnPastilleLigne: View {
    let ligne: SnLigneReseau
    var taille: CGFloat = 22
    var body: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(Color(hex: ligne.fond))
            .frame(minWidth: taille, maxWidth: taille * 1.9)
            .frame(height: taille)
            .overlay {
                Text(ligne.code)
                    .font(.system(size: taille * 0.55, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .fixedSize(horizontal: true, vertical: false)
    }
}

/// Vignette de transporteur, dessinée (aucune image externe).
struct SnLogoTransporteur: View {
    let nom: String
    var hauteur: CGFloat = 26

    private var abrege: String {
        if nom.hasPrefix("TGV INOUI") { return "inOui" }
        if nom.hasPrefix("TGV Lyria") { return "Lyria" }
        if nom.hasPrefix("TER") { return "TER" }
        if nom == "INTERCITÉS" { return "IC" }
        if nom == "OUIGO" { return "OUIGO" }
        if nom == "BlaBlaCar" { return "BlaBla" }
        if nom == "Car TER" { return "CAR" }
        return "SNCF"
    }
    private var fond: UInt {
        if nom.hasPrefix("TGV INOUI") { return 0xFFFFFF }
        if nom == "OUIGO" { return 0xE1006E }
        if nom == "BlaBlaCar" { return 0xFFFFFF }
        if nom.hasPrefix("TER") || nom == "Car TER" { return 0x00A0A0 }
        if nom == "INTERCITÉS" { return 0x1E3D8F }
        if nom.hasPrefix("TGV Lyria") { return 0xFFFFFF }
        return 0xFFFFFF
    }
    private var encre: UInt {
        if fond == 0xFFFFFF { return 0x1E1E2C }
        return 0xFFFFFF
    }

    var body: some View {
        Text(abrege)
            .font(.system(size: hauteur * 0.46, weight: .heavy))
            .foregroundStyle(Color(hex: encre))
            .padding(.horizontal, hauteur * 0.32)
            .frame(height: hauteur)
            .background {
                RoundedRectangle(cornerRadius: 4, style: .continuous).fill(Color(hex: fond))
            }
            .fixedSize(horizontal: true, vertical: false)
    }
}

/// QR code dessiné, déterministe à partir d'une graine (aucune image, aucun réseau).
struct SnQrCode: View {
    let graine: String
    var cote: CGFloat = 190

    private var matrice: [[Bool]] { SnQrCode.calculer(graine) }

    static func calculer(_ texte: String) -> [[Bool]] {
        let n = 25
        var g = UInt64(5381)
        for u in texte.unicodeScalars { g = (g &* 33) &+ UInt64(u.value) }
        var m = Array(repeating: Array(repeating: false, count: n), count: n)
        for y in 0..<n {
            for x in 0..<n {
                g = g &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
                m[y][x] = ((g >> 34) & 1) == 1
            }
        }
        let coins = [(0, 0), (n - 7, 0), (0, n - 7)]
        for coin in coins {
            for dy in -1...7 {
                for dx in -1...7 {
                    let px = coin.0 + dx
                    let py = coin.1 + dy
                    if px < 0 || py < 0 || px >= n || py >= n { continue }
                    if dx < 0 || dy < 0 || dx > 6 || dy > 6 {
                        m[py][px] = false
                        continue
                    }
                    let bord = dx == 0 || dx == 6 || dy == 0 || dy == 6
                    let coeur = dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4
                    m[py][px] = bord || coeur
                }
            }
        }
        return m
    }

    var body: some View {
        let m = matrice
        return Canvas { contexte, taille in
            let n = m.count
            let pas = taille.width / CGFloat(n)
            for y in 0..<n {
                for x in 0..<n where m[y][x] {
                    let r = CGRect(x: CGFloat(x) * pas, y: CGFloat(y) * pas,
                                   width: pas + 0.4, height: pas + 0.4)
                    contexte.fill(Path(r), with: .color(Color.black))
                }
            }
        }
        .frame(width: cote, height: cote)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white)
        }
    }
}

/// Ligne du trajet en violet, avec les heures en pastille (e027 / e030).
struct SnLigneTemps: View {
    let arrets: [SnArret]
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                ForEach(Array(arrets.enumerated()), id: \.element.id) { paire in
                    rangee(paire.element, dernier: paire.offset == arrets.count - 1)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func rangee(_ arret: SnArret, dernier: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(arret.heure)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: 0x231A3A))
                .padding(.horizontal, 8)
                .frame(height: 24)
                .background { Capsule().fill(SnTeinte.violet) }
                .frame(width: 62)
            ZStack(alignment: .top) {
                if !dernier {
                    Rectangle().fill(SnTeinte.violet).frame(width: 8)
                        .padding(.top, 10)
                }
                Circle()
                    .stroke(SnTeinte.texte, lineWidth: 2)
                    .frame(width: 13, height: 13)
                    .padding(.top, 5)
            }
            .frame(width: 14)
            VStack(alignment: .leading, spacing: 2) {
                Text(arret.nom)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.leading)
                if !arret.arret.isEmpty {
                    Text(arret.arret)
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.gris)
                }
            }
            .padding(.bottom, dernier ? 0 : 22)
            Spacer(minLength: 0)
        }
    }
}

/// Silhouette de rame dessinée (e030 « Train court ») — aucune image externe.
struct SnDessinTrain: View {
    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            HStack(spacing: 3) {
                UnevenRoundedRectangle(topLeadingRadius: h * 0.45, bottomLeadingRadius: h * 0.2,
                                       bottomTrailingRadius: 2, topTrailingRadius: 2,
                                       style: .continuous)
                    .fill(Color(hex: 0xC8102E))
                    .frame(width: h * 1.5)
                    .overlay(alignment: .topTrailing) {
                        Rectangle().fill(Color(hex: 0xD9D9DE))
                            .frame(width: h * 0.9, height: h * 0.42)
                            .padding(.top, h * 0.24)
                    }
                voiture(hauteur: h)
                voiture(hauteur: h)
                voiture(hauteur: h)
            }
        }
        .frame(height: 54)
    }

    private func voiture(hauteur h: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(Color(hex: 0xD9D9DE))
            .overlay(alignment: .center) {
                HStack(spacing: h * 0.16) {
                    ForEach(0..<3, id: \.self) { _ in
                        Capsule().fill(Color(hex: 0x2A3140))
                            .frame(width: h * 0.28, height: h * 0.3)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(Color(hex: 0x8C1B2F)).frame(height: h * 0.14)
            }
    }
}

// ============================================================ RACINE

struct SncfVue: View {
    @Environment(\.dismiss) private var quitter
    @State private var onglet: Int

    init(onglet: Int = 0) {
        _onglet = State(initialValue: onglet)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                ZStack {
                    SnTeinte.fond.ignoresSafeArea()
                    VStack(spacing: 0) {
                        contenuOnglet
                        SnBarreOnglets(onglet: $onglet)
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
            }
            .tint(SnTeinte.accent)
            BarreHome { quitter() }
        }
        .background(SnTeinte.fond)
    }

    @ViewBuilder
    private var contenuOnglet: some View {
        switch onglet {
        case 1: SnBilletsVue()
        case 2: SnOffresVue()
        case 3: SnCompteVue(onglet: $onglet)
        default: SnAccueilVue()
        }
    }
}

/// Barre d'onglets Voyager / Billets / Offres / Compte (e001), posée AU-DESSUS de BarreHome.
struct SnBarreOnglets: View {
    @Binding var onglet: Int
    @ObservedObject private var etat = SnEtat.partage

    private let items: [(String, String)] = [
        ("Voyager", "point.topleft.down.curvedto.point.bottomright.up"),
        ("Billets", "qrcode"),
        ("Offres", "book.pages"),
        ("Compte", "person")
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { paire in
                bouton(index: paire.offset, titre: paire.element.0, systeme: paire.element.1)
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 10)
        .padding(.bottom, 22)
        .background(SnTeinte.fond)
        .overlay(alignment: .top) {
            Rectangle().fill(SnTeinte.separateur).frame(height: 0.5)
        }
    }

    private func bouton(index: Int, titre: String, systeme: String) -> some View {
        Button {
            onglet = index
        } label: {
            VStack(spacing: 5) {
                Image(systemName: systeme)
                    .font(.system(size: 19))
                    .overlay(alignment: .topTrailing) {
                        if index == 1 && etat.nombreArticles > 0 {
                            Circle().fill(SnTeinte.accent)
                                .frame(width: 8, height: 8).offset(x: 5, y: -3)
                        }
                    }
                Text(titre)
                    .font(.system(size: 12))
                    .underline(onglet == index, color: SnTeinte.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(onglet == index ? SnTeinte.accent : SnTeinte.gris)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================ ONGLET 1 — VOYAGER (e001)

struct SnAccueilVue: View {
    @ObservedObject private var etat = SnEtat.partage

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                enTete
                champRecherche
                grilleServices
                SnTitreSection(texte: "Utile au quotidien", haut: 26)
                utile
                Spacer(minLength: 26)
            }
        }
    }

    private var enTete: some View {
        HStack {
            Text("Bonjour " + etat.identite.prenom + " !")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            Spacer()
            NavigationLink {
                SnNotificationsVue()
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 22))
                    .foregroundStyle(SnTeinte.texte)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // Champ blanc en capsule, SANS micro de dictée (D67 / consigne).
    private var champRecherche: some View {
        NavigationLink {
            SnDestinationVue(titre: "Rechercher", versRecherche: true, choisir: { _ in })
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 19))
                    .foregroundStyle(Color(hex: 0x3C4657))
                Text("Où souhaitez-vous aller ?")
                    .font(.system(size: 17))
                    .foregroundStyle(Color(hex: 0x5A6270))
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 52)
            .background { Capsule().fill(Color.white) }
            .padding(.horizontal, 16)
            .padding(.top, 18)
        }
        .buttonStyle(.plain)
    }

    // D92 : seules les 4 tuiles qui mènent à un écran réel sont conservées.
    private var grilleServices: some View {
        HStack(spacing: 0) {
            tuile(titre: "Trains", systeme: "tram.fill") {
                SnRechercheVue(mode: .train)
            }
            separateurVertical
            tuile(titre: "Bus et covoit.", systeme: "bus") {
                SnRechercheVue(mode: .covoit)
            }
            separateurVertical
            tuile(titre: "Horaires en gare", systeme: "clock") {
                SnGareRechercheVue()
            }
            separateurVertical
            tuile(titre: "Info trafic", systeme: "exclamationmark.triangle") {
                SnTraficVue()
            }
        }
        .background(SnTeinte.grille)
        .padding(.top, 20)
    }

    private var separateurVertical: some View {
        Rectangle().fill(SnTeinte.separateur).frame(width: 1, height: 82)
    }

    private func tuile<D: View>(titre: String, systeme: String,
                                @ViewBuilder destination: @escaping () -> D) -> some View {
        NavigationLink {
            destination()
        } label: {
            VStack(spacing: 10) {
                Image(systemName: systeme)
                    .font(.system(size: 24))
                    .foregroundStyle(SnTeinte.accent)
                    .frame(height: 28)
                Text(titre)
                    .font(.system(size: 13))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var utile: some View {
        VStack(spacing: 12) {
            NavigationLink {
                SnGareRechercheVue()
            } label: {
                ligneUtile(systeme: "house", titre: "Rechercher des horaires à enregistrer")
            }
            .buttonStyle(.plain)
            NavigationLink {
                SnRechercheVue(mode: .train)
            } label: {
                ligneUtile(systeme: "point.topleft.down.curvedto.point.bottomright.up",
                           titre: "Rechercher un trajet à enregistrer")
            }
            .buttonStyle(.plain)
        }
    }

    private func ligneUtile(systeme: String, titre: String) -> some View {
        SnCarte(marge: 16) {
            HStack(spacing: 16) {
                Image(systemName: systeme)
                    .font(.system(size: 20))
                    .foregroundStyle(SnTeinte.texte)
                    .frame(width: 30)
                Text(titre)
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(SnTeinte.accent)
            }
        }
    }
}

// ------------------------------------------------------------ Rechercher une destination (e002 / e005)

struct SnDestinationVue: View {
    let titre: String
    var versRecherche: Bool = false
    var depart: String = SnDonneesSncf.gareOrigine
    let choisir: (String) -> Void

    @Environment(\.dismiss) private var revenir
    @State private var saisie = ""

    private var resultats: [SnLieu] {
        let q = saisie.folding(options: .diacriticInsensitive, locale: Locale(identifier: "fr_FR"))
            .lowercased()
        if q.isEmpty { return [] }
        return SnDonneesSncf.lieux.filter {
            $0.nom.folding(options: .diacriticInsensitive, locale: Locale(identifier: "fr_FR"))
                .lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreFeuille(titre: titre) { revenir() }
                champ
                if saisie.isEmpty {
                    recentes
                } else {
                    liste
                }
                Spacer(minLength: 0)
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var champ: some View {
        HStack(spacing: 10) {
            TextField("", text: $saisie, prompt: Text("Où souhaitez-vous aller ?")
                .foregroundColor(Color(hex: 0x5A6270)))
                .font(.system(size: 17))
                .foregroundStyle(Color(hex: 0x0E1420))
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.words)
            if saisie.isEmpty {
                Circle().fill(SnTeinte.accent)
                    .frame(width: 42, height: 42)
                    .overlay {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color(hex: 0x0E1420))
                    }
            } else {
                Button {
                    saisie = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(hex: 0x8C93A1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 6)
        .frame(height: 54)
        .background { Capsule().fill(Color.white) }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    // D59/D92 : les vignettes « Ajouter Maison / Travail » des frames (sans conséquence)
    // sont remplacées par les destinations réellement récentes de Sarah.
    private var recentes: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Destinations récentes")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .padding(.horizontal, 16)
                .padding(.top, 22)
                .padding(.bottom, 10)
            ForEach(SnDonneesSncf.recentes, id: \.self) { nom in
                rangee(nom: nom, genre: .gare,
                       region: SnDonneesSncf.lieux.first(where: { $0.nom == nom })?.region ?? "",
                       reseaux: [], recent: true)
            }
        }
    }

    private var liste: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Villes, Gares et Stations")
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 6)
                if resultats.isEmpty {
                    Text("Aucun lieu ne correspond à « " + saisie + " ».")
                        .font(.system(size: 15))
                        .foregroundStyle(SnTeinte.gris)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 28)
                }
                ForEach(resultats) { lieu in
                    rangee(nom: lieu.nom, genre: lieu.genre, region: lieu.region,
                           reseaux: lieu.reseaux, recent: false)
                }
                Spacer(minLength: 30)
            }
        }
    }

    @ViewBuilder
    private func rangee(nom: String, genre: SnGenreLieu, region: String,
                        reseaux: [SnLigneReseau], recent: Bool) -> some View {
        if versRecherche {
            NavigationLink {
                SnRechercheVue(depart: depart, arrivee: nom, mode: .train)
            } label: {
                contenuRangee(nom: nom, genre: genre, region: region,
                              reseaux: reseaux, recent: recent)
            }
            .buttonStyle(.plain)
        } else {
            Button {
                choisir(nom)
                revenir()
            } label: {
                contenuRangee(nom: nom, genre: genre, region: region,
                              reseaux: reseaux, recent: recent)
            }
            .buttonStyle(.plain)
        }
    }

    private func contenuRangee(nom: String, genre: SnGenreLieu, region: String,
                               reseaux: [SnLigneReseau], recent: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbole(genre: genre, recent: recent))
                .font(.system(size: 21))
                .foregroundStyle(SnTeinte.texte)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(recent ? "Récent" : (genre == .ville ? "Ville" : "Gare"))
                    .font(.system(size: 13))
                    .foregroundStyle(SnTeinte.gris)
                HStack(spacing: 6) {
                    Text(nom)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                    if !region.isEmpty {
                        Text("(" + region + ")")
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.gris)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                if !reseaux.isEmpty {
                    HStack(spacing: 5) {
                        ForEach(reseaux) { l in
                            SnPastilleLigne(ligne: l, taille: 20)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }

    private func symbole(genre: SnGenreLieu, recent: Bool) -> String {
        if recent { return "clock.arrow.circlepath" }
        return genre == .ville ? "building.2" : "house.lodge"
    }
}

// ------------------------------------------------------------ Recherche (e009 / e086)

struct SnRechercheVue: View {
    @State private var depart: String
    @State private var arrivee: String
    @State private var offset: Int
    @State private var heure: Int
    @State private var voyageurs: Int
    @State private var directs: Bool
    @State private var mode: SnMode

    init(depart: String = SnDonneesSncf.gareOrigine, arrivee: String = "",
         mode: SnMode = .train) {
        _depart = State(initialValue: depart)
        _arrivee = State(initialValue: arrivee)
        _offset = State(initialValue: 0)
        _heure = State(initialValue: 10)
        _voyageurs = State(initialValue: 1)
        _directs = State(initialValue: false)
        _mode = State(initialValue: mode)
    }

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Recherche")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        carteLieux
                        carteDate
                        filtres
                        SnTitreSection(texte: "Qui voyage ?")
                        compteurVoyageurs
                        carteVoyageur
                        boutonPrix
                        blocAide
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var carteLieux: some View {
        ZStack(alignment: .trailing) {
            SnCarte(marge: 0) {
                lienLieu(etiquette: "Départ", valeur: depart) { depart = $0 }
                SnSeparateur().padding(.trailing, 74)
                lienLieu(etiquette: "Arrivée", valeur: arrivee) { arrivee = $0 }
            }
            Button {
                let t = depart
                depart = arrivee
                arrivee = t
            } label: {
                Circle()
                    .fill(Color(hex: 0x0E1420))
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(SnTeinte.texte)
                    }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 26)
        }
        .padding(.top, 8)
    }

    private func lienLieu(etiquette: String, valeur: String,
                          affecter: @escaping (String) -> Void) -> some View {
        NavigationLink {
            SnDestinationVue(titre: etiquette, choisir: affecter)
        } label: {
            HStack(spacing: 6) {
                Text(etiquette + " :")
                    .font(.system(size: 17))
                    .foregroundStyle(SnTeinte.gris)
                Text(valeur.isEmpty ? "Gare, ville, lieu…" : valeur)
                    .font(.system(size: 17))
                    .foregroundStyle(valeur.isEmpty ? SnTeinte.gris : SnTeinte.texte)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 70)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var carteDate: some View {
        NavigationLink {
            SnCalendrierVue(offset: offset, heure: heure) { o, h in
                offset = o
                heure = h
            }
        } label: {
            SnCarte(marge: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .font(.system(size: 19))
                        .foregroundStyle(SnTeinte.gris)
                    Text("Aller :")
                        .font(.system(size: 17))
                        .foregroundStyle(SnTeinte.gris)
                    Text(SnAgenda.avecHeure(offset, heure))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(SnTeinte.texte)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    // « Trajets directs » filtre RÉELLEMENT la liste des résultats.
    private var filtres: some View {
        HStack(spacing: 12) {
            Text("Filtrer par :")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            Button {
                directs.toggle()
            } label: {
                HStack(spacing: 8) {
                    Text("Trajets directs")
                        .font(.system(size: 15))
                        .foregroundStyle(directs ? Color(hex: 0x0E1420) : SnTeinte.texte)
                    Image(systemName: directs ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(directs ? Color(hex: 0x0E1420) : SnTeinte.accent)
                }
                .padding(.horizontal, 14)
                .frame(height: 42)
                .background { Capsule().fill(directs ? SnTeinte.accent : SnTeinte.carte) }
            }
            .buttonStyle(.plain)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    private var compteurVoyageurs: some View {
        SnCarte(marge: 16) {
            HStack(spacing: 14) {
                Image(systemName: "person")
                    .font(.system(size: 22))
                    .foregroundStyle(SnTeinte.texte)
                Text("Voyageur")
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.texte)
                Spacer()
                Button {
                    if voyageurs > 1 { voyageurs -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(voyageurs > 1 ? SnTeinte.accent : Color(hex: 0x3A4356))
                }
                .buttonStyle(.plain)
                Text("\(voyageurs)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                    .frame(width: 30)
                Button {
                    if voyageurs < 6 { voyageurs += 1 }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(voyageurs < 6 ? SnTeinte.accent : Color(hex: 0x3A4356))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var carteVoyageur: some View {
        NavigationLink {
            SnCartesReductionVue()
        } label: {
            SnCarte(marge: 14) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(Color(hex: 0xE9A8C9))
                        .frame(width: 46, height: 46)
                        .overlay {
                            Text("SL")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color(hex: 0x2A1A22))
                        }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(SnEtat.partage.identite.prenom + " " + SnEtat.partage.identite.nom)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(SnTeinte.texte)
                        Text(SnEtat.partage.carte.nom)
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.gris)
                        Text("Sans carte de fidélité")
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.gris)
                    }
                    Spacer(minLength: 6)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(SnTeinte.accent)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 14)
    }

    @ViewBuilder
    private var boutonPrix: some View {
        if arrivee.isEmpty {
            Text("Choisissez une destination pour voir les prix.")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .frame(maxWidth: .infinity)
                .padding(.top, 26)
        } else {
            NavigationLink {
                SnResultatsVue(depart: depart, arrivee: arrivee, offset: offset,
                               voyageurs: voyageurs, directs: directs, mode: mode)
            } label: {
                SnPiluleCyan(titre: "Voir les prix")
                    .padding(.horizontal, 60)
            }
            .buttonStyle(.plain)
            .padding(.top, 26)
        }
    }

    private var blocAide: some View {
        SnBlocAide()
            .padding(.top, 30)
    }
}

/// Bloc « Besoin d'aide ? » avec suggestions cliquables (e016 / e068).
struct SnBlocAide: View {
    private let suggestions = ["Que signifie non réservable ?",
                               "Comment ajouter un bagage ?",
                               "Quand acheter mon billet ?"]
    var body: some View {
        SnCarte(marge: 16) {
            HStack(spacing: 12) {
                Image(systemName: "bubble.left.and.text.bubble.right")
                    .font(.system(size: 24))
                    .foregroundStyle(SnTeinte.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Besoin d'aide ?")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                    Text("Posez-nous votre question.")
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.gris)
                }
                Spacer(minLength: 0)
            }
            NavigationLink {
                SnAideVue(question: "")
            } label: {
                SnPiluleCreuse(titre: "Lancer la conversation")
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
            Text("Suggestions :")
                .font(.system(size: 14))
                .foregroundStyle(SnTeinte.gris)
                .padding(.top, 16)
            ForEach(suggestions, id: \.self) { s in
                NavigationLink {
                    SnAideVue(question: s)
                } label: {
                    HStack {
                        Text(s)
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.texte)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(SnTeinte.sombre)
                    }
                    .padding(.top, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ------------------------------------------------------------ Calendrier (e011 / e017)

struct SnCalendrierVue: View {
    @State private var offset: Int
    @State private var heure: Int
    let valider: (Int, Int) -> Void
    @Environment(\.dismiss) private var revenir

    init(offset: Int, heure: Int, valider: @escaping (Int, Int) -> Void) {
        _offset = State(initialValue: offset)
        _heure = State(initialValue: heure)
        self.valider = valider
    }

    private let entetes = ["L", "M", "M", "J", "V", "S", "D"]
    private let heures = [6, 8, 10, 12, 14, 16, 18, 20, 22]

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreFeuille(titre: "Aller : " + SnAgenda.court(offset)) { revenir() }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        mois(nom: "Août 2026", numero: 8, jours: 31, decalage: 5)
                        mois(nom: "Septembre 2026", numero: 9, jours: 30, decalage: 1)
                        Spacer(minLength: 20)
                    }
                }
                choixHeure
                SnBoutonCyan(titre: "Confirmer") {
                    valider(offset, heure)
                    revenir()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func mois(nom: String, numero: Int, jours: Int, decalage: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(nom)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
                .padding(.horizontal, 16)
                .padding(.top, 18)
            HStack(spacing: 0) {
                ForEach(Array(entetes.enumerated()), id: \.offset) { paire in
                    Text(paire.element)
                        .font(.system(size: 13))
                        .foregroundStyle(SnTeinte.gris)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            grille(numero: numero, jours: jours, decalage: decalage)
        }
    }

    private func grille(numero: Int, jours: Int, decalage: Int) -> some View {
        let cases = decalage + jours
        let lignes = (cases + 6) / 7
        return VStack(spacing: 6) {
            ForEach(0..<lignes, id: \.self) { l in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { c in
                        celluleJour(index: l * 7 + c, decalage: decalage,
                                    jours: jours, numero: numero)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }

    @ViewBuilder
    private func celluleJour(index: Int, decalage: Int, jours: Int, numero: Int) -> some View {
        let numeroJour = index - decalage + 1
        if numeroJour < 1 || numeroJour > jours {
            Color.clear.frame(maxWidth: .infinity).frame(height: 38)
        } else {
            let cible = numero == 8 ? numeroJour - 18 : numeroJour + 13
            let possible = cible >= 0 && cible <= 43
            Button {
                if possible { offset = cible }
            } label: {
                Text("\(numeroJour)")
                    .font(.system(size: 15, weight: cible == offset ? Font.Weight.bold : Font.Weight.regular))
                    .foregroundStyle(couleurJour(cible: cible, possible: possible))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background {
                        if cible == offset {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(SnTeinte.accent, lineWidth: 1.5)
                        }
                    }
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!possible)
        }
    }

    private func couleurJour(cible: Int, possible: Bool) -> Color {
        if !possible { return Color(hex: 0x4A5264) }
        if cible == offset { return SnTeinte.accent }
        return SnTeinte.texte
    }

    private var choixHeure: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(heures, id: \.self) { h in
                    Button {
                        heure = h
                    } label: {
                        Text("\(h)h")
                            .font(.system(size: 15, weight: h == heure ? Font.Weight.bold : Font.Weight.regular))
                            .foregroundStyle(h == heure ? Color(hex: 0x0E1420) : SnTeinte.texte)
                            .frame(width: 58, height: 40)
                            .background {
                                Capsule().fill(h == heure ? SnTeinte.accent : SnTeinte.carte)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 56)
    }
}

// ------------------------------------------------------------ Résultats (e021 / e063)

struct SnResultatsVue: View {
    let depart: String
    let arrivee: String
    let voyageurs: Int
    let directs: Bool

    @State private var offset: Int
    @State private var modeIndex: Int
    @State private var precedents = false
    @State private var suivants = false

    init(depart: String, arrivee: String, offset: Int, voyageurs: Int,
         directs: Bool, mode: SnMode) {
        self.depart = depart
        self.arrivee = arrivee
        self.voyageurs = voyageurs
        self.directs = directs
        _offset = State(initialValue: offset)
        _modeIndex = State(initialValue: mode == .covoit ? 1 : 0)
    }

    private var mode: SnMode { modeIndex == 1 ? SnMode.covoit : SnMode.train }

    private var tous: [SnTrajet] {
        SnMoteur.trajets(depart: depart, arrivee: arrivee, offset: offset,
                         mode: mode, directs: directs, avantage: SnEtat.partage.avantage)
    }
    private var visibles: [SnTrajet] {
        let l = tous
        if l.count <= 4 { return l }
        let debut = precedents ? 0 : 1
        let fin = suivants ? l.count : min(l.count, debut + 5)
        return Array(l[debut..<max(fin, debut)])
    }
    private var jours: [Int] {
        let debut = max(0, offset - 1)
        return Array(debut...(debut + 4))
    }

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: arrivee)
                SnSegment(items: ["Train", "Bus ou covoit."], selection: $modeIndex,
                          symboles: ["tram.fill", "bus"])
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        bandeauJours
                        mention
                        if tous.count > 4 && !precedents {
                            boutonPlage(titre: "Afficher les trajets précédents",
                                        systeme: "chevron.up") { precedents = true }
                        }
                        liste
                        if tous.count > 4 && !suivants {
                            boutonPlage(titre: "Afficher les trajets suivants",
                                        systeme: "chevron.down") { suivants = true }
                        }
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var bandeauJours: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(jours, id: \.self) { j in
                    chipJour(j)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 78)
        .padding(.top, 8)
    }

    private func chipJour(_ j: Int) -> some View {
        let prix = SnMoteur.prixMinimum(depart: depart, arrivee: arrivee,
                                        offset: j, avantage: SnEtat.partage.avantage)
        return Button {
            offset = j
            precedents = false
            suivants = false
        } label: {
            VStack(spacing: 4) {
                Text(SnAgenda.mini(j))
                    .font(.system(size: 15))
                Text(prix > 0 ? SnFormat.prix(prix) : "—")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(j == offset ? Color(hex: 0x0E1420) : SnTeinte.texte)
            .frame(width: 108, height: 62)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(j == offset ? SnTeinte.accent : SnTeinte.carte)
            }
        }
        .buttonStyle(.plain)
    }

    private var mention: some View {
        HStack(alignment: .top) {
            Text("Nos offres sont présentées par horaires de départ.")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 10)
            NavigationLink {
                SnConditionsVue()
            } label: {
                Text("Voir conditions")
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func boutonPlage(titre: String, systeme: String,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(titre)
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.accent)
                Image(systemName: systeme)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: 0x0E1420))
                    .frame(width: 22, height: 22)
                    .background { Circle().fill(SnTeinte.accent) }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(SnTeinte.carte)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var liste: some View {
        if visibles.isEmpty {
            SnAucunTrajet(directs: directs)
        } else {
            VStack(spacing: 12) {
                ForEach(visibles) { t in
                    NavigationLink {
                        SnTarifVue(trajet: t, voyageurs: voyageurs)
                    } label: {
                        SnCarteTrajet(trajet: t, voyageurs: voyageurs)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// État vide filmé (e092) : « Aucun trajet trouvé ».
struct SnAucunTrajet: View {
    let directs: Bool
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tram.fill")
                .font(.system(size: 40))
                .foregroundStyle(SnTeinte.bleuDoux)
            Text("Aucun trajet trouvé")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            Text(directs
                 ? "Essayez de modifier votre date, ou retirez le filtre « Trajets directs »."
                 : "Essayez de modifier votre date de départ ou d'arrivée.")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

/// Carte d'un trajet dans la liste (e021), avec le bandeau « Trajet recommandé ».
struct SnCarteTrajet: View {
    let trajet: SnTrajet
    let voyageurs: Int

    var body: some View {
        if trajet.recommande {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(hex: 0x121A28))
                    Text("Trajet recommandé")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color(hex: 0x121A28))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 46)
                corps
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(SnTeinte.carte)
                    }
                    .padding(4)
            }
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(SnTeinte.bleuDoux)
            }
            .padding(.horizontal, 16)
        } else {
            corps
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(SnTeinte.carte)
                }
                .padding(.horizontal, 16)
        }
    }

    private var corps: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    ligneHoraire(heure: trajet.heureDepart, gare: trajet.depart)
                    ligneHoraire(heure: trajet.heureArrivee, gare: trajet.arrivee)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 0) {
                    Text("dès")
                        .font(.system(size: 13))
                        .foregroundStyle(SnTeinte.gris)
                    Text(SnFormat.prix(trajet.prix * Double(voyageurs)))
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                }
            }
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                        .foregroundStyle(SnTeinte.gris)
                    Text(trajet.duree)
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.gris)
                    Text(trajet.direct ? "Direct" : "1 correspondance")
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.gris)
                    SnLogoTransporteur(nom: trajet.transporteur, hauteur: 20)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(SnTeinte.accent)
                }
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background { Capsule().fill(SnTeinte.sombre) }
                Spacer(minLength: 0)
                if trajet.mode == .train {
                    Image(systemName: "bicycle")
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.gris)
                }
            }
        }
        .padding(14)
        .contentShape(Rectangle())
    }

    private func ligneHoraire(heure: String, gare: String) -> some View {
        HStack(spacing: 10) {
            Text(heure)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            Text(gare)
                .font(.system(size: 17))
                .foregroundStyle(SnTeinte.texte)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

// ------------------------------------------------------------ Choisissez un tarif (e027 / e065)

struct SnTarifVue: View {
    let trajet: SnTrajet
    let voyageurs: Int
    @ObservedObject private var etat = SnEtat.partage

    private var total: Double { trajet.prix * Double(voyageurs) }

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Choisissez un tarif")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        recapitulatif
                        SnTitreSection(texte: "Choisissez votre tarif")
                        blocTarif
                        SnLigneTemps(arrets: trajet.arrets)
                            .padding(.top, 26)
                        ficheTransporteur
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var recapitulatif: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Aller : " + SnAgenda.court(trajet.offset))
                .font(.system(size: 17))
                .foregroundStyle(SnTeinte.texte)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            SnSeparateur().padding(.horizontal, 16)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    ligne(heure: trajet.heureDepart, gare: trajet.depart)
                    ligne(heure: trajet.heureArrivee, gare: trajet.arrivee)
                }
                Spacer(minLength: 8)
                HStack(spacing: 2) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(SnTeinte.texte)
                    Text("x\(voyageurs)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            SnSeparateur().padding(.horizontal, 16)
            HStack(spacing: 10) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundStyle(SnTeinte.gris)
                Text(trajet.duree)
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                Text(trajet.direct ? "Direct" : "1 correspondance")
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                SnLogoTransporteur(nom: trajet.transporteur, hauteur: 22)
                Spacer()
                if trajet.mode == .train {
                    Image(systemName: "bicycle")
                        .font(.system(size: 15))
                        .foregroundStyle(SnTeinte.gris)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .padding(.top, 4)
    }

    private func ligne(heure: String, gare: String) -> some View {
        HStack(spacing: 10) {
            Text(heure)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            Text(gare)
                .font(.system(size: 18))
                .foregroundStyle(SnTeinte.texte)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var blocTarif: some View {
        VStack(spacing: 0) {
            Text("Pour \(voyageurs) voyageur" + (voyageurs > 1 ? "s" : ""))
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(trajet.classe)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(SnTeinte.texte)
                        Text("Modifiable sous conditions")
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.texte)
                    }
                    Spacer()
                    Text(SnFormat.prix(total))
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SnTeinte.teal)
                actionTarif
                NavigationLink {
                    SnConditionsVue()
                } label: {
                    Text("Conditions tarifaires")
                        .font(.system(size: 16))
                        .foregroundStyle(SnTeinte.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(SnTeinte.carte)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    // D92 : le covoiturage se réserve chez BlaBlaCar — pas de faux achat, on l'explique.
    @ViewBuilder
    private var actionTarif: some View {
        if trajet.mode == .covoit {
            Text("La réservation de ce covoiturage se termine dans l'application "
                 + "BlaBlaCar, avec le compte du conducteur "
                 + trajet.conducteur + ".")
                .font(.system(size: 14))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(.leading)
                .padding(16)
        } else {
            NavigationLink {
                SnPanierVue()
            } label: {
                SnPiluleCyan(titre: "Choisir cet aller à " + SnFormat.prix(total))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                etat.ajouter(trajet, voyageurs: voyageurs)
            })
        }
    }

    @ViewBuilder
    private var ficheTransporteur: some View {
        if trajet.mode == .train {
            NavigationLink {
                SnTrainVue(trajet: trajet)
            } label: {
                SnCarte(marge: 16) {
                    HStack(alignment: .top) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(SnTeinte.gris)
                        Spacer()
                        SnLogoTransporteur(nom: trajet.transporteur, hauteur: 34)
                    }
                    Text(trajet.transporteur + " n° " + trajet.numero)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                        .padding(.top, 12)
                    Text("Opéré par SNCF Voyageurs")
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.gris)
                    SnSeparateur().padding(.vertical, 12)
                    HStack(spacing: 10) {
                        Image(systemName: "bicycle")
                            .font(.system(size: 16))
                            .foregroundStyle(SnTeinte.texte)
                        Text("Espace vélo gratuit")
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.texte)
                        Spacer()
                    }
                    HStack(spacing: 10) {
                        Text("Voir + de détails")
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.accent)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SnTeinte.accent)
                    }
                    .padding(.top, 12)
                }
                .padding(.top, 20)
            }
            .buttonStyle(.plain)
        } else {
            SnCarte(marge: 16) {
                HStack {
                    Text(trajet.vehicule)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                    Spacer()
                    SnLogoTransporteur(nom: "BlaBlaCar", hauteur: 28)
                }
                Text("Accueil embarquement avec pièce d'identité jusqu'à 15 minutes "
                     + "avant le départ.")
                    .font(.system(size: 14))
                    .foregroundStyle(SnTeinte.gris)
                    .padding(.top, 10)
            }
            .padding(.top, 20)
        }
    }
}

// ------------------------------------------------------------ Conditions tarifaires

struct SnConditionsVue: View {
    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Conditions tarifaires")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        paragraphe(titre: "Échange et remboursement",
                                   corps: "Billet échangeable et remboursable sans frais "
                                        + "jusqu'à 3 jours avant le départ. Ensuite, 19 € de "
                                        + "frais par billet et par sens jusqu'à 30 minutes "
                                        + "après le départ. Aucun échange au-delà.")
                        paragraphe(titre: "Prix et réductions",
                                   corps: "Le prix affiché tient compte de votre "
                                        + SnEtat.partage.carte.nom
                                        + ". Le tarif est susceptible d'évoluer jusqu'à la "
                                        + "validation de la commande.")
                        paragraphe(titre: "Bagages",
                                   corps: "Deux bagages et un bagage à main par voyageur, "
                                        + "étiquetés à votre nom. Au-delà, une régularisation "
                                        + "de 50 € peut être demandée à bord.")
                        paragraphe(titre: "Vélos",
                                   corps: "Emplacement vélo gratuit et non réservable dans "
                                        + "la limite des places disponibles, vélo démonté et "
                                        + "housse obligatoires sur les TGV INOUI.")
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func paragraphe(titre: String, corps: String) -> some View {
        SnCarte(marge: 16) {
            Text(titre)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            Text(corps)
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(.leading)
                .padding(.top, 6)
        }
    }
}

// ------------------------------------------------------------ Fiche train (e030 / e034)

struct SnTrainVue: View {
    let trajet: SnTrajet

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: trajet.transporteur + " " + trajet.numero)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        rame
                        SnTitreSection(texte: "Services à bord de ce train", haut: 22)
                        services
                        Text(trajet.materiel)
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.gris)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        destination
                        SnLigneTemps(arrets: trajet.arrets)
                            .padding(.top, 16)
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var rame: some View {
        SnCarte(marge: 16) {
            Text(trajet.materiel.contains("8 voitures") ? "Train long" : "Train court")
                .font(.system(size: 17))
                .foregroundStyle(SnTeinte.texte)
            SnDessinTrain()
                .padding(.top, 18)
                .padding(.bottom, 6)
        }
        .padding(.top, 8)
    }

    private var services: some View {
        HStack(spacing: 26) {
            picto("snowflake")
            picto("powerplug")
            picto("bicycle")
            picto("cart")
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private func picto(_ systeme: String) -> some View {
        Image(systemName: systeme)
            .font(.system(size: 21))
            .foregroundStyle(SnTeinte.texte)
    }

    private var destination: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Destination " + trajet.arrivee)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(SnTeinte.texte)
            Text("Opéré par SNCF Voyageurs — " + trajet.numero)
                .font(.system(size: 16))
                .foregroundStyle(SnTeinte.gris)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }
}

// ------------------------------------------------------------ Panier (e042 / e057 / e077)

struct SnPanierVue: View {
    @ObservedObject private var etat = SnEtat.partage
    @State private var optionPosee = false
    @State private var detailOuvert = true

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Panier")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        if optionPosee { confirmationOption }
                        if etat.panier.isEmpty {
                            vide
                        } else {
                            detailCommande
                            blocOption
                            ForEach(etat.panier) { article in
                                SnCarteArticle(article: article)
                            }
                            assurance
                            bagages
                            billetTelephone
                            actions
                        }
                        SnBlocAide().padding(.top, 26)
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var vide: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 40))
                .foregroundStyle(SnTeinte.bleuDoux)
            Text("Votre panier est vide")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            Text("Recherchez un trajet depuis l'onglet Voyager pour ajouter un billet.")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }

    private var confirmationOption: some View {
        SnCarte(marge: 16, teinte: SnTeinte.teal) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(SnTeinte.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Option posée")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                    Text("Retrouvez-la dans Billets › Vos voyages › À venir. Rien ne vous "
                         + "a été débité.")
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.texte)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(.top, 8)
    }

    private var detailCommande: some View {
        SnCarte(marge: 0) {
            Button {
                detailOuvert.toggle()
            } label: {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Détail de la commande")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(SnTeinte.texte)
                        Text("(\(etat.nombreArticles) produit" + (etat.nombreArticles > 1 ? "s)" : ")"))
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                    }
                    Spacer()
                    Image(systemName: detailOuvert ? "chevron.up" : "chevron.down")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(SnTeinte.accent)
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if detailOuvert {
                lignePrix(cle: "\(etat.nombreArticles) voyage"
                          + (etat.nombreArticles > 1 ? "s" : ""),
                          valeur: SnFormat.prix(etat.sousTotal), gras: false)
                if etat.assurance {
                    lignePrix(cle: "Assurance Allianz Travel",
                              valeur: SnFormat.prix(etat.totalAssurance), gras: false)
                }
            }
            SnSeparateur()
            lignePrix(cle: "Total commande", valeur: SnFormat.prix(etat.total), gras: true)
        }
        .padding(.top, 8)
    }

    private func lignePrix(cle: String, valeur: String, gras: Bool) -> some View {
        HStack {
            Text(cle)
                .font(.system(size: gras ? 19 : 16, weight: gras ? Font.Weight.bold : Font.Weight.regular))
                .foregroundStyle(SnTeinte.texte)
            Spacer()
            Text(valeur)
                .font(.system(size: gras ? 19 : 16, weight: gras ? Font.Weight.bold : Font.Weight.regular))
                .foregroundStyle(SnTeinte.texte)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // D93 (officiel/09_07) : « Poser une option gratuitement » — conséquence RÉELLE.
    private var blocOption: some View {
        Button {
            if etat.poserOption() { optionPosee = true }
        } label: {
            SnCarte(marge: 16) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Poser une option gratuitement")
                            .font(.system(size: 17))
                            .foregroundStyle(SnTeinte.texte)
                        Text("Bloque votre prix et votre place pendant 48 heures, sans "
                             + "paiement.")
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 6)
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(SnTeinte.accent)
                }
            }
            .padding(.top, 12)
        }
        .buttonStyle(.plain)
    }

    private var assurance: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Souhaitez-vous assurer votre voyage ?")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
                .padding(.horizontal, 16)
                .padding(.top, 26)
            Text("Choix obligatoire : réservez l'esprit libre avec notre partenaire "
                 + "Allianz Travel.")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 12)
            choixAssurance(oui: true)
            choixAssurance(oui: false)
        }
    }

    private func choixAssurance(oui: Bool) -> some View {
        Button {
            etat.assurance = oui
        } label: {
            SnCarte(marge: 16) {
                HStack(spacing: 12) {
                    Image(systemName: etat.assurance == oui
                          ? "largecircle.fill.circle" : "circle")
                        .font(.system(size: 21))
                        .foregroundStyle(etat.assurance == oui ? SnTeinte.accent : SnTeinte.gris)
                    Text(oui ? "Oui, je m'assure" : "Non, je ne veux pas assurer mon voyage")
                        .font(.system(size: 16))
                        .foregroundStyle(SnTeinte.texte)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 6)
                    if oui {
                        Text(SnFormat.prix(1.05))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(SnTeinte.texte)
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .buttonStyle(.plain)
    }

    private var bagages: some View {
        SnCarte(marge: 16) {
            HStack(spacing: 12) {
                Image(systemName: "suitcase")
                    .font(.system(size: 19))
                    .foregroundStyle(SnTeinte.texte)
                Text("Bagages à bord")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                Spacer()
            }
            Text("Le nombre de bagages maximum par personne et leur taille dépendent du "
                 + "type de train ou de car. Les bagages doivent être étiquetés à votre nom "
                 + "et rester sous votre surveillance.")
                .font(.system(size: 14))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(.leading)
                .padding(.top, 8)
        }
        .padding(.top, 14)
    }

    private var billetTelephone: some View {
        SnCarte(marge: 16) {
            HStack(spacing: 12) {
                Image(systemName: "iphone")
                    .font(.system(size: 19))
                    .foregroundStyle(SnTeinte.texte)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Billet sur votre téléphone")
                        .font(.system(size: 17))
                        .foregroundStyle(SnTeinte.texte)
                    Text("Mode de retrait")
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.gris)
                }
                Spacer()
            }
        }
        .padding(.top, 12)
    }

    private var actions: some View {
        VStack(spacing: 12) {
            NavigationLink {
                SnPaiementVue()
            } label: {
                SnPiluleCyan(titre: "Valider et payer")
                    .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            NavigationLink {
                SnRechercheVue(mode: .train)
            } label: {
                SnPiluleCreuse(titre: "Ajouter un autre billet")
                    .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            Button {
                etat.vider()
                optionPosee = false
            } label: {
                Text("Retirer du panier")
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.accent)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 22)
    }
}

/// Carte d'un billet dans le panier (e042).
struct SnCarteArticle: View {
    let article: SnArticle
    @ObservedObject private var etat = SnEtat.partage

    private var t: SnTrajet { article.trajet }

    var body: some View {
        VStack(spacing: 0) {
            bandeau
            corps
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(SnTeinte.carte)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var bandeau: some View {
        HStack(spacing: 12) {
            SnLogoTransporteur(nom: t.transporteur, hauteur: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(t.depart)
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.texte)
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13))
                        .foregroundStyle(SnTeinte.texte)
                    Text(t.arrivee)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SnTeinte.teal)
    }

    private var corps: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 2) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 19))
                        .foregroundStyle(SnTeinte.texte)
                    Text("x\(article.voyageurs)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                }
                Spacer()
                Text(SnFormat.prix(t.prix * Double(article.voyageurs)))
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
            }
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.orange)
                Text("Prix valable jusqu'à 21:23")
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.orange)
            }
            .padding(.top, 10)
            blocAller
        }
        .padding(14)
    }

    private var blocAller: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Aller")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                    Text("Le " + SnAgenda.court(t.offset).lowercased()
                         + " de " + t.heureDepart + " à " + t.heureArrivee)
                        .font(.system(size: 15))
                        .foregroundStyle(SnTeinte.texte)
                }
                Spacer()
            }
            .padding(14)
            SnSeparateur()
            HStack(spacing: 12) {
                SnLogoTransporteur(nom: t.transporteur, hauteur: 22)
                Image(systemName: "figure.seated.side")
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                Text("Placement libre")
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.texte)
                Spacer()
            }
            .padding(14)
        }
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(SnTeinte.sombre)
        }
        .padding(.top, 14)
    }
}

// ------------------------------------------------------------ Paiement (D93 — officiel/03_06)

struct SnPaiementVue: View {
    @ObservedObject private var etat = SnEtat.partage
    @State private var moyen = 0
    @State private var accepte = false
    @State private var echec = false

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Paiement sécurisé")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Payez en toute sécurité")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(SnTeinte.texte)
                            .padding(.horizontal, 16)
                            .padding(.top, 6)
                        Text("Sélectionnez un moyen de paiement")
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.gris)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .padding(.bottom, 10)
                        moyenPaiement(index: 0, titre: "Apple Pay", systeme: "applelogo",
                                      detail: "Le paiement Apple Pay est éligible aux marques : "
                                            + "CB, Visa et Mastercard")
                        moyenPaiement(index: 1, titre: "Carte bancaire", systeme: "creditcard",
                                      detail: "Visa LCL •••• 4417")
                        totaux
                        conditions
                        bouton
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
        // D82-B : le paiement n'aboutit pas — aucun billet n'est émis, le panier est conservé.
        .alert("Paiement refusé", isPresented: $echec) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Le paiement n'a pas pu être finalisé. Réessayez plus tard.")
        }
    }

    private func moyenPaiement(index: Int, titre: String, systeme: String,
                               detail: String) -> some View {
        Button {
            moyen = index
        } label: {
            SnCarte(marge: 14) {
                HStack(spacing: 12) {
                    Image(systemName: systeme)
                        .font(.system(size: 18))
                        .foregroundStyle(SnTeinte.texte)
                        .frame(width: 26)
                    Text(titre)
                        .font(.system(size: 16))
                        .foregroundStyle(SnTeinte.texte)
                    Spacer()
                    Image(systemName: moyen == index ? "largecircle.fill.circle" : "circle")
                        .font(.system(size: 21))
                        .foregroundStyle(moyen == index ? SnTeinte.accent : SnTeinte.gris)
                }
                if moyen == index {
                    Text(detail)
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.gris)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 8)
                }
            }
            .padding(.bottom, 10)
        }
        .buttonStyle(.plain)
    }

    private var totaux: some View {
        SnCarte(marge: 0) {
            HStack {
                Text("Voyage (\(etat.nombreArticles))")
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.texte)
                Spacer()
                Text(SnFormat.prix(etat.sousTotal))
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.texte)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            SnSeparateur()
            HStack {
                Text("Total commande")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                Spacer()
                Text(SnFormat.prix(etat.total))
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .padding(.top, 10)
    }

    private var conditions: some View {
        Button {
            accepte.toggle()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: accepte ? "checkmark.square.fill" : "square")
                    .font(.system(size: 21))
                    .foregroundStyle(accepte ? SnTeinte.accent : SnTeinte.gris)
                Text("J'ai pris connaissance des conditions ci-après et je les accepte.")
                    .font(.system(size: 14))
                    .foregroundStyle(SnTeinte.gris)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var bouton: some View {
        SnBoutonCyan(titre: "Payer " + SnFormat.prix(etat.total), actif: accepte) {
            echec = true
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
}

// ------------------------------------------------------------ Horaires en gare (e102 / e105)

struct SnGareRechercheVue: View {
    @State private var saisie = ""

    private var gares: [SnLieu] {
        let q = saisie.folding(options: .diacriticInsensitive, locale: Locale(identifier: "fr_FR"))
            .lowercased()
        let toutes = SnDonneesSncf.lieux.filter { $0.genre == .gare }
        if q.isEmpty { return [] }
        return toutes.filter {
            $0.nom.folding(options: .diacriticInsensitive, locale: Locale(identifier: "fr_FR"))
                .lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Horaires en gare")
                champ
                if saisie.isEmpty { accueil } else { liste }
                Spacer(minLength: 0)
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var champ: some View {
        HStack(spacing: 10) {
            TextField("", text: $saisie,
                      prompt: Text("Rechercher une gare, un arrêt…")
                        .foregroundColor(Color(hex: 0x5A6270)))
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: 0x0E1420))
                .autocorrectionDisabled(true)
            if saisie.isEmpty {
                Circle().fill(SnTeinte.accent)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color(hex: 0x0E1420))
                    }
            } else {
                Button {
                    saisie = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 21))
                        .foregroundStyle(Color(hex: 0x8C93A1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, 18)
        .padding(.trailing, 6)
        .frame(height: 52)
        .background { Capsule().fill(Color.white) }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private var accueil: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Consultez les horaires de tous les trains et transports en commun")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                    .padding(.top, 26)
                explication(systeme: "mappin.and.ellipse",
                            texte: "Recherchez la gare, la station ou l'arrêt qui vous intéresse.")
                explication(systeme: "tram",
                            texte: "Retrouvez les horaires de tous les trains mais aussi des "
                                 + "bus, du tramway, du métro…")
                explication(systeme: "arrow.left.arrow.right",
                            texte: "Trains grandes lignes : choisissez d'afficher les trains "
                                 + "au départ ou à l'arrivée de la gare.")
                Text("Votre gare")
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                    .padding(.horizontal, 16)
                    .padding(.top, 26)
                    .padding(.bottom, 8)
                NavigationLink {
                    SnHorairesVue(gare: SnDonneesSncf.gareOrigine)
                } label: {
                    SnCarte(marge: 0) {
                        SnLigneChevron(titre: SnDonneesSncf.gareOrigine,
                                       detail: "Auvergne-Rhône-Alpes",
                                       systeme: "house.lodge")
                    }
                }
                .buttonStyle(.plain)
                Spacer(minLength: 30)
            }
        }
    }

    private func explication(systeme: String, texte: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systeme)
                .font(.system(size: 20))
                .foregroundStyle(SnTeinte.bleuDoux)
                .frame(width: 30)
            Text(texte)
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private var liste: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                if gares.isEmpty {
                    Text("Aucune gare ne correspond à « " + saisie + " ».")
                        .font(.system(size: 15))
                        .foregroundStyle(SnTeinte.gris)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 28)
                }
                ForEach(gares) { g in
                    NavigationLink {
                        SnHorairesVue(gare: g.nom)
                    } label: {
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: "house.lodge")
                                .font(.system(size: 21))
                                .foregroundStyle(SnTeinte.texte)
                                .frame(width: 30, height: 30)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Gare")
                                    .font(.system(size: 13))
                                    .foregroundStyle(SnTeinte.gris)
                                Text(g.nom)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(SnTeinte.texte)
                                Text(g.region)
                                    .font(.system(size: 14))
                                    .foregroundStyle(SnTeinte.gris)
                                if !g.reseaux.isEmpty {
                                    HStack(spacing: 5) {
                                        ForEach(g.reseaux) { l in
                                            SnPastilleLigne(ligne: l, taille: 20)
                                        }
                                    }
                                    .padding(.top, 2)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 30)
            }
            .padding(.top, 10)
        }
    }
}

// ------------------------------------------------------------ Tableau des départs / arrivées (e109 / e123)

struct SnHorairesVue: View {
    let gare: String
    @State private var reseau = 0        // 0 = Grandes lignes, 1 = Bus
    @State private var sens = 0          // 0 = Départs, 1 = Arrivées
    @State private var filtre = ""
    @State private var filtreOuvert = false

    private var lignes: [SnDepartGare] {
        let l = SnMoteur.tableau(gare: gare, arrivees: sens == 1, grandesLignes: reseau == 0)
        if filtre.isEmpty { return l }
        let q = filtre.lowercased()
        return l.filter { $0.lieu.lowercased().contains(q) }
    }

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: gare)
                chipsReseau
                SnSegment(items: ["Départs", "Arrivées"], selection: $sens)
                    .padding(.top, 8)
                champVers
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        if lignes.isEmpty { aucun }
                        SnCarte(marge: 0) {
                            ForEach(Array(lignes.enumerated()), id: \.element.id) { paire in
                                SnLigneHoraire(depart: paire.element)
                                if paire.offset < lignes.count - 1 {
                                    SnSeparateur().padding(.horizontal, 14)
                                }
                            }
                        }
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 12)
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var chipsReseau: some View {
        HStack(spacing: 12) {
            chip(index: 0, titre: "Grandes lignes", systeme: "tram.fill")
            chip(index: 1, titre: "Bus", systeme: "bus")
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    private func chip(index: Int, titre: String, systeme: String) -> some View {
        Button {
            reseau = index
        } label: {
            HStack(spacing: 8) {
                Image(systemName: systeme)
                    .font(.system(size: 15))
                Text(titre)
                    .font(.system(size: 16, weight: reseau == index ? Font.Weight.semibold : Font.Weight.regular))
            }
            .foregroundStyle(reseau == index ? Color(hex: 0x0E1420) : SnTeinte.texte)
            .padding(.horizontal, 20)
            .frame(height: 44)
            .background {
                Capsule().fill(reseau == index ? SnTeinte.accent : SnTeinte.carte)
            }
        }
        .buttonStyle(.plain)
    }

    private var champVers: some View {
        HStack(spacing: 10) {
            Text("Vers")
                .font(.system(size: 16))
                .foregroundStyle(SnTeinte.gris)
            if filtreOuvert {
                TextField("", text: $filtre,
                          prompt: Text("Toutes les gares").foregroundColor(SnTeinte.gris))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SnTeinte.texte)
                    .autocorrectionDisabled(true)
            } else {
                Text(filtre.isEmpty ? "Toutes les gares" : filtre)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SnTeinte.texte)
            }
            Spacer()
            Button {
                if filtreOuvert && !filtre.isEmpty {
                    filtre = ""
                } else {
                    filtreOuvert.toggle()
                }
            } label: {
                Image(systemName: filtreOuvert && !filtre.isEmpty
                      ? "xmark.circle.fill" : "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundStyle(SnTeinte.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(SnTeinte.carte)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    private var aucun: some View {
        Text("Aucun train vers « " + filtre + " » dans les prochaines heures.")
            .font(.system(size: 15))
            .foregroundStyle(SnTeinte.gris)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)
            .padding(.vertical, 40)
    }
}

struct SnLigneHoraire: View {
    let depart: SnDepartGare

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(depart.heure)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(depart.etat == .supprime ? SnTeinte.gris : SnTeinte.texte)
                    .strikethrough(depart.etat == .supprime, color: SnTeinte.gris)
                if depart.etat == .retard {
                    Text("+\(depart.minutes) min")
                        .font(.system(size: 13))
                        .foregroundStyle(SnTeinte.orange)
                }
            }
            .frame(width: 66, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text(depart.lieu)
                    .font(.system(size: 17))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.leading)
                HStack(spacing: 8) {
                    SnLogoTransporteur(nom: depart.transporteur, hauteur: 18)
                    Text(depart.numero + " – " + depart.materiel)
                        .font(.system(size: 13))
                        .foregroundStyle(SnTeinte.gris)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                etiquette
            }
            Spacer(minLength: 4)
            if depart.etat != .supprime {
                VStack(spacing: 0) {
                    Text("Voie")
                        .font(.system(size: 12))
                    Text(depart.voie)
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(SnTeinte.texte)
                .frame(width: 42, height: 44)
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(SnTeinte.texte, lineWidth: 1)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private var etiquette: some View {
        switch depart.etat {
        case .retard:
            marque(texte: "Retard estimé", systeme: "clock.fill", teinte: SnTeinte.orange)
        case .supprime:
            marque(texte: "Supprimé", systeme: "xmark.circle.fill", teinte: SnTeinte.rouge)
        case .modifie:
            marque(texte: "Parcours modifié", systeme: "exclamationmark.circle.fill",
                   teinte: SnTeinte.orange)
        case .normal:
            EmptyView()
        }
    }

    private func marque(texte: String, systeme: String, teinte: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systeme)
                .font(.system(size: 14))
            Text(texte)
                .font(.system(size: 14))
        }
        .foregroundStyle(teinte)
    }
}

// ------------------------------------------------------------ Info trafic et réseaux (e138)

struct SnTraficVue: View {
    @State private var onglet = 0
    static let colonnes = [GridItem(.adaptive(minimum: 54), spacing: 14)]

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Infos trafic et réseaux")
                SnSegment(items: ["Auvergne-Rhône-Alpes", "Grandes lignes"], selection: $onglet)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        if onglet == 0 { pastilles }
                        titrePerturbations
                        ForEach(perturbationsAffichees) { p in
                            NavigationLink {
                                SnPerturbationVue(perturbation: p)
                            } label: {
                                SnCartePerturbation(perturbation: p)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var perturbationsAffichees: [SnPerturbation] {
        onglet == 0 ? SnDonneesSncf.perturbations : []
    }

    private var pastilles: some View {
        SnCarte(marge: 16) {
            Text("Métro et tramway TCL")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .padding(.bottom, 12)
            LazyVGrid(columns: SnTraficVue.colonnes, alignment: .leading, spacing: 16) {
                ForEach(SnDonneesSncf.lignesRegion) { l in
                    pastille(l)
                }
            }
        }
    }

    private func pastille(_ l: SnLigneReseau) -> some View {
        SnPastilleLigne(ligne: l, taille: 34)
            .overlay(alignment: .topTrailing) {
                if l.code == "B" {
                    Circle().fill(SnTeinte.rouge)
                        .frame(width: 17, height: 17)
                        .overlay {
                            Image(systemName: "exclamationmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                        .offset(x: 7, y: -7)
                }
            }
    }

    @ViewBuilder
    private var titrePerturbations: some View {
        if perturbationsAffichees.isEmpty {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(SnTeinte.accent)
                Text("Aucune perturbation signalée sur les grandes lignes.")
                    .font(.system(size: 16))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 26)
        } else {
            HStack(spacing: 10) {
                Circle().fill(SnTeinte.rouge)
                    .frame(width: 26, height: 26)
                    .overlay {
                        Image(systemName: "exclamationmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                Text("Perturbations")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 10)
        }
    }
}

struct SnCartePerturbation: View {
    let perturbation: SnPerturbation
    var body: some View {
        SnCarte(marge: 14) {
            HStack(alignment: .top, spacing: 12) {
                SnPastilleLigne(ligne: SnLigneReseau(code: perturbation.ligne,
                                                     fond: perturbation.fond),
                                taille: 34)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Image(systemName: perturbation.grave
                              ? "exclamationmark.circle.fill" : "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(perturbation.grave ? SnTeinte.rouge : SnTeinte.bleuDoux)
                        Text(perturbation.niveau)
                            .font(.system(size: 14))
                            .foregroundStyle(perturbation.grave ? SnTeinte.rouge : SnTeinte.bleuDoux)
                    }
                    Text(perturbation.titre)
                        .font(.system(size: 16))
                        .foregroundStyle(SnTeinte.texte)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(SnTeinte.accent)
            }
        }
        .padding(.bottom, 12)
    }
}

struct SnPerturbationVue: View {
    let perturbation: SnPerturbation
    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Ligne " + perturbation.ligne)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        SnCarte(marge: 16) {
                            HStack(spacing: 12) {
                                SnPastilleLigne(ligne: SnLigneReseau(code: perturbation.ligne,
                                                                     fond: perturbation.fond),
                                                taille: 38)
                                Text(perturbation.niveau)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(perturbation.grave ? SnTeinte.rouge : SnTeinte.bleuDoux)
                                Spacer()
                            }
                            Text(perturbation.titre)
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(SnTeinte.texte)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 14)
                            Text(perturbation.corps)
                                .font(.system(size: 15))
                                .foregroundStyle(SnTeinte.gris)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 10)
                        }
                        .padding(.top, 8)
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ============================================================ ONGLET 2 — BILLETS (e145 / e147)

struct SnBilletsVue: View {
    @ObservedObject private var etat = SnEtat.partage
    @State private var segment = 0

    private var liste: [SnVoyage] { segment == 0 ? etat.voyages : etat.passes }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                SnGrandTitre(texte: "Billets")
                    .padding(.top, 14)
                SnTitreSection(texte: "Vos cartes et titres urbains", haut: 22)
                carteQr
                if !etat.panier.isEmpty { rappelPanier }
                SnTitreSection(texte: "Vos voyages", haut: 26)
                SnSegment(items: ["À venir", "Passés"], selection: $segment)
                if liste.isEmpty {
                    vide
                } else {
                    VStack(spacing: 12) {
                        ForEach(liste) { v in
                            NavigationLink {
                                SnVoyageVue(voyage: v)
                            } label: {
                                SnCarteVoyage(voyage: v)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 16)
                }
                alerte3117
                SnBlocAide().padding(.top, 22)
                Spacer(minLength: 26)
            }
        }
    }

    private var carteQr: some View {
        NavigationLink {
            SnQrCartesVue()
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "qrcode")
                    .font(.system(size: 30))
                    .foregroundStyle(SnTeinte.texte)
                Text("Votre QR code cartes SNCF")
                    .font(.system(size: 14))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 150, height: 128)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(SnTeinte.carte)
            }
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }

    private var rappelPanier: some View {
        NavigationLink {
            SnPanierVue()
        } label: {
            SnCarte(marge: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(SnTeinte.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Votre panier vous attend")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(SnTeinte.texte)
                        Text("\(etat.nombreArticles) voyage"
                             + (etat.nombreArticles > 1 ? "s" : "")
                             + " · " + SnFormat.prix(etat.total))
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(SnTeinte.accent)
                }
            }
            .padding(.top, 18)
        }
        .buttonStyle(.plain)
    }

    // État vide filmé (e145) — conservé comme repli si la liste sélectionnée est vide.
    private var vide: some View {
        VStack(spacing: 12) {
            Text(segment == 0
                 ? "Aucun voyage prévu pour le moment"
                 : "Vous n'avez pas encore fait de voyage avec SNCF Connect")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Text("Billet déjà acheté, option déjà posée ? Vous pouvez l'importer en haut "
                 + "de cette page.")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Image(systemName: "ticket")
                .font(.system(size: 54))
                .foregroundStyle(SnTeinte.bleuDoux)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
    }

    private var alerte3117: some View {
        NavigationLink {
            SnAlerteVue()
        } label: {
            SnCarte(marge: 14) {
                HStack(spacing: 14) {
                    Text("3117")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .frame(height: 34)
                        .background {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(SnTeinte.rouge)
                        }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Numéro d'alerte 3117")
                            .font(.system(size: 16))
                            .foregroundStyle(SnTeinte.texte)
                        Text("Un risque pour votre sécurité ou celle des autres ?")
                            .font(.system(size: 13))
                            .foregroundStyle(SnTeinte.gris)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(SnTeinte.accent)
                }
            }
            .padding(.top, 26)
        }
        .buttonStyle(.plain)
    }
}

/// Carte d'un voyage dans « Vos voyages ».
struct SnCarteVoyage: View {
    let voyage: SnVoyage

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                SnLogoTransporteur(nom: voyage.transporteur, hauteur: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(voyage.depart)
                        .font(.system(size: 16))
                        .foregroundStyle(SnTeinte.texte)
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13))
                            .foregroundStyle(SnTeinte.texte)
                        Text(voyage.arrivee)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(SnTeinte.texte)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(voyage.genre == .option ? SnTeinte.orange : SnTeinte.teal)

            VStack(alignment: .leading, spacing: 8) {
                Text(voyage.jour)
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                HStack {
                    Text(voyage.heureDepart + " → " + voyage.heureArrivee)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                    Spacer()
                    Text(SnFormat.prix(voyage.prix))
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                }
                HStack(spacing: 8) {
                    Image(systemName: voyage.genre == .option ? "clock.badge.exclamationmark" : "ticket")
                        .font(.system(size: 14))
                        .foregroundStyle(voyage.genre == .option ? SnTeinte.orange : SnTeinte.gris)
                    Text(voyage.mention)
                        .font(.system(size: 14))
                        .foregroundStyle(voyage.genre == .option ? SnTeinte.orange : SnTeinte.gris)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(SnTeinte.accent)
                }
            }
            .padding(14)
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(SnTeinte.carte)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
    }
}

// ------------------------------------------------------------ Détail d'un voyage

struct SnVoyageVue: View {
    let voyage: SnVoyage
    @ObservedObject private var etat = SnEtat.partage
    @Environment(\.dismiss) private var revenir

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: voyage.arrivee)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        SnCarteVoyage(voyage: voyage).padding(.top, 8)
                        details
                        actions
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var rubriques: [(String, String)] {
        [("Numéro de dossier", voyage.dossier),
         ("Train", voyage.transporteur + " n° " + voyage.numero),
         ("Classe", voyage.classe),
         ("Place", voyage.voiture == "—"
            ? voyage.place
            : "Voiture " + voyage.voiture + " · place " + voyage.place),
         ("Voyageur", etat.identite.prenom + " " + etat.identite.nom),
         ("Tarif", etat.carte.nom)]
    }

    private var details: some View {
        SnGroupe {
            ForEach(Array(rubriques.enumerated()), id: \.offset) { paire in
                SnLigneValeur(cle: paire.element.0, valeur: paire.element.1)
                if paire.offset < rubriques.count - 1 {
                    SnSeparateur().padding(.horizontal, 16)
                }
            }
        }
        .padding(.top, 18)
    }

    @ViewBuilder
    private var actions: some View {
        if voyage.genre == .billet && !voyage.passe {
            NavigationLink {
                SnBilletVue(voyage: voyage)
            } label: {
                SnPiluleCyan(titre: "Afficher le billet")
                    .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            .padding(.top, 22)
        } else if voyage.genre == .option {
            VStack(spacing: 12) {
                Text("Cette option bloque votre prix sans paiement. Passé le délai, elle "
                     + "expire et rien ne vous est débité.")
                    .font(.system(size: 14))
                    .foregroundStyle(SnTeinte.gris)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                Button {
                    etat.annuler(voyage)
                    revenir()
                } label: {
                    SnPiluleCreuse(titre: "Annuler l'option")
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 22)
        } else {
            Text("Voyage terminé — justificatif disponible pendant 12 mois.")
                .font(.system(size: 14))
                .foregroundStyle(SnTeinte.gris)
                .padding(.horizontal, 16)
                .padding(.top, 22)
        }
    }
}

struct SnLigneValeur: View {
    let cle: String
    let valeur: String
    var body: some View {
        HStack(alignment: .top) {
            Text(cle)
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
            Spacer(minLength: 12)
            Text(valeur)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(SnTeinte.texte)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// ------------------------------------------------------------ Billet plein écran (QR dessiné)

struct SnBilletVue: View {
    let voyage: SnVoyage
    @ObservedObject private var etat = SnEtat.partage
    @State private var wallet = false

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Votre billet")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        carteBillet
                        boutonWallet
                        conditions
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
        // D82-B : Wallet n'existe pas dans le prototype — message crédible façon iOS.
        .alert("Impossible d'ajouter à Apple Wallet", isPresented: $wallet) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Ce billet n'a pas pu être ajouté pour le moment. Réessayez plus tard.")
        }
    }

    private var carteBillet: some View {
        VStack(spacing: 0) {
            HStack {
                SnLogoTransporteur(nom: voyage.transporteur, hauteur: 32)
                Spacer()
                Text(voyage.classe)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(SnTeinte.texte)
            }
            .padding(16)
            .background(SnTeinte.teal)

            VStack(spacing: 14) {
                Text(voyage.jour)
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                HStack(alignment: .top, spacing: 12) {
                    coteGare(heure: voyage.heureDepart, gare: voyage.depart, alignement: .leading)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16))
                        .foregroundStyle(SnTeinte.accent)
                        .padding(.top, 6)
                    coteGare(heure: voyage.heureArrivee, gare: voyage.arrivee, alignement: .trailing)
                }
                SnQrCode(graine: voyage.dossier + voyage.numero, cote: 176)
                    .padding(.top, 6)
                Text("Dossier " + voyage.dossier)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                Text(etat.identite.prenom.uppercased() + " " + etat.identite.nom.uppercased())
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                HStack(spacing: 22) {
                    bloc(cle: "Train", valeur: voyage.numero)
                    if voyage.voiture != "—" {
                        bloc(cle: "Voiture", valeur: voyage.voiture)
                        bloc(cle: "Place", valeur: voyage.place)
                    } else {
                        bloc(cle: "Placement", valeur: "Libre")
                    }
                }
                .padding(.top, 4)
            }
            .padding(18)
        }
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(SnTeinte.carte)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func coteGare(heure: String, gare: String,
                          alignement: HorizontalAlignment) -> some View {
        VStack(alignment: alignement, spacing: 3) {
            Text(heure)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            Text(gare)
                .font(.system(size: 14))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(alignement == .leading ? TextAlignment.leading : TextAlignment.trailing)
        }
        .frame(maxWidth: .infinity, alignment: alignement == .leading ? Alignment.leading : Alignment.trailing)
    }

    private func bloc(cle: String, valeur: String) -> some View {
        VStack(spacing: 2) {
            Text(cle)
                .font(.system(size: 12))
                .foregroundStyle(SnTeinte.gris)
            Text(valeur)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
        }
    }

    private var boutonWallet: some View {
        SnBoutonCyan(titre: "Ajouter à Apple Wallet") { wallet = true }
            .padding(.horizontal, 16)
            .padding(.top, 18)
    }

    private var conditions: some View {
        SnCarte(marge: 16) {
            Text("Conditions")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(SnTeinte.texte)
            Text("Présentez ce QR code au contrôleur, avec une pièce d'identité. "
                 + "Billet nominatif, échangeable et remboursable sans frais jusqu'à "
                 + "3 jours avant le départ, puis 19 € de frais. " + voyage.mention + ".")
                .font(.system(size: 14))
                .foregroundStyle(SnTeinte.gris)
                .multilineTextAlignment(.leading)
                .padding(.top, 8)
        }
        .padding(.top, 18)
    }
}

// ------------------------------------------------------------ QR code des cartes SNCF (e143)

struct SnQrCartesVue: View {
    @ObservedObject private var etat = SnEtat.partage
    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "QR code de vos cartes SNCF")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        SnQrCode(graine: etat.carte.numero, cote: 210)
                            .padding(.top, 20)
                        Text(etat.carte.nom)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(SnTeinte.texte)
                        Text(etat.identite.prenom + " " + etat.identite.nom)
                            .font(.system(size: 16))
                            .foregroundStyle(SnTeinte.texte)
                        Text("N° " + etat.carte.numero)
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.gris)
                        Text(etat.carte.validite)
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.gris)
                        Text("Présentez ce code au contrôleur : il justifie la réduction "
                             + "appliquée sur vos billets.")
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 8)
                        Spacer(minLength: 30)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ------------------------------------------------------------ Numéro d'alerte 3117 (e147)

struct SnAlerteVue: View {
    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Numéro d'alerte")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        SnCarte(marge: 16) {
                            Text("3117")
                                .font(.system(size: 30, weight: .heavy))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 14)
                                .frame(height: 54)
                                .background {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(SnTeinte.rouge)
                                }
                            Text("Un risque pour votre sécurité ou celle des autres ?")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(SnTeinte.texte)
                                .padding(.top, 14)
                            Text("Appelez le 3117 ou envoyez un SMS au 31177. Ce numéro "
                                 + "d'alerte est disponible 24 h/24 dans toutes les gares "
                                 + "et tous les trains SNCF. Vos échanges restent "
                                 + "confidentiels.")
                                .font(.system(size: 15))
                                .foregroundStyle(SnTeinte.gris)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 10)
                        }
                        .padding(.top, 8)
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ============================================================ ONGLET 3 — OFFRES (e154)

struct SnOffresVue: View {
    @State private var recherche = ""

    private var offres: [SnOffre] {
        if recherche.isEmpty { return SnDonneesSncf.offres }
        let q = recherche.lowercased()
        return SnDonneesSncf.offres.filter {
            $0.nom.lowercased().contains(q) || $0.tranche.lowercased().contains(q)
                || $0.corps.lowercased().contains(q)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                SnGrandTitre(texte: "Offres")
                    .padding(.top, 14)
                champ
                SnTitreSection(texte: "Cartes et abonnements SNCF", haut: 24)
                if offres.isEmpty {
                    Text("Aucune offre ne correspond à « " + recherche + " ».")
                        .font(.system(size: 15))
                        .foregroundStyle(SnTeinte.gris)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 30)
                }
                VStack(spacing: 12) {
                    ForEach(offres) { o in
                        NavigationLink {
                            SnOffreVue(offre: o)
                        } label: {
                            carte(o)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer(minLength: 26)
            }
        }
    }

    private var champ: some View {
        HStack(spacing: 10) {
            TextField("", text: $recherche,
                      prompt: Text("Carte, abonnement, région")
                        .foregroundColor(Color(hex: 0x5A6270)))
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: 0x0E1420))
                .autocorrectionDisabled(true)
            if !recherche.isEmpty {
                Button {
                    recherche = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: 0x8C93A1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 52)
        .background { Capsule().fill(Color.white) }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private func carte(_ o: SnOffre) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: o.teinte),
                                              Color(hex: o.teinte).opacity(0.45)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 92)
                .overlay(alignment: .bottomLeading) {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .padding(14)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(o.nom)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                Text(o.tranche)
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                HStack {
                    Spacer()
                    Text(o.prix)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                }
                .padding(.top, 6)
            }
            .padding(14)
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(SnTeinte.carte)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
    }
}

struct SnOffreVue: View {
    let offre: SnOffre
    @ObservedObject private var etat = SnEtat.partage

    private var possedee: Bool { offre.nom == etat.carte.nom }

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: offre.nom)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        SnCarte(marge: 16, teinte: Color(hex: offre.teinte)) {
                            Text(offre.nom)
                                .font(.system(size: 22, weight: .heavy))
                                .foregroundStyle(SnTeinte.texte)
                            Text(offre.tranche)
                                .font(.system(size: 16))
                                .foregroundStyle(SnTeinte.texte)
                                .padding(.top, 4)
                            Text(offre.prix)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(SnTeinte.texte)
                                .padding(.top, 18)
                        }
                        .padding(.top, 8)
                        SnCarte(marge: 16) {
                            Text(offre.corps)
                                .font(.system(size: 15))
                                .foregroundStyle(SnTeinte.gris)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.top, 14)
                        etatCarte
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var etatCarte: some View {
        if possedee {
            NavigationLink {
                SnCartesReductionVue()
            } label: {
                SnCarte(marge: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(SnTeinte.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Vous possédez déjà cette carte")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(SnTeinte.texte)
                            Text(etat.carte.validite)
                                .font(.system(size: 14))
                                .foregroundStyle(SnTeinte.gris)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(SnTeinte.accent)
                    }
                }
                .padding(.top, 14)
            }
            .buttonStyle(.plain)
        } else {
            Text("Cette carte n'est pas rattachée à votre compte.")
                .font(.system(size: 14))
                .foregroundStyle(SnTeinte.gris)
                .padding(.horizontal, 16)
                .padding(.top, 18)
        }
    }
}

// ============================================================ ONGLET 4 — COMPTE (e155 / e167)

struct SnCompteVue: View {
    @Binding var onglet: Int
    @ObservedObject private var etat = SnEtat.partage

    init(onglet: Binding<Int>) {
        _onglet = onglet
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                reglages
                enTeteProfil
                blocCartes
                blocPreferences
                blocAchats
                Spacer(minLength: 26)
            }
        }
    }

    private var blocCartes: some View {
        VStack(alignment: .leading, spacing: 0) {
            SnTitreSection(texte: "Cartes de réduction et fidélité", haut: 24)
            cartesReduction
        }
    }

    private var blocPreferences: some View {
        VStack(alignment: .leading, spacing: 0) {
            SnTitreSection(texte: "Préférences de voyage", haut: 24)
            compagnons
            SnTitreSection(texte: "Besoin d'aide ?", haut: 24)
            aide
        }
    }

    private var blocAchats: some View {
        VStack(alignment: .leading, spacing: 0) {
            SnTitreSection(texte: "Achats", haut: 24)
            achats
        }
    }

    private var reglages: some View {
        HStack {
            Spacer()
            NavigationLink {
                SnParametresVue()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 22))
                    .foregroundStyle(SnTeinte.texte)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private var enTeteProfil: some View {
        NavigationLink {
            SnCoordonneesVue()
        } label: {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(hex: 0xE9A8C9))
                    .frame(width: 62, height: 62)
                    .overlay {
                        Text("SL")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(hex: 0x2A1A22))
                    }
                VStack(alignment: .leading, spacing: 3) {
                    Text(etat.identite.prenom + " " + etat.identite.nom)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(SnTeinte.texte)
                    Text("Infos de votre compte, préférences…")
                        .font(.system(size: 15))
                        .foregroundStyle(SnTeinte.gris)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SnTeinte.accent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var cartesReduction: some View {
        VStack(spacing: 12) {
            NavigationLink {
                SnQrCartesVue()
            } label: {
                SnCarte(marge: 0) {
                    SnLigneChevron(titre: "QR code de vos cartes SNCF", systeme: "qrcode")
                }
            }
            .buttonStyle(.plain)
            NavigationLink {
                SnCartesReductionVue()
            } label: {
                SnCarte(marge: 0) {
                    SnLigneChevron(titre: "Vos cartes de réduction et fidélité")
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var compagnons: some View {
        NavigationLink {
            SnCompagnonsVue()
        } label: {
            SnCarte(marge: 0) {
                SnLigneChevron(titre: "Vos compagnons")
            }
        }
        .buttonStyle(.plain)
    }

    private var aide: some View {
        NavigationLink {
            SnAideVue(question: "")
        } label: {
            SnCarte(marge: 0) {
                SnLigneChevron(titre: "Aide en ligne, accessibilité et messagerie")
            }
        }
        .buttonStyle(.plain)
    }

    private var achats: some View {
        VStack(spacing: 12) {
            Button {
                onglet = 1
            } label: {
                SnCarte(marge: 0) {
                    SnLigneChevron(titre: "Voir vos titres de transport",
                                   detail: "Vos billets, options et justificatifs de voyage…")
                }
            }
            .buttonStyle(.plain)
            NavigationLink {
                SnMoyensPaiementVue()
            } label: {
                SnCarte(marge: 0) {
                    SnLigneChevron(titre: "Vos moyens de paiement",
                                   detail: "Visa LCL •••• 4417")
                }
            }
            .buttonStyle(.plain)
            NavigationLink {
                SnAlertesBilletsVue()
            } label: {
                SnCarte(marge: 0) {
                    SnLigneChevron(titre: "Alertes billets disponibles",
                                   detail: "Pour être prévenue dès qu'un billet qui vous "
                                         + "intéresse est disponible.")
                }
            }
            .buttonStyle(.plain)
            NavigationLink {
                SnAlerteVue()
            } label: {
                SnCarte(marge: 0) {
                    SnLigneChevron(titre: "Numéro d'alerte 3117",
                                   detail: "Un risque pour votre sécurité ou celle des autres ?")
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// ------------------------------------------------------------ Vos coordonnées (e156)

struct SnCoordonneesVue: View {
    @ObservedObject private var etat = SnEtat.partage
    @State private var identiteOuverte = false

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Vos coordonnées")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        SnTitreSection(texte: "Coordonnées perso", haut: 12)
                        fiche
                        adresse
                        courriel
                        SnTitreSection(texte: "Votre compte", haut: 24)
                        motDePasse
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
        // Recouvrement interne (jamais .sheet) : la BarreHome reste visible.
        .overlay {
            if identiteOuverte {
                SnIdentiteVue { identiteOuverte = false }
            }
        }
    }

    private var fiche: some View {
        Button {
            identiteOuverte = true
        } label: {
            SnCarte(marge: 14) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(Color(hex: 0xE9A8C9))
                        .frame(width: 52, height: 52)
                        .overlay {
                            Text("SL")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(Color(hex: 0x2A1A22))
                        }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(etat.identite.prenom + " " + etat.identite.nom)
                            .font(.system(size: 17))
                            .foregroundStyle(SnTeinte.texte)
                        Text(etat.identite.naissance)
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.gris)
                        Text(etat.identite.telephone)
                            .font(.system(size: 15))
                            .foregroundStyle(SnTeinte.gris)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(SnTeinte.accent)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var adresse: some View {
        SnCarte(marge: 14) {
            Text("Adresse")
                .font(.system(size: 16))
                .foregroundStyle(SnTeinte.texte)
            Text(etat.identite.adresse)
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .padding(.top, 4)
        }
        .padding(.top, 12)
    }

    private var courriel: some View {
        SnCarte(marge: 14) {
            Text("Adresse e-mail")
                .font(.system(size: 16))
                .foregroundStyle(SnTeinte.texte)
            Text(etat.identite.email)
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .padding(.top, 4)
        }
        .padding(.top, 12)
    }

    private var motDePasse: some View {
        SnCarte(marge: 14) {
            Text("Mot de passe")
                .font(.system(size: 16))
                .foregroundStyle(SnTeinte.texte)
            Text("xxxxxxxxxx")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.gris)
                .padding(.top, 4)
        }
    }
}

// ------------------------------------------------------------ Identité (e158) — recouvrement interne

struct SnIdentiteVue: View {
    let fermer: () -> Void
    @ObservedObject private var etat = SnEtat.partage
    @State private var prenom = ""
    @State private var nom = ""
    @State private var naissance = ""
    @State private var telephone = ""
    @State private var enregistre = false

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreFeuille(titre: "Identité", fermer: fermer)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("*champs obligatoires")
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                            .padding(.horizontal, 16)
                        champ(etiquette: "*Prénom", valeur: $prenom)
                        champ(etiquette: "*Nom", valeur: $nom)
                        champ(etiquette: "*Date de naissance (JJ/MM/AAAA)", valeur: $naissance)
                        champ(etiquette: "Numéro de téléphone", valeur: $telephone)
                        Text("SNCF Connect traite les données pour la gestion du compte. "
                             + "Pour en savoir plus et exercer vos droits, consultez les "
                             + "mentions légales.")
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16)
                        if enregistre {
                            Text("Modifications enregistrées.")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(SnTeinte.accent)
                                .padding(.horizontal, 16)
                        }
                        SnBoutonCyan(titre: "Enregistrer") {
                            etat.identite.prenom = prenom
                            etat.identite.nom = nom
                            etat.identite.naissance = naissance
                            etat.identite.telephone = telephone
                            enregistre = true
                        }
                        .padding(.horizontal, 60)
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.bottom, 22)
        }
        .onAppear {
            prenom = etat.identite.prenom
            nom = etat.identite.nom
            naissance = etat.identite.naissance
            telephone = etat.identite.telephone
        }
    }

    private func champ(etiquette: String, valeur: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("", text: valeur)
                .font(.system(size: 17))
                .foregroundStyle(SnTeinte.texte)
                .autocorrectionDisabled(true)
                .padding(.horizontal, 16)
                .frame(height: 58)
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(SnTeinte.texte, lineWidth: 1)
                }
                .overlay(alignment: .topLeading) {
                    Text(etiquette)
                        .font(.system(size: 13))
                        .foregroundStyle(SnTeinte.texte)
                        .padding(.horizontal, 5)
                        .background(SnTeinte.fond)
                        .offset(x: 12, y: -8)
                }
        }
        .padding(.horizontal, 16)
    }
}

// ------------------------------------------------------------ Paramètres (e173 / e175)

struct SnParametresVue: View {
    @ObservedObject private var etat = SnEtat.partage

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Paramètres")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        SnTitreSection(texte: "Consentements", haut: 12)
                        consentements
                        SnTitreSection(texte: "Paramètres avancés", haut: 24)
                        avances
                        Text("Version 20260730.0.0-2026")
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 26)
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var consentements: some View {
        SnGroupe {
            SnInterrupteur(titre: "Offres proposées sur l'accueil",
                           detail: "Selon votre position et vos voyages à venir.",
                           valeur: $etat.offresAccueil)
            SnSeparateur().padding(.horizontal, 16)
            SnInterrupteur(titre: "Notifications",
                           detail: "Infos et perturbations sur vos trajets, disponibilité "
                                 + "des billets qui vous intéressent…",
                           valeur: $etat.notificationsActives)
        }
    }

    private var avances: some View {
        SnGroupe {
            NavigationLink {
                SnAffichageVue()
            } label: {
                SnLigneChevron(titre: "Préférences d'affichage",
                               detail: etat.theme, systeme: "iphone")
            }
            .buttonStyle(.plain)
            SnSeparateur().padding(.horizontal, 16)
            NavigationLink {
                SnLangueVue()
            } label: {
                SnLigneChevron(titre: "Langue de l'application",
                               detail: etat.langue, systeme: "globe")
            }
            .buttonStyle(.plain)
            SnSeparateur().padding(.horizontal, 16)
            SnInterrupteur(titre: "Afficher le numéro de circulation de tous les trains",
                           detail: "", valeur: $etat.numeroCirculation)
            SnSeparateur().padding(.horizontal, 16)
            SnInterrupteur(titre: "Annonces à bord",
                           detail: "Soyez informée par notifications des annonces "
                                 + "délivrées par le chef de bord durant votre voyage "
                                 + "(TGV INOUI, OUIGO, INTERCITÉS et TER).",
                           valeur: $etat.annoncesBord)
        }
    }
}

struct SnInterrupteur: View {
    let titre: String
    var detail: String = ""
    @Binding var valeur: Bool

    var body: some View {
        Toggle(isOn: $valeur) {
            VStack(alignment: .leading, spacing: 3) {
                Text(titre)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.leading)
                if !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 14))
                        .foregroundStyle(SnTeinte.gris)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .tint(SnTeinte.accent)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct SnAffichageVue: View {
    @ObservedObject private var etat = SnEtat.partage
    private let choix = ["Sombre", "Clair", "Automatique"]
    var body: some View {
        SnListeChoix(titre: "Préférences d'affichage", choix: choix,
                     detail: "Le thème sombre est celui utilisé dans les gares et les "
                           + "trains : il fatigue moins les yeux.",
                     selection: $etat.theme)
    }
}

struct SnLangueVue: View {
    @ObservedObject private var etat = SnEtat.partage
    private let choix = ["Français", "English", "Deutsch", "Español", "Italiano"]
    var body: some View {
        SnListeChoix(titre: "Langue de l'application", choix: choix,
                     detail: "La langue s'applique à l'application et aux e-mails de "
                           + "confirmation.",
                     selection: $etat.langue)
    }
}

struct SnListeChoix: View {
    let titre: String
    let choix: [String]
    let detail: String
    @Binding var selection: String

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: titre)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(detail)
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 14)
                        SnGroupe {
                            ForEach(Array(choix.enumerated()), id: \.offset) { paire in
                                Button {
                                    selection = paire.element
                                } label: {
                                    HStack {
                                        Text(paire.element)
                                            .font(.system(size: 16))
                                            .foregroundStyle(SnTeinte.texte)
                                        Spacer()
                                        if selection == paire.element {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(SnTeinte.accent)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                if paire.offset < choix.count - 1 {
                                    SnSeparateur().padding(.horizontal, 16)
                                }
                            }
                        }
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ------------------------------------------------------------ Cartes de réduction (D93 — officiel/05_04)

struct SnCartesReductionVue: View {
    @ObservedObject private var etat = SnEtat.partage
    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Cartes de réduction et fidélité")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        visuel
                        NavigationLink {
                            SnQrCartesVue()
                        } label: {
                            SnCarte(marge: 0) {
                                SnLigneChevron(titre: "Afficher le QR code de la carte",
                                               systeme: "qrcode")
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 14)
                        Text("Aucune carte de fidélité n'est rattachée à ce compte.")
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var visuel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: 0x2C5F7A), Color(hex: 0x16303F)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 86)
                .overlay(alignment: .topLeading) {
                    Text("AVANTAGE")
                        .font(.system(size: 20, weight: .heavy))
                        .kerning(2)
                        .foregroundStyle(Color.white)
                        .padding(16)
                }
            VStack(alignment: .leading, spacing: 5) {
                Text(etat.carte.nom)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                Text(etat.carte.detail)
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.gris)
                Text(etat.identite.prenom + " " + etat.identite.nom)
                    .font(.system(size: 15))
                    .foregroundStyle(SnTeinte.texte)
                    .padding(.top, 6)
                Text("N° " + etat.carte.numero)
                    .font(.system(size: 14))
                    .foregroundStyle(SnTeinte.gris)
                Text(etat.carte.validite)
                    .font(.system(size: 14))
                    .foregroundStyle(SnTeinte.gris)
            }
            .padding(16)
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(SnTeinte.carte)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// ------------------------------------------------------------ Moyens de paiement

struct SnMoyensPaiementVue: View {
    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Vos moyens de paiement")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        carteVisa
                        Text("La carte enregistrée sert aux paiements et aux "
                             + "remboursements. Elle n'est jamais partagée avec les "
                             + "transporteurs.")
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 18)
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var carteVisa: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0x0B2E5C), Color(hex: 0x061C3A)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text("LCL")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(Color(hex: 0xF5C400))
                    Spacer()
                    Text("VISA")
                        .font(.system(size: 17, weight: .heavy))
                        .italic()
                        .foregroundStyle(Color.white)
                }
                Spacer()
                Text("•••• •••• •••• 4417")
                    .font(.system(size: 17, weight: .semibold))
                    .kerning(1.5)
                    .foregroundStyle(Color.white)
                Text("SARAH LEVASSEUR — 11/28")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.top, 6)
            }
            .padding(16)
        }
        .frame(height: 130)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// ------------------------------------------------------------ Alertes billets (D93 — officiel/06_05)

struct SnAlertesBilletsVue: View {
    @ObservedObject private var etat = SnEtat.partage
    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Alertes billets disponibles")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        SnGroupe {
                            SnInterrupteur(titre: "Alertes petits prix",
                                           detail: "Pour ne jamais rater une bonne affaire.",
                                           valeur: $etat.alertePetitsPrix)
                            SnSeparateur().padding(.horizontal, 16)
                            SnInterrupteur(titre: "Alertes réservation",
                                           detail: "Pour être prévenue de la mise en vente "
                                                 + "des billets qui vous intéressent.",
                                           valeur: $etat.alerteReservation)
                            SnSeparateur().padding(.horizontal, 16)
                            SnInterrupteur(titre: "Alertes train complet",
                                           detail: "Pour être prévenue si une place se "
                                                 + "libère sur un train complet.",
                                           valeur: $etat.alerteTrainComplet)
                        }
                        .padding(.top, 10)
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ------------------------------------------------------------ Vos compagnons

struct SnCompagnonsVue: View {
    @ObservedObject private var etat = SnEtat.partage
    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Vos compagnons")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        SnCarte(marge: 14) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(Color(hex: 0xE9A8C9))
                                    .frame(width: 46, height: 46)
                                    .overlay {
                                        Text("SL")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundStyle(Color(hex: 0x2A1A22))
                                    }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(etat.identite.prenom + " " + etat.identite.nom)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(SnTeinte.texte)
                                    Text("Vous · " + etat.carte.nom)
                                        .font(.system(size: 14))
                                        .foregroundStyle(SnTeinte.gris)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.top, 8)
                        Text("Aucun compagnon de voyage enregistré. Les compagnons "
                             + "permettent de pré-remplir les billets pour vos proches.")
                            .font(.system(size: 14))
                            .foregroundStyle(SnTeinte.gris)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 18)
                        Spacer(minLength: 30)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ------------------------------------------------------------ Notifications — état vide (e185)

struct SnNotificationsVue: View {
    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreTitre(titre: "Notifications")
                Spacer()
                Image(systemName: "bell")
                    .font(.system(size: 62, weight: .light))
                    .foregroundStyle(SnTeinte.bleuDoux)
                Text("Retrouvez vos notifications ici")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                Text("Infos sur vos trajets, n° de quai, bons plans…")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SnTeinte.texte)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                Spacer()
                Spacer()
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ------------------------------------------------------------ Chatbot d'aide (e190 / e194)

struct SnAideVue: View {
    let question: String
    @ObservedObject private var etat = SnEtat.partage
    @Environment(\.dismiss) private var revenir
    @State private var saisie = ""
    @State private var envoyee = false

    var body: some View {
        ZStack {
            SnTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                SnBarreFeuille(titre: "") { revenir() }
                entete
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(etat.messages) { m in
                            SnBulle(message: m)
                        }
                        Spacer(minLength: 20)
                    }
                    .padding(.top, 10)
                }
                champ
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !question.isEmpty && !envoyee {
                envoyee = true
                etat.envoyer(question)
            }
        }
    }

    private var entete: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nous traitons vos données conformément à notre charte de confidentialité.")
                .font(.system(size: 16))
                .foregroundStyle(SnTeinte.texte)
                .multilineTextAlignment(.leading)
            Text("En savoir plus sur la charte de confidentialité")
                .font(.system(size: 15))
                .foregroundStyle(SnTeinte.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }

    private var champ: some View {
        HStack(spacing: 10) {
            TextField("", text: $saisie,
                      prompt: Text("Écrivez votre message…").foregroundColor(SnTeinte.gris))
                .font(.system(size: 16))
                .foregroundStyle(SnTeinte.texte)
                .autocorrectionDisabled(true)
                .padding(.horizontal, 18)
                .frame(height: 52)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(SnTeinte.carte)
                }
            Button {
                etat.envoyer(saisie)
                saisie = ""
            } label: {
                Circle()
                    .fill(saisie.isEmpty ? Color(hex: 0x243044) : SnTeinte.accent)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(saisie.isEmpty ? SnTeinte.gris : Color(hex: 0x0E1420))
                    }
            }
            .buttonStyle(.plain)
            .disabled(saisie.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

struct SnBulle: View {
    let message: SnMessageBot
    var body: some View {
        HStack {
            if !message.duBot { Spacer(minLength: 50) }
            Text(message.texte)
                .font(.system(size: 16))
                .foregroundStyle(message.duBot ? SnTeinte.texte : Color(hex: 0x0E1420))
                .multilineTextAlignment(.leading)
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(message.duBot ? SnTeinte.carte : SnTeinte.bleuDoux)
                }
            if message.duBot { Spacer(minLength: 50) }
        }
        .padding(.horizontal, 16)
    }
}
