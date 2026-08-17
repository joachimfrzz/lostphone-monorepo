// App MESSAGES iOS 26 — construite contre refs-messages/ (vidéo réelle du 17/08, 112 frames)
// Liste + recherche en bas, filtres (Messages / Indésirables / Suppressions), conversations
// iMessage bleues et SMS-RCS vertes, expéditeur inconnu avec bandeau de signalement,
// fiche contact (Infos / Photos / Documents), menu +, suppressions récupérables.
// Règles D51-D55 : tout répond, messages du joueur persistants sans distribution (D54).
import SwiftUI

// Couleurs mesurées sur les frames de la vidéo
let msgFond = Color(hex: 0x000000)
let msgBleu = Color(hex: 0x178BFC)
let msgVert = Color(hex: 0x32DE52)
let msgRecu = Color(hex: 0x1C1B20)
let msgChamp = Color(hex: 0x1C1C1E)
let msgTexte = Color(hex: 0xF2F2F2)
let msgTexte2 = Color(hex: 0x8E8E93)
let msgAvatar = Color(hex: 0x48475C)

// ============================================================ DONNÉES (Coches bleues)
enum ElementMsg {
    case sep(String)                       // "jeu. 6 août à 21:32"
    case recu(String)
    case envoye(String, tag: String?)      // tag : "Distribué", "Lu le 31/07/2026", nil
    case document(String, String, Bool)    // nom, taille, reçu ?
    case systeme(String)                   // notes système centrées
}

struct ConvMsg: Identifiable {
    var id: String { nom }
    let nom: String
    let numero: String
    let service: String        // "iMessage" / "Message texte · SMS" / "Message texte · RCS"
    let bleu: Bool
    let inconnu: Bool          // expéditeur inconnu → bandeau signalement
    let apercu: String
    let date: String
    let elements: [ElementMsg]
}

struct ConvSupprimee: Identifiable {
    var id: String { conv.nom }
    let jours: String
    let nbMessages: String
    let conv: ConvMsg
}

enum DonneesMsg {
    static let convs: [ConvMsg] = [
        ConvMsg(nom: "Chloé", numero: "+33 6 24 81 05 77", service: "iMessage", bleu: true, inconnu: false,
                apercu: "Rappelle-moi quand tu vois mes messages, s'il te plaît 🙏", date: "19:41",
                elements: [
                    .sep("mardi à 12:04"),
                    .recu("Coucou ma belle, on se fait un ciné jeudi ? Le nouveau film avec Léa Seydoux a l'air top"),
                    .envoye("Je peux pas jeudi, j'ai plein de choses à régler en ce moment", tag: nil),
                    .recu("Encore ? Tu me caches des trucs toi 😅"),
                    .sep("hier à 18:22"),
                    .recu("Sarah je viens de voir ton statut WhatsApp… on peut parler ?"),
                    .recu("Je dis pas ça pour t'embêter. C'est juste que ce Marc, personne l'a jamais vu, même pas en visio correcte"),
                    .envoye("Tu te trompes complètement sur lui. Il m'a jamais rien demandé", tag: "Lu hier"),
                    .recu("Et le virement dont tu m'as parlé alors ?"),
                    .sep("aujourd'hui à 19:33"),
                    .recu("Je viens d'essayer de t'appeler deux fois"),
                    .recu("Rappelle-moi quand tu vois mes messages, s'il te plaît 🙏"),
                ]),
        ConvMsg(nom: "Maman", numero: "+33 6 88 41 27 30", service: "Message texte · SMS", bleu: false, inconnu: false,
                apercu: "Je te rappelle dans 5 minutes", date: "jeudi",
                elements: [
                    .sep("dim. 9 août à 10:12"),
                    .recu("Coucou ma chérie, tu viens toujours dimanche prochain ? Ton père veut faire un rôti"),
                    .envoye("Oui bien sûr maman, j'apporte le dessert 😊", tag: "Distribué"),
                    .recu("Parfait ! Et ramène-moi mon tupperware, le bleu 😄"),
                    .sep("jeudi à 17:45"),
                    .recu("Ma chérie j'ai essayé de t'appeler, tu vas bien ? Tu as l'air distante en ce moment"),
                    .recu("Je te rappelle dans 5 minutes"),
                ]),
        ConvMsg(nom: "Agence Bellecour", numero: "04 72 40 18 62", service: "Message texte · RCS", bleu: false, inconnu: false,
                apercu: "Bonjour Madame Levasseur, votre rendez-vous de lundi à 11h30 est confirmé…", date: "mercredi",
                elements: [
                    .sep("mercredi à 09:31"),
                    .recu("Bonjour Madame Levasseur, votre rendez-vous de lundi à 11h30 avec M. Garnier est confirmé. Objet : demande de virement international. Merci de vous munir d'une pièce d'identité et du RIB du bénéficiaire. Agence LCL Bellecour."),
                    .envoye("Bonjour, c'est bien noté. À lundi", tag: "Distribué"),
                ]),
        ConvMsg(nom: "62244", numero: "62244", service: "Message texte · SMS", bleu: false, inconnu: false,
                apercu: "Votre code de sécurité est 483920. Ne le communiquez à personne.", date: "mercredi",
                elements: [
                    .sep("lun. 3 août à 15:07"),
                    .recu("Votre code de sécurité est 174205. Ne le communiquez à personne, y compris un conseiller bancaire."),
                    .sep("mercredi à 09:47"),
                    .recu("Votre code de sécurité est 483920. Ne le communiquez à personne, y compris un conseiller bancaire."),
                ]),
        ConvMsg(nom: "Marie kiné", numero: "+33 6 02 55 18 64", service: "Message texte · SMS", bleu: false, inconnu: false,
                apercu: "Rappel : séance de kinésithérapie mardi à 14h00. En cas d'empêchement…", date: "mardi",
                elements: [
                    .sep("mardi à 08:00"),
                    .recu("Rappel : séance de kinésithérapie mardi à 14h00. En cas d'empêchement, merci de prévenir 24h à l'avance."),
                    .envoye("Bien reçu, à mardi !", tag: "Distribué"),
                ]),
        ConvMsg(nom: "Thomas", numero: "+33 6 51 33 90 12", service: "iMessage", bleu: true, inconnu: false,
                apercu: "Grosse rando samedi si tu veux te changer les idées 🏔️", date: "sam.",
                elements: [
                    .sep("sam. 8 août à 11:20"),
                    .recu("Salut Sarah ! T'as reçu mes photos du lac sur WhatsApp ?"),
                    .envoye("Oui elles sont magnifiques 😍", tag: "Distribué"),
                    .recu("Grosse rando samedi si tu veux te changer les idées 🏔️"),
                ]),
        ConvMsg(nom: "Chronopost", numero: "38044", service: "Message texte · SMS", bleu: false, inconnu: false,
                apercu: "Votre colis XY293847561FR sera livré demain entre 9h et 12h.", date: "07/08/2026",
                elements: [
                    .sep("ven. 7 août à 08:15"),
                    .recu("Chronopost : votre colis XY293847561FR sera livré demain entre 9h et 12h. Suivi : chrono.fr/s"),
                ]),
        ConvMsg(nom: "+33 7 49 12 53 08", numero: "+33 7 49 12 53 08", service: "Message texte · RCS", bleu: false, inconnu: true,
                apercu: "Bonjour Sarah 🌹 C'est Marc, du forum de photographie. J'ai beaucoup aimé…", date: "12/03/2026",
                elements: [
                    .sep("jeu. 12 mars à 21:47"),
                    .recu("Bonjour Sarah 🌹 C'est Marc, du forum de photographie. J'ai beaucoup aimé nos échanges sur les couchers de soleil. Je suis officier sur un navire de commerce, la connexion est mauvaise ici. On pourrait continuer sur WhatsApp ?"),
                    .envoye("Ah bonjour Marc ! Oui bien sûr, avec plaisir 😊", tag: "Distribué"),
                    .recu("Merci Sarah. Vous avez un très beau prénom. À tout de suite là-bas 🌹"),
                ]),
        ConvMsg(nom: "Messagerie", numero: "666", service: "Message texte · SMS", bleu: false, inconnu: false,
                apercu: "Messagerie « 666 » Free : le 08/08 à 19:33, ce correspondant a appelé…", date: "08/08/2026",
                elements: [
                    .sep("sam. 8 août à 19:34"),
                    .recu("Messagerie « 666 » Free : le 08/08 à 19:33, ce correspondant (+33 6 24 81 05 77) a appelé 2 fois sur votre mobile sans laisser de message."),
                ]),
    ]

    // Conversations supprimées par Sarah — récupérables (or narratif)
    static let supprimees: [ConvSupprimee] = [
        ConvSupprimee(jours: "12 jours", nbMessages: "2 messages",
            conv: ConvMsg(nom: "SécuriBQE", numero: "38007", service: "Message texte · SMS", bleu: false, inconnu: false,
                apercu: "ALERTE LCL : un virement international de 4 850 € est en attente…", date: "05/08/2026",
                elements: [
                    .sep("mer. 5 août à 10:02"),
                    .recu("ALERTE LCL : une demande de virement international de 4 850 € vers un compte hors zone SEPA est en attente de validation. Si vous n'êtes pas à l'origine de cette opération, contactez immédiatement votre agence."),
                    .sep("mer. 5 août à 16:40"),
                    .recu("LCL : votre conseiller M. Garnier souhaite s'entretenir avec vous avant toute validation. Merci de rappeler l'agence Bellecour au 04 72 40 18 62."),
                ])),
        ConvSupprimee(jours: "13 jours", nbMessages: "3 messages",
            conv: ConvMsg(nom: "UPSPkgInfo", numero: "36047", service: "Message texte · SMS", bleu: false, inconnu: false,
                apercu: "UPS : votre colis 1Z2847X0392 a été livré.", date: "04/08/2026",
                elements: [
                    .sep("lun. 3 août à 09:10"),
                    .recu("UPS : votre colis 1Z2847X0392 est en cours d'acheminement."),
                    .recu("UPS : votre colis 1Z2847X0392 sera livré aujourd'hui."),
                    .sep("mar. 4 août à 14:22"),
                    .recu("UPS : votre colis 1Z2847X0392 a été livré."),
                ])),
        ConvSupprimee(jours: "5 jours", nbMessages: "1 message",
            conv: ConvMsg(nom: "Nirio", numero: "36180", service: "Message texte · SMS", bleu: false, inconnu: false,
                apercu: "Votre facture du mois d'août est disponible dans votre espace client.", date: "12/08/2026",
                elements: [
                    .sep("mer. 12 août à 07:58"),
                    .recu("Nirio : votre facture du mois d'août est disponible dans votre espace client."),
                ])),
    ]
}

// ============================================================ MAGASINS (messages du joueur + récupérations)
final class EnvoisMsg: ObservableObject {
    static let partage = EnvoisMsg()
    @Published var parConv: [String: [String]] = [:]   // nom → textes envoyés par le joueur
    func envoyer(_ texte: String, a nom: String) {
        parConv[nom, default: []].append(texte)
    }
}

final class MagasinMsg: ObservableObject {
    static let partage = MagasinMsg()
    @Published var supprimees: [ConvSupprimee] = DonneesMsg.supprimees
    @Published var recuperees: [ConvMsg] = []
    @Published var indesirables: [ConvMsg] = []
    @Published var signalees: Set<String> = []

    func toutRecuperer() {
        recuperees.append(contentsOf: supprimees.map { $0.conv })
        supprimees.removeAll()
    }
    func supprimer(_ ids: Set<String>) {
        supprimees.removeAll { ids.contains($0.id) }
    }
    func signaler(_ conv: ConvMsg) {
        signalees.insert(conv.nom)
        indesirables.append(conv)
    }
}

// ============================================================ APP MESSAGES
enum FiltreMsg: String {
    case messages = "Messages"
    case indesirables = "Indésirables"
    case suppressions = "Suppressions"
}

struct MessagesVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinMsg.partage
    @State private var filtre: FiltreMsg = .messages
    @State private var menuFiltres = false
    @State private var menuModifier = false
    @State private var modeSelection = false
    @State private var selection = Set<String>()
    @State private var recherche = ""
    @State private var nouveauMessage = false
    @State private var filtrageVisible = false

    private var convs: [ConvMsg] {
        let toutes = magasin.recuperees + DonneesMsg.convs.filter { !magasin.signalees.contains($0.nom) }
        guard !recherche.isEmpty else { return toutes }
        return toutes.filter {
            $0.nom.localizedCaseInsensitiveContains(recherche)
            || $0.apercu.localizedCaseInsensitiveContains(recherche)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                msgFond.ignoresSafeArea()
                switch filtre {
                case .messages: listePrincipale
                case .indesirables: MsgIndesirablesVue()
                case .suppressions: MsgSuppressionsVue()
                }

                // Barre du haut
                HStack {
                    if filtre == .messages {
                        if modeSelection {
                            Text("Terminé").font(.system(size: 16, weight: .semibold)).foregroundStyle(msgTexte)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(msgChamp, in: Capsule())
                                .onTapGesture { modeSelection = false; selection.removeAll() }
                        } else {
                            Text("Modifier").font(.system(size: 16)).foregroundStyle(msgTexte)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(msgChamp, in: Capsule())
                                .onTapGesture { Haptique.leger(); menuModifier.toggle() }
                        }
                    } else {
                        Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(msgTexte)
                            .padding(10).background(msgChamp, in: Circle())
                            .onTapGesture { filtre = .messages }
                    }
                    Spacer()
                    if filtre != .messages {
                        Text(filtre.rawValue).font(.system(size: 16, weight: .semibold)).foregroundStyle(msgTexte)
                        Spacer()
                    }
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(msgTexte)
                        .padding(10)
                        .background(filtre == .messages ? msgChamp : Color(hex: 0x0A84FF), in: Circle())
                        .onTapGesture { Haptique.leger(); menuFiltres.toggle() }
                }
                .padding(.horizontal, 14).padding(.top, 6)

                // Menu Modifier (déroulant)
                if menuModifier {
                    VStack(alignment: .leading, spacing: 0) {
                        LigneMenuMsg(symbole: "checkmark.circle", texte: "Sélectionner des conversations") {
                            menuModifier = false; modeSelection = true
                        }
                    }
                    .frame(width: 280)
                    .background(Color(hex: 0x2A2A2E), in: RoundedRectangle(cornerRadius: 13))
                    .padding(.top, 52).padding(.leading, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
                }

                // Menu Filtres (déroulant, comme la référence)
                if menuFiltres {
                    VStack(alignment: .leading, spacing: 0) {
                        LigneMenuMsg(symbole: "bubble.left.and.bubble.right", texte: "Messages", coche: filtre == .messages) {
                            filtre = .messages; menuFiltres = false
                        }
                        Divider().overlay(Color.white.opacity(0.12))
                        LigneMenuMsg(symbole: "xmark.bin", texte: "Indésirables", coche: filtre == .indesirables) {
                            filtre = .indesirables; menuFiltres = false
                        }
                        Divider().overlay(Color.white.opacity(0.12))
                        LigneMenuMsg(symbole: "trash", texte: "Suppressions", coche: filtre == .suppressions) {
                            filtre = .suppressions; menuFiltres = false
                        }
                        Divider().overlay(Color.white.opacity(0.3)).padding(.vertical, 2)
                        LigneMenuMsg(symbole: "", texte: "Gérer le filtrage") {
                            menuFiltres = false; filtrageVisible = true
                        }
                    }
                    .frame(width: 250)
                    .background(Color(hex: 0x2A2A2E), in: RoundedRectangle(cornerRadius: 13))
                    .padding(.top, 52).padding(.trailing, 14)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .transition(.opacity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onTapGesture { menuFiltres = false; menuModifier = false }
            .sheet(isPresented: $nouveauMessage) { NouveauMessageVue() }
            .sheet(isPresented: $filtrageVisible) { GererFiltrageVue() }
        }
    }

    private var listePrincipale: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Messages")
                        .font(.system(size: 33, weight: .bold)).foregroundStyle(msgTexte)
                        .padding(.horizontal, 18).padding(.top, 56).padding(.bottom, 8)
                    ForEach(Array(convs.enumerated()), id: \.element.id) { indice, conv in
                        HStack(spacing: 0) {
                            if modeSelection {
                                Image(systemName: selection.contains(conv.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(selection.contains(conv.id) ? msgBleu : msgTexte2)
                                    .padding(.leading, 14)
                                    .onTapGesture {
                                        if selection.contains(conv.id) { selection.remove(conv.id) }
                                        else { selection.insert(conv.id) }
                                    }
                                LigneConvMsg(conv: conv)
                            } else {
                                NavigationLink { MsgConvVue(conv: conv) } label: {
                                    LigneConvMsg(conv: conv)
                                }.buttonStyle(.plain)
                            }
                        }
                        // Mini-lignes de séparation entre conversations (référence IMG_3486)
                        if indice < convs.count - 1 {
                            Divider().overlay(Color.white.opacity(0.13))
                                .padding(.leading, 73).padding(.trailing, 16)
                        }
                    }
                    Color.clear.frame(height: 90)
                }
            }
            .scrollIndicators(.hidden)
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 10) {
                HStack(spacing: 7) {
                    Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(msgTexte2)
                    TextField("", text: $recherche,
                              prompt: Text("Recherche").foregroundStyle(msgTexte2))
                        .font(.system(size: 16)).foregroundStyle(msgTexte)
                    Image(systemName: "mic.fill").font(.system(size: 15)).foregroundStyle(msgTexte2)
                }
                .padding(.horizontal, 13).padding(.vertical, 11)
                .background(Color(hex: 0x1F1F21), in: Capsule())
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .medium)).foregroundStyle(msgTexte)
                    .padding(12).background(Color(hex: 0x1F1F21), in: Circle())
                    .onTapGesture { Haptique.leger(); nouveauMessage = true }
            }
            .padding(.horizontal, 14).padding(.bottom, 8)
        }
    }
}

struct LigneMenuMsg: View {
    let symbole: String
    let texte: String
    var coche: Bool = false
    let action: () -> Void
    var body: some View {
        HStack {
            if coche { Image(systemName: "checkmark").font(.system(size: 13, weight: .semibold)).foregroundStyle(msgTexte) }
            Text(texte).font(.system(size: 16)).foregroundStyle(msgTexte)
            Spacer()
            if !symbole.isEmpty {
                Image(systemName: symbole).font(.system(size: 15)).foregroundStyle(msgTexte)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); action() }
    }
}

struct LigneConvMsg: View {
    let conv: ConvMsg
    var body: some View {
        HStack(spacing: 12) {
            AvatarMsg(nom: conv.nom, taille: 45)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(conv.nom).font(.system(size: 16, weight: .semibold)).foregroundStyle(msgTexte)
                        .lineLimit(1)
                    Spacer()
                    Text(conv.date).font(.system(size: 14)).foregroundStyle(msgTexte2)
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(msgTexte2.opacity(0.7))
                }
                Text(conv.apercu).font(.system(size: 14.5)).foregroundStyle(msgTexte2)
                    .lineLimit(2).multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 7)
        .contentShape(Rectangle())
    }
}

struct AvatarMsg: View {
    let nom: String
    var taille: CGFloat = 45
    private var initiales: String {
        if nom.first?.isNumber == true || nom.hasPrefix("+") { return "" }
        let mots = nom.split(separator: " ")
        return mots.prefix(2).compactMap { $0.first.map(String.init) }.joined().uppercased()
    }
    var body: some View {
        ZStack {
            Circle().fill(LinearGradient(colors: [Color(hex: 0x54536A), Color(hex: 0x3E3D50)],
                                          startPoint: .top, endPoint: .bottom))
            if initiales.isEmpty {
                Image(systemName: "person.fill")
                    .font(.system(size: taille * 0.5)).foregroundStyle(Color(hex: 0xD8D8E0))
            } else {
                Text(initiales).font(.system(size: taille * 0.42, weight: .medium))
                    .foregroundStyle(Color(hex: 0xE8E8F0))
            }
        }
        .frame(width: taille, height: taille)
    }
}

// ============================================================ CONVERSATION
struct MsgConvVue: View {
    @Environment(\.dismiss) private var dismiss
    let conv: ConvMsg
    @ObservedObject private var envois = EnvoisMsg.partage
    @ObservedObject private var magasin = MagasinMsg.partage
    @State private var saisie = ""
    @State private var ficheVisible = false
    @State private var menuPlus = false
    @State private var erreurVisible = false
    @State private var erreurTexte = ""
    @State private var confirmationSignaler = false
    @State private var appelVideo = false

    private var couleurEnvoi: Color { conv.bleu ? msgBleu : msgVert }

    var body: some View {
        ZStack(alignment: .bottom) {
            msgFond.ignoresSafeArea()
            VStack(spacing: 0) {
                // En-tête : retour / avatar+nom / FaceTime
                HStack {
                    Image(systemName: "chevron.left").font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(msgTexte)
                        .padding(10).contentShape(Rectangle())
                        .onTapGesture { dismiss() }
                    Spacer()
                    VStack(spacing: 3) {
                        AvatarMsg(nom: conv.nom, taille: 44)
                        HStack(spacing: 2) {
                            Text(conv.nom).font(.system(size: 12)).foregroundStyle(msgTexte)
                            Image(systemName: "chevron.right").font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(msgTexte2)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); ficheVisible = true }
                    Spacer()
                    Image(systemName: "video").font(.system(size: 19)).foregroundStyle(msgTexte)
                        .padding(10).contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); appelVideo = true }
                }
                .padding(.horizontal, 6).padding(.top, 2).padding(.bottom, 6)

                ScrollViewReader { lecteur in
                    ScrollView {
                        VStack(spacing: 3) {
                            ForEach(Array(conv.elements.enumerated()), id: \.offset) { _, el in
                                vue(el)
                            }
                            // Messages du joueur (D54 : persistants, sans mention de distribution)
                            ForEach(Array((envois.parConv[conv.nom] ?? []).enumerated()), id: \.offset) { _, texte in
                                BulleMsgTexte(texte: texte, recu: false, couleur: couleurEnvoi, tag: nil)
                            }
                            if conv.inconnu && !magasin.signalees.contains(conv.nom) {
                                VStack(spacing: 8) {
                                    Text("Si vous ne vous attendiez pas à recevoir ce message et qu'il provient d'un expéditeur inconnu, il s'agit peut-être d'un message indésirable.")
                                        .font(.system(size: 11.5)).foregroundStyle(msgTexte2)
                                        .multilineTextAlignment(.center)
                                    Text("Signaler comme indésirable")
                                        .font(.system(size: 13)).foregroundStyle(msgBleu)
                                        .onTapGesture { confirmationSignaler = true }
                                }
                                .padding(.horizontal, 30).padding(.top, 14)
                            }
                            Color.clear.frame(height: 12).id("fin")
                        }
                        .padding(.top, 6)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: envois.parConv[conv.nom]?.count ?? 0) {
                        withAnimation { lecteur.scrollTo("fin", anchor: .bottom) }
                    }
                }

                // Barre de saisie
                HStack(spacing: 10) {
                    Image(systemName: "plus").font(.system(size: 18, weight: .medium)).foregroundStyle(msgTexte)
                        .padding(11).background(Color(hex: 0x1F1F21), in: Circle())
                        .onTapGesture { Haptique.leger(); withAnimation(.easeOut(duration: 0.15)) { menuPlus.toggle() } }
                    HStack {
                        TextField("", text: $saisie,
                                  prompt: Text(conv.service).foregroundStyle(msgTexte2))
                            .font(.system(size: 16)).foregroundStyle(msgTexte)
                        if saisie.isEmpty {
                            Image(systemName: "mic").font(.system(size: 16)).foregroundStyle(msgTexte2)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 26)).foregroundStyle(couleurEnvoi)
                                .onTapGesture {
                                    let t = saisie.trimmingCharacters(in: .whitespaces)
                                    guard !t.isEmpty else { return }
                                    Haptique.leger()
                                    envois.envoyer(t, a: conv.nom)
                                    saisie = ""
                                }
                        }
                    }
                    .padding(.horizontal, 13).padding(.vertical, 8)
                    .background(Color(hex: 0x1F1F21), in: Capsule())
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
            }

            // Menu + (comme la référence : Appareil photo, Photos, Autocollants…)
            if menuPlus {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(["Appareil photo|camera", "Photos|photo",
                                   "Autocollants|face.smiling", "Sondages|chart.bar",
                                   "Envoyer plus tard|clock", "Genmoji|sparkles",
                                   "Image Playground|paintpalette"].enumerated()), id: \.offset) { i, item in
                        let parts = item.split(separator: "|")
                        HStack(spacing: 12) {
                            Image(systemName: String(parts[1]))
                                .font(.system(size: 16)).foregroundStyle(msgTexte)
                                .frame(width: 30, height: 30)
                                .background(Color(hex: 0x3A3A40), in: Circle())
                            Text(String(parts[0])).font(.system(size: 16)).foregroundStyle(msgTexte)
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            menuPlus = false
                            erreurTexte = ErreurLambda.message(conv.nom.count + i)
                            erreurVisible = true
                        }
                    }
                }
                .frame(width: 250)
                .background(Color(hex: 0x232327), in: RoundedRectangle(cornerRadius: 16))
                .padding(.leading, 12).padding(.bottom, 64)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.scale(scale: 0.9, anchor: .bottomLeading).combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $ficheVisible) {
            NavigationStack { MsgFicheVue(conv: conv) }.preferredColorScheme(.dark)
        }
        .fullScreenCover(isPresented: $appelVideo) {
            AppelTelVue(destinataire: conv.nom, numero: conv.numero)
        }
        .alert("Messages", isPresented: $erreurVisible) {
            Button("OK", role: .cancel) {}
        } message: { Text(erreurTexte) }
        .confirmationDialog("Signaler comme indésirable ?", isPresented: $confirmationSignaler, titleVisibility: .visible) {
            Button("Signaler et supprimer", role: .destructive) {
                magasin.signaler(conv)
                dismiss()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Ce message sera transmis à votre opérateur et la conversation sera déplacée dans Indésirables.")
        }
    }

    @ViewBuilder private func vue(_ el: ElementMsg) -> some View {
        switch el {
        case .sep(let d):
            Text(d).font(.system(size: 11.5)).foregroundStyle(msgTexte2)
                .padding(.vertical, 8)
        case .recu(let t):
            BulleMsgTexte(texte: t, recu: true, couleur: msgRecu, tag: nil)
        case .envoye(let t, let tag):
            BulleMsgTexte(texte: t, recu: false, couleur: couleurEnvoi, tag: tag)
        case .document(let nom, let taille, let recu):
            HStack {
                if !recu { Spacer(minLength: 70) }
                HStack(spacing: 10) {
                    Image(systemName: "doc.fill").font(.system(size: 22)).foregroundStyle(msgTexte)
                        .frame(width: 38, height: 44)
                        .background(Color(hex: 0x2E2E33), in: RoundedRectangle(cornerRadius: 6))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(nom).font(.system(size: 14.5)).foregroundStyle(msgTexte).lineLimit(2)
                        Text(taille).font(.system(size: 12)).foregroundStyle(msgTexte2)
                    }
                }
                .padding(10)
                .background(msgRecu, in: RoundedRectangle(cornerRadius: 16))
                if recu { Spacer(minLength: 70) }
            }
            .padding(.horizontal, 14)
        case .systeme(let t):
            Text(t).font(.system(size: 11.5)).foregroundStyle(msgTexte2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 34).padding(.vertical, 4)
        }
    }
}

struct BulleMsgTexte: View {
    let texte: String
    let recu: Bool
    let couleur: Color
    let tag: String?
    var body: some View {
        VStack(alignment: recu ? .leading : .trailing, spacing: 2) {
            HStack {
                if !recu { Spacer(minLength: 70) }
                Text(texte)
                    .font(.system(size: 16.5))
                    .foregroundStyle(recu ? msgTexte : .white)
                    .padding(.horizontal, 13).padding(.vertical, 8)
                    .background(couleur, in: RoundedRectangle(cornerRadius: 19))
                if recu { Spacer(minLength: 70) }
            }
            if let tag {
                Text(tag).font(.system(size: 10.5)).foregroundStyle(msgTexte2)
                    .padding(.trailing, 4)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 1)
    }
}

// ============================================================ FICHE CONTACT (Infos / Photos / Documents)
struct MsgFicheVue: View {
    @Environment(\.dismiss) private var dismiss
    let conv: ConvMsg
    @State private var onglet = 0
    @State private var masquerAlertes = false
    @State private var confirmationsLecture = true
    @State private var partageAvecVous = true
    @State private var traductionAuto = false
    @State private var bloque = false
    @State private var confirmationBloquer = false
    @State private var telechargement = false
    @State private var erreurTelechargement = false
    @State private var appelAudio = false
    @State private var erreurVisible = false
    @State private var erreurTexte = ""

    private var estContact: Bool { conv.nom.first?.isNumber != true && !conv.nom.hasPrefix("+") }

    var body: some View {
        ZStack {
            msgFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(msgTexte)
                            .padding(10).background(msgChamp, in: Circle())
                            .onTapGesture { dismiss() }
                        Spacer()
                        Text("Modifier").font(.system(size: 16)).foregroundStyle(msgTexte)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(msgChamp, in: Capsule())
                            .onTapGesture {
                                erreurTexte = ErreurLambda.message(conv.nom.count + 3)
                                erreurVisible = true
                            }
                    }
                    .padding(.horizontal, 14).padding(.top, 10)

                    AvatarMsg(nom: conv.nom, taille: 92).padding(.top, 8)
                    Text(conv.nom).font(.system(size: 24, weight: .semibold)).foregroundStyle(msgTexte)
                        .padding(.top, 10)

                    HStack(spacing: 22) {
                        RondFicheMsg(symbole: "phone.fill") { appelAudio = true }
                        RondFicheMsg(symbole: "video.fill") { appelAudio = true }
                        RondFicheMsg(symbole: "envelope.fill") {
                            erreurTexte = ErreurLambda.message(conv.nom.count + 7)
                            erreurVisible = true
                        }
                    }
                    .padding(.top, 14)

                    // Onglets Infos / Photos / Documents
                    HStack(spacing: 6) {
                        OngletFiche(nom: "Infos", actif: onglet == 0) { onglet = 0 }
                        OngletFiche(nom: "Photos", actif: onglet == 1) { onglet = 1 }
                        OngletFiche(nom: "Documents", actif: onglet == 2) { onglet = 2 }
                    }
                    .padding(.top, 16)

                    switch onglet {
                    case 1:
                        VStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 34)).foregroundStyle(msgTexte2)
                            Text("Aucune photo").font(.system(size: 15)).foregroundStyle(msgTexte2)
                        }
                        .padding(.top, 60)
                    case 2:
                        VStack(spacing: 10) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 34)).foregroundStyle(msgTexte2)
                            Text("Aucun document").font(.system(size: 15)).foregroundStyle(msgTexte2)
                        }
                        .padding(.top, 60)
                    default:
                        VStack(spacing: 14) {
                            // Numéro
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(estContact ? "téléphone" : "Message texte · RCS")
                                        .font(.system(size: 12)).foregroundStyle(msgTexte2)
                                    if estContact {
                                        Text("RÉCENT").font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(msgTexte2)
                                            .padding(.horizontal, 5).padding(.vertical, 2)
                                            .background(Color(hex: 0x3A3A3E), in: RoundedRectangle(cornerRadius: 4))
                                    }
                                }
                                HStack {
                                    Text(conv.numero).font(.system(size: 16)).foregroundStyle(msgBleu)
                                    Spacer()
                                    Image(systemName: "phone").font(.system(size: 15)).foregroundStyle(msgTexte2)
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(msgChamp, in: RoundedRectangle(cornerRadius: 12))
                            .contentShape(Rectangle())
                            .onTapGesture { appelAudio = true }

                            VStack(spacing: 0) {
                                LigneBascule(nom: "Masquer les alertes", valeur: $masquerAlertes)
                                Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 14)
                                LigneBascule(nom: "Confirmations de lecture", valeur: $confirmationsLecture)
                                Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 14)
                                LigneBascule(nom: "Afficher dans Partagé avec vous", valeur: $partageAvecVous)
                            }
                            .background(msgChamp, in: RoundedRectangle(cornerRadius: 12))

                            VStack(spacing: 0) {
                                LigneBascule(nom: "Traduction automatique", valeur: $traductionAuto)
                            }
                            .background(msgChamp, in: RoundedRectangle(cornerRadius: 12))

                            VStack(spacing: 0) {
                                if estContact {
                                    NavigationLink { TelFicheVue(nom: conv.nom) } label: {
                                        HStack {
                                            Text("Afficher dans Contacts").font(.system(size: 16)).foregroundStyle(msgBleu)
                                            Spacer()
                                        }
                                        .padding(14)
                                    }
                                    Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 14)
                                }
                                HStack {
                                    Text(bloque ? "Débloquer le contact" : "Bloquer le contact")
                                        .font(.system(size: 16)).foregroundStyle(Color(hex: 0xFF453A))
                                    Spacer()
                                }
                                .padding(14)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if bloque { bloque = false } else { confirmationBloquer = true }
                                }
                            }
                            .background(msgChamp, in: RoundedRectangle(cornerRadius: 12))

                            if estContact {
                                HStack {
                                    if telechargement {
                                        ProgressView().tint(msgTexte2)
                                        Text("Téléchargement…").font(.system(size: 16)).foregroundStyle(msgTexte2)
                                    } else {
                                        Text("Télécharger les pièces jointes sur iCloud")
                                            .font(.system(size: 16)).foregroundStyle(msgBleu)
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(msgChamp, in: RoundedRectangle(cornerRadius: 12))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard !telechargement else { return }
                                    telechargement = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                        telechargement = false
                                        erreurTelechargement = true
                                    }
                                }
                            }

                            Text(conv.bleu
                                 ? "Cette conversation est chiffrée de bout en bout."
                                 : "Cette conversation n'est pas chiffrée de bout en bout.")
                                .font(.system(size: 12)).foregroundStyle(msgTexte2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }
                        .padding(.horizontal, 16).padding(.top, 18)
                    }
                    Color.clear.frame(height: 40)
                }
            }
        }
        .fullScreenCover(isPresented: $appelAudio) {
            AppelTelVue(destinataire: conv.nom, numero: conv.numero)
        }
        .alert("Messages", isPresented: $erreurVisible) {
            Button("OK", role: .cancel) {}
        } message: { Text(erreurTexte) }
        .alert("iCloud", isPresented: $erreurTelechargement) {
            Button("OK", role: .cancel) {}
        } message: { Text("Impossible de télécharger les pièces jointes pour le moment.") }
        .confirmationDialog("Bloquer ce contact ?", isPresented: $confirmationBloquer, titleVisibility: .visible) {
            Button("Bloquer le contact", role: .destructive) { bloque = true }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Vous ne recevrez plus ni messages ni appels de ce contact.")
        }
    }
}

struct RondFicheMsg: View {
    let symbole: String
    let action: () -> Void
    var body: some View {
        Image(systemName: symbole)
            .font(.system(size: 17)).foregroundStyle(msgTexte)
            .frame(width: 56, height: 38)
            .background(msgChamp, in: RoundedRectangle(cornerRadius: 19))
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); action() }
    }
}

struct OngletFiche: View {
    let nom: String
    let actif: Bool
    let action: () -> Void
    var body: some View {
        Text(nom).font(.system(size: 14, weight: actif ? .semibold : .regular))
            .foregroundStyle(actif ? msgTexte : msgTexte2)
            .padding(.horizontal, 16).padding(.vertical, 7)
            .background(actif ? Color(hex: 0x3A3A3E) : .clear, in: Capsule())
            .contentShape(Rectangle())
            .onTapGesture { Haptique.leger(); action() }
    }
}

struct LigneBascule: View {
    let nom: String
    @Binding var valeur: Bool
    var body: some View {
        HStack {
            Text(nom).font(.system(size: 16)).foregroundStyle(msgTexte)
            Spacer()
            Toggle("", isOn: $valeur).labelsHidden().tint(Color(hex: 0x30D158))
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
    }
}

// ============================================================ INDÉSIRABLES
struct MsgIndesirablesVue: View {
    @ObservedObject private var magasin = MagasinMsg.partage
    var body: some View {
        VStack {
            if magasin.indesirables.isEmpty {
                Spacer()
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 44)).foregroundStyle(Color(hex: 0x3A3A3E))
                Text("Aucun message").font(.system(size: 20, weight: .semibold)).foregroundStyle(msgTexte)
                    .padding(.top, 10)
                Text("Les messages considérés comme indésirables apparaîtront ici.")
                    .font(.system(size: 14)).foregroundStyle(msgTexte2)
                    .multilineTextAlignment(.center).padding(.horizontal, 60)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 60)
                        ForEach(Array(magasin.indesirables.enumerated()), id: \.element.id) { indice, conv in
                            NavigationLink { MsgConvVue(conv: conv) } label: {
                                LigneConvMsg(conv: conv)
                            }.buttonStyle(.plain)
                            if indice < magasin.indesirables.count - 1 {
                                Divider().overlay(Color.white.opacity(0.13))
                                    .padding(.leading, 73).padding(.trailing, 16)
                            }
                        }
                    }
                }
            }
        }
    }
}

// ============================================================ SUPPRESSIONS (récupérables — or narratif)
struct MsgSuppressionsVue: View {
    @ObservedObject private var magasin = MagasinMsg.partage
    @State private var selection = Set<String>()
    @State private var confirmationRecuperer = false
    @State private var confirmationSupprimer = false

    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 58)
            Text("Les conversations affichent le nombre de jours restant avant leur suppression. Une fois ce délai écoulé, les messages seront définitivement supprimés. Cela peut prendre jusqu'à 40 jours.")
                .font(.system(size: 12.5)).foregroundStyle(msgTexte2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30).padding(.bottom, 14)

            if magasin.supprimees.isEmpty {
                Spacer()
                Text("Aucune conversation supprimée récemment")
                    .font(.system(size: 15)).foregroundStyle(msgTexte2)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(magasin.supprimees) { s in
                            HStack(spacing: 12) {
                                Image(systemName: selection.contains(s.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 21))
                                    .foregroundStyle(selection.contains(s.id) ? msgBleu : msgTexte2)
                                    .onTapGesture {
                                        Haptique.leger()
                                        if selection.contains(s.id) { selection.remove(s.id) }
                                        else { selection.insert(s.id) }
                                    }
                                AvatarMsg(nom: s.conv.nom, taille: 42)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(s.conv.nom).font(.system(size: 16, weight: .semibold)).foregroundStyle(msgTexte)
                                    Text(s.nbMessages).font(.system(size: 13.5)).foregroundStyle(msgTexte2)
                                }
                                Spacer()
                                Text(s.jours).font(.system(size: 14)).foregroundStyle(msgTexte2)
                            }
                            .padding(.horizontal, 18).padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                    }
                }
            }

            HStack {
                Text("Tout récupérer").font(.system(size: 15, weight: .medium)).foregroundStyle(msgTexte)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(msgChamp, in: Capsule())
                    .opacity(magasin.supprimees.isEmpty ? 0.4 : 1)
                    .onTapGesture {
                        guard !magasin.supprimees.isEmpty else { return }
                        Haptique.leger(); confirmationRecuperer = true
                    }
                Spacer()
                Image(systemName: "trash").font(.system(size: 16)).foregroundStyle(selection.isEmpty ? msgTexte2 : Color(hex: 0xFF453A))
                    .padding(12).background(msgChamp, in: Circle())
                    .onTapGesture {
                        guard !selection.isEmpty else { return }
                        Haptique.leger(); confirmationSupprimer = true
                    }
            }
            .padding(.horizontal, 16).padding(.bottom, 10)
        }
        .confirmationDialog("Récupérer \(magasin.supprimees.count) conversation(s) ?",
                            isPresented: $confirmationRecuperer, titleVisibility: .visible) {
            Button("Tout récupérer") { magasin.toutRecuperer() }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Les conversations seront replacées dans votre liste de messages.")
        }
        .confirmationDialog("Supprimer définitivement ?",
                            isPresented: $confirmationSupprimer, titleVisibility: .visible) {
            Button("Supprimer \(selection.count) conversation(s)", role: .destructive) {
                magasin.supprimer(selection); selection.removeAll()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette action est irréversible.")
        }
    }
}

// ============================================================ GÉRER LE FILTRAGE
struct GererFiltrageVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var filtrerInconnus = true
    @State private var filtrerIndesirables = true
    var body: some View {
        NavigationStack {
            ZStack {
                msgFond.ignoresSafeArea()
                VStack(spacing: 14) {
                    VStack(spacing: 0) {
                        LigneBascule(nom: "Filtrer les expéditeurs inconnus", valeur: $filtrerInconnus)
                    }
                    .background(msgChamp, in: RoundedRectangle(cornerRadius: 12))
                    Text("Trie les messages des personnes qui ne figurent pas dans vos contacts et désactive les notifications les concernant.")
                        .font(.system(size: 12.5)).foregroundStyle(msgTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    VStack(spacing: 0) {
                        LigneBascule(nom: "Filtrer les indésirables", valeur: $filtrerIndesirables)
                    }
                    .background(msgChamp, in: RoundedRectangle(cornerRadius: 12))
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.top, 16)
            }
            .navigationTitle("Filtrage des messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }.foregroundStyle(msgBleu)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ NOUVEAU MESSAGE
struct NouveauMessageVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var destinataire = ""
    @State private var convOuverte: ConvMsg? = nil

    private var suggestions: [(String, String)] {
        guard !destinataire.isEmpty else { return [] }
        return DonneesTel.contacts.filter { $0.0.localizedCaseInsensitiveContains(destinataire) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                msgFond.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Text("À :").font(.system(size: 16)).foregroundStyle(msgTexte2)
                        TextField("", text: $destinataire)
                            .font(.system(size: 16)).foregroundStyle(msgBleu)
                        Image(systemName: "plus.circle").font(.system(size: 20)).foregroundStyle(msgBleu)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    .background(Color(hex: 0x111113))

                    ForEach(suggestions, id: \.0) { s in
                        HStack(spacing: 12) {
                            AvatarMsg(nom: s.0, taille: 40)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(s.0).font(.system(size: 16, weight: .medium)).foregroundStyle(msgTexte)
                                Text(s.1).font(.system(size: 13.5)).foregroundStyle(msgTexte2)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Haptique.leger()
                            if let existante = DonneesMsg.convs.first(where: { $0.nom == s.0 }) {
                                convOuverte = existante
                            } else {
                                convOuverte = ConvMsg(nom: s.0, numero: s.1,
                                                      service: "Message texte · SMS", bleu: false,
                                                      inconnu: false, apercu: "", date: "", elements: [])
                            }
                        }
                    }
                    Spacer()
                }
            }
            .navigationTitle("Nouveau message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }.foregroundStyle(msgBleu)
                }
            }
            .navigationDestination(item: $convOuverte) { conv in
                MsgConvVue(conv: conv)
            }
        }
        .preferredColorScheme(.dark)
    }
}

extension ConvMsg: Hashable {
    static func == (a: ConvMsg, b: ConvMsg) -> Bool { a.nom == b.nom }
    func hash(into hasher: inout Hasher) { hasher.combine(nom) }
}
