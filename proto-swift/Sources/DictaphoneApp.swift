// Dictaphone (Mémos vocaux) — construit contre la vidéo de référence du 18/08 (23 écrans, iOS 26)
// D59 : données remplaçables. AUDIO RÉEL : 2 mémos de Sarah générés et embarqués (voix Leda),
// dont la répétition du rendez-vous bancaire (recoupe la note P60 « Dire que c'est pour des travaux ?? »).
// D51 : lecture réelle, avance/recul 15 s réels, renommer/dupliquer/supprimer/favori réels.
import SwiftUI
import AVFoundation

// ============================================================ DONNÉES (remplaçables — D59)
struct MemoVocal: Identifiable {
    let id = UUID()
    var titre: String
    var dateTexte: String
    var duree: String
    var fichier: String            // nom du mp3 dans Ressources/
    var transcription: String
    var favori: Bool = false
    var dossier: String? = nil
}

final class MagasinMemos: ObservableObject {
    static let partage = MagasinMemos()
    @Published var memos: [MemoVocal] = [
        MemoVocal(titre: "Nouvel enregistrement 14",
                  dateTexte: "16 août 2026", duree: "0:22", fichier: "memo-banque",
                  transcription: "Bonjour… j'aurais besoin d'augmenter mon plafond de virement, s'il vous plaît. C'est pour… c'est pour des travaux dans mon appartement. Hum. Non. Bonjour, je souhaite augmenter mon plafond de virement pour financer des travaux. Voilà. C'est mieux. Cinq mille euros. Ils vont pas me demander les factures quand même ?… Bon. On verra bien. Onze heures trente.",
                  favori: false),
        MemoVocal(titre: "Idée photo quais",
                  dateTexte: "12 oct. 2025", duree: "0:14", fichier: "memo-photo",
                  transcription: "Idée photo… la brume sur les quais ce matin, c'était incroyable. Y retourner en novembre, tôt, genre sept heures. Prendre le cinquante millimètres. Et tester la pose longue sur les reflets, cette fois sans trembler.",
                  favori: true, dossier: "Idées photo"),
    ]
}

// ============================================================ LECTEUR (seek réel ±15 s)
final class LecteurMemo: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let partage = LecteurMemo()
    @Published var fichierActif: String? = nil
    @Published var enLecture = false
    @Published var position: TimeInterval = 0
    @Published var duree: TimeInterval = 0
    private var lecteur: AVAudioPlayer?
    private var minuteur: Timer?

    func charge(_ fichier: String) {
        guard fichierActif != fichier else { return }
        arret()
        let url = Bundle.main.url(forResource: fichier, withExtension: "mp3")
            ?? Bundle.main.url(forResource: fichier, withExtension: "mp3", subdirectory: "Ressources")
        guard let url else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        lecteur = try? AVAudioPlayer(contentsOf: url)
        lecteur?.delegate = self
        fichierActif = fichier
        duree = lecteur?.duration ?? 0
        position = 0
    }
    func bascule() {
        guard let l = lecteur else { return }
        if enLecture { l.pause(); enLecture = false; minuteur?.invalidate() }
        else {
            l.play(); enLecture = true
            minuteur = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self, let l = self.lecteur else { return }
                self.position = l.currentTime
            }
        }
    }
    func saute(_ delta: TimeInterval) {
        guard let l = lecteur else { return }
        l.currentTime = max(0, min(l.duration - 0.2, l.currentTime + delta))
        position = l.currentTime
    }
    func arret() {
        lecteur?.stop(); lecteur = nil
        minuteur?.invalidate(); minuteur = nil
        fichierActif = nil; enLecture = false; position = 0; duree = 0
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        enLecture = false; position = 0; minuteur?.invalidate()
    }
}

// ============================================================ APP
struct DictaphoneVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinMemos.partage
    @State private var enregAlerte = false
    // Miroir lot 1 : la vraie app s'ouvre sur la liste, les dossiers sont l'écran de retour
    @State private var chemin: [String] = ["tous"]

    var body: some View {
        NavigationStack(path: $chemin) {
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Mémos vocaux").font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                            .padding(.top, 6)
                        VStack(spacing: 1) {
                            NavigationLink(destination: ListeMemosVue(titre: "Tous les enregistrements") { _ in true }) {
                                LigneDossier(symbole: "waveform", couleur: Color(hex: 0x0A84FF),
                                             nom: "Tous les enregistrements", compte: magasin.memos.count)
                            }
                            NavigationLink(destination: ListeMemosVue(titre: "Favoris") { $0.favori }) {
                                LigneDossier(symbole: "heart", couleur: Color(hex: 0xE84D6B),
                                             nom: "Favoris", compte: magasin.memos.filter { $0.favori }.count)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text("Mes dossiers").font(.system(size: 15)).foregroundStyle(.secondary)
                        VStack(spacing: 1) {
                            NavigationLink(destination: ListeMemosVue(titre: "Idées photo") { $0.dossier == "Idées photo" }) {
                                LigneDossier(symbole: "folder.fill", couleur: Color(hex: 0x0A84FF),
                                             nom: "Idées photo", compte: magasin.memos.filter { $0.dossier == "Idées photo" }.count)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 16)
                }

                // Bouton d'enregistrement
                Button { enregAlerte = true } label: {
                    Circle().fill(Color(hex: 0xFF3B30)).frame(width: 54, height: 54)
                        .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 3).frame(width: 66, height: 66))
                }
                .padding(.bottom, 22)

            BarreHome { dismiss() }
            }
            .navigationDestination(for: String.self) { _ in
                ListeMemosVue(titre: "Tous les enregistrements") { _ in true }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("Modifier").foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            // D56 : réponse déterministe de type matériel, propre à ce bouton
            .alert("Enregistrement impossible", isPresented: $enregAlerte) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Le micro est utilisé par une autre app.")
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear { LecteurMemo.partage.arret() }
    }
}

struct LigneDossier: View {
    let symbole: String
    let couleur: Color
    let nom: String
    let compte: Int
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbole).font(.system(size: 17)).foregroundStyle(couleur)
                .frame(width: 28)
            Text(nom).font(.system(size: 16.5)).foregroundStyle(.white)
            Spacer()
            Text("\(compte)").font(.system(size: 16)).foregroundStyle(.secondary)
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(Color(hex: 0x1C1C1E))
    }
}

// ============================================================ LISTE + LECTURE
struct ListeMemosVue: View {
    let titre: String
    let filtre: (MemoVocal) -> Bool
    @ObservedObject private var magasin = MagasinMemos.partage
    @ObservedObject private var lecteur = LecteurMemo.partage
    @State private var ouvert: UUID? = nil
    @State private var renommageId: UUID? = nil
    @State private var nouveauNom = ""
    @State private var transcriptionVisible: MemoVocal? = nil
    @State private var partageVisible = false
    @State private var enregAlerteListe = false
    @State private var remplacerAlerte = false

    init(titre: String, filtre: @escaping (MemoVocal) -> Bool) {
        self.titre = titre; self.filtre = filtre
    }

    private var items: [MemoVocal] { magasin.memos.filter(filtre) }

    private func fmt(_ t: TimeInterval) -> String {
        String(format: "%02d:%05.2f", Int(t) / 60, t.truncatingRemainder(dividingBy: 60))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(titre).font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                    .padding(.bottom, 10)
                if items.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "folder").font(.system(size: 42)).foregroundStyle(.secondary)
                        Text("Aucun enregistrement").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                        Text("Touchez le bouton Enregistrer pour commencer un mémo vocal.")
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 120)
                }
                ForEach(items) { m in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(m.titre).font(.system(size: 16.5, weight: .semibold)).foregroundStyle(.white)
                                Text(m.dateTexte).font(.system(size: 13.5)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if ouvert != m.id {
                                Text(m.duree).font(.system(size: 14)).foregroundStyle(.secondary)
                            }
                            Menu {
                                Button { renommageId = m.id; nouveauNom = m.titre } label: { Label("Renommer", systemImage: "pencil") }
                                Button { transcriptionVisible = m } label: { Label("Afficher la transcription", systemImage: "quote.bubble") }
                                Button {
                                    if let i = magasin.memos.firstIndex(where: { $0.id == m.id }) {
                                        magasin.memos[i].favori.toggle()
                                    }
                                } label: { Label(m.favori ? "Retirer des favoris" : "Ajouter aux favoris", systemImage: "heart") }
                                Button {
                                    if let i = magasin.memos.firstIndex(where: { $0.id == m.id }) {
                                        let copie = magasin.memos[i]
                                        let nouvelle = MemoVocal(titre: copie.titre + " copie", dateTexte: copie.dateTexte,
                                                                 duree: copie.duree, fichier: copie.fichier,
                                                                 transcription: copie.transcription, favori: false, dossier: copie.dossier)
                                        magasin.memos.insert(nouvelle, at: i + 1)
                                    }
                                } label: { Label("Dupliquer", systemImage: "plus.square.on.square") }
                                Button(role: .destructive) {
                                    magasin.memos.removeAll { $0.id == m.id }
                                } label: { Label("Supprimer", systemImage: "trash") }
                            } label: {
                                Image(systemName: "ellipsis").font(.system(size: 17)).foregroundStyle(.secondary)
                                    .frame(width: 34, height: 34)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if ouvert == m.id { ouvert = nil; lecteur.arret() }
                                else { ouvert = m.id; lecteur.charge(m.fichier) }
                            }
                        }
                        .contextMenu {
                            Button { partageVisible = true } label: { Label("Partager", systemImage: "square.and.arrow.up") }
                            Button { renommageId = m.id; nouveauNom = m.titre } label: { Label("Renommer", systemImage: "pencil") }
                            Button { transcriptionVisible = m } label: { Label("Afficher la transcription", systemImage: "quote.bubble") }
                            Button {
                                if let i = magasin.memos.firstIndex(where: { $0.id == m.id }) {
                                    magasin.memos[i].favori.toggle()
                                }
                            } label: { Label(m.favori ? "Retirer des favoris" : "Ajouter aux favoris", systemImage: "heart") }
                            Button {
                                if let i = magasin.memos.firstIndex(where: { $0.id == m.id }) {
                                    let copie = magasin.memos[i]
                                    let nouvelle = MemoVocal(titre: copie.titre + " copie", dateTexte: copie.dateTexte,
                                                             duree: copie.duree, fichier: copie.fichier,
                                                             transcription: copie.transcription, favori: false, dossier: copie.dossier)
                                    magasin.memos.insert(nouvelle, at: i + 1)
                                }
                            } label: { Label("Dupliquer", systemImage: "plus.square.on.square") }
                            Button(role: .destructive) {
                                magasin.memos.removeAll { $0.id == m.id }
                            } label: { Label("Supprimer", systemImage: "trash") }
                        }

                        if ouvert == m.id {
                            VStack(spacing: 12) {
                                // Transcription visible pendant la lecture (comme la référence)
                                Text(m.transcription)
                                    .font(.system(size: 14.5)).foregroundStyle(.white.opacity(0.85))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 8)
                                // Barre de progression réelle
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color(hex: 0x3A3A3C)).frame(height: 4)
                                        Capsule().fill(.white)
                                            .frame(width: max(4, geo.size.width * (lecteur.duree > 0 ? lecteur.position / lecteur.duree : 0)), height: 4)
                                    }
                                    .frame(maxHeight: .infinity, alignment: .center)
                                }
                                .frame(height: 12)
                                Text(fmt(lecteur.position))
                                    .font(.system(size: 34, weight: .light)).monospacedDigit().foregroundStyle(.white)
                                HStack(spacing: 40) {
                                    Button { lecteur.saute(-15) } label: {
                                        Image(systemName: "gobackward.15").font(.system(size: 22)).foregroundStyle(.white)
                                    }
                                    Button { lecteur.bascule() } label: {
                                        Image(systemName: lecteur.enLecture ? "pause.fill" : "play.fill")
                                            .font(.system(size: 30)).foregroundStyle(.white)
                                    }
                                    Button { lecteur.saute(15) } label: {
                                        Image(systemName: "goforward.15").font(.system(size: 22)).foregroundStyle(.white)
                                    }
                                }
                                Button { remplacerAlerte = true } label: {
                                    Text("REMPLACER").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                                        .padding(.horizontal, 26).padding(.vertical, 10)
                                        .background(Color(hex: 0xFF3B30), in: Capsule())
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .padding(.vertical, 10)
                    Divider().overlay(Color(hex: 0x2C2C2E))
                }
                Spacer(minLength: 60)
            }
            .padding(.horizontal, 18)
        }
        .background(Color.black)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(hex: 0x1C1C1E), in: Circle())
                    Text("Sélectionner").font(.system(size: 15)).foregroundStyle(Color(hex: 0x0A84FF))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color(hex: 0x1C1C1E), in: Capsule())
                }
            }
        }
        .overlay(alignment: .bottom) {
            // Miroir lot 1bis : le bouton d'enregistrement vit AUSSI sur la liste (référence f001)
            Button { enregAlerteListe = true } label: {
                Circle().fill(Color(hex: 0xFF3B30)).frame(width: 54, height: 54)
                    .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 3).frame(width: 66, height: 66))
            }
            .padding(.bottom, 26)
        }
        .alert("Enregistrement impossible", isPresented: $enregAlerteListe) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Le micro est utilisé par une autre app.")
        }
        .sheet(isPresented: $partageVisible) { FeuillePartage(element: "Mémo vocal") }
        .alert("Renommer", isPresented: Binding(get: { renommageId != nil }, set: { if !$0 { renommageId = nil } })) {
            TextField("Nom", text: $nouveauNom)
            Button("Annuler", role: .cancel) {}
            Button("OK") {
                if let id = renommageId, let i = magasin.memos.firstIndex(where: { $0.id == id }) {
                    magasin.memos[i].titre = nouveauNom
                }
            }
        }
        .alert("Remplacement impossible", isPresented: $remplacerAlerte) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Le micro est utilisé par une autre app.")
        }
        .sheet(item: $transcriptionVisible) { m in
            NavigationStack {
                ScrollView {
                    Text(m.transcription)
                        .font(.system(size: 16)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                }
                .background(Color(hex: 0x1C1C1E))
                .navigationTitle("Transcription")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("OK") { transcriptionVisible = nil }.foregroundStyle(Color(hex: 0x0A84FF))
                    }
                }
            }
            .preferredColorScheme(.dark)
            .presentationDetents([.medium])
        }
        .onDisappear { lecteur.arret() }
    }
}

extension MemoVocal: Hashable {
    static func == (a: MemoVocal, b: MemoVocal) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
