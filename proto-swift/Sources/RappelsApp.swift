// Rappels — construite contre la vidéo de référence du 18/08 (42 écrans, iOS 26)
// D59 : données remplaçables. R3 : les Terminés racontent la préparation du dossier bancaire (recoupe P60).
// D51 : utilisable de A à Z (cocher termine vraiment, création réelle, détails fonctionnels).
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct Rappel: Identifiable {
    let id = UUID()
    var titre: String
    var sousTexte: String? = nil       // "Demain, 11:15" etc.
    var liste: String                  // "Rappels" / "Courses"
    var urgent: Bool = false
    var drapeau: Bool = false
    var programme: Bool = false
    var aujourdhui: Bool = false
    var termine: Bool = false
    var termineTexte: String? = nil    // "Terminé : 16/08/2026 21:40"
}

final class MagasinRappels: ObservableObject {
    static let partage = MagasinRappels()
    @Published var rappels: [Rappel] = [
        Rappel(titre: "Rappeler Chloé", liste: "Rappels", aujourdhui: true),
        Rappel(titre: "Banque — dossier complet !!", sousTexte: "Demain, 11:15 🔁", liste: "Rappels",
               urgent: true, drapeau: true, programme: true),
        Rappel(titre: "Kiné jeudi", sousTexte: "20/08/2026, 17:30", liste: "Rappels", programme: true),
        Rappel(titre: "Carottes", liste: "Courses"),
        // Terminés — la préparation du dossier, en creux (R3 avec la note P60)
        Rappel(titre: "Imprimer le RIB", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 16/08/2026 21:38"),
        Rappel(titre: "Photographier pièce d'identité", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 12/08/2026 09:41"),
        Rappel(titre: "Acheter enveloppe A4", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 12/08/2026 18:02"),
        Rappel(titre: "Rendre le tupperware à maman 😅", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 09/08/2026 14:20"),
        Rappel(titre: "Kiné", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 06/08/2026 17:35"),
        Rappel(titre: "Photos du festival à Chloé", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 12/07/2026 18:24"),
    ]

    func terminer(_ id: UUID) {
        guard let i = rappels.firstIndex(where: { $0.id == id }) else { return }
        rappels[i].termine = true
        rappels[i].termineTexte = "Terminé : à l'instant"
    }
    func compter(_ filtre: (Rappel) -> Bool) -> Int { rappels.filter(filtre).count }
}

// ============================================================ APP
struct RappelsVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    @State private var nouveauVisible = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        // Grille de compteurs (2 colonnes, comme la référence)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                            TuileRappel(nom: "Aujourd'hui", symbole: "calendar.badge.clock", fond: Color(hex: 0x56A2E1),
                                        compte: magasin.compter { $0.aujourdhui && !$0.termine },
                                        destination: FiltreVue(titre: "Aujourd'hui", teinte: Color(hex: 0x0A84FF)) { $0.aujourdhui && !$0.termine })
                            TuileRappel(nom: "Programmés", symbole: "calendar", fond: Color(hex: 0xE68081),
                                        compte: magasin.compter { $0.programme && !$0.termine },
                                        destination: FiltreVue(titre: "Programmés", teinte: Color(hex: 0xFF3B30)) { $0.programme && !$0.termine })
                            TuileRappel(nom: "Tous", symbole: "tray.fill", fond: Color(hex: 0x474747),
                                        compte: magasin.compter { !$0.termine },
                                        destination: FiltreVue(titre: "Tous", teinte: .white) { !$0.termine })
                            TuileRappel(nom: "Avec drapeau", symbole: "flag.fill", fond: Color(hex: 0xEDB47D),
                                        compte: magasin.compter { $0.drapeau && !$0.termine },
                                        destination: FiltreVue(titre: "Avec drapeau", teinte: Color(hex: 0xE8873D)) { $0.drapeau && !$0.termine })
                            TuileRappel(nom: "Urgent", symbole: "exclamationmark.circle.fill", fond: Color(hex: 0xDE6E96),
                                        compte: magasin.compter { $0.urgent && !$0.termine },
                                        destination: FiltreVue(titre: "Urgent", teinte: Color(hex: 0xE84D6B)) { $0.urgent && !$0.termine })
                            TuileRappel(nom: "Terminés", symbole: "checkmark", fond: Color(hex: 0x8E9196),
                                        compte: magasin.compter { $0.termine },
                                        destination: TerminesVue())
                        }

                        // Mes listes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mes listes").font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
                            VStack(spacing: 1) {
                                NavigationLink(destination: FiltreVue(titre: "Rappels", teinte: Color(hex: 0xE8873D)) { $0.liste == "Rappels" && !$0.termine }) {
                                    LigneListe(nom: "Rappels", couleur: Color(hex: 0xE8873D), symbole: "list.bullet",
                                               compte: magasin.compter { $0.liste == "Rappels" && !$0.termine })
                                }
                                NavigationLink(destination: FiltreVue(titre: "Courses", teinte: Color(hex: 0x30D158)) { $0.liste == "Courses" && !$0.termine }) {
                                    LigneListe(nom: "Courses", couleur: Color(hex: 0x30D158), symbole: "cart.fill",
                                               compte: magasin.compter { $0.liste == "Courses" && !$0.termine })
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 16).padding(.top, 8)
                }

                // Miroir lot 2 : la référence n'a qu'un bouton + flottant en bas à droite
                HStack {
                    Spacer()
                    Button { nouveauVisible = true } label: {
                        Circle().fill(Color(hex: 0x0A84FF)).frame(width: 52, height: 52)
                            .overlay(Image(systemName: "plus").font(.system(size: 23, weight: .semibold)).foregroundStyle(.white))
                            .shadow(color: .black.opacity(0.4), radius: 8, y: 3)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 14)

            BarreHome { dismiss() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Image(systemName: "magnifyingglass").foregroundStyle(Color(hex: 0x0A84FF))
                        Image(systemName: "text.badge.plus").foregroundStyle(Color(hex: 0x0A84FF))
                        Image(systemName: "ellipsis.circle").foregroundStyle(Color(hex: 0x0A84FF))
                    }
                }
            }
            .sheet(isPresented: $nouveauVisible) { NouveauRappelVue() }
        }
        .preferredColorScheme(.dark)
    }
}

struct TuileRappel<D: View>: View {
    let nom: String
    let symbole: String
    let fond: Color
    let compte: Int
    let destination: D
    var body: some View {
        NavigationLink(destination: destination) {
            // Miroir lot 2 : tuiles PLEINES colorées comme la référence (v5 f001, couleurs échantillonnées)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Circle().fill(.white.opacity(0.28))
                        .frame(width: 32, height: 32)
                        .overlay(Image(systemName: symbole).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white))
                    Spacer()
                    Text("\(compte)").font(.system(size: 27, weight: .bold)).foregroundStyle(.white)
                }
                Text(nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white.opacity(0.95))
            }
            .padding(12)
            .background(
                LinearGradient(colors: [fond, fond.opacity(0.82)], startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct LigneListe: View {
    let nom: String
    let couleur: Color
    let symbole: String
    let compte: Int
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(couleur).frame(width: 30, height: 30)
                .overlay(Image(systemName: symbole).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white))
            Text(nom).font(.system(size: 16)).foregroundStyle(.white)
            Spacer()
            Text("\(compte)").font(.system(size: 16)).foregroundStyle(.secondary)
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .background(Color(hex: 0x1C1C1E))
    }
}

// ============================================================ LISTE FILTRÉE
struct FiltreVue: View {
    let titre: String
    let teinte: Color
    let filtre: (Rappel) -> Bool
    @ObservedObject private var magasin = MagasinRappels.partage
    @State private var detail: Rappel? = nil
    @State private var nouveau = ""
    @FocusState private var saisieActive: Bool

    init(titre: String, teinte: Color, filtre: @escaping (Rappel) -> Bool) {
        self.titre = titre; self.teinte = teinte; self.filtre = filtre
    }

    private var items: [Rappel] { magasin.rappels.filter(filtre) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(titre).font(.system(size: 32, weight: .bold)).foregroundStyle(teinte)
                    .padding(.bottom, 12)
                if items.isEmpty && nouveau.isEmpty && !saisieActive {
                    Text(titre == "Courses" ? "Ajoutez des articles de courses\nLes articles ajoutés sont automatiquement organisés en sections."
                                            : "Aucun rappel")
                        .font(.system(size: 14)).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity).padding(.top, 80)
                }
                ForEach(items) { r in
                    HStack(alignment: .top, spacing: 12) {
                        Circle().stroke(Color(hex: 0x8E8E93), lineWidth: 1.5)
                            .frame(width: 24, height: 24)
                            .contentShape(Circle())
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.25)) { magasin.terminer(r.id) }
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                if r.urgent { Text("!!!").font(.system(size: 16, weight: .bold)).foregroundStyle(Color(hex: 0xE84D6B)) }
                                Text(r.titre).font(.system(size: 16.5)).foregroundStyle(.white)
                            }
                            if let s = r.sousTexte {
                                Text(s).font(.system(size: 14)).foregroundStyle(Color(hex: 0x0A84FF))
                            }
                        }
                        Spacer()
                        if r.drapeau { Image(systemName: "flag.fill").font(.system(size: 13)).foregroundStyle(Color(hex: 0xE8873D)) }
                        Image(systemName: "info.circle").font(.system(size: 18)).foregroundStyle(Color(hex: 0x0A84FF))
                            .onTapGesture { detail = r }
                    }
                    .padding(.vertical, 10)
                    Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 36)
                }
                // Saisie d'un nouveau rappel directement dans la liste (D51 A à Z)
                HStack(spacing: 12) {
                    Circle().stroke(Color(hex: 0x8E8E93).opacity(saisieActive ? 1 : 0), lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    TextField("", text: $nouveau)
                        .focused($saisieActive)
                        .foregroundStyle(.white)
                        .onSubmit {
                            let t = nouveau.trimmingCharacters(in: .whitespaces)
                            if !t.isEmpty {
                                magasin.rappels.append(Rappel(titre: t,
                                                              liste: titre == "Courses" ? "Courses" : "Rappels",
                                                              urgent: titre == "Urgent",
                                                              drapeau: titre == "Avec drapeau",
                                                              aujourdhui: titre == "Aujourd'hui"))
                            }
                            nouveau = ""
                        }
                }
                .padding(.vertical, 10)
                Spacer(minLength: 60)
            }
            .padding(.horizontal, 18)
        }
        .background(Color.black)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.up").foregroundStyle(Color(hex: 0x0A84FF))
                    Image(systemName: "ellipsis.circle").foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { saisieActive = true }
        .sheet(item: $detail) { r in DetailRappelVue(rappelId: r.id) }
    }
}

extension Rappel: Hashable {
    static func == (a: Rappel, b: Rappel) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// ============================================================ TERMINÉS
struct TerminesVue: View {
    @ObservedObject private var magasin = MagasinRappels.partage
    @State private var effacerConfirm = false
    private var termines: [Rappel] { magasin.rappels.filter { $0.termine } }

    // Miroir phase C : regroupement par jour comme la référence (« Sam. 16 août »)
    private var parJour: [(String, [Rappel])] {
        let brut = Dictionary(grouping: termines) { r -> String in
            String((r.termineTexte ?? "").dropFirst(10).prefix(10))   // « 16/08/2026 »
        }
        let entree = DateFormatter(); entree.dateFormat = "dd/MM/yyyy"
        let sortie = DateFormatter(); sortie.locale = Locale(identifier: "fr_FR"); sortie.dateFormat = "EEE d MMMM"
        return brut.keys.sorted(by: >).map { cle in
            let libelle = entree.date(from: cle).map { sortie.string(from: $0).capitalized } ?? cle
            return (libelle, brut[cle] ?? [])
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Terminés").font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                HStack(spacing: 6) {
                    Text("\(termines.count) terminés").font(.system(size: 14)).foregroundStyle(.secondary)
                    Text("·").foregroundStyle(.secondary)
                    Text("Effacer").font(.system(size: 14)).foregroundStyle(Color(hex: 0x0A84FF))
                        .contentShape(Rectangle())
                        .onTapGesture { effacerConfirm = true }
                }
                .padding(.bottom, 14)
                ForEach(parJour, id: \.0) { jour, rappels in
                    Text(jour).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                        .padding(.top, 12).padding(.bottom, 4)
                    ForEach(rappels) { r in
                    HStack(alignment: .top, spacing: 12) {
                        Circle().fill(Color(hex: 0x8E8E93)).frame(width: 22, height: 22)
                            .overlay(Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.black))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(r.titre).font(.system(size: 16)).foregroundStyle(.secondary)
                            Text("\(r.liste) · \(r.termineTexte ?? "")").font(.system(size: 12.5)).foregroundStyle(.secondary.opacity(0.7))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 9)
                    Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 34)
                    }
                }
                Spacer(minLength: 60)
            }
            .padding(.horizontal, 18)
        }
        .background(Color.black)
        .confirmationDialog("Effacer \(termines.count) rappels terminés ?", isPresented: $effacerConfirm, titleVisibility: .visible) {
            Button("Effacer les rappels terminés", role: .destructive) {
                Haptique.leger()
                magasin.rappels.removeAll { $0.termine }
            }
            Button("Annuler", role: .cancel) {}
        }
    }
}

// ============================================================ DÉTAILS (fonctionnels — D56)
struct DetailRappelVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    let rappelId: UUID
    private var index: Int? { magasin.rappels.firstIndex { $0.id == rappelId } }

    var body: some View {
        NavigationStack {
            List {
                if let i = index {
                    Section {
                        HStack {
                            Text(magasin.rappels[i].titre).foregroundStyle(.white)
                            Spacer()
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                    }
                    Section {
                        HStack {
                            Label { Text("Date").foregroundStyle(.white) } icon: {
                                Image(systemName: "calendar").foregroundStyle(Color(hex: 0xFF3B30))
                            }
                            Spacer()
                            Toggle("", isOn: Binding(get: { magasin.rappels[i].programme },
                                                     set: { magasin.rappels[i].programme = $0 })).labelsHidden().tint(Color(hex: 0x30D158))
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                        HStack {
                            Label { Text("Urgent").foregroundStyle(.white) } icon: {
                                Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Color(hex: 0xE84D6B))
                            }
                            Spacer()
                            Toggle("", isOn: Binding(get: { magasin.rappels[i].urgent },
                                                     set: { magasin.rappels[i].urgent = $0 })).labelsHidden().tint(Color(hex: 0x30D158))
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                        HStack {
                            Label { Text("Avec drapeau").foregroundStyle(.white) } icon: {
                                Image(systemName: "flag.fill").foregroundStyle(Color(hex: 0xE8873D))
                            }
                            Spacer()
                            Toggle("", isOn: Binding(get: { magasin.rappels[i].drapeau },
                                                     set: { magasin.rappels[i].drapeau = $0 })).labelsHidden().tint(Color(hex: 0x30D158))
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                    }
                    Section {
                        HStack {
                            Text("Liste").foregroundStyle(.white)
                            Spacer()
                            Circle().fill(magasin.rappels[i].liste == "Courses" ? Color(hex: 0x30D158) : Color(hex: 0xE8873D))
                                .frame(width: 12, height: 12)
                            Text(magasin.rappels[i].liste).foregroundStyle(.secondary)
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0x1C1C1E))
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "xmark").foregroundStyle(.white) }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "checkmark").fontWeight(.semibold).foregroundStyle(.black)
                            .padding(7).background(Color(hex: 0x0A84FF), in: Circle())
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
    }
}

// ============================================================ NOUVEAU RAPPEL
struct NouveauRappelVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    @State private var titre = ""
    @State private var note = ""
    @State private var listeChoisie = "Rappels"

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Titre", text: $titre).foregroundStyle(.white)
                        .listRowBackground(Color(hex: 0x2C2C2E))
                    TextField("Notes", text: $note).foregroundStyle(.white)
                        .listRowBackground(Color(hex: 0x2C2C2E))
                }
                Section {
                    Menu {
                        Button("Rappels") { listeChoisie = "Rappels" }
                        Button("Courses") { listeChoisie = "Courses" }
                    } label: {
                        HStack {
                            Text("Liste").foregroundStyle(.white)
                            Spacer()
                            Circle().fill(listeChoisie == "Courses" ? Color(hex: 0x30D158) : Color(hex: 0xE8873D))
                                .frame(width: 12, height: 12)
                            Text(listeChoisie).foregroundStyle(.secondary)
                            Image(systemName: "chevron.up.chevron.down").font(.system(size: 11)).foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color(hex: 0x2C2C2E))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0x1C1C1E))
            .navigationTitle("Nouveau rappel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ajouter") {
                        let t = titre.trimmingCharacters(in: .whitespaces)
                        if !t.isEmpty { magasin.rappels.append(Rappel(titre: t, liste: listeChoisie)) }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(titre.isEmpty ? Color(hex: 0x5A5A5E) : Color(hex: 0x0A84FF))
                    .disabled(titre.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
    }
}
