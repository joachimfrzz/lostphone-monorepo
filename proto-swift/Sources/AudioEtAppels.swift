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
        guard let url = Bundle.main.url(forResource: fichier, withExtension: "mp3") else { return }
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
struct AppelVue: View {
    @Environment(\.dismiss) private var dismiss
    let nom: String
    let fichier: String
    let transcription: String
    @ObservedObject private var lecteur = LecteurAudio.partage
    @State private var secondes = 0
    @State private var transcriptionVisible = true
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
                Text(String(format: "%d:%02d", secondes / 60, secondes % 60))
                    .font(.system(size: 16)).foregroundStyle(waTexte2).padding(.top, 4)

                Spacer()

                if transcriptionVisible {
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
                    RondAppel(symbole: "video.slash.fill")
                    RondAppel(symbole: "mic.slash.fill")
                    Button {
                        Haptique.leger()
                        transcriptionVisible.toggle()
                    } label: {
                        RondAppel(symbole: "text.bubble.fill", actif: transcriptionVisible)
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
        .onAppear { lecteur.bascule(fichier) }
        .onDisappear { lecteur.arret() }
        .onReceive(tic) { _ in secondes += 1 }
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

// ============================================================ SOUS-RÉGLAGE GÉNÉRIQUE (D51-1)
// Chaque ligne de réglages ouvre un écran plausible : rien n'est un bouton mort.
struct SousReglageVue: View {
    @Environment(\.dismiss) private var dismiss
    let titre: String
    @State private var interrupteur1 = true
    @State private var interrupteur2 = false

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

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Activé").font(.system(size: 17)).foregroundStyle(waTexte)
                            Spacer()
                            Toggle("", isOn: $interrupteur1).labelsHidden().tint(waVertVif)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 11)
                        Divider().background(Color(hex: 0x2A2A2A)).padding(.leading, 16)
                        HStack {
                            Text("Aperçus").font(.system(size: 17)).foregroundStyle(waTexte)
                            Spacer()
                            Toggle("", isOn: $interrupteur2).labelsHidden().tint(waVertVif)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 11)
                    }
                    .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16).padding(.top, 14)

                    Text("Ces réglages s'appliquent à \(titre.lowercased()).")
                        .font(.system(size: 13)).foregroundStyle(waTexte2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30).padding(.top, 8)
                    Spacer(minLength: 60)
                }
            }
        }
        .background(waNoir.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ============================================================ ERREURS BANALES VARIÉES (D51-1)
// Jamais deux fois la même : le message dépend du contexte (graine déterministe).
enum ErreurLambda {
    private static let messages = [
        "Impossible de charger le contenu. Réessayez plus tard.",
        "Cette fonctionnalité nécessite une connexion Internet.",
        "Une erreur s'est produite. Réessayez. (WA-2201)",
        "Service momentanément indisponible.",
        "Le chargement a expiré. Vérifiez votre connexion.",
        "Action impossible pour le moment.",
    ]
    static func message(_ graine: Int) -> String {
        messages[abs(graine) % messages.count]
    }
}
