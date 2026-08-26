// Facebook — construit contre les références vidéo de Joachim du 26/08 (D67, 159 écrans mesurés).
// v1 : fil (composer, stories, posts complets avec commentaires), commentaires, Reels, Ami(e)s
// (Confirmer/Supprimer réels), Groupes (Découvrir + Rejoindre), Notifications, Menu (raccourcis).
// Thème CLAIR comme la référence. Données Sarah = jeu plausible remplaçable (D59).
import SwiftUI

// ============================================================ DONNÉES
struct FbPost: Identifiable {
    let id = UUID()
    var auteur: String
    var teinte: UInt
    var meta: String          // "3 j · 🌐"
    var texte: String
    var image: String?
    var reactions: String     // "👍❤️ 118"
    var commentaires: String
    var partages: String
}

enum DonneesFb {
    static let posts: [FbPost] = [
        FbPost(auteur: "Lyon Ma Ville", teinte: 0x0866FF, meta: "5 h · Suivre",
               texte: "L'été indien s'installe sur les quais du Rhône 🌇 Profitez-en ce week-end !",
               image: "p36", reactions: "👍❤️ 597", commentaires: "36 commentaires", partages: "12 partages"),
        FbPost(auteur: "Atelier Poterie Lyon 3", teinte: 0xFF9F0A, meta: "1 j · Suivre",
               texte: "Les inscriptions de septembre sont ouvertes ! Cours du mardi et jeudi soir, tous niveaux 🏺",
               image: "p33", reactions: "👍 118", commentaires: "23 commentaires", partages: "4 partages"),
        FbPost(auteur: "Chloé Berthier", teinte: 0xE64980, meta: "9 j · 👥",
               texte: "Week-end parfait au bord du lac avec la meilleure 💙",
               image: "p30", reactions: "❤️👍 87", commentaires: "14 commentaires", partages: "1 partage"),
    ]
    static let commentaires: [(String, String, String)] = [
        ("Gaëlle Capitaine", "Magnifique ! Profitez bien les filles 😍", "5 j"),
        ("Aurore Dauriac", "Il faut qu'on y aille aussi !!", "6 j"),
        ("Francis Baron", "Superbes photos 👏", "8 j"),
    ]
    static let demandes: [(String, String)] = [
        ("Marie-Pierre Fourez", "4 amis en commun"), ("Dorian Delzers", "Suivi(e) par 191 personnes"),
        ("Seb Cbien", "2 amis en commun"), ("Evelyne Guitonneau", "42 min"),
    ]
    static let groupes: [(String, String, String)] = [
        ("Lyon 3e — Entre voisins", "Groupe (Privé) · 8,9 K membres", "p36"),
        ("Céramique & Poterie France", "Groupe (Public) · 24 K membres", "p33"),
        ("Randos autour de Lyon", "Groupe (Public) · 11 K membres", "p31"),
        ("Vide-dressing Lyon", "Groupe (Privé) · 3,4 K membres", "p24"),
    ]
}

let fbBleu: UInt = 0x0866FF

// ============================================================ APP (6 onglets)
struct FacebookVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()
            Group {
                switch onglet {
                case 1: FbReelsVue()
                case 2: FbAmisVue()
                case 3: FbGroupesVue()
                case 4: FbNotificationsVue()
                case 5: FbMenuVue()
                default: FbFilVue()
                }
            }

            HStack {
                ForEach(Array([
                    ("house.fill", "Accueil", 0), ("play.rectangle.on.rectangle", "Reels", 1),
                    ("person.2", "Ami(e)s", 2), ("person.3", "Groupes", 3),
                    ("bell", "Notifications", 4), ("line.3.horizontal", "Menu", 5),
                ].enumerated()), id: \.offset) { _, o in
                    VStack(spacing: 2) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: o.2 == onglet && o.2 == 0 ? "house.fill" : o.0).font(.system(size: 20))
                            if o.2 == 4 {
                                Text("3").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                                    .padding(.horizontal, 4).padding(.vertical, 1)
                                    .background(Color(hex: 0xFF3B30), in: Capsule())
                                    .offset(x: 8, y: -5)
                            }
                        }
                        Text(o.1).font(.system(size: 9))
                    }
                    .foregroundStyle(onglet == o.2 ? Color(hex: fbBleu) : Color.gray)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { onglet = o.2 }
                }
            }
            .padding(.top, 8).padding(.bottom, 26)
            .background(Color.white.opacity(0.98))
            .overlay(Rectangle().fill(Color(hex: 0xE4E6EB)).frame(height: 0.5), alignment: .top)

            BarreHome(action: { dismiss() }, sombre: true)
        }
        .preferredColorScheme(.light)
    }
}

// ============================================================ FIL
struct FbFilVue: View {
    @State private var commentairesVisibles = false
    @State private var storyOuverte: Int? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("facebook").font(.system(size: 26, weight: .heavy)).foregroundStyle(Color(hex: fbBleu))
                    Spacer()
                    ForEach(["plus.circle.fill", "magnifyingglass.circle.fill"], id: \.self) { s in
                        Image(systemName: s).font(.system(size: 26)).foregroundStyle(.black)
                    }
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "message.circle.fill").font(.system(size: 26)).foregroundStyle(.black)
                        Text("8").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 4).padding(.vertical, 1)
                            .background(Color(hex: 0xFF3B30), in: Capsule())
                            .offset(x: 4, y: -3)
                    }
                }
                .padding(.horizontal, 14)

                HStack(spacing: 10) {
                    Group {
                        if let img = ChargeurPhoto.image("p04") {
                            Image(uiImage: img).resizable().scaledToFill().frame(width: 36, height: 36).clipShape(Circle())
                        } else {
                            Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 36, height: 36)
                        }
                    }
                    Text("Quoi de neuf ?").font(.system(size: 15)).foregroundStyle(.gray)
                    Spacer()
                    Image(systemName: "photo.on.rectangle").font(.system(size: 19)).foregroundStyle(Color(hex: 0x45BD62))
                }
                .padding(.horizontal, 14).padding(.vertical, 6)

                // Stories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ZStack(alignment: .bottom) {
                            Group {
                                if let img = ChargeurPhoto.image("p04") {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else { Rectangle().fill(Color(hex: 0xE4E6EB)) }
                            }
                            .frame(width: 104, height: 170).clipped()
                            VStack(spacing: 4) {
                                Circle().fill(Color(hex: fbBleu)).frame(width: 30, height: 30)
                                    .overlay(Image(systemName: "plus").font(.system(size: 15, weight: .bold)).foregroundStyle(.white))
                                    .overlay(Circle().strokeBorder(Color.white, lineWidth: 3))
                                Text("Créer une story").font(.system(size: 11, weight: .semibold)).foregroundStyle(.black)
                            }
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .frame(height: 62, alignment: .bottom)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        ForEach(Array([("Chloé", "p12"), ("Inès", "p22"), ("Léa", "p18")].enumerated()), id: \.offset) { i, s in
                            ZStack(alignment: .bottomLeading) {
                                Group {
                                    if let img = ChargeurPhoto.image(s.1) {
                                        Image(uiImage: img).resizable().scaledToFill()
                                    } else { Rectangle().fill(Color(hex: 0xB0B3B8)) }
                                }
                                .frame(width: 104, height: 232).clipped()
                                LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)
                                Text(s.0).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white).padding(8)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(Rectangle())
                            .onTapGesture { storyOuverte = i }
                        }
                    }
                    .padding(.horizontal, 14)
                }

                // Posts
                ForEach(DonneesFb.posts) { p in
                    Rectangle().fill(Color(hex: 0xF0F2F5)).frame(height: 6)
                    FbPostVue(post: p) { commentairesVisibles = true }
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 6)
        }
        .sheet(isPresented: $commentairesVisibles) { FbCommentairesVue() }
        .fullScreenCover(isPresented: Binding(get: { storyOuverte != nil }, set: { if !$0 { storyOuverte = nil } })) {
            VisualiseurContenuVue(titre: [("Chloé Berthier", "p12"), ("Inès Djellal", "p22"), ("Léa Moreau", "p18")][storyOuverte ?? 0].0,
                                  sousTitre: "Story · il y a 5 h",
                                  imageCle: [("Chloé", "p12"), ("Inès", "p22"), ("Léa", "p18")][storyOuverte ?? 0].1)
        }
    }
}

struct FbPostVue: View {
    let post: FbPost
    var ouvrirCommentaires: () -> Void
    @State private var aime = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 9) {
                Circle().fill(Color(hex: post.teinte)).frame(width: 40, height: 40)
                    .overlay(Text(String(post.auteur.prefix(1))).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 1) {
                    Text(post.auteur).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(.black)
                    Text(post.meta).font(.system(size: 12)).foregroundStyle(.gray)
                }
                Spacer()
                Image(systemName: "ellipsis").foregroundStyle(.gray)
                Image(systemName: "xmark").foregroundStyle(.gray)
            }
            .padding(.horizontal, 14)
            Text(post.texte).font(.system(size: 14.5)).foregroundStyle(.black).padding(.horizontal, 14)
            if let cle = post.image {
                Group {
                    if let img = ChargeurPhoto.image(cle) {
                        Image(uiImage: img).resizable().scaledToFill()
                    } else { Rectangle().fill(Color(hex: 0xE4E6EB)) }
                }
                .frame(maxWidth: .infinity).frame(height: 300).clipped()
            }
            HStack {
                Text(post.reactions).font(.system(size: 13)).foregroundStyle(.gray)
                Spacer()
                Text("\(post.commentaires)  \(post.partages)").font(.system(size: 13)).foregroundStyle(.gray)
            }
            .padding(.horizontal, 14)
            Divider().padding(.horizontal, 14)
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: aime ? "hand.thumbsup.fill" : "hand.thumbsup")
                    Text("J'aime")
                }
                .foregroundStyle(aime ? Color(hex: fbBleu) : .gray)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); aime.toggle() }
                .frame(maxWidth: .infinity)
                HStack(spacing: 5) { Image(systemName: "bubble.left"); Text("Commenter") }
                    .foregroundStyle(.gray).frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: ouvrirCommentaires)
                HStack(spacing: 5) { Image(systemName: "arrowshape.turn.up.right"); Text("Partager") }
                    .foregroundStyle(.gray).frame(maxWidth: .infinity)
            }
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 8).padding(.bottom, 4)
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

// Commentaires
struct FbCommentairesVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var saisie = ""
    @State private var envoyes: [String] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(Array(DonneesFb.commentaires.enumerated()), id: \.offset) { _, c in
                            FbCommentaire(nom: c.0, texte: c.1, date: c.2)
                        }
                        ForEach(Array(envoyes.enumerated()), id: \.offset) { _, t in
                            FbCommentaire(nom: "Sarah Levasseur", texte: t, date: "À l'instant")
                        }
                    }
                    .padding(14)
                }
                Divider()
                HStack(spacing: 10) {
                    TextField("Commentez…", text: $saisie)
                        .font(.system(size: 14)).foregroundStyle(.black)
                        .padding(.horizontal, 13).padding(.vertical, 9)
                        .background(Color(hex: 0xF0F2F5), in: Capsule())
                        .onSubmit { if !saisie.isEmpty { envoyes.append(saisie); saisie = "" } }
                    Image(systemName: "paperplane.fill").foregroundStyle(Color(hex: fbBleu))
                        .contentShape(Rectangle())
                        .onTapGesture { if !saisie.isEmpty { envoyes.append(saisie); saisie = "" } }
                }
                .padding(12)
            }
            .background(Color.white)
            .navigationTitle("Commentaires")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: fbBleu))
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

struct FbCommentaire: View {
    let nom: String
    let texte: String
    let date: String
    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Circle().fill(Color(hex: 0xB0B3B8)).frame(width: 34, height: 34)
                .overlay(Text(String(nom.prefix(1))).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(nom).font(.system(size: 13, weight: .semibold)).foregroundStyle(.black)
                    Text(texte).font(.system(size: 14)).foregroundStyle(.black)
                }
                .padding(10)
                .background(Color(hex: 0xF0F2F5), in: RoundedRectangle(cornerRadius: 14))
                Text("\(date) · J'aime · Répondre").font(.system(size: 12)).foregroundStyle(.gray).padding(.leading, 6)
            }
            Spacer()
        }
    }
}

// ============================================================ REELS
struct FbReelsVue: View {
    @State private var aime = false
    var body: some View {
        ZStack {
            Group {
                if let img = ChargeurPhoto.image("p27") {
                    Image(uiImage: img).resizable().scaledToFill()
                } else { Color.black }
            }
            .ignoresSafeArea()
            Color.black.opacity(0.2).ignoresSafeArea()
            VStack {
                HStack {
                    Text("Reels").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "camera").font(.system(size: 21)).foregroundStyle(.white)
                }
                .padding(.horizontal, 14).padding(.top, 4)
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Circle().fill(Color(hex: 0x45BD62)).frame(width: 34, height: 34)
                                .overlay(Text("R").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white))
                            Text("Radio Cool Direct").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                            Text("· Suivre").font(.system(size: 14)).foregroundStyle(.white)
                        }
                        Text("Le meilleur moment du concert d'hier soir 🎶").font(.system(size: 13.5)).foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Image(systemName: aime ? "hand.thumbsup.fill" : "hand.thumbsup").font(.system(size: 25))
                                .foregroundStyle(aime ? Color(hex: fbBleu) : .white)
                                .contentShape(Rectangle())
                                .onTapGesture { Haptique.leger(); aime.toggle() }
                            Text("959").font(.system(size: 11.5)).foregroundStyle(.white)
                        }
                        VStack(spacing: 2) {
                            Image(systemName: "bubble.left").font(.system(size: 23)).foregroundStyle(.white)
                            Text("66").font(.system(size: 11.5)).foregroundStyle(.white)
                        }
                        Image(systemName: "arrowshape.turn.up.right").font(.system(size: 23)).foregroundStyle(.white)
                        Image(systemName: "ellipsis").font(.system(size: 19)).foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 14).padding(.bottom, 96)
            }
        }
    }
}

// ============================================================ AMI(E)S
struct FbAmisVue: View {
    @State private var traites: [String: String] = [:]   // nom -> "confirmé"/"supprimé"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Ami(e)s").font(.system(size: 24, weight: .bold)).foregroundStyle(.black)
                    Spacer()
                    Image(systemName: "magnifyingglass").font(.system(size: 19)).foregroundStyle(.black)
                }
                .padding(.horizontal, 14)
                HStack(spacing: 8) {
                    ForEach(["Suggestions", "Vos ami(e)s"], id: \.self) { c in
                        Text(c).font(.system(size: 13, weight: .semibold)).foregroundStyle(.black)
                            .padding(.horizontal, 13).padding(.vertical, 7)
                            .background(Color(hex: 0xE4E6EB), in: Capsule())
                    }
                }
                .padding(.horizontal, 14)
                Text("Demandes d'ami(e)s  ·  \(DonneesFb.demandes.count)")
                    .font(.system(size: 16, weight: .bold)).foregroundStyle(.black).padding(.horizontal, 14)

                ForEach(Array(DonneesFb.demandes.enumerated()), id: \.offset) { _, d in
                    HStack(alignment: .top, spacing: 11) {
                        Circle().fill(Color(hex: 0xB0B3B8)).frame(width: 76, height: 76)
                            .overlay(Text(String(d.0.prefix(1))).font(.system(size: 27, weight: .semibold)).foregroundStyle(.white))
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(d.0).font(.system(size: 15, weight: .semibold)).foregroundStyle(.black)
                                Spacer()
                                Text(d.1.contains("min") ? d.1 : "4 sem.").font(.system(size: 12)).foregroundStyle(.gray)
                            }
                            if let etat = traites[d.0] {
                                Text(etat == "confirmé" ? "Demande acceptée" : "Demande supprimée")
                                    .font(.system(size: 13.5)).foregroundStyle(.gray)
                            } else {
                                Text(d.1).font(.system(size: 12.5)).foregroundStyle(.gray)
                                HStack(spacing: 8) {
                                    Text("Confirmer").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                                        .background(Color(hex: fbBleu), in: RoundedRectangle(cornerRadius: 7))
                                        .contentShape(Rectangle())
                                        .onTapGesture { Haptique.leger(); traites[d.0] = "confirmé" }
                                    Text("Supprimer").font(.system(size: 14, weight: .semibold)).foregroundStyle(.black)
                                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                                        .background(Color(hex: 0xE4E6EB), in: RoundedRectangle(cornerRadius: 7))
                                        .contentShape(Rectangle())
                                        .onTapGesture { Haptique.leger(); traites[d.0] = "supprimé" }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 6)
        }
    }
}

// ============================================================ GROUPES
struct FbGroupesVue: View {
    @State private var rejoints: Set<String> = []
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Groupes").font(.system(size: 24, weight: .bold)).foregroundStyle(.black)
                    Spacer()
                    Image(systemName: "plus").font(.system(size: 19)).foregroundStyle(.black)
                    Image(systemName: "magnifyingglass").font(.system(size: 19)).foregroundStyle(.black).padding(.leading, 12)
                }
                .padding(.horizontal, 14)
                Text("Découvrir").font(.system(size: 16, weight: .bold)).foregroundStyle(.black).padding(.horizontal, 14)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(Array(DonneesFb.groupes.enumerated()), id: \.offset) { _, g in
                        VStack(alignment: .leading, spacing: 0) {
                            Group {
                                if let img = ChargeurPhoto.image(g.2) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else { Rectangle().fill(Color(hex: 0xE4E6EB)) }
                            }
                            .frame(height: 96).clipped()
                            VStack(alignment: .leading, spacing: 5) {
                                Text(g.0).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.black).lineLimit(2)
                                Text(g.1).font(.system(size: 11.5)).foregroundStyle(.gray).lineLimit(1)
                                Text(rejoints.contains(g.0) ? "Demande envoyée" : "Rejoindre")
                                    .font(.system(size: 13.5, weight: .semibold))
                                    .foregroundStyle(rejoints.contains(g.0) ? Color.gray : Color(hex: fbBleu))
                                    .frame(maxWidth: .infinity).padding(.vertical, 7)
                                    .background(Color(hex: 0xE7F0FF), in: RoundedRectangle(cornerRadius: 7))
                                    .contentShape(Rectangle())
                                    .onTapGesture { Haptique.leger(); rejoints.insert(g.0) }
                            }
                            .padding(9)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(hex: 0xE4E6EB), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 14)
                Spacer(minLength: 90)
            }
            .padding(.top, 6)
        }
        .background(Color(hex: 0xF7F8FA))
    }
}

// ============================================================ NOTIFICATIONS
struct FbNotificationsVue: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Notifications").font(.system(size: 24, weight: .bold)).foregroundStyle(.black).padding(.horizontal, 14)
                ForEach(Array([
                    ("Chloé Berthier", "a commenté votre photo.", "2 j", true),
                    ("Atelier Poterie Lyon 3", "a publié : « Les inscriptions de septembre sont ouvertes ! »", "1 j", true),
                    ("Lyon Ma Ville", "a publié une nouvelle vidéo.", "5 h", true),
                    ("Marie-Pierre Fourez", "vous a envoyé une demande d'ami(e).", "4 sem.", false),
                ].enumerated()), id: \.offset) { _, n in
                    HStack(alignment: .top, spacing: 11) {
                        Circle().fill(Color(hex: 0xB0B3B8)).frame(width: 52, height: 52)
                            .overlay(Text(String(n.0.prefix(1))).font(.system(size: 20, weight: .semibold)).foregroundStyle(.white))
                        VStack(alignment: .leading, spacing: 2) {
                            (Text(n.0 + " ").font(.system(size: 14, weight: .semibold))
                             + Text(n.1).font(.system(size: 14)))
                                .foregroundStyle(.black)
                            Text(n.2).font(.system(size: 12.5)).foregroundStyle(n.3 ? Color.gray : Color(hex: fbBleu))
                        }
                        Spacer()
                        Image(systemName: "ellipsis").foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 5)
                    .background(n.3 ? Color.white : Color(hex: 0xE7F0FF))
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 6)
        }
    }
}

// ============================================================ MENU
struct FbMenuVue: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Menu").font(.system(size: 24, weight: .bold)).foregroundStyle(.black)
                    Spacer()
                    Image(systemName: "gearshape.fill").font(.system(size: 19)).foregroundStyle(.black)
                    Image(systemName: "magnifyingglass").font(.system(size: 19)).foregroundStyle(.black).padding(.leading, 12)
                }
                .padding(.horizontal, 14)

                HStack(spacing: 11) {
                    Group {
                        if let img = ChargeurPhoto.image("p04") {
                            Image(uiImage: img).resizable().scaledToFill().frame(width: 42, height: 42).clipShape(Circle())
                        } else { Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 42, height: 42) }
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Sarah Levasseur").font(.system(size: 15.5, weight: .semibold)).foregroundStyle(.black)
                        Text("Voir votre profil").font(.system(size: 12.5)).foregroundStyle(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.down.circle.fill").font(.system(size: 22)).foregroundStyle(.gray)
                }
                .padding(12)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: 0xE4E6EB), lineWidth: 1))
                .padding(.horizontal, 14)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(Array([
                        ("clock.arrow.circlepath", "Souvenirs"), ("bookmark.fill", "Enregistrements"),
                        ("person.3.fill", "Groupes"), ("play.rectangle.on.rectangle.fill", "Reels"),
                        ("storefront.fill", "Marketplace"), ("rss", "Fils"),
                    ].enumerated()), id: \.offset) { _, r in
                        HStack(spacing: 9) {
                            Image(systemName: r.0).font(.system(size: 17)).foregroundStyle(Color(hex: fbBleu))
                            Text(r.1).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.black)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(hex: 0xE4E6EB), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 14)

                VStack(spacing: 0) {
                    ForEach(Array(["Aide et assistance", "Paramètres et confidentialité", "Meta AI", "Mentions légales et politiques"].enumerated()), id: \.offset) { i, r in
                        HStack {
                            Text(r).font(.system(size: 15)).foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.down").font(.system(size: 13)).foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 13)
                        if i < 3 { Divider().padding(.leading, 14) }
                    }
                }
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: 0xE4E6EB), lineWidth: 1))
                .padding(.horizontal, 14)
                Spacer(minLength: 90)
            }
            .padding(.top, 6)
        }
        .background(Color(hex: 0xF7F8FA))
    }
}
