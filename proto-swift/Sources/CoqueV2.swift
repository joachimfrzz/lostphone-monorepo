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
        case "coque2.accueil": AccueilV2View()
        case "coque2.spotlight": SpotlightV2View()
        case "coque2.multitache": MultitacheV2View()
        case "coque2.controle": CentreControleV2View()
        case "coque2.notifs": CentreNotifsV2View()
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

// ============================================================
// LOT 2 — Accueil v2, Spotlight v2, Multitâche v2 (réf vidéo S1)
// ============================================================

// MARK: - Accueil v2 (réf : widgets moyens Météo+Photos, grille 4 col, pilule Recherche, dock 4, points de page)
struct AccueilV2View: View {
    let apps: [(String, Color, String)] = [
        ("FaceTime", .green, "video.fill"), ("Calendrier", .white, "calendar"),
        ("Photos", .white, "photo.on.rectangle.angled"), ("Appareil photo", .gray, "camera.fill"),
        ("Mail", .blue, "envelope.fill"), ("Notes", .yellow, "note.text"),
        ("Rappels", .white, "checklist"), ("Horloge", .black, "clock.fill"),
        ("TV", .black, "play.tv.fill"), ("Podcasts", .purple, "waveform.circle.fill"),
        ("App Store", .blue, "square.stack.3d.up.fill"), ("Plans", .green, "map.fill"),
        ("Santé", .white, "heart.fill"), ("Cartes", .black, "wallet.pass.fill"),
        ("Réglages", .gray, "gearshape.fill"), ("ChatGPT", .black, "circle.hexagongrid.fill")
    ]
    var body: some View {
        ZStack {
            Color.clear.overlay(
                Image("FondEcran").resizable().scaledToFill()
            ).clipped().ignoresSafeArea()
            Color.black.opacity(0.18).ignoresSafeArea()

            VStack(spacing: 0) {
                // Widgets moyens : Météo (gauche) + pile Photos (droite)
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill").font(.system(size: 11))
                            Text("Lyon").font(.system(size: 14, weight: .semibold))
                        }
                        Text("24°").font(.system(size: 40, weight: .light))
                        Spacer(minLength: 0)
                        HStack(spacing: 4) {
                            Image(systemName: "sun.max.fill").font(.system(size: 12)).foregroundStyle(.yellow)
                            Text("Ensoleillé").font(.system(size: 12, weight: .medium))
                        }
                        Text("↑29° ↓18°").font(.system(size: 12, weight: .medium)).opacity(0.85)
                    }
                    .foregroundStyle(.white)
                    .padding(14)
                    .frame(width: 160, height: 160, alignment: .topLeading)
                    .background(LinearGradient(colors: [Color(red: 0.25, green: 0.5, blue: 0.85), Color(red: 0.15, green: 0.3, blue: 0.6)], startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                    Color.clear.overlay(
                        Image("FondEcran").resizable().scaledToFill()
                    )
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(alignment: .bottomLeading) {
                        Text("Festival 2025").font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white).padding(10)
                    }
                }
                .padding(.top, 24)

                // Grille 4 colonnes
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 22) {
                    ForEach(apps, id: \.0) { app in
                        VStack(spacing: 5) {
                            IconeAccueilV2(app)
                            Text(app.0).font(.system(size: 12)).foregroundStyle(.white)
                                .lineLimit(1).shadow(radius: 2)
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 26)

                Spacer()

                // Points de page + pilule Recherche
                HStack(spacing: 8) {
                    Circle().fill(.white).frame(width: 7, height: 7)
                    Circle().fill(.white.opacity(0.4)).frame(width: 7, height: 7)
                    Circle().fill(.white.opacity(0.4)).frame(width: 7, height: 7)
                }
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").font(.system(size: 13, weight: .semibold))
                    Text("Recherche").font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 10)

                // Dock
                HStack(spacing: 26) {
                    IconeAccueilV2(("Téléphone", .green, "phone.fill"))
                    IconeAccueilV2(("Messages", .green, "message.fill"))
                    IconeAccueilV2(("Safari", .white, "safari.fill"))
                    IconeAccueilV2(("Musique", .red, "music.note"))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 36))
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
        }
    }
}

struct IconeAccueilV2: View {
    let app: (String, Color, String)
    init(_ app: (String, Color, String)) { self.app = app }
    static let assets: [String: String] = [
        "FaceTime": "ic-facetime", "Calendrier": "ic-calendrier", "Photos": "ic-photos",
        "Mail": "ic-mail", "Notes": "ic-notes", "Rappels": "ic-rappels", "Horloge": "ic-horloge",
        "TV": "ic-tv", "Podcasts": "ic-podcasts", "App Store": "ic-app-store", "Plans": "ic-plans",
        "Santé": "ic-sante", "Cartes": "ic-cartes", "Réglages": "ic-reglages", "ChatGPT": "ic-chatgpt",
        "Téléphone": "ic-telephone", "Messages": "ic-messages", "Safari": "ic-safari", "Musique": "ic-musique",
        "WhatsApp": "ic-whatsapp", "Instagram": "ic-instagram", "Snapchat": "ic-snapchat",
        "TikTok": "ic-tiktok", "X": "ic-x", "Telegram": "ic-telegram", "Facebook": "ic-facebook",
        "Threads": "ic-threads", "Messenger": "ic-messenger", "Discord": "ic-discord", "Signal": "ic-signal"
    ]
    var body: some View {
        Group {
            if let nom = Self.assets[app.0], let ui = chargerPellicule(nom) {
                Image(uiImage: ui).resizable().scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(app.1 == .white ? Color.white : app.1)
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: app.2)
                        .font(.system(size: 28))
                        .foregroundStyle(app.1 == .white ? Color.black : .white))
            }
        }
        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        .onTapGesture { NavV2.partage.ouvrir(app.0) }
    }
}

// MARK: - Spotlight v2 (réf S1 : fond flouté, 8 suggestions Siri, champ + clavier système au focus)
struct SpotlightV2View: View {
    let suggestions: [(String, Color, String)] = [
        ("WhatsApp", Color(red: 0.14, green: 0.83, blue: 0.4), "phone.fill"),
        ("ChatGPT", .black, "circle.hexagongrid.fill"),
        ("Photos", .white, "photo.on.rectangle.angled"), ("Mail", .blue, "envelope.fill"),
        ("Ma Banque", .white, "building.columns.fill"), ("Notes", .yellow, "note.text"),
        ("Plans", .green, "map.fill"), ("Météo", .cyan, "cloud.sun.fill")
    ]
    var body: some View {
        ZStack {
            Color.clear.overlay(Image("FondEcran").resizable().scaledToFill()).clipped()
                .ignoresSafeArea()
                .overlay(.thinMaterial)
            VStack(spacing: 18) {
                Text("Suggestions de Siri")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24).padding(.top, 60)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 18) {
                    ForEach(suggestions, id: \.0) { app in
                        VStack(spacing: 5) {
                            IconeAccueilV2(app)
                            Text(app.0).font(.system(size: 11)).lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal, 22)
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    Text("Recherche").font(.system(size: 17)).foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "mic.fill").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Multitâche v2 (réf S1 : cartes réduites, nom+icône au-dessus, étiquette Handoff dessous)
struct MultitacheV2View: View {
    var body: some View {
        ZStack {
            Color.clear.overlay(Image("FondEcran").resizable().scaledToFill()).clipped()
                .ignoresSafeArea()
                .overlay(.ultraThinMaterial)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 22) {
                    CarteMultitache(nom: "WhatsApp", teinte: Color(red: 0.14, green: 0.83, blue: 0.4), symbole: "phone.fill", handoff: nil) {
                        AnyView(Rectangle().fill(Color(red: 0.04, green: 0.09, blue: 0.09)))
                    }
                    CarteMultitache(nom: "Safari", teinte: .white, symbole: "safari.fill", handoff: "De « iPad de Sarah »") {
                        AnyView(Rectangle().fill(.white))
                    }
                    CarteMultitache(nom: "Ma Banque", teinte: .white, symbole: "building.columns.fill", handoff: nil) {
                        AnyView(Rectangle().fill(Color(red: 0.95, green: 0.96, blue: 0.98)))
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 120)
            }
        }
    }
}

struct CarteMultitache<Contenu: View>: View {
    let nom: String; let teinte: Color; let symbole: String; let handoff: String?
    @ViewBuilder let contenu: () -> Contenu
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(teinte == .white ? Color.white : teinte)
                    .frame(width: 30, height: 30)
                    .overlay(Image(systemName: symbole).font(.system(size: 14)).foregroundStyle(teinte == .white ? Color.black : .white))
                Text(nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
            }
            contenu()
                .frame(width: 250, height: 540)
                .clipShape(RoundedRectangle(cornerRadius: 32))
            if let h = handoff {
                HStack(spacing: 5) {
                    Image(systemName: "ipad").font(.system(size: 11))
                    Text(h).font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(.ultraThinMaterial, in: Capsule())
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

// ============================================================
// LOT 3 — Centre de contrôle v2 + Centre de notifications v2 (réf e001 S1)
// ============================================================

// MARK: - Centre de contrôle v2
struct CentreControleV2View: View {
    var body: some View {
        ZStack {
            Color.clear.overlay(Image("FondEcran").resizable().scaledToFill()).clipped()
                .ignoresSafeArea()
                .overlay(.ultraThinMaterial.opacity(0.0))
                .overlay(Color.black.opacity(0.35).ignoresSafeArea())
                .overlay(.thinMaterial.opacity(0.92))
                .environment(\.colorScheme, .dark)
            VStack(spacing: 14) {
                // barre haute : + à gauche, power à droite, app d'origine au centre
                HStack {
                    Image(systemName: "plus").font(.system(size: 22, weight: .medium)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "power").font(.system(size: 20, weight: .medium)).foregroundStyle(.white)
                }
                .padding(.horizontal, 24).padding(.top, 14)
                HStack(spacing: 6) {
                    Image(systemName: "location.circle.fill").font(.system(size: 20)).foregroundStyle(.blue)
                    Text("Météo").font(.system(size: 17, weight: .medium)).foregroundStyle(.white)
                    Image(systemName: "chevron.forward").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white.opacity(0.6))
                }
                HStack(spacing: 8) {
                    Image(systemName: "cellularbars").font(.system(size: 15)).foregroundStyle(.white)
                    Text("Free Appels Wi-Fi").font(.system(size: 16, weight: .medium)).foregroundStyle(.white)
                    Image(systemName: "wifi").font(.system(size: 15)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "alarm.fill").font(.system(size: 13)).foregroundStyle(.white)
                    Text("100 %").font(.system(size: 16, weight: .medium)).foregroundStyle(.white)
                    Image(systemName: "battery.100.bolt").font(.system(size: 17)).foregroundStyle(.green)
                }
                .padding(.horizontal, 26)

                // rangée 1 : bloc connectivité + bloc média
                HStack(spacing: 14) {
                    VStack(spacing: 14) {
                        HStack(spacing: 18) {
                            RondCC(symbole: "airplane", actif: false)
                            RondCC(symbole: "wave.3.right.circle", actif: false)
                        }
                        HStack(spacing: 10) {
                            Circle().fill(.blue).frame(width: 56, height: 56)
                                .overlay(Image(systemName: "wifi").font(.system(size: 24)).foregroundStyle(.white))
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Circle().fill(.green).frame(width: 26, height: 26)
                                        .overlay(Image(systemName: "cellularbars").font(.system(size: 12)).foregroundStyle(.white))
                                    Circle().fill(.blue).frame(width: 26, height: 26)
                                        .overlay(Image(systemName: "personalhotspot").font(.system(size: 11)).foregroundStyle(.white))
                                }
                                HStack(spacing: 8) {
                                    Circle().fill(.red).frame(width: 26, height: 26)
                                        .overlay(Image(systemName: "link.circle").font(.system(size: 12)).foregroundStyle(.white))
                                    Circle().fill(.red).frame(width: 26, height: 26)
                                        .overlay(Image(systemName: "globe").font(.system(size: 12)).foregroundStyle(.white))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 170)
                    .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 34))

                    VStack(spacing: 10) {
                        HStack {
                            RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.2)).frame(width: 54, height: 54)
                            Spacer()
                            Image(systemName: "airplay.audio").font(.system(size: 20)).foregroundStyle(.white)
                        }
                        Text("À l'arrêt").font(.system(size: 18, weight: .semibold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 26) {
                            Image(systemName: "backward.fill")
                            Image(systemName: "play.fill").font(.system(size: 26))
                            Image(systemName: "forward.fill")
                        }
                        .font(.system(size: 18)).foregroundStyle(.white)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 170)
                    .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 34))
                }
                .padding(.horizontal, 20)

                // rangée 2 : verrou rotation + silence + curseurs
                HStack(spacing: 14) {
                    VStack(spacing: 14) {
                        HStack(spacing: 14) {
                            Circle().fill(.white.opacity(0.85)).frame(width: 62, height: 62)
                                .overlay(Image(systemName: "lock.rotation").font(.system(size: 24)).foregroundStyle(.red))
                            Circle().fill(.white.opacity(0.85)).frame(width: 62, height: 62)
                                .overlay(Image(systemName: "bell.slash.fill").font(.system(size: 24)).foregroundStyle(.red))
                        }
                        HStack(spacing: 8) {
                            Circle().fill(.white.opacity(0.25)).frame(width: 30, height: 30)
                                .overlay(Image(systemName: "person.fill").font(.system(size: 13)).foregroundStyle(.white))
                            Text("Concentration").font(.system(size: 13, weight: .medium)).foregroundStyle(.white).lineLimit(1).fixedSize()
                            Image(systemName: "chevron.up.chevron.down").font(.system(size: 11)).foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(.white.opacity(0.16), in: Capsule())
                    }
                    CurseurCC(symbole: "sun.max.fill", niveau: 0.28)
                    CurseurCC(symbole: "speaker.wave.2.fill", niveau: 0.22)
                }
                .padding(.horizontal, 20)

                // rangée 3 : Maison + torch/minuteur/calculatrice/caméra
                HStack(spacing: 14) {
                    VStack(spacing: 8) {
                        Image(systemName: "house").font(.system(size: 34)).foregroundStyle(.white)
                        Text("Aucun domicile\nconfiguré").font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 34))
                    VStack(spacing: 14) {
                        HStack(spacing: 14) {
                            RondCC(symbole: "flashlight.off.fill", actif: false)
                            RondCC(symbole: "timer", actif: false)
                        }
                        HStack(spacing: 14) {
                            RondCC(symbole: "plus.slash.minus", actif: false)
                            RondCC(symbole: "camera.fill", actif: false)
                        }
                    }
                }
                .padding(.horizontal, 20)

                // rangée 4 : enregistrement (actif) / recopie / batterie / QR, puis musique / shazam
                HStack(spacing: 14) {
                    Circle().fill(.white.opacity(0.85)).frame(width: 62, height: 62)
                        .overlay(Image(systemName: "record.circle").font(.system(size: 26)).foregroundStyle(.red))
                    RondCC(symbole: "rectangle.on.rectangle", actif: false)
                    RondCC(symbole: "battery.25", actif: false)
                    RondCC(symbole: "qrcode.viewfinder", actif: false)
                }
                HStack(spacing: 14) {
                    RondCC(symbole: "music.note", actif: false)
                    RondCC(symbole: "shazam.logo", actif: false)
                    Spacer().frame(width: 62)
                    Spacer().frame(width: 62)
                }
                Spacer()
            }
        }
        .statusBarHidden()
    }
}

struct RondCC: View {
    let symbole: String; let actif: Bool
    var body: some View {
        Circle().fill(actif ? Color.blue : Color.white.opacity(0.16))
            .frame(width: 62, height: 62)
            .overlay(Image(systemName: symbole).font(.system(size: 24)).foregroundStyle(.white))
    }
}

struct CurseurCC: View {
    let symbole: String; let niveau: Double
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 40).fill(.white.opacity(0.16))
                RoundedRectangle(cornerRadius: 0).fill(.white.opacity(0.92))
                    .frame(height: geo.size.height * niveau)
                Image(systemName: symbole)
                    .font(.system(size: 20))
                    .foregroundStyle(symbole.contains("sun") ? .yellow : .cyan)
                    .padding(.bottom, 20)
            }
            .clipShape(RoundedRectangle(cornerRadius: 40))
        }
        .frame(width: 82, height: 240)
    }
}

// MARK: - Centre de notifications v2 (réf S1 : liste sur fond flouté, piles par app)
struct CentreNotifsV2View: View {
    var body: some View {
        ZStack {
            Color.clear.overlay(Image("FondEcran").resizable().scaledToFill()).clipped()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.35))
            VStack(spacing: 10) {
                Text("19:47")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 60)
                Spacer()
                NotifV2(app: "WhatsApp", symbole: "message.fill", teinte: Color(red: 0.14, green: 0.83, blue: 0.4),
                        titre: "Marc ❤️", corps: "Tu me manques déjà… tu as pu passer à la banque ?", quand: "il y a 2 h")
                ZStack {
                    NotifV2(app: "", symbole: "", teinte: .clear, titre: "", corps: "", quand: "", squelette: true)
                        .scaleEffect(0.95).offset(y: 10).opacity(0.7)
                    NotifV2(app: "WhatsApp", symbole: "message.fill", teinte: Color(red: 0.14, green: 0.83, blue: 0.4),
                            titre: "Chloé", corps: "Rappelle-moi AVANT d'y aller. Promets-le moi.", quand: "il y a 4 h")
                }
                NotifV2(app: "Mail", symbole: "envelope.fill", teinte: .blue,
                        titre: "LCL — Votre rendez-vous", corps: "Confirmation de votre rendez-vous du lundi 17 août à 11 h 30, agence Lyon Bellecour.", quand: "hier")
                Text("3 notifications plus anciennes")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white.opacity(0.9))
                    .padding(.vertical, 8).padding(.horizontal, 16)
                    .background(.white.opacity(0.18), in: Capsule())
                    .padding(.bottom, 100)
            }
        }
        .statusBarHidden()
    }
}
