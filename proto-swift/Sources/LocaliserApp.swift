// Localiser — construit contre la vidéo de référence du 19/08 (62 écrans + 12 captures, iOS 26)
// D51-2 réaffirmée : TOUS les composants, pour toutes situations — personnes (tous états),
// appareils (fiche complète), objets (AirTag entier), Moi. Les états pleins viennent des patrons
// de la référence (lignes « Avec vous », « Domicile · Maintenant », « Aucune position trouvée »).
// Or narratif : l'invitation de partage envoyée à Marc, en attente depuis le 12 mai. Jamais acceptée.
import SwiftUI
import MapKit

// ============================================================ DONNÉES (remplaçables — D59)
struct PersonneLoc: Identifiable {
    let id = UUID()
    var nom: String
    var etat: String          // "Croix-Rousse, Lyon · Maintenant", "En attente…"
    var partage: Bool         // partage mutuel actif
    var invitation: Bool = false
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
    static let personnes = [
        PersonneLoc(nom: "Chloé", etat: "Croix-Rousse, Lyon · Maintenant", partage: true, lat: 45.7747, lon: 4.8320),
        PersonneLoc(nom: "Maman", etat: "Theizé · il y a 40 min", partage: true, lat: 45.9394, lon: 4.6120),
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

// ============================================================ APP
struct LocaliserVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = 1
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.7699, longitude: 4.8290),
                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))

    var body: some View {
        ZStack(alignment: .bottom) {
            // La carte occupe tout l'écran (comme la référence)
            Map(position: $position) {
                if onglet == 0 {
                    ForEach(DonneesLocaliser.personnes.filter { $0.partage }) { p in
                        Annotation(p.nom, coordinate: CLLocationCoordinate2D(latitude: p.lat, longitude: p.lon)) {
                            PastilleCarte(texte: String(p.nom.prefix(1)))
                        }
                    }
                } else if onglet == 1 {
                    ForEach(DonneesLocaliser.appareils.filter { !$0.sansPosition }) { a in
                        Annotation(a.nom, coordinate: CLLocationCoordinate2D(latitude: a.lat, longitude: a.lon)) {
                            PastilleCarte(symbole: a.symbole)
                        }
                    }
                } else if onglet == 2 {
                    ForEach(DonneesLocaliser.objets) { o in
                        Annotation(o.nom, coordinate: CLLocationCoordinate2D(latitude: o.lat, longitude: o.lon)) {
                            PastilleCarte(symbole: "key.fill")
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .ignoresSafeArea()

            // Panneau bas + barre d'onglets
            VStack(spacing: 0) {
                Group {
                    switch onglet {
                    case 0: PersonnesPanneau()
                    case 2: ObjetsPanneau()
                    case 3: MoiPanneau()
                    default: AppareilsPanneau()
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

            Color.clear.frame(height: 8)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 20).onEnded { v in
                    if v.translation.height < -35 { dismiss() }
                })
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
        .foregroundStyle(actif ? Color(hex: 0x0A84FF) : .secondary)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// ============================================================ PERSONNES (tous les états)
struct PersonnesPanneau: View {
    @State private var detail: PersonneLoc? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Personnes").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "plus").font(.system(size: 17)).foregroundStyle(.white)
                    .frame(width: 32, height: 32).background(Color.white.opacity(0.12), in: Circle())
            }
            ForEach(DonneesLocaliser.personnes) { p in
                Button { detail = p } label: {
                    HStack(spacing: 12) {
                        Circle().fill(Color(hex: p.invitation ? 0x8E8E93 : 0x5B7CFA))
                            .frame(width: 42, height: 42)
                            .overlay(Text(String(p.nom.prefix(1))).font(.system(size: 18, weight: .semibold)).foregroundStyle(.white))
                            .opacity(p.invitation ? 0.5 : 1)
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
    @State private var alerte: String? = nil
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
                            Button { alerte = "invitation" } label: {
                                Text("Renvoyer l'invitation").font(.system(size: 15, weight: .semibold)).foregroundStyle(Color(hex: 0x0A84FF))
                                    .padding(.horizontal, 20).padding(.vertical, 10)
                                    .background(Color(hex: 0x1C1C1E), in: Capsule())
                            }
                        }
                        .padding(.top, 20)
                    } else {
                        HStack(spacing: 12) {
                            BoutonLocaliser(symbole: "phone.fill", nom: "Contacter") { alerte = "contact" }
                            BoutonLocaliser(symbole: "car.fill", nom: "Itinéraire") { alerte = "plans" }
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
                        Button { alerte = "cesser" } label: {
                            Text("Cesser de partager ma position")
                                .font(.system(size: 15)).foregroundStyle(Color(hex: 0xFF453A))
                                .frame(maxWidth: .infinity).padding(.vertical, 13)
                                .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 14))
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
        .alert(titreAlerte, isPresented: Binding(get: { alerte != nil }, set: { if !$0 { alerte = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(messageAlerte) }
    }

    private var titreAlerte: String {
        switch alerte {
        case "invitation": return "Invitation renvoyée"
        case "contact": return personne.nom
        case "cesser": return "Partage"
        default: return "Plans"
        }
    }
    private var messageAlerte: String {
        switch alerte {
        case "invitation": return "Une nouvelle invitation a été envoyée à \(personne.nom)."
        case "contact": return "Ouvrez Téléphone ou Messages pour contacter \(personne.nom)."
        case "cesser": return "Maintenez pour confirmer l'arrêt du partage avec \(personne.nom)."
        default: return ErreurLambda.reponse("app.attente")
        }
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
            .foregroundStyle(Color(hex: 0x0A84FF))
            .frame(maxWidth: .infinity).padding(.vertical, 12)
            .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// ============================================================ APPAREILS (fiche complète)
struct AppareilsPanneau: View {
    @State private var detail: AppareilLoc? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Appareils").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "plus").font(.system(size: 17)).foregroundStyle(.white)
                    .frame(width: 32, height: 32).background(Color.white.opacity(0.12), in: Circle())
            }
            ForEach(DonneesLocaliser.appareils) { a in
                Button { detail = a } label: {
                    HStack(spacing: 12) {
                        Circle().fill(Color(hex: 0x2C2C2E)).frame(width: 42, height: 42)
                            .overlay(Image(systemName: a.symbole).font(.system(size: 17)).foregroundStyle(a.sansPosition ? .secondary : .white))
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
    @State private var alerte: String? = nil
    @State private var prevenir = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("14 rue des Capucins · 69001 Lyon")
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        BoutonLocaliser(symbole: "speaker.wave.2.fill", nom: "Émettre un son") { alerte = "son" }
                        BoutonLocaliser(symbole: "car.fill", nom: "Itinéraire") { alerte = "plans" }
                    }
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Appareil perdu").foregroundStyle(.white)
                                Text("Mode Perdu — activez la protection supplémentaire")
                                    .font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("Non").font(.system(size: 14)).foregroundStyle(.secondary)
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .contentShape(Rectangle())
                        .onTapGesture { alerte = "perdu" }
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
                        Button { alerte = "effacer" } label: {
                            HStack { Text("Effacer cet appareil").foregroundStyle(Color(hex: 0xFF453A)); Spacer() }
                                .padding(14)
                        }
                        Divider().overlay(Color(hex: 0x2C2C2E))
                        Button { alerte = "supprimer" } label: {
                            HStack { Text("Supprimer").foregroundStyle(Color(hex: 0xFF453A)); Spacer() }
                                .padding(14)
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
        .alert(titreAlerte, isPresented: Binding(get: { alerte != nil }, set: { if !$0 { alerte = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(messageAlerte) }
    }

    private var titreAlerte: String {
        switch alerte {
        case "son": return appareil.cetAppareil ? "Son émis" : "Émettre un son"
        case "perdu": return "Mode Perdu"
        case "effacer": return "Effacer cet appareil"
        case "supprimer": return "Supprimer"
        default: return "Plans"
        }
    }
    private var messageAlerte: String {
        switch alerte {
        case "son": return appareil.cetAppareil ? "Ce son est émis sur cet iPhone."
                                                : "Le son sera émis lorsque l'appareil sera en ligne."
        case "perdu": return "Le Mode Perdu verrouille l'appareil avec son code et affiche un message de contact. Cette action nécessite le code de l'iPhone."
        case "effacer": return "Tout le contenu et les réglages seront effacés. Cette action nécessite le mot de passe du compte Apple."
        case "supprimer": return "Cet appareil doit être hors ligne pour être retiré du compte."
        default: return ErreurLambda.reponse("app.attente")
        }
    }
}

// ============================================================ OBJETS (composant AirTag entier)
struct ObjetsPanneau: View {
    @State private var detail: ObjetLoc? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Objets").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "plus").font(.system(size: 17)).foregroundStyle(.white)
                    .frame(width: 32, height: 32).background(Color.white.opacity(0.12), in: Circle())
            }
            ForEach(DonneesLocaliser.objets) { o in
                Button { detail = o } label: {
                    HStack(spacing: 12) {
                        Circle().fill(Color(hex: 0x2C2C2E)).frame(width: 42, height: 42)
                            .overlay(Image(systemName: "key.fill").font(.system(size: 16)).foregroundStyle(Color(hex: 0xE8C33D)))
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
    @State private var alerte: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("AirTag · " + objet.etat).font(.system(size: 13)).foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        BoutonLocaliser(symbole: "speaker.wave.2.fill", nom: "Émettre un son") { alerte = "son" }
                        BoutonLocaliser(symbole: "location.viewfinder", nom: "Localiser") { alerte = "precision" }
                    }
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Objet perdu").foregroundStyle(.white)
                                Text("Mode Perdu — soyez averti quand il est localisé")
                                    .font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("Non").font(.system(size: 14)).foregroundStyle(.secondary)
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .contentShape(Rectangle())
                        .onTapGesture { alerte = "perdu" }
                        Divider().overlay(Color(hex: 0x2C2C2E))
                        Button { alerte = "retirer" } label: {
                            HStack { Text("Retirer l'objet").foregroundStyle(Color(hex: 0xFF453A)); Spacer() }
                                .padding(14)
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
        .alert(titreAlerte, isPresented: Binding(get: { alerte != nil }, set: { if !$0 { alerte = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(messageAlerte) }
    }

    private var titreAlerte: String {
        switch alerte {
        case "son": return "Émettre un son"
        case "precision": return "Recherche de précision"
        case "perdu": return "Mode Perdu"
        default: return "Retirer l'objet"
        }
    }
    private var messageAlerte: String {
        switch alerte {
        case "son": return "Le son sera émis lorsque l'AirTag sera à portée."
        case "precision": return "Rapprochez-vous de l'objet pour lancer la recherche de précision."
        case "perdu": return "Le Mode Perdu associe votre numéro à cet AirTag pour qu'on puisse vous contacter."
        default: return "Approchez l'AirTag de l'iPhone pour le retirer du compte."
        }
    }
}

// ============================================================ MOI
struct MoiPanneau: View {
    @State private var partage = true
    @State private var demandesAmis = true
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Moi").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text("Lyon, France").font(.system(size: 12.5)).foregroundStyle(.secondary)
                }
                Spacer()
            }
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "location.circle.fill").font(.system(size: 20)).foregroundStyle(Color(hex: 0x0A84FF))
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
                Divider().overlay(Color(hex: 0x2C2C2E))
                HStack {
                    Text("Étiquette de localisation").font(.system(size: 15)).foregroundStyle(.white)
                    Spacer()
                    Text("Aucune").font(.system(size: 14)).foregroundStyle(.secondary)
                    Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
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
