// X (Twitter) — construit contre les références vidéo de Joachim du 26/08 (D67, 153 écrans mesurés).
// v1 : fil Pour vous/Abonnements, post détail + réponses, Explore (tendances), notifications, DM
// (conversation réelle), profil de compte (bannière + Suivre), composer. Thème sombre.
// Données Sarah = jeu plausible remplaçable (D59).
import SwiftUI

// ============================================================ DONNÉES
struct XPost: Identifiable {
    let id = UUID()
    var compte: String
    var pseudo: String
    var teinte: UInt
    var certifie: Bool
    var date: String
    var texte: String
    var image: String?
    var reponses: String
    var reposts: String
    var jaime: String
    var vues: String
}

enum DonneesX {
    static let posts: [XPost] = [
        XPost(compte: "Lyon Ma Ville", pseudo: "@lyonmaville", teinte: 0x0A84FF, certifie: true, date: "3 h",
              texte: "L'été indien s'installe sur les quais du Rhône ce week-end 🌇 Températures autour de 27°.",
              image: "p36", reponses: "23", reposts: "68", jaime: "412", vues: "38,2 K"),
        XPost(compte: "Météo Rhône", pseudo: "@meteo_rhone69", teinte: 0x30D1C4, certifie: false, date: "6 h",
              texte: "Beau temps durable sur l'agglomération lyonnaise jusqu'à jeudi. Quelques nuages vendredi.",
              image: nil, reponses: "4", reposts: "12", jaime: "97", vues: "8,4 K"),
        XPost(compte: "Atelier Poterie Lyon 3", pseudo: "@atelierpoterie3", teinte: 0xFF9F0A, certifie: false, date: "1 j",
              texte: "Les inscriptions de septembre sont ouvertes ! Cours du mardi et du jeudi soir, tous niveaux 🏺 Lien en bio.",
              image: "p33", reponses: "7", reposts: "15", jaime: "134", vues: "12,7 K"),
    ]
    static let tendances: [(String, String, String)] = [
        ("Tendances dans la catégorie France", "Rentrée", "42,1 K posts"),
        ("Sport · Tendances", "OL", "18,3 K posts"),
        ("Jeux vidéo · Tendances", "GTA 6", "231 K posts"),
        ("Musique · Tendances", "Festival", "9,8 K posts"),
        ("Tendances dans la catégorie France", "Canicule", "12,4 K posts"),
    ]
    static let reponses: [(String, String, String)] = [
        ("Karim L.", "@karim_lyn", "Enfin !! On y sera 🙌"),
        ("Élise", "@elise_69", "Les quais vont être blindés mais tant pis"),
    ]
}

let xFond: UInt = 0x000000

struct XAvatar: View {
    let nom: String
    let teinte: UInt
    var taille: CGFloat = 42
    var body: some View {
        Circle().fill(Color(hex: teinte)).frame(width: taille, height: taille)
            .overlay(Text(String(nom.prefix(1))).font(.system(size: taille * 0.42, weight: .semibold)).foregroundStyle(.white))
    }
}

// ============================================================ APP (5 onglets — v1 : 4 racines + DM)
struct XVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0
    @State private var composerVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: xFond).ignoresSafeArea()
            Group {
                switch onglet {
                case 1: XExploreVue()
                case 2: XNotificationsVue()
                case 3: XDMVue()
                default: XFilVue()
                }
            }

            // Bouton composer flottant
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Circle().fill(Color(hex: 0x1D9BF0)).frame(width: 54, height: 54)
                        .overlay(Image(systemName: "plus").font(.system(size: 23, weight: .semibold)).foregroundStyle(.white))
                        .contentShape(Circle())
                        .onTapGesture { composerVisible = true }
                        .padding(.trailing, 18).padding(.bottom, 106)
                }
            }

            HStack {
                ForEach(Array([("house.fill", 0), ("magnifyingglass", 1), ("bell", 2), ("envelope", 3)].enumerated()), id: \.offset) { _, o in
                    Image(systemName: o.0).font(.system(size: 22))
                        .foregroundStyle(onglet == o.1 ? Color.white : Color.gray)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { onglet = o.1 }
                }
            }
            .padding(.top, 12).padding(.bottom, 26)
            .background(Color(hex: xFond).opacity(0.98))
            .overlay(Rectangle().fill(Color(hex: 0x2F3336)).frame(height: 0.5), alignment: .top)

            BarreHome { dismiss() }
        }
        .sheet(isPresented: $composerVisible) { XComposerVue() }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ FIL
struct XFilVue: View {
    @State private var ongletFil = 0
    @State private var postOuvert: XPost? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Group {
                    if let img = ChargeurPhoto.image("p04") {
                        Image(uiImage: img).resizable().scaledToFill().frame(width: 30, height: 30).clipShape(Circle())
                    } else { Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 30, height: 30) }
                }
                Spacer()
                Text("𝕏").font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "gearshape").font(.system(size: 18)).foregroundStyle(.white)
            }
            .padding(.horizontal, 14).padding(.vertical, 6)

            HStack(spacing: 0) {
                ForEach(Array(["Pour vous", "Abonnements"].enumerated()), id: \.offset) { i, t in
                    Text(t).font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ongletFil == i ? Color.white : Color.gray)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .overlay(Capsule().fill(ongletFil == i ? Color(hex: 0x1D9BF0) : .clear).frame(width: 56, height: 3), alignment: .bottom)
                        .contentShape(Rectangle())
                        .onTapGesture { ongletFil = i }
                }
            }
            Divider().overlay(Color(hex: 0x2F3336))

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(ongletFil == 0 ? DonneesX.posts : Array(DonneesX.posts.suffix(2))) { p in
                        XPostVue(post: p)
                            .contentShape(Rectangle())
                            .onTapGesture { postOuvert = p }
                        Divider().overlay(Color(hex: 0x2F3336))
                    }
                    Spacer(minLength: 90)
                }
            }
        }
        .fullScreenCover(isPresented: Binding(get: { postOuvert != nil }, set: { if !$0 { postOuvert = nil } })) {
            XPostDetailVue(post: postOuvert ?? DonneesX.posts[0])
        }
    }
}

struct XPostVue: View {
    let post: XPost
    var detail: Bool = false
    @State private var aime = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            XAvatar(nom: post.compte, teinte: post.teinte)
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    Text(post.compte).font(.system(size: 14.5, weight: .bold)).foregroundStyle(.white).lineLimit(1)
                    if post.certifie {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 13)).foregroundStyle(Color(hex: 0x1D9BF0))
                    }
                    Text("\(post.pseudo) · \(post.date)").font(.system(size: 13.5)).foregroundStyle(.gray).lineLimit(1)
                    Spacer()
                    Text("𝕏").font(.system(size: 13)).foregroundStyle(.gray)
                }
                Text(post.texte).font(.system(size: 14.5)).foregroundStyle(.white)
                if let cle = post.image {
                    Group {
                        if let img = ChargeurPhoto.image(cle) {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else { Rectangle().fill(Color(hex: 0x2F3336)) }
                    }
                    .frame(height: 190).clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                HStack {
                    HStack(spacing: 4) { Image(systemName: "bubble.left"); Text(post.reponses) }
                    Spacer()
                    HStack(spacing: 4) { Image(systemName: "arrow.2.squarepath"); Text(post.reposts) }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: aime ? "heart.fill" : "heart")
                            .foregroundStyle(aime ? Color(hex: 0xF91880) : Color.gray)
                        Text(post.jaime)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); aime.toggle() }
                    Spacer()
                    HStack(spacing: 4) { Image(systemName: "chart.bar.xaxis"); Text(post.vues) }
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                }
                .font(.system(size: 12.5)).foregroundStyle(.gray)
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }
}

// ============================================================ POST DÉTAIL
struct XPostDetailVue: View {
    @Environment(\.dismiss) private var dismiss
    let post: XPost
    @State private var saisie = ""
    @State private var envoyees: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.left").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .onTapGesture { dismiss() }
                Text("Post").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    XPostVue(post: post, detail: true)
                    Divider().overlay(Color(hex: 0x2F3336))
                    ForEach(Array(DonneesX.reponses.enumerated()), id: \.offset) { _, r in
                        HStack(alignment: .top, spacing: 10) {
                            XAvatar(nom: r.0, teinte: 0x8B5CF6, taille: 36)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 4) {
                                    Text(r.0).font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                                    Text(r.1).font(.system(size: 13)).foregroundStyle(.gray)
                                }
                                Text(r.2).font(.system(size: 14)).foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        Divider().overlay(Color(hex: 0x2F3336))
                    }
                    ForEach(Array(envoyees.enumerated()), id: \.offset) { _, t in
                        HStack(alignment: .top, spacing: 10) {
                            XAvatar(nom: "Sarah", teinte: 0x5B7CFA, taille: 36)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 4) {
                                    Text("Sarah").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                                    Text("@sarah_lvsr").font(.system(size: 13)).foregroundStyle(.gray)
                                }
                                Text(t).font(.system(size: 14)).foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        Divider().overlay(Color(hex: 0x2F3336))
                    }
                }
            }
            HStack(spacing: 10) {
                TextField("Postez votre réponse", text: $saisie)
                    .font(.system(size: 14)).foregroundStyle(.white)
                    .padding(.horizontal, 13).padding(.vertical, 9)
                    .background(Color(hex: 0x202327), in: Capsule())
                    .onSubmit { if !saisie.isEmpty { envoyees.append(saisie); saisie = "" } }
                Text("Répondre").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 13).padding(.vertical, 8)
                    .background(Color(hex: 0x1D9BF0), in: Capsule())
                    .contentShape(Capsule())
                    .onTapGesture { if !saisie.isEmpty { envoyees.append(saisie); saisie = "" } }
            }
            .padding(12)
            BarreHome { dismiss() }
        }
        .background(Color(hex: xFond))
        .preferredColorScheme(.dark)
    }
}

// ============================================================ EXPLORE
struct XExploreVue: View {
    @State private var texte = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.gray)
                    TextField("Rechercher", text: $texte).font(.system(size: 14.5)).foregroundStyle(.white)
                }
                .padding(.horizontal, 12).frame(height: 38)
                .background(Color(hex: 0x202327), in: Capsule())
                .padding(.horizontal, 14)

                HStack(spacing: 16) {
                    ForEach(Array(["Explore", "Tendances", "Actualités", "Sport", "Div"].enumerated()), id: \.offset) { i, t in
                        Text(t).font(.system(size: 14, weight: i == 0 ? .bold : .regular))
                            .foregroundStyle(i == 0 ? Color.white : Color.gray)
                    }
                }
                .padding(.horizontal, 14)
                Divider().overlay(Color(hex: 0x2F3336))

                ForEach(Array(DonneesX.tendances.enumerated()), id: \.offset) { i, t in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(t.0).font(.system(size: 12.5)).foregroundStyle(.gray)
                            Text(t.1).font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                            Text(t.2).font(.system(size: 12.5)).foregroundStyle(.gray)
                        }
                        Spacer()
                        Image(systemName: "ellipsis").foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 8)
        }
    }
}

// ============================================================ NOTIFICATIONS
struct XNotificationsVue: View {
    @State private var ongletN = 0
    var body: some View {
        VStack(spacing: 0) {
            Text("Notifications").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 10)
            HStack(spacing: 0) {
                ForEach(Array(["Tous", "Mentions"].enumerated()), id: \.offset) { i, t in
                    Text(t).font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ongletN == i ? Color.white : Color.gray)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .overlay(Capsule().fill(ongletN == i ? Color(hex: 0x1D9BF0) : .clear).frame(width: 46, height: 3), alignment: .bottom)
                        .contentShape(Rectangle())
                        .onTapGesture { ongletN = i }
                }
            }
            Divider().overlay(Color(hex: 0x2F3336))
            ScrollView {
                if ongletN == 0 {
                    VStack(spacing: 0) {
                        ForEach(Array([
                            ("Lyon Ma Ville", "Nouveau post : « L'été indien s'installe sur les quais… »", 0x0A84FF),
                            ("Atelier Poterie Lyon 3", "a posté récemment.", 0xFF9F0A),
                            ("Météo Rhône", "Nouvelles notifications de post activées.", 0x30D1C4),
                        ].enumerated()), id: \.offset) { _, n in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "bolt.fill").font(.system(size: 17)).foregroundStyle(Color(hex: 0x7856FF)).frame(width: 30)
                                VStack(alignment: .leading, spacing: 3) {
                                    XAvatar(nom: n.0, teinte: UInt(n.2), taille: 30)
                                    (Text(n.0 + " ").font(.system(size: 14, weight: .bold))
                                     + Text(n.1).font(.system(size: 14)))
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            Divider().overlay(Color(hex: 0x2F3336))
                        }
                        Spacer(minLength: 90)
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("Rien à voir ici, pour le moment").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                        Text("Quand quelqu'un vous mentionnera, vous le retrouverez ici.")
                            .font(.system(size: 13.5)).foregroundStyle(.gray).multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40).padding(.top, 90)
                }
            }
        }
    }
}

// ============================================================ MESSAGES PRIVÉS
struct XDMVue: View {
    @State private var convOuverte = false
    var body: some View {
        VStack(spacing: 0) {
            Text("Messages").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 10)
            Divider().overlay(Color(hex: 0x2F3336))
            ScrollView {
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 10) {
                        XAvatar(nom: "Atelier Poterie Lyon 3", teinte: 0xFF9F0A)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text("Atelier Poterie Lyon 3").font(.system(size: 14.5, weight: .bold)).foregroundStyle(.white)
                                Text("@atelierpoterie3 · 12 juil.").font(.system(size: 13)).foregroundStyle(.gray)
                            }
                            Text("Oui bien sûr, il reste des places le jeudi !").font(.system(size: 13.5)).foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .contentShape(Rectangle())
                    .onTapGesture { convOuverte = true }
                    Divider().overlay(Color(hex: 0x2F3336))
                    Spacer(minLength: 90)
                }
            }
        }
        .sheet(isPresented: $convOuverte) { XConversationVue() }
    }
}

struct XConversationVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var saisie = ""
    @State private var envoyes: [String] = []
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 10) {
                        Text("12 juil. 2026").font(.system(size: 11.5)).foregroundStyle(.gray)
                        HStack {
                            Text("Bonjour ! Est-ce qu'il reste des places pour les cours du soir en septembre ?")
                                .font(.system(size: 14.5)).foregroundStyle(.white)
                                .padding(.horizontal, 13).padding(.vertical, 9)
                                .background(Color(hex: 0x1D9BF0), in: RoundedRectangle(cornerRadius: 18))
                                .frame(maxWidth: 290, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        HStack {
                            Text("Oui bien sûr, il reste des places le jeudi !")
                                .font(.system(size: 14.5)).foregroundStyle(.white)
                                .padding(.horizontal, 13).padding(.vertical, 9)
                                .background(Color(hex: 0x2F3336), in: RoundedRectangle(cornerRadius: 18))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(Array(envoyes.enumerated()), id: \.offset) { _, t in
                            HStack {
                                Text(t).font(.system(size: 14.5)).foregroundStyle(.white)
                                    .padding(.horizontal, 13).padding(.vertical, 9)
                                    .background(Color(hex: 0x1D9BF0), in: RoundedRectangle(cornerRadius: 18))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(14)
                }
                HStack(spacing: 10) {
                    TextField("Envoyer un message", text: $saisie)
                        .font(.system(size: 14)).foregroundStyle(.white)
                        .padding(.horizontal, 13).padding(.vertical, 9)
                        .background(Color(hex: 0x202327), in: Capsule())
                        .onSubmit { if !saisie.isEmpty { envoyes.append(saisie); saisie = "" } }
                    Image(systemName: "paperplane.fill").foregroundStyle(Color(hex: 0x1D9BF0))
                        .contentShape(Rectangle())
                        .onTapGesture { if !saisie.isEmpty { envoyes.append(saisie); saisie = "" } }
                }
                .padding(12)
            }
            .background(Color(hex: xFond))
            .navigationTitle("Atelier Poterie Lyon 3")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x1D9BF0))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ COMPOSER
struct XComposerVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var texte = ""
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Group {
                        if let img = ChargeurPhoto.image("p04") {
                            Image(uiImage: img).resizable().scaledToFill().frame(width: 40, height: 40).clipShape(Circle())
                        } else { Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 40, height: 40) }
                    }
                    TextField("", text: $texte, prompt: Text("Quoi de neuf ?!").foregroundStyle(.gray), axis: .vertical)
                        .font(.system(size: 17)).foregroundStyle(.white)
                }
                Spacer()
                HStack(spacing: 18) {
                    ForEach(["photo", "gift", "list.bullet", "mappin"], id: \.self) { s in
                        Image(systemName: s).font(.system(size: 18)).foregroundStyle(Color(hex: 0x1D9BF0))
                    }
                    Spacer()
                }
            }
            .padding(16)
            .background(Color(hex: xFond))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }.foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Poster") { dismiss() }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .background(Color(hex: 0x1D9BF0), in: Capsule())
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
