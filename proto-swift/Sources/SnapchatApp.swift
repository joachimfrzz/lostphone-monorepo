// Snapchat — construit contre les références vidéo de Joachim du 26/08 (D67, 114 écrans mesurés).
// v1 : Chat (chips, statuts Reçu/Remis/Appuyer pour Chatter), conversation (noms colorés + barre),
// Carte (MapKit + avatars + pilule explorée + rangée amis), Caméra (viseur diégétique + capture),
// Stories (Amis-es + Découvrir), Spotlight (plein écran + rail d'actions). Thème CLAIR comme la vraie app.
// Données Sarah = jeu plausible remplaçable (D59). Avatars Bitmoji -> émojis (D55, maison).
import SwiftUI
import MapKit

// ============================================================ DONNÉES
struct SnapAmi: Identifiable {
    let id: String
    var nom: String
    var emoji: String
    var teinte: UInt
    var statut: String       // "Reçu · 2sem", "Remis · 21sem", "Appuyer pour Chatter"
    var typeStatut: Int      // 0 reçu (carré bleu), 1 remis (flèche), 2 neutre
}

enum DonneesSnap {
    static let amis: [SnapAmi] = [
        SnapAmi(id: "chloe", nom: "Chloé 💛", emoji: "👩🏻‍🦰", teinte: 0xFFE9EC, statut: "À proximité · maintenant", typeStatut: 2),
        SnapAmi(id: "ines", nom: "Inès", emoji: "👩🏽", teinte: 0xEDE7FF, statut: "Reçu · 2sem", typeStatut: 0),
        SnapAmi(id: "team", nom: "Team Snapchat", emoji: "👻", teinte: 0xFFFC00, statut: "Appuyez 2x pour répondre", typeStatut: 2),
        SnapAmi(id: "camille", nom: "Camille", emoji: "👱🏻‍♀️", teinte: 0xE2F4E8, statut: "Remis · 5sem", typeStatut: 1),
        SnapAmi(id: "soiree", nom: "Soirée 30 juin", emoji: "🥂", teinte: 0xFFF3D6, statut: "Inès a réagi à un Chat. · 8sem", typeStatut: 2),
        SnapAmi(id: "thomas", nom: "Thomas", emoji: "👨🏻", teinte: 0xE3EEFF, statut: "Appuyer pour Chatter", typeStatut: 2),
        SnapAmi(id: "lea", nom: "Léa 🌻", emoji: "👩🏼", teinte: 0xFDEBDD, statut: "Remis · 12sem", typeStatut: 1),
    ]
    static let decouvrir: [(String, String, UInt)] = [
        ("Ça commence aujourd'hui", "p24", 0xE84D8A),
        ("Recettes en 1 min", "p33", 0xFF9F0A),
        ("Lyon Secret", "p36", 0x0A84FF),
        ("Astro du jour", "p39", 0x8B5CF6),
    ]
}

let snapJaune: UInt = 0xFFFC00
let snapBleu: UInt = 0x0EADFF

struct SnapAvatar: View {
    let ami: SnapAmi
    var taille: CGFloat = 50
    var body: some View {
        Circle().fill(Color(hex: ami.teinte)).frame(width: taille, height: taille)
            .overlay(Text(ami.emoji).font(.system(size: taille * 0.52)))
    }
}

// ============================================================ APP (5 onglets)
struct SnapchatVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 1

    var body: some View {
        ZStack(alignment: .bottom) {
            (onglet == 0 || onglet == 1 || onglet == 3 ? Color.white : Color.black).ignoresSafeArea()
            Group {
                switch onglet {
                case 0: SnapCarteVue()
                case 2: SnapCameraVue()
                case 3: SnapStoriesVue()
                case 4: SnapSpotlightVue()
                default: SnapChatListeVue()
                }
            }

            // Barre 5 onglets (fond suit le thème de l'écran)
            HStack {
                ForEach(Array([
                    ("location.fill", 0), ("bubble.left.fill", 1), ("camera.fill", 2),
                    ("person.2.fill", 3), ("play.rectangle.fill", 4),
                ].enumerated()), id: \.offset) { _, o in
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: o.0).font(.system(size: 22))
                            .foregroundStyle(onglet == o.1
                                             ? (onglet == 0 || onglet == 1 || onglet == 3 ? Color.black : Color.white)
                                             : Color.gray.opacity(0.75))
                        if o.1 == 4 {
                            Text("3").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                                .padding(.horizontal, 4).padding(.vertical, 1)
                                .background(Color(hex: 0xFF3B30), in: Capsule())
                                .offset(x: 9, y: -6)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { onglet = o.1 }
                }
            }
            .padding(.top, 10).padding(.bottom, 26)
            .background((onglet == 0 || onglet == 1 || onglet == 3 ? Color.white : Color.black).opacity(0.98))

            BarreHome(action: { dismiss() }, sombre: onglet == 0 || onglet == 1 || onglet == 3)
        }
        .preferredColorScheme(onglet == 0 || onglet == 1 || onglet == 3 ? .light : .dark)
    }
}

// ============================================================ CHAT (liste, thème clair)
struct SnapChatListeVue: View {
    @State private var conv: SnapAmi? = nil
    @State private var filtre: String? = nil

    private var amisVisibles: [SnapAmi] {
        switch filtre {
        case "Groupes": return DonneesSnap.amis.filter { $0.id == "soiree" }
        case "Près de moi": return DonneesSnap.amis.filter { $0.id == "chloe" }
        case "Meilleurs·es amis·es": return DonneesSnap.amis.filter { ["chloe", "ines", "camille"].contains($0.id) }
        case "🤖 My AI": return DonneesSnap.amis.filter { $0.id == "team" }
        default: return DonneesSnap.amis
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Circle().fill(Color(hex: 0xFFE9EC)).frame(width: 34, height: 34)
                        .overlay(Text("👩🏻").font(.system(size: 18)))
                    Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .semibold)).foregroundStyle(.black))
                    Spacer()
                    Text("Chat").font(.system(size: 19, weight: .bold)).foregroundStyle(.black)
                    Spacer()
                    Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "bell").font(.system(size: 15, weight: .semibold)).foregroundStyle(.black))
                    ZStack(alignment: .topTrailing) {
                        Circle().fill(Color(hex: snapJaune)).frame(width: 34, height: 34)
                            .overlay(Text("C+").font(.system(size: 13, weight: .bold)).foregroundStyle(.black))
                        Text("47").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 4).padding(.vertical, 1)
                            .background(Color(hex: 0xFF3B30), in: Capsule())
                            .offset(x: 6, y: -5)
                    }
                    Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "ellipsis").font(.system(size: 15, weight: .semibold)).foregroundStyle(.black))
                }
                .padding(.horizontal, 14)

                // Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["🤖 My AI", "Groupes", "Près de moi", "Meilleurs·es amis·es"], id: \.self) { c in
                            Text(c).font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(filtre == c ? Color.white : Color.black)
                                .padding(.horizontal, 13).padding(.vertical, 7)
                                .background(filtre == c ? Color.black : Color(hex: 0xF0F0F0), in: Capsule())
                                .contentShape(Capsule())
                                .onTapGesture { Haptique.leger(); filtre = (filtre == c ? nil : c) }
                        }
                    }
                    .padding(.horizontal, 14)
                }

                VStack(spacing: 0) {
                    ForEach(amisVisibles) { a in
                        HStack(spacing: 11) {
                            SnapAvatar(ami: a)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(a.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.black)
                                HStack(spacing: 5) {
                                    if a.typeStatut == 0 {
                                        Image(systemName: "square.fill").font(.system(size: 10)).foregroundStyle(Color(hex: snapBleu))
                                    } else if a.typeStatut == 1 {
                                        Image(systemName: "paperplane.fill").font(.system(size: 10)).foregroundStyle(Color(hex: 0xB84DFF))
                                    } else if a.id == "chloe" {
                                        Image(systemName: "location.fill").font(.system(size: 10)).foregroundStyle(Color(hex: 0x30D158))
                                    }
                                    Text(a.statut).font(.system(size: 12.5)).foregroundStyle(.gray)
                                }
                            }
                            Spacer()
                            Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 34, height: 34)
                                .overlay(Image(systemName: "camera").font(.system(size: 14, weight: .semibold)).foregroundStyle(.gray))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .contentShape(Rectangle())
                        .onTapGesture { conv = a }
                    }
                }
                Spacer(minLength: 100)
            }
            .padding(.top, 6)
        }
        .fullScreenCover(isPresented: Binding(get: { conv != nil }, set: { if !$0 { conv = nil } })) {
            SnapConversationVue(ami: conv ?? DonneesSnap.amis[0])
        }
    }
}

// ============================================================ CONVERSATION (nom coloré + barre latérale)
struct SnapConversationVue: View {
    @Environment(\.dismiss) private var dismiss
    let ami: SnapAmi
    @State private var saisie = ""
    @State private var envoyes: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "chevron.left").font(.system(size: 19, weight: .semibold)).foregroundStyle(.gray)
                    .contentShape(Rectangle())
                    .onTapGesture { dismiss() }
                SnapAvatar(ami: ami, taille: 36)
                Text(ami.nom).font(.system(size: 16, weight: .bold)).foregroundStyle(.black)
                Spacer()
                Image(systemName: "phone.fill").font(.system(size: 17)).foregroundStyle(.gray)
                Image(systemName: "video.fill").font(.system(size: 17)).foregroundStyle(.gray)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color.white)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("7 AOÛT").font(.system(size: 11, weight: .semibold)).foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                    SnapBloc(nom: "MOI", teinte: 0xFF3B30, lignes: ["Coucou !! Vous avez des lunettes éclipse au magasin ?"])
                    SnapBloc(nom: ami.nom.uppercased(), teinte: 0x0EADFF, lignes: ["Coucou !! Non on en a plus 😔", "D'accord merci !"])
                    Text("HIER").font(.system(size: 11, weight: .semibold)).foregroundStyle(.gray)
                        .frame(maxWidth: .infinity).padding(.top, 6)
                    SnapBloc(nom: ami.nom.uppercased(), teinte: 0x0EADFF, lignes: ["On se capte ce week-end ? 👀"])
                    if !envoyes.isEmpty {
                        SnapBloc(nom: "MOI", teinte: 0xFF3B30, lignes: envoyes)
                    }
                }
                .padding(14)
            }
            .background(Color.white)

            HStack(spacing: 10) {
                Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 36, height: 36)
                    .overlay(Image(systemName: "camera.fill").font(.system(size: 15)).foregroundStyle(.black))
                TextField("Envoyer un Chat", text: $saisie)
                    .font(.system(size: 14.5)).foregroundStyle(.black)
                    .padding(.horizontal, 13).padding(.vertical, 9)
                    .background(Color(hex: 0xF0F0F0), in: Capsule())
                    .onSubmit {
                        if !saisie.isEmpty { envoyes.append(saisie); saisie = "" }
                    }
                Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 36, height: 36)
                    .overlay(Image(systemName: "mic.fill").font(.system(size: 15)).foregroundStyle(.black))
                Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 36, height: 36)
                    .overlay(Text("🙂").font(.system(size: 17)))
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color.white)

            BarreHome(action: { dismiss() }, sombre: true)
                .background(Color.white)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}

// Bloc de messages Snapchat (nom coloré + barre verticale)
struct SnapBloc: View {
    let nom: String
    let teinte: UInt
    let lignes: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(nom).font(.system(size: 11, weight: .bold)).foregroundStyle(Color(hex: teinte))
            HStack(spacing: 0) {
                Rectangle().fill(Color(hex: teinte)).frame(width: 2.5)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(lignes, id: \.self) { l in
                        Text(l).font(.system(size: 15)).foregroundStyle(.black)
                    }
                }
                .padding(.leading, 9)
            }
        }
    }
}

// ============================================================ CARTE (Snap Map)
struct SnapCarteVue: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.7640, longitude: 4.8357),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var rechercheVisible = false
    @State private var filtreCarteActif: String? = nil

    private struct Epingle: Identifiable {
        let id = UUID()
        let lat: Double, lon: Double
        let emoji: String
        let nom: String
    }
    private let epingles: [Epingle] = [
        Epingle(lat: 45.7640, lon: 4.8357, emoji: "👩🏻", nom: "Moi"),
        Epingle(lat: 45.7700, lon: 4.8280, emoji: "👩🏻‍🦰", nom: "Chloé · 12min"),
        Epingle(lat: 45.7540, lon: 4.8450, emoji: "👩🏽", nom: "Inès · 3h"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: epingles) { e in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: e.lat, longitude: e.lon)) {
                    VStack(spacing: 1) {
                        ZStack {
                            Circle().fill(.white).frame(width: 42, height: 42).shadow(radius: 2)
                            Text(e.emoji).font(.system(size: 24))
                        }
                        if e.nom != "Moi" {
                            Text(e.nom).font(.system(size: 9, weight: .semibold)).foregroundStyle(.black)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(Color.white.opacity(0.92), in: Capsule())
                        }
                    }
                }
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Circle().fill(Color(hex: 0xFFE9EC)).frame(width: 34, height: 34)
                        .overlay(Text("👩🏻").font(.system(size: 18)))
                    Spacer()
                    Text("Lyon").font(.system(size: 17, weight: .bold)).foregroundStyle(.black)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(Color.white.opacity(0.92), in: Capsule())
                        .contentShape(Capsule())
                        .onTapGesture { rechercheVisible = true }
                    Spacer()
                    Circle().fill(Color.white.opacity(0.92)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "gearshape.fill").font(.system(size: 15)).foregroundStyle(.black))
                }
                .padding(.horizontal, 14).padding(.top, 6)
                HStack(spacing: 8) {
                    ForEach(["Souvenirs", "Tendance", "Footsteps", "Visité"], id: \.self) { c in
                        Text(c).font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(filtreCarteActif == c ? Color.white : Color.black)
                            .padding(.horizontal, 11).padding(.vertical, 6)
                            .background(filtreCarteActif == c ? Color.black : Color.white.opacity(0.92), in: Capsule())
                            .contentShape(Capsule())
                            .onTapGesture { Haptique.leger(); filtreCarteActif = (filtreCarteActif == c ? nil : c) }
                    }
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: "map.fill").font(.system(size: 11))
                    Text("2,4 % exploré(s)").font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 11).padding(.vertical, 6)
                .background(Color(hex: 0xB84DFF), in: Capsule())

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(DonneesSnap.amis) { a in
                            SnapAvatar(ami: a, taille: 44)
                                .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }
            .padding(.bottom, 108)
            .padding(.leading, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .sheet(isPresented: $rechercheVisible) { SnapRechercheCarteVue() }
    }
}

struct SnapRechercheCarteVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recherche = ""
    private let lieux = ["Lyon 1er", "Lyon 2e", "Lyon 3e", "Lyon 6e", "Villeurbanne", "Caluire-et-Cuire"]
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundStyle(.secondary)
                    TextField("Rechercher un lieu", text: $recherche).font(.system(size: 15))
                }
                .padding(.horizontal, 12).frame(height: 38)
                .background(Color(hex: 0xF0F0F0), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 14).padding(.vertical, 10)
                List(lieux.filter { recherche.isEmpty || $0.localizedCaseInsensitiveContains(recherche) }, id: \.self) { lieu in
                    Button(action: { Haptique.leger(); dismiss() }) {
                        Label(lieu, systemImage: "location.fill")
                            .foregroundStyle(.black)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Carte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}

// ============================================================ CAMÉRA (viseur diégétique)
struct SnapCameraVue: View {
    @State private var flashActif = false
    @State private var envoiVisible = false
    var body: some View {
        ZStack {
            // Viseur : pas d'accès caméra dans la fiction -> scène sombre plausible (D56 : même type que l'action)
            LinearGradient(colors: [Color(hex: 0x101418), Color(hex: 0x05060A)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            if flashActif {
                Color.white.ignoresSafeArea().transition(.opacity).zIndex(10)
            }
            VStack {
                HStack {
                    Circle().fill(Color(hex: 0xFFE9EC)).frame(width: 34, height: 34)
                        .overlay(Text("👩🏻").font(.system(size: 18)))
                    Circle().fill(Color.black.opacity(0.35)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(.white))
                    Spacer()
                    VStack(spacing: 14) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                        Image(systemName: "bolt.slash.fill")
                        Image(systemName: "moon.fill")
                        Image(systemName: "music.note")
                    }
                    .font(.system(size: 17)).foregroundStyle(.white)
                    .padding(.vertical, 12).padding(.horizontal, 8)
                    .background(Color.black.opacity(0.35), in: Capsule())
                }
                .padding(.horizontal, 14).padding(.top, 6)
                Spacer()
                HStack(spacing: 26) {
                    Circle().fill(Color.black.opacity(0.4)).frame(width: 44, height: 44)
                        .overlay(Image(systemName: "photo.on.rectangle").font(.system(size: 17)).foregroundStyle(.white))
                    Circle().strokeBorder(Color.white, lineWidth: 5).frame(width: 78, height: 78)
                        .contentShape(Circle())
                        .onTapGesture {
                            Haptique.leger()
                            withAnimation(.easeOut(duration: 0.1)) { flashActif = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                withAnimation { flashActif = false }
                                envoiVisible = true
                            }
                        }
                    Circle().fill(Color.black.opacity(0.4)).frame(width: 44, height: 44)
                        .overlay(Image(systemName: "face.smiling").font(.system(size: 17)).foregroundStyle(.white))
                }
                .padding(.bottom, 116)
            }
        }
        .sheet(isPresented: $envoiVisible) { SnapEnvoiSnapVue() }
    }
}

struct SnapEnvoiSnapVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Group {
                    if let img = ChargeurPhoto.image("p04") {
                        Image(uiImage: img).resizable().scaledToFill()
                    } else {
                        Rectangle().fill(Color(hex: 0x1C1C1E))
                    }
                }
                .frame(maxWidth: .infinity).frame(height: 260).clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16).padding(.top, 10)
                Text("Envoyer à…").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                VStack(spacing: 0) {
                    ForEach(DonneesSnap.amis.prefix(4)) { a in
                        HStack(spacing: 12) {
                            SnapAvatar(ami: a, taille: 40)
                            Text(a.nom).font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "circle").font(.system(size: 20)).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); dismiss() }
                    }
                }
                Spacer()
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }.foregroundStyle(Color(hex: snapBleu))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ STORIES (Amis-es + Découvrir)
struct SnapStoriesVue: View {
    @State private var storyAmi: SnapAmi? = nil
    @State private var carteDecouvrir: Int? = nil
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle().fill(Color(hex: 0xFFE9EC)).frame(width: 34, height: 34)
                        .overlay(Text("👩🏻").font(.system(size: 18)))
                    Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .semibold)).foregroundStyle(.black))
                    Spacer()
                    Text("Stories").font(.system(size: 19, weight: .bold)).foregroundStyle(.black)
                    Spacer()
                    Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "bell").font(.system(size: 15, weight: .semibold)).foregroundStyle(.black))
                    Circle().fill(Color(hex: 0xF0F0F0)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "ellipsis").font(.system(size: 15, weight: .semibold)).foregroundStyle(.black))
                }
                .padding(.horizontal, 14)

                Text("Amis·es").font(.system(size: 16, weight: .bold)).foregroundStyle(.black).padding(.horizontal, 14)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(DonneesSnap.amis.prefix(5)) { a in
                            VStack(spacing: 4) {
                                SnapAvatar(ami: a, taille: 62)
                                    .overlay(Circle().strokeBorder(Color(hex: 0xB84DFF), lineWidth: 2.5).frame(width: 68, height: 68))
                                Text(a.nom.components(separatedBy: " ").first ?? a.nom)
                                    .font(.system(size: 11)).foregroundStyle(.black).lineLimit(1)
                            }
                            .frame(width: 74)
                            .contentShape(Rectangle())
                            .onTapGesture { storyAmi = a }
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 4)
                }

                Text("Découvrir").font(.system(size: 16, weight: .bold)).foregroundStyle(.black).padding(.horizontal, 14)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(Array(DonneesSnap.decouvrir.enumerated()), id: \.offset) { i, d in
                        ZStack(alignment: .bottomLeading) {
                            Group {
                                if let img = ChargeurPhoto.image(d.1) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else {
                                    Rectangle().fill(Color(hex: d.2))
                                }
                            }
                            .frame(height: 230).clipped()
                            LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .center, endPoint: .bottom)
                            Text(d.0).font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                                .padding(10)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                        .onTapGesture { carteDecouvrir = i }
                    }
                }
                .padding(.horizontal, 14)
                Spacer(minLength: 100)
            }
            .padding(.top, 6)
        }
        .fullScreenCover(isPresented: Binding(get: { storyAmi != nil }, set: { if !$0 { storyAmi = nil } })) {
            VisualiseurContenuVue(titre: (storyAmi ?? DonneesSnap.amis[0]).nom,
                                  sousTitre: "Story · il y a 3 h",
                                  emoji: (storyAmi ?? DonneesSnap.amis[0]).emoji,
                                  teinte: 0xB84DFF)
        }
        .fullScreenCover(isPresented: Binding(get: { carteDecouvrir != nil }, set: { if !$0 { carteDecouvrir = nil } })) {
            VisualiseurContenuVue(titre: DonneesSnap.decouvrir[carteDecouvrir ?? 0].0,
                                  sousTitre: "Découvrir",
                                  imageCle: DonneesSnap.decouvrir[carteDecouvrir ?? 0].1,
                                  teinte: DonneesSnap.decouvrir[carteDecouvrir ?? 0].2,
                                  avecMessage: false)
        }
    }
}

// ============================================================ SPOTLIGHT
struct SnapSpotlightVue: View {
    @State private var aime = false
    var body: some View {
        ZStack {
            Group {
                if let img = ChargeurPhoto.image("p28") {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    LinearGradient(colors: [Color(hex: 0x1B2735), Color(hex: 0x090A0F)], startPoint: .top, endPoint: .bottom)
                }
            }
            .ignoresSafeArea()
            Color.black.opacity(0.15).ignoresSafeArea()

            VStack {
                HStack {
                    Circle().fill(Color(hex: 0xFFE9EC)).frame(width: 34, height: 34)
                        .overlay(Text("👩🏻").font(.system(size: 18)))
                    Circle().fill(Color.black.opacity(0.35)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(.white))
                    Spacer()
                    Text("Spotlight").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Circle().fill(Color.black.opacity(0.35)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "person.badge.plus").font(.system(size: 15)).foregroundStyle(.white))
                    Circle().fill(Color.black.opacity(0.35)).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "square.and.arrow.up").font(.system(size: 15)).foregroundStyle(.white))
                }
                .padding(.horizontal, 14).padding(.top, 6)
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("lyonnaise.dycoeur").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                        HStack(spacing: 5) {
                            Image(systemName: "music.note").font(.system(size: 11))
                            Text("Son original · lyonnaise.dycoeur").font(.system(size: 12))
                        }
                        .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Image(systemName: aime ? "heart.fill" : "heart").font(.system(size: 26))
                                .foregroundStyle(aime ? Color(hex: 0xFF3B30) : .white)
                                .contentShape(Rectangle())
                                .onTapGesture { Haptique.leger(); aime.toggle() }
                            Text("741").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                        }
                        VStack(spacing: 2) {
                            Image(systemName: "bubble.left").font(.system(size: 24)).foregroundStyle(.white)
                            Text("108").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                        }
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.2.squarepath").font(.system(size: 24)).foregroundStyle(.white)
                            Text("49").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                        }
                        VStack(spacing: 2) {
                            Image(systemName: "arrowshape.turn.up.right.fill").font(.system(size: 24)).foregroundStyle(.white)
                            Text("143").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.bottom, 100)
            }
        }
    }
}
