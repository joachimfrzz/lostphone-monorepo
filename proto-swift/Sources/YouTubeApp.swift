// YouTube — construit contre les références vidéo de Joachim du 26/08 (D67, 267 écrans mesurés).
// v1 : accueil (chips + cartes vidéo + rangée Shorts), lecteur (actions, description, commentaires,
// suggestions), Shorts plein écran, Abonnements, Vous (historique/playlists), notifications, recherche.
// Vidéos : images fixes de la pellicule (lecture simulée). Données Sarah remplaçables (D59).
import SwiftUI

// ============================================================ DONNÉES
struct YtVideo: Identifiable {
    let id = UUID()
    var titre: String
    var chaine: String
    var teinte: UInt
    var meta: String
    var duree: String
    var image: String?
}

enum DonneesYt {
    static let videos: [YtVideo] = [
        YtVideo(titre: "On a testé les meilleures randos autour de Lyon (ça vaut le détour)",
                chaine: "Lyon Aventures", teinte: 0x2A9D8F, meta: "128 k vues · il y a 3 jours", duree: "14:32", image: "p30"),
        YtVideo(titre: "Céramique : 10 erreurs de débutant à éviter absolument",
                chaine: "Terre & Tour", teinte: 0xFF9F0A, meta: "64 k vues · il y a 1 semaine", duree: "18:05", image: "p33"),
        YtVideo(titre: "Vlog : une semaine à Annecy 🌊", chaine: "Camille Voyage", teinte: 0xE84D8A,
                meta: "212 k vues · il y a 2 semaines", duree: "22:47", image: "p31"),
    ]
    static let shorts: [(String, String, String)] = [
        ("Le lever de soleil de ce matin 😍", "412 k", "p36"), ("Recette express du soir", "1,2 M", "p27"),
    ]
    static let commentaires: [(String, String)] = [
        ("@randolyonnais", "Le point de vue à 8:12 est incroyable, merci pour la découverte !"),
        ("@marie_69200", "On y est allés ce week-end grâce à la vidéo 🙌"),
    ]
    static let abonnements: [(String, String, UInt)] = [
        ("Lyon Aventures", "Nouvelle vidéo il y a 3 j", 0x2A9D8F),
        ("Terre & Tour", "Nouvelle vidéo il y a 1 sem.", 0xFF9F0A),
        ("Camille Voyage", "Nouvelle vidéo il y a 2 sem.", 0xE84D8A),
    ]
}

let ytRouge: UInt = 0xFF0000
let ytFond: UInt = 0x0F0F0F

struct YtMiniature: View {
    let video: YtVideo
    var hauteur: CGFloat = 210
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let cle = video.image, let img = ChargeurPhoto.image(cle) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else { Rectangle().fill(Color(hex: video.teinte)) }
            }
            .frame(maxWidth: .infinity).frame(height: hauteur).clipped()
            Text(video.duree).font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                .padding(.horizontal, 5).padding(.vertical, 2)
                .background(Color.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 4))
                .padding(8)
        }
    }
}

// ============================================================ APP (5 onglets)
struct YouTubeVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: ytFond).ignoresSafeArea()
            Group {
                switch onglet {
                case 1: YtShortsVue()
                case 2: YtAbonnementsVue()
                case 3: YtVousVue()
                default: YtAccueilVue()
                }
            }

            HStack {
                ForEach(Array([
                    ("house.fill", "Accueil", 0), ("bolt.fill", "Shorts", 1),
                    ("plus.circle", "", 4), ("play.square.stack", "Abonnements", 2),
                    ("person.circle", "Vous", 3),
                ].enumerated()), id: \.offset) { _, o in
                    VStack(spacing: 3) {
                        Image(systemName: o.0).font(.system(size: o.1.isEmpty ? 30 : 20))
                        if !o.1.isEmpty { Text(o.1).font(.system(size: 9)) }
                    }
                    .foregroundStyle(onglet == o.2 && o.2 < 4 ? Color.white : Color.gray)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { if o.2 < 4 { onglet = o.2 } }
                }
            }
            .padding(.top, 8).padding(.bottom, 26)
            .background(Color(hex: ytFond).opacity(0.98))
            .overlay(Rectangle().fill(Color(hex: 0x272727)).frame(height: 0.5), alignment: .top)

            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ ACCUEIL
struct YtAccueilVue: View {
    @State private var videoOuverte: YtVideo? = nil
    @State private var notifsVisibles = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "play.rectangle.fill").font(.system(size: 26)).foregroundStyle(Color(hex: ytRouge))
                    Text("YouTube").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).kerning(-0.5)
                    Spacer()
                    Image(systemName: "tv").font(.system(size: 18)).foregroundStyle(.white)
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell").font(.system(size: 19)).foregroundStyle(.white)
                        Text("9+").font(.system(size: 8, weight: .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 3).padding(.vertical, 1)
                            .background(Color(hex: ytRouge), in: Capsule())
                            .offset(x: 7, y: -5)
                    }
                    .padding(.leading, 14)
                    .contentShape(Rectangle())
                    .onTapGesture { notifsVisibles = true }
                    Image(systemName: "magnifyingglass").font(.system(size: 19)).foregroundStyle(.white).padding(.leading, 14)
                }
                .padding(.horizontal, 14)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array([("Tous", true), ("Randonnée", false), ("Musique", false), ("Céramique", false), ("Actualités", false)].enumerated()), id: \.offset) { _, c in
                            Text(c.0).font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(c.1 ? Color.black : Color.white)
                                .padding(.horizontal, 12).padding(.vertical, 7)
                                .background(c.1 ? Color.white : Color(hex: 0x272727), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 14)
                }

                ForEach(DonneesYt.videos.prefix(1)) { v in
                    YtCarteVideo(video: v) { videoOuverte = v }
                }

                // Rangée Shorts
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill").font(.system(size: 17)).foregroundStyle(Color(hex: ytRouge))
                    Text("Shorts").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 14)
                HStack(spacing: 8) {
                    ForEach(Array(DonneesYt.shorts.enumerated()), id: \.offset) { _, s in
                        ZStack(alignment: .bottomLeading) {
                            Group {
                                if let img = ChargeurPhoto.image(s.2) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else { Rectangle().fill(Color(hex: 0x272727)) }
                            }
                            .frame(height: 260).clipped()
                            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.0).font(.system(size: 12.5, weight: .semibold)).foregroundStyle(.white).lineLimit(2)
                                Text("\(s.1) de vues").font(.system(size: 11)).foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(8)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 14)

                ForEach(DonneesYt.videos.dropFirst()) { v in
                    YtCarteVideo(video: v) { videoOuverte = v }
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 6)
        }
        .fullScreenCover(isPresented: Binding(get: { videoOuverte != nil }, set: { if !$0 { videoOuverte = nil } })) {
            YtLecteurVue(video: videoOuverte ?? DonneesYt.videos[0])
        }
        .sheet(isPresented: $notifsVisibles) { YtNotificationsVue() }
    }
}

struct YtCarteVideo: View {
    let video: YtVideo
    let action: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            YtMiniature(video: video)
            HStack(alignment: .top, spacing: 10) {
                Circle().fill(Color(hex: video.teinte)).frame(width: 36, height: 36)
                    .overlay(Text(String(video.chaine.prefix(1))).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 3) {
                    Text(video.titre).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(.white).lineLimit(2)
                    Text("\(video.chaine) · \(video.meta)").font(.system(size: 12)).foregroundStyle(.gray)
                }
                Spacer()
                Image(systemName: "ellipsis").foregroundStyle(.gray).rotationEffect(.degrees(90))
            }
            .padding(.horizontal, 14)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// ============================================================ LECTEUR
struct YtLecteurVue: View {
    @Environment(\.dismiss) private var dismiss
    let video: YtVideo
    @State private var aime = false
    @State private var abonne = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                YtMiniature(video: video, hauteur: 230)
                Image(systemName: "chevron.down").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                    .padding(12)
                    .contentShape(Rectangle())
                    .onTapGesture { dismiss() }
                VStack { Spacer(); HStack { Spacer()
                    Circle().fill(Color.black.opacity(0.5)).frame(width: 54, height: 54)
                        .overlay(Image(systemName: "play.fill").font(.system(size: 22)).foregroundStyle(.white))
                    Spacer() }; Spacer() }
            }
            .frame(height: 230)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(video.titre).font(.system(size: 16.5, weight: .bold)).foregroundStyle(.white)
                    Text("\(video.meta) · #lyon #rando").font(.system(size: 12.5)).foregroundStyle(.gray)

                    HStack(spacing: 10) {
                        Circle().fill(Color(hex: video.teinte)).frame(width: 34, height: 34)
                            .overlay(Text(String(video.chaine.prefix(1))).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white))
                        Text(video.chaine).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                        Text("128 k").font(.system(size: 12)).foregroundStyle(.gray)
                        Spacer()
                        Text(abonne ? "Abonné(e)" : "S'abonner")
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundStyle(abonne ? Color.white : Color.black)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(abonne ? Color(hex: 0x272727) : Color.white, in: Capsule())
                            .contentShape(Capsule())
                            .onTapGesture { Haptique.leger(); abonne.toggle() }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            HStack(spacing: 0) {
                                HStack(spacing: 5) {
                                    Image(systemName: aime ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    Text("2,4 k")
                                }
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .contentShape(Rectangle())
                                .onTapGesture { Haptique.leger(); aime.toggle() }
                                Rectangle().fill(Color(hex: 0x3F3F3F)).frame(width: 1, height: 18)
                                Image(systemName: "hand.thumbsdown").padding(.horizontal, 12)
                            }
                            .background(Color(hex: 0x272727), in: Capsule())
                            ForEach(Array([("arrowshape.turn.up.right", "Partager"), ("arrow.down.to.line", "Télécharger"), ("bookmark", "Enregistrer")].enumerated()), id: \.offset) { _, b in
                                HStack(spacing: 5) { Image(systemName: b.0); Text(b.1) }
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .background(Color(hex: 0x272727), in: Capsule())
                            }
                        }
                    }
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)

                    // Commentaires
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Text("Commentaires").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                            Text("68").font(.system(size: 12.5)).foregroundStyle(.gray)
                        }
                        ForEach(Array(DonneesYt.commentaires.enumerated()), id: \.offset) { _, c in
                            HStack(alignment: .top, spacing: 9) {
                                Circle().fill(Color(hex: 0x3F3F3F)).frame(width: 26, height: 26)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(c.0).font(.system(size: 11.5)).foregroundStyle(.gray)
                                    Text(c.1).font(.system(size: 13)).foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(hex: 0x272727), in: RoundedRectangle(cornerRadius: 12))

                    Text("À suivre").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                    ForEach(DonneesYt.videos.filter { $0.id != video.id }) { v in
                        YtCarteVideo(video: v) {}
                    }
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 14).padding(.top, 10)
            }
            BarreHome { dismiss() }
        }
        .background(Color(hex: ytFond))
        .preferredColorScheme(.dark)
    }
}

// ============================================================ SHORTS
struct YtShortsVue: View {
    @State private var aime = false
    var body: some View {
        ZStack {
            Group {
                if let img = ChargeurPhoto.image("p36") {
                    Image(uiImage: img).resizable().scaledToFill()
                } else { Color.black }
            }
            .ignoresSafeArea()
            Color.black.opacity(0.15).ignoresSafeArea()
            VStack {
                HStack {
                    Text("Shorts").font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "camera").font(.system(size: 20)).foregroundStyle(.white)
                    Image(systemName: "magnifyingglass").font(.system(size: 20)).foregroundStyle(.white).padding(.leading, 14)
                }
                .padding(.horizontal, 14).padding(.top, 4)
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Circle().fill(Color(hex: 0x2A9D8F)).frame(width: 32, height: 32)
                                .overlay(Text("L").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white))
                            Text("@lyonaventures").font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                            Text("S'abonner").font(.system(size: 12.5, weight: .bold)).foregroundStyle(.black)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.white, in: Capsule())
                        }
                        Text("Le lever de soleil de ce matin sur le parc 😍 #lyon").font(.system(size: 13)).foregroundStyle(.white)
                        HStack(spacing: 5) {
                            Image(systemName: "music.note").font(.system(size: 11))
                            Text("Son original · lyonaventures").font(.system(size: 12))
                        }
                        .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(spacing: 17) {
                        VStack(spacing: 2) {
                            Image(systemName: aime ? "hand.thumbsup.fill" : "hand.thumbsup").font(.system(size: 25))
                                .foregroundStyle(.white)
                                .contentShape(Rectangle())
                                .onTapGesture { Haptique.leger(); aime.toggle() }
                            Text("412 k").font(.system(size: 11.5)).foregroundStyle(.white)
                        }
                        VStack(spacing: 2) {
                            Image(systemName: "hand.thumbsdown").font(.system(size: 24)).foregroundStyle(.white)
                            Text("Je n'aime pas").font(.system(size: 10)).foregroundStyle(.white)
                        }
                        VStack(spacing: 2) {
                            Image(systemName: "bubble.right").font(.system(size: 23)).foregroundStyle(.white)
                            Text("1,1 k").font(.system(size: 11.5)).foregroundStyle(.white)
                        }
                        VStack(spacing: 2) {
                            Image(systemName: "arrowshape.turn.up.right").font(.system(size: 23)).foregroundStyle(.white)
                            Text("Partager").font(.system(size: 10)).foregroundStyle(.white)
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.bottom, 96)
            }
        }
    }
}

// ============================================================ ABONNEMENTS + VOUS + NOTIFICATIONS
struct YtAbonnementsVue: View {
    @State private var videoOuverte: YtVideo? = nil
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Abonnements").font(.system(size: 22, weight: .bold)).foregroundStyle(.white).padding(.horizontal, 14)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(DonneesYt.abonnements.enumerated()), id: \.offset) { _, a in
                            VStack(spacing: 5) {
                                Circle().fill(Color(hex: a.2)).frame(width: 56, height: 56)
                                    .overlay(Text(String(a.0.prefix(1))).font(.system(size: 21, weight: .semibold)).foregroundStyle(.white))
                                Text(a.0.components(separatedBy: " ").first ?? a.0).font(.system(size: 11)).foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }
                ForEach(DonneesYt.videos) { v in
                    YtCarteVideo(video: v) { videoOuverte = v }
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 8)
        }
        .fullScreenCover(isPresented: Binding(get: { videoOuverte != nil }, set: { if !$0 { videoOuverte = nil } })) {
            YtLecteurVue(video: videoOuverte ?? DonneesYt.videos[0])
        }
    }
}

struct YtVousVue: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Group {
                        if let img = ChargeurPhoto.image("p04") {
                            Image(uiImage: img).resizable().scaledToFill().frame(width: 62, height: 62).clipShape(Circle())
                        } else { Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 62, height: 62) }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sarah Levasseur").font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
                        Text("@sarah_lvsr · Gérer votre compte Google").font(.system(size: 12.5)).foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)

                HStack {
                    Text("Historique").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Text("Tout afficher").font(.system(size: 13)).foregroundStyle(.gray)
                }
                .padding(.horizontal, 14)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(DonneesYt.videos) { v in
                            VStack(alignment: .leading, spacing: 5) {
                                YtMiniature(video: v, hauteur: 90)
                                    .frame(width: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 9))
                                Text(v.titre).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                                    .lineLimit(2).frame(width: 160, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }

                VStack(spacing: 0) {
                    ForEach(Array([("clock.arrow.circlepath", "Historique"), ("play.square.stack", "Playlists"), ("arrow.down.to.line.circle", "Vidéos téléchargées"), ("hand.thumbsup", "Vidéos likées")].enumerated()), id: \.offset) { i, r in
                        HStack(spacing: 12) {
                            Image(systemName: r.0).font(.system(size: 17)).foregroundStyle(.white).frame(width: 26)
                            Text(r.1).font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        if i < 3 { Divider().overlay(Color(hex: 0x272727)).padding(.leading, 50) }
                    }
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 8)
        }
    }
}

struct YtNotificationsVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array([
                        ("Lyon Aventures", "Mise en ligne : On a testé les meilleures randos autour de Lyon", "il y a 3 j", 0x2A9D8F, "p30"),
                        ("Terre & Tour", "Mise en ligne : Céramique : 10 erreurs de débutant à éviter", "il y a 1 sem.", 0xFF9F0A, "p33"),
                        ("Camille Voyage", "Vlog : une semaine à Annecy 🌊", "il y a 2 sem.", 0xE84D8A, "p31"),
                    ].enumerated()), id: \.offset) { _, n in
                        HStack(alignment: .top, spacing: 11) {
                            Circle().fill(Color(hex: UInt(n.3))).frame(width: 40, height: 40)
                                .overlay(Text(String(n.0.prefix(1))).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white))
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(n.0) · \(n.1)").font(.system(size: 13.5)).foregroundStyle(.white).lineLimit(2)
                                Text(n.2).font(.system(size: 12)).foregroundStyle(.gray)
                            }
                            Spacer()
                            Group {
                                if let img = ChargeurPhoto.image(n.4) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else { Rectangle().fill(Color(hex: 0x272727)) }
                            }
                            .frame(width: 80, height: 46).clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                    }
                }
                .padding(.top, 8)
            }
            .background(Color(hex: ytFond))
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
