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

// ============================================================ WHATSAPP (idiome iOS)
let waFond = Color(hex: 0x111B21)
let waTexte = Color(hex: 0xE9EDEF)
let waTexte2 = Color(hex: 0x8696A0)
let waVert = Color(hex: 0x25D366)
let waBulleEnvoi = Color(hex: 0x005C4B)
let waBulleRecu = Color(hex: 0x202C33)
let cocheBleue = Color(hex: 0x53BDEB)

struct WhatsAppListeView: View {
    @Environment(\.dismiss) private var dismiss

    private let convs: [(String, UInt, String, String, String, String?, Bool)] = [
        ("M", 0x5B7C99, "Marc ❤️", "17:41", "N'oublie pas : 11h30. Après-demain je te tiens dans mes b…", "1", true),
        ("C", 0xC76B8F, "Chloé", "19:33", "📞 Appel vocal manqué", "2", true),
        ("T", 0x6B8F71, "Thomas", "samedi", "🎤 0:42", nil, false),
        ("M", 0x8F7C6B, "Maman", "dimanche", "tu viens dimanche ??? bisous maman", nil, false),
        ("M", 0x7C6B8F, "Marie kiné", "vendredi", "✓✓ ok pour l'échange de créneaux jeudi 👍", nil, false),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Grand titre + actions rondes
                HStack(spacing: 10) {
                    Text("Discussions").font(.system(size: 33, weight: .bold)).foregroundStyle(waTexte)
                    Spacer()
                    RondAction(symbole: "ellipsis") { dismiss() }
                    RondAction(symbole: "camera")
                    RondAction(symbole: "plus", fond: waVert, teinte: Color(hex: 0x0B141A))
                }
                .padding(.horizontal, 18).padding(.top, 10)

                // Recherche iOS
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").foregroundStyle(waTexte2).font(.system(size: 16))
                    Text("Rechercher").foregroundStyle(waTexte2).font(.system(size: 16.5))
                    Spacer()
                }
                .padding(.horizontal, 10).frame(height: 38)
                .background(Color(hex: 0x1C242B), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 16).padding(.top, 10)

                // Filtres
                HStack(spacing: 8) {
                    Puce(texte: "Toutes", active: true)
                    Puce(texte: "Non lues", active: false)
                    Puce(texte: "Favoris", active: false)
                    Puce(texte: "Groupes", active: false)
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 4)

                // Conversations
                List {
                    ForEach(convs, id: \.2) { c in
                        Group {
                            if c.2 == "Marc ❤️" {
                                NavigationLink(destination: ConversationMarcView()) {
                                    LigneConv(c: c)
                                }
                            } else {
                                LigneConv(c: c)
                            }
                        }
                        .listRowBackground(waFond)
                        .listRowSeparatorTint(Color(hex: 0x222D34))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                // Barre d'onglets iOS
                HStack {
                    Onglet(symbole: "arrow.triangle.2.circlepath", nom: "Mises à jour")
                    Onglet(symbole: "phone", nom: "Appels")
                    Onglet(symbole: "person.3", nom: "Communautés")
                    Onglet(symbole: "message.fill", nom: "Discussions", actif: true, badge: "3")
                    Onglet(symbole: "gearshape", nom: "Réglages")
                }
                .padding(.top, 7)
                .background(Color(hex: 0x161B20))
                .overlay(alignment: .top) { Rectangle().fill(Color(hex: 0x2A3238)).frame(height: 0.5) }
            }
            .background(waFond.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct RondAction: View {
    let symbole: String
    var fond: Color = Color(hex: 0x1C242B)
    var teinte: Color = waTexte
    var action: (() -> Void)? = nil
    var body: some View {
        Circle().fill(fond).frame(width: 34, height: 34)
            .overlay(Image(systemName: symbole).font(.system(size: 15, weight: .semibold)).foregroundStyle(teinte))
            .onTapGesture { action?() }
    }
}

struct Puce: View {
    let texte: String
    let active: Bool
    var body: some View {
        Text(texte)
            .font(.system(size: 14, weight: active ? .semibold : .regular))
            .foregroundStyle(active ? Color(hex: 0x66D07E) : waTexte2)
            .padding(.horizontal, 13).padding(.vertical, 6)
            .background(active ? Color(hex: 0x103629) : Color(hex: 0x1C242B), in: Capsule())
    }
}

struct Onglet: View {
    let symbole: String
    let nom: String
    var actif: Bool = false
    var badge: String? = nil
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbole)
                .font(.system(size: 21))
                .foregroundStyle(actif ? waVert : waTexte2)
                .overlay(alignment: .topTrailing) {
                    if let badge {
                        Text(badge).font(.system(size: 10.5, weight: .bold))
                            .foregroundStyle(Color(hex: 0x0B141A))
                            .padding(.horizontal, 5).frame(minWidth: 16, minHeight: 16)
                            .background(waVert, in: Capsule())
                            .offset(x: 12, y: -6)
                    }
                }
            Text(nom).font(.system(size: 10, weight: actif ? .semibold : .regular))
                .foregroundStyle(actif ? waVert : waTexte2)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LigneConv: View {
    let c: (String, UInt, String, String, String, String?, Bool)
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar par défaut WhatsApp : silhouette grise (pas d'initiales colorées)
            ZStack {
                Circle().fill(Color(hex: 0x6E7A84))
                Image(systemName: "person.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: 0xCFD9DE))
                    .offset(y: 4)
            }
            .frame(width: 52, height: 52)
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(c.2).font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                    Spacer()
                    Text(c.3).font(.system(size: 14.5)).foregroundStyle(c.6 ? waVert : waTexte2)
                }
                HStack(alignment: .top) {
                    // iOS : aperçu sur DEUX lignes
                    Text(c.4).font(.system(size: 15)).foregroundStyle(waTexte2)
                        .lineLimit(2).multilineTextAlignment(.leading)
                    Spacer()
                    if let p = c.5 {
                        Text(p).font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: 0x0B141A))
                            .padding(.horizontal, 6).frame(minWidth: 20, minHeight: 20)
                            .background(waVert, in: Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// ————— Conversation « Marc ❤️ » —————
struct ConversationMarcView: View {
    @Environment(\.dismiss) private var dismiss

    private static let messages: [(Bool, String, String, String?)] = [
        (true, "Bonjour Sarah ❤️ Je suis très heureux de ton message. Comment se passe ta journée à toi ?", "10:12", "14 mars"),
        (false, "Bien ! C'est bizarre, j'ai l'impression qu'on se connaît depuis longtemps. Bref 😊 Tu es où là, en mer ?", "12:40", nil),
        (true, "Ma chérie ❤️🌹🌹 Cette nuit j'ai pensé à notre maison près de Cassis. Tu es la reine de mon cœur.", "09:03", "2 avril"),
        (false, "Tu me manques. C'est ridicule non ? On s'est jamais vus et tu me manques ❤️", "22:51", "19 avril"),
        (true, "Mon amour, la connexion satellite du navire est suspendue. 300 euros pour la rétablir. Sans cela nous ne pouvons plus parler… Je rembourse à Marseille, promis de mon cœur.", "11:20", "6 mai"),
        (true, "Un colis pour toi est bloqué en douane ma reine. 800 euros de frais. C'est mon cadeau pour toi, j'ai honte de demander.", "14:47", "11 juin"),
        (true, "Bonne nuit, chère Monique.", "21:58", "28 juin"),
        (true, "Pardon ma chérie !! Je pensais à ma tante Monique, je suis fatigué ce soir. Bonne nuit mon trésor ❤️", "21:59", nil),
        (true, "Ma solde est bloquée par la compagnie. Il faut payer la caution de débarquement : 3000 euros. Sinon pas de Marseille le 28… Voici le compte de l'agent maritime : FR76 XXXX (M. OKAFOR AGENT MARITIME).", "10:31", "16 juillet"),
        (true, "N'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges comme je t'ai dit ❤️", "17:41", "aujourd'hui"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header iOS
            HStack(spacing: 9) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundStyle(waVert)
                }
                .padding(.leading, 6)
                Circle().fill(Color(hex: 0x5B7C99)).frame(width: 36, height: 36)
                    .overlay(Text("M").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 0) {
                    Text("Marc ❤️").font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                    Text("en ligne").font(.system(size: 12.5)).foregroundStyle(waTexte2)
                }
                Spacer()
                Image(systemName: "video").font(.system(size: 21)).foregroundStyle(waVert)
                Image(systemName: "phone").font(.system(size: 18)).foregroundStyle(waVert).padding(.leading, 14)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color(hex: 0x161B20))

            // Messages
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(0..<Self.messages.count, id: \.self) { i in
                        let m = Self.messages[i]
                        if let jour = m.3 {
                            Text(jour)
                                .font(.system(size: 12.5)).foregroundStyle(waTexte2)
                                .padding(.horizontal, 13).padding(.vertical, 5)
                                .background(Color(hex: 0x182229), in: RoundedRectangle(cornerRadius: 9))
                                .padding(.top, 12).padding(.bottom, 8)
                        }
                        Bulle(recu: m.0, texte: m.1, heure: m.2)
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
            }
            .background(
                ZStack {
                    Color(hex: 0x0B141A)
                    MotifDiscussion() // motif « doodle » discret du vrai WhatsApp
                }
            )

            // Saisie iOS
            HStack(spacing: 10) {
                Image(systemName: "plus").font(.system(size: 24)).foregroundStyle(waVert)
                HStack {
                    Spacer()
                    Image(systemName: "face.smiling").font(.system(size: 18)).foregroundStyle(waTexte2)
                }
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(Color(hex: 0x1C242B), in: RoundedRectangle(cornerRadius: 19))
                .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color(hex: 0x2A3238), lineWidth: 0.5))
                Image(systemName: "camera").font(.system(size: 20)).foregroundStyle(waVert)
                Image(systemName: "mic").font(.system(size: 20)).foregroundStyle(waVert)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color(hex: 0x161B20))
        }
        .background(waFond)
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
                Text(texte).font(.system(size: 16.5)).foregroundStyle(waTexte)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 3) {
                    Text(heure).font(.system(size: 11)).foregroundStyle(waTexte.opacity(0.5))
                    if !recu {
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue)
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue).padding(.leading, -7)
                    }
                }
                .padding(.top, 3)
            }
            .padding(.horizontal, 11).padding(.vertical, 7)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(.rect(topLeadingRadius: recu ? 5 : 16, bottomLeadingRadius: 16,
                             bottomTrailingRadius: 16, topTrailingRadius: recu ? 16 : 5))
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
