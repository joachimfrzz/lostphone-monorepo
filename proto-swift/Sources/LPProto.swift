// Lost Phone — Prototype-duel D49, prétendant SWIFTUI natif
// Verrouillage + Accueil + WhatsApp iOS (conversation « Marc ❤️ », contenu de Coches bleues).
// Différences voulues vs Flutter : matériaux système réels (.ultraThinMaterial),
// police SF native, AUCUNE barre d'état ni barre home dessinées (les vraies font foi).
import SwiftUI

@main
struct LPProtoApp: App {
    var body: some Scene {
        WindowGroup {
            VerrouillageView().preferredColorScheme(.dark)
        }
    }
}

// ============================================================ VERROUILLAGE
struct VerrouillageView: View {
    @State private var deverrouille = false
    @State private var glisse: CGFloat = 0

    var body: some View {
        ZStack {
            if deverrouille {
                AccueilView()
                    .transition(.opacity.combined(with: .scale(scale: 1.06)))
            } else {
                ecranVerrouille
                    .statusBarHidden(true)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var ecranVerrouille: some View {
        ZStack {
            // Vrai fond d'écran photo (Sarah & Chloé au festival — canon D46)
            Image("FondEcran")
                .resizable().scaledToFill()
                .ignoresSafeArea()
            // Voile de lisibilité comme sur iOS (léger, haut et bas)
            LinearGradient(
                stops: [.init(color: .black.opacity(0.38), location: 0),
                        .init(color: .black.opacity(0.05), location: 0.3),
                        .init(color: .black.opacity(0.05), location: 0.65),
                        .init(color: .black.opacity(0.35), location: 1)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .padding(.top, 24)
                Text("lundi 20 juillet")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 10)
                Text("19:47")
                    .font(.system(size: 92, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .kerning(-2)

                Spacer()

                NotifCard(couleur: Color(hex: 0x25D366), symbole: "message.fill",
                          app: "WhatsApp · Marc ❤️", quand: "il y a 2 h",
                          corps: "N'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges co…")
                NotifCard(couleur: Color(hex: 0x34C759), symbole: "phone.fill",
                          app: "Téléphone · Chloé", quand: "19:32",
                          corps: "2 appels manqués")
                    .padding(.top, 8)

                HStack {
                    RondVerre(symbole: "flashlight.on.fill")
                    Spacer()
                    RondVerre(symbole: "camera.fill")
                }
                .padding(.horizontal, 52)
                .padding(.top, 30)
                .padding(.bottom, 34)
            }
        }
        .contentShape(Rectangle())
        .offset(y: -glisse * 0.55)
        .gesture(
            DragGesture()
                .onChanged { v in glisse = max(0, -v.translation.height) }
                .onEnded { _ in
                    if glisse > 90 {
                        withAnimation(.spring(duration: 0.45)) { deverrouille = true }
                    }
                    withAnimation(.spring(duration: 0.35)) { glisse = 0 }
                }
        )
        .onTapGesture { withAnimation(.spring(duration: 0.45)) { deverrouille = true } }
    }
}

struct NotifCard: View {
    let couleur: Color
    let symbole: String
    let app: String
    let quand: String
    let corps: String
    var body: some View {
        HStack(spacing: 11) {
            RoundedRectangle(cornerRadius: 9)
                .fill(couleur)
                .frame(width: 38, height: 38)
                .overlay(Image(systemName: symbole).foregroundStyle(.white).font(.system(size: 18)))
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(app).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    Spacer()
                    Text(quand).font(.system(size: 13)).foregroundStyle(.white.opacity(0.55))
                }
                Text(corps)
                    .font(.system(size: 14.5))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 15).padding(.vertical, 13)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24)) // VRAI verre iOS
        .padding(.horizontal, 12)
    }
}

struct RondVerre: View {
    let symbole: String
    var body: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .frame(width: 52, height: 52)
            .overlay(Image(systemName: symbole).foregroundStyle(.white).font(.system(size: 20)))
    }
}

// ============================================================ ACCUEIL
struct AccueilView: View {
    @State private var whatsappOuvert = false

    private let apps: [(String, Color, String, Color)] = [
        ("Horloge", Color(hex: 0x1C1C1E), "clock", .white),
        ("Calendrier", .white, "calendar", Color(hex: 0xFF3B30)),
        ("Photos", .white, "photo.on.rectangle.angled", Color(hex: 0xE64980)),
        ("Plans", Color(hex: 0x34C3FF), "location.north.circle.fill", .white),
        ("Météo", Color(hex: 0x54C7FC), "sun.max.fill", Color(hex: 0xFFD60A)),
        ("Notes", Color(hex: 0xFFCC00), "note.text", .white),
        ("Rappels", .white, "checklist", Color(hex: 0x0A84FF)),
        ("Calculatrice", Color(hex: 0x2C2C2E), "plus.slash.minus", Color(hex: 0xFF9F0A)),
        ("Réglages", Color(hex: 0x8E8E93), "gearshape.fill", .white),
        ("Localiser", Color(hex: 0x32D74B), "dot.radiowaves.left.and.right", .white),
        ("Santé", .white, "heart.fill", Color(hex: 0xFA5252)),
        ("Ma Banque", Color(hex: 0x123E6B), "building.columns.fill", .white),
        ("Musique", .white, "music.note", Color(hex: 0xFA2D48)),
        ("App Store", Color(hex: 0x0A84FF), "square.stack.3d.up.fill", .white),
        ("Fichiers", .white, "folder.fill", Color(hex: 0x0A84FF)),
        ("Dictaphone", Color(hex: 0x1C1C1E), "waveform", Color(hex: 0xFF3B30)),
    ]

    var body: some View {
        ZStack {
            // Même photo que le verrouillage, assombrie (comportement iOS réel)
            Image("FondEcran")
                .resizable().scaledToFill()
                .ignoresSafeArea()
            Color.black.opacity(0.30).ignoresSafeArea()

            VStack(spacing: 0) {
                // Widget météo (vrai verre)
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Lyon").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                        Text("24°").font(.system(size: 36, weight: .light)).foregroundStyle(.white)
                    }
                    Spacer()
                    Text("Nuit dégagée\nMax. 29°  Min. 18°")
                        .font(.system(size: 12.5)).foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal, 18).padding(.vertical, 14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20).padding(.top, 14)

                // Grille d'apps
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                          spacing: 20) {
                    ForEach(apps, id: \.0) { a in
                        AppIcone(nom: a.0, fond: a.1, symbole: a.2, teinte: a.3)
                    }
                    AppIcone(nom: "WhatsApp", fond: Color(hex: 0x25D366),
                             symbole: "message.fill", teinte: .white, badge: "1") {
                        whatsappOuvert = true
                    }
                }
                .padding(.horizontal, 20).padding(.top, 22)

                Spacer()

                // Pilule Recherche
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                    Text("Recherche").font(.system(size: 12.5)).foregroundStyle(.white.opacity(0.85))
                }
                .padding(.horizontal, 16).padding(.vertical, 7)
                .background(.ultraThinMaterial, in: Capsule())

                // Dock (vrai verre, sans étiquettes)
                HStack {
                    Spacer()
                    AppIcone(nom: "", fond: Color(hex: 0x2FC74F), symbole: "phone.fill", teinte: .white, badge: "2")
                    Spacer()
                    AppIcone(nom: "", fond: Color(hex: 0x2FC74F), symbole: "message.fill", teinte: .white)
                    Spacer()
                    AppIcone(nom: "", fond: Color(hex: 0x0A84FF), symbole: "envelope.fill", teinte: .white)
                    Spacer()
                    AppIcone(nom: "", fond: Color(hex: 0xF2F2F7), symbole: "safari.fill", teinte: Color(hex: 0x0A84FF))
                    Spacer()
                }
                .padding(.vertical, 15)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32))
                .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 6)
            }
        }
        .fullScreenCover(isPresented: $whatsappOuvert) { WhatsAppListeView() }
    }
}

struct AppIcone: View {
    let nom: String
    let fond: Color
    let symbole: String
    let teinte: Color
    var badge: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 14.5)
                .fill(fond)
                .frame(width: 62, height: 62)
                .overlay(Image(systemName: symbole).font(.system(size: 27)).foregroundStyle(teinte))
                .overlay(alignment: .topTrailing) {
                    if let badge {
                        Text(badge)
                            .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 7).frame(minWidth: 23, minHeight: 23)
                            .background(Color(hex: 0xFF3B30), in: Capsule())
                            .offset(x: 8, y: -8)
                    }
                }
                .shadow(color: .black.opacity(0.35), radius: 10, y: 3)
            if !nom.isEmpty {
                Text(nom).font(.system(size: 11.5, weight: .medium)).foregroundStyle(.white)
            }
        }
        .onTapGesture { action?() }
    }
}

// ============================================================ WHATSAPP (iOS 26, mesuré sur captures réelles du 16/08)
// Couleurs échantillonnées pixel par pixel dans references/whatsapp/ :
let waNoir = Color(hex: 0x0A0A0A)        // fond liste
let waChamp = Color(hex: 0x222222)       // barre de recherche
let waChipInactif = Color(hex: 0x161717)
let waChipActifFond = Color(hex: 0xE0FCD6)
let waChipActifTexte = Color(hex: 0x1A3429)
let waVertDoux = Color(hex: 0x5BBD6C)    // heures non-lues, badges
let waVertVif = Color(hex: 0x25D366)     // bouton +
let waBulleEnvoi = Color(hex: 0x144D37)
let waBulleRecu = Color(hex: 0x242626)
let waTabBar = Color(hex: 0x1D1D1D)
let waSaisie = Color(hex: 0x282828)
let waCarte = Color(hex: 0x1D1E1E)       // pilules de date, cartes d'appel
let waTexte = Color(hex: 0xF2F2F2)
let waTexte2 = Color(hex: 0x8E8E93)
let cocheBleue = Color(hex: 0x53BDEB)

struct WhatsAppListeView: View {
    @Environment(\.dismiss) private var dismiss

    private let convs: [(String, String, String, String?, Bool)] = [
        ("Marc ❤️", "17:41", "N'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges co…", "1", true),
        ("Chloé", "19:33", "📞 Appel vocal manqué", "2", true),
        ("Thomas", "samedi", "🎤 0:42", nil, false),
        ("Maman", "dimanche", "tu viens dimanche ??? bisous maman", nil, false),
        ("Marie kiné", "vendredi", "✓✓ ok pour l'échange de créneaux jeudi 👍", nil, false),
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                waNoir.ignoresSafeArea()
                VStack(spacing: 0) {
                    // ——— Actions rondes + grand titre
                    HStack(spacing: 10) {
                        RondAction(symbole: "ellipsis") { dismiss() }
                        Spacer()
                        RondAction(symbole: "camera.fill")
                        RondAction(symbole: "plus", fond: waVertVif, teinte: Color(hex: 0x062E1C), gras: true)
                    }
                    .padding(.horizontal, 16).padding(.top, 8)
                    HStack {
                        Text("Discussions").font(.system(size: 34, weight: .bold)).foregroundStyle(waTexte)
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.top, 12)

                    // ——— Recherche « Meta AI » (capsule)
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(waTexte2).font(.system(size: 17))
                        Text("Demander à Meta AI ou...").foregroundStyle(waTexte2).font(.system(size: 17))
                        Spacer()
                    }
                    .padding(.horizontal, 16).frame(height: 44)
                    .background(waChamp, in: Capsule())
                    .padding(.horizontal, 16).padding(.top, 14)

                    // ——— Filtres avec compteurs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Puce(texte: "Toutes", active: true)
                            Puce(texte: "Non lues 20", active: false)
                            Puce(texte: "Favoris", active: false)
                            Puce(texte: "Groupes 4", active: false)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 12)

                    // ——— Archivées
                    HStack(spacing: 26) {
                        Image(systemName: "archivebox").font(.system(size: 17)).foregroundStyle(waTexte2)
                        Text("Archivées").font(.system(size: 16, weight: .semibold)).foregroundStyle(waTexte)
                        Spacer()
                    }
                    .padding(.horizontal, 26).padding(.vertical, 14)

                    // ——— Conversations
                    List {
                        ForEach(convs, id: \.0) { c in
                            Group {
                                if c.0 == "Marc ❤️" {
                                    NavigationLink(destination: ConversationMarcView()) { LigneConv(c: c) }
                                } else {
                                    LigneConv(c: c)
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

                // ——— Barre d'onglets FLOTTANTE (pilule) + bouton Vous
                HStack(spacing: 10) {
                    HStack(spacing: 0) {
                        OngletFlottant(symbole: "circle.dashed", nom: "Actus", pointVert: true)
                        OngletFlottant(symbole: "phone", nom: "Appels")
                        OngletFlottant(symbole: "person.3", nom: "Communautés")
                        OngletFlottant(symbole: "bubble.left.and.bubble.right.fill", nom: "Discussions", actif: true, badge: "3")
                    }
                    .padding(.vertical, 8).padding(.horizontal, 6)
                    .background(waTabBar, in: Capsule())
                    VStack(spacing: 3) {
                        ZStack {
                            Circle().fill(Color(hex: 0x143D2B)).frame(width: 34, height: 34)
                            Image(systemName: "person.crop.circle.fill").font(.system(size: 20)).foregroundStyle(waVertDoux)
                        }
                        Text("Vous").font(.system(size: 10)).foregroundStyle(waTexte2)
                    }
                    .padding(.vertical, 6).padding(.horizontal, 10)
                    .background(waTabBar, in: Capsule())
                }
                .padding(.horizontal, 14).padding(.bottom, 6)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct RondAction: View {
    let symbole: String
    var fond: Color = Color(hex: 0x1C1C1E)
    var teinte: Color = waTexte
    var gras: Bool = false
    var action: (() -> Void)? = nil
    var body: some View {
        Circle().fill(fond).frame(width: 40, height: 40)
            .overlay(Image(systemName: symbole)
                .font(.system(size: 17, weight: gras ? .bold : .semibold))
                .foregroundStyle(teinte))
            .onTapGesture { action?() }
    }
}

struct Puce: View {
    let texte: String
    let active: Bool
    var body: some View {
        Text(texte)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(active ? waChipActifTexte : waTexte2)
            .padding(.horizontal, 15).padding(.vertical, 8)
            .background(active ? waChipActifFond : waChipInactif, in: Capsule())
    }
}

struct OngletFlottant: View {
    let symbole: String
    let nom: String
    var actif: Bool = false
    var badge: String? = nil
    var pointVert: Bool = false
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbole)
                .font(.system(size: 20))
                .foregroundStyle(actif ? waTexte : waTexte2)
                .overlay(alignment: .topTrailing) {
                    if let badge {
                        Text(badge).font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: 0x062E1C))
                            .padding(.horizontal, 5).frame(minWidth: 17, minHeight: 17)
                            .background(waVertDoux, in: Capsule())
                            .offset(x: 12, y: -7)
                    } else if pointVert {
                        Circle().fill(waVertDoux).frame(width: 7, height: 7).offset(x: 4, y: -2)
                    }
                }
            Text(nom).font(.system(size: 10, weight: actif ? .semibold : .regular))
                .foregroundStyle(actif ? waTexte : waTexte2)
        }
        .padding(.horizontal, 10).padding(.vertical, 4)
        .background(actif ? Color(hex: 0x303030) : .clear, in: Capsule())
    }
}

struct LigneConv: View {
    let c: (String, String, String, String?, Bool)
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: 0x6E7A84))
                Image(systemName: "person.fill")
                    .font(.system(size: 30)).foregroundStyle(Color(hex: 0xCFD9DE)).offset(y: 5)
            }
            .frame(width: 56, height: 56).clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(c.0).font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                    Spacer()
                    Text(c.1).font(.system(size: 15)).foregroundStyle(c.4 ? waVertDoux : waTexte2)
                }
                HStack(alignment: .top) {
                    Text(c.2).font(.system(size: 15)).foregroundStyle(waTexte2)
                        .lineLimit(2).multilineTextAlignment(.leading)
                    Spacer()
                    if let p = c.3 {
                        Text(p).font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: 0x062E1C))
                            .padding(.horizontal, 6).frame(minWidth: 21, minHeight: 21)
                            .background(waVertDoux, in: Capsule())
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding(.vertical, 5)
    }
}

// ————— Conversation « Marc ❤️ » — contenu de Coches bleues, habillage mesuré —————
enum ElementConv {
    case jour(String)
    case message(recu: Bool, texte: String, heure: String)
    case appelManque(heure: String)
}

struct ConversationMarcView: View {
    @Environment(\.dismiss) private var dismiss

    private static let elements: [ElementConv] = [
        .jour("14 mars"),
        .message(recu: true, texte: "Bonjour Sarah ❤️ Je suis très heureux de ton message. Comment se passe ta journée à toi ?", heure: "10:12"),
        .message(recu: false, texte: "Bien ! C'est bizarre, j'ai l'impression qu'on se connaît depuis longtemps. Bref 😊 Tu es où là, en mer ?", heure: "12:40"),
        .jour("2 avril"),
        .message(recu: true, texte: "Ma chérie ❤️🌹🌹 Cette nuit j'ai pensé à notre maison près de Cassis. Tu es la reine de mon cœur.", heure: "09:03"),
        .jour("19 avril"),
        .message(recu: false, texte: "Tu me manques. C'est ridicule non ? On s'est jamais vus et tu me manques ❤️", heure: "22:51"),
        .jour("6 mai"),
        .appelManque(heure: "21:12"),
        .message(recu: true, texte: "Mon amour, la connexion satellite du navire est suspendue. 300 euros pour la rétablir. Sans cela nous ne pouvons plus parler… Je rembourse à Marseille, promis de mon cœur.", heure: "11:20"),
        .jour("11 juin"),
        .message(recu: true, texte: "Un colis pour toi est bloqué en douane ma reine. 800 euros de frais. C'est mon cadeau pour toi, j'ai honte de demander.", heure: "14:47"),
        .jour("28 juin"),
        .message(recu: true, texte: "Bonne nuit, chère Monique.", heure: "21:58"),
        .message(recu: true, texte: "Pardon ma chérie !! Je pensais à ma tante Monique, je suis fatigué ce soir. Bonne nuit mon trésor ❤️", heure: "21:59"),
        .jour("16 juillet"),
        .message(recu: true, texte: "Ma solde est bloquée par la compagnie. Il faut payer la caution de débarquement : 3000 euros. Sinon pas de Marseille le 28… Voici le compte de l'agent maritime : FR76 XXXX (M. OKAFOR AGENT MARITIME).", heure: "10:31"),
        .jour("aujourd'hui"),
        .message(recu: true, texte: "N'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges comme je t'ai dit ❤️", heure: "17:41"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // ——— Header : chevron, avatar, nom / en ligne, pilule appels
            HStack(spacing: 9) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 22, weight: .semibold)).foregroundStyle(waTexte)
                }
                .padding(.leading, 8)
                ZStack {
                    Circle().fill(Color(hex: 0x6E7A84))
                    Image(systemName: "person.fill").font(.system(size: 20)).foregroundStyle(Color(hex: 0xCFD9DE)).offset(y: 3)
                }
                .frame(width: 38, height: 38).clipShape(Circle())
                VStack(alignment: .leading, spacing: 0) {
                    Text("Marc ❤️").font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                    Text("en ligne aujourd'hui à 17:41").font(.system(size: 12.5)).foregroundStyle(waTexte2)
                }
                Spacer()
                HStack(spacing: 22) {
                    Image(systemName: "video").font(.system(size: 19))
                    Image(systemName: "phone").font(.system(size: 17))
                }
                .foregroundStyle(waTexte)
                .padding(.horizontal, 18).padding(.vertical, 10)
                .background(Color(hex: 0x1C201E), in: Capsule())
            }
            .padding(.horizontal, 8).padding(.vertical, 6)
            .background(Color(hex: 0x111312))

            // ——— Fil de messages sur fond doodle
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(0..<Self.elements.count, id: \.self) { i in
                        switch Self.elements[i] {
                        case .jour(let j):
                            Text(j)
                                .font(.system(size: 12.5)).foregroundStyle(waTexte2)
                                .padding(.horizontal, 13).padding(.vertical, 5)
                                .background(waCarte, in: RoundedRectangle(cornerRadius: 10))
                                .padding(.top, 12).padding(.bottom, 8)
                        case .message(let recu, let texte, let heure):
                            Bulle(recu: recu, texte: texte, heure: heure)
                        case .appelManque(let heure):
                            HStack {
                                HStack(spacing: 14) {
                                    Circle().fill(Color(hex: 0x3A1518)).frame(width: 44, height: 44)
                                        .overlay(Image(systemName: "video.slash.fill").font(.system(size: 17)).foregroundStyle(Color(hex: 0xF25B5B)))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Appel vidéo manqué").font(.system(size: 16, weight: .semibold)).foregroundStyle(waTexte)
                                        Text("Appuyez pour rappeler").font(.system(size: 14)).foregroundStyle(waTexte2)
                                    }
                                    Text(heure).font(.system(size: 11.5)).foregroundStyle(waTexte2)
                                        .padding(.leading, 8).padding(.top, 18)
                                }
                                .padding(.horizontal, 13).padding(.vertical, 10)
                                .background(waCarte, in: RoundedRectangle(cornerRadius: 16))
                                Spacer(minLength: 80)
                            }
                        }
                    }
                    Spacer(minLength: 6)
                }
                .padding(.horizontal, 12).padding(.vertical, 12)
            }
            .background(ZStack { waNoir; MotifDiscussion() })

            // ——— Saisie iOS 26 : « + » blanc, champ sombre avec autocollant, caméra et micro BLANCS
            HStack(spacing: 14) {
                Image(systemName: "plus").font(.system(size: 24, weight: .regular)).foregroundStyle(waTexte)
                HStack {
                    Spacer()
                    Image(systemName: "theatermask.and.paintbrush").font(.system(size: 17)).foregroundStyle(waTexte2)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(waSaisie, in: Capsule())
                Image(systemName: "camera").font(.system(size: 21)).foregroundStyle(waTexte)
                Image(systemName: "mic").font(.system(size: 21)).foregroundStyle(waTexte)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(waNoir)
        }
        .background(waNoir)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct Bulle: View {
    let recu: Bool
    let texte: String
    let heure: String
    var body: some View {
        HStack {
            if !recu { Spacer(minLength: 60) }
            VStack(alignment: .trailing, spacing: 0) {
                Text(texte).font(.system(size: 17)).foregroundStyle(waTexte)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 3) {
                    Text(heure).font(.system(size: 11.5)).foregroundStyle(waTexte.opacity(0.55))
                    if !recu {
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue)
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue).padding(.leading, -7)
                    }
                }
                .padding(.top, 3)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(.rect(topLeadingRadius: 18, bottomLeadingRadius: recu ? 5 : 18,
                             bottomTrailingRadius: recu ? 18 : 5, topTrailingRadius: 18))
            if recu { Spacer(minLength: 60) }
        }
    }
}

// ————— Motif de fond de discussion (approximation du doodle WhatsApp) —————
struct MotifDiscussion: View {
    private static let symboles = ["heart", "star", "cup.and.saucer", "leaf", "music.note",
                                   "moon", "paperplane", "camera", "gift", "sun.min",
                                   "cloud", "bicycle", "book", "airplane", "pawprint"]
    var body: some View {
        GeometryReader { geo in
            let cols = 6
            let lignes = 14
            ForEach(0..<(cols * lignes), id: \.self) { i in
                let c = i % cols
                let l = i / cols
                Image(systemName: Self.symboles[(i * 7) % Self.symboles.count])
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.035))
                    .rotationEffect(.degrees(Double((i * 37) % 60) - 30))
                    .position(
                        x: (CGFloat(c) + (l % 2 == 0 ? 0.5 : 1.0)) * geo.size.width / CGFloat(cols),
                        y: (CGFloat(l) + 0.5) * geo.size.height / CGFloat(lignes)
                    )
            }
        }
        .allowsHitTesting(false)
        .clipped()
    }
}

// ————— Utilitaire couleur hexadécimale —————
extension Color {
    init(hex: UInt) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
