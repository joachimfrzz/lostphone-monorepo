// Rappels — refonte D95 (12/11/2026) contre la référence iOS 26 (simulateur iPhone 17, français, mode sombre).
// Mesures prises sur ref-com.apple.reminders (1206×2622 px = 402×874 pt) avec outils/mesure.py :
//   accueil : barre haute 44 pt à y=62, tuiles 181×80 pt (rayon 17, espace 8, marges 16), titre « Mes listes » 20 pt gras,
//             carte de liste 62 pt (#1C1C1E), bouton + 48 pt à 28 pt du bord (#0091FF), capsules de verre #191919.
//   listes  : titre large 34 pt gras teinté (cap. 23,7 pt), en-têtes de section 15 pt (jours) / 21 pt (mois), traits de 2 pt #1C1C1F.
//   feuilles: cartes #2C2C2E sur fond #1C1C1E, marges 20 pt, rangées 52 pt, séparateurs 1 pt #404043.
// Contenu d'exemple (rappels de Sarah, listes) : RappelsDonnees.swift (D59).
import SwiftUI

// ============================================================ MODÈLE
struct Rappel: Identifiable {
    let id = UUID()
    var titre: String
    var sousTexte: String? = nil       // "Demain, 11:15" etc.
    var liste: String                  // nom de la liste
    var urgent: Bool = false
    var drapeau: Bool = false
    var programme: Bool = false
    var aujourdhui: Bool = false
    var termine: Bool = false
    var termineTexte: String? = nil    // "Terminé : 16/08/2026 21:40"
    var jour: Int? = nil               // décalage en jours depuis « aujourd'hui » (sert aux sections de Programmés)
    var note: String = ""
}

struct ListeRappels: Identifiable, Hashable {
    var id: String { nom }
    var nom: String
    var couleur: UInt
    var symbole: String
}

extension Rappel: Hashable {
    static func == (a: Rappel, b: Rappel) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum RapLibelle {
    static let aujourdhui = "Aujourd’hui"
    static let programmes = "Programmés"
    static let tous = "Tous"
    static let termines = "Terminés"
    static let moments = ["Matin", "Après-midi", "Soir"]
}

// Les quatre tuiles de l'accueil (la référence n'en affiche que quatre).
enum RapTuile: String, CaseIterable {
    case aujourdhui, programmes, tous, termines

    var titre: String {
        switch self {
        case .aujourdhui: return RapLibelle.aujourdhui
        case .programmes: return RapLibelle.programmes
        case .tous: return RapLibelle.tous
        case .termines: return RapLibelle.termines
        }
    }
    var symbole: String {
        switch self {
        case .aujourdhui: return "calendar"
        case .programmes: return "calendar"
        case .tous: return "tray.fill"
        case .termines: return "checkmark"
        }
    }
    // 001 : dégradé échantillonné en haut / en bas de chaque tuile
    var haut: Color {
        switch self {
        case .aujourdhui: return Color(hex: 0x6BB3EA)
        case .programmes: return Color(hex: 0xEC898C)
        case .tous: return Color(hex: 0x575757)
        case .termines: return Color(hex: 0x9CA4AA)
        }
    }
    var bas: Color {
        switch self {
        case .aujourdhui: return Color(hex: 0x4B9CE2)
        case .programmes: return Color(hex: 0xE46E70)
        case .tous: return Color(hex: 0x363636)
        case .termines: return Color(hex: 0x7D868C)
        }
    }
    // 005 à 008 : couleur du titre large
    var teinteTitre: Color {
        switch self {
        case .aujourdhui: return Color(hex: 0x0091FF)
        case .programmes: return Color(hex: 0xFF4245)
        case .tous: return Color(hex: 0x636366)
        case .termines: return Color(hex: 0x6F7F88)
        }
    }
}

enum RapTeinte {
    static let fond = Color.black
    static let carte = Color(hex: 0x1C1C1E)         // 001 : carte « Mes listes »
    static let fondFeuille = Color(hex: 0x1C1C1E)   // 044 : fond des feuilles
    static let carteFeuille = Color(hex: 0x2C2C2E)  // 044 : cartes des feuilles
    static let champ = Color(hex: 0x47474C)         // 003 : champ « Nom de la liste »
    static let bleu = Color(hex: 0x0A84FF)
    static let bleuBouton = Color(hex: 0x0091FF)    // 001 : bouton +
    static let rouge = Color(hex: 0xFF453A)
    static let gris = Color(hex: 0x98989F)          // compteurs, valeurs
    static let secondaire = Color(hex: 0x8D8D93)    // sous-titres
    static let discret = Color(hex: 0x464649)       // en-têtes vides, « Aucun rappel »
    static let chevron = Color(hex: 0x5A5A5E)
    static let verre = Color(hex: 0x191919)         // 001 : capsules de la barre haute
    static let ligne = Color(hex: 0x1C1C1F)         // 006 : trait de 2 pt sous les grands en-têtes
    static let ligneFine = Color(hex: 0x141415)     // 006 : trait de 0,33 pt sous les jours
    static let separateur = Color(hex: 0x2A2A2C)    // 008 : trait de 1 pt
    static let separateurFeuille = Color(hex: 0x404043)
    static let anneau = Color(hex: 0x656569)        // 003 : anneau de la couleur choisie
    static let orange = Color(hex: 0xFF9F0A)
}

// ============================================================ DATES (calendrier du jeu, voir DonneesRappels)
struct RapSection: Identifiable {
    let id: String
    let gras: String
    let suite: String
    let grand: Bool
    let debut: Int
    let fin: Int
}

struct RapGroupeTermine: Identifiable {
    let cle: String
    let gras: String
    let suite: String
    let rappels: [Rappel]
    var id: String { cle }
}

struct RapBrouillon {
    var jour: Int? = nil
    var lieu: String? = nil
    var drapeau: Bool = false
}

enum RapFocus: Hashable {
    case nouveau
    case rappel(UUID)
    var estRappel: Bool {
        if case .rappel = self { return true }
        return false
    }
}

enum RapTri { case defaut, titre }

enum RapGenre { case aujourdhui, programmes, tous, termines, liste, autre }

enum RapDates {
    static let calendrier: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "fr_FR")
        return c
    }()
    static let joursCourts = ["Dim.", "Lun.", "Mar.", "Mer.", "Jeu.", "Ven.", "Sam."]
    static let moisCourts = ["janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc."]
    static let moisNoms = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"]

    static var base: Date {
        calendrier.date(from: DateComponents(year: DonneesRappels.annee, month: DonneesRappels.mois, day: DonneesRappels.jour)) ?? Date()
    }
    static let heureParDefaut: Date = {
        RapDates.calendrier.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 9, minute: 0)) ?? Date()
    }()

    static func date(_ decalage: Int) -> Date {
        calendrier.date(byAdding: .day, value: decalage, to: base) ?? base
    }
    static func jourCourt(_ d: Date) -> String {
        joursCourts[calendrier.component(.weekday, from: d) - 1]
    }
    static func dateCourte(_ d: Date) -> String {
        let c = calendrier.dateComponents([.day, .month], from: d)
        return "\(c.day ?? 1) " + moisCourts[(c.month ?? 1) - 1]
    }
    static func libelle(_ decalage: Int) -> String {
        if decalage == 0 { return RapLibelle.aujourdhui }
        if decalage == 1 { return "Demain" }
        let d = date(decalage)
        return jourCourt(d) + " " + dateCourte(d)
    }
    // Nombre de jours jusqu'au prochain jour de la semaine (1 = dimanche … 7 = samedi), jamais 0.
    static func decalageVers(_ jourSemaine: Int) -> Int {
        let w = calendrier.component(.weekday, from: base)
        let d = (jourSemaine - w + 7) % 7
        return d == 0 ? 7 : d
    }
    static func heureTexte(_ d: Date) -> String {
        let c = calendrier.dateComponents([.hour, .minute], from: d)
        return String(format: "%02d:%02d", c.hour ?? 0, c.minute ?? 0)
    }
    static func sousTexte(jour: Int?, heure: Date?) -> String? {
        var morceaux: [String] = []
        if let j = jour { morceaux.append(libelle(j)) }
        if let h = heure { morceaux.append(heureTexte(h)) }
        return morceaux.isEmpty ? nil : morceaux.joined(separator: ", ")
    }

    // 006 : Aujourd'hui, Demain, Après-demain, 4 jours nommés, reste du mois, puis 7 mois.
    static func sectionsProgrammes() -> [RapSection] {
        var s: [RapSection] = [
            RapSection(id: "j0", gras: RapLibelle.aujourdhui, suite: "", grand: true, debut: 0, fin: 0),
            RapSection(id: "j1", gras: "Demain", suite: "", grand: false, debut: 1, fin: 1),
            RapSection(id: "j2", gras: "Après-demain", suite: "", grand: false, debut: 2, fin: 2),
        ]
        for k in 3...6 {
            let d = date(k)
            s.append(RapSection(id: "j\(k)", gras: jourCourt(d), suite: dateCourte(d), grand: false, debut: k, fin: k))
        }
        let nbJours = calendrier.range(of: .day, in: .month, for: base)?.count ?? 30
        let finMois = max(7, nbJours - DonneesRappels.jour)
        let nomMois = moisNoms[DonneesRappels.mois - 1]
        s.append(RapSection(id: "reste", gras: "Reste du mois (" + nomMois + ")", suite: "", grand: true, debut: 7, fin: finMois))
        let debutMois = calendrier.date(from: DateComponents(year: DonneesRappels.annee, month: DonneesRappels.mois, day: 1)) ?? base
        var debut = finMois + 1
        for k in 1...7 {
            guard let premier = calendrier.date(byAdding: .month, value: k, to: debutMois),
                  let suivant = calendrier.date(byAdding: .month, value: k + 1, to: debutMois) else { continue }
            let c = calendrier.dateComponents([.year, .month], from: premier)
            let ecart = calendrier.dateComponents([.day], from: base, to: suivant).day ?? (debut + 30)
            let fin = ecart - 1
            var nom = moisNoms[(c.month ?? 1) - 1]
            let an = c.year ?? DonneesRappels.annee
            if an != DonneesRappels.annee { nom += ", \(an)" }
            s.append(RapSection(id: "m\(k)", gras: nom, suite: "", grand: true, debut: debut, fin: fin))
            debut = fin + 1
        }
        return s
    }

    // « Terminé : 16/08/2026 21:38 » → (clé de tri, jour abrégé, date)
    static func groupeTermine(_ texte: String?) -> (String, String, String) {
        let brut = texte ?? ""
        let morceaux = brut.dropFirst(10).prefix(10).split(separator: "/")
        guard morceaux.count == 3,
              let j = Int(morceaux[0]), let m = Int(morceaux[1]), let a = Int(morceaux[2]),
              let d = calendrier.date(from: DateComponents(year: a, month: m, day: j)) else {
            return ("99999999", RapLibelle.aujourdhui, "")
        }
        let cle = String(format: "%04d%02d%02d", a, m, j)
        let mois = moisNoms[max(0, min(11, m - 1))]
        return (cle, jourCourt(d), "\(j) " + mois)
    }
}

// ============================================================ MAGASIN
final class MagasinRappels: ObservableObject {
    static let partage = MagasinRappels()
    @Published var rappels: [Rappel] = DonneesRappels.rappels
    @Published var listes: [ListeRappels] = DonneesRappels.listes
    @Published var ordreTuiles: [RapTuile] = RapTuile.allCases
    @Published var tuilesMasquees: Set<RapTuile> = []

    func terminer(_ id: UUID) {
        guard let i = rappels.firstIndex(where: { $0.id == id }) else { return }
        rappels[i].termine = true
        rappels[i].termineTexte = "Terminé : à l'instant"
    }
    func rouvrir(_ id: UUID) {
        guard let i = rappels.firstIndex(where: { $0.id == id }) else { return }
        rappels[i].termine = false
        rappels[i].termineTexte = nil
    }
    func compter(_ filtre: (Rappel) -> Bool) -> Int { rappels.filter(filtre).count }

    func compte(_ t: RapTuile) -> Int {
        switch t {
        case .aujourdhui: return compter { $0.aujourdhui && !$0.termine }
        case .programmes: return compter { $0.programme && !$0.termine }
        case .tous: return compter { !$0.termine }
        case .termines: return compter { $0.termine }
        }
    }
    func supprimerListe(_ nom: String) {
        listes.removeAll { $0.nom == nom }
        rappels.removeAll { $0.liste == nom }
    }
    func basculerTuile(_ t: RapTuile) {
        if tuilesMasquees.contains(t) { tuilesMasquees.remove(t) } else { tuilesMasquees.insert(t) }
    }
    func deplacerTuile(_ t: RapTuile, par n: Int) {
        guard n != 0, let i = ordreTuiles.firstIndex(of: t) else { return }
        let j = max(0, min(ordreTuiles.count - 1, i + n))
        ordreTuiles.remove(at: i)
        ordreTuiles.insert(t, at: j)
    }
    func deplacerListe(_ nom: String, par n: Int) {
        guard n != 0, let i = listes.firstIndex(where: { $0.nom == nom }) else { return }
        let j = max(0, min(listes.count - 1, i + n))
        let l = listes.remove(at: i)
        listes.insert(l, at: j)
    }
    func titreLie(_ id: UUID) -> Binding<String> {
        Binding(
            get: { self.rappels.first(where: { $0.id == id })?.titre ?? "" },
            set: { v in
                if let i = self.rappels.firstIndex(where: { $0.id == id }) { self.rappels[i].titre = v }
            })
    }
}

// ============================================================ COMPOSANTS COMMUNS
/// Verre liquide d'iOS 26 quand il existe, capsule sombre mesurée (#191919) sinon.
struct RapVerre<F: Shape>: ViewModifier {
    let forme: F
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: forme)
        } else {
            content.background(forme.fill(RapTeinte.verre))
        }
    }
}

struct RapBoutonRond: View {
    let symbole: String
    var taille: CGFloat = 44
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: symbole)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: taille, height: taille)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .modifier(RapVerre(forme: Circle()))
    }
}

struct RapBoutonPlus: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.white)
                .frame(width: 48, height: 48)
                .background(Circle().fill(RapTeinte.bleuBouton))
        }
        .buttonStyle(.plain)
    }
}

/// Contenu posé à 28 pt du bord réel de l'écran (mesuré : bouton +, pilules), au-dessus de la capsule home.
struct RapPied<Contenu: View>: View {
    let alignement: Alignment
    @ViewBuilder let contenu: () -> Contenu
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                contenu()
                    .frame(maxWidth: .infinity, alignment: alignement)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

struct RapPastille: View {
    let couleur: Color
    let symbole: String
    var taille: CGFloat = 32
    var body: some View {
        Circle().fill(couleur)
            .frame(width: taille, height: taille)
            .overlay(
                Image(systemName: symbole)
                    .font(.system(size: taille * 0.47, weight: .semibold))
                    .foregroundStyle(Color.white))
    }
}

struct RapCarte<Contenu: View>: View {
    @ViewBuilder let contenu: () -> Contenu
    var body: some View {
        VStack(spacing: 0) { contenu() }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(RapTeinte.carteFeuille))
    }
}

struct RapSeparateurFeuille: View {
    var retrait: CGFloat = 52
    var body: some View {
        Rectangle().fill(RapTeinte.separateurFeuille).frame(height: 1).padding(.leading, retrait)
    }
}

struct RapRangeBascule: View {
    let symbole: String
    let teinteIcone: Color
    let nom: String
    @Binding var valeur: Bool
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbole).font(.system(size: 17)).foregroundStyle(teinteIcone).frame(width: 24)
            Text(nom).font(.system(size: 17)).foregroundStyle(Color.white)
            Spacer(minLength: 8)
            Toggle("", isOn: $valeur).labelsHidden()
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
    }
}

// ============================================================ ACCUEIL
struct RappelsVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    @State private var modification = false
    @State private var nouveauVisible = false
    @State private var nouvelleListeVisible = false
    @State private var recherche = false
    @State private var saisie = ""
    @State private var listeDetail: ListeRappels? = nil
    @State private var suppression: ListeRappels? = nil
    @State private var detailRappel: Rappel? = nil
    @FocusState private var rechercheFocus: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack { accueil }
            BarreHome { dismiss() }
        }
        .preferredColorScheme(.dark)
    }

    private var accueil: some View {
        VStack(spacing: 0) {
            if !recherche {
                RapEnteteAccueil(modification: modification,
                                 rechercher: { recherche = true },
                                 nouvelleListe: { nouvelleListeVisible = true },
                                 basculer: { modification.toggle() })
            }
            corpsAccueil
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(RapTeinte.fond.ignoresSafeArea())
        .overlay(piedAccueil)
        .safeAreaInset(edge: .bottom, spacing: 0) { barreRecherche }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $nouveauVisible) { NouveauRappelVue() }
        .sheet(isPresented: $nouvelleListeVisible) { RappelsNouvelleListeVue() }
        .sheet(item: $listeDetail) { l in RappelsNouvelleListeVue(edition: l.nom) }
        .sheet(item: $detailRappel) { r in DetailRappelVue(rappelId: r.id) }
        .alert("Supprimer cette liste ?", isPresented: suppressionAffichee) {
            Button("Supprimer", role: .destructive) {
                if let l = suppression { magasin.supprimerListe(l.nom) }
                suppression = nil
            }
            Button("Annuler", role: .cancel) { suppression = nil }
        } message: {
            Text(messageSuppression)
        }
    }

    private var suppressionAffichee: Binding<Bool> {
        Binding(get: { suppression != nil }, set: { v in if !v { suppression = nil } })
    }

    private var messageSuppression: String {
        guard let l = suppression else { return "" }
        let n = magasin.compter { $0.liste == l.nom }
        return "La liste « \(l.nom) » et ses \(n) rappels seront supprimés."
    }

    private var resultats: [Rappel] {
        let q = saisie.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }
        return magasin.rappels.filter {
            $0.titre.localizedCaseInsensitiveContains(q) || $0.liste.localizedCaseInsensitiveContains(q)
        }
    }

    @ViewBuilder private var corpsAccueil: some View {
        if modification {
            RapModifierAccueil(infoListe: { l in listeDetail = l }, supprimer: { l in suppression = l })
        } else if recherche && !saisie.trimmingCharacters(in: .whitespaces).isEmpty {
            RapResultatsVue(resultats: resultats, ouvrir: { r in detailRappel = r })
        } else {
            contenuAccueil
        }
    }

    private var contenuAccueil: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible())], spacing: 8) {
                    ForEach(magasin.ordreTuiles.filter { !magasin.tuilesMasquees.contains($0) }, id: \.self) { t in
                        NavigationLink {
                            RapDestinationTuile(tuile: t)
                        } label: {
                            TuileRappel(tuile: t, compte: magasin.compte(t))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text("Mes listes").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.white)
                    .padding(.leading, 16).padding(.top, 30).padding(.bottom, 11)
                carteListes
            }
            .padding(.horizontal, 16)
            .padding(.top, recherche ? 8 : 16)
            .padding(.bottom, 120)
        }
    }

    private var carteListes: some View {
        VStack(spacing: 0) {
            ForEach(magasin.listes) { l in
                VStack(spacing: 0) {
                    NavigationLink {
                        FiltreVue(titre: l.nom, teinte: Color(hex: l.couleur)) { $0.liste == l.nom && !$0.termine }
                    } label: {
                        LigneListe(nom: l.nom, couleur: Color(hex: l.couleur), symbole: l.symbole,
                                   compte: magasin.compter { $0.liste == l.nom && !$0.termine })
                    }
                    .buttonStyle(.plain)
                    if l.id != magasin.listes.last?.id {
                        Rectangle().fill(RapTeinte.separateur).frame(height: 1).padding(.leading, 60)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(RapTeinte.carte))
    }

    @ViewBuilder private var piedAccueil: some View {
        if modification {
            RapPied(alignement: .center) { RapBoutonAjouterGroupe() }
        } else if !recherche {
            RapPied(alignement: .trailing) { RapBoutonPlus { nouveauVisible = true } }
        }
    }

    // 002 : pilule de recherche au-dessus du clavier + bouton de fermeture
    @ViewBuilder private var barreRecherche: some View {
        if recherche {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .medium)).foregroundStyle(RapTeinte.gris)
                    TextField("Recherche", text: $saisie)
                        .focused($rechercheFocus)
                        .font(.system(size: 17)).foregroundStyle(Color.white)
                        .submitLabel(.search)
                }
                .padding(.horizontal, 14)
                .frame(height: 46)
                .modifier(RapVerre(forme: Capsule()))
                RapBoutonRond(symbole: "xmark", taille: 46) { fermerRecherche() }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .onAppear { rechercheFocus = true }
        }
    }

    private func fermerRecherche() {
        rechercheFocus = false
        saisie = ""
        recherche = false
    }
}

struct RapEnteteAccueil: View {
    let modification: Bool
    let rechercher: () -> Void
    let nouvelleListe: () -> Void
    let basculer: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Spacer(minLength: 0)
            if modification {
                RapBoutonRond(symbole: "text.badge.plus", action: nouvelleListe)
                Button(action: basculer) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(RapTeinte.bleuBouton))
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 0) {
                    boutonIcone("magnifyingglass", action: rechercher)
                    Button(action: nouvelleListe) {
                        RapIconeNouvelleListe()
                            .frame(width: 51, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .modifier(RapVerre(forme: Capsule()))
                Button(action: basculer) {
                    Text("Modifier")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.white)
                        .frame(width: 94, height: 44)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .modifier(RapVerre(forme: Capsule()))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }

    private func boutonIcone(_ symbole: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbole)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .frame(width: 51, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Icône « nouvelle liste » d'iOS 26 : carré arrondi, deux lignes à puce, pastille « + » en bas à droite.
struct RapIconeNouvelleListe: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.white, lineWidth: 1.8)
                .frame(width: 22, height: 22)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 3) {
                    Circle().stroke(Color.white, lineWidth: 1.4).frame(width: 4.5, height: 4.5)
                    Capsule().fill(Color.white).frame(width: 7, height: 1.6)
                }
                HStack(spacing: 3) {
                    Circle().stroke(Color.white, lineWidth: 1.4).frame(width: 4.5, height: 4.5)
                    Capsule().fill(Color.white).frame(width: 4, height: 1.6)
                }
            }
            .offset(x: -1.5, y: -2)
            ZStack {
                Circle().fill(Color.black).frame(width: 15, height: 15)
                Circle().fill(Color.white).frame(width: 12, height: 12)
                Image(systemName: "plus")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(Color.black)
            }
            .offset(x: 9, y: 8)
        }
    }
}

struct RapBoutonAjouterGroupe: View {
    var body: some View {
        // 004 : bouton grisé (aucun groupe ne peut être créé tant qu'aucune liste n'est sélectionnée)
        Button { } label: {
            Text("Ajouter un groupe")
                .font(.system(size: 17))
                .foregroundStyle(RapTeinte.discret)
                .frame(width: 172, height: 48)
        }
        .buttonStyle(.plain)
        .disabled(true)
        .modifier(RapVerre(forme: Capsule()))
    }
}

struct TuileRappel: View {
    let tuile: RapTuile
    let compte: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                icone.padding(.top, 6)
                Spacer(minLength: 0)
                Text("\(compte)").font(.system(size: 30, weight: .bold)).foregroundStyle(Color.white)
            }
            Spacer(minLength: 0)
            Text(tuile.titre).font(.system(size: 16, weight: .semibold)).foregroundStyle(Color.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 17)
                .fill(LinearGradient(colors: [tuile.haut, tuile.bas], startPoint: .topLeading, endPoint: .bottomTrailing)))
    }

    @ViewBuilder private var icone: some View {
        switch tuile {
        case .aujourdhui:
            Image(systemName: "calendar")
                .font(.system(size: 24))
                .foregroundStyle(Color.white)
                .overlay(
                    Text("\(DonneesRappels.jour)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.white)
                        .offset(y: 3))
        case .programmes:
            Image(systemName: "calendar").font(.system(size: 24)).foregroundStyle(Color.white)
        case .tous:
            Image(systemName: "tray.fill").font(.system(size: 24)).foregroundStyle(Color.white)
        case .termines:
            Image(systemName: "checkmark").font(.system(size: 26, weight: .medium)).foregroundStyle(Color.white)
        }
    }
}

struct RapDestinationTuile: View {
    let tuile: RapTuile
    var body: some View {
        switch tuile {
        case .aujourdhui:
            FiltreVue(titre: RapLibelle.aujourdhui, teinte: tuile.teinteTitre) { $0.aujourdhui && !$0.termine }
        case .programmes:
            FiltreVue(titre: RapLibelle.programmes, teinte: tuile.teinteTitre) { $0.programme && !$0.termine }
        case .tous:
            FiltreVue(titre: RapLibelle.tous, teinte: tuile.teinteTitre) { !$0.termine }
        case .termines:
            TerminesVue()
        }
    }
}

struct LigneListe: View {
    let nom: String
    let couleur: Color
    let symbole: String
    let compte: Int
    var body: some View {
        HStack(spacing: 12) {
            RapPastille(couleur: couleur, symbole: symbole, taille: 32)
            Text(nom).font(.system(size: 17)).foregroundStyle(Color.white)
            Spacer(minLength: 8)
            Text("\(compte)").font(.system(size: 17)).foregroundStyle(RapTeinte.gris)
            Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(RapTeinte.chevron)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 62)
        .contentShape(Rectangle())
    }
}

// ============================================================ ACCUEIL — MODE « MODIFIER » (004)
struct RapModifierAccueil: View {
    @ObservedObject private var magasin = MagasinRappels.partage
    let infoListe: (ListeRappels) -> Void
    let supprimer: (ListeRappels) -> Void

    init(infoListe: @escaping (ListeRappels) -> Void, supprimer: @escaping (ListeRappels) -> Void) {
        self.infoListe = infoListe
        self.supprimer = supprimer
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                carteTuiles
                Text("Mes listes").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.white)
                    .padding(.leading, 16).padding(.top, 30).padding(.bottom, 11)
                carteListes
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }

    private var carteTuiles: some View {
        VStack(spacing: 0) {
            ForEach(magasin.ordreTuiles, id: \.self) { t in
                VStack(spacing: 0) {
                    ligneTuile(t)
                    if t != magasin.ordreTuiles.last {
                        Rectangle().fill(RapTeinte.separateur).frame(height: 1).padding(.leading, 104)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(RapTeinte.carte))
    }

    private func ligneTuile(_ t: RapTuile) -> some View {
        let visible = !magasin.tuilesMasquees.contains(t)
        return HStack(spacing: 16) {
            Button { magasin.basculerTuile(t) } label: {
                RapCercleCoche(rempli: visible, fond: RapTeinte.bleu, coche: Color.white, taille: 24)
            }
            .buttonStyle(.plain)
            RapPastille(couleur: t.teinteTitre, symbole: t.symbole, taille: 32)
            Text(t.titre).font(.system(size: 17)).foregroundStyle(Color.white)
            Spacer(minLength: 8)
            Image(systemName: "line.3.horizontal").font(.system(size: 18)).foregroundStyle(RapTeinte.secondaire)
                .frame(width: 36, height: 62)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 6).onEnded { v in
                    magasin.deplacerTuile(t, par: Int((v.translation.height / 62).rounded()))
                })
        }
        .padding(.leading, 16).padding(.trailing, 12)
        .frame(height: 62)
    }

    private var carteListes: some View {
        VStack(spacing: 0) {
            ForEach(magasin.listes) { l in
                VStack(spacing: 0) {
                    ligneListe(l)
                    if l.id != magasin.listes.last?.id {
                        Rectangle().fill(RapTeinte.separateur).frame(height: 1).padding(.leading, 104)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(RapTeinte.carte))
    }

    private func ligneListe(_ l: ListeRappels) -> some View {
        HStack(spacing: 16) {
            Button { supprimer(l) } label: {
                Circle().fill(RapTeinte.rouge).frame(width: 24, height: 24)
                    .overlay(RoundedRectangle(cornerRadius: 1).fill(Color.white).frame(width: 12, height: 2.5))
            }
            .buttonStyle(.plain)
            RapPastille(couleur: Color(hex: l.couleur), symbole: l.symbole, taille: 32)
            Text(l.nom).font(.system(size: 17)).foregroundStyle(Color.white)
            Spacer(minLength: 8)
            Button { infoListe(l) } label: {
                Image(systemName: "info.circle").font(.system(size: 22)).foregroundStyle(RapTeinte.bleu)
            }
            .buttonStyle(.plain)
            Rectangle().fill(RapTeinte.separateur).frame(width: 1, height: 62)
            Image(systemName: "line.3.horizontal").font(.system(size: 18)).foregroundStyle(RapTeinte.secondaire)
                .frame(width: 30, height: 62)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 6).onEnded { v in
                    magasin.deplacerListe(l.nom, par: Int((v.translation.height / 62).rounded()))
                })
        }
        .padding(.leading, 16).padding(.trailing, 12)
        .frame(height: 62)
    }
}

struct RapCercleCoche: View {
    let rempli: Bool
    let fond: Color
    let coche: Color
    var taille: CGFloat = 22
    var body: some View {
        ZStack {
            if rempli {
                Circle().fill(fond)
                Image(systemName: "checkmark")
                    .font(.system(size: taille * 0.5, weight: .bold)).foregroundStyle(coche)
            } else {
                Circle().stroke(Color(hex: 0x8E8E93), lineWidth: 1.5)
            }
        }
        .frame(width: taille, height: taille)
    }
}

// ============================================================ ACCUEIL — RÉSULTATS DE RECHERCHE
struct RapResultatsVue: View {
    let resultats: [Rappel]
    let ouvrir: (Rappel) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if resultats.isEmpty {
                    Text("Aucun résultat")
                        .font(.system(size: 20)).foregroundStyle(RapTeinte.discret)
                        .frame(maxWidth: .infinity).padding(.top, 120)
                }
                ForEach(resultats) { r in
                    VStack(spacing: 0) {
                        ligne(r)
                        Rectangle().fill(RapTeinte.separateur).frame(height: 1).padding(.leading, 54)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private func ligne(_ r: Rappel) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RapCercleCoche(rempli: r.termine, fond: Color(hex: 0x8E8E93), coche: Color.black)
            VStack(alignment: .leading, spacing: 2) {
                Text(r.titre).font(.system(size: 17))
                    .foregroundStyle(r.termine ? RapTeinte.secondaire : Color.white)
                Text(r.liste).font(.system(size: 14)).foregroundStyle(RapTeinte.secondaire)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 18).padding(.trailing, 16).padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { ouvrir(r) }
    }
}

// ============================================================ LISTE (Aujourd'hui, Programmés, Tous, Terminés, listes)
struct RapEnTeteSection: View {
    let gras: String
    let suite: String
    let grand: Bool
    let allume: Bool
    var couleur: Color? = nil

    private var teinte: Color {
        if let c = couleur { return c }
        return allume ? Color.white : RapTeinte.discret
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text(gras).font(.system(size: grand ? 21 : 15, weight: .bold)).foregroundStyle(teinte)
                if !suite.isEmpty {
                    Text(suite).font(.system(size: 15)).foregroundStyle(teinte)
                }
            }
            .frame(maxWidth: .infinity, minHeight: grand ? 44 : 40, alignment: .leading)
            .padding(.horizontal, 16)
            Rectangle()
                .fill(grand ? RapTeinte.ligne : RapTeinte.ligneFine)
                .frame(height: grand ? 2 : 0.5)
        }
    }
}

struct RapLignePlaceholder: View {
    let action: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .strokeBorder(RapTeinte.discret, style: StrokeStyle(lineWidth: 1.5, dash: [2.5, 3]))
                    .frame(width: 22, height: 22)
                Spacer(minLength: 0)
            }
            .padding(.leading, 18).padding(.vertical, 10)
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
            Rectangle().fill(RapTeinte.separateur).frame(height: 1).padding(.leading, 54)
        }
    }
}

struct RapLigneRappel: View {
    let rappel: Rappel
    let enEdition: Bool
    let selection: Bool?
    let titre: Binding<String>
    var focus: FocusState<RapFocus?>.Binding
    let cocher: () -> Void
    let toucher: () -> Void
    let info: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            cercle
            VStack(alignment: .leading, spacing: 2) {
                texteTitre
                sousLignes
            }
            Spacer(minLength: 0)
            droite
        }
        .padding(.leading, 18).padding(.trailing, 16).padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { if !enEdition { toucher() } }
    }

    private var cercle: some View {
        Group {
            if let choisi = selection {
                RapCercleCoche(rempli: choisi, fond: RapTeinte.bleu, coche: Color.white)
            } else if rappel.termine {
                RapCercleCoche(rempli: true, fond: Color(hex: 0x8E8E93), coche: Color.black)
            } else {
                Circle().stroke(Color(hex: 0x8E8E93), lineWidth: 1.5).frame(width: 22, height: 22)
            }
        }
        .contentShape(Circle())
        .onTapGesture { cocher() }
    }

    @ViewBuilder private var texteTitre: some View {
        if enEdition {
            TextField("", text: titre)
                .font(.system(size: 17)).foregroundStyle(Color.white)
                .focused(focus, equals: .rappel(rappel.id))
                .submitLabel(.done)
                .onSubmit { focus.wrappedValue = nil }
                .onAppear { focus.wrappedValue = .rappel(rappel.id) }
        } else {
            HStack(spacing: 6) {
                if rappel.urgent {
                    Text("!!!").font(.system(size: 17, weight: .bold)).foregroundStyle(RapTeinte.bleu)
                }
                Text(rappel.titre).font(.system(size: 17))
                    .foregroundStyle(rappel.termine ? RapTeinte.secondaire : Color.white)
            }
        }
    }

    @ViewBuilder private var sousLignes: some View {
        if !rappel.note.isEmpty {
            Text(rappel.note).font(.system(size: 14)).foregroundStyle(RapTeinte.secondaire)
        } else if enEdition {
            Text("Ajouter une note").font(.system(size: 14)).foregroundStyle(RapTeinte.discret)
        }
        if let s = rappel.sousTexte {
            Text(s).font(.system(size: 14)).foregroundStyle(RapTeinte.secondaire)
        }
        if rappel.termine, let t = rappel.termineTexte {
            Text(rappel.liste + " · " + t).font(.system(size: 14)).foregroundStyle(RapTeinte.secondaire)
        }
    }

    @ViewBuilder private var droite: some View {
        if rappel.drapeau {
            Image(systemName: "flag.fill").font(.system(size: 14)).foregroundStyle(RapTeinte.orange).padding(.top, 3)
        }
        if enEdition {
            Button(action: info) {
                Image(systemName: "info.circle").font(.system(size: 20)).foregroundStyle(RapTeinte.bleu)
            }
            .buttonStyle(.plain)
        }
    }
}

struct FiltreVue: View {
    let titre: String
    let teinte: Color
    let filtre: (Rappel) -> Bool

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    @State private var detail: Rappel? = nil
    @State private var nouveau = ""
    @State private var ajout = false
    @State private var enEdition: UUID? = nil
    @State private var afficherTermines = false
    @State private var grouperHeure = true
    @State private var tri: RapTri = .defaut
    @State private var selection = false
    @State private var choisis: Set<UUID> = []
    @State private var detailsListe = false
    @State private var suppressionVisible = false
    @State private var impressionVisible = false
    @State private var cameraVisible = false
    @State private var effacerVisible = false
    @State private var brouillon = RapBrouillon()
    @FocusState private var focus: RapFocus?

    init(titre: String, teinte: Color, filtre: @escaping (Rappel) -> Bool) {
        self.titre = titre; self.teinte = teinte; self.filtre = filtre
    }

    // ---------------------------------------------------------------- données
    private var genre: RapGenre {
        if titre == RapLibelle.aujourdhui { return .aujourdhui }
        if titre == RapLibelle.programmes { return .programmes }
        if titre == RapLibelle.tous { return .tous }
        if titre == RapLibelle.termines { return .termines }
        if magasin.listes.contains(where: { $0.nom == titre }) { return .liste }
        return .autre
    }

    private func concerne(_ r: Rappel) -> Bool {
        switch genre {
        case .tous: return true
        case .programmes: return r.programme
        case .aujourdhui: return r.aujourdhui
        case .liste: return r.liste == titre
        case .termines, .autre: return false
        }
    }

    private var items: [Rappel] {
        var r = magasin.rappels.filter(filtre).filter { genre == .termines || !$0.termine }
        if afficherTermines && genre != .termines {
            r += magasin.rappels.filter { $0.termine && concerne($0) }
        }
        if tri == .titre {
            r.sort { $0.titre.localizedCaseInsensitiveCompare($1.titre) == .orderedAscending }
        }
        return r
    }

    private var cible: String {
        if genre == .liste { return titre }
        return magasin.listes.first?.nom ?? DonneesRappels.listeParDefaut
    }

    private var nbRappelsListe: Int { magasin.compter { $0.liste == titre } }

    private var montrePlus: Bool { genre == .aujourdhui || genre == .liste }

    private var montreVide: Bool {
        if genre == .programmes || genre == .tous { return false }
        return items.isEmpty && !ajout
    }

    private func jourEffectif(_ r: Rappel) -> Int { max(0, r.jour ?? 0) }

    // ---------------------------------------------------------------- corps
    var body: some View {
        contenu
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { barre }
            .sheet(item: $detail) { r in DetailRappelVue(rappelId: r.id) }
            .sheet(isPresented: $detailsListe) { RappelsNouvelleListeVue(edition: titre) }
            .onChange(of: focus) { _, nouveauFocus in
                if nouveauFocus == nil && ajout {
                    DispatchQueue.main.async { if focus == nil { terminerAjout() } }
                }
                if !(nouveauFocus?.estRappel ?? false) { enEdition = nil }
            }
            .alert("Supprimer cette liste ?", isPresented: $suppressionVisible) {
                Button("Supprimer", role: .destructive) {
                    magasin.supprimerListe(titre)
                    dismiss()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("La liste « \(titre) » et ses \(nbRappelsListe) rappels seront supprimés.")
            }
            .alert("Effacer les rappels terminés ?", isPresented: $effacerVisible) {
                Button("Effacer", role: .destructive) {
                    Haptique.leger()
                    magasin.rappels.removeAll { $0.termine }
                }
                Button("Annuler", role: .cancel) {}
            }
            .alert(ErreurLambda.reponse("menu.indisponible"), isPresented: $impressionVisible) {
                Button("OK", role: .cancel) {}
            }
            .alert(ErreurLambda.reponse("camera"), isPresented: $cameraVisible) {
                Button("OK", role: .cancel) {}
            }
    }

    private var contenu: some View {
        ZStack {
            RapTeinte.fond.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(titre)
                        .font(.system(size: 34, weight: .bold)).foregroundStyle(teinte)
                        .lineLimit(1)
                        .padding(.horizontal, 16).padding(.top, 5).padding(.bottom, 8)
                    corps
                    Spacer(minLength: 140)
                }
            }
            .onTapGesture { toucherFond() }
            etatVide
        }
        .overlay(pied)
    }

    @ViewBuilder private var corps: some View {
        switch genre {
        case .aujourdhui: corpsAujourdhui
        case .programmes: corpsProgrammes
        case .tous: corpsTous
        case .termines: corpsTermines
        case .liste, .autre: corpsListe
        }
    }

    @ViewBuilder private var etatVide: some View {
        if montreVide {
            Text("Aucun rappel")
                .font(.system(size: 20)).foregroundStyle(RapTeinte.discret)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 70)
                .allowsHitTesting(false)
        }
    }

    private var corpsListe: some View {
        VStack(alignment: .leading, spacing: 0) {
            rangees(items)
            if ajout { ligneNouveau }
        }
    }

    private var corpsAujourdhui: some View {
        VStack(alignment: .leading, spacing: 0) {
            rangees(items)
            if ajout { ligneNouveau }
            if grouperHeure {
                ForEach(RapLibelle.moments, id: \.self) { m in
                    RapEnTeteSection(gras: m, suite: "", grand: false, allume: false)
                }
            }
        }
    }

    private var corpsProgrammes: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(RapDates.sectionsProgrammes()) { s in sectionProgrammes(s) }
        }
    }

    private func sectionProgrammes(_ s: RapSection) -> some View {
        let contenuSection = items.filter { jourEffectif($0) >= s.debut && jourEffectif($0) <= s.fin }
        let premiere = s.id == "j0"
        return VStack(alignment: .leading, spacing: 0) {
            RapEnTeteSection(gras: s.gras, suite: s.suite, grand: s.grand, allume: premiere || !contenuSection.isEmpty)
            rangees(contenuSection)
            if premiere && ajout { ligneNouveau }
            if premiere && contenuSection.isEmpty && !ajout { RapLignePlaceholder { commencerAjout() } }
        }
    }

    private var corpsTous: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(magasin.listes) { l in groupeListe(l) }
        }
    }

    private func groupeListe(_ l: ListeRappels) -> some View {
        let contenuListe = items.filter { $0.liste == l.nom }
        return VStack(alignment: .leading, spacing: 0) {
            RapEnTeteSection(gras: l.nom, suite: "", grand: true, allume: true, couleur: Color(hex: l.couleur))
            rangees(contenuListe)
            if ajout && l.nom == cible { ligneNouveau }
            if contenuListe.isEmpty && !(ajout && l.nom == cible) { RapLignePlaceholder { commencerAjout() } }
        }
    }

    private var groupesTermines: [RapGroupeTermine] {
        let brut = Dictionary(grouping: items) { RapDates.groupeTermine($0.termineTexte).0 }
        return brut.keys.sorted(by: >).map { (cle: String) -> RapGroupeTermine in
            let rs = brut[cle] ?? []
            let e = RapDates.groupeTermine(rs.first?.termineTexte)
            return RapGroupeTermine(cle: cle, gras: e.1, suite: e.2, rappels: rs)
        }
    }

    private var corpsTermines: some View {
        VStack(alignment: .leading, spacing: 0) {
            enteteTermines
            ForEach(groupesTermines) { g in
                RapEnTeteSection(gras: g.gras, suite: g.suite, grand: false, allume: true)
                rangees(g.rappels)
            }
        }
    }

    // 008 : « 0 terminé • Effacer » puis un trait de 1 pt
    private var enteteTermines: some View {
        let n = items.count
        return VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text(n > 1 ? "\(n) terminés" : "\(n) terminé")
                    .font(.system(size: 15)).foregroundStyle(RapTeinte.secondaire)
                Text("•").font(.system(size: 15)).foregroundStyle(RapTeinte.discret)
                Text("Effacer").font(.system(size: 15))
                    .foregroundStyle(n > 0 ? RapTeinte.bleu : RapTeinte.discret)
                    .onTapGesture { if n > 0 { effacerVisible = true } }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            Rectangle().fill(RapTeinte.separateur).frame(height: 1).padding(.horizontal, 16)
        }
    }

    // ---------------------------------------------------------------- rangées
    private func rangees(_ liste: [Rappel]) -> some View {
        ForEach(liste) { r in
            VStack(spacing: 0) {
                ligne(r)
                Rectangle().fill(RapTeinte.separateur).frame(height: 1).padding(.leading, 54)
            }
        }
    }

    private func ligne(_ r: Rappel) -> some View {
        RapLigneRappel(rappel: r,
                       enEdition: enEdition == r.id,
                       selection: selection ? choisis.contains(r.id) : nil,
                       titre: magasin.titreLie(r.id),
                       focus: $focus,
                       cocher: { cocher(r) },
                       toucher: { toucher(r) },
                       info: { detail = r })
    }

    // 036 / 039 : nouvelle ligne avec curseur, « Ajouter une note » en dessous
    private var ligneNouveau: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                Circle().stroke(RapTeinte.discret, lineWidth: 1.5).frame(width: 22, height: 22)
                VStack(alignment: .leading, spacing: 2) {
                    TextField("", text: $nouveau)
                        .font(.system(size: 17)).foregroundStyle(Color.white)
                        .focused($focus, equals: .nouveau)
                        .submitLabel(.done)
                        .onSubmit { validerNouveau() }
                    Text("Ajouter une note").font(.system(size: 14)).foregroundStyle(RapTeinte.discret)
                    if genre == .aujourdhui || genre == .programmes {
                        Text(descriptionBrouillon).font(.system(size: 14)).foregroundStyle(RapTeinte.secondaire)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.leading, 18).padding(.trailing, 16).padding(.vertical, 10)
            Rectangle().fill(RapTeinte.separateur).frame(height: 1).padding(.leading, 54)
        }
    }

    private var descriptionBrouillon: String {
        var morceaux: [String] = [cible]
        if let j = brouillon.jour { morceaux.append(RapDates.libelle(j)) }
        if let l = brouillon.lieu { morceaux.append(l) }
        return morceaux.joined(separator: " · ")
    }

    // ---------------------------------------------------------------- actions
    private func cocher(_ r: Rappel) {
        if selection { basculerChoix(r.id); return }
        withAnimation(.easeOut(duration: 0.25)) {
            if r.termine { magasin.rouvrir(r.id) } else { magasin.terminer(r.id) }
        }
    }

    private func toucher(_ r: Rappel) {
        if selection { basculerChoix(r.id); return }
        ajout = false
        enEdition = r.id
    }

    private func basculerChoix(_ id: UUID) {
        if choisis.contains(id) { choisis.remove(id) } else { choisis.insert(id) }
    }

    private func toucherFond() {
        if genre == .termines || selection || ajout { return }
        commencerAjout()
    }

    private func commencerAjout() {
        if genre == .termines || selection { return }
        enEdition = nil
        ajout = true
        DispatchQueue.main.async { focus = .nouveau }
    }

    private func validerNouveau() {
        let t = nouveau.trimmingCharacters(in: .whitespaces)
        if t.isEmpty {
            ajout = false
            focus = nil
            return
        }
        creerRappel(t)
        nouveau = ""
        brouillon = RapBrouillon()
        focus = .nouveau
    }

    private func terminerAjout() {
        let t = nouveau.trimmingCharacters(in: .whitespaces)
        if !t.isEmpty { creerRappel(t) }
        nouveau = ""
        brouillon = RapBrouillon()
        ajout = false
    }

    private func creerRappel(_ t: String) {
        var r = Rappel(titre: t, liste: cible)
        r.urgent = titre == "Urgent"
        r.drapeau = titre == "Avec drapeau" || brouillon.drapeau
        r.aujourdhui = genre == .aujourdhui
        if genre == .programmes && brouillon.jour == nil { r.programme = true; r.jour = 0 }
        if let j = brouillon.jour {
            r.programme = true
            r.jour = j
            r.aujourdhui = j == 0
        }
        var morceaux: [String] = []
        if let j = brouillon.jour { morceaux.append(RapDates.libelle(j)) }
        if let l = brouillon.lieu { morceaux.append(l) }
        r.sousTexte = morceaux.isEmpty ? nil : morceaux.joined(separator: " · ")
        magasin.rappels.append(r)
    }

    private func supprimerChoix() {
        let ids = choisis
        magasin.rappels.removeAll { ids.contains($0.id) }
        choisis = []
        selection = false
    }

    // ---------------------------------------------------------------- barre haute, menu, accessoire clavier
    @ToolbarContentBuilder private var barre: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) { actionsHaut }
        ToolbarItemGroup(placement: .keyboard) { accessoire }
    }

    @ViewBuilder private var actionsHaut: some View {
        if selection {
            Button("OK") { selection = false; choisis = [] }
        } else {
            HStack(spacing: 8) {
                menuHaut
                if focus != nil {
                    Button { focus = nil } label: {
                        Image(systemName: "checkmark").fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(RapTeinte.bleuBouton)
                }
            }
        }
    }

    // 015 / 020 / 037 / 038 : menus de la référence, selon l'écran
    private var menuHaut: some View {
        Menu {
            if genre == .liste {
                Button { detailsListe = true } label: {
                    Label("Afficher les détails de la liste", systemImage: "info.circle")
                }
            }
            Button { selection = true; choisis = []; ajout = false } label: {
                Label("Sélectionner des rappels", systemImage: "checkmark.circle")
            }
            if genre == .aujourdhui {
                Toggle(isOn: $grouperHeure) {
                    Label("Grouper par heure", systemImage: "rectangle.split.1x2")
                }
            }
            if genre == .aujourdhui || genre == .liste { sousMenuTri }
            if genre != .aujourdhui && genre != .termines {
                Button { afficherTermines.toggle() } label: {
                    Label(afficherTermines ? "Masquer les rappels terminés" : "Afficher les rappels terminés",
                          systemImage: afficherTermines ? "eye.slash" : "eye")
                }
            }
            Button { impressionVisible = true } label: {
                Label("Imprimer", systemImage: "printer")
            }
            if genre == .liste {
                Button(role: .destructive) { suppressionVisible = true } label: {
                    Label("Supprimer la liste", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }

    private var sousMenuTri: some View {
        Menu {
            Picker("Trier par", selection: $tri) {
                Text(genre == .liste ? "Manuel" : "Échéance").tag(RapTri.defaut)
                Text("Titre").tag(RapTri.titre)
            }
        } label: {
            Label("Trier par", systemImage: "arrow.up.arrow.down")
        }
    }

    // 019 : date, lieu, drapeau, appareil photo au-dessus du clavier
    @ViewBuilder private var accessoire: some View {
        Menu {
            optionDate("Aujourd’hui", 0)
            optionDate("Demain", 1)
            optionDate("Ce week-end", RapDates.decalageVers(7))
            optionDate("La semaine prochaine", RapDates.decalageVers(2))
            Button { brouillon.jour = nil } label: {
                Label("Aucun(e)", systemImage: brouillon.jour == nil ? "checkmark" : "xmark.circle")
            }
        } label: {
            Image(systemName: "calendar.badge.clock")
        }
        Spacer()
        Menu {
            optionLieu("Sortie de voiture")
            optionLieu("Montée en voiture")
            optionLieu("Lieu actuel")
            Button { brouillon.lieu = nil } label: {
                Label("Aucun", systemImage: brouillon.lieu == nil ? "checkmark" : "xmark.circle")
            }
        } label: {
            Image(systemName: "location")
        }
        Spacer()
        Button { brouillon.drapeau.toggle() } label: {
            Image(systemName: brouillon.drapeau ? "flag.fill" : "flag")
        }
        Spacer()
        Button { cameraVisible = true } label: {
            Image(systemName: "camera")
        }
    }

    private func optionDate(_ nom: String, _ jour: Int) -> some View {
        Button { brouillon.jour = jour } label: {
            Label(nom, systemImage: brouillon.jour == jour ? "checkmark" : "calendar")
        }
    }

    private func optionLieu(_ nom: String) -> some View {
        Button { brouillon.lieu = nom } label: {
            Label(nom, systemImage: brouillon.lieu == nom ? "checkmark" : "location")
        }
    }

    // ---------------------------------------------------------------- bas d'écran
    @ViewBuilder private var pied: some View {
        if selection && !choisis.isEmpty {
            RapPied(alignement: .center) {
                Button(role: .destructive) { supprimerChoix() } label: {
                    Text("Supprimer")
                        .font(.system(size: 17)).foregroundStyle(RapTeinte.rouge)
                        .padding(.horizontal, 28).frame(height: 48)
                }
                .buttonStyle(.plain)
                .modifier(RapVerre(forme: Capsule()))
            }
        } else if montrePlus && focus == nil && !selection {
            RapPied(alignement: .trailing) { RapBoutonPlus { commencerAjout() } }
        }
    }
}

// ============================================================ TERMINÉS
struct TerminesVue: View {
    var body: some View {
        FiltreVue(titre: RapLibelle.termines, teinte: RapTuile.termines.teinteTitre) { $0.termine }
    }
}

// ============================================================ DÉTAILS / NOUVEAU RAPPEL (feuille 044)
struct DetailRappelVue: View {
    let rappelId: UUID
    var body: some View {
        RapFormulaireVue(rappelId: rappelId)
    }
}

struct NouveauRappelVue: View {
    var body: some View {
        RapFormulaireVue(rappelId: nil)
    }
}

struct RapFormulaireVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    let rappelId: UUID?
    @State private var titre = ""
    @State private var note = ""
    @State private var liste = DonneesRappels.listeParDefaut
    @State private var dateActive = false
    @State private var jour = 0
    @State private var heureActive = false
    @State private var heure = RapDates.heureParDefaut
    @State private var urgent = false
    @State private var drapeau = false
    @State private var datesTouchees = false
    @FocusState private var titreFocus: Bool

    init(rappelId: UUID?) { self.rappelId = rappelId }

    private var titrePage: String { rappelId == nil ? "Nouveau rappel" : "Détails" }
    private var listeCourante: ListeRappels? { magasin.listes.first(where: { $0.nom == liste }) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    carteTexte
                    entete("Date et heure")
                    carteDate
                    entete("Plus d’options")
                    carteListe
                    carteDetails
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(RapTeinte.fondFeuille)
            .navigationTitle(titrePage)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(Color.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { enregistrer() } label: {
                        Image(systemName: "checkmark").fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(RapTeinte.bleuBouton)
                    .disabled(titre.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { charger() }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationBackground(RapTeinte.fondFeuille)
    }

    private func entete(_ texte: String) -> some View {
        Text(texte)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(RapTeinte.secondaire)
            .padding(.leading, 16).padding(.top, 26).padding(.bottom, 10)
    }

    private var carteTexte: some View {
        RapCarte {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Titre", text: $titre)
                    .focused($titreFocus)
                    .font(.system(size: 17))
                    .frame(height: 42)
                TextField("Notes", text: $note)
                    .font(.system(size: 17))
                    .frame(height: 42)
            }
            .padding(.horizontal, 16).padding(.top, 17).padding(.bottom, 7)
        }
    }

    private var liaisonDate: Binding<Bool> {
        Binding(get: { dateActive }, set: { v in dateActive = v; datesTouchees = true })
    }
    private var liaisonHeure: Binding<Bool> {
        Binding(get: { heureActive }, set: { v in heureActive = v; datesTouchees = true })
    }
    private var liaisonHeureDate: Binding<Date> {
        Binding(get: { heure }, set: { v in heure = v; datesTouchees = true })
    }

    private var carteDate: some View {
        RapCarte {
            RapRangeBascule(symbole: "calendar", teinteIcone: RapTeinte.secondaire, nom: "Date", valeur: liaisonDate)
            if dateActive {
                RapSeparateurFeuille()
                rangeJour
            }
            RapSeparateurFeuille()
            RapRangeBascule(symbole: "clock", teinteIcone: RapTeinte.secondaire, nom: "Heure", valeur: liaisonHeure)
            if heureActive {
                RapSeparateurFeuille()
                HStack {
                    Spacer(minLength: 0)
                    DatePicker("", selection: liaisonHeureDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 52)
            }
        }
    }

    private var rangeJour: some View {
        Menu {
            choixJour("Aujourd’hui", 0)
            choixJour("Demain", 1)
            choixJour("Ce week-end", RapDates.decalageVers(7))
            choixJour("La semaine prochaine", RapDates.decalageVers(2))
        } label: {
            HStack {
                Text(RapDates.libelle(jour)).font(.system(size: 17)).foregroundStyle(RapTeinte.bleu)
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 12)).foregroundStyle(RapTeinte.gris)
            }
            .padding(.leading, 52).padding(.trailing, 16)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
    }

    private func choixJour(_ nom: String, _ valeur: Int) -> some View {
        Button { jour = valeur; datesTouchees = true } label: {
            Label(nom, systemImage: jour == valeur ? "checkmark" : "calendar")
        }
    }

    private var carteListe: some View {
        NavigationLink {
            RapChoixListeVue(liste: $liste)
        } label: {
            RapCarte {
                HStack(spacing: 12) {
                    RapPastille(couleur: Color(hex: listeCourante?.couleur ?? 0x0A84FF),
                                symbole: listeCourante?.symbole ?? "list.bullet", taille: 30)
                    Text("Liste").font(.system(size: 17)).foregroundStyle(Color.white)
                    Spacer(minLength: 8)
                    Text(liste).font(.system(size: 17)).foregroundStyle(RapTeinte.gris)
                    Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(RapTeinte.chevron)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 52)
            }
        }
        .buttonStyle(.plain)
    }

    private var carteDetails: some View {
        NavigationLink {
            RapDetailsOptionsVue(urgent: $urgent, drapeau: $drapeau)
        } label: {
            RapCarte {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle").font(.system(size: 17))
                        .foregroundStyle(RapTeinte.secondaire).frame(width: 30)
                    Text("Détails").font(.system(size: 17)).foregroundStyle(Color.white)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(RapTeinte.chevron)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 52)
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    private func charger() {
        if let id = rappelId, let r = magasin.rappels.first(where: { $0.id == id }) {
            titre = r.titre
            note = r.note
            liste = r.liste
            dateActive = r.programme || r.aujourdhui
            jour = r.jour ?? 0
            urgent = r.urgent
            drapeau = r.drapeau
        } else {
            DispatchQueue.main.async { titreFocus = true }
        }
    }

    private func enregistrer() {
        let t = titre.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        let j: Int? = dateActive ? jour : nil
        let h: Date? = heureActive ? heure : nil
        if let id = rappelId, let i = magasin.rappels.firstIndex(where: { $0.id == id }) {
            magasin.rappels[i].titre = t
            magasin.rappels[i].note = note
            magasin.rappels[i].liste = liste
            magasin.rappels[i].urgent = urgent
            magasin.rappels[i].drapeau = drapeau
            if datesTouchees {
                magasin.rappels[i].programme = j != nil
                magasin.rappels[i].aujourdhui = j == 0
                magasin.rappels[i].jour = j
                magasin.rappels[i].sousTexte = RapDates.sousTexte(jour: j, heure: h)
            }
        } else {
            var r = Rappel(titre: t, liste: liste)
            r.note = note
            r.urgent = urgent
            r.drapeau = drapeau
            r.programme = j != nil
            r.aujourdhui = j == 0
            r.jour = j
            r.sousTexte = RapDates.sousTexte(jour: j, heure: h)
            magasin.rappels.append(r)
        }
        dismiss()
    }
}

// 041 : choix de la liste (« Le rappel sera créé dans « Rappels ». », section « Local »)
struct RapChoixListeVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    @Binding var liste: String

    init(liste: Binding<String>) { _liste = liste }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Le rappel sera créé dans « \(liste) ».")
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                Text("Local")
                    .font(.system(size: 20, weight: .bold)).foregroundStyle(Color.white)
                    .padding(.leading, 4).padding(.top, 28).padding(.bottom, 10)
                RapCarte {
                    ForEach(magasin.listes) { l in
                        VStack(spacing: 0) {
                            ligne(l)
                            if l.id != magasin.listes.last?.id { RapSeparateurFeuille(retrait: 58) }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .background(RapTeinte.fondFeuille)
        .navigationTitle("Liste")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func ligne(_ l: ListeRappels) -> some View {
        Button {
            liste = l.nom
            dismiss()
        } label: {
            HStack(spacing: 12) {
                RapPastille(couleur: Color(hex: l.couleur), symbole: l.symbole, taille: 30)
                Text(l.nom).font(.system(size: 17)).foregroundStyle(Color.white)
                Spacer(minLength: 8)
                if liste == l.nom {
                    Image(systemName: "checkmark").font(.system(size: 17, weight: .semibold)).foregroundStyle(RapTeinte.bleu)
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// « Détails » d'un rappel : urgent / drapeau (l'écran lui-même n'est pas dans la référence)
struct RapDetailsOptionsVue: View {
    @Binding var urgent: Bool
    @Binding var drapeau: Bool

    var body: some View {
        ScrollView {
            RapCarte {
                RapRangeBascule(symbole: "exclamationmark.circle.fill", teinteIcone: RapTeinte.rouge, nom: "Urgent", valeur: $urgent)
                RapSeparateurFeuille()
                RapRangeBascule(symbole: "flag.fill", teinteIcone: RapTeinte.orange, nom: "Avec drapeau", valeur: $drapeau)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(RapTeinte.fondFeuille)
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ============================================================ NOUVELLE LISTE (feuille 003) / DÉTAILS DE LA LISTE
struct RappelsNouvelleListeVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinRappels.partage
    var edition: String? = nil
    @State private var nom = ""
    @State private var couleur: UInt = 0x0A84FF
    @FocusState private var champFocus: Bool
    private let couleurs: [UInt] = [0xFF453A, 0xFF9F0A, 0xFFD60A, 0x30D15B, 0x0A84FF, 0xD57FF5, 0xC9A675]

    init(edition: String? = nil) { self.edition = edition }

    private var titrePage: String { edition == nil ? "Nouvelle liste" : "Détails de la liste" }

    private var symbole: String {
        if let e = edition, let l = magasin.listes.first(where: { $0.nom == e }) { return l.symbole }
        return "list.bullet"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    carteNom
                    carteCouleurs
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(RapTeinte.fondFeuille)
            .navigationTitle(titrePage)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(Color.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { enregistrer() } label: {
                        Image(systemName: "checkmark").fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(RapTeinte.bleuBouton)
                    .disabled(nom.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { charger() }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationBackground(RapTeinte.fondFeuille)
    }

    private var carteNom: some View {
        RapCarte {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color(hex: couleur))
                    .frame(width: 97, height: 97)
                    .overlay(
                        Circle().fill(LinearGradient(colors: [Color.white.opacity(0.22), Color.clear],
                                                     startPoint: .top, endPoint: .bottom)))
                    .overlay(Image(systemName: symbole)
                        .font(.system(size: 44, weight: .semibold)).foregroundStyle(Color.white))
                    .padding(.top, 20)
                TextField("", text: $nom,
                          prompt: Text("Nom de la liste").foregroundColor(Color(hex: 0x78787E)))
                    .focused($champFocus)
                    .disabled(edition != nil)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .frame(height: 57)
                    .background(RoundedRectangle(cornerRadius: 14).fill(RapTeinte.champ))
                    .padding(.horizontal, 16)
                    .padding(.top, 19)
                    .padding(.bottom, 16)
            }
        }
    }

    private var carteCouleurs: some View {
        RapCarte {
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    ForEach(0..<6, id: \.self) { i in
                        pastilleCouleur(couleurs[i])
                        if i < 5 { Spacer(minLength: 0) }
                    }
                }
                HStack(spacing: 0) {
                    pastilleCouleur(couleurs[6])
                    Spacer(minLength: 0)
                }
            }
            .padding(16)
        }
    }

    private func pastilleCouleur(_ c: UInt) -> some View {
        Circle().fill(Color(hex: c))
            .frame(width: 40, height: 40)
            .overlay(
                Circle().stroke(RapTeinte.anneau, lineWidth: 2.7)
                    .padding(-5.3)
                    .opacity(couleur == c ? 1 : 0))
            .contentShape(Circle())
            .onTapGesture { couleur = c }
    }

    private func charger() {
        if let e = edition, let l = magasin.listes.first(where: { $0.nom == e }) {
            nom = l.nom
            couleur = l.couleur
        } else {
            DispatchQueue.main.async { champFocus = true }
        }
    }

    private func enregistrer() {
        let n = nom.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { return }
        if let e = edition, let i = magasin.listes.firstIndex(where: { $0.nom == e }) {
            magasin.listes[i].couleur = couleur
        } else if !magasin.listes.contains(where: { $0.nom == n }) {
            magasin.listes.append(ListeRappels(nom: n, couleur: couleur, symbole: "list.bullet"))
        }
        dismiss()
    }
}
