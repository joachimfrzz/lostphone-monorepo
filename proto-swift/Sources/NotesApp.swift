// Notes — construite contre la vidéo de référence du 18/08 (26 écrans, iOS 26)
// D59 : données remplaçables. R3 : contient la note « Documents pour lundi » de la capture P60.
// D51 : utilisable de A à Z (création, édition persistante, recherche réelle, épinglage).
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct NoteItem: Identifiable {
    let id = UUID()
    var titre: String
    var corps: String
    var dateTexte: String       // "22:47", "hier", "11/08/2026"
    var section: String         // "Épinglées", "Aujourd'hui", "7 jours précédents", "30 jours précédents"
    var verrouillee: Bool = false
    var apercu: String {
        let lignes = corps.split(separator: "\n").map(String.init)
        return lignes.first ?? ""
    }
}

final class MagasinNotes: ObservableObject {
    static let partage = MagasinNotes()
    @Published var notes: [NoteItem] = [
        // Épinglées
        NoteItem(titre: "Documents pour lundi",
                 corps: "Pièce d'identité (photographiée ✓)\nRIB (capture ✓)\nJustificatif de domicile\nRelevés des 3 derniers mois\n\nDemander augmentation du plafond → 5 000 €\nRDV 11h30 — Agence Bellecour\nDire que c'est pour des travaux ??",
                 dateTexte: "22:47", section: "Épinglées"),
        NoteItem(titre: "Exercices épaule S32",
                 corps: "2 séries chaque matin :\nRotations externes élastique x15\nPendulaire 1 min\nÉtirement porte 30 s\nGlace si douleur le soir",
                 dateTexte: "05/08/2026", section: "Épinglées"),
        // Aujourd'hui
        NoteItem(titre: "Perso 🔒",
                 corps: "", dateTexte: "19:12", section: "Aujourd'hui", verrouillee: true),
        // 7 jours précédents
        NoteItem(titre: "Idées week-end Marseille",
                 corps: "Hôtel près du Vieux-Port ?\nRestaurant « Chez Fonfon » (il adore le poisson)\nRobe bleue + créoles\nPrévoir crème solaire\n⚓️ Le 28 !!!",
                 dateTexte: "mercredi", section: "7 jours précédents"),
        NoteItem(titre: "Recette gratin de mamie",
                 corps: "Courgettes + pommes de terre fines\nCrème entière OBLIGATOIRE (maman insiste)\nMuscade, pas trop\nComté râpé au-dessus\n45 min à 180°",
                 dateTexte: "jeudi", section: "7 jours précédents"),
        // 30 jours précédents
        NoteItem(titre: "Questions kiné",
                 corps: "Encore mal en fin de journée, normal ?\nCombien de semaines encore ?\nPiscine autorisée ?",
                 dateTexte: "22/07/2026", section: "30 jours précédents"),
        NoteItem(titre: "Livres à lire",
                 corps: "Le vieil homme et la mer (recommandé par M. ❤️)\nLa vague — Todd Strasser\nRelire Rebecca",
                 dateTexte: "12/07/2026", section: "30 jours précédents"),
        NoteItem(titre: "Objectifs 2026",
                 corps: "Reprendre la photo sérieusement\nCourir un 10 km\nMoins de téléphone le soir 😅\nRencontrer quelqu'un de bien ✓",
                 dateTexte: "02/01/2026", section: "30 jours précédents"),
    ]
    func nouvelle() -> NoteItem {
        let n = NoteItem(titre: "", corps: "", dateTexte: "22:47", section: "Aujourd'hui")
        notes.insert(n, at: 2)
        return n
    }
}

// ============================================================ APP
struct NotesVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinNotes.partage
    @State private var recherche = ""
    @State private var rechercheActive = false
    @State private var noteOuverte: NoteItem? = nil
    @State private var codeDemande = false

    private let ordreSections = ["Épinglées", "Aujourd'hui", "7 jours précédents", "30 jours précédents"]

    private var filtrees: [NoteItem] {
        guard !recherche.isEmpty else { return magasin.notes }
        return magasin.notes.filter {
            $0.titre.localizedCaseInsensitiveContains(recherche) ||
            $0.corps.localizedCaseInsensitiveContains(recherche)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("iCloud (toutes)").font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                            Text("\(magasin.notes.count) notes").font(.system(size: 13)).foregroundStyle(.secondary)
                        }
                        .padding(.top, 6)

                        ForEach(ordreSections, id: \.self) { section in
                            let items = filtrees.filter { $0.section == section }
                            if !items.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 4) {
                                        Text(section).font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                        if section == "Épinglées" {
                                            Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                                        }
                                    }
                                    VStack(spacing: 1) {
                                        ForEach(items) { n in
                                            Button {
                                                if n.verrouillee { codeDemande = true } else { noteOuverte = n }
                                            } label: {
                                                VStack(alignment: .leading, spacing: 3) {
                                                    HStack(spacing: 6) {
                                                        Text(n.titre.isEmpty ? "Nouvelle note" : n.titre)
                                                            .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                                                        if n.verrouillee {
                                                            Image(systemName: "lock.fill").font(.system(size: 12)).foregroundStyle(.secondary)
                                                        }
                                                    }
                                                    HStack(spacing: 8) {
                                                        Text(n.dateTexte).font(.system(size: 14)).foregroundStyle(.secondary)
                                                        Text(n.verrouillee ? "Note verrouillée" : n.apercu)
                                                            .font(.system(size: 14)).foregroundStyle(.secondary).lineLimit(1)
                                                    }
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "folder").font(.system(size: 11))
                                                        Text("Notes").font(.system(size: 12.5))
                                                    }
                                                    .foregroundStyle(.secondary).padding(.top, 1)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 16).padding(.vertical, 10)
                                                .background(Color(hex: 0x1C1C1E))
                                            }
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        if !recherche.isEmpty && filtrees.isEmpty {
                            Text("Aucun résultat").font(.system(size: 15)).foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity).padding(.top, 60)
                        }
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 16)
                }

                // Barre basse : recherche + composition (comme la référence)
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Recherche", text: $recherche)
                            .foregroundStyle(.white)
                        if !recherche.isEmpty {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                                .onTapGesture { recherche = "" }
                        } else {
                            Image(systemName: "mic.fill").foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 14).frame(height: 42)
                    .background(Color(hex: 0x1C1C1E), in: Capsule())
                    Button {
                        noteOuverte = magasin.nouvelle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 19)).foregroundStyle(Color(hex: 0xE8A33D))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: 0x1C1C1E), in: Circle())
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 8)

            BarreHome { dismiss() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                        Text("Dossiers").font(.system(size: 17))
                    }
                    .foregroundStyle(Color(hex: 0xE8A33D))
                    .onTapGesture { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { } label: { Label("Afficher les pièces jointes", systemImage: "paperclip") }
                        Button { } label: { Label("Sélectionner des notes", systemImage: "checkmark.circle") }
                        Button { } label: { Label("Afficher en galerie", systemImage: "square.grid.2x2") }
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundStyle(Color(hex: 0xE8A33D))
                    }
                }
            }
            .navigationDestination(item: $noteOuverte) { n in
                NoteEditionVue(noteId: n.id)
            }
            // D57 : porte fermée visible — la note verrouillée demande le code
            .alert("Note verrouillée", isPresented: $codeDemande) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Saisissez le code de l'iPhone pour afficher cette note.")
            }
        }
        .tint(Color(hex: 0xE8A33D))
        .preferredColorScheme(.dark)
    }
}

// NoteItem doit être Hashable pour navigationDestination(item:)
extension NoteItem: Hashable {
    static func == (a: NoteItem, b: NoteItem) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// ============================================================ ÉDITION (persistante — D51)
struct NoteEditionVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinNotes.partage
    let noteId: UUID
    @State private var texte = ""
    @State private var alerteOutil: String? = nil

    private var index: Int? { magasin.notes.firstIndex { $0.id == noteId } }

    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $texte)
                .font(.system(size: 17))
                .foregroundStyle(.white)
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .padding(.horizontal, 10)
                .onAppear {
                    if let i = index {
                        let n = magasin.notes[i]
                        texte = n.titre.isEmpty ? "" : n.titre + "\n" + n.corps
                    }
                }
                .onChange(of: texte) { _, t in
                    guard let i = index else { return }
                    let lignes = t.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false).map(String.init)
                    magasin.notes[i].titre = lignes.first ?? ""
                    magasin.notes[i].corps = lignes.count > 1 ? lignes[1] : ""
                }

            // Barre d'outils basse (icônes de la référence — réponses catalogue)
            HStack(spacing: 30) {
                ForEach(["textformat", "checklist", "tablecells", "paperclip", "pencil.tip.crop.circle"], id: \.self) { s in
                    Image(systemName: s)
                        .font(.system(size: 19)).foregroundStyle(Color(hex: 0xE8A33D))
                        .onTapGesture { alerteOutil = s }
                }
                Spacer()
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 19)).foregroundStyle(Color(hex: 0xE8A33D))
                    .onTapGesture { dismiss() }
            }
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(Color(hex: 0x111111))
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 18) {
                    Image(systemName: "square.and.arrow.up").foregroundStyle(Color(hex: 0xE8A33D))
                        .onTapGesture { alerteOutil = "partage" }
                    Image(systemName: "ellipsis.circle").foregroundStyle(Color(hex: 0xE8A33D))
                        .onTapGesture { alerteOutil = "menu" }
                }
            }
        }
        .alert(titreOutil, isPresented: Binding(get: { alerteOutil != nil }, set: { if !$0 { alerteOutil = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(messageOutil)
        }
        .tint(Color(hex: 0xE8A33D))
        .preferredColorScheme(.dark)
    }

    private var titreOutil: String {
        switch alerteOutil {
        case "partage": return "Partager"
        case "menu": return "Options"
        default: return "Mise en forme"
        }
    }
    private var messageOutil: String {
        switch alerteOutil {
        case "partage": return ErreurLambda.reponse("partage")
        case "checklist": return "Terminez la ligne en cours pour créer une liste de pointage."
        default: return "La mise en forme avancée arrive avec la synchronisation iCloud."
        }
    }
}
