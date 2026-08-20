// Horloge — construite contre la vidéo de référence du 18/08 (40 écrans, iOS 26)
// D59 : contenu = données remplaçables ; D51 : utilisable de A à Z (alarmes créables/éditables,
// chrono et minuteurs réellement fonctionnels).
import SwiftUI
import AVFoundation

// ============================================================ DONNÉES (remplaçables — D59)
struct Alarme: Identifiable {
    let id = UUID()
    var heure: Int      // minutes depuis minuit
    var libelle: String
    var recurrence: String
    var active: Bool
    var hh: String { String(format: "%d:%02d", heure / 60, heure % 60) }
}

final class MagasinHorloge: ObservableObject {
    static let partage = MagasinHorloge()
    @Published var alarmes: [Alarme] = [
        Alarme(heure: 6 * 60 + 45, libelle: "Réveil", recurrence: "En semaine", active: false),
        Alarme(heure: 8 * 60 + 30, libelle: "Kiné — exercices épaule", recurrence: "Chaque jour", active: true),
        Alarme(heure: 11 * 60, libelle: "Brunch les filles", recurrence: "Chaque samedi", active: false),
        Alarme(heure: 11 * 60 + 15, libelle: "Banque !!", recurrence: "Jamais", active: true),
        Alarme(heure: 21 * 60 + 30, libelle: "Appel Marc 🌙", recurrence: "Chaque jour", active: true),
    ]
    @Published var minuteursRecents: [Int] = [60, 600, 1200, 660] // secondes
}

// ============================================================ APP
struct HorlogeVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = 1 // ouvre sur Alarmes (le plus parlant)

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $onglet) {
                HorlogesMondeVue().tabItem { Label("Horloges", systemImage: "globe") }.tag(0)
                AlarmesVue().tabItem { Label("Alarmes", systemImage: "alarm.fill") }.tag(1)
                ChronometreVue().tabItem { Label("Chronomètre", systemImage: "stopwatch.fill") }.tag(2)
                MinuteursVue().tabItem { Label("Minuteurs", systemImage: "timer") }.tag(3)
            }
            .tint(.orange)
            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ HORLOGES (monde)
struct HorlogesMondeVue: View {
    @State private var edition = false
    @State private var ajout = false
    var body: some View {
        NavigationStack {
            List {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Aujourd'hui, +0 h").font(.system(size: 14)).foregroundStyle(.secondary)
                        Text("Paris").font(.system(size: 25)).foregroundStyle(.white)
                    }
                    Spacer()
                    TimelineView(.periodic(from: .now, by: 1)) { ctx in
                        Text(ctx.date, format: .dateTime.hour().minute())
                            .font(.system(size: 52, weight: .light)).foregroundStyle(.white)
                    }
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.black)
                .listRowSeparatorTint(Color(hex: 0x2C2C2E))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Horloges")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(edition ? "OK" : "Modifier") { edition.toggle() }.foregroundStyle(.orange)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { ajout = true } label: { Image(systemName: "plus").foregroundStyle(.orange) }
                }
            }
            .sheet(isPresented: $ajout) { VilleRechercheVue() }
        }
    }
}

struct VilleRechercheVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recherche = ""
    private let villes = ["Abidjan, Côte d'Ivoire", "Abou Dabi, É.A.U.", "Accra, Ghana", "Adélaïde, Australie",
                          "Alger, Algérie", "Amsterdam, Pays-Bas", "Anchorage, É.-U.", "Athènes, Grèce",
                          "Bangkok, Thaïlande", "Barcelone, Espagne", "Berlin, Allemagne", "Bogota, Colombie",
                          "Brasilia, Brésil", "Bruxelles, Belgique", "Casablanca, Maroc", "Chicago, É.-U.",
                          "Dakar, Sénégal", "Denver, É.-U.", "Djakarta, Indonésie", "Dubaï, É.A.U.",
                          "Dublin, Irlande", "Genève, Suisse", "Hanoï, Vietnam", "Helsinki, Finlande",
                          "Hong Kong, Chine", "Honolulu, É.-U.", "Istanbul, Turquie", "Lagos, Nigéria",
                          "Le Caire, Égypte", "Lima, Pérou", "Lisbonne, Portugal", "Londres, Royaume-Uni",
                          "Los Angeles, É.-U.", "Madrid, Espagne", "Marseille, France", "Melbourne, Australie",
                          "Mexico, Mexique", "Montréal, Canada", "Moscou, Russie", "New York, É.-U.",
                          "Oslo, Norvège", "Paris, France", "Pékin, Chine", "Rome, Italie", "Séoul, Corée du Sud",
                          "Singapour", "Stockholm, Suède", "Sydney, Australie", "Tokyo, Japon", "Toronto, Canada"]
    private var resultats: [String] {
        recherche.isEmpty ? villes : villes.filter { $0.localizedCaseInsensitiveContains(recherche) }
    }
    var body: some View {
        NavigationStack {
            List(resultats, id: \.self) { v in
                Text(v).foregroundStyle(.white)
                    .listRowBackground(Color(hex: 0x1C1C1E))
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0x1C1C1E))
            .searchable(text: $recherche, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher")
            .navigationTitle("Choisir une ville")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Annuler") { dismiss() }.foregroundStyle(.orange)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ ALARMES
struct AlarmesVue: View {
    @ObservedObject private var magasin = MagasinHorloge.partage
    @State private var edition = false
    @State private var alarmeEditee: Alarme? = nil
    @State private var nouvelle = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Aucune alarme").font(.system(size: 16)).foregroundStyle(.secondary)
                        Spacer()
                        Text("CONFIGURER").font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color(hex: 0x2C2C2E), in: Capsule())
                    }
                    .listRowBackground(Color.black)
                } header: {
                    HStack(spacing: 6) {
                        Image(systemName: "bed.double.fill")
                        Text("Sommeil | Réveil")
                    }
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    .textCase(nil)
                }

                Section {
                    ForEach($magasin.alarmes) { $a in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(a.hh)
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundStyle(a.active ? .white : .secondary)
                                Text(a.libelle + (a.recurrence == "Jamais" ? "" : ", " + a.recurrence.lowercased()))
                                    .font(.system(size: 14))
                                    .foregroundStyle(a.active ? .white.opacity(0.8) : .secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $a.active).labelsHidden().tint(Color(hex: 0x32D74B))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { alarmeEditee = a }
                        .listRowBackground(Color.black)
                        .listRowSeparatorTint(Color(hex: 0x2C2C2E))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                magasin.alarmes.removeAll { $0.id == a.id }
                            } label: { Label("Supprimer", systemImage: "trash.fill") }
                        }
                    }
                } header: {
                    Text("Autres").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).textCase(nil)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Alarmes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(edition ? "OK" : "Modifier") { edition.toggle() }.foregroundStyle(.orange)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { nouvelle = true } label: { Image(systemName: "plus").foregroundStyle(.orange) }
                }
            }
            .sheet(item: $alarmeEditee) { a in AlarmeEditionVue(alarme: a, creation: false) }
            .sheet(isPresented: $nouvelle) {
                AlarmeEditionVue(alarme: Alarme(heure: 13 * 60, libelle: "Alarme", recurrence: "Jamais", active: true),
                                 creation: true)
            }
        }
    }
}

struct AlarmeEditionVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinHorloge.partage
    @State var alarme: Alarme
    let creation: Bool
    @State private var h: Int = 0
    @State private var m: Int = 0
    @State private var rappel = true
    @State private var sonnerie = "Radial"
    @State private var dureeRappel = "9 min"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Picker("", selection: $h) {
                        ForEach(0..<24, id: \.self) { Text(String($0)).tag($0) }
                    }
                    .pickerStyle(.wheel).frame(width: 90).clipped()
                    Picker("", selection: $m) {
                        ForEach(0..<60, id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                    }
                    .pickerStyle(.wheel).frame(width: 90).clipped()
                }
                .padding(.top, 8)

                List {
                    Section {
                        LigneChoix(titre: "Récurrence", valeur: $alarme.recurrence,
                                   options: ["Jamais", "Chaque jour", "En semaine", "Chaque samedi", "Chaque dimanche"])
                        HStack {
                            Text("Description").foregroundStyle(.white)
                            Spacer()
                            TextField("Alarme", text: $alarme.libelle)
                                .multilineTextAlignment(.trailing).foregroundStyle(.secondary)
                                .frame(maxWidth: 180)
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                        LigneChoix(titre: "Sonnerie", valeur: $sonnerie,
                                   options: ["Radial", "Reflet", "Départ", "Aube", "Éclats", "Aucun"])
                        HStack {
                            Text("Rappel d'alarme").foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: $rappel).labelsHidden().tint(Color(hex: 0x32D74B))
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                        if rappel { LigneChoix(titre: "Durée du rappel", valeur: $dureeRappel,
                                                               options: ["1 min", "5 min", "9 min", "15 min"], valeurOrange: true) }
                    }
                    if !creation {
                        Section {
                            Button {
                                magasin.alarmes.removeAll { $0.id == alarme.id }
                                dismiss()
                            } label: {
                                Text("Supprimer l'alarme").foregroundStyle(Color(hex: 0xFF453A))
                                    .frame(maxWidth: .infinity)
                            }
                            .listRowBackground(Color(hex: 0x2C2C2E))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .background(Color(hex: 0x1C1C1E))
            .navigationTitle(creation ? "Nouv. alarme" : "Alarme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "xmark").foregroundStyle(.white) }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        alarme.heure = h * 60 + m
                        if creation {
                            magasin.alarmes.append(alarme)
                            magasin.alarmes.sort { $0.heure < $1.heure }
                        } else if let i = magasin.alarmes.firstIndex(where: { $0.id == alarme.id }) {
                            magasin.alarmes[i] = alarme
                            magasin.alarmes.sort { $0.heure < $1.heure }
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark").fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .padding(8).background(.orange, in: Circle())
                    }
                }
            }
            .onAppear { h = alarme.heure / 60; m = alarme.heure % 60 }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
    }
}

struct LigneChoix: View {
    let titre: String
    @Binding var valeur: String
    let options: [String]
    var valeurOrange: Bool = false
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { o in
                Button {
                    valeur = o
                } label: {
                    if o == valeur { Label(o, systemImage: "checkmark") } else { Text(o) }
                }
            }
        } label: {
            HStack {
                Text(titre).foregroundStyle(.white)
                Spacer()
                Text(valeur).foregroundStyle(valeurOrange ? .orange : .secondary)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 11)).foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .listRowBackground(Color(hex: 0x2C2C2E))
    }
}

// ============================================================ CHRONOMÈTRE
struct ChronometreVue: View {
    @State private var demarre = false
    @State private var base: Date? = nil
    @State private var cumul: TimeInterval = 0
    @State private var tours: [TimeInterval] = []

    private func texte(_ t: TimeInterval) -> String {
        let cs = Int((t * 100).rounded()) % 100
        let s = Int(t) % 60
        let mn = Int(t) / 60
        return String(format: "%02d:%02d,%02d", mn, s, cs)
    }
    private func total(_ maintenant: Date) -> TimeInterval {
        cumul + (demarre ? maintenant.timeIntervalSince(base ?? maintenant) : 0)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            TimelineView(.periodic(from: .now, by: 0.03)) { ctx in
                Text(texte(total(ctx.date)))
                    .font(.system(size: 76, weight: .thin))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            Spacer()
            HStack {
                Button {
                    if demarre { tours.insert(total(Date()), at: 0) }
                    else { cumul = 0; tours = [] }
                } label: {
                    Text(demarre ? "Tour" : (cumul > 0 ? "Effacer" : "Tour"))
                        .font(.system(size: 17)).foregroundStyle(.white)
                        .frame(width: 84, height: 84)
                        .background(Color(hex: 0x333333), in: Circle())
                }
                Spacer()
                Button {
                    if demarre { cumul = total(Date()); demarre = false }
                    else { base = Date(); demarre = true }
                } label: {
                    Text(demarre ? "Arrêter" : "Démarrer")
                        .font(.system(size: 17))
                        .foregroundStyle(demarre ? Color(hex: 0xFF453A) : Color(hex: 0x30D158))
                        .frame(width: 84, height: 84)
                        .background((demarre ? Color(hex: 0x340E0C) : Color(hex: 0x0A2B12)), in: Circle())
                }
            }
            .padding(.horizontal, 24)
            List {
                ForEach(Array(tours.enumerated()), id: \.offset) { i, t in
                    HStack {
                        Text("Tour \(tours.count - i)").foregroundStyle(.white)
                        Spacer()
                        Text(texte(t)).monospacedDigit().foregroundStyle(.white)
                    }
                    .listRowBackground(Color.black)
                    .listRowSeparatorTint(Color(hex: 0x2C2C2E))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(height: 240)
        }
        .background(Color.black)
    }
}

// ============================================================ MINUTEURS
struct MinuteursVue: View {
    @ObservedObject private var magasin = MagasinHorloge.partage
    @State private var h = 0
    @State private var mn = 5
    @State private var s = 0
    @State private var fin: Date? = nil
    @State private var duree: TimeInterval = 0
    @State private var enPause = false
    @State private var resteEnPause: TimeInterval = 0
    @State private var descriptionMinuteur = ""
    @State private var sonnerieMinuteur = "Radial"

    private var actif: Bool { fin != nil }

    private func fmt(_ t: TimeInterval) -> String {
        let tt = max(0, Int(t.rounded()))
        if tt >= 3600 { return String(format: "%d:%02d:%02d", tt / 3600, (tt % 3600) / 60, tt % 60) }
        return String(format: "%d:%02d", tt / 60, tt % 60)
    }
    private func fmtRecent(_ sec: Int) -> (String, String) {
        if sec >= 3600 { return (String(format: "%d:%02d:00", sec / 3600, (sec % 3600) / 60), "\(sec / 3600) h \((sec % 3600) / 60) min") }
        return (String(format: "%d:%02d", sec / 60, sec % 60), sec % 60 == 0 ? "\(sec / 60) min" : "\(sec / 60) min \(sec % 60) s")
    }
    private func lancer(_ sec: Int) {
        duree = TimeInterval(sec)
        fin = Date().addingTimeInterval(duree)
        enPause = false
        if let i = magasin.minuteursRecents.firstIndex(of: sec) { magasin.minuteursRecents.remove(at: i) }
        magasin.minuteursRecents.insert(sec, at: 0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if actif {
                        TimelineView(.periodic(from: .now, by: 0.25)) { ctx in
                            let reste = enPause ? resteEnPause : (fin?.timeIntervalSince(ctx.date) ?? 0)
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle().stroke(Color(hex: 0x2C2C2E), lineWidth: 9)
                                    Circle()
                                        .trim(from: 0, to: max(0.001, reste / max(duree, 1)))
                                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                    VStack(spacing: 6) {
                                        Text(fmt(reste))
                                            .font(.system(size: 64, weight: .thin)).monospacedDigit()
                                            .foregroundStyle(.white)
                                        HStack(spacing: 5) {
                                            Image(systemName: "bell.fill")
                                            Text((fin ?? Date()), format: .dateTime.hour().minute())
                                        }
                                        .font(.system(size: 15)).foregroundStyle(.secondary)
                                    }
                                }
                                .frame(width: 300, height: 300)
                                .padding(.top, 16)
                                HStack {
                                    Button {
                                        fin = nil; enPause = false
                                    } label: {
                                        Text("Annuler").font(.system(size: 17)).foregroundStyle(.white)
                                            .frame(width: 84, height: 84)
                                            .background(Color(hex: 0x333333), in: Circle())
                                    }
                                    Spacer()
                                    Button {
                                        if enPause {
                                            fin = Date().addingTimeInterval(resteEnPause); enPause = false
                                        } else {
                                            resteEnPause = fin?.timeIntervalSinceNow ?? 0; enPause = true
                                        }
                                    } label: {
                                        Text(enPause ? "Reprendre" : "Pause")
                                            .font(.system(size: 16)).foregroundStyle(.orange)
                                            .frame(width: 84, height: 84)
                                            .background(Color(hex: 0x3A2A10), in: Circle())
                                    }
                                }
                                .padding(.horizontal, 24)
                                if reste <= 0 && !enPause {
                                    Color.clear.frame(height: 1).onAppear { fin = nil }
                                }
                            }
                        }
                    } else {
                        HStack(spacing: 0) {
                            Picker("", selection: $h) { ForEach(0..<24, id: \.self) { Text("\($0)").tag($0) } }
                                .pickerStyle(.wheel).frame(width: 76).clipped()
                            Text("heure").font(.system(size: 15)).foregroundStyle(.white)
                            Picker("", selection: $mn) { ForEach(0..<60, id: \.self) { Text("\($0)").tag($0) } }
                                .pickerStyle(.wheel).frame(width: 76).clipped()
                            Text("min").font(.system(size: 15)).foregroundStyle(.white)
                            Picker("", selection: $s) { ForEach(0..<60, id: \.self) { Text("\($0)").tag($0) } }
                                .pickerStyle(.wheel).frame(width: 76).clipped()
                            Text("s").font(.system(size: 15)).foregroundStyle(.white)
                        }
                        .frame(height: 190)
                        HStack {
                            Text("Annuler").font(.system(size: 17)).foregroundStyle(.secondary)
                                .frame(width: 84, height: 84)
                                .background(Color(hex: 0x232323), in: Circle())
                            Spacer()
                            Button {
                                let sec = h * 3600 + mn * 60 + s
                                if sec > 0 { lancer(sec) }
                            } label: {
                                Text("Démarrer").font(.system(size: 16)).foregroundStyle(Color(hex: 0x30D158))
                                    .frame(width: 84, height: 84)
                                    .background(Color(hex: 0x0A2B12), in: Circle())
                            }
                        }
                        .padding(.horizontal, 24)
                        VStack(spacing: 0) {
                            HStack {
                                Text("Description").foregroundStyle(.white)
                                Spacer()
                                TextField("Minuteur", text: $descriptionMinuteur)
                                    .multilineTextAlignment(.trailing).foregroundStyle(.secondary)
                                    .frame(maxWidth: 160)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 12)
                            .background(Color(hex: 0x1C1C1E))
                            Divider().overlay(Color(hex: 0x2C2C2E))
                            LigneChoix(titre: "Sonnerie", valeur: $sonnerieMinuteur,
                                       options: ["Radial", "Reflet", "Départ", "Aube", "Éclats"])
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .background(Color(hex: 0x1C1C1E))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Récents").font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                            .padding(.horizontal, 16).padding(.bottom, 8)
                        ForEach(magasin.minuteursRecents, id: \.self) { sec in
                            let f = fmtRecent(sec)
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(f.0).font(.system(size: 34, weight: .light)).foregroundStyle(.white)
                                    Text(f.1).font(.system(size: 13)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button { lancer(sec) } label: {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 17)).foregroundStyle(Color(hex: 0x30D158))
                                        .frame(width: 44, height: 44)
                                        .background(Color(hex: 0x0A2B12), in: Circle())
                                }
                            }
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            if sec != magasin.minuteursRecents.last {
                                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 16)
                            }
                        }
                    }
                    .padding(.top, 6)
                }
            }
            .background(Color.black)
            .navigationTitle("Minuteurs")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Modifier") {}.foregroundStyle(.orange)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: { Image(systemName: "plus").foregroundStyle(.orange) }
                }
            }
        }
    }
}
