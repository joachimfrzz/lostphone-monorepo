// App FACETIME iOS 26 — Lost Phone, vague B (07/09/2026)
//
// D93 : Joachim n'a AUCUN enregistrement de FaceTime. La seule source autorisée est donc
//   la 2e source « captures officielles de l'éditeur » : refs/officiel/facetime/*.png (9) et
//   refs/officiel2/facetime/* (11, voir SOURCES.md — support.apple.com fr-fr/en-us + 9to5mac).
//   Écrans reproduits d'après ces captures :
//     • liste des récents en tuiles-affiches 2 colonnes  → 02_appleguide_recents_remplie.png
//       (+ 01 annotée pour la sémantique des pastilles, + 03 version en-us pour le titre centré)
//     • feuille « Nouveau FaceTime » (À : / jetons / + / Suggestions / lien · FaceTime · téléphone)
//       → 04_appleguide_nouveau_facetime_sheet.png
//     • appel sortant + « X est indisponible » (Rappeler / Enregistrer une vidéo / Fermer)
//       → 05_appleguide_appel_sortant_indisponible.png
//     • enregistrement d'un message vidéo (Annuler / À X / Enregistrer, flèche verte, Reprendre)
//       → 08_appleguide_message_video_enregistrement.png
//     • viseur sombre + colonne de contrôles → 06_appleguide_appel_en_cours_portrait.png,
//       11_9to5mac_controles_appel_en.jpg
//   Écrans NON faits (aucune source, D82-C) : appel entrant plein écran, bannière d'appel entrant,
//   appel de groupe en cours, effets de caméra, réglages FaceTime (ils sont dans l'app Réglages).
//
// D59 : aucune donnée de Joachim. Tout est le contenu de Sarah Levasseur — et c'est ici que
//   FaceTime devient une pièce d'enquête : 6 tentatives d'appel VIDÉO sortantes vers « Marc ❤️ »,
//   toutes sans réponse ou annulées, un seul appel AUDIO entrant de 4 min, et JAMAIS un seul
//   appel vidéo abouti — alors que Chloé, Maman et Thomas se voient sans problème.
//
// D92 « juste milieu » : la seule création de l'app est l'enregistrement d'un message vidéo
//   (persistant via FtEtat.partage). Réglages FaceTime, effets, appels de groupe, appel entrant :
//   RETIRÉS plutôt que morts. Détail dans docs_vague-b/facetime-livraison.md.
//
// Coque : BarreHome dessinée par l'app (comme PayPalVue). AUCUN .sheet / .fullScreenCover /
//   .confirmationDialog : toutes les feuilles sont des recouvrements internes de la ZStack racine.
//   Pas de status bar, pas de micro de dictée, retour = chevron.
// Préfixe de types : Ft — aucune collision avec LPProto ni les autres apps.
import SwiftUI
import UIKit

// ============================================================ PALETTE
// Mesurée sur 02_appleguide_recents_remplie.png et 05_appleguide_appel_sortant_indisponible.png.
enum FtTeinte {
    static let fond = Color(hex: 0x000000)          // 02 : fond de la liste (0,0,0)
    static let carte = Color(hex: 0x1C1C1E)         // 02 : capsules « Modifier » / filtre
    static let carte2 = Color(hex: 0x2C2C2E)        // 05 : bouton « Fermer »
    static let separateur = Color(hex: 0x3A3A3C)
    static let texte = Color(hex: 0xF2F2F7)
    static let texte2 = Color(hex: 0x8E8E93)        // 05 : sous-titre « FaceTime vidéo »
    static let vert = Color(hex: 0x30D158)          // 02 : « Nouvel appel », 04 : bouton FaceTime
    static let vertSombre = Color(hex: 0x0E3D1E)
    static let rouge = Color(hex: 0xD93A32)         // 06/11 : croix rouge de raccrochage
    static let rougeVif = Color(hex: 0xFF453A)      // 02 : nom d'un appel manqué
    static let blanc = Color.white
}

// ============================================================ DONNÉES (remplaçables — D59)

enum FtMode {
    case video
    case audio

    var libelle: String {
        switch self {
        case .video: return "FaceTime vidéo"
        case .audio: return "FaceTime audio"
        }
    }
    var libelleCourt: String {
        switch self {
        case .video: return "Vidéo"
        case .audio: return "Audio"
        }
    }
    var symbole: String {
        switch self {
        case .video: return "video.fill"
        case .audio: return "phone.fill"
        }
    }
}

enum FtIssue {
    case abouti
    case sansReponse
    case annule
    case manque

    var libelle: String {
        switch self {
        case .abouti: return "Abouti"
        case .sansReponse: return "Sans réponse"
        case .annule: return "Annulé"
        case .manque: return "Manqué"
        }
    }
}

struct FtAppel: Identifiable, Hashable {
    let id = UUID()
    var nom: String
    var mode: FtMode
    var sortant: Bool
    var issue: FtIssue
    var jour: String        // « dimanche 16 août 2026 »
    var jourCourt: String   // « Hier », « 15 août »
    var heure: String       // « 22:05 »
    var duree: String?      // « 38 min » — nil si l'appel n'a pas abouti

    var fleche: String { sortant ? "arrow.up.right" : "arrow.down.left" }
    var intitule: String {
        if issue == .manque { return "Appel manqué" }
        return sortant ? "Appel sortant" : "Appel entrant"
    }
    var detailDuree: String { duree ?? issue.libelle }
}

struct FtContact: Identifiable, Hashable {
    let id = UUID()
    var nom: String
    var identifiant: String     // numéro ou adresse iCloud utilisée comme identifiant FaceTime
    var teinte: UInt
    var photo: String? = nil
}

struct FtMessageVideo: Identifiable, Hashable {
    let id = UUID()
    var auteur: String          // qui l'a enregistré
    var pour: String            // à qui il est adressé
    var duree: String
    var secondes: Int
    var quand: String
    var deSarah: Bool
    var lignes: [String]        // transcription scriptée (pas de fausse vidéo — D92)
}

/// Le contenu de Sarah. Aujourd'hui dans le jeu ≈ lundi 17 août 2026, donc « Hier » = dimanche 16.
enum DonneesFt {
    static let contacts: [FtContact] = [
        FtContact(nom: "Marc ❤️", identifiant: "+33 7 49 12 53 08", teinte: 0x2F4858, photo: "AvatarMarc"),
        FtContact(nom: "Chloé", identifiant: "+33 6 24 81 05 77", teinte: 0xE17BB2),
        FtContact(nom: "Maman", identifiant: "+33 6 88 41 27 30", teinte: 0x8E6BB5),
        FtContact(nom: "Thomas", identifiant: "+33 6 51 33 90 12", teinte: 0x4A7C8C),
        FtContact(nom: "Julie", identifiant: "+33 6 47 92 33 08", teinte: 0xD98A4A),
        FtContact(nom: "Camille Roux", identifiant: "camille.roux69@gmail.com", teinte: 0xE8863D),
        FtContact(nom: "Papa", identifiant: "+33 6 71 05 44 92", teinte: 0x5B7C63)
    ]

    /// Contacts jamais appelés en FaceTime : ils apparaissent en tuile « Suggestions » (cf. 02, tuile Ashley).
    static let suggestions: [String] = ["Camille Roux"]

    /// Journal FaceTime, du plus récent au plus ancien.
    /// La colonne vertébrale de l'indice : Marc = 6 appels VIDÉO sortants, aucun abouti ;
    /// un seul contact vocal (audio entrant du 10 mai). Il ne montre jamais son visage.
    static func appels() -> [FtAppel] {
        [
            FtAppel(nom: "Marc ❤️", mode: .video, sortant: true, issue: .sansReponse,
                    jour: "dimanche 16 août 2026", jourCourt: "Hier", heure: "22:05", duree: nil),
            FtAppel(nom: "Chloé", mode: .video, sortant: true, issue: .abouti,
                    jour: "dimanche 16 août 2026", jourCourt: "Hier", heure: "21:12", duree: "38 min"),
            FtAppel(nom: "Maman", mode: .audio, sortant: false, issue: .abouti,
                    jour: "dimanche 16 août 2026", jourCourt: "Hier", heure: "11:02", duree: "27 min"),
            FtAppel(nom: "Julie", mode: .video, sortant: false, issue: .manque,
                    jour: "samedi 15 août 2026", jourCourt: "15 août", heure: "18:47", duree: nil),
            FtAppel(nom: "Chloé", mode: .video, sortant: false, issue: .abouti,
                    jour: "vendredi 14 août 2026", jourCourt: "14 août", heure: "22:40", duree: "1 h 04"),
            FtAppel(nom: "Chloé", mode: .video, sortant: true, issue: .abouti,
                    jour: "dimanche 9 août 2026", jourCourt: "9 août", heure: "20:05", duree: "22 min"),
            FtAppel(nom: "Maman", mode: .audio, sortant: true, issue: .abouti,
                    jour: "dimanche 9 août 2026", jourCourt: "9 août", heure: "11:15", duree: "31 min"),
            FtAppel(nom: "Maman", mode: .audio, sortant: false, issue: .abouti,
                    jour: "dimanche 2 août 2026", jourCourt: "2 août", heure: "10:58", duree: "24 min"),
            FtAppel(nom: "Thomas", mode: .video, sortant: false, issue: .abouti,
                    jour: "jeudi 30 juillet 2026", jourCourt: "30 juil.", heure: "19:22", duree: "12 min"),
            FtAppel(nom: "Marc ❤️", mode: .video, sortant: true, issue: .annule,
                    jour: "vendredi 17 juillet 2026", jourCourt: "17 juil.", heure: "21:48", duree: nil),
            FtAppel(nom: "Marc ❤️", mode: .video, sortant: true, issue: .sansReponse,
                    jour: "dimanche 5 juillet 2026", jourCourt: "5 juil.", heure: "20:31", duree: nil),
            FtAppel(nom: "Marc ❤️", mode: .audio, sortant: false, issue: .abouti,
                    jour: "dimanche 10 mai 2026", jourCourt: "10 mai", heure: "22:14", duree: "4 min"),
            FtAppel(nom: "Marc ❤️", mode: .video, sortant: true, issue: .sansReponse,
                    jour: "mercredi 6 mai 2026", jourCourt: "6 mai", heure: "21:03", duree: nil),
            FtAppel(nom: "Marc ❤️", mode: .video, sortant: true, issue: .annule,
                    jour: "lundi 20 avril 2026", jourCourt: "20 avr.", heure: "22:37", duree: nil),
            FtAppel(nom: "Marc ❤️", mode: .video, sortant: true, issue: .sansReponse,
                    jour: "jeudi 12 mars 2026", jourCourt: "12 mars", heure: "23:19", duree: nil)
        ]
    }

    /// Un seul message vidéo reçu : celui de Chloé. Marc n'en a JAMAIS laissé (il ne se montre pas).
    static func messages() -> [FtMessageVideo] {
        [
            FtMessageVideo(auteur: "Chloé", pour: "Sarah", duree: "0:22", secondes: 22,
                           quand: "Hier", deSarah: false,
                           lignes: [
                            "Sarah, rappelle-moi, faut qu'on parle de Marc, sérieux…",
                            "J'ai regardé ses photos, celle du bateau, elle traîne partout sur Internet.",
                            "Je t'embête pas pour rien, promis. Rappelle-moi ce soir."
                           ])
        ]
    }

    static let appelParDefaut = FtAppel(nom: "Marc ❤️", mode: .video, sortant: true, issue: .sansReponse,
                                        jour: "dimanche 16 août 2026", jourCourt: "Hier",
                                        heure: "22:05", duree: nil)
    static let messageParDefaut = FtMessageVideo(auteur: "Chloé", pour: "Sarah", duree: "0:22",
                                                 secondes: 22, quand: "Hier", deSarah: false,
                                                 lignes: ["Sarah, rappelle-moi, faut qu'on parle de Marc, sérieux…"])
    static let contactParDefaut = FtContact(nom: "Chloé", identifiant: "+33 6 24 81 05 77", teinte: 0xE17BB2)

    static func contact(_ nom: String) -> FtContact {
        contacts.first(where: { $0.nom == nom })
            ?? FtContact(nom: nom, identifiant: "", teinte: 0x4A4A4E)
    }
}

// ============================================================ MAGASIN (persistance — D92)
final class FtEtat: ObservableObject {
    static let partage = FtEtat()

    @Published var appels: [FtAppel] = DonneesFt.appels()
    @Published var messages: [FtMessageVideo] = DonneesFt.messages()
    @Published var messagesEcoutes: Set<UUID> = []
    @Published var lienCree = false

    /// Suppression réelle depuis le mode « Modifier » : tout l'historique du contact disparaît.
    func supprimer(contact nom: String) {
        appels.removeAll { $0.nom == nom }
        messages.removeAll { $0.auteur == nom || ($0.deSarah && $0.pour == nom) }
    }

    /// La seule création de l'app : Sarah enregistre un message vidéo pour un contact.
    func enregistrer(pour nom: String, secondes: Int) {
        let duree = String(format: "%d:%02d", secondes / 60, secondes % 60)
        let message = FtMessageVideo(auteur: "Sarah", pour: nom, duree: duree, secondes: secondes,
                                     quand: "À l'instant", deSarah: true,
                                     lignes: ["Message vidéo enregistré par Sarah — non lu par le destinataire."])
        messages.insert(message, at: 0)
        appels.insert(FtAppel(nom: nom, mode: .video, sortant: true, issue: .sansReponse,
                              jour: "lundi 17 août 2026", jourCourt: "À l'instant",
                              heure: "—", duree: nil), at: 0)
    }

    func historique(de nom: String) -> [FtAppel] { appels.filter { $0.nom == nom } }
    func message(de nom: String) -> FtMessageVideo? { messages.first(where: { $0.auteur == nom }) }
    func messageEnvoye(a nom: String) -> FtMessageVideo? {
        messages.first(where: { $0.deSarah && $0.pour == nom })
    }
}

/// Une tuile-affiche de la liste : un contact + son dernier appel + son éventuel message vidéo.
struct FtTuile: Identifiable {
    var id: String { nom }
    var nom: String
    var dernier: FtAppel?
    var message: FtMessageVideo?
    var suggestion: Bool

    var contact: FtContact { DonneesFt.contact(nom) }
    var manque: Bool {
        guard let dernier else { return false }
        return dernier.issue != .abouti
    }
}

enum FtGroupes {
    /// Regroupe le journal par contact en conservant l'ordre chronologique inverse,
    /// puis ajoute les contacts suggérés (jamais appelés en FaceTime) — cf. tuile « Suggestions » de 02.
    static func tuiles(_ etat: FtEtat, manquesSeulement: Bool) -> [FtTuile] {
        var vus: [String] = []
        var resultat: [FtTuile] = []
        let journal = manquesSeulement ? etat.appels.filter { $0.issue != .abouti } : etat.appels
        for appel in journal where !vus.contains(appel.nom) {
            vus.append(appel.nom)
            resultat.append(FtTuile(nom: appel.nom, dernier: appel,
                                    message: etat.message(de: appel.nom) ?? etat.messageEnvoye(a: appel.nom),
                                    suggestion: false))
        }
        guard !manquesSeulement else { return resultat }
        for nom in DonneesFt.suggestions where !vus.contains(nom) {
            resultat.append(FtTuile(nom: nom, dernier: nil, message: nil, suggestion: true))
        }
        return resultat
    }
}

// ============================================================ CAPTURE (boucle miroir)
enum FtCapture {
    static func etat() -> FtEtat { FtEtat.partage }
    static func appel() -> FtAppel {
        FtEtat.partage.appels.first(where: { $0.nom == "Marc ❤️" }) ?? DonneesFt.appelParDefaut
    }
    static func message() -> FtMessageVideo {
        FtEtat.partage.messages.first ?? DonneesFt.messageParDefaut
    }
    static func contact() -> FtContact {
        DonneesFt.contacts.first(where: { $0.nom == "Chloé" }) ?? DonneesFt.contactParDefaut
    }
}

/// Enveloppe de capture d'un écran POUSSÉ : dans le jeu la BarreHome est portée par `FaceTimeVue`
/// (hors NavigationStack). En capture isolée, cette enveloppe la restitue.
struct FtEcranCapture<Contenu: View>: View {
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        ZStack(alignment: .bottom) {
            FtTeinte.fond.ignoresSafeArea()
            NavigationStack { contenu() }
                .tint(FtTeinte.vert)
            BarreHome { }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ FORMATS
enum FtFormat {
    /// « Marc ❤️ » → « Marc » (pour « Marc est indisponible », cf. 05).
    static func prenom(_ nom: String) -> String {
        let mot = nom.split(separator: " ").first.map { String($0) } ?? nom
        let lettres = mot.filter { $0.isLetter || $0 == "-" || $0 == "'" }
        return lettres.isEmpty ? mot : lettres
    }
    static func monogramme(_ nom: String) -> String {
        let mots = nom.split(separator: " ").prefix(2)
        var lettres = ""
        for mot in mots {
            if let premiere = mot.first, premiere.isLetter {
                lettres += String(premiere).uppercased()
            }
        }
        return lettres.isEmpty ? "?" : lettres
    }
    static func liste(_ noms: [String]) -> String {
        let courts = noms.map { prenom($0) }
        if courts.count <= 1 { return courts.first ?? "" }
        return courts.dropLast().joined(separator: ", ") + " et " + (courts.last ?? "")
    }
    static func indisponible(_ noms: [String]) -> String {
        if noms.count > 1 { return liste(noms) + " sont indisponibles" }
        return liste(noms) + " est indisponible"
    }
    static func chrono(_ secondes: Int) -> String {
        String(format: "%d:%02d", secondes / 60, secondes % 60)
    }
}

// ============================================================ AVATAR
/// Marc a une photo (« AvatarMarc », la photo volée du coach milanais) ; les autres, un monogramme
/// sur un rond de couleur — comme les mémojis/photos des tuiles de 02.
struct FtAvatar: View {
    let nom: String
    var diametre: CGFloat = 88

    private var contact: FtContact { DonneesFt.contact(nom) }

    var body: some View {
        if let photo = contact.photo {
            AvatarSilhouette(taille: diametre, image: photo)
        } else {
            Circle()
                .fill(LinearGradient(colors: [Color(hex: contact.teinte),
                                              Color(hex: contact.teinte).opacity(0.55)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: diametre, height: diametre)
                .overlay(
                    Text(FtFormat.monogramme(nom))
                        .font(.system(size: diametre * 0.38, weight: .medium))
                        .foregroundStyle(FtTeinte.blanc)
                )
        }
    }
}

// ============================================================ RACINE

enum FtRecouvrement {
    case aucun
    case nouveau
    case appel
    case enregistrement
    case lien
}

struct FaceTimeVue: View {
    @Environment(\.dismiss) private var quitter
    @State private var chemin: [FtAppel] = []
    @State private var recouvrement: FtRecouvrement = .aucun
    @State private var appelNoms: [String] = []
    @State private var appelMode: FtMode = .video
    @State private var enregistrementPour = ""
    @State private var messageOuvert: FtMessageVideo? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            FtTeinte.fond.ignoresSafeArea()
            NavigationStack(path: $chemin) {
                FtListeVue(chemin: $chemin,
                           surAppel: lancer,
                           surMessage: { messageOuvert = $0 },
                           surNouveau: { recouvrement = .nouveau })
                    .navigationDestination(for: FtAppel.self) { appel in
                        FtDetailVue(appel: appel, surAppel: lancer,
                                    surMessage: { messageOuvert = $0 })
                    }
            }
            .tint(FtTeinte.vert)
            recouvrements
            BarreHome { quitter() }
        }
        .background(FtTeinte.fond)
        .preferredColorScheme(.dark)
    }

    private func lancer(_ noms: [String], _ mode: FtMode) {
        guard !noms.isEmpty else { return }
        Haptique.leger()
        appelNoms = noms
        appelMode = mode
        recouvrement = .appel
    }

    @ViewBuilder
    private var recouvrements: some View {
        if recouvrement == .nouveau {
            FtNouveauVue(surAppel: lancer,
                         surLien: { recouvrement = .lien },
                         fermer: { recouvrement = .aucun })
        }
        if recouvrement == .appel {
            FtAppelVue(noms: appelNoms, mode: appelMode,
                       surEnregistrer: { nom in
                           enregistrementPour = nom
                           recouvrement = .enregistrement
                       },
                       fermer: { recouvrement = .aucun })
        }
        if recouvrement == .enregistrement {
            FtEnregistrementVue(destinataire: enregistrementPour,
                                fermer: { recouvrement = .aucun })
        }
        if recouvrement == .lien {
            FtLienVue(fermer: { recouvrement = .aucun })
        }
        if let message = messageOuvert {
            FtLecteurMessageVue(message: message, fermer: { messageOuvert = nil })
        }
    }
}

// ============================================================ ÉCRAN 1 — LISTE DES RÉCENTS
// Référence : 02_appleguide_recents_remplie.png (fond noir, « Modifier » à gauche, filtre à droite,
// grille de 2 colonnes de tuiles-affiches, bouton vert flottant « Nouvel appel »)
// + 03_appleguide_recents_remplie_en.jpg (titre « FaceTime » centré dans la barre du haut).

struct FtListeVue: View {
    @Binding var chemin: [FtAppel]
    var surAppel: ([String], FtMode) -> Void = { _, _ in }
    var surMessage: (FtMessageVideo) -> Void = { _ in }
    var surNouveau: () -> Void = { }
    /// Sert au registre de capture (`facetime.modifier`) : ouvre l'écran déjà en mode suppression.
    var editionInitiale: Bool = false

    @ObservedObject private var etat = FtEtat.partage
    @State private var modeEdition = false
    @State private var menuFiltre = false
    @State private var manquesSeulement = false
    @State private var aSupprimer: String? = nil

    private var tuiles: [FtTuile] { FtGroupes.tuiles(etat, manquesSeulement: manquesSeulement) }
    private let colonnes = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack(alignment: .bottom) {
            FtTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                barreHaut
                if tuiles.isEmpty {
                    vide
                } else {
                    grille
                }
            }
            FtBoutonNouvelAppel(action: surNouveau)
                .padding(.bottom, 34)
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topTrailing) {
            if menuFiltre {
                FtMenuFiltre(manquesSeulement: $manquesSeulement, fermer: { menuFiltre = false })
                    .padding(.trailing, 16)
                    .padding(.top, 58)
            }
        }
        .onAppear { if editionInitiale { modeEdition = true } }
        .alert(titreSuppression,
               isPresented: Binding(get: { aSupprimer != nil }, set: { if !$0 { aSupprimer = nil } })) {
            Button("Supprimer", role: .destructive) {
                if let nom = aSupprimer { withAnimation { etat.supprimer(contact: nom) } }
                aSupprimer = nil
            }
            Button("Annuler", role: .cancel) { aSupprimer = nil }
        }
    }

    private var titreSuppression: String {
        "Supprimer tous les appels FaceTime avec " + (aSupprimer ?? "") + " ?"
    }

    private var barreHaut: some View {
        HStack {
            Text(modeEdition ? "OK" : "Modifier")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(FtTeinte.texte)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(Capsule().fill(FtTeinte.carte))
                .contentShape(Capsule())
                .onTapGesture { Haptique.leger(); withAnimation { modeEdition.toggle() } }
            Spacer()
            Text("FaceTime")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(FtTeinte.texte)
            Spacer()
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(manquesSeulement ? FtTeinte.vert : FtTeinte.texte)
                .frame(width: 34, height: 34)
                .background(Circle().fill(FtTeinte.carte))
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); withAnimation { menuFiltre.toggle() } }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var grille: some View {
        ScrollView {
            LazyVGrid(columns: colonnes, spacing: 12) {
                ForEach(tuiles) { tuile in
                    FtTuileVue(tuile: tuile,
                               edition: modeEdition,
                               surTap: {
                                   let mode = tuile.dernier?.mode ?? FtMode.video
                                   surAppel([tuile.nom], mode)
                               },
                               surInfo: {
                                   if let appel = tuile.dernier { chemin.append(appel) }
                               },
                               surMessage: { if let message = tuile.message { surMessage(message) } },
                               surSupprimer: { aSupprimer = tuile.nom })
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 130)
        }
    }

    private var vide: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "video.slash")
                .font(.system(size: 34))
                .foregroundStyle(FtTeinte.texte2)
            Text(manquesSeulement ? "Aucun appel manqué" : "Aucun appel récent")
                .font(.system(size: 15))
                .foregroundStyle(FtTeinte.texte2)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// Menu du filtre : Tous / Manqués. « Manqués » = tout appel qui n'a pas abouti (manqué, sans
// réponse, annulé) — c'est ce filtre qui fait apparaître le mur d'appels vers Marc.
struct FtMenuFiltre: View {
    @Binding var manquesSeulement: Bool
    var fermer: () -> Void = { }

    var body: some View {
        VStack(spacing: 0) {
            ligne(titre: "Tous", actif: !manquesSeulement) {
                manquesSeulement = false
            }
            Rectangle().fill(FtTeinte.separateur).frame(height: 0.5)
            ligne(titre: "Manqués", actif: manquesSeulement) {
                manquesSeulement = true
            }
        }
        .frame(width: 190)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(FtTeinte.carte2))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.5), radius: 14, y: 6)
    }

    private func ligne(titre: String, actif: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Text(titre)
                .font(.system(size: 16))
                .foregroundStyle(FtTeinte.texte)
            Spacer()
            if actif {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FtTeinte.vert)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptique.leger()
            action()
            withAnimation { fermer() }
        }
    }
}

// Tuile-affiche (02) : dégradé sombre teinté, avatar centré, nom en haut (rouge si non abouti,
// pastille verte s'il y a un message enregistré), statut en bas à gauche, bouton rond en bas à droite.
struct FtTuileVue: View {
    let tuile: FtTuile
    var edition: Bool = false
    var surTap: () -> Void = { }
    var surInfo: () -> Void = { }
    var surMessage: () -> Void = { }
    var surSupprimer: () -> Void = { }

    @ObservedObject private var etat = FtEtat.partage

    private var couleurNom: Color { tuile.manque ? FtTeinte.rougeVif : FtTeinte.texte }
    /// Seul un message REÇU se lit depuis la tuile (pastille ▶) ; un message que Sarah vient
    /// d'enregistrer reste un appel sortant « ↗ Vidéo · À l'instant ».
    private var messageRecu: FtMessageVideo? {
        guard let message = tuile.message, !message.deSarah else { return nil }
        return message
    }
    /// Pastille verte = message enregistré pas encore écouté (sémantique de la capture 01 annotée).
    private var nonEcoute: Bool {
        guard let message = messageRecu else { return false }
        return !etat.messagesEcoutes.contains(message.id)
    }

    var body: some View {
        ZStack {
            fondTuile
            FtAvatar(nom: tuile.nom, diametre: 96)
            contenu
        }
        .aspectRatio(0.74, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture { if !edition { surTap() } }
        .onLongPressGesture(minimumDuration: 0.45) { Haptique.leger(); surInfo() }
        .overlay(alignment: .topTrailing) { badgeCoin }
    }

    private var fondTuile: some View {
        LinearGradient(colors: [Color(hex: tuile.contact.teinte).opacity(0.55),
                                Color(hex: 0x0A0A0C)],
                       startPoint: .top, endPoint: .bottom)
    }

    private var contenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                if nonEcoute {
                    Circle().fill(FtTeinte.vert).frame(width: 8, height: 8)
                }
                Text(tuile.nom)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(couleurNom)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            HStack(alignment: .bottom) {
                statut
                Spacer(minLength: 6)
                bouton
            }
        }
        .padding(12)
    }

    @ViewBuilder
    private var statut: some View {
        VStack(alignment: .leading, spacing: 1) {
            if tuile.suggestion {
                Text("Suggestions")
                    .font(.system(size: 13))
                    .foregroundStyle(FtTeinte.texte2)
            } else if let message = messageRecu {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(FtTeinte.texte)
                    Text(message.duree)
                        .font(.system(size: 13))
                        .foregroundStyle(FtTeinte.texte)
                }
                Text(message.quand)
                    .font(.system(size: 13))
                    .foregroundStyle(FtTeinte.texte2)
            } else if let dernier = tuile.dernier {
                HStack(spacing: 4) {
                    Image(systemName: dernier.fleche)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(FtTeinte.texte2)
                    Text(dernier.mode.libelleCourt)
                        .font(.system(size: 13))
                        .foregroundStyle(FtTeinte.texte2)
                }
                Text(dernier.jourCourt)
                    .font(.system(size: 13))
                    .foregroundStyle(FtTeinte.texte2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if messageRecu != nil {
                Haptique.leger()
                surMessage()
            } else if !edition {
                surTap()
            }
        }
    }

    private var bouton: some View {
        let mode = tuile.dernier?.mode ?? FtMode.video
        return Circle()
            .fill(Color.white.opacity(0.22))
            .frame(width: 42, height: 42)
            .overlay(
                Image(systemName: mode.symbole)
                    .font(.system(size: 16))
                    .foregroundStyle(FtTeinte.blanc)
            )
            .contentShape(Circle())
            .onTapGesture { if !edition { surTap() } }
    }

    @ViewBuilder
    private var badgeCoin: some View {
        if edition {
            Image(systemName: "minus.circle.fill")
                .font(.system(size: 24))
                .symbolRenderingMode(.palette)
                .foregroundStyle(FtTeinte.blanc, FtTeinte.rougeVif)
                .padding(8)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); surSupprimer() }
        } else if tuile.dernier != nil {
            Image(systemName: "info.circle")
                .font(.system(size: 17))
                .foregroundStyle(Color.white.opacity(0.65))
                .padding(9)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); surInfo() }
        }
    }
}

// Bouton vert flottant « Nouvel appel » (02, bas de l'écran, au-dessus de la BarreHome).
struct FtBoutonNouvelAppel: View {
    var action: () -> Void = { }
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "video.fill").font(.system(size: 15))
            Text("Nouvel appel").font(.system(size: 16, weight: .semibold))
        }
        .foregroundStyle(FtTeinte.blanc)
        .padding(.horizontal, 20)
        .frame(height: 46)
        .background(Capsule().fill(FtTeinte.vert))
        .contentShape(Capsule())
        .onTapGesture { Haptique.leger(); action() }
    }
}

// ============================================================ ÉCRAN 2 — FICHE DÉTAIL D'UN APPEL
// Écran POUSSÉ (chevron de retour). Pas de source officielle du détail FaceTime : construit
// dans la langue de l'app Téléphone validée (TelFicheVue), avec l'historique complet du contact —
// c'est là que le joueur voit les 6 tentatives vidéo vers Marc alignées.

struct FtDetailVue: View {
    @Environment(\.dismiss) private var revenir
    let appel: FtAppel
    var surAppel: ([String], FtMode) -> Void = { _, _ in }
    var surMessage: (FtMessageVideo) -> Void = { _ in }

    @ObservedObject private var etat = FtEtat.partage

    private var historique: [FtAppel] { etat.historique(de: appel.nom) }
    private var contact: FtContact { DonneesFt.contact(appel.nom) }

    var body: some View {
        ZStack {
            FtTeinte.fond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    entete
                    actions
                    carteAppel
                    carteMessage
                    carteHistorique
                    Spacer(minLength: 90)
                }
            }
            VStack {
                barreRetour
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var barreRetour: some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(FtTeinte.texte)
                .frame(width: 36, height: 36)
                .background(Circle().fill(FtTeinte.carte))
                .contentShape(Circle())
                .onTapGesture { revenir() }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var entete: some View {
        VStack(spacing: 10) {
            FtAvatar(nom: appel.nom, diametre: 116)
            Text(appel.nom)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(FtTeinte.texte)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(contact.identifiant)
                .font(.system(size: 14))
                .foregroundStyle(FtTeinte.texte2)
        }
        .padding(.top, 54)
    }

    private var actions: some View {
        HStack(spacing: 16) {
            FtRondAction(symbole: "video.fill", titre: "FaceTime") {
                surAppel([appel.nom], .video)
            }
            FtRondAction(symbole: "phone.fill", titre: "Audio") {
                surAppel([appel.nom], .audio)
            }
            FtRondAction(symbole: "message.fill", titre: "Message") {
                Haptique.leger()
                Routeur.partage.allerMessages()
            }
        }
        .padding(.top, 20)
    }

    private var carteAppel: some View {
        FtCarte {
            VStack(alignment: .leading, spacing: 8) {
                FtLigneInfo(cle: "Type", valeur: appel.mode.libelle)
                FtLigneInfo(cle: "Sens", valeur: appel.intitule)
                FtLigneInfo(cle: "Date", valeur: appel.jour)
                FtLigneInfo(cle: "Heure", valeur: appel.heure)
                FtLigneInfo(cle: appel.duree == nil ? "Issue" : "Durée",
                            valeur: appel.detailDuree,
                            alerte: appel.issue != .abouti)
            }
        }
        .padding(.top, 22)
    }

    @ViewBuilder
    private var carteMessage: some View {
        if let message = etat.message(de: appel.nom) ?? etat.messageEnvoye(a: appel.nom) {
            FtCarte {
                HStack(spacing: 12) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(FtTeinte.vert)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(message.deSarah ? "Message vidéo envoyé" : "Message vidéo reçu")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(FtTeinte.texte)
                        Text("\(message.quand) · \(message.duree)")
                            .font(.system(size: 13))
                            .foregroundStyle(FtTeinte.texte2)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); surMessage(message) }
            }
            .padding(.top, 12)
        }
    }

    private var carteHistorique: some View {
        FtCarte {
            VStack(alignment: .leading, spacing: 0) {
                Text("Tous les appels FaceTime")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FtTeinte.texte2)
                    .padding(.bottom, 8)
                if historique.isEmpty {
                    Text("Aucun appel")
                        .font(.system(size: 14))
                        .foregroundStyle(FtTeinte.texte2)
                } else {
                    ForEach(historique) { ligne in
                        FtLigneHistorique(appel: ligne)
                    }
                }
            }
        }
        .padding(.top, 12)
    }
}

struct FtLigneHistorique: View {
    let appel: FtAppel
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: appel.mode.symbole)
                .font(.system(size: 12))
                .foregroundStyle(FtTeinte.texte2)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(appel.intitule) · \(appel.mode.libelleCourt.lowercased())")
                    .font(.system(size: 14))
                    .foregroundStyle(appel.issue == .abouti ? FtTeinte.texte : FtTeinte.rougeVif)
                Text(appel.detailDuree)
                    .font(.system(size: 12.5))
                    .foregroundStyle(FtTeinte.texte2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text(appel.jourCourt)
                    .font(.system(size: 13))
                    .foregroundStyle(FtTeinte.texte2)
                Text(appel.heure)
                    .font(.system(size: 12))
                    .foregroundStyle(FtTeinte.texte2)
            }
        }
        .padding(.vertical, 7)
    }
}

struct FtLigneInfo: View {
    let cle: String
    let valeur: String
    var alerte: Bool = false
    var body: some View {
        HStack {
            Text(cle)
                .font(.system(size: 14))
                .foregroundStyle(FtTeinte.texte2)
            Spacer()
            Text(valeur)
                .font(.system(size: 15))
                .foregroundStyle(alerte ? FtTeinte.rougeVif : FtTeinte.texte)
        }
    }
}

struct FtCarte<Contenu: View>: View {
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { contenu() }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(FtTeinte.carte))
            .padding(.horizontal, 16)
    }
}

struct FtRondAction: View {
    let symbole: String
    let titre: String
    var action: () -> Void = { }
    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(FtTeinte.carte)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: symbole)
                        .font(.system(size: 20))
                        .foregroundStyle(FtTeinte.vert)
                )
            Text(titre)
                .font(.system(size: 12))
                .foregroundStyle(FtTeinte.texte2)
        }
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }
}

// ============================================================ ÉCRAN 3 — FEUILLE « NOUVEAU FACETIME »
// Référence : 04_appleguide_nouveau_facetime_sheet.png. Recouvrement interne (jamais .sheet) :
// il monte depuis le bas et laisse la BarreHome visible.

struct FtNouveauVue: View {
    var surAppel: ([String], FtMode) -> Void = { _, _ in }
    var surLien: () -> Void = { }
    var fermer: () -> Void = { }

    @State private var destinataires: [String] = []
    @State private var saisie = ""
    @State private var tousVisibles = false
    @FocusState private var champActif: Bool

    private var candidats: [FtContact] {
        let restants = DonneesFt.contacts.filter { !destinataires.contains($0.nom) }
        let texte = saisie.trimmingCharacters(in: .whitespaces)
        guard !texte.isEmpty else { return restants }
        return restants.filter {
            $0.nom.localizedCaseInsensitiveContains(texte) || $0.identifiant.localizedCaseInsensitiveContains(texte)
        }
    }
    private var pret: Bool { !destinataires.isEmpty }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { fermer() }
            VStack(spacing: 0) {
                poignee
                entete
                champDestinataires
                suggestions
                Spacer(minLength: 0)
                boutons
            }
            .frame(maxWidth: .infinity)
            .frame(height: 430)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: 0x151517))
            )
            .padding(.horizontal, 6)
            .padding(.bottom, 34)
        }
        .transition(.move(edge: .bottom))
    }

    private var poignee: some View {
        Capsule().fill(FtTeinte.separateur)
            .frame(width: 38, height: 5)
            .padding(.top, 8)
    }

    private var entete: some View {
        ZStack {
            Text("Nouveau FaceTime")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(FtTeinte.texte)
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(FtTeinte.texte2)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(FtTeinte.carte2))
                    .contentShape(Circle())
                    .onTapGesture { Haptique.leger(); fermer() }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    private var champDestinataires: some View {
        HStack(spacing: 8) {
            Text("À :")
                .font(.system(size: 15))
                .foregroundStyle(FtTeinte.texte2)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(destinataires, id: \.self) { nom in
                        FtJeton(nom: nom) {
                            withAnimation { destinataires.removeAll { $0 == nom } }
                        }
                    }
                    TextField("", text: $saisie,
                              prompt: Text("Nom, e-mail ou numéro").foregroundStyle(FtTeinte.texte2))
                        .font(.system(size: 15))
                        .foregroundStyle(FtTeinte.texte)
                        .focused($champActif)
                        .frame(minWidth: 150)
                        .onSubmit { ajouterPremier() }
                }
            }
            Image(systemName: tousVisibles ? "minus" : "plus")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(FtTeinte.texte)
                .frame(width: 28, height: 28)
                .background(Circle().fill(FtTeinte.separateur))
                .contentShape(Circle())
                .onTapGesture {
                    Haptique.leger()
                    withAnimation { tousVisibles.toggle() }
                }
        }
        .padding(.horizontal, 12)
        .frame(height: 46)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(FtTeinte.carte))
        .padding(.horizontal, 14)
        .padding(.top, 14)
    }

    @ViewBuilder
    private var suggestions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tousVisibles ? "Tous les contacts" : "Suggestions")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(FtTeinte.texte)
                .padding(.horizontal, 16)
            if candidats.isEmpty {
                Text("Aucun contact ne correspond")
                    .font(.system(size: 14))
                    .foregroundStyle(FtTeinte.texte2)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            } else if tousVisibles {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(candidats) { contact in
                            FtLigneContact(contact: contact) { ajouter(contact.nom) }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxHeight: 168)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 18) {
                        ForEach(candidats.prefix(6)) { contact in
                            FtSuggestion(contact: contact) { ajouter(contact.nom) }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.top, 16)
    }

    private var boutons: some View {
        HStack {
            Circle()
                .fill(FtTeinte.vert)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "link")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(FtTeinte.blanc)
                )
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); surLien() }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "video.fill").font(.system(size: 16))
                Text("FaceTime").font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(FtTeinte.blanc)
            .padding(.horizontal, 26)
            .frame(height: 50)
            .background(Capsule().fill(pret ? FtTeinte.vert : FtTeinte.vertSombre))
            .opacity(pret ? 1 : 0.6)
            .contentShape(Capsule())
            .onTapGesture { if pret { surAppel(destinataires, .video) } }
            Spacer()
            Circle()
                .fill(pret ? FtTeinte.vert : FtTeinte.vertSombre)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "phone.fill")
                        .font(.system(size: 19))
                        .foregroundStyle(FtTeinte.blanc)
                )
                .opacity(pret ? 1 : 0.6)
                .contentShape(Circle())
                .onTapGesture { if pret { surAppel(destinataires, .audio) } }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 22)
    }

    private func ajouter(_ nom: String) {
        Haptique.leger()
        withAnimation {
            if !destinataires.contains(nom) { destinataires.append(nom) }
            saisie = ""
        }
    }

    private func ajouterPremier() {
        guard let premier = candidats.first else { return }
        ajouter(premier.nom)
    }
}

struct FtJeton: View {
    let nom: String
    var retirer: () -> Void = { }
    var body: some View {
        HStack(spacing: 5) {
            Text(nom)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(FtTeinte.vert)
                .lineLimit(1)
            Image(systemName: "xmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(FtTeinte.vert)
        }
        .padding(.horizontal, 9)
        .frame(height: 26)
        .background(Capsule().fill(FtTeinte.vert.opacity(0.18)))
        .contentShape(Capsule())
        .onTapGesture { Haptique.leger(); retirer() }
    }
}

struct FtSuggestion: View {
    let contact: FtContact
    var action: () -> Void = { }
    var body: some View {
        VStack(spacing: 6) {
            FtAvatar(nom: contact.nom, diametre: 56)
            Text(FtFormat.prenom(contact.nom))
                .font(.system(size: 12))
                .foregroundStyle(FtTeinte.texte)
                .lineLimit(1)
        }
        .frame(width: 66)
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }
}

struct FtLigneContact: View {
    let contact: FtContact
    var action: () -> Void = { }
    var body: some View {
        HStack(spacing: 10) {
            FtAvatar(nom: contact.nom, diametre: 34)
            VStack(alignment: .leading, spacing: 1) {
                Text(contact.nom)
                    .font(.system(size: 15))
                    .foregroundStyle(FtTeinte.texte)
                Text(contact.identifiant)
                    .font(.system(size: 12.5))
                    .foregroundStyle(FtTeinte.texte2)
            }
            Spacer()
        }
        .padding(.vertical, 7)
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }
}

// ============================================================ ÉCRAN 4/5 — APPEL SORTANT & INDISPONIBLE
// Référence : 05_appleguide_appel_sortant_indisponible.png (avatar rond, « X est indisponible »,
// « FaceTime vidéo », Rappeler / Enregistrer une vidéo / Fermer).
// Règle du 16/08 reprise de l'app Téléphone validée (D52/D53) : PERSONNE ne décroche.
// Marc, lui, ne décroche jamais un appel vidéo — c'est le cœur de l'indice.

struct FtAppelVue: View {
    var noms: [String] = ["Marc ❤️"]
    var mode: FtMode = .video
    var surEnregistrer: (String) -> Void = { _ in }
    var fermer: () -> Void = { }
    /// Sert au registre de capture (`facetime.indisponible`) : ouvre l'écran déjà en fin d'appel.
    var indisponibleInitiale: Bool = false

    @State private var secondes = 0
    @State private var indisponible = false
    private let tic = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var titre: String { FtFormat.liste(noms) }
    private var statut: String {
        if indisponible { return mode.libelle }
        if secondes >= 2 { return "sonnerie…" }
        return mode == .video ? "Appel FaceTime vidéo…" : "Appel FaceTime audio…"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(colors: [Color(white: 0.10), Color.black],
                           center: .init(x: 0.5, y: 0.32), startRadius: 40, endRadius: 460)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                avatars
                Text(indisponible ? FtFormat.indisponible(noms) : titre)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(FtTeinte.texte)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                Text(statut)
                    .font(.system(size: 16))
                    .foregroundStyle(FtTeinte.texte2)
                    .padding(.top, 5)
                Spacer()
                if indisponible {
                    boutonsIndisponible
                } else {
                    boutonRaccrocher
                }
            }
        }
        .onAppear { if indisponibleInitiale { indisponible = true } }
        .onReceive(tic) { _ in
            guard !indisponible else { return }
            secondes += 1
            if secondes >= 7 {
                Haptique.leger()
                withAnimation(.easeOut(duration: 0.25)) { indisponible = true }
            }
        }
    }

    private var avatars: some View {
        HStack(spacing: -18) {
            ForEach(noms.prefix(3), id: \.self) { nom in
                FtAvatar(nom: nom, diametre: noms.count > 1 ? 106 : 150)
                    .overlay(Circle().stroke(Color.black.opacity(0.6), lineWidth: noms.count > 1 ? 3 : 0))
            }
        }
    }

    private var boutonRaccrocher: some View {
        Circle()
            .fill(FtTeinte.rouge)
            .frame(width: 66, height: 66)
            .overlay(
                Image(systemName: "xmark")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(FtTeinte.blanc)
            )
            .contentShape(Circle())
            .onTapGesture { Haptique.leger(); fermer() }
            .padding(.bottom, 88)
    }

    private var boutonsIndisponible: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                FtBoutonPilule(titre: "Rappeler", symbole: mode.symbole,
                               fond: FtTeinte.vert, texte: FtTeinte.blanc) {
                    secondes = 0
                    withAnimation { indisponible = false }
                }
                if mode == .video {
                    FtBoutonPilule(titre: "Enregistrer\nune vidéo", symbole: "record.circle",
                                   fond: FtTeinte.blanc, texte: Color.black, symboleRouge: true) {
                        surEnregistrer(noms.first ?? "")
                    }
                }
            }
            FtBoutonPilule(titre: "Fermer", symbole: nil,
                           fond: FtTeinte.carte2, texte: FtTeinte.texte, pleineLargeur: true) {
                fermer()
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 80)
    }
}

struct FtBoutonPilule: View {
    let titre: String
    var symbole: String? = nil
    var fond: Color = FtTeinte.vert
    var texte: Color = FtTeinte.blanc
    var symboleRouge: Bool = false
    var pleineLargeur: Bool = false
    var action: () -> Void = { }

    var body: some View {
        contenu
            .frame(maxWidth: largeurMax)
            .frame(minWidth: largeurMin, minHeight: 52)
            .background(Capsule().fill(fond))
            .contentShape(Capsule())
            .onTapGesture { Haptique.leger(); action() }
    }

    private var largeurMax: CGFloat { pleineLargeur ? CGFloat.infinity : CGFloat(230) }
    private var largeurMin: CGFloat { pleineLargeur ? CGFloat(0) : CGFloat(140) }

    private var contenu: some View {
        HStack(spacing: 7) {
            if let symbole {
                Image(systemName: symbole)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(symboleRouge ? FtTeinte.rougeVif : texte)
            }
            Text(titre)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(texte)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
    }
}

// ============================================================ ÉCRAN 6 — ENREGISTREMENT D'UN MESSAGE VIDÉO
// Référence : 08_appleguide_message_video_enregistrement.png (Annuler / « À X » / Enregistrer,
// grand bouton flèche verte, « Reprendre »). Viseur SANS caméra réelle : pénombre granuleuse,
// comme le retour caméra de `AppelVideoVue` du fichier partagé (D82-A plutôt qu'une fausse vidéo).

enum FtPhaseEnregistrement {
    case pret
    case decompte
    case enregistre
    case relecture
}

struct FtEnregistrementVue: View {
    var destinataire: String = "Marc ❤️"
    var fermer: () -> Void = { }
    /// Sert au registre de capture (`facetime.enregistrement`) : ouvre l'écran sur une phase donnée.
    var phaseInitiale: FtPhaseEnregistrement = .pret

    @State private var phase: FtPhaseEnregistrement = .pret
    @State private var decompte = 3
    @State private var secondes = 0
    @State private var envoye = false
    private let tic = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            viseur
            VStack(spacing: 0) {
                barreHaut
                Spacer()
                centre
                Spacer()
                barreBas
            }
            if envoye { confirmation }
        }
        .onAppear { phase = phaseInitiale }
        .onReceive(tic) { _ in avancer() }
    }

    private var viseur: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(colors: [Color(white: 0.11), Color.black],
                           center: .init(x: 0.44, y: 0.34), startRadius: 60, endRadius: 520)
                .ignoresSafeArea()
            Canvas { contexte, taille in
                var graine: UInt64 = 20260817
                for _ in 0..<260 {
                    graine = graine &* 6364136223846793005 &+ 1442695040888963407
                    let fx = CGFloat(Double((graine >> 16) % 1000) / 1000.0)
                    let fy = CGFloat(Double((graine >> 33) % 1000) / 1000.0)
                    let x: CGFloat = fx * taille.width
                    let y: CGFloat = fy * taille.height
                    contexte.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.4, height: 1.4)),
                                  with: .color(Color.white.opacity(0.05)))
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    private var barreHaut: some View {
        HStack {
            Text("Annuler")
                .font(.system(size: 16))
                .foregroundStyle(FtTeinte.texte)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); fermer() }
            Spacer()
            Text("À \(FtFormat.prenom(destinataire))")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(FtTeinte.texte)
            Spacer()
            Text(phase == .enregistre ? "Arrêter" : "Enregistrer")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(phase == .pret ? Color.black : FtTeinte.texte)
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(Capsule().fill(phase == .pret ? FtTeinte.blanc : FtTeinte.carte2))
                .contentShape(Capsule())
                .onTapGesture { basculerEnregistrement() }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    @ViewBuilder
    private var centre: some View {
        switch phase {
        case .pret:
            Text("Appuyez sur Enregistrer")
                .font(.system(size: 15))
                .foregroundStyle(FtTeinte.texte2)
        case .decompte:
            Text("\(decompte)")
                .font(.system(size: 82, weight: .light))
                .foregroundStyle(FtTeinte.blanc)
        case .enregistre:
            HStack(spacing: 8) {
                Circle().fill(FtTeinte.rougeVif).frame(width: 10, height: 10)
                Text(FtFormat.chrono(secondes))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(FtTeinte.blanc)
            }
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(Capsule().fill(Color.black.opacity(0.45)))
        case .relecture:
            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: "play.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(FtTeinte.blanc)
                )
        }
    }

    @ViewBuilder
    private var barreBas: some View {
        if phase == .relecture {
            HStack {
                Spacer()
                Circle()
                    .fill(FtTeinte.blanc)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: "arrow.up")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(FtTeinte.vert)
                    )
                    .contentShape(Circle())
                    .onTapGesture { envoyer() }
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Text("Reprendre")
                    .font(.system(size: 15))
                    .foregroundStyle(FtTeinte.texte)
                    .padding(.trailing, 22)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Haptique.leger()
                        secondes = 0
                        decompte = 3
                        phase = .decompte
                    }
            }
            .padding(.bottom, 76)
        } else {
            Color.clear.frame(height: 76)
        }
    }

    private var confirmation: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(FtTeinte.vert)
                Text("Message vidéo envoyé à \(FtFormat.prenom(destinataire))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(FtTeinte.texte)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Capsule().fill(FtTeinte.carte))
            Spacer()
        }
    }

    private func basculerEnregistrement() {
        Haptique.leger()
        switch phase {
        case .pret:
            decompte = 3
            secondes = 0
            phase = .decompte
        case .enregistre:
            phase = .relecture
        default:
            break
        }
    }

    private func avancer() {
        switch phase {
        case .decompte:
            decompte -= 1
            if decompte <= 0 { phase = .enregistre; secondes = 0 }
        case .enregistre:
            secondes += 1
            if secondes >= 30 { phase = .relecture }
        default:
            break
        }
    }

    private func envoyer() {
        Haptique.leger()
        FtEtat.partage.enregistrer(pour: destinataire, secondes: max(1, secondes))
        withAnimation { envoye = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { fermer() }
    }
}

// ============================================================ ÉCRAN 7 — LECTURE D'UN MESSAGE VIDÉO
// D92, juste milieu : aucune vidéo réelle n'existe. Plutôt qu'une fausse image, un lecteur sombre
// qui déroule la TRANSCRIPTION du message, ligne par ligne, au rythme du chrono.

struct FtLecteurMessageVue: View {
    var message: FtMessageVideo = DonneesFt.messageParDefaut
    var fermer: () -> Void = { }

    @State private var secondes = 0
    @State private var enLecture = false
    private let tic = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var progression: Double {
        guard message.secondes > 0 else { return 0 }
        return min(1, Double(secondes) / Double(message.secondes))
    }
    private var titre: String {
        if message.deSarah { return "Message vidéo pour " + FtFormat.prenom(message.pour) }
        return "Message vidéo de " + FtFormat.prenom(message.auteur)
    }
    private var sousTitre: String { message.quand + " · " + message.duree }
    private var lignesVisibles: Int {
        guard message.secondes > 0, !message.lignes.isEmpty else { return 0 }
        let pas = max(1, message.secondes / message.lignes.count)
        return min(message.lignes.count, (secondes / pas) + (secondes > 0 ? 1 : 0))
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.94).ignoresSafeArea()
            RadialGradient(colors: [Color(white: 0.09), Color.black],
                           center: .init(x: 0.5, y: 0.3), startRadius: 50, endRadius: 480)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                entete
                Spacer()
                FtAvatar(nom: message.auteur, diametre: 100)
                Text(titre)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(FtTeinte.texte)
                    .padding(.top, 14)
                Text(sousTitre)
                    .font(.system(size: 13))
                    .foregroundStyle(FtTeinte.texte2)
                    .padding(.top, 3)
                transcription
                Spacer()
                controles
            }
        }
        .onReceive(tic) { _ in
            guard enLecture else { return }
            secondes += 1
            if secondes >= message.secondes {
                secondes = message.secondes
                enLecture = false
                FtEtat.partage.messagesEcoutes.insert(message.id)
            }
        }
    }

    private var entete: some View {
        HStack {
            Spacer()
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(FtTeinte.texte2)
                .frame(width: 32, height: 32)
                .background(Circle().fill(FtTeinte.carte))
                .contentShape(Circle())
                .onTapGesture { Haptique.leger(); fermer() }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var transcription: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transcription")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(FtTeinte.texte2)
            if lignesVisibles == 0 {
                Text("Lancez la lecture pour afficher la transcription.")
                    .font(.system(size: 14))
                    .foregroundStyle(FtTeinte.texte2)
            } else {
                ForEach(0..<lignesVisibles, id: \.self) { index in
                    Text("« \(message.lignes[index]) »")
                        .font(.system(size: 15))
                        .italic()
                        .foregroundStyle(FtTeinte.texte.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.06)))
        .padding(.horizontal, 22)
        .padding(.top, 22)
    }

    private var controles: some View {
        VStack(spacing: 10) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(FtTeinte.separateur).frame(height: 4)
                    Capsule().fill(FtTeinte.texte)
                        .frame(width: max(CGFloat(4), geo.size.width * CGFloat(progression)), height: 4)
                }
            }
            .frame(height: 6)
            HStack {
                Text(FtFormat.chrono(secondes))
                    .font(.system(size: 11))
                    .foregroundStyle(FtTeinte.texte2)
                Spacer()
                Text(message.duree)
                    .font(.system(size: 11))
                    .foregroundStyle(FtTeinte.texte2)
            }
            Circle()
                .fill(FtTeinte.vert)
                .frame(width: 62, height: 62)
                .overlay(
                    Image(systemName: enLecture ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(FtTeinte.blanc)
                )
                .contentShape(Circle())
                .onTapGesture {
                    Haptique.leger()
                    if secondes >= message.secondes { secondes = 0 }
                    enLecture.toggle()
                    if enLecture { FtEtat.partage.messagesEcoutes.insert(message.id) }
                }
                .padding(.top, 6)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 76)
    }
}

// ============================================================ ÉCRAN 8 — LIEN FACETIME
// Aucune capture officielle de l'écran « Créer un lien » n'existe (SOURCES.md §3) : on ne
// reproduit donc PAS l'écran d'Apple. Feuille minimale, sobre, avec une copie RÉELLE
// dans le presse-papiers — l'affordance du bouton lien de 04 garde ainsi une conséquence.

struct FtLienVue: View {
    var fermer: () -> Void = { }
    @State private var copie = false

    private let lien = "https://facetime.apple.com/join#v=1&p=sarah-lev&k=8f3c1a"

    private var titreCopie: String { copie ? "Lien copié" : "Copier" }
    private var symboleCopie: String { copie ? "checkmark" : "doc.on.doc" }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { fermer() }
            VStack(spacing: 14) {
                Capsule().fill(FtTeinte.separateur)
                    .frame(width: 38, height: 5)
                    .padding(.top, 8)
                Text("Lien FaceTime")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(FtTeinte.texte)
                Text("Toute personne disposant de ce lien peut rejoindre l'appel.")
                    .font(.system(size: 13))
                    .foregroundStyle(FtTeinte.texte2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                Text(lien)
                    .font(.system(size: 13))
                    .foregroundStyle(FtTeinte.vert)
                    .lineLimit(2)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(FtTeinte.carte))
                    .padding(.horizontal, 20)
                HStack(spacing: 10) {
                    FtBoutonPilule(titre: titreCopie,
                                   symbole: symboleCopie,
                                   fond: FtTeinte.vert, texte: FtTeinte.blanc) {
                        UIPasteboard.general.string = lien
                        FtEtat.partage.lienCree = true
                        withAnimation { copie = true }
                    }
                    FtBoutonPilule(titre: "Fermer", symbole: nil,
                                   fond: FtTeinte.carte2, texte: FtTeinte.texte) {
                        fermer()
                    }
                }
                .padding(.bottom, 18)
            }
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(hex: 0x151517)))
            .padding(.horizontal, 6)
            .padding(.bottom, 34)
        }
        .transition(.move(edge: .bottom))
    }
}
