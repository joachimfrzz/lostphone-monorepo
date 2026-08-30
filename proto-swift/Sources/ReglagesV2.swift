import SwiftUI
import UIKit

// ============================================================
// RÉGLAGES V2 (D80 — refonte contre FICHE-REGLAGES-V2, 85 pages réf. S2/1b/crawler)
// Lot 1 : racine iOS 26.6 (ordre exact) + Luminosité (Liquid Glass) + Batterie (Utilisation par app)
// Données Sarah (remplaçables D59).
// ============================================================

struct ReglagesV2Capture: View {
    let cle: String
    var body: some View {
        switch cle {
        case "reglages2.racine": ReglagesV2RacineVue()
        case "reglages2.luminosite": NavigationStack { LuminositeV2Vue() }
        case "reglages2.batterie": NavigationStack { BatterieV2Vue() }
        case "reglages2.general": NavigationStack { GeneralV2Vue() }
        case "reglages2.infos": NavigationStack { InformationsV2Vue() }
        case "reglages2.notifications": NavigationStack { NotificationsV2Vue() }
        case "reglages2.sons": NavigationStack { SonsV2Vue() }
        default: ReglagesV2RacineVue()
        }
    }
}

// MARK: - Racine v2 (ordre exact S1b/S2 : compte, connectivité+Batterie+VPN, apparence, notifs, sécurité, Cartes, Apps)
struct ReglagesV2RacineVue: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Group {
                            if let ui = chargerPellicule("p04") {
                                Color.clear.overlay(Image(uiImage: ui).resizable().scaledToFill())
                            } else {
                                Circle().fill(Color(white: 0.4)).overlay(Text("SL").font(.system(size: 22, weight: .medium)).foregroundStyle(.white))
                            }
                        }
                            .frame(width: 58, height: 58).clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sarah Levasseur").font(.system(size: 20))
                            Text("Compte Apple, iCloud+ et autres").font(.system(size: 13)).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    LigneRV2(icone: "airplane", fond: .orange, nom: "Mode Avion", toggle: true)
                    LigneRV2(icone: "wifi", fond: .blue, nom: "Wi-Fi", valeur: "Bbox-A47F2C")
                    LigneRV2(icone: "wave.3.right", fond: .blue, nom: "Bluetooth", valeur: "Oui")
                    LigneRV2(icone: "antenna.radiowaves.left.and.right", fond: .green, nom: "Données cellulaires")
                    LigneRV2(icone: "personalhotspot", fond: .green, nom: "Partage de connexion", valeur: "Non")
                    LigneRV2(icone: "battery.100", fond: .green, nom: "Batterie")
                    LigneRV2(icone: "network", fond: .blue, nom: "VPN", valeur: "Déconnecté")
                }
                Section {
                    LigneRV2(icone: "gear", fond: .gray, nom: "Général")
                    LigneRV2(icone: "accessibility", fond: .blue, nom: "Accessibilité")
                    LigneRV2(icone: "sparkles", fond: Color(red: 0.5, green: 0.3, blue: 0.9), nom: "Apple Intelligence et Siri")
                    LigneRV2(icone: "camera.fill", fond: .gray, nom: "Appareil photo")
                    LigneRV2(icone: "button.programmable", fond: .blue, nom: "Bouton Action")
                    LigneRV2(icone: "switch.2", fond: .gray, nom: "Centre de contrôle")
                    LigneRV2(icone: "apps.iphone", fond: .blue, nom: "Écran d'accueil et bibliothèque d'apps")
                    LigneRV2(icone: "clock.badge.checkmark", fond: .black, nom: "En veille")
                    LigneRV2(icone: "photo.on.rectangle", fond: .cyan, nom: "Fond d'écran")
                    LigneRV2(icone: "sun.max.fill", fond: .blue, nom: "Luminosité et affichage")
                    LigneRV2(icone: "magnifyingglass", fond: .gray, nom: "Recherche")
                }
                Section {
                    LigneRV2(icone: "bell.badge.fill", fond: .red, nom: "Notifications")
                    LigneRV2(icone: "speaker.wave.3.fill", fond: .pink, nom: "Sons et vibrations")
                    LigneRV2(icone: "moon.fill", fond: .indigo, nom: "Concentration")
                    LigneRV2(icone: "hourglass", fond: .indigo, nom: "Temps d'écran")
                }
                Section {
                    LigneRV2(icone: "faceid", fond: .green, nom: "Face ID et code")
                    LigneRV2(icone: "sos", fond: .red, nom: "Appel d'urgence")
                    LigneRV2(icone: "hand.raised.fill", fond: .blue, nom: "Confidentialité et sécurité")
                }
                Section {
                    LigneRV2(icone: "creditcard.fill", fond: .black, nom: "Cartes et Apple Pay")
                }
                Section {
                    LigneRV2(icone: "square.grid.3x3.fill", fond: .gray, nom: "Apps")
                }
            }
            .navigationTitle("Réglages")
            .searchable(text: .constant(""), prompt: "Recherche")
        }
        .preferredColorScheme(.dark)
    }
}

struct LigneRV2: View {
    let icone: String; let fond: Color; let nom: String
    var valeur: String? = nil
    var toggle: Bool = false
    @State private var actif = false
    static let routes: [String: String] = [
        "Batterie": "reglages2.batterie",
        "Général": "reglages2.general",
        "Luminosité et affichage": "reglages2.luminosite",
        "Notifications": "reglages2.notifications",
        "Sons et vibrations": "reglages2.sons"
    ]
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 7)
                .fill(fond)
                .frame(width: 30, height: 30)
                .overlay(Image(systemName: icone)
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white))
            Text(nom).font(.system(size: 17))
            Spacer()
            if toggle {
                Toggle("", isOn: $actif).labelsHidden()
            } else {
                if let v = valeur {
                    Text(v).font(.system(size: 17)).foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.forward")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let cle = LigneRV2.routes[nom] { NavV2.partage.pousser(cle) }
        }
    }
}

// MARK: - Luminosité et affichage v2 (réf S1b : Claire/Sombre, Automatique, LIQUID GLASS, True Tone...)
struct LuminositeV2Vue: View {
    @State private var auto = true
    @State private var trueTone = true
    @State private var nightShift = false
    @State private var luminosite = 0.62
    var body: some View {
        List {
            Section(header: Text("APPARENCE")) {
                HStack(spacing: 30) {
                    Spacer()
                    ApparenceChoix(nom: "Claire", sombre: false, choisie: false)
                    ApparenceChoix(nom: "Sombre", sombre: true, choisie: true)
                    Spacer()
                }.padding(.vertical, 6)
                Toggle("Automatique", isOn: $auto)
            }
            Section {
                HStack {
                    Text("Liquid Glass")
                    Spacer()
                    Text("Transparent").foregroundStyle(.secondary)
                    Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
                }
            } footer: {
                Text("Définir l'apparence des boutons, barres de navigation et commandes.")
            }
            Section {
                HStack { Text("Taille du texte"); Spacer(); Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5)) }
                Toggle("Texte en gras", isOn: .constant(false))
            }
            Section(header: Text("LUMINOSITÉ"), footer: Text("L'affichage de l'iPhone s'adapte automatiquement aux conditions d'éclairage ambiant.")) {
                HStack(spacing: 10) {
                    Image(systemName: "sun.min.fill").foregroundStyle(.secondary)
                    Slider(value: $luminosite)
                    Image(systemName: "sun.max.fill").foregroundStyle(.secondary)
                }
                Toggle("True Tone", isOn: $trueTone)
            }
            Section {
                HStack { Text("Night Shift"); Spacer(); Text("Non").foregroundStyle(.secondary); Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5)) }
            }
        }
        .navigationTitle("Luminosité et affichage")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct ApparenceChoix: View {
    let nom: String; let sombre: Bool; let choisie: Bool
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(sombre ? Color.black : Color.white)
                .frame(width: 64, height: 118)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4)))
                .overlay(VStack(spacing: 3) {
                    Text("9:41").font(.system(size: 13, weight: .semibold)).foregroundStyle(sombre ? .white : .black)
                    RoundedRectangle(cornerRadius: 2).fill(sombre ? Color.white.opacity(0.3) : .black.opacity(0.15)).frame(width: 40, height: 5)
                    RoundedRectangle(cornerRadius: 2).fill(sombre ? Color.white.opacity(0.3) : .black.opacity(0.15)).frame(width: 40, height: 5)
                }.padding(.top, 8), alignment: .top)
            Text(nom).font(.system(size: 14))
            Image(systemName: choisie ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(choisie ? .blue : .secondary)
        }
    }
}

// MARK: - Batterie v2 (réf S1b/S2 : état de charge, Limite 100 %, graphique, Utilisation par app, État de santé)
struct BatterieV2Vue: View {
    let usages: [(String, String, String, Int)] = [
        ("WhatsApp", "message.fill", "1 h 12 — À l'écran", 31),
        ("Safari", "safari.fill", "43 min — À l'écran", 22),
        ("Ma Banque", "building.columns.fill", "17 min — À l'écran", 12),
        ("Photos", "photo.on.rectangle.angled", "14 min — À l'écran", 9),
        ("Mail", "envelope.fill", "9 min — À l'écran", 6)
    ]
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Niveau de la batterie : 38 %")
                    Spacer()
                }
                HStack { Text("Limite de 100 %"); Spacer(); Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5)) }
                HStack { Text("Mode économie d'énergie"); Spacer(); Toggle("", isOn: .constant(false)).labelsHidden() }
            }
            Section(header: Text("DERNIÈRES 24 HEURES")) {
                // graphique en barres simple (24 barres)
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(0..<24, id: \.self) { h in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(h == 19 ? Color.yellow : Color.green)
                            .frame(width: 9, height: CGFloat([42,40,38,36,35,34,33,60,55,48,44,40,58,52,46,42,66,72,58,30,26,52,46,40][h]))
                    }
                }
                .frame(height: 80)
                .padding(.vertical, 6)
            }
            Section(header: Text("UTILISATION DE LA BATTERIE PAR APP")) {
                ForEach(usages, id: \.0) { u in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 7).fill(Color(white: 0.25))
                            .frame(width: 30, height: 30)
                            .overlay(Image(systemName: u.1).font(.system(size: 14)).foregroundStyle(.white))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(u.0).font(.system(size: 16))
                            Text(u.2).font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(u.3) %").font(.system(size: 16)).foregroundStyle(.secondary)
                    }
                }
            }
            Section {
                HStack { Text("État de santé de la batterie"); Spacer(); Text("91 %").foregroundStyle(.secondary); Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5)) }
            }
        }
        .navigationTitle("Batterie")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

// ============================================================
// LOT 2 — Général, Informations, Notifications, Sons (contenus extraits des XML S2)
// ============================================================

// MARK: - Général v2 (fusion racine crawler + page S2)
struct GeneralV2Vue: View {
    var body: some View {
        List {
            Section {
                LigneSimpleRV2(nom: "Informations")
                LigneSimpleRV2(nom: "Mise à jour logicielle")
            }
            Section {
                LigneSimpleRV2(nom: "Stockage de l'iPhone")
                LigneSimpleRV2(nom: "Actualiser en arrière-plan")
            }
            Section {
                LigneSimpleRV2(nom: "AirDrop")
                LigneSimpleRV2(nom: "AirPlay et Continuité")
                LigneSimpleRV2(nom: "Image dans l'image")
            }
            Section {
                LigneSimpleRV2(nom: "Clavier")
                LigneSimpleRV2(nom: "Date et heure")
                LigneSimpleRV2(nom: "Dictionnaires")
                LigneSimpleRV2(nom: "Langue et région")
                LigneSimpleRV2(nom: "Polices")
                LigneSimpleRV2(nom: "Remplissage auto. et mots de passe")
                LigneSimpleRV2(nom: "Capture d'écran")
                LigneSimpleRV2(nom: "Fournisseur TV")
            }
            Section {
                LigneSimpleRV2(nom: "VPN et gestion de l'appareil")
            }
            Section {
                LigneSimpleRV2(nom: "Mentions légales et certifications")
            }
            Section {
                LigneSimpleRV2(nom: "Transférer ou réinitialiser l'iPhone")
                HStack { Spacer(); Text("Éteindre").foregroundStyle(.blue); Spacer() }
            }
        }
        .navigationTitle("Général")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct LigneSimpleRV2: View {
    let nom: String
    var valeur: String? = nil
    var body: some View {
        HStack {
            Text(nom).font(.system(size: 17))
            Spacer()
            if let v = valeur { Text(v).font(.system(size: 17)).foregroundStyle(.secondary) }
            Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if nom == "Informations" { NavV2.partage.pousser("reglages2.infos") }
        }
    }
}

// MARK: - Informations v2 (39 lignes réelles, données Sarah)
struct InformationsV2Vue: View {
    let lignes: [(String, String)] = [
        ("Nom", "iPhone de Sarah"),
        ("Version d'iOS", "26.6.1"),
        ("Nom du modèle", "iPhone 16"),
        ("N° du modèle", "MYED3F/A"),
        ("Numéro de série", "KX7P2Q0RD4"),
        ("Garantie limitée", "Expiration le 03/11/2026")
    ]
    let medias: [(String, String)] = [
        ("Morceaux", "127"), ("Vidéos", "58"), ("Photos", "1 243"), ("Apps", "31")
    ]
    let stockage: [(String, String)] = [
        ("Capacité", "128 Go"), ("Disponible", "41,7 Go")
    ]
    let reseau: [(String, String)] = [
        ("Réseau", "Free"), ("Wi-Fi", "Bbox-A47F2C"), ("Bluetooth", "58:2F:40:AA:19:C3")
    ]
    var body: some View {
        List {
            Section { ForEach(lignes, id: \.0) { l in LigneInfoV2(l) } }
            Section { ForEach(medias, id: \.0) { l in LigneInfoV2(l) } }
            Section { ForEach(stockage, id: \.0) { l in LigneInfoV2(l) } }
            Section { ForEach(reseau, id: \.0) { l in LigneInfoV2(l) } }
        }
        .navigationTitle("Informations")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct LigneInfoV2: View {
    let l: (String, String)
    init(_ l: (String, String)) { self.l = l }
    var body: some View {
        HStack { Text(l.0).font(.system(size: 17)); Spacer(); Text(l.1).font(.system(size: 17)).foregroundStyle(.secondary) }
    }
}

// MARK: - Notifications v2 (réf S2 : styles + réglages iOS 26 + liste d'apps)
struct NotificationsV2Vue: View {
    let apps: [(String, String, Color, String)] = [
        ("WhatsApp", "phone.fill", Color(red: 0.14, green: 0.83, blue: 0.4), "Bannières, Sons, Pastilles"),
        ("Ma Banque", "building.columns.fill", .white, "Bannières, Sons"),
        ("Mail", "envelope.fill", .blue, "Pastilles"),
        ("Messages", "message.fill", .green, "Bannières, Sons, Pastilles"),
        ("Messenger", "bubble.left.and.bubble.right.fill", .blue, "Désactivées")
    ]
    var body: some View {
        List {
            Section(header: Text("AFFICHAGE (ÉCRAN VERROUILLÉ)")) {
                HStack(spacing: 30) {
                    Spacer()
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 8).fill(Color(white: 0.2)).frame(width: 56, height: 100)
                            .overlay(Circle().fill(.white.opacity(0.6)).frame(width: 16, height: 16).offset(y: 34))
                        Text("Nombre").font(.system(size: 13))
                        Image(systemName: "circle").foregroundStyle(.secondary)
                    }
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 8).fill(Color(white: 0.2)).frame(width: 56, height: 100)
                            .overlay(VStack(spacing: 3) {
                                RoundedRectangle(cornerRadius: 2).fill(.white.opacity(0.6)).frame(width: 40, height: 9)
                                RoundedRectangle(cornerRadius: 2).fill(.white.opacity(0.6)).frame(width: 40, height: 9)
                            }.offset(y: 28))
                        Text("Liste").font(.system(size: 13))
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue)
                    }
                    Spacer()
                }.padding(.vertical, 6)
            }
            Section {
                LigneSimpleRV2(nom: "Résumé programmé", valeur: "Non")
                LigneSimpleRV2(nom: "Afficher les aperçus", valeur: "Si déverrouillé")
                LigneSimpleRV2(nom: "Partage d'écran", valeur: "Notif. désactivées")
            }
            Section {
                LigneSimpleRV2(nom: "Prioriser les notifications", valeur: "Activé")
                LigneSimpleRV2(nom: "Résumer les notifications", valeur: "Non")
                LigneSimpleRV2(nom: "Annoncer les notifications", valeur: "Activé")
            }
            Section {
                LigneSimpleRV2(nom: "Suggestions de Siri")
            }
            Section(header: Text("STYLE DE NOTIFICATION")) {
                ForEach(apps, id: \.0) { a in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(a.2 == .white ? Color.white : a.2)
                            .frame(width: 30, height: 30)
                            .overlay(Image(systemName: a.1).font(.system(size: 14)).foregroundStyle(a.2 == .white ? Color.black : .white))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(a.0).font(.system(size: 16))
                            Text(a.3).font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Sons et vibrations v2 (réf S2 : Reflet, Note, Gouttelette...)
struct SonsV2Vue: View {
    @State private var barre = true
    @State private var boutons = true
    @State private var silence = false
    var body: some View {
        List {
            Section(header: Text("MODE SILENCE")) {
                Toggle("Mode Silence", isOn: $silence)
                Toggle("Afficher dans la barre d'état", isOn: $barre)
            }
            Section {
                LigneSimpleRV2(nom: "Entrée", valeur: "Micro de l'iPhone")
            }
            Section(header: Text("VOLUME (SONNERIE ET ALERTES)")) {
                HStack(spacing: 10) {
                    Image(systemName: "speaker.fill").foregroundStyle(.secondary)
                    Slider(value: .constant(0.55))
                    Image(systemName: "speaker.wave.3.fill").foregroundStyle(.secondary)
                }
                Toggle("Utiliser les boutons", isOn: $boutons)
            }
            Section {
                LigneSimpleRV2(nom: "Vibrations", valeur: "Vibrer en mode Silence")
            }
            Section(header: Text("SONS ET SÉQUENCES DE VIBRATION")) {
                LigneSimpleRV2(nom: "Sonnerie", valeur: "Reflet")
                LigneSimpleRV2(nom: "Son SMS", valeur: "Note")
                LigneSimpleRV2(nom: "Nouv. message vocal", valeur: "Gouttelette")
                LigneSimpleRV2(nom: "Alertes de calendrier", valeur: "Accord")
                LigneSimpleRV2(nom: "Alertes de rappel", valeur: "Carillon")
                LigneSimpleRV2(nom: "AirDrop", valeur: "Impulsion")
            }
        }
        .navigationTitle("Sons et vibrations")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}
