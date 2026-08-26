// Spotify — construit contre les références vidéo de Joachim du 26/08 (D67, 122 écrans mesurés).
// v1 : accueil (chips, grille reprise, sections horizontales, mini-lecteur), lecteur plein écran
// (contrôles réels + carte paroles), page artiste, bibliothèque, recherche, écran Premium.
// Audio : lecture simulée (pas de fichiers audio — curseur animé). Données Sarah remplaçables (D59).
import SwiftUI

// ============================================================ DONNÉES
struct SpotTitre: Identifiable {
    let id = UUID()
    var titre: String
    var artiste: String
    var teinte: UInt
    var image: String?
}

enum DonneesSpot {
    static let reprise: [SpotTitre] = [
        SpotTitre(titre: "Nuits d'été", artiste: "Léna Situations · Podcast", teinte: 0xB56576, image: "p24"),
        SpotTitre(titre: "C'est la cité", artiste: "Jul", teinte: 0x355070, image: nil),
        SpotTitre(titre: "Air Max", artiste: "Rim'K, Ninho", teinte: 0x6D597A, image: nil),
        SpotTitre(titre: "Chill piano", artiste: "Playlist", teinte: 0x2A9D8F, image: "p31"),
        SpotTitre(titre: "Randonnée 🥾", artiste: "Playlist de Sarah", teinte: 0xE9C46A, image: "p30"),
        SpotTitre(titre: "Feel Good Friday", artiste: "Playlist", teinte: 0xE76F51, image: "p27"),
    ]
    static let radio: [(String, String, UInt)] = [
        ("The Weeknd", "Ariana Grande, The Weeknd, Future…", 0xB84DFF),
        ("Bad Bunny", "Bad Bunny, Ozuna, Arcángel…", 0xE84D8A),
        ("Amy Winehouse", "Amy Winehouse, Mark Ronson…", 0x2A9D8F),
    ]
    static let titresArtiste: [(String, String)] = [
        ("Soleil", "38 904 314"), ("Parisienne", "179 471 625"), ("Ninao", "246 026 018"),
        ("SPA", "66 580 169"), ("Spider", "97 210 883"),
    ]
}

let spotVert: UInt = 0x1ED760
let spotFond: UInt = 0x121212

// ============================================================ APP (5 onglets)
struct SpotifyVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0
    @State private var lecteurVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: spotFond).ignoresSafeArea()
            Group {
                switch onglet {
                case 1: SpotRechercheVue()
                case 2: SpotBibliothequeVue()
                case 3: SpotPremiumVue()
                default: SpotAccueilVue()
                }
            }

            VStack(spacing: 0) {
                // Mini-lecteur
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 5).fill(Color(hex: 0x6D597A)).frame(width: 38, height: 38)
                        .overlay(Image(systemName: "music.note").font(.system(size: 15)).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Air Max").font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                        Text("Rim'K, Ninho").font(.system(size: 12)).foregroundStyle(.gray)
                    }
                    Spacer()
                    Image(systemName: "hifispeaker").font(.system(size: 16)).foregroundStyle(.gray)
                    Image(systemName: "play.fill").font(.system(size: 19)).foregroundStyle(.white)
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(Color(hex: 0x4A3A50), in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 8).padding(.bottom, 4)
                .contentShape(Rectangle())
                .onTapGesture { lecteurVisible = true }

                HStack {
                    ForEach(Array([
                        ("house.fill", "Accueil", 0), ("magnifyingglass", "Recherche", 1),
                        ("books.vertical.fill", "Bibliothèque", 2), ("sparkle", "Premium", 3),
                        ("plus", "Créer", 4),
                    ].enumerated()), id: \.offset) { _, o in
                        VStack(spacing: 3) {
                            Image(systemName: o.0).font(.system(size: 20))
                            Text(o.1).font(.system(size: 9.5))
                        }
                        .foregroundStyle(onglet == o.2 ? Color.white : Color.gray)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { if o.2 < 4 { onglet = o.2 } }
                    }
                }
                .padding(.top, 8).padding(.bottom, 26)
                .background(Color.black.opacity(0.96))
            }

            BarreHome { dismiss() }
        }
        .fullScreenCover(isPresented: $lecteurVisible) { SpotLecteurVue() }
        .onAppear {
            let cle = ProcessInfo.processInfo.environment["ECRAN"] ?? ""
            if cle == "spotify.lecteur" { lecteurVisible = true }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ ACCUEIL
struct SpotAccueilVue: View {
    @State private var artisteVisible = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Group {
                        if let img = ChargeurPhoto.image("p04") {
                            Image(uiImage: img).resizable().scaledToFill().frame(width: 32, height: 32).clipShape(Circle())
                        } else { Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 32, height: 32) }
                    }
                    ForEach(Array([("Tout", true), ("Musique", false), ("Podcasts", false), ("Livres audio", false)].enumerated()), id: \.offset) { _, c in
                        Text(c.0).font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(c.1 ? Color.black : Color.white)
                            .padding(.horizontal, 13).padding(.vertical, 7)
                            .background(c.1 ? Color(hex: spotVert) : Color(hex: 0x2A2A2A), in: Capsule())
                    }
                }
                .padding(.horizontal, 14)

                Text("Lancer la lecture").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).padding(.horizontal, 14)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(DonneesSpot.reprise) { t in
                        HStack(spacing: 8) {
                            Group {
                                if let cle = t.image, let img = ChargeurPhoto.image(cle) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else {
                                    Rectangle().fill(Color(hex: t.teinte))
                                        .overlay(Image(systemName: "music.note").font(.system(size: 15)).foregroundStyle(.white.opacity(0.8)))
                                }
                            }
                            .frame(width: 48, height: 48).clipped()
                            Text(t.titre).font(.system(size: 12.5, weight: .semibold)).foregroundStyle(.white).lineLimit(2)
                            Spacer(minLength: 2)
                        }
                        .background(Color(hex: 0x2A2A2A))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                .padding(.horizontal, 14)

                Text("Radio tendance").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).padding(.horizontal, 14)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(DonneesSpot.radio.enumerated()), id: \.offset) { _, r in
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack(alignment: .topLeading) {
                                    Rectangle().fill(Color(hex: r.2)).frame(width: 150, height: 150)
                                        .overlay(Image(systemName: "dot.radiowaves.left.and.right").font(.system(size: 40)).foregroundStyle(.white.opacity(0.7)))
                                    Text("RADIO").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                                        .padding(.horizontal, 6).padding(.vertical, 3)
                                        .background(Color.black.opacity(0.5), in: Capsule())
                                        .padding(6)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                Text(r.0).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                Text(r.1).font(.system(size: 11.5)).foregroundStyle(.gray).lineLimit(2).frame(width: 150, alignment: .leading)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { artisteVisible = true }
                        }
                    }
                    .padding(.horizontal, 14)
                }

                Text("Conçu pour Sarah").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).padding(.horizontal, 14)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array([("Découvertes de la semaine", 0xD62828), ("Daily Mix 01", 0xE84D8A), ("Daily Mix 02", 0x2A9D8F)].enumerated()), id: \.offset) { _, m in
                            VStack(alignment: .leading, spacing: 6) {
                                Rectangle().fill(Color(hex: UInt(m.1))).frame(width: 150, height: 150)
                                    .overlay(Text(m.0).font(.system(size: 15, weight: .heavy)).foregroundStyle(.white).multilineTextAlignment(.center).padding(8))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }
                Spacer(minLength: 160)
            }
            .padding(.top, 8)
        }
        .sheet(isPresented: $artisteVisible) { SpotArtisteVue() }
    }
}

// ============================================================ LECTEUR
struct SpotLecteurVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var enLecture = true
    @State private var progression: Double = 63
    private let minuteur = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x6D597A), Color(hex: spotFond)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                HStack {
                    Image(systemName: "chevron.down").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                        .contentShape(Rectangle())
                        .onTapGesture { dismiss() }
                    Spacer()
                    Text("Titres likés").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "ellipsis").foregroundStyle(.white)
                }
                .padding(.horizontal, 18).padding(.top, 8)

                RoundedRectangle(cornerRadius: 8).fill(Color(hex: 0x355070))
                    .frame(width: 330, height: 330)
                    .overlay(Image(systemName: "music.note").font(.system(size: 80)).foregroundStyle(.white.opacity(0.6)))
                    .padding(.top, 12)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Air Max").font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                        Text("Rim'K, Ninho").font(.system(size: 14)).foregroundStyle(.gray)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 24)).foregroundStyle(Color(hex: spotVert))
                }
                .padding(.horizontal, 22)

                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.25)).frame(height: 4)
                            Capsule().fill(Color.white).frame(width: geo.size.width * progression / 222, height: 4)
                        }
                    }
                    .frame(height: 4)
                    HStack {
                        Text(String(format: "%d:%02d", Int(progression) / 60, Int(progression) % 60))
                        Spacer()
                        Text("3:42")
                    }
                    .font(.system(size: 11)).foregroundStyle(.gray)
                }
                .padding(.horizontal, 22)

                HStack {
                    Image(systemName: "shuffle").font(.system(size: 20)).foregroundStyle(Color(hex: spotVert))
                    Spacer()
                    Image(systemName: "backward.end.fill").font(.system(size: 26)).foregroundStyle(.white)
                    Spacer()
                    Circle().fill(Color.white).frame(width: 62, height: 62)
                        .overlay(Image(systemName: enLecture ? "pause.fill" : "play.fill").font(.system(size: 25)).foregroundStyle(.black))
                        .contentShape(Circle())
                        .onTapGesture { Haptique.leger(); enLecture.toggle() }
                    Spacer()
                    Image(systemName: "forward.end.fill").font(.system(size: 26)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "timer").font(.system(size: 19)).foregroundStyle(.white)
                }
                .padding(.horizontal, 26)

                // Carte paroles (référence : bloc coloré « Aperçu des paroles »)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Aperçu des paroles").font(.system(size: 12, weight: .bold)).foregroundStyle(.white.opacity(0.85))
                    Text("J'arrive en Air Max, personne peut stopper la machine\nOn connaît le quartier, on connaît la routine")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                    Text("Afficher les paroles").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(hex: 0xD62828), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 18)

                Spacer()
            }
            VStack {
                Spacer()
                BarreHome { dismiss() }
            }
        }
        .onReceive(minuteur) { _ in if enLecture && progression < 222 { progression += 1 } }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ ARTISTE
struct SpotArtisteVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var abonnee = true
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ZStack(alignment: .bottomLeading) {
                        Rectangle().fill(LinearGradient(colors: [Color(hex: 0x355070), Color(hex: spotFond)], startPoint: .top, endPoint: .bottom))
                            .frame(height: 220)
                        Text("GIMS").font(.system(size: 42, weight: .heavy)).foregroundStyle(.white).padding(16)
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("15,8 M auditeurs mensuels").font(.system(size: 12.5)).foregroundStyle(.gray)
                            Text(abonnee ? "Abonné(e)" : "S'abonner")
                                .font(.system(size: 12.5, weight: .semibold)).foregroundStyle(.white)
                                .padding(.horizontal, 11).padding(.vertical, 6)
                                .background(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
                                .contentShape(Rectangle())
                                .onTapGesture { Haptique.leger(); abonnee.toggle() }
                        }
                        Spacer()
                        Image(systemName: "shuffle").font(.system(size: 20)).foregroundStyle(.gray)
                        Circle().fill(Color(hex: spotVert)).frame(width: 52, height: 52)
                            .overlay(Image(systemName: "play.fill").font(.system(size: 21)).foregroundStyle(.black))
                    }
                    .padding(.horizontal, 16)
                    Text("Titres les plus écoutés").font(.system(size: 18, weight: .bold)).foregroundStyle(.white).padding(.horizontal, 16)
                    ForEach(Array(DonneesSpot.titresArtiste.enumerated()), id: \.offset) { i, t in
                        HStack(spacing: 12) {
                            Text("\(i + 1)").font(.system(size: 14)).foregroundStyle(.gray).frame(width: 16)
                            RoundedRectangle(cornerRadius: 4).fill(Color(hex: 0x4A3A50)).frame(width: 44, height: 44)
                                .overlay(Image(systemName: "music.note").font(.system(size: 14)).foregroundStyle(.white.opacity(0.7)))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(t.0).font(.system(size: 15)).foregroundStyle(.white)
                                Text(t.1).font(.system(size: 12.5)).foregroundStyle(.gray)
                            }
                            Spacer()
                            Image(systemName: "ellipsis").foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 4)
                    }
                    Spacer(minLength: 40)
                }
            }
            .background(Color(hex: spotFond))
            .ignoresSafeArea(edges: .top)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ RECHERCHE + BIBLIOTHÈQUE + PREMIUM
struct SpotRechercheVue: View {
    @State private var texte = ""
    private let genres: [(String, UInt)] = [
        ("Musique", 0xD62828), ("Podcasts", 0x2A9D8F), ("Livres audio", 0xE9C46A), ("Radio", 0x355070),
        ("Concerts", 0xB84DFF), ("Rap français", 0xE76F51), ("Pop", 0xE84D8A), ("Chill", 0x6D597A),
    ]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recherche").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.black)
                    TextField("Que souhaitez-vous écouter ?", text: $texte)
                        .font(.system(size: 14.5)).foregroundStyle(.black)
                }
                .padding(.horizontal, 12).frame(height: 42)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 7))
                Text("Parcourir tout").font(.system(size: 16, weight: .bold)).foregroundStyle(.white).padding(.top, 6)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(Array(genres.enumerated()), id: \.offset) { _, g in
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 8).fill(Color(hex: g.1)).frame(height: 92)
                            Text(g.0).font(.system(size: 15, weight: .bold)).foregroundStyle(.white).padding(12)
                        }
                    }
                }
                Spacer(minLength: 160)
            }
            .padding(.horizontal, 14).padding(.top, 8)
        }
    }
}

struct SpotBibliothequeVue: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Group {
                        if let img = ChargeurPhoto.image("p04") {
                            Image(uiImage: img).resizable().scaledToFill().frame(width: 32, height: 32).clipShape(Circle())
                        } else { Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 32, height: 32) }
                    }
                    Text("Bibliothèque").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "magnifyingglass").font(.system(size: 19)).foregroundStyle(.white)
                    Image(systemName: "plus").font(.system(size: 21)).foregroundStyle(.white).padding(.leading, 12)
                }
                HStack(spacing: 8) {
                    ForEach(["Playlists", "Artistes", "Albums"], id: \.self) { c in
                        Text(c).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 13).padding(.vertical, 7)
                            .background(Color(hex: 0x2A2A2A), in: Capsule())
                    }
                }
                ForEach(Array([
                    ("Titres likés", "Playlist · 118 titres", spotVert, "heart.fill"),
                    ("Randonnée 🥾", "Playlist · de Sarah", 0xE9C46A, "music.note.list"),
                    ("GIMS", "Artiste", 0x355070, "person.fill"),
                    ("Jul", "Artiste", 0x6D597A, "person.fill"),
                    ("Léna Situations", "Podcast", 0xB56576, "mic.fill"),
                ].enumerated()), id: \.offset) { _, r in
                    HStack(spacing: 12) {
                        Group {
                            if r.1 == "Artiste" {
                                Circle().fill(Color(hex: UInt(r.2)))
                            } else {
                                RoundedRectangle(cornerRadius: 4).fill(Color(hex: UInt(r.2)))
                            }
                        }
                        .frame(width: 56, height: 56)
                        .overlay(Image(systemName: r.3).font(.system(size: 18)).foregroundStyle(.white))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(r.0).font(.system(size: 15)).foregroundStyle(.white)
                            Text(r.1).font(.system(size: 12.5)).foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                }
                Spacer(minLength: 160)
            }
            .padding(.horizontal, 14).padding(.top, 8)
        }
    }
}

struct SpotPremiumVue: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Premium").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Retrouvez Premium :\n2 mois pour 6,07 €").font(.system(size: 22, weight: .heavy)).foregroundStyle(.white)
                    Text("Offre à durée limitée").font(.system(size: 12, weight: .semibold)).foregroundStyle(.black)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Color.white, in: Capsule())
                    Text("Essayez pendant 2 mois pour 6,07 €")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(Color.white, in: Capsule())
                }
                .padding(16)
                .background(LinearGradient(colors: [Color(hex: 0x8E3B92), Color(hex: 0x1E3264)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 12))
                Text("Pourquoi s'abonner à Premium ?").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                VStack(spacing: 0) {
                    ForEach(Array(["Musique sans pub", "Téléchargez pour écouter en mode hors connexion", "Qualité audio supérieure", "Passez autant de titres que vous voulez"].enumerated()), id: \.offset) { i, a in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark").font(.system(size: 13, weight: .bold)).foregroundStyle(Color(hex: spotVert))
                            Text(a).font(.system(size: 14.5)).foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        if i < 3 { Divider().overlay(Color(hex: 0x2A2A2A)) }
                    }
                }
                Spacer(minLength: 160)
            }
            .padding(.horizontal, 14).padding(.top, 8)
        }
    }
}
