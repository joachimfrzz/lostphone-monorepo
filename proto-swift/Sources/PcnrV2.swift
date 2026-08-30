import SwiftUI

// Chargeur pellicule : les fichiers Ressources/ sont des .jpg — UIImage(named:)
// exige l'extension pour le non-PNG (cause des replis dégradés/initiales, S2/S5).
func chargerPellicule(_ nom: String) -> UIImage? {
    UIImage(named: nom) ?? UIImage(named: nom + ".jpg") ?? UIImage(named: nom + ".jpeg") ?? UIImage(named: nom + ".png")
}

// ============================================================
// S5 V2 — PHOTOS / CALENDRIER / NOTES / RAPPELS (D80, réf XML S5 du 29/08)
// Structure réelle mesurée : Photothèque (compteur d'éléments, Trier et
// filtrer, Sélect., onglets bas), Collections (Souvenirs, Types de média,
// Plan), détail photo ; Calendrier mois + jour (« Un seul jour ») ;
// Notes dossiers + liste (sections Aujourd'hui/Hier/7 jours précédents) ;
// Rappels accueil (cartes + Mes listes + Suppressions récentes) + liste
// à sections. Données Sarah (D59) — le contenu réel ne rentre jamais.
// ============================================================

struct PcnrV2Capture: View {
    let cle: String
    var body: some View {
        switch cle {
        case "pcnr2.photos.phototheque": PhotothequeV2Vue()
        case "pcnr2.photos.collections": CollectionsPhotosV2Vue()
        case "pcnr2.photos.detail": PhotoDetailV2Vue()
        case "pcnr2.cal.mois": CalMoisV2Vue()
        case "pcnr2.cal.jour": CalJourV2Vue()
        case "pcnr2.notes.dossiers": NotesDossiersV2Vue()
        case "pcnr2.notes.liste": NotesListeV2Vue()
        case "pcnr2.rappels.accueil": RappelsAccueilV2Vue()
        case "pcnr2.rappels.liste": RappelsListeV2Vue()
        default: PhotothequeV2Vue()
        }
    }
}

// MARK: - Tuile photo avec repli (pellicule Ressources/ → dégradé)
struct TuilePhotoV2: View {
    let nom: String
    let teinte: Color
    var body: some View {
        GeometryReader { geo in
            if let img = chargerPellicule(nom) {
                Color.clear.overlay(Image(uiImage: img).resizable().scaledToFill()).clipped()
            } else {
                LinearGradient(colors: [teinte.opacity(0.55), teinte.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        .clipped()
    }
}

// MARK: - Photos : Photothèque (réf 046 — grille, compteur, onglets bas)
struct PhotothequeV2Vue: View {
    let teintes: [Color] = [.orange, .teal, .indigo, .pink, .green, .brown, .cyan, .purple, .mint, .red, .blue, .yellow]
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Photothèque").font(.system(size: 22, weight: .bold))
                    Text("1 243 éléments").font(.system(size: 13)).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.arrow.down").font(.system(size: 15, weight: .semibold))
                    .padding(9).background(Color(white: 0.16), in: Circle())
                Text("Sélect.").font(.system(size: 15, weight: .medium))
                    .padding(.horizontal, 13).padding(.vertical, 8)
                    .background(Color(white: 0.16), in: Capsule())
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 10)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                    ForEach(0..<21, id: \.self) { i in
                        ZStack(alignment: .bottomLeading) {
                            TuilePhotoV2(nom: "p" + String(format: "%02d", (i % 15) + 1), teinte: teintes[i % teintes.count])
                                .frame(height: 128)
                            if i == 9 {
                                HStack(spacing: 3) {
                                    Image(systemName: "video.fill").font(.system(size: 10))
                                    Text("0:35").font(.system(size: 11, weight: .medium))
                                }
                                .foregroundStyle(.white)
                                .padding(5)
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            HStack {
                VStack(spacing: 3) {
                    Image(systemName: "photo.fill.on.rectangle.fill").font(.system(size: 20))
                    Text("Photothèque").font(.system(size: 10))
                }
                .foregroundStyle(.white)
                Spacer()
                VStack(spacing: 3) {
                    Image(systemName: "square.stack").font(.system(size: 20))
                    Text("Collections").font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
                Spacer()
                VStack(spacing: 3) {
                    Image(systemName: "magnifyingglass").font(.system(size: 20))
                    Text("Recherche").font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40).padding(.top, 8).padding(.bottom, 4)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Photos : Collections (réf 043/076/091 — Souvenirs, Types de média, Plan)
struct CollectionsPhotosV2Vue: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("Collections").font(.system(size: 30, weight: .bold))
                        Spacer()
                        Image(systemName: "ellipsis").font(.system(size: 16, weight: .semibold))
                            .padding(10).background(Color(white: 0.16), in: Circle())
                    }
                    .padding(.top, 8)
                    HStack {
                        Text("Souvenirs").font(.system(size: 20, weight: .bold))
                        Spacer()
                        Text("Tout").font(.system(size: 15)).foregroundStyle(.blue)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ZStack(alignment: .bottomLeading) {
                                TuilePhotoV2(nom: "p07", teinte: .teal).frame(width: 250, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                Text("Étés au lac d'Annecy").font(.system(size: 16, weight: .bold)).foregroundStyle(.white).padding(12)
                            }
                            ZStack(alignment: .bottomLeading) {
                                TuilePhotoV2(nom: "p11", teinte: .indigo).frame(width: 250, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                Text("Au fil des ans").font(.system(size: 16, weight: .bold)).foregroundStyle(.white).padding(12)
                            }
                        }
                    }
                    Text("Types de média").font(.system(size: 20, weight: .bold)).padding(.top, 6)
                    VStack(spacing: 0) {
                        LigneCollectionV2(icone: "video", nom: "Vidéos", compte: "58")
                        Divider().padding(.leading, 44)
                        LigneCollectionV2(icone: "person.crop.square", nom: "Selfies", compte: "112")
                        Divider().padding(.leading, 44)
                        LigneCollectionV2(icone: "camera.viewfinder", nom: "Captures d'écran", compte: "204")
                    }
                    .background(Color(white: 0.11), in: RoundedRectangle(cornerRadius: 12))
                    Text("Plan").font(.system(size: 20, weight: .bold)).padding(.top, 6)
                    ZStack {
                        RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.14)).frame(height: 130)
                        VStack(spacing: 6) {
                            Image(systemName: "map").font(.system(size: 26)).foregroundStyle(.secondary)
                            Text("868 photos géolocalisées").font(.system(size: 13)).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            HStack {
                VStack(spacing: 3) {
                    Image(systemName: "photo.fill.on.rectangle.fill").font(.system(size: 20))
                    Text("Photothèque").font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
                Spacer()
                VStack(spacing: 3) {
                    Image(systemName: "square.stack").font(.system(size: 20))
                    Text("Collections").font(.system(size: 10))
                }
                .foregroundStyle(.white)
                Spacer()
                VStack(spacing: 3) {
                    Image(systemName: "magnifyingglass").font(.system(size: 20))
                    Text("Recherche").font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40).padding(.top, 8).padding(.bottom, 4)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

struct LigneCollectionV2: View {
    let icone: String; let nom: String; let compte: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icone).font(.system(size: 17)).foregroundStyle(.blue).frame(width: 26)
            Text(nom).font(.system(size: 16))
            Spacer()
            Text(compte).font(.system(size: 15)).foregroundStyle(.secondary)
            Image(systemName: "chevron.forward").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
    }
}

// MARK: - Photos : détail (réf 013 — Précédent / Jeudi 08:45 / Plus, barre basse)
struct PhotoDetailV2Vue: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.backward").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                    .padding(10).background(Color(white: 0.18), in: Circle())
                Spacer()
                VStack(spacing: 1) {
                    Text("Jeudi").font(.system(size: 15, weight: .semibold))
                    Text("08:45").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "ellipsis").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    .padding(10).background(Color(white: 0.18), in: Circle())
            }
            .padding(.horizontal, 14).padding(.top, 6)
            Spacer()
            TuilePhotoV2(nom: "p04", teinte: .orange)
                .frame(height: 480)
            Spacer()
            HStack {
                Image(systemName: "square.and.arrow.up").font(.system(size: 20))
                Spacer()
                Image(systemName: "heart").font(.system(size: 20))
                Spacer()
                Image(systemName: "info.circle").font(.system(size: 20))
                Spacer()
                Image(systemName: "trash").font(.system(size: 20))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 34).padding(.vertical, 12)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Calendrier : mois (réf 014/026 — Août, « Un seul jour », Rechercher, Ajouter)
struct CalMoisV2Vue: View {
    let jours = ["L", "M", "M", "J", "V", "S", "D"]
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "chevron.backward").font(.system(size: 17, weight: .semibold))
                    Text("Août").font(.system(size: 17))
                }
                .foregroundStyle(.red)
                Spacer()
                HStack(spacing: 18) {
                    Image(systemName: "square.split.2x2")
                    Image(systemName: "magnifyingglass")
                    Image(systemName: "plus")
                }
                .font(.system(size: 17)).foregroundStyle(.red)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            Text("août 2026").font(.system(size: 26, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16).padding(.bottom, 10)
            HStack {
                ForEach(0..<7, id: \.self) { i in
                    Text(jours[i]).font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 6)
            let semaines: [[Int]] = [[0,0,0,0,0,1,2],[3,4,5,6,7,8,9],[10,11,12,13,14,15,16],[17,18,19,20,21,22,23],[24,25,26,27,28,29,30],[31,0,0,0,0,0,0]]
            VStack(spacing: 14) {
                ForEach(0..<semaines.count, id: \.self) { r in
                    HStack {
                        ForEach(0..<7, id: \.self) { c in
                            let j = semaines[r][c]
                            VStack(spacing: 4) {
                                if j == 0 {
                                    Text(" ").font(.system(size: 17))
                                } else if j == 29 {
                                    Text("29").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                                        .frame(width: 34, height: 34).background(Color.red, in: Circle())
                                } else {
                                    Text(String(j)).font(.system(size: 17)).frame(width: 34, height: 34)
                                }
                                Circle().fill([17, 20, 27].contains(j) ? Color.secondary : Color.clear).frame(width: 5, height: 5)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            Spacer()
            HStack {
                Text("Aujourd'hui").foregroundStyle(.red)
                Spacer()
                Text("Calendriers").foregroundStyle(.red)
                Spacer()
                Text("Notifications").foregroundStyle(.red)
            }
            .font(.system(size: 16))
            .padding(.horizontal, 18).padding(.vertical, 12)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Calendrier : jour (réf 014 — grille horaire + évènement)
struct CalJourV2Vue: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "chevron.backward").font(.system(size: 17, weight: .semibold))
                    Text("Août").font(.system(size: 17))
                }
                .foregroundStyle(.red)
                Spacer()
                HStack(spacing: 18) {
                    Image(systemName: "magnifyingglass")
                    Image(systemName: "plus")
                }
                .font(.system(size: 17)).foregroundStyle(.red)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            Text("Lundi 17 août 2026").font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16).padding(.bottom, 8)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(8..<19, id: \.self) { h in
                        HStack(alignment: .top, spacing: 8) {
                            Text(String(format: "%02d:00", h))
                                .font(.system(size: 11)).foregroundStyle(.secondary)
                                .frame(width: 42, alignment: .trailing)
                            VStack(spacing: 0) {
                                Divider()
                                if h == 11 {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 2).fill(Color.blue).frame(width: 4)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("Agence Bellecour — estimation").font(.system(size: 13, weight: .semibold))
                                            Text("11:30 – 12:30 · Lyon 2e").font(.system(size: 11)).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(6)
                                    .background(Color.blue.opacity(0.22), in: RoundedRectangle(cornerRadius: 6))
                                    .padding(.top, 20)
                                } else if h == 17 {
                                    HStack {
                                        RoundedRectangle(cornerRadius: 2).fill(Color.green).frame(width: 4)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("Kiné — Marie Fabre").font(.system(size: 13, weight: .semibold))
                                            Text("17:30 – 18:15").font(.system(size: 11)).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(6)
                                    .background(Color.green.opacity(0.22), in: RoundedRectangle(cornerRadius: 6))
                                    .padding(.top, 24)
                                } else {
                                    Color.clear.frame(height: 52)
                                }
                            }
                        }
                        .frame(minHeight: 56, alignment: .top)
                        .padding(.horizontal, 10)
                    }
                }
            }
            HStack {
                Text("Aujourd'hui").foregroundStyle(.red)
                Spacer()
                Text("Calendriers").foregroundStyle(.red)
                Spacer()
                Text("Notifications").foregroundStyle(.red)
            }
            .font(.system(size: 16))
            .padding(.horizontal, 18).padding(.vertical, 12)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Notes : dossiers (réf 050 — iCloud (toutes), compteurs, Nouvelle note)
struct NotesDossiersV2Vue: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("iCLOUD")) {
                    LigneDossierNotesV2(icone: "folder", nom: "iCloud (toutes)", compte: "214")
                    LigneDossierNotesV2(icone: "folder", nom: "Notes", compte: "186")
                    LigneDossierNotesV2(icone: "folder", nom: "Recettes", compte: "17")
                    LigneDossierNotesV2(icone: "folder", nom: "Appart", compte: "9")
                    LigneDossierNotesV2(icone: "trash", nom: "Suppressions récentes", compte: "2")
                }
            }
            .navigationTitle("Dossiers")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Text("Modifier").foregroundStyle(.orange).fixedSize() } }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Image(systemName: "folder.badge.plus").font(.system(size: 20)).foregroundStyle(.orange)
                    Spacer()
                    Image(systemName: "square.and.pencil").font(.system(size: 20)).foregroundStyle(.orange)
                }
                .padding(.horizontal, 18).padding(.vertical, 8)
                .background(.black.opacity(0.85))
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct LigneDossierNotesV2: View {
    let icone: String; let nom: String; let compte: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icone).font(.system(size: 17)).foregroundStyle(.orange).frame(width: 26)
            Text(nom).font(.system(size: 17))
            Spacer()
            Text(compte).font(.system(size: 16)).foregroundStyle(.secondary)
            Image(systemName: "chevron.forward").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
        }
    }
}

// MARK: - Notes : liste (réf 050 — sections temporelles, aperçu date + première ligne)
struct NotesListeV2Vue: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Épinglées")) {
                    LigneNoteV2(titre: "Liste valise week-end", apercu: "jeudi  Trousse de toilette, chargeur, livre", verrou: false)
                }
                Section(header: Text("Aujourd'hui")) {
                    LigneNoteV2(titre: "À dire à Chloé", apercu: "19:10  Pas au téléphone. En vrai.", verrou: false)
                    LigneNoteV2(titre: "Courses samedi", apercu: "19:09  Rôti, carottes, crème, vin blanc", verrou: false)
                }
                Section(header: Text("7 jours précédents")) {
                    LigneNoteV2(titre: "Codes", apercu: "mardi  Cette note est verrouillée", verrou: true)
                    LigneNoteV2(titre: "Idées cadeau maman", apercu: "lundi  Coffret thé, écharpe verte", verrou: false)
                    LigneNoteV2(titre: "Questions agence", apercu: "24/08  Frais ? Délai ? Estimation basse ?", verrou: false)
                }
            }
            .navigationTitle("Notes")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Image(systemName: "ellipsis.circle").foregroundStyle(.orange) } }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Text("214 notes").font(.system(size: 12)).foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "square.and.pencil").font(.system(size: 20)).foregroundStyle(.orange)
                }
                .padding(.horizontal, 18).padding(.vertical, 8)
                .background(.black.opacity(0.85))
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct LigneNoteV2: View {
    let titre: String; let apercu: String; let verrou: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(titre).font(.system(size: 16, weight: .semibold))
                if verrou { Image(systemName: "lock.fill").font(.system(size: 12)).foregroundStyle(.secondary) }
            }
            Text(apercu).font(.system(size: 14)).foregroundStyle(.secondary).lineLimit(1)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Rappels : accueil (réf 092 — cartes + Mes listes + Suppressions récentes)
struct RappelsAccueilV2Vue: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        CarteRappelsV2(icone: "calendar", teinte: .blue, nom: "Aujourd'hui", compte: "0")
                        CarteRappelsV2(icone: "calendar.badge.clock", teinte: .red, nom: "Programmés", compte: "1")
                        CarteRappelsV2(icone: "tray.fill", teinte: Color(white: 0.45), nom: "Tous", compte: "4")
                        CarteRappelsV2(icone: "flag.fill", teinte: .orange, nom: "Avec drapeau", compte: "0")
                        CarteRappelsV2(icone: "checkmark", teinte: Color(white: 0.45), nom: "Terminés", compte: "")
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Mes listes").font(.system(size: 20, weight: .bold))
                            .padding(.bottom, 8)
                        VStack(spacing: 0) {
                            LigneListeRappelsV2(pastille: .blue, icone: "list.bullet", nom: "Rappels", compte: "1")
                            Divider().padding(.leading, 48)
                            LigneListeRappelsV2(pastille: .orange, icone: "carrot.fill", nom: "Courses", compte: "3")
                            Divider().padding(.leading, 48)
                            LigneListeRappelsV2(pastille: Color(white: 0.4), icone: "trash", nom: "Suppressions récentes", compte: "15")
                        }
                        .background(Color(white: 0.11), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16).padding(.top, 6)
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Image(systemName: "ellipsis.circle").foregroundStyle(.blue) }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill").font(.system(size: 20))
                        Text("Nouveau rappel").font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.blue)
                    Spacer()
                    Text("Ajouter une liste").font(.system(size: 15)).foregroundStyle(.blue)
                }
                .padding(.horizontal, 18).padding(.vertical, 10)
                .background(.black.opacity(0.85))
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct CarteRappelsV2: View {
    let icone: String; let teinte: Color; let nom: String; let compte: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icone).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 30, height: 30).background(teinte, in: Circle())
                Spacer()
                Text(compte).font(.system(size: 24, weight: .bold))
            }
            Text(nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(white: 0.11), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct LigneListeRappelsV2: View {
    let pastille: Color; let icone: String; let nom: String; let compte: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icone).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                .frame(width: 28, height: 28).background(pastille, in: Circle())
            Text(nom).font(.system(size: 16))
            Spacer()
            Text(compte).font(.system(size: 15)).foregroundStyle(.secondary)
            Image(systemName: "chevron.forward").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }
}

// MARK: - Rappels : liste Courses (réf 074 — section « Fruits et légumes », cercles)
struct RappelsListeV2Vue: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Fruits et légumes").font(.system(size: 17, weight: .bold)).foregroundStyle(.orange).textCase(nil)) {
                    LigneRappelV2(titre: "Carottes")
                    LigneRappelV2(titre: "Pommes de terre")
                }
                Section(header: Text("Autres").font(.system(size: 17, weight: .bold)).foregroundStyle(.orange).textCase(nil)) {
                    LigneRappelV2(titre: "Rôti de bœuf (chez Perrin)")
                }
            }
            .navigationTitle("Courses")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.backward").font(.system(size: 17, weight: .semibold))
                        Text("Listes").fixedSize()
                    }
                    .foregroundStyle(.orange)
                }
                ToolbarItem(placement: .topBarTrailing) { Image(systemName: "ellipsis.circle").foregroundStyle(.orange) }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill").font(.system(size: 20))
                        Text("Nouveau rappel").font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.orange)
                    Spacer()
                }
                .padding(.horizontal, 18).padding(.vertical, 10)
                .background(.black.opacity(0.85))
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct LigneRappelV2: View {
    let titre: String
    var body: some View {
        HStack(spacing: 12) {
            Circle().stroke(Color.secondary, lineWidth: 1.5).frame(width: 22, height: 22)
            Text(titre).font(.system(size: 16))
            Spacer()
        }
        .padding(.vertical, 2)
    }
}
