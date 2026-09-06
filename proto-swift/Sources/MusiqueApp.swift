// Musique v1 D92 (06/09) — construit contre les 180 frames de Joachim
// Apple Music iOS 26, schéma sombre (fond noir pur, accent rouge 0xFA2D48), barre d'onglets
// flottante Accueil / Nouveautés / Radio / Bibliothèque + loupe séparée, mini-lecteur en capsule.
// Écrans FILMÉS reproduits : Accueil « Pour vous », Écoutés récemment, Nouveautés, Titres du
// moment, Radio, Bibliothèque (Playlists / Artistes / Albums / Morceaux / Téléchargements),
// playlist ouverte, album ouvert, artiste ouvert, lecteur plein écran, file d'attente, Rechercher
// (tuiles + résultats réels). Le non filmé (Compte Apple, Réglages Musique, Concerts, Classements)
// est retiré — D82-C.
// D92 : les compteurs annoncent EXACTEMENT ce qui est accessible (127 morceaux réels, 13 albums,
// 13 artistes, playlists dont le nombre de titres est calculé). Aucune affordance décorative.
// D59 : univers de Sarah Levasseur (cohérent avec SpotifyApp : Jul, Ninho, Rim'K, GIMS, Angèle,
// Marine, Bad Bunny, Elderbrook & Bob Moses…) ; la playlist « Marseille — le 28 ⚓️ » fait écho à
// la note « Idées week-end Marseille » — indice discret.
// D51 : aucun fichier audio dans le projet, la lecture est un ÉTAT (progression animée) partagé
// par le mini-lecteur, le lecteur plein écran et la file d'attente.
import SwiftUI

// ============================================================ COULEURS
let muRouge = Color(hex: 0xFA2D48)
let muFond = Color.black
let muGris = Color(hex: 0x8E8E93)
let muSeparateur = Color(hex: 0x2C2C2E)
let muCarte = Color(hex: 0x1C1C1E)

// ============================================================ DONNÉES
struct MuMorceau: Identifiable {
    let id: Int
    let titre: String
    let artiste: String
    let album: String
    let piste: Int
    let duree: Int
}

struct MuAlbum: Identifiable {
    let id: Int
    let titre: String
    let artiste: String
    let genre: String
    let annee: String
    let teinte: UInt
    let dateTexte: String
    let copyright: String
    let resume: String
}

struct MuPlaylist: Identifiable {
    let id: Int
    let titre: String
    let auteur: String
    let teinte: UInt
    let teinte2: UInt
    let resume: String
    let titresRef: [String]
}

struct MuStation: Identifiable {
    let id: Int
    let nom: String
    let logo: String
    let teinteLogo: UInt
    let sousTitre: String
    let emission: String
    let creneau: String
    let accroche: String
}

struct MuEmission: Identifiable {
    let id: Int
    let titre: String
    let animateur: String
    let resume: String
    let teinte: UInt
}

enum MuDonnees {
    // ---------- 13 albums, 127 morceaux (le compteur de Réglages est tenu à la piste près)
    static let albums: [MuAlbum] = [
        MuAlbum(id: 0, titre: "Nonante-Cinq", artiste: "Angèle", genre: "Pop française", annee: "2021",
                teinte: 0xE84D8A, dateTexte: "10 décembre 2021", copyright: "℗ 2021 Angèle VL Records",
                resume: "Le deuxième album d'Angèle, écrit entre Bruxelles et Paris : des chansons de rupture qui se dansent quand même."),
        MuAlbum(id: 1, titre: "Back to Black", artiste: "Amy Winehouse", genre: "Soul", annee: "2006",
                teinte: 0x6B4226, dateTexte: "27 octobre 2006", copyright: "℗ 2006 Island Records",
                resume: "Onze titres de soul écorchée qui ont redéfini la pop britannique des années 2000."),
        MuAlbum(id: 2, titre: "DeBÍ TiRAR MáS FOToS", artiste: "Bad Bunny", genre: "Latin", annee: "2025",
                teinte: 0x4E7A34, dateTexte: "5 janvier 2025", copyright: "℗ 2024 Rimas Entertainment LLC",
                resume: "Nombre d'artistes portoricains ont exprimé leur amour et leur fierté pour leur île à travers leur musique ; Bad Bunny en fait ici un album entier."),
        MuAlbum(id: 3, titre: "Le Fléau", artiste: "GIMS", genre: "Rap français", annee: "2020",
                teinte: 0x355070, dateTexte: "28 août 2020", copyright: "℗ 2020 Play Two",
                resume: "Un album charnière : le rap, la variété et l'orchestre dans le même mouchoir."),
        MuAlbum(id: 4, titre: "La Machine", artiste: "Jul", genre: "Rap français", annee: "2020",
                teinte: 0x6D597A, dateTexte: "9 octobre 2020", copyright: "℗ 2020 D'or et de platine",
                resume: "Marseille de bout en bout : l'album le plus solaire et le plus mélancolique de Jul à la fois."),
        MuAlbum(id: 5, titre: "Jefe", artiste: "Ninho", genre: "Rap français", annee: "2019",
                teinte: 0x2C2C2E, dateTexte: "6 septembre 2019", copyright: "℗ 2019 Warner Music France",
                resume: "Dix titres taillés pour la voiture, entre confidences et démonstrations."),
        MuAlbum(id: 6, titre: "After Hours", artiste: "The Weeknd", genre: "R&B", annee: "2020",
                teinte: 0x8B1A1A, dateTexte: "20 mars 2020", copyright: "℗ 2020 The Weeknd XO, Inc.",
                resume: "Une nuit entière condensée en onze morceaux, des néons jusqu'au petit matin."),
        MuAlbum(id: 7, titre: "Cœur", artiste: "Clara Luciani", genre: "Pop française", annee: "2021",
                teinte: 0xC94F7C, dateTexte: "11 juin 2021", copyright: "℗ 2021 Initial Artist Services",
                resume: "Le disco assumé d'une chanteuse qui décide de guérir en dansant."),
        MuAlbum(id: 8, titre: "Chris", artiste: "Christine and the Queens", genre: "Pop", annee: "2018",
                teinte: 0xB84DFF, dateTexte: "21 septembre 2018", copyright: "℗ 2018 Because Music",
                resume: "Un album de désir et de muscles, chanté en deux langues."),
        MuAlbum(id: 9, titre: "Dissidænce", artiste: "Vitalic", genre: "Électronique", annee: "2021",
                teinte: 0x1E88A8, dateTexte: "1 octobre 2021", copyright: "℗ 2021 Citizen Records",
                resume: "L'électro française des indispensables : des machines qui respirent."),
        MuAlbum(id: 10, titre: "Tricheur", artiste: "Marine", genre: "Pop française", annee: "2026",
                teinte: 0xE9C46A, dateTexte: "21 août 2026", copyright: "℗ 2026 Marine",
                resume: "Six titres écrits après coup, quand on comprend ce qui s'est vraiment passé."),
        MuAlbum(id: 11, titre: "Inner Light", artiste: "Elderbrook & Bob Moses", genre: "Électronique", annee: "2023",
                teinte: 0x4A3A50, dateTexte: "14 avril 2023", copyright: "℗ 2023 Parlophone",
                resume: "Deux voix basses posées sur une house patiente et chaude."),
        MuAlbum(id: 12, titre: "Fantôme", artiste: "Rim'K", genre: "Rap français", annee: "2023",
                teinte: 0x2A9D8F, dateTexte: "17 février 2023", copyright: "℗ 2023 Believe",
                resume: "Un disque de nuit, écrit au volant entre deux périphériques."),
    ]

    // Pistes déclarées album par album : (titre, durée en secondes)
    static let pistes: [[(String, Int)]] = [
        [("Bruxelles je t'aime", 191), ("Libre", 179), ("Démons", 203), ("Solo", 181),
         ("Plus de sens", 196), ("Taxi", 167), ("Pensées", 214), ("Mauvais rêves", 185),
         ("Balance ton quoi (live)", 200), ("Nonante-Cinq", 182), ("Tempête", 209), ("Fin de siècle", 242)],
        [("Rehab", 214), ("You Know I'm No Good", 257), ("Me & Mr Jones", 153), ("Just Friends", 193),
         ("Back to Black", 241), ("Love Is a Losing Game", 155), ("Tears Dry on Their Own", 186),
         ("Wake Up Alone", 203), ("Some Unholy War", 142), ("He Can Only Hold Her", 166), ("Addicted", 165)],
        [("NUEVAYoL", 180), ("VOY A LLeVARTE PA PR", 204), ("BAILE INoLVIDABLE", 365),
         ("PERFuMITO NUEVO", 198), ("WELTITA", 187), ("VeLDÁ", 224), ("EL CLúB", 233),
         ("KETU TeCRÉ", 172), ("BOKeTE", 215), ("LO QUE LE PASÓ A HAWAii", 252)],
        [("Immortel", 192), ("GJENTE", 185), ("Le Fléau", 208), ("Belle", 221), ("Faya", 178),
         ("Ciel", 199), ("Yolo", 182), ("Sablier", 213), ("Vertigo", 191), ("Dernier round", 227)],
        [("La Machine", 171), ("Bande organisée", 272), ("Alors la Zone", 184), ("Toto", 167),
         ("C'est la cité", 192), ("Fais pas semblant", 178), ("Sur la route", 201), ("Rien à perdre", 186),
         ("Vaï", 164), ("Marseillais", 195), ("Tchikita 2020", 182), ("La bonne étoile", 218)],
        [("Jefe", 182), ("Lettre à une femme", 209), ("Cadenas", 176), ("Goutte d'eau", 191),
         ("Air Max", 204), ("Maman ne le sait pas", 198), ("Mafia", 167), ("Zipette", 185),
         ("Pas bon", 179), ("Fin de vie", 213)],
        [("Alone Again", 250), ("Too Late", 240), ("Hardest to Love", 211), ("Scared to Live", 231),
         ("Snowchild", 247), ("Escape from LA", 355), ("Heartless", 198), ("Faith", 283),
         ("Blinding Lights", 200), ("In Your Eyes", 237), ("Save Your Tears", 215)],
        [("Le Reste", 202), ("Amour toujours", 187), ("Cœur", 215), ("Respire encore", 194),
         ("Tout pour moi", 181), ("La Baie", 224), ("Sad & Slow", 206), ("Ma sœur", 199),
         ("Bandit", 188), ("Nue", 241)],
        [("Comme si", 200), ("Damn (what must a woman do)", 191), ("Doesn't Matter", 224),
         ("5 dollars", 211), ("Goya Soda", 219), ("Girlfriend", 227), ("What's-her-face", 260),
         ("The Walker", 196), ("Feel So Good", 209), ("Make Some Sense", 232), ("Here", 213)],
        [("Waiting for the Sun", 302), ("Rave Against the Machine", 278), ("Cosmic Renegade", 251),
         ("Nadar", 320), ("Dissidænce", 285), ("Sirius", 247), ("Nova", 311),
         ("Ghost Riders", 269), ("Tu conmigo", 296)],
        [("Tricheur", 194), ("Menteur d'occasion", 182), ("Toi non plus", 207),
         ("Le vent tourne", 189), ("Vieille photo", 221), ("Tricheur (a cappella)", 178)],
        [("Inner Light", 258), ("Numb", 232), ("Something About You", 245),
         ("Back to My Bed", 273), ("Inner Light (Extended)", 372)],
        [("Fantôme", 185), ("Paname", 192), ("Chien de la casse", 178), ("Vibes", 200),
         ("Mon frère", 213), ("Bendero", 181), ("Tôlard", 169), ("Sur le bitume", 196),
         ("Nuit blanche", 207), ("Dernier vol", 224)],
    ]

    static let morceaux: [MuMorceau] = construireMorceaux()

    private static func construireMorceaux() -> [MuMorceau] {
        var sortie: [MuMorceau] = []
        var identifiant = 0
        for (indexAlbum, album) in albums.enumerated() {
            guard indexAlbum < pistes.count else { continue }
            for (indexPiste, piste) in pistes[indexAlbum].enumerated() {
                sortie.append(MuMorceau(id: identifiant, titre: piste.0, artiste: album.artiste,
                                        album: album.titre, piste: indexPiste + 1, duree: piste.1))
                identifiant += 1
            }
        }
        return sortie
    }

    static func morceau(_ identifiant: Int) -> MuMorceau? {
        guard identifiant >= 0, identifiant < morceaux.count else { return nil }
        return morceaux[identifiant]
    }

    static func album(nomme titre: String) -> MuAlbum? {
        albums.first { $0.titre == titre }
    }

    static func albumDe(_ morceau: MuMorceau) -> MuAlbum? {
        album(nomme: morceau.album)
    }

    static func teinteDe(_ morceau: MuMorceau) -> UInt {
        albumDe(morceau)?.teinte ?? 0x3A3A3C
    }

    static func morceauxDe(album titre: String) -> [MuMorceau] {
        morceaux.filter { $0.album == titre }
    }

    static func morceauxDe(artiste nom: String) -> [MuMorceau] {
        morceaux.filter { $0.artiste == nom }
    }

    static func albumsDe(artiste nom: String) -> [MuAlbum] {
        albums.filter { $0.artiste == nom }
    }

    static var artistes: [String] {
        var vus: [String] = []
        for album in albums where !vus.contains(album.artiste) { vus.append(album.artiste) }
        return vus.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    // Résolution d'une référence « Artiste — Titre » vers un identifiant de morceau.
    static func identifiant(pour reference: String) -> Int? {
        let parties = reference.components(separatedBy: " — ")
        guard parties.count == 2 else { return nil }
        return morceaux.first { $0.artiste == parties[0] && $0.titre == parties[1] }?.id
    }

    static func identifiants(pour references: [String]) -> [Int] {
        var sortie: [Int] = []
        for reference in references {
            if let identifiant = identifiant(pour: reference) { sortie.append(identifiant) }
        }
        return sortie
    }

    // ---------- Playlists de Sarah (le nombre de titres affiché est TOUJOURS calculé)
    static let playlists: [MuPlaylist] = [
        MuPlaylist(id: 0, titre: "Marseille — le 28 ⚓️", auteur: "Sarah Levasseur",
                   teinte: 0x2B5F8A, teinte2: 0xE0A45C,
                   resume: "Pour la route du 28. Il a dit qu'il mettrait la même de son côté en partant.",
                   titresRef: ["Jul — La Machine", "Jul — Marseillais", "Jul — Bande organisée",
                               "Bad Bunny — VOY A LLeVARTE PA PR", "Marine — Tricheur",
                               "The Weeknd — Blinding Lights", "Elderbrook & Bob Moses — Inner Light",
                               "Angèle — Libre", "Jul — Sur la route"]),
        MuPlaylist(id: 1, titre: "Labo photo — nuit", auteur: "Sarah Levasseur",
                   teinte: 0x1B1B2F, teinte2: 0x7A2E4A,
                   resume: "Ce qui tourne pendant que les tirages sèchent.",
                   titresRef: ["Vitalic — Waiting for the Sun", "Vitalic — Nadar", "Vitalic — Nova",
                               "Vitalic — Cosmic Renegade", "Elderbrook & Bob Moses — Numb",
                               "Elderbrook & Bob Moses — Back to My Bed", "The Weeknd — Alone Again",
                               "Rim'K — Nuit blanche"]),
        MuPlaylist(id: 2, titre: "Randonnée 🥾", auteur: "Sarah Levasseur",
                   teinte: 0x2F6B3D, teinte2: 0xE9C46A,
                   resume: "Monts d'Or, Pilat, et une fois les Calanques.",
                   titresRef: ["Christine and the Queens — Comme si", "Clara Luciani — Respire encore",
                               "Vitalic — Rave Against the Machine", "Angèle — Bruxelles je t'aime",
                               "The Weeknd — In Your Eyes", "Jul — Vaï", "GIMS — Ciel"]),
        MuPlaylist(id: 3, titre: "Terrasses de la Croix-Rousse", auteur: "Sarah Levasseur",
                   teinte: 0xB5541F, teinte2: 0xF0C27B,
                   resume: "Fin de journée, pentes, verre de blanc.",
                   titresRef: ["Clara Luciani — Le Reste", "Clara Luciani — Bandit",
                               "Angèle — Taxi", "Amy Winehouse — Me & Mr Jones",
                               "Christine and the Queens — 5 dollars", "Angèle — Nonante-Cinq"]),
        MuPlaylist(id: 4, titre: "Kiné / respirer", auteur: "Sarah Levasseur",
                   teinte: 0x3D5A6C, teinte2: 0x9AC1D9,
                   resume: "Épaule droite, deux séries chaque matin.",
                   titresRef: ["Amy Winehouse — Love Is a Losing Game", "Clara Luciani — Nue",
                               "Angèle — Pensées", "Christine and the Queens — Here",
                               "Elderbrook & Bob Moses — Something About You"]),
    ]

    static func morceauxDe(playlist: MuPlaylist) -> [MuMorceau] {
        var sortie: [MuMorceau] = []
        for identifiant in identifiants(pour: playlist.titresRef) {
            if let morceau = morceau(identifiant) { sortie.append(morceau) }
        }
        return sortie
    }

    // ---------- Favoris de départ (« Morceaux préférés »)
    static var favorisInitiaux: Set<Int> {
        Set(identifiants(pour: [
            "Marine — Tricheur", "Jul — La Machine", "Angèle — Libre",
            "Elderbrook & Bob Moses — Inner Light", "The Weeknd — Blinding Lights",
            "Amy Winehouse — Back to Black", "Clara Luciani — Respire encore",
            "Ninho — Air Max", "Bad Bunny — NUEVAYoL", "Vitalic — Nadar",
            "Christine and the Queens — Comme si", "Rim'K — Nuit blanche",
        ]))
    }

    // ---------- Écoutés récemment / ajouts récents / téléchargements (indices d'albums)
    static let recentsAlbums: [Int] = [10, 11, 4, 6, 2, 9, 0, 12, 7, 1]
    static let ajoutsRecents: [Int] = [10, 11, 2, 9, 4, 6]
    static let telechargements: [Int] = [10, 11, 4, 0]

    // ---------- Titres du moment (Nouveautés) — 10 titres réellement lisibles
    static var titresMoment: [Int] {
        identifiants(pour: [
            "Marine — Tricheur", "Bad Bunny — NUEVAYoL", "Angèle — Bruxelles je t'aime",
            "Clara Luciani — Cœur", "Elderbrook & Bob Moses — Inner Light",
            "Jul — Bande organisée", "The Weeknd — Save Your Tears",
            "Rim'K — Fantôme", "Vitalic — Dissidænce", "Ninho — Jefe",
        ])
    }

    // ---------- Stations Apple Music (gabarit conservé : ce sont de vraies stations)
    static let stations: [MuStation] = [
        MuStation(id: 0, nom: "Apple Music 1", logo: "1", teinteLogo: 0xFA2D48, sousTitre: "Music Radio",
                  emission: "New Music Daily", creneau: "18:00 – 20:00",
                  accroche: "Les sorties de la semaine, commentées."),
        MuStation(id: 1, nom: "Apple Music Hits", logo: "HITS", teinteLogo: 0x2E7DD8, sousTitre: "Music Radio",
                  emission: "Tubes de tous les temps", creneau: "en continu",
                  accroche: "Des années 80 à aujourd'hui, sans respirer."),
        MuStation(id: 2, nom: "Apple Music Country", logo: "COUNTRY", teinteLogo: 0xE0A400, sousTitre: "Music Radio",
                  emission: "Nashville en direct", creneau: "en continu",
                  accroche: "Le Tennessee à portée d'écouteurs."),
        MuStation(id: 3, nom: "Música Uno", logo: "MÚSICA UNO", teinteLogo: 0xE91E8C, sousTitre: "Music Radio",
                  emission: "Latin ahora", creneau: "en continu",
                  accroche: "Reggaeton, cumbia, urbano."),
        MuStation(id: 4, nom: "Apple Music Club", logo: "club", teinteLogo: 0x1C1C1E, sousTitre: "Music Radio",
                  emission: "Après minuit", creneau: "00:00 – 06:00",
                  accroche: "House, techno, et rien pour dormir."),
        MuStation(id: 5, nom: "Apple Music Chill", logo: "Chill", teinteLogo: 0x2E9BF0, sousTitre: "Music Radio",
                  emission: "Chill mix", creneau: "en continu",
                  accroche: "Pour travailler, ou faire semblant."),
    ]

    static let emissions: [MuEmission] = [
        MuEmission(id: 0, titre: "À l'écoute avec Chassol", animateur: "Chassol",
                   resume: "Le musicien décortique trois morceaux qu'il n'arrive pas à oublier.", teinte: 0x8B1A1A),
        MuEmission(id: 1, titre: "À l'écoute avec Tatyana Jane", animateur: "Tatyana Jane",
                   resume: "Une heure de découvertes francophones, sans filtre.", teinte: 0x355070),
        MuEmission(id: 2, titre: "Radio Genèse", animateur: "Ebony",
                   resume: "Comment un morceau est né, raconté par ceux qui l'ont fait.", teinte: 0x4E7A34),
        MuEmission(id: 3, titre: "Électro française : les indispensables", animateur: "Apple Music",
                   resume: "De Cassius à Vitalic, la ligne directe.", teinte: 0x1E88A8),
    ]

    // ---------- Rechercher : tuiles de catégories (chacune ouvre une liste RÉELLE)
    static let categories: [(String, UInt, String)] = [
        ("Radio", 0xE8203A, "radio"),
        ("Pop française", 0xE84D8A, "Pop française"),
        ("Rap français", 0x5B7CFA, "Rap français"),
        ("Soul", 0x6B4226, "Soul"),
        ("Électronique", 0x1E88A8, "Électronique"),
        ("Latin", 0x4E7A34, "Latin"),
        ("R&B", 0x8B4DC9, "R&B"),
        ("Pop", 0xB84DFF, "Pop"),
    ]
}

// ============================================================ ÉTAT DE LECTURE (D51 : état, pas d'audio)
final class MuLecture: ObservableObject {
    static let partage = MuLecture()

    @Published var file: [Int] = []
    @Published var index: Int = 0
    @Published var enLecture: Bool = false
    @Published var position: Double = 0
    @Published var favoris: Set<Int> = MuDonnees.favorisInitiaux
    @Published var source: String = ""
    @Published var aleatoire: Bool = false
    @Published var volume: Double = 0.42

    let sortieAudio = "AirPods de Sarah"

    var courant: MuMorceau? {
        guard index >= 0, index < file.count else { return nil }
        return MuDonnees.morceau(file[index])
    }

    var suivants: [MuMorceau] {
        guard index + 1 <= file.count else { return [] }
        var sortie: [MuMorceau] = []
        for identifiant in file.dropFirst(index + 1) {
            if let morceau = MuDonnees.morceau(identifiant) { sortie.append(morceau) }
        }
        return sortie
    }

    var duree: Double {
        Double(courant?.duree ?? 1)
    }

    func lancer(_ identifiants: [Int], depuis depart: Int, source nom: String, melange: Bool = false) {
        guard !identifiants.isEmpty else { return }
        var liste = identifiants
        if melange { liste.shuffle() }
        file = liste
        index = melange ? 0 : min(max(0, depart), liste.count - 1)
        aleatoire = melange
        source = nom
        position = 0
        enLecture = true
        Haptique.leger()
    }

    func basculer() {
        guard courant != nil else { return }
        enLecture.toggle()
        Haptique.leger()
    }

    func suivant() {
        guard !file.isEmpty else { return }
        if index + 1 < file.count {
            index += 1
        } else {
            index = 0
        }
        position = 0
        enLecture = true
    }

    func precedent() {
        guard !file.isEmpty else { return }
        if position > 4 {
            position = 0
            return
        }
        index = index > 0 ? index - 1 : file.count - 1
        position = 0
        enLecture = true
    }

    func allerA(_ cible: Int) {
        guard cible >= 0, cible < file.count else { return }
        index = cible
        position = 0
        enLecture = true
        Haptique.leger()
    }

    func retirerDeLaFile(_ cible: Int) {
        guard cible > index, cible < file.count else { return }
        file.remove(at: cible)
    }

    func avancer(_ delta: Double) {
        guard courant != nil else { return }
        position = min(max(0, position + delta), duree)
    }

    func tic() {
        guard enLecture, courant != nil else { return }
        if position + 1 >= duree {
            suivant()
        } else {
            position += 1
        }
    }

    func estFavori(_ identifiant: Int) -> Bool { favoris.contains(identifiant) }

    func basculerFavori(_ identifiant: Int) {
        if favoris.contains(identifiant) {
            favoris.remove(identifiant)
        } else {
            favoris.insert(identifiant)
        }
        Haptique.leger()
    }

    var morceauxFavoris: [MuMorceau] {
        MuDonnees.morceaux.filter { favoris.contains($0.id) }
    }
}

// ============================================================ FORMATAGE
enum MuFormat {
    static func duree(_ secondes: Int) -> String {
        String(format: "%d:%02d", secondes / 60, secondes % 60)
    }

    static func horloge(_ secondes: Double) -> String {
        let entier = Int(max(0, secondes))
        return String(format: "%d:%02d", entier / 60, entier % 60)
    }

    static func restant(_ position: Double, _ duree: Double) -> String {
        let reste = Int(max(0, duree - position))
        return String(format: "−%d:%02d", reste / 60, reste % 60)
    }

    static func minutes(_ morceaux: [MuMorceau]) -> String {
        let total = morceaux.reduce(0) { $0 + $1.duree }
        let mots = morceaux.count == 1 ? "morceau" : "morceaux"
        return "\(morceaux.count) \(mots), \(max(1, total / 60)) minutes"
    }

    static func compte(_ nombre: Int, _ singulier: String, _ pluriel: String) -> String {
        "\(nombre) " + (nombre == 1 ? singulier : pluriel)
    }
}

// ============================================================ ROUTES (une seule table de navigation)
enum MuRoute: Hashable {
    case album(Int)
    case artiste(String)
    case playlist(Int)
    case favoris
    case listeMorceaux
    case listeAlbums
    case listeArtistes
    case listePlaylists
    case telechargements
    case recents
    case titresMoment
    case station(Int)
    case genre(String)
}

struct MuDestinationVue: View {
    let route: MuRoute
    var body: some View {
        switch route {
        case .album(let indice): MuAlbumVue(indice: indice)
        case .artiste(let nom): MuArtisteVue(nom: nom)
        case .playlist(let indice): MuPlaylistVue(indice: indice)
        case .favoris: MuFavorisVue()
        case .listeMorceaux: MuListeMorceauxVue()
        case .listeAlbums: MuListeAlbumsVue()
        case .listeArtistes: MuListeArtistesVue()
        case .listePlaylists: MuListePlaylistsVue()
        case .telechargements: MuTelechargementsVue()
        case .recents: MuRecentsVue()
        case .titresMoment: MuTitresMomentVue()
        case .station(let indice): MuStationVue(indice: indice)
        case .genre(let nom): MuGenreVue(genre: nom)
        }
    }
}

// Pile de navigation : UN SEUL navigationDestination par NavigationStack (règle du projet).
struct MuPile<Contenu: View>: View {
    @ViewBuilder let contenu: () -> Contenu
    var body: some View {
        NavigationStack {
            contenu()
                .navigationDestination(for: MuRoute.self) { route in
                    MuDestinationVue(route: route)
                }
        }
    }
}

// ============================================================ COMPOSANTS
// Pochette dessinée (aucun asset audio/visuel dans le projet — D51) : dégradé de la teinte
// de l'album + monogramme. Jamais de .scaledToFill() : il n'y a pas d'image à rogner.
struct MuPochette: View {
    let titre: String
    let artiste: String
    let teinte: UInt
    var teinte2: UInt? = nil
    var cote: CGFloat = 120
    var coin: CGFloat = 6
    var compacte: Bool = false

    private var degrade: LinearGradient {
        let seconde = teinte2 ?? MuPochette.assombrir(teinte)
        return LinearGradient(colors: [Color(hex: teinte), Color(hex: seconde)],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func assombrir(_ valeur: UInt) -> UInt {
        let rouge = ((valeur >> 16) & 0xFF) * 45 / 100
        let vert = ((valeur >> 8) & 0xFF) * 45 / 100
        let bleu = (valeur & 0xFF) * 45 / 100
        return (rouge << 16) | (vert << 8) | bleu
    }

    private var monogramme: String {
        let mots = artiste.split(separator: " ")
        let premier = mots.first.map { String($0.prefix(1)) } ?? "♪"
        return premier.uppercased()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: coin, style: .continuous)
            .fill(degrade)
            .frame(width: cote, height: cote)
            .overlay(alignment: .topLeading) {
                if !compacte {
                    Text(monogramme)
                        .font(.system(size: cote * 0.30, weight: .black, design: .serif))
                        .foregroundStyle(.white.opacity(0.28))
                        .padding(cote * 0.07)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if !compacte {
                    Text(titre.uppercased())
                        .font(.system(size: max(7, cote * 0.075), weight: .semibold))
                        .kerning(0.6)
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .padding(cote * 0.07)
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: cote * 0.34))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(cote * 0.06)
                }
            }
    }
}

struct MuPochetteMorceau: View {
    let morceau: MuMorceau
    var cote: CGFloat = 48
    var coin: CGFloat = 4
    var body: some View {
        MuPochette(titre: morceau.album, artiste: morceau.artiste,
                   teinte: MuDonnees.teinteDe(morceau), cote: cote, coin: coin,
                   compacte: cote < 56)
    }
}

// En-tête de grand titre (« Accueil », « Radio », « Bibliothèque »… + avatar Sarah)
struct MuEnteteTitre: View {
    let titre: String
    var boutonPoints: Bool = false
    var actionPoints: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(titre)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            if boutonPoints {
                Circle()
                    .fill(Color(hex: 0x2C2C2E))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .contentShape(Circle())
                    .onTapGesture { actionPoints?() }
            }
            MuAvatarSarah()
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}

struct MuAvatarSarah: View {
    var cote: CGFloat = 30
    var body: some View {
        Circle()
            .fill(LinearGradient(colors: [Color(hex: 0xC9E4E0), Color(hex: 0x9FC7C1)],
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: cote, height: cote)
            .overlay(
                Text("S")
                    .font(.system(size: cote * 0.52, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x2C3E3B))
            )
    }
}

// Titre de section avec chevron cliquable (le chevron n'apparaît que s'il mène quelque part)
struct MuTitreSection: View {
    let titre: String
    var route: MuRoute? = nil
    var body: some View {
        Group {
            if let cible = route {
                NavigationLink(value: cible) {
                    HStack(spacing: 4) {
                        Text(titre)
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(.white)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(muGris)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            } else {
                Text(titre)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
    }
}

// Cellule de morceau (liste d'album / playlist / bibliothèque)
struct MuCelluleMorceau: View {
    @ObservedObject private var lecture = MuLecture.partage
    let morceau: MuMorceau
    var numero: Int? = nil
    var pochette: Bool = true
    var afficherAlbum: Bool = false
    @State private var menuVisible = false
    let action: () -> Void

    private var estCourant: Bool {
        lecture.courant?.id == morceau.id
    }

    var body: some View {
        HStack(spacing: 12) {
            if lecture.estFavori(morceau.id) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(muGris)
            }
            if let rang = numero {
                Text("\(rang)")
                    .font(.system(size: 15))
                    .foregroundStyle(muGris)
                    .frame(width: 18, alignment: .center)
            }
            if pochette {
                MuPochetteMorceau(morceau: morceau)
            }
            VStack(alignment: .leading, spacing: 2) {
                let teinteTitre: Color = estCourant ? muRouge : Color.white
                Text(morceau.titre)
                    .font(.system(size: 16))
                    .foregroundStyle(teinteTitre)
                    .lineLimit(1)
                if pochette || afficherAlbum {
                    Text(afficherAlbum ? morceau.artiste + " — " + morceau.album : morceau.artiste)
                        .font(.system(size: 14))
                        .foregroundStyle(muGris)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 6)
            Text(MuFormat.duree(morceau.duree))
                .font(.system(size: 13))
                .foregroundStyle(muGris)
            Image(systemName: "ellipsis")
                .font(.system(size: 15))
                .foregroundStyle(muGris)
                .contentShape(Rectangle())
                .onTapGesture { menuVisible = true }
        }
        .padding(.vertical, 7)
        .contentShape(Rectangle())
        .onTapGesture { action() }
        .sheet(isPresented: $menuVisible) {
            MuMenuMorceauVue(morceau: morceau)
        }
    }
}

// Ligne de séparation alignée sur le texte (comme les frames)
struct MuSeparateur: View {
    var retrait: CGFloat = 0
    var body: some View {
        Rectangle()
            .fill(muSeparateur)
            .frame(height: 0.5)
            .padding(.leading, retrait)
    }
}

// Bouton rond translucide (retour / partage / … sur album, playlist, artiste)
struct MuBoutonRond: View {
    let symbole: String
    var cote: CGFloat = 34
    let action: () -> Void
    var body: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .frame(width: cote, height: cote)
            .overlay(
                Image(systemName: symbole)
                    .font(.system(size: cote * 0.45, weight: .semibold))
                    .foregroundStyle(.white)
            )
            .contentShape(Circle())
            .onTapGesture { action() }
    }
}

// Rangée « aléatoire / Lecture / télécharger » des pages album, playlist, artiste
struct MuRangeeLecture: View {
    let identifiants: [Int]
    let source: String
    var telechargeable: Bool = true
    @ObservedObject private var lecture = MuLecture.partage
    @State private var telecharge = false

    var body: some View {
        HStack(spacing: 18) {
            Circle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "shuffle")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                )
                .contentShape(Circle())
                .onTapGesture { lecture.lancer(identifiants, depuis: 0, source: source, melange: true) }

            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("Lecture")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Capsule().fill(Color.white))
            .contentShape(Capsule())
            .onTapGesture { lecture.lancer(identifiants, depuis: 0, source: source) }

            if telechargeable {
                Circle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: telecharge ? "checkmark" : "arrow.down")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .contentShape(Circle())
                    .onTapGesture { telecharge = true; Haptique.leger() }
            }
        }
        .padding(.horizontal, 22)
    }
}

// ============================================================ MINI-LECTEUR + BARRE D'ONGLETS
struct MuMiniLecteur: View {
    @ObservedObject private var lecture = MuLecture.partage
    let action: () -> Void

    var body: some View {
        Group {
            if let morceau = lecture.courant {
                HStack(spacing: 10) {
                    MuPochetteMorceau(morceau: morceau, cote: 38, coin: 4)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(morceau.titre)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(morceau.artiste)
                            .font(.system(size: 13))
                            .foregroundStyle(muGris)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: lecture.enLecture ? "pause.fill" : "play.fill")
                        .font(.system(size: 19))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .contentShape(Rectangle())
                        .onTapGesture { lecture.basculer() }
                    Image(systemName: "forward.fill")
                        .font(.system(size: 19))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .contentShape(Rectangle())
                        .onTapGesture { lecture.suivant() }
                }
                .padding(.leading, 8)
                .padding(.trailing, 6)
                .padding(.vertical, 6)
                .background(Capsule().fill(.ultraThinMaterial))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5))
                .padding(.horizontal, 12)
                .contentShape(Capsule())
                .onTapGesture { action() }
            }
        }
    }
}

struct MuBarreOnglets: View {
    @Binding var onglet: Int
    private let items: [(String, String)] = [
        ("house.fill", "Accueil"),
        ("square.grid.2x2.fill", "Nouveautés"),
        ("dot.radiowaves.left.and.right", "Radio"),
        ("music.note.house.fill", "Bibliothèque"),
    ]

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { indice, item in
                    let choisi: Bool = onglet == indice
                    let teinte: Color = choisi ? muRouge : Color.white
                    let fondItem: Color = choisi ? Color.white.opacity(0.09) : Color.clear
                    VStack(spacing: 3) {
                        Image(systemName: item.0)
                            .font(.system(size: 19))
                        Text(item.1)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundStyle(teinte)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(fondItem))
                    .contentShape(Rectangle())
                    .onTapGesture { onglet = indice }
                }
            }
            .padding(.horizontal, 4)
            .background(Capsule().fill(.ultraThinMaterial))

            let teinteLoupe: Color = onglet == 4 ? muRouge : Color.white
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 54, height: 54)
                .overlay(
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(teinteLoupe)
                )
                .contentShape(Circle())
                .onTapGesture { onglet = 4 }
        }
        .padding(.horizontal, 12)
    }
}

// ============================================================ RACINE
struct MusiqueVue: View {
    @Environment(\.dismiss) private var fermer
    @ObservedObject private var lecture = MuLecture.partage
    @State private var onglet: Int
    @State private var lecteurVisible = false
    @State private var fileVisible = false
    @State private var rechercheTexte = ""
    private let minuteur = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(onglet: Int? = nil) {
        var depart = 0
        if let brut = ProcessInfo.processInfo.environment["ONGLET"], let valeur = Int(brut) { depart = valeur }
        if let impose = onglet { depart = impose }
        _onglet = State(initialValue: depart)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            muFond.ignoresSafeArea()

            Group {
                switch onglet {
                case 1: MuPile { MuNouveautesVue() }
                case 2: MuPile { MuRadioVue() }
                case 3: MuPile { MuBibliothequeVue() }
                case 4: MuPile { MuRechercheVue(texte: $rechercheTexte) }
                default: MuPile { MuAccueilVue() }
                }
            }

            VStack(spacing: 8) {
                MuMiniLecteur { lecteurVisible = true }
                if onglet == 4 {
                    MuBarreRecherche(texte: $rechercheTexte) { onglet = 0 }
                } else {
                    MuBarreOnglets(onglet: $onglet)
                }
                BarreHome { fermer() }
                    .padding(.top, -4)
            }
            .padding(.bottom, 2)
        }
        .fullScreenCover(isPresented: $lecteurVisible) {
            MuLecteurVue(fileVisible: $fileVisible)
        }
        .sheet(isPresented: $fileVisible) {
            MuFileVue()
        }
        .onReceive(minuteur) { _ in lecture.tic() }
        .onAppear { MusiqueVue.preparerEtat() }
        .preferredColorScheme(.dark)
    }

    // État d'ouverture crédible : Sarah a laissé « Tricheur » de Marine en cours,
    // depuis la playlist « Marseille — le 28 ⚓️ ».
    static func preparerEtat() {
        let lecture = MuLecture.partage
        guard lecture.file.isEmpty else { return }
        guard let playlist = MuDonnees.playlists.first else { return }
        let identifiants = MuDonnees.morceauxDe(playlist: playlist).map { $0.id }
        guard !identifiants.isEmpty else { return }
        lecture.file = identifiants
        lecture.index = min(4, identifiants.count - 1)
        lecture.source = playlist.titre
        lecture.position = 41
        lecture.enLecture = false
    }
}

// ============================================================ ONGLET 0 — ACCUEIL « POUR VOUS »
struct MuAccueilVue: View {
    @ObservedObject private var lecture = MuLecture.partage

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                MuEnteteTitre(titre: "Accueil")
                MuTitreSection(titre: "Pour vous")
                cartesPourVous
                MuTitreSection(titre: "Écoutés récemment", route: .recents)
                grilleRecents
                Group {
                    MuTitreSection(titre: "Vos playlists sur mesure", route: .listePlaylists)
                    bandePlaylists
                    MuTitreSection(titre: "Électro française : les indispensables",
                                   route: .genre("Électronique"))
                    bandeGenre
                    MuTitreSection(titre: "Radios personnalisées")
                    bandeRadios
                }
                Spacer(minLength: 170)
            }
            .padding(.top, 6)
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }

    // 3 cartes larges : la station de Sarah, la nouveauté de Marine, la playlist du 28
    private var cartesPourVous: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                MuCarteVedette(surTitre: "Vos mix sur mesure",
                               titre: "Station de : Sarah Levasseur",
                               sousTitre: nil,
                               teinte: 0xFA2D48, teinte2: 0xE8348C,
                               badge: true,
                               identifiants: MuDonnees.morceaux.map { $0.id },
                               source: "Station de Sarah Levasseur")
                MuCarteVedette(surTitre: "Nouveauté",
                               titre: "Tricheur",
                               sousTitre: "Marine",
                               teinte: 0xE9C46A, teinte2: 0x8A6A20,
                               badge: false,
                               identifiants: MuDonnees.morceauxDe(album: "Tricheur").map { $0.id },
                               source: "Tricheur — Marine")
                MuCarteVedette(surTitre: "Votre playlist",
                               titre: "Marseille — le 28 ⚓️",
                               sousTitre: MuFormat.compte(
                                   MuDonnees.playlists.isEmpty ? 0 :
                                       MuDonnees.morceauxDe(playlist: MuDonnees.playlists[0]).count,
                                   "titre", "titres"),
                               teinte: 0x2B5F8A, teinte2: 0xE0A45C,
                               badge: false,
                               identifiants: MuDonnees.playlists.isEmpty ? [] :
                                   MuDonnees.morceauxDe(playlist: MuDonnees.playlists[0]).map { $0.id },
                               source: "Marseille — le 28 ⚓️")
            }
            .padding(.horizontal, 16)
        }
    }

    // 2 lignes horizontales de pochettes (comme les frames)
    private var grilleRecents: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            let indices = MuDonnees.recentsAlbums
            let moitie = (indices.count + 1) / 2
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(0..<moitie), id: \.self) { colonne in
                    VStack(alignment: .leading, spacing: 12) {
                        MuVignetteAlbum(indice: indices[colonne], cote: 120)
                        if colonne + moitie < indices.count {
                            MuVignetteAlbum(indice: indices[colonne + moitie], cote: 120)
                        }
                    }
                    .frame(width: 120)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var bandePlaylists: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(MuDonnees.playlists) { playlist in
                    NavigationLink(value: MuRoute.playlist(playlist.id)) {
                        VStack(alignment: .leading, spacing: 6) {
                            MuPochette(titre: playlist.titre, artiste: playlist.auteur,
                                       teinte: playlist.teinte, teinte2: playlist.teinte2,
                                       cote: 150, coin: 8)
                            Text(playlist.titre)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(MuFormat.compte(MuDonnees.morceauxDe(playlist: playlist).count,
                                                 "titre", "titres"))
                                .font(.system(size: 13))
                                .foregroundStyle(muGris)
                        }
                        .frame(width: 150, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var bandeGenre: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(MuDonnees.albums.filter { $0.genre == "Électronique" }) { album in
                    MuVignetteAlbum(indice: album.id, cote: 138)
                }
                ForEach(MuDonnees.albums.filter { $0.genre == "Pop française" }) { album in
                    MuVignetteAlbum(indice: album.id, cote: 138)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var bandeRadios: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(MuDonnees.stations) { station in
                    NavigationLink(value: MuRoute.station(station.id)) {
                        VStack(alignment: .leading, spacing: 6) {
                            MuPochette(titre: station.emission, artiste: station.nom,
                                       teinte: station.teinteLogo, cote: 138, coin: 8)
                            Text(station.nom)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text("Station de radio")
                                .font(.system(size: 13))
                                .foregroundStyle(muGris)
                        }
                        .frame(width: 138, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct MuCarteVedette: View {
    let surTitre: String
    let titre: String
    let sousTitre: String?
    let teinte: UInt
    let teinte2: UInt
    let badge: Bool
    let identifiants: [Int]
    let source: String
    @ObservedObject private var lecture = MuLecture.partage

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: teinte), Color(hex: teinte2)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            if badge {
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "applelogo").font(.system(size: 11))
                            Text("Music").font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding(12)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(surTitre)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.85))
                Text(titre)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                if let bas = sousTitre {
                    Text(bas)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(14)
        }
        .frame(width: 188, height: 250)
        .contentShape(Rectangle())
        .onTapGesture {
            lecture.lancer(identifiants, depuis: 0, source: source)
        }
    }
}

struct MuVignetteAlbum: View {
    let indice: Int
    var cote: CGFloat = 120
    var body: some View {
        Group {
            if indice >= 0, indice < MuDonnees.albums.count {
                let album = MuDonnees.albums[indice]
                NavigationLink(value: MuRoute.album(indice)) {
                    VStack(alignment: .leading, spacing: 5) {
                        MuPochette(titre: album.titre, artiste: album.artiste,
                                   teinte: album.teinte, cote: cote, coin: 6)
                        Text(album.titre)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(album.artiste)
                            .font(.system(size: 13))
                            .foregroundStyle(muGris)
                            .lineLimit(1)
                    }
                    .frame(width: cote, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ============================================================ ONGLET 1 — NOUVEAUTÉS
struct MuNouveautesVue: View {
    @ObservedObject private var lecture = MuLecture.partage

    private var titres: [MuMorceau] {
        var sortie: [MuMorceau] = []
        for identifiant in MuDonnees.titresMoment {
            if let morceau = MuDonnees.morceau(identifiant) { sortie.append(morceau) }
        }
        return sortie
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                MuEnteteTitre(titre: "Nouveautés")
                bandeauNouveautes
                MuTitreSection(titre: "Titres du moment", route: .titresMoment)
                VStack(spacing: 0) {
                    ForEach(Array(titres.prefix(8))) { morceau in
                        MuCelluleMorceau(morceau: morceau) {
                            lecture.lancer(MuDonnees.titresMoment,
                                           depuis: MuDonnees.titresMoment.firstIndex(of: morceau.id) ?? 0,
                                           source: "Titres du moment")
                        }
                        MuSeparateur(retrait: 60)
                    }
                }
                .padding(.horizontal, 16)
                MuTitreSection(titre: "Sorties récentes", route: .listeAlbums)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(Array(MuDonnees.recentsAlbums.prefix(6)), id: \.self) { indice in
                            MuVignetteAlbum(indice: indice, cote: 138)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                Spacer(minLength: 170)
            }
            .padding(.top, 6)
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var bandeauNouveautes: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(MuDonnees.recentsAlbums.prefix(4)), id: \.self) { indice in
                    if indice >= 0, indice < MuDonnees.albums.count {
                        let album = MuDonnees.albums[indice]
                        NavigationLink(value: MuRoute.album(indice)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("NOUVEL ALBUM")
                                    .font(.system(size: 10, weight: .bold))
                                    .kerning(0.6)
                                    .foregroundStyle(muGris)
                                MuPochette(titre: album.titre, artiste: album.artiste,
                                           teinte: album.teinte, cote: 240, coin: 10)
                                Text(album.titre)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                Text("Apple Music · " + album.genre)
                                    .font(.system(size: 13))
                                    .foregroundStyle(muGris)
                            }
                            .frame(width: 240, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// ============================================================ ONGLET 2 — RADIO
struct MuRadioVue: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                MuEnteteTitre(titre: "Radio")
                grilleStations
                MuTitreSection(titre: "À l'antenne")
                aLAntenne
                MuTitreSection(titre: "À l'écoute")
                VStack(spacing: 0) {
                    ForEach(MuDonnees.emissions) { emission in
                        MuLigneEmission(emission: emission)
                        MuSeparateur(retrait: 66)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
            .padding(.top, 6)
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var grilleStations: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(MuDonnees.stations) { station in
                NavigationLink(value: MuRoute.station(station.id)) {
                    MuTuileStation(station: station)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private var aLAntenne: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(MuDonnees.stations.prefix(3))) { station in
                    NavigationLink(value: MuRoute.station(station.id)) {
                        VStack(alignment: .leading, spacing: 0) {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(LinearGradient(colors: [Color(hex: station.teinteLogo),
                                                              Color(hex: MuPochette.assombrir(station.teinteLogo))],
                                                     startPoint: .top, endPoint: .bottom))
                                .frame(width: 290, height: 190)
                                .overlay(alignment: .topLeading) {
                                    Text(station.logo)
                                        .font(.system(size: 22, weight: .black))
                                        .foregroundStyle(.white.opacity(0.9))
                                        .padding(14)
                                }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(station.nom + " · " + station.creneau)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(muGris)
                                Text(station.emission)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text(station.accroche)
                                    .font(.system(size: 14))
                                    .foregroundStyle(muGris)
                                    .lineLimit(2)
                            }
                            .frame(width: 290, alignment: .leading)
                            .padding(12)
                            .background(Rectangle().fill(muCarte))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct MuTuileStation: View {
    let station: MuStation
    var body: some View {
        VStack(spacing: 6) {
            let corpsLogo: CGFloat = station.logo.count > 5 ? 15 : 34
            Text(station.logo)
                .font(.system(size: corpsLogo, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: station.teinteLogo))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 6)
            HStack(spacing: 2) {
                Image(systemName: "applelogo").font(.system(size: 8))
                Text("Music").font(.system(size: 10, weight: .medium)).foregroundStyle(.black)
                Text("Radio").font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: station.teinteLogo))
            }
            .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 106)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(hex: 0xF2F2F5)))
    }
}

struct MuLigneEmission: View {
    let emission: MuEmission
    @ObservedObject private var lecture = MuLecture.partage
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(colors: [Color(hex: emission.teinte),
                                              Color(hex: MuPochette.assombrir(emission.teinte))],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 54, height: 54)
                .overlay(
                    Text(String(emission.animateur.prefix(1)))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(emission.titre)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(emission.resume)
                    .font(.system(size: 14))
                    .foregroundStyle(muGris)
                    .lineLimit(2)
            }
            Spacer(minLength: 6)
            Image(systemName: "play.circle")
                .font(.system(size: 22))
                .foregroundStyle(muGris)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            let identifiants = MuDonnees.morceaux.filter { morceau in
                MuDonnees.albumDe(morceau)?.genre == "Électronique"
            }.map { $0.id }
            let liste = identifiants.isEmpty ? MuDonnees.morceaux.map { $0.id } : identifiants
            lecture.lancer(liste, depuis: 0, source: emission.titre, melange: true)
        }
    }
}

// ============================================================ ONGLET 3 — BIBLIOTHÈQUE
struct MuBibliothequeVue: View {
    private let rubriques: [(String, String, MuRoute)] = [
        ("Playlists", "music.note.list", .listePlaylists),
        ("Artistes", "music.mic", .listeArtistes),
        ("Albums", "square.stack", .listeAlbums),
        ("Morceaux", "music.note", .listeMorceaux),
        ("Téléchargements", "arrow.down.circle", .telechargements),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                MuEnteteTitre(titre: "Bibliothèque")
                VStack(spacing: 0) {
                    ForEach(Array(rubriques.enumerated()), id: \.offset) { indice, rubrique in
                        NavigationLink(value: rubrique.2) {
                            HStack(spacing: 14) {
                                Image(systemName: rubrique.1)
                                    .font(.system(size: 19))
                                    .foregroundStyle(muRouge)
                                    .frame(width: 26)
                                Text(rubrique.0)
                                    .font(.system(size: 19))
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(muGris)
                            }
                            .padding(.vertical, 13)
                        }
                        .buttonStyle(.plain)
                        if indice < rubriques.count - 1 {
                            MuSeparateur(retrait: 40)
                        }
                    }
                }
                .padding(.horizontal, 16)

                Text("Ajouts récents")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 26)
                    .padding(.bottom, 12)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 18) {
                    ForEach(MuDonnees.ajoutsRecents, id: \.self) { indice in
                        MuTuileAjoutRecent(indice: indice)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
            .padding(.top, 6)
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuTuileAjoutRecent: View {
    let indice: Int
    var body: some View {
        Group {
            if indice >= 0, indice < MuDonnees.albums.count {
                let album = MuDonnees.albums[indice]
                NavigationLink(value: MuRoute.album(indice)) {
                    VStack(alignment: .leading, spacing: 6) {
                        MuPochette(titre: album.titre, artiste: album.artiste,
                                   teinte: album.teinte, cote: 168, coin: 6)
                        Text(album.titre)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(album.artiste)
                            .font(.system(size: 15))
                            .foregroundStyle(muGris)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ============================================================ EN-TÊTE DES ÉCRANS POUSSÉS
struct MuEnteteNav: View {
    let titre: String
    var body: some View {
        HStack(spacing: 10) {
            MuRetour()
            Text(titre)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer()
            MuAvatarSarah(cote: 28)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 10)
    }
}

struct MuRetour: View {
    @Environment(\.dismiss) private var fermer
    var body: some View {
        MuBoutonRond(symbole: "chevron.left") { fermer() }
    }
}

// ============================================================ ALBUM OUVERT
struct MuAlbumVue: View {
    let indice: Int
    @ObservedObject private var lecture = MuLecture.partage
    @State private var deplie = false

    private var album: MuAlbum? {
        guard indice >= 0, indice < MuDonnees.albums.count else { return nil }
        return MuDonnees.albums[indice]
    }

    var body: some View {
        Group {
            if let album = album {
                contenu(album)
            } else {
                MuVueVide(message: "Cet album n'est plus dans la bibliothèque.")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func contenu(_ album: MuAlbum) -> some View {
        let morceaux = MuDonnees.morceauxDe(album: album.titre)
        let identifiants = morceaux.map { $0.id }
        return ZStack(alignment: .top) {
            LinearGradient(colors: [Color(hex: MuPochette.assombrir(album.teinte)),
                                    muFond],
                           startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    HStack {
                        MuRetour()
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 6)

                    MuPochette(titre: album.titre, artiste: album.artiste,
                               teinte: album.teinte, cote: 228, coin: 8)
                        .shadow(color: .black.opacity(0.4), radius: 10, y: 6)

                    VStack(spacing: 4) {
                        Text(album.titre)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        NavigationLink(value: MuRoute.artiste(album.artiste)) {
                            Text(album.artiste)
                                .font(.system(size: 20))
                                .foregroundStyle(muRouge)
                        }
                        .buttonStyle(.plain)
                        Text(album.genre + " · " + album.annee + " · Lossless")
                            .font(.system(size: 12))
                            .foregroundStyle(muGris)
                    }
                    .padding(.horizontal, 20)

                    MuRangeeLecture(identifiants: identifiants, source: album.titre)

                    let limiteAlbum: Int? = deplie ? nil : 2
                    Text(album.resume)
                        .font(.system(size: 15))
                        .foregroundStyle(muGris)
                        .lineLimit(limiteAlbum)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                        .onTapGesture { deplie.toggle() }
                    if !deplie {
                        Text("PLUS")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                            .onTapGesture { deplie = true }
                    }

                    VStack(spacing: 0) {
                        ForEach(morceaux) { morceau in
                            MuCelluleMorceau(morceau: morceau, numero: morceau.piste, pochette: false) {
                                lecture.lancer(identifiants,
                                               depuis: identifiants.firstIndex(of: morceau.id) ?? 0,
                                               source: album.titre)
                            }
                            MuSeparateur(retrait: 30)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(album.dateTexte)
                        Text(MuFormat.minutes(morceaux))
                        Text(album.copyright)
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(muGris)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    Spacer(minLength: 170)
                }
            }
        }
    }
}

// ============================================================ PLAYLIST OUVERTE
struct MuPlaylistVue: View {
    let indice: Int
    @ObservedObject private var lecture = MuLecture.partage
    @State private var deplie = false

    private var playlist: MuPlaylist? {
        guard indice >= 0, indice < MuDonnees.playlists.count else { return nil }
        return MuDonnees.playlists[indice]
    }

    var body: some View {
        Group {
            if let playlist = playlist {
                contenu(playlist)
            } else {
                MuVueVide(message: "Cette playlist n'existe plus.")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func contenu(_ playlist: MuPlaylist) -> some View {
        let morceaux = MuDonnees.morceauxDe(playlist: playlist)
        let identifiants = morceaux.map { $0.id }
        return ZStack(alignment: .top) {
            LinearGradient(colors: [Color(hex: playlist.teinte),
                                    Color(hex: MuPochette.assombrir(playlist.teinte2)),
                                    muFond],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    HStack {
                        MuRetour()
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 6)

                    MuPochette(titre: playlist.titre, artiste: playlist.auteur,
                               teinte: playlist.teinte, teinte2: playlist.teinte2,
                               cote: 250, coin: 10)
                        .shadow(color: .black.opacity(0.4), radius: 10, y: 6)

                    VStack(spacing: 4) {
                        Text(playlist.titre)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Text(playlist.auteur)
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.8))
                        Text(MuFormat.minutes(morceaux))
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 20)

                    MuRangeeLecture(identifiants: identifiants, source: playlist.titre)

                    let limitePlaylist: Int? = deplie ? nil : 2
                    Text(playlist.resume)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(limitePlaylist)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                        .onTapGesture { deplie.toggle() }

                    VStack(spacing: 0) {
                        ForEach(morceaux) { morceau in
                            MuCelluleMorceau(morceau: morceau) {
                                lecture.lancer(identifiants,
                                               depuis: identifiants.firstIndex(of: morceau.id) ?? 0,
                                               source: playlist.titre)
                            }
                            MuSeparateur(retrait: 60)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)

                    Spacer(minLength: 170)
                }
            }
        }
    }
}

// ============================================================ MORCEAUX PRÉFÉRÉS (favoris)
struct MuFavorisVue: View {
    @ObservedObject private var lecture = MuLecture.partage
    var body: some View {
        let morceaux = lecture.morceauxFavoris
        let identifiants = morceaux.map { $0.id }
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                HStack {
                    MuRetour()
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: [muRouge, Color(hex: 0x8A1020)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 230, height: 230)
                    .overlay(
                        Image(systemName: "star.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.white)
                    )

                VStack(spacing: 4) {
                    Text("Morceaux préférés")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                    Text(MuFormat.minutes(morceaux))
                        .font(.system(size: 12))
                        .foregroundStyle(muGris)
                }

                if morceaux.isEmpty {
                    Text("Aucun morceau marqué d'une étoile pour l'instant.")
                        .font(.system(size: 15))
                        .foregroundStyle(muGris)
                        .padding(.top, 20)
                } else {
                    MuRangeeLecture(identifiants: identifiants, source: "Morceaux préférés",
                                    telechargeable: false)
                    VStack(spacing: 0) {
                        ForEach(morceaux) { morceau in
                            MuCelluleMorceau(morceau: morceau) {
                                lecture.lancer(identifiants,
                                               depuis: identifiants.firstIndex(of: morceau.id) ?? 0,
                                               source: "Morceaux préférés")
                            }
                            MuSeparateur(retrait: 60)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                }
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ============================================================ ARTISTE OUVERT
struct MuArtisteVue: View {
    let nom: String
    @ObservedObject private var lecture = MuLecture.partage

    var body: some View {
        let morceaux = MuDonnees.morceauxDe(artiste: nom)
        let identifiants = morceaux.map { $0.id }
        let albums = MuDonnees.albumsDe(artiste: nom)
        let teinte: UInt = albums.first?.teinte ?? 0x3A3A3C
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                HStack {
                    MuRetour()
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)

                Circle()
                    .fill(LinearGradient(colors: [Color(hex: teinte),
                                                  Color(hex: MuPochette.assombrir(teinte))],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 116, height: 116)
                    .overlay(
                        Text(String(nom.prefix(1)))
                            .font(.system(size: 46, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                Text(nom)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Text(MuFormat.compte(morceaux.count, "morceau", "morceaux")
                     + " · " + MuFormat.compte(albums.count, "album", "albums"))
                    .font(.system(size: 13))
                    .foregroundStyle(muGris)

                HStack(spacing: 12) {
                    MuPetitBoutonRouge(symbole: "play.fill", texte: "Lecture") {
                        lecture.lancer(identifiants, depuis: 0, source: nom)
                    }
                    MuPetitBoutonRouge(symbole: "shuffle", texte: "Aléatoire") {
                        lecture.lancer(identifiants, depuis: 0, source: nom, melange: true)
                    }
                }

                if !albums.isEmpty {
                    MuTitreSection(titre: "Albums")
                        .padding(.top, 6)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(albums) { album in
                                MuVignetteAlbum(indice: album.id, cote: 150)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                MuTitreSection(titre: "Morceaux")
                    .padding(.top, 6)
                VStack(spacing: 0) {
                    ForEach(morceaux) { morceau in
                        MuCelluleMorceau(morceau: morceau) {
                            lecture.lancer(identifiants,
                                           depuis: identifiants.firstIndex(of: morceau.id) ?? 0,
                                           source: nom)
                        }
                        MuSeparateur(retrait: 60)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuPetitBoutonRouge: View {
    let symbole: String
    let texte: String
    let action: () -> Void
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbole).font(.system(size: 13, weight: .bold))
            Text(texte).font(.system(size: 15, weight: .semibold))
        }
        .foregroundStyle(muRouge)
        .padding(.horizontal, 26)
        .padding(.vertical, 9)
        .background(Capsule().fill(Color(hex: 0x1C1C1E)))
        .contentShape(Capsule())
        .onTapGesture { action() }
    }
}

// ============================================================ LISTES DE LA BIBLIOTHÈQUE
struct MuListeMorceauxVue: View {
    @ObservedObject private var lecture = MuLecture.partage
    @State private var filtre = ""

    private var resultats: [MuMorceau] {
        let base = MuDonnees.morceaux
        guard !filtre.isEmpty else { return base }
        let terme = filtre.lowercased()
        return base.filter {
            $0.titre.lowercased().contains(terme)
            || $0.artiste.lowercased().contains(terme)
            || $0.album.lowercased().contains(terme)
        }
    }

    var body: some View {
        let liste = resultats
        let identifiants = liste.map { $0.id }
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                MuEnteteNav(titre: "Morceaux")
                MuChampRecherche(texte: $filtre, invite: "Rechercher")
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                Text(MuFormat.compte(liste.count, "morceau", "morceaux"))
                    .font(.system(size: 13))
                    .foregroundStyle(muGris)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                LazyVStack(spacing: 0) {
                    ForEach(liste) { morceau in
                        MuCelluleMorceau(morceau: morceau, afficherAlbum: true) {
                            lecture.lancer(identifiants,
                                           depuis: identifiants.firstIndex(of: morceau.id) ?? 0,
                                           source: "Morceaux")
                        }
                        MuSeparateur(retrait: 60)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuListeAlbumsVue: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                MuEnteteNav(titre: "Albums")
                Text(MuFormat.compte(MuDonnees.albums.count, "album", "albums"))
                    .font(.system(size: 13))
                    .foregroundStyle(muGris)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 18) {
                    ForEach(MuDonnees.albums) { album in
                        MuTuileAjoutRecent(indice: album.id)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuListeArtistesVue: View {
    var body: some View {
        let noms = MuDonnees.artistes
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                MuEnteteNav(titre: "Artistes")
                Text(MuFormat.compte(noms.count, "artiste", "artistes"))
                    .font(.system(size: 13))
                    .foregroundStyle(muGris)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                ForEach(Array(noms.enumerated()), id: \.offset) { indice, nom in
                    let initiale = String(nom.prefix(1)).uppercased()
                    let precedente: String = indice == 0 ? "" :
                        String(noms[indice - 1].prefix(1)).uppercased()
                    if initiale != precedente {
                        Text(initiale)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .padding(.bottom, 4)
                    }
                    NavigationLink(value: MuRoute.artiste(nom)) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: MuDonnees.albumsDe(artiste: nom).first?.teinte ?? 0x3A3A3C))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(initiale)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                )
                            Text(nom)
                                .font(.system(size: 17))
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(muGris)
                        }
                        .padding(.vertical, 7)
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)
                    MuSeparateur(retrait: 72)
                }
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuListePlaylistsVue: View {
    @ObservedObject private var lecture = MuLecture.partage
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                MuEnteteNav(titre: "Playlists")
                NavigationLink(value: MuRoute.favoris) {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(LinearGradient(colors: [muRouge, Color(hex: 0x8A1020)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Morceaux préférés")
                                .font(.system(size: 17))
                                .foregroundStyle(.white)
                            Text(MuFormat.compte(lecture.favoris.count, "titre", "titres"))
                                .font(.system(size: 14))
                                .foregroundStyle(muGris)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(muGris)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                MuSeparateur(retrait: 84)
                ForEach(MuDonnees.playlists) { playlist in
                    NavigationLink(value: MuRoute.playlist(playlist.id)) {
                        HStack(spacing: 12) {
                            MuPochette(titre: playlist.titre, artiste: playlist.auteur,
                                       teinte: playlist.teinte, teinte2: playlist.teinte2,
                                       cote: 56, coin: 6, compacte: true)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(playlist.titre)
                                    .font(.system(size: 17))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                Text(MuFormat.compte(MuDonnees.morceauxDe(playlist: playlist).count,
                                                     "titre", "titres"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(muGris)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(muGris)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    MuSeparateur(retrait: 84)
                }
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuTelechargementsVue: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                MuEnteteNav(titre: "Téléchargements")
                Text("Disponibles hors connexion — "
                     + MuFormat.compte(MuDonnees.telechargements.count, "album", "albums"))
                    .font(.system(size: 13))
                    .foregroundStyle(muGris)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 18) {
                    ForEach(MuDonnees.telechargements, id: \.self) { indice in
                        MuTuileAjoutRecent(indice: indice)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuRecentsVue: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                MuEnteteNav(titre: "Écoutés récemment")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 18) {
                    ForEach(MuDonnees.recentsAlbums, id: \.self) { indice in
                        MuTuileAjoutRecent(indice: indice)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuTitresMomentVue: View {
    @ObservedObject private var lecture = MuLecture.partage
    var body: some View {
        let identifiants = MuDonnees.titresMoment
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                MuEnteteNav(titre: "Titres du moment")
                VStack(spacing: 0) {
                    ForEach(identifiants, id: \.self) { identifiant in
                        if let morceau = MuDonnees.morceau(identifiant) {
                            MuCelluleMorceau(morceau: morceau) {
                                lecture.lancer(identifiants,
                                               depuis: identifiants.firstIndex(of: identifiant) ?? 0,
                                               source: "Titres du moment")
                            }
                            MuSeparateur(retrait: 60)
                        }
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuGenreVue: View {
    let genre: String
    @ObservedObject private var lecture = MuLecture.partage
    var body: some View {
        let albums = MuDonnees.albums.filter { $0.genre == genre }
        let morceaux = MuDonnees.morceaux.filter { MuDonnees.albumDe($0)?.genre == genre }
        let identifiants = morceaux.map { $0.id }
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                MuEnteteNav(titre: genre)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(albums) { album in
                            MuVignetteAlbum(indice: album.id, cote: 150)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                Text(MuFormat.compte(morceaux.count, "morceau", "morceaux"))
                    .font(.system(size: 13))
                    .foregroundStyle(muGris)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
                VStack(spacing: 0) {
                    ForEach(morceaux) { morceau in
                        MuCelluleMorceau(morceau: morceau) {
                            lecture.lancer(identifiants,
                                           depuis: identifiants.firstIndex(of: morceau.id) ?? 0,
                                           source: genre)
                        }
                        MuSeparateur(retrait: 60)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct MuStationVue: View {
    let indice: Int
    @ObservedObject private var lecture = MuLecture.partage

    private var station: MuStation? {
        guard indice >= 0, indice < MuDonnees.stations.count else { return nil }
        return MuDonnees.stations[indice]
    }

    var body: some View {
        Group {
            if let station = station {
                contenu(station)
            } else {
                MuVueVide(message: "Cette station n'est pas disponible.")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func contenu(_ station: MuStation) -> some View {
        // La station puise dans le catalogue de Sarah : ce qui est annoncé est réellement joué.
        let morceaux = MuDonnees.morceaux
        let identifiants = morceaux.map { $0.id }
        return ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                HStack {
                    MuRetour()
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)

                MuTuileStation(station: station)
                    .frame(width: 180)

                VStack(spacing: 4) {
                    Text(station.nom)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                    Text(station.emission + " · " + station.creneau)
                        .font(.system(size: 14))
                        .foregroundStyle(muGris)
                    Text(station.accroche)
                        .font(.system(size: 15))
                        .foregroundStyle(muGris)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                MuRangeeLecture(identifiants: identifiants, source: station.nom,
                                telechargeable: false)

                MuTitreSection(titre: "À l'antenne maintenant")
                    .padding(.top, 8)
                VStack(spacing: 0) {
                    ForEach(Array(morceaux.dropFirst(indice * 9).prefix(8))) { morceau in
                        MuCelluleMorceau(morceau: morceau) {
                            lecture.lancer(identifiants,
                                           depuis: identifiants.firstIndex(of: morceau.id) ?? 0,
                                           source: station.nom)
                        }
                        MuSeparateur(retrait: 60)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 170)
            }
        }
        .background(muFond)
    }
}

struct MuVueVide: View {
    let message: String
    var body: some View {
        VStack(spacing: 14) {
            MuRetour()
            Text(message)
                .font(.system(size: 16))
                .foregroundStyle(muGris)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(muFond)
    }
}

struct MuChampRecherche: View {
    @Binding var texte: String
    let invite: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(muGris)
            TextField(invite, text: $texte)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .autocorrectionDisabled(true)
            if !texte.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(muGris)
                    .contentShape(Rectangle())
                    .onTapGesture { texte = "" }
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(hex: 0x1C1C1E)))
    }
}

// ============================================================ RECHERCHER (réelle : filtre le catalogue)
struct MuRechercheVue: View {
    @Binding var texte: String
    @ObservedObject private var lecture = MuLecture.partage
    @State private var portee = 0   // 0 = Apple Music, 1 = Bibliothèque

    private var terme: String { texte.trimmingCharacters(in: .whitespaces).lowercased() }

    private var morceauxTrouves: [MuMorceau] {
        guard !terme.isEmpty else { return [] }
        return MuDonnees.morceaux.filter {
            $0.titre.lowercased().contains(terme)
            || $0.artiste.lowercased().contains(terme)
            || $0.album.lowercased().contains(terme)
        }
    }

    private var albumsTrouves: [MuAlbum] {
        guard !terme.isEmpty else { return [] }
        return MuDonnees.albums.filter {
            $0.titre.lowercased().contains(terme)
            || $0.artiste.lowercased().contains(terme)
            || $0.genre.lowercased().contains(terme)
        }
    }

    private var artistesTrouves: [String] {
        guard !terme.isEmpty else { return [] }
        return MuDonnees.artistes.filter { $0.lowercased().contains(terme) }
    }

    private var playlistsTrouvees: [MuPlaylist] {
        guard !terme.isEmpty else { return [] }
        return MuDonnees.playlists.filter {
            $0.titre.lowercased().contains(terme) || $0.resume.lowercased().contains(terme)
        }
    }

    private var stationsTrouvees: [MuStation] {
        guard !terme.isEmpty, portee == 0 else { return [] }
        return MuDonnees.stations.filter {
            $0.nom.lowercased().contains(terme) || $0.emission.lowercased().contains(terme)
        }
    }

    private var aucunResultat: Bool {
        morceauxTrouves.isEmpty && albumsTrouves.isEmpty && artistesTrouves.isEmpty
        && playlistsTrouvees.isEmpty && stationsTrouvees.isEmpty
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                MuEnteteTitre(titre: "Rechercher")
                if terme.isEmpty {
                    tuilesCategories
                } else {
                    segments
                    resultats
                }
                Spacer(minLength: 190)
            }
            .padding(.top, 6)
        }
        .background(muFond)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var tuilesCategories: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            ForEach(Array(MuDonnees.categories.enumerated()), id: \.offset) { _, categorie in
                MuTuileCategorie(nom: categorie.0, teinte: categorie.1, cible: categorie.2)
            }
        }
        .padding(.horizontal, 16)
    }

    private var segments: some View {
        HStack(spacing: 0) {
            ForEach(Array(["Apple Music", "Bibliothèque"].enumerated()), id: \.offset) { indice, nom in
                let choisi: Bool = portee == indice
                let teinte: Color = choisi ? Color.white : muGris
                let fond: Color = choisi ? Color(hex: 0x3A3A3C) : Color.clear
                Text(nom)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(teinte)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(fond))
                    .contentShape(Rectangle())
                    .onTapGesture { portee = indice }
            }
        }
        .padding(3)
        .background(Capsule().fill(Color(hex: 0x1C1C1E)))
        .padding(.horizontal, 16)
    }

    private var resultats: some View {
        VStack(alignment: .leading, spacing: 14) {
            if aucunResultat {
                Text("Aucun résultat pour « " + texte + " »")
                    .font(.system(size: 15))
                    .foregroundStyle(muGris)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
            }
            if !artistesTrouves.isEmpty {
                MuTitreSection(titre: "Artistes")
                VStack(spacing: 0) {
                    ForEach(artistesTrouves, id: \.self) { nom in
                        NavigationLink(value: MuRoute.artiste(nom)) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(hex: MuDonnees.albumsDe(artiste: nom).first?.teinte ?? 0x3A3A3C))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Text(String(nom.prefix(1)))
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(.white)
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(nom).font(.system(size: 16)).foregroundStyle(.white)
                                    Text("Artiste").font(.system(size: 14)).foregroundStyle(muGris)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(muGris)
                            }
                            .padding(.vertical, 7)
                        }
                        .buttonStyle(.plain)
                        MuSeparateur(retrait: 56)
                    }
                }
                .padding(.horizontal, 16)
            }
            if !albumsTrouves.isEmpty {
                MuTitreSection(titre: "Albums")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(albumsTrouves) { album in
                            MuVignetteAlbum(indice: album.id, cote: 138)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            if !playlistsTrouvees.isEmpty {
                MuTitreSection(titre: "Playlists")
                VStack(spacing: 0) {
                    ForEach(playlistsTrouvees) { playlist in
                        NavigationLink(value: MuRoute.playlist(playlist.id)) {
                            HStack(spacing: 12) {
                                MuPochette(titre: playlist.titre, artiste: playlist.auteur,
                                           teinte: playlist.teinte, teinte2: playlist.teinte2,
                                           cote: 48, coin: 5, compacte: true)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(playlist.titre).font(.system(size: 16)).foregroundStyle(.white)
                                    Text("Playlist").font(.system(size: 14)).foregroundStyle(muGris)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 7)
                        }
                        .buttonStyle(.plain)
                        MuSeparateur(retrait: 60)
                    }
                }
                .padding(.horizontal, 16)
            }
            if !stationsTrouvees.isEmpty {
                MuTitreSection(titre: "Émissions de radio")
                VStack(spacing: 0) {
                    ForEach(stationsTrouvees) { station in
                        NavigationLink(value: MuRoute.station(station.id)) {
                            HStack(spacing: 12) {
                                MuTuileStation(station: station).frame(width: 78)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(station.nom).font(.system(size: 16)).foregroundStyle(.white)
                                    Text(station.emission).font(.system(size: 14)).foregroundStyle(muGris)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 7)
                        }
                        .buttonStyle(.plain)
                        MuSeparateur(retrait: 90)
                    }
                }
                .padding(.horizontal, 16)
            }
            if !morceauxTrouves.isEmpty {
                MuTitreSection(titre: "Morceaux")
                let identifiants = morceauxTrouves.map { $0.id }
                LazyVStack(spacing: 0) {
                    ForEach(morceauxTrouves) { morceau in
                        MuCelluleMorceau(morceau: morceau, afficherAlbum: true) {
                            lecture.lancer(identifiants,
                                           depuis: identifiants.firstIndex(of: morceau.id) ?? 0,
                                           source: "Recherche")
                        }
                        MuSeparateur(retrait: 60)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct MuTuileCategorie: View {
    let nom: String
    let teinte: UInt
    let cible: String
    var body: some View {
        Group {
            if cible == "radio" {
                NavigationLink(value: MuRoute.station(0)) { tuile }
                    .buttonStyle(.plain)
            } else {
                NavigationLink(value: MuRoute.genre(cible)) { tuile }
                    .buttonStyle(.plain)
            }
        }
    }

    private var tuile: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: teinte),
                                              Color(hex: MuPochette.assombrir(teinte))],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(nom)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .padding(12)
        }
        .frame(height: 80)
    }
}

// Barre de recherche basse (remplace la barre d'onglets sur l'onglet Rechercher — frames e131+)
struct MuBarreRecherche: View {
    @Binding var texte: String
    let retour: () -> Void
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "house.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                )
                .contentShape(Circle())
                .onTapGesture { retour() }
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(muGris)
                TextField("Artistes, morceaux, paroles…", text: $texte)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .autocorrectionDisabled(true)
                if texte.isEmpty {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(muGris)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(muGris)
                        .contentShape(Rectangle())
                        .onTapGesture { texte = "" }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(Capsule().fill(.ultraThinMaterial))
        }
        .padding(.horizontal, 12)
    }
}

// ============================================================ LECTEUR PLEIN ÉCRAN
struct MuLecteurVue: View {
    @Environment(\.dismiss) private var fermer
    @ObservedObject private var lecture = MuLecture.partage
    @Binding var fileVisible: Bool
    @State private var menuVisible = false
    @State private var parolesVisibles = false

    var body: some View {
        ZStack {
            let teinte: UInt = lecture.courant.map { MuDonnees.teinteDe($0) } ?? 0x2C2C2E
            LinearGradient(colors: [Color(hex: MuPochette.assombrir(teinte)),
                                    Color(hex: 0x14121A)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if let morceau = lecture.courant {
                contenu(morceau)
            } else {
                VStack(spacing: 14) {
                    Text("Aucune lecture en cours")
                        .font(.system(size: 17))
                        .foregroundStyle(muGris)
                    Text("Fermer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .contentShape(Rectangle())
                        .onTapGesture { fermer() }
                }
            }

            VStack {
                Spacer()
                BarreHome { fermer() }
            }
        }
        .sheet(isPresented: $menuVisible) {
            if let morceau = lecture.courant {
                MuMenuMorceauVue(morceau: morceau)
            }
        }
        .sheet(isPresented: $parolesVisibles) {
            MuParolesVue(morceau: lecture.courant)
        }
        .preferredColorScheme(.dark)
    }

    private func contenu(_ morceau: MuMorceau) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .contentShape(Rectangle())
                .onTapGesture { fermer() }

            MuPochetteMorceau(morceau: morceau, cote: 264, coin: 8)
                .shadow(color: .black.opacity(0.5), radius: 14, y: 8)
                .padding(.top, 26)

            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(morceau.titre)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(morceau.artiste)
                        .font(.system(size: 22))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
                Spacer(minLength: 6)
                let symboleFavori: String = lecture.estFavori(morceau.id) ? "star.fill" : "star"
                Circle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: symboleFavori)
                            .font(.system(size: 15))
                            .foregroundStyle(.white)
                    )
                    .contentShape(Circle())
                    .onTapGesture { lecture.basculerFavori(morceau.id) }
                Circle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15))
                            .foregroundStyle(.white)
                    )
                    .contentShape(Circle())
                    .onTapGesture { menuVisible = true }
            }
            .padding(.horizontal, 24)
            .padding(.top, 26)

            barreProgression
                .padding(.horizontal, 24)
                .padding(.top, 18)

            HStack {
                Image(systemName: "backward.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 60)
                    .contentShape(Rectangle())
                    .onTapGesture { lecture.precedent() }
                Spacer()
                let symboleLecture: String = lecture.enLecture ? "pause.fill" : "play.fill"
                Image(systemName: symboleLecture)
                    .font(.system(size: 38))
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 60)
                    .contentShape(Rectangle())
                    .onTapGesture { lecture.basculer() }
                Spacer()
                Image(systemName: "forward.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 60)
                    .contentShape(Rectangle())
                    .onTapGesture { lecture.suivant() }
            }
            .padding(.horizontal, 30)
            .padding(.top, 18)

            curseurVolume
                .padding(.horizontal, 24)
                .padding(.top, 24)

            HStack {
                Image(systemName: "quote.bubble")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 60, height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture { parolesVisibles = true }
                Spacer()
                VStack(spacing: 2) {
                    Image(systemName: "airpodspro")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.7))
                    Text(lecture.sortieAudio)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "list.bullet")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 60, height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture { fermer(); fileVisible = true }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer(minLength: 10)
        }
    }

    private var barreProgression: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                let avance: CGFloat = lecture.duree > 0 ?
                    CGFloat(lecture.position / lecture.duree) * geo.size.width : 0
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.22)).frame(height: 6)
                    Capsule().fill(Color.white.opacity(0.85))
                        .frame(width: max(0, min(avance, geo.size.width)), height: 6)
                }
                .frame(height: 22)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0).onChanged { valeur in
                        guard geo.size.width > 0 else { return }
                        let ratio = Double(valeur.location.x / geo.size.width)
                        lecture.position = min(max(0, ratio), 1) * lecture.duree
                    }
                )
            }
            .frame(height: 22)
            HStack {
                Text(MuFormat.horloge(lecture.position))
                Spacer()
                Text(MuFormat.restant(lecture.position, lecture.duree))
            }
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var curseurVolume: some View {
        HStack(spacing: 10) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.6))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.22)).frame(height: 5)
                    Capsule().fill(Color.white.opacity(0.85))
                        .frame(width: geo.size.width * CGFloat(lecture.volume), height: 5)
                }
                .frame(height: 18)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0).onChanged { valeur in
                        guard geo.size.width > 0 else { return }
                        lecture.volume = min(max(0, Double(valeur.location.x / geo.size.width)), 1)
                    }
                )
            }
            .frame(height: 18)
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

// ============================================================ FILE D'ATTENTE
struct MuFileVue: View {
    @Environment(\.dismiss) private var fermer
    @ObservedObject private var lecture = MuLecture.partage

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0x1C1C1E).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Poursuivre la lecture")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("Fermer")
                            .font(.system(size: 16))
                            .foregroundStyle(muRouge)
                            .contentShape(Rectangle())
                            .onTapGesture { fermer() }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 6)

                    if let courant = lecture.courant {
                        Text("En cours — " + lecture.source)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(muGris)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        MuLigneFile(morceau: courant, courant: true) { }
                            .padding(.horizontal, 16)
                    }

                    if lecture.suivants.isEmpty {
                        Text("Plus rien après ce morceau.")
                            .font(.system(size: 15))
                            .foregroundStyle(muGris)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                    } else {
                        Text("À SUIVRE")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(muGris)
                            .padding(.horizontal, 16)
                            .padding(.top, 18)
                            .padding(.bottom, 4)
                        LazyVStack(spacing: 0) {
                            ForEach(Array(lecture.suivants.enumerated()), id: \.offset) { rang, morceau in
                                MuLigneFile(morceau: morceau, courant: false) {
                                    lecture.allerA(lecture.index + 1 + rang)
                                }
                                MuSeparateur(retrait: 60)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    Spacer(minLength: 60)
                }
            }
            BarreHome { fermer() }
        }
        .preferredColorScheme(.dark)
    }
}

struct MuLigneFile: View {
    let morceau: MuMorceau
    let courant: Bool
    let action: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            MuPochetteMorceau(morceau: morceau, cote: 44, coin: 4)
            VStack(alignment: .leading, spacing: 2) {
                let teinteFile: Color = courant ? muRouge : Color.white
                Text(morceau.titre)
                    .font(.system(size: 16))
                    .foregroundStyle(teinteFile)
                    .lineLimit(1)
                Text(morceau.artiste)
                    .font(.system(size: 14))
                    .foregroundStyle(muGris)
                    .lineLimit(1)
            }
            Spacer(minLength: 6)
            if courant {
                Image(systemName: "waveform")
                    .font(.system(size: 15))
                    .foregroundStyle(muRouge)
            } else {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 14))
                    .foregroundStyle(muGris)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }
}

// ============================================================ MENU « … » D'UN MORCEAU
// D82/D92 : ne restent que les actions qui produisent un état visible. Retirés du menu filmé :
// « Épingler le morceau », « Créer une station », « Partager les paroles »,
// « Afficher les crédits », « Supprimer de la bibliothèque » (aucune conséquence utile au jeu).
struct MuMenuMorceauVue: View {
    @Environment(\.dismiss) private var fermer
    @ObservedObject private var lecture = MuLecture.partage
    let morceau: MuMorceau

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                MuPochetteMorceau(morceau: morceau, cote: 54, coin: 6)
                VStack(alignment: .leading, spacing: 2) {
                    Text(morceau.titre)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(morceau.artiste + " — " + morceau.album)
                        .font(.system(size: 14))
                        .foregroundStyle(muGris)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(16)

            MuSeparateur()

            let etiquetteFavori: String = lecture.estFavori(morceau.id) ?
                "Retirer des morceaux préférés" : "Ajouter aux morceaux préférés"
            let symboleFavori: String = lecture.estFavori(morceau.id) ? "star.slash" : "star"
            MuLigneMenu(symbole: symboleFavori, texte: etiquetteFavori) {
                lecture.basculerFavori(morceau.id)
                fermer()
            }
            MuSeparateur(retrait: 50)
            MuLigneMenu(symbole: "text.line.first.and.arrowtriangle.forward", texte: "Lire ensuite") {
                if lecture.file.isEmpty {
                    lecture.lancer([morceau.id], depuis: 0, source: morceau.album)
                } else {
                    let position = min(lecture.index + 1, lecture.file.count)
                    lecture.file.insert(morceau.id, at: position)
                }
                fermer()
            }
            MuSeparateur(retrait: 50)
            MuLigneMenu(symbole: "text.append", texte: "Ajouter à la fin de la file") {
                if lecture.file.isEmpty {
                    lecture.lancer([morceau.id], depuis: 0, source: morceau.album)
                } else {
                    lecture.file.append(morceau.id)
                }
                fermer()
            }
            MuSeparateur(retrait: 50)
            MuLigneMenu(symbole: "play.circle", texte: "Lire maintenant") {
                let identifiants = MuDonnees.morceauxDe(album: morceau.album).map { $0.id }
                lecture.lancer(identifiants,
                               depuis: identifiants.firstIndex(of: morceau.id) ?? 0,
                               source: morceau.album)
                fermer()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(hex: 0x1C1C1E).ignoresSafeArea())
        .presentationDetents([.height(330)])
        .preferredColorScheme(.dark)
    }
}

struct MuLigneMenu: View {
    let symbole: String
    let texte: String
    let action: () -> Void
    var body: some View {
        HStack(spacing: 14) {
            Text(texte)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: symbole)
                .font(.system(size: 16))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }
}

// ============================================================ PAROLES (état, pas d'audio synchronisé)
struct MuParolesVue: View {
    @Environment(\.dismiss) private var fermer
    let morceau: MuMorceau?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0x1C1C1E).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(morceau?.titre ?? "Paroles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("Fermer")
                            .font(.system(size: 16))
                            .foregroundStyle(muRouge)
                            .contentShape(Rectangle())
                            .onTapGesture { fermer() }
                    }
                    .padding(.top, 18)
                    Text("Les paroles de ce morceau ne sont pas incluses dans le téléchargement.")
                        .font(.system(size: 16))
                        .foregroundStyle(muGris)
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
            }
            BarreHome { fermer() }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ CAPTURE (D63)
// Lecteur seul pour la capture : l'état de départ est préparé avant l'affichage.
struct MuLecteurVueCapture: View {
    @State private var fileVisible = false
    var body: some View {
        MuLecteurVue(fileVisible: $fileVisible)
            .onAppear {
                MusiqueVue.preparerEtat()
                MuLecture.partage.enLecture = true
            }
    }
}
