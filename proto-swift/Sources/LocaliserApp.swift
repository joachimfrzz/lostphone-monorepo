// Localiser — construit contre la vidéo de référence du 19/08 (62 écrans + 12 captures, iOS 26)
// D51-2 réaffirmée : TOUS les composants, pour toutes situations — personnes (tous états),
// appareils (fiche complète), objets (AirTag entier), Moi. Les états pleins viennent des patrons
// de la référence (lignes « Avec vous », « Domicile · Maintenant », « Aucune position trouvée »).
// Or narratif : l'invitation de partage envoyée à Marc, en attente depuis le 12 mai. Jamais acceptée.
// v3 02/09 (retours Joachim, session 4) : boutons « + » retirés (le joueur ne modifie pas Localiser) ;
// boutons de carte RÉELS (type de carte plan/satellite, recentrer sur moi) ; sélectionner une personne/un appareil/
// un objet RECENTRE la carte sur sa position ; Memoji (images) pour les personnes ; Itinéraire ouvre Plans
// AVEC la destination ; « Étiquette de localisation » retirée ; bouton « Localiser » (À proximité) retiré (C).
import SwiftUI
import MapKit

// ============================================================ DONNÉES (remplaçables — D59)
struct PersonneLoc: Identifiable {
    let id = UUID()
    var nom: String
    var etat: String          // "Croix-Rousse, Lyon · Maintenant", "En attente…"
    var partage: Bool         // partage mutuel actif
    var invitation: Bool = false
    var emoji: String = "\u{1F464}"
    var memoji: String? = nil // v3 : image Memoji (Ressources/memoji-*.png)
    var tel: String = ""
    var lat: Double = 45.7640
    var lon: Double = 4.8357
}

struct AppareilLoc: Identifiable {
    let id = UUID()
    var nom: String
    var symbole: String
    var etat: String
    var cetAppareil: Bool = false
    var sansPosition: Bool = false
    var lat: Double = 45.7699
    var lon: Double = 4.8290
}

struct ObjetLoc: Identifiable {
    let id = UUID()
    var nom: String
    var etat: String
    var lat: Double = 45.7699
    var lon: Double = 4.8290
}

enum DonneesLocaliser {
    static let maPosition = CLLocationCoordinate2D(latitude: 45.7699, longitude: 4.8290)   // 14 rue des Capucins
    static let personnes = [
        PersonneLoc(nom: "Chloé", etat: "Croix-Rousse, Lyon · Maintenant", partage: true, emoji: "\u{1F471}\u{1F3FB}\u{200D}\u{2640}\u{FE0F}", memoji: "memoji-chloe", tel: "06 24 81 05 77", lat: 45.7747, lon: 4.8320),
        PersonneLoc(nom: "Maman", etat: "Theizé · il y a 40 min", partage: true, emoji: "\u{1F469}\u{1F3FB}\u{200D}\u{1F9B3}", memoji: "memoji-maman", tel: "06 81 35 42 19", lat: 45.9394, lon: 4.6120),
        PersonneLoc(nom: "Marc ❤️", etat: "Invitation envoyée le 12 mai · En attente", partage: false, invitation: true),
    ]
    static let appareils = [
        AppareilLoc(nom: "iPhone de Sarah", symbole: "iphone", etat: "Cet iPhone", cetAppareil: true),
        AppareilLoc(nom: "AirPods de Sarah", symbole: "airpods.gen3", etat: "Domicile · il y a 2 h"),
        AppareilLoc(nom: "MacBook Air de Sarah", symbole: "laptopcomputer", etat: "Aucune position trouvée", sansPosition: true),
    ]
    static let objets = [
        ObjetLoc(nom: "Clés 🔑", etat: "Domicile · il y a 5 h"),
    ]
}

// ============================================================ ÉTAT DE SESSION (boutons réels — anti-friction 21/08)
final class MagasinLoc: ObservableObject {
    static let partage = MagasinLoc()
    @Published var partageCesse: Set<String> = []
    @Published var modePerdu: Set<String> = []
    @Published var supprimes: Set<String> = []
}

// Memoji (image) avec repli emoji — le Memoji est un PNG des Ressources (outils/memoji.tar.b64)
struct AvatarMemoji: View {
    let personne: PersonneLoc
    var taille: CGFloat = 42
    var body: some View {
        Circle()
            .fill(LinearGradient(colors: personne.invitation ? [Color(hex: 0x48484A), Color(hex: 0x2C2C2E)] : [Color(hex: 0xBFD9F2), Color(hex: 0x8FB8E0)],
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: taille, height: taille)
            .overlay {
                if let m = personne.memoji, let img = chargerPellicule(m) {
                    Color.clear.overlay(Image(uiImage: img).resizable().scaledToFill()).clipShape(Circle())
                } else {
                    Text(personne.emoji).font(.system(size: taille * 0.57))
                }
            }
            .opacity(personne.invitation ? 0.55 : 1)
    }
}

// ============================================================ APP
struct LocaliserVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 1
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(center: DonneesLocaliser.maPosition,
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    @State private var satellite = false   // v3 : bouton « carte pliée » RÉEL = type de carte

    // v3 : recentrer la carte sur une position (sélection d'un élément, bouton localisation)
    private func centrer(_ lat: Double, _ lon: Double, zoom: Double = 0.02) {
        withAnimation(.easeInOut(duration: 0.5)) {
            position = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                                  span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)))
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // La carte occupe tout l'écran (comme la référence)
            Map(position: $position) {
                if onglet == 0 {
                    ForEach(DonneesLocaliser.personnes.filter { $0.partage }) { p in
                        Annotation(p.nom, coordinate: CLLocationCoordinate2D(latitude: p.lat, longitude: p.lon)) {
                            AvatarMemoji(personne: p, taille: 36).shadow(radius: 4)
                        }
                    }
                } else if onglet == 1 {
                    // Miroir phase C : grappe quand plusieurs appareils partagent la même position (réf v8)
                    let visibles = DonneesLocaliser.appareils.filter { !$0.sansPosition }
                    let groupes = Dictionary(grouping: visibles) { "\(Int($0.lat * 1000))-\(Int($0.lon * 1000))" }
                    ForEach(Array(groupes.keys.sorted()), id: \.self) { cle in
                        if let groupe = groupes[cle], let premier = groupe.first {
                            Annotation(groupe.count > 1 ? "" : premier.nom,
                                       coordinate: CLLocationCoordinate2D(latitude: premier.lat, longitude: premier.lon)) {
                                if groupe.count > 1 {
                                    HStack(spacing: 5) {
                                        ForEach(groupe.prefix(2)) { a in
                                            Image(systemName: a.symbole).font(.system(size: 13))
                                                .foregroundStyle(Color(hex: 0x2E4A6B))
                                        }
                                        if groupe.count > 2 {
                                            Text("+\(groupe.count - 2)").font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(Color(hex: 0x2E4A6B))
                                        }
                                    }
                                    .padding(.horizontal, 10).padding(.vertical, 8)
                                    .background(.white, in: Capsule())
                                    .shadow(radius: 4)
                                } else {
                                    PastilleCarte(symbole: premier.symbole)
                                }
                            }
                        }
                    }
                } else if onglet == 2 {
                    ForEach(DonneesLocaliser.objets) { o in
                        Annotation(o.nom, coordinate: CLLocationCoordinate2D(latitude: o.lat, longitude: o.lon)) {
                            PastilleCarte(texte: "\u{1F511}")
                        }
                    }
                } else {
                    Annotation("Moi", coordinate: DonneesLocaliser.maPosition) {
                        Circle().fill(Color(hex: 0x0A84FF)).frame(width: 16, height: 16)
                            .overlay(Circle().stroke(.white, lineWidth: 3))
                    }
                }
            }
            .mapStyle(satellite ? .hybrid(elevation: .flat, pointsOfInterest: .excludingAll) : .standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .ignoresSafeArea()

            // Panneau bas + barre d'onglets
            VStack(spacing: 0) {
                Group {
                    switch onglet {
                    case 0: PersonnesPanneau { p in centrer(p.lat, p.lon) }
                    case 2: ObjetsPanneau { o in centrer(o.lat, o.lon) }
                    case 3: MoiPanneau()
                    default: AppareilsPanneau { a in if !a.sansPosition { centrer(a.lat, a.lon) } }
                    }
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                .padding(.horizontal, 10)

                HStack {
                    OngletLocaliser(nom: "Personnes", symbole: "figure.2", actif: onglet == 0) { onglet = 0 }
                    OngletLocaliser(nom: "Appareils", symbole: "macbook.and.iphone", actif: onglet == 1) { onglet = 1 }
                    OngletLocaliser(nom: "Objets", symbole: "circle.grid.2x2.fill", actif: onglet == 2) { onglet = 2 }
                    OngletLocaliser(nom: "Moi", symbole: "location.fill", actif: onglet == 3) { onglet = 3 }
                }
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
            }

            BarreHome { dismiss() }

            // Miroir lot 3 : pile de boutons carte flottants (référence v8) — v3 : RÉELS
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Button { Haptique.leger(); withAnimation { satellite.toggle() } } label: {
                            Image(systemName: satellite ? "map.fill" : "map").font(.system(size: 16)).foregroundStyle(.white.opacity(0.9))
                                .frame(width: 42, height: 42)
                        }
                        Divider().frame(width: 42).overlay(Color.white.opacity(0.15))
                        Button { Haptique.leger(); centrer(DonneesLocaliser.maPosition.latitude, DonneesLocaliser.maPosition.longitude, zoom: 0.05) } label: {
                            Image(systemName: "location").font(.system(size: 16)).foregroundStyle(.white.opacity(0.9))
                                .frame(width: 42, height: 42)
                        }
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.trailing, 10)
                }
                .padding(.top, 62)
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct PastilleCarte: View {
    var texte: String? = nil
    var symbole: String? = nil
    var body: some View {
        Circle().fill(.white)
            .frame(width: 36, height: 36)
            .overlay {
                if let texte {
                    Text(texte).font(.system(size: 16, weight: .bold)).foregroundStyle(Color(hex: 0x2E4A6B))
                } else if let symbole {
                    Image(systemName: symbole).font(.system(size: 15)).foregroundStyle(Color(hex: 0x2E4A6B))
                }
            }
            .shadow(radius: 4)
    }
}

// Miroir lot 5 : vignettes produit dessinées (la réf montre les rendus des appareils, pas des pictos plats)
struct VignetteAppareil: View {
    let symbole: String
    var estompee: Bool = false
    var body: some View {
        Circle().fill(Color(hex: 0x2C2C2E)).frame(width: 42, height: 42)
            .overlay(rendu.opacity(estompee ? 0.45 : 1))
    }
    @ViewBuilder private var rendu: some View {
        switch symbole {
        case "iphone":
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(colors: [Color(hex: 0x3C6FB0), Color(hex: 0x18324F)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 14, height: 24)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: 0x0E1B2C), lineWidth: 1.6))
                .overlay(Capsule().fill(.black).frame(width: 5, height: 2).offset(y: -9))
        case "airpods.gen3":
            Image(systemName: "airpods.gen3").font(.system(size: 16)).foregroundStyle(.white)
        case "laptopcomputer":
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(LinearGradient(colors: [Color(hex: 0x8E9196), Color(hex: 0x5A5D62)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 22, height: 13)
                    .overlay(RoundedRectangle(cornerRadius: 2).inset(by: 1.6).fill(Color(hex: 0x1A2A3E)))
                RoundedRectangle(cornerRadius: 1).fill(Color(hex: 0xB8BBC0)).frame(width: 26, height: 2)
            }
        default:
            Image(systemName: symbole).font(.system(size: 16)).foregroundStyle(.white)
        }
    }
}

struct OngletLocaliser: View {
    let nom: String
    let symbole: String
    let actif: Bool
    let action: () -> Void
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbole).font(.system(size: 20))
            Text(nom).font(.system(size: 10))
        }
        .foregroundStyle(actif ? Color(hex: 0x007AFF) : .secondary)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// ============================================================ PERSONNES (tous les états)
struct PersonnesPanneau: View {
    var centrer: (PersonneLoc) -> Void = { _ in }
    @State private var detail: PersonneLoc? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Personnes").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                Spacer()
                // v3 : « + » retiré — le joueur ne modifie pas Localiser (Joachim)
            }
            ForEach(DonneesLocaliser.personnes) { p in
                Button {
                    if p.partage { centrer(p) }   // v3 : la carte se recentre sur la personne
                    detail = p
                } label: {
                    HStack(spacing: 12) {
                        AvatarMemoji(personne: p)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.nom).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                            Text(p.etat).font(.system(size: 12.5))
                                .foregroundStyle(p.invitation ? Color(hex: 0xE8873D) : .secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding(16)
        .sheet(item: $detail) { p in PersonneDetailVue(personne: p) }
    }
}

extension PersonneLoc: Hashable {
    static func == (a: PersonneLoc, b: PersonneLoc) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct PersonneDetailVue: View {
    @Environment(\.dismiss) private var dismiss
    let personne: PersonneLoc
    @ObservedObject private var magasin = MagasinLoc.partage
    @State private var invitationEnvoyee = false
    @State private var cesserConfirm = false
    @State private var notifier = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if personne.invitation {
                        VStack(spacing: 10) {
                            Circle().fill(Color(hex: 0x2C2C2E)).frame(width: 64, height: 64)
                                .overlay(Image(systemName: "person.fill.questionmark").font(.system(size: 26)).foregroundStyle(.secondary))
                            Text("Invitation en attente").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                            Text("Vous avez proposé à \(personne.nom) de partager sa position le 12 mai 2026. Cette personne n'a pas encore accepté.")
                                .font(.system(size: 13.5)).foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            Button {
                                Haptique.leger()
                                invitationEnvoyee = true
                            } label: {
                                Text(invitationEnvoyee ? "Invitation envoyée" : "Renvoyer l'invitation")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(invitationEnvoyee ? .secondary : Color(hex: 0x007AFF))
                                    .padding(.horizontal, 20).padding(.vertical, 10)
                                    .background(Color(hex: 0x1C1C1E), in: Capsule())
                            }
                            .disabled(invitationEnvoyee)
                        }
                        .padding(.top, 20)
                    } else {
                        HStack(spacing: 12) {
                            AvatarMemoji(personne: personne, taille: 56)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(personne.nom).font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                Text(personne.etat).font(.system(size: 13)).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        HStack(spacing: 12) {
                            BoutonLocaliser(symbole: "phone.fill", nom: "Contacter") {
                                Routeur.partage.allerTelephone(personne.tel)
                            }
                            // v3 : Plans s'ouvre DIRECTEMENT sur l'itinéraire vers cette personne
                            BoutonLocaliser(symbole: "car.fill", nom: "Itinéraire") {
                                Routeur.partage.allerPlans(itineraireVers: personne.nom, lat: personne.lat, lon: personne.lon)
                            }
                            BoutonLocaliser(symbole: "bell.fill", nom: "Notifications") { notifier.toggle() }
                        }
                        VStack(spacing: 0) {
                            HStack {
                                Text("Position").foregroundStyle(.white)
                                Spacer()
                                Text(personne.etat).font(.system(size: 13)).foregroundStyle(.secondary)
                            }
                            .padding(14)
                            Divider().overlay(Color(hex: 0x2C2C2E))
                            HStack {
                                Text("Me prévenir").foregroundStyle(.white)
                                Spacer()
                                Toggle("", isOn: $notifier).labelsHidden().tint(Color(hex: 0x32D74B))
                            }
                            .padding(14)
                        }
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                        Button { cesserConfirm = true } label: {
                            Text(magasin.partageCesse.contains(personne.nom) ? "Recommencer à partager ma position" : "Cesser de partager ma position")
                                .font(.system(size: 15))
                                .foregroundStyle(magasin.partageCesse.contains(personne.nom) ? Color(hex: 0x007AFF) : Color(hex: 0xFF453A))
                                .frame(maxWidth: .infinity).padding(.vertical, 13)
                                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .confirmationDialog("", isPresented: $cesserConfirm, titleVisibility: .hidden) {
                            if magasin.partageCesse.contains(personne.nom) {
                                Button("Partager ma position") { Haptique.leger(); magasin.partageCesse.remove(personne.nom) }
                            } else {
                                Button("Cesser de partager ma position", role: .destructive) { Haptique.leger(); magasin.partageCesse.insert(personne.nom) }
                            }
                            Button("Annuler", role: .cancel) {}
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle(personne.nom)
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
    }
}

struct BoutonLocaliser: View {
    let symbole: String
    let nom: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbole).font(.system(size: 17))
                Text(nom).font(.system(size: 11.5))
            }
            .foregroundStyle(Color(hex: 0x007AFF))
            .frame(maxWidth: .infinity).padding(.vertical, 12)
            .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// ============================================================ APPAREILS (fiche complète)
struct AppareilsPanneau: View {
    var centrer: (AppareilLoc) -> Void = { _ in }
    @ObservedObject private var magasin = MagasinLoc.partage
    @State private var detail: AppareilLoc? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Appareils").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                Spacer()
            }
            ForEach(DonneesLocaliser.appareils.filter { !magasin.supprimes.contains($0.nom) }) { a in
                Button { centrer(a); detail = a } label: {
                    HStack(spacing: 12) {
                        VignetteAppareil(symbole: a.symbole, estompee: a.sansPosition)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.nom).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                            Text(a.etat).font(.system(size: 12.5)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if !a.sansPosition {
                            Text("Avec vous").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding(16)
        .sheet(item: $detail) { a in AppareilDetailVue(appareil: a) }
    }
}

extension AppareilLoc: Hashable {
    static func == (a: AppareilLoc, b: AppareilLoc) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct AppareilDetailVue: View {
    @Environment(\.dismiss) private var dismiss
    let appareil: AppareilLoc
    @ObservedObject private var magasin = MagasinLoc.partage
    @State private var sonEmis = false
    @State private var effacerConfirm = false
    @State private var supprimerConfirm = false
    @State private var effacementDemande = false
    @State private var prevenir = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        VignetteAppareil(symbole: appareil.symbole, estompee: appareil.sansPosition)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(appareil.nom).font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                            Text(appareil.sansPosition ? "Aucune position trouvée" : "14 rue des Capucins · 69001 Lyon · \(appareil.etat)")
                                .font(.system(size: 12.5)).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    HStack(spacing: 12) {
                        BoutonLocaliser(symbole: sonEmis ? "speaker.wave.3.fill" : "speaker.wave.2.fill", nom: sonEmis ? "Son émis" : "Émettre un son") { Haptique.leger(); sonEmis = true }
                        if !appareil.sansPosition {
                            BoutonLocaliser(symbole: "car.fill", nom: "Itinéraire") {
                                Routeur.partage.allerPlans(itineraireVers: appareil.nom, lat: appareil.lat, lon: appareil.lon)
                            }
                        }
                    }
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Appareil perdu").foregroundStyle(.white)
                                Text("Mode Perdu — activez la protection supplémentaire")
                                    .font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(magasin.modePerdu.contains(appareil.nom) ? "Activé" : "Non").font(.system(size: 14)).foregroundStyle(magasin.modePerdu.contains(appareil.nom) ? Color(hex: 0xE8873D) : .secondary)
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Haptique.leger()
                            if magasin.modePerdu.contains(appareil.nom) { magasin.modePerdu.remove(appareil.nom) }
                            else { magasin.modePerdu.insert(appareil.nom) }
                        }
                        Divider().overlay(Color(hex: 0x2C2C2E))
                        HStack {
                            Text("Me prévenir quand il sera localisé").foregroundStyle(.white)
                            Spacer()
                            Toggle("", isOn: $prevenir).labelsHidden().tint(Color(hex: 0x32D74B))
                        }
                        .padding(14)
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                    VStack(spacing: 0) {
                        Button { if !effacementDemande { effacerConfirm = true } } label: {
                            HStack {
                                Text(effacementDemande ? "Effacement en attente de connexion…" : "Effacer cet appareil")
                                    .foregroundStyle(effacementDemande ? .secondary : Color(hex: 0xFF453A))
                                Spacer()
                            }
                            .padding(14)
                        }
                        .confirmationDialog("Effacer « \(appareil.nom) » ?", isPresented: $effacerConfirm, titleVisibility: .visible) {
                            Button("Effacer", role: .destructive) { Haptique.leger(); effacementDemande = true }
                            Button("Annuler", role: .cancel) {}
                        } message: { Text("Tout le contenu et les réglages seront effacés à la prochaine connexion de l'appareil.") }
                        Divider().overlay(Color(hex: 0x2C2C2E))
                        Button { supprimerConfirm = true } label: {
                            HStack { Text("Supprimer").foregroundStyle(Color(hex: 0xFF453A)); Spacer() }
                                .padding(14)
                        }
                        .confirmationDialog("Supprimer « \(appareil.nom) » du compte ?", isPresented: $supprimerConfirm, titleVisibility: .visible) {
                            Button("Supprimer", role: .destructive) { Haptique.leger(); magasin.supprimes.insert(appareil.nom); dismiss() }
                            Button("Annuler", role: .cancel) {}
                        }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle(appareil.nom)
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

// ============================================================ OBJETS (composant AirTag entier)
struct ObjetsPanneau: View {
    var centrer: (ObjetLoc) -> Void = { _ in }
    @ObservedObject private var magasin = MagasinLoc.partage
    @State private var detail: ObjetLoc? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Objets").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                Spacer()
            }
            ForEach(DonneesLocaliser.objets.filter { !magasin.supprimes.contains($0.nom) }) { o in
                Button { centrer(o); detail = o } label: {
                    HStack(spacing: 12) {
                        Circle().fill(.white).frame(width: 42, height: 42)
                            .overlay(Text("\u{1F511}").font(.system(size: 20)))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(o.nom).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                            Text(o.etat).font(.system(size: 12.5)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding(16)
        .sheet(item: $detail) { o in ObjetDetailVue(objet: o) }
    }
}

extension ObjetLoc: Hashable {
    static func == (a: ObjetLoc, b: ObjetLoc) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct ObjetDetailVue: View {
    @Environment(\.dismiss) private var dismiss
    let objet: ObjetLoc
    @ObservedObject private var magasin = MagasinLoc.partage
    @State private var sonEmis = false
    @State private var retirerConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("AirTag · " + objet.etat).font(.system(size: 13)).foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        BoutonLocaliser(symbole: sonEmis ? "speaker.wave.3.fill" : "speaker.wave.2.fill", nom: sonEmis ? "Son émis" : "Émettre un son") { Haptique.leger(); sonEmis = true }
                        // v3 : bouton « Localiser » (À proximité) RETIRÉ — interaction artificielle (Joachim, option C)
                        BoutonLocaliser(symbole: "car.fill", nom: "Itinéraire") {
                            Routeur.partage.allerPlans(itineraireVers: objet.nom, lat: objet.lat, lon: objet.lon)
                        }
                    }
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Objet perdu").foregroundStyle(.white)
                                Text("Mode Perdu — soyez averti quand il est localisé")
                                    .font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(magasin.modePerdu.contains(objet.nom) ? "Activé" : "Non").font(.system(size: 14)).foregroundStyle(magasin.modePerdu.contains(objet.nom) ? Color(hex: 0xE8873D) : .secondary)
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Haptique.leger()
                            if magasin.modePerdu.contains(objet.nom) { magasin.modePerdu.remove(objet.nom) }
                            else { magasin.modePerdu.insert(objet.nom) }
                        }
                        Divider().overlay(Color(hex: 0x2C2C2E))
                        Button { retirerConfirm = true } label: {
                            HStack { Text("Retirer l'objet").foregroundStyle(Color(hex: 0xFF453A)); Spacer() }
                                .padding(14)
                        }
                        .confirmationDialog("Retirer « \(objet.nom) » ?", isPresented: $retirerConfirm, titleVisibility: .visible) {
                            Button("Retirer", role: .destructive) { Haptique.leger(); magasin.supprimes.insert(objet.nom); dismiss() }
                            Button("Annuler", role: .cancel) {}
                        }
                    }
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle(objet.nom)
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
    }
}

// ============================================================ MOI
struct MoiPanneau: View {
    @State private var partage = true
    @State private var demandesAmis = true
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AvatarMemoji(personne: PersonneLoc(nom: "Sarah", etat: "", partage: true, emoji: "\u{1F469}", memoji: "memoji-sarah"), taille: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Moi").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text("Lyon, France").font(.system(size: 12.5)).foregroundStyle(.secondary)
                }
                Spacer()
            }
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "location.circle.fill").font(.system(size: 20)).foregroundStyle(Color(hex: 0x007AFF))
                    Text("Ma position").foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 14).padding(.top, 12).padding(.bottom, 6)
                HStack {
                    Text("Partager ma position").font(.system(size: 15)).foregroundStyle(.white)
                    Spacer()
                    Toggle("", isOn: $partage).labelsHidden().tint(Color(hex: 0x32D74B))
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
                Divider().overlay(Color(hex: 0x2C2C2E))
                HStack {
                    Text("Partage à partir de").font(.system(size: 15)).foregroundStyle(.white)
                    Spacer()
                    Text("Cet iPhone").font(.system(size: 14)).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                // v3 : « Étiquette de localisation : Aucune » RETIRÉE (sans intérêt + chevron mort — Joachim)
            }
            .background(Color(hex: 0x1C1C1E).opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
            HStack {
                Image(systemName: "bell.badge.fill").font(.system(size: 17)).foregroundStyle(Color(hex: 0xFF453A))
                Text("Autoriser les demandes d'amis").font(.system(size: 15)).foregroundStyle(.white)
                Spacer()
                Toggle("", isOn: $demandesAmis).labelsHidden().tint(Color(hex: 0x32D74B))
            }
            .padding(14)
            .background(Color(hex: 0x1C1C1E).opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(16)
    }
}
