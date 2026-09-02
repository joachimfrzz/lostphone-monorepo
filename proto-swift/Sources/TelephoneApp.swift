// App TÉLÉPHONE iOS 26 — construite contre references/telephone/ (vidéo réelle du 16/08)
// 5 onglets : Favoris / Récents / Contacts / Clavier / Messagerie. Règles D51-D55 d'office :
// tout répond, appels sortants = sonnent puis Indisponible (D52/D53), répondeur écoutable + transcription.
import SwiftUI

// Couleurs mesurées sur les références
let telNoir = Color(hex: 0x000000)
let telChamp = Color(hex: 0x1C1C1E)
let telBleu = Color(hex: 0x0A84FF)
let telRouge = Color(hex: 0xFF453A)
let telVert = Color(hex: 0x30D158)
let telTexte = Color(hex: 0xF2F2F2)
let telTexte2 = Color(hex: 0x8E8E93)

// ============================================================ DONNÉES (Coches bleues)
struct AppelRecent {
    let nom: String
    let manque: Bool
    let sortant: Bool
    let type: String       // "portable", "WhatsApp audio", "FaceTime vidéo"…
    let date: String
    let compte: Int        // (2), (3)…
    let duree: String?     // nil si manqué
}

struct MessageVocal {
    let nom: String
    let date: String
    let duree: String
    let fichier: String
    let transcription: String
}

enum DonneesTel {
    // v2 correctifs 31/08 : TRIÉ du plus récent au plus ancien (aujourd'hui = lundi 17 août)
    static let recents: [AppelRecent] = [
        AppelRecent(nom: "Chloé", manque: true, sortant: false, type: "portable", date: "19:33", compte: 2, duree: nil),
        AppelRecent(nom: "Thomas", manque: false, sortant: false, type: "portable", date: "sam.", compte: 1, duree: "8 minutes"),
        AppelRecent(nom: "Chloé", manque: false, sortant: true, type: "portable", date: "jeudi", compte: 1, duree: "3 minutes"),
        AppelRecent(nom: "Agence Bellecour", manque: false, sortant: false, type: "portable", date: "mercredi", compte: 1, duree: "4 minutes"),
        AppelRecent(nom: "Marie kiné", manque: false, sortant: true, type: "portable", date: "mardi", compte: 1, duree: "6 minutes"),
        AppelRecent(nom: "Maman", manque: false, sortant: true, type: "portable", date: "dim. 12 juil.", compte: 1, duree: "12 minutes"),
        AppelRecent(nom: "Marc ❤️", manque: false, sortant: false, type: "WhatsApp vidéo", date: "5 juil.", compte: 1, duree: "19 secondes"),
        AppelRecent(nom: "Marc ❤️", manque: true, sortant: false, type: "WhatsApp vidéo", date: "6 mai", compte: 1, duree: nil),
    ]

    static let contacts: [(String, String)] = [
        ("Agence Bellecour", "04 72 40 18 62"),
        ("Chloé", "+33 6 24 81 05 77"),
        ("Julie", "+33 6 47 92 33 08"),
        ("Maman", "+33 6 88 41 27 30"),
        ("Marc ❤️", "+33 7 49 12 53 08"),
        ("Marie kiné", "+33 6 02 55 18 64"),
        ("Papa", "+33 6 71 05 44 92"),
        ("Thomas", "+33 6 51 33 90 12"),
    ]

    static let messagerie: [MessageVocal] = [
        MessageVocal(nom: "Agence Bellecour", date: "mercredi", duree: "0:25", fichier: "repondeur-banque",
                     transcription: "Bonjour madame, Philippe Garnier, votre conseiller de l'agence Bellecour. Je vous confirme votre rendez-vous de lundi à onze heures trente concernant votre demande de virement international. Pensez à apporter une pièce d'identité et le RIB du bénéficiaire. Je me permets d'insister : pour un premier virement de ce montant vers ce type de compte, nous devrons passer en revue quelques points de vigilance ensemble. À lundi, madame. Bonne journée."),
        MessageVocal(nom: "Maman", date: "vendredi", duree: "0:19", fichier: "vocal-maman",
                     transcription: "Allô ma chérie, c'est maman ! Alors dis-moi, pour dimanche… le rôti, je le mets au four à quelle heure ? Ton père dit midi, moi je dis onze heures et demie… Rappelle-moi ! Ah, et ramène-moi mon tupperware, le bleu. Bisous bisous ma chérie."),
    ]
}

// ============================================================ MAGASIN TÉLÉPHONE (v2 étape 4 — audit D82)
// Favoris réels, suppressions d'appels/vocaux (session), contacts ajoutés par le joueur.
final class MagasinTel: ObservableObject {
    static let partage = MagasinTel()
    @Published var favoris: [String] = ["Maman", "Chloé", "Marc ❤️"]   // crédible : Sarah a des favoris
    @Published var appelsSupprimes: Set<Int> = []      // index dans DonneesTel.recents
    @Published var vocauxSupprimes: Set<String> = []   // fichiers
    @Published var contactsAjoutes: [(String, String)] = []

    var tousContacts: [(String, String)] {
        (DonneesTel.contacts + contactsAjoutes).sorted { $0.0.localizedCaseInsensitiveCompare($1.0) == .orderedAscending }
    }
    func basculerFavori(_ nom: String) {
        if let i = favoris.firstIndex(of: nom) { favoris.remove(at: i) } else { favoris.append(nom) }
    }
}

// ============================================================ APP TÉLÉPHONE (5 onglets)
struct TelephoneVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? (Routeur.partage.numeroAppel != nil ? 3 : 1) // 0 Favoris, 1 Récents, 2 Contacts, 3 Clavier, 4 Messagerie

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                telNoir.ignoresSafeArea()
                Group {
                    switch onglet {
                    case 0: TelFavorisVue()
                    case 2: TelContactsVue()
                    case 3: TelClavierVue()
                    case 4: TelMessagerieVue()
                    default: TelRecentsVue()
                    }
                }

                HStack(spacing: 0) {
                    OngletTel(symbole: "star.fill", nom: "Favoris", actif: onglet == 0) { onglet = 0 }
                    OngletTel(symbole: "clock.fill", nom: "Récents", actif: onglet == 1) { onglet = 1 }
                    OngletTel(symbole: "person.crop.circle", nom: "Contacts", actif: onglet == 2) { onglet = 2 }
                    OngletTel(symbole: "circle.grid.3x3.fill", nom: "Clavier", actif: onglet == 3) { onglet = 3 }
                    OngletTel(symbole: "recordingtape", nom: "Messagerie", actif: onglet == 4) { onglet = 4 }
                }
                .padding(.vertical, 8).padding(.horizontal, 6)
                .background(Color(hex: 0x1D1D1D), in: Capsule())
                .padding(.horizontal, 14).padding(.bottom, 6)

            BarreHome { dismiss() }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct OngletTel: View {
    let symbole: String
    let nom: String
    var actif: Bool = false
    var action: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbole).font(.system(size: 20))
                .foregroundStyle(actif ? telBleu : telTexte2)
            Text(nom).font(.system(size: 10, weight: actif ? .semibold : .regular))
                .foregroundStyle(actif ? telBleu : telTexte2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(actif ? Color(hex: 0x303030) : .clear, in: Capsule())
        .contentShape(Rectangle())
        .onTapGesture { action?() }
    }
}

// ============================================================ RÉCENTS
struct TelRecentsVue: View {
    @State private var filtreManques = false
    @State private var menuVisible = false
    @State private var appelVisible = false
    @State private var appelDestinataire = ""
    @State private var appelNumero = ""
    @State private var recherche = ""
    @State private var modeSelection = false
    @State private var selection = Set<Int>()
    @ObservedObject private var magasin = MagasinTel.partage

    // v2 étape 4 : indices réels conservés pour suppression/sélection
    private var appels: [(Int, AppelRecent)] {
        var r = Array(DonneesTel.recents.enumerated()).filter { !magasin.appelsSupprimes.contains($0.offset) }
        if filtreManques { r = r.filter { $0.element.manque } }
        if !recherche.isEmpty {
            r = r.filter { $0.element.nom.localizedCaseInsensitiveContains(recherche) }
        }
        return r.map { ($0.offset, $0.element) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Barre du haut : Modifier | Tous/Manqués | menu
            HStack {
                Text(modeSelection ? "Terminé" : "Modifier").font(.system(size: 16)).foregroundStyle(telTexte)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(telChamp, in: Capsule())
                    .contentShape(Capsule())
                    .onTapGesture { Haptique.leger(); modeSelection.toggle() }
                Spacer()
                HStack(spacing: 0) {
                    Text("Tous").font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(filtreManques ? telTexte2 : telTexte)
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(filtreManques ? .clear : Color(hex: 0x3A3A3C), in: Capsule())
                        .onTapGesture { filtreManques = false }
                    Text("Manqués").font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(filtreManques ? telTexte : telTexte2)
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(filtreManques ? Color(hex: 0x3A3A3C) : .clear, in: Capsule())
                        .onTapGesture { filtreManques = true }
                }
                .padding(3)
                .background(telChamp, in: Capsule())
                Spacer()
                // v2 correctifs 31/08 : bouton ≡ (effacer l'historique) SUPPRIMÉ — décision Joachim
            }
            .padding(.horizontal, 16).padding(.top, 8)

            HStack {
                Text("Récents").font(.system(size: 34, weight: .bold)).foregroundStyle(telTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 10)

            // v2 étape 4 : vraie recherche (clavier réel, filtre en direct)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(telTexte2).font(.system(size: 16))
                TextField("", text: $recherche,
                          prompt: Text("Recherche").foregroundStyle(telTexte2))
                    .foregroundStyle(telTexte).font(.system(size: 17))
            }
            .padding(.horizontal, 12).frame(height: 38)
            .background(telChamp, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16).padding(.top, 10)

            List {
                ForEach(appels, id: \.0) { paire in
                    let indexReel = paire.0
                    let a = paire.1
                    HStack(spacing: 12) {
                        if modeSelection {
                            Image(systemName: "minus.circle.fill").font(.system(size: 22))
                                .foregroundStyle(telRouge)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    Haptique.leger()
                                    withAnimation { _ = magasin.appelsSupprimes.insert(indexReel) }
                                }
                        }
                        // Miroir phase B : la réf montre des INITIALES rondes, pas des silhouettes
                        if a.nom == "Marc ❤️" {
                            AvatarSilhouette(taille: 42, image: "AvatarMarc")
                        } else {
                            Circle().fill(Color(hex: 0x3A3A3C)).frame(width: 42, height: 42)
                                .overlay(Text(a.nom.split(separator: " ").prefix(2).compactMap { $0.first.map(String.init) }.joined().uppercased())
                                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.compte > 1 ? "\(a.nom)  (\(a.compte))" : a.nom)
                                .font(.system(size: 17))
                                .foregroundStyle(a.manque ? telRouge : telTexte)
                            HStack(spacing: 4) {
                                Image(systemName: a.sortant ? "arrow.up.right" : "arrow.down.left")
                                    .font(.system(size: 11, weight: .bold)).foregroundStyle(telTexte2)
                                Text(a.type).font(.system(size: 14)).foregroundStyle(telTexte2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let num = DonneesTel.contacts.first(where: { $0.0 == a.nom })?.1 ?? "numéro masqué"
                            appelDestinataire = a.nom
                            appelNumero = num
                            Haptique.leger()
                            appelVisible = true
                        }
                        // v2 correctifs 31/08 : date + ⓘ calés à DROITE (le NavigationLink ne s'étire plus)
                        Text(a.date).font(.system(size: 15)).foregroundStyle(telTexte2)
                            .layoutPriority(1)
                        NavigationLink(destination: TelFicheVue(nom: a.nom)) {
                            Image(systemName: "info.circle").font(.system(size: 20)).foregroundStyle(telBleu)
                        }
                        .fixedSize()
                    }
                    .listRowBackground(telNoir)
                    .listRowSeparatorTint(Color(hex: 0x222222))
                    // v2 étape 4 : balayage = suppression réelle (comme iOS)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation { _ = magasin.appelsSupprimes.insert(indexReel) }
                        } label: { Label("Supprimer", systemImage: "trash.fill") }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .padding(.bottom, 70)
        }
        .fullScreenCover(isPresented: $appelVisible) {
            AppelTelVue(destinataire: appelDestinataire, numero: appelNumero)
        }
    }
}

// ============================================================ FICHE CONTACT (verre liquide)
struct TelFicheVue: View {
    @Environment(\.dismiss) private var dismiss
    let nom: String
    @State private var appelVisible = false
    @State private var messagesVisible = false
    @State private var ongletVocaux = false
    @State private var notesTexte = ""
    @State private var notesEnEdition = false
    @ObservedObject private var lecteurAudio = LecteurAudio.partage   // v2 étape 4 : lecture vocaux fiche

    private var numero: String {
        if nom == "Sarah Levasseur" { return "+33 6 99 01 47 23" }   // le numéro de Sarah (cohérent QR WhatsApp)
        return MagasinTel.partage.tousContacts.first(where: { $0.0 == nom })?.1 ?? "numéro masqué"
    }
    private var initiales: String {
        let mots = nom.split(separator: " ")
        return mots.prefix(2).compactMap { $0.first.map(String.init) }.joined()
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x2A2440), Color(hex: 0x101018)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left").font(.system(size: 19, weight: .semibold))
                                .foregroundStyle(telTexte).padding(10)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        Spacer()
                        // v2 étape 4 : Modifier ouvre la vraie feuille de modification (session)
                        BoutonModifierContact(nom: nom, numero: numero)
                    }
                    .padding(.horizontal, 16).padding(.top, 6)

                    ZStack {
                        Circle().fill(.ultraThinMaterial).frame(width: 130, height: 130)
                        if nom == "Marc ❤️" {
                            AvatarSilhouette(taille: 124, image: "AvatarMarc")
                        } else {
                            Text(initiales.uppercased())
                                .font(.system(size: 46, weight: .medium)).foregroundStyle(telTexte)
                        }
                    }
                    .padding(.top, 14)
                    Text(nom).font(.system(size: 30, weight: .bold)).foregroundStyle(telTexte).padding(.top, 10)

                    HStack(spacing: 14) {
                        RondFiche(symbole: "message.fill") { messagesVisible = true }
                        RondFiche(symbole: "phone.fill") { appelVisible = true }
                        RondFiche(symbole: "video.fill") { appelVisible = true }
                        // v2 correctifs 31/08 : Mail s'ouvre sur un NOUVEAU MESSAGE préadressé au contact
                        RondFiche(symbole: "envelope.fill") {
                            Routeur.partage.allerMail(composePour: AnnuaireMail.adresse(nom))
                        }
                    }
                    .padding(.top, 16)

                    // Miroir phase B (réf 03-fiche-contact) : segments + carte numéro + Notes
                    HStack(spacing: 0) {
                        Text("Détails")
                            .font(.system(size: 14, weight: ongletVocaux ? .regular : .semibold))
                            .foregroundStyle(ongletVocaux ? telTexte2 : telTexte)
                            .padding(.vertical, 7).frame(maxWidth: .infinity)
                            .background(ongletVocaux ? AnyShapeStyle(.clear) : AnyShapeStyle(.ultraThinMaterial), in: Capsule())
                            .contentShape(Rectangle())
                            .onTapGesture { withAnimation(.easeInOut(duration: 0.18)) { ongletVocaux = false } }
                        Text("Messages vocaux")
                            .font(.system(size: 14, weight: ongletVocaux ? .semibold : .regular))
                            .foregroundStyle(ongletVocaux ? telTexte : telTexte2)
                            .padding(.vertical, 7).frame(maxWidth: .infinity)
                            .background(ongletVocaux ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear), in: Capsule())
                            .contentShape(Rectangle())
                            .onTapGesture { withAnimation(.easeInOut(duration: 0.18)) { ongletVocaux = true } }
                    }
                    .padding(3)
                    .background(Color.white.opacity(0.06), in: Capsule())
                    .padding(.horizontal, 16).padding(.top, 18)

                    if ongletVocaux {
                        // Onglet Messages vocaux : filtrés depuis DonneesTel.messagerie
                        let vocaux = DonneesTel.messagerie.filter { $0.nom == nom }
                        if vocaux.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "recordingtape").font(.system(size: 36)).foregroundStyle(telTexte2)
                                Text("Aucun message vocal").font(.system(size: 15)).foregroundStyle(telTexte2)
                            }
                            .frame(maxWidth: .infinity).padding(.top, 40)
                        } else {
                            ForEach(vocaux, id: \.fichier) { v in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        // v2 étape 4 : lecture réelle du vocal depuis la fiche
                                        Button { LecteurAudio.partage.bascule(v.fichier) } label: {
                                            Image(systemName: LecteurAudio.partage.fichierActif == v.fichier ? "pause.circle.fill" : "play.circle.fill")
                                                .font(.system(size: 26)).foregroundStyle(telBleu)
                                        }
                                        Text(v.date).font(.system(size: 13)).foregroundStyle(telTexte2)
                                        Spacer()
                                        Text(v.duree).font(.system(size: 13)).foregroundStyle(telTexte2)
                                    }
                                    Text("« \(v.transcription.prefix(80))… »")
                                        .font(.system(size: 14)).foregroundStyle(telTexte.opacity(0.85))
                                        .lineLimit(3)
                                }
                                .padding(14)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                                .padding(.horizontal, 16).padding(.top, 10)
                            }
                        }
                    } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("portable").font(.system(size: 13)).foregroundStyle(telTexte2)
                        HStack {
                            Text(numero).font(.system(size: 17)).foregroundStyle(Color(hex: 0x64B5F7))
                            Spacer()
                            Image(systemName: "phone.fill").font(.system(size: 15)).foregroundStyle(telTexte2)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16).padding(.top, 10)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); appelVisible = true }   // v2 étape 4 : la carte numéro appelle

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes").font(.system(size: 13)).foregroundStyle(telTexte2)
                        if notesEnEdition {
                            TextField("Ajouter une note…", text: $notesTexte)
                                .font(.system(size: 15)).foregroundStyle(telTexte)
                                .onSubmit { notesEnEdition = false }
                        } else {
                            Text(notesTexte.isEmpty ? " " : notesTexte)
                                .font(.system(size: 15)).foregroundStyle(notesTexte.isEmpty ? telTexte2 : telTexte)
                                .frame(height: 26, alignment: .leading)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16).padding(.top, 10)
                    .contentShape(Rectangle())
                    .onTapGesture { notesEnEdition = true }

                    // Historique — DÉRIVÉ du même journal que l'onglet Récents (cohérence R3)
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Historique des appels").font(.system(size: 16)).foregroundStyle(telTexte)
                            Spacer()
                            // v2 étape 4 : chevron retiré (il ne menait nulle part — l'historique est dessous)
                        }
                        .padding(.horizontal, 14).padding(.top, 12)
                        let historique = DonneesTel.recents.filter { $0.nom == nom }.prefix(3)
                        if historique.isEmpty {
                            Text("Aucun appel récent").font(.system(size: 14)).foregroundStyle(telTexte2)
                                .padding(.horizontal, 14).padding(.vertical, 10)
                        } else {
                            ForEach(Array(historique.enumerated()), id: \.offset) { _, a in
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(a.manque ? "Appel manqué" : (a.sortant ? "Appel sortant" : "Appel entrant"))
                                        .font(.system(size: 14))
                                        .foregroundStyle(a.manque ? telRouge : telTexte2)
                                    HStack {
                                        Text(a.duree ?? "Sans réponse").font(.system(size: 13)).foregroundStyle(telTexte2)
                                        Spacer()
                                        Text(a.date).font(.system(size: 13)).foregroundStyle(telTexte2)
                                    }
                                }
                                .padding(.horizontal, 14).padding(.top, 6)
                            }
                            Color.clear.frame(height: 12)
                        }
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16).padding(.top, 20)

                    // Numéro
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("portable").font(.system(size: 13)).foregroundStyle(telTexte2)
                            Text("RÉCENT").font(.system(size: 9, weight: .bold)).foregroundStyle(telTexte)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(Color(hex: 0x5E5CE6), in: Capsule())
                        }
                        HStack {
                            Text(numero).font(.system(size: 17)).foregroundStyle(telBleu)
                            Spacer()
                            Image(systemName: "phone.fill").font(.system(size: 15)).foregroundStyle(telTexte2)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16).padding(.top, 10)
                    .contentShape(Rectangle())
                    .onTapGesture { appelVisible = true }

                    // Actions
                    VStack(spacing: 0) {
                        LigneFiche(texte: "Partager cette fiche", nomFiche: nom, numeroFiche: numero)
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 14)
                        LigneFiche(texte: "Ajouter aux favoris")
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 14)
                        LigneFiche(texte: "Ajouter à une liste")
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 14)
                        LigneFiche(texte: "Ajouter aux contacts d'urgence")
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 14)
                        LigneFiche(texte: "Bloquer le contact", rouge: true)
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16).padding(.top, 10)
                    } // fin else (onglet Détails)
                    Spacer(minLength: 50)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $appelVisible) {
            AppelTelVue(destinataire: nom == "Marc ❤️" ? "Marc ❤️" : nom, numero: numero)
        }
        // D56 anneau 1 : le bouton message ouvre la VRAIE conversation Messages du contact
        .fullScreenCover(isPresented: $messagesVisible) {
            MsgConvVue(conv: DonneesMsg.convs.first(where: { $0.nom == nom })
                ?? ConvMsg(nom: nom, numero: numero, service: "Message texte · SMS",
                           bleu: false, inconnu: false, apercu: "", date: "", elements: []))
        }
    }
}

struct RondFiche: View {
    let symbole: String
    var action: (() -> Void)? = nil
    @State private var alerteVisible = false
    var body: some View {
        Circle().fill(.ultraThinMaterial).frame(width: 54, height: 54)
            .overlay(Image(systemName: symbole).font(.system(size: 19)).foregroundStyle(telTexte))
            .onTapGesture {
                if let action { action() } else { alerteVisible = true }
            }
            // D56 : réponse déterministe du même type que l'action
            .alert(ErreurLambda.reponse(symbole == "envelope.fill" ? "mail" : "generique"),
                   isPresented: $alerteVisible) {
                Button("OK", role: .cancel) {}
            }
    }
}

struct LigneFiche: View {
    let texte: String
    var rouge: Bool = false
    var nomFiche: String = ""      // v2 correctifs 31/08 : pour le partage réel
    var numeroFiche: String = ""
    @State private var alerteVisible = false
    @State private var partageVisible = false
    @State private var bascule = false
    var body: some View {
        HStack {
            Text(texteAffiche).font(.system(size: 16)).foregroundStyle(bascule ? telTexte2 : (rouge ? telRouge : telTexte))
            Spacer()
            if bascule { Image(systemName: "checkmark").font(.system(size: 13)).foregroundStyle(telTexte2) }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            if texte.hasPrefix("Partager") { partageVisible = true }
            else if texte.contains("favoris") || texte.contains("liste") || texte.contains("urgence") || texte.hasPrefix("Bloquer") {
                Haptique.leger(); bascule.toggle()
            } else { alerteVisible = true }
        }
        // v2 correctifs 31/08 : partage de fiche RÉEL (la fiche part vraiment dans Messages ou WhatsApp)
        .sheet(isPresented: $partageVisible) { PartageFicheContactVue(nomContact: nomFiche, numero: numeroFiche) }
        // D56 : réponse déterministe propre à chaque ligne
        .alert(ErreurLambda.reponse(cleBanale), isPresented: $alerteVisible) {
            Button("OK", role: .cancel) {}
        }
    }

    private var texteAffiche: String {
        guard bascule else { return texte }
        if texte.contains("favoris") { return "Retirer des favoris" }
        if texte.contains("liste") { return "Ajouté à Mes listes" }
        if texte.contains("urgence") { return "Contact d'urgence" }
        if texte.hasPrefix("Bloquer") { return "Débloquer le contact" }
        return texte
    }

    private var cleBanale: String {
        if texte.hasPrefix("Partager") { return "partage" }
        if texte.contains("favoris") { return "favoris" }
        if texte.contains("liste") { return "liste" }
        if texte.contains("urgence") { return "urgence" }
        if texte.hasPrefix("Bloquer") { return "blocage" }
        return "generique"
    }
}

// ============================================================ FAVORIS (v2 étape 4 : réels — Sarah a des favoris)
struct TelFavorisVue: View {
    @ObservedObject private var magasin = MagasinTel.partage
    @State private var pickerVisible = false
    @State private var appelVisible = false
    @State private var appelNom = ""
    @State private var appelNumero = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Favoris").font(.system(size: 17, weight: .semibold)).foregroundStyle(telTexte)
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Image(systemName: "plus").font(.system(size: 17, weight: .semibold)).foregroundStyle(telTexte)
                    .padding(.trailing, 18)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); pickerVisible = true }
            }
            .padding(.vertical, 12)

            if magasin.favoris.isEmpty {
                Spacer()
                Text("Aucun favori").font(.system(size: 16)).foregroundStyle(telTexte2)
                Spacer()
            } else {
                List {
                    ForEach(magasin.favoris, id: \.self) { nom in
                        HStack(spacing: 12) {
                            if nom == "Marc ❤️" {
                                AvatarSilhouette(taille: 42, image: "AvatarMarc")
                            } else {
                                Circle().fill(Color(hex: 0x3A3A3C)).frame(width: 42, height: 42)
                                    .overlay(Text(nom.split(separator: " ").prefix(2).compactMap { $0.first.map(String.init) }.joined().uppercased())
                                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(nom).font(.system(size: 17)).foregroundStyle(telTexte)
                                HStack(spacing: 4) {
                                    Image(systemName: "phone.fill").font(.system(size: 11)).foregroundStyle(telTexte2)
                                    Text("portable").font(.system(size: 14)).foregroundStyle(telTexte2)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Haptique.leger()
                                appelNom = nom
                                appelNumero = DonneesTel.contacts.first(where: { $0.0 == nom })?.1 ?? ""
                                appelVisible = true
                            }
                            // v2 correctifs 31/08 : ⓘ calé à droite
                            NavigationLink(destination: TelFicheVue(nom: nom)) {
                                Image(systemName: "info.circle").font(.system(size: 20)).foregroundStyle(telBleu)
                            }
                            .fixedSize()
                        }
                        .listRowBackground(telNoir)
                        .listRowSeparatorTint(Color(hex: 0x222222))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation { magasin.favoris.removeAll { $0 == nom } }
                            } label: { Label("Supprimer", systemImage: "trash.fill") }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 70)
            }
        }
        .sheet(isPresented: $pickerVisible) {
            // Choisir un contact à ajouter aux favoris — réel
            NavigationStack {
                List {
                    ForEach(magasin.tousContacts.filter { !magasin.favoris.contains($0.0) }, id: \.0) { c in
                        HStack {
                            Text(c.0).font(.system(size: 17)).foregroundStyle(telTexte)
                            Spacer()
                            Text(c.1).font(.system(size: 14)).foregroundStyle(telTexte2)
                        }
                        .listRowBackground(telNoir)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Haptique.leger()
                            magasin.favoris.append(c.0)
                            pickerVisible = false
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(telNoir)
                .navigationTitle("Ajouter un favori")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") { pickerVisible = false }.foregroundStyle(telBleu)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
        .fullScreenCover(isPresented: $appelVisible) {
            AppelTelVue(destinataire: appelNom, numero: appelNumero)
        }
    }
}

// ============================================================ CONTACTS (v2 étape 4 : recherche + ajout réels)
struct TelContactsVue: View {
    @ObservedObject private var magasin = MagasinTel.partage
    @State private var recherche = ""
    @State private var nouveauVisible = false
    @State private var champNom = ""
    @State private var champTel = ""

    private var contacts: [(String, String)] {
        guard !recherche.isEmpty else { return magasin.tousContacts }
        return magasin.tousContacts.filter {
            $0.0.localizedCaseInsensitiveContains(recherche) || $0.1.contains(recherche)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Contacts").font(.system(size: 34, weight: .bold)).foregroundStyle(telTexte)
                Spacer()
                Image(systemName: "plus").font(.system(size: 19)).foregroundStyle(telBleu)
                    .contentShape(Rectangle())
                    .onTapGesture { champNom = ""; champTel = ""; nouveauVisible = true }
            }
            .padding(.horizontal, 20).padding(.top, 14)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(telTexte2).font(.system(size: 16))
                TextField("", text: $recherche,
                          prompt: Text("Recherche").foregroundStyle(telTexte2))
                    .foregroundStyle(telTexte).font(.system(size: 17))
            }
            .padding(.horizontal, 12).frame(height: 38)
            .background(telChamp, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16).padding(.top, 8)

            List {
                if recherche.isEmpty {
                    Section {
                        NavigationLink(destination: TelFicheVue(nom: "Sarah Levasseur")) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle().fill(Color(hex: 0x1D6F4C)).frame(width: 44, height: 44)
                                    Image(systemName: "person.fill").font(.system(size: 20)).foregroundStyle(Color(hex: 0x7BE0A2)).offset(y: 2)
                                }
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Sarah Levasseur").font(.system(size: 17, weight: .semibold)).foregroundStyle(telTexte)
                                    Text("Fiche de contact").font(.system(size: 13)).foregroundStyle(telTexte2)
                                }
                            }
                        }
                        .listRowBackground(telNoir)
                    }
                }
                ForEach(contacts, id: \.0) { c in
                    NavigationLink(destination: TelFicheVue(nom: c.0)) {
                        Text(c.0).font(.system(size: 17)).foregroundStyle(telTexte)
                    }
                    .listRowBackground(telNoir)
                    .listRowSeparatorTint(Color(hex: 0x222222))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .padding(.bottom, 70)
        }
        // v2 étape 4 : nouveau contact RÉEL (session) — apparaît dans la liste et devient appelable
        .sheet(isPresented: $nouveauVisible) {
            NavigationStack {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Nom").font(.system(size: 14)).foregroundStyle(.secondary).frame(width: 70, alignment: .leading)
                            TextField("Nom du contact", text: $champNom).foregroundStyle(.white)
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x3A3A3C))
                        HStack {
                            Text("Numéro").font(.system(size: 14)).foregroundStyle(.secondary).frame(width: 70, alignment: .leading)
                            TextField("+33 6 …", text: $champTel).foregroundStyle(.white).keyboardType(.phonePad)
                        }
                        .padding(14)
                    }
                    .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
                    .padding(16)
                    Spacer()
                }
                .background(Color(hex: 0x1C1C1E))
                .navigationTitle("Nouveau contact")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") { nouveauVisible = false }.foregroundStyle(telBleu)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("OK") {
                            let n = champNom.trimmingCharacters(in: .whitespaces)
                            guard !n.isEmpty else { return }
                            Haptique.leger()
                            magasin.contactsAjoutes.append((n, champTel.trimmingCharacters(in: .whitespaces)))
                            nouveauVisible = false
                        }
                        .foregroundStyle(champNom.trimmingCharacters(in: .whitespaces).isEmpty ? telTexte2 : telBleu)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .presentationDetents([.medium])
        }
    }
}

// ============================================================ CLAVIER (fonctionnel, suggestions)
struct TelClavierVue: View {
    // P3 : si une autre app a demandé un appel (Ma Banque, Plans, Localiser), le numéro arrive pré-rempli
    @State private var numero = Routeur.partage.consommerNumero() ?? ""
    @State private var appelVisible = false

    private var suggestion: (String, String)? {
        guard numero.count >= 2 else { return nil }
        return DonneesTel.contacts.first(where: { $0.1.replacingOccurrences(of: " ", with: "").contains(numero) })
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text(numero.isEmpty ? " " : numero)
                .font(.system(size: numero.count > 12 ? 26 : 34, weight: .regular))
                .foregroundStyle(telTexte)
                .lineLimit(1).minimumScaleFactor(0.5)
                .padding(.horizontal, 30)

            if let s = suggestion {
                // v2 étape 4 : la suggestion APPELLE au toucher, et le compte est réel
                let autres = max(0, DonneesTel.contacts.filter { $0.1.replacingOccurrences(of: " ", with: "").contains(numero) }.count - 1)
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle").font(.system(size: 15)).foregroundStyle(telTexte2)
                        Text(s.0).font(.system(size: 14, weight: .semibold)).foregroundStyle(telTexte).lineLimit(1)
                        Text(s.1).font(.system(size: 14)).foregroundStyle(telBleu)
                    }
                    if autres > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundStyle(telTexte2)
                            Text("\(autres) autre\(autres > 1 ? "s" : "") résultat\(autres > 1 ? "s" : "")").font(.system(size: 13.5)).foregroundStyle(telTexte2)
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(telChamp, in: RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); appelVisible = true }
            }

            Spacer()

            let touches: [[(String, String)]] = [
                [("1", ""), ("2", "ABC"), ("3", "DEF")],
                [("4", "GHI"), ("5", "JKL"), ("6", "MNO")],
                [("7", "PQRS"), ("8", "TUV"), ("9", "WXYZ")],
                [("*", ""), ("0", "+"), ("#", "")],
            ]
            VStack(spacing: 14) {
                ForEach(0..<touches.count, id: \.self) { r in
                    HStack(spacing: 22) {
                        ForEach(0..<touches[r].count, id: \.self) { c in
                            let t = touches[r][c]
                            Button {
                                Haptique.leger()
                                numero += t.0
                            } label: {
                                VStack(spacing: 0) {
                                    Text(t.0).font(.system(size: 32, weight: .regular)).foregroundStyle(telTexte)
                                    if !t.1.isEmpty {
                                        Text(t.1).font(.system(size: 10, weight: .semibold)).foregroundStyle(telTexte2)
                                    }
                                }
                                .frame(width: 76, height: 76)
                                .background(telChamp, in: Circle())
                            }
                        }
                    }
                }
            }

            HStack(spacing: 22) {
                Color.clear.frame(width: 76, height: 66)
                Button {
                    guard !numero.isEmpty else { return }
                    appelVisible = true
                } label: {
                    Circle().fill(telVert).frame(width: 70, height: 70)
                        .overlay(Image(systemName: "phone.fill").font(.system(size: 26)).foregroundStyle(.white))
                }
                if numero.isEmpty {
                    Color.clear.frame(width: 76, height: 66)
                } else {
                    Button {
                        numero = String(numero.dropLast())
                    } label: {
                        Image(systemName: "delete.left").font(.system(size: 22)).foregroundStyle(telTexte)
                            .frame(width: 76, height: 66)
                    }
                }
            }
            .padding(.top, 14)
            Spacer(minLength: 90)
        }
        .fullScreenCover(isPresented: $appelVisible) {
            AppelTelVue(destinataire: suggestion?.0 ?? numero, numero: numero)
        }
    }
}

// ============================================================ MESSAGERIE (répondeur + lecteur + transcription)
struct TelMessagerieVue: View {
    @ObservedObject private var lecteur = LecteurAudio.partage
    @ObservedObject private var magasin = MagasinTel.partage
    @State private var ouvert: Int? = nil
    @State private var modeSelection = false
    @State private var annonceVisible = false
    @State private var hautParleur = true
    @State private var partageVisible = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    // v2 étape 4 : Modifier = mode suppression réel
                    Text(modeSelection ? "Terminé" : "Modifier").font(.system(size: 16)).foregroundStyle(telTexte)
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); modeSelection.toggle() }
                    Spacer()
                    // v2 étape 4 : Annonce = écran réel du message d'accueil
                    Text("Annonce").font(.system(size: 16)).foregroundStyle(telTexte)
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); annonceVisible = true }
                }
                Text("Messagerie").font(.system(size: 17, weight: .semibold)).foregroundStyle(telTexte)
            }
            .padding(.horizontal, 18).padding(.vertical, 10)
            .sheet(isPresented: $annonceVisible) {
                VStack(spacing: 16) {
                    Text("Annonce d'accueil").font(.system(size: 18, weight: .semibold)).foregroundStyle(telTexte)
                        .padding(.top, 24)
                    Text("Annonce par défaut de l'opérateur")
                        .font(.system(size: 15)).foregroundStyle(telTexte2)
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(telVert)
                        Text("Par défaut").font(.system(size: 16)).foregroundStyle(telTexte)
                        Spacer()
                    }
                    .padding(14)
                    .background(telChamp, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    HStack(spacing: 10) {
                        Image(systemName: "circle").foregroundStyle(telTexte2)
                        Text("Personnalisée").font(.system(size: 16)).foregroundStyle(telTexte2)
                        Spacer()
                        Text("Non enregistrée").font(.system(size: 13)).foregroundStyle(telTexte2)
                    }
                    .padding(14)
                    .background(telChamp, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(telNoir)
                .presentationDetents([.height(280)])
                .preferredColorScheme(.dark)
            }

            HStack {
                Text("Messagerie").font(.system(size: 34, weight: .bold)).foregroundStyle(telTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 4)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<DonneesTel.messagerie.count, id: \.self) { i in
                        let m = DonneesTel.messagerie[i]
                        if !magasin.vocauxSupprimes.contains(m.fichier) {
                        VStack(spacing: 0) {
                            HStack(alignment: .top, spacing: 12) {
                                if modeSelection {
                                    Image(systemName: "minus.circle.fill").font(.system(size: 22))
                                        .foregroundStyle(telRouge)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            Haptique.leger()
                                            if lecteur.fichierActif == m.fichier { lecteur.arret() }
                                            withAnimation { _ = magasin.vocauxSupprimes.insert(m.fichier) }
                                        }
                                        .padding(.top, 8)
                                }
                                AvatarSilhouette(taille: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(m.nom).font(.system(size: 17, weight: .semibold)).foregroundStyle(telTexte)
                                        Spacer()
                                        Text(m.date).font(.system(size: 14)).foregroundStyle(telTexte2)
                                    }
                                    HStack(spacing: 5) {
                                        Image(systemName: "recordingtape").font(.system(size: 11)).foregroundStyle(telTexte2)
                                        Text("« \(m.transcription.prefix(38))… »")
                                            .font(.system(size: 14)).foregroundStyle(telTexte2).lineLimit(1)
                                        Spacer()
                                        Text(m.duree).font(.system(size: 13)).foregroundStyle(telTexte2)
                                    }
                                }
                            }
                            .padding(.horizontal, 16).padding(.vertical, 11)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    ouvert = (ouvert == i) ? nil : i
                                }
                            }

                            if ouvert == i {
                                VStack(spacing: 10) {
                                    // Scrubber
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(Color(hex: 0x3A3A3C)).frame(height: 4)
                                            Capsule().fill(telTexte)
                                                .frame(width: max(8, geo.size.width * (lecteur.fichierActif == m.fichier ? lecteur.progression : 0)), height: 4)
                                            Circle().fill(telTexte).frame(width: 12, height: 12)
                                                .offset(x: max(0, geo.size.width * (lecteur.fichierActif == m.fichier ? lecteur.progression : 0) - 6))
                                        }
                                    }
                                    .frame(height: 12)
                                    HStack {
                                        Text("00:00").font(.system(size: 11)).foregroundStyle(telTexte2)
                                        Spacer()
                                        Text("-\(m.duree)").font(.system(size: 11)).foregroundStyle(telTexte2)
                                    }
                                    HStack(spacing: 40) {
                                        // v2 étape 4 : partage / haut-parleur / corbeille RÉELS
                                        Image(systemName: "square.and.arrow.up").font(.system(size: 19)).foregroundStyle(telTexte)
                                            .contentShape(Rectangle())
                                            .onTapGesture { partageVisible = true }
                                        Button { lecteur.bascule(m.fichier) } label: {
                                            Image(systemName: lecteur.fichierActif == m.fichier ? "pause.fill" : "play.fill")
                                                .font(.system(size: 26)).foregroundStyle(telTexte)
                                        }
                                        Image(systemName: hautParleur ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                            .font(.system(size: 19)).foregroundStyle(hautParleur ? telBleu : telTexte)
                                            .contentShape(Rectangle())
                                            .onTapGesture { Haptique.leger(); hautParleur.toggle() }
                                        Image(systemName: "trash").font(.system(size: 18)).foregroundStyle(telRouge)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                Haptique.leger()
                                                if lecteur.fichierActif == m.fichier { lecteur.arret() }
                                                withAnimation { _ = magasin.vocauxSupprimes.insert(m.fichier) }
                                            }
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Transcription").font(.system(size: 12, weight: .semibold)).foregroundStyle(telTexte2)
                                        Text(m.transcription).font(.system(size: 14.5)).foregroundStyle(telTexte.opacity(0.9))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 4)
                                }
                                .padding(.horizontal, 20).padding(.bottom, 14)
                            }
                            Divider().background(Color(hex: 0x222222)).padding(.leading, 68)
                        }
                        }  // fin if non-supprimé (v2 étape 4)
                    }
                    if DonneesTel.messagerie.allSatisfy({ magasin.vocauxSupprimes.contains($0.fichier) }) {
                        VStack(spacing: 8) {
                            Image(systemName: "recordingtape").font(.system(size: 36)).foregroundStyle(telTexte2)
                            Text("Aucun message vocal").font(.system(size: 15)).foregroundStyle(telTexte2)
                        }
                        .frame(maxWidth: .infinity).padding(.top, 60)
                    }
                    Spacer(minLength: 90)
                }
            }
        }
        .sheet(isPresented: $partageVisible) { FeuillePartage(element: "Message vocal") }
    }
}

// ============================================================ v2 CORRECTIFS 31/08 — PARTAGE DE FICHE RÉEL
struct PartageFicheContactVue: View {
    @Environment(\.dismiss) private var dismiss
    let nomContact: String
    let numero: String
    @State private var envoyeA: String? = nil
    @State private var whatsappPickerVisible = false

    private var carte: String { "👤 \(nomContact) — \(numero)" }
    private func heure() -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: Date())
    }
    private func envoyerMessages(_ dest: String) {
        Haptique.leger()
        EnvoisMsg.partage.envoyer(carte, a: dest)
        envoyeA = dest + " (Messages)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { dismiss() }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle().fill(Color(hex: 0x3A3A3C)).frame(width: 40, height: 40)
                    .overlay(Image(systemName: "person.crop.circle.fill").font(.system(size: 20)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fiche de \(nomContact)").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                    Text(numero).font(.system(size: 12.5)).foregroundStyle(.secondary)
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                        .frame(width: 28, height: 28).background(Color(hex: 0x2C2C2E), in: Circle())
                }
            }
            .padding(16)
            Divider().overlay(Color(hex: 0x2C2C2E))

            if let dest = envoyeA {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(telVert)
                    Text("Fiche envoyée à \(dest)").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                }
                .padding(.vertical, 26)
            } else {
                HStack(spacing: 22) {
                    DestinatairePartagePhoto(nom: "Chloé", symbole: "message.fill", fond: 0x32D74B) {
                        envoyerMessages("Chloé")
                    }
                    DestinatairePartagePhoto(nom: "Thomas", symbole: "message.fill", fond: 0x32D74B) {
                        envoyerMessages("Thomas")
                    }
                    DestinatairePartagePhoto(nom: "Maman", symbole: "message.fill", fond: 0x32D74B) {
                        envoyerMessages("Maman")
                    }
                    DestinatairePartagePhoto(nom: "WhatsApp", symbole: "phone.fill", fond: 0x25D366) {
                        whatsappPickerVisible = true
                    }
                }
                .padding(.vertical, 20)
            }
            Spacer()
        }
        .background(Color(hex: 0x1C1C1E))
        .presentationDetents([.height(220)])
        .preferredColorScheme(.dark)
        .sheet(isPresented: $whatsappPickerVisible) {
            PartageContactWAVue(nomSource: "") { dest in
                EnvoisJoueur.partage.ajouter(dest, .contactPartage(false, nomContact, heure()))
                whatsappPickerVisible = false
                envoyeA = dest + " (WhatsApp)"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { dismiss() }
            }
        }
    }
}

// ============================================================ ÉCRAN D'APPEL TÉLÉPHONE (dégradé mesuré)
struct AppelTelVue: View {
    @Environment(\.dismiss) private var dismiss
    let destinataire: String
    let numero: String
    @State private var secondes = 0
    @State private var statut = "Appel…"
    // v2 étape 4 : les boutons de l'écran d'appel RÉAGISSENT (bascules + pavé DTMF)
    @State private var hautParleur = false
    @State private var muet = false
    @State private var pave = false
    @State private var saisiePave = ""
    private let tic = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0xB03040), Color(hex: 0x5E2A6E), Color(hex: 0x1B2A6B)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                Text(statut).font(.system(size: 17)).foregroundStyle(.white.opacity(0.85)).padding(.top, 40)
                Text(destinataire).font(.system(size: 30, weight: .semibold)).foregroundStyle(.white)
                    .padding(.top, 4).lineLimit(1).minimumScaleFactor(0.6).padding(.horizontal, 24)

                Spacer()

                if pave {
                    // Pavé DTMF réel pendant l'appel
                    Text(saisiePave.isEmpty ? " " : saisiePave)
                        .font(.system(size: 26)).foregroundStyle(.white)
                        .lineLimit(1).minimumScaleFactor(0.5).padding(.horizontal, 30)
                    VStack(spacing: 10) {
                        ForEach(0..<4, id: \.self) { r in
                            HStack(spacing: 18) {
                                ForEach(0..<3, id: \.self) { c in
                                    let t = [["1","2","3"],["4","5","6"],["7","8","9"],["*","0","#"]][r][c]
                                    Button {
                                        Haptique.leger()
                                        saisiePave += t
                                    } label: {
                                        Text(t).font(.system(size: 28)).foregroundStyle(.white)
                                            .frame(width: 66, height: 66)
                                            .background(.white.opacity(0.18), in: Circle())
                                    }
                                }
                            }
                        }
                        Text("Masquer le clavier").font(.system(size: 14)).foregroundStyle(.white.opacity(0.85))
                            .padding(.top, 6)
                            .contentShape(Rectangle())
                            .onTapGesture { withAnimation(.easeOut(duration: 0.2)) { pave = false } }
                    }
                    .padding(.bottom, 16)
                }

                VStack(spacing: 22) {
                    if !pave {
                        HStack(spacing: 34) {
                            BoutonAppelTel(symbole: "speaker.wave.2.fill", nom: "Haut-parleur", actif: hautParleur) {
                                hautParleur.toggle()
                            }
                            BoutonAppelTel(symbole: "video.fill", nom: "FaceTime")
                            BoutonAppelTel(symbole: muet ? "mic.slash.fill" : "mic.fill",
                                           nom: muet ? "Son coupé" : "Couper le son", actif: muet) {
                                muet.toggle()
                            }
                        }
                    }
                    HStack(spacing: 34) {
                        if !pave { BoutonAppelTel(symbole: "ellipsis", nom: "Plus") }
                        Button {
                            dismiss()
                        } label: {
                            VStack(spacing: 7) {
                                Circle().fill(Color(hex: 0xE53935)).frame(width: 64, height: 64)
                                    .overlay(Image(systemName: "phone.down.fill").font(.system(size: 24)).foregroundStyle(.white))
                                Text("Raccrocher").font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
                            }
                        }
                        if !pave {
                            BoutonAppelTel(symbole: "circle.grid.3x3.fill", nom: "Clavier") {
                                withAnimation(.easeOut(duration: 0.2)) { pave = true }
                            }
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onReceive(tic) { _ in
            secondes += 1
            // D52/D53 : personne ne décroche — Appel… → Indisponible → raccroche
            if secondes >= 11 { dismiss() }
            else if secondes >= 8 { statut = "Indisponible" }
            else { statut = "Appel…" }
        }
    }
}

struct BoutonAppelTel: View {
    let symbole: String
    let nom: String
    var actif: Bool = false
    var action: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 7) {
            Circle().fill(actif ? .white.opacity(0.9) : .white.opacity(0.18)).frame(width: 64, height: 64)
                .overlay(Image(systemName: symbole).font(.system(size: 23))
                    .foregroundStyle(actif ? Color(hex: 0x5E2A6E) : .white))
            Text(nom).font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
        }
        .contentShape(Rectangle())
        .opacity(action == nil ? 0.45 : 1)   // sans action = grisé (comme iOS tant que l'appel n'est pas décroché)
        .onTapGesture { if let action { Haptique.leger(); action() } }
    }
}
