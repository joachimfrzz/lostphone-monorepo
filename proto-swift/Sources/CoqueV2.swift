import SwiftUI

// ============================================================
// COQUE V2 (D80 — refonte contre les références S1 du 2026-08-29)
// Mesures issues de SPEC-COQUE-V2.md (points logiques 402x874, arbres XML réels).
// État Sarah : lundi 17 août 2026, 19:47 (canon).
// ============================================================

// MARK: - Capture (famille "coque2")
struct CoqueV2Capture: View {
    let cle: String
    var body: some View {
        switch cle {
        case "coque2.verrouillage": VerrouillageV2View(depliee: false)
        case "coque2.verrouillage.depliee": VerrouillageV2View(depliee: true)
        case "coque2.bibliotheque": BibliothequeV2View()
        default: VerrouillageV2View(depliee: false)
        }
    }
}

// MARK: - Verrouillage v2 (réf S1 : date au-dessus, horloge massive, pile de notifs EN BAS, compteur, lampe/caméra)
struct VerrouillageV2View: View {
    @State var depliee: Bool
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.clear.overlay(
                    Image("FondEcran").resizable().scaledToFill()
                ).clipped().ignoresSafeArea()
                LinearGradient(
                    stops: [.init(color: .black.opacity(0.38), location: 0),
                            .init(color: .black.opacity(0.05), location: 0.3),
                            .init(color: .black.opacity(0.05), location: 0.62),
                            .init(color: .black.opacity(0.40), location: 1)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Réf : cadenas discret puis date puis horloge (date x76 y72 h37 ; horloge y89 h144)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.top, 18)
                    Text("lundi 17 août")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.top, 6)
                    Text("19:47")
                        .font(.system(size: 96, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .kerning(-2)
                        .padding(.top, -8)

                    Spacer(minLength: 0)

                    // Pile de notifications EN BAS (réf S1 : la pile remonte du bas, compteur sous la pile)
                    if depliee {
                        VStack(spacing: 8) {
                            HStack {
                                Text("WhatsApp").font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                Spacer()
                                Capsule().fill(.ultraThinMaterial)
                                    .frame(width: 150, height: 30)
                                    .overlay(Text("En afficher moins").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white))
                                Circle().fill(.ultraThinMaterial).frame(width: 30, height: 30)
                                    .overlay(Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundStyle(.white))
                            }.padding(.horizontal, 22)
                            NotifV2(app: "WhatsApp", symbole: "message.fill", teinte: Color(red: 0.14, green: 0.83, blue: 0.4),
                                    titre: "Marc ❤️", corps: "Tu me manques déjà… tu as pu passer à la banque ?", quand: "il y a 2 h")
                            NotifV2(app: "WhatsApp", symbole: "message.fill", teinte: Color(red: 0.14, green: 0.83, blue: 0.4),
                                    titre: "Chloé", corps: "Rappelle-moi AVANT d'y aller. Promets-le moi.", quand: "il y a 4 h")
                            NotifV2(app: "WhatsApp", symbole: "message.fill", teinte: Color(red: 0.14, green: 0.83, blue: 0.4),
                                    titre: "Chloé", corps: "Sarah ?? Réponds moi stp", quand: "il y a 5 h")
                        }
                        .padding(.bottom, 8)
                    } else {
                        ZStack {
                            // effet de pile : deux cartes esquissées derrière
                            NotifV2(app: "", symbole: "", teinte: .clear, titre: "", corps: "", quand: "", squelette: true)
                                .scaleEffect(0.90).offset(y: 16).opacity(0.55)
                            NotifV2(app: "", symbole: "", teinte: .clear, titre: "", corps: "", quand: "", squelette: true)
                                .scaleEffect(0.95).offset(y: 8).opacity(0.75)
                            NotifV2(app: "WhatsApp", symbole: "message.fill", teinte: Color(red: 0.14, green: 0.83, blue: 0.4),
                                    titre: "Marc ❤️", corps: "Tu me manques déjà… tu as pu passer à la banque ?", quand: "il y a 2 h")
                        }
                        Text("3 notifications")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.95))
                            .padding(.top, 10)
                    }

                    // Lampe / Appareil photo (réf : 94x94 pts à y=748, marges 28)
                    HStack {
                        BoutonRondVerrou(symbole: "flashlight.off.fill")
                        Spacer()
                        BoutonRondVerrou(symbole: "camera.fill")
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 14)

                    // Indicateur d'accueil (réf : 144x5 à y=861)
                    Capsule().fill(.white)
                        .frame(width: 144, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                }
            }
        }
        .statusBarHidden()
    }
}

struct NotifV2: View {
    let app: String; let symbole: String; let teinte: Color
    let titre: String; let corps: String; let quand: String
    var squelette: Bool = false
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !squelette {
                RoundedRectangle(cornerRadius: 10)
                    .fill(teinte)
                    .frame(width: 38, height: 38)
                    .overlay(Image(systemName: symbole).font(.system(size: 18)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(titre).font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Text(quand).font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    Text(corps).font(.system(size: 15)).lineLimit(2)
                }
            } else {
                Color.clear.frame(height: 38)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal, 14)
    }
}

struct BoutonRondVerrou: View {
    let symbole: String
    var body: some View {
        Circle().fill(.ultraThinMaterial)
            .frame(width: 62, height: 62)
            .overlay(Image(systemName: symbole).font(.system(size: 22)).foregroundStyle(.white))
    }
}

// MARK: - Bibliothèque d'apps v2 (réf S1 : pilule de recherche, tuiles 169x192, 2 colonnes, icônes 69, catégories auto)
struct BibliothequeV2View: View {
    let categories: [(String, [(String, Color, String)])] = [
        ("Suggestions", [("Appareil photo", .gray, "camera.fill"), ("Notes", .yellow, "note.text"),
                         ("Réglages", .gray, "gearshape.fill"), ("Plans", .green, "map.fill")]),
        ("Ajouts récents", [("Cartes", .black, "wallet.pass.fill"), ("Santé", .white, "heart.fill"),
                            ("Fichiers", .blue, "folder.fill"), ("Dictaphone", .black, "waveform")]),
        ("Réseaux sociaux", [("WhatsApp", Color(red: 0.14, green: 0.83, blue: 0.4), "phone.fill"),
                             ("Instagram", .purple, "camera.circle.fill"),
                             ("Messenger", .blue, "bubble.left.fill"), ("X", .black, "xmark")]),
        ("Utilitaires", [("Safari", .blue, "safari.fill"), ("Horloge", .black, "clock.fill"),
                         ("Calculatrice", .orange, "plus.slash.minus"), ("Météo", .cyan, "cloud.sun.fill")]),
        ("Productivité", [("Mail", .blue, "envelope.fill"), ("Calendrier", .white, "calendar"),
                          ("Rappels", .white, "checklist"), ("Notes", .yellow, "note.text")]),
        ("Divertissement", [("Musique", .red, "music.note"), ("Photos", .white, "photo.on.rectangle"),
                            ("TV", .black, "play.tv.fill"), ("Podcasts", .purple, "waveform.circle.fill")])
    ]
    var body: some View {
        ZStack {
            Color.clear.overlay(Image("FondEcran").resizable().scaledToFill()).clipped()
                .ignoresSafeArea()
                .overlay(.ultraThinMaterial)
            VStack(spacing: 14) {
                // Pilule de recherche (réf : "Bibliothèque d'apps" centré, loupe à gauche)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(.white.opacity(0.85))
                    Text("Bibliothèque d’apps").font(.system(size: 17)).foregroundStyle(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(.white.opacity(0.18), in: Capsule())
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                        ForEach(categories, id: \.0) { cat in
                            VStack(alignment: .leading, spacing: 6) {
                                // Tuile 169x192 : fond translucide, 4 icônes 69pt en 2x2
                                VStack(spacing: 7) {
                                    HStack(spacing: 7) {
                                        IconeBiblio(cat.1[0]); IconeBiblio(cat.1[1])
                                    }
                                    HStack(spacing: 7) {
                                        IconeBiblio(cat.1[2]); IconeBiblio(cat.1[3])
                                    }
                                }
                                .padding(12)
                                .background(.white.opacity(0.22), in: RoundedRectangle(cornerRadius: 34))
                                Text(cat.0)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct IconeBiblio: View {
    let app: (String, Color, String)
    init(_ app: (String, Color, String)) { self.app = app }
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(app.1 == .white ? Color.white : app.1)
            .frame(width: 69, height: 69)
            .overlay(Image(systemName: app.2)
                .font(.system(size: 30))
                .foregroundStyle(app.1 == .white ? .black : .white))
    }
}
