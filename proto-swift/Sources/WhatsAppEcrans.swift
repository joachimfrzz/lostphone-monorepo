// WhatsApp iOS 26 — écrans secondaires et composants riches (itération 4)
// Construit contre docs/whatsapp-navigation.md (vidéo réelle du 2026-08-16).
// Données : Coches bleues (Sarah, Marc ❤️, Chloé…).
import SwiftUI

// ============================================================ AVATAR SILHOUETTE
struct AvatarSilhouette: View {
    var taille: CGFloat = 52
    var image: String? = nil
    var body: some View {
        ZStack {
            if let image {
                Image(image).resizable().scaledToFill()
            } else {
                Circle().fill(Color(hex: 0x6E7A84))
                Image(systemName: "person.fill")
                    .font(.system(size: taille * 0.54))
                    .foregroundStyle(Color(hex: 0xCFD9DE))
                    .offset(y: taille * 0.08)
            }
        }
        .frame(width: taille, height: taille)
        .clipShape(Circle())
    }
}

// ============================================================ ONGLET APPELS
struct AppelsVue: View {
    // (nom, manqué, icône, type, date)
    private let recents: [(String, Bool, String, String, String)] = [
        ("Chloé", true, "phone.arrow.down.left", "Manqué (2)", "19:33"),
        ("Marc ❤️", false, "video", "Entrant · 19 s", "ven."),
        ("Marc ❤️", true, "video", "Manqué", "ven."),
        ("Chloé", false, "phone.arrow.up.right", "Sortant", "jeu."),
        ("Maman", false, "phone.arrow.down.left", "Entrant", "dim. 12 juil."),
        ("Marc ❤️", false, "video", "Entrant · 12 min", "8 juil."),
        ("Thomas", false, "phone.arrow.up.right", "Sortant", "5 juil."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RondAction(symbole: "ellipsis")
                Spacer()
                RondAction(symbole: "plus", fond: waVertVif, teinte: Color(hex: 0x062E1C), gras: true)
            }
            .padding(.horizontal, 16).padding(.top, 8)
            HStack {
                Text("Appels").font(.system(size: 34, weight: .bold)).foregroundStyle(waTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 12)

            // Rangée d'actions rondes
            HStack(spacing: 18) {
                ActionRonde(symbole: "phone.fill", nom: "Appeler")
                ActionRonde(symbole: "calendar", nom: "Planifier")
                ActionRonde(symbole: "circle.grid.3x3.fill", nom: "Clavier")
                ActionRonde(symbole: "person.fill", nom: "Chloé", vert: true)
                ActionRonde(symbole: "heart", nom: "Favoris")
            }
            .padding(.top, 18)

            HStack {
                Text("Récents").font(.system(size: 22, weight: .bold)).foregroundStyle(waTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 22).padding(.bottom, 6)

            List {
                ForEach(0..<recents.count, id: \.self) { i in
                    let r = recents[i]
                    NavigationLink(destination: InfosContactVue(
                        nom: r.0, numero: DonneesWA.fiches[r.0]?.numero ?? "")) {
                        HStack(alignment: .center, spacing: 12) {
                            AvatarSilhouette(taille: 46, image: r.0 == "Marc ❤️" ? "AvatarMarc" : nil)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.0)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundStyle(r.1 ? Color(hex: 0xF25B5B) : waTexte)
                                HStack(spacing: 5) {
                                    Image(systemName: r.2).font(.system(size: 13)).foregroundStyle(waTexte2)
                                    Text(r.3).font(.system(size: 14.5)).foregroundStyle(waTexte2)
                                }
                            }
                            Spacer()
                            Text(r.4).font(.system(size: 15)).foregroundStyle(waTexte2)
                            Image(systemName: "info.circle").font(.system(size: 20)).foregroundStyle(waTexte)
                        }
                    }
                    .listRowBackground(waNoir)
                    .listRowSeparatorTint(Color(hex: 0x222222))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .padding(.bottom, 70)
        }
    }
}

struct ActionRonde: View {
    let symbole: String
    let nom: String
    var vert: Bool = false
    @State private var alerteVisible = false
    @State private var appelVisible = false
    var body: some View {
        VStack(spacing: 7) {
            Circle()
                .fill(vert ? Color(hex: 0x143D2B) : Color(hex: 0x1C1C1E))
                .frame(width: 56, height: 56)
                .overlay(Image(systemName: symbole)
                    .font(.system(size: 20))
                    .foregroundStyle(vert ? waVertDoux : waTexte))
            Text(nom).font(.system(size: 13)).foregroundStyle(waTexte)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // D56 anneau 1 : la tuile d'un contact lance un vrai appel (qui sonne sans réponse, D53)
            if vert { appelVisible = true } else { alerteVisible = true }
        }
        .fullScreenCover(isPresented: $appelVisible) { AppelVue(nom: nom) }
        .alert(ErreurLambda.reponse(cleBanale), isPresented: $alerteVisible) {
            Button("OK", role: .cancel) {}
        }
    }

    private var cleBanale: String {
        switch nom {
        case "Appeler": return "wa.appeler"
        case "Planifier": return "planifier"
        case "Clavier": return "clavier.wa"
        case "Favoris": return "wa.favoris"
        default: return "generique"
        }
    }
}

// ============================================================ ONGLET VOUS (profil de Sarah)
struct VousVue: View {
    @State private var qrVisible = false
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RondAction(symbole: "magnifyingglass")
                Spacer()
                HStack(spacing: 22) {
                    Image(systemName: "qrcode").font(.system(size: 17))
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); qrVisible = true }
                    Image(systemName: "pencil").font(.system(size: 17))
                }
                .foregroundStyle(waTexte)
                .padding(.horizontal, 18).padding(.vertical, 11)
                .background(Color(hex: 0x1C1C1E), in: Capsule())
            }
            .padding(.horizontal, 16).padding(.top, 8)
            .sheet(isPresented: $qrVisible) { WAQRCodeVue() }

            ScrollView {
                VStack(spacing: 0) {
                    ZStack {
                        Circle().fill(Color(hex: 0x1D6F4C)).frame(width: 130, height: 130)
                        Image(systemName: "person.fill").font(.system(size: 62)).foregroundStyle(Color(hex: 0x7BE0A2)).offset(y: 8)
                    }
                    .clipShape(Circle())
                    .padding(.top, 18)
                    HStack(spacing: 6) {
                        Text("Sarah").font(.system(size: 30, weight: .bold)).foregroundStyle(waTexte)
                        Image(systemName: "plus.circle").font(.system(size: 18)).foregroundStyle(waVertDoux)
                    }
                    .padding(.top, 12).padding(.bottom, 20)

                    GroupeReglages(lignes: [
                        ("crown", "Abonnements", "point"),
                        ("person.crop.rectangle.stack", "Listes", ">"),
                        ("megaphone", "Messages de diffusion", ">"),
                        ("star", "Important", ">"),
                        ("laptopcomputer", "Appareils connectés", ">"),
                    ])
                    GroupeReglages(lignes: [
                        ("key", "Compte", ">"),
                        ("lock", "Confidentialité", ">"),
                        ("bubble.left", "Discussions", ">"),
                        ("paintpalette", "Apparence", ">"),
                        ("app.badge", "Notifications", ">"),
                        ("arrow.up.arrow.down", "Stockage et données", ">"),
                    ])
                    GroupeReglages(lignes: [
                        ("info.circle", "Aide", ">"),
                        ("person.2", "Inviter un proche", ">"),
                    ])
                    Spacer(minLength: 90)
                }
            }
        }
    }
}

struct GroupeReglages: View {
    let lignes: [(String, String, String)]
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<lignes.count, id: \.self) { i in
                let l = lignes[i]
                NavigationLink(destination: SousReglageVue(titre: l.1)) {
                    HStack(spacing: 14) {
                        Image(systemName: l.0).font(.system(size: 17)).foregroundStyle(waTexte)
                            .frame(width: 26)
                        Text(l.1).font(.system(size: 17)).foregroundStyle(waTexte)
                        Spacer()
                        if l.2 == "point" {
                            Circle().fill(waVertDoux).frame(width: 10, height: 10)
                            Image(systemName: "arrow.up.right").font(.system(size: 13)).foregroundStyle(waTexte2)
                        } else {
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(waTexte2)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 13)
                }
                if i < lignes.count - 1 {
                    Divider().background(Color(hex: 0x2A2A2A)).padding(.leading, 56)
                }
            }
        }
        .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16).padding(.bottom, 18)
    }
}

// ============================================================ ARCHIVÉES (v2 étape 3 : contenu réel + désarchivage)
struct ArchiveesVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinWA.partage
    private let convsBase: [(String, String, String)] = [
        ("Yoga du mardi 🧘‍♀️", "Émilie : On reprend le 2 septembre !", "12/07/2026"),
        ("Copro Bât. B", "Vous : Merci pour l'info", "28/06/2026"),
        ("+33 7 55 10 92 33", "Votre code de livraison est le 4471", "13/06/2026"),
    ]
    // + les discussions archivées par le joueur (balayage)
    private var convs: [(String, String, String)] {
        magasin.archiveesJoueur.map { nom in
            let (a, h) = EnvoisJoueur.partage.dernierApercu(nom) ?? ("", "")
            return (nom, a, h)
        } + convsBase
    }
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold))
                            // v2 correctifs 31/08 : compteur RÉEL de non-lues (disparaît à zéro)
                            if !MagasinWA.partage.nonLues.isEmpty {
                                Text("\(MagasinWA.partage.nonLues.count)").font(.system(size: 16))
                            }
                        }
                        .foregroundStyle(waTexte)
                    }
                    Spacer()
                    Text("Modifier").font(.system(size: 16)).foregroundStyle(waTexte)
                }
                Text("Archivées").font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)

            Text("Ces discussions restent archivées lorsque vous recevez de nouveaux messages. Appuyez pour modifier.")
                .font(.system(size: 13)).foregroundStyle(waTexte2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30).padding(.vertical, 10)

            List {
                ForEach(convs, id: \.0) { c in
                    NavigationLink(destination: ConversationVue(nomContact: c.0)) {
                        HStack(alignment: .top, spacing: 12) {
                            AvatarSilhouette(taille: 52)
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(c.0).font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                                    Spacer()
                                    Text(c.2).font(.system(size: 14)).foregroundStyle(waTexte2)
                                }
                                Text(c.1).font(.system(size: 15)).foregroundStyle(waTexte2).lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(waNoir)
                    .listRowSeparatorTint(Color(hex: 0x222222))
                    // v2 étape 3 : désarchiver par balayage (réel pour les archivées du joueur)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if magasin.archiveesJoueur.contains(c.0) {
                            Button {
                                withAnimation { magasin.desarchiver(c.0) }
                            } label: { Label("Désarchiver", systemImage: "archivebox") }.tint(Color(hex: 0x1D6F4C))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(waNoir.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ============================================================ INFOS DU CONTACT (Marc ❤️)
struct InfosContactVue: View {
    @Environment(\.dismiss) private var dismiss
    var nom: String = "Marc ❤️"
    var numero: String = "+33 7 49 12 53 08"
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundStyle(waTexte)
                    }
                    Spacer()
                    Text("Modifier").font(.system(size: 16)).foregroundStyle(waTexte)
                }
                Text("Infos du contact").font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)

            ScrollView {
                VStack(spacing: 0) {
                    AvatarSilhouette(taille: 110, image: nom == "Marc ❤️" ? "AvatarMarc" : nil).padding(.top, 10)
                    Text(nom).font(.system(size: 26, weight: .bold)).foregroundStyle(waTexte).padding(.top, 10)
                    Text(numero).font(.system(size: 16)).foregroundStyle(waTexte2).padding(.top, 2)

                    HStack(spacing: 12) {
                        BoutonInfo(symbole: "phone.fill", nom: "Audio", contact: nom)
                        BoutonInfo(symbole: "video.fill", nom: "Vidéo", contact: nom)
                        BoutonInfo(symbole: "magnifyingglass", nom: "Rechercher")
                    }
                    .padding(.top, 16).padding(.horizontal, 16)

                    // v2 étape 3 : « Médias, liens et documents » ouvre un écran RÉEL (contenu de la discussion)
                    VStack(spacing: 0) {
                        NavigationLink(destination: MediasLiensDocsVue(contact: nom)) {
                            HStack(spacing: 14) {
                                Image(systemName: "photo.on.rectangle").font(.system(size: 17)).foregroundStyle(waTexte).frame(width: 26)
                                Text("Médias, liens et documents").font(.system(size: 17)).foregroundStyle(waTexte)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(waTexte2)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 13)
                        }
                        Divider().background(Color(hex: 0x2A2A2A)).padding(.leading, 56)
                        NavigationLink(destination: SousReglageVue(titre: "Gérer le stockage")) {
                            HStack(spacing: 14) {
                                Image(systemName: "externaldrive").font(.system(size: 17)).foregroundStyle(waTexte).frame(width: 26)
                                Text("Gérer le stockage").font(.system(size: 17)).foregroundStyle(waTexte)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(waTexte2)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 13)
                        }
                        Divider().background(Color(hex: 0x2A2A2A)).padding(.leading, 56)
                        NavigationLink(destination: SousReglageVue(titre: "Important")) {
                            HStack(spacing: 14) {
                                Image(systemName: "star").font(.system(size: 17)).foregroundStyle(waTexte).frame(width: 26)
                                Text("Important").font(.system(size: 17)).foregroundStyle(waTexte)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(waTexte2)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 13)
                        }
                    }
                    .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16).padding(.bottom, 18)
                    .padding(.top, 20)
                    GroupeReglages(lignes: [
                        ("app.badge", "Notifications", ">"),
                        ("paintpalette", "Thème de la discussion", ">"),
                        ("square.and.arrow.down", "Enregistrer (Photos)", ">"),
                        ("timer", "Messages éphémères", ">"),
                        ("lock", "Verrouiller la discussion", ">"),
                        ("hand.raised", "Confidentialité avancée", ">"),
                    ])
                    // Détail narratif clef : aucun groupe en commun avec « Marc »
                    VStack(spacing: 0) {
                        HStack {
                            Text("Aucun groupe en commun").font(.system(size: 15)).foregroundStyle(waTexte2)
                            Spacer()
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        Divider().background(Color(hex: 0x2A2A2A)).padding(.leading, 16)
                        HStack(spacing: 14) {
                            Image(systemName: "person.badge.plus").font(.system(size: 17)).foregroundStyle(waVertDoux).frame(width: 26)
                            Text("Créer un groupe avec \(nom)").font(.system(size: 17)).foregroundStyle(waVertDoux)
                            Spacer()
                        }
                        .padding(.horizontal, 16).padding(.vertical, 13)
                    }
                    .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16).padding(.bottom, 18)

                    VStack(spacing: 0) {
                        LigneAction(texte: "Bloquer \(nom)", rouge: true)
                        Divider().background(Color(hex: 0x2A2A2A)).padding(.leading, 16)
                        LigneAction(texte: "Signaler \(nom)", rouge: true)
                    }
                    .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    Spacer(minLength: 40)
                }
            }
        }
        .background(waNoir.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct BoutonInfo: View {
    let symbole: String
    let nom: String
    var contact: String = ""
    @State private var rechercheVisible = false
    @State private var appelVisible = false
    @State private var alerteVisible = false
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbole).font(.system(size: 19)).foregroundStyle(waVertDoux)
            Text(nom).font(.system(size: 13)).foregroundStyle(waVertDoux)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            if nom == "Audio" || nom == "Vidéo" { appelVisible = true }
            else if nom == "Rechercher" { rechercheVisible = true }   // D82 : la recherche cherche vraiment
            else { alerteVisible = true }
        }
        .fullScreenCover(isPresented: $appelVisible) {
            AppelVue(nom: contact) // sonne sans réponse (règle 16/08)
        }
        .sheet(isPresented: $rechercheVisible) {
            RechercheConvWAVue(contact: contact)
        }
        .alert(ErreurLambda.reponse("generique"), isPresented: $alerteVisible) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct LigneAction: View {
    let texte: String
    var rouge: Bool = false
    var body: some View {
        HStack {
            Text(texte).font(.system(size: 17)).foregroundStyle(rouge ? Color(hex: 0xF25B5B) : waVertDoux)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }
}

// ============================================================ v2 ÉTAPE 3 — MÉDIAS, LIENS ET DOCUMENTS (réel)
struct MediasLiensDocsVue: View {
    @Environment(\.dismiss) private var dismiss
    let contact: String
    @State private var onglet = 0

    private var elements: [ElementConv] {
        DonneesWA.conversation(contact) + (EnvoisJoueur.partage.parContact[contact] ?? [])
    }
    private var medias: [(String?, String)] {   // (fichier joueur éventuel, heure)
        var out: [(String?, String)] = []
        for el in elements {
            switch el {
            case .image(_, let h): out.append((nil, h))
            case .album(_, let n, let h): for _ in 0..<n { out.append((nil, h)) }
            case .imageJoueur(let f, let h): out.append((f, h))
            case .video(_, _, let h): out.append((nil, h))
            default: break
            }
        }
        return out
    }
    private var liens: [(String, String, String)] {
        elements.compactMap { if case .lien(_, let t, let u, _, let h) = $0 { return (t, u, h) } else { return nil } }
    }
    private var docs: [(String, String, String)] {
        elements.compactMap { if case .document(_, let n, let d, let h) = $0 { return (n, d, h) } else { return nil } }
    }
    private let colonnes = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2),
                            GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundStyle(waTexte)
                    }
                    Spacer()
                }
                Text(contact).font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)

            Picker("", selection: $onglet) {
                Text("Médias").tag(0)
                Text("Liens").tag(1)
                Text("Docs").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16).padding(.bottom, 10)

            ScrollView {
                switch onglet {
                case 1:
                    if liens.isEmpty { EtatVideMLD(texte: "Aucun lien") } else {
                        VStack(spacing: 0) {
                            ForEach(0..<liens.count, id: \.self) { i in
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 8).fill(Color(hex: 0x1C242B))
                                        .frame(width: 44, height: 44)
                                        .overlay(Image(systemName: "link").font(.system(size: 17)).foregroundStyle(waTexte2))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(liens[i].0).font(.system(size: 15.5)).foregroundStyle(waTexte).lineLimit(2)
                                        Text(liens[i].1).font(.system(size: 13)).foregroundStyle(waVertDoux)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 16).padding(.vertical, 9)
                            }
                        }
                    }
                case 2:
                    if docs.isEmpty { EtatVideMLD(texte: "Aucun document") } else {
                        VStack(spacing: 0) {
                            ForEach(0..<docs.count, id: \.self) { i in
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.fill").font(.system(size: 24)).foregroundStyle(Color(hex: 0xE05B5B))
                                        .frame(width: 44, height: 44)
                                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 8))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(docs[i].0).font(.system(size: 15.5)).foregroundStyle(waTexte)
                                        Text(docs[i].1).font(.system(size: 13)).foregroundStyle(waTexte2)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 16).padding(.vertical, 9)
                            }
                        }
                    }
                default:
                    if medias.isEmpty { EtatVideMLD(texte: "Aucun média") } else {
                        LazyVGrid(columns: colonnes, spacing: 2) {
                            ForEach(0..<medias.count, id: \.self) { i in
                                if let f = medias[i].0, let img = ChargeurPhoto.image(f) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                        .frame(height: 96).clipped()
                                } else {
                                    Rectangle().fill(Color(hex: 0x1C242B)).frame(height: 96)
                                        .overlay(Image(systemName: "photo").font(.system(size: 20)).foregroundStyle(waTexte2))
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(waNoir.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

struct EtatVideMLD: View {
    let texte: String
    var body: some View {
        VStack {
            Spacer(minLength: 160)
            Text(texte).font(.system(size: 15)).foregroundStyle(waTexte2)
        }
    }
}

// ============================================================ COMPOSANTS DE CONVERSATION
// Bulle d'événement d'appel (observée en vidéo : bulle, pas carte pleine largeur)
struct BulleAppel: View {
    let recu: Bool
    let symbole: String
    let titre: String
    let sousTitre: String?
    let heure: String
    var rouge: Bool = false
    var body: some View {
        HStack {
            if !recu { Spacer(minLength: 60) }
            HStack(spacing: 11) {
                Circle().fill(rouge ? Color(hex: 0x3A1518) : Color(hex: 0x123528))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: symbole).font(.system(size: 15))
                        .foregroundStyle(rouge ? Color(hex: 0xF25B5B) : waVertDoux))
                VStack(alignment: .leading, spacing: 1) {
                    Text(titre).font(.system(size: 16, weight: .semibold)).foregroundStyle(waTexte)
                    if let st = sousTitre {
                        Text(st).font(.system(size: 13.5)).foregroundStyle(waTexte2)
                    }
                }
                Text(heure).font(.system(size: 11.5)).foregroundStyle(waTexte.opacity(0.55))
                    .padding(.leading, 6).padding(.top, 16)
            }
            .padding(.horizontal, 11).padding(.vertical, 8)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            if recu { Spacer(minLength: 60) }
        }
    }
}

// Bulle vocale : waveform + durée + vitesse
struct BulleVocale: View {
    let recu: Bool
    let duree: String
    let heure: String
    private let barres: [CGFloat] = [5, 9, 14, 8, 16, 11, 6, 13, 17, 9, 5, 12, 15, 7, 10, 14, 6, 9, 12, 5, 8, 13, 7, 11]
    var body: some View {
        HStack {
            if !recu { Spacer(minLength: 60) }
            HStack(spacing: 9) {
                AvatarSilhouette(taille: 34)
                Image(systemName: "play.fill").font(.system(size: 18)).foregroundStyle(waTexte2)
                HStack(alignment: .center, spacing: 2) {
                    ForEach(0..<barres.count, id: \.self) { i in
                        Capsule().fill(waTexte2).frame(width: 2.5, height: barres[i])
                    }
                }
                VStack(alignment: .trailing, spacing: 2) {
                    Text("1x").font(.system(size: 12, weight: .semibold)).foregroundStyle(waTexte)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color(hex: 0x333333), in: Capsule())
                    HStack(spacing: 3) {
                        Text(duree).font(.system(size: 11)).foregroundStyle(waTexte2)
                        Text(heure).font(.system(size: 11)).foregroundStyle(waTexte.opacity(0.55))
                    }
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            if recu { Spacer(minLength: 60) }
        }
    }
}

// Bulle avec réponse citée et/ou réaction
struct BulleRiche: View {
    let recu: Bool
    let texte: String
    let heure: String
    var citationNom: String? = nil
    var citationTexte: String? = nil
    var reaction: String? = nil
    var distribue: Bool = true  // D54 : false → coche grise (joueur, non-distribué)
    var body: some View {
        HStack {
            if !recu { Spacer(minLength: 60) }
            VStack(alignment: .leading, spacing: 5) {
                if let nom = citationNom, let cit = citationTexte {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2).fill(Color(hex: 0xB48EF0)).frame(width: 4)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(nom).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(Color(hex: 0xB48EF0))
                            Text(cit).font(.system(size: 13.5)).foregroundStyle(waTexte2).lineLimit(2)
                        }
                        .padding(.horizontal, 9).padding(.vertical, 6)
                        Spacer(minLength: 0)
                    }
                    .background(Color.black.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                HStack(alignment: .bottom, spacing: 8) {
                    Text(texte).font(.system(size: 17)).foregroundStyle(waTexte)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 3) {
                        Text(heure).font(.system(size: 11.5)).foregroundStyle(waTexte.opacity(0.55))
                        if !recu {
                            if distribue {
                                Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue)
                                Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue).padding(.leading, -7)
                            } else {
                                Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(waTexte2)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 7)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(.rect(topLeadingRadius: 18, bottomLeadingRadius: recu ? 5 : 18,
                             bottomTrailingRadius: recu ? 18 : 5, topTrailingRadius: 18))
            .overlay(alignment: recu ? .bottomLeading : .bottomTrailing) {
                if let r = reaction {
                    Text(r).font(.system(size: 13))
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Color(hex: 0x2C2C2C), in: Capsule())
                        .overlay(Capsule().stroke(waNoir, lineWidth: 2))
                        .offset(x: recu ? 10 : -10, y: 12)
                }
            }
            .padding(.bottom, reaction != nil ? 14 : 0)
            if recu { Spacer(minLength: 60) }
        }
    }
}

// ============================================================ QR CODE FACTICE (VousVue)
struct WAQRCodeVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                waNoir.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "qrcode").font(.system(size: 180)).foregroundStyle(waTexte)
                        .padding(20)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
                    Text("+33 6 99 01 47 23")
                        .font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                    Text("Scannez ce code pour m'ajouter sur WhatsApp")
                        .font(.system(size: 14)).foregroundStyle(waTexte2)
                        .multilineTextAlignment(.center).padding(.horizontal, 40)
                }
            }
            .navigationTitle("Mon code QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }.foregroundStyle(waVertDoux)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}


// ============================================================ D82 — RECHERCHE RÉELLE DANS LA CONVERSATION
struct RechercheConvWAVue: View {
    let contact: String
    @Environment(\.dismiss) private var dismiss
    @State private var saisie = ""
    private var resultats: [(String, String, Bool)] {
        let elements = DonneesWA.conversation(contact) + (EnvoisJoueur.partage.parContact[contact] ?? [])
        guard !saisie.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        var out: [(String, String, Bool)] = []
        for el in elements {
            switch el {
            case .msg(let recu, let texte, let heure):
                if texte.localizedCaseInsensitiveContains(saisie) { out.append((texte, heure, !recu)) }
            case .msgJoueur(let texte, let heure):
                if texte.localizedCaseInsensitiveContains(saisie) { out.append((texte, heure, true)) }
            case .msgGroupe(_, _, let texte, let heure):
                if texte.localizedCaseInsensitiveContains(saisie) { out.append((texte, heure, false)) }
            default: break
            }
        }
        return out.reversed()
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundStyle(waTexte2)
                    TextField("Rechercher", text: $saisie)
                        .font(.system(size: 16)).foregroundStyle(waTexte)
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 10))
                Button("OK") { dismiss() }
                    .font(.system(size: 16)).foregroundStyle(waVertDoux)
            }
            .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 8)
            if saisie.isEmpty {
                Spacer()
                Text("Recherchez dans la conversation avec \(contact)")
                    .font(.system(size: 14)).foregroundStyle(waTexte2)
                Spacer()
            } else if resultats.isEmpty {
                Spacer()
                Text("Aucun résultat pour « \(saisie) »")
                    .font(.system(size: 14)).foregroundStyle(waTexte2)
                Spacer()
            } else {
                List {
                    ForEach(Array(resultats.enumerated()), id: \.offset) { _, r in
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(r.2 ? "Vous" : contact).font(.system(size: 13, weight: .semibold)).foregroundStyle(waVertDoux)
                                Spacer()
                                Text(r.1).font(.system(size: 12)).foregroundStyle(waTexte2)
                            }
                            Text(r.0).font(.system(size: 15)).foregroundStyle(waTexte).lineLimit(3)
                        }
                        .listRowBackground(Color(hex: 0x121212))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color(hex: 0x0B0B0B))
        .preferredColorScheme(.dark)
    }
}
