// Instagram — construit contre les références vidéo de Joachim du 26/08 (D67, 239 écrans mesurés).
// v1 : feed (stories + publications), recherche (mosaïque + récent + résultats), Reels, profil Sarah
// (grille, onglets), profil privé (« Ce profil est privé »), visionneuse de story, DM, activité.
// Données Sarah = jeu plausible remplaçable (D59). Icônes = approximations SF (D55, maison).
import SwiftUI

// ============================================================ DONNÉES
struct InstaCompte: Identifiable {
    let id: String          // pseudo
    var nom: String
    var photo: String?
    var teinte: UInt
    var prive: Bool = false
}

struct InstaPost: Identifiable {
    let id = UUID()
    var compte: InstaCompte
    var lieu: String? = nil
    var image: String
    var jaime: String
    var aimePar: String
    var legende: String
    var date: String
}

enum DonneesInsta {
    static let sarah = InstaCompte(id: "sarah.lvsr", nom: "Sarah Levasseur", photo: "p04", teinte: 0x5B7CFA)
    static let comptes: [InstaCompte] = [
        InstaCompte(id: "chloe.brt", nom: "Chloé Berthier", photo: "p12", teinte: 0xE64980),
        InstaCompte(id: "ines.djl", nom: "Inès Djellal", photo: nil, teinte: 0x8B5CF6),
        InstaCompte(id: "atelierpoterie.lyon3", nom: "Atelier Poterie Lyon 3", photo: nil, teinte: 0xFF9F0A),
        InstaCompte(id: "lea.mrx", nom: "Léa Moreau", photo: "p18", teinte: 0x30D1C4, prive: true),
        InstaCompte(id: "lyon.maville", nom: "Lyon Ma Ville", photo: nil, teinte: 0x0A84FF),
    ]
    static let posts: [InstaPost] = [
        InstaPost(compte: comptes[0], lieu: "Lac d'Annecy", image: "p30",
                  jaime: "87", aimePar: "Aimé par ines.djl et d'autres personnes",
                  legende: "Week-end parfait avec la meilleure 💙 #annecy", date: "Il y a 9 jours"),
        InstaPost(compte: comptes[2], lieu: "Lyon 3e", image: "p33",
                  jaime: "214", aimePar: "Aimé par chloe.brt et d'autres personnes",
                  legende: "Les créations du cours du mardi soir 🏺 Inscriptions ouvertes pour septembre !", date: "Il y a 2 semaines"),
        InstaPost(compte: comptes[4], lieu: "Parc de la Tête d'Or", image: "p36",
                  jaime: "1 892", aimePar: "Aimé par atelierpoterie.lyon3 et d'autres personnes",
                  legende: "L'été indien s'installe sur le parc 🌇", date: "Il y a 3 semaines"),
    ]
    static let grilleSarah = ["p30", "p31", "p32", "p33", "p34", "p35", "p36", "p37", "p38", "p39", "p40", "p41"]
    static let mosaique = ["p20", "p21", "p22", "p23", "p24", "p25", "p26", "p27", "p28", "p29", "p30", "p31",
                           "p32", "p33", "p34", "p35", "p36", "p37", "p38", "p39", "p40"]
}

let instaFond: UInt = 0x000000

// Avatar (photo ou initiale, anneau story en option)
struct InstaAvatar: View {
    let compte: InstaCompte
    var taille: CGFloat = 56
    var anneau: Bool = false
    var body: some View {
        Group {
            if let cle = compte.photo, let img = ChargeurPhoto.image(cle) {
                Image(uiImage: img).resizable().scaledToFill()
                    .frame(width: taille, height: taille).clipShape(Circle())
            } else {
                Circle().fill(Color(hex: compte.teinte)).frame(width: taille, height: taille)
                    .overlay(Text(String(compte.nom.prefix(1))).font(.system(size: taille * 0.4, weight: .semibold)).foregroundStyle(.white))
            }
        }
        .padding(anneau ? 3 : 0)
        .background(
            anneau ?
            AnyView(Circle().strokeBorder(
                AngularGradient(colors: [Color(hex: 0xF9CE34), Color(hex: 0xEE2A7B), Color(hex: 0x6228D7), Color(hex: 0xF9CE34)], center: .center),
                lineWidth: 2.5)) : AnyView(EmptyView())
        )
    }
}

// ============================================================ APP (5 onglets)
struct InstagramVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: instaFond).ignoresSafeArea()
            Group {
                switch onglet {
                case 1: InstaRechercheVue()
                case 2: InstaReelsVue()
                case 3: InstaProfilVue()
                default: InstaFeedVue()
                }
            }

            HStack {
                Image(systemName: onglet == 0 ? "house.fill" : "house").font(.system(size: 23))
                    .frame(maxWidth: .infinity).contentShape(Rectangle())
                    .onTapGesture { onglet = 0 }
                Image(systemName: "magnifyingglass").font(.system(size: 23, weight: onglet == 1 ? .semibold : .regular))
                    .frame(maxWidth: .infinity).contentShape(Rectangle())
                    .onTapGesture { onglet = 1 }
                Image(systemName: "plus.app").font(.system(size: 23))
                    .frame(maxWidth: .infinity)
                Image(systemName: onglet == 2 ? "play.rectangle.fill" : "play.rectangle").font(.system(size: 23))
                    .frame(maxWidth: .infinity).contentShape(Rectangle())
                    .onTapGesture { onglet = 2 }
                Group {
                    if let img = ChargeurPhoto.image("p04") {
                        Image(uiImage: img).resizable().scaledToFill()
                            .frame(width: 26, height: 26).clipShape(Circle())
                            .overlay(Circle().strokeBorder(onglet == 3 ? Color.white : Color.clear, lineWidth: 1.5))
                    } else {
                        Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 26, height: 26)
                    }
                }
                .frame(maxWidth: .infinity).contentShape(Rectangle())
                .onTapGesture { onglet = 3 }
            }
            .foregroundStyle(.white)
            .padding(.top, 10).padding(.bottom, 26)
            .background(Color(hex: instaFond).opacity(0.98))
            .overlay(Rectangle().fill(Color(hex: 0x262626)).frame(height: 0.5), alignment: .top)

            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ FEED
struct InstaFeedVue: View {
    @State private var storyOuverte: InstaCompte? = nil
    @State private var dmOuverts = false
    @State private var activiteOuverte = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Instagram").font(.system(size: 25, weight: .bold)).foregroundStyle(.white)
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "heart").font(.system(size: 22)).foregroundStyle(.white)
                        .contentShape(Rectangle())
                        .onTapGesture { activiteOuverte = true }
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "paperplane").font(.system(size: 21)).foregroundStyle(.white)
                        Text("3").font(.system(size: 9, weight: .semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 4).padding(.vertical, 1)
                            .background(Color(hex: 0xFF3B30), in: Capsule())
                            .offset(x: 8, y: -7)
                    }
                    .padding(.leading, 16)
                    .contentShape(Rectangle())
                    .onTapGesture { dmOuverts = true }
                }
                .padding(.horizontal, 14).padding(.bottom, 10)

                // Stories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        VStack(spacing: 4) {
                            ZStack(alignment: .bottomTrailing) {
                                InstaAvatar(compte: DonneesInsta.sarah, taille: 62)
                                Circle().fill(Color(hex: 0x0095F6)).frame(width: 20, height: 20)
                                    .overlay(Image(systemName: "plus").font(.system(size: 11, weight: .bold)).foregroundStyle(.white))
                                    .overlay(Circle().strokeBorder(Color.black, lineWidth: 2))
                            }
                            Text("Votre story").font(.system(size: 11.5)).foregroundStyle(.secondary)
                        }
                        ForEach(DonneesInsta.comptes) { c in
                            VStack(spacing: 4) {
                                InstaAvatar(compte: c, taille: 62, anneau: true)
                                Text(c.id).font(.system(size: 11.5)).foregroundStyle(.white).lineLimit(1)
                            }
                            .frame(width: 72)
                            .contentShape(Rectangle())
                            .onTapGesture { storyOuverte = c }
                        }
                    }
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 10)
                Divider().overlay(Color(hex: 0x262626))

                // Publications
                ForEach(DonneesInsta.posts) { p in
                    InstaPostVue(post: p)
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 6)
        }
        .fullScreenCover(isPresented: Binding(get: { storyOuverte != nil }, set: { if !$0 { storyOuverte = nil } })) {
            InstaStoryVue(compte: storyOuverte ?? DonneesInsta.comptes[0])
        }
        .sheet(isPresented: $dmOuverts) { InstaDMVue() }
        .sheet(isPresented: $activiteOuverte) { InstaActiviteVue() }
    }
}

struct InstaPostVue: View {
    let post: InstaPost
    @State private var aime = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 9) {
                InstaAvatar(compte: post.compte, taille: 34, anneau: true)
                VStack(alignment: .leading, spacing: 0) {
                    Text(post.compte.id).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                    if let lieu = post.lieu {
                        Text(lieu).font(.system(size: 11.5)).foregroundStyle(.white.opacity(0.85))
                    }
                }
                Spacer()
                Image(systemName: "ellipsis").font(.system(size: 15)).foregroundStyle(.white)
            }
            .padding(.horizontal, 12)

            Group {
                if let img = ChargeurPhoto.image(post.image) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Rectangle().fill(Color(hex: 0x262626))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 380).clipped()
            .contentShape(Rectangle())
            .onTapGesture(count: 2) { Haptique.leger(); aime = true }

            HStack(spacing: 16) {
                HStack(spacing: 5) {
                    Image(systemName: aime ? "heart.fill" : "heart").font(.system(size: 22))
                        .foregroundStyle(aime ? Color(hex: 0xFF3040) : .white)
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); aime.toggle() }
                    Text(post.jaime).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                }
                HStack(spacing: 5) {
                    Image(systemName: "bubble.right").font(.system(size: 21)).foregroundStyle(.white)
                    Text("12").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                }
                Image(systemName: "paperplane").font(.system(size: 21)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "bookmark").font(.system(size: 21)).foregroundStyle(.white)
            }
            .padding(.horizontal, 12)

            VStack(alignment: .leading, spacing: 3) {
                Text(post.aimePar).font(.system(size: 13)).foregroundStyle(.white)
                (Text(post.compte.id + " ").font(.system(size: 13, weight: .semibold))
                 + Text(post.legende).font(.system(size: 13)))
                    .foregroundStyle(.white)
                Text(post.date).font(.system(size: 11.5)).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 10)
    }
}

// ============================================================ STORY
struct InstaStoryVue: View {
    @Environment(\.dismiss) private var dismiss
    let compte: InstaCompte
    @State private var saisie = ""

    var body: some View {
        ZStack {
            Group {
                if let img = ChargeurPhoto.image("p31") {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    LinearGradient(colors: [Color(hex: 0x6228D7), Color(hex: 0xEE2A7B)], startPoint: .top, endPoint: .bottom)
                }
            }
            .ignoresSafeArea()
            Color.black.opacity(0.12).ignoresSafeArea()

            VStack(spacing: 10) {
                Capsule().fill(Color.white.opacity(0.9)).frame(height: 2.5)
                    .padding(.horizontal, 10).padding(.top, 8)
                HStack(spacing: 9) {
                    InstaAvatar(compte: compte, taille: 34)
                    Text(compte.id).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                    Text("Il y a 4 h").font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                    Spacer()
                    Image(systemName: "ellipsis").foregroundStyle(.white)
                    Image(systemName: "xmark").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                        .contentShape(Rectangle())
                        .onTapGesture { dismiss() }
                }
                .padding(.horizontal, 12)
                Spacer()
                HStack(spacing: 12) {
                    TextField("", text: $saisie, prompt: Text("Envoyer un message…").foregroundStyle(.white.opacity(0.8)))
                        .font(.system(size: 14)).foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
                    Image(systemName: "heart").font(.system(size: 24)).foregroundStyle(.white)
                    Image(systemName: "paperplane").font(.system(size: 23)).foregroundStyle(.white)
                }
                .padding(.horizontal, 12).padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ RECHERCHE
struct InstaRechercheVue: View {
    @State private var texte = ""
    @State private var profilOuvert: InstaCompte? = nil
    @FocusState private var actif: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    HStack(spacing: 7) {
                        Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundStyle(.secondary)
                        TextField("Rechercher", text: $texte).font(.system(size: 15)).foregroundStyle(.white)
                            .focused($actif)
                    }
                    .padding(.horizontal, 11).frame(height: 36)
                    .background(Color(hex: 0x262626), in: RoundedRectangle(cornerRadius: 10))
                    if actif || !texte.isEmpty {
                        Text("Annuler").font(.system(size: 14)).foregroundStyle(.white)
                            .contentShape(Rectangle())
                            .onTapGesture { texte = ""; actif = false }
                    }
                }
                .padding(.horizontal, 12)

                if actif || !texte.isEmpty {
                    // Récent + résultats de comptes
                    HStack {
                        Text("Récent").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        Spacer()
                        Text("Voir tout").font(.system(size: 13)).foregroundStyle(Color(hex: 0x0095F6))
                    }
                    .padding(.horizontal, 14).padding(.top, 4)
                    ForEach(DonneesInsta.comptes.filter { texte.isEmpty || $0.id.lowercased().contains(texte.lowercased()) || $0.nom.lowercased().contains(texte.lowercased()) }) { c in
                        HStack(spacing: 11) {
                            InstaAvatar(compte: c, taille: 46)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(c.id).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                Text(c.nom).font(.system(size: 13)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "xmark").font(.system(size: 13)).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .contentShape(Rectangle())
                        .onTapGesture { profilOuvert = c }
                    }
                } else {
                    // Mosaïque
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1.5), count: 3), spacing: 1.5) {
                        ForEach(Array(DonneesInsta.mosaique.enumerated()), id: \.offset) { _, cle in
                            Group {
                                if let img = ChargeurPhoto.image(cle) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else {
                                    Rectangle().fill(Color(hex: 0x262626))
                                }
                            }
                            .frame(height: 128).clipped()
                        }
                    }
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 8)
        }
        .fullScreenCover(isPresented: Binding(get: { profilOuvert != nil }, set: { if !$0 { profilOuvert = nil } })) {
            InstaProfilTiersVue(compte: profilOuvert ?? DonneesInsta.comptes[0])
        }
    }
}

// ============================================================ REELS
struct InstaReelsVue: View {
    @State private var aime = false
    var body: some View {
        ZStack {
            Group {
                if let img = ChargeurPhoto.image("p37") {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    LinearGradient(colors: [Color(hex: 0x111111), Color(hex: 0x333333)], startPoint: .top, endPoint: .bottom)
                }
            }
            .ignoresSafeArea()
            Color.black.opacity(0.18).ignoresSafeArea()

            VStack {
                HStack {
                    Text("Reels").font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "camera").font(.system(size: 21)).foregroundStyle(.white)
                }
                .padding(.horizontal, 14).padding(.top, 4)
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 9) {
                        HStack(spacing: 8) {
                            InstaAvatar(compte: DonneesInsta.comptes[4], taille: 32)
                            Text(DonneesInsta.comptes[4].id).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                            Text("Suivre").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                                .padding(.horizontal, 9).padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 7).strokeBorder(Color.white.opacity(0.8), lineWidth: 1))
                        }
                        Text("Coucher de soleil sur les quais du Rhône 🌅").font(.system(size: 13)).foregroundStyle(.white)
                        HStack(spacing: 5) {
                            Image(systemName: "music.note").font(.system(size: 11))
                            Text("lyon.maville · Audio d'origine").font(.system(size: 12))
                        }
                        .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(spacing: 17) {
                        VStack(spacing: 3) {
                            Image(systemName: aime ? "heart.fill" : "heart").font(.system(size: 26))
                                .foregroundStyle(aime ? Color(hex: 0xFF3040) : .white)
                                .contentShape(Rectangle())
                                .onTapGesture { Haptique.leger(); aime.toggle() }
                            Text("2 481").font(.system(size: 11.5)).foregroundStyle(.white)
                        }
                        VStack(spacing: 3) {
                            Image(systemName: "bubble.right").font(.system(size: 24)).foregroundStyle(.white)
                            Text("57").font(.system(size: 11.5)).foregroundStyle(.white)
                        }
                        VStack(spacing: 3) {
                            Image(systemName: "paperplane").font(.system(size: 24)).foregroundStyle(.white)
                            Text("103").font(.system(size: 11.5)).foregroundStyle(.white)
                        }
                        Image(systemName: "ellipsis").font(.system(size: 19)).foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 14).padding(.bottom, 96)
            }
        }
    }
}

// ============================================================ PROFIL SARAH
struct InstaProfilVue: View {
    @State private var ongletGrille = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 5) {
                    Text(DonneesInsta.sarah.id).font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "plus.app").font(.system(size: 22)).foregroundStyle(.white)
                    Image(systemName: "line.3.horizontal").font(.system(size: 22)).foregroundStyle(.white).padding(.leading, 14)
                }
                .padding(.horizontal, 14)

                HStack(spacing: 0) {
                    InstaAvatar(compte: DonneesInsta.sarah, taille: 82, anneau: true)
                    Spacer()
                    ForEach([("12", "publications"), ("143", "followers"), ("187", "suivi(e)s")], id: \.1) { v in
                        VStack(spacing: 1) {
                            Text(v.0).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                            Text(v.1).font(.system(size: 12.5)).foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Sarah Levasseur").font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                    Text("Lyon 🌸 photo, céramique et randos\n📚 infirmière le reste du temps").font(.system(size: 13)).foregroundStyle(.white)
                }
                .padding(.horizontal, 14)

                HStack(spacing: 7) {
                    Text("Modifier").font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(Color(hex: 0x262626), in: RoundedRectangle(cornerRadius: 8))
                    Text("Partager le profil").font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .background(Color(hex: 0x262626), in: RoundedRectangle(cornerRadius: 8))
                    Image(systemName: "person.badge.plus").font(.system(size: 14)).foregroundStyle(.white)
                        .padding(.vertical, 8).padding(.horizontal, 9)
                        .background(Color(hex: 0x262626), in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 14)

                HStack(spacing: 0) {
                    ForEach(Array(["squareshape.split.3x3", "play.rectangle", "person.crop.square"].enumerated()), id: \.offset) { i, s in
                        Image(systemName: s).font(.system(size: 20))
                            .foregroundStyle(ongletGrille == i ? Color.white : Color.secondary)
                            .frame(maxWidth: .infinity).padding(.vertical, 9)
                            .overlay(Rectangle().fill(ongletGrille == i ? Color.white : Color.clear).frame(height: 1.5), alignment: .bottom)
                            .contentShape(Rectangle())
                            .onTapGesture { ongletGrille = i }
                    }
                }

                if ongletGrille == 0 {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1.5), count: 3), spacing: 1.5) {
                        ForEach(Array(DonneesInsta.grilleSarah.enumerated()), id: \.offset) { _, cle in
                            Group {
                                if let img = ChargeurPhoto.image(cle) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else {
                                    Rectangle().fill(Color(hex: 0x262626))
                                }
                            }
                            .frame(height: 128).clipped()
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: ongletGrille == 1 ? "play.rectangle" : "person.crop.square")
                            .font(.system(size: 36)).foregroundStyle(.secondary)
                        Text(ongletGrille == 1 ? "Aucun reel" : "Photos et vidéos de vous")
                            .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        Text(ongletGrille == 1 ? "Les reels que vous partagez apparaîtront ici."
                             : "Lorsque des personnes vous identifient sur des photos, elles apparaissent ici.")
                            .font(.system(size: 12.5)).foregroundStyle(.secondary).multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 50)
                }
                Spacer(minLength: 90)
            }
            .padding(.top, 6)
        }
    }
}

// ============================================================ PROFIL TIERS (dont privé)
struct InstaProfilTiersVue: View {
    @Environment(\.dismiss) private var dismiss
    let compte: InstaCompte
    @State private var suit = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .onTapGesture { dismiss() }
                Text(compte.id).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "ellipsis").font(.system(size: 18)).foregroundStyle(.white)
            }
            .padding(.horizontal, 14).padding(.top, 8)

            HStack(spacing: 0) {
                InstaAvatar(compte: compte, taille: 82)
                Spacer()
                ForEach([(compte.prive ? "9" : "48", "publications"), ("223", "followers"), ("233", "suivi(e)s")], id: \.1) { v in
                    VStack(spacing: 1) {
                        Text(v.0).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                        Text(v.1).font(.system(size: 12.5)).foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 14)

            Text(compte.nom).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                .padding(.horizontal, 14)

            Text(suit ? "Suivi(e)" : "Suivre")
                .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 9)
                .background(suit ? Color(hex: 0x262626) : Color(hex: 0x0095F6), in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 14)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); suit.toggle() }

            if compte.prive && !suit {
                Spacer()
                VStack(spacing: 10) {
                    Circle().strokeBorder(Color.white.opacity(0.8), lineWidth: 1.5).frame(width: 64, height: 64)
                        .overlay(Image(systemName: "lock").font(.system(size: 24)).foregroundStyle(.white))
                    Text("Ce profil est privé").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    Text("Suivez ce profil pour voir ses photos et vidéos.")
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                Spacer()
                Spacer()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1.5), count: 3), spacing: 1.5) {
                    ForEach(Array(["p20", "p23", "p26", "p29", "p32", "p35"].enumerated()), id: \.offset) { _, cle in
                        Group {
                            if let img = ChargeurPhoto.image(cle) {
                                Image(uiImage: img).resizable().scaledToFill()
                            } else {
                                Rectangle().fill(Color(hex: 0x262626))
                            }
                        }
                        .frame(height: 128).clipped()
                    }
                }
                Spacer()
            }
        }
        .background(Color(hex: instaFond))
        .preferredColorScheme(.dark)
    }
}

// ============================================================ DM + ACTIVITÉ
struct InstaDMVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var filOuvert: InstaCompte? = nil
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(DonneesInsta.comptes) { c in
                        HStack(spacing: 12) {
                            InstaAvatar(compte: c, taille: 54)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(c.nom).font(.system(size: 14.5)).foregroundStyle(.white)
                                Text(c.id == "chloe.brt" ? "A envoyé une publication · 2 j" : "Vu · 1 sem.")
                                    .font(.system(size: 13)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "camera").font(.system(size: 19)).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture { filOuvert = c }
                    }
                }
                .padding(.top, 8)
            }
            .background(Color(hex: instaFond))
            .navigationTitle(DonneesInsta.sarah.id)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0095F6))
                }
            }
            .sheet(isPresented: Binding(get: { filOuvert != nil }, set: { if !$0 { filOuvert = nil } })) {
                FilGeneriqueVue(nom: (filOuvert ?? DonneesInsta.comptes[0]).nom,
                                teinte: (filOuvert ?? DonneesInsta.comptes[0]).teinte,
                                messages: (filOuvert?.id == "chloe.brt")
                                ? [(false, "Regarde cette publication, ça m'a fait penser à toi 😍"), (true, "Ahah j'adore !! On y va ?"), (false, "Carrément, je regarde les dates")]
                                : [(false, "Vu · pas encore de réponse")])
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct InstaActiviteVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cette semaine").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.top, 10)
                    ForEach(Array([
                        (DonneesInsta.comptes[0], "a aimé votre photo.", "2 j"),
                        (DonneesInsta.comptes[1], "a commencé à vous suivre.", "4 j"),
                        (DonneesInsta.comptes[2], "a aimé votre photo.", "6 j"),
                    ].enumerated()), id: \.offset) { _, a in
                        HStack(spacing: 11) {
                            InstaAvatar(compte: a.0, taille: 44)
                            (Text(a.0.id + " ").font(.system(size: 13.5, weight: .semibold))
                             + Text(a.1 + " ").font(.system(size: 13.5))
                             + Text(a.2).font(.system(size: 13)).foregroundColor(.secondary))
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 5)
                    }
                }
            }
            .background(Color(hex: instaFond))
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0095F6))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
