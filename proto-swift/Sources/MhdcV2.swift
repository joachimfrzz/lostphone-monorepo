import SwiftUI

// ============================================================
// S6 V2 — MÉTÉO / HORLOGE / DICTAPHONE / CALCULATRICE (D80, réf XML S6)
// Structure réelle mesurée : Météo (DOMICILE, ↑↓, heure par heure,
// prévisions 10 jours, liste des lieux), Horloge (Sommeil|Réveil +
// CONFIGURER, alarmes à libellés, minuteurs avec Récents, chrono),
// Dictaphone (Tous les enregistrements, lecteur déplié, Enregistrer),
// Calculatrice (élémentaire + menu de modes avec Notes mathématiques).
// Données Sarah (D59).
// ============================================================

struct MhdcV2Capture: View {
    let cle: String
    var body: some View {
        switch cle {
        case "mhdc2.meteo.accueil": MeteoAccueilV2Vue()
        case "mhdc2.meteo.lieux": MeteoLieuxV2Vue()
        case "mhdc2.horloge.alarmes": HorlogeAlarmesV2Vue()
        case "mhdc2.horloge.minuteurs": HorlogeMinuteursV2Vue()
        case "mhdc2.horloge.chrono": HorlogeChronoV2Vue()
        case "mhdc2.dicta.liste": DictaListeV2Vue()
        case "mhdc2.calc.elementaire": CalcElementaireV2Vue()
        case "mhdc2.calc.modes": CalcModesV2Vue()
        default: MeteoAccueilV2Vue()
        }
    }
}

// MARK: - Météo : accueil (réf 004 — DOMICILE, heure/heure, 10 jours)
struct MeteoAccueilV2Vue: View {
    let heures: [(String, String, String)] = [
        ("Maint.", "sun.max.fill", "27°"), ("20:38", "sunset.fill", "Coucher"),
        ("21 h", "moon.stars.fill", "25°"), ("22 h", "moon.stars.fill", "23°"),
        ("23 h", "moon.stars.fill", "22°"), ("00 h", "moon.stars.fill", "21°")
    ]
    let jours: [(String, String, String, String, String)] = [
        ("Auj.", "sun.max.fill", "", "15°", "30°"),
        ("Dim.", "sun.min.fill", "", "16°", "30°"),
        ("Lun.", "cloud.bolt.rain.fill", "40 %", "19°", "27°"),
        ("Mar.", "cloud.sun.fill", "", "15°", "28°"),
        ("Mer.", "cloud.sun.fill", "", "16°", "29°"),
        ("Jeu.", "sun.max.fill", "", "14°", "30°"),
        ("Ven.", "sun.max.fill", "", "15°", "34°"),
        ("Sam.", "sun.min.fill", "", "18°", "35°")
    ]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.25, green: 0.5, blue: 0.85), Color(red: 0.45, green: 0.65, blue: 0.9)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 2) {
                        Text("DOMICILE").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white.opacity(0.85)).tracking(1.5)
                        Text("Lyon").font(.system(size: 34, weight: .regular)).foregroundStyle(.white)
                        Text("27°").font(.system(size: 92, weight: .thin)).foregroundStyle(.white)
                        Text("Ensoleillé").font(.system(size: 19)).foregroundStyle(.white.opacity(0.9))
                        Text("↑ 30°  ↓ 15°").font(.system(size: 19)).foregroundStyle(.white)
                    }
                    .padding(.top, 30)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Temps clair ce soir et demain matin. Rafales de vent allant jusqu'à 25 km/h.")
                            .font(.system(size: 14)).foregroundStyle(.white)
                        Divider().overlay(Color.white.opacity(0.3))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 22) {
                                ForEach(heures, id: \.0) { h in
                                    VStack(spacing: 8) {
                                        Text(h.0).font(.system(size: 13, weight: .medium))
                                        Image(systemName: h.1).font(.system(size: 17)).symbolRenderingMode(.multicolor)
                                        Text(h.2).font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar").font(.system(size: 12))
                            Text("PRÉVISIONS SUR 10 JOURS").font(.system(size: 12, weight: .semibold)).tracking(0.5)
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        ForEach(jours, id: \.0) { j in
                            VStack(spacing: 0) {
                                Divider().overlay(Color.white.opacity(0.25))
                                HStack(spacing: 10) {
                                    Text(j.0).font(.system(size: 17, weight: .medium)).frame(width: 44, alignment: .leading)
                                    VStack(spacing: 0) {
                                        Image(systemName: j.1).font(.system(size: 17)).symbolRenderingMode(.multicolor)
                                        if !j.2.isEmpty { Text(j.2).font(.system(size: 11, weight: .semibold)).foregroundStyle(.cyan) }
                                    }
                                    .frame(width: 34)
                                    Text(j.3).font(.system(size: 17)).foregroundStyle(.white.opacity(0.6)).frame(width: 36, alignment: .trailing)
                                    Capsule().fill(LinearGradient(colors: [.green, .yellow, .orange], startPoint: .leading, endPoint: .trailing))
                                        .frame(height: 4)
                                    Text(j.4).font(.system(size: 17)).frame(width: 36, alignment: .trailing)
                                }
                                .foregroundStyle(.white)
                                .padding(.vertical, 7)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 16)
            }
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "map").font(.system(size: 19))
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill").font(.system(size: 11))
                        Circle().fill(.white).frame(width: 6, height: 6)
                        Circle().fill(.white.opacity(0.4)).frame(width: 6, height: 6)
                        Circle().fill(.white.opacity(0.4)).frame(width: 6, height: 6)
                    }
                    Spacer()
                    Image(systemName: "list.bullet").font(.system(size: 19))
                        .contentShape(Rectangle())
                        .onTapGesture { NavV2.partage.pousser("mhdc2.meteo.lieux") }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24).padding(.vertical, 10)
                .background(Color.black.opacity(0.18))
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Météo : liste des lieux (réf 013)
struct MeteoLieuxV2Vue: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Météo").font(.system(size: 30, weight: .bold))
                Spacer()
                Image(systemName: "ellipsis.circle").font(.system(size: 22)).foregroundStyle(.white)
            }
            .padding(.horizontal, 16).padding(.top, 8)
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                Text("Ville ou aéroport").foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "mic.fill").foregroundStyle(.secondary)
            }
            .font(.system(size: 16))
            .padding(.horizontal, 12).padding(.vertical, 9)
            .background(Color(white: 0.16), in: RoundedRectangle(cornerRadius: 11))
            .padding(.horizontal, 16).padding(.vertical, 10)
            ScrollView {
                VStack(spacing: 10) {
                    CarteLieuMeteoV2(titre: "Ma position", sousTitre: "Domicile · Lyon", temp: "27°", cond: "Ensoleillé", minmax: "↑ 30°  ↓ 15°")
                        .contentShape(Rectangle())
                        .onTapGesture { NavV2.partage.retour() }
                    CarteLieuMeteoV2(titre: "Mâcon", sousTitre: "20:08", temp: "26°", cond: "Ensoleillé", minmax: "↑ 28°  ↓ 14°")
                    CarteLieuMeteoV2(titre: "Annecy", sousTitre: "20:08", temp: "24°", cond: "Ciel plutôt dégagé", minmax: "↑ 27°  ↓ 13°")
                    Text("En savoir plus sur les données météo et les données de plans")
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

struct CarteLieuMeteoV2: View {
    let titre: String; let sousTitre: String; let temp: String; let cond: String; let minmax: String
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(titre).font(.system(size: 19, weight: .semibold))
                Text(sousTitre).font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                Spacer()
                Text(cond).font(.system(size: 13)).foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(temp).font(.system(size: 46, weight: .light))
                Spacer()
                Text(minmax).font(.system(size: 13)).foregroundStyle(.white.opacity(0.85))
            }
        }
        .foregroundStyle(.white)
        .padding(14)
        .frame(height: 108)
        .background(
            LinearGradient(colors: [Color(red: 0.25, green: 0.5, blue: 0.85), Color(red: 0.4, green: 0.6, blue: 0.9)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

// MARK: - Horloge : alarmes (réf 005 — Sommeil|Réveil CONFIGURER, Autres à libellés)
struct HorlogeAlarmesV2Vue: View {
    let alarmes: [(String, String, Bool)] = [
        ("06:45", "Alarme", false),
        ("07:30", "Fermer les volets !", false),
        ("12:00", "Pain", true),
        ("16:30", "Carte d'identité, chaque jeudi", false),
        ("18:20", "Appeler maman", true)
    ]
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Modifier").font(.system(size: 17)).foregroundStyle(.orange).fixedSize()
                Spacer()
                Image(systemName: "plus").font(.system(size: 19)).foregroundStyle(.orange)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            Text("Alarmes").font(.system(size: 30, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16).padding(.bottom, 8)
            List {
                Section(header:
                    HStack(spacing: 6) {
                        Image(systemName: "bed.double.fill")
                        Text("Sommeil | Réveil")
                    }
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(.primary).textCase(nil)
                ) {
                    HStack {
                        Text("Aucune alarme").font(.system(size: 17)).foregroundStyle(.secondary)
                        Spacer()
                        Text("CONFIGURER").font(.system(size: 13, weight: .semibold)).foregroundStyle(.orange)
                    }
                }
                Section(header: Text("Autres").font(.system(size: 15, weight: .semibold)).foregroundStyle(.primary).textCase(nil)) {
                    ForEach(alarmes, id: \.0) { a in
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(a.0).font(.system(size: 46, weight: .light))
                                    .foregroundStyle(a.2 ? .primary : .secondary)
                                Text(a.1).font(.system(size: 14))
                                    .foregroundStyle(a.2 ? .primary : .secondary)
                            }
                            Spacer()
                            Capsule().fill(a.2 ? Color.green : Color(white: 0.3))
                                .frame(width: 50, height: 30)
                                .overlay(Circle().fill(.white).frame(width: 26).offset(x: a.2 ? 10 : -10))
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .listStyle(.grouped)
            HStack {
                VStack(spacing: 3) { Image(systemName: "globe").font(.system(size: 20)); Text("Horloges").font(.system(size: 10)) }.foregroundStyle(.secondary)
                Spacer()
                VStack(spacing: 3) { Image(systemName: "alarm.fill").font(.system(size: 20)); Text("Alarmes").font(.system(size: 10)) }.foregroundStyle(.orange)
                Spacer()
                VStack(spacing: 3) { Image(systemName: "stopwatch.fill").font(.system(size: 20)); Text("Chronomètre").font(.system(size: 10)) }.foregroundStyle(.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture { NavV2.partage.remplacer("mhdc2.horloge.chrono") }
                Spacer()
                VStack(spacing: 3) { Image(systemName: "timer").font(.system(size: 20)); Text("Minuteurs").font(.system(size: 10)) }.foregroundStyle(.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture { NavV2.partage.remplacer("mhdc2.horloge.minuteurs") }
            }
            .padding(.horizontal, 28).padding(.top, 8).padding(.bottom, 4)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Horloge : minuteurs (réf 017 — anneau en cours + Récents)
struct HorlogeMinuteursV2Vue: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Modifier").font(.system(size: 17)).foregroundStyle(.orange).fixedSize()
                Spacer()
                Image(systemName: "plus").font(.system(size: 19)).foregroundStyle(.orange)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            Text("Minuteurs").font(.system(size: 30, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16).padding(.bottom, 14)
            ZStack {
                Circle().stroke(Color(white: 0.22), lineWidth: 8).frame(width: 240, height: 240)
                Circle().trim(from: 0, to: 0.83).stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90)).frame(width: 240, height: 240)
                VStack(spacing: 4) {
                    Text("05:01").font(.system(size: 64, weight: .thin))
                    HStack(spacing: 5) {
                        Image(systemName: "bell.fill").font(.system(size: 12))
                        Text("09:32").font(.system(size: 14))
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 16)
            HStack {
                Circle().fill(Color(white: 0.2)).frame(width: 78, height: 78)
                    .overlay(Text("Annuler").font(.system(size: 15)).foregroundStyle(.white))
                Spacer()
                Circle().fill(Color.orange.opacity(0.25)).frame(width: 78, height: 78)
                    .overlay(Text("Pause").font(.system(size: 15)).foregroundStyle(.orange))
            }
            .padding(.horizontal, 40)
            List {
                Section(header: Text("Récents").font(.system(size: 15, weight: .semibold)).foregroundStyle(.primary).textCase(nil)) {
                    HStack { Text("5 min et 4 s").font(.system(size: 22, weight: .light)); Spacer(); Image(systemName: "play.circle.fill").font(.system(size: 26)).foregroundStyle(.green) }
                    HStack { Text("10 min").font(.system(size: 22, weight: .light)); Spacer(); Image(systemName: "play.circle.fill").font(.system(size: 26)).foregroundStyle(.green) }
                    HStack { Text("20 min").font(.system(size: 22, weight: .light)); Spacer(); Image(systemName: "play.circle.fill").font(.system(size: 26)).foregroundStyle(.green) }
                }
            }
            .listStyle(.grouped)
            HStack {
                VStack(spacing: 3) { Image(systemName: "globe").font(.system(size: 20)); Text("Horloges").font(.system(size: 10)) }.foregroundStyle(.secondary)
                Spacer()
                VStack(spacing: 3) { Image(systemName: "alarm.fill").font(.system(size: 20)); Text("Alarmes").font(.system(size: 10)) }.foregroundStyle(.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture { NavV2.partage.remplacer("mhdc2.horloge.alarmes") }
                Spacer()
                VStack(spacing: 3) { Image(systemName: "stopwatch.fill").font(.system(size: 20)); Text("Chronomètre").font(.system(size: 10)) }.foregroundStyle(.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture { NavV2.partage.remplacer("mhdc2.horloge.chrono") }
                Spacer()
                VStack(spacing: 3) { Image(systemName: "timer").font(.system(size: 20)); Text("Minuteurs").font(.system(size: 10)) }.foregroundStyle(.orange)
            }
            .padding(.horizontal, 28).padding(.top, 8).padding(.bottom, 4)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Horloge : chronomètre (réf 011 — Tour/Arrêter)
struct HorlogeChronoV2Vue: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Chronomètre").font(.system(size: 30, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16).padding(.top, 14)
            Spacer()
            Text("00:06,42").font(.system(size: 76, weight: .thin)).monospacedDigit()
            Spacer()
            HStack {
                Circle().fill(Color(white: 0.2)).frame(width: 82, height: 82)
                    .overlay(Text("Tour").font(.system(size: 16)).foregroundStyle(.white))
                Spacer()
                Circle().fill(Color.red.opacity(0.25)).frame(width: 82, height: 82)
                    .overlay(Text("Arrêter").font(.system(size: 16)).foregroundStyle(.red))
            }
            .padding(.horizontal, 36)
            List {
                HStack { Text("Tour 1").font(.system(size: 16)); Spacer(); Text("00:06,42").font(.system(size: 16)).monospacedDigit() }
            }
            .listStyle(.plain)
            .frame(height: 150)
            HStack {
                VStack(spacing: 3) { Image(systemName: "globe").font(.system(size: 20)); Text("Horloges").font(.system(size: 10)) }.foregroundStyle(.secondary)
                Spacer()
                VStack(spacing: 3) { Image(systemName: "alarm.fill").font(.system(size: 20)); Text("Alarmes").font(.system(size: 10)) }.foregroundStyle(.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture { NavV2.partage.remplacer("mhdc2.horloge.alarmes") }
                Spacer()
                VStack(spacing: 3) { Image(systemName: "stopwatch.fill").font(.system(size: 20)); Text("Chronomètre").font(.system(size: 10)) }.foregroundStyle(.orange)
                Spacer()
                VStack(spacing: 3) { Image(systemName: "timer").font(.system(size: 20)); Text("Minuteurs").font(.system(size: 10)) }.foregroundStyle(.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture { NavV2.partage.remplacer("mhdc2.horloge.minuteurs") }
            }
            .padding(.horizontal, 28).padding(.top, 8).padding(.bottom, 4)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Dictaphone : liste (réf 046 — lecteur déplié, Enregistrer)
struct DictaListeV2Vue: View {
    let memos: [(String, String, String)] = [
        ("Idée cadeau Chloé", "26 août 2026", "0:41"),
        ("Répétition — ce que je dois dire à Marc", "14 août 2026", "1:47"),
        ("Liste appart — questions agence", "9 août 2026", "0:58"),
        ("Mémo kiné exercices", "25 juil. 2026", "2:10")
    ]
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "chevron.backward").font(.system(size: 17, weight: .semibold))
                    Text("Mémos vocaux").fixedSize()
                }
                .foregroundStyle(.blue)
                Spacer()
                Text("Sélectionner").font(.system(size: 17)).foregroundStyle(.blue).fixedSize()
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            Text("Tous les enregistrements").font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16).padding(.bottom, 6)
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                Text("Rechercher").foregroundStyle(.secondary)
                Spacer()
            }
            .font(.system(size: 16))
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color(white: 0.16), in: RoundedRectangle(cornerRadius: 11))
            .padding(.horizontal, 16).padding(.bottom, 4)
            List {
                // Rangée dépliée avec lecteur (réf : Retour 15 s / Lire / Avance 15 s / Supprimer)
                VStack(alignment: .leading, spacing: 8) {
                    Text(memos[0].0).font(.system(size: 16, weight: .semibold))
                    HStack {
                        Text(memos[0].1).font(.system(size: 13)).foregroundStyle(.secondary)
                        Spacer()
                        Text(memos[0].2).font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    RoundedRectangle(cornerRadius: 2).fill(Color(white: 0.3)).frame(height: 3)
                        .overlay(alignment: .leading) { RoundedRectangle(cornerRadius: 2).fill(.white).frame(width: 70, height: 3) }
                    HStack {
                        Image(systemName: "ellipsis.circle").font(.system(size: 20)).foregroundStyle(.blue)
                        Spacer()
                        Image(systemName: "gobackward.15").font(.system(size: 22))
                        Spacer()
                        Image(systemName: "play.fill").font(.system(size: 28))
                        Spacer()
                        Image(systemName: "goforward.15").font(.system(size: 22))
                        Spacer()
                        Image(systemName: "trash").font(.system(size: 20)).foregroundStyle(.blue)
                    }
                    .padding(.top, 2)
                }
                .padding(.vertical, 6)
                ForEach(memos.dropFirst(), id: \.0) { m in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(m.0).font(.system(size: 16))
                        HStack {
                            Text(m.1).font(.system(size: 13)).foregroundStyle(.secondary)
                            Spacer()
                            Text(m.2).font(.system(size: 13)).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            ZStack {
                Rectangle().fill(Color(white: 0.09)).frame(height: 90)
                Circle().stroke(Color(white: 0.4), lineWidth: 3).frame(width: 62, height: 62)
                    .overlay(Circle().fill(.red).frame(width: 50, height: 50))
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Calculatrice : élémentaire (réf 035)
struct CalcElementaireV2Vue: View {
    let rangées: [[(String, Color, Color)]] = [
        [("AC", Color(white: 0.65), .black), ("⁺∕₋", Color(white: 0.65), .black), ("%", Color(white: 0.65), .black), ("÷", .orange, .white)],
        [("7", Color(white: 0.2), .white), ("8", Color(white: 0.2), .white), ("9", Color(white: 0.2), .white), ("×", .orange, .white)],
        [("4", Color(white: 0.2), .white), ("5", Color(white: 0.2), .white), ("6", Color(white: 0.2), .white), ("−", .orange, .white)],
        [("1", Color(white: 0.2), .white), ("2", Color(white: 0.2), .white), ("3", Color(white: 0.2), .white), ("+", .orange, .white)],
        [("CALCICONE", Color(white: 0.2), .white), ("0", Color(white: 0.2), .white), (",", Color(white: 0.2), .white), ("=", .orange, .white)]
    ]
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "list.bullet").font(.system(size: 18)).foregroundStyle(.orange)
                Spacer()
                Image(systemName: "slider.horizontal.3").font(.system(size: 18)).foregroundStyle(.orange)
                    .contentShape(Rectangle())
                    .onTapGesture { NavV2.partage.pousser("mhdc2.calc.modes") }
            }
            .padding(.horizontal, 22).padding(.top, 10)
            Spacer()
            Text("162+98").font(.system(size: 30)).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 28)
            Text("260").font(.system(size: 84, weight: .light))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24).padding(.bottom, 14)
            VStack(spacing: 12) {
                ForEach(0..<rangées.count, id: \.self) { r in
                    HStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { c in
                            let b = rangées[r][c]
                            Circle().fill(b.1)
                                .frame(width: 82, height: 82)
                                .overlay(
                                    Group {
                                        if b.0 == "CALCICONE" {
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.white, lineWidth: 2.2)
                                                .frame(width: 24, height: 32)
                                                .overlay(
                                                    VStack(spacing: 4) {
                                                        RoundedRectangle(cornerRadius: 1).fill(.white).frame(width: 14, height: 4)
                                                        HStack(spacing: 4) {
                                                            Circle().fill(.white).frame(width: 3.5, height: 3.5)
                                                            Circle().fill(.white).frame(width: 3.5, height: 3.5)
                                                        }
                                                        HStack(spacing: 4) {
                                                            Circle().fill(.white).frame(width: 3.5, height: 3.5)
                                                            Circle().fill(.white).frame(width: 3.5, height: 3.5)
                                                        }
                                                    }
                                                )
                                        } else {
                                            Text(b.0).font(.system(size: b.0.count > 1 ? 26 : 34, weight: .medium)).foregroundStyle(b.2)
                                        }
                                    }
                                )
                        }
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Calculatrice : menu de modes (réf 077 — Élémentaire/Scientifique/Notes mathématiques)
struct CalcModesV2Vue: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CalcElementaireV2Vue().blur(radius: 3).overlay(Color.black.opacity(0.35))
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Élémentaire").font(.system(size: 16))
                    Spacer()
                    Image(systemName: "checkmark").font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
                .contentShape(Rectangle())
                .onTapGesture { NavV2.partage.retour() }
                Divider()
                HStack {
                    Text("Scientifique").font(.system(size: 16))
                    Spacer()
                    Image(systemName: "function").font(.system(size: 14))
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
                Divider()
                HStack {
                    Text("Notes mathématiques").font(.system(size: 16))
                    Spacer()
                    Image(systemName: "pencil.and.scribble").font(.system(size: 14))
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
                Divider()
                HStack {
                    Text("Convertir").font(.system(size: 16))
                    Spacer()
                    Capsule().fill(Color(white: 0.35)).frame(width: 42, height: 26)
                        .overlay(Circle().fill(.white).frame(width: 22).offset(x: -8))
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
            }
            .frame(width: 265)
            .background(Color(white: 0.14), in: RoundedRectangle(cornerRadius: 14))
            .padding(.top, 54).padding(.trailing, 16)
        }
        .preferredColorScheme(.dark)
    }
}
