// Météo — construite contre la vidéo de référence du 18/08 (44 écrans, iOS 26)
// D59 : données remplaçables. Villes de Sarah : Lyon (domicile), Theizé, Marseille (le port du 28).
// Cohérence R3 : Lyon = 24°, nuit dégagée, ↑29° ↓18° (identique au widget de l'accueil).
import SwiftUI
import MapKit

// ============================================================ DONNÉES (remplaçables — D59)
struct VilleMeteo: Identifiable {
    let id: String
    let nom: String
    let etiquette: String?     // "DOMICILE" etc.
    let maPosition: Bool
    let temp: Int
    let condition: String
    let max: Int
    let min: Int
    let resume: String
    let heures: [(String, String, Int)]           // (heure, symbole SF, temp)
    let jours: [(String, String, Int, Int, Int?)] // (jour, symbole, min, max, %pluie)
    let ressenti: Int
    let uv: Int
    let vent: Int
    let rafales: Int
    let directionVent: String
    let coucher: String
    let lever: String
    let visibilite: Int
    let humidite: Int
    let rosee: Int
    let pression: Int
    let lat: Double
    let lon: Double
}

enum DonneesMeteo {
    static let villes: [VilleMeteo] = [
        VilleMeteo(id: "lyon", nom: "Lyon", etiquette: "DOMICILE", maPosition: true,
                   temp: 24, condition: "Nuit dégagée", max: 29, min: 18,
                   resume: "Ciel dégagé pour le reste de la soirée. Rafales de vent allant jusqu'à 19 km/h.",
                   heures: [("Maint.", "moon.stars.fill", 24), ("21 h", "moon.stars.fill", 23), ("22 h", "moon.fill", 22),
                            ("23 h", "moon.fill", 21), ("00 h", "moon.fill", 20), ("01 h", "moon.fill", 20),
                            ("02 h", "moon.fill", 19), ("03 h", "moon.fill", 19), ("04 h", "moon.fill", 18),
                            ("05 h", "moon.fill", 18), ("06 h", "sun.horizon.fill", 18), ("07 h", "sun.max.fill", 19)],
                   jours: [("Auj.", "sun.max.fill", 18, 29, nil), ("Mar.", "sun.max.fill", 19, 31, nil),
                           ("Mer.", "cloud.sun.fill", 19, 32, nil), ("Jeu.", "cloud.sun.rain.fill", 18, 27, 65),
                           ("Ven.", "cloud.rain.fill", 17, 24, 75), ("Sam.", "cloud.fill", 16, 23, 40),
                           ("Dim.", "cloud.sun.fill", 16, 23, nil), ("Lun.", "cloud.fill", 15, 21, 30),
                           ("Mar.", "cloud.rain.fill", 14, 26, 55), ("Mer.", "cloud.sun.fill", 16, 27, nil)],
                   ressenti: 24, uv: 0, vent: 11, rafales: 19, directionVent: "308° ONO",
                   coucher: "20:52", lever: "06:38", visibilite: 30, humidite: 58, rosee: 15, pression: 1016,
                   lat: 45.7640, lon: 4.8357),
        VilleMeteo(id: "theize", nom: "Theizé", etiquette: nil, maPosition: false,
                   temp: 22, condition: "Nuit dégagée", max: 28, min: 16,
                   resume: "Nuit claire sur les pierres dorées. Vent faible.",
                   heures: [("Maint.", "moon.stars.fill", 22), ("21 h", "moon.stars.fill", 21), ("22 h", "moon.fill", 20),
                            ("23 h", "moon.fill", 19), ("00 h", "moon.fill", 18), ("01 h", "moon.fill", 18),
                            ("02 h", "moon.fill", 17), ("03 h", "moon.fill", 17), ("04 h", "moon.fill", 16),
                            ("05 h", "moon.fill", 16), ("06 h", "sun.horizon.fill", 17), ("07 h", "sun.max.fill", 18)],
                   jours: [("Auj.", "sun.max.fill", 16, 28, nil), ("Mar.", "sun.max.fill", 17, 30, nil),
                           ("Mer.", "cloud.sun.fill", 18, 31, nil), ("Jeu.", "cloud.sun.rain.fill", 17, 26, 60),
                           ("Ven.", "cloud.rain.fill", 16, 23, 70), ("Sam.", "cloud.fill", 15, 22, 35),
                           ("Dim.", "cloud.sun.fill", 15, 22, nil), ("Lun.", "cloud.fill", 14, 20, 30),
                           ("Mar.", "cloud.rain.fill", 13, 24, 50), ("Mer.", "cloud.sun.fill", 15, 26, nil)],
                   ressenti: 22, uv: 0, vent: 7, rafales: 13, directionVent: "295° ONO",
                   coucher: "20:54", lever: "06:40", visibilite: 32, humidite: 62, rosee: 14, pression: 1017,
                   lat: 45.9394, lon: 4.6120),
        VilleMeteo(id: "marseille", nom: "Marseille", etiquette: nil, maPosition: false,
                   temp: 26, condition: "Nuit dégagée", max: 31, min: 22,
                   resume: "Mistral faiblissant dans la nuit. Mer peu agitée au large.",
                   heures: [("Maint.", "moon.stars.fill", 26), ("21 h", "moon.stars.fill", 25), ("22 h", "moon.fill", 25),
                            ("23 h", "moon.fill", 24), ("00 h", "moon.fill", 24), ("01 h", "moon.fill", 23),
                            ("02 h", "moon.fill", 23), ("03 h", "moon.fill", 23), ("04 h", "moon.fill", 22),
                            ("05 h", "moon.fill", 22), ("06 h", "sun.horizon.fill", 23), ("07 h", "sun.max.fill", 24)],
                   jours: [("Auj.", "sun.max.fill", 22, 31, nil), ("Mar.", "sun.max.fill", 22, 32, nil),
                           ("Mer.", "sun.max.fill", 23, 32, nil), ("Jeu.", "sun.max.fill", 23, 31, nil),
                           ("Ven.", "cloud.sun.fill", 22, 30, nil), ("Sam.", "cloud.sun.fill", 22, 29, nil),
                           ("Dim.", "sun.max.fill", 21, 30, nil), ("Lun.", "sun.max.fill", 21, 30, nil),
                           ("Mar.", "cloud.sun.fill", 22, 29, 20), ("Mer.", "sun.max.fill", 22, 31, nil)],
                   ressenti: 27, uv: 0, vent: 22, rafales: 38, directionVent: "340° NNO",
                   coucher: "20:47", lever: "06:47", visibilite: 35, humidite: 55, rosee: 16, pression: 1014,
                   lat: 43.2965, lon: 5.3698),
    ]
}

// ============================================================ APP
struct MeteoVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0
    @State private var listeVisible = false
    @State private var carteVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $page) {
                ForEach(Array(DonneesMeteo.villes.enumerated()), id: \.offset) { i, v in
                    VilleMeteoVue(ville: v).tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Barre basse : carte / points / liste (comme la référence)
            HStack {
                Button { carteVisible = true } label: {
                    Image(systemName: "map").font(.system(size: 20)).foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                }
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<DonneesMeteo.villes.count, id: \.self) { i in
                        if i == 0 {
                            Image(systemName: "location.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(page == 0 ? .white : .white.opacity(0.4))
                        } else {
                            Circle().fill(page == i ? .white : .white.opacity(0.4))
                                .frame(width: 7, height: 7)
                        }
                    }
                }
                Spacer()
                Button { listeVisible = true } label: {
                    Image(systemName: "list.bullet").font(.system(size: 20)).foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                }
            }
            .padding(.horizontal, 18).padding(.bottom, 4)
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )

            BarreHome { dismiss() }
        }
        .background(FondMeteo())
        .preferredColorScheme(.dark)
        .sheet(isPresented: $listeVisible) { ListeVillesVue(page: $page) }
        .fullScreenCover(isPresented: $carteVisible) { CarteMeteoVue() }
    }
}

// Fond dégradé nuit d'été (proche de la référence en soirée)
struct FondMeteo: View {
    var body: some View {
        LinearGradient(colors: [Color(hex: 0x2E4A6B), Color(hex: 0x1B2A44), Color(hex: 0x101828)],
                       startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

// ============================================================ PAGE VILLE
struct VilleMeteoVue: View {
    let ville: VilleMeteo
    @State private var conditionsVisibles = false
    @State private var signaler = false
    @State private var plans = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                // En-tête
                VStack(spacing: 2) {
                    if ville.maPosition {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill").font(.system(size: 11))
                            Text("DOMICILE").font(.system(size: 12, weight: .semibold)).kerning(1)
                        }
                        .foregroundStyle(.white.opacity(0.8))
                    }
                    Text(ville.nom).font(.system(size: 34)).foregroundStyle(.white)
                    Text("\(ville.temp)°").font(.system(size: 100, weight: .thin)).foregroundStyle(.white)
                        .padding(.leading, 26)
                    Text(ville.condition).font(.system(size: 20)).foregroundStyle(.white.opacity(0.85))
                    Text("↑ \(ville.max)°  ↓ \(ville.min)°").font(.system(size: 20)).foregroundStyle(.white)
                }
                .padding(.top, 60)

                // Résumé + bande horaire
                CarteMeteoBloc {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(ville.resume).font(.system(size: 15)).foregroundStyle(.white)
                        Divider().overlay(.white.opacity(0.2))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 22) {
                                ForEach(Array(ville.heures.enumerated()), id: \.offset) { _, h in
                                    VStack(spacing: 8) {
                                        Text(h.0).font(.system(size: 13, weight: .medium))
                                        Image(systemName: h.1).font(.system(size: 17))
                                            .symbolRenderingMode(.multicolor)
                                        Text("\(h.2)°").font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { conditionsVisibles = true }

                // Prévisions 10 jours
                CarteMeteoBloc(titre: "PRÉVISIONS SUR 10 JOURS", symbole: "calendar") {
                    VStack(spacing: 0) {
                        ForEach(Array(ville.jours.enumerated()), id: \.offset) { i, j in
                            HStack(spacing: 10) {
                                Text(j.0).font(.system(size: 17, weight: .medium)).foregroundStyle(.white)
                                    .frame(width: 46, alignment: .leading)
                                VStack(spacing: 1) {
                                    Image(systemName: j.1).font(.system(size: 16)).symbolRenderingMode(.multicolor)
                                    if let p = j.4 {
                                        Text("\(p) %").font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(Color(hex: 0x7CD1F5))
                                    }
                                }
                                .frame(width: 34)
                                Text("\(j.2)°").font(.system(size: 17)).foregroundStyle(.white.opacity(0.55))
                                    .frame(width: 32, alignment: .trailing)
                                BarreTemp(min: j.2, max: j.3, minGlobal: 13, maxGlobal: 32, tempActuelle: i == 0 ? ville.temp : nil)
                                Text("\(j.3)°").font(.system(size: 17)).foregroundStyle(.white)
                                    .frame(width: 32, alignment: .trailing)
                            }
                            .padding(.vertical, 9)
                            if i < ville.jours.count - 1 { Divider().overlay(.white.opacity(0.15)) }
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { conditionsVisibles = true }

                // Qualité de l'air
                CarteMeteoBloc(titre: "QUALITÉ DE L'AIR", symbole: "aqi.medium") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Moyenne").font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
                        Text("La qualité de l'air est la même qu'hier à peu près à la même heure.")
                            .font(.system(size: 14)).foregroundStyle(.white.opacity(0.85))
                        LinearGradient(colors: [.green, .yellow, .orange, .red, .purple],
                                       startPoint: .leading, endPoint: .trailing)
                            .frame(height: 5).clipShape(Capsule())
                            .overlay(alignment: .leading) {
                                Circle().fill(.white).frame(width: 9, height: 9)
                                    .padding(.leading, 90)
                            }
                    }
                }

                // Tuiles 2 colonnes
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                    TuileMeteo(titre: "RESSENTI", symbole: "thermometer.medium",
                               valeur: "\(ville.ressenti)°",
                               note: ville.ressenti > ville.temp ? "Le ressenti est plus élevé que la température réelle." : "Identique à la température réelle.")
                    TuileMeteo(titre: "INDICE UV", symbole: "sun.max.fill",
                               valeur: "\(ville.uv)", sousValeur: ville.uv <= 2 ? "Faible" : "Modéré",
                               note: "Restera faible jusqu'au lever du soleil.")
                    TuileVent(ville: ville)
                    TuileMeteo(titre: "COUCHER DE SOLEIL", symbole: "sunset.fill",
                               valeur: ville.coucher, note: "Lever : \(ville.lever)")
                    TuileMeteo(titre: "PRÉCIPITATIONS", symbole: "drop.fill",
                               valeur: "0 mm", sousValeur: "Aujourd'hui",
                               note: "Prochaines précipitations : jeu.")
                    TuileMeteo(titre: "VISIBILITÉ", symbole: "eye.fill",
                               valeur: "\(ville.visibilite) km", note: "Vue parfaitement dégagée.")
                    TuileMeteo(titre: "HUMIDITÉ", symbole: "humidity.fill",
                               valeur: "\(ville.humidite) %", note: "Le point de rosée est de \(ville.rosee)°.")
                    TuileMeteo(titre: "PRESSION", symbole: "gauge.medium",
                               valeur: "\(ville.pression)", sousValeur: "hPa", note: "Stable")
                }

                // Signaler un problème (catalogue D56)
                CarteMeteoBloc {
                    Button { signaler = true } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.bubble.fill").font(.system(size: 17))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Signaler un problème").font(.system(size: 16, weight: .semibold))
                                Text("Vous pouvez décrire les conditions actuelles dans votre lieu pour aider à améliorer les prévisions.")
                                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .foregroundStyle(.white)
                    }
                }

                // Pied de page
                VStack(spacing: 10) {
                    if ville.maPosition {
                        Text("Météo pour le domicile\n14 rue des Capucins, 69001 Lyon")
                            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    Button { plans = true } label: {
                        Text("Afficher dans Plans").font(.system(size: 14)).foregroundStyle(.white)
                    }
                    Text("En savoir plus sur les données météo et les données de plans")
                        .font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
                }
                .padding(.bottom, 80)
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $conditionsVisibles) { ConditionsMeteoVue(ville: ville) }
        .alert("Signalement impossible", isPresented: $signaler) { Button("OK", role: .cancel) {} } message: {
            Text("Impossible d\u{2019}envoyer votre signalement pour le moment. Réessayez lorsque vous serez de nouveau en ligne.")
        }
        .alert("Plans", isPresented: $plans) { Button("OK", role: .cancel) {} } message: {
            Text(ErreurLambda.reponse("app.attente"))
        }
    }
}

// Barre de température des prévisions (dégradé positionné dans la plage globale)
struct BarreTemp: View {
    let min: Int
    let max: Int
    let minGlobal: Int
    let maxGlobal: Int
    var tempActuelle: Int? = nil
    var body: some View {
        GeometryReader { geo in
            let plage = CGFloat(maxGlobal - minGlobal)
            let x0 = CGFloat(min - minGlobal) / plage * geo.size.width
            let x1 = CGFloat(max - minGlobal) / plage * geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.25)).frame(height: 5)
                Capsule()
                    .fill(LinearGradient(colors: [Color(hex: 0x8CC7F0), Color(hex: 0xF6D35B), Color(hex: 0xF2994A)],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: base(x1 - x0), height: 5)
                    .offset(x: x0)
                if let t = tempActuelle {
                    let xt = CGFloat(t - minGlobal) / plage * geo.size.width
                    Circle().fill(.white).frame(width: 6, height: 6)
                        .overlay(Circle().stroke(.black.opacity(0.4), lineWidth: 1.5))
                        .offset(x: xt - 3)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 16)
    }
    private func base(_ v: CGFloat) -> CGFloat { Swift.max(v, 8) }
}

struct CarteMeteoBloc<Contenu: View>: View {
    var titre: String? = nil
    var symbole: String? = nil
    @ViewBuilder let contenu: Contenu
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let titre {
                HStack(spacing: 5) {
                    if let symbole { Image(systemName: symbole).font(.system(size: 12)) }
                    Text(titre).font(.system(size: 12, weight: .semibold)).kerning(0.5)
                }
                .foregroundStyle(.white.opacity(0.6))
            }
            contenu
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
        .background(.ultraThinMaterial.opacity(0.4), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct TuileMeteo: View {
    let titre: String
    let symbole: String
    let valeur: String
    var sousValeur: String? = nil
    var note: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: symbole).font(.system(size: 12))
                Text(titre).font(.system(size: 12, weight: .semibold)).kerning(0.3)
            }
            .foregroundStyle(.white.opacity(0.6))
            Text(valeur).font(.system(size: 30)).foregroundStyle(.white)
            if let sousValeur {
                Text(sousValeur).font(.system(size: 16, weight: .medium)).foregroundStyle(.white)
                    .padding(.top, -6)
            }
            Spacer(minLength: 0)
            if let note {
                Text(note).font(.system(size: 12.5)).foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct TuileVent: View {
    let ville: VilleMeteo
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: "wind").font(.system(size: 12))
                Text("VENT").font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.6))
            VStack(alignment: .leading, spacing: 5) {
                HStack { Text("Vent"); Spacer(); Text("\(ville.vent) km/h") }
                Divider().overlay(.white.opacity(0.2))
                HStack { Text("Rafales"); Spacer(); Text("\(ville.rafales) km/h") }
                Divider().overlay(.white.opacity(0.2))
                HStack { Text("Direction"); Spacer(); Text(ville.directionVent) }
            }
            .font(.system(size: 13)).foregroundStyle(.white)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
    }
}

// ============================================================ CONDITIONS MÉTÉO (feuille détaillée)
struct ConditionsMeteoVue: View {
    @Environment(\.dismiss) private var dismiss
    let ville: VilleMeteo
    @State private var jourChoisi = 0
    @State private var ressentie = false

    // Courbe de température plausible sur 24 h (min la nuit, max ~16-17 h)
    private var courbe: [Double] {
        let mn = Double(jourChoisi == 0 ? ville.min : ville.jours[Swift.min(jourChoisi, ville.jours.count - 1)].2)
        let mx = Double(jourChoisi == 0 ? ville.max : ville.jours[Swift.min(jourChoisi, ville.jours.count - 1)].3)
        let delta = ressentie ? 1.0 : 0.0
        return (0..<24).map { h in
            let phase = Double(h - 5) / 11.0 * .pi
            let v = mn + (mx - mn) * Swift.max(0, sin(Swift.min(Swift.max(phase, 0), .pi)))
            return v + (v > (mn + mx) / 2 ? delta : 0)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Sélecteur de jours
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(0..<8, id: \.self) { i in
                                let jours = ["L", "M", "M", "J", "V", "S", "D", "L"]
                                VStack(spacing: 5) {
                                    Text(jours[i]).font(.system(size: 12)).foregroundStyle(.secondary)
                                    Text("\(17 + i)").font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(jourChoisi == i ? .black : .white)
                                        .frame(width: 34, height: 34)
                                        .background(jourChoisi == i ? Color.white : .clear, in: Circle())
                                }
                                .contentShape(Rectangle())
                                .onTapGesture { jourChoisi = i }
                            }
                        }
                        .padding(.horizontal, 4)
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(Int(courbe.max() ?? 0))°").font(.system(size: 34, weight: .semibold))
                        Text("\(Int(courbe.min() ?? 0))°").font(.system(size: 34)).foregroundStyle(.secondary)
                        Image(systemName: "sun.max.fill").symbolRenderingMode(.multicolor).font(.system(size: 24))
                        Spacer()
                    }
                    .foregroundStyle(.white)

                    // Graphe de courbe
                    GeometryReader { geo in
                        let vals = courbe
                        let mn = (vals.min() ?? 0) - 2
                        let mx = (vals.max() ?? 1) + 2
                        let pas = geo.size.width / CGFloat(vals.count - 1)
                        ZStack {
                            LinearGradient(colors: [Color(hex: 0x2C4A32).opacity(0.6), Color(hex: 0x87551E).opacity(0.6)],
                                           startPoint: .bottom, endPoint: .top)
                            Path { p in
                                for (i, v) in vals.enumerated() {
                                    let x = CGFloat(i) * pas
                                    let y = geo.size.height * (1 - CGFloat((v - mn) / (mx - mn)))
                                    if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                                    else { p.addLine(to: CGPoint(x: x, y: y)) }
                                }
                            }
                            .stroke(Color(hex: 0xF2994A), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .frame(height: 150)

                    HStack {
                        Text("00 h").frame(maxWidth: .infinity, alignment: .leading)
                        Text("06 h").frame(maxWidth: .infinity)
                        Text("12 h").frame(maxWidth: .infinity)
                        Text("18 h").frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.system(size: 12)).foregroundStyle(.secondary)

                    // Réelle / Ressentie
                    Picker("", selection: $ressentie) {
                        Text("Réelle").tag(false)
                        Text("Ressentie").tag(true)
                    }
                    .pickerStyle(.segmented)
                    Text("La température \(ressentie ? "ressentie" : "réelle").")
                        .font(.system(size: 13)).foregroundStyle(.secondary)

                    Divider().overlay(Color(hex: 0x2C2C2E))

                    Group {
                        Text("Risque de précipitation").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                        Text("Risque du jour : \(jourChoisi >= 3 ? 15 : 0) %").font(.system(size: 13)).foregroundStyle(.secondary)

                        Text("Précipitations totales").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                        VStack(spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("DERNIÈRES 24 HEURES").font(.system(size: 11)).foregroundStyle(.secondary)
                                    Text("Précipitations").font(.system(size: 15)).foregroundStyle(.white)
                                }
                                Spacer()
                                Text("0 mm").font(.system(size: 15)).foregroundStyle(.white)
                            }
                            Divider().overlay(Color(hex: 0x2C2C2E))
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("PROCHAINES 24 HEURES").font(.system(size: 11)).foregroundStyle(.secondary)
                                    Text("Précipitations").font(.system(size: 15)).foregroundStyle(.white)
                                }
                                Spacer()
                                Text("0 mm").font(.system(size: 15)).foregroundStyle(.white)
                            }
                        }
                        .padding(12)
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))

                        Text("Comparaison jour après jour").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                        Text("Aujourd'hui, la température maximale est similaire à celle d'hier.")
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                        VStack(spacing: 10) {
                            HStack {
                                Text("Aujourd'hui").font(.system(size: 15)).foregroundStyle(.white).frame(width: 92, alignment: .leading)
                                Text("\(ville.min)°").font(.system(size: 14)).foregroundStyle(.secondary)
                                BarreTemp(min: ville.min, max: ville.max, minGlobal: ville.min - 3, maxGlobal: ville.max + 2)
                                Text("\(ville.max)°").font(.system(size: 14)).foregroundStyle(.white)
                            }
                            HStack {
                                Text("Hier").font(.system(size: 15)).foregroundStyle(.secondary).frame(width: 92, alignment: .leading)
                                Text("\(ville.min + 1)°").font(.system(size: 14)).foregroundStyle(.secondary)
                                BarreTemp(min: ville.min + 1, max: ville.max - 1, minGlobal: ville.min - 3, maxGlobal: ville.max + 2)
                                Text("\(ville.max - 1)°").font(.system(size: 14)).foregroundStyle(.white)
                            }
                        }

                        Text("Options").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                        VStack(spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Température").font(.system(size: 15)).foregroundStyle(.white)
                                    Text("Utiliser le réglage système (°C)").font(.system(size: 12)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down").font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                            Divider().overlay(Color(hex: 0x2C2C2E))
                            HStack {
                                Text("Précipitations").font(.system(size: 15)).foregroundStyle(.white)
                                Spacer()
                                Text("mm, cm").font(.system(size: 13)).foregroundStyle(.secondary)
                                Image(systemName: "chevron.up.chevron.down").font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                        }
                        .padding(12)
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Conditions météo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 30, height: 30).background(Color(hex: 0x2C2C2E), in: Circle())
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ LISTE DES VILLES
struct ListeVillesVue: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var page: Int
    @State private var recherche = ""
    @State private var resultatChoisi: String? = nil
    @State private var chargement = false
    @State private var echec = false

    private let annuaire = ["Ajaccio", "Annecy", "Bordeaux", "Brest", "Cassis", "Clermont-Ferrand",
                            "Dijon", "Grenoble", "Lille", "Montpellier", "Nantes", "Nice",
                            "Paris", "Rennes", "Strasbourg", "Toulouse", "Tours", "Villefranche-sur-Saône"]
    private var resultats: [String] {
        recherche.isEmpty ? [] : annuaire.filter { $0.localizedCaseInsensitiveContains(recherche) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    if recherche.isEmpty {
                        ForEach(Array(DonneesMeteo.villes.enumerated()), id: \.offset) { i, v in
                            Button {
                                page = i
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(v.nom).font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)
                                        Text(v.maPosition ? "Ma position · Domicile" : "20:0\(i) ")
                                            .font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                                        Spacer()
                                        Text(v.condition).font(.system(size: 12)).foregroundStyle(.white.opacity(0.8))
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 3) {
                                        Text("\(v.temp)°").font(.system(size: 46, weight: .light)).foregroundStyle(.white)
                                        Spacer()
                                        Text("↑ \(v.max)°  ↓ \(v.min)°").font(.system(size: 12)).foregroundStyle(.white.opacity(0.8))
                                    }
                                }
                                .padding(14)
                                .frame(height: 104)
                                .background(
                                    LinearGradient(colors: [Color(hex: 0x3A5B85), Color(hex: 0x24344F)],
                                                   startPoint: .top, endPoint: .bottom),
                                    in: RoundedRectangle(cornerRadius: 18))
                            }
                        }
                        Text("En savoir plus sur les données météo et les données de plans")
                            .font(.system(size: 11)).foregroundStyle(.secondary)
                            .padding(.top, 12)
                    } else if resultats.isEmpty {
                        Text("Aucun résultat").font(.system(size: 15)).foregroundStyle(.secondary).padding(.top, 40)
                    } else {
                        ForEach(resultats, id: \.self) { r in
                            Button {
                                // Météo est une app EN LIGNE : l'ajout échoue en réseau (anneau 3, D56)
                                resultatChoisi = r
                                chargement = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                                    chargement = false
                                    echec = true
                                }
                            } label: {
                                HStack {
                                    Text(r).font(.system(size: 16)).foregroundStyle(.white)
                                    Spacer()
                                    if chargement && resultatChoisi == r { ProgressView().tint(.white) }
                                }
                                .padding(.horizontal, 14).padding(.vertical, 12)
                                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Météo")
            .searchable(text: $recherche, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Ville ou aéroport")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Modifier la liste") {}
                        Button("Unités") {}
                        Button("Signaler un problème") {}
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundStyle(.white)
                    }
                }
            }
            .alert("Connexion impossible", isPresented: $echec) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Impossible de charger la météo pour « \(resultatChoisi ?? "") ». Vérifiez votre connexion et réessayez.")
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ CARTE PLEIN ÉCRAN
struct CarteMeteoVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.7640, longitude: 4.8357),
                           span: MKCoordinateSpan(latitudeDelta: 6.5, longitudeDelta: 6.5)))

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position) {
                ForEach(DonneesMeteo.villes) { v in
                    Annotation(v.nom, coordinate: CLLocationCoordinate2D(latitude: v.lat, longitude: v.lon)) {
                        Text("\(v.temp)°")
                            .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 9).padding(.vertical, 5)
                            .background(Color(hex: 0x2E4A6B), in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.6), lineWidth: 1))
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .ignoresSafeArea()

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "square.3.layers.3d")
                        .font(.system(size: 17)).foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                    Image(systemName: "location")
                        .font(.system(size: 16)).foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding(.horizontal, 16).padding(.top, 8)
        }
        .preferredColorScheme(.dark)
    }
}
