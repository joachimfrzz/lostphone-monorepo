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
    static let recents: [AppelRecent] = [
        AppelRecent(nom: "Chloé", manque: true, sortant: false, type: "portable", date: "19:33", compte: 2, duree: nil),
        AppelRecent(nom: "Agence Bellecour", manque: false, sortant: false, type: "portable", date: "mercredi", compte: 1, duree: "4 minutes"),
        AppelRecent(nom: "Marc ❤️", manque: false, sortant: false, type: "WhatsApp vidéo", date: "5 juil.", compte: 1, duree: "19 secondes"),
        AppelRecent(nom: "Maman", manque: false, sortant: true, type: "portable", date: "dim. 12 juil.", compte: 1, duree: "12 minutes"),
        AppelRecent(nom: "Marc ❤️", manque: true, sortant: false, type: "WhatsApp vidéo", date: "6 mai", compte: 1, duree: nil),
        AppelRecent(nom: "Marie kiné", manque: false, sortant: true, type: "portable", date: "mardi", compte: 1, duree: "6 minutes"),
        AppelRecent(nom: "Chloé", manque: false, sortant: true, type: "portable", date: "jeudi", compte: 1, duree: "3 minutes"),
        AppelRecent(nom: "Thomas", manque: false, sortant: false, type: "portable", date: "sam.", compte: 1, duree: "8 minutes"),
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

    private var appels: [AppelRecent] {
        filtreManques ? DonneesTel.recents.filter { $0.manque } : DonneesTel.recents
    }

    var body: some View {
        VStack(spacing: 0) {
            // Barre du haut : Modifier | Tous/Manqués | menu
            HStack {
                Text("Modifier").font(.system(size: 16)).foregroundStyle(telTexte)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(telChamp, in: Capsule())
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
                Image(systemName: "line.3.horizontal").font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(telTexte)
                    .padding(9).background(telChamp, in: Circle())
                    .onTapGesture { menuVisible = true }
                    .confirmationDialog("", isPresented: $menuVisible, titleVisibility: .hidden) {
                        Button("Effacer les appels récents", role: .destructive) {}
                        Button("Annuler", role: .cancel) {}
                    }
            }
            .padding(.horizontal, 16).padding(.top, 8)

            HStack {
                Text("Récents").font(.system(size: 34, weight: .bold)).foregroundStyle(telTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 10)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(telTexte2).font(.system(size: 16))
                Text("Recherche").foregroundStyle(telTexte2).font(.system(size: 17))
                Spacer()
                Image(systemName: "mic.fill").foregroundStyle(telTexte2).font(.system(size: 15))
            }
            .padding(.horizontal, 12).frame(height: 38)
            .background(telChamp, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16).padding(.top, 10)

            List {
                ForEach(0..<appels.count, id: \.self) { i in
                    let a = appels[i]
                    HStack(spacing: 12) {
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
                        Text(a.date).font(.system(size: 15)).foregroundStyle(telTexte2)
                        NavigationLink(destination: TelFicheVue(nom: a.nom)) {
                            Image(systemName: "info.circle").font(.system(size: 20)).foregroundStyle(telBleu)
                        }
                    }
                    .listRowBackground(telNoir)
                    .listRowSeparatorTint(Color(hex: 0x222222))
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

    private var numero: String {
        DonneesTel.contacts.first(where: { $0.0 == nom })?.1 ?? "numéro masqué"
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
                        Text("Modifier").font(.system(size: 15)).foregroundStyle(telTexte)
                            .padding(.horizontal, 14).padding(.vertical, 9)
                            .background(.ultraThinMaterial, in: Capsule())
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
                        RondFiche(symbole: "envelope.fill") { Routeur.partage.allerMail() }
                    }
                    .padding(.top, 16)

                    // Miroir phase B (réf 03-fiche-contact) : segments + carte numéro + Notes
                    HStack(spacing: 0) {
                        Text("Détails").font(.system(size: 14, weight: .semibold)).foregroundStyle(telTexte)
                            .padding(.vertical, 7).frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial, in: Capsule())
                        Text("Messages vocaux").font(.system(size: 14)).foregroundStyle(telTexte2)
                            .padding(.vertical, 7).frame(maxWidth: .infinity)
                    }
                    .padding(3)
                    .background(Color.white.opacity(0.06), in: Capsule())
                    .padding(.horizontal, 16).padding(.top, 18)

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

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes").font(.system(size: 13)).foregroundStyle(telTexte2)
                        Color.clear.frame(height: 26)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16).padding(.top, 10)

                    // Historique — DÉRIVÉ du même journal que l'onglet Récents (cohérence R3)
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Historique des appels").font(.system(size: 16)).foregroundStyle(telTexte)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(telTexte2)
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
                        LigneFiche(texte: "Partager cette fiche")
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
        .sheet(isPresented: $partageVisible) { FeuillePartage(element: "Fiche de contact") }
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

// ============================================================ FAVORIS (état vide réel)
struct TelFavorisVue: View {
    @State private var menuVisible = false
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
                    .onTapGesture { menuVisible = true }
                    .confirmationDialog("Ajouter un favori", isPresented: $menuVisible, titleVisibility: .visible) {
                        Button("Choisir un contact") {}
                        Button("Annuler", role: .cancel) {}
                    }
            }
            .padding(.vertical, 12)
            Spacer()
            Text("Aucun favori").font(.system(size: 16)).foregroundStyle(telTexte2)
            Spacer()
        }
    }
}

// ============================================================ CONTACTS
struct TelContactsVue: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Contacts").font(.system(size: 34, weight: .bold)).foregroundStyle(telTexte)
                Spacer()
                Image(systemName: "plus").font(.system(size: 19)).foregroundStyle(telBleu)
            }
            .padding(.horizontal, 20).padding(.top, 14)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(telTexte2).font(.system(size: 16))
                Text("Recherche").foregroundStyle(telTexte2).font(.system(size: 17))
                Spacer()
                Image(systemName: "mic.fill").foregroundStyle(telTexte2).font(.system(size: 15))
            }
            .padding(.horizontal, 12).frame(height: 38)
            .background(telChamp, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16).padding(.top, 8)

            List {
                Section {
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
                    .listRowBackground(telNoir)
                }
                ForEach(0..<DonneesTel.contacts.count, id: \.self) { i in
                    let c = DonneesTel.contacts[i]
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
                // Miroir phase B (réf 05-clavier-suggestion) : carte contact + « autres résultats »
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle").font(.system(size: 15)).foregroundStyle(telTexte2)
                        Text(s.0).font(.system(size: 14, weight: .semibold)).foregroundStyle(telTexte).lineLimit(1)
                        Text(s.1).font(.system(size: 14)).foregroundStyle(telBleu)
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundStyle(telTexte2)
                        Text("3 autres résultats").font(.system(size: 13.5)).foregroundStyle(telTexte2)
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(telChamp, in: RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)
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
    @State private var ouvert: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Text("Modifier").font(.system(size: 16)).foregroundStyle(telTexte)
                    Spacer()
                    Text("Annonce").font(.system(size: 16)).foregroundStyle(telTexte)
                }
                Text("Messagerie").font(.system(size: 17, weight: .semibold)).foregroundStyle(telTexte)
            }
            .padding(.horizontal, 18).padding(.vertical, 10)

            HStack {
                Text("Messagerie").font(.system(size: 34, weight: .bold)).foregroundStyle(telTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 4)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<DonneesTel.messagerie.count, id: \.self) { i in
                        let m = DonneesTel.messagerie[i]
                        VStack(spacing: 0) {
                            HStack(alignment: .top, spacing: 12) {
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
                                        Image(systemName: "square.and.arrow.up").font(.system(size: 19)).foregroundStyle(telTexte)
                                        Button { lecteur.bascule(m.fichier) } label: {
                                            Image(systemName: lecteur.fichierActif == m.fichier ? "pause.fill" : "play.fill")
                                                .font(.system(size: 26)).foregroundStyle(telTexte)
                                        }
                                        Image(systemName: "speaker.wave.2.fill").font(.system(size: 19)).foregroundStyle(telTexte)
                                        Image(systemName: "trash").font(.system(size: 18)).foregroundStyle(telTexte)
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
                    }
                    Spacer(minLength: 90)
                }
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

                VStack(spacing: 22) {
                    HStack(spacing: 34) {
                        BoutonAppelTel(symbole: "speaker.wave.2.fill", nom: "Haut-parleur")
                        BoutonAppelTel(symbole: "video.fill", nom: "FaceTime")
                        BoutonAppelTel(symbole: "mic.slash.fill", nom: "Couper le son")
                    }
                    HStack(spacing: 34) {
                        BoutonAppelTel(symbole: "ellipsis", nom: "Plus")
                        Button {
                            dismiss()
                        } label: {
                            VStack(spacing: 7) {
                                Circle().fill(Color(hex: 0xE53935)).frame(width: 64, height: 64)
                                    .overlay(Image(systemName: "phone.down.fill").font(.system(size: 24)).foregroundStyle(.white))
                                Text("Raccrocher").font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
                            }
                        }
                        BoutonAppelTel(symbole: "circle.grid.3x3.fill", nom: "Clavier")
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
    var body: some View {
        VStack(spacing: 7) {
            Circle().fill(.white.opacity(0.18)).frame(width: 64, height: 64)
                .overlay(Image(systemName: symbole).font(.system(size: 23)).foregroundStyle(.white))
            Text(nom).font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
        }
    }
}
