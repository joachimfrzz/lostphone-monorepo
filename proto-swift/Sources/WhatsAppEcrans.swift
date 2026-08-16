// WhatsApp iOS 26 — écrans secondaires et composants riches (itération 4)
// Construit contre docs/whatsapp-navigation.md (vidéo réelle du 2026-08-16).
// Données : Coches bleues (Sarah, Marc ❤️, Chloé…).
import SwiftUI

// ============================================================ AVATAR SILHOUETTE
struct AvatarSilhouette: View {
    var taille: CGFloat = 52
    var body: some View {
        ZStack {
            Circle().fill(Color(hex: 0x6E7A84))
            Image(systemName: "person.fill")
                .font(.system(size: taille * 0.54))
                .foregroundStyle(Color(hex: 0xCFD9DE))
                .offset(y: taille * 0.08)
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
                    HStack(spacing: 12) {
                        AvatarSilhouette(taille: 46)
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
    }
}

// ============================================================ ONGLET VOUS (profil de Sarah)
struct VousVue: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RondAction(symbole: "magnifyingglass")
                Spacer()
                HStack(spacing: 22) {
                    Image(systemName: "qrcode").font(.system(size: 17))
                    Image(systemName: "pencil").font(.system(size: 17))
                }
                .foregroundStyle(waTexte)
                .padding(.horizontal, 18).padding(.vertical, 11)
                .background(Color(hex: 0x1C1C1E), in: Capsule())
            }
            .padding(.horizontal, 16).padding(.top, 8)

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
                if i < lignes.count - 1 {
                    Divider().background(Color(hex: 0x2A2A2A)).padding(.leading, 56)
                }
            }
        }
        .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16).padding(.bottom, 18)
    }
}

// ============================================================ ARCHIVÉES
struct ArchiveesVue: View {
    @Environment(\.dismiss) private var dismiss
    private let convs: [(String, String, String)] = [
        ("Yoga du mardi 🧘‍♀️", "Émilie : On reprend le 2 septembre !", "12/07/2026"),
        ("Copro Bât. B", "Vous : Merci pour l'info", "28/06/2026"),
        ("+33 7 55 10 92 33", "Votre code de livraison est le 4471", "13/06/2026"),
    ]
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold))
                            Text("3").font(.system(size: 16))
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
                    .listRowBackground(waNoir)
                    .listRowSeparatorTint(Color(hex: 0x222222))
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
                    AvatarSilhouette(taille: 110).padding(.top, 10)
                    Text("Marc ❤️").font(.system(size: 26, weight: .bold)).foregroundStyle(waTexte).padding(.top, 10)
                    Text("+33 7 49 12 53 08").font(.system(size: 16)).foregroundStyle(waTexte2).padding(.top, 2)

                    HStack(spacing: 12) {
                        BoutonInfo(symbole: "phone.fill", nom: "Audio")
                        BoutonInfo(symbole: "video.fill", nom: "Vidéo")
                        BoutonInfo(symbole: "magnifyingglass", nom: "Rechercher")
                    }
                    .padding(.top, 16).padding(.horizontal, 16)

                    GroupeReglages(lignes: [
                        ("photo.on.rectangle", "Médias, liens et documents", ">"),
                        ("externaldrive", "Gérer le stockage", ">"),
                        ("star", "Important", ">"),
                    ]).padding(.top, 20)
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
                            Text("Créer un groupe avec Marc ❤️").font(.system(size: 17)).foregroundStyle(waVertDoux)
                            Spacer()
                        }
                        .padding(.horizontal, 16).padding(.vertical, 13)
                    }
                    .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16).padding(.bottom, 18)

                    VStack(spacing: 0) {
                        LigneAction(texte: "Bloquer Marc ❤️", rouge: true)
                        Divider().background(Color(hex: 0x2A2A2A)).padding(.leading, 16)
                        LigneAction(texte: "Signaler Marc ❤️", rouge: true)
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
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbole).font(.system(size: 19)).foregroundStyle(waVertDoux)
            Text(nom).font(.system(size: 13)).foregroundStyle(waVertDoux)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 12))
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
                    HStack(spacing: 3) {
                        Text(heure).font(.system(size: 11.5)).foregroundStyle(waTexte.opacity(0.55))
                        if !recu {
                            Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue)
                            Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue).padding(.leading, -7)
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
