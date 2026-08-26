// Santé v2 — D68 (26/08) : complétude fonctionnelle maximale (option B, conçu sans vidéo de référence,
// structure robot + composants natifs). Branchées : Activité (pas/distance/étages/énergie), Sommeil
// (phases + horaires), Cœur (repos + marche), Audition (casque), Mesures corporelles (poids).
// États vides crédibles : Alimentation, Cycle, Pleine conscience, Respiratoire. Transverses : Points
// forts, Tendances, Recherche (loupe réelle — D62), Fiche médicale, Contact d'urgence (Appeler routé),
// Historique de santé. Données = jeu de démonstration remplaçable (D59), 35 jours (14 juil - 17 août),
// continuité STRICTE avec la v1 validée sur les 14 derniers jours.
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct JourMesure: Identifiable {
    let id = UUID()
    var jour: String       // "L", "M"…
    var date: String       // "17 août"
    var valeur: Double
}

enum DonneesSante {
    static let pas: [JourMesure] = [
        JourMesure(jour: "L", date: "14 juillet", valeur: 7204), JourMesure(jour: "M", date: "15 juillet", valeur: 6512),
        JourMesure(jour: "M", date: "16 juillet", valeur: 5890), JourMesure(jour: "J", date: "17 juillet", valeur: 4102),
        JourMesure(jour: "V", date: "18 juillet", valeur: 6320), JourMesure(jour: "S", date: "19 juillet", valeur: 8110),
        JourMesure(jour: "D", date: "20 juillet", valeur: 5240), JourMesure(jour: "L", date: "21 juillet", valeur: 6720),
        JourMesure(jour: "M", date: "22 juillet", valeur: 7015), JourMesure(jour: "M", date: "23 juillet", valeur: 5460),
        JourMesure(jour: "J", date: "24 juillet", valeur: 10460), JourMesure(jour: "V", date: "25 juillet", valeur: 6890),
        JourMesure(jour: "S", date: "26 juillet", valeur: 4530), JourMesure(jour: "D", date: "27 juillet", valeur: 7340),
        JourMesure(jour: "L", date: "28 juillet", valeur: 6210), JourMesure(jour: "M", date: "29 juillet", valeur: 5870),
        JourMesure(jour: "M", date: "30 juillet", valeur: 7605), JourMesure(jour: "J", date: "31 juillet", valeur: 8320),
        JourMesure(jour: "V", date: "1 août", valeur: 6045), JourMesure(jour: "S", date: "2 août", valeur: 9130),
        JourMesure(jour: "D", date: "3 août", valeur: 4780), JourMesure(jour: "L", date: "4 août", valeur: 6214),
        JourMesure(jour: "M", date: "5 août", valeur: 5830), JourMesure(jour: "M", date: "6 août", valeur: 7102),
        JourMesure(jour: "J", date: "7 août", valeur: 5418), JourMesure(jour: "V", date: "8 août", valeur: 6890),
        JourMesure(jour: "S", date: "9 août", valeur: 8934), JourMesure(jour: "D", date: "10 août", valeur: 4021),
        JourMesure(jour: "L", date: "11 août", valeur: 11248), JourMesure(jour: "M", date: "12 août", valeur: 6633),
        JourMesure(jour: "M", date: "13 août", valeur: 5977), JourMesure(jour: "J", date: "14 août", valeur: 7245),
        JourMesure(jour: "V", date: "15 août", valeur: 9412), JourMesure(jour: "S", date: "16 août", valeur: 5106),
        JourMesure(jour: "D", date: "17 août", valeur: 3860),
    ]
    static let sommeil: [JourMesure] = [
        JourMesure(jour: "L", date: "14 juillet", valeur: 7.1), JourMesure(jour: "M", date: "15 juillet", valeur: 6.9),
        JourMesure(jour: "M", date: "16 juillet", valeur: 7.2), JourMesure(jour: "J", date: "17 juillet", valeur: 3.1),
        JourMesure(jour: "V", date: "18 juillet", valeur: 5.4), JourMesure(jour: "S", date: "19 juillet", valeur: 6.9),
        JourMesure(jour: "D", date: "20 juillet", valeur: 7.0), JourMesure(jour: "L", date: "21 juillet", valeur: 6.7),
        JourMesure(jour: "M", date: "22 juillet", valeur: 6.9), JourMesure(jour: "M", date: "23 juillet", valeur: 6.4),
        JourMesure(jour: "J", date: "24 juillet", valeur: 5.9), JourMesure(jour: "V", date: "25 juillet", valeur: 6.6),
        JourMesure(jour: "S", date: "26 juillet", valeur: 7.1), JourMesure(jour: "D", date: "27 juillet", valeur: 6.5),
        JourMesure(jour: "L", date: "28 juillet", valeur: 6.2), JourMesure(jour: "M", date: "29 juillet", valeur: 6.6),
        JourMesure(jour: "M", date: "30 juillet", valeur: 6.3), JourMesure(jour: "J", date: "31 juillet", valeur: 6.0),
        JourMesure(jour: "V", date: "1 août", valeur: 6.4), JourMesure(jour: "S", date: "2 août", valeur: 6.8),
        JourMesure(jour: "D", date: "3 août", valeur: 6.1), JourMesure(jour: "L", date: "4 août", valeur: 7.2),
        JourMesure(jour: "M", date: "5 août", valeur: 6.9), JourMesure(jour: "M", date: "6 août", valeur: 7.4),
        JourMesure(jour: "J", date: "7 août", valeur: 6.6), JourMesure(jour: "V", date: "8 août", valeur: 7.1),
        JourMesure(jour: "S", date: "9 août", valeur: 8.2), JourMesure(jour: "D", date: "10 août", valeur: 7.5),
        JourMesure(jour: "L", date: "11 août", valeur: 6.1), JourMesure(jour: "M", date: "12 août", valeur: 6.8),
        JourMesure(jour: "M", date: "13 août", valeur: 7.0), JourMesure(jour: "J", date: "14 août", valeur: 6.4),
        JourMesure(jour: "V", date: "15 août", valeur: 7.3), JourMesure(jour: "S", date: "16 août", valeur: 2.57),
        JourMesure(jour: "D", date: "17 août", valeur: 5.9),
    ]
    static let coeur: [JourMesure] = [
        JourMesure(jour: "L", date: "14 juillet", valeur: 61), JourMesure(jour: "M", date: "15 juillet", valeur: 62),
        JourMesure(jour: "M", date: "16 juillet", valeur: 60), JourMesure(jour: "J", date: "17 juillet", valeur: 63),
        JourMesure(jour: "V", date: "18 juillet", valeur: 71), JourMesure(jour: "S", date: "19 juillet", valeur: 68),
        JourMesure(jour: "D", date: "20 juillet", valeur: 65), JourMesure(jour: "L", date: "21 juillet", valeur: 63),
        JourMesure(jour: "M", date: "22 juillet", valeur: 64), JourMesure(jour: "M", date: "23 juillet", valeur: 62),
        JourMesure(jour: "J", date: "24 juillet", valeur: 66), JourMesure(jour: "V", date: "25 juillet", valeur: 65),
        JourMesure(jour: "S", date: "26 juillet", valeur: 63), JourMesure(jour: "D", date: "27 juillet", valeur: 64),
        JourMesure(jour: "L", date: "28 juillet", valeur: 65), JourMesure(jour: "M", date: "29 juillet", valeur: 64),
        JourMesure(jour: "M", date: "30 juillet", valeur: 66), JourMesure(jour: "J", date: "31 juillet", valeur: 65),
        JourMesure(jour: "V", date: "1 août", valeur: 64), JourMesure(jour: "S", date: "2 août", valeur: 66),
        JourMesure(jour: "D", date: "3 août", valeur: 65), JourMesure(jour: "L", date: "4 août", valeur: 64),
        JourMesure(jour: "M", date: "5 août", valeur: 66), JourMesure(jour: "M", date: "6 août", valeur: 63),
        JourMesure(jour: "J", date: "7 août", valeur: 65), JourMesure(jour: "V", date: "8 août", valeur: 64),
        JourMesure(jour: "S", date: "9 août", valeur: 62), JourMesure(jour: "D", date: "10 août", valeur: 66),
        JourMesure(jour: "L", date: "11 août", valeur: 71), JourMesure(jour: "M", date: "12 août", valeur: 67),
        JourMesure(jour: "M", date: "13 août", valeur: 65), JourMesure(jour: "J", date: "14 août", valeur: 66),
        JourMesure(jour: "V", date: "15 août", valeur: 64), JourMesure(jour: "S", date: "16 août", valeur: 84),
        JourMesure(jour: "D", date: "17 août", valeur: 73),
    ]
    static let distance: [JourMesure] = [
        JourMesure(jour: "L", date: "14 juillet", valeur: 5.2), JourMesure(jour: "M", date: "15 juillet", valeur: 4.7),
        JourMesure(jour: "M", date: "16 juillet", valeur: 4.2), JourMesure(jour: "J", date: "17 juillet", valeur: 3.0),
        JourMesure(jour: "V", date: "18 juillet", valeur: 4.6), JourMesure(jour: "S", date: "19 juillet", valeur: 5.8),
        JourMesure(jour: "D", date: "20 juillet", valeur: 3.8), JourMesure(jour: "L", date: "21 juillet", valeur: 4.8),
        JourMesure(jour: "M", date: "22 juillet", valeur: 5.1), JourMesure(jour: "M", date: "23 juillet", valeur: 3.9),
        JourMesure(jour: "J", date: "24 juillet", valeur: 7.5), JourMesure(jour: "V", date: "25 juillet", valeur: 5.0),
        JourMesure(jour: "S", date: "26 juillet", valeur: 3.3), JourMesure(jour: "D", date: "27 juillet", valeur: 5.3),
        JourMesure(jour: "L", date: "28 juillet", valeur: 4.5), JourMesure(jour: "M", date: "29 juillet", valeur: 4.2),
        JourMesure(jour: "M", date: "30 juillet", valeur: 5.5), JourMesure(jour: "J", date: "31 juillet", valeur: 6.0),
        JourMesure(jour: "V", date: "1 août", valeur: 4.4), JourMesure(jour: "S", date: "2 août", valeur: 6.6),
        JourMesure(jour: "D", date: "3 août", valeur: 3.4), JourMesure(jour: "L", date: "4 août", valeur: 4.5),
        JourMesure(jour: "M", date: "5 août", valeur: 4.2), JourMesure(jour: "M", date: "6 août", valeur: 5.1),
        JourMesure(jour: "J", date: "7 août", valeur: 3.9), JourMesure(jour: "V", date: "8 août", valeur: 5.0),
        JourMesure(jour: "S", date: "9 août", valeur: 6.4), JourMesure(jour: "D", date: "10 août", valeur: 2.9),
        JourMesure(jour: "L", date: "11 août", valeur: 8.1), JourMesure(jour: "M", date: "12 août", valeur: 4.8),
        JourMesure(jour: "M", date: "13 août", valeur: 4.3), JourMesure(jour: "J", date: "14 août", valeur: 5.2),
        JourMesure(jour: "V", date: "15 août", valeur: 6.8), JourMesure(jour: "S", date: "16 août", valeur: 3.7),
        JourMesure(jour: "D", date: "17 août", valeur: 2.8),
    ]
    static let etages: [JourMesure] = [
        JourMesure(jour: "L", date: "14 juillet", valeur: 6), JourMesure(jour: "M", date: "15 juillet", valeur: 4),
        JourMesure(jour: "M", date: "16 juillet", valeur: 3), JourMesure(jour: "J", date: "17 juillet", valeur: 1),
        JourMesure(jour: "V", date: "18 juillet", valeur: 5), JourMesure(jour: "S", date: "19 juillet", valeur: 9),
        JourMesure(jour: "D", date: "20 juillet", valeur: 2), JourMesure(jour: "L", date: "21 juillet", valeur: 6),
        JourMesure(jour: "M", date: "22 juillet", valeur: 7), JourMesure(jour: "M", date: "23 juillet", valeur: 4),
        JourMesure(jour: "J", date: "24 juillet", valeur: 12), JourMesure(jour: "V", date: "25 juillet", valeur: 5),
        JourMesure(jour: "S", date: "26 juillet", valeur: 2), JourMesure(jour: "D", date: "27 juillet", valeur: 8),
        JourMesure(jour: "L", date: "28 juillet", valeur: 5), JourMesure(jour: "M", date: "29 juillet", valeur: 4),
        JourMesure(jour: "M", date: "30 juillet", valeur: 7), JourMesure(jour: "J", date: "31 juillet", valeur: 9),
        JourMesure(jour: "V", date: "1 août", valeur: 5), JourMesure(jour: "S", date: "2 août", valeur: 10),
        JourMesure(jour: "D", date: "3 août", valeur: 3), JourMesure(jour: "L", date: "4 août", valeur: 5),
        JourMesure(jour: "M", date: "5 août", valeur: 4), JourMesure(jour: "M", date: "6 août", valeur: 6),
        JourMesure(jour: "J", date: "7 août", valeur: 3), JourMesure(jour: "V", date: "8 août", valeur: 6),
        JourMesure(jour: "S", date: "9 août", valeur: 8), JourMesure(jour: "D", date: "10 août", valeur: 2),
        JourMesure(jour: "L", date: "11 août", valeur: 14), JourMesure(jour: "M", date: "12 août", valeur: 5),
        JourMesure(jour: "M", date: "13 août", valeur: 4), JourMesure(jour: "J", date: "14 août", valeur: 6),
        JourMesure(jour: "V", date: "15 août", valeur: 9), JourMesure(jour: "S", date: "16 août", valeur: 3),
        JourMesure(jour: "D", date: "17 août", valeur: 2),
    ]
    static let energie: [JourMesure] = [
        JourMesure(jour: "L", date: "14 juillet", valeur: 380), JourMesure(jour: "M", date: "15 juillet", valeur: 358),
        JourMesure(jour: "M", date: "16 juillet", valeur: 338), JourMesure(jour: "J", date: "17 juillet", valeur: 281),
        JourMesure(jour: "V", date: "18 juillet", valeur: 352), JourMesure(jour: "S", date: "19 juillet", valeur: 409),
        JourMesure(jour: "D", date: "20 juillet", valeur: 317), JourMesure(jour: "L", date: "21 juillet", valeur: 365),
        JourMesure(jour: "M", date: "22 juillet", valeur: 374), JourMesure(jour: "M", date: "23 juillet", valeur: 324),
        JourMesure(jour: "J", date: "24 juillet", valeur: 484), JourMesure(jour: "V", date: "25 juillet", valeur: 370),
        JourMesure(jour: "S", date: "26 juillet", valeur: 294), JourMesure(jour: "D", date: "27 juillet", valeur: 384),
        JourMesure(jour: "L", date: "28 juillet", valeur: 348), JourMesure(jour: "M", date: "29 juillet", valeur: 337),
        JourMesure(jour: "M", date: "30 juillet", valeur: 393), JourMesure(jour: "J", date: "31 juillet", valeur: 416),
        JourMesure(jour: "V", date: "1 août", valeur: 343), JourMesure(jour: "S", date: "2 août", valeur: 442),
        JourMesure(jour: "D", date: "3 août", valeur: 302), JourMesure(jour: "L", date: "4 août", valeur: 348),
        JourMesure(jour: "M", date: "5 août", valeur: 336), JourMesure(jour: "M", date: "6 août", valeur: 377),
        JourMesure(jour: "J", date: "7 août", valeur: 323), JourMesure(jour: "V", date: "8 août", valeur: 370),
        JourMesure(jour: "S", date: "9 août", valeur: 435), JourMesure(jour: "D", date: "10 août", valeur: 278),
        JourMesure(jour: "L", date: "11 août", valeur: 509), JourMesure(jour: "M", date: "12 août", valeur: 362),
        JourMesure(jour: "M", date: "13 août", valeur: 341), JourMesure(jour: "J", date: "14 août", valeur: 381),
        JourMesure(jour: "V", date: "15 août", valeur: 451), JourMesure(jour: "S", date: "16 août", valeur: 313),
        JourMesure(jour: "D", date: "17 août", valeur: 273),
    ]
    static let fcMarche: [JourMesure] = [
        JourMesure(jour: "L", date: "14 juillet", valeur: 98), JourMesure(jour: "M", date: "15 juillet", valeur: 101),
        JourMesure(jour: "M", date: "16 juillet", valeur: 96), JourMesure(jour: "J", date: "17 juillet", valeur: 104),
        JourMesure(jour: "V", date: "18 juillet", valeur: 112), JourMesure(jour: "S", date: "19 juillet", valeur: 106),
        JourMesure(jour: "D", date: "20 juillet", valeur: 100), JourMesure(jour: "L", date: "21 juillet", valeur: 99),
        JourMesure(jour: "M", date: "22 juillet", valeur: 103), JourMesure(jour: "M", date: "23 juillet", valeur: 98),
        JourMesure(jour: "J", date: "24 juillet", valeur: 110), JourMesure(jour: "V", date: "25 juillet", valeur: 102),
        JourMesure(jour: "S", date: "26 juillet", valeur: 97), JourMesure(jour: "D", date: "27 juillet", valeur: 105),
        JourMesure(jour: "L", date: "28 juillet", valeur: 101), JourMesure(jour: "M", date: "29 juillet", valeur: 100),
        JourMesure(jour: "M", date: "30 juillet", valeur: 104), JourMesure(jour: "J", date: "31 juillet", valeur: 107),
        JourMesure(jour: "V", date: "1 août", valeur: 101), JourMesure(jour: "S", date: "2 août", valeur: 106),
        JourMesure(jour: "D", date: "3 août", valeur: 103), JourMesure(jour: "L", date: "4 août", valeur: 106),
        JourMesure(jour: "M", date: "5 août", valeur: 109), JourMesure(jour: "M", date: "6 août", valeur: 104),
        JourMesure(jour: "J", date: "7 août", valeur: 108), JourMesure(jour: "V", date: "8 août", valeur: 105),
        JourMesure(jour: "S", date: "9 août", valeur: 102), JourMesure(jour: "D", date: "10 août", valeur: 110),
        JourMesure(jour: "L", date: "11 août", valeur: 121), JourMesure(jour: "M", date: "12 août", valeur: 111),
        JourMesure(jour: "M", date: "13 août", valeur: 107), JourMesure(jour: "J", date: "14 août", valeur: 109),
        JourMesure(jour: "V", date: "15 août", valeur: 105), JourMesure(jour: "S", date: "16 août", valeur: 128),
        JourMesure(jour: "D", date: "17 août", valeur: 115),
    ]
    static let audition: [JourMesure] = [
        JourMesure(jour: "L", date: "4 août", valeur: 66), JourMesure(jour: "M", date: "5 août", valeur: 71),
        JourMesure(jour: "M", date: "6 août", valeur: 64), JourMesure(jour: "J", date: "7 août", valeur: 73),
        JourMesure(jour: "V", date: "8 août", valeur: 68), JourMesure(jour: "S", date: "9 août", valeur: 75),
        JourMesure(jour: "D", date: "10 août", valeur: 62), JourMesure(jour: "L", date: "11 août", valeur: 70),
        JourMesure(jour: "M", date: "12 août", valeur: 74), JourMesure(jour: "M", date: "13 août", valeur: 77),
        JourMesure(jour: "J", date: "14 août", valeur: 72), JourMesure(jour: "V", date: "15 août", valeur: 69),
        JourMesure(jour: "S", date: "16 août", valeur: 81), JourMesure(jour: "D", date: "17 août", valeur: 79),
    ]
    static let poids: [JourMesure] = [
        JourMesure(jour: "", date: "12 mai", valeur: 63.5), JourMesure(jour: "", date: "20 juin", valeur: 63.1),
        JourMesure(jour: "", date: "25 juillet", valeur: 61.9), JourMesure(jour: "", date: "16 août", valeur: 61.0),
    ]
    // Nuit dernière (16 -> 17 août) : phases + horaires
    static let phasesNuit: [(nom: String, minutes: Int, teinte: UInt)] = [
        ("Éveil", 24, 0xFF9F0A), ("Paradoxal", 52, 0x5AC8FA), ("Léger", 190, 0x0A84FF), ("Profond", 88, 0x3634A3),
    ]
    static let coucher = "01:12"
    static let lever = "07:30"}

// ============================================================ APP
struct SanteVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0
    @State private var rechercheVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0x000000).ignoresSafeArea()
            Group {
                if onglet == 0 { ResumeSanteVue() } else { ParcourirSanteVue() }
            }

            // Pilule flottante + loupe séparée (référence robot)
            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    VStack(spacing: 2) {
                        Image(systemName: "heart.fill").font(.system(size: 17))
                        Text("Résumé").font(.system(size: 10))
                    }
                    .foregroundStyle(onglet == 0 ? Color(hex: 0xFA5252) : .secondary)
                    .padding(.vertical, 7).padding(.horizontal, 20)
                    .background(onglet == 0 ? Color(hex: 0x3A3A3C).opacity(0.85) : .clear, in: Capsule())
                    .contentShape(Capsule())
                    .onTapGesture { onglet = 0 }
                    VStack(spacing: 2) {
                        Image(systemName: "square.grid.2x2.fill").font(.system(size: 17))
                        Text("Parcourir").font(.system(size: 10))
                    }
                    .foregroundStyle(onglet == 1 ? Color(hex: 0xFA5252) : .secondary)
                    .padding(.vertical, 7).padding(.horizontal, 20)
                    .background(onglet == 1 ? Color(hex: 0x3A3A3C).opacity(0.85) : .clear, in: Capsule())
                    .contentShape(Capsule())
                    .onTapGesture { onglet = 1 }
                }
                .padding(6)
                .background(.ultraThinMaterial, in: Capsule())
                Image(systemName: "magnifyingglass").font(.system(size: 17)).foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(.ultraThinMaterial, in: Circle())
                    .contentShape(Circle())
                    .onTapGesture { rechercheVisible = true }
            }
            .padding(.bottom, 34)

            BarreHome { dismiss() }
        }
        .sheet(isPresented: $rechercheVisible) { RechercheSanteVue() }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ CATALOGUE DES DONNÉES (recherche + catégories)
struct MetriqueSante: Identifiable {
    let id: String        // clé de fiche
    let titre: String
    let symbole: String
    let teinte: UInt
    let valeur: String
    let date: String
}

enum CatalogueSante {
    static let toutes: [MetriqueSante] = [
        MetriqueSante(id: "pas", titre: "Pas", symbole: "figure.walk", teinte: 0xFF9F0A, valeur: "3 860 pas", date: "Aujourd'hui"),
        MetriqueSante(id: "distance", titre: "Distance de marche", symbole: "figure.walk.motion", teinte: 0xFF9F0A, valeur: "2,8 km", date: "Aujourd'hui"),
        MetriqueSante(id: "etages", titre: "Étages montés", symbole: "figure.stairs", teinte: 0xFF9F0A, valeur: "2 étages", date: "Aujourd'hui"),
        MetriqueSante(id: "energie", titre: "Énergie active", symbole: "flame.fill", teinte: 0xFF9F0A, valeur: "273 kcal", date: "Aujourd'hui"),
        MetriqueSante(id: "sommeil", titre: "Sommeil", symbole: "bed.double.fill", teinte: 0x5AC8FA, valeur: "5 h 54", date: "La nuit dernière"),
        MetriqueSante(id: "coeur", titre: "Fréq. cardiaque au repos", symbole: "heart.fill", teinte: 0xFA5252, valeur: "73 BPM", date: "Aujourd'hui"),
        MetriqueSante(id: "fcmarche", titre: "Fréq. cardiaque en marchant", symbole: "heart.fill", teinte: 0xFA5252, valeur: "115 BPM", date: "Aujourd'hui"),
        MetriqueSante(id: "audition", titre: "Niveaux sonores du casque", symbole: "ear", teinte: 0x0A84FF, valeur: "79 dB", date: "Aujourd'hui"),
        MetriqueSante(id: "poids", titre: "Poids", symbole: "figure", teinte: 0x8B5CF6, valeur: "61 kg", date: "16 août"),
    ]
    static func metrique(_ id: String) -> MetriqueSante { toutes.first(where: { $0.id == id }) ?? toutes[0] }
}

// ============================================================ RÉSUMÉ
struct ResumeSanteVue: View {
    @State private var fiche: String? = nil
    @State private var profilVisible = false
    @State private var tendancesVisibles = false

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

                // Points forts (comme la vraie app : cartes générées sur les données)
                Text("Points forts").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).padding(.top, 6)
                PointFortSante(symbole: "bed.double.fill", teinte: 0x5AC8FA, titre: "Sommeil en forte baisse",
                               texte: "Sur les 5 dernières nuits, vous avez dormi en moyenne 5 h 31, contre 6 h 48 début juillet.",
                               mesures: DonneesSante.sommeil, max: 9) { fiche = "sommeil" }
                PointFortSante(symbole: "heart.fill", teinte: 0xFA5252, titre: "FC au repos en hausse",
                               texte: "Votre fréquence cardiaque au repos moyenne a augmenté de 7 BPM depuis la mi-juillet.",
                               mesures: DonneesSante.coeur, max: 100) { fiche = "coeur" }

                Text("Tendances").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).padding(.top, 6)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "bed.double.fill").font(.system(size: 16)).foregroundStyle(Color(hex: 0x5AC8FA))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Sommeil en baisse").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            Text("Vous dormez en moyenne 42 min de moins que le mois dernier.")
                                .font(.system(size: 12.5)).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    Divider().overlay(Color(hex: 0x2C2C2E))
                    Text("Afficher les tendances").font(.system(size: 15)).foregroundStyle(Color(hex: 0x0A84FF))
                        .contentShape(Rectangle())
                        .onTapGesture { tendancesVisibles = true }
                }
                .padding(14)
                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                Spacer(minLength: 110)
            }
            .padding(.horizontal, 16).padding(.top, 6)
        }
        .sheet(isPresented: Binding(get: { fiche != nil }, set: { if !$0 { fiche = nil } })) {
            FicheRoutageSante(genre: fiche ?? "pas")
        }
        .sheet(isPresented: $profilVisible) { ProfilSanteVue() }
        .sheet(isPresented: $tendancesVisibles) { TendancesSanteVue() }
    }
}

// Route sommeil vers sa fiche spéciale (phases), le reste vers la fiche générique
struct FicheRoutageSante: View {
    let genre: String
    var body: some View {
        if genre == "sommeil" { FicheSommeilVue() } else { FicheSanteVue(genre: genre) }
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
                    ForEach(mesures.suffix(14)) { m in
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

// Carte « point fort » (texte + mini-graphique)
struct PointFortSante: View {
    let symbole: String
    let teinte: UInt
    let titre: String
    let texte: String
    let mesures: [JourMesure]
    let max: Double
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: symbole).font(.system(size: 13)).foregroundStyle(Color(hex: teinte))
                Text(titre).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color(hex: teinte))
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(.secondary)
            }
            Text(texte).font(.system(size: 13.5)).foregroundStyle(.white)
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(mesures.suffix(10)) { m in
                    Capsule().fill(Color(hex: teinte).opacity(0.75))
                        .frame(height: CGFloat(8 + (m.valeur / max) * 26))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 36, alignment: .bottom)
        }
        .padding(14)
        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// ============================================================ FICHE GÉNÉRIQUE (graphique J/S/M avec sélection)
struct FicheSanteVue: View {
    @Environment(\.dismiss) private var dismiss
    let genre: String
    @State private var periode = 1   // 0 J, 1 S, 2 M
    @State private var selection: UUID? = nil

    private var config: (titre: String, teinte: UInt, unite: String, mesures: [JourMesure], max: Double, tete: String, apropos: String) {
        switch genre {
        case "coeur":
            return ("Fréq. cardiaque au repos", 0xFA5252, "BPM", DonneesSante.coeur, 100, "MOYENNE",
                    "Votre fréquence cardiaque au repos est le nombre de battements par minute lorsque vous êtes calme et détendue.")
        case "fcmarche":
            return ("FC en marchant", 0xFA5252, "BPM", DonneesSante.fcMarche, 140, "MOYENNE",
                    "La fréquence cardiaque moyenne en marchant est mesurée pendant vos déplacements à pied de la journée.")
        case "distance":
            return ("Distance de marche", 0xFF9F0A, "km", DonneesSante.distance, 9, "TOTAL",
                    "La distance correspond à la longueur cumulée de vos déplacements à pied ou en course.")
        case "etages":
            return ("Étages montés", 0xFF9F0A, "étages", DonneesSante.etages, 16, "TOTAL",
                    "Un étage compté correspond à environ 3 mètres de dénivelé positif.")
        case "energie":
            return ("Énergie active", 0xFF9F0A, "kcal", DonneesSante.energie, 550, "TOTAL",
                    "L'énergie active correspond aux calories brûlées par vos mouvements, en plus de votre métabolisme de base.")
        case "audition":
            return ("Niveaux sonores du casque", 0x0A84FF, "dB", DonneesSante.audition, 100, "MOYENNE",
                    "L'exposition sonore de votre casque est mesurée pendant l'écoute. Une exposition répétée au-dessus de 80 dB peut affecter l'audition.")
        case "poids":
            return ("Poids", 0x8B5CF6, "kg", DonneesSante.poids, 70, "DERNIÈRE MESURE",
                    "Le poids regroupe les mesures saisies manuellement ou envoyées par une balance connectée.")
        default:
            return ("Pas", 0xFF9F0A, "pas", DonneesSante.pas, 12000, "TOTAL",
                    "Le nombre de pas correspond au nombre de pas que vous faites au cours de la journée.")
        }
    }
    private var visibles: [JourMesure] {
        if genre == "poids" { return config.mesures }
        return periode == 0 ? Array(config.mesures.suffix(1)) : (periode == 1 ? Array(config.mesures.suffix(7)) : config.mesures)
    }
    private func libelle(_ v: Double) -> String {
        switch genre {
        case "coeur", "fcmarche", "etages": return "\(Int(v))"
        case "distance", "poids": return String(format: "%.1f", v).replacingOccurrences(of: ".", with: ",")
        case "energie": return "\(Int(v))"
        default:
            let f = NumberFormatter(); f.numberStyle = .decimal; f.groupingSeparator = " "
            return f.string(from: NSNumber(value: Int(v))) ?? "\(Int(v))"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if genre != "poids" {
                        SelecteurPeriodeSante(periode: $periode) { selection = nil }
                    }

                    // Valeur en tête (sélection ou dernier point)
                    let point = visibles.first(where: { $0.id == selection }) ?? visibles.last!
                    VStack(alignment: .leading, spacing: 2) {
                        Text(config.tete).font(.system(size: 11, weight: .semibold)).kerning(0.5).foregroundStyle(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(libelle(point.valeur)).font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                            Text(config.unite).font(.system(size: 14)).foregroundStyle(.secondary)
                        }
                        Text(point.date + " 2026").font(.system(size: 13)).foregroundStyle(.secondary)
                    }

                    // Graphique à barres (sélection au tap)
                    VStack(spacing: 8) {
                        HStack(alignment: .bottom, spacing: periode == 2 ? 3 : 16) {
                            ForEach(visibles) { m in
                                VStack(spacing: 5) {
                                    Capsule()
                                        .fill(Color(hex: config.teinte).opacity(selection == nil || selection == m.id ? 1 : 0.35))
                                        .frame(height: CGFloat(16 + (m.valeur / config.max) * 150))
                                    if periode != 2 || genre == "poids" {
                                        Text(m.jour.isEmpty ? String(m.date.prefix(6)) : m.jour)
                                            .font(.system(size: 9)).foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .onTapGesture { Haptique.leger(); selection = (selection == m.id ? nil : m.id) }
                            }
                        }
                        .frame(height: 200, alignment: .bottom)
                        if periode == 2 && genre != "poids" {
                            HStack {
                                Text(visibles.first?.date ?? "").font(.system(size: 10)).foregroundStyle(.secondary)
                                Spacer()
                                Text(visibles.last?.date ?? "").font(.system(size: 10)).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))

                    // Historique (poids : liste des pesées, fidèle « Afficher toutes les données »)
                    if genre == "poids" {
                        VStack(spacing: 0) {
                            ForEach(Array(config.mesures.reversed().enumerated()), id: \.offset) { i, m in
                                HStack {
                                    Text(m.date + " 2026").font(.system(size: 14)).foregroundStyle(.white)
                                    Spacer()
                                    Text(libelle(m.valeur) + " kg").font(.system(size: 14)).foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 11)
                                if i < config.mesures.count - 1 {
                                    Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                                }
                            }
                        }
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    }

                    // À propos (texte fidèle au ton de la vraie app)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("À propos").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                        Text(config.apropos).font(.system(size: 13)).foregroundStyle(.secondary)
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

// Sélecteur J / S / M partagé
struct SelecteurPeriodeSante: View {
    @Binding var periode: Int
    var auChangement: () -> Void = {}
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(["J", "S", "M"].enumerated()), id: \.offset) { i, p in
                Text(p).font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(periode == i ? .white : .secondary)
                    .padding(.vertical, 6).frame(maxWidth: .infinity)
                    .background(periode == i ? Color(hex: 0x3A3A3C) : .clear, in: RoundedRectangle(cornerRadius: 7))
                    .contentShape(Rectangle())
                    .onTapGesture { periode = i; auChangement() }
            }
        }
        .padding(3)
        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 9))
    }
}

// ============================================================ FICHE SOMMEIL (phases de la nuit + historique)
struct FicheSommeilVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var periode = 0   // 0 J (nuit dernière), 1 S, 2 M
    @State private var selection: UUID? = nil

    private var totalMinutes: Int { DonneesSante.phasesNuit.filter { $0.nom != "Éveil" }.reduce(0) { $0 + $1.minutes } }
    private func duree(_ mn: Int) -> String { "\(mn / 60) h \(String(format: "%02d", mn % 60))" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SelecteurPeriodeSante(periode: $periode) { selection = nil }

                    if periode == 0 {
                        // NUIT DERNIÈRE : durée, horaires, phases
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DURÉE DE SOMMEIL").font(.system(size: 11, weight: .semibold)).kerning(0.5).foregroundStyle(.secondary)
                            Text(duree(totalMinutes)).font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                            Text("16–17 août 2026 · Couchée \(DonneesSante.coucher) – Levée \(DonneesSante.lever)")
                                .font(.system(size: 13)).foregroundStyle(.secondary)
                        }

                        // Bande des phases (proportions réelles)
                        VStack(alignment: .leading, spacing: 12) {
                            GeometryReader { geo in
                                HStack(spacing: 2) {
                                    ForEach(Array(DonneesSante.phasesNuit.enumerated()), id: \.offset) { _, ph in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color(hex: ph.teinte))
                                            .frame(width: geo.size.width * CGFloat(ph.minutes) / CGFloat(DonneesSante.phasesNuit.reduce(0) { $0 + $1.minutes }) - 2)
                                    }
                                }
                            }
                            .frame(height: 54)
                            VStack(spacing: 0) {
                                ForEach(Array(DonneesSante.phasesNuit.enumerated()), id: \.offset) { i, ph in
                                    HStack(spacing: 10) {
                                        Circle().fill(Color(hex: ph.teinte)).frame(width: 10, height: 10)
                                        Text(ph.nom).font(.system(size: 14.5)).foregroundStyle(.white)
                                        Spacer()
                                        Text(duree(ph.minutes)).font(.system(size: 14)).foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 9)
                                    if i < DonneesSante.phasesNuit.count - 1 {
                                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 20)
                                    }
                                }
                            }
                        }
                        .padding(14)
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    } else {
                        // HISTORIQUE S / M
                        let visibles = periode == 1 ? Array(DonneesSante.sommeil.suffix(7)) : DonneesSante.sommeil
                        let point = visibles.first(where: { $0.id == selection }) ?? visibles.last!
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DURÉE DE SOMMEIL").font(.system(size: 11, weight: .semibold)).kerning(0.5).foregroundStyle(.secondary)
                            let h = Int(point.valeur); let mn = Int((point.valeur - Double(h)) * 60)
                            Text("\(h) h \(String(format: "%02d", mn))").font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                            Text(point.date + " 2026").font(.system(size: 13)).foregroundStyle(.secondary)
                        }
                        VStack(spacing: 8) {
                            HStack(alignment: .bottom, spacing: periode == 2 ? 3 : 16) {
                                ForEach(visibles) { m in
                                    VStack(spacing: 5) {
                                        Capsule()
                                            .fill(Color(hex: 0x5AC8FA).opacity(selection == nil || selection == m.id ? 1 : 0.35))
                                            .frame(height: CGFloat(16 + (m.valeur / 9) * 150))
                                        if periode != 2 {
                                            Text(m.jour).font(.system(size: 10)).foregroundStyle(.secondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture { Haptique.leger(); selection = (selection == m.id ? nil : m.id) }
                                }
                            }
                            .frame(height: 200, alignment: .bottom)
                            if periode == 2 {
                                HStack {
                                    Text(visibles.first?.date ?? "").font(.system(size: 10)).foregroundStyle(.secondary)
                                    Spacer()
                                    Text(visibles.last?.date ?? "").font(.system(size: 10)).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("À propos").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                        Text("Le suivi du sommeil vous aide à connaître le temps que vous passez endormie, ainsi que la répartition entre les phases de sommeil léger, profond et paradoxal.")
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Sommeil")
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

// ============================================================ TENDANCES (liste complète)
struct TendancesSanteVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fiche: String? = nil

    private let tendances: [(id: String, symbole: String, teinte: UInt, titre: String, sens: String, texte: String)] = [
        ("sommeil", "bed.double.fill", 0x5AC8FA, "Sommeil", "arrow.down.right", "6 h 12 par nuit en moyenne, contre 6 h 54 le mois dernier."),
        ("coeur", "heart.fill", 0xFA5252, "FC au repos", "arrow.up.right", "67 BPM en moyenne, contre 63 BPM le mois dernier."),
        ("audition", "ear", 0x0A84FF, "Niveaux du casque", "arrow.up.right", "73 dB en moyenne, écoute plus longue en soirée."),
        ("pas", "figure.walk", 0xFF9F0A, "Pas", "arrow.right", "6 800 pas par jour en moyenne, stable."),
        ("energie", "flame.fill", 0xFF9F0A, "Énergie active", "arrow.right", "368 kcal par jour en moyenne, stable."),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Vos tendances comparent vos 28 derniers jours à vos moyennes précédentes.")
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                    VStack(spacing: 0) {
                        ForEach(Array(tendances.enumerated()), id: \.offset) { i, t in
                            HStack(spacing: 12) {
                                Image(systemName: t.symbole).font(.system(size: 16)).foregroundStyle(Color(hex: t.teinte)).frame(width: 26)
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 5) {
                                        Text(t.titre).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                                        Image(systemName: t.sens).font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(t.sens == "arrow.right" ? Color.secondary : Color(hex: t.teinte))
                                    }
                                    Text(t.texte).font(.system(size: 12.5)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 11)
                            .contentShape(Rectangle())
                            .onTapGesture { fiche = t.id }
                            if i < tendances.count - 1 {
                                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 52)
                            }
                        }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Tendances")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            .sheet(isPresented: Binding(get: { fiche != nil }, set: { if !$0 { fiche = nil } })) {
                FicheRoutageSante(genre: fiche ?? "pas")
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ RECHERCHE (loupe — D62 : la loupe agit)
struct RechercheSanteVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var texte = ""
    @State private var fiche: String? = nil

    private var resultats: [MetriqueSante] {
        texte.isEmpty ? CatalogueSante.toutes
        : CatalogueSante.toutes.filter { $0.titre.lowercased().contains(texte.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Rechercher", text: $texte).foregroundStyle(.white)
                        if !texte.isEmpty {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                                .onTapGesture { texte = "" }
                        }
                    }
                    .padding(.horizontal, 12).frame(height: 38)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 11))

                    if resultats.isEmpty {
                        VStack(spacing: 8) {
                            Text("Aucun résultat").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                            Text("Aucune donnée santé ne correspond à « \(texte) ».")
                                .font(.system(size: 13)).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity).padding(.top, 80)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(resultats.enumerated()), id: \.offset) { i, m in
                                HStack(spacing: 12) {
                                    Image(systemName: m.symbole).font(.system(size: 16)).foregroundStyle(Color(hex: m.teinte)).frame(width: 26)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(m.titre).font(.system(size: 15)).foregroundStyle(.white)
                                        Text("\(m.valeur) · \(m.date)").font(.system(size: 12.5)).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 11)
                                .contentShape(Rectangle())
                                .onTapGesture { fiche = m.id }
                                if i < resultats.count - 1 {
                                    Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 52)
                                }
                            }
                        }
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Recherche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            .sheet(isPresented: Binding(get: { fiche != nil }, set: { if !$0 { fiche = nil } })) {
                FicheRoutageSante(genre: fiche ?? "pas")
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ PARCOURIR
struct ParcourirSanteVue: View {
    @State private var categorie: String? = nil
    @State private var categorieVide: String? = nil
    @State private var rechercheVisible = false

    private let categories: [(String, String, UInt, Bool)] = [
        ("Activité", "flame.fill", 0xFF9F0A, true),
        ("Alimentation", "carrot.fill", 0x30D158, false),
        ("Audition", "ear", 0x0A84FF, true),
        ("Cœur", "heart.fill", 0xFA5252, true),
        ("Cycle menstruel", "drop.fill", 0xE84D8A, false),
        ("Mesures corporelles", "figure", 0x8B5CF6, true),
        ("Pleine conscience", "brain.head.profile", 0x30D1C4, false),
        ("Respiratoire", "lungs.fill", 0x5AC8FA, false),
        ("Sommeil", "bed.double.fill", 0x5AC8FA, true),
        ("Vitaux", "waveform.path.ecg", 0xFF3B30, true),
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
                .contentShape(Rectangle())
                .onTapGesture { rechercheVisible = true }

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
                            if c.3 { categorie = c.0 } else { categorieVide = c.0 }
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
        .sheet(isPresented: Binding(get: { categorie != nil }, set: { if !$0 { categorie = nil } })) {
            CategorieSanteVue(nom: categorie ?? "Activité")
        }
        .sheet(isPresented: Binding(get: { categorieVide != nil }, set: { if !$0 { categorieVide = nil } })) {
            CategorieVideSanteVue(nom: categorieVide ?? "")
        }
        .sheet(isPresented: $rechercheVisible) { RechercheSanteVue() }
    }
}

// Catégorie AVEC données : liste des métriques de la catégorie -> fiches
struct CategorieSanteVue: View {
    @Environment(\.dismiss) private var dismiss
    let nom: String
    @State private var fiche: String? = nil

    private var metriques: [MetriqueSante] {
        switch nom {
        case "Activité": return ["pas", "distance", "etages", "energie"].map(CatalogueSante.metrique)
        case "Cœur": return ["coeur", "fcmarche"].map(CatalogueSante.metrique)
        case "Vitaux": return ["coeur", "fcmarche"].map(CatalogueSante.metrique)
        case "Audition": return ["audition"].map(CatalogueSante.metrique)
        case "Mesures corporelles": return ["poids"].map(CatalogueSante.metrique)
        default: return ["sommeil"].map(CatalogueSante.metrique)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(spacing: 0) {
                        ForEach(Array(metriques.enumerated()), id: \.offset) { i, m in
                            HStack(spacing: 12) {
                                Image(systemName: m.symbole).font(.system(size: 16)).foregroundStyle(Color(hex: m.teinte)).frame(width: 26)
                                Text(m.titre).font(.system(size: 15)).foregroundStyle(.white)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text(m.valeur).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                    Text(m.date).font(.system(size: 11)).foregroundStyle(.secondary)
                                }
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .contentShape(Rectangle())
                            .onTapGesture { fiche = m.id }
                            if i < metriques.count - 1 {
                                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 52)
                            }
                        }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle(nom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            .sheet(isPresented: Binding(get: { fiche != nil }, set: { if !$0 { fiche = nil } })) {
                FicheRoutageSante(genre: fiche ?? "pas")
            }
        }
        .preferredColorScheme(.dark)
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
    @State private var ficheMedicale = false
    @State private var contactUrgence = false
    @State private var historique = false

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
                        .contentShape(Rectangle())
                        .onTapGesture { ficheMedicale = true }
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Image(systemName: "phone.fill").font(.system(size: 15)).foregroundStyle(Color(hex: 0xFA5252))
                            Text("Contact d'urgence").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Text("Maman").font(.system(size: 14)).foregroundStyle(.secondary)
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .contentShape(Rectangle())
                        .onTapGesture { contactUrgence = true }
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14)
                        HStack {
                            Image(systemName: "list.bullet.clipboard.fill").font(.system(size: 15)).foregroundStyle(Color(hex: 0x0A84FF))
                            Text("Historique de santé").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .contentShape(Rectangle())
                        .onTapGesture { historique = true }
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
            .sheet(isPresented: $ficheMedicale) { FicheMedicaleVue() }
            .sheet(isPresented: $contactUrgence) { ContactUrgenceSanteVue() }
            .sheet(isPresented: $historique) { HistoriqueSanteVue() }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
    }
}

// Fiche médicale (fidèle à l'écran d'urgence iOS)
struct FicheMedicaleVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 0) {
                        LigneInfoFichier(cle: "Conditions médicales", valeur: "Aucune")
                        LigneInfoFichier(cle: "Allergies et réactions", valeur: "Pollen (graminées)")
                        LigneInfoFichier(cle: "Médicaments", valeur: "Aucun")
                        LigneInfoFichier(cle: "Groupe sanguin", valeur: "A+")
                        LigneInfoFichier(cle: "Donneuse d'organes", valeur: "Oui", derniere: true)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))
                    Text("Ces informations sont visibles sur l'écran verrouillé en cas d'urgence.")
                        .font(.system(size: 12.5)).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Fiche médicale")
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

// Contact d'urgence (bouton Appeler réel — D62, routé vers Téléphone)
struct ContactUrgenceSanteVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    Circle().fill(Color(hex: 0xE8A0A0)).frame(width: 72, height: 72)
                        .overlay(Text("👩").font(.system(size: 34)))
                        .padding(.top, 8)
                    Text("Maman").font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)
                    Text("Relation : mère").font(.system(size: 13)).foregroundStyle(.secondary)

                    VStack(spacing: 0) {
                        LigneInfoFichier(cle: "Téléphone", valeur: "06 51 28 74 93", derniere: true)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))

                    Text("Appeler")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(Color(hex: 0x30D158), in: RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismiss()
                            Routeur.partage.allerTelephone("06 51 28 74 93")
                        }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Contact d'urgence")
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

// Historique de santé (vaccinations, antécédents — statique crédible, D56 anneau 2)
struct HistoriqueSanteVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Vaccinations").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary)
                    VStack(spacing: 0) {
                        LigneInfoFichier(cle: "COVID-19", valeur: "3 doses · 2023")
                        LigneInfoFichier(cle: "DTP (rappel)", valeur: "Juin 2021", derniere: true)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))

                    Text("Antécédents").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary)
                    VStack(spacing: 0) {
                        LigneInfoFichier(cle: "Entorse cheville droite", valeur: "2024 · kinésithérapie", derniere: true)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))

                    Text("Les documents ajoutés par vos apps de santé apparaîtront ici.")
                        .font(.system(size: 12.5)).foregroundStyle(.secondary)
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Historique de santé")
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
