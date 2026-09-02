// Dictaphone (Mémos vocaux) — construit contre la vidéo de référence du 18/08 (23 écrans, iOS 26)
// D59 : données remplaçables. AUDIO RÉEL : 2 mémos de Sarah générés et embarqués (voix Leda),
// dont la répétition du rendez-vous bancaire (recoupe la note P60 « Dire que c'est pour des travaux ?? »).
// D51 : lecture réelle, avance/recul 15 s réels, renommer/dupliquer/supprimer/favori réels.
// v2 session 3 (02/09, retours Joachim) : un NOUVEL ENREGISTREMENT est un vrai fichier audio de la durée
// exacte enregistrée (fini le mémo « Idée photo » lu à sa place — cause : nom de fichier vide → iOS renvoyait
// le premier .mp3 du bundle) ; Sélectionner RÉEL (cocher → Supprimer/Partager) ; Recherche RÉELLE ;
// Modifier RÉEL sur les dossiers (supprimer/renommer un dossier) ; bouton rouge remonté au-dessus de la capsule.
import SwiftUI
import AVFoundation

// ============================================================ DONNÉES (remplaçables — D59)
struct MemoVocal: Identifiable {
    let id = UUID()
    var titre: String
    var dateTexte: String
    var duree: String
    var fichier: String            // nom du mp3 dans Ressources/ OU chemin absolu d'un enregistrement du joueur
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
    // v2 : dossiers persistants (Modifier réel)
    @Published var dossiers: [String] = ["Idées photo"]

    func supprimer(_ ids: Set<UUID>) { memos.removeAll { ids.contains($0.id) } }
    func supprimerDossier(_ d: String) {
        dossiers.removeAll { $0 == d }
        for i in memos.indices where memos[i].dossier == d { memos[i].dossier = nil }
    }
    func renommerDossier(_ d: String, en nouveau: String) {
        guard let i = dossiers.firstIndex(of: d), !nouveau.isEmpty else { return }
        dossiers[i] = nouveau
        for k in memos.indices where memos[k].dossier == d { memos[k].dossier = nouveau }
    }
}

// ============================================================ FICHIER AUDIO D'UN ENREGISTREMENT DU JOUEUR
// Le jeu n'active pas le micro (la demande d'autorisation iOS « Lost Phone souhaite accéder au micro »
// casserait la fiction). On produit un vrai WAV PCM de la durée exacte mesurée : la lecture dure ce temps-là,
// la barre avance, ±15 s marchent — cohérence totale avec ce qui vient d'être créé.
enum AudioJoueur {
    static func creerWavSilencieux(duree: TimeInterval) -> String? {
        let hz = 8000, canaux = 1, bits = 16
        let frames = max(1, Int(duree * Double(hz)))
        let dataSize = frames * canaux * bits / 8
        var d = Data(capacity: 44 + dataSize)
        func u32(_ v: UInt32) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 4)) }
        func u16(_ v: UInt16) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 2)) }
        d.append(contentsOf: Array("RIFF".utf8)); u32(UInt32(36 + dataSize)); d.append(contentsOf: Array("WAVE".utf8))
        d.append(contentsOf: Array("fmt ".utf8)); u32(16); u16(1); u16(UInt16(canaux))
        u32(UInt32(hz)); u32(UInt32(hz * canaux * bits / 8)); u16(UInt16(canaux * bits / 8)); u16(UInt16(bits))
        d.append(contentsOf: Array("data".utf8)); u32(UInt32(dataSize))
        d.append(Data(count: dataSize))
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("memo-\(UUID().uuidString).wav")
        do { try d.write(to: url); return url.path } catch { return nil }
    }
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
        // v2 : JAMAIS de nom vide (iOS renverrait le premier mp3 du bundle) ; chemins absolus acceptés
        guard !fichier.isEmpty else { return }
        let url: URL?
        if fichier.hasPrefix("/") {
            url = FileManager.default.fileExists(atPath: fichier) ? URL(fileURLWithPath: fichier) : nil
        } else {
            url = Bundle.main.url(forResource: fichier, withExtension: "mp3")
                ?? Bundle.main.url(forResource: fichier, withExtension: "mp3", subdirectory: "Ressources")
        }
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
        l.currentTime = max(0, min(max(0, l.duration - 0.2), l.currentTime + delta))
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
    @State private var enregVisible = false
    @State private var edition = false                 // v2 : Modifier réel (dossiers)
    @State private var dossierARenommer: String? = nil
    @State private var nouveauNomDossier = ""
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

                        if !magasin.dossiers.isEmpty {
                            Text("Mes dossiers").font(.system(size: 15)).foregroundStyle(.secondary)
                            VStack(spacing: 1) {
                                ForEach(magasin.dossiers, id: \.self) { d in
                                    HStack(spacing: 0) {
                                        if edition {
                                            // v2 : mode Modifier réel — supprimer / renommer un dossier
                                            Button {
                                                withAnimation { magasin.supprimerDossier(d) }
                                            } label: {
                                                Image(systemName: "minus.circle.fill").font(.system(size: 22)).foregroundStyle(Color(hex: 0xFF453A))
                                            }
                                            .padding(.leading, 14)
                                            Button { dossierARenommer = d; nouveauNomDossier = d } label: {
                                                LigneDossier(symbole: "folder.fill", couleur: Color(hex: 0x0A84FF),
                                                             nom: d, compte: magasin.memos.filter { $0.dossier == d }.count, chevron: false)
                                            }
                                        } else {
                                            NavigationLink(destination: ListeMemosVue(titre: d) { $0.dossier == d }) {
                                                LigneDossier(symbole: "folder.fill", couleur: Color(hex: 0x0A84FF),
                                                             nom: d, compte: magasin.memos.filter { $0.dossier == d }.count)
                                            }
                                        }
                                    }
                                    .background(Color(hex: 0x1C1C1E))
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        Spacer(minLength: 130)
                    }
                    .padding(.horizontal, 16)
                }

                // Bouton d'enregistrement (v2 : remonté au-dessus de la capsule home)
                Button { enregVisible = true } label: {
                    Circle().fill(Color(hex: 0xFF3B30)).frame(width: 54, height: 54)
                        .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 3).frame(width: 66, height: 66))
                }
                .padding(.bottom, 34)

            BarreHome { dismiss() }
            }
            .navigationDestination(for: String.self) { _ in
                ListeMemosVue(titre: "Tous les enregistrements") { _ in true }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // v2 : Modifier RÉEL
                    Button(edition ? "OK" : "Modifier") { withAnimation { edition.toggle() } }
                        .font(.system(size: 17, weight: edition ? .semibold : .regular))
                        .foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            .alert("Renommer le dossier", isPresented: Binding(get: { dossierARenommer != nil }, set: { if !$0 { dossierARenommer = nil } })) {
                TextField("Nom", text: $nouveauNomDossier)
                Button("Annuler", role: .cancel) {}
                Button("OK") { if let d = dossierARenommer { magasin.renommerDossier(d, en: nouveauNomDossier) } }
            }
            .sheet(isPresented: $enregVisible) {
                EnregistrementDictaVue().presentationDetents([.height(280)])
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
    var chevron: Bool = true
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbole).font(.system(size: 17)).foregroundStyle(couleur)
                .frame(width: 28)
            Text(nom).font(.system(size: 16.5)).foregroundStyle(.white)
            Spacer()
            Text("\(compte)").font(.system(size: 16)).foregroundStyle(.secondary)
            if chevron {
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
            }
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
    @State private var enregListeVisible = false
    @State private var remplacerAlerte = false
    // v2 : sélection RÉELLE + recherche RÉELLE
    @State private var selectionActive = false
    @State private var selectionIds: Set<UUID> = []
    @State private var rechercheActive = false
    @State private var recherche = ""
    @FocusState private var champRecherche: Bool

    init(titre: String, filtre: @escaping (MemoVocal) -> Bool) {
        self.titre = titre; self.filtre = filtre
    }

    private var items: [MemoVocal] {
        let base = magasin.memos.filter(filtre)
        guard rechercheActive, !recherche.trimmingCharacters(in: .whitespaces).isEmpty else { return base }
        return base.filter { $0.titre.localizedCaseInsensitiveContains(recherche) || $0.transcription.localizedCaseInsensitiveContains(recherche) }
    }

    private func fmt(_ t: TimeInterval) -> String {
        String(format: "%02d:%05.2f", Int(t) / 60, t.truncatingRemainder(dividingBy: 60))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(titre).font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                    .padding(.bottom, 10)
                if rechercheActive {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Rechercher", text: $recherche).foregroundStyle(.white).focused($champRecherche)
                        if !recherche.isEmpty {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary).onTapGesture { recherche = "" }
                        }
                    }
                    .padding(.horizontal, 12).frame(height: 38)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 10)
                }
                if items.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: rechercheActive && !recherche.isEmpty ? "magnifyingglass" : "folder").font(.system(size: 42)).foregroundStyle(.secondary)
                        Text(rechercheActive && !recherche.isEmpty ? "Aucun résultat" : "Aucun enregistrement").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                        if !(rechercheActive && !recherche.isEmpty) {
                            Text("Touchez le bouton Enregistrer pour commencer un mémo vocal.")
                                .font(.system(size: 13)).foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.top, 120)
                }
                ForEach(items) { m in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            if selectionActive {
                                Image(systemName: selectionIds.contains(m.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22)).foregroundStyle(selectionIds.contains(m.id) ? Color(hex: 0x0A84FF) : .secondary)
                                    .padding(.trailing, 6)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(m.titre).font(.system(size: 16.5, weight: .semibold)).foregroundStyle(.white)
                                Text(m.dateTexte).font(.system(size: 13.5)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if ouvert != m.id {
                                Text(m.duree).font(.system(size: 14)).foregroundStyle(.secondary)
                            }
                            if !selectionActive {
                                Menu {
                                    Button { renommageId = m.id; nouveauNom = m.titre } label: { Label("Renommer", systemImage: "pencil") }
                                    Button { transcriptionVisible = m } label: { Label("Afficher la transcription", systemImage: "quote.bubble") }
                                    Button {
                                        if let i = magasin.memos.firstIndex(where: { $0.id == m.id }) { magasin.memos[i].favori.toggle() }
                                    } label: { Label(m.favori ? "Retirer des favoris" : "Ajouter aux favoris", systemImage: "heart") }
                                    if !magasin.dossiers.isEmpty {
                                        Menu("Déplacer vers") {
                                            ForEach(magasin.dossiers, id: \.self) { d in
                                                Button(d) { if let i = magasin.memos.firstIndex(where: { $0.id == m.id }) { magasin.memos[i].dossier = d } }
                                            }
                                            if m.dossier != nil {
                                                Button("Aucun dossier") { if let i = magasin.memos.firstIndex(where: { $0.id == m.id }) { magasin.memos[i].dossier = nil } }
                                            }
                                        }
                                    }
                                    Button { dupliquer(m) } label: { Label("Dupliquer", systemImage: "plus.square.on.square") }
                                    Button(role: .destructive) { magasin.memos.removeAll { $0.id == m.id } } label: { Label("Supprimer", systemImage: "trash") }
                                } label: {
                                    Image(systemName: "ellipsis").font(.system(size: 17)).foregroundStyle(.secondary)
                                        .frame(width: 34, height: 34)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectionActive {
                                if selectionIds.contains(m.id) { selectionIds.remove(m.id) } else { selectionIds.insert(m.id) }
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if ouvert == m.id { ouvert = nil; lecteur.arret() }
                                    else { ouvert = m.id; lecteur.charge(m.fichier) }
                                }
                            }
                        }
                        .contextMenu {
                            Button { partageVisible = true } label: { Label("Partager", systemImage: "square.and.arrow.up") }
                            Button { renommageId = m.id; nouveauNom = m.titre } label: { Label("Renommer", systemImage: "pencil") }
                            Button { transcriptionVisible = m } label: { Label("Afficher la transcription", systemImage: "quote.bubble") }
                            Button {
                                if let i = magasin.memos.firstIndex(where: { $0.id == m.id }) { magasin.memos[i].favori.toggle() }
                            } label: { Label(m.favori ? "Retirer des favoris" : "Ajouter aux favoris", systemImage: "heart") }
                            Button { dupliquer(m) } label: { Label("Dupliquer", systemImage: "plus.square.on.square") }
                            Button(role: .destructive) { magasin.memos.removeAll { $0.id == m.id } } label: { Label("Supprimer", systemImage: "trash") }
                        }

                        if ouvert == m.id && !selectionActive {
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
                Spacer(minLength: 120)
            }
            .padding(.horizontal, 18)
        }
        .background(Color.black)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 10) {
                    // v2 : Recherche RÉELLE
                    Button {
                        withAnimation { rechercheActive.toggle() }
                        if rechercheActive { champRecherche = true } else { recherche = "" }
                    } label: {
                        Image(systemName: rechercheActive ? "xmark" : "magnifyingglass").font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color(hex: 0x1C1C1E), in: Circle())
                    }
                    // v2 : Sélectionner RÉEL
                    Button {
                        withAnimation { selectionActive.toggle() }
                        if !selectionActive { selectionIds.removeAll() } else { ouvert = nil; lecteur.arret() }
                    } label: {
                        Text(selectionActive ? "Annuler" : "Sélectionner").font(.system(size: 15)).foregroundStyle(Color(hex: 0x0A84FF))
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color(hex: 0x1C1C1E), in: Capsule())
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if selectionActive {
                // v2 : barre d'actions de sélection (comme iOS : Partager / Supprimer)
                HStack {
                    Button { partageVisible = true } label: {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 20))
                            .foregroundStyle(selectionIds.isEmpty ? .secondary : Color(hex: 0x0A84FF))
                    }.disabled(selectionIds.isEmpty)
                    Spacer()
                    Text(selectionIds.isEmpty ? "Sélectionner des éléments" : "\(selectionIds.count) sélectionné\(selectionIds.count > 1 ? "s" : "")")
                        .font(.system(size: 15)).foregroundStyle(.white)
                    Spacer()
                    Button {
                        withAnimation { magasin.supprimer(selectionIds) }
                        selectionIds.removeAll(); selectionActive = false
                    } label: {
                        Image(systemName: "trash").font(.system(size: 20))
                            .foregroundStyle(selectionIds.isEmpty ? .secondary : Color(hex: 0xFF453A))
                    }.disabled(selectionIds.isEmpty)
                }
                .padding(.horizontal, 22).padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .padding(.bottom, 26)
            } else {
                // Miroir lot 1bis : le bouton d'enregistrement vit AUSSI sur la liste (référence f001) — v2 : remonté
                Button { enregListeVisible = true } label: {
                    Circle().fill(Color(hex: 0xFF3B30)).frame(width: 54, height: 54)
                        .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 3).frame(width: 66, height: 66))
                }
                .padding(.bottom, 34)
            }
        }
        .sheet(isPresented: $enregListeVisible) {
            EnregistrementDictaVue(dossier: magasin.dossiers.contains(titre) ? titre : nil).presentationDetents([.height(280)])
        }
        .sheet(isPresented: $partageVisible) { FeuillePartage(element: selectionIds.count > 1 ? "\(selectionIds.count) mémos vocaux" : "Mémo vocal", contenu: "Mémo vocal (audio)", type: .fichier) }
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

    private func dupliquer(_ m: MemoVocal) {
        if let i = magasin.memos.firstIndex(where: { $0.id == m.id }) {
            let copie = magasin.memos[i]
            let nouvelle = MemoVocal(titre: copie.titre + " copie", dateTexte: copie.dateTexte,
                                     duree: copie.duree, fichier: copie.fichier,
                                     transcription: copie.transcription, favori: false, dossier: copie.dossier)
            magasin.memos.insert(nouvelle, at: i + 1)
        }
    }
}

extension MemoVocal: Hashable {
    static func == (a: MemoVocal, b: MemoVocal) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}


// ============================================================ D82 — ENREGISTREMENT RÉEL
// L'enregistrement tourne (chrono + onde animée) et crée un vrai mémo dans la liste,
// avec un VRAI fichier audio de la durée exacte (v2).
struct EnregistrementDictaVue: View {
    var dossier: String? = nil
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var magasin = MagasinMemos.partage
    @State private var debut = Date()
    @State private var tics = 0
    private let minuteur = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private var chrono: String {
        let e = Date().timeIntervalSince(debut)
        let t = Int(e)
        let dixiemes = Int(e * 10) % 10
        return String(format: "%d:%02d,%d0", t / 60, t % 60, dixiemes)
    }
    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color(white: 0.35)).frame(width: 36, height: 5).padding(.top, 8)
            HStack {
                Text("Nouvel enregistrement \(numeroSuivant)")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 18).padding(.top, 18)
            HStack {
                Text(chrono).font(.system(size: 15)).monospacedDigit().foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 18).padding(.top, 2)
            // onde animée
            HStack(spacing: 2.5) {
                ForEach(0..<48, id: \.self) { i in
                    Capsule().fill(Color.red)
                        .frame(width: 2.5, height: hauteurBarre(i))
                }
            }
            .frame(height: 46)
            .padding(.top, 26)
            .onReceive(minuteur) { _ in tics += 1 }
            Spacer()
            Button {
                let elapsed = max(1.0, Date().timeIntervalSince(debut))
                let t = Int(elapsed.rounded())
                let duree = String(format: "%d:%02d", t / 60, t % 60)
                let f = DateFormatter(); f.dateFormat = "d MMM yyyy"; f.locale = Locale(identifier: "fr_FR")
                // v2 : fichier audio réel de la durée enregistrée (jamais un nom vide)
                let chemin = AudioJoueur.creerWavSilencieux(duree: elapsed) ?? "memo-vide-introuvable"
                magasin.memos.insert(MemoVocal(titre: "Nouvel enregistrement \(numeroSuivant)",
                                               dateTexte: f.string(from: Date()), duree: duree,
                                               fichier: chemin, transcription: "Aucune transcription disponible",
                                               dossier: dossier),
                                     at: 0)
                Haptique.leger()
                dismiss()
            } label: {
                Circle().stroke(Color(white: 0.45), lineWidth: 3).frame(width: 64, height: 64)
                    .overlay(RoundedRectangle(cornerRadius: 6).fill(.red).frame(width: 26, height: 26))
            }
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: 0x1C1C1E))
        .preferredColorScheme(.dark)
    }
    private func hauteurBarre(_ i: Int) -> CGFloat {
        let phase: Int = (i * 7 + tics * 3) % 13
        let h: Int = 6 + (17 * phase) / 13
        return CGFloat(h)
    }

    private var numeroSuivant: Int {
        let nums = magasin.memos.compactMap { m -> Int? in
            guard m.titre.hasPrefix("Nouvel enregistrement ") else { return nil }
            return Int(m.titre.replacingOccurrences(of: "Nouvel enregistrement ", with: ""))
        }
        return (nums.max() ?? 14) + 1
    }
}
