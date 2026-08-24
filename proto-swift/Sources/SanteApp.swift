// Santé — construit contre la référence robot (structure simulateur) + références publiques (24/08)
// D51-2 : Résumé (épinglés + tendances), Parcourir (catégories), fiches avec graphiques J/S/M/A,
// profil, états vides propres. D59 : données banales crédibles d'abord ; or narratif DISCRET,
// jamais bloquant : nuit quasi blanche du 16 août (2 h 34), fréquence cardiaque élevée ce soir-là,
// pics de pas les jours banque / Western Union (validé par Joachim le 24/08).
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct JourMesure: Identifiable {
    let id = UUID()
    var jour: String       // "L", "M"…
    var date: String       // "17 août"
    var valeur: Double
}

enum DonneesSante {
    // Pas — 14 derniers jours (pics : 13/06 hors fenêtre ; ici 11/08 banque, 15/08 balade, 16/08 errance nocturne courte)
    static let pas: [JourMesure] = [
        JourMesure(jour: "L", date: "4 août", valeur: 6214), JourMesure(jour: "M", date: "5 août", valeur: 5830),
        JourMesure(jour: "M", date: "6 août", valeur: 7102), JourMesure(jour: "J", date: "7 août", valeur: 5418),
        JourMesure(jour: "V", date: "8 août", valeur: 6890), JourMesure(jour: "S", date: "9 août", valeur: 8934),
        JourMesure(jour: "D", date: "10 août", valeur: 4021), JourMesure(jour: "L", date: "11 août", valeur: 11248),
        JourMesure(jour: "M", date: "12 août", valeur: 6633), JourMesure(jour: "M", date: "13 août", valeur: 5977),
        JourMesure(jour: "J", date: "14 août", valeur: 7245), JourMesure(jour: "V", date: "15 août", valeur: 9412),
        JourMesure(jour: "S", date: "16 août", valeur: 5106), JourMesure(jour: "D", date: "17 août", valeur: 3860),
    ]
    // Sommeil (heures) — la nuit du 16 au 17 : 2 h 34 (or narratif discret)
    static let sommeil: [JourMesure] = [
        JourMesure(jour: "L", date: "4 août", valeur: 7.2), JourMesure(jour: "M", date: "5 août", valeur: 6.9),
        JourMesure(jour: "M", date: "6 août", valeur: 7.4), JourMesure(jour: "J", date: "7 août", valeur: 6.6),
        JourMesure(jour: "V", date: "8 août", valeur: 7.1), JourMesure(jour: "S", date: "9 août", valeur: 8.2),
        JourMesure(jour: "D", date: "10 août", valeur: 7.5), JourMesure(jour: "L", date: "11 août", valeur: 6.1),
        JourMesure(jour: "M", date: "12 août", valeur: 6.8), JourMesure(jour: "M", date: "13 août", valeur: 7.0),
        JourMesure(jour: "J", date: "14 août", valeur: 6.4), JourMesure(jour: "V", date: "15 août", valeur: 7.3),
        JourMesure(jour: "S", date: "16 août", valeur: 2.57), JourMesure(jour: "D", date: "17 août", valeur: 5.9),
    ]
    // Fréquence cardiaque au repos — élevée le 16 au soir
    static let coeur: [JourMesure] = [
        JourMesure(jour: "L", date: "4 août", valeur: 64), JourMesure(jour: "M", date: "5 août", valeur: 66),
        JourMesure(jour: "M", date: "6 août", valeur: 63), JourMesure(jour: "J", date: "7 août", valeur: 65),
        JourMesure(jour: "V", date: "8 août", valeur: 64), JourMesure(jour: "S", date: "9 août", valeur: 62),
        JourMesure(jour: "D", date: "10 août", valeur: 66), JourMesure(jour: "L", date: "11 août", valeur: 71),
        JourMesure(jour: "M", date: "12 août", valeur: 67), JourMesure(jour: "M", date: "13 août", valeur: 65),
        JourMesure(jour: "J", date: "14 août", valeur: 66), JourMesure(jour: "V", date: "15 août", valeur: 64),
        JourMesure(jour: "S", date: "16 août", valeur: 84), JourMesure(jour: "D", date: "17 août", valeur: 73),
    ]
}

// ============================================================ APP
struct SanteVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0x000000).ignoresSafeArea()
            Group {
                if onglet == 0 { ResumeSanteVue() } else { ParcourirSanteVue() }
            }

            HStack {
                VStack(spacing: 3) {
                    Image(systemName: "heart.fill").font(.system(size: 20))
                    Text("Résumé").font(.system(size: 10))
                }
                .foregroundStyle(onglet == 0 ? Color(hex: 0xFA5252) : .secondary)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { onglet = 0 }
                VStack(spacing: 3) {
                    Image(systemName: "square.grid.2x2.fill").font(.system(size: 20))
                    Text("Parcourir").font(.system(size: 10))
                }
                .foregroundStyle(onglet == 1 ? Color(hex: 0xFA5252) : .secondary)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { onglet = 1 }
            }
            .padding(.vertical, 9)
            .background(.ultraThinMaterial)

            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ RÉSUMÉ
struct ResumeSanteVue: View {
    @State private var fiche: String? = nil
    @State private var profilVisible = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Résumé").font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Group {
                        if let portrait = ChargeurPhoto.image("p04") {
                            Image(uiImage: portrait).resizable().scaledToFill()
                                .frame(width: 34, height: 34).clipShape(Circle())
                        } else {
                            Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 34, height: 34)
                                .overlay(Text("S").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white))
                        }
                    }
                    .onTapGesture { profilVisible = true }
                }

                HStack {
                    Text("Épinglés").font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Text("Modifier").font(.system(size: 14)).foregroundStyle(Color(hex: 0x0A84FF))
                }

                CarteSante(titre: "Pas", symbole: "figure.walk", teinte: 0xFF9F0A,
                           valeur: "3 860", unite: "pas", date: "Aujourd'hui",
                           mesures: DonneesSante.pas, max: 12000) { fiche = "pas" }

                CarteSante(titre: "Sommeil", symbole: "bed.double.fill", teinte: 0x5AC8FA,
                           valeur: "5 h 54", unite: "", date: "La nuit dernière",
                           mesures: DonneesSante.sommeil, max: 9) { fiche = "sommeil" }

                CarteSante(titre: "Fréq. cardiaque au repos", symbole: "heart.fill", teinte: 0xFA5252,
                           valeur: "73", unite: "BPM", date: "Aujourd'hui",
                           mesures: DonneesSante.coeur, max: 100) { fiche = "coeur" }

                Text("Tendances").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).padding(.top, 6)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: "bed.double.fill").font(.system(size: 16)).foregroundStyle(Color(hex: 0x5AC8FA))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Sommeil en baisse").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            Text("Vous dormez en moyenne 42 min de moins que le mois dernier.")
                                .font(.system(size: 12.5)).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(14)
                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                Spacer(minLength: 110)
            }
            .padding(.horizontal, 16).padding(.top, 6)
        }
        .sheet(isPresented: Binding(get: { fiche != nil }, set: { if !$0 { fiche = nil } })) {
            FicheSanteVue(genre: fiche ?? "pas")
        }
        .sheet(isPresented: $profilVisible) { ProfilSanteVue() }
    }
}

// Carte épinglée (mini-graphique 14 jours)
struct CarteSante: View {
    let titre: String
    let symbole: String
    let teinte: UInt
    let valeur: String
    let unite: String
    let date: String
    let mesures: [JourMesure]
    let max: Double
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: symbole).font(.system(size: 13)).foregroundStyle(Color(hex: teinte))
                Text(titre).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color(hex: teinte))
                Spacer()
                Text(date).font(.system(size: 12)).foregroundStyle(.secondary)
                Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(.secondary)
            }
            HStack(alignment: .bottom, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(valeur).font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                    Text(unite).font(.system(size: 13)).foregroundStyle(.secondary)
                }
                Spacer()
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(mesures) { m in
                        Capsule().fill(Color(hex: teinte).opacity(m.id == mesures.last?.id ? 1 : 0.45))
                            .frame(width: 5, height: CGFloat(9 + (m.valeur / max) * 30))
                    }
                }
            }
        }
        .padding(14)
        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// ============================================================ FICHE (graphique J/S/M avec sélection)
struct FicheSanteVue: View {
    @Environment(\.dismiss) private var dismiss
    let genre: String
    @State private var periode = 1   // 0 J, 1 S, 2 M
    @State private var selection: UUID? = nil

    private var config: (titre: String, teinte: UInt, unite: String, mesures: [JourMesure], max: Double) {
        switch genre {
        case "sommeil": return ("Sommeil", 0x5AC8FA, "h", DonneesSante.sommeil, 9)
        case "coeur": return ("Fréq. cardiaque au repos", 0xFA5252, "BPM", DonneesSante.coeur, 100)
        default: return ("Pas", 0xFF9F0A, "pas", DonneesSante.pas, 12000)
        }
    }
    private var visibles: [JourMesure] {
        periode == 0 ? Array(config.mesures.suffix(1)) : (periode == 1 ? Array(config.mesures.suffix(7)) : config.mesures)
    }
    private func libelle(_ v: Double) -> String {
        if genre == "sommeil" {
            let h = Int(v); let mn = Int((v - Double(h)) * 60)
            return "\(h) h \(String(format: "%02d", mn))"
        }
        if genre == "coeur" { return "\(Int(v))" }
        let f = NumberFormatter(); f.numberStyle = .decimal; f.groupingSeparator = " "
        return f.string(from: NSNumber(value: Int(v))) ?? "\(Int(v))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Sélecteur de période (J / S / M — comme la vraie fiche)
                    HStack(spacing: 0) {
                        ForEach(Array(["J", "S", "M"].enumerated()), id: \.offset) { i, p in
                            Text(p).font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(periode == i ? .white : .secondary)
                                .padding(.vertical, 6).frame(maxWidth: .infinity)
                                .background(periode == i ? Color(hex: 0x3A3A3C) : .clear, in: RoundedRectangle(cornerRadius: 7))
                                .contentShape(Rectangle())
                                .onTapGesture { periode = i; selection = nil }
                        }
                    }
                    .padding(3)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 9))

                    // Valeur en tête (sélection ou dernier point)
                    let point = visibles.first(where: { $0.id == selection }) ?? visibles.last!
                    VStack(alignment: .leading, spacing: 2) {
                        Text(genre == "pas" ? "TOTAL" : (genre == "sommeil" ? "DURÉE DE SOMMEIL" : "MOYENNE"))
                            .font(.system(size: 11, weight: .semibold)).kerning(0.5).foregroundStyle(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(libelle(point.valeur)).font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                            Text(config.unite == "h" ? "" : config.unite).font(.system(size: 14)).foregroundStyle(.secondary)
                        }
                        Text(point.date + " 2026").font(.system(size: 13)).foregroundStyle(.secondary)
                    }

                    // Graphique à barres (sélection au tap)
                    HStack(alignment: .bottom, spacing: periode == 2 ? 8 : 16) {
                        ForEach(visibles) { m in
                            VStack(spacing: 5) {
                                Capsule()
                                    .fill(Color(hex: config.teinte).opacity(selection == nil || selection == m.id ? 1 : 0.35))
                                    .frame(height: CGFloat(16 + (m.valeur / config.max) * 150))
                                Text(m.jour).font(.system(size: 10)).foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture { Haptique.leger(); selection = (selection == m.id ? nil : m.id) }
                        }
                    }
                    .frame(height: 200, alignment: .bottom)
                    .padding(14)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))

                    // À propos (texte fidèle au ton de la vraie app)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("À propos").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                        Text(genre == "pas"
                             ? "Le nombre de pas correspond au nombre de pas que vous faites au cours de la journée."
                             : (genre == "sommeil"
                                ? "Le suivi du sommeil vous aide à connaître le temps que vous passez endormie."
                                : "Votre fréquence cardiaque au repos est le nombre de battements par minute lorsque vous êtes calme et détendue."))
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle(config.titre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ PARCOURIR
struct ParcourirSanteVue: View {
    @State private var fiche: String? = nil
    @State private var categorieVide: String? = nil

    private let categories: [(String, String, UInt, Bool)] = [
        ("Activité", "flame.fill", 0xFF9F0A, true),
        ("Audition", "ear", 0x0A84FF, false),
        ("Cœur", "heart.fill", 0xFA5252, true),
        ("Cycle menstruel", "drop.fill", 0xE84D8A, false),
        ("Mesures corporelles", "figure", 0x8B5CF6, false),
        ("Pleine conscience", "brain.head.profile", 0x30D1C4, false),
        ("Sommeil", "bed.double.fill", 0x5AC8FA, true),
        ("Vitaux", "waveform.path.ecg", 0xFF3B30, false),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Parcourir").font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    Text("Rechercher").foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12).frame(height: 38)
                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 11))

                Text("Catégories santé").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary).padding(.top, 4)
                VStack(spacing: 0) {
                    ForEach(Array(categories.enumerated()), id: \.offset) { i, c in
                        HStack(spacing: 12) {
                            Image(systemName: c.1).font(.system(size: 17)).foregroundStyle(Color(hex: c.2)).frame(width: 28)
                            Text(c.0).font(.system(size: 15.5)).foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            switch c.0 {
                            case "Activité": fiche = "pas"
                            case "Cœur": fiche = "coeur"
                            case "Sommeil": fiche = "sommeil"
                            default: categorieVide = c.0
                            }
                        }
                        if i < categories.count - 1 {
                            Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 54)
                        }
                    }
                }
                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                Spacer(minLength: 110)
            }
            .padding(.horizontal, 16).padding(.top, 6)
        }
        .sheet(isPresented: Binding(get: { fiche != nil }, set: { if !$0 { fiche = nil } })) {
            FicheSanteVue(genre: fiche ?? "pas")
        }
        .sheet(isPresented: Binding(get: { categorieVide != nil }, set: { if !$0 { categorieVide = nil } })) {
            CategorieVideSanteVue(nom: categorieVide ?? "")
        }
    }
}

// Catégorie sans données (état vide réel — D51)
struct CategorieVideSanteVue: View {
    @Environment(\.dismiss) private var dismiss
    let nom: String
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis").font(.system(size: 42)).foregroundStyle(.secondary)
                Text("Aucune donnée").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                Text("Les données « \(nom) » enregistrées par votre iPhone ou vos apps apparaîtront ici.")
                    .font(.system(size: 13)).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .navigationTitle(nom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ PROFIL
struct ProfilSanteVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    Group {
                        if let portrait = ChargeurPhoto.image("p04") {
                            Image(uiImage: portrait).resizable().scaledToFill()
                                .frame(width: 84, height: 84).clipShape(Circle())
                        } else {
                            Circle().fill(Color(hex: 0x5B7CFA)).frame(width: 84, height: 84)
                        }
                    }
                    .padding(.top, 8)
                    Text("Sarah Levasseur").font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)

                    VStack(spacing: 0) {
                        LigneInfoFichier(cle: "Date de naissance", valeur: "14 mars 1987")
                        LigneInfoFichier(cle: "Sexe", valeur: "Femme")
                        LigneInfoFichier(cle: "Groupe sanguin", valeur: "A+")
                        LigneInfoFichier(cle: "Taille", valeur: "1,66 m")
                        LigneInfoFichier(cle: "Poids", valeur: "61 kg", derniere: true)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))

                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "staroflife.fill").font(.system(size: 15)).foregroundStyle(Color(hex: 0xFA5252))
                            Text("Fiche médicale").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Image(systemName: "phone.fill").font(.system(size: 15)).foregroundStyle(Color(hex: 0xFA5252))
                            Text("Contact d'urgence").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Text("Maman").font(.system(size: 14)).foregroundStyle(.secondary)
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
    }
}
