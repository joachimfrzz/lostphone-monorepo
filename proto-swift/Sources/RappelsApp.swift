// Rappels — construite contre la vidéo de référence du 18/08 (42 écrans, iOS 26)
// D59 : données remplaçables. R3 : les Terminés racontent la préparation du dossier bancaire (recoupe P60).
// D51 : utilisable de A à Z (cocher termine vraiment, création réelle, détails fonctionnels).
// v2 session 2 (02/09, retours Joachim) : Recherche RÉELLE, menu … RÉEL (Modifier les listes / Modèles),
// listes persistantes (Nouvelle liste s'ajoute vraiment), barres remontées au-dessus de la capsule home.
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

struct ListeRappels: Identifiable, Hashable {
    var id: String { nom }
    var nom: String
    var couleur: UInt
    var symbole: String
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
    // v2 : listes persistantes (Nouvelle liste / Modifier les listes réels)
    @Published var listes: [ListeRappels] = [
        ListeRappels(nom: "Rappels", couleur: 0xE8873D, symbole: "list.bullet"),
        ListeRappels(nom: "Courses", couleur: 0x30D158, symbole: "cart.fill"),
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
    @State private var nouvelleListeVisible = false
    @State private var rechercheVisible = false       // v2 : recherche réelle
    @State private var modifierListesVisible = false  // v2 : menu … réel
    @State private var modelesVisible = false

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

                        // Mes listes (v2 : depuis le magasin — les listes créées apparaissent vraiment)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mes listes").font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
                            VStack(spacing: 1) {
                                ForEach(magasin.listes) { l in
                                    NavigationLink(destination: FiltreVue(titre: l.nom, teinte: Color(hex: l.couleur)) { $0.liste == l.nom && !$0.termine }) {
                                        LigneListe(nom: l.nom, couleur: Color(hex: l.couleur), symbole: l.symbole,
                                                   compte: magasin.compter { $0.liste == l.nom && !$0.termine })
                                    }
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16).padding(.top, 8)
                }

                // Miroir lot 2 : la référence n'a qu'un bouton + flottant en bas à droite (v2 : remonté au-dessus de la capsule)
                HStack {
                    Spacer()
                    Button { nouveauVisible = true } label: {
                        Circle().fill(Color(hex: 0x0A84FF)).frame(width: 52, height: 52)
                            .overlay(Image(systemName: "plus").font(.system(size: 23, weight: .semibold)).foregroundStyle(.white))
                            .shadow(color: .black.opacity(0.4), radius: 8, y: 3)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 30)

            BarreHome { dismiss() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        // v2 : Recherche RÉELLE
                        Button { rechercheVisible = true } label: {
                            Image(systemName: "magnifyingglass").foregroundStyle(Color(hex: 0x0A84FF))
                        }
                        Button { nouvelleListeVisible = true } label: {
                            Image(systemName: "text.badge.plus").foregroundStyle(Color(hex: 0x0A84FF))
                        }
                        // v2 : menu … RÉEL
                        Menu {
                            Button { modifierListesVisible = true } label: { Label("Modifier les listes", systemImage: "pencil") }
                            Button { modelesVisible = true } label: { Label("Modèles", systemImage: "doc.on.doc") }
                        } label: {
                            Image(systemName: "ellipsis.circle").foregroundStyle(Color(hex: 0x0A84FF))
                        }
                    }
                }
            }
            .sheet(isPresented: $nouveauVisible) { NouveauRappelVue() }
            .sheet(isPresented: $nouvelleListeVisible) { RappelsNouvelleListeVue() }
            .sheet(isPresented: $rechercheVisible) { RechercheRappelsVue() }
            .sheet(isPresented: $modifierListesVisible) { ModifierListesRappelsVue() }
            .sheet(isPresented: $modelesVisible) { ModelesRappelsVue() }
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

// ============================================================ v2 — RECHERCHE RÉELLE
struct RechercheRappelsVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    @State private var recherche = ""
    private var resultats: [Rappel] {
        guard !recherche.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        return magasin.rappels.filter { $0.titre.localizedCaseInsensitiveContains(recherche) || $0.liste.localizedCaseInsensitiveContains(recherche) }
    }
    var body: some View {
        NavigationStack {
            List {
                if recherche.isEmpty {
                    Text("Recherchez dans vos rappels et vos listes.").foregroundStyle(.secondary)
                        .listRowBackground(Color(hex: 0x1C1C1E))
                } else if resultats.isEmpty {
                    Text("Aucun résultat pour « \(recherche) »").foregroundStyle(.secondary)
                        .listRowBackground(Color(hex: 0x1C1C1E))
                } else {
                    ForEach(resultats) { r in
                        HStack(alignment: .top, spacing: 12) {
                            if r.termine {
                                Circle().fill(Color(hex: 0x8E8E93)).frame(width: 22, height: 22)
                                    .overlay(Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.black))
                            } else {
                                Circle().stroke(Color(hex: 0x8E8E93), lineWidth: 1.5).frame(width: 22, height: 22)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.titre).font(.system(size: 16)).foregroundStyle(r.termine ? .secondary : .white)
                                Text(r.liste + (r.sousTexte.map { " · " + $0 } ?? "") + (r.termineTexte.map { " · " + $0 } ?? ""))
                                    .font(.system(size: 13)).foregroundStyle(.secondary)
                            }
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0x1C1C1E))
            .searchable(text: $recherche, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher")
            .navigationTitle("Recherche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF)) }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ v2 — MODIFIER LES LISTES (réordonner / supprimer, réel)
struct ModifierListesRappelsVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("MES LISTES")) {
                    ForEach(magasin.listes) { l in
                        HStack(spacing: 12) {
                            Circle().fill(Color(hex: l.couleur)).frame(width: 28, height: 28)
                                .overlay(Image(systemName: l.symbole).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white))
                            Text(l.nom).foregroundStyle(.white)
                            Spacer()
                            Text("\(magasin.compter { $0.liste == l.nom && !$0.termine })").foregroundStyle(.secondary)
                        }
                        .listRowBackground(Color(hex: 0x2C2C2E))
                    }
                    .onMove { from, to in magasin.listes.move(fromOffsets: from, toOffset: to) }
                    .onDelete { idx in
                        let noms = idx.map { magasin.listes[$0].nom }
                        magasin.listes.remove(atOffsets: idx)
                        magasin.rappels.removeAll { noms.contains($0.liste) }
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0x1C1C1E))
            .navigationTitle("Modifier les listes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("OK") { dismiss() }.fontWeight(.semibold).foregroundStyle(Color(hex: 0x0A84FF)) }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ v2 — MODÈLES (écran iOS réel, état vide)
struct ModelesRappelsVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 10) {
                    Image(systemName: "doc.on.doc").font(.system(size: 40)).foregroundStyle(.secondary)
                    Text("Aucun modèle").font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
                    Text("Enregistrez une liste comme modèle pour la réutiliser (menu … d'une liste).")
                        .font(.system(size: 14)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 40)
                }
            }
            .navigationTitle("Modèles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF)) } }
        }
        .preferredColorScheme(.dark)
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
    @State private var afficherTermines = false     // v2 : menu … réel
    @State private var triTitre = false
    @State private var partageVisible = false
    @FocusState private var saisieActive: Bool

    init(titre: String, teinte: Color, filtre: @escaping (Rappel) -> Bool) {
        self.titre = titre; self.teinte = teinte; self.filtre = filtre
    }

    private var items: [Rappel] {
        var r = magasin.rappels.filter(filtre)
        if afficherTermines { r += magasin.rappels.filter { $0.termine && (titre == "Tous" || $0.liste == titre) } }
        if triTitre { r.sort { $0.titre.localizedCaseInsensitiveCompare($1.titre) == .orderedAscending } }
        return r
    }

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
                        if r.termine {
                            Circle().fill(Color(hex: 0x8E8E93)).frame(width: 24, height: 24)
                                .overlay(Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.black))
                        } else {
                            Circle().stroke(Color(hex: 0x8E8E93), lineWidth: 1.5)
                                .frame(width: 24, height: 24)
                                .contentShape(Circle())
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.25)) { magasin.terminer(r.id) }
                                }
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                if r.urgent { Text("!!!").font(.system(size: 16, weight: .bold)).foregroundStyle(Color(hex: 0xE84D6B)) }
                                Text(r.titre).font(.system(size: 16.5)).foregroundStyle(r.termine ? .secondary : .white)
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
                                let listeCible = magasin.listes.contains { $0.nom == titre } ? titre : "Rappels"
                                magasin.rappels.append(Rappel(titre: t,
                                                              liste: listeCible,
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
                    // v2 : partage réel + menu … réel (afficher terminés / trier)
                    Button { partageVisible = true } label: {
                        Image(systemName: "square.and.arrow.up").foregroundStyle(Color(hex: 0x0A84FF))
                    }
                    Menu {
                        Button { withAnimation { afficherTermines.toggle() } } label: {
                            Label(afficherTermines ? "Masquer les terminés" : "Afficher les terminés", systemImage: afficherTermines ? "eye.slash" : "eye")
                        }
                        Menu("Trier par") {
                            Button { triTitre = false } label: { Label("Manuel", systemImage: triTitre ? "" : "checkmark") }
                            Button { triTitre = true } label: { Label("Titre", systemImage: triTitre ? "checkmark" : "") }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundStyle(Color(hex: 0x0A84FF))
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { saisieActive = true }
        .sheet(item: $detail) { r in DetailRappelVue(rappelId: r.id) }
        .sheet(isPresented: $partageVisible) { FeuillePartage(element: "Liste « \(titre) »") }
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
                        // v2 : la liste se change vraiment
                        Menu {
                            ForEach(magasin.listes) { l in
                                Button(l.nom) { magasin.rappels[i].liste = l.nom }
                            }
                        } label: {
                            HStack {
                                Text("Liste").foregroundStyle(.white)
                                Spacer()
                                Circle().fill(Color(hex: magasin.listes.first { $0.nom == magasin.rappels[i].liste }?.couleur ?? 0xE8873D))
                                    .frame(width: 12, height: 12)
                                Text(magasin.rappels[i].liste).foregroundStyle(.secondary)
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                            }
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
                        ForEach(magasin.listes) { l in
                            Button(l.nom) { listeChoisie = l.nom }
                        }
                    } label: {
                        HStack {
                            Text("Liste").foregroundStyle(.white)
                            Spacer()
                            Circle().fill(Color(hex: magasin.listes.first { $0.nom == listeChoisie }?.couleur ?? 0xE8873D))
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

struct RappelsNouvelleListeVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    @State private var nom = ""
    @State private var couleurIdx = 0
    private let couleurs: [UInt] = [0xFF3B30, 0xE8873D, 0xFFD60A, 0x30D158, 0x0A84FF, 0xBF5AF2, 0xFF375F]
    private let symboles = ["list.bullet", "star.fill", "cart.fill", "heart.fill", "bookmark.fill", "house.fill"]
    @State private var symboleIdx = 0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: symboles[symboleIdx])
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(hex: couleurs[couleurIdx]), in: Circle())
                        TextField("Titre", text: $nom)
                            .font(.system(size: 17))
                    }
                }
                Section("Couleur") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(couleurs.indices, id: \.self) { i in
                                Circle().fill(Color(hex: couleurs[i])).frame(width: 32, height: 32)
                                    .overlay(couleurIdx == i ? Circle().stroke(.white, lineWidth: 2) : nil)
                                    .onTapGesture { couleurIdx = i }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                Section("Icône") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(symboles.indices, id: \.self) { i in
                                Image(systemName: symboles[i]).foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color(white: symboleIdx == i ? 0.35 : 0.2), in: Circle())
                                    .onTapGesture { symboleIdx = i }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Nouvelle liste")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }.foregroundStyle(.blue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    // v2 : la liste est vraiment créée et apparaît dans « Mes listes »
                    Button("OK") {
                        let n = nom.trimmingCharacters(in: .whitespaces)
                        if !n.isEmpty && !magasin.listes.contains(where: { $0.nom == n }) {
                            magasin.listes.append(ListeRappels(nom: n, couleur: couleurs[couleurIdx], symbole: symboles[symboleIdx]))
                        }
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                    .disabled(nom.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
