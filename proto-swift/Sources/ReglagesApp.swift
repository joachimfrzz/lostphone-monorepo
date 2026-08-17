// App RÉGLAGES iOS 26 — construite contre refs-reglages/ (2 vidéos réelles du 17/08, 454 s)
// Liste principale en groupes, recherche plein écran avec suggestions, Compte Apple complet,
// Wi-Fi, Bluetooth, Batterie, Général (Informations, MàJ, Stockage), Temps d'écran,
// Fond d'écran, Luminosité, Notifications, Sons, Face ID verrouillé par code, Cartes et Apple Pay.
// Règles D51-D55 : tout répond — vrai contenu ou échec plausible (D53). Canon : Sarah Levasseur.
import SwiftUI

let regFond = Color(hex: 0x000000)
let regCarte = Color(hex: 0x1C1C1E)
let regBleu = Color(hex: 0x0A84FF)
let regVert = Color(hex: 0x30D158)
let regRouge = Color(hex: 0xFF453A)
let regTexte = Color(hex: 0xF2F2F2)
let regTexte2 = Color(hex: 0x8E8E93)

// ============================================================ COMPOSANTS DE BASE
struct RegIcone: View {
    let symbole: String
    let fond: Color
    var teinte: Color = .white
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(fond)
            .frame(width: 30, height: 30)
            .overlay(Image(systemName: symbole).font(.system(size: 16)).foregroundStyle(teinte))
    }
}

struct RegLigne<Destination: View>: View {
    let symbole: String
    let fond: Color
    let nom: String
    var valeur: String? = nil
    @ViewBuilder let destination: () -> Destination
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                RegIcone(symbole: symbole, fond: fond)
                Text(nom).font(.system(size: 16)).foregroundStyle(regTexte)
                    .lineLimit(2).multilineTextAlignment(.leading)
                Spacer()
                if let valeur {
                    Text(valeur).font(.system(size: 16)).foregroundStyle(regTexte2)
                }
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(regTexte2.opacity(0.6))
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct RegBascule: View {
    let symbole: String
    let fond: Color
    let nom: String
    @Binding var valeur: Bool
    var body: some View {
        HStack(spacing: 12) {
            RegIcone(symbole: symbole, fond: fond)
            Text(nom).font(.system(size: 16)).foregroundStyle(regTexte)
            Spacer()
            Toggle("", isOn: $valeur).labelsHidden().tint(regVert)
        }
        .padding(.horizontal, 14).padding(.vertical, 6)
    }
}

struct RegGroupe<Contenu: View>: View {
    @ViewBuilder let contenu: () -> Contenu
    var body: some View {
        VStack(spacing: 0) { contenu() }
            .background(regCarte, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
    }
}

struct RegSeparateur: View {
    var retrait: CGFloat = 56
    var body: some View {
        Divider().overlay(Color.white.opacity(0.08)).padding(.leading, retrait)
    }
}

// Écran générique : chargement qui échoue proprement (D53 — comme une vraie app)
struct RegGeneriqueVue: View {
    let nom: String
    @State private var echec = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            if echec {
                VStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 34)).foregroundStyle(regTexte2)
                    Text("Impossible de charger « \(nom) ». Vérifiez votre connexion.")
                        .font(.system(size: 15)).foregroundStyle(regTexte2)
                        .multilineTextAlignment(.center).padding(.horizontal, 40)
                }
            } else {
                ProgressView().tint(regTexte2)
            }
        }
        .navigationTitle(nom)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { echec = true }
        }
    }
}

// ============================================================ RÉGLAGES — RACINE
struct ReglagesVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var modeAvion = false
    @State private var rechercheVisible = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                regFond.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        HStack {
                            Text("Réglages").font(.system(size: 33, weight: .bold)).foregroundStyle(regTexte)
                            Spacer()
                        }
                        .padding(.horizontal, 18).padding(.top, 14)

                        // Carte Compte Apple (canon : Sarah Levasseur)
                        RegGroupe {
                            NavigationLink { CompteAppleVue() } label: {
                                HStack(spacing: 12) {
                                    AvatarMsg(nom: "Sarah Levasseur", taille: 46)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Sarah Levasseur").font(.system(size: 18)).foregroundStyle(regTexte)
                                        Text("Compte Apple, iCloud+ et autres")
                                            .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(regTexte2.opacity(0.6))
                                }
                                .padding(14)
                                .contentShape(Rectangle())
                            }.buttonStyle(.plain)
                        }

                        RegGroupe {
                            NavigationLink { MiseAJourVue() } label: {
                                HStack {
                                    Text("Mise à jour du logiciel cette nuit")
                                        .font(.system(size: 16)).foregroundStyle(regTexte)
                                    Spacer()
                                    Text("1").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                                        .frame(width: 22, height: 22)
                                        .background(regRouge, in: Circle())
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(regTexte2.opacity(0.6))
                                }
                                .padding(.horizontal, 14).padding(.vertical, 11)
                                .contentShape(Rectangle())
                            }.buttonStyle(.plain)
                        }

                        RegGroupe {
                            RegBascule(symbole: "airplane", fond: Color(hex: 0xFF9F0A), nom: "Mode Avion", valeur: $modeAvion)
                            RegSeparateur()
                            RegLigne(symbole: "wifi", fond: regBleu, nom: "Wi-Fi",
                                     valeur: modeAvion ? "Non connecté" : "Livebox-2C48") { WiFiVue() }
                            RegSeparateur()
                            RegLigne(symbole: "personalhotspot", fond: regBleu, nom: "Bluetooth", valeur: "Oui") { BluetoothVue() }
                            RegSeparateur()
                            RegLigne(symbole: "antenna.radiowaves.left.and.right", fond: regVert, nom: "Données cellulaires") { DonneesCellVue() }
                            RegSeparateur()
                            RegLigne(symbole: "person.2.wave.2.fill", fond: regVert, nom: "Partage de connexion") { RegContenuVue(nom: "Partage de connexion") }
                            RegSeparateur()
                            RegLigne(symbole: "battery.100", fond: regVert, nom: "Batterie") { BatterieVue() }
                            RegSeparateur()
                            RegLigne(symbole: "network", fond: regBleu, nom: "VPN", valeur: "Déconnecté") { RegContenuVue(nom: "VPN") }
                        }

                        RegGroupe {
                            RegLigne(symbole: "gear", fond: Color(hex: 0x8E8E93), nom: "Général") { GeneralVue() }
                            RegSeparateur()
                            RegLigne(symbole: "accessibility", fond: regBleu, nom: "Accessibilité") { RegContenuVue(nom: "Accessibilité") }
                            RegSeparateur()
                            RegLigne(symbole: "camera.fill", fond: Color(hex: 0x8E8E93), nom: "Appareil photo") { RegContenuVue(nom: "Appareil photo") }
                            RegSeparateur()
                            RegLigne(symbole: "sparkles", fond: Color(hex: 0x5E5CE6), nom: "Apple Intelligence et Siri") { RegContenuVue(nom: "Apple Intelligence et Siri") }
                            RegSeparateur()
                            RegLigne(symbole: "button.horizontal.top.press", fond: regBleu, nom: "Bouton Action") { RegContenuVue(nom: "Bouton Action") }
                            RegSeparateur()
                            RegLigne(symbole: "switch.2", fond: Color(hex: 0x8E8E93), nom: "Centre de contrôle") { CentreControleVue() }
                            RegSeparateur()
                            RegLigne(symbole: "square.grid.3x3.fill", fond: regBleu, nom: "Écran d'accueil et bibliothèque d'apps") { EcranAccueilVue() }
                            RegSeparateur()
                            RegLigne(symbole: "clock.fill", fond: Color(hex: 0x30B0C7), nom: "En veille") { RegContenuVue(nom: "En veille") }
                            RegSeparateur()
                            RegLigne(symbole: "photo.on.rectangle", fond: Color(hex: 0x30B0C7), nom: "Fond d'écran") { FondEcranVue() }
                            RegSeparateur()
                            RegLigne(symbole: "sun.max.fill", fond: regBleu, nom: "Luminosité et affichage") { LuminositeVue() }
                            RegSeparateur()
                            RegLigne(symbole: "magnifyingglass", fond: Color(hex: 0x8E8E93), nom: "Recherche") { RechercheReglagesInfoVue() }
                        }

                        RegGroupe {
                            RegLigne(symbole: "bell.badge.fill", fond: regRouge, nom: "Notifications") { NotificationsVue() }
                            RegSeparateur()
                            RegLigne(symbole: "speaker.wave.3.fill", fond: regRouge, nom: "Sons et vibrations") { SonsVue() }
                            RegSeparateur()
                            RegLigne(symbole: "moon.fill", fond: Color(hex: 0x5E5CE6), nom: "Concentration") { RegContenuVue(nom: "Concentration") }
                            RegSeparateur()
                            RegLigne(symbole: "hourglass", fond: Color(hex: 0x5E5CE6), nom: "Temps d'écran") { TempsEcranVue() }
                        }

                        RegGroupe {
                            RegLigne(symbole: "faceid", fond: regVert, nom: "Face ID et code") { FaceIDVue() }
                            RegSeparateur()
                            RegLigne(symbole: "sos", fond: regRouge, nom: "Appel d'urgence") { RegContenuVue(nom: "Appel d'urgence") }
                            RegSeparateur()
                            RegLigne(symbole: "hand.raised.fill", fond: regBleu, nom: "Confidentialité et sécurité") { ConfidentialiteVue() }
                        }

                        RegGroupe {
                            RegLigne(symbole: "creditcard.fill", fond: Color(hex: 0x32ADE6), nom: "Cartes et Apple Pay") { CartesPayVue() }
                            RegSeparateur()
                            RegLigne(symbole: "gamecontroller.fill", fond: Color(hex: 0x8E8E93), nom: "Game Center") { RegContenuVue(nom: "Game Center") }
                            RegSeparateur()
                            RegLigne(symbole: "icloud.fill", fond: regBleu, nom: "iCloud") { ICloudVue() }
                        }

                        RegGroupe {
                            RegLigne(symbole: "square.grid.2x2.fill", fond: Color(hex: 0x8E8E93), nom: "Apps") { AppsListeVue() }
                        }

                        Color.clear.frame(height: 80)
                    }
                }
                .scrollIndicators(.hidden)

                // Pilule Recherche flottante (iOS 26)
                HStack(spacing: 7) {
                    Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(regTexte2)
                    Text("Recherche").font(.system(size: 16)).foregroundStyle(regTexte2)
                    Spacer()
                    Image(systemName: "mic.fill").font(.system(size: 15)).foregroundStyle(regTexte2)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color(hex: 0x1F1F21), in: Capsule())
                .padding(.horizontal, 16).padding(.bottom, 8)
                .contentShape(Capsule())
                .onTapGesture { Haptique.leger(); rechercheVisible = true }

                // Geste home : quitter l'app
                Color.clear.frame(height: 10)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 20).onEnded { v in
                        if v.translation.height < -35 { dismiss() }
                    })
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $rechercheVisible) { RechercheReglagesVue() }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ RECHERCHE DES RÉGLAGES
struct RechercheReglagesVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var saisie = ""
    @FocusState private var focalise: Bool

    // Index plat : nom affiché → chemin
    private let index: [(String, String)] = [
        ("Wi-Fi", ""), ("Bluetooth", ""), ("Batterie", ""), ("Général", ""),
        ("Informations", "Général"), ("Mise à jour logicielle", "Général"),
        ("Stockage de l'iPhone", "Général"), ("Fond d'écran", ""),
        ("Luminosité et affichage", ""), ("Notifications", ""),
        ("Sons et vibrations", ""), ("Temps d'écran", ""),
        ("Face ID et code", ""), ("Cartes et Apple Pay", ""),
        ("iCloud", "Compte Apple"), ("Abonnements", "Compte Apple"),
        ("Dictée", "Général → Clavier"), ("Langues pour la dictée", "Général → Clavier"),
        ("Mode Avion", ""), ("VPN", ""), ("Apps", ""),
    ]

    private var resultats: [(String, String)] {
        guard !saisie.isEmpty else { return [] }
        return index.filter { $0.0.localizedCaseInsensitiveContains(saisie) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                regFond.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Suggestions / résultats
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            if saisie.isEmpty {
                                Text("Suggestions").font(.system(size: 13)).foregroundStyle(regTexte2)
                                    .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 6)
                                RegGroupe {
                                    SuggestionRecherche(symbole: "icloud.fill", nom: "iCloud", detail: "Compte Apple")
                                    RegSeparateur(retrait: 50)
                                    SuggestionRecherche(symbole: "externaldrive.fill.badge.icloud", nom: "Enregistré sur iCloud", detail: "Compte Apple → iCloud")
                                    RegSeparateur(retrait: 50)
                                    SuggestionRecherche(symbole: "personalhotspot", nom: "Bluetooth", detail: "")
                                    RegSeparateur(retrait: 50)
                                    SuggestionRecherche(symbole: "button.horizontal.top.press", nom: "Bouton Action", detail: "")
                                }
                            } else if resultats.isEmpty {
                                VStack(spacing: 8) {
                                    Text("Aucun résultat").font(.system(size: 17, weight: .semibold)).foregroundStyle(regTexte)
                                    Text("Essayez un autre terme.").font(.system(size: 14)).foregroundStyle(regTexte2)
                                }
                                .frame(maxWidth: .infinity).padding(.top, 60)
                            } else {
                                RegGroupe {
                                    ForEach(Array(resultats.enumerated()), id: \.offset) { i, r in
                                        SuggestionRecherche(symbole: "gear", nom: r.0, detail: r.1)
                                        if i < resultats.count - 1 { RegSeparateur(retrait: 50) }
                                    }
                                }
                                .padding(.top, 14)
                            }
                        }
                    }

                    // Champ de saisie bas (comme la référence)
                    HStack(spacing: 8) {
                        HStack(spacing: 7) {
                            Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(regTexte2)
                            TextField("", text: $saisie,
                                      prompt: Text("Recherche").foregroundStyle(regTexte2))
                                .font(.system(size: 16)).foregroundStyle(regTexte)
                                .focused($focalise)
                            if !saisie.isEmpty {
                                Image(systemName: "xmark.circle.fill").font(.system(size: 15)).foregroundStyle(regTexte2)
                                    .onTapGesture { saisie = "" }
                            }
                        }
                        .padding(.horizontal, 13).padding(.vertical, 11)
                        .background(Color(hex: 0x1F1F21), in: Capsule())
                        Image(systemName: "xmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(regTexte)
                            .padding(12).background(Color(hex: 0x1F1F21), in: Circle())
                            .onTapGesture { dismiss() }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                }
            }
            .onAppear { focalise = true }
        }
        .preferredColorScheme(.dark)
    }
}

struct SuggestionRecherche: View {
    let symbole: String
    let nom: String
    let detail: String
    @State private var erreur = false
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbole).font(.system(size: 16)).foregroundStyle(regTexte2)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 1) {
                Text(nom).font(.system(size: 16)).foregroundStyle(regTexte)
                if !detail.isEmpty {
                    Text(detail).font(.system(size: 12.5)).foregroundStyle(regTexte2)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .contentShape(Rectangle())
        .onTapGesture { erreur = true }
        .alert("Réglages", isPresented: $erreur) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Fermez la recherche pour ouvrir « \(nom) » depuis la liste.")
        }
    }
}

// Écran « Recherche » (réglages de la recherche système)
struct RechercheReglagesInfoVue: View {
    @State private var recentes = true
    @State private var contenu = true
    @State private var ameliorer = true
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("Recherche et Chercher").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 12)
                    RegGroupe {
                        LigneBascule(nom: "Afficher les recherches récentes", valeur: $recentes)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Afficher le contenu associé", valeur: $contenu)
                    }
                    RegGroupe {
                        LigneBascule(nom: "Aider Apple à améliorer la recherche", valeur: $ameliorer)
                    }
                    Text("Les recherches incluent les recherches d'ordre général, ainsi que les requêtes pour effectuer des actions, comme lire de la musique ou obtenir des itinéraires.")
                        .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        .padding(.horizontal, 20)
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Rechercher")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ============================================================ COMPTE APPLE (Sarah)
struct CompteAppleVue: View {
    @State private var deconnexion = false
    @State private var erreurDeco = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    AvatarMsg(nom: "Sarah Levasseur", taille: 88).padding(.top, 8)
                    VStack(spacing: 2) {
                        Text("Sarah Levasseur").font(.system(size: 24, weight: .semibold)).foregroundStyle(regTexte)
                        Text("sarah.levasseur@gmail.com").font(.system(size: 14)).foregroundStyle(regTexte2)
                    }

                    RegGroupe {
                        RegLigne(symbole: "person.text.rectangle", fond: regBleu, nom: "Infos personnelles") { InfosPersoVue() }
                        RegSeparateur()
                        RegLigne(symbole: "lock.shield", fond: Color(hex: 0x8E8E93), nom: "Connexion et sécurité") { ConnexionSecuVue() }
                        RegSeparateur()
                        RegLigne(symbole: "creditcard", fond: regVert, nom: "Paiement et livraison", valeur: "Visa") { PaiementVue() }
                        RegSeparateur()
                        RegLigne(symbole: "arrow.triangle.2.circlepath", fond: Color(hex: 0x8E8E93), nom: "Abonnements") { AbonnementsVue() }
                    }

                    RegGroupe {
                        RegLigne(symbole: "icloud.fill", fond: regBleu, nom: "iCloud", valeur: "200 Go") { ICloudVue() }
                        RegSeparateur()
                        RegLigne(symbole: "figure.2.and.child.holdinghands", fond: Color(hex: 0xFF9F0A), nom: "Famille", valeur: "Configurer") { RegContenuVue(nom: "Famille") }
                        RegSeparateur()
                        RegLigne(symbole: "location.fill", fond: regVert, nom: "Localiser") { RegContenuVue(nom: "Localiser") }
                        RegSeparateur()
                        RegLigne(symbole: "play.rectangle.fill", fond: regBleu, nom: "Contenu multimédia et achats") { RegGeneriqueVue(nom: "Contenu multimédia et achats") }
                        RegSeparateur()
                        RegLigne(symbole: "apple.logo", fond: Color(hex: 0x1C1C1E), nom: "Se connecter avec Apple") { RegGeneriqueVue(nom: "Se connecter avec Apple") }
                    }

                    // Appareils (canon : le téléphone trouvé + l'iPad resté chez elle)
                    RegGroupe {
                        HStack(spacing: 12) {
                            Image(systemName: "iphone").font(.system(size: 22)).foregroundStyle(regTexte)
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("iPhone de Sarah").font(.system(size: 16)).foregroundStyle(regTexte)
                                Text("Cet appareil (iPhone 15)").font(.system(size: 12.5)).foregroundStyle(regTexte2)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        RegSeparateur(retrait: 56)
                        RegLigne(symbole: "ipad", fond: Color(hex: 0x1C1C1E), nom: "iPad de Sarah", valeur: "") { RegContenuVue(nom: "iPad de Sarah") }
                    }

                    RegGroupe {
                        Text("Se déconnecter")
                            .font(.system(size: 16)).foregroundStyle(regRouge)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                            .onTapGesture { deconnexion = true }
                    }
                    Color.clear.frame(height: 40)
                }
            }
        }
        .navigationTitle("Compte Apple")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Se déconnecter ?", isPresented: $deconnexion, titleVisibility: .visible) {
            Button("Se déconnecter", role: .destructive) { erreurDeco = true }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Vos données iCloud seront retirées de cet iPhone.")
        }
        .alert("Compte Apple", isPresented: $erreurDeco) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("La déconnexion n'est pas disponible : saisissez d'abord le mot de passe du compte.")
        }
    }
}

struct InfosPersoVue: View {
    @State private var partage = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        HStack {
                            Text("Nom").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Sarah Levasseur").font(.system(size: 16)).foregroundStyle(regTexte2)
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                    }
                    RegGroupe {
                        LigneBascule(nom: "Partage du nom et de la photo", valeur: $partage)
                    }
                    RegGroupe {
                        HStack {
                            Text("Date de naissance").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("14 mars 1987").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("Préférences de communication").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle("Informations personnelles")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ConnexionSecuVue: View {
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("E-mails et numéros").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 12)
                    RegGroupe {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("sarah.levasseur@gmail.com").font(.system(size: 16)).foregroundStyle(regTexte)
                            Text("Adresse e-mail principale").font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                        RegSeparateur(retrait: 14)
                        Text("+33 6 12 84 55 07").font(.system(size: 16)).foregroundStyle(regTexte)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                        RegSeparateur(retrait: 14)
                        Text("Ajouter un e-mail ou un numéro").font(.system(size: 16)).foregroundStyle(regBleu)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                    }
                    Text("Sécurité").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        Text("Modifier le mot de passe").font(.system(size: 16)).foregroundStyle(regBleu)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("Identification à deux facteurs").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Activée").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    Text("Méthodes de récupération").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        HStack {
                            Text("Contacts de récupération").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Configurer").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("Clé de secours").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Configurer").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Connexion et sécurité")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PaiementVue: View {
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("Modes de paiement").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 12)
                    RegGroupe {
                        HStack(spacing: 12) {
                            Text("Pay").font(.system(size: 14, weight: .semibold)).foregroundStyle(.black)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(.white, in: RoundedRectangle(cornerRadius: 5))
                            Text("Apple Pay").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 4).fill(Color(hex: 0x00539B)).frame(width: 34, height: 24)
                                .overlay(Text("LCL").font(.system(size: 9, weight: .bold)).foregroundStyle(.white))
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Carte LCL Visa").font(.system(size: 16)).foregroundStyle(regTexte)
                                Text("•••• 8207 (Apple Pay)").font(.system(size: 12.5)).foregroundStyle(regTexte2)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        Text("Ajouter un mode de paiement").font(.system(size: 16)).foregroundStyle(regBleu)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                        RegSeparateur(retrait: 14)
                        Text("Ajouter de l'argent au compte Apple").font(.system(size: 16)).foregroundStyle(regBleu)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                    }
                    Text("Adresse de livraison").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sarah Levasseur").font(.system(size: 16)).foregroundStyle(regTexte)
                            Text("26 rue des Fantasques, 69001 Lyon").font(.system(size: 13.5)).foregroundStyle(regTexte2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Paiement et livraison")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AbonnementsVue: View {
    // Or narratif : Meetic (la rencontre), le reste banal
    private let actifs: [(String, String, String, String)] = [
        ("heart.circle.fill", "Meetic Premium", "Renouv. le 3 septembre", "29,99 €"),
        ("icloud.fill", "iCloud+", "200 Go de stockage · Renouv. le 23 août", "2,99 €"),
        ("music.note", "Deezer Premium", "Renouv. le 12 septembre", "11,99 €"),
    ]
    private let inactifs: [(String, String, String)] = [
        ("face.smiling.inverse", "FaceApp : Perfect Face Editor", "A expiré le 17 février"),
    ]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        ForEach(Array(actifs.enumerated()), id: \.offset) { i, a in
                            HStack(spacing: 12) {
                                RegIcone(symbole: a.0, fond: Color(hex: 0x3A3A3E))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(a.1).font(.system(size: 16)).foregroundStyle(regTexte)
                                    Text(a.2).font(.system(size: 12.5)).foregroundStyle(regTexte2)
                                }
                                Spacer()
                                Text(a.3).font(.system(size: 15)).foregroundStyle(regTexte2)
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            if i < actifs.count - 1 { RegSeparateur() }
                        }
                    }
                    .padding(.top, 12)
                    Text("Inactif").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        ForEach(Array(inactifs.enumerated()), id: \.offset) { _, a in
                            HStack(spacing: 12) {
                                RegIcone(symbole: a.0, fond: Color(hex: 0x3A3A3E))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(a.1).font(.system(size: 16)).foregroundStyle(regTexte)
                                    Text(a.2).font(.system(size: 12.5)).foregroundStyle(regTexte2)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                        }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Abonnements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ICloudVue: View {
    @State private var basculesApps: [String: Bool] = [
        "Photos": true, "Rappels": true, "Safari": true, "Maison": true,
        "Cartes": true, "Siri": true, "Téléphone et FaceTime": true,
        "Livres": true, "Pages": true, "WhatsApp": true,
    ]
    private let ordre = ["Photos", "Rappels", "Safari", "Maison", "Cartes", "Siri", "Téléphone et FaceTime", "WhatsApp", "Livres", "Pages"]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    // Barre de stockage
                    RegGroupe {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("iCloud+").font(.system(size: 16, weight: .semibold)).foregroundStyle(regTexte)
                                Spacer()
                                Text("173,2 Go sur 200 Go").font(.system(size: 13)).foregroundStyle(regTexte2)
                            }
                            GeometryReader { geo in
                                HStack(spacing: 2) {
                                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: 0xFFD60A)).frame(width: geo.size.width * 0.55)
                                    RoundedRectangle(cornerRadius: 2).fill(regBleu).frame(width: geo.size.width * 0.22)
                                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: 0x8E8E93)).frame(width: geo.size.width * 0.09)
                                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: 0x3A3A3E))
                                }
                            }
                            .frame(height: 7)
                            HStack(spacing: 12) {
                                Etiquette(couleur: Color(hex: 0xFFD60A), nom: "Photos")
                                Etiquette(couleur: regBleu, nom: "Sauvegardes")
                                Etiquette(couleur: Color(hex: 0x8E8E93), nom: "Docs")
                            }
                        }
                        .padding(14)
                    }
                    .padding(.top, 12)
                    RegGroupe {
                        HStack {
                            Text("Sauvegarde iCloud").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Il y a 26 jours").font(.system(size: 15)).foregroundStyle(Color(hex: 0xFF9F0A))
                        }
                        .padding(14)
                    }
                    Text("La dernière sauvegarde n'a pas pu être effectuée : espace iCloud insuffisant.")
                        .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    Text("Apps utilisant iCloud").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        ForEach(Array(ordre.enumerated()), id: \.offset) { i, app in
                            HStack {
                                Text(app).font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { basculesApps[app] ?? false },
                                    set: { basculesApps[app] = $0 }
                                )).labelsHidden().tint(regVert)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 6)
                            if i < ordre.count - 1 { RegSeparateur(retrait: 14) }
                        }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("iCloud")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Etiquette: View {
    let couleur: Color
    let nom: String
    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(couleur).frame(width: 7, height: 7)
            Text(nom).font(.system(size: 11)).foregroundStyle(regTexte2)
        }
    }
}

// ============================================================ MISE À JOUR LOGICIELLE
struct MiseAJourVue: View {
    @State private var programmee = true
    @State private var verification = false
    @State private var erreur = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        HStack {
                            Text("MÀJ automatiques").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Oui").font(.system(size: 16)).foregroundStyle(regTexte2)
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                    }
                    .padding(.top, 12)

                    RegGroupe {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8).fill(
                                    LinearGradient(colors: [Color(hex: 0x3A7BD5), Color(hex: 0x9B59B6)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 44, height: 44)
                                    .overlay(Image(systemName: "gear").foregroundStyle(.white))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("iOS 26.6.1").font(.system(size: 16, weight: .semibold)).foregroundStyle(regTexte)
                                    Text("Téléchargée").font(.system(size: 12.5)).foregroundStyle(regTexte2)
                                }
                            }
                            Text("Cette mise à jour apporte des correctifs de sécurité importants pour votre iPhone.")
                                .font(.system(size: 14)).foregroundStyle(regTexte)
                        }
                        .padding(14)
                    }

                    if programmee {
                        RegGroupe {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Mise à jour programmée").font(.system(size: 16, weight: .semibold)).foregroundStyle(regTexte)
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(regVert)
                                }
                                Text("iOS 26.6.1 sera installé lorsque l'iPhone sera verrouillé et suffisamment chargé pour effectuer la mise à jour.")
                                    .font(.system(size: 13.5)).foregroundStyle(regTexte2)
                                Text("Mettre à jour").font(.system(size: 15)).foregroundStyle(regBleu)
                                    .padding(.top, 4)
                                    .onTapGesture {
                                        verification = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            verification = false; erreur = true
                                        }
                                    }
                                Text("Annuler la mise à jour").font(.system(size: 15)).foregroundStyle(regRouge)
                                    .onTapGesture { programmee = false }
                            }
                            .padding(14)
                        }
                    }
                    if verification {
                        HStack(spacing: 8) {
                            ProgressView().tint(regTexte2)
                            Text("Préparation de la mise à jour…").font(.system(size: 13.5)).foregroundStyle(regTexte2)
                        }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Mise à jour logicielle")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Mise à jour", isPresented: $erreur) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Impossible d'installer maintenant : branchez l'iPhone ou réessayez cette nuit.")
        }
    }
}

// ============================================================ WI-FI / BLUETOOTH / DONNÉES
struct WiFiVue: View {
    @State private var actif = true
    @State private var erreur = false
    @State private var reseau = ""
    private let autres = ["Freebox-9A21", "SFR_A0F8", "Livebox-6E11"]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        HStack {
                            Text("Wi-Fi").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Toggle("", isOn: $actif).labelsHidden().tint(regVert)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                    }
                    .padding(.top, 12)
                    if actif {
                        RegGroupe {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark").font(.system(size: 14, weight: .semibold)).foregroundStyle(regBleu)
                                Text("Livebox-2C48").font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Image(systemName: "lock.fill").font(.system(size: 12)).foregroundStyle(regTexte2)
                                Image(systemName: "wifi").font(.system(size: 14)).foregroundStyle(regTexte)
                                Image(systemName: "info.circle").font(.system(size: 16)).foregroundStyle(regBleu)
                            }
                            .padding(14)
                        }
                        Text("Autres réseaux").font(.system(size: 13)).foregroundStyle(regTexte2)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                        RegGroupe {
                            ForEach(Array(autres.enumerated()), id: \.offset) { i, r in
                                HStack(spacing: 10) {
                                    Text(r).font(.system(size: 16)).foregroundStyle(regTexte)
                                    Spacer()
                                    Image(systemName: "lock.fill").font(.system(size: 12)).foregroundStyle(regTexte2)
                                    Image(systemName: "wifi").font(.system(size: 14)).foregroundStyle(regTexte2)
                                }
                                .padding(14)
                                .contentShape(Rectangle())
                                .onTapGesture { reseau = r; erreur = true }
                                if i < autres.count - 1 { RegSeparateur(retrait: 14) }
                            }
                        }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Wi-Fi")
        .navigationBarTitleDisplayMode(.inline)
        .alert("« \(reseau) »", isPresented: $erreur) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Mot de passe requis pour rejoindre ce réseau.")
        }
    }
}

struct BluetoothVue: View {
    @State private var actif = true
    @State private var erreur = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        HStack {
                            Text("Bluetooth").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Toggle("", isOn: $actif).labelsHidden().tint(regVert)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                    }
                    .padding(.top, 12)
                    if actif {
                        Text("Mes appareils").font(.system(size: 13)).foregroundStyle(regTexte2)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                        RegGroupe {
                            HStack {
                                Text("AirPods de Sarah").font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Text("Non connecté").font(.system(size: 15)).foregroundStyle(regTexte2)
                                Image(systemName: "info.circle").font(.system(size: 16)).foregroundStyle(regBleu)
                            }
                            .padding(14)
                            .contentShape(Rectangle())
                            .onTapGesture { erreur = true }
                            RegSeparateur(retrait: 14)
                            HStack {
                                Text("Enceinte JBL Flip").font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Text("Non connecté").font(.system(size: 15)).foregroundStyle(regTexte2)
                                Image(systemName: "info.circle").font(.system(size: 16)).foregroundStyle(regBleu)
                            }
                            .padding(14)
                            .contentShape(Rectangle())
                            .onTapGesture { erreur = true }
                        }
                        Text("Autres appareils").font(.system(size: 13)).foregroundStyle(regTexte2)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                        HStack(spacing: 8) {
                            ProgressView().tint(regTexte2)
                            Text("Recherche…").font(.system(size: 14)).foregroundStyle(regTexte2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Bluetooth")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Appareil hors de portée", isPresented: $erreur) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Rapprochez-vous de l'appareil pour vous y connecter.")
        }
    }
}

struct DonneesCellVue: View {
    @State private var donnees = true
    @State private var itinerance = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        LigneBascule(nom: "Données cellulaires", valeur: $donnees)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Itinérance des données", valeur: $itinerance)
                    }
                    .padding(.top, 12)
                    Text("Consommation").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        HStack {
                            Text("Période en cours").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("14,7 Go").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("WhatsApp").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("9,2 Go").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("Safari").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("2,1 Go").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Données cellulaires")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ============================================================ BATTERIE (fidèle à la vidéo du 17/08, 12h10)
struct BatterieVue: View {
    @State private var pourcentage = true
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    // Gros pourcentage + dernier niveau de charge
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Text("34").font(.system(size: 44, weight: .semibold)).foregroundStyle(regTexte)
                            Text("%").font(.system(size: 20, weight: .semibold)).foregroundStyle(regTexte2)
                            Spacer()
                            Image(systemName: "info.circle").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        Text("Dernier niveau de charge : 78 % 07:12")
                            .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(hex: 0x2C2C2E))
                                Capsule().fill(regVert).frame(width: geo.size.width * 0.34)
                            }
                        }
                        .frame(height: 5)
                    }
                    .padding(.horizontal, 20).padding(.top, 12)

                    Text("Utilisation quotidienne").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Vous avez utilisé plus de batterie aujourd'hui qu'en temps normal à 12:10.")
                                .font(.system(size: 14)).foregroundStyle(regTexte)
                            GraphSemaineBatterie()
                            HStack(spacing: 5) {
                                Circle().fill(regTexte2).frame(width: 5, height: 5)
                                Text("Journée entière").font(.system(size: 11)).foregroundStyle(regTexte2)
                                Circle().fill(Color(hex: 0xFF9F0A)).frame(width: 5, height: 5)
                                Text("Quotidiennement à 12:10").font(.system(size: 11)).foregroundStyle(regTexte2)
                            }
                        }
                        .padding(14)
                    }

                    Text("Activité des apps et du système").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        LigneAppBatterie(nom: "WhatsApp", detail: "1h 12min de plus à l'écran", part: "24 %", alerte: true)
                        RegSeparateur()
                        LigneAppBatterie(nom: "Safari", detail: "18min de plus à l'écran", part: "9 %", alerte: true)
                        RegSeparateur()
                        LigneAppBatterie(nom: "Téléphone", detail: "À l'écran : 21min", part: "8 %", alerte: true)
                        RegSeparateur()
                        LigneAppBatterie(nom: "Écran d'accueil et verrouillé", detail: "À l'écran : 14min", part: "6 %", alerte: true)
                        RegSeparateur()
                        NavigationLink { UtilisationBatterieVue() } label: {
                            HStack {
                                Text("Voir toute l'utilisation de la batterie")
                                    .font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(regTexte2.opacity(0.6))
                            }
                            .padding(14)
                            .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }

                    RegGroupe {
                        NavigationLink { EtatSanteVue() } label: {
                            HStack {
                                Text("État de santé de la batterie").font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Text("Normal").font(.system(size: 16)).foregroundStyle(regTexte2)
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(regTexte2.opacity(0.6))
                            }
                            .padding(14)
                            .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("En charge").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("Mode d'alimentation").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Adaptatif").font(.system(size: 16)).foregroundStyle(regTexte2)
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Pourcentage de la batterie", valeur: $pourcentage)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Batterie")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Comparaison Moyenne / Aujourd'hui + barres hebdomadaires (L M M J V S D L, aujourd'hui en orange)
struct GraphSemaineBatterie: View {
    private let jours = ["L", "M", "M", "J", "V", "S", "D", "L"]
    private let hauteurs: [CGFloat] = [34, 42, 30, 38, 46, 58, 72, 86]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 26) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Moyenne").font(.system(size: 12)).foregroundStyle(regTexte2)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("21").font(.system(size: 20, weight: .semibold)).foregroundStyle(regTexte)
                        Text("%").font(.system(size: 12)).foregroundStyle(regTexte2)
                    }
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Aujourd'hui").font(.system(size: 12)).foregroundStyle(Color(hex: 0xFF9F0A))
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("43").font(.system(size: 20, weight: .semibold)).foregroundStyle(Color(hex: 0xFF9F0A))
                        Text("%").font(.system(size: 12)).foregroundStyle(Color(hex: 0xFF9F0A))
                    }
                }
                Spacer()
            }
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(0..<jours.count, id: \.self) { i in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i == jours.count - 1 ? Color(hex: 0xFF9F0A) : Color(hex: 0x3A3A3E))
                            .frame(height: hauteurs[i])
                        Text(jours[i]).font(.system(size: 10)).foregroundStyle(regTexte2)
                    }
                    .frame(maxWidth: .infinity)
                }
                Text("Moyenne").font(.system(size: 10)).foregroundStyle(regTexte2)
            }
            .frame(height: 108, alignment: .bottom)
        }
    }
}

// Détail « Utilisation de la batterie » : graphique 24 h avec pic de charge vert + liste par app
struct UtilisationBatterieVue: View {
    private let heures: [CGFloat] = [14, 10, 8, 6, 5, 4, 6, 30, 12, 10, 14, 18,
                                     10, 8, 12, 16, 10, 14, 20, 34, 44, 38, 26, 12]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("Utilisation quotidienne").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 12)
                    RegGroupe {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Vous avez utilisé plus de batterie aujourd'hui qu'en temps normal à 12:10.")
                                .font(.system(size: 14)).foregroundStyle(regTexte)
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("43 %").font(.system(size: 24, weight: .semibold)).foregroundStyle(Color(hex: 0xFF9F0A))
                                Spacer()
                                Text("17 août 2026").font(.system(size: 12)).foregroundStyle(regTexte2)
                            }
                            // 24 h : pic de charge (vert) à 7 h, activité du soir
                            HStack(alignment: .bottom, spacing: 3) {
                                ForEach(0..<heures.count, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(i == 7 ? regVert : Color(hex: 0xFF9F0A).opacity(0.8))
                                        .frame(height: max(2, heures[i] * 1.7))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 80, alignment: .bottom)
                            HStack {
                                Text("00 h").font(.system(size: 10)).foregroundStyle(regTexte2)
                                Spacer()
                                Text("06").font(.system(size: 10)).foregroundStyle(regTexte2)
                                Spacer()
                                Text("12 h").font(.system(size: 10)).foregroundStyle(regTexte2)
                                Spacer()
                                Text("18").font(.system(size: 10)).foregroundStyle(regTexte2)
                            }
                            HStack(spacing: 40) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Écran actif").font(.system(size: 12)).foregroundStyle(regTexte2)
                                    Text("4h 51min").font(.system(size: 18, weight: .semibold)).foregroundStyle(regTexte)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Écran inactif").font(.system(size: 12)).foregroundStyle(regTexte2)
                                    Text("38min").font(.system(size: 18, weight: .semibold)).foregroundStyle(regTexte)
                                }
                            }
                        }
                        .padding(14)
                    }

                    Text("Utilisation de la batterie par app").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        LigneAppBatterie(nom: "WhatsApp", detail: "À l'écran : 3h 42min · En arrière-plan : 26min", part: "24 %", alerte: true)
                        RegSeparateur()
                        LigneAppBatterie(nom: "Safari", detail: "À l'écran : 48min", part: "9 %", alerte: true)
                        RegSeparateur()
                        LigneAppBatterie(nom: "Téléphone", detail: "À l'écran : 21min", part: "8 %", alerte: true)
                        RegSeparateur()
                        LigneAppBatterie(nom: "Photos", detail: "À l'écran : 12min", part: "4 %", alerte: false)
                        RegSeparateur()
                        LigneAppBatterie(nom: "Ma Banque", detail: "À l'écran : 6min", part: "2 %", alerte: false)
                        RegSeparateur()
                        Text("En afficher plus").font(.system(size: 15)).foregroundStyle(regBleu)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                    }

                    Text("Autres utilisations de la batterie").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        LigneAppBatterie(nom: "Écran d'accueil et verrouillé", detail: "À l'écran : 14min", part: "6 %", alerte: true)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Utilisation de la batterie")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EtatSanteVue: View {
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        HStack {
                            Text("État de santé de la batterie").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Normal").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    .padding(.top, 12)
                    Text("Les performances de la batterie de cet iPhone sont normales. Batterie et garantie…")
                        .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        HStack {
                            Text("Capacité maximum").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("89 %").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    Text("Ceci est une mesure de la capacité de la batterie comparée à lorsqu'elle était neuve. Une capacité plus faible peut réduire le nombre d'heures d'utilisation possibles entre les recharges.")
                        .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        HStack {
                            Text("Comptage de cycles").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("412").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    RegGroupe {
                        HStack {
                            Text("Date de fabrication").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Octobre 2023").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("Première utilisation").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Novembre 2023").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("État de santé de la batterie")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LigneAppBatterie: View {
    let nom: String
    let detail: String
    let part: String
    let alerte: Bool
    var body: some View {
        HStack(spacing: 12) {
            RegIcone(symbole: "app.fill", fond: Color(hex: 0x3A3A3E))
            VStack(alignment: .leading, spacing: 1) {
                Text(nom).font(.system(size: 15.5)).foregroundStyle(regTexte)
                Text(detail).font(.system(size: 12)).foregroundStyle(regTexte2)
            }
            Spacer()
            if alerte {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 13)).foregroundStyle(Color(hex: 0xFF9F0A))
            }
            Text(part).font(.system(size: 15)).foregroundStyle(regTexte)
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                .foregroundStyle(regTexte2.opacity(0.6))
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
    }
}

struct LigneActivite: View {
    let nom: String
    let part: String
    var body: some View {
        HStack {
            Text(nom).font(.system(size: 16)).foregroundStyle(regTexte)
            Spacer()
            Text(part).font(.system(size: 16)).foregroundStyle(regTexte2)
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
    }
}

// ============================================================ GÉNÉRAL
struct GeneralVue: View {
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        RegLigne(symbole: "info.circle", fond: Color(hex: 0x8E8E93), nom: "Informations") { InformationsVue() }
                        RegSeparateur()
                        RegLigne(symbole: "gear.badge", fond: Color(hex: 0x8E8E93), nom: "Mise à jour logicielle") { MiseAJourVue() }
                        RegSeparateur()
                        RegLigne(symbole: "internaldrive", fond: Color(hex: 0x8E8E93), nom: "Stockage de l'iPhone") { StockageVue() }
                    }
                    .padding(.top, 12)
                    RegGroupe {
                        RegLigne(symbole: "applelogo", fond: regRouge, nom: "AppleCare et garantie") { RegGeneriqueVue(nom: "AppleCare et garantie") }
                    }
                    RegGroupe {
                        RegLigne(symbole: "dot.radiowaves.right", fond: regBleu, nom: "AirDrop") { RegContenuVue(nom: "AirDrop") }
                        RegSeparateur()
                        RegLigne(symbole: "play.tv", fond: regBleu, nom: "AirPlay et Continuité") { RegContenuVue(nom: "AirPlay et Continuité") }
                        RegSeparateur()
                        RegLigne(symbole: "rectangle.inset.filled", fond: Color(hex: 0x8E8E93), nom: "Image dans l'image") { RegContenuVue(nom: "Image dans l'image") }
                        RegSeparateur()
                        RegLigne(symbole: "camera.viewfinder", fond: Color(hex: 0x8E8E93), nom: "Capture d'écran") { RegContenuVue(nom: "Capture d'écran") }
                        RegSeparateur()
                        RegLigne(symbole: "car.fill", fond: regVert, nom: "CarPlay") { RegContenuVue(nom: "CarPlay") }
                    }
                    RegGroupe {
                        RegLigne(symbole: "arrow.clockwise", fond: Color(hex: 0x8E8E93), nom: "Actualiser en arrière-plan") { RegContenuVue(nom: "Actualiser en arrière-plan") }
                        RegSeparateur()
                        RegLigne(symbole: "keyboard", fond: Color(hex: 0x8E8E93), nom: "Clavier") { RegContenuVue(nom: "Clavier") }
                        RegSeparateur()
                        RegLigne(symbole: "globe", fond: Color(hex: 0x8E8E93), nom: "Langue et région") { RegContenuVue(nom: "Langue et région") }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Général")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InformationsVue: View {
    private let lignes: [(String, String)] = [
        ("Nom", "iPhone de Sarah"),
        ("Version d'iOS", "26.6.1"),
        ("Nom du modèle", "iPhone 15"),
        ("N° du modèle", "MTP63ZD/A"),
        ("N° de série", "H7QX2L4KP9"),
        ("Capacité", "256 Go"),
        ("Photos", "9 412"),
        ("Applications", "34"),
        ("Morceaux", "217"),
    ]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        ForEach(Array(lignes.enumerated()), id: \.offset) { i, l in
                            HStack {
                                Text(l.0).font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Text(l.1).font(.system(size: 16)).foregroundStyle(regTexte2)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 9)
                            if i < lignes.count - 1 { RegSeparateur(retrait: 14) }
                        }
                    }
                    .padding(.top, 12)
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Informations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StockageVue: View {
    // Or narratif : WhatsApp énorme, Meetic présent, Ma Banque minuscule
    private let apps: [(String, String, String)] = [
        ("Photos", "48,2 Go", "Dernière utilisation : aujourd'hui"),
        ("WhatsApp", "14,8 Go", "Dernière utilisation : aujourd'hui"),
        ("Musique", "6,1 Go", "Dernière utilisation : hier"),
        ("Safari", "2,4 Go", "Dernière utilisation : aujourd'hui"),
        ("Meetic", "1,9 Go", "Dernière utilisation : 12 mars"),
        ("Notes", "840 Mo", "Dernière utilisation : mercredi"),
        ("Ma Banque", "210 Ko", "Dernière utilisation : mercredi"),
    ]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("iPhone").font(.system(size: 16, weight: .semibold)).foregroundStyle(regTexte)
                                Spacer()
                                Text("187,4 Go sur 256 Go utilisés").font(.system(size: 13)).foregroundStyle(regTexte2)
                            }
                            GeometryReader { geo in
                                HStack(spacing: 2) {
                                    RoundedRectangle(cornerRadius: 2).fill(regRouge).frame(width: geo.size.width * 0.22)
                                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: 0xFFD60A)).frame(width: geo.size.width * 0.34)
                                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: 0xE64980)).frame(width: geo.size.width * 0.06)
                                    RoundedRectangle(cornerRadius: 2).fill(regBleu).frame(width: geo.size.width * 0.05)
                                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: 0x8E8E93)).frame(width: geo.size.width * 0.06)
                                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: 0x3A3A3E))
                                }
                            }
                            .frame(height: 7)
                            HStack(spacing: 10) {
                                Etiquette(couleur: regRouge, nom: "Applications")
                                Etiquette(couleur: Color(hex: 0xFFD60A), nom: "Photos")
                                Etiquette(couleur: Color(hex: 0xE64980), nom: "Musique")
                                Etiquette(couleur: regBleu, nom: "iCloud Drive")
                                Etiquette(couleur: Color(hex: 0x8E8E93), nom: "iOS")
                            }
                        }
                        .padding(14)
                    }
                    .padding(.top, 12)

                    Text("Recommandations").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Décharger les apps inutilisées").font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Text("Activer").font(.system(size: 16)).foregroundStyle(regBleu)
                            }
                            Text("Économisez jusqu'à 11,2 Go. Déchargez automatiquement les apps inutilisées lorsque vous manquez d'espace.")
                                .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }

                    RegGroupe {
                        ForEach(Array(apps.enumerated()), id: \.offset) { i, a in
                            HStack(spacing: 12) {
                                RegIcone(symbole: "app.fill", fond: Color(hex: 0x3A3A3E))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(a.0).font(.system(size: 16)).foregroundStyle(regTexte)
                                    Text(a.2).font(.system(size: 12)).foregroundStyle(regTexte2)
                                }
                                Spacer()
                                Text(a.1).font(.system(size: 15)).foregroundStyle(regTexte2)
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                            }
                            .padding(.horizontal, 14).padding(.vertical, 9)
                            if i < apps.count - 1 { RegSeparateur() }
                        }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Stockage iPhone")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ============================================================ TEMPS D'ÉCRAN
struct TempsEcranVue: View {
    @State private var periode = 1 // 0 Semaine, 1 Jour
    private let barres: [CGFloat] = [10, 4, 2, 1, 0, 1, 3, 8, 14, 22, 18, 26,
                                     20, 16, 24, 28, 22, 30, 34, 46, 58, 52, 38, 20]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Picker("", selection: $periode) {
                        Text("Semaine").tag(0)
                        Text("Jour").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16).padding(.top, 12)

                    RegGroupe {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(periode == 1 ? "Aujourd'hui" : "Moyenne quotidienne")
                                .font(.system(size: 13)).foregroundStyle(regTexte2)
                            Text(periode == 1 ? "6 h 42 min" : "5 h 58 min")
                                .font(.system(size: 26, weight: .bold)).foregroundStyle(regTexte)
                            HStack(alignment: .bottom, spacing: 3) {
                                ForEach(0..<barres.count, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(i >= 19 && i <= 22 ? Color(hex: 0x5E5CE6) : regBleu.opacity(0.75))
                                        .frame(height: max(2, barres[i] * 1.4))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 86, alignment: .bottom)
                            HStack {
                                Text("00 h").font(.system(size: 10)).foregroundStyle(regTexte2)
                                Spacer()
                                Text("06 h").font(.system(size: 10)).foregroundStyle(regTexte2)
                                Spacer()
                                Text("12 h").font(.system(size: 10)).foregroundStyle(regTexte2)
                                Spacer()
                                Text("18 h").font(.system(size: 10)).foregroundStyle(regTexte2)
                            }
                        }
                        .padding(14)
                    }

                    Text("Les plus utilisées").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        LigneActivite(nom: "WhatsApp", part: "4 h 05")
                        RegSeparateur(retrait: 14)
                        LigneActivite(nom: "Safari", part: "1 h 12")
                        RegSeparateur(retrait: 14)
                        LigneActivite(nom: "Téléphone", part: "24 min")
                        RegSeparateur(retrait: 14)
                        LigneActivite(nom: "Ma Banque", part: "18 min")
                        RegSeparateur(retrait: 14)
                        LigneActivite(nom: "Photos", part: "14 min")
                    }

                    RegGroupe {
                        HStack {
                            Text("Limites").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Toutes les apps et catégories · 3 h").font(.system(size: 14)).foregroundStyle(regTexte2)
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                    }
                    Text("Limite dépassée tous les jours cette semaine.")
                        .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Temps d'écran")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ============================================================ AFFICHAGE / FOND D'ÉCRAN / CENTRE DE CONTRÔLE / ACCUEIL
struct LuminositeVue: View {
    @State private var automatique = false
    @State private var luminosite = 0.62
    @State private var trueTone = false
    @State private var texteGras = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("Apparence").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 12)
                    RegGroupe {
                        HStack(spacing: 30) {
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 10).fill(.white).frame(width: 58, height: 118)
                                    .overlay(Text("9:41").font(.system(size: 11, weight: .semibold)).foregroundStyle(.black).padding(.top, 8), alignment: .top)
                                Text("Claire").font(.system(size: 14)).foregroundStyle(regTexte)
                                Image(systemName: "circle").font(.system(size: 16)).foregroundStyle(regTexte2)
                            }
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 10).fill(Color(hex: 0x2A2A2E)).frame(width: 58, height: 118)
                                    .overlay(Text("9:41").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white).padding(.top, 8), alignment: .top)
                                Text("Sombre").font(.system(size: 14)).foregroundStyle(regTexte)
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 16)).foregroundStyle(regBleu)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Automatique", valeur: $automatique)
                    }
                    RegGroupe {
                        HStack {
                            Text("Taille du texte").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Texte en gras", valeur: $texteGras)
                    }
                    Text("Luminosité").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        VStack(spacing: 4) {
                            HStack(spacing: 10) {
                                Image(systemName: "sun.min").font(.system(size: 14)).foregroundStyle(regTexte2)
                                Slider(value: $luminosite).tint(.white)
                                Image(systemName: "sun.max.fill").font(.system(size: 16)).foregroundStyle(regTexte2)
                            }
                            .padding(.horizontal, 14).padding(.top, 12)
                            LigneBascule(nom: "True Tone", valeur: $trueTone)
                        }
                        .padding(.bottom, 6)
                    }
                    RegGroupe {
                        HStack {
                            Text("Night Shift").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Non").font(.system(size: 16)).foregroundStyle(regTexte2)
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("Verrouillage automatique").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Jamais").font(.system(size: 16)).foregroundStyle(regTexte2)
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Luminosité et affichage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FondEcranVue: View {
    @State private var erreur = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("ACTUEL").font(.system(size: 12, weight: .semibold)).foregroundStyle(regTexte2)
                        .padding(.top, 16)
                    HStack(spacing: 14) {
                        VStack(spacing: 8) {
                            Image("FondEcran").resizable().scaledToFill()
                                .frame(width: 118, height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            Text("Personnaliser").font(.system(size: 13)).foregroundStyle(regTexte)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(regCarte, in: Capsule())
                                .onTapGesture { erreur = true }
                        }
                        VStack(spacing: 8) {
                            Image("FondEcran").resizable().scaledToFill()
                                .frame(width: 118, height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay(RoundedRectangle(cornerRadius: 18).fill(Color.black.opacity(0.35)))
                            Text("Personnaliser").font(.system(size: 13)).foregroundStyle(regTexte)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(regCarte, in: Capsule())
                                .onTapGesture { erreur = true }
                        }
                    }
                    Text("+ Ajouter un fond d'écran")
                        .font(.system(size: 15, weight: .medium)).foregroundStyle(.white)
                        .padding(.horizontal, 18).padding(.vertical, 10)
                        .background(regBleu, in: Capsule())
                        .onTapGesture { erreur = true }
                    RegGroupe {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Changez de fond d'écran depuis l'écran verrouillé")
                                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(regTexte)
                                Text("Depuis votre écran verrouillé, touchez et maintenez appuyé pour ajouter, modifier ou basculer entre différents fonds d'écran et widgets.")
                                    .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                            }
                            Spacer()
                        }
                        .padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Fond d'écran")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Fond d'écran", isPresented: $erreur) {
            Button("OK", role: .cancel) {}
        } message: { Text(ErreurLambda.reponse("code.requis")) }
    }
}

struct CentreControleVue: View {
    @State private var acces = true
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Personnaliser le centre de contrôle")
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(regTexte)
                            Text("Balayez l'écran à partir du coin supérieur droit pour ouvrir le centre de contrôle. Ajoutez, réorganisez ou redimensionnez n'importe quelle commande.")
                                .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    .padding(.top, 12)
                    RegGroupe {
                        LigneBascule(nom: "Accès à partir des apps", valeur: $acces)
                    }
                    Text("Autorisez l'accès au centre de contrôle depuis les applications.")
                        .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        Text("Réinitialiser le centre de contrôle")
                            .font(.system(size: 16)).foregroundStyle(regBleu)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Centre de contrôle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EcranAccueilVue: View {
    @State private var choix = 0
    @State private var pastilles = false
    @State private var afficher = true
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("Nouvelles apps téléchargées").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 12)
                    RegGroupe {
                        HStack {
                            Text("Sur l'écran d'accueil").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            if choix == 0 { Image(systemName: "checkmark").foregroundStyle(regBleu) }
                        }
                        .padding(14).contentShape(Rectangle())
                        .onTapGesture { choix = 0 }
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("Bibliothèque d'apps uniquement").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            if choix == 1 { Image(systemName: "checkmark").foregroundStyle(regBleu) }
                        }
                        .padding(14).contentShape(Rectangle())
                        .onTapGesture { choix = 1 }
                    }
                    Text("Pastilles de notification").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        LigneBascule(nom: "Afficher dans la bibliothèque d'apps", valeur: $pastilles)
                    }
                    Text("Recherche").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        LigneBascule(nom: "Afficher sur l'écran d'accueil", valeur: $afficher)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Écran d'accueil et bibliothèque d'apps")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ============================================================ NOTIFICATIONS / SONS
struct NotificationsVue: View {
    private let apps: [(String, String)] = [
        ("WhatsApp", "Bannières, Sons, Pastilles"),
        ("Messages", "Bannières, Sons, Pastilles"),
        ("Téléphone", "Bannières, Sons"),
        ("Ma Banque", "Désactivées"),
        ("Meetic", "Désactivées"),
        ("Mail", "Bannières"),
        ("Calendrier", "Bannières, Sons"),
        ("Photos", "Bannières"),
    ]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("Style des notifications").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 12)
                    RegGroupe {
                        ForEach(Array(apps.enumerated()), id: \.offset) { i, a in
                            NavigationLink { NotifAppVue(nom: a.0) } label: {
                                HStack(spacing: 12) {
                                    RegIcone(symbole: "app.fill", fond: Color(hex: 0x3A3A3E))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(a.0).font(.system(size: 16)).foregroundStyle(regTexte)
                                        Text(a.1).font(.system(size: 12.5)).foregroundStyle(regTexte2)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                                }
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }.buttonStyle(.plain)
                            if i < apps.count - 1 { RegSeparateur() }
                        }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotifAppVue: View {
    let nom: String
    @State private var autoriser = true
    @State private var sons = true
    @State private var pastilles = true
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        LigneBascule(nom: "Autoriser les notifications", valeur: $autoriser)
                    }
                    .padding(.top, 12)
                    if autoriser {
                        RegGroupe {
                            LigneBascule(nom: "Sons", valeur: $sons)
                            RegSeparateur(retrait: 14)
                            LigneBascule(nom: "Pastilles", valeur: $pastilles)
                        }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle(nom)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SonsVue: View {
    @State private var verrouillage = true
    @State private var vibrations = true
    @State private var diminuer = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        HStack {
                            Text("Retour clavier").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Aucun").font(.system(size: 16)).foregroundStyle(regTexte2)
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Son de verrouillage", valeur: $verrouillage)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Vibrations du système", valeur: $vibrations)
                    }
                    .padding(.top, 12)
                    Text("Émet une vibration pour les commandes système et les interactions.")
                        .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    Text("Haut-parleur intégré").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        HStack {
                            Text("Limite du volume").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                    }
                    RegGroupe {
                        LigneBascule(nom: "Diminuer les sons forts", valeur: $diminuer)
                    }
                    Text("Écouteurs").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        HStack {
                            Text("Sécurité des écouteurs").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                        RegSeparateur(retrait: 14)
                        HStack {
                            Text("Audio spatial personnalisé").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Sons et vibrations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ============================================================ FACE ID — VERROUILLÉ PAR CODE (porte diégétique)
struct FaceIDVue: View {
    @State private var code = ""
    @State private var tremble = false
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            VStack(spacing: 26) {
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.system(size: 40)).foregroundStyle(regTexte2)
                Text("Saisissez le code de l'iPhone")
                    .font(.system(size: 16)).foregroundStyle(regTexte)
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .strokeBorder(regTexte2, lineWidth: 1)
                            .background(Circle().fill(i < code.count ? regTexte : .clear))
                            .frame(width: 13, height: 13)
                    }
                }
                .offset(x: tremble ? -8 : 0)
                Spacer()
                // Pavé numérique
                VStack(spacing: 14) {
                    ForEach(0..<3, id: \.self) { ligne in
                        HStack(spacing: 24) {
                            ForEach(1..<4, id: \.self) { col in
                                let n = ligne * 3 + col
                                ToucheCode(chiffre: "\(n)") { appuyer("\(n)") }
                            }
                        }
                    }
                    HStack(spacing: 24) {
                        Color.clear.frame(width: 76, height: 76)
                        ToucheCode(chiffre: "0") { appuyer("0") }
                        Text("Effacer").font(.system(size: 15)).foregroundStyle(regTexte)
                            .frame(width: 76, height: 76)
                            .contentShape(Rectangle())
                            .onTapGesture { if !code.isEmpty { code.removeLast() } }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Face ID et code")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func appuyer(_ c: String) {
        Haptique.leger()
        code += c
        if code.count == 6 {
            // Le joueur ne connaît pas ce code : la porte reste fermée (D53)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(duration: 0.08).repeatCount(5, autoreverses: true)) { tremble = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    tremble = false; code = ""
                }
            }
        }
    }
}

struct ToucheCode: View {
    let chiffre: String
    let action: () -> Void
    var body: some View {
        Circle().fill(Color(hex: 0x1C1C1E))
            .frame(width: 76, height: 76)
            .overlay(Text(chiffre).font(.system(size: 30, weight: .light)).foregroundStyle(regTexte))
            .contentShape(Circle())
            .onTapGesture(perform: action)
    }
}

// ============================================================ CONFIDENTIALITÉ
struct ConfidentialiteVue: View {
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        RegLigne(symbole: "location.fill", fond: regBleu, nom: "Service de localisation", valeur: "Oui") { RegContenuVue(nom: "Service de localisation") }
                        RegSeparateur()
                        RegLigne(symbole: "hand.raised.fill", fond: regBleu, nom: "Suivi") { RegContenuVue(nom: "Suivi") }
                    }
                    .padding(.top, 12)
                    RegGroupe {
                        RegLigne(symbole: "person.2.fill", fond: Color(hex: 0x32ADE6), nom: "Contacts") { RegContenuVue(nom: "Contacts", cle: "acces.contacts") }
                        RegSeparateur()
                        RegLigne(symbole: "photo.fill", fond: Color(hex: 0xE64980), nom: "Photos") { RegContenuVue(nom: "Photos", cle: "acces.photos") }
                        RegSeparateur()
                        RegLigne(symbole: "mic.fill", fond: Color(hex: 0xFF9F0A), nom: "Micro") { RegContenuVue(nom: "Micro", cle: "acces.micro") }
                        RegSeparateur()
                        RegLigne(symbole: "camera.fill", fond: regVert, nom: "Appareil photo") { RegContenuVue(nom: "Appareil photo", cle: "acces.camera") }
                    }
                    RegGroupe {
                        RegLigne(symbole: "checkerboard.shield", fond: Color(hex: 0x8E8E93), nom: "Contrôle de sécurité") { RegContenuVue(nom: "Contrôle de sécurité") }
                        RegSeparateur()
                        RegLigne(symbole: "exclamationmark.shield.fill", fond: regRouge, nom: "Analyse et améliorations") { RegContenuVue(nom: "Analyse et améliorations") }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Confidentialité et sécurité")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ============================================================ CARTES ET APPLE PAY (or narratif)
struct CartesPayVue: View {
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        HStack(spacing: 12) {
                            RegIcone(symbole: "creditcard.fill", fond: Color(hex: 0x32ADE6))
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Réglages par défaut d'Apple Pay").font(.system(size: 16)).foregroundStyle(regTexte)
                                Text("Carte, adresse, préférences").font(.system(size: 12.5)).foregroundStyle(regTexte2)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                    }
                    .padding(.top, 12)

                    Text("Cartes de paiement").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        NavigationLink { CarteDetailVue() } label: {
                            LigneCarte(couleur: Color(hex: 0x00539B), nom: "Carte LCL Visa", detail: "•••• 8207", alerte: nil)
                        }.buttonStyle(.plain)
                        RegSeparateur()
                        LigneCarte(couleur: Color(hex: 0xE8590C), nom: "VISA PREPAGO", detail: "•••• 5246", alerte: "Suspendue")
                        RegSeparateur()
                        LigneCarte(couleur: Color(hex: 0x2F9E44), nom: "Carte Virtuelle Nirio", detail: "•••• 8476", alerte: "Suspendue")
                    }
                    Text("Deux cartes prépayées ont été suspendues par leur émetteur.")
                        .font(.system(size: 12.5)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)

                    RegGroupe {
                        HStack {
                            Text("Cartes à remplissage automatique").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("3").font(.system(size: 16)).foregroundStyle(regTexte2)
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                        }
                        .padding(14)
                    }
                    Text("Cartes de transport").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        HStack {
                            Text("Carte de transport express").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Aucune").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Cartes et Apple Pay")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LigneCarte: View {
    let couleur: Color
    let nom: String
    let detail: String
    let alerte: String?
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4).fill(couleur).frame(width: 34, height: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(nom).font(.system(size: 16)).foregroundStyle(regTexte)
                Text(detail).font(.system(size: 12.5)).foregroundStyle(regTexte2)
            }
            Spacer()
            if let alerte {
                Text(alerte).font(.system(size: 13)).foregroundStyle(Color(hex: 0xFF9F0A))
            }
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .contentShape(Rectangle())
    }
}

struct CarteDetailVue: View {
    @State private var onglet = 0
    // Or narratif : les transactions racontent l'arnaque (Western Union, recharges prépayées)
    private let transactions: [(String, String, String)] = [
        ("Boulangerie Marguerite", "Lyon 1er · aujourd'hui", "3,80 €"),
        ("Western Union", "Lyon Part-Dieu · mardi", "850,00 €"),
        ("Recharge PCS Mastercard", "Tabac le Marigny · mardi", "250,00 €"),
        ("Monoprix", "Lyon 1er · lundi", "42,17 €"),
        ("Western Union", "Lyon Part-Dieu · 28 juil.", "600,00 €"),
        ("Pharmacie des Terreaux", "Lyon 1er · 26 juil.", "18,60 €"),
        ("Retrait DAB", "LCL Bellecour · 24 juil.", "300,00 €"),
    ]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: [Color(hex: 0x00539B), Color(hex: 0x003A6E)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 210, height: 132)
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sarah Levasseur").font(.system(size: 12)).foregroundStyle(.white.opacity(0.9))
                                Text("•••• 8207").font(.system(size: 13, weight: .medium)).foregroundStyle(.white)
                            }
                            .padding(12)
                        }
                        .overlay(alignment: .topLeading) {
                            Text("LCL").font(.system(size: 15, weight: .bold)).foregroundStyle(.white).padding(12)
                        }
                        .padding(.top, 14)

                    Picker("", selection: $onglet) {
                        Text("Infos").tag(0)
                        Text("Transactions").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 40)

                    if onglet == 0 {
                        RegGroupe {
                            HStack {
                                Text("Informations de la carte").font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                            }
                            .padding(14)
                            RegSeparateur(retrait: 14)
                            HStack {
                                Text("Transport express").font(.system(size: 16)).foregroundStyle(regTexte)
                                Spacer()
                                Text("Non").font(.system(size: 16)).foregroundStyle(regTexte2)
                            }
                            .padding(14)
                        }
                    } else {
                        RegGroupe {
                            ForEach(Array(transactions.enumerated()), id: \.offset) { i, t in
                                HStack(spacing: 12) {
                                    RegIcone(symbole: "eurosign", fond: Color(hex: 0x3A3A3E))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(t.0).font(.system(size: 15.5)).foregroundStyle(regTexte)
                                        Text(t.1).font(.system(size: 12.5)).foregroundStyle(regTexte2)
                                    }
                                    Spacer()
                                    Text(t.2).font(.system(size: 15.5, weight: t.2.count > 7 ? .semibold : .regular))
                                        .foregroundStyle(regTexte)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                if i < transactions.count - 1 { RegSeparateur() }
                            }
                        }
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Carte LCL Visa")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ============================================================ APPS (liste)
struct AppsListeVue: View {
    private let apps = ["Calculatrice", "Calendrier", "Dictaphone", "Fichiers", "Horloge",
                        "Localiser", "Ma Banque", "Mail", "Meetic", "Météo", "Musique",
                        "Notes", "Photos", "Plans", "Rappels", "Santé", "WhatsApp"]
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    RegGroupe {
                        ForEach(Array(apps.enumerated()), id: \.offset) { i, a in
                            NavigationLink { RegAppVue(nom: a) } label: {
                                HStack(spacing: 12) {
                                    RegIcone(symbole: "app.fill", fond: Color(hex: 0x3A3A3E))
                                    Text(a).font(.system(size: 16)).foregroundStyle(regTexte)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(regTexte2.opacity(0.6))
                                }
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }.buttonStyle(.plain)
                            if i < apps.count - 1 { RegSeparateur() }
                        }
                    }
                    .padding(.top, 12)
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle("Apps")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// ============================================================ CONTENU RÉEL DES ÉCRANS LOCAUX (D56 anneau 2)
// Un réglage local ne peut pas échouer : chaque écran a son vrai contenu statique.
// L'échec réseau (RegGeneriqueVue) est réservé aux écrans réellement en ligne.
enum LigneRC {
    case titre(String)
    case bascule(String, Bool)
    case valeur(String, String)
    case note(String)
}

enum ContenuEcrans {
    static let ecrans: [String: [LigneRC]] = [
        "Partage de connexion": [
            .bascule("Autoriser d'autres utilisateurs", false),
            .valeur("Mot de passe Wi-Fi", "flamant-rose-72"),
            .note("Le partage de connexion de « iPhone de Sarah » est visible par vos autres appareils lorsque vous êtes connectée à iCloud."),
        ],
        "VPN": [
            .valeur("État", "Déconnecté"),
            .note("Aucune configuration VPN enregistrée."),
        ],
        "Accessibilité": [
            .titre("Vision"),
            .valeur("VoiceOver", "Désactivé"),
            .valeur("Zoom", "Désactivé"),
            .valeur("Taille du texte", "Par défaut"),
            .titre("Physique et moteur"),
            .valeur("AssistiveTouch", "Désactivé"),
            .titre("Audition"),
            .bascule("Audio mono", false),
        ],
        "Appareil photo": [
            .bascule("Grille", true),
            .bascule("Miroiter la photo de face", true),
            .valeur("Formats", "Haute efficacité"),
            .valeur("Enregistrement vidéo", "4K à 30 i/s"),
            .bascule("Correction de l'objectif", true),
        ],
        "Apple Intelligence et Siri": [
            .valeur("Apple Intelligence", "Non disponible"),
            .note("Apple Intelligence n'est pas disponible sur cet iPhone."),
            .titre("Siri"),
            .bascule("Détecter « Dis Siri »", true),
            .valeur("Langue", "Français (France)"),
            .valeur("Voix de Siri", "Française (voix 3)"),
        ],
        "Bouton Action": [
            .valeur("Action", "Mode silencieux"),
            .note("Maintenez le bouton Action enfoncé pour activer ou désactiver le mode silencieux."),
        ],
        "En veille": [
            .bascule("En veille", true),
            .note("L'iPhone affiche l'horloge et les widgets lorsqu'il charge, posé sur le côté."),
            .bascule("Mode nuit", true),
        ],
        "Concentration": [
            .valeur("Ne pas déranger", "Désactivé"),
            .valeur("Sommeil", "22:30 – 07:00"),
            .valeur("Travail", "Désactivé"),
            .note("Les concentrations se synchronisent sur tous vos appareils."),
        ],
        "Appel d'urgence": [
            .bascule("Appel en maintenant enfoncé", true),
            .bascule("Appel par 5 pressions", false),
            .valeur("Contacts d'urgence", "Maman"),
            .note("L'iPhone peut appeler les services d'urgence et prévenir vos contacts d'urgence."),
        ],
        "Game Center": [
            .valeur("Profil", "sarah_lvsr"),
            .bascule("Invitations d'amis", true),
            .bascule("Joueurs à proximité", false),
        ],
        "Famille": [
            .valeur("Partage familial", "Désactivé"),
            .note("Partagez vos abonnements, votre musique, vos films et tout achat de contenu multimédia avec jusqu'à cinq personnes."),
        ],
        "Localiser": [
            .bascule("Localiser mon iPhone", true),
            .bascule("Réseau Localiser", true),
            .bascule("Envoyer la dernière position", true),
            .valeur("Partager ma position", "Chloé"),
            .note("Votre position est partagée depuis cet iPhone."),
        ],
        "iPad de Sarah": [
            .valeur("Modèle", "iPad Air"),
            .valeur("Version", "iPadOS 26.4"),
            .valeur("Sauvegarde", "14 août"),
            .note("Cet appareil apparaîtra en ligne lorsqu'il sera connecté à Internet."),
        ],
        "AirDrop": [
            .valeur("Réception", "Contacts uniquement"),
            .bascule("Utiliser les données cellulaires", true),
        ],
        "AirPlay et Continuité": [
            .bascule("Transfert automatique vers AirPlay", true),
            .bascule("Handoff", true),
        ],
        "Image dans l'image": [
            .bascule("Démarrer automatiquement", true),
            .note("La vidéo continue dans une fenêtre flottante lorsque vous quittez l'app."),
        ],
        "Capture d'écran": [
            .valeur("Enregistrer dans", "Photos"),
        ],
        "CarPlay": [
            .note("Aucune voiture jumelée."),
        ],
        "Actualiser en arrière-plan": [
            .bascule("Actualiser en arrière-plan", true),
            .bascule("WhatsApp", true),
            .bascule("Messages", true),
            .bascule("Safari", false),
            .bascule("Ma Banque", true),
        ],
        "Clavier": [
            .bascule("Majuscules automatiques", true),
            .bascule("Correction automatique", true),
            .valeur("Claviers", "2"),
            .valeur("Dictée", "Activée"),
        ],
        "Langue et région": [
            .valeur("Langue de l'iPhone", "Français (France)"),
            .valeur("Région", "France"),
            .valeur("Calendrier", "Grégorien"),
            .valeur("Température", "°C"),
        ],
        "Service de localisation": [
            .bascule("Service de localisation", true),
            .titre("Apps"),
            .valeur("WhatsApp", "Pendant l'utilisation"),
            .valeur("Plans", "Pendant l'utilisation"),
            .valeur("Messages", "Jamais"),
            .valeur("Météo", "Toujours"),
        ],
        "Suivi": [
            .bascule("Autoriser les demandes de suivi", false),
            .note("Les nouvelles demandes de suivi des apps sont automatiquement refusées."),
        ],
        "acces.contacts": [
            .note("Les apps ci-dessous ont demandé l'accès à vos contacts."),
            .bascule("WhatsApp", true),
            .bascule("Meetic", true),
        ],
        "acces.photos": [
            .valeur("WhatsApp", "Accès complet"),
            .valeur("Meetic", "Photos sélectionnées"),
            .valeur("Ma Banque", "Aucun accès"),
        ],
        "acces.micro": [
            .bascule("WhatsApp", true),
            .bascule("Dictaphone", true),
        ],
        "acces.camera": [
            .bascule("WhatsApp", true),
            .bascule("Meetic", true),
        ],
        "Contrôle de sécurité": [
            .note("Vérifiez qui a accès à vos informations, et gérez le partage avec des personnes et des apps."),
            .valeur("Partage avec des personnes", "1 personne"),
        ],
        "Analyse et améliorations": [
            .bascule("Partager l'analyse de l'iPhone", false),
            .bascule("Améliorer Siri et la dictée", false),
        ],
    ]
}

struct RegContenuVue: View {
    let nom: String
    var cle: String? = nil
    @State private var bascules: [Int: Bool] = [:]

    private var lignes: [LigneRC] { ContenuEcrans.ecrans[cle ?? nom] ?? [] }

    // Regroupe les lignes en sections (titre → en-tête, note → pied de section)
    private var sections: [(entete: String?, rangs: [(Int, LigneRC)], pied: String?)] {
        var resultat: [(String?, [(Int, LigneRC)], String?)] = []
        var entete: String? = nil
        var rangs: [(Int, LigneRC)] = []
        for (i, l) in lignes.enumerated() {
            switch l {
            case .titre(let t):
                if !rangs.isEmpty { resultat.append((entete, rangs, nil)); rangs = [] }
                entete = t
            case .note(let n):
                resultat.append((entete, rangs, n)); rangs = []; entete = nil
            default:
                rangs.append((i, l))
            }
        }
        if !rangs.isEmpty { resultat.append((entete, rangs, nil)) }
        return resultat
    }

    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                        if let entete = section.entete {
                            Text(entete).font(.system(size: 13)).foregroundStyle(regTexte2)
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                        }
                        if !section.rangs.isEmpty {
                            RegGroupe {
                                ForEach(Array(section.rangs.enumerated()), id: \.offset) { j, rang in
                                    vue(rang.0, rang.1)
                                    if j < section.rangs.count - 1 { RegSeparateur(retrait: 14) }
                                }
                            }
                        }
                        if let pied = section.pied {
                            Text(pied).font(.system(size: 12.5)).foregroundStyle(regTexte2)
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                        }
                    }
                    Color.clear.frame(height: 30)
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle(nom)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private func vue(_ indice: Int, _ ligne: LigneRC) -> some View {
        switch ligne {
        case .bascule(let nom, let defaut):
            HStack {
                Text(nom).font(.system(size: 16)).foregroundStyle(regTexte)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { bascules[indice] ?? defaut },
                    set: { bascules[indice] = $0 }
                )).labelsHidden().tint(regVert)
            }
            .padding(.horizontal, 14).padding(.vertical, 6)
        case .valeur(let nom, let valeur):
            HStack {
                Text(nom).font(.system(size: 16)).foregroundStyle(regTexte)
                Spacer()
                Text(valeur).font(.system(size: 16)).foregroundStyle(regTexte2)
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
        default:
            EmptyView()
        }
    }
}

// Écran de réglages d'une app (structure réelle observée sur la vidéo — écran Fiverr)
struct RegAppVue: View {
    let nom: String
    @State private var siri = true
    @State private var arrierePlan = true
    @State private var cellulaires = true
    @State private var notifications = true
    var body: some View {
        ZStack {
            regFond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("Autoriser « \(nom) » à accéder à :").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 12)
                    RegGroupe {
                        LigneBascule(nom: "Siri et recherche", valeur: $siri)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Notifications", valeur: $notifications)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Actualisation en arrière-plan", valeur: $arrierePlan)
                        RegSeparateur(retrait: 14)
                        LigneBascule(nom: "Données cellulaires", valeur: $cellulaires)
                    }
                    Text("Langue préférée").font(.system(size: 13)).foregroundStyle(regTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)
                    RegGroupe {
                        HStack {
                            Text("Langue").font(.system(size: 16)).foregroundStyle(regTexte)
                            Spacer()
                            Text("Français").font(.system(size: 16)).foregroundStyle(regTexte2)
                        }
                        .padding(14)
                    }
                    Color.clear.frame(height: 30)
                }
            }
        }
        .navigationTitle(nom)
        .navigationBarTitleDisplayMode(.inline)
    }
}
