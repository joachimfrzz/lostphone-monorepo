// Plans — construit contre la vidéo de référence du 20/08 (82 écrans, iOS 26)
// D51-2 : recherche, à proximité, fiche lieu complète, itinéraires multimodes avec alternatives,
// navigation guidée (mode clair). R3 : les Récents de Sarah = agence LCL, Western Union Part-Dieu,
// le kiné, la gare Part-Dieu (le billet du 28). L'historique de déplacement raconte tout.
import SwiftUI
import MapKit

// ============================================================ DONNÉES (remplaçables — D59)
struct LieuPlan: Identifiable {
    let id = UUID()
    var nom: String
    var sousTitre: String
    var categorie: String      // symbole SF
    var note: Double = 4.0
    var horaires: String = "Ouvert"
    var tel: String = "04 72 10 24 36"
    var distance: String = ""
    var lat: Double
    var lon: Double
}

enum DonneesPlans {
    static let recents: [LieuPlan] = [
        LieuPlan(nom: "LCL Agence Bellecour", sousTitre: "Depuis ma position", categorie: "building.columns.fill",
                 horaires: "Ouvert · ferme à 17:30", tel: "04 78 42 63 21", distance: "400 m", lat: 45.7578, lon: 4.8320),
        LieuPlan(nom: "Gare de Lyon Part-Dieu", sousTitre: "Il y a 7 jours", categorie: "tram.fill",
                 horaires: "Ouvert", tel: "3635", distance: "2,8 km", lat: 45.7605, lon: 4.8590),
        LieuPlan(nom: "Western Union — Part-Dieu", sousTitre: "13 juin", categorie: "banknote.fill",
                 horaires: "Ouvert · ferme à 19:00", tel: "04 72 60 51 33", distance: "2,7 km", lat: 45.7610, lon: 4.8570),
        LieuPlan(nom: "12 rue des Fantasques", sousTitre: "Cabinet kiné · jeudi", categorie: "cross.case.fill",
                 horaires: "Sur rendez-vous", distance: "850 m", lat: 45.7720, lon: 4.8390),
    ]
    static let proximite: [LieuPlan] = [
        LieuPlan(nom: "Boulangerie du Griffon", sousTitre: "Boulangerie", categorie: "fork.knife",
                 note: 4.6, horaires: "Ouvert · ferme à 20:00", tel: "04 78 27 61 45", distance: "160 m", lat: 45.7690, lon: 4.8350),
        LieuPlan(nom: "Café Mokxa", sousTitre: "Café", categorie: "cup.and.saucer.fill",
                 note: 4.5, horaires: "Fermé · ouvre à 08:00", tel: "04 78 27 84 25", distance: "300 m", lat: 45.7700, lon: 4.8330),
        LieuPlan(nom: "Pharmacie du Parc", sousTitre: "Pharmacie", categorie: "cross.fill",
                 note: 4.1, horaires: "Ouvert · ferme à 20:00", tel: "04 78 28 66 09", distance: "450 m", lat: 45.7660, lon: 4.8370),
        LieuPlan(nom: "Carrefour City Lyon 1er", sousTitre: "Supermarché", categorie: "cart.fill",
                 note: 3.8, horaires: "Ouvert · ferme à 23:00", tel: "04 72 98 33 40", distance: "220 m", lat: 45.7680, lon: 4.8310),
    ]
}

// ============================================================ APP
struct PlansVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.7660, longitude: 4.8350),
                           span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)))
    @State private var recherche = ""
    @State private var rechercheActive = false
    @State private var lieuOuvert: LieuPlan? = nil
    @State private var itineraireVers: LieuPlan? = nil
    @State private var navigationActive: LieuPlan? = nil

    private var resultats: [LieuPlan] {
        let tous = DonneesPlans.proximite + DonneesPlans.recents
        guard !recherche.isEmpty else { return [] }
        return tous.filter { $0.nom.localizedCaseInsensitiveContains(recherche) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                Annotation("Ma position", coordinate: CLLocationCoordinate2D(latitude: 45.7660, longitude: 4.8350)) {
                    Circle().fill(Color(hex: 0x0A84FF)).frame(width: 16, height: 16)
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                }
                ForEach(DonneesPlans.proximite) { l in
                    Annotation(l.nom, coordinate: CLLocationCoordinate2D(latitude: l.lat, longitude: l.lon)) {
                        Circle().fill(Color(hex: 0xE8873D)).frame(width: 24, height: 24)
                            .overlay(Image(systemName: l.categorie).font(.system(size: 10)).foregroundStyle(.white))
                            .onTapGesture { lieuOuvert = l }
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .ignoresSafeArea()

            // Miroir lot 3 : pastille météo (haut gauche) + pile de boutons (droite), référence v11
            VStack {
                HStack(alignment: .top) {
                    VStack(spacing: 1) {
                        HStack(spacing: 3) {
                            Image(systemName: "sun.max.fill").font(.system(size: 11)).foregroundStyle(Color(hex: 0xFFD60A))
                            Text("24°").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                        }
                        Text("Air : 42").font(.system(size: 9)).foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 9).padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 11))
                    Spacer()
                    VStack(spacing: 0) {
                        Image(systemName: "car.fill").font(.system(size: 15)).foregroundStyle(.white.opacity(0.9))
                            .frame(width: 42, height: 42)
                        Divider().frame(width: 42).overlay(Color.white.opacity(0.15))
                        Image(systemName: "location").font(.system(size: 15)).foregroundStyle(.white.opacity(0.9))
                            .frame(width: 42, height: 42)
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 10).padding(.top, 4)
                Spacer()
            }

            // Feuille basse (recherche + lieux + récents)
            VStack(spacing: 12) {
                Capsule().fill(Color(hex: 0x5A5A5E)).frame(width: 36, height: 5).padding(.top, 8)
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Plans d'Apple", text: $recherche)
                            .foregroundStyle(.white)
                            .onTapGesture { rechercheActive = true }
                        Image(systemName: "mic.fill").foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12).frame(height: 40)
                    .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 11))
                    Circle().fill(Color(hex: 0x2C2C2E)).frame(width: 40, height: 40)
                        .overlay(Text("S").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white))
                }
                .padding(.horizontal, 14)

                if !recherche.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(resultats) { l in
                            Button { lieuOuvert = l; recherche = "" } label: {
                                HStack(spacing: 12) {
                                    Circle().fill(Color(hex: 0xE8873D)).frame(width: 34, height: 34)
                                        .overlay(Image(systemName: l.categorie).font(.system(size: 14)).foregroundStyle(.white))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(l.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                                        Text("\(l.distance) · \(l.sousTitre)").font(.system(size: 12.5)).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 16).padding(.vertical, 8)
                            }
                        }
                        if resultats.isEmpty {
                            Text("Aucun résultat").font(.system(size: 14)).foregroundStyle(.secondary).padding(.vertical, 14)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Lieux").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                            Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(.secondary)
                            Spacer()
                        }
                        HStack(spacing: 20) {
                            LieuRapide(symbole: "house.fill", couleur: 0x5AA3DC, nom: "Domicile", sous: "Proche") {
                                lieuOuvert = LieuPlan(nom: "Domicile", sousTitre: "14 rue des Capucins, Lyon",
                                                      categorie: "house.fill", horaires: "—", distance: "0 m",
                                                      lat: 45.7699, lon: 4.8290)
                            }
                            LieuRapide(symbole: "cross.case.fill", couleur: 0x8B5CF6, nom: "Kiné", sous: "jeudi") {
                                lieuOuvert = DonneesPlans.recents[3]
                            }
                            LieuRapide(symbole: "tram.fill", couleur: 0x0A84FF, nom: "Transports", sous: "À proximité") {
                                lieuOuvert = DonneesPlans.recents[1]
                            }
                            LieuRapide(symbole: "plus", couleur: 0x3A3A3C, nom: "Ajouter", sous: "") { }
                        }
                        HStack {
                            Text("Récents").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                            Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.top, 4)
                        ForEach(DonneesPlans.recents) { l in
                            Button { lieuOuvert = l } label: {
                                HStack(spacing: 12) {
                                    Circle().fill(Color(hex: 0x3A3A3C)).frame(width: 34, height: 34)
                                        .overlay(Image(systemName: l.categorie).font(.system(size: 14)).foregroundStyle(.white))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(l.nom).font(.system(size: 15)).foregroundStyle(.white)
                                        Text(l.sousTitre).font(.system(size: 12.5)).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "ellipsis").font(.system(size: 14)).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 3)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                Spacer(minLength: 10)
            }
            .frame(maxHeight: recherche.isEmpty ? 330 : 380, alignment: .top)
            .background(.ultraThinMaterial, in: UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))

            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $lieuOuvert) { l in
            FicheLieuVue(lieu: l) { itineraireVers = l; lieuOuvert = nil }
        }
        .sheet(item: $itineraireVers) { l in
            ItinerairePlanVue(lieu: l) { navigationActive = l; itineraireVers = nil }
        }
        .fullScreenCover(item: $navigationActive) { l in
            NavigationGuideeVue(lieu: l)
        }
    }
}

struct LieuRapide: View {
    let symbole: String
    let couleur: UInt
    let nom: String
    let sous: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Circle().fill(Color(hex: couleur)).frame(width: 48, height: 48)
                    .overlay(Image(systemName: symbole).font(.system(size: 19)).foregroundStyle(.white))
                Text(nom).font(.system(size: 12)).foregroundStyle(.white)
                if !sous.isEmpty {
                    Text(sous).font(.system(size: 10)).foregroundStyle(.secondary)
                }
            }
        }
    }
}

extension LieuPlan: Hashable {
    static func == (a: LieuPlan, b: LieuPlan) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// ============================================================ FICHE LIEU
struct FicheLieuVue: View {
    @Environment(\.dismiss) private var dismiss
    let lieu: LieuPlan
    let itineraire: () -> Void
    @State private var alerte: String? = nil
    @State private var noterVisible = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        Button(action: itineraire) {
                            VStack(spacing: 3) {
                                Image(systemName: "car.fill").font(.system(size: 16))
                                Text("Itinéraire").font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 11)
                            .background(Color(hex: 0x0A84FF), in: RoundedRectangle(cornerRadius: 12))
                        }
                        BoutonFiche(symbole: "phone.fill", nom: "Appeler") { Routeur.partage.allerTelephone(lieu.tel) }
                        BoutonFiche(symbole: "safari.fill", nom: "Site web") {
                            // P3/P4 : ouvre Safari sur une page locale rendue pour ce lieu
                            let slug = lieu.nom.folding(options: .diacriticInsensitive, locale: .current)
                                .lowercased().replacingOccurrences(of: " ", with: "")
                                .filter { $0.isLetter || $0.isNumber }
                            Routeur.partage.allerSafari(page: "site:" + lieu.nom, url: slug + ".fr")
                        }
                    }
                    VStack(spacing: 0) {
                        HStack {
                            Text("Horaires").foregroundStyle(.white)
                            Spacer()
                            Text(lieu.horaires).font(.system(size: 14))
                                .foregroundStyle(lieu.horaires.hasPrefix("Ouvert") ? Color(hex: 0x30D158) : .secondary)
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x3A3A3C))
                        HStack {
                            Text("Distance").foregroundStyle(.white)
                            Spacer()
                            Text(lieu.distance).font(.system(size: 14)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        Divider().overlay(Color(hex: 0x3A3A3C))
                        HStack {
                            Text("Note").foregroundStyle(.white)
                            Spacer()
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill").font(.system(size: 12)).foregroundStyle(Color(hex: 0xE8C33D))
                                Text(String(format: "%.1f", lieu.note)).font(.system(size: 14)).foregroundStyle(.secondary)
                            }
                        }
                        .padding(14)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    Button { noterVisible = true } label: {
                        HStack {
                            Text("Noter ce lieu").foregroundStyle(.white)
                            Spacer()
                            HStack(spacing: 8) {
                                ForEach(0..<5, id: \.self) { _ in
                                    Image(systemName: "star").foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle(lieu.nom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 28, height: 28).background(Color(hex: 0x2C2C2E), in: Circle())
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
        .alert(titreAlerte, isPresented: Binding(get: { alerte != nil }, set: { if !$0 { alerte = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(messageAlerte) }
        .sheet(isPresented: $noterVisible) { NoterLieuVue(nom: lieu.nom) }
    }

    private var titreAlerte: String {
        switch alerte {
        case "appel": return lieu.nom
        case "web": return "Safari"
        default: return "Noter ce lieu"
        }
    }
    private var messageAlerte: String {
        switch alerte {
        case "appel": return "Ouvrez l'app Téléphone pour appeler ce lieu."
        case "web": return ErreurLambda.reponse("app.attente")
        default: return "Connectez-vous avec votre compte Apple pour noter ce lieu."
        }
    }
}

struct BoutonFiche: View {
    let symbole: String
    let nom: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: symbole).font(.system(size: 16))
                Text(nom).font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(Color(hex: 0x0A84FF))
            .frame(maxWidth: .infinity).padding(.vertical, 11)
            .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// ============================================================ ITINÉRAIRE (multimodes + alternatives)
struct ItinerairePlanVue: View {
    @Environment(\.dismiss) private var dismiss
    let lieu: LieuPlan
    let demarrer: () -> Void
    @State private var mode = 0

    private var alternatives: [(String, String, String)] {
        switch mode {
        case 1: return [("28 min", "Arrivée à 20:32 · 2,1 km", "Le plus rapide"),
                        ("34 min", "Arrivée à 20:38 · 2,4 km", "Moins de dénivelé")]
        case 2: return [("18 min", "Départ du bus prévu à 20:12 · C13", "Le plus rapide"),
                        ("24 min", "Départ du métro prévu à 20:16 · Ligne A", "Moins de marche")]
        case 3: return [("11 min", "Arrivée à 20:15 · 2,2 km", "Piste cyclable"),
                        ("13 min", "Arrivée à 20:17 · 2,5 km", "Moins de côtes")]
        default: return [("7 min", "Arrivée à 20:11 · \(lieu.distance)", "Le plus rapide"),
                         ("9 min", "Arrivée à 20:13", "Moins d'émissions"),
                         ("12 min", "Arrivée à 20:16", "Évite les grands axes")]
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("", selection: $mode) {
                        Image(systemName: "car.fill").tag(0)
                        Image(systemName: "figure.walk").tag(1)
                        Image(systemName: "tram.fill").tag(2)
                        Image(systemName: "bicycle").tag(3)
                    }
                    .pickerStyle(.segmented)
                    VStack(spacing: 0) {
                        HStack(spacing: 10) {
                            Circle().fill(Color(hex: 0x0A84FF)).frame(width: 10, height: 10)
                            Text("Ma position").foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "line.3.horizontal").foregroundStyle(.secondary)
                        }
                        .padding(13)
                        Divider().overlay(Color(hex: 0x3A3A3C)).padding(.leading, 32)
                        HStack(spacing: 10) {
                            Circle().fill(Color(hex: 0xFF453A)).frame(width: 10, height: 10)
                            Text(lieu.nom).foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(13)
                        Divider().overlay(Color(hex: 0x3A3A3C)).padding(.leading, 32)
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill").font(.system(size: 15)).foregroundStyle(Color(hex: 0x0A84FF))
                            Text("Ajouter un arrêt").font(.system(size: 15)).foregroundStyle(Color(hex: 0x0A84FF))
                            Spacer()
                        }
                        .padding(13)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))

                    ForEach(0..<alternatives.count, id: \.self) { i in
                        let a = alternatives[i]
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(a.0).font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                                Text(a.1).font(.system(size: 13)).foregroundStyle(.secondary)
                                Text(a.2).font(.system(size: 12.5)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(action: demarrer) {
                                VStack(spacing: 2) {
                                    Image(systemName: "figure.walk.departure").font(.system(size: 15))
                                    Text("Aller").font(.system(size: 13, weight: .bold))
                                }
                                .foregroundStyle(.white)
                                .frame(width: 62, height: 56)
                                .background(Color(hex: 0x30D158), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(14)
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    }
                    Text("Les itinéraires plus écologiques sont encouragés. En savoir plus")
                        .font(.system(size: 11.5)).foregroundStyle(.secondary)
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Itinéraire")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 28, height: 28).background(Color(hex: 0x2C2C2E), in: Circle())
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
    }
}

// ============================================================ NAVIGATION GUIDÉE (mode clair, comme la référence)
struct NavigationGuideeVue: View {
    @Environment(\.dismiss) private var dismiss
    let lieu: LieuPlan
    @State private var position: MapCameraPosition

    init(lieu: LieuPlan) {
        self.lieu = lieu
        _position = State(initialValue: .region(
            MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (45.7660 + lieu.lat) / 2,
                                                              longitude: (4.8350 + lieu.lon) / 2),
                               span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position) {
                MapPolyline(coordinates: [
                    CLLocationCoordinate2D(latitude: 45.7660, longitude: 4.8350),
                    CLLocationCoordinate2D(latitude: (45.7660 + lieu.lat) / 2, longitude: (4.8350 + lieu.lon) / 2),
                    CLLocationCoordinate2D(latitude: lieu.lat, longitude: lieu.lon),
                ])
                .stroke(Color(hex: 0x0A84FF), lineWidth: 8)
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: 45.7660, longitude: 4.8350)) {
                    Image(systemName: "location.north.fill").font(.system(size: 20))
                        .foregroundStyle(.white).padding(7)
                        .background(Color(hex: 0x0A84FF), in: Circle())
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .ignoresSafeArea()
            .preferredColorScheme(.light)

            // Bandeau haut
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill").font(.system(size: 22)).foregroundStyle(.white)
                    Text("Rejoignez l'itinéraire").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                    Spacer()
                }
                .padding(16)
                .background(Color(hex: 0x1C6E43))
                HStack {
                    Image(systemName: "arrow.uturn.left").font(.system(size: 14)).foregroundStyle(.white.opacity(0.9))
                    Text("Vers " + lieu.nom).font(.system(size: 14)).foregroundStyle(.white.opacity(0.9))
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Color(hex: 0x155934))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 10).padding(.top, 4)

            // Bandeau bas
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("20:57").font(.system(size: 22, weight: .bold)).foregroundStyle(.black)
                        Text("arrivée").font(.system(size: 11)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(spacing: 1) {
                        Text("14").font(.system(size: 22, weight: .bold)).foregroundStyle(.black)
                        Text("min").font(.system(size: 11)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("9,9").font(.system(size: 22, weight: .bold)).foregroundStyle(.black)
                        Text("km").font(.system(size: 11)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Text("Fin").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(Color(hex: 0xFF453A), in: Capsule())
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 10).padding(.bottom, 10)
            }
        }
    }
}


// Notation d'un lieu (réelle, session) — anti-friction 21/08
struct NoterLieuVue: View {
    @Environment(\.dismiss) private var dismiss
    let nom: String
    @State private var note = 0
    var body: some View {
        VStack(spacing: 22) {
            Text("Noter « \(nom) »").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                .padding(.top, 26).lineLimit(1)
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= note ? "star.fill" : "star")
                        .font(.system(size: 30))
                        .foregroundStyle(i <= note ? Color(hex: 0xE8C33D) : .secondary)
                        .onTapGesture { Haptique.leger(); note = i }
                }
            }
            Button { Haptique.leger(); dismiss() } label: {
                Text("Envoyer").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(note == 0 ? Color(hex: 0x3A3A3C) : Color(hex: 0x0A84FF), in: RoundedRectangle(cornerRadius: 12))
            }
            .disabled(note == 0)
            .padding(.horizontal, 20)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: 0x1C1C1E))
        .presentationDetents([.height(230)])
        .preferredColorScheme(.dark)
    }
}
