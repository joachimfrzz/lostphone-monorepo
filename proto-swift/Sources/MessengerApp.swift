// Messenger — construit contre les références vidéo de Joachim du 26/08 (D67, 106 écrans mesurés).
// v1 : Discussions (recherche Meta AI, rangée notes, liste), conversation (bulles 0084FF, réactions,
// horodatages centrés, événements d'appel Rappeler, confirmations de lecture), groupe (noms + avatars),
// fiche discussion (actions + bascules réelles D62), membres, contenus multimédias, Stories,
// Notifications (suggestions), Menu, Paramètres, Invitations par message, Archive, nouvelle discussion.
// Données Sarah = jeu plausible remplaçable (D59). Icônes = approximations SF (D55, maison).
import SwiftUI

// ============================================================ DONNÉES
struct MsgrConversation: Identifiable {
    let id: String
    var nom: String
    var photo: String?      // clé pellicule ou nil -> initiale colorée
    var teinte: UInt
    var apercu: String
    var date: String = ""
    var nonLu: Bool = false
    var groupe: Bool = false
}

struct MsgrMessage: Identifiable {
    let id = UUID()
    var deMoi: Bool
    var auteur: String? = nil     // groupes : nom au-dessus de la bulle
    var texte: String? = nil
    var separateur: String? = nil // "MAR. À 19:24"
    var appel: (manque: Bool, duree: String)? = nil
    var reaction: String? = nil
    var vu: Bool = false
}

enum DonneesMessenger {
    static let conversations: [MsgrConversation] = [
        MsgrConversation(id: "chloe", nom: "Chloé Berthier", photo: "p12", teinte: 0xE64980,
                         apercu: "Vous : Oui promis on se fait ça 😊 · 16 août", nonLu: true),
        MsgrConversation(id: "maman", nom: "Maman", photo: nil, teinte: 0xE8A0A0,
                         apercu: "A réagi avec ❤️ à votre message · 14 août"),
        MsgrConversation(id: "filles", nom: "Les filles 💃", photo: "p22", teinte: 0x8B5CF6,
                         apercu: "Inès : On dit 20h30 chez moi alors ! · 12 août", nonLu: true, groupe: true),
        MsgrConversation(id: "thomas", nom: "Thomas Levasseur", photo: nil, teinte: 0x0A84FF,
                         apercu: "L'appel vocal est terminé. · 9 août"),
        MsgrConversation(id: "julie", nom: "Julie Kiné Villeurbanne", photo: nil, teinte: 0x30D158,
                         apercu: "Vous : Parfait, à jeudi ! · 7 août"),
        MsgrConversation(id: "commode", nom: "Nadia Benkacem", photo: nil, teinte: 0xFF9F0A,
                         apercu: "La commode est toujours dispo ? · 28 juil."),
        MsgrConversation(id: "lea", nom: "Léa Moreau", photo: "p18", teinte: 0x30D1C4,
                         apercu: "Super merci beaucoup !! · 21 juil."),
        MsgrConversation(id: "cadeau", nom: "Idée cadeau papa", photo: nil, teinte: 0x5B7CFA,
                         apercu: "Vous avez quitté le groupe. · 2 mai", groupe: true),
    ]

    static let convChloe: [MsgrMessage] = [
        MsgrMessage(deMoi: false, separateur: "SAM. À 18:47"),
        MsgrMessage(deMoi: false, texte: "Coucou ! Alors ce week-end à Annecy c'était comment ?? 😍"),
        MsgrMessage(deMoi: true, texte: "Trop bien !! Le lac était magnifique, je te montre les photos jeudi"),
        MsgrMessage(deMoi: false, texte: "Trop hâte 😍 Et sinon ça va toi ? Tu avais l'air ailleurs au tél"),
        MsgrMessage(deMoi: true, texte: "Oui oui t'inquiète, juste fatiguée en ce moment", reaction: "❤️"),
        MsgrMessage(deMoi: false, separateur: "16 AOÛT À 21:04"),
        MsgrMessage(deMoi: false, appel: (manque: true, duree: "")),
        MsgrMessage(deMoi: false, texte: "Je t'ai appelée, rappelle-moi quand tu peux 🙏"),
        MsgrMessage(deMoi: false, texte: "On se fait un ciné la semaine prochaine ? Ça te changera les idées"),
        MsgrMessage(deMoi: true, texte: "Oui promis on se fait ça 😊", vu: true),
    ]

    static let convFilles: [MsgrMessage] = [
        MsgrMessage(deMoi: false, separateur: "12 AOÛT À 14:12"),
        MsgrMessage(deMoi: false, auteur: "Inès", texte: "Les filles, soirée chez moi vendredi ? 🥂"),
        MsgrMessage(deMoi: false, auteur: "Chloé Berthier", texte: "Ouiii carrément !"),
        MsgrMessage(deMoi: true, texte: "Je peux venir un peu plus tard ? J'ai un truc avant"),
        MsgrMessage(deMoi: false, auteur: "Inès", texte: "Pas de souci ! On dit 20h30 chez moi alors !", reaction: "👍"),
    ]

    static func messages(_ id: String) -> [MsgrMessage] {
        id == "filles" ? convFilles : convChloe
    }

    static let membresFilles: [(String, String)] = [
        ("Sarah Levasseur", "Créatrice du groupe"),
        ("Chloé Berthier", "Ajoutée par Sarah Levasseur"),
        ("Inès Djellal", "Ajoutée par Sarah Levasseur"),
        ("Léa Moreau", "Ajoutée par Chloé Berthier"),
        ("Camille Roussel", "Ajoutée par Inès Djellal"),
    ]

    static let suggestions: [(String, String)] = [
        ("Marc Delorme", "Suivi(e) par 2 personnes"),
        ("Vincent Berthier", "Suivi(e) par Chloé Berthier"),
        ("Atelier Poterie Lyon 3", "Suivi(e) par 41 personnes"),
    ]

    static let mediasFilles = ["p22", "p23", "p24", "p25", "p26", "p27"]
}

let msgrBleu: UInt = 0x0084FF

// Avatar réutilisable (photo pellicule ou initiale colorée)
struct MsgrAvatar: View {
    let conv: MsgrConversation
    var taille: CGFloat = 52
    var body: some View {
        Group {
            if let cle = conv.photo, let img = ChargeurPhoto.image(cle) {
                Image(uiImage: img).resizable().scaledToFill()
                    .frame(width: taille, height: taille).clipShape(Circle())
            } else {
                Circle().fill(Color(hex: conv.teinte)).frame(width: taille, height: taille)
                    .overlay(Text(String(conv.nom.prefix(1))).font(.system(size: taille * 0.42, weight: .semibold)).foregroundStyle(.white))
            }
        }
    }
}

// ============================================================ APP (4 onglets)
struct MessengerVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            Group {
                switch onglet {
                case 1: MsgrStoriesVue()
                case 2: MsgrNotificationsVue()
                case 3: MsgrMenuVue()
                default: MsgrDiscussionsVue()
                }
            }

            // Barre d'onglets (référence : 4 items, badge rouge sur Menu)
            HStack {
                MsgrOngletItem(symbole: "bubble.left.and.bubble.right.fill", titre: "Discussions", actif: onglet == 0) { onglet = 0 }
                MsgrOngletItem(symbole: "rectangle.stack.person.crop.fill", titre: "Stories", actif: onglet == 1) { onglet = 1 }
                MsgrOngletItem(symbole: "bell.fill", titre: "Notifications", actif: onglet == 2) { onglet = 2 }
                MsgrOngletItem(symbole: "line.3.horizontal", titre: "Menu", actif: onglet == 3, badge: "2") { onglet = 3 }
            }
            .padding(.top, 8).padding(.bottom, 26)
            .background(Color(hex: 0x111111).opacity(0.98))
            .overlay(Rectangle().fill(Color(hex: 0x2C2C2E)).frame(height: 0.5), alignment: .top)

            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
    }
}

struct MsgrOngletItem: View {
    let symbole: String
    let titre: String
    let actif: Bool
    var badge: String? = nil
    let action: () -> Void
    var body: some View {
        VStack(spacing: 3) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: symbole).font(.system(size: 20))
                if let b = badge {
                    Text(b).font(.system(size: 10, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 5).padding(.vertical, 1)
                        .background(Color(hex: 0xFF3B30), in: Capsule())
                        .offset(x: 10, y: -6)
                }
            }
            Text(titre).font(.system(size: 10))
        }
        .foregroundStyle(actif ? Color(hex: msgrBleu) : .secondary)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// ============================================================ DISCUSSIONS
struct MsgrDiscussionsVue: View {
    @State private var conv: MsgrConversation? = nil
    @State private var nouveau = false
    @State private var recherche = ""
    @FocusState private var champActif: Bool

    private var visibles: [MsgrConversation] {
        recherche.isEmpty ? DonneesMessenger.conversations
        : DonneesMessenger.conversations.filter { $0.nom.lowercased().contains(recherche.lowercased()) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("messenger").font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "square.and.pencil").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                        .contentShape(Rectangle())
                        .onTapGesture { nouveau = true }
                    ZStack(alignment: .topTrailing) {
                        Circle().fill(Color(hex: 0x1C1C1E)).frame(width: 32, height: 32)
                            .overlay(Text("f").font(.system(size: 18, weight: .bold)).foregroundStyle(Color(hex: msgrBleu)))
                        Text("8").font(.system(size: 9, weight: .semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 4).padding(.vertical, 1)
                            .background(Color(hex: 0xFF3B30), in: Capsule())
                            .offset(x: 5, y: -4)
                    }
                }

                // Recherche Meta AI (champ réel — D62)
                HStack(spacing: 8) {
                    Circle().fill(AngularGradient(colors: [Color(hex: 0x0084FF), Color(hex: 0xA033FF), Color(hex: 0xFF5C87), Color(hex: 0x0084FF)], center: .center))
                        .frame(width: 18, height: 18)
                    TextField("Demandez à Meta AI ou faites une recherche", text: $recherche)
                        .font(.system(size: 14.5)).foregroundStyle(.white)
                        .focused($champActif)
                }
                .padding(.horizontal, 12).frame(height: 38)
                .background(Color(hex: 0x1C1C1E), in: Capsule())

                // Rangée notes (référence : Partagez une note + contacts)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 5) {
                            ZStack(alignment: .top) {
                                Group {
                                    if let img = ChargeurPhoto.image("p04") {
                                        Image(uiImage: img).resizable().scaledToFill()
                                            .frame(width: 58, height: 58).clipShape(Circle())
                                    } else {
                                        Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 58, height: 58)
                                    }
                                }
                                Text("Partagez une note…")
                                    .font(.system(size: 9.5)).foregroundStyle(.white)
                                    .padding(.horizontal, 7).padding(.vertical, 4)
                                    .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 10))
                                    .offset(y: -16)
                            }
                            Text("Votre note").font(.system(size: 11)).foregroundStyle(.secondary)
                        }
                        ForEach(DonneesMessenger.conversations.prefix(4)) { c in
                            VStack(spacing: 5) {
                                MsgrAvatar(conv: c, taille: 58)
                                Text(c.nom.components(separatedBy: " ").first ?? c.nom)
                                    .font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(1)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { conv = c }
                        }
                    }
                    .padding(.top, 14)
                }

                // Liste des conversations
                VStack(spacing: 0) {
                    if visibles.isEmpty {
                        Text("Aucun résultat pour « \(recherche) »")
                            .font(.system(size: 14)).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity).padding(.top, 40)
                    }
                    ForEach(visibles) { c in
                        HStack(spacing: 12) {
                            MsgrAvatar(conv: c)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(c.nom).font(.system(size: 15.5, weight: c.nonLu ? .semibold : .regular)).foregroundStyle(.white)
                                Text(c.apercu).font(.system(size: 13.5))
                                    .foregroundStyle(c.nonLu ? .white : .secondary).lineLimit(1)
                            }
                            Spacer()
                            if c.nonLu { Circle().fill(Color(hex: msgrBleu)).frame(width: 9, height: 9) }
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture { conv = c }
                    }
                }
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16).padding(.top, 6)
        }
        .fullScreenCover(isPresented: Binding(get: { conv != nil }, set: { if !$0 { conv = nil } })) {
            MsgrConversationVue(conv: conv ?? DonneesMessenger.conversations[0])
        }
        .sheet(isPresented: $nouveau) { MsgrNouvelleDiscussionVue() }
    }
}

// ============================================================ CONVERSATION
struct MsgrConversationVue: View {
    @Environment(\.dismiss) private var dismiss
    let conv: MsgrConversation
    @State private var saisie = ""
    @State private var ficheVisible = false
    @State private var appelVisible = false
    @State private var messages: [MsgrMessage] = []
    @State private var envoyes: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            // En-tête
            HStack(spacing: 10) {
                Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundStyle(Color(hex: msgrBleu))
                    .contentShape(Rectangle())
                    .onTapGesture { dismiss() }
                MsgrAvatar(conv: conv, taille: 36)
                VStack(alignment: .leading, spacing: 0) {
                    Text(conv.nom).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                    if conv.groupe {
                        Text("\(DonneesMessenger.membresFilles.count) membres").font(.system(size: 11.5)).foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { ficheVisible = true }
                Spacer()
                Image(systemName: "phone.fill").font(.system(size: 19)).foregroundStyle(Color(hex: msgrBleu))
                    .contentShape(Rectangle())
                    .onTapGesture { appelVisible = true }
                Image(systemName: "video.fill").font(.system(size: 19)).foregroundStyle(Color(hex: msgrBleu))
                    .contentShape(Rectangle())
                    .onTapGesture { appelVisible = true }
            }
            .padding(.horizontal, 14).padding(.vertical, 8)

            // Fil
            ScrollViewReader { lecteur in
                ScrollView {
                    VStack(spacing: 3) {
                        ForEach(messages) { m in
                            MsgrBulle(message: m, conv: conv)
                        }
                        ForEach(Array(envoyes.enumerated()), id: \.offset) { _, t in
                            MsgrBulle(message: MsgrMessage(deMoi: true, texte: t), conv: conv)
                        }
                        Color.clear.frame(height: 1).id("fin")
                    }
                    .padding(.horizontal, 12).padding(.top, 6)
                }
                .onAppear {
                    messages = DonneesMessenger.messages(conv.id)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { lecteur.scrollTo("fin") }
                }
                .onChange(of: envoyes.count) { _ in lecteur.scrollTo("fin") }
            }

            // Composeur (référence : + appareil photo galerie micro, Aa, pouce bleu)
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill").font(.system(size: 24)).foregroundStyle(Color(hex: msgrBleu))
                Image(systemName: "camera.fill").font(.system(size: 20)).foregroundStyle(Color(hex: msgrBleu))
                Image(systemName: "photo").font(.system(size: 20)).foregroundStyle(Color(hex: msgrBleu))
                Image(systemName: "mic.fill").font(.system(size: 20)).foregroundStyle(Color(hex: msgrBleu))
                TextField("Aa", text: $saisie)
                    .font(.system(size: 15)).foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Color(hex: 0x1C1C1E), in: Capsule())
                if saisie.isEmpty {
                    Image(systemName: "hand.thumbsup.fill").font(.system(size: 22)).foregroundStyle(Color(hex: msgrBleu))
                } else {
                    Image(systemName: "paperplane.fill").font(.system(size: 20)).foregroundStyle(Color(hex: msgrBleu))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // D54 : message libre du joueur, non-distribution discrète
                            envoyes.append(saisie); saisie = ""
                        }
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)

            BarreHome { dismiss() }
        }
        .background(Color.black)
        .sheet(isPresented: $ficheVisible) { MsgrFicheVue(conv: conv) }
        .fullScreenCover(isPresented: $appelVisible) { MsgrAppelVue(conv: conv) }
        .preferredColorScheme(.dark)
    }
}

// Bulle (bleu 0084FF à droite, 26262B à gauche, réactions, appels, vu)
struct MsgrBulle: View {
    let message: MsgrMessage
    let conv: MsgrConversation

    var body: some View {
        if let sep = message.separateur {
            Text(sep).font(.system(size: 11, weight: .medium)).foregroundStyle(.secondary)
                .padding(.vertical, 10)
        }
        if let appel = message.appel {
            HStack {
                if message.deMoi { Spacer() }
                HStack(spacing: 10) {
                    Circle().fill(appel.manque ? Color(hex: 0xFF3B30) : Color(hex: 0x2C2C2E))
                        .frame(width: 34, height: 34)
                        .overlay(Image(systemName: appel.manque ? "phone.down.fill" : "phone.fill")
                            .font(.system(size: 15)).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(appel.manque ? "Appel vocal manqué" : "Appel vocal")
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                        Text(appel.manque ? "Rappeler" : appel.duree)
                            .font(.system(size: 12.5)).foregroundStyle(Color(hex: msgrBleu))
                    }
                }
                .padding(12)
                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 16))
                if !message.deMoi { Spacer() }
            }
            .padding(.vertical, 3)
        }
        if let texte = message.texte {
            VStack(alignment: message.deMoi ? .trailing : .leading, spacing: 2) {
                if let auteur = message.auteur {
                    Text(auteur).font(.system(size: 11)).foregroundStyle(.secondary).padding(.leading, 44)
                }
                HStack(alignment: .bottom, spacing: 8) {
                    if message.deMoi { Spacer(minLength: 60) }
                    if !message.deMoi && conv.groupe {
                        Circle().fill(Color(hex: 0x3A3A3C)).frame(width: 28, height: 28)
                            .overlay(Text(String((message.auteur ?? conv.nom).prefix(1)))
                                .font(.system(size: 12, weight: .semibold)).foregroundStyle(.white))
                    }
                    ZStack(alignment: message.deMoi ? .bottomLeading : .bottomTrailing) {
                        Text(texte)
                            .font(.system(size: 15.5)).foregroundStyle(.white)
                            .padding(.horizontal, 13).padding(.vertical, 8)
                            .background(message.deMoi ? Color(hex: msgrBleu) : Color(hex: 0x26262B),
                                        in: RoundedRectangle(cornerRadius: 19))
                        if let r = message.reaction {
                            Text(r).font(.system(size: 12))
                                .padding(4)
                                .background(Color(hex: 0x1C1C1E), in: Circle())
                                .offset(x: message.deMoi ? -6 : 6, y: 12)
                        }
                    }
                    if !message.deMoi { Spacer(minLength: 60) }
                }
                if message.vu {
                    MsgrAvatar(conv: conv, taille: 14).padding(.trailing, 2)
                }
            }
            .padding(.bottom, message.reaction != nil ? 12 : 0)
        }
    }
}

// ============================================================ APPEL (vocal simple, raccrocher réel)
struct MsgrAppelVue: View {
    @Environment(\.dismiss) private var dismiss
    let conv: MsgrConversation
    @State private var secondes = 0
    private let minuteur = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x1B2735), Color(hex: 0x090A0F)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                Spacer()
                MsgrAvatar(conv: conv, taille: 110)
                Text(conv.nom).font(.system(size: 26, weight: .semibold)).foregroundStyle(.white)
                Text(secondes < 3 ? "Appel en cours…" : String(format: "%d:%02d", secondes / 60, secondes % 60))
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.7))
                Spacer()
                HStack(spacing: 40) {
                    RondVerre(symbole: "mic.slash.fill")
                    RondVerre(symbole: "speaker.wave.2.fill")
                    Circle().fill(Color(hex: 0xFF3B30)).frame(width: 62, height: 62)
                        .overlay(Image(systemName: "phone.down.fill").font(.system(size: 24)).foregroundStyle(.white))
                        .contentShape(Circle())
                        .onTapGesture { dismiss() }
                }
                .padding(.bottom, 60)
            }
        }
        .onReceive(minuteur) { _ in secondes += 1 }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ FICHE DISCUSSION
struct MsgrFicheVue: View {
    @Environment(\.dismiss) private var dismiss
    let conv: MsgrConversation
    @State private var sourdine = false
    @State private var confirmations = true
    @State private var indicateur = true
    @State private var membresVisibles = false
    @State private var mediasVisibles = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    MsgrAvatar(conv: conv, taille: 88).padding(.top, 8)
                    VStack(spacing: 3) {
                        Text(conv.nom).font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                        Text("Modifier le nom ou l'image").font(.system(size: 13)).foregroundStyle(Color(hex: msgrBleu))
                    }
                    HStack(spacing: 26) {
                        MsgrActionRonde(symbole: "person.badge.plus", titre: "Ajouter")
                        MsgrActionRonde(symbole: "textformat", titre: "Pseudos")
                        MsgrActionRonde(symbole: "magnifyingglass", titre: "Rechercher")
                        MsgrActionRonde(symbole: "paintpalette", titre: "Personnaliser")
                    }

                    MsgrSection(titre: "Informations sur la discussion") {
                        MsgrLigne(symbole: "photo.on.rectangle", titre: "Contenus multimédias, liens et fichiers") { mediasVisibles = true }
                        if conv.groupe {
                            MsgrLigne(symbole: "person.2", titre: "Voir les membres de la discussion") { membresVisibles = true }
                        }
                    }

                    MsgrSection(titre: "Actions") {
                        HStack {
                            Image(systemName: "bell.slash").font(.system(size: 16)).foregroundStyle(.white).frame(width: 28)
                            Text("Mettre \(conv.nom) en sourdine").font(.system(size: 15)).foregroundStyle(.white).lineLimit(1)
                            Spacer()
                            Toggle("", isOn: $sourdine).labelsHidden().tint(Color(hex: msgrBleu))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        MsgrLigne(symbole: "speaker.wave.2", titre: "Sons et notifications") {}
                        MsgrLigne(symbole: "person.3", titre: "Créer une nouvelle discussion de groupe") {}
                    }

                    MsgrSection(titre: "Confidentialité et assistance") {
                        HStack {
                            Image(systemName: "checkmark.circle").font(.system(size: 16)).foregroundStyle(.white).frame(width: 28)
                            Text("Confirmations de lecture").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: $confirmations).labelsHidden().tint(Color(hex: msgrBleu))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        HStack {
                            Image(systemName: "ellipsis.bubble").font(.system(size: 16)).foregroundStyle(.white).frame(width: 28)
                            Text("Indicateur de saisie").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: $indicateur).labelsHidden().tint(Color(hex: msgrBleu))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        MsgrLigne(symbole: "hand.raised", titre: "Restreindre") {}
                        MsgrLigne(symbole: "exclamationmark.triangle", titre: "Signaler", teinte: 0xFF3B30) {}
                        if conv.groupe {
                            MsgrLigne(symbole: "rectangle.portrait.and.arrow.right", titre: "Quitter la discussion", teinte: 0xFF3B30) {}
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: msgrBleu))
                }
            }
            .sheet(isPresented: $membresVisibles) { MsgrMembresVue() }
            .sheet(isPresented: $mediasVisibles) { MsgrMediasVue(conv: conv) }
        }
        .preferredColorScheme(.dark)
    }
}

struct MsgrActionRonde: View {
    let symbole: String
    let titre: String
    var body: some View {
        VStack(spacing: 6) {
            Circle().fill(Color(hex: 0x1C1C1E)).frame(width: 44, height: 44)
                .overlay(Image(systemName: symbole).font(.system(size: 17)).foregroundStyle(.white))
            Text(titre).font(.system(size: 11)).foregroundStyle(.secondary)
        }
    }
}

struct MsgrSection<Contenu: View>: View {
    let titre: String
    @ViewBuilder let contenu: Contenu
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titre).font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 0) { contenu }
                .background(Color(hex: 0x141414), in: RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct MsgrLigne: View {
    let symbole: String
    let titre: String
    var teinte: UInt = 0xFFFFFF
    let action: () -> Void
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: symbole).font(.system(size: 16)).foregroundStyle(Color(hex: teinte)).frame(width: 28)
            Text(titre).font(.system(size: 15)).foregroundStyle(Color(hex: teinte))
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// ============================================================ MEMBRES
struct MsgrMembresVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ongletAdmins = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 0) {
                        Text("Tous").font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(ongletAdmins ? .secondary : .white)
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                            .overlay(Rectangle().fill(ongletAdmins ? .clear : Color(hex: msgrBleu)).frame(height: 2), alignment: .bottom)
                            .contentShape(Rectangle())
                            .onTapGesture { ongletAdmins = false }
                        Text("Admins").font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(ongletAdmins ? .white : .secondary)
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                            .overlay(Rectangle().fill(ongletAdmins ? Color(hex: msgrBleu) : .clear).frame(height: 2), alignment: .bottom)
                            .contentShape(Rectangle())
                            .onTapGesture { ongletAdmins = true }
                    }
                    VStack(spacing: 0) {
                        ForEach(Array((ongletAdmins ? Array(DonneesMessenger.membresFilles.prefix(1)) : DonneesMessenger.membresFilles).enumerated()), id: \.offset) { _, m in
                            HStack(spacing: 12) {
                                Circle().fill(Color(hex: 0x3A3A3C)).frame(width: 44, height: 44)
                                    .overlay(Text(String(m.0.prefix(1))).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(m.0).font(.system(size: 15)).foregroundStyle(.white)
                                    Text(m.1).font(.system(size: 12.5)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "ellipsis").font(.system(size: 15)).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Membres · \(DonneesMessenger.membresFilles.count) personnes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: msgrBleu))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ CONTENUS MULTIMÉDIAS
struct MsgrMediasVue: View {
    @Environment(\.dismiss) private var dismiss
    let conv: MsgrConversation
    @State private var onglet = 1   // Partagé par / Photos / Vidéos

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        ForEach(Array(["Partagé par", "Photos", "Vidéos"].enumerated()), id: \.offset) { i, t in
                            Text(t).font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(onglet == i ? .black : .white)
                                .padding(.horizontal, 13).padding(.vertical, 7)
                                .background(onglet == i ? Color.white : Color(hex: 0x1C1C1E), in: Capsule())
                                .contentShape(Capsule())
                                .onTapGesture { onglet = i }
                        }
                    }
                    if conv.groupe && onglet != 2 {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                            ForEach(Array(DonneesMessenger.mediasFilles.enumerated()), id: \.offset) { _, cle in
                                Group {
                                    if let img = ChargeurPhoto.image(cle) {
                                        Image(uiImage: img).resizable().scaledToFill()
                                    } else {
                                        Rectangle().fill(Color(hex: 0x2C2C2E))
                                    }
                                }
                                .frame(height: 120).clipped()
                            }
                        }
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle").font(.system(size: 38)).foregroundStyle(.secondary)
                            Text("Aucun contenu multimédia").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            Text("Réinitialisez ou ajustez vos filtres pour voir plus de résultats")
                                .font(.system(size: 12.5)).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity).padding(.top, 70)
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Contenu multimédia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: msgrBleu))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ STORIES
struct MsgrStoriesVue: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Stories").font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                ZStack(alignment: .bottomLeading) {
                    Group {
                        if let img = ChargeurPhoto.image("p04") {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else {
                            Rectangle().fill(Color(hex: 0x2C2C2E))
                        }
                    }
                    .frame(width: 150, height: 220).clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    VStack(alignment: .leading, spacing: 6) {
                        Circle().fill(Color(hex: msgrBleu)).frame(width: 34, height: 34)
                            .overlay(Image(systemName: "plus").font(.system(size: 16, weight: .bold)).foregroundStyle(.white))
                        Text("Ajouter à la story").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                    }
                    .padding(10)
                }
                Spacer(minLength: 100)
            }
            .padding(16)
        }
    }
}

// ============================================================ NOTIFICATIONS
struct MsgrNotificationsVue: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Notifications").font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                VStack(spacing: 6) {
                    Text("Aucune notification").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    Text("Si vous avez des notifications, elles apparaîtront ici.")
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 30)

                HStack {
                    Text("Vous connaissez peut-être").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    Image(systemName: "questionmark.circle").font(.system(size: 13)).foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "ellipsis").font(.system(size: 15)).foregroundStyle(.secondary)
                }
                VStack(spacing: 0) {
                    ForEach(Array(DonneesMessenger.suggestions.enumerated()), id: \.offset) { _, s in
                        HStack(spacing: 12) {
                            Circle().fill(Color(hex: 0x3A3A3C)).frame(width: 52, height: 52)
                                .overlay(Text(String(s.0.prefix(1))).font(.system(size: 19, weight: .semibold)).foregroundStyle(.white))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.0).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                                Text(s.1).font(.system(size: 12.5)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("Ajouter comme ami(e)")
                                .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(Color(hex: msgrBleu), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.vertical, 8)
                    }
                }
                Spacer(minLength: 100)
            }
            .padding(16)
        }
    }
}

// ============================================================ MENU + PARAMÈTRES + INVITATIONS + ARCHIVE
struct MsgrMenuVue: View {
    @State private var parametres = false
    @State private var invitations = false
    @State private var archive = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Menu").font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "square.grid.2x2").font(.system(size: 18)).foregroundStyle(.white)
                }
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Group {
                            if let img = ChargeurPhoto.image("p04") {
                                Image(uiImage: img).resizable().scaledToFill()
                                    .frame(width: 44, height: 44).clipShape(Circle())
                            } else {
                                Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 44, height: 44)
                            }
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Sarah Levasseur").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            Text("Changer de profil").font(.system(size: 12.5)).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                    MsgrLigne(symbole: "gearshape", titre: "Paramètres") { parametres = true }
                }
                .background(Color(hex: 0x141414), in: RoundedRectangle(cornerRadius: 14))

                VStack(spacing: 0) {
                    MsgrLigne(symbole: "person.3", titre: "Communautés") {}
                    MsgrLigne(symbole: "envelope.open", titre: "Invitations par message") { invitations = true }
                    MsgrLigne(symbole: "archivebox", titre: "Archive") { archive = true }
                }
                .background(Color(hex: 0x141414), in: RoundedRectangle(cornerRadius: 14))

                Text("Aussi de Meta").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary)
                VStack(spacing: 0) {
                    MsgrLigne(symbole: "play.rectangle", titre: "Facebook Reels") {}
                    MsgrLigne(symbole: "calendar", titre: "Événements Facebook") {}
                    MsgrLigne(symbole: "heart", titre: "Facebook Rencontres") {}
                }
                .background(Color(hex: 0x141414), in: RoundedRectangle(cornerRadius: 14))
                Spacer(minLength: 100)
            }
            .padding(16)
        }
        .sheet(isPresented: $parametres) { MsgrParametresVue() }
        .sheet(isPresented: $invitations) { MsgrInvitationsVue() }
        .sheet(isPresented: $archive) { MsgrArchiveVue() }
    }
}

struct MsgrParametresVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var statutEnLigne = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Group {
                        if let img = ChargeurPhoto.image("p04") {
                            Image(uiImage: img).resizable().scaledToFill()
                                .frame(width: 84, height: 84).clipShape(Circle())
                        } else {
                            Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 84, height: 84)
                        }
                    }
                    .padding(.top, 8)
                    Text("Sarah Levasseur").font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)

                    MsgrSection(titre: "Votre compte · ∞ Meta") {
                        MsgrLigne(symbole: "person.crop.circle", titre: "Espace Comptes") {}
                    }
                    MsgrSection(titre: "Préférences") {
                        HStack {
                            Image(systemName: "circle.fill").font(.system(size: 12)).foregroundStyle(Color(hex: 0x30D158)).frame(width: 28)
                            Text("Statut En ligne").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: $statutEnLigne).labelsHidden().tint(Color(hex: msgrBleu))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        HStack {
                            Image(systemName: "moon").font(.system(size: 16)).foregroundStyle(.white).frame(width: 28)
                            Text("Mode sombre").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Text("Système").font(.system(size: 14)).foregroundStyle(.secondary)
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        MsgrLigne(symbole: "figure.wave", titre: "Accessibilité") {}
                        MsgrLigne(symbole: "lock.shield", titre: "Confidentialité et sécurité") {}
                        MsgrLigne(symbole: "bell", titre: "Notifications et sons") {}
                        MsgrLigne(symbole: "photo", titre: "Photos et contenu multimédia") {}
                    }
                    MsgrSection(titre: "Assistance") {
                        MsgrLigne(symbole: "exclamationmark.bubble", titre: "Signaler un problème") {}
                        MsgrLigne(symbole: "questionmark.circle", titre: "Aide") {}
                        MsgrLigne(symbole: "doc.text", titre: "Mentions légales et politiques") {}
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: msgrBleu))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MsgrInvitationsVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ongletSpam = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HStack(spacing: 0) {
                    Text("VOUS CONNAISSEZ PEUT-ÊTRE").font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ongletSpam ? .secondary : .white)
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .overlay(Rectangle().fill(ongletSpam ? .clear : Color(hex: msgrBleu)).frame(height: 2), alignment: .bottom)
                        .contentShape(Rectangle())
                        .onTapGesture { ongletSpam = false }
                    Text("SPAM").font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ongletSpam ? .white : .secondary)
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                        .overlay(Rectangle().fill(ongletSpam ? Color(hex: msgrBleu) : .clear).frame(height: 2), alignment: .bottom)
                        .contentShape(Rectangle())
                        .onTapGesture { ongletSpam = true }
                }
                Text("Ouvrez une discussion pour en savoir plus sur la personne qui vous envoie un message. Elle ne saura pas que vous l'avez vue tant que vous n'aurez pas répondu.")
                    .font(.system(size: 12.5)).foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                Spacer()
                VStack(spacing: 4) {
                    Text("Aucun message").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    Text("Les nouveaux messages apparaîtront ici.").font(.system(size: 13)).foregroundStyle(.secondary)
                }
                Spacer()
                Spacer()
            }
            .padding(.top, 8)
            .background(Color.black)
            .navigationTitle("Invitations par message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: msgrBleu))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MsgrArchiveVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 52, height: 52)
                            .overlay(Text("I").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Idée cadeau papa").font(.system(size: 15.5)).foregroundStyle(.white)
                            Text("Vous avez quitté le groupe. · 2 mai").font(.system(size: 13.5)).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                }
            }
            .background(Color.black)
            .navigationTitle("Archive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: msgrBleu))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ NOUVELLE DISCUSSION
struct MsgrNouvelleDiscussionVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var destinataire = ""
    @State private var convOuverte: MsgrConversation? = nil

    private var suggestions: [MsgrConversation] {
        destinataire.isEmpty ? DonneesMessenger.conversations.filter { !$0.groupe }
        : DonneesMessenger.conversations.filter { !$0.groupe && $0.nom.lowercased().contains(destinataire.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Text("À :").font(.system(size: 15)).foregroundStyle(.secondary)
                    TextField("", text: $destinataire).font(.system(size: 15)).foregroundStyle(.white)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                Divider().overlay(Color(hex: 0x2C2C2E))
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Suggestions").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary)
                            .padding(.horizontal, 16).padding(.vertical, 10)
                        ForEach(suggestions) { c in
                            HStack(spacing: 12) {
                                MsgrAvatar(conv: c, taille: 44)
                                Text(c.nom).font(.system(size: 15)).foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .onTapGesture { convOuverte = c }
                        }
                    }
                }
            }
            .background(Color.black)
            .navigationTitle("Nouveau message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }.foregroundStyle(Color(hex: msgrBleu))
                }
            }
            .fullScreenCover(isPresented: Binding(get: { convOuverte != nil }, set: { if !$0 { convOuverte = nil } })) {
                MsgrConversationVue(conv: convOuverte ?? DonneesMessenger.conversations[0])
            }
        }
        .preferredColorScheme(.dark)
    }
}
