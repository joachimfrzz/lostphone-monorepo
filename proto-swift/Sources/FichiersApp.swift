// Fichiers — construit contre la vidéo de référence du 24/08 (75 écrans, iOS 26)
// D51-2 : 3 onglets (Récents / Partagé / Explorer), grille de vignettes, tri Icônes/Liste,
// menu contextuel complet, fiche Infos, recherche à jetons, tags, dossiers, aperçus réels.
// D59 : contenu = données remplaçables ; or narratif en garniture (billet du 28, exercices kiné,
// relevés LCL — chaque fichier recoupe une autre app, R3).
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct FichierItem: Identifiable {
    let id = UUID()
    var nom: String
    var genre: String          // "pdf", "image", "zip", "dossier", "audio"
    var taille: String
    var date: String
    var creation: String = "10 août 2026 à 14:02"
    var emplacement: String = "Sur mon iPhone"
    var photoId: String? = nil // image de la pellicule pour l'aperçu réel
    var elements: Int = 0      // si dossier
    var tag: String? = nil
    var dossier: String? = nil // dossier parent
}

enum DonneesFichiers {
    static let tout: [FichierItem] = [
        FichierItem(nom: "Documents", genre: "dossier", taille: "—", date: "hier", elements: 5),
        FichierItem(nom: "Kiné", genre: "dossier", taille: "—", date: "mardi", elements: 2),
        FichierItem(nom: "Billets", genre: "dossier", taille: "—", date: "10/08/2026", elements: 2),
        FichierItem(nom: "billet-tgv-28-aout", genre: "pdf", taille: "417 Ko", date: "10/08/2026",
                    creation: "10 août 2026 à 10:21", emplacement: "iCloud Drive", tag: "Important", dossier: "Billets"),
        FichierItem(nom: "exercices_epaule_S32", genre: "pdf", taille: "840 Ko", date: "mardi",
                    creation: "18 août 2026 à 10:02", dossier: "Kiné"),
        FichierItem(nom: "releve_LCL_juillet", genre: "pdf", taille: "212 Ko", date: "05/08/2026",
                    creation: "5 août 2026 à 09:12", emplacement: "iCloud Drive", dossier: "Documents"),
        FichierItem(nom: "justificatif_domicile", genre: "pdf", taille: "148 Ko", date: "hier",
                    creation: "16 août 2026 à 22:41", tag: "Important", dossier: "Documents"),
        FichierItem(nom: "photo_festival", genre: "image", taille: "3,1 Mo", date: "12/07/2026",
                    creation: "12 juillet 2026 à 18:20", photoId: "p15"),
        FichierItem(nom: "chloe_et_moi", genre: "image", taille: "2,8 Mo", date: "12/07/2026",
                    creation: "12 juillet 2026 à 18:22", photoId: "p04"),
        FichierItem(nom: "recettes_mamie", genre: "zip", taille: "1,2 Mo", date: "07/08/2026",
                    creation: "7 août 2026 à 19:44", dossier: "Documents"),
        FichierItem(nom: "attestation_caf", genre: "pdf", taille: "96 Ko", date: "02/08/2026",
                    creation: "2 août 2026 à 11:30", dossier: "Documents"),
        FichierItem(nom: "cv_sarah_levasseur", genre: "pdf", taille: "184 Ko", date: "14/03/2026",
                    creation: "14 mars 2026 à 16:08", dossier: "Documents"),
    ]
    static let tags = [("Rouge", 0xFF453A), ("Orange", 0xFF9F0A), ("Bleu", 0x0A84FF), ("Violet", 0xBF5AF2),
                       ("Gris", 0x8E8E93), ("Vert", 0x32D74B), ("Travail", 0x8E8E93), ("Jaune", 0xFFD60A),
                       ("Maison", 0x8E8E93), ("Important", 0xFF9F0A)]
}

final class MagasinFichiers: ObservableObject {
    static let partage = MagasinFichiers()
    @Published var supprimes: Set<UUID> = []
    @Published var renommages: [UUID: String] = [:]
    var visibles: [FichierItem] { DonneesFichiers.tout.filter { !supprimes.contains($0.id) } }
    func nom(_ f: FichierItem) -> String { renommages[f.id] ?? f.nom }
}

// ============================================================ APP
struct FichiersVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            Group {
                switch onglet {
                case 1: PartageFichiersVue()
                case 2: ExplorerFichiersVue()
                default: RecentsFichiersVue()
                }
            }

            // Barre d'onglets en PILULE FLOTTANTE (diff cercle 2 : la référence détache la capsule du bord)
            HStack(spacing: 4) {
                OngletFichiers(symbole: "clock.fill", nom: "Récents", actif: onglet == 0) { onglet = 0 }
                OngletFichiers(symbole: "folder.fill.badge.person.crop", nom: "Partagé", actif: onglet == 1) { onglet = 1 }
                OngletFichiers(symbole: "folder.fill", nom: "Explorer", actif: onglet == 2) { onglet = 2 }
            }
            .padding(6)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.horizontal, 40).padding(.bottom, 34)

            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
    }
}

struct OngletFichiers: View {
    let symbole: String
    let nom: String
    let actif: Bool
    let action: () -> Void
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: symbole).font(.system(size: 17))
            Text(nom).font(.system(size: 10))
        }
        .foregroundStyle(actif ? Color(hex: 0x0A84FF) : .secondary)
        .padding(.vertical, 7).frame(maxWidth: .infinity)
        .background(actif ? Color(hex: 0x3A3A3C).opacity(0.85) : .clear, in: Capsule())
        .contentShape(Capsule())
        .onTapGesture(perform: action)
    }
}

// ============================================================ RÉCENTS
struct RecentsFichiersVue: View {
    @ObservedObject private var magasin = MagasinFichiers.partage
    @State private var recherche = ""
    @State private var enListe = false
    @State private var apercu: FichierItem? = nil
    @State private var infos: FichierItem? = nil
    @State private var renommageId: UUID? = nil
    @State private var nouveauNom = ""
    @State private var partageVisible = false
    @State private var selectionActive = false
    @State private var selectionIds: Set<UUID> = []

    private var items: [FichierItem] {
        let base = magasin.visibles.filter { $0.genre != "dossier" }
        guard !recherche.isEmpty else { return base }
        return base.filter { magasin.nom($0).localizedCaseInsensitiveContains(recherche) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Récents").font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Menu {
                        Button { selectionActive.toggle() } label: { Label(selectionActive ? "Terminer" : "Sélectionner", systemImage: "checkmark.circle") }
                        Button { } label: { Label("Scanner des documents", systemImage: "doc.viewfinder") }
                        Button { } label: { Label("Se connecter au serveur", systemImage: "server.rack") }
                        Divider()
                        Button { enListe = false } label: { Label("Icônes", systemImage: enListe ? "square.grid.2x2" : "checkmark") }
                        Button { enListe = true } label: { Label("Liste", systemImage: enListe ? "checkmark" : "list.bullet") }
                    } label: {
                        Image(systemName: "ellipsis").font(.system(size: 16)).foregroundStyle(Color(hex: 0x0A84FF))
                            .frame(width: 32, height: 32).background(Color(hex: 0x1C1C1E), in: Circle())
                    }
                }
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Rechercher", text: $recherche).foregroundStyle(.white)
                    Image(systemName: "mic.fill").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12).frame(height: 38)
                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 11))

                if !recherche.isEmpty {
                    HStack(spacing: 6) {
                        Text("Le nom contient « \(recherche) »").font(.system(size: 12.5)).foregroundStyle(.secondary)
                        Spacer()
                    }
                }

                if items.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").font(.system(size: 38)).foregroundStyle(.secondary)
                        Text("Aucun résultat pour « \(recherche) »").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        Text("Vérifiez l'orthographe ou lancez une nouvelle recherche.").font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 90)
                } else if enListe {
                    VStack(spacing: 0) {
                        ForEach(items) { f in
                            LigneFichier(fichier: f)
                                .contentShape(Rectangle())
                                .onTapGesture { apercu = f }
                                .contextMenu { menuFichier(f) }
                            Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 52)
                        }
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible())], spacing: 18) {
                        ForEach(items) { f in
                            TuileFichier(fichier: f)
                                .onTapGesture { apercu = f }
                                .contextMenu { menuFichier(f) }
                        }
                    }
                }
                Spacer(minLength: 110)
            }
            .padding(.horizontal, 16).padding(.top, 6)
        }
        .fullScreenCover(item: $apercu) { f in ApercuFichierVue(fichier: f) }
        .sheet(item: $infos) { f in InfosFichierVue(fichier: f) }
        .sheet(isPresented: $partageVisible) { FeuillePartage(element: "1 document") }
        .alert("Renommer", isPresented: Binding(get: { renommageId != nil }, set: { if !$0 { renommageId = nil } })) {
            TextField("Nom", text: $nouveauNom)
            Button("Annuler", role: .cancel) {}
            Button("OK") { if let id = renommageId { magasin.renommages[id] = nouveauNom } }
        }
    }

    @ViewBuilder
    private func menuFichier(_ f: FichierItem) -> some View {
        Button { apercu = f } label: { Label("Coup d'œil", systemImage: "eye") }
        Button { partageVisible = true } label: { Label("Partager", systemImage: "square.and.arrow.up") }
        Button { infos = f } label: { Label("Lire les informations", systemImage: "info.circle") }
        Button { renommageId = f.id; nouveauNom = magasin.nom(f) } label: { Label("Renommer", systemImage: "pencil") }
        Button { } label: { Label("Compresser", systemImage: "archivebox") }
        Button { } label: { Label("Dupliquer", systemImage: "plus.square.on.square") }
        Button(role: .destructive) { magasin.supprimes.insert(f.id) } label: { Label("Supprimer", systemImage: "trash") }
    }
}

// Vignette (référence : icône du type + nom + date + taille + emplacement)
struct TuileFichier: View {
    @ObservedObject private var magasin = MagasinFichiers.partage
    let fichier: FichierItem
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                if fichier.genre == "image", let pid = fichier.photoId, let img = ChargeurPhoto.image(pid) {
                    Image(uiImage: img).resizable().scaledToFill()
                        .frame(width: 74, height: 92).clipShape(RoundedRectangle(cornerRadius: 6))
                } else if fichier.genre == "dossier" {
                    Image(systemName: "folder.fill").font(.system(size: 52)).foregroundStyle(Color(hex: 0x54A5F5))
                        .frame(height: 92)
                } else {
                    RoundedRectangle(cornerRadius: 6).fill(.white)
                        .frame(width: 74, height: 92)
                        .overlay(alignment: .top) {
                            VStack(spacing: 3) {
                                ForEach(0..<6, id: \.self) { _ in
                                    Capsule().fill(Color(hex: 0xC9CDD4)).frame(height: 3).padding(.horizontal, 9)
                                }
                            }
                            .padding(.top, 12)
                        }
                        .overlay(alignment: .bottomLeading) {
                            Text(fichier.genre.uppercased()).font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4).padding(.vertical, 2)
                                .background(fichier.genre == "pdf" ? Color(hex: 0xFF3B30) : Color(hex: 0x8E8E93),
                                            in: RoundedRectangle(cornerRadius: 3))
                                .padding(4)
                        }
                }
            }
            Text(magasin.nom(fichier)).font(.system(size: 12)).foregroundStyle(.white)
                .lineLimit(1).truncationMode(.middle)
            Text(fichier.genre == "dossier" ? "\(fichier.elements) éléments" : "\(fichier.date) · \(fichier.taille)")
                .font(.system(size: 10)).foregroundStyle(.secondary)
            Text(fichier.emplacement).font(.system(size: 10)).foregroundStyle(.secondary)
        }
    }
}

struct LigneFichier: View {
    @ObservedObject private var magasin = MagasinFichiers.partage
    let fichier: FichierItem
    var body: some View {
        HStack(spacing: 12) {
            if fichier.genre == "dossier" {
                Image(systemName: "folder.fill").font(.system(size: 26)).foregroundStyle(Color(hex: 0x54A5F5)).frame(width: 36)
            } else if fichier.genre == "image", let pid = fichier.photoId, let img = ChargeurPhoto.image(pid) {
                Image(uiImage: img).resizable().scaledToFill().frame(width: 32, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 4)).frame(width: 36)
            } else {
                Image(systemName: "doc.fill").font(.system(size: 26)).foregroundStyle(.white.opacity(0.85)).frame(width: 36)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(magasin.nom(fichier)).font(.system(size: 15)).foregroundStyle(.white).lineLimit(1)
                Text(fichier.genre == "dossier" ? "\(fichier.date) · \(fichier.elements) éléments" : "\(fichier.date) · \(fichier.taille)")
                    .font(.system(size: 12)).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// ============================================================ PARTAGÉ (état vide réel)
struct PartageFichiersVue: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Partagé").font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 6)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                Text("Rechercher").foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "mic.fill").foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12).frame(height: 38)
            .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 11))
            .padding(.horizontal, 16).padding(.top, 10)
            Spacer()
            Image(systemName: "folder.fill.badge.person.crop").font(.system(size: 46)).foregroundStyle(.secondary)
            Text("Aucun fichier partagé").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white).padding(.top, 12)
            Text("Les fichiers partagés apparaîtront ici.").font(.system(size: 13)).foregroundStyle(.secondary).padding(.top, 2)
            Spacer()
            Spacer()
        }
    }
}

// ============================================================ EXPLORER
struct ExplorerFichiersVue: View {
    @ObservedObject private var magasin = MagasinFichiers.partage
    @State private var dossierOuvert: FichierItem? = nil
    @State private var tagOuvert: String? = nil
    @State private var supprimesVisible = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Explorer").font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        Text("Rechercher").foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "mic.fill").foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12).frame(height: 38)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 11))

                    HStack {
                        Text("Favoris").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "chevron.down").font(.system(size: 11, weight: .semibold)).foregroundStyle(Color(hex: 0x0A84FF))
                    }
                    .padding(.top, 4)
                    VStack(spacing: 0) {
                        ForEach(magasin.visibles.filter { $0.genre == "dossier" }) { d in
                            HStack(spacing: 10) {
                                Image(systemName: "folder").font(.system(size: 17)).foregroundStyle(Color(hex: 0x54A5F5))
                                Text(magasin.nom(d)).font(.system(size: 15)).foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 11)
                            .contentShape(Rectangle())
                            .onTapGesture { dossierOuvert = d }
                            if d.id != magasin.visibles.filter({ $0.genre == "dossier" }).last?.id {
                                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 40)
                            }
                        }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))

                    HStack {
                        Text("Emplacements").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "chevron.down").font(.system(size: 11, weight: .semibold)).foregroundStyle(Color(hex: 0x0A84FF))
                    }
                    .padding(.top, 4)
                    VStack(spacing: 0) {
                        LigneEmplacement(symbole: "iphone", nom: "Sur mon iPhone")
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 40)
                        LigneEmplacement(symbole: "icloud.fill", nom: "iCloud Drive")
                        Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 40)
                        HStack(spacing: 10) {
                            Image(systemName: "trash").font(.system(size: 16)).foregroundStyle(.secondary)
                            Text("Suppressions récentes").font(.system(size: 15)).foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 11)
                        .contentShape(Rectangle())
                        .onTapGesture { supprimesVisible = true }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))

                    Text("Tags").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary).padding(.top, 4)
                    VStack(spacing: 0) {
                        ForEach(DonneesFichiers.tags, id: \.0) { t in
                            HStack(spacing: 10) {
                                Circle().fill(Color(hex: UInt(t.1))).frame(width: 12, height: 12)
                                Text(t.0).font(.system(size: 15)).foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .onTapGesture { tagOuvert = t.0 }
                            if t.0 != DonneesFichiers.tags.last?.0 {
                                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 36)
                            }
                        }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))
                    Spacer(minLength: 110)
                }
                .padding(.horizontal, 16).padding(.top, 6)
            }
            .background(Color.black)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $dossierOuvert) { d in DossierFichiersVue(dossier: d) }
            .sheet(isPresented: Binding(get: { tagOuvert != nil }, set: { if !$0 { tagOuvert = nil } })) {
                TagFichiersVue(tag: tagOuvert ?? "")
            }
            .sheet(isPresented: $supprimesVisible) { SuppressionsFichiersVue() }
        }
        .preferredColorScheme(.dark)
    }
}

struct LigneEmplacement: View {
    let symbole: String
    let nom: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbole).font(.system(size: 16)).foregroundStyle(Color(hex: 0x54A5F5))
            Text(nom).font(.system(size: 15)).foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
    }
}

// Dossier ouvert (grille comme la référence)
struct DossierFichiersVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinFichiers.partage
    let dossier: FichierItem
    @State private var apercu: FichierItem? = nil
    private var contenus: [FichierItem] { magasin.visibles.filter { $0.dossier == dossier.nom } }
    var body: some View {
        NavigationStack {
            ScrollView {
                if contenus.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "folder").font(.system(size: 42)).foregroundStyle(.secondary)
                        Text("Dossier vide").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 120)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible())], spacing: 18) {
                        ForEach(contenus) { f in
                            TuileFichier(fichier: f).onTapGesture { apercu = f }
                        }
                    }
                    .padding(16)
                }
            }
            .background(Color.black)
            .navigationTitle(magasin.nom(dossier))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            .fullScreenCover(item: $apercu) { f in ApercuFichierVue(fichier: f) }
        }
        .preferredColorScheme(.dark)
    }
}

// Tag ouvert (état vide ou fichiers marqués)
struct TagFichiersVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinFichiers.partage
    let tag: String
    private var marques: [FichierItem] { magasin.visibles.filter { $0.tag == tag } }
    var body: some View {
        NavigationStack {
            Group {
                if marques.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "tag").font(.system(size: 42)).foregroundStyle(.secondary)
                        Text("Aucun fichier avec tag").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        Text("Les fichiers associés au tag « \(tag) » apparaîtront ici.")
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(marques) { f in
                                LigneFichier(fichier: f)
                                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 52)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.black)
            .navigationTitle(tag)
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

// Suppressions récentes
struct SuppressionsFichiersVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinFichiers.partage
    private var supprimesListe: [FichierItem] { DonneesFichiers.tout.filter { magasin.supprimes.contains($0.id) } }
    var body: some View {
        NavigationStack {
            Group {
                if supprimesListe.isEmpty {
                    VStack(spacing: 10) {
                        Text("Les éléments récemment supprimés peuvent être effacés définitivement par votre fournisseur de stockage.")
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center).padding(.horizontal, 36)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(supprimesListe) { f in
                                LigneFichier(fichier: f)
                                    .contextMenu {
                                        Button { magasin.supprimes.remove(f.id) } label: { Label("Récupérer", systemImage: "arrow.uturn.backward") }
                                    }
                                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 52)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.black)
            .navigationTitle("Suppressions récentes")
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

// ============================================================ APERÇU (Coup d'œil)
struct ApercuFichierVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinFichiers.partage
    let fichier: FichierItem
    @State private var infosVisible = false
    @State private var partageVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 30, height: 30).background(Color(hex: 0x2C2C2E), in: Circle())
                    }
                    Spacer()
                    Text(magasin.nom(fichier)).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                    Spacer()
                    Image(systemName: "square.and.arrow.up").font(.system(size: 16)).foregroundStyle(Color(hex: 0x0A84FF))
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                        .onTapGesture { partageVisible = true }
                }
                .padding(.horizontal, 14).padding(.top, 8)

                Spacer()
                if fichier.genre == "image", let pid = fichier.photoId, let img = ChargeurPhoto.image(pid) {
                    Image(uiImage: img).resizable().scaledToFit().frame(maxWidth: .infinity)
                } else if fichier.genre == "pdf" {
                    // Page factice (le contenu réel arrive avec l'or narratif propre à chaque document)
                    VStack(alignment: .leading, spacing: 10) {
                        Text(magasin.nom(fichier).replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 17, weight: .bold)).foregroundStyle(.black)
                        ForEach(0..<14, id: \.self) { i in
                            Capsule().fill(Color(hex: 0xD5D9DE)).frame(height: 6)
                                .padding(.trailing, i % 4 == 3 ? 70 : 0)
                        }
                        Spacer()
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, maxHeight: 560, alignment: .topLeading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 4))
                    .padding(.horizontal, 22)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "doc.zipper").font(.system(size: 52)).foregroundStyle(.secondary)
                        Text(magasin.nom(fichier)).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        Text(fichier.taille).font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                }
                Spacer()

                HStack {
                    Image(systemName: "square.and.arrow.up").onTapGesture { partageVisible = true }
                    Spacer()
                    Image(systemName: "info.circle").onTapGesture { infosVisible = true }
                    Spacer()
                    Image(systemName: "trash").onTapGesture { magasin.supprimes.insert(fichier.id); dismiss() }
                }
                .font(.system(size: 19)).foregroundStyle(Color(hex: 0x0A84FF))
                .padding(.horizontal, 34).padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }

            BarreHome { dismiss() }
        }
        .sheet(isPresented: $infosVisible) { InfosFichierVue(fichier: fichier) }
        .sheet(isPresented: $partageVisible) { FeuillePartage(element: magasin.nom(fichier)) }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ INFOS (référence : fiche complète)
struct InfosFichierVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinFichiers.partage
    let fichier: FichierItem

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 14) {
                        if fichier.genre == "image", let pid = fichier.photoId, let img = ChargeurPhoto.image(pid) {
                            Image(uiImage: img).resizable().scaledToFill()
                                .frame(width: 74, height: 92).clipShape(RoundedRectangle(cornerRadius: 6))
                        } else {
                            Image(systemName: fichier.genre == "dossier" ? "folder.fill" : "doc.fill")
                                .font(.system(size: 46)).foregroundStyle(Color(hex: 0x54A5F5))
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(magasin.nom(fichier)).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                            Text("\(fichier.genre.uppercased()) · \(fichier.taille)").font(.system(size: 13)).foregroundStyle(.secondary)
                            Text("Ouvrir").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                                .padding(.horizontal, 14).padding(.vertical, 5)
                                .background(Color(hex: 0x0A84FF), in: Capsule())
                                .padding(.top, 3)
                        }
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        LigneInfoFichier(cle: "Type", valeur: fichier.genre == "image" ? "Image PNG" : fichier.genre.uppercased())
                        LigneInfoFichier(cle: "Taille", valeur: fichier.taille)
                        LigneInfoFichier(cle: "Création", valeur: fichier.creation)
                        LigneInfoFichier(cle: "Modification", valeur: fichier.creation)
                        LigneInfoFichier(cle: "Où", valeur: fichier.emplacement, valeurBleue: true)
                        if fichier.genre == "image" {
                            LigneInfoFichier(cle: "Dimensions", valeur: "1206 × 2622")
                            LigneInfoFichier(cle: "Profil de couleur", valeur: "sRGB IEC61966-2.1", derniere: true)
                        } else {
                            LigneInfoFichier(cle: "Tags", valeur: fichier.tag ?? "Ajouter des tags", derniere: true)
                        }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Infos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
    }
}

struct LigneInfoFichier: View {
    let cle: String
    let valeur: String
    var valeurBleue: Bool = false
    var derniere: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(cle).font(.system(size: 14)).foregroundStyle(.secondary)
                Spacer()
                Text(valeur).font(.system(size: 14)).foregroundStyle(valeurBleue ? Color(hex: 0x0A84FF) : .white)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            if !derniere { Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 14) }
        }
    }
}
