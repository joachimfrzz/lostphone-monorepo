// Calendrier — construit contre la vidéo de référence du 19/08 (27 écrans + 2 captures, iOS 26)
// D59 : données remplaçables. Présent du jeu : lundi 17 août 2026 (pastille rouge sur le 17).
// R3 : RDV Banque 11:30 le 17, kiné les jeudis 17:30, brunch des filles le samedi 22 (groupe WhatsApp),
// anniversaire de Maman le 14 février (= P01-P05), et « MARC ARRIVE ⚓️ » le vendredi 28 août.
// D51 : vue mois/année/jour réelles, création d'événement fonctionnelle, recherche réelle.
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct Evenement: Identifiable {
    let id = UUID()
    var titre: String
    var annee: Int
    var mois: Int
    var jour: Int
    var heure: Int?          // nil = journée entière
    var minute: Int = 0
    var duree: Int = 60      // minutes
    var couleur: UInt        // 0xE8873D rappel orange, 0x30D158 férié vert, 0x0A84FF perso bleu, 0xE84D6B rose
    var lieu: String? = nil
}

final class MagasinCalendrier: ObservableObject {
    static let partage = MagasinCalendrier()
    @Published var evenements: [Evenement] = {
        var evts: [Evenement] = [
            // — Le cœur (août 2026)
            Evenement(titre: "Banque — plafond", annee: 2026, mois: 8, jour: 17, heure: 11, minute: 30,
                      couleur: 0xE84D6B, lieu: "LCL Agence Bellecour"),
            Evenement(titre: "Brunch les filles", annee: 2026, mois: 8, jour: 22, heure: 13,
                      couleur: 0x0A84FF, lieu: "Place Sathonay"),
            Evenement(titre: "MARC ARRIVE ⚓️", annee: 2026, mois: 8, jour: 28, heure: nil,
                      couleur: 0xE84D6B, lieu: "Marseille — port"),
            Evenement(titre: "L'Assomption", annee: 2026, mois: 8, jour: 15, heure: nil, couleur: 0x30D158),
            // — Les anniversaires (R3 avec la pellicule)
            Evenement(titre: "Anniv Maman 🎂", annee: 2026, mois: 2, jour: 14, heure: nil, couleur: 0xE84D6B),
            Evenement(titre: "Anniv Chloé", annee: 2026, mois: 4, jour: 3, heure: nil, couleur: 0x0A84FF),
            // — La vie qui continue
            Evenement(titre: "Révision voiture", annee: 2026, mois: 9, jour: 8, heure: 9,
                      couleur: 0x0A84FF, lieu: "Garage Perret"),
            Evenement(titre: "Dr Pasquier", annee: 2026, mois: 10, jour: 9, heure: 14, minute: 30,
                      couleur: 0x0A84FF, lieu: "Cabinet médical"),
            Evenement(titre: "La Toussaint", annee: 2026, mois: 11, jour: 1, heure: nil, couleur: 0x30D158),
            // — Fériés utiles
            Evenement(titre: "Fête nationale", annee: 2026, mois: 7, jour: 14, heure: nil, couleur: 0x30D158),
        ]
        // Kiné : tous les jeudis 17:30 du 2 juillet au 24 septembre 2026 (raccord Marie kiné)
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        var d = DateComponents(year: 2026, month: 7, day: 2)
        while let date = cal.date(from: d),
              let fin = cal.date(from: DateComponents(year: 2026, month: 9, day: 24)),
              date <= fin {
            let c = cal.dateComponents([.year, .month, .day], from: date)
            evts.append(Evenement(titre: "Kiné", annee: c.year!, mois: c.month!, jour: c.day!,
                                  heure: 17, minute: 30, duree: 45, couleur: 0xE8873D,
                                  lieu: "12 rue des Fantasques"))
            d.day! += 7
        }
        return evts
    }()

    func pour(_ a: Int, _ m: Int, _ j: Int) -> [Evenement] {
        evenements.filter { $0.annee == a && $0.mois == m && $0.jour == j }
            .sorted { ($0.heure ?? -1) < ($1.heure ?? -1) }
    }
}

// Le présent du jeu
let jeuAnnee = 2026, jeuMois = 8, jeuJour = 17

// ============================================================ APP
struct CalendrierVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vueAnnee = false
    @State private var creation = false
    @State private var rechercheVisible = false
    @State private var jourOuvert: (Int, Int, Int)? = nil

    // Période couverte : février 2025 → décembre 2026
    private let moisListe: [(Int, Int)] = {
        var l: [(Int, Int)] = []
        for m in 2...12 { l.append((2025, m)) }
        for m in 1...12 { l.append((2026, m)) }
        return l
    }()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()
                if vueAnnee {
                    AnneeVue(vueAnnee: $vueAnnee)
                } else {
                    ScrollViewReader { defileur in
                        ScrollView {
                            // Miroir run 1 : réserve sous les pilules de la toolbar (Août + L M M J V S D étaient masqués)
                            LazyVStack(alignment: .leading, spacing: 26) {
                                ForEach(0..<moisListe.count, id: \.self) { i in
                                    let a = moisListe[i].0
                                    let m = moisListe[i].1
                                    MoisVue(annee: a, mois: m) { j in jourOuvert = (a, m, j) }
                                        .id("\(a)-\(m)")
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                        .contentMargins(.top, 48, for: .scrollContent)
                        .onAppear { defileur.scrollTo("2026-8", anchor: .top) }
                    }
                }

                HStack {
                    Button {
                        vueAnnee = false
                    } label: {
                        Text("Aujourd'hui").font(.system(size: 15)).foregroundStyle(.white)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(Color(hex: 0x1C1C1E), in: Capsule())
                    }
                    Spacer()
                    HStack(spacing: 14) {
                        Image(systemName: "exclamationmark.circle").font(.system(size: 18))
                        Image(systemName: "tray").font(.system(size: 17))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(Color(hex: 0x1C1C1E), in: Capsule())
                }
                .padding(.horizontal, 14).padding(.bottom, 6)

            BarreHome { dismiss() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vueAnnee.toggle()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left").font(.system(size: 15, weight: .semibold))
                            Text(vueAnnee ? "Août" : "2026").font(.system(size: 16))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color(hex: 0x1C1C1E), in: Capsule())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Image(systemName: "square.stack").font(.system(size: 16))
                        Image(systemName: "magnifyingglass").font(.system(size: 16))
                            .onTapGesture { rechercheVisible = true }
                        Image(systemName: "plus").font(.system(size: 17))
                            .onTapGesture { creation = true }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color(hex: 0x1C1C1E), in: Capsule())
                }
            }
            .sheet(isPresented: $creation) { NouvelEvenementVue() }
            .sheet(isPresented: $rechercheVisible) { RechercheCalendrierVue() }
            .sheet(isPresented: Binding(get: { jourOuvert != nil }, set: { if !$0 { jourOuvert = nil } })) {
                if let (a, m, j) = jourOuvert {
                    JourVue(annee: a, mois: m, jour: j)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ VUE MOIS
let nomsMois = ["", "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
                "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]

struct MoisVue: View {
    let annee: Int
    let mois: Int
    let ouvrir: (Int) -> Void
    @ObservedObject private var magasin = MagasinCalendrier.partage

    private var grille: [[Int?]] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        guard let debut = cal.date(from: DateComponents(year: annee, month: mois, day: 1)),
              let nb = cal.range(of: .day, in: .month, for: debut)?.count else { return [] }
        let decalage = (cal.component(.weekday, from: debut) - cal.firstWeekday + 7) % 7
        var jours: [Int?] = Array(repeating: nil, count: decalage) + (1...nb).map { $0 }
        while jours.count % 7 != 0 { jours.append(nil) }
        return stride(from: 0, to: jours.count, by: 7).map { Array(jours[$0..<$0+7]) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(nomsMois[mois] + (annee == 2026 ? "" : " \(annee)"))
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(annee == jeuAnnee && mois == jeuMois ? Color(hex: 0xFF453A) : .white)
            HStack {
                ForEach(Array(["L", "M", "M", "J", "V", "S", "D"].enumerated()), id: \.offset) { idx, j in
                    Text(j).font(.system(size: 11)).foregroundStyle(.secondary)
                        .opacity(idx >= 5 ? 0.45 : 1)
                        .frame(maxWidth: .infinity)
                }
            }
            ForEach(0..<grille.count, id: \.self) { s in
                Divider().overlay(Color(hex: 0x2C2C2E))
                HStack(alignment: .top, spacing: 2) {
                    ForEach(0..<7, id: \.self) { c in
                        if let j = grille[s][c] {
                            let evts = magasin.pour(annee, mois, j)
                            let estPresent = annee == jeuAnnee && mois == jeuMois && j == jeuJour
                            VStack(spacing: 3) {
                                Text("\(j)")
                                    .font(.system(size: 16, weight: estPresent ? .bold : .regular))
                                    .foregroundStyle(estPresent ? .white : (c >= 5 ? .secondary : .white))
                                    .frame(width: 30, height: 30)
                                    .background(estPresent ? Color(hex: 0xFF453A) : .clear, in: Circle())
                                ForEach(evts.prefix(3)) { e in
                                    HStack(spacing: 2) {
                                        Circle().strokeBorder(Color(hex: e.couleur), lineWidth: 2)
                                            .frame(width: 7, height: 7)
                                        Text(e.titre).font(.system(size: 8.5))
                                            .foregroundStyle(.white.opacity(0.85))
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 3).padding(.vertical, 2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(hex: 0x2C2C2E).opacity(0.8), in: RoundedRectangle(cornerRadius: 4))
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 74, alignment: .top)
                            .contentShape(Rectangle())
                            .onTapGesture { ouvrir(j) }
                        } else {
                            Color.clear.frame(maxWidth: .infinity, minHeight: 74)
                        }
                    }
                }
            }
        }
    }
}

// ============================================================ VUE ANNÉE
struct AnneeVue: View {
    @Binding var vueAnnee: Bool
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("2026").font(.system(size: 34, weight: .bold)).foregroundStyle(Color(hex: 0xFF453A))
                Divider().overlay(Color(hex: 0x2C2C2E))
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 3), spacing: 24) {
                    ForEach(1...12, id: \.self) { m in
                        MiniMois(annee: 2026, mois: m)
                            .contentShape(Rectangle())
                            .onTapGesture { vueAnnee = false }
                    }
                }
            }
            .padding(16)
        }
    }
}

struct MiniMois: View {
    let annee: Int
    let mois: Int
    private var jours: [[Int?]] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        guard let debut = cal.date(from: DateComponents(year: annee, month: mois, day: 1)),
              let nb = cal.range(of: .day, in: .month, for: debut)?.count else { return [] }
        let dec = (cal.component(.weekday, from: debut) - cal.firstWeekday + 7) % 7
        var l: [Int?] = Array(repeating: nil, count: dec) + (1...nb).map { $0 }
        while l.count % 7 != 0 { l.append(nil) }
        return stride(from: 0, to: l.count, by: 7).map { Array(l[$0..<$0+7]) }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(nomsMois[mois]).font(.system(size: 15, weight: .semibold))
                .foregroundStyle(mois == jeuMois ? Color(hex: 0xFF453A) : .white)
            ForEach(0..<jours.count, id: \.self) { s in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { c in
                        if let j = jours[s][c] {
                            Text("\(j)").font(.system(size: 8.5))
                                .foregroundStyle(mois == jeuMois && j == jeuJour ? .white : .white.opacity(0.9))
                                .frame(maxWidth: .infinity, minHeight: 12)
                                .background(mois == jeuMois && j == jeuJour ? Color(hex: 0xFF453A) : .clear, in: Circle())
                        } else {
                            Color.clear.frame(maxWidth: .infinity, minHeight: 12)
                        }
                    }
                }
            }
        }
    }
}

// ============================================================ VUE JOUR
struct JourVue: View {
    @Environment(\.dismiss) private var dismiss
    let annee: Int
    let mois: Int
    let jour: Int
    @ObservedObject private var magasin = MagasinCalendrier.partage

    private var nomJour: String {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        guard let d = cal.date(from: DateComponents(year: annee, month: mois, day: jour)) else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "EEEE - d MMMM yyyy"
        return f.string(from: d).capitalized
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { defileur in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Journée entière
                        ForEach(magasin.pour(annee, mois, jour).filter { $0.heure == nil }) { e in
                            HStack(spacing: 8) {
                                Text("Jour entier").font(.system(size: 11)).foregroundStyle(.secondary)
                                    .frame(width: 52, alignment: .trailing)
                                Text(e.titre).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(Color(hex: e.couleur).opacity(0.35), in: Capsule())
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        ForEach(0..<24, id: \.self) { h in
                            HStack(alignment: .top, spacing: 8) {
                                Text(String(format: "%02d:00", h))
                                    .font(.system(size: 11)).foregroundStyle(.secondary)
                                    .frame(width: 52, alignment: .trailing)
                                VStack(alignment: .leading, spacing: 4) {
                                    Divider().overlay(Color(hex: 0x2C2C2E))
                                    ForEach(magasin.pour(annee, mois, jour).filter { $0.heure == h }) { e in
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(e.titre).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                            HStack(spacing: 6) {
                                                Text(String(format: "%02d:%02d – %02d:%02d", h, e.minute,
                                                            (h * 60 + e.minute + e.duree) / 60, (e.minute + e.duree) % 60))
                                                if let l = e.lieu { Text("· " + l) }
                                            }
                                            .font(.system(size: 11.5)).foregroundStyle(.white.opacity(0.75))
                                        }
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(hex: e.couleur).opacity(0.32), in: RoundedRectangle(cornerRadius: 8))
                                        .overlay(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2).fill(Color(hex: e.couleur)).frame(width: 3)
                                        }
                                    }
                                }
                            }
                            .frame(minHeight: 44, alignment: .top)
                            .id(h)
                        }
                    }
                    .padding(.horizontal, 14).padding(.top, 8)
                }
                .onAppear { defileur.scrollTo(8, anchor: .top) }
            }
            .background(Color.black)
            .navigationTitle(nomJour)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0xFF453A))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ CRÉATION (fonctionnelle — D51)
struct NouvelEvenementVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinCalendrier.partage
    @State private var titre = ""
    @State private var lieu = ""
    @State private var jour = jeuJour
    @State private var mois = jeuMois
    @State private var heure = 12
    @State private var minute = 0
    @State private var journeeEntiere = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Titre", text: $titre).foregroundStyle(.white)
                        .listRowBackground(Color(hex: 0x2C2C2E))
                    TextField("Lieu ou visio", text: $lieu).foregroundStyle(.white)
                        .listRowBackground(Color(hex: 0x2C2C2E))
                }
                Section {
                    HStack {
                        Text("Jour entier").foregroundStyle(.white)
                        Spacer()
                        Toggle("", isOn: $journeeEntiere).labelsHidden().tint(Color(hex: 0x32D74B))
                    }
                    .listRowBackground(Color(hex: 0x2C2C2E))
                    HStack {
                        Text("Date").foregroundStyle(.white)
                        Spacer()
                        Picker("", selection: $jour) { ForEach(1...31, id: \.self) { Text("\($0)").tag($0) } }
                            .pickerStyle(.menu).tint(.secondary)
                        Picker("", selection: $mois) { ForEach(1...12, id: \.self) { Text(nomsMois[$0]).tag($0) } }
                            .pickerStyle(.menu).tint(.secondary)
                    }
                    .listRowBackground(Color(hex: 0x2C2C2E))
                    if !journeeEntiere {
                        HStack {
                            Text("Heure").foregroundStyle(.white)
                            Spacer()
                            Picker("", selection: $heure) { ForEach(0..<24, id: \.self) { Text(String(format: "%02d", $0)).tag($0) } }
                                .pickerStyle(.menu).tint(.secondary)
                            Text(":").foregroundStyle(.secondary)
                            Picker("", selection: $minute) { ForEach([0, 15, 30, 45], id: \.self) { Text(String(format: "%02d", $0)).tag($0) } }
                                .pickerStyle(.menu).tint(.secondary)
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0x1C1C1E))
            .navigationTitle("Nouvel événement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }.foregroundStyle(Color(hex: 0xFF453A))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ajouter") {
                        let t = titre.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        magasin.evenements.append(
                            Evenement(titre: t, annee: 2026, mois: mois, jour: jour,
                                      heure: journeeEntiere ? nil : heure, minute: minute,
                                      couleur: 0x0A84FF, lieu: lieu.isEmpty ? nil : lieu))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(titre.isEmpty ? Color(hex: 0x5A5A5E) : Color(hex: 0xFF453A))
                    .disabled(titre.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ RECHERCHE
struct RechercheCalendrierVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinCalendrier.partage
    @State private var recherche = ""

    private var resultats: [Evenement] {
        guard !recherche.isEmpty else { return [] }
        return magasin.evenements
            .filter { $0.titre.localizedCaseInsensitiveContains(recherche) || ($0.lieu ?? "").localizedCaseInsensitiveContains(recherche) }
            .sorted { ($0.annee, $0.mois, $0.jour) < ($1.annee, $1.mois, $1.jour) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(resultats) { e in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(hex: e.couleur)).frame(width: 9, height: 9)
                            Text(e.titre).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        }
                        Text("\(e.jour) \(nomsMois[e.mois].lowercased()) \(e.annee)" +
                             (e.heure != nil ? String(format: " · %02d:%02d", e.heure!, e.minute) : "") +
                             (e.lieu != nil ? " · \(e.lieu!)" : ""))
                            .font(.system(size: 12.5)).foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color(hex: 0x2C2C2E))
                }
                if !recherche.isEmpty && resultats.isEmpty {
                    Text("Aucun résultat").foregroundStyle(.secondary)
                        .listRowBackground(Color(hex: 0x1C1C1E))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0x1C1C1E))
            .searchable(text: $recherche, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher")
            .navigationTitle("Recherche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0xFF453A))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
