// WhatsApp iOS 26 — AUDIO RÉEL et APPELS ÉCOUTABLES (itération 7, D52)
// Vocaux : vraie lecture + transcription dépliable (comme le vrai WhatsApp).
// Appels audio : écran d'appel avec voix + transcription. Appels vidéo interactifs : écartés (D52).
import SwiftUI
import AVFoundation

// ============================================================ LECTEUR PARTAGÉ
final class LecteurAudio: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let partage = LecteurAudio()
    @Published var fichierActif: String? = nil
    @Published var progression: Double = 0
    private var lecteur: AVAudioPlayer?
    private var minuteur: Timer?

    func bascule(_ fichier: String) {
        if fichierActif == fichier { arret(); return }
        arret()
        let url = Bundle.main.url(forResource: fichier, withExtension: "mp3")
            ?? Bundle.main.url(forResource: fichier, withExtension: "mp3", subdirectory: "Ressources")
        guard let url else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        lecteur = try? AVAudioPlayer(contentsOf: url)
        lecteur?.delegate = self
        lecteur?.play()
        fichierActif = fichier
        minuteur = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let l = self.lecteur, l.duration > 0 else { return }
            self.progression = l.currentTime / l.duration
        }
    }

    func arret() {
        lecteur?.stop(); lecteur = nil
        minuteur?.invalidate(); minuteur = nil
        fichierActif = nil; progression = 0
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { arret() }
}

// ============================================================ VOCAL AVEC AUDIO + TRANSCRIPTION
struct BulleVocaleAudio: View {
    let recu: Bool
    let duree: String
    let heure: String
    let fichier: String
    let transcription: String
    @ObservedObject private var lecteur = LecteurAudio.partage
    @State private var transcriptionVisible = false
    private let barres: [CGFloat] = [5, 9, 14, 8, 16, 11, 6, 13, 17, 9, 5, 12, 15, 7, 10, 14, 6, 9, 12, 5, 8, 13, 7, 11]

    private var enLecture: Bool { lecteur.fichierActif == fichier }

    var body: some View {
        EnveloppeBulle(recu: recu) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 9) {
                    AvatarSilhouette(taille: 34)
                    Button { lecteur.bascule(fichier) } label: {
                        Image(systemName: enLecture ? "pause.fill" : "play.fill")
                            .font(.system(size: 18)).foregroundStyle(waTexte)
                            .frame(width: 26)
                    }
                    HStack(alignment: .center, spacing: 2) {
                        ForEach(0..<barres.count, id: \.self) { i in
                            Capsule()
                                .fill(enLecture && Double(i) / Double(barres.count) < lecteur.progression
                                      ? waVertDoux : waTexte2)
                                .frame(width: 2.5, height: barres[i])
                        }
                    }
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("1x").font(.system(size: 12, weight: .semibold)).foregroundStyle(waTexte)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color(hex: 0x333333), in: Capsule())
                        HStack(spacing: 3) {
                            Text(duree).font(.system(size: 11)).foregroundStyle(waTexte2)
                            Text(heure).font(.system(size: 11)).foregroundStyle(waTexte.opacity(0.55))
                        }
                    }
                }
                // Transcription dépliable (comme le vrai WhatsApp)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { transcriptionVisible.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: transcriptionVisible ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Transcription").font(.system(size: 12.5))
                    }
                    .foregroundStyle(waTexte2)
                }
                if transcriptionVisible {
                    Text(transcription)
                        .font(.system(size: 14.5)).italic()
                        .foregroundStyle(waTexte.opacity(0.85))
                        .padding(.top, 2)
                        .frame(maxWidth: 250, alignment: .leading)
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ============================================================ ÉCRAN D'APPEL AUDIO (écoutable)
// Deux modes (règle utilisateur du 16/08) : soit l'appel fait partie de l'histoire et il connecte
// (mode .histoire, voix + transcription), soit il sonne dans le vide (mode .sansReponse — défaut).
enum ModeAppel {
    case sansReponse
    case histoire(fichier: String, transcription: String)
}

struct AppelVue: View {
    @Environment(\.dismiss) private var dismiss
    let nom: String
    var mode: ModeAppel = .sansReponse
    @ObservedObject private var lecteur = LecteurAudio.partage
    @State private var secondes = 0
    @State private var transcriptionVisible = true
    @State private var statut = "appel…"
    private let tic = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x0E1B14), Color(hex: 0x060B08)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                Text("Chiffré de bout en bout")
                    .font(.system(size: 12.5)).foregroundStyle(waTexte2)
                    .padding(.top, 18)
                AvatarSilhouette(taille: 110, image: nom == "Marc ❤️" ? "AvatarMarc" : nil).padding(.top, 30)
                Text(nom).font(.system(size: 28, weight: .semibold)).foregroundStyle(waTexte).padding(.top, 14)
                Text(statut)
                    .font(.system(size: 16)).foregroundStyle(waTexte2).padding(.top, 4)

                Spacer()

                if case .histoire(_, let transcription) = mode, transcriptionVisible, secondes > 0 {
                    Text(transcription)
                        .font(.system(size: 15)).italic()
                        .foregroundStyle(waTexte.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 34).padding(.vertical, 14)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 24)
                }

                Spacer()

                HStack(spacing: 26) {
                    RondAppel(symbole: "speaker.wave.2.fill", actif: true)
                    RondAppel(symbole: "mic.slash.fill")
                    if case .histoire = mode {
                        Button {
                            Haptique.leger()
                            transcriptionVisible.toggle()
                        } label: {
                            RondAppel(symbole: "text.bubble.fill", actif: transcriptionVisible)
                        }
                    }
                    Button {
                        lecteur.arret()
                        dismiss()
                    } label: {
                        Circle().fill(Color(hex: 0xE53935)).frame(width: 62, height: 62)
                            .overlay(Image(systemName: "phone.down.fill")
                                .font(.system(size: 22)).foregroundStyle(.white))
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            if case .histoire(let fichier, _) = mode {
                statut = "0:00"
                lecteur.bascule(fichier)
            }
        }
        .onDisappear { lecteur.arret() }
        .onReceive(tic) { _ in
            secondes += 1
            switch mode {
            case .histoire:
                statut = String(format: "%d:%02d", secondes / 60, secondes % 60)
            case .sansReponse:
                // Wording WhatsApp réel : appel… → sonnerie… → Indisponible → raccroche
                if secondes >= 11 { dismiss() }
                else if secondes >= 8 { statut = "Indisponible" }
                else if secondes >= 2 { statut = "sonnerie…" }
                else { statut = "appel…" }
            }
        }
    }
}

struct RondAppel: View {
    let symbole: String
    var actif: Bool = false
    var body: some View {
        Circle().fill(actif ? Color.white.opacity(0.9) : Color.white.opacity(0.12))
            .frame(width: 52, height: 52)
            .overlay(Image(systemName: symbole)
                .font(.system(size: 19))
                .foregroundStyle(actif ? Color(hex: 0x0E1B14) : waTexte))
    }
}

enum Haptique {
    static func leger() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// ============================================================ SOUS-RÉGLAGES RÉELS (règle 16/08)
// Chaque écran connu a son VRAI contenu ; les autres : un chargement qui échoue, comme une vraie app.
enum LigneReglage {
    case interrupteur(String, Bool)
    case valeur(String, String)
    case navigation(String)
    case destructif(String)
}

// États vides RÉELS (comme le vrai WhatsApp) pour les écrans sans contenu
enum EcranVide {
    static let messages: [String: String] = [
        "Important": "Aucun message important",
        "Listes": "Créez des listes pour organiser vos discussions",
        "Messages de diffusion": "Aucune liste de diffusion",
        "Contacts bloqués": "Aucun contact bloqué",
        "Appareils connectés": "Utilisez WhatsApp sur d'autres appareils",
        "Exporter l'historique": "Choisissez une discussion à exporter",
    ]
}

enum ContenuReglages {
    static let ecrans: [String: [LigneReglage]] = [
        "Notifications": [.interrupteur("Afficher les notifications", true),
                          .valeur("Son", "Note"),
                          .interrupteur("Pastilles", true),
                          .interrupteur("Notifications groupées", false)],
        "Compte": [.valeur("Adresse e-mail", "sar•••@icloud.com"),
                   .navigation("Changer de numéro"),
                   .navigation("Demander les infos de mon compte"),
                   .destructif("Supprimer le compte")],
        "Confidentialité": [.valeur("Dernière connexion", "Tout le monde"),
                            .valeur("Photo de profil", "Mes contacts"),
                            .interrupteur("Confirmations de lecture", true),
                            .navigation("Contacts bloqués")],
        "Apparence": [.valeur("Thème", "Sombre"),
                      .navigation("Fond d'écran par défaut"),
                      .valeur("Taille du texte", "Standard")],
        "Discussions": [.valeur("Sauvegarde", "iCloud · hier à 03:12"),
                        .interrupteur("Enregistrer dans Photos", false),
                        .navigation("Exporter l'historique")],
        "Stockage et données": [.valeur("Utilisation du réseau", "1,2 Go envoyés"),
                                .valeur("Téléchargement auto", "Wi-Fi"),
                                .valeur("Gérer le stockage", "5,7 Mo")],
        "Aide": [.navigation("Centre d'aide"),
                 .navigation("Nous contacter"),
                 .navigation("Conditions et confidentialité")],
        "Thème de la discussion": [.valeur("Thème", "Par défaut"),
                                   .navigation("Choisir un fond d'écran")],
        "Messages éphémères": [.valeur("Durée", "Désactivés")],
    ]
}

struct SousReglageVue: View {
    @Environment(\.dismiss) private var dismiss
    let titre: String
    @State private var etats: [Int: Bool] = [:]
    @State private var confirmationDestructif = false
    @State private var nomDestructif = ""

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundStyle(waTexte)
                    }
                    Spacer()
                }
                Text(titre).font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)

            if let lignes = ContenuReglages.ecrans[titre] {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<lignes.count, id: \.self) { i in
                            ligneVue(lignes[i], index: i)
                            if i < lignes.count - 1 {
                                Divider().background(Color(hex: 0x2A2A2A)).padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16).padding(.top, 14)
                }
            } else if let vide = EcranVide.messages[titre] {
                // État vide réel, sobre — comme le vrai
                Spacer()
                Text(vide).font(.system(size: 15)).foregroundStyle(waTexte2)
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
                if titre == "Appareils connectés" {
                    Text("Associer un appareil").font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x062E1C))
                        .padding(.horizontal, 22).padding(.vertical, 12)
                        .background(waVertVif, in: Capsule())
                        .padding(.top, 18)
                }
                Spacer()
            } else {
                // Chargement discret qui n'aboutit pas (comportement d'app réel, sans drame)
                Spacer()
                ProgressView().tint(waTexte2).scaleEffect(1.2)
                Spacer()
            }
        }
        .background(waNoir.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(nomDestructif, isPresented: $confirmationDestructif, titleVisibility: .visible) {
            Button(nomDestructif, role: .destructive) {}
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette action est irréversible.")
        }
    }

    @ViewBuilder
    private func ligneVue(_ l: LigneReglage, index: Int) -> some View {
        switch l {
        case .interrupteur(let nom, let defaut):
            HStack {
                Text(nom).font(.system(size: 17)).foregroundStyle(waTexte)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { etats[index] ?? defaut },
                    set: { etats[index] = $0 })).labelsHidden().tint(waVertVif)
            }
            .padding(.horizontal, 16).padding(.vertical, 11)
        case .valeur(let nom, let valeur):
            HStack {
                Text(nom).font(.system(size: 17)).foregroundStyle(waTexte)
                Spacer()
                Text(valeur).font(.system(size: 16)).foregroundStyle(waTexte2)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(waTexte2)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        case .navigation(let nom):
            NavigationLink(destination: SousReglageVue(titre: nom)) {
                HStack {
                    Text(nom).font(.system(size: 17)).foregroundStyle(waTexte)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(waTexte2)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }
        case .destructif(let nom):
            HStack {
                Text(nom).font(.system(size: 17)).foregroundStyle(Color(hex: 0xF25B5B))
                Spacer()
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                nomDestructif = nom
                confirmationDestructif = true
            }
        }
    }
}

// ============================================================ RÉPONSES BANALES DÉTERMINISTES (D56)
// Doctrine des 4 anneaux : ce catalogue sert l'anneau 3 (actions qui sortiraient du téléphone).
// Règles : même bouton = toujours la même réponse ; deux boutons différents ne partagent
// jamais la même formulation ; chaque message est du même TYPE que l'action (réseau, matériel,
// compte, partage, contenu vide) et formulé comme iOS le ferait.
enum ErreurLambda {
    static let catalogue: [String: String] = [
        // Système / apps
        "app.attente": "Cette app sera de nouveau disponible après la mise à jour d'iOS programmée cette nuit.",
        "appstore": "Impossible de se connecter à l'App Store.",
        "camera": "Appareil photo indisponible.",
        "mail": "Aucun compte e-mail configuré.",
        "partage": "Aucune app disponible pour le partage.",
        "code.requis": "Cette action nécessite le code de l'iPhone.",
        "reseau": "Connexion au serveur impossible. Vérifiez votre connexion.",
        // Messages
        "photos.vide": "Photothèque indisponible pendant la synchronisation iCloud.",
        "autocollants": "Aucun autocollant installé.",
        "sondage": "Les sondages ne sont pas disponibles dans cette conversation.",
        "programmation": "L'envoi programmé est indisponible.",
        "intelligence": "Apple Intelligence n'est pas disponible sur cet iPhone.",
        "playground": "Image Playground n'est pas disponible sur cet iPhone.",
        "modif.contact": "Impossible de modifier ce contact.",
        // Téléphone
        "favoris": "Impossible d'ajouter aux favoris pour le moment.",
        "liste": "Impossible d'ajouter à une liste pour le moment.",
        "urgence": "Impossible de modifier les contacts d'urgence.",
        "blocage": "Le blocage est indisponible pour le moment.",
        "signalement": "Le signalement est indisponible pour le moment.",
        // WhatsApp
        "recherche.conv": "La recherche dans la conversation est indisponible.",
        "planifier": "Aucun événement à planifier avec ce contact.",
        "clavier.wa": "Ouvrez l'app Téléphone pour composer un numéro.",
        "wa.appeler": "Sélectionnez un contact dans la liste pour l'appeler.",
        "wa.favoris": "Aucun favori pour le moment.",
        "menu.indisponible": "Menu indisponible pour le moment.",
        "creation.indisponible": "Création indisponible pour le moment.",
        // Générique (dernier recours uniquement)
        "generique": "Réessayez plus tard.",
    ]
    static func reponse(_ cle: String) -> String {
        catalogue[cle] ?? catalogue["generique"]!
    }
    // Ancien pot commun (avant D56) — conservé pour compatibilité, ne plus utiliser.
    private static let messages = [
        "Une erreur s'est produite. Réessayez plus tard.",
        "Réessayez plus tard.",
        "Aucune connexion Internet.",
    ]
    static func message(_ graine: Int) -> String {
        messages[abs(graine) % messages.count]
    }
}
