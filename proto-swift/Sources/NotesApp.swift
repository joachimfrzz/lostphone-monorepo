// Notes — construite contre la vidéo de référence du 18/08 (26 écrans, iOS 26) + XML S5 (29/08).
// D59 : données remplaçables. R3 : contient la note « Documents pour lundi » de la capture P60.
// D51 : utilisable de A à Z (création, édition persistante, recherche réelle, épinglage).
// v2 session 2 (02/09, retours Joachim) : niveau DOSSIERS racine (le retour ne quitte plus l'app),
// teinte = JAUNE système Notes (plus l'ambre), titres de notes en GRAS (première ligne = titre),
// micro retiré, menu … RÉEL (pièces jointes, sélection, galerie), barres remontées au-dessus de la capsule home.
// v3 (02/09 soir, vidéo ScreenRecording 18-47 de la vraie app Notes iOS 26 sombre) :
// JAUNE MESURÉ AU PIXEL = 0xDEA40B, et il ne colore QUE les icônes de dossier, le chevron de section et les liens.
// Tous les boutons (retour, Partager, …, Modifier, nouveau dossier, barre d'outils d'édition, composer) sont BLANCS
// sur capsule/cercle sombre (verre iOS 26). Racine Dossiers : recherche EN BAS, nouveau dossier + Modifier EN HAUT.
import SwiftUI

// Jaune Notes iOS 26 mode sombre — mesuré sur la vidéo de Joachim (02/09) : 0xDEA40B (remplace 0xFFD60A)
let notesJaune = Color(hex: 0xDEA40B)
let notesFondCellule = Color(hex: 0x1C1C1E)
// Fond des boutons « verre » (capsules et cercles de la barre de navigation / barre basse)
let notesFondVerre = Color(hex: 0x2A2A2C)

// Bouton rond « verre » iOS 26 : icône BLANCHE sur cercle sombre (retour, Partager, …, nouveau dossier, composer)
struct BoutonVerreNotes: View {
    let systeme: String
    var taille: CGFloat = 17
    var poids: Font.Weight = .semibold
    var diametre: CGFloat = 40
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systeme).font(.system(size: taille, weight: poids)).foregroundStyle(.white)
                .frame(width: diametre, height: diametre)
                .background(notesFondVerre, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

// Capsule « verre » texte (Modifier / OK / Terminé) : texte BLANC
struct CapsuleVerreNotes: View {
    let titre: String
    var poids: Font.Weight = .regular
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(titre).font(.system(size: 17, weight: poids)).foregroundStyle(.white)
                .padding(.horizontal, 16).frame(height: 40)
                .background(notesFondVerre, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================ DONNÉES (remplaçables — D59)
struct NoteItem: Identifiable {
    let id = UUID()
    var titre: String
    var corps: String
    var dateTexte: String       // "22:47", "hier", "11/08/2026"
    var section: String         // "Épinglées", "Aujourd'hui", "7 jours précédents", "30 jours précédents"
    var dossier: String = "Notes"
    var verrouillee: Bool = false
    var apercu: String {
        let lignes = corps.split(separator: "\n").map(String.init)
        return lignes.first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) ?? ""
    }
}

struct DossierNotes: Identifiable, Hashable {
    let id: String          // nom = identifiant
    var nom: String { id }
    var icone: String
    var toutes: Bool = false
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
                 dateTexte: "05/08/2026", section: "Épinglées", dossier: "Santé"),
        // Aujourd'hui
        NoteItem(titre: "Perso 🔒",
                 corps: "", dateTexte: "19:12", section: "Aujourd'hui", verrouillee: true),
        // 7 jours précédents
        NoteItem(titre: "Idées week-end Marseille",
                 corps: "Hôtel près du Vieux-Port ?\nRestaurant « Chez Fonfon » (il adore le poisson)\nRobe bleue + créoles\nPrévoir crème solaire\n⚓️ Le 28 !!!",
                 dateTexte: "mercredi", section: "7 jours précédents"),
        NoteItem(titre: "Recette gratin de mamie",
                 corps: "Courgettes + pommes de terre fines\nCrème entière OBLIGATOIRE (maman insiste)\nMuscade, pas trop\nComté râpé au-dessus\n45 min à 180°",
                 dateTexte: "jeudi", section: "7 jours précédents", dossier: "Recettes"),
        // 30 jours précédents
        NoteItem(titre: "Questions kiné",
                 corps: "Encore mal en fin de journée, normal ?\nCombien de semaines encore ?\nPiscine autorisée ?",
                 dateTexte: "22/07/2026", section: "30 jours précédents", dossier: "Santé"),
        NoteItem(titre: "Livres à lire",
                 corps: "Le vieil homme et la mer (recommandé par M. ❤️)\nLa vague — Todd Strasser\nRelire Rebecca",
                 dateTexte: "12/07/2026", section: "30 jours précédents"),
        NoteItem(titre: "Objectifs 2026",
                 corps: "Reprendre la photo sérieusement\nCourir un 10 km\nMoins de téléphone le soir 😅\nRencontrer quelqu'un de bien ✓",
                 dateTexte: "02/01/2026", section: "30 jours précédents"),
    ]
    @Published var supprimees: [NoteItem] = []

    @Published var dossiers: [DossierNotes] = [
        DossierNotes(id: "iCloud (toutes)", icone: "folder", toutes: true),
        DossierNotes(id: "Notes", icone: "folder"),
        DossierNotes(id: "Recettes", icone: "folder"),
        DossierNotes(id: "Santé", icone: "folder"),
    ]
    // v2 02/09 : Modifier réel — supprimer / renommer / créer un dossier
    func supprimerDossier(_ nom: String) {
        guard nom != "Notes" else { return }
        dossiers.removeAll { $0.nom == nom }
        for i in notes.indices where notes[i].dossier == nom { notes[i].dossier = "Notes" }
    }
    func renommerDossier(_ nom: String, en nouveau: String) {
        let n = nouveau.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty, let i = dossiers.firstIndex(where: { $0.nom == nom }), !dossiers.contains(where: { $0.nom == n }) else { return }
        dossiers[i] = DossierNotes(id: n, icone: dossiers[i].icone)
        for k in notes.indices where notes[k].dossier == nom { notes[k].dossier = n }
    }
    func ajouterDossier(_ nom: String) {
        let n = nom.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty, !dossiers.contains(where: { $0.nom == n }) else { return }
        dossiers.append(DossierNotes(id: n, icone: "folder"))
    }

    func compte(_ d: DossierNotes) -> Int {
        d.toutes ? notes.count : notes.filter { $0.dossier == d.nom }.count
    }
    func nouvelle(dossier: String = "Notes") -> NoteItem {
        let n = NoteItem(titre: "", corps: "", dateTexte: "22:47", section: "Aujourd'hui", dossier: dossier)
        notes.insert(n, at: notes.filter { $0.section == "Épinglées" }.count)
        return n
    }
    func supprimer(_ ids: Set<UUID>) {
        let retirees = notes.filter { ids.contains($0.id) }
        supprimees.append(contentsOf: retirees)
        notes.removeAll { ids.contains($0.id) }
    }
}

// NoteItem doit être Hashable pour navigationDestination(item:)
extension NoteItem: Hashable {
    static func == (a: NoteItem, b: NoteItem) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// ============================================================ APP — racine = DOSSIERS (v2 : niveau manquant rétabli)
struct NotesVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinNotes.partage
    @State private var chemin = NavigationPath()   // dossiers ET notes (un seul type de destination par pile)
    @State private var recherche = ""
    @State private var nouveauDossierVisible = false
    @State private var nomNouveauDossier = ""
    @State private var edition = false                 // v2 02/09 : Modifier RÉEL (dossiers)
    @State private var dossierARenommer: DossierNotes? = nil
    @State private var nomRenommage = ""
    @FocusState private var rechercheFocalisee: Bool

    var body: some View {
        NavigationStack(path: $chemin) {
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Dossiers").font(.system(size: 34, weight: .bold)).foregroundStyle(.white)
                            .padding(.top, 4)

                        if recherche.isEmpty {
                            // v3 : en-tête de section « iCloud » + chevron JAUNE (comme la vraie app)
                            HStack {
                                Text("iCloud").font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.down").font(.system(size: 13, weight: .semibold)).foregroundStyle(notesJaune)
                            }
                            .padding(.top, 6).padding(.trailing, 6)
                            VStack(spacing: 0) {
                                ForEach(Array(magasin.dossiers.enumerated()), id: \.element.id) { i, d in
                                    Button {
                                        if edition { if !d.toutes { dossierARenommer = d; nomRenommage = d.nom } }
                                        else { rechercheFocalisee = false; chemin.append(d) }
                                    } label: {
                                        HStack(spacing: 12) {
                                            if edition && !d.toutes {
                                                // v2 02/09 : mode Modifier réel — pastille de suppression (le dossier part, ses notes restent dans « Notes »)
                                                Image(systemName: "minus.circle.fill").font(.system(size: 22)).foregroundStyle(Color(hex: 0xFF453A))
                                                    .onTapGesture { withAnimation { magasin.supprimerDossier(d.nom) } }
                                            }
                                            // v3 : SEUL élément jaune de la rangée = l'icône de dossier (mesuré 0xDEA40B)
                                            Image(systemName: d.icone).font(.system(size: 18)).foregroundStyle(notesJaune).frame(width: 28)
                                            Text(d.nom).font(.system(size: 17)).foregroundStyle(.white)
                                            Spacer()
                                            Text("\(magasin.compte(d))").font(.system(size: 17)).foregroundStyle(.secondary)
                                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary.opacity(0.6))
                                        }
                                        .padding(.horizontal, 16).padding(.vertical, 12)
                                    }
                                    if i < magasin.dossiers.count - 1 { Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 56) }
                                }
                                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 56)
                                HStack(spacing: 12) {
                                    Image(systemName: "trash").font(.system(size: 18)).foregroundStyle(notesJaune).frame(width: 28)
                                    Text("Suppressions récentes").font(.system(size: 17)).foregroundStyle(.white)
                                    Spacer()
                                    Text("\(magasin.supprimees.count)").font(.system(size: 17)).foregroundStyle(.secondary)
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary.opacity(0.6))
                                }
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .contentShape(Rectangle())
                                .onTapGesture { chemin.append(DossierNotes(id: "Suppressions récentes", icone: "trash")) }
                            }
                            .background(notesFondCellule, in: RoundedRectangle(cornerRadius: 12))
                        } else {
                            // Recherche globale réelle depuis la racine
                            ResultatsRechercheNotes(recherche: recherche) { n in chemin.append(n) }
                        }
                        Spacer(minLength: 110)
                    }
                    .padding(.horizontal, 16)
                }

                // v3 : barre basse = RECHERCHE en capsule (comme la vraie racine Dossiers) — SANS micro (règle Joachim)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Recherche", text: $recherche).foregroundStyle(.white)
                        .focused($rechercheFocalisee)
                        .submitLabel(.search)
                    if !recherche.isEmpty {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            .onTapGesture { recherche = ""; rechercheFocalisee = false }
                    }
                }
                .padding(.horizontal, 14).frame(height: 44)
                .background(notesFondVerre, in: Capsule())
                .padding(.horizontal, 16).padding(.bottom, 26)

                BarreHome { dismiss() }
            }
            .toolbar {
                // v3 : nouveau dossier (cercle) + Modifier (capsule), BLANCS — comme la vraie app
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 10) {
                        BoutonVerreNotes(systeme: "folder.badge.plus", taille: 16) { nouveauDossierVisible = true }
                        CapsuleVerreNotes(titre: edition ? "OK" : "Modifier", poids: edition ? .semibold : .regular) {
                            withAnimation { edition.toggle() }
                        }
                    }
                }
            }
            .alert("Renommer le dossier", isPresented: Binding(get: { dossierARenommer != nil }, set: { if !$0 { dossierARenommer = nil } })) {
                TextField("Nom", text: $nomRenommage)
                Button("Annuler", role: .cancel) {}
                Button("OK") { if let d = dossierARenommer { magasin.renommerDossier(d.nom, en: nomRenommage) } }
            }
            // v2 02/09 : un tap hors du champ masque le clavier (comportement naturel)
            .simultaneousGesture(TapGesture().onEnded { rechercheFocalisee = false })
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(for: DossierNotes.self) { d in
                if d.nom == "Suppressions récentes" {
                    SuppressionsRecentesNotesVue()
                } else {
                    NotesListeVue(dossier: d) { n in chemin.append(n) }
                }
            }
            .navigationDestination(for: NoteItem.self) { n in
                NoteEditionVue(noteId: n.id)
            }
            .alert("Nouveau dossier", isPresented: $nouveauDossierVisible) {
                TextField("Nom", text: $nomNouveauDossier)
                Button("Enregistrer") { magasin.ajouterDossier(nomNouveauDossier); nomNouveauDossier = "" }
                Button("Annuler", role: .cancel) { nomNouveauDossier = "" }
            }
        }
        .tint(notesJaune)
        .preferredColorScheme(.dark)
    }
}

// ============================================================ LISTE D'UN DOSSIER (ex-racine)
struct NotesListeVue: View {
    let dossier: DossierNotes
    let ouvrir: (NoteItem) -> Void
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinNotes.partage
    @State private var recherche = ""
    @State private var codeDemande = false
    // v2 : menu … réel
    @State private var modeSelection = false
    @State private var selection = Set<UUID>()
    @State private var galerie = false
    @State private var piecesJointesVisibles = false
    @FocusState private var rechercheFocalisee: Bool

    private let ordreSections = ["Épinglées", "Aujourd'hui", "7 jours précédents", "30 jours précédents"]

    private var duDossier: [NoteItem] {
        dossier.toutes ? magasin.notes : magasin.notes.filter { $0.dossier == dossier.nom }
    }
    private var filtrees: [NoteItem] {
        guard !recherche.isEmpty else { return duDossier }
        return duDossier.filter {
            $0.titre.localizedCaseInsensitiveContains(recherche) ||
            $0.corps.localizedCaseInsensitiveContains(recherche)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dossier.nom).font(.system(size: 34, weight: .bold)).foregroundStyle(.white)
                        // v3 : sous-titre « N notes » comme la vraie app
                        Text("\(duDossier.count) note\(duDossier.count > 1 ? "s" : "")").font(.system(size: 15)).foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)

                    ForEach(ordreSections, id: \.self) { section in
                        let items = filtrees.filter { $0.section == section }
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 4) {
                                    Text(section).font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                    Spacer()
                                    if section == "Épinglées" {
                                        Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundStyle(notesJaune)
                                    }
                                }
                                if galerie {
                                    // v2 : « Afficher en galerie » = vraies cartes 2 colonnes
                                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                                        ForEach(items) { n in
                                            carteGalerie(n)
                                        }
                                    }
                                } else {
                                    VStack(spacing: 1) {
                                        ForEach(items) { n in rangee(n) }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                    if !recherche.isEmpty && filtrees.isEmpty {
                        Text("Aucun résultat").font(.system(size: 15)).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity).padding(.top, 60)
                    }
                    Spacer(minLength: 110)
                }
                .padding(.horizontal, 16)
            }

            // Barre basse (v2 : SANS micro, REMONTÉE au-dessus de la capsule home)
            if modeSelection {
                HStack {
                    Button("Déplacer") { Haptique.leger() }
                        .foregroundStyle(selection.isEmpty ? .secondary : .white).disabled(selection.isEmpty)
                    Spacer()
                    Text(selection.isEmpty ? "Sélectionner des notes" : "\(selection.count) sélectionnée\(selection.count > 1 ? "s" : "")")
                        .font(.system(size: 15)).foregroundStyle(.white)
                    Spacer()
                    Button("Supprimer") {
                        withAnimation { magasin.supprimer(selection) }
                        selection.removeAll(); modeSelection = false
                    }
                    .foregroundStyle(selection.isEmpty ? .secondary : Color(hex: 0xFF453A)).disabled(selection.isEmpty)
                }
                .font(.system(size: 17))
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .padding(.bottom, 26)
            } else {
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Recherche", text: $recherche)
                            .foregroundStyle(.white)
                            .focused($rechercheFocalisee)
                            .submitLabel(.search)
                        if !recherche.isEmpty {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                                .onTapGesture { recherche = ""; rechercheFocalisee = false }
                        }
                    }
                    .padding(.horizontal, 14).frame(height: 44)
                    .background(notesFondVerre, in: Capsule())
                    // v3 : composer = icône BLANCHE sur cercle sombre (plus de jaune)
                    BoutonVerreNotes(systeme: "square.and.pencil", taille: 18, poids: .regular, diametre: 44) {
                        ouvrir(magasin.nouvelle(dossier: dossier.toutes ? "Notes" : dossier.nom))
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 26)
            }

            BarreHome { dismiss() }   // capsule = retour ACCUEIL ; le chevron = navigation interne
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                // v3 : retour iOS 26 = chevron BLANC seul dans un cercle sombre (plus de texte « Dossiers », plus de jaune) ; reste DANS Notes
                BoutonVerreNotes(systeme: "chevron.left") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if modeSelection {
                    CapsuleVerreNotes(titre: "Terminé", poids: .semibold) { modeSelection = false; selection.removeAll() }
                } else {
                    Menu {
                        // v2 : les 3 entrées font quelque chose de RÉEL
                        Button { piecesJointesVisibles = true } label: { Label("Afficher les pièces jointes", systemImage: "paperclip") }
                        Button { modeSelection = true } label: { Label("Sélectionner des notes", systemImage: "checkmark.circle") }
                        Button { withAnimation(.easeInOut(duration: 0.2)) { galerie.toggle() } } label: {
                            Label(galerie ? "Afficher en liste" : "Afficher en galerie", systemImage: galerie ? "list.bullet" : "square.grid.2x2")
                        }
                    } label: {
                        Image(systemName: "ellipsis").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(notesFondVerre, in: Circle())
                    }
                }
            }
        }
        .sheet(isPresented: $piecesJointesVisibles) { PiecesJointesNotesVue(dossier: dossier.nom) }
        .simultaneousGesture(TapGesture().onEnded { rechercheFocalisee = false })   // v2 02/09 : tap ailleurs = clavier masqué
        .scrollDismissesKeyboard(.interactively)
        // D57 : porte fermée visible — la note verrouillée demande le code
        .alert("Note verrouillée", isPresented: $codeDemande) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Saisissez le code de l'iPhone pour afficher cette note.")
        }
        .tint(notesJaune)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder private func rangee(_ n: NoteItem) -> some View {
        Button {
            if modeSelection {
                if selection.contains(n.id) { selection.remove(n.id) } else { selection.insert(n.id) }
            } else if n.verrouillee { codeDemande = true } else { ouvrir(n) }
        } label: {
            HStack(spacing: 12) {
                if modeSelection {
                    Image(systemName: selection.contains(n.id) ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22)).foregroundStyle(selection.contains(n.id) ? notesJaune : .secondary)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        // v2 : titre en GRAS (comme Notes)
                        Text(n.titre.isEmpty ? "Nouvelle note" : n.titre)
                            .font(.system(size: 17, weight: .bold)).foregroundStyle(.white).lineLimit(1)
                        if n.verrouillee {
                            Image(systemName: "lock.fill").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                    }
                    HStack(spacing: 8) {
                        Text(n.dateTexte).font(.system(size: 15)).foregroundStyle(.secondary)
                        Text(n.verrouillee ? "Note verrouillée" : (n.apercu.isEmpty ? "Aucun texte supplémentaire" : n.apercu))
                            .font(.system(size: 15)).foregroundStyle(.secondary).lineLimit(1)
                    }
                    if dossier.toutes {
                        HStack(spacing: 4) {
                            Image(systemName: "folder").font(.system(size: 11))
                            Text(n.dossier).font(.system(size: 13))
                        }
                        .foregroundStyle(.secondary).padding(.top, 1)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16).padding(.vertical, 11)
            .background(notesFondCellule)
        }
    }

    @ViewBuilder private func carteGalerie(_ n: NoteItem) -> some View {
        Button {
            if n.verrouillee { codeDemande = true } else { ouvrir(n) }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10).fill(Color(hex: 0x2C2C2E))
                    if n.verrouillee {
                        Image(systemName: "lock.fill").font(.system(size: 26)).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Text(n.corps).font(.system(size: 9)).foregroundStyle(.white.opacity(0.8))
                            .padding(8).lineLimit(9)
                    }
                }
                .frame(height: 118)
                Text(n.titre.isEmpty ? "Nouvelle note" : n.titre).font(.system(size: 14, weight: .bold)).foregroundStyle(.white).lineLimit(1)
                Text(n.dateTexte).font(.system(size: 12)).foregroundStyle(.secondary)
            }
        }
    }
}

// Recherche depuis la racine Dossiers
struct ResultatsRechercheNotes: View {
    let recherche: String
    let ouvrir: (NoteItem) -> Void
    @ObservedObject private var magasin = MagasinNotes.partage
    private var resultats: [NoteItem] {
        magasin.notes.filter { !$0.verrouillee && ($0.titre.localizedCaseInsensitiveContains(recherche) || $0.corps.localizedCaseInsensitiveContains(recherche)) }
    }
    var body: some View {
        if resultats.isEmpty {
            Text("Aucun résultat pour « \(recherche) »").font(.system(size: 15)).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity).padding(.top, 60)
        } else {
            VStack(spacing: 1) {
                ForEach(resultats) { n in
                    Button { ouvrir(n) } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(n.titre).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                            HStack(spacing: 8) {
                                Text(n.dateTexte).font(.system(size: 15)).foregroundStyle(.secondary)
                                Text(n.apercu).font(.system(size: 15)).foregroundStyle(.secondary).lineLimit(1)
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "folder").font(.system(size: 11)); Text(n.dossier).font(.system(size: 13))
                            }.foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.vertical, 11)
                        .background(notesFondCellule)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// ============================================================ PIÈCES JOINTES (réel : état iOS « Aucune pièce jointe »)
struct PiecesJointesNotesVue: View {
    let dossier: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 10) {
                    Image(systemName: "paperclip").font(.system(size: 40)).foregroundStyle(.secondary)
                    Text("Aucune pièce jointe").font(.system(size: 20, weight: .semibold)).foregroundStyle(.white)
                    Text("Les photos, scans, dessins et liens ajoutés à vos notes apparaîtront ici.")
                        .font(.system(size: 14)).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            .navigationTitle("Pièces jointes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("OK") { dismiss() }.foregroundStyle(.white) } }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ SUPPRESSIONS RÉCENTES (réel : récupérer)
struct SuppressionsRecentesNotesVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinNotes.partage
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Suppressions récentes").font(.system(size: 34, weight: .bold)).foregroundStyle(.white)
                    Text("Les notes sont conservées 30 jours avant d'être définitivement supprimées.")
                        .font(.system(size: 13)).foregroundStyle(.secondary)
                    if magasin.supprimees.isEmpty {
                        Text("Aucune note").font(.system(size: 15)).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity).padding(.top, 60)
                    } else {
                        VStack(spacing: 1) {
                            ForEach(magasin.supprimees) { n in
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(n.titre.isEmpty ? "Nouvelle note" : n.titre).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                                        Text(n.dateTexte).font(.system(size: 15)).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Button("Récupérer") {
                                        withAnimation {
                                            magasin.supprimees.removeAll { $0.id == n.id }
                                            magasin.notes.insert(n, at: 0)
                                        }
                                    }
                                    .font(.system(size: 15)).foregroundStyle(notesJaune)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 11)
                                .background(notesFondCellule)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
            }
            BarreHome { }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                // v3 : retour = cercle verre, chevron blanc
                BoutonVerreNotes(systeme: "chevron.left") { dismiss() }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ ÉDITION (persistante — D51)
// v2 : première ligne = TITRE en gras 28 pt (comme Notes), date centrée en tête, « Terminé » pendant la saisie.
// v3 : barre d'outils basse = capsule verre à 4 icônes BLANCHES (liste, trombone, A, marquage) + composer en cercle séparé ;
// retour / Partager / … = cercles verre blancs. Le jaune ne sert plus qu'aux liens (aucun ici).
struct NoteEditionVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinNotes.partage
    let noteId: UUID
    @State private var titre = ""
    @State private var corps = ""
    @State private var alerteOutil: String? = nil
    @State private var partageVisible = false
    @State private var confirmerSuppression = false
    @FocusState private var champ: Champ?
    enum Champ { case titre, corps }

    private var index: Int? { magasin.notes.firstIndex { $0.id == noteId } }
    private var epinglee: Bool { index.map { magasin.notes[$0].section == "Épinglées" } ?? false }
    private var dateEntete: String {
        guard let i = index else { return "" }
        let d = magasin.notes[i].dateTexte
        return d.contains(":") ? "17 août 2026 à \(d)" : d
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    Text(dateEntete).font(.system(size: 12)).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity).padding(.top, 6)
                    TextField("Titre", text: $titre, axis: .vertical)
                        .font(.system(size: 28, weight: .bold)).foregroundStyle(.white)
                        .focused($champ, equals: .titre)
                        .onSubmit { champ = .corps }
                    TextEditor(text: $corps)
                        .font(.system(size: 17)).foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color.black)
                        .frame(minHeight: 420)
                        .focused($champ, equals: .corps)
                        .padding(.horizontal, -5)
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                if let i = index {
                    titre = magasin.notes[i].titre
                    corps = magasin.notes[i].corps
                    if titre.isEmpty && corps.isEmpty { champ = .titre }
                }
            }
            .onChange(of: titre) { _, t in
                guard let i = index else { return }
                magasin.notes[i].titre = t.replacingOccurrences(of: "\n", with: " ")
            }
            .onChange(of: corps) { _, c in
                guard let i = index else { return }
                magasin.notes[i].corps = c
            }

            // v3 : barre d'outils basse iOS 26 — capsule verre 4 icônes blanches + composer séparé (ordre de la vraie app)
            HStack(spacing: 12) {
                HStack(spacing: 0) {
                    ForEach(["checklist", "paperclip", "textformat.alt", "pencil.tip.crop.circle"], id: \.self) { s in
                        Image(systemName: s)
                            .font(.system(size: 19)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).frame(height: 48)
                            .contentShape(Rectangle())
                            .onTapGesture { alerteOutil = s }
                    }
                }
                .padding(.horizontal, 6)
                .background(notesFondVerre, in: Capsule())
                BoutonVerreNotes(systeme: "square.and.pencil", taille: 18, poids: .regular, diametre: 48) { dismiss() }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)
            .background(Color.black)
        }
        .background(Color.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BoutonVerreNotes(systeme: "chevron.left") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 10) {
                    if champ != nil {
                        CapsuleVerreNotes(titre: "Terminé", poids: .semibold) { champ = nil }
                    } else {
                        BoutonVerreNotes(systeme: "square.and.arrow.up", taille: 16) { partageVisible = true }
                        Menu {
                            Button {
                                guard let i = index else { return }
                                magasin.notes[i].section = epinglee ? "Aujourd'hui" : "Épinglées"
                                Haptique.leger()
                            } label: {
                                Label(epinglee ? "Désépingler" : "Épingler", systemImage: epinglee ? "pin.slash" : "pin")
                            }
                            Button { partageVisible = true } label: { Label("Partager", systemImage: "square.and.arrow.up") }
                            Button(role: .destructive) { confirmerSuppression = true } label: { Label("Supprimer", systemImage: "trash") }
                        } label: {
                            Image(systemName: "ellipsis").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(notesFondVerre, in: Circle())
                        }
                    }
                }
            }
        }
        .alert("Supprimer la note ?", isPresented: $confirmerSuppression) {
            Button("Supprimer", role: .destructive) {
                magasin.supprimer([noteId])
                dismiss()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("La note sera déplacée dans Suppressions récentes.")
        }
        .alert(titreOutil, isPresented: Binding(get: { alerteOutil != nil }, set: { if !$0 { alerteOutil = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(messageOutil)
        }
        .sheet(isPresented: $partageVisible) { FeuillePartage(element: (index.map { magasin.notes[$0].titre } ?? "Note"), contenu: (index.map { magasin.notes[$0].titre + "\n" + magasin.notes[$0].corps } ?? ""), type: .note) }
        .tint(notesJaune)
        .preferredColorScheme(.dark)
    }

    private var titreOutil: String {
        switch alerteOutil {
        case "checklist": return "Liste de pointage"
        default: return "Mise en forme"
        }
    }
    private var messageOutil: String {
        switch alerteOutil {
        case "checklist": return "Terminez la ligne en cours pour créer une liste de pointage."
        default: return "La mise en forme avancée arrive avec la synchronisation iCloud."
        }
    }
}
