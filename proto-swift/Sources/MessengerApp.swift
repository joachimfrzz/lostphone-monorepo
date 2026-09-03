// Messenger — v3 D91 (03/09) — reconstruit contre les 106 frames de Joachim, mesures audit/messenger.md
//
// Doctrines appliquées :
//  · D67 — la référence est l'enregistrement de Joachim (refs/c2/messenger/e001…e106, 1 pt = 1,5 px).
//  · D82 — aucun bouton mort : chaque commande agit (A), répond par un message iOS crédible (B, rare),
//          ou a été retirée (C). Les retraits sont annotés « (C) » dans le code.
//  · D59 — contenu Sarah remplaçable, noms FACEBOOK (Sylvie Lavisse, Julie Ferrand). Marc n'est PAS
//          sur Messenger : il n'apparaît ni dans les fils, ni dans les suggestions.
//  · Les écrans jamais filmés (§5 de l'audit) sont implémentés MINIMAUX et sobres, dans les jetons
//    mesurés, et signalés par « TODO tournage : … » pour retouche après réception des vidéos.
//
// Points d'entrée publics conservés : MessengerVue() (racine appelée par la coque, LPProto l. 1176)
// et les vues citées par EcranCapture.ecransMessenger() (registre mis à jour dans LPProto.swift).
import SwiftUI
import UIKit

// ============================================================================
// MARK: - 1. JETONS DE STYLE (§2.1 de l'audit — échantillonnés au pixel)
// ============================================================================

enum MsgrStyle {
    static let fond            = Color.black                 // #000000 (e001/e009)
    static let bulleEnvoi      = Color(hex: 0x1260FF)        // e009 y 250-270
    static let bulleRecue      = Color(hex: 0x2C2B30)        // e009 y 395-420
    static let accent          = Color(hex: 0x3454FF)        // icônes composeur (e009)
    static let boutonPlein     = Color(hex: 0x0F5BFC)        // Ajouter comme ami(e), Confirmer (e076)
    static let champ           = Color(hex: 0x2C2B30)        // champ « Aa » et recherche
    static let carte           = Color(hex: 0x1F2326)        // cartes fiche / menu / réglages (e035, e080)
    static let sepCarte        = Color(hex: 0x303437)        // séparateur interne de carte
    static let barreOnglets    = Color(hex: 0x090909)        // fond de la barre d'onglets (e001)
    static let inactif         = Color(hex: 0xA4A7AE)        // onglet inactif, textes secondaires
    static let rouge           = Color(hex: 0xFF3B36)        // appel manqué, badge
    static let destructif      = Color(hex: 0xFD3D3C)        // « Supprimer la conversation » (e091)
    static let rappeler        = Color(hex: 0x515055)        // bouton « Rappeler » (e009)
    static let rondAppel       = Color(hex: 0x3A3A3F)        // rond d'un appel abouti
    static let themeRecue      = Color(hex: 0x1E1F3B)        // bulle reçue, thème personnalisé (e091)
    static let themeFond1      = Color(hex: 0x3B1560)
    static let themeFond2      = Color(hex: 0x150B2E)
    static let themeAccent     = Color(hex: 0xF2606B)        // chevron corail du fil à thème (e094)
    static let menuContextuel  = Color(hex: 0x2A2A2E)        // carte du menu d'appui long (e012)

    // Géométrie récurrente
    static let margeLaterale: CGFloat  = 17                  // 26 px (e001)
    static let avatarListe: CGFloat    = 58                  // ⌀ 88 px
    static let pasRangee: CGFloat      = 76                  // 114 px
    static let avatarFil: CGFloat      = 28                  // ⌀ 42 px (e009)
    static let avatarEnTete: CGFloat   = 35                  // ⌀ 53 px
    static let rayonBulle: CGFloat     = 18                  // ≈ 27 px
}

// ============================================================================
// MARK: - 2. MODÈLES
// ============================================================================

/// Contenu d'un message. `.horodatage` et `.systeme` sont des lignes centrées, pas des bulles :
/// c'est le moteur de fil (§2.3) qui leur applique l'espacement de 17 pt.
enum MsgrContenu: Equatable {
    case texte(String)
    case photo(String)                            // clé pellicule (ChargeurPhoto)
    case vocal(String)                            // durée affichée, ex. « 0:25 »
    case autocollant(String)                      // grand emoji, sans bulle
    case localisation(String)                     // légende, ex. « Lyon 3e · Rue Paul Bert »
    case appel(manque: Bool, detail: String)      // « 47 s » ou « 5:09 PM »
    case systeme(String)
    case horodatage(String)                       // « 1 AOÛT À 18:37 »
}

struct MsgrMessage: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var deMoi: Bool = false
    var auteur: String? = nil                     // groupes : nom affiché au-dessus de la bulle
    var photoAuteur: String? = nil                // clé pellicule de l'avatar de l'auteur
    var contenu: MsgrContenu
    var reactions: [String] = []                  // emojis posés (le joueur pose/retire le sien)
    var compteurReaction: Int = 0                 // « ❤️ 8 » — réactions préexistantes (e027)
    var lecteurs: [String] = []                   // clés pellicule des accusés de lecture
    var citation: String? = nil                   // « Mathieu vous a répondu » (e020)

    var estCentre: Bool {
        switch contenu {
        case .horodatage, .systeme: return true
        default: return false
        }
    }
    var texteBrut: String {
        switch contenu {
        case .texte(let t): return t
        case .autocollant(let e): return e
        case .localisation(let l): return l
        case .photo: return "Photo"
        case .vocal(let d): return "Message vocal (\(d))"
        case .appel(let m, _): return m ? "Appel vocal manqué" : "Appel vocal"
        case .systeme(let t): return t
        case .horodatage(let t): return t
        }
    }
}

struct MsgrConversation: Identifiable, Equatable {
    let id: String
    var nom: String
    var photo: String? = nil                      // clé pellicule ; nil → initiale colorée
    var photoSecondaire: String? = nil            // groupes : 2ᵉ photo du cluster (e035)
    var teinte: UInt = 0x5B7CFA
    var apercu: String
    var date: String
    var nonLu: Bool = false
    var groupe: Bool = false
    var lecteurApercu: String? = nil              // petit avatar d'accusé à droite de la rangée (e001)
    var sourdine: Bool = false
    var theme: Bool = false                       // thème personnalisé (e091-e096)
    var quitte: Bool = false                      // « Vous ne pouvez plus écrire » (e094)
    var membres: [MsgrMembre] = []
    var confirmationsLecture: Bool = true
    var indicateurSaisie: Bool = true
}

struct MsgrMembre: Identifiable, Equatable {
    var id: String { nom }
    var nom: String
    var detail: String
    var photo: String? = nil
    var teinte: UInt = 0x3A3A3C
    var admin: Bool = false
}

struct MsgrNote: Identifiable, Equatable {
    var id: String { auteur }
    var auteur: String
    var texte: String
    var photo: String?
    var teinte: UInt = 0x5B7CFA
    var expiration: String = "il y a 3 h"
}

struct MsgrStory: Identifiable, Equatable {
    var id: String { auteur }
    var auteur: String
    var photo: String?                            // image de la story
    var avatar: String?
    var teinte: UInt = 0x8B5CF6
    var age: String = "23 h"
    var legende: String = ""
    var vue: Bool = false
}

struct MsgrSuggestion: Identifiable, Equatable {
    var id: String { nom }
    var nom: String
    var detail: String
    var photo: String? = nil
    var teinte: UInt = 0x3A3A3C
}

// ============================================================================
// MARK: - 3. STORE (P0-1 — remplace l'ancien `enum DonneesMessenger` immuable)
// ============================================================================

/// Tout l'état mutable de Messenger. `nonLu` devient réellement faux à l'ouverture
/// d'une conversation, ce qui corrige le point 4.2 de l'audit.
final class MessengerStore: ObservableObject {
    static let partage = MessengerStore()

    @Published var conversations: [MsgrConversation]
    @Published var archivees: [MsgrConversation]
    @Published var fils: [String: [MsgrMessage]]
    @Published var notes: [MsgrNote]
    @Published var stories: [MsgrStory]
    @Published var suggestions: [MsgrSuggestion]
    @Published var invitationsFacebook: [MsgrSuggestion]
    @Published var amisAjoutes: Set<String> = []
    @Published var invitationsTraitees: Set<String> = []
    @Published var maNote: String = ""
    @Published var maStory: Bool = false
    @Published var messagesEpingles: [String: [String]] = [:]
    @Published var membresBloques: Set<String> = []
    @Published var ongletDemande: Int? = nil       // pilotage de la barre d'onglets depuis un enfant

    private init() {
        conversations = MessengerStore.conversationsInitiales()
        archivees = MessengerStore.archiveesInitiales()
        fils = MessengerStore.filsInitiaux()
        notes = MessengerStore.notesInitiales()
        stories = MessengerStore.storiesInitiales()
        suggestions = MessengerStore.suggestionsInitiales()
        invitationsFacebook = MessengerStore.invitationsInitiales()
    }

    // ————— Lecture
    func conversation(_ id: String) -> MsgrConversation? {
        conversations.first { $0.id == id } ?? archivees.first { $0.id == id }
    }
    func messages(_ id: String) -> [MsgrMessage] { fils[id] ?? [] }
    var nombreNonLues: Int { conversations.filter { $0.nonLu }.count }

    // ————— Écriture
    func marquerLue(_ id: String) {
        guard let i = conversations.firstIndex(where: { $0.id == id }), conversations[i].nonLu else { return }
        conversations[i].nonLu = false
    }

    func envoyer(_ contenu: MsgrContenu, dans id: String) {
        var fil = fils[id] ?? []
        fil.append(MsgrMessage(deMoi: true, contenu: contenu))
        fils[id] = fil
        majApercu(id, texte: "Vous : " + resume(contenu))
    }

    func retirerEnvoi(_ messageID: String, dans id: String) {
        guard var fil = fils[id], let i = fil.firstIndex(where: { $0.id == messageID }) else { return }
        fil[i] = MsgrMessage(contenu: .systeme("Vous avez retiré un message."))
        fils[id] = fil
    }

    func basculerReaction(_ emoji: String, message messageID: String, dans id: String) {
        guard var fil = fils[id], let i = fil.firstIndex(where: { $0.id == messageID }) else { return }
        if fil[i].reactions.contains(emoji) {
            fil[i].reactions.removeAll { $0 == emoji }
        } else {
            fil[i].reactions = [emoji]
        }
        fils[id] = fil
    }

    func epingler(_ messageID: String, dans id: String) {
        guard let fil = fils[id], let m = fil.first(where: { $0.id == messageID }) else { return }
        var liste = messagesEpingles[id] ?? []
        if !liste.contains(m.texteBrut) { liste.append(m.texteBrut) }
        messagesEpingles[id] = liste
    }

    func supprimerMessage(_ messageID: String, dans id: String) {
        guard var fil = fils[id] else { return }
        fil.removeAll { $0.id == messageID }
        fils[id] = fil
    }

    func basculerSourdine(_ id: String) {
        guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[i].sourdine.toggle()
    }

    func definirConfirmations(_ valeur: Bool, dans id: String) {
        guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[i].confirmationsLecture = valeur
    }

    func definirIndicateur(_ valeur: Bool, dans id: String) {
        guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[i].indicateurSaisie = valeur
    }

    func quitter(_ id: String) {
        guard let i = conversations.firstIndex(where: { $0.id == id }) else { return }
        var conv = conversations.remove(at: i)
        conv.quitte = true
        conv.apercu = "Vous avez quitté le groupe."
        archivees.insert(conv, at: 0)
    }

    func supprimerConversation(_ id: String) {
        conversations.removeAll { $0.id == id }
        archivees.removeAll { $0.id == id }
        fils[id] = nil
    }

    func creerGroupe(nom: String, membres: [MsgrMembre]) -> String {
        let identifiant = "groupe-\(UUID().uuidString.prefix(6))"
        let conv = MsgrConversation(id: identifiant, nom: nom, teinte: 0x5B7CFA,
                                    apercu: "Vous avez créé le groupe.", date: "à l'instant",
                                    groupe: true, membres: membres)
        conversations.insert(conv, at: 0)
        fils[identifiant] = [MsgrMessage(contenu: .systeme("Vous avez créé le groupe « \(nom) »."))]
        return identifiant
    }

    func basculerAmi(_ nom: String) {
        if amisAjoutes.contains(nom) { amisAjoutes.remove(nom) } else { amisAjoutes.insert(nom) }
    }

    func traiterInvitation(_ nom: String) { invitationsTraitees.insert(nom) }

    func bloquer(_ nom: String) { membresBloques.insert(nom) }

    // ————— Utilitaires privés
    private func majApercu(_ id: String, texte: String) {
        if let i = conversations.firstIndex(where: { $0.id == id }) {
            conversations[i].apercu = texte
            conversations[i].date = "à l'instant"
            let conv = conversations.remove(at: i)
            conversations.insert(conv, at: 0)
        }
    }

    private func resume(_ contenu: MsgrContenu) -> String {
        switch contenu {
        case .texte(let t): return t
        case .photo: return "Photo"
        case .vocal(let d): return "Message vocal · \(d)"
        case .autocollant(let e): return e
        case .localisation: return "Position partagée"
        case .appel(let m, _): return m ? "Appel vocal manqué" : "Appel vocal"
        case .systeme(let t): return t
        case .horodatage(let t): return t
        }
    }
}

// ============================================================================
// MARK: - 4. CONTENU SARAH (D59 — noms FACEBOOK ; Marc n'est pas sur Messenger)
// ============================================================================

extension MessengerStore {

    static func conversationsInitiales() -> [MsgrConversation] {
        [
            MsgrConversation(id: "chloe", nom: "Chloé Berthier", photo: "p12", teinte: 0xE64980,
                             apercu: "Vous : Oui promis on se fait ça 😊", date: "16 août",
                             nonLu: true, lecteurApercu: "p12",
                             membres: []),
            MsgrConversation(id: "sylvie", nom: "Sylvie Lavisse", photo: nil, teinte: 0xE8A0A0,
                             apercu: "A réagi avec ❤️ à votre message", date: "14 août"),
            MsgrConversation(id: "filles", nom: "Les filles 💃", photo: "p22", photoSecondaire: "p18",
                             teinte: 0x8B5CF6,
                             apercu: "Inès : On dit 20h30 chez moi alors !", date: "12 août",
                             nonLu: true, groupe: true,
                             membres: MessengerStore.membresFilles),
            MsgrConversation(id: "thomas", nom: "Thomas Levasseur", photo: nil, teinte: 0x0A84FF,
                             apercu: "L'appel vocal est terminé.", date: "9 août"),
            MsgrConversation(id: "julie", nom: "Julie Ferrand", photo: nil, teinte: 0x30D158,
                             apercu: "Vous : Parfait, à jeudi !", date: "7 août"),
            MsgrConversation(id: "nadia", nom: "Nadia Benkacem", photo: nil, teinte: 0xFF9F0A,
                             apercu: "La commode est toujours dispo ?", date: "28 juil."),
            MsgrConversation(id: "lea", nom: "Léa Moreau", photo: "p18", teinte: 0x30D1C4,
                             apercu: "Super merci beaucoup !!", date: "21 juil."),
        ]
    }

    static func archiveesInitiales() -> [MsgrConversation] {
        [
            MsgrConversation(id: "cadeau", nom: "Idée cadeau papa", photo: "p24", photoSecondaire: "p25",
                             teinte: 0x5B7CFA,
                             apercu: "Vous avez quitté le groupe.", date: "2 mai",
                             groupe: true, theme: true, quitte: true,
                             membres: MessengerStore.membresCadeau),
        ]
    }

    static let membresFilles: [MsgrMembre] = [
        MsgrMembre(nom: "Sarah Levasseur", detail: "Créatrice du groupe", photo: "p04",
                   teinte: 0x5B7CFA, admin: true),
        MsgrMembre(nom: "Chloé Berthier", detail: "Ajoutée par Sarah Levasseur", photo: "p12", teinte: 0xE64980),
        MsgrMembre(nom: "Inès Djellal", detail: "Ajoutée par Sarah Levasseur", photo: nil, teinte: 0xFF9F0A),
        MsgrMembre(nom: "Léa Moreau", detail: "Ajoutée par Chloé Berthier", photo: "p18", teinte: 0x30D1C4),
        MsgrMembre(nom: "Camille Roussel", detail: "Ajoutée par Inès Djellal", photo: nil, teinte: 0x8B5CF6),
    ]

    static let membresCadeau: [MsgrMembre] = [
        MsgrMembre(nom: "Thomas Levasseur", detail: "Créateur du groupe", photo: nil, teinte: 0x0A84FF, admin: true),
        MsgrMembre(nom: "Sylvie Lavisse", detail: "Ajoutée par Thomas Levasseur", photo: nil, teinte: 0xE8A0A0),
        MsgrMembre(nom: "Sarah Levasseur", detail: "A quitté le groupe", photo: "p04", teinte: 0x5B7CFA),
    ]

    static func notesInitiales() -> [MsgrNote] {
        [
            MsgrNote(auteur: "Chloé Berthier", texte: "Besoin d'un café ☕️", photo: "p12",
                     teinte: 0xE64980, expiration: "il y a 3 h"),
            MsgrNote(auteur: "Léa Moreau", texte: "Reprise du sport, priez pour moi 💪", photo: "p18",
                     teinte: 0x30D1C4, expiration: "il y a 11 h"),
        ]
    }

    static func storiesInitiales() -> [MsgrStory] {
        [
            MsgrStory(auteur: "Nadia Benkacem", photo: "p23", avatar: nil, teinte: 0xFF9F0A,
                      age: "5 h", legende: "Enfin le week-end"),
            MsgrStory(auteur: "Thomas Levasseur", photo: "p26", avatar: nil, teinte: 0x0A84FF,
                      age: "23 h", legende: "Balade du dimanche", vue: true),
        ]
    }

    // Marc Delorme RETIRÉ des suggestions (§4.1 de l'audit).
    static func suggestionsInitiales() -> [MsgrSuggestion] {
        [
            MsgrSuggestion(nom: "Vincent Berthier", detail: "Suivi(e) par Chloé Berthier", teinte: 0x3A6EA5),
            MsgrSuggestion(nom: "Atelier Poterie Lyon 3", detail: "Suivi(e) par 41 personnes", teinte: 0xB07A4A),
            MsgrSuggestion(nom: "Camille Roussel", detail: "Suivi(e) par 2 personnes", teinte: 0x8B5CF6),
            MsgrSuggestion(nom: "Hugo Da Silva", detail: "Suivi(e) par 318 personnes", teinte: 0x3F8F5C),
        ]
    }

    static func invitationsInitiales() -> [MsgrSuggestion] {
        [
            MsgrSuggestion(nom: "Christian Renaud", detail: "3 amis en commun", teinte: 0x8A6D5B),
            MsgrSuggestion(nom: "Manon Saint-Jeannet", detail: "Suivi(e) par 898 personnes", teinte: 0xA05B7A),
            MsgrSuggestion(nom: "Franck Soubielle", detail: "1 ami en commun", teinte: 0x4A7FA5),
        ]
    }

    static func filsInitiaux() -> [String: [MsgrMessage]] {
        // ⚠️ Piège Swift (crash build 274) : un littéral de dictionnaire à clés dupliquées plante
        // fatalement au lancement. Les 8 clés ci-dessous sont uniques — vérifié à la relecture.
        var table: [String: [MsgrMessage]] = [:]
        table["chloe"]  = filChloe()
        table["sylvie"] = filSylvie()
        table["filles"] = filFilles()
        table["thomas"] = filThomas()
        table["julie"]  = filJulie()
        table["nadia"]  = filNadia()
        table["lea"]    = filLea()
        table["cadeau"] = filCadeau()
        return table
    }

    static func filChloe() -> [MsgrMessage] {
        [
            MsgrMessage(contenu: .horodatage("SAM. À 18:47")),
            MsgrMessage(photoAuteur: "p12", contenu: .texte("Coucou ! Alors ce week-end à Annecy c'était comment ?? 😍")),
            MsgrMessage(deMoi: true, contenu: .texte("Trop bien !! Le lac était magnifique, je te montre les photos jeudi")),
            MsgrMessage(photoAuteur: "p12", contenu: .texte("Trop hâte 😍 Et sinon ça va toi ? Tu avais l'air ailleurs au téléphone")),
            MsgrMessage(deMoi: true, contenu: .texte("Oui oui t'inquiète, juste fatiguée en ce moment"), reactions: ["❤️"]),
            MsgrMessage(contenu: .horodatage("16 AOÛT À 21:04")),
            MsgrMessage(photoAuteur: "p12", contenu: .appel(manque: true, detail: "9:04 PM")),
            MsgrMessage(photoAuteur: "p12", contenu: .texte("Je t'ai appelée, rappelle-moi quand tu peux 🙏")),
            MsgrMessage(photoAuteur: "p12", contenu: .texte("On se fait un ciné la semaine prochaine ? Ça te changera les idées")),
            MsgrMessage(deMoi: true, contenu: .texte("Oui promis on se fait ça 😊"), lecteurs: ["p12"]),
        ]
    }

    static func filSylvie() -> [MsgrMessage] {
        [
            MsgrMessage(contenu: .horodatage("14 AOÛT À 11:20")),
            MsgrMessage(contenu: .texte("Ma chérie, tu passes dimanche ? Je fais le gratin que tu aimes")),
            MsgrMessage(deMoi: true, contenu: .texte("Oui maman, je serai là vers midi")),
            MsgrMessage(deMoi: true, contenu: .texte("Par contre je repars tôt, j'ai des trucs à régler"), reactions: ["❤️"]),
            MsgrMessage(contenu: .texte("Des trucs à régler ? Tout va bien ma puce ?")),
            MsgrMessage(deMoi: true, contenu: .texte("Tout va bien, je t'expliquerai 😘"), lecteurs: []),
        ]
    }

    static func filFilles() -> [MsgrMessage] {
        [
            MsgrMessage(contenu: .horodatage("12 AOÛT À 14:12")),
            MsgrMessage(auteur: "Inès Djellal", contenu: .texte("Les filles, soirée chez moi vendredi ? 🥂")),
            MsgrMessage(auteur: "Chloé Berthier", photoAuteur: "p12", contenu: .texte("Ouiii carrément !")),
            MsgrMessage(auteur: "Léa Moreau", photoAuteur: "p18", contenu: .photo("p22")),
            MsgrMessage(auteur: "Léa Moreau", photoAuteur: "p18", contenu: .texte("La photo de la dernière fois 😂"),
                        compteurReaction: 8, lecteurs: ["p12", "p18", "p04"]),
            MsgrMessage(contenu: .systeme("Inès Djellal vous a ajouté(e) ainsi que Camille Roussel au groupe.")),
            MsgrMessage(deMoi: true, contenu: .texte("Je peux venir un peu plus tard ? J'ai un truc avant")),
            MsgrMessage(auteur: "Inès Djellal", contenu: .vocal("0:25")),
            MsgrMessage(auteur: "Inès Djellal", contenu: .texte("Pas de souci ! On dit 20h30 chez moi alors !"),
                        reactions: ["👍"]),
        ]
    }

    static func filThomas() -> [MsgrMessage] {
        [
            MsgrMessage(contenu: .horodatage("9 AOÛT À 19:31")),
            MsgrMessage(contenu: .texte("Sarah, papa m'a dit que tu lui avais demandé de l'argent")),
            MsgrMessage(contenu: .texte("Tu peux m'appeler ? Je préfère qu'on en parle de vive voix")),
            MsgrMessage(deMoi: true, contenu: .texte("C'est rien, un décalage sur mon salaire, je te jure")),
            MsgrMessage(contenu: .appel(manque: false, detail: "47 s")),
            MsgrMessage(contenu: .texte("Ok. Mais tu me dis si ça recommence, hein."), lecteurs: []),
        ]
    }

    static func filJulie() -> [MsgrMessage] {
        [
            MsgrMessage(contenu: .horodatage("7 AOÛT À 09:12")),
            MsgrMessage(contenu: .texte("Bonjour Sarah, je confirme votre séance de jeudi 10h au cabinet de Villeurbanne")),
            MsgrMessage(contenu: .localisation("Cabinet — 14 rue Léon Blum, Villeurbanne")),
            MsgrMessage(deMoi: true, contenu: .texte("Parfait, à jeudi !"), lecteurs: []),
        ]
    }

    static func filNadia() -> [MsgrMessage] {
        [
            MsgrMessage(contenu: .horodatage("28 JUIL. À 16:40")),
            MsgrMessage(contenu: .texte("Bonjour, j'ai vu votre annonce")),
            MsgrMessage(contenu: .texte("La commode est toujours dispo ?")),
        ]
    }

    static func filLea() -> [MsgrMessage] {
        [
            MsgrMessage(contenu: .horodatage("21 JUIL. À 21:55")),
            MsgrMessage(deMoi: true, contenu: .texte("Je t'ai envoyé les photos du week-end 📸")),
            MsgrMessage(deMoi: true, contenu: .photo("p26")),
            MsgrMessage(photoAuteur: "p18", contenu: .texte("Super merci beaucoup !!"), reactions: ["😍"]),
        ]
    }

    static func filCadeau() -> [MsgrMessage] {
        [
            MsgrMessage(contenu: .horodatage("2 MAI À 20:03")),
            MsgrMessage(auteur: "Thomas Levasseur", contenu: .texte("On part sur la montre ou sur le week-end en Bourgogne ?")),
            MsgrMessage(auteur: "Sylvie Lavisse", contenu: .texte("Le week-end, il ne porte jamais de montre 😅")),
            MsgrMessage(deMoi: true, contenu: .texte("Je peux mettre 60 € max ce mois-ci, désolée")),
            MsgrMessage(auteur: "Thomas Levasseur", contenu: .texte("Sarah, c'est la troisième fois que tu dis ça…")),
            MsgrMessage(contenu: .systeme("Vous avez quitté le groupe.")),
        ]
    }
}

// ============================================================================
// MARK: - 5. COMPOSANTS DE BASE
// ============================================================================

/// Avatar rond : photo de la pellicule si disponible, sinon initiale sur fond teinté.
struct MsgrAvatar: View {
    var photo: String?
    var nom: String
    var teinte: UInt = 0x5B7CFA
    var taille: CGFloat = 58

    var body: some View {
        // Motif imposé (jamais `.scaledToFill()` nu dans une cellule) : conteneur neutre + overlay + clip.
        Color.clear
            .frame(width: taille, height: taille)
            .overlay(contenuAvatar)
            .clipShape(Circle())
    }

    @ViewBuilder private var contenuAvatar: some View {
        if let cle = photo, let img = ChargeurPhoto.image(cle) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            Circle().fill(Color(hex: teinte))
                .overlay(
                    Text(String(nom.prefix(1)))
                        .font(.system(size: taille * 0.42, weight: .semibold))
                        .foregroundStyle(.white)
                )
        }
    }
}

/// Cluster de 2 photos des groupes (e035, e090) : grande en haut-droite, petite en bas-gauche.
struct MsgrAvatarCluster: View {
    let conv: MsgrConversation
    var taille: CGFloat = 58

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            MsgrAvatar(photo: conv.photo, nom: conv.nom, teinte: conv.teinte, taille: taille * 0.78)
                .frame(width: taille, height: taille, alignment: .topTrailing)
            MsgrAvatar(photo: conv.photoSecondaire, nom: "•", teinte: 0x3A3A3C, taille: taille * 0.62)
                .overlay(Circle().stroke(MsgrStyle.fond, lineWidth: 2.5))
        }
        .frame(width: taille, height: taille)
    }
}

/// Choisit automatiquement l'avatar simple ou le cluster selon le type de conversation.
struct MsgrAvatarConv: View {
    let conv: MsgrConversation
    var taille: CGFloat = 58
    var body: some View {
        if conv.groupe, conv.photoSecondaire != nil {
            MsgrAvatarCluster(conv: conv, taille: taille)
        } else {
            MsgrAvatar(photo: conv.photo, nom: conv.nom, teinte: conv.teinte, taille: taille)
        }
    }
}

/// Carte de réglages `#1F2326`, rayon 14 (e035, e080).
struct MsgrCarte<Contenu: View>: View {
    @ViewBuilder let contenu: Contenu
    var body: some View {
        VStack(spacing: 0) { contenu }
            .background(RoundedRectangle(cornerRadius: 14).fill(MsgrStyle.carte))
    }
}

/// Séparateur interne de carte `#303437`, aligné sous le texte.
struct MsgrSeparateurCarte: View {
    var body: some View {
        Rectangle().fill(MsgrStyle.sepCarte).frame(height: 0.7).padding(.leading, 56)
    }
}

/// Ligne de carte. `valeur` rend le motif « Activé › » de la fiche (e037).
struct MsgrLigne: View {
    let symbole: String
    let titre: String
    var sousTitre: String? = nil
    var valeur: String? = nil
    var chevron: Bool = true
    var destructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Image(systemName: symbole)
                    .font(.system(size: 19))
                    .foregroundStyle(destructive ? MsgrStyle.destructif : Color.white)
                    .frame(width: 44, alignment: .leading)
                VStack(alignment: .leading, spacing: 2) {
                    Text(titre)
                        .font(.system(size: 16.5))
                        .foregroundStyle(destructive ? MsgrStyle.destructif : Color.white)
                        .multilineTextAlignment(.leading)
                    if let s = sousTitre {
                        Text(s).font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 8)
                if let v = valeur {
                    Text(v).font(.system(size: 16)).foregroundStyle(MsgrStyle.inactif)
                }
                if chevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(MsgrStyle.inactif)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// En-tête d'écran poussé : chevron seul à gauche, titre centré, action facultative à droite (e090, e081).
struct MsgrEnTetePile<Droite: View>: View {
    let titre: String
    var sousTitre: String? = nil
    var teinteChevron: Color = .white
    let retour: () -> Void
    @ViewBuilder let droite: Droite

    var body: some View {
        ZStack {
            VStack(spacing: 1) {
                Text(titre).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                if let s = sousTitre {
                    Text(s).font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
                }
            }
            HStack {
                Button(action: retour) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(teinteChevron)
                        .frame(width: 44, height: 40, alignment: .leading)
                }
                .buttonStyle(.plain)
                Spacer()
                droite
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.vertical, 6)
    }
}

/// Pilule d'onglet grise (e055 « Photos », e088 « VOUS CONNAISSEZ PEUT-ÊTRE »).
struct MsgrPilule: View {
    let titre: String
    var actif: Bool = false
    var chevron: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(titre)
                    .font(.system(size: 15.5, weight: actif ? .semibold : .regular))
                    .foregroundStyle(actif ? Color.white : MsgrStyle.inactif)
                if chevron {
                    Image(systemName: "chevron.down").font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(actif ? Color.white : MsgrStyle.inactif)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(Capsule().fill(actif ? MsgrStyle.carte : Color.clear))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// Bouton plein bleu Messenger (`#0F5BFC`), en capsule (e076, e100).
struct MsgrBoutonPlein: View {
    let titre: String
    var fond: Color = MsgrStyle.boutonPlein
    var couleurTexte: Color = .white
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(titre)
                .font(.system(size: 15.5, weight: .semibold))
                .foregroundStyle(couleurTexte)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(fond))
        }
        .buttonStyle(.plain)
    }
}

/// État vide sobre, réutilisé par Communautés, Invitations par message, Messages épinglés.
struct MsgrEtatVide: View {
    let titre: String
    var detail: String = ""
    var body: some View {
        VStack(spacing: 6) {
            Text(titre).font(.system(size: 19, weight: .semibold)).foregroundStyle(MsgrStyle.inactif)
            if !detail.isEmpty {
                Text(detail).font(.system(size: 15)).foregroundStyle(MsgrStyle.inactif)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }
}

extension MsgrEnTetePile where Droite == EmptyView {
    init(titre: String, sousTitre: String? = nil, teinteChevron: Color = .white,
         retour: @escaping () -> Void) {
        self.init(titre: titre, sousTitre: sousTitre, teinteChevron: teinteChevron,
                  retour: retour, droite: { EmptyView() })
    }
}

// ============================================================================
// MARK: - 6. RACINE + BARRE D'ONGLETS
// ============================================================================

/// Racine de l'app (appelée par la coque : `MessengerVue().coquilleSarah()`).
struct MessengerVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    @State private var onglet: Int = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0
    @State private var demandeRecherche: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            MsgrStyle.fond.ignoresSafeArea()
            contenuOnglet
                .padding(.bottom, 96)
            metaAI
            barreBasse
        }
        .preferredColorScheme(.dark)
        .onChange(of: store.ongletDemande) { _, nouveau in
            if let n = nouveau { onglet = n; store.ongletDemande = nil }
        }
    }

    @ViewBuilder private var contenuOnglet: some View {
        switch onglet {
        case 1: MsgrStoriesVue()
        case 2: MsgrNotificationsVue()
        case 3: MsgrMenuVue()
        default: MsgrDiscussionsVue(demandeRecherche: demandeRecherche)
        }
    }

    private var barreBasse: some View {
        VStack(spacing: 0) {
            MsgrBarreOnglets(onglet: $onglet)
            BarreHome(action: { dismiss() }, sombre: false)
        }
        .background(MsgrStyle.barreOnglets.ignoresSafeArea(edges: .bottom))
    }

    // Pastille Meta AI (e001) sur Discussions, FAB fleur seule ailleurs (e075, e080).
    // A) elle amène toujours au champ de recherche Meta AI, qui filtre réellement.
    private var metaAI: some View {
        HStack {
            Spacer()
            Button {
                Haptique.leger()
                if onglet != 0 { onglet = 0 }
                demandeRecherche += 1
            } label: {
                HStack(spacing: 9) {
                    MsgrFleurMeta(taille: 26)
                    if onglet == 0 {
                        Text("Demander à Meta AI")
                            .font(.system(size: 16, weight: .medium)).foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, onglet == 0 ? 16 : 13)
                .padding(.vertical, 13)
                .background(Capsule().fill(Color(hex: 0x1A1A1C)))
            }
            .buttonStyle(.plain)
        }
        .padding(.trailing, MsgrStyle.margeLaterale)
        .padding(.bottom, 100)
    }
}

/// Fleur Meta AI (dégradé violet/bleu) — approximation maison assumée (D55).
struct MsgrFleurMeta: View {
    var taille: CGFloat = 26
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(MsgrFleurMeta.degrade)
                    .frame(width: taille * 0.30, height: taille * 0.30)
                    .offset(y: -taille * 0.28)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
        .frame(width: taille, height: taille)
    }
    static let degrade = LinearGradient(colors: [Color(hex: 0x7B3FE4), Color(hex: 0x3454FF)],
                                        startPoint: .top, endPoint: .bottom)
}

struct MsgrBarreOnglets: View {
    @Binding var onglet: Int
    var body: some View {
        HStack(spacing: 0) {
            MsgrOngletItem(indice: 0, titre: "Discussions", actif: onglet == 0) { onglet = 0 }
            MsgrOngletItem(indice: 1, titre: "Stories", actif: onglet == 1) { onglet = 1 }
            MsgrOngletItem(indice: 2, titre: "Notifications", actif: onglet == 2) { onglet = 2 }
            MsgrOngletItem(indice: 3, titre: "Menu", actif: onglet == 3) { onglet = 3 }
        }
        .padding(.top, 9)
        .padding(.bottom, 4)
    }
}

/// Un onglet. (C) Le badge rouge « 2 » de l'ancien code est SUPPRIMÉ : aucune frame n'en montre.
struct MsgrOngletItem: View {
    let indice: Int
    let titre: String
    let actif: Bool
    let action: () -> Void

    private var teinte: Color { actif ? MsgrStyle.accent : MsgrStyle.inactif }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                glyphe.frame(height: 24)
                Text(titre).font(.system(size: 10)).foregroundStyle(teinte)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var glyphe: some View {
        switch indice {
        case 1:
            // Deux rectangles verticaux (e001) — aucun symbole SF ne correspond.
            HStack(spacing: 2.5) {
                RoundedRectangle(cornerRadius: 2.5).fill(teinte).frame(width: 11, height: 21)
                RoundedRectangle(cornerRadius: 2.5).fill(teinte).frame(width: 6, height: 21)
            }
        case 2:
            Image(systemName: "bell.fill").font(.system(size: 20)).foregroundStyle(teinte)
        case 3:
            Image(systemName: "line.3.horizontal").font(.system(size: 21, weight: .semibold)).foregroundStyle(teinte)
        default:
            Image(systemName: "bubble.left.fill").font(.system(size: 21)).foregroundStyle(teinte)
        }
    }
}

// ============================================================================
// MARK: - 7. ONGLET DISCUSSIONS (e001, e023, e024, e073, e106)
// ============================================================================

struct MsgrDiscussionsVue: View {
    var demandeRecherche: Int = 0
    @ObservedObject private var store = MessengerStore.partage
    @State private var recherche: String = ""
    @State private var convOuverte: MsgrConversation? = nil
    @State private var nouveauMessage = false
    @State private var editeurNote = false
    @State private var noteOuverte: MsgrNote? = nil
    @State private var storyOuverte: MsgrStory? = nil
    @FocusState private var champActif: Bool

    private var visibles: [MsgrConversation] {
        let q = recherche.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return store.conversations }
        return store.conversations.filter {
            $0.nom.lowercased().contains(q) || $0.apercu.lowercased().contains(q)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                enTete
                champRecherche
                if recherche.isEmpty { rangeeHaute }
                liste
                Spacer(minLength: 24)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: demandeRecherche) { _, _ in champActif = true }
        .fullScreenCover(item: $convOuverte) { c in MsgrConversationVue(conv: c) }
        .fullScreenCover(isPresented: $nouveauMessage) {
            MsgrNouveauMessageVue { conv in
                nouveauMessage = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { convOuverte = conv }
            }
        }
        .sheet(isPresented: $editeurNote) { MsgrEditeurNoteVue() }
        .sheet(item: $noteOuverte) { n in MsgrNoteAmieVue(note: n) }
        .fullScreenCover(item: $storyOuverte) { s in MsgrVisionneuseStoryVue(story: s) }
    }

    // ————— En-tête : wordmark 29 pt bold, ✎, logo Facebook + badge 8
    private var enTete: some View {
        HStack(spacing: 18) {
            Text("messenger")
                .font(.system(size: 29, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            Button { nouveauMessage = true } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 22, weight: .regular)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            boutonFacebook
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.top, 6)
        .padding(.bottom, 12)
    }

    // §4.3 — A) le logo ouvre RÉELLEMENT l'app Facebook de la coque, via le Routeur inter-apps.
    private var boutonFacebook: some View {
        Button {
            Haptique.leger()
            Routeur.partage.allerFacebook()
        } label: {
            ZStack(alignment: .topTrailing) {
                Circle().fill(Color(hex: 0x0866FF)).frame(width: 31, height: 31)
                    .overlay(
                        Text("f").font(.system(size: 21, weight: .heavy)).foregroundStyle(.white)
                            .offset(y: 1)
                    )
                    .clipShape(Circle())
                Text("8")
                    .font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                    .frame(minWidth: 17, minHeight: 17)
                    .background(Circle().fill(MsgrStyle.rouge))
                    .offset(x: 6, y: -6)
            }
            .frame(width: 34, height: 34)
        }
        .buttonStyle(.plain)
    }

    // ————— Champ Meta AI : recherche RÉELLE (jamais de micro de dictée, règle Joachim)
    private var champRecherche: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium)).foregroundStyle(MsgrStyle.inactif)
            TextField("", text: $recherche, prompt: Text("Demandez à Meta AI ou faites une rech…")
                .foregroundColor(MsgrStyle.inactif))
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .focused($champActif)
                .submitLabel(.search)
            if !recherche.isEmpty {
                Button { recherche = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17)).foregroundStyle(MsgrStyle.inactif)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 37)
        .background(Capsule().fill(MsgrStyle.champ))
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 14)
    }

    // ————— Rangée du haut : « Votre note » + notes et stories des amis (§4.9)
    private var rangeeHaute: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                MsgrTuileVotreNote(texte: store.maNote) { editeurNote = true }
                ForEach(store.notes) { n in
                    MsgrTuileNote(note: n) { noteOuverte = n }
                }
                ForEach(store.stories) { s in
                    MsgrTuileStory(story: s) { storyOuverte = s }
                }
            }
            .padding(.horizontal, MsgrStyle.margeLaterale)
            .padding(.bottom, 10)
        }
    }

    private var liste: some View {
        VStack(spacing: 0) {
            if visibles.isEmpty {
                MsgrEtatVide(titre: "Aucun résultat",
                             detail: "Aucune discussion ne correspond à « \(recherche) ».")
                    .padding(.vertical, 50)
            } else {
                ForEach(visibles) { c in
                    MsgrRangeeConv(conv: c) {
                        store.marquerLue(c.id)
                        convOuverte = c
                    }
                }
            }
        }
    }
}

/// Rangée de conversation : pas 76 pt, avatar 58, nom 17,5, aperçu 15,5 (§2.2).
struct MsgrRangeeConv: View {
    let conv: MsgrConversation
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                MsgrAvatarConv(conv: conv, taille: MsgrStyle.avatarListe)
                VStack(alignment: .leading, spacing: 3) {
                    Text(conv.nom)
                        .font(.system(size: 17.5, weight: conv.nonLu ? .semibold : .regular))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("\(conv.apercu) · \(conv.date)")
                        .font(.system(size: 15.5, weight: conv.nonLu ? .medium : .regular))
                        .foregroundStyle(conv.nonLu ? Color.white : MsgrStyle.inactif)
                        .lineLimit(1)
                }
                Spacer(minLength: 6)
                accessoireDroit
            }
            .padding(.horizontal, MsgrStyle.margeLaterale)
            .frame(height: MsgrStyle.pasRangee)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // TODO tournage : la ligne NON LUE n'a jamais été filmée (§5-7). Rendu minimal :
    // gras + point bleu, à confirmer avec la vidéo.
    @ViewBuilder private var accessoireDroit: some View {
        if conv.nonLu {
            Circle().fill(MsgrStyle.accent).frame(width: 11, height: 11)
        } else if let cle = conv.lecteurApercu {
            MsgrAvatar(photo: cle, nom: conv.nom, teinte: conv.teinte, taille: 13)
        } else if conv.sourdine {
            Image(systemName: "bell.slash.fill").font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
        }
    }
}

// ============================================================================
// MARK: - 8. NOTES ET STORIES (rangée haute + visionneuses)
// ============================================================================

/// « Votre note » : avatar 58 pt + bulle grise ancrée -16 pt au-dessus (e001).
struct MsgrTuileVotreNote: View {
    let texte: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .top) {
                    MsgrAvatar(photo: "p04", nom: "Sarah", teinte: 0x5B7CFA, taille: MsgrStyle.avatarListe)
                        .padding(.top, 14)
                    bulle
                }
                Text("Votre note").font(.system(size: 12)).foregroundStyle(MsgrStyle.inactif)
            }
            .frame(width: 78)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var bulle: some View {
        Text(texte.isEmpty ? "Partagez une pensé." : texte)
            .font(.system(size: 10.5))
            .foregroundStyle(.white)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 74)
            .padding(.horizontal, 8).padding(.vertical, 5)
            .background(RoundedRectangle(cornerRadius: 11).fill(MsgrStyle.champ))
    }
}

/// Note d'un ami : même géométrie, avec son texte.
struct MsgrTuileNote: View {
    let note: MsgrNote
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .top) {
                    MsgrAvatar(photo: note.photo, nom: note.auteur, teinte: note.teinte,
                               taille: MsgrStyle.avatarListe)
                        .padding(.top, 14)
                    Text(note.texte)
                        .font(.system(size: 10.5)).foregroundStyle(.white)
                        .lineLimit(2).multilineTextAlignment(.center)
                        .frame(maxWidth: 74)
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 11).fill(MsgrStyle.champ))
                }
                Text(prenom).font(.system(size: 12)).foregroundStyle(MsgrStyle.inactif).lineLimit(1)
            }
            .frame(width: 78)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    private var prenom: String { String(note.auteur.split(separator: " ").first ?? "") }
}

/// Story d'un ami : anneau dégradé si non vue.
struct MsgrTuileStory: View {
    let story: MsgrStory
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                MsgrAvatar(photo: story.avatar ?? story.photo, nom: story.auteur,
                           teinte: story.teinte, taille: 54)
                    .padding(3)
                    .overlay(anneau)
                    .padding(.top, 14)
                Text(prenom).font(.system(size: 12)).foregroundStyle(MsgrStyle.inactif).lineLimit(1)
            }
            .frame(width: 78)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    private var prenom: String { String(story.auteur.split(separator: " ").first ?? "") }
    @ViewBuilder private var anneau: some View {
        if story.vue {
            Circle().stroke(MsgrStyle.inactif.opacity(0.5), lineWidth: 2)
        } else {
            Circle().stroke(MsgrFleurMeta.degrade, lineWidth: 2.5)
        }
    }
}

/// Rédaction d'une note. TODO tournage : §5-10 (jamais filmé) — feuille minimale, sans chrome inventé.
struct MsgrEditeurNoteVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    @State private var texte: String = ""
    @FocusState private var actif: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Annuler") { dismiss() }
                    .font(.system(size: 16)).foregroundStyle(MsgrStyle.accent)
                Spacer()
                Text("Note").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                Spacer()
                Button("Partager") {
                    store.maNote = texte.trimmingCharacters(in: .whitespaces)
                    Haptique.leger()
                    dismiss()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(texte.isEmpty ? MsgrStyle.inactif : MsgrStyle.accent)
                .disabled(texte.isEmpty)
            }
            .padding(.horizontal, MsgrStyle.margeLaterale).padding(.vertical, 14)

            MsgrAvatar(photo: "p04", nom: "Sarah", teinte: 0x5B7CFA, taille: 74).padding(.top, 20)

            TextField("", text: $texte, prompt: Text("Partagez une pensé.")
                .foregroundColor(MsgrStyle.inactif), axis: .vertical)
                .font(.system(size: 18))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .focused($actif)
                .lineLimit(1...3)
                .padding(.horizontal, 18).padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 18).fill(MsgrStyle.champ))
                .padding(.horizontal, 34).padding(.top, 18)

            Text("Votre note disparaît au bout de 24 heures.")
                .font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif).padding(.top, 14)

            Spacer()
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onAppear { texte = store.maNote; actif = true }
    }
}

/// Note d'une amie : bulle + réponse réelle (envoyée dans la conversation correspondante).
struct MsgrNoteAmieVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let note: MsgrNote
    @State private var reponse: String = ""
    @State private var envoye = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(MsgrStyle.margeLaterale)

            ZStack(alignment: .top) {
                MsgrAvatar(photo: note.photo, nom: note.auteur, teinte: note.teinte, taille: 96)
                    .padding(.top, 22)
                Text(note.texte)
                    .font(.system(size: 16)).foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 220)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 16).fill(MsgrStyle.champ))
            }
            Text(note.auteur).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white).padding(.top, 14)
            Text(note.expiration).font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)

            Spacer()

            if envoye {
                Text("Réponse envoyée").font(.system(size: 14)).foregroundStyle(MsgrStyle.inactif)
                    .padding(.bottom, 12)
            }
            barreReponse
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var barreReponse: some View {
        HStack(spacing: 12) {
            TextField("", text: $reponse,
                      prompt: Text("Répondre à \(note.auteur)…").foregroundColor(MsgrStyle.inactif))
                .font(.system(size: 16)).foregroundStyle(.white)
                .padding(.horizontal, 16).frame(height: 42)
                .background(Capsule().fill(MsgrStyle.champ))
            Button {
                envoyerReponse()
            } label: {
                Image(systemName: "paperplane.fill").font(.system(size: 21))
                    .foregroundStyle(reponse.isEmpty ? MsgrStyle.inactif : MsgrStyle.accent)
            }
            .buttonStyle(.plain)
            .disabled(reponse.isEmpty)
        }
        .padding(.horizontal, MsgrStyle.margeLaterale).padding(.bottom, 26)
    }

    private func envoyerReponse() {
        guard !reponse.isEmpty else { return }
        if let conv = store.conversations.first(where: { $0.nom == note.auteur }) {
            store.envoyer(.texte(reponse), dans: conv.id)
        }
        reponse = ""
        envoye = true
        Haptique.leger()
    }
}

/// Visionneuse de story (e067–e072) : barres de progression, en-tête, légende, réponses ❤️😆😮.
struct MsgrVisionneuseStoryVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let story: MsgrStory
    @State private var progression: CGFloat = 0
    @State private var reponse: String = ""
    @State private var confirmation: String? = nil
    private let tic = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            carte
            barreBasse
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onReceive(tic) { _ in
            if progression < 1 { progression += 0.0035 } else { dismiss() }
        }
    }

    private var carte: some View {
        ZStack(alignment: .top) {
            Color(hex: 0x1A1A1C)
                .overlay(image)
                .clipped()
            LinearGradient(colors: [Color.black.opacity(0.45), .clear],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 120)
            VStack(spacing: 10) {
                barreProgression
                enTete
            }
            .padding(.horizontal, 12).padding(.top, 10)
            VStack {
                Spacer()
                if !story.legende.isEmpty { legende }
            }
            .padding(.bottom, 18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 6)
        .padding(.top, 6)
    }

    @ViewBuilder private var image: some View {
        if let cle = story.photo, let img = ChargeurPhoto.image(cle) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            LinearGradient(colors: [Color(hex: story.teinte), Color(hex: story.teinte).opacity(0.4)],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    private var barreProgression: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.35)).frame(height: 3)
                Capsule().fill(Color.white).frame(width: geo.size.width * progression, height: 3)
            }
        }
        .frame(height: 3)
    }

    private var enTete: some View {
        HStack(spacing: 9) {
            MsgrAvatar(photo: story.avatar ?? story.photo, nom: story.auteur,
                       teinte: story.teinte, taille: 34)
            Text(story.auteur).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                .lineLimit(1)
            Text(story.age).font(.system(size: 15)).foregroundStyle(.white.opacity(0.85))
            Spacer(minLength: 4)
            Image(systemName: "ellipsis").font(.system(size: 18, weight: .semibold)).foregroundStyle(.white)
            Image(systemName: "speaker.wave.2.fill").font(.system(size: 16)).foregroundStyle(.white)
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
    }

    private var legende: some View {
        Text(story.legende)
            .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(Capsule().fill(Color.black.opacity(0.35)))
    }

    private var barreBasse: some View {
        VStack(spacing: 6) {
            if let c = confirmation {
                Text(c).font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
            }
            HStack(spacing: 14) {
                TextField("", text: $reponse,
                          prompt: Text("Envoyer un message").foregroundColor(MsgrStyle.inactif))
                    .font(.system(size: 16)).foregroundStyle(.white)
                    .padding(.horizontal, 16).frame(height: 44)
                    .background(Capsule().fill(MsgrStyle.champ))
                    .onSubmit { envoyer(reponse) }
                ForEach(["❤️", "😆", "😮"], id: \.self) { e in
                    Button { envoyer(e) } label: { Text(e).font(.system(size: 28)) }
                        .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 10).padding(.vertical, 10)
    }

    private func envoyer(_ texte: String) {
        let t = texte.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        if let conv = store.conversations.first(where: { $0.nom == story.auteur }) {
            store.envoyer(.texte(t), dans: conv.id)
            confirmation = "Envoyé à \(story.auteur)"
        } else {
            confirmation = "Envoyé"
        }
        reponse = ""
        Haptique.leger()
    }
}

// ============================================================================
// MARK: - 9. MOTEUR DE FIL (P0-3 — espacements 3 / 13 / 17, avatar 28 pt, bulles 17 pt)
// ============================================================================

/// Mode d'appel : la vidéo et l'audio sont deux écrans DISTINCTS (§4.7).
enum MsgrModeAppel: String, Identifiable, Equatable {
    case vocal, video
    var id: String { rawValue }
}

/// Bulle de texte. Padding 11/9, radius 18, texte 17 pt (§2.3).
struct MsgrBulleTexte: View {
    let texte: String
    let deMoi: Bool
    var theme: Bool = false

    private var fond: Color {
        if deMoi { return MsgrStyle.bulleEnvoi }
        return theme ? MsgrStyle.themeRecue : MsgrStyle.bulleRecue
    }

    var body: some View {
        Text(texte)
            .font(.system(size: 17))
            .foregroundStyle(.white)
            .lineSpacing(3)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: MsgrStyle.rayonBulle, style: .continuous).fill(fond))
    }
}

/// Bulle photo (e019–e022) : image radius 18 + flèche de téléchargement.
struct MsgrBullePhoto: View {
    let cle: String
    let deMoi: Bool
    @State private var telecharge = false

    var body: some View {
        Color.clear
            .frame(width: 186, height: 232)
            .overlay(image)
            .clipShape(RoundedRectangle(cornerRadius: MsgrStyle.rayonBulle, style: .continuous))
            .overlay(alignment: .bottomTrailing) { bouton }
    }

    @ViewBuilder private var image: some View {
        if let img = ChargeurPhoto.image(cle) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            LinearGradient(colors: [Color(hex: 0x3A3A3F), Color(hex: 0x232327)],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    // A) le téléchargement produit un vrai retour visuel (D82).
    private var bouton: some View {
        Button {
            Haptique.leger()
            telecharge = true
        } label: {
            Image(systemName: telecharge ? "checkmark" : "arrow.down")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.black.opacity(0.45)))
        }
        .buttonStyle(.plain)
        .padding(8)
    }
}

/// Bulle vocale (e017–e020) : lecture + forme d'onde + durée.
struct MsgrBulleVocale: View {
    let duree: String
    let deMoi: Bool
    @State private var lecture = false

    private static let hauteurs: [CGFloat] = [6, 11, 17, 9, 14, 20, 8, 13, 18, 10, 7, 16, 12, 19, 9, 14, 7, 11]

    var body: some View {
        HStack(spacing: 9) {
            Button {
                Haptique.leger()
                lecture.toggle()
            } label: {
                Image(systemName: lecture ? "pause.fill" : "play.fill")
                    .font(.system(size: 15)).foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.white.opacity(0.18)))
            }
            .buttonStyle(.plain)
            HStack(spacing: 2.5) {
                ForEach(Array(MsgrBulleVocale.hauteurs.enumerated()), id: \.offset) { _, h in
                    Capsule().fill(Color.white.opacity(lecture ? 0.95 : 0.6))
                        .frame(width: 2.5, height: h)
                }
            }
            Text(duree).font(.system(size: 13)).foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: MsgrStyle.rayonBulle, style: .continuous)
            .fill(deMoi ? MsgrStyle.bulleEnvoi : MsgrStyle.bulleRecue))
    }
}

/// Carte de localisation partagée (fil de Julie Ferrand).
struct MsgrBulleLocalisation: View {
    let legende: String
    let deMoi: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            carte
            Text(legende)
                .font(.system(size: 14)).foregroundStyle(.white)
                .padding(.horizontal, 11).padding(.vertical, 9)
                .frame(width: 214, alignment: .leading)
        }
        .background(RoundedRectangle(cornerRadius: MsgrStyle.rayonBulle, style: .continuous)
            .fill(deMoi ? MsgrStyle.bulleEnvoi : MsgrStyle.bulleRecue))
    }

    private var carte: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x27333A), Color(hex: 0x1B252B)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(.white, MsgrStyle.rouge)
        }
        .frame(width: 214, height: 108)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: MsgrStyle.rayonBulle,
                                          bottomLeadingRadius: 0,
                                          bottomTrailingRadius: 0,
                                          topTrailingRadius: MsgrStyle.rayonBulle))
    }
}

/// Bloc d'appel (e009, e015) : 107 pt, rond 23 pt, bouton « Rappeler » gris plein pleine largeur.
struct MsgrBlocAppel: View {
    let manque: Bool
    let detail: String
    let rappeler: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(manque ? MsgrStyle.rouge : MsgrStyle.rondAppel)
                    .frame(width: 23, height: 23)
                    .overlay(
                        Image(systemName: manque ? "phone.down.fill" : "phone.arrow.down.left.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    )
                VStack(alignment: .leading, spacing: 1) {
                    Text(manque ? "Appel vocal manqué" : "Appel vocal")
                        .font(.system(size: 15.5, weight: .semibold)).foregroundStyle(.white)
                    Text(detail).font(.system(size: 13.5)).foregroundStyle(MsgrStyle.inactif)
                }
            }
            Button(action: rappeler) {
                Text("Rappeler")
                    .font(.system(size: 14.5, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 27)
                    .background(RoundedRectangle(cornerRadius: 8).fill(MsgrStyle.rappeler))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(width: 205)
        .background(RoundedRectangle(cornerRadius: 16).fill(MsgrStyle.bulleRecue))
    }
}

/// Ligne centrée : horodatage (e009) ou message système (e027, e091).
struct MsgrLigneCentree: View {
    let texte: String
    let systeme: Bool
    var body: some View {
        Text(texte)
            .font(.system(size: systeme ? 14 : 12.5))
            .foregroundStyle(MsgrStyle.inactif)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
    }
}

/// Pastille de réaction sous la bulle (e009 ❤️, e027 ❤️ 8).
struct MsgrPastilleReaction: View {
    let emoji: String
    let compteur: Int
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text(emoji).font(.system(size: 13))
                if compteur > 0 {
                    Text("\(compteur)").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color(hex: 0x1C1C1E)))
            .overlay(Capsule().strokeBorder(MsgrStyle.fond, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}

/// Rangée d'accusés de lecture (⌀ 13 pt ; 3 avatars en groupe, e027).
struct MsgrLecteurs: View {
    let cles: [String]
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(cles.enumerated()), id: \.offset) { _, cle in
                MsgrAvatar(photo: cle, nom: "•", teinte: 0x3A3A3C, taille: 13)
            }
        }
    }
}

/// Une rangée du fil : avatar 28 pt + contenu + réaction + accusés.
struct MsgrRangeeMessage: View {
    let message: MsgrMessage
    let conv: MsgrConversation
    let premierDeRafale: Bool
    let dernierDeRafale: Bool
    let appuiLong: () -> Void
    let tapReaction: () -> Void
    let rappeler: () -> Void

    var body: some View {
        if message.estCentre {
            ligneCentree
        } else {
            ligneBulle
        }
    }

    @ViewBuilder private var ligneCentree: some View {
        switch message.contenu {
        case .horodatage(let t): MsgrLigneCentree(texte: t, systeme: false)
        case .systeme(let t): MsgrLigneCentree(texte: t, systeme: true)
        default: EmptyView()
        }
    }

    private var ligneBulle: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.deMoi { Spacer(minLength: 56) }
            if !message.deMoi { zoneAvatar }
            colonne
            if !message.deMoi { Spacer(minLength: 56) }
        }
        .padding(.leading, message.deMoi ? MsgrStyle.margeLaterale : 12)
        .padding(.trailing, message.deMoi ? 10 : MsgrStyle.margeLaterale)
    }

    private var colonne: some View {
        VStack(alignment: message.deMoi ? .trailing : .leading, spacing: 2) {
            if afficherAuteur, let a = message.auteur {
                Text(a).font(.system(size: 12)).foregroundStyle(MsgrStyle.inactif)
                    .padding(.leading, 8)
            }
            contenu
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: 0.35) {
                    Haptique.leger()
                    appuiLong()
                }
            if aUneReaction {
                MsgrPastilleReaction(emoji: emojiAffiche, compteur: message.compteurReaction,
                                     action: tapReaction)
                    .padding(.top, -7)
                    .padding(message.deMoi ? .trailing : .leading, 10)
            }
            if !message.lecteurs.isEmpty {
                MsgrLecteurs(cles: message.lecteurs).padding(.top, 1)
            }
        }
    }

    @ViewBuilder private var contenu: some View {
        switch message.contenu {
        case .texte(let t):
            MsgrBulleTexte(texte: t, deMoi: message.deMoi, theme: conv.theme)
        case .photo(let cle):
            MsgrBullePhoto(cle: cle, deMoi: message.deMoi)
        case .vocal(let d):
            MsgrBulleVocale(duree: d, deMoi: message.deMoi)
        case .autocollant(let e):
            Text(e).font(.system(size: 62))
        case .localisation(let l):
            MsgrBulleLocalisation(legende: l, deMoi: message.deMoi)
        case .appel(let manque, let detail):
            MsgrBlocAppel(manque: manque, detail: detail, rappeler: rappeler)
        case .systeme, .horodatage:
            EmptyView()
        }
    }

    private var afficherAuteur: Bool {
        conv.groupe && !message.deMoi && premierDeRafale && message.auteur != nil
    }
    private var aUneReaction: Bool {
        !message.reactions.isEmpty || message.compteurReaction > 0
    }
    private var emojiAffiche: String {
        message.reactions.first ?? "❤️"
    }

    @ViewBuilder private var zoneAvatar: some View {
        Group {
            if dernierDeRafale {
                MsgrAvatar(photo: message.photoAuteur ?? conv.photo,
                           nom: message.auteur ?? conv.nom,
                           teinte: conv.teinte,
                           taille: MsgrStyle.avatarFil)
            } else {
                Color.clear.frame(width: MsgrStyle.avatarFil, height: 1)
            }
        }
        .frame(width: MsgrStyle.avatarFil)
        .padding(.trailing, 13)
    }
}

// ============================================================================
// MARK: - 10. BARRE DE SAISIE (P0-4 — ordre exact §2.4, 6 éléments, tous câblés)
// ============================================================================

struct MsgrBarreSaisie: View {
    @Binding var saisie: String
    var focus: FocusState<Bool>.Binding
    let ouvrirPlus: () -> Void
    let ouvrirViseur: () -> Void
    let ouvrirPellicule: () -> Void
    let vocal: () -> Void
    let indiceMicro: () -> Void
    let ouvrirEmojis: () -> Void
    let pouce: () -> Void
    let envoyer: () -> Void

    private var vide: Bool { saisie.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        HStack(spacing: 15) {
            boutonPlus
            if vide {
                glyphe("camera.fill", 20, ouvrirViseur)
                glyphe("photo.fill", 20, ouvrirPellicule)
                micro
            }
            champ
            if vide {
                Button(action: pouce) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 22)).foregroundStyle(MsgrStyle.accent)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: envoyer) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 21)).foregroundStyle(MsgrStyle.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.vertical, 8)
    }

    // 1 — « + » rond plein bleu ⌀ 21 pt, glyphe blanc
    private var boutonPlus: some View {
        Button(action: ouvrirPlus) {
            Circle().fill(MsgrStyle.accent)
                .frame(width: 21, height: 21)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
                )
        }
        .buttonStyle(.plain)
    }

    private func glyphe(_ nom: String, _ taille: CGFloat, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: nom).font(.system(size: taille)).foregroundStyle(MsgrStyle.accent)
        }
        .buttonStyle(.plain)
    }

    // 4 — micro : appui long = message vocal ; tap simple = indice (B crédible)
    private var micro: some View {
        Image(systemName: "mic.fill")
            .font(.system(size: 19))
            .foregroundStyle(MsgrStyle.accent)
            .contentShape(Rectangle())
            .onTapGesture { indiceMicro() }
            .onLongPressGesture(minimumDuration: 0.5) {
                Haptique.leger()
                vocal()
            }
    }

    // 5 — champ « Aa » capsule 39 pt, smiley bleu À L'INTÉRIEUR à droite
    private var champ: some View {
        HStack(spacing: 8) {
            TextField("", text: $saisie,
                      prompt: Text("Aa").foregroundColor(MsgrStyle.inactif))
                .font(.system(size: 16.5))
                .foregroundStyle(.white)
                .focused(focus)
                .submitLabel(.send)
                .onSubmit { envoyer() }
            Button(action: ouvrirEmojis) {
                Image(systemName: "face.smiling.inverse")
                    .font(.system(size: 20)).foregroundStyle(MsgrStyle.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 14)
        .padding(.trailing, 8)
        .frame(height: 39)
        .background(Capsule().fill(MsgrStyle.champ))
    }
}

/// Panneau d'emojis du champ « Aa » (jamais filmé — TODO tournage §5-1).
struct MsgrPanneauEmojis: View {
    @Binding var saisie: String
    let fermer: () -> Void
    private let emojis = ["😀", "😂", "🥰", "😍", "😘", "😉", "😢", "😡", "👍", "🙏",
                          "❤️", "🔥", "🎉", "😱", "🤔", "😴", "☕️", "💪", "🥂", "✨"]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Emojis").font(.system(size: 13, weight: .semibold)).foregroundStyle(MsgrStyle.inactif)
                Spacer()
                Button("Fermer", action: fermer)
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(MsgrStyle.accent)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 10), spacing: 10) {
                ForEach(emojis, id: \.self) { e in
                    Button {
                        saisie += e
                    } label: {
                        Text(e).font(.system(size: 24))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.vertical, 10)
        .background(Color(hex: 0x121214))
    }
}

// ============================================================================
// MARK: - 11. APPUI LONG : barre de réactions + menu contextuel (e012, e013)
// ============================================================================

struct MsgrSuperpositionAppuiLong: View {
    let message: MsgrMessage
    let conv: MsgrConversation
    let poser: (String) -> Void
    let repondre: () -> Void
    let copier: () -> Void
    let traduire: () -> Void
    let plus: () -> Void
    let fermer: () -> Void

    private let emojis = ["❤️", "😂", "😮", "😢", "😡", "👍"]

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
                .onTapGesture { fermer() }
            VStack(alignment: message.deMoi ? .trailing : .leading, spacing: 12) {
                barreReactions
                apercuBulle
                carteMenu
            }
            .padding(.horizontal, MsgrStyle.margeLaterale)
        }
    }

    private var barreReactions: some View {
        HStack(spacing: 10) {
            ForEach(emojis, id: \.self) { e in
                Button { poser(e) } label: {
                    Text(e).font(.system(size: 24))
                        .opacity(message.reactions.contains(e) ? 0.45 : 1)
                }
                .buttonStyle(.plain)
            }
            Circle().fill(MsgrStyle.accent).frame(width: 26, height: 26)
                .overlay(Image(systemName: "camera.fill").font(.system(size: 12)).foregroundStyle(.white))
            Circle().fill(Color.white.opacity(0.12)).frame(width: 26, height: 26)
                .overlay(Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                    .foregroundStyle(MsgrStyle.inactif))
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 9)
        .background(Capsule().fill(MsgrStyle.bulleRecue))
    }

    private var apercuBulle: some View {
        MsgrBulleTexte(texte: message.texteBrut, deMoi: message.deMoi, theme: conv.theme)
    }

    private var carteMenu: some View {
        VStack(spacing: 0) {
            ligne("Répondre", "arrowshape.turn.up.left.fill", repondre)
            separateur
            ligne("Copier", "doc.on.doc.fill", copier)
            separateur
            ligne("Traduire", "character.book.closed.fill", traduire)
            separateur
            ligne("Plus", "ellipsis.circle.fill", plus)
        }
        .frame(width: 300)
        .background(RoundedRectangle(cornerRadius: 14).fill(MsgrStyle.menuContextuel))
    }

    private var separateur: some View {
        Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.7)
    }

    private func ligne(_ titre: String, _ symbole: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(titre).font(.system(size: 16)).foregroundStyle(.white)
                Spacer()
                Image(systemName: symbole).font(.system(size: 15)).foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Feuille « Réactions » (e011) : qui a réagi + « Appuyez pour supprimer ».
struct MsgrFeuilleReactionsVue: View {
    @Environment(\.dismiss) private var dismiss
    let message: MsgrMessage
    let conv: MsgrConversation
    let retirer: (String) -> Void

    private var lignes: [MsgrSuggestion] {
        var resultat: [MsgrSuggestion] = []
        for e in message.reactions {
            resultat.append(MsgrSuggestion(nom: "Sarah Levasseur", detail: e, photo: "p04", teinte: 0x5B7CFA))
        }
        if message.compteurReaction > 0 {
            resultat.append(MsgrSuggestion(nom: "Chloé Berthier", detail: "❤️", photo: "p12", teinte: 0xE64980))
            resultat.append(MsgrSuggestion(nom: "Léa Moreau", detail: "❤️", photo: "p18", teinte: 0x30D1C4))
        }
        return resultat
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.white.opacity(0.25)).frame(width: 38, height: 4).padding(.vertical, 10)
            Text("Réactions").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                .padding(.bottom, 10)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(lignes.enumerated()), id: \.offset) { _, l in
                        rangee(l)
                    }
                }
            }
            Text("Appuyez sur votre réaction pour la supprimer.")
                .font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
                .padding(.vertical, 14)
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
    }

    private func rangee(_ l: MsgrSuggestion) -> some View {
        Button {
            guard l.nom == "Sarah Levasseur" else { return }
            retirer(l.detail)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                MsgrAvatar(photo: l.photo, nom: l.nom, teinte: l.teinte, taille: 42)
                VStack(alignment: .leading, spacing: 1) {
                    Text(l.nom).font(.system(size: 16)).foregroundStyle(.white)
                    if l.nom == "Sarah Levasseur" {
                        Text("Appuyez pour supprimer")
                            .font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
                    }
                }
                Spacer()
                Text(l.detail).font(.system(size: 20))
            }
            .padding(.horizontal, MsgrStyle.margeLaterale)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 12. CONVERSATION (e007–e032, e089–e096)
// ============================================================================

/// En-tête : chevron, avatar 35 pt, nom 17 semibold, combiné, caméra (e009).
struct MsgrEnTeteConversation: View {
    let conv: MsgrConversation
    let retour: () -> Void
    let appelVocal: () -> Void
    let appelVideo: () -> Void
    let ouvrirFiche: () -> Void

    private var teinteChevron: Color { conv.theme ? MsgrStyle.themeAccent : MsgrStyle.accent }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: retour) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(teinteChevron)
                    .frame(width: 34, height: 40, alignment: .leading)
            }
            .buttonStyle(.plain)
            Button(action: ouvrirFiche) {
                HStack(spacing: 11) {
                    MsgrAvatarConv(conv: conv, taille: MsgrStyle.avatarEnTete)
                    Text(conv.nom)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Spacer(minLength: 8)
            if !conv.quitte {
                Button(action: appelVocal) {
                    Image(systemName: "phone.fill").font(.system(size: 21))
                        .foregroundStyle(MsgrStyle.accent)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 18)
                Button(action: appelVideo) {
                    Image(systemName: "video.fill").font(.system(size: 22))
                        .foregroundStyle(MsgrStyle.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 6)
    }
}

/// Bandeau des conversations quittées (e094) + bouton rouge « Supprimer la conversation ».
struct MsgrBandeauQuitte: View {
    let supprimer: () -> Void
    var body: some View {
        VStack(spacing: 6) {
            Text("Vous ne pouvez pas envoyer de message à ce groupe")
                .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
            Text("Vous ne faites plus partie de ce groupe. Vous ne pouvez ni envoyer ni recevoir d'appels ou de messages, sauf si vous le rejoigniez à nouveau.")
                .font(.system(size: 13.5)).foregroundStyle(MsgrStyle.inactif)
                .multilineTextAlignment(.center)
            Button(action: supprimer) {
                Text("Supprimer la conversation")
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 44)
                    .background(RoundedRectangle(cornerRadius: 12).fill(MsgrStyle.destructif))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }
}

struct MsgrConversationVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let conv: MsgrConversation

    @State private var saisie = ""
    @State private var appel: MsgrModeAppel? = nil
    @State private var ficheVisible = false
    @State private var cibleAppui: MsgrMessage? = nil
    @State private var reactionsVisibles: MsgrMessage? = nil
    @State private var viseurVisible = false
    @State private var pelliculeVisible = false
    @State private var emojisVisibles = false
    @State private var menuPlus = false
    @State private var menuPlusMessage = false
    @State private var indice: String? = nil
    @State private var citation: String? = nil
    @FocusState private var champActif: Bool

    private var courante: MsgrConversation { store.conversation(conv.id) ?? conv }
    private var messages: [MsgrMessage] { store.messages(conv.id) }

    var body: some View {
        ZStack {
            fond
            VStack(spacing: 0) {
                MsgrEnTeteConversation(conv: courante,
                                       retour: { dismiss() },
                                       appelVocal: { appel = .vocal },
                                       appelVideo: { appel = .video },
                                       ouvrirFiche: { ficheVisible = true })
                fil
                bas
                BarreHome(action: { dismiss() }, sombre: false)
            }
            if let m = cibleAppui { superposition(m) }
        }
        .preferredColorScheme(.dark)
        .onAppear { store.marquerLue(conv.id) }
        .fullScreenCover(item: $appel) { m in MsgrAppelVue(conv: courante, mode: m) }
        .fullScreenCover(isPresented: $ficheVisible) { MsgrFicheVue(conv: courante) }
        .fullScreenCover(isPresented: $viseurVisible) { viseur }
        .sheet(isPresented: $pelliculeVisible) { pellicule }
        .sheet(item: $reactionsVisibles) { m in feuilleReactions(m) }
        .confirmationDialog("Ajouter à la discussion", isPresented: $menuPlus, titleVisibility: .visible) {
            boutonsMenuPlus
        }
        .confirmationDialog("Message", isPresented: $menuPlusMessage, titleVisibility: .visible) {
            boutonsMenuMessage
        }
    }

    // ————— Fond : thème personnalisé (e091) ou noir
    @ViewBuilder private var fond: some View {
        if courante.theme {
            LinearGradient(colors: [MsgrStyle.themeFond1, MsgrStyle.themeFond2],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        } else {
            MsgrStyle.fond.ignoresSafeArea()
        }
    }

    // ————— Fil
    private var fil: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(messages.enumerated()), id: \.element.id) { i, m in
                        MsgrRangeeMessage(message: m,
                                          conv: courante,
                                          premierDeRafale: premier(i),
                                          dernierDeRafale: dernier(i),
                                          appuiLong: { cibleAppui = m },
                                          tapReaction: { reactionsVisibles = m },
                                          rappeler: { appel = .vocal })
                            .padding(.top, espacement(i))
                            .id(m.id)
                    }
                    Color.clear.frame(height: 10).id("bas")
                }
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear { proxy.scrollTo("bas", anchor: .bottom) }
            .onChange(of: messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo("bas", anchor: .bottom) }
            }
        }
    }

    // ————— Bas d'écran : bandeau (conversation quittée) ou barre de saisie
    @ViewBuilder private var bas: some View {
        if courante.quitte {
            MsgrBandeauQuitte {
                store.supprimerConversation(courante.id)
                Haptique.leger()
                dismiss()
            }
        } else {
            VStack(spacing: 0) {
                if let c = citation { apercuCitation(c) }
                if let i = indice { ligneIndice(i) }
                if emojisVisibles {
                    MsgrPanneauEmojis(saisie: $saisie) { emojisVisibles = false }
                }
                MsgrBarreSaisie(saisie: $saisie,
                                focus: $champActif,
                                ouvrirPlus: { menuPlus = true },
                                ouvrirViseur: { viseurVisible = true },
                                ouvrirPellicule: { pelliculeVisible = true },
                                vocal: { envoyerVocal() },
                                indiceMicro: { indice = "Maintenez le micro pour enregistrer un message vocal." },
                                ouvrirEmojis: { emojisVisibles.toggle() },
                                pouce: { envoyer(.texte("👍")) },
                                envoyer: { envoyerTexte() })
            }
        }
    }

    private func apercuCitation(_ c: String) -> some View {
        HStack(spacing: 8) {
            Rectangle().fill(MsgrStyle.accent).frame(width: 3, height: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text("Vous répondez").font(.system(size: 12)).foregroundStyle(MsgrStyle.inactif)
                Text(c).font(.system(size: 13.5)).foregroundStyle(.white).lineLimit(1)
            }
            Spacer()
            Button { citation = nil } label: {
                Image(systemName: "xmark").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MsgrStyle.inactif)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.vertical, 7)
    }

    private func ligneIndice(_ texte: String) -> some View {
        Text(texte)
            .font(.system(size: 12.5)).foregroundStyle(MsgrStyle.inactif)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 4)
    }

    // ————— Appui long
    @ViewBuilder private func superposition(_ m: MsgrMessage) -> some View {
        MsgrSuperpositionAppuiLong(
            message: m,
            conv: courante,
            poser: { e in
                store.basculerReaction(e, message: m.id, dans: courante.id)
                Haptique.leger()
                cibleAppui = nil
            },
            repondre: {
                citation = m.texteBrut
                cibleAppui = nil
                champActif = true
            },
            copier: {
                UIPasteboard.general.string = m.texteBrut
                indice = "Copié dans le presse-papiers."
                cibleAppui = nil
            },
            traduire: {
                indice = "Traduction indisponible hors connexion."
                cibleAppui = nil
            },
            plus: {
                cibleAppui = nil
                menuPlusMessage = true
                cibleSecondaire = m
            },
            fermer: { cibleAppui = nil }
        )
    }

    @State private var cibleSecondaire: MsgrMessage? = nil

    @ViewBuilder private var boutonsMenuPlus: some View {
        Button("Appareil photo") { viseurVisible = true }
        Button("Photos et vidéos") { pelliculeVisible = true }
        Button("Position") { envoyer(.localisation("Lyon 3e · Rue Paul Bert")) }
        Button("Autocollant") { envoyer(.autocollant("🥰")) }
        Button("Annuler", role: .cancel) {}
    }

    @ViewBuilder private var boutonsMenuMessage: some View {
        Button("Épingler") {
            if let m = cibleSecondaire { store.epingler(m.id, dans: courante.id) }
            indice = "Message épinglé."
        }
        if cibleSecondaire?.deMoi == true {
            Button("Retirer l'envoi", role: .destructive) {
                if let m = cibleSecondaire { store.retirerEnvoi(m.id, dans: courante.id) }
            }
        }
        Button("Supprimer pour vous", role: .destructive) {
            if let m = cibleSecondaire { store.supprimerMessage(m.id, dans: courante.id) }
        }
        Button("Annuler", role: .cancel) {}
    }

    private func feuilleReactions(_ m: MsgrMessage) -> some View {
        MsgrFeuilleReactionsVue(message: m, conv: courante) { e in
            store.basculerReaction(e, message: m.id, dans: courante.id)
        }
    }

    private var viseur: some View {
        MsgrViseurVue { cle in
            envoyer(.photo(cle))
        }
    }

    private var pellicule: some View {
        MsgrPelliculeVue { cle in
            envoyer(.photo(cle))
        }
    }

    // ————— Envois
    private func envoyerTexte() {
        let t = saisie.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        envoyer(.texte(citation == nil ? t : "↩︎ " + t))
        saisie = ""
        citation = nil
    }

    private func envoyerVocal() {
        envoyer(.vocal("0:07"))
    }

    private func envoyer(_ contenu: MsgrContenu) {
        store.envoyer(contenu, dans: courante.id)
        indice = nil
        emojisVisibles = false
        Haptique.leger()
    }

    // ————— Espacements (§2.3)
    private func espacement(_ i: Int) -> CGFloat {
        guard i > 0 else { return 0 }
        let m = messages[i]
        let p = messages[i - 1]
        if m.estCentre || p.estCentre { return 17 }
        if m.deMoi == p.deMoi && m.auteur == p.auteur { return 3 }
        return 13
    }

    private func premier(_ i: Int) -> Bool {
        guard i > 0 else { return true }
        let m = messages[i]
        let p = messages[i - 1]
        if p.estCentre { return true }
        return !(m.deMoi == p.deMoi && m.auteur == p.auteur)
    }

    private func dernier(_ i: Int) -> Bool {
        guard i + 1 < messages.count else { return true }
        let m = messages[i]
        let s = messages[i + 1]
        if s.estCentre { return true }
        return !(m.deMoi == s.deMoi && m.auteur == s.auteur)
    }
}

// ============================================================================
// MARK: - 13. FICHE DE DISCUSSION (e033–e040, e052, e053, e062)
// ============================================================================

/// Destinations poussées depuis la fiche. UNE seule `navigationDestination`
/// est déclarée, au niveau du `NavigationStack` (règle anti-crash de build).
enum MsgrDestinationFiche: String, Identifiable, Hashable {
    case medias, membres, sons, nouveauGroupe, moments, epingles
    case confirmations, saisie, bloquer, restreindre, signaler, personnaliser, pseudos, rechercher
    var id: String { rawValue }
}

struct MsgrFicheVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let conv: MsgrConversation
    @State private var destination: MsgrDestinationFiche? = nil
    @State private var quitter = false

    private var courante: MsgrConversation { store.conversation(conv.id) ?? conv }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    entete
                    ronds
                    sectionInfos
                    sectionActions
                    sectionConfidentialite
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, MsgrStyle.margeLaterale)
                .padding(.top, 4)
            }
            .background(MsgrStyle.fond.ignoresSafeArea())
            .safeAreaInset(edge: .top) { barreHaute }
            .safeAreaInset(edge: .bottom) { BarreHome(action: { dismiss() }, sombre: false) }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $destination) { d in
                MsgrSousEcranFiche(destination: d, conv: courante)
            }
            .alert("Quitter la discussion ?", isPresented: $quitter) {
                Button("Quitter", role: .destructive) {
                    store.quitter(courante.id)
                    dismiss()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Vous ne recevrez plus les messages de cette discussion.")
            }
        }
        .preferredColorScheme(.dark)
    }

    // Chevron seul (e035) — pas de bouton « OK ».
    private var barreHaute: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 44, height: 40, alignment: .leading)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .background(MsgrStyle.fond)
    }

    private var entete: some View {
        VStack(spacing: 8) {
            MsgrAvatarConv(conv: courante, taille: 96).padding(.top, 8)
            Text(courante.nom)
                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Button {
                destination = .personnaliser
            } label: {
                Text("Modifier le nom ou l'image")
                    .font(.system(size: 15)).foregroundStyle(MsgrStyle.accent)
            }
            .buttonStyle(.plain)
        }
    }

    private var ronds: some View {
        HStack(spacing: 26) {
            MsgrActionRonde(symbole: "person.badge.plus", titre: "Ajouter") { destination = .membres }
            MsgrActionRonde(symbole: "textformat", titre: "Pseudos") { destination = .pseudos }
            MsgrActionRonde(symbole: "magnifyingglass", titre: "Rechercher") { destination = .rechercher }
            MsgrActionRonde(symbole: "paintpalette", titre: "Personnaliser") { destination = .personnaliser }
        }
    }

    private var sectionInfos: some View {
        MsgrSectionFiche(titre: "Informations sur la discussion") {
            MsgrLigne(symbole: "photo.on.rectangle", titre: "Contenus multimédias, liens et fichiers") {
                destination = .medias
            }
            if courante.groupe {
                MsgrSeparateurCarte()
                MsgrLigne(symbole: "person.2.fill", titre: "Voir les membres de la discussion") {
                    destination = .membres
                }
            }
        }
    }

    private var sectionActions: some View {
        MsgrSectionFiche(titre: "Actions") {
            MsgrLigne(symbole: "bell", titre: "Mettre \(courante.nom) en sourdine",
                      valeur: courante.sourdine ? "Activé" : nil, chevron: false) {
                store.basculerSourdine(courante.id)
                Haptique.leger()
            }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "speaker.wave.2.fill", titre: "Sons et notifications") { destination = .sons }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "person.3.fill", titre: "Créer une nouvelle discussion de groupe") {
                destination = .nouveauGroupe
            }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "archivebox", titre: "Paramètres des moments") { destination = .moments }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "pin.fill", titre: "Messages épinglés") { destination = .epingles }
        }
    }

    private var sectionConfidentialite: some View {
        MsgrSectionFiche(titre: "Confidentialité et assistance") {
            MsgrLigne(symbole: "eye.fill", titre: "Confirmations de lecture",
                      valeur: courante.confirmationsLecture ? "Activé" : "Désactivé") {
                destination = .confirmations
            }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "ellipsis.bubble.fill", titre: "Indicateur de saisie",
                      valeur: courante.indicateurSaisie ? "Activé" : "Désactivé") {
                destination = .saisie
            }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "minus.circle.fill", titre: "Bloquer un membre") { destination = .bloquer }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "circle.slash", titre: "Restreindre") { destination = .restreindre }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "exclamationmark.triangle.fill", titre: "Signaler",
                      sousTitre: "Donnez votre avis ou signalez la conversation", chevron: false) {
                destination = .signaler
            }
            if courante.groupe {
                MsgrSeparateurCarte()
                MsgrLigne(symbole: "rectangle.portrait.and.arrow.right", titre: "Quitter la discussion",
                          chevron: false, destructive: true) { quitter = true }
            }
        }
    }
}

/// Section de la fiche : titre gris hors carte + carte `#1F2326`.
struct MsgrSectionFiche<Contenu: View>: View {
    let titre: String
    @ViewBuilder let contenu: Contenu
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titre)
                .font(.system(size: 15))
                .foregroundStyle(MsgrStyle.inactif)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 0) { contenu }
                .background(RoundedRectangle(cornerRadius: 16).fill(MsgrStyle.carte))
        }
    }
}

/// Rond d'action de la fiche (⌀ 44, fond `#1F2326`) — désormais AVEC action (D82).
struct MsgrActionRonde: View {
    let symbole: String
    let titre: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Circle().fill(MsgrStyle.carte).frame(width: 44, height: 44)
                    .overlay(Image(systemName: symbole).font(.system(size: 18)).foregroundStyle(.white))
                Text(titre).font(.system(size: 12)).foregroundStyle(.white)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Aiguillage des sous-écrans de la fiche (une seule `navigationDestination` en amont).
struct MsgrSousEcranFiche: View {
    let destination: MsgrDestinationFiche
    let conv: MsgrConversation

    var body: some View {
        switch destination {
        case .medias: MsgrMediasVue(conv: conv)
        case .membres: MsgrMembresVue(conv: conv)
        case .epingles: MsgrEpinglesVue(conv: conv)
        case .confirmations:
            MsgrBasculeVue(titre: "Confirmations de lecture",
                           explication: "Les autres personnes voient quand vous avez lu leurs messages.",
                           conv: conv, genre: .confirmations)
        case .saisie:
            MsgrBasculeVue(titre: "Indicateur de saisie",
                           explication: "Les autres personnes voient quand vous êtes en train d'écrire.",
                           conv: conv, genre: .saisie)
        case .bloquer: MsgrBloquerVue(conv: conv)
        case .sons:
            MsgrEcranSobreVue(titre: "Sons et notifications",
                              message: "Les notifications de cette discussion sont actives.",
                              detail: "Sons, aperçus et vibreur suivent les réglages du téléphone.")
        case .nouveauGroupe: MsgrNouveauGroupeVue(conv: conv)
        case .moments:
            MsgrEcranSobreVue(titre: "Paramètres des moments",
                              message: "Aucun moment partagé",
                              detail: "Les moments partagés dans cette discussion apparaîtront ici.")
        case .restreindre:
            MsgrEcranSobreVue(titre: "Restreindre",
                              message: "Cette discussion n'est pas restreinte",
                              detail: "Une discussion restreinte est déplacée dans les invitations par message.")
        case .signaler:
            MsgrEcranSobreVue(titre: "Signaler",
                              message: "Merci pour votre signalement",
                              detail: "Nous examinerons cette conversation. Personne ne saura que vous l'avez signalée.")
        case .personnaliser:
            MsgrEcranSobreVue(titre: "Personnaliser",
                              message: "Personnalisation indisponible",
                              detail: "Thème, emoji et pseudos ne peuvent pas être modifiés pour l'instant.")
        case .pseudos: MsgrPseudosVue(conv: conv)
        case .rechercher: MsgrRechercheFilVue(conv: conv)
        }
    }
}

/// Écran sobre générique — sert aux lignes jamais filmées (TODO tournage §5-12).
struct MsgrEcranSobreVue: View {
    @Environment(\.dismiss) private var dismiss
    let titre: String
    let message: String
    var detail: String = ""

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: titre) { dismiss() }
            Spacer()
            MsgrEtatVide(titre: message, detail: detail)
            Spacer()
            Spacer()
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

/// Écran « Activé / Désactivé » (e037 : la vidéo montre `Activé ›`, pas un Toggle).
struct MsgrBasculeVue: View {
    enum Genre { case confirmations, saisie }
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let titre: String
    let explication: String
    let conv: MsgrConversation
    let genre: Genre

    private var actif: Bool {
        let c = store.conversation(conv.id) ?? conv
        return genre == .confirmations ? c.confirmationsLecture : c.indicateurSaisie
    }

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: titre) { dismiss() }
            Text(explication)
                .font(.system(size: 14)).foregroundStyle(MsgrStyle.inactif)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, MsgrStyle.margeLaterale)
                .padding(.bottom, 14)
            VStack(spacing: 0) {
                choix("Activé", vrai: true)
                MsgrSeparateurCarte()
                choix("Désactivé", vrai: false)
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(MsgrStyle.carte))
            .padding(.horizontal, MsgrStyle.margeLaterale)
            Spacer()
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private func choix(_ titre: String, vrai: Bool) -> some View {
        Button {
            if genre == .confirmations {
                store.definirConfirmations(vrai, dans: conv.id)
            } else {
                store.definirIndicateur(vrai, dans: conv.id)
            }
            Haptique.leger()
        } label: {
            HStack {
                Text(titre).font(.system(size: 16.5)).foregroundStyle(.white)
                Spacer()
                if actif == vrai {
                    Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(MsgrStyle.accent)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// « Bloquer un membre » — la liste des membres, chaque ligne bloque réellement.
struct MsgrBloquerVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let conv: MsgrConversation

    private var membres: [MsgrMembre] {
        conv.membres.isEmpty
        ? [MsgrMembre(nom: conv.nom, detail: "Contact", photo: conv.photo, teinte: conv.teinte)]
        : conv.membres
    }

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: "Bloquer un membre") { dismiss() }
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(membres) { m in rangee(m) }
                }
                .padding(.horizontal, MsgrStyle.margeLaterale)
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private func rangee(_ m: MsgrMembre) -> some View {
        HStack(spacing: 12) {
            MsgrAvatar(photo: m.photo, nom: m.nom, teinte: m.teinte, taille: 44)
            Text(m.nom).font(.system(size: 16)).foregroundStyle(.white)
            Spacer()
            if store.membresBloques.contains(m.nom) {
                Text("Bloqué").font(.system(size: 14)).foregroundStyle(MsgrStyle.inactif)
            } else {
                Button("Bloquer") {
                    store.bloquer(m.nom)
                    Haptique.leger()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(MsgrStyle.destructif)
            }
        }
        .padding(.vertical, 9)
    }
}

/// Messages épinglés d'une discussion (alimentés par « Plus → Épingler »).
struct MsgrEpinglesVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let conv: MsgrConversation

    private var liste: [String] { store.messagesEpingles[conv.id] ?? [] }

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: "Messages épinglés") { dismiss() }
            if liste.isEmpty {
                Spacer()
                MsgrEtatVide(titre: "Aucun message épinglé",
                             detail: "Maintenez un message puis choisissez « Plus › Épingler ».")
                Spacer()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(liste.enumerated()), id: \.offset) { _, t in
                            HStack(spacing: 10) {
                                Image(systemName: "pin.fill").font(.system(size: 14))
                                    .foregroundStyle(MsgrStyle.inactif)
                                Text(t).font(.system(size: 16)).foregroundStyle(.white)
                                Spacer(minLength: 4)
                            }
                            .padding(.vertical, 12)
                            MsgrSeparateurCarte()
                        }
                    }
                    .padding(.horizontal, MsgrStyle.margeLaterale)
                }
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

/// Pseudos de la discussion — lecture seule, sobre (jamais filmé, §5).
struct MsgrPseudosVue: View {
    @Environment(\.dismiss) private var dismiss
    let conv: MsgrConversation

    private var membres: [MsgrMembre] {
        conv.membres.isEmpty
        ? [MsgrMembre(nom: conv.nom, detail: "Aucun pseudo", photo: conv.photo, teinte: conv.teinte)]
        : conv.membres
    }

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: "Pseudos") { dismiss() }
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(membres) { m in
                        HStack(spacing: 12) {
                            MsgrAvatar(photo: m.photo, nom: m.nom, teinte: m.teinte, taille: 44)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(m.nom).font(.system(size: 16)).foregroundStyle(.white)
                                Text("Aucun pseudo").font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 9)
                    }
                }
                .padding(.horizontal, MsgrStyle.margeLaterale)
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

/// Recherche dans le fil — filtre réellement les messages de la conversation.
struct MsgrRechercheFilVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let conv: MsgrConversation
    @State private var requete = ""

    private var resultats: [MsgrMessage] {
        let q = requete.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return [] }
        return store.messages(conv.id).filter { !$0.estCentre && $0.texteBrut.lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: "Rechercher") { dismiss() }
            champ
            if requete.isEmpty {
                Spacer()
                MsgrEtatVide(titre: "Rechercher dans la discussion",
                             detail: "Saisissez un mot pour retrouver un message.")
                Spacer()
                Spacer()
            } else if resultats.isEmpty {
                Spacer()
                MsgrEtatVide(titre: "Aucun résultat", detail: "Aucun message ne contient « \(requete) ».")
                Spacer()
                Spacer()
            } else {
                liste
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var champ: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").font(.system(size: 17)).foregroundStyle(MsgrStyle.inactif)
            TextField("", text: $requete, prompt: Text("Rechercher").foregroundColor(MsgrStyle.inactif))
                .font(.system(size: 16)).foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .frame(height: 37)
        .background(Capsule().fill(MsgrStyle.champ))
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 12)
    }

    private var liste: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(resultats) { m in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(m.deMoi ? "Vous" : (m.auteur ?? conv.nom))
                            .font(.system(size: 13, weight: .semibold)).foregroundStyle(MsgrStyle.inactif)
                        Text(m.texteBrut).font(.system(size: 16)).foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    MsgrSeparateurCarte()
                }
            }
            .padding(.horizontal, MsgrStyle.margeLaterale)
        }
    }
}

/// « Créer une nouvelle discussion de groupe » : crée RÉELLEMENT le groupe (D82).
struct MsgrNouveauGroupeVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let conv: MsgrConversation
    @State private var nom = ""
    @State private var choisis: Set<String> = []
    @State private var cree = false

    private var candidats: [MsgrConversation] { store.conversations.filter { !$0.groupe } }

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: "Nouveau groupe") { dismiss() }
            champNom
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(candidats) { c in rangee(c) }
                }
                .padding(.horizontal, MsgrStyle.margeLaterale)
            }
            if cree {
                Text("Groupe créé.").font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
                    .padding(.bottom, 6)
            }
            MsgrBoutonPlein(titre: "Créer le groupe") { creer() }
                .padding(.horizontal, MsgrStyle.margeLaterale)
                .padding(.bottom, 14)
                .opacity(peutCreer ? 1 : 0.4)
                .disabled(!peutCreer)
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var peutCreer: Bool {
        !nom.trimmingCharacters(in: .whitespaces).isEmpty && choisis.count >= 2
    }

    private var champNom: some View {
        TextField("", text: $nom, prompt: Text("Nom du groupe").foregroundColor(MsgrStyle.inactif))
            .font(.system(size: 16)).foregroundStyle(.white)
            .padding(.horizontal, 14)
            .frame(height: 39)
            .background(Capsule().fill(MsgrStyle.champ))
            .padding(.horizontal, MsgrStyle.margeLaterale)
            .padding(.bottom, 12)
    }

    private func rangee(_ c: MsgrConversation) -> some View {
        Button {
            if choisis.contains(c.nom) { choisis.remove(c.nom) } else { choisis.insert(c.nom) }
        } label: {
            HStack(spacing: 12) {
                MsgrAvatarConv(conv: c, taille: 44)
                Text(c.nom).font(.system(size: 16)).foregroundStyle(.white)
                Spacer()
                Image(systemName: choisis.contains(c.nom) ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(choisis.contains(c.nom) ? MsgrStyle.accent : MsgrStyle.inactif)
            }
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func creer() {
        let membres = candidats.filter { choisis.contains($0.nom) }
            .map { MsgrMembre(nom: $0.nom, detail: "Ajoutée par Sarah Levasseur",
                              photo: $0.photo, teinte: $0.teinte) }
        _ = store.creerGroupe(nom: nom.trimmingCharacters(in: .whitespaces), membres: membres)
        cree = true
        Haptique.leger()
    }
}

// ============================================================================
// MARK: - 14. MEMBRES (e038, e041, e042, e057–e061) + feuille d'action (e058)
// ============================================================================

struct MsgrMembresVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let conv: MsgrConversation
    @State private var admins = false
    @State private var cible: MsgrMembre? = nil
    @State private var indice: String? = nil

    private var membres: [MsgrMembre] {
        admins ? conv.membres.filter { $0.admin } : conv.membres
    }

    var body: some View {
        VStack(spacing: 0) {
            entete
            pilules
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(membres) { m in rangee(m) }
                }
                .padding(.horizontal, MsgrStyle.margeLaterale)
            }
            if let i = indice {
                Text(i).font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif).padding(.bottom, 8)
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .confirmationDialog(cible?.nom ?? "", isPresented: presentationCible, titleVisibility: .visible) {
            actionsMembre
        }
    }

    private var presentationCible: Binding<Bool> {
        Binding(get: { cible != nil }, set: { if !$0 { cible = nil } })
    }

    @ViewBuilder private var actionsMembre: some View {
        Button("Voir le profil Facebook") {
            Routeur.partage.allerFacebook()
        }
        Button("Message") {
            indice = "Discussion ouverte depuis la liste."
        }
        Button("Bloquer", role: .destructive) {
            if let m = cible { store.bloquer(m.nom) }
            indice = "Membre bloqué."
        }
        Button("Annuler", role: .cancel) {}
    }

    private var entete: some View {
        ZStack {
            VStack(spacing: 1) {
                Text("Membres").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                Text("\(conv.membres.count) personnes")
                    .font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
            }
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                Spacer()
                Button { indice = "Ajoutez des membres depuis la fiche de discussion." } label: {
                    Image(systemName: "plus").font(.system(size: 21, weight: .medium)).foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 10)
    }

    private var pilules: some View {
        HStack(spacing: 0) {
            MsgrPilule(titre: "Tous", actif: !admins) { admins = false }
                .frame(maxWidth: .infinity)
            MsgrPilule(titre: "Admins", actif: admins) { admins = true }
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 8)
    }

    private func rangee(_ m: MsgrMembre) -> some View {
        HStack(spacing: 12) {
            MsgrAvatar(photo: m.photo, nom: m.nom, teinte: m.teinte, taille: 46)
            VStack(alignment: .leading, spacing: 2) {
                Text(m.nom).font(.system(size: 16.5)).foregroundStyle(.white)
                Text(m.detail).font(.system(size: 13.5)).foregroundStyle(MsgrStyle.inactif).lineLimit(2)
            }
            Spacer(minLength: 6)
            Button { cible = m } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(MsgrStyle.inactif)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(MsgrStyle.carte))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 9)
    }
}

// ============================================================================
// MARK: - 15. CONTENU MULTIMÉDIA (e043, e044, e053–e056)
// ============================================================================

struct MsgrMediasVue: View {
    @Environment(\.dismiss) private var dismiss
    let conv: MsgrConversation
    @State private var filtre = 1                 // 0 Partagé par · 1 Photos · 2 Vidéos
    @State private var sousOnglet = 0             // 0 Contenu · 1 Fichiers · 2 Liens
    @State private var selection = false
    @State private var apercu: String? = nil

    private static let medias = ["p22", "p23", "p24", "p25", "p26", "p27", "p12", "p18", "p04"]

    private var visibles: [String] {
        conv.groupe ? MsgrMediasVue.medias : Array(MsgrMediasVue.medias.prefix(3))
    }

    var body: some View {
        VStack(spacing: 0) {
            entete
            pilules
            contenu
            sousOnglets
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .fullScreenCover(item: apercuBinding) { cle in
            MsgrApercuMediaVue(cle: cle.valeur)
        }
    }

    private var apercuBinding: Binding<MsgrCleMedia?> {
        Binding(get: { apercu.map { MsgrCleMedia(valeur: $0) } },
                set: { apercu = $0?.valeur })
    }

    private var entete: some View {
        ZStack {
            Text("Contenu multimédia").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                Spacer()
                Button { selection.toggle() } label: {
                    Text(selection ? "OK" : "Sélectionner")
                        .font(.system(size: 15.5)).foregroundStyle(MsgrStyle.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 10)
    }

    private var pilules: some View {
        HStack(spacing: 10) {
            MsgrPilule(titre: "Partagé par", actif: filtre == 0, chevron: true) { filtre = 0 }
            MsgrPilule(titre: "Photos", actif: filtre == 1) { filtre = 1 }
            MsgrPilule(titre: "Vidéos", actif: filtre == 2) { filtre = 2 }
            Spacer()
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 10)
    }

    @ViewBuilder private var contenu: some View {
        if sousOnglet != 0 || filtre == 2 || visibles.isEmpty {
            Spacer()
            MsgrEtatVide(titre: vide,
                         detail: "Réinitialisez ou ajustez vos filtres pour voir plus de résultats.")
            Spacer()
            Spacer()
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    albums
                    Text("Tous les contenus multimédias (\(visibles.count))")
                        .font(.system(size: 16)).foregroundStyle(.white)
                        .padding(.horizontal, MsgrStyle.margeLaterale)
                    grille
                }
                .padding(.top, 4)
            }
        }
    }

    private var vide: String {
        switch sousOnglet {
        case 1: return "Aucun fichier"
        case 2: return "Aucun lien"
        default: return "Aucun contenu multimédia"
        }
    }

    private var albums: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Albums").font(.system(size: 15)).foregroundStyle(MsgrStyle.inactif)
            HStack(spacing: 12) {
                Circle().fill(MsgrStyle.carte).frame(width: 44, height: 44)
                    .overlay(Image(systemName: "plus").font(.system(size: 17)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Créer des albums pour cette discussion")
                        .font(.system(size: 16)).foregroundStyle(.white)
                    Text("Une fois créés, les albums apparaissent ici")
                        .font(.system(size: 13.5)).foregroundStyle(MsgrStyle.inactif)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MsgrStyle.inactif)
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
    }

    private var grille: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
            ForEach(Array(visibles.enumerated()), id: \.offset) { _, cle in
                Button { apercu = cle } label: {
                    Color.clear
                        .frame(height: 132)
                        .overlay(vignette(cle))
                        .clipped()
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder private func vignette(_ cle: String) -> some View {
        if let img = ChargeurPhoto.image(cle) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            Rectangle().fill(Color(hex: 0x2C2C2E))
        }
    }

    private var sousOnglets: some View {
        HStack(spacing: 0) {
            sousOngletItem(0, "Contenu multimédia", "photo.on.rectangle")
            sousOngletItem(1, "Fichiers", "doc.text.fill")
            sousOngletItem(2, "Liens", "link")
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(MsgrStyle.barreOnglets)
    }

    private func sousOngletItem(_ i: Int, _ titre: String, _ symbole: String) -> some View {
        Button { sousOnglet = i } label: {
            VStack(spacing: 4) {
                Image(systemName: symbole).font(.system(size: 19))
                Text(titre).font(.system(size: 11))
            }
            .foregroundStyle(sousOnglet == i ? MsgrStyle.accent : MsgrStyle.inactif)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Enveloppe Identifiable pour présenter un média en plein écran.
struct MsgrCleMedia: Identifiable, Equatable {
    var id: String { valeur }
    let valeur: String
}

struct MsgrApercuMediaVue: View {
    @Environment(\.dismiss) private var dismiss
    let cle: String
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            image
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                            .padding(MsgrStyle.margeLaterale)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder private var image: some View {
        if let img = ChargeurPhoto.image(cle) {
            Image(uiImage: img).resizable().scaledToFit()
        } else {
            MsgrEtatVide(titre: "Aperçu indisponible")
        }
    }
}

// ============================================================================
// MARK: - 16. ONGLET STORIES (e075)
// ============================================================================

struct MsgrStoriesVue: View {
    @ObservedObject private var store = MessengerStore.partage
    @State private var storyOuverte: MsgrStory? = nil
    @State private var pelliculeVisible = false
    @State private var indice: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Stories").font(.system(size: 29, weight: .bold)).foregroundStyle(.white)
                    .padding(.horizontal, MsgrStyle.margeLaterale)
                grille
                if let i = indice {
                    Text(i).font(.system(size: 13)).foregroundStyle(MsgrStyle.inactif)
                        .padding(.horizontal, MsgrStyle.margeLaterale)
                }
                Spacer(minLength: 40)
            }
            .padding(.top, 6)
        }
        .fullScreenCover(item: $storyOuverte) { s in MsgrVisionneuseStoryVue(story: s) }
        .sheet(isPresented: $pelliculeVisible) {
            MsgrPelliculeVue { _ in
                store.maStory = true
                indice = "Story publiée. Elle disparaîtra dans 24 heures."
            }
        }
    }

    private var grille: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 14) {
            tuileAjout
            ForEach(store.stories) { s in
                MsgrTuileStoryGrille(story: s) { storyOuverte = s }
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
    }

    // Tuile 119 × 167 pt, rond blanc à glyphe noir en HAUT à gauche (e075).
    private var tuileAjout: some View {
        Button { pelliculeVisible = true } label: {
            ZStack(alignment: .topLeading) {
                Color.clear
                    .frame(height: 167)
                    .overlay(fondAjout)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Circle().fill(Color.white).frame(width: 34, height: 34)
                    .overlay(Image(systemName: "plus").font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black))
                    .padding(10)
                VStack {
                    Spacer()
                    Text("Ajouter à la story")
                        .font(.system(size: 12.5, weight: .semibold)).foregroundStyle(.white)
                        .padding(10)
                }
            }
            .frame(height: 167)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var fondAjout: some View {
        if let img = ChargeurPhoto.image("p04") {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            LinearGradient(colors: [Color(hex: 0xD9D2EC), Color(hex: 0xB9AEDA)],
                           startPoint: .top, endPoint: .bottom)
        }
    }
}

struct MsgrTuileStoryGrille: View {
    let story: MsgrStory
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                Color.clear
                    .frame(height: 167)
                    .overlay(image)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                LinearGradient(colors: [.clear, Color.black.opacity(0.55)],
                               startPoint: .center, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 6) {
                    MsgrAvatar(photo: story.avatar ?? story.photo, nom: story.auteur,
                               teinte: story.teinte, taille: 30)
                        .overlay(Circle().stroke(story.vue ? Color.white.opacity(0.4) : Color.white,
                                                 lineWidth: 2))
                    Text(story.auteur).font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(.white).lineLimit(1)
                }
                .padding(10)
            }
            .frame(height: 167)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var image: some View {
        if let cle = story.photo, let img = ChargeurPhoto.image(cle) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            LinearGradient(colors: [Color(hex: story.teinte), Color(hex: story.teinte).opacity(0.4)],
                           startPoint: .top, endPoint: .bottom)
        }
    }
}

// ============================================================================
// MARK: - 17. ONGLET NOTIFICATIONS (e076–e078)
// ============================================================================

struct MsgrNotificationsVue: View {
    @ObservedObject private var store = MessengerStore.partage
    @State private var profil: MsgrSuggestion? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Notifications").font(.system(size: 29, weight: .bold)).foregroundStyle(.white)
                    .padding(.horizontal, MsgrStyle.margeLaterale)
                    .padding(.bottom, 24)
                MsgrEtatVide(titre: "Aucune notification",
                             detail: "Si vous avez des notifications, elles apparaîtront ici.")
                    .padding(.bottom, 26)
                entete
                ForEach(store.suggestions) { s in rangee(s) }
                Spacer(minLength: 40)
            }
            .padding(.top, 6)
        }
        .sheet(item: $profil) { s in MsgrProfilSuggestionVue(suggestion: s) }
    }

    private var entete: some View {
        HStack(spacing: 6) {
            Text("Vous connaissez peut-être")
                .font(.system(size: 16)).foregroundStyle(MsgrStyle.inactif)
            Image(systemName: "info.circle").font(.system(size: 14)).foregroundStyle(MsgrStyle.inactif)
            Spacer()
            Image(systemName: "ellipsis").font(.system(size: 16, weight: .semibold))
                .foregroundStyle(MsgrStyle.inactif)
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 10)
    }

    private func rangee(_ s: MsgrSuggestion) -> some View {
        Button { profil = s } label: {
            HStack(spacing: 12) {
                MsgrAvatar(photo: s.photo, nom: s.nom, teinte: s.teinte, taille: 58)
                VStack(alignment: .leading, spacing: 2) {
                    Text(s.nom).font(.system(size: 16.5, weight: .semibold))
                        .foregroundStyle(.white).lineLimit(1)
                    if !s.detail.isEmpty {
                        Text(s.detail).font(.system(size: 14)).foregroundStyle(MsgrStyle.inactif)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 6)
                bouton(s)
            }
            .padding(.horizontal, MsgrStyle.margeLaterale)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // §4.11 — A) le bouton bascule réellement (capsule, pas radius 8).
    private func bouton(_ s: MsgrSuggestion) -> some View {
        Button {
            store.basculerAmi(s.nom)
            Haptique.leger()
        } label: {
            Text(store.amisAjoutes.contains(s.nom) ? "Demande envoyée" : "Ajouter comme ami(e)")
                .font(.system(size: 14.5, weight: .semibold))
                .foregroundStyle(store.amisAjoutes.contains(s.nom) ? MsgrStyle.inactif : Color.white)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Capsule().fill(store.amisAjoutes.contains(s.nom)
                                           ? MsgrStyle.carte : MsgrStyle.boutonPlein))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 172)
    }
}

/// Aperçu de profil d'une suggestion — sobre (jamais filmé, §5).
struct MsgrProfilSuggestionVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let suggestion: MsgrSuggestion

    var body: some View {
        VStack(spacing: 14) {
            Capsule().fill(Color.white.opacity(0.25)).frame(width: 38, height: 4).padding(.top, 10)
            MsgrAvatar(photo: suggestion.photo, nom: suggestion.nom,
                       teinte: suggestion.teinte, taille: 96).padding(.top, 10)
            Text(suggestion.nom).font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)
            Text(suggestion.detail).font(.system(size: 14)).foregroundStyle(MsgrStyle.inactif)
            MsgrBoutonPlein(titre: store.amisAjoutes.contains(suggestion.nom)
                            ? "Demande envoyée" : "Ajouter comme ami(e)") {
                store.basculerAmi(suggestion.nom)
                Haptique.leger()
            }
            .padding(.horizontal, 40)
            Button("Voir le profil Facebook") {
                Routeur.partage.allerFacebook()
            }
            .font(.system(size: 15)).foregroundStyle(MsgrStyle.accent)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(MsgrStyle.fond.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
    }
}

// ============================================================================
// MARK: - 18. ONGLET MENU (e080) — libellés et ordre exacts
// ============================================================================

enum MsgrDestinationMenu: String, Identifiable, Hashable {
    case parametres, communautes, invitationsMessage, archive, invitationsFacebook, ia
    var id: String { rawValue }
}

struct MsgrMenuVue: View {
    @State private var destination: MsgrDestinationMenu? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    titre
                    carteProfil
                    carteDeux
                    carteTrois
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, MsgrStyle.margeLaterale)
                .padding(.top, 6)
            }
            .background(MsgrStyle.fond.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $destination) { d in
                MsgrSousEcranMenu(destination: d)
            }
        }
    }

    // (C) L'icône « 4 carrés » de e080 est SUPPRIMÉE (choix de Joachim).
    private var titre: some View {
        Text("Menu").font(.system(size: 29, weight: .bold)).foregroundStyle(.white)
    }

    private var carteProfil: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                MsgrAvatar(photo: "p04", nom: "Sarah", teinte: 0x5B7CFA, taille: 44)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Sarah Levasseur").font(.system(size: 16.5)).foregroundStyle(.white)
                    Text("Changer de profil").font(.system(size: 13.5)).foregroundStyle(MsgrStyle.inactif)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "gearshape.fill", titre: "Paramètres") { destination = .parametres }
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(MsgrStyle.carte))
    }

    private var carteDeux: some View {
        VStack(spacing: 0) {
            MsgrLigne(symbole: "person.3.fill", titre: "Communautés") { destination = .communautes }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "ellipsis.bubble.fill", titre: "Invitations par message") {
                destination = .invitationsMessage
            }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "archivebox.fill", titre: "Archive") { destination = .archive }
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(MsgrStyle.carte))
    }

    private var carteTrois: some View {
        VStack(spacing: 0) {
            MsgrLigne(symbole: "person.2.fill", titre: "Invitations") { destination = .invitationsFacebook }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "face.smiling", titre: "Discuter avec des IA") { destination = .ia }
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(MsgrStyle.carte))
    }
}

struct MsgrSousEcranMenu: View {
    let destination: MsgrDestinationMenu
    var body: some View {
        switch destination {
        case .parametres: MsgrParametresVue()
        case .communautes: MsgrCommunautesVue()
        case .invitationsMessage: MsgrInvitationsMessageVue()
        case .archive: MsgrArchiveVue()
        case .invitationsFacebook: MsgrInvitationsFacebookVue()
        case .ia:
            // (B) refus crédible : la fonctionnalité n'existe pas sur ce téléphone.
            MsgrEcranSobreVue(titre: "Discuter avec des IA",
                              message: "Indisponible dans votre région",
                              detail: "Les IA de Meta ne sont pas encore proposées sur ce compte.")
        }
    }
}

// ============================================================================
// MARK: - 19. PARAMÈTRES (e081–e084)
// ============================================================================

struct MsgrParametresVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var enLigne = true
    @State private var sousEcran: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: "Paramètres") { dismiss() }
            ScrollView {
                VStack(spacing: 20) {
                    profil
                    MsgrSectionFiche(titre: "Votre compte · ∞ Meta") {
                        MsgrLigne(symbole: "person.crop.circle", titre: "Espace Comptes") {
                            sousEcran = "Espace Comptes"
                        }
                    }
                    preferences
                    MsgrSectionFiche(titre: "Assistance") {
                        MsgrLigne(symbole: "exclamationmark.bubble.fill", titre: "Signaler un problème") {
                            sousEcran = "Signaler un problème"
                        }
                        MsgrSeparateurCarte()
                        MsgrLigne(symbole: "questionmark.circle.fill", titre: "Aide") { sousEcran = "Aide" }
                        MsgrSeparateurCarte()
                        MsgrLigne(symbole: "doc.text.fill", titre: "Mentions légales et politiques") {
                            sousEcran = "Mentions légales et politiques"
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, MsgrStyle.margeLaterale)
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sheet(item: sousEcranBinding) { e in
            MsgrEcranSobreVue(titre: e.valeur,
                              message: "Rien à afficher",
                              detail: "Ce réglage n'est pas modifiable dans cette version.")
        }
    }

    private var sousEcranBinding: Binding<MsgrCleMedia?> {
        Binding(get: { sousEcran.map { MsgrCleMedia(valeur: $0) } },
                set: { sousEcran = $0?.valeur })
    }

    private var profil: some View {
        VStack(spacing: 10) {
            MsgrAvatar(photo: "p04", nom: "Sarah", teinte: 0x5B7CFA, taille: 84).padding(.top, 6)
            Text("Sarah Levasseur").font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)
        }
    }

    private var preferences: some View {
        MsgrSectionFiche(titre: "Préférences") {
            MsgrLigne(symbole: enLigne ? "circle.fill" : "circle", titre: "Statut En ligne",
                      valeur: enLigne ? "Activé" : "Désactivé", chevron: false) {
                enLigne.toggle()
                Haptique.leger()
            }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "moon.fill", titre: "Mode sombre", valeur: "Système") {
                sousEcran = "Mode sombre"
            }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "figure.wave", titre: "Accessibilité") { sousEcran = "Accessibilité" }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "lock.shield.fill", titre: "Confidentialité et sécurité") {
                sousEcran = "Confidentialité et sécurité"
            }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "bell.fill", titre: "Notifications et sons") {
                sousEcran = "Notifications et sons"
            }
            MsgrSeparateurCarte()
            MsgrLigne(symbole: "photo.fill", titre: "Photos et contenu multimédia") {
                sousEcran = "Photos et contenu multimédia"
            }
        }
    }
}

// ============================================================================
// MARK: - 20. ARCHIVE (e090, e098, e106) — la ligne S'OUVRE réellement
// ============================================================================

struct MsgrArchiveVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    @State private var modification = false
    @State private var convOuverte: MsgrConversation? = nil

    var body: some View {
        VStack(spacing: 0) {
            entete
            if store.archivees.isEmpty {
                Spacer()
                MsgrEtatVide(titre: "Aucune conversation archivée",
                             detail: "Les conversations que vous archivez apparaissent ici.")
                Spacer()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(store.archivees) { c in rangee(c) }
                    }
                }
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .fullScreenCover(item: $convOuverte) { c in MsgrConversationVue(conv: c) }
    }

    private var entete: some View {
        ZStack {
            Text("Archive").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                Spacer()
                Button { modification.toggle() } label: {
                    Text(modification ? "OK" : "Modifier")
                        .font(.system(size: 15.5)).foregroundStyle(MsgrStyle.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 8)
    }

    private func rangee(_ c: MsgrConversation) -> some View {
        HStack(spacing: 12) {
            if modification {
                Button {
                    store.supprimerConversation(c.id)
                    Haptique.leger()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 21)).foregroundStyle(MsgrStyle.destructif)
                }
                .buttonStyle(.plain)
            }
            Button { convOuverte = c } label: {
                HStack(spacing: 13) {
                    MsgrAvatarConv(conv: c, taille: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(c.nom).font(.system(size: 17)).foregroundStyle(.white).lineLimit(1)
                        Text("\(c.apercu) · \(c.date)")
                            .font(.system(size: 15)).foregroundStyle(MsgrStyle.inactif).lineLimit(1)
                    }
                    Spacer(minLength: 4)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.vertical, 10)
    }
}

// ============================================================================
// MARK: - 21. COMMUNAUTÉS (jamais filmé — §5-6, écran sobre et réel)
// ============================================================================

struct MsgrCommunautesVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rejointe: String? = nil

    private let communautes: [MsgrSuggestion] = [
        MsgrSuggestion(nom: "Kinés de Lyon", detail: "312 membres · Professionnel", teinte: 0x3F8F5C),
        MsgrSuggestion(nom: "Vide-dressing Lyon 3", detail: "1 204 membres · Achat-vente", teinte: 0xB07A4A),
    ]

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: "Communautés") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Vos communautés")
                        .font(.system(size: 15)).foregroundStyle(MsgrStyle.inactif)
                    VStack(spacing: 0) {
                        ForEach(communautes) { c in
                            rangee(c)
                            if c.id != communautes.last?.id { MsgrSeparateurCarte() }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 16).fill(MsgrStyle.carte))
                }
                .padding(.horizontal, MsgrStyle.margeLaterale)
                .padding(.top, 4)
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private func rangee(_ c: MsgrSuggestion) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12).fill(Color(hex: c.teinte))
                .frame(width: 46, height: 46)
                .overlay(Text(String(c.nom.prefix(1)))
                    .font(.system(size: 19, weight: .semibold)).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 2) {
                Text(c.nom).font(.system(size: 16.5)).foregroundStyle(.white)
                Text(c.detail).font(.system(size: 13.5)).foregroundStyle(MsgrStyle.inactif)
            }
            Spacer(minLength: 6)
            Button {
                rejointe = c.nom
                Haptique.leger()
            } label: {
                Text(rejointe == c.nom ? "Rejointe" : "Rejoindre")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(rejointe == c.nom ? MsgrStyle.inactif : Color.white)
                    .padding(.horizontal, 13).padding(.vertical, 8)
                    .background(Capsule().fill(rejointe == c.nom ? MsgrStyle.champ : MsgrStyle.boutonPlein))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

// ============================================================================
// MARK: - 22. INVITATIONS PAR MESSAGE (e086–e088)
// ============================================================================

struct MsgrInvitationsMessageVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var spam = false
    @State private var reglageVisible = false

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: "Invitations par message") { dismiss() }
            pilules
            encart
            Spacer()
            MsgrEtatVide(titre: "Aucun message", detail: "Les nouveaux messages apparaîtront ici.")
            Spacer()
            Spacer()
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $reglageVisible) {
            MsgrEcranSobreVue(titre: "Qui peut vous envoyer un message",
                              message: "Vos amis Facebook",
                              detail: "Les autres personnes arrivent dans les invitations par message.")
        }
    }

    private var pilules: some View {
        HStack(spacing: 10) {
            MsgrPilule(titre: "VOUS CONNAISSEZ PEUT-ÊTRE", actif: !spam) { spam = false }
            MsgrPilule(titre: "SPAM", actif: spam) { spam = true }
            Spacer()
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 12)
    }

    private var encart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ouvrez une discussion pour en savoir plus sur la personne qui vous envoie un message. Elle ne saura pas que vous l'avez vue tant que vous n'aurez pas répondu.")
                .font(.system(size: 15)).foregroundStyle(MsgrStyle.inactif)
            Button("Choisissez qui peut vous envoyer un message") { reglageVisible = true }
                .font(.system(size: 15, weight: .semibold)).foregroundStyle(MsgrStyle.accent)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MsgrStyle.margeLaterale)
    }
}

// ============================================================================
// MARK: - 23. INVITATIONS FACEBOOK (e099–e104)
// ============================================================================

struct MsgrInvitationsFacebookVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    @State private var tout = false

    private var invitations: [MsgrSuggestion] {
        store.invitationsFacebook.filter { !store.invitationsTraitees.contains($0.nom) }
    }

    var body: some View {
        VStack(spacing: 0) {
            MsgrEnTetePile(titre: "Invitations Facebook") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    titreSection("Invitations", lien: "Voir tout") { tout = true }
                    if invitations.isEmpty {
                        MsgrEtatVide(titre: "Aucune invitation en attente").padding(.vertical, 20)
                    } else {
                        ForEach(invitations) { s in rangeeInvitation(s) }
                    }
                    titreSection("Vous connaissez peut-être…", lien: "Voir plus") { tout = true }
                    ForEach(store.suggestions) { s in rangeeSuggestion(s) }
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, MsgrStyle.margeLaterale)
                .padding(.top, 4)
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private func titreSection(_ titre: String, lien: String,
                              action: @escaping () -> Void) -> some View {
        HStack {
            Text(titre).font(.system(size: 16)).foregroundStyle(MsgrStyle.inactif)
            Spacer()
            Button(lien, action: action)
                .font(.system(size: 16)).foregroundStyle(MsgrStyle.accent)
        }
    }

    private func rangeeInvitation(_ s: MsgrSuggestion) -> some View {
        HStack(alignment: .top, spacing: 13) {
            MsgrAvatar(photo: s.photo, nom: s.nom, teinte: s.teinte, taille: 72)
            VStack(alignment: .leading, spacing: 7) {
                Text(s.nom).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                if !s.detail.isEmpty {
                    Text(s.detail).font(.system(size: 14)).foregroundStyle(MsgrStyle.inactif)
                }
                HStack(spacing: 10) {
                    MsgrBoutonPlein(titre: "Confirmer") { store.traiterInvitation(s.nom) }
                    MsgrBoutonPlein(titre: "Supprimer", fond: MsgrStyle.carte) {
                        store.traiterInvitation(s.nom)
                    }
                }
            }
        }
        .padding(.bottom, 6)
    }

    private func rangeeSuggestion(_ s: MsgrSuggestion) -> some View {
        HStack(alignment: .top, spacing: 13) {
            MsgrAvatar(photo: s.photo, nom: s.nom, teinte: s.teinte, taille: 72)
            VStack(alignment: .leading, spacing: 7) {
                Text(s.nom).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                HStack(spacing: 10) {
                    MsgrBoutonPlein(titre: store.amisAjoutes.contains(s.nom)
                                    ? "Demande envoyée" : "Ajouter comme ami(e)") {
                        store.basculerAmi(s.nom)
                    }
                    MsgrBoutonPlein(titre: "Supprimer", fond: MsgrStyle.carte) {
                        store.traiterInvitation(s.nom)
                    }
                }
            }
        }
        .padding(.bottom, 6)
    }
}

// ============================================================================
// MARK: - 24. NOUVEAU MESSAGE (✎ — jamais filmé, §5-9 : sobre et fonctionnel)
// ============================================================================

struct MsgrNouveauMessageVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = MessengerStore.partage
    let ouvrir: (MsgrConversation) -> Void
    @State private var destinataire = ""
    @FocusState private var champActif: Bool

    private var visibles: [MsgrConversation] {
        let q = destinataire.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return store.conversations }
        return store.conversations.filter { $0.nom.lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            barre
            champ
            liste
            BarreHome(action: { dismiss() }, sombre: false)
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onAppear { champActif = true }
    }

    private var barre: some View {
        ZStack {
            Text("Nouveau message").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
            HStack {
                Button("Annuler") { dismiss() }
                    .font(.system(size: 16)).foregroundStyle(MsgrStyle.accent)
                Spacer()
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.vertical, 10)
    }

    private var champ: some View {
        HStack(spacing: 8) {
            Text("À :").font(.system(size: 16)).foregroundStyle(MsgrStyle.inactif)
            TextField("", text: $destinataire,
                      prompt: Text("Nom").foregroundColor(MsgrStyle.inactif))
                .font(.system(size: 16)).foregroundStyle(.white)
                .focused($champActif)
        }
        .padding(.horizontal, 14)
        .frame(height: 39)
        .background(Capsule().fill(MsgrStyle.champ))
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.bottom, 12)
    }

    private var liste: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Suggestions")
                    .font(.system(size: 15)).foregroundStyle(MsgrStyle.inactif)
                    .padding(.horizontal, MsgrStyle.margeLaterale)
                    .padding(.bottom, 6)
                if visibles.isEmpty {
                    MsgrEtatVide(titre: "Aucun contact",
                                 detail: "Aucun nom ne correspond à « \(destinataire) ».")
                        .padding(.vertical, 40)
                } else {
                    ForEach(visibles) { c in rangee(c) }
                }
            }
        }
    }

    private func rangee(_ c: MsgrConversation) -> some View {
        Button { ouvrir(c) } label: {
            HStack(spacing: 13) {
                MsgrAvatarConv(conv: c, taille: 46)
                Text(c.nom).font(.system(size: 16.5)).foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, MsgrStyle.margeLaterale)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 25. APPELS (jamais filmés — §5-2 : vocal et VIDÉO bien distincts)
// ============================================================================

struct MsgrAppelVue: View {
    @Environment(\.dismiss) private var dismiss
    let conv: MsgrConversation
    let mode: MsgrModeAppel
    @State private var secondes = 0
    @State private var micro = false
    @State private var camera = true
    private let minuteur = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var duree: String {
        secondes < 3 ? "Appel en cours…" : String(format: "%d:%02d", secondes / 60, secondes % 60)
    }

    var body: some View {
        ZStack {
            fond
            VStack(spacing: 0) {
                Spacer()
                identite
                Spacer()
                commandes
                BarreHome(action: { dismiss() }, sombre: true)
            }
        }
        .onReceive(minuteur) { _ in secondes += 1 }
        .preferredColorScheme(.dark)
    }

    // Vidéo : aperçu caméra plein écran + vignette. Vocal : fond sombre uni.
    @ViewBuilder private var fond: some View {
        if mode == .video {
            Color.clear
                .overlay(imageDistant)
                .clipped()
                .ignoresSafeArea()
            LinearGradient(colors: [Color.black.opacity(0.35), .clear, Color.black.opacity(0.55)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        } else {
            LinearGradient(colors: [Color(hex: 0x14161C), Color(hex: 0x07080B)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder private var imageDistant: some View {
        if let cle = conv.photo, let img = ChargeurPhoto.image(cle) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            Color(hex: 0x1E2026)
        }
    }

    @ViewBuilder private var identite: some View {
        if mode == .vocal {
            VStack(spacing: 14) {
                MsgrAvatarConv(conv: conv, taille: 110)
                Text(conv.nom).font(.system(size: 26, weight: .semibold)).foregroundStyle(.white)
                Text(duree).font(.system(size: 15)).foregroundStyle(.white.opacity(0.7))
            }
        } else {
            VStack(spacing: 6) {
                Text(conv.nom).font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
                Text(duree).font(.system(size: 14)).foregroundStyle(.white.opacity(0.8))
                Spacer()
                HStack {
                    Spacer()
                    vignetteLocale
                }
            }
            .padding(.horizontal, MsgrStyle.margeLaterale)
            .padding(.top, 40)
        }
    }

    private var vignetteLocale: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(camera ? Color(hex: 0x2A2C33) : Color.black)
            .frame(width: 96, height: 132)
            .overlay(
                Image(systemName: camera ? "person.fill" : "video.slash.fill")
                    .font(.system(size: 26)).foregroundStyle(.white.opacity(0.7))
            )
    }

    private var commandes: some View {
        HStack(spacing: 26) {
            bouton(micro ? "mic.slash.fill" : "mic.fill") { micro.toggle() }
            if mode == .video {
                bouton(camera ? "video.fill" : "video.slash.fill") { camera.toggle() }
                bouton("arrow.triangle.2.circlepath.camera.fill") { Haptique.leger() }
            } else {
                bouton("speaker.wave.2.fill") { Haptique.leger() }
            }
            Button {
                Haptique.leger()
                dismiss()
            } label: {
                Circle().fill(MsgrStyle.rouge).frame(width: 62, height: 62)
                    .overlay(Image(systemName: "phone.down.fill")
                        .font(.system(size: 24)).foregroundStyle(.white))
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 40)
    }

    private func bouton(_ symbole: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle().fill(Color.white.opacity(0.16)).frame(width: 56, height: 56)
                .overlay(Image(systemName: symbole).font(.system(size: 21)).foregroundStyle(.white))
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 26. VISEUR ET PELLICULE (composeur : photo et image)
// ============================================================================

/// Viseur d'appareil photo (jamais filmé — §5-1). Le déclencheur envoie une VRAIE photo.
struct MsgrViseurVue: View {
    @Environment(\.dismiss) private var dismiss
    let envoyer: (String) -> Void
    @State private var cle = "p26"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            apercu
            VStack {
                barreHaute
                Spacer()
                declencheur
                BarreHome(action: { dismiss() }, sombre: true)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder private var apercu: some View {
        if let img = ChargeurPhoto.image(cle) {
            Color.clear.overlay(Image(uiImage: img).resizable().scaledToFill()).clipped().ignoresSafeArea()
        } else {
            Color(hex: 0x101013).ignoresSafeArea()
        }
    }

    private var barreHaute: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("Appareil photo").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
            Spacer()
            Button { cle = (cle == "p26") ? "p23" : "p26" } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 19)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(MsgrStyle.margeLaterale)
    }

    private var declencheur: some View {
        Button {
            Haptique.leger()
            envoyer(cle)
            dismiss()
        } label: {
            Circle().stroke(Color.white, lineWidth: 4).frame(width: 72, height: 72)
                .overlay(Circle().fill(Color.white).frame(width: 58, height: 58))
        }
        .buttonStyle(.plain)
        .padding(.bottom, 28)
    }
}

/// Sélecteur de pellicule : le choix ENVOIE réellement la photo dans le fil (D82).
struct MsgrPelliculeVue: View {
    @Environment(\.dismiss) private var dismiss
    let choisir: (String) -> Void
    private let cles = ["p22", "p23", "p24", "p25", "p26", "p27", "p12", "p18", "p04"]

    var body: some View {
        VStack(spacing: 0) {
            barre
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3),
                          spacing: 3) {
                    ForEach(Array(cles.enumerated()), id: \.offset) { _, cle in
                        Button {
                            Haptique.leger()
                            choisir(cle)
                            dismiss()
                        } label: {
                            Color.clear.frame(height: 120).overlay(vignette(cle)).clipped()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .background(MsgrStyle.fond.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var barre: some View {
        ZStack {
            Text("Pellicule").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
            HStack {
                Button("Annuler") { dismiss() }
                    .font(.system(size: 16)).foregroundStyle(MsgrStyle.accent)
                Spacer()
            }
        }
        .padding(.horizontal, MsgrStyle.margeLaterale)
        .padding(.vertical, 12)
    }

    @ViewBuilder private func vignette(_ cle: String) -> some View {
        if let img = ChargeurPhoto.image(cle) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            Rectangle().fill(Color(hex: 0x2C2C2E))
        }
    }
}

// ============================================================================
// MARK: - 27. ACCÈS POUR LE REGISTRE DE CAPTURES (D63 — LPProto.ecransMessenger)
// ============================================================================
//
// La boucle miroir instancie chaque écran SANS état externe : ces accesseurs
// rendent des valeurs NON optionnelles, prises dans le store vivant quand il
// existe, sinon dans les données initiales (jamais de `!`, jamais de crash).

extension MessengerStore {

    /// Conversation par identifiant, garantie non optionnelle.
    static func convCapture(_ identifiant: String) -> MsgrConversation {
        if let c = MessengerStore.partage.conversation(identifiant) { return c }
        if let c = MessengerStore.conversationsInitiales().first(where: { $0.id == identifiant }) { return c }
        if let c = MessengerStore.archiveesInitiales().first(where: { $0.id == identifiant }) { return c }
        return MessengerStore.conversationsInitiales()[0]
    }

    /// Note d'une amie (visionneuse de note) — non optionnelle.
    static func noteCapture() -> MsgrNote {
        MessengerStore.partage.notes.first ?? MessengerStore.notesInitiales()[0]
    }

    /// Story (visionneuse plein écran) — non optionnelle.
    static func storyCapture() -> MsgrStory {
        MessengerStore.partage.stories.first ?? MessengerStore.storiesInitiales()[0]
    }

    /// Message porteur de réactions (feuille « Réactions ») — non optionnel.
    static func messageCapture() -> MsgrMessage {
        let fil = MessengerStore.partage.messages("filles")
        if let m = fil.first(where: { !$0.reactions.isEmpty || $0.compteurReaction > 0 }) { return m }
        if let m = MessengerStore.filFilles().first(where: { !$0.reactions.isEmpty || $0.compteurReaction > 0 }) { return m }
        return MsgrMessage(contenu: .texte("Message"))
    }
}
