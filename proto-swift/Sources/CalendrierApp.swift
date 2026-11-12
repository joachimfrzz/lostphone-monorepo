// Calendrier — refonte « indiscernable » contre les captures du simulateur de référence
// (iOS 26, iPhone 17, français, mode sombre — refs com.apple.mobilecal, 80 PNG, mesures à 3x).
// Structure : Jour (ouverture) → Mois → Année ; barre haute et barre basse en capsules ; feuilles
// Calendriers / Invitations / Nouveau ; recherche. Les feuilles sont des recouvrements internes (jamais .sheet,
// règle 10 : la BarreHome reste visible). Contenu d'exemple : CalendrierDonnees.swift (D59).
import SwiftUI

// ============================================================ MODÈLE
struct Evenement: Identifiable {
    let id = UUID()
    var titre: String
    var annee: Int
    var mois: Int
    var jour: Int
    var heure: Int?          // nil = journée entière
    var minute: Int = 0
    var duree: Int = 60      // minutes
    var couleur: UInt
    var lieu: String? = nil
    var calendrier: String = CalDonnees.nomPerso
    var symbole: String? = nil   // glyphe dans la pastille (étoile des fêtes, cadeau des anniversaires)
}

final class MagasinCalendrier: ObservableObject {
    static let partage = MagasinCalendrier()
    @Published var evenements: [Evenement] = CalDonnees.evenements()

    func pour(_ a: Int, _ m: Int, _ j: Int) -> [Evenement] {
        let etat = CalEtat.partage
        return evenements
            .filter { $0.annee == a && $0.mois == m && $0.jour == j && etat.estVisible($0.calendrier) }
            .sorted { ($0.heure ?? -1) < ($1.heure ?? -1) }
    }
    func duMois(_ a: Int, _ m: Int) -> [Evenement] {
        let etat = CalEtat.partage
        return evenements
            .filter { $0.annee == a && $0.mois == m && etat.estVisible($0.calendrier) }
            .sorted { ($0.jour, $0.heure ?? -1) < ($1.jour, $1.heure ?? -1) }
    }
}

// Le présent du jeu
let jeuAnnee = CalDonnees.anneeJeu
let jeuMois = CalDonnees.moisJeu
let jeuJour = CalDonnees.jourJeu

let nomsMois = ["", "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
                "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]

// Modes d'affichage du mois (menu du premier bouton de la capsule haute : Compact / Pile / Détails / Liste)
enum ModeAffichageCal: String, CaseIterable {
    case compact = "Compact"
    case pile = "Pile"
    case details = "Détails"
    case liste = "Liste"
    var symbole: String {
        switch self {
        case .compact: return "capsule"
        case .pile: return "rectangle.grid.1x2"
        case .details: return "rectangle.split.1x2"
        case .liste: return "list.bullet.below.rectangle"
        }
    }
}

// ============================================================ PALETTE (mesurée)
enum CalTeinte {
    static let capsule = Color(hex: 0x191919)          // 002 : (25,25,25) fond des capsules
    static let bordCapsule = Color(hex: 0x363636)      // 002 : (54,54,54) liseré
    static let separateur = Color(hex: 0x2A2A2C)       // 002 : (42,42,44) lignes de grille
    static let rouge = Color(hex: 0xFF4245)            // 002 : (255,66,69) aujourd'hui
    static let gris = Color(hex: 0x8E8E93)             // week-ends, heures
    static let grisTexte = Color(hex: 0x98989F)        // 013 : (152,152,159)
    static let feuille = Color(hex: 0x1C1C1E)          // 013 : (28,28,30)
    static let carte = Color(hex: 0x2C2C2E)            // 013 : (44,44,46)
    static let separateurCarte = Color(hex: 0x404043)  // 013 : (64,64,67)
    static let boutonRond = Color(hex: 0x252527)       // 005 : (37,37,39)
    static let boutonValider = Color(hex: 0x3A3A3C)
    static let segment = Color(hex: 0x303035)          // 005 : (49,49,54)
    static let segmentActif = Color(hex: 0x68686E)     // 005 : (104,104,110)
    static let segmentInvit = Color(hex: 0x464648)
    static let bandeau = Color(hex: 0x141416)          // 004 : bande de recherche
    static let vert = Color(hex: 0x30D158)             // 013 : (48,209,88)
    static let placeholder = Color(hex: 0x7C7C80)
    static let contourCoche = Color(hex: 0x636366)
}

// ============================================================ OUTILS DE DATES
struct CalDate: Equatable, Hashable {
    var a: Int
    var m: Int
    var j: Int
    var cle: String { "\(a)-\(m)" }
    static var aujourdhui: CalDate { CalDate(a: jeuAnnee, m: jeuMois, j: jeuJour) }
}

enum CalOutils {
    static let initiales: [String] = ["L", "M", "M", "J", "V", "S", "D"]
    static let annees: [Int] = [2025, 2026, 2027]

    static let moisListe: [CalDate] = {
        var l: [CalDate] = []
        for a in 2025...2027 {
            for m in 1...12 { l.append(CalDate(a: a, m: m, j: 1)) }
        }
        return l
    }()

    static func calendrier() -> Calendar {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        return c
    }

    static func date(_ d: CalDate) -> Date? {
        return calendrier().date(from: DateComponents(year: d.a, month: d.m, day: d.j))
    }

    static func moment(_ d: CalDate, _ heure: Int) -> Date {
        let c = DateComponents(year: d.a, month: d.m, day: d.j, hour: heure, minute: 0)
        return calendrier().date(from: c) ?? Date()
    }

    static func nbJours(_ a: Int, _ m: Int) -> Int {
        let cal = calendrier()
        guard let debut = cal.date(from: DateComponents(year: a, month: m, day: 1)),
              let r = cal.range(of: .day, in: .month, for: debut) else { return 30 }
        return r.count
    }

    // Colonne 0...6, lundi = 0
    static func colonne(_ d: CalDate) -> Int {
        guard let dt = date(d) else { return 0 }
        return (calendrier().component(.weekday, from: dt) + 5) % 7
    }

    static func semaines(_ a: Int, _ m: Int) -> [[Int?]] {
        let dec = colonne(CalDate(a: a, m: m, j: 1))
        var jours: [Int?] = Array(repeating: nil, count: dec)
        for j in 1...nbJours(a, m) { jours.append(j) }
        while jours.count % 7 != 0 { jours.append(nil) }
        var res: [[Int?]] = []
        var i = 0
        while i < jours.count {
            res.append(Array(jours[i..<(i + 7)]))
            i += 7
        }
        return res
    }

    static func ajouter(_ d: CalDate, jours: Int) -> CalDate {
        let cal = calendrier()
        guard let dt = date(d), let n = cal.date(byAdding: .day, value: jours, to: dt) else { return d }
        let c = cal.dateComponents([.year, .month, .day], from: n)
        return CalDate(a: c.year ?? d.a, m: c.month ?? d.m, j: c.day ?? d.j)
    }

    // « Mercredi - 4 nov. 2026 » (bandeau de la vue Jour)
    static func titreJour(_ d: CalDate) -> String {
        guard let dt = date(d) else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "EEEE - d MMM yyyy"
        let s = f.string(from: dt)
        return s.prefix(1).uppercased() + String(s.dropFirst())
    }

    // « lundi 17 août 2026 » (résultats de recherche)
    static func titreLong(_ d: CalDate) -> String {
        guard let dt = date(d) else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f.string(from: dt)
    }

    static func heureTexte(_ e: Evenement) -> String {
        guard let h = e.heure else { return "Jour entier" }
        return String(format: "%02d:%02d", h, e.minute)
    }

    static func plage(_ e: Evenement) -> String {
        guard let h = e.heure else { return "Jour entier" }
        let debut = h * 60 + e.minute
        let fin = debut + e.duree
        return String(format: "%02d:%02d – %02d:%02d", debut / 60, debut % 60, (fin / 60) % 24, fin % 60)
    }

    static func cleTri(_ e: Evenement) -> Int {
        let h = (e.heure ?? -1) + 1
        return (((e.annee * 100 + e.mois) * 100 + e.jour) * 100 + h) * 100 + e.minute
    }
}

// ============================================================ ÉTAT PARTAGÉ (feuilles, recherche, mode, calendriers cochés)
enum CalFeuille: Equatable {
    case aucune
    case creation
    case calendriers
    case invitations
}

enum CalNiveau {
    case annee
    case mois
    case jour
}

final class CalEtat: ObservableObject {
    static let partage = CalEtat()
    @Published var feuille: CalFeuille = .aucune
    @Published var recherche: Bool = false
    @Published var mode: ModeAffichageCal = .details
    @Published var calendriers: [CalCalendrier] = CalDonnees.calendriers()
    @Published var rappelsTermines: Bool = true
    @Published var jourCreation: CalDate = CalDate.aujourdhui
    var anneeChoisie: Int = jeuAnnee

    func estVisible(_ nom: String) -> Bool {
        guard let c = calendriers.first(where: { $0.nom == nom }) else { return true }
        return c.coche
    }

    func basculer(_ id: UUID) {
        if let i = calendriers.firstIndex(where: { $0.id == id }) {
            calendriers[i].coche.toggle()
        }
    }

    func ouvrirCreation(_ d: CalDate) {
        jourCreation = d
        feuille = .creation
    }

    func creerCalendrier(_ nom: String) {
        let n = nom.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { return }
        let palette: [UInt] = [0xFF9500, 0x34C759, 0xAF52DE, 0xFF2D55, 0x5AC8FA]
        let couleur = palette[calendriers.count % palette.count]
        calendriers.append(CalCalendrier(nom: n, couleur: couleur, groupe: 0))
    }

    func toutFermer() {
        feuille = .aucune
        recherche = false
        anneeChoisie = jeuAnnee
    }
}

// ============================================================ COMPOSANTS DE BARRES
struct CalFondCapsule: View {
    var body: some View {
        Capsule()
            .fill(CalTeinte.capsule)
            .overlay(Capsule().stroke(CalTeinte.bordCapsule, lineWidth: 1))
    }
}

// « < Novembre » (02 : x 16→108, h 44, chevron 17 semibold, libellé 17)
struct CalBoutonRetour: View {
    let titre: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                Text(titre).font(.system(size: 17))
            }
            .foregroundStyle(Color.white)
            .padding(.leading, 13).padding(.trailing, 17)
            .frame(height: 44)
            .background(CalFondCapsule())
        }
        .buttonStyle(.plain)
    }
}

// Capsule haute à droite : [affichage] [recherche] [+]  (002 : x 225→386, h 44 ; année : x 285→386)
struct CalBarreOutils: View {
    var avecMode: Bool = true
    var symboleMode: String = "rectangle.split.1x2"
    let creer: () -> Void
    @ObservedObject private var etat = CalEtat.partage

    var body: some View {
        HStack(spacing: 34) {
            if avecMode { boutonMode }
            Button { etat.recherche = true } label: {
                Image(systemName: "magnifyingglass").font(.system(size: 20))
            }
            Button(action: creer) {
                Image(systemName: "plus").font(.system(size: 21))
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.white)
        .tint(Color.white)
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(CalFondCapsule())
    }

    private var boutonMode: some View {
        Menu {
            Picker("", selection: $etat.mode) {
                ForEach([ModeAffichageCal.compact, ModeAffichageCal.pile, ModeAffichageCal.details], id: \.self) { m in
                    Label(m.rawValue, systemImage: m.symbole).tag(m)
                }
            }
            .pickerStyle(.inline)
            Picker("", selection: $etat.mode) {
                Label(ModeAffichageCal.liste.rawValue, systemImage: ModeAffichageCal.liste.symbole)
                    .tag(ModeAffichageCal.liste)
            }
            .pickerStyle(.inline)
        } label: {
            Image(systemName: symboleMode).font(.system(size: 20))
        }
    }
}

// Barre basse : [Aujourd’hui]  …  [calendrier | boîte de réception]  (002 : y 798→846)
struct CalBarreBasse: View {
    let aujourdhui: () -> Void
    @ObservedObject private var etat = CalEtat.partage

    var body: some View {
        HStack(spacing: 0) {
            Button {
                Haptique.leger()
                aujourdhui()
            } label: {
                Text("Aujourd’hui").font(.system(size: 17)).foregroundStyle(Color.white)
                    .padding(.horizontal, 21).frame(height: 48)
                    .background(CalFondCapsule())
            }
            Spacer(minLength: 0)
            HStack(spacing: 0) {
                Button { etat.feuille = .calendriers } label: {
                    Image(systemName: "calendar").font(.system(size: 22)).frame(width: 66, height: 48)
                }
                Button { etat.feuille = .invitations } label: {
                    Image(systemName: "tray").font(.system(size: 22)).frame(width: 61, height: 48)
                }
            }
            .foregroundStyle(Color.white)
            .background(CalFondCapsule())
        }
        .buttonStyle(.plain)
        .padding(.leading, 18).padding(.trailing, 28).padding(.bottom, 28)
    }
}

// Numéro de jour (18 pt, pastille 39 pt)
struct CalChiffre: View {
    let jour: Int
    let texte: Color
    let fond: Color
    var gras: Bool = false
    var body: some View {
        Text("\(jour)")
            .font(.system(size: 18, weight: gras ? Font.Weight.semibold : Font.Weight.medium))
            .foregroundStyle(texte)
            .frame(width: 39, height: 39)
            .background(Circle().fill(fond))
    }
}

// ============================================================ APP (racine)
struct CalendrierVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var etat = CalEtat.partage
    @State private var niveau: CalNiveau = .jour
    @State private var cible: CalDate = CalDate.aujourdhui
    @State private var alerteNouveau = false
    @State private var nomNouveau = ""
    let ouvrirRecherche: Bool
    let ouvrirCreation: Bool
    let feuilleInitiale: CalFeuille

    // Les paramètres ne servent qu'au mode capture (calendrier.nouveau, .recherche, .mois, .calendriers…)
    init(recherche: Bool = false, creation: Bool = false, feuille: CalFeuille = .aucune, niveau: CalNiveau = .jour) {
        self.ouvrirRecherche = recherche
        self.ouvrirCreation = creation
        self.feuilleInitiale = feuille
        _niveau = State(initialValue: niveau)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            niveauCourant
            if etat.feuille != .aucune {
                CalCoucheFeuille(nouveau: { alerteNouveau = true })
                    .transition(.move(edge: .bottom))
            }
            if etat.recherche {
                CalRechercheCouche(ouvrir: { d in allerAuJour(d) })
                    .transition(.opacity)
            }
            BarreHome { dismiss() }
        }
        .animation(.easeOut(duration: 0.28), value: etat.feuille)
        .animation(.easeOut(duration: 0.2), value: etat.recherche)
        .alert("Nouveau calendrier", isPresented: $alerteNouveau) {
            TextField("Nom du calendrier", text: $nomNouveau)
            Button("Annuler", role: .cancel) { nomNouveau = "" }
            Button("Créer") {
                etat.creerCalendrier(nomNouveau)
                nomNouveau = ""
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if ouvrirCreation { etat.ouvrirCreation(CalDate.aujourdhui) }
            if ouvrirRecherche { etat.recherche = true }
            if feuilleInitiale != .aucune { etat.feuille = feuilleInitiale }
        }
        .onDisappear { etat.toutFermer() }
    }

    @ViewBuilder
    private var niveauCourant: some View {
        switch niveau {
        case .annee:
            AnneeVue { m in
                cible = CalDate(a: etat.anneeChoisie, m: m, j: 1)
                withAnimation(.easeInOut(duration: 0.25)) { niveau = .mois }
            }
        case .mois:
            CalMoisEcran(depart: cible,
                         versAnnee: { a in
                             etat.anneeChoisie = a
                             withAnimation(.easeInOut(duration: 0.25)) { niveau = .annee }
                         },
                         versJour: { d in allerAuJour(d) })
        case .jour:
            JourVue(annee: cible.a, mois: cible.m, jour: cible.j, retour: { d in
                cible = d
                withAnimation(.easeInOut(duration: 0.25)) { niveau = .mois }
            })
            .id("\(cible.a)-\(cible.m)-\(cible.j)")
        }
    }

    private func allerAuJour(_ d: CalDate) {
        etat.recherche = false
        cible = d
        withAnimation(.easeInOut(duration: 0.25)) { niveau = .jour }
    }
}

// Écrans historiques appelés par le registre de capture (LPProto) : même racine, feuille déjà ouverte.
struct NouvelEvenementVue: View {
    var body: some View { CalendrierVue(creation: true) }
}

struct RechercheCalendrierVue: View {
    var body: some View { CalendrierVue(recherche: true) }
}

// ============================================================ VUE MOIS (défilement continu)
struct CalMoisEcran: View {
    let depart: CalDate
    let versAnnee: (Int) -> Void
    let versJour: (CalDate) -> Void
    @ObservedObject private var etat = CalEtat.partage
    @State private var visible: String? = nil
    @State private var allerAuj = 0

    private var courant: CalDate {
        let p = (visible ?? depart.cle).split(separator: "-")
        if p.count == 2, let a = Int(p[0]), let m = Int(p[1]) {
            return CalDate(a: a, m: m, j: 1)
        }
        return depart
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
            VStack(spacing: 0) {
                CalEnteteMois(date: courant,
                              retour: { versAnnee(courant.a) },
                              creer: { etat.ouvrirCreation(CalDate.aujourdhui) })
                defilement
            }
            .frame(maxHeight: .infinity, alignment: .top)
            CalBarreBasse(aujourdhui: { allerAuj += 1 })
        }
        .ignoresSafeArea()
    }

    private var defilement: some View {
        ScrollViewReader { lecteur in
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(0..<CalOutils.moisListe.count, id: \.self) { i in
                        CalBlocMois(date: CalOutils.moisListe[i], mode: etat.mode, ouvrir: versJour)
                            .id(CalOutils.moisListe[i].cle)
                    }
                }
                .scrollTargetLayout()
                .padding(.bottom, 150)
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $visible, anchor: .top)
            .onAppear {
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) { visible = depart.cle }
            }
            .onChange(of: allerAuj) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) { visible = CalDate.aujourdhui.cle }
            }
            .onChange(of: etat.mode) { _, _ in
                // changer de mode ne déplace pas la période consultée
                let cibleCle = visible ?? depart.cle
                DispatchQueue.main.async {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) {
                        lecteur.scrollTo(cibleCle, anchor: .top)
                        visible = cibleCle
                    }
                }
            }
            .simultaneousGesture(MagnificationGesture().onEnded { v in
                if v < 0.8 { versAnnee(courant.a) }
            })
        }
    }
}

// En-tête fixe : « < 2026 » + capsule d'outils, grand titre du mois, initiales des jours, filet (002)
struct CalEnteteMois: View {
    let date: CalDate
    let retour: () -> Void
    let creer: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                CalBoutonRetour(titre: "\(date.a)", action: retour)
                Spacer()
                CalBarreOutils(avecMode: true, symboleMode: CalEtat.partage.mode.symbole, creer: creer)
            }
            .padding(.horizontal, 16).padding(.top, 62)
            Text(nomsMois[date.m])
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.leading, 20).padding(.top, 15)
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { c in
                    Text(CalOutils.initiales[c])
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(c >= 5 ? CalTeinte.gris : Color.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 15).padding(.top, 7)
            Rectangle().fill(CalTeinte.separateur).frame(height: 1)
        }
        .background(Color.black)
    }
}

// Un mois : lignes de 119 pt (Détails/Pile) ou 66 pt (Compact/Liste), filet sur chaque jour existant
struct CalBlocMois: View {
    let date: CalDate
    let mode: ModeAffichageCal
    let ouvrir: (CalDate) -> Void
    @ObservedObject private var etat = CalEtat.partage
    @ObservedObject private var magasin = MagasinCalendrier.partage

    private var hauteurLigne: CGFloat {
        return (mode == .compact || mode == .liste) ? 66 : 119
    }

    var body: some View {
        let semaines = CalOutils.semaines(date.a, date.m)
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<semaines.count, id: \.self) { s in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<7, id: \.self) { c in
                        cellule(semaines[s][c], c)
                    }
                }
            }
            if mode == .liste {
                CalListeMois(date: date, ouvrir: ouvrir)
            }
        }
        .overlay(alignment: .topLeading) {
            titreInline.offset(y: -26)
        }
    }

    @ViewBuilder
    private func cellule(_ jour: Int?, _ c: Int) -> some View {
        if let j = jour {
            celluleJour(j, c)
        } else {
            Color.clear.frame(maxWidth: .infinity, minHeight: hauteurLigne, maxHeight: hauteurLigne)
        }
    }

    private func celluleJour(_ j: Int, _ c: Int) -> some View {
        let d = CalDate(a: date.a, m: date.m, j: j)
        let evts = magasin.pour(date.a, date.m, j)
        let present = d == CalDate.aujourdhui
        let couleurTexte: Color = present ? Color.white : (c >= 5 ? CalTeinte.gris : Color.white)
        let couleurFond: Color = present ? CalTeinte.rouge : Color.clear
        return VStack(spacing: 0) {
            Rectangle().fill(CalTeinte.separateur).frame(height: 1)
            CalChiffre(jour: j, texte: couleurTexte, fond: couleurFond, gras: present).padding(.top, 7)
            contenuEvenements(evts)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: hauteurLigne, maxHeight: hauteurLigne)
        .contentShape(Rectangle())
        .onTapGesture { ouvrir(d) }
    }

    @ViewBuilder
    private func contenuEvenements(_ evts: [Evenement]) -> some View {
        if mode == .details {
            VStack(spacing: 2) {
                ForEach(evts.prefix(3)) { e in
                    CalPastille(evenement: e)
                }
            }
            .padding(.top, 7).padding(.horizontal, 2)
        } else if mode == .pile {
            VStack(spacing: 3) {
                ForEach(evts.prefix(4)) { e in
                    Capsule().fill(Color(hex: e.couleur)).frame(height: 4)
                }
            }
            .padding(.top, 8).padding(.horizontal, 6)
        } else if !evts.isEmpty {
            HStack(spacing: 3) {
                ForEach(evts.prefix(3)) { e in
                    Circle().fill(Color(hex: e.couleur)).frame(width: 5, height: 5)
                }
            }
            .padding(.top, 3)
        }
    }

    // Nom du mois dans l'interligne, centré sur la colonne du 1er (020 : « Septembre »)
    private var libelleMois: some View {
        Text(nomsMois[date.m])
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(Color.white)
            .lineLimit(1)
    }

    private var titreInline: some View {
        let col = CalOutils.colonne(CalDate(a: date.a, m: date.m, j: 1))
        return HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { c in
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: 26)
                    .overlay(alignment: .center) {
                        if c == col && col <= 4 {
                            libelleMois.fixedSize()
                        }
                    }
            }
        }
        .overlay(alignment: .trailing) {
            if col > 4 {
                libelleMois.fixedSize().padding(.trailing, 12)
            }
        }
    }
}

// Pastille d'évènement du mois, mode Détails (020 : 53×16 pt, fond = couleur à 22 %)
struct CalPastille: View {
    let evenement: Evenement
    var body: some View {
        let c = Color(hex: evenement.couleur)
        HStack(spacing: 3) {
            icone(c)
            Text(evenement.titre)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(c)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 3)
        .frame(height: 16)
        .frame(maxWidth: .infinity)
        .background(Capsule().fill(c.opacity(0.22)))
        .clipShape(Capsule())
    }

    @ViewBuilder
    private func icone(_ c: Color) -> some View {
        if let s = evenement.symbole {
            ZStack {
                Circle().fill(c)
                Image(systemName: s).font(.system(size: 6, weight: .bold)).foregroundStyle(Color.black.opacity(0.75))
            }
            .frame(width: 11, height: 11)
        } else {
            Circle().fill(c).frame(width: 6, height: 6).frame(width: 11, height: 11)
        }
    }
}

// Mode Liste : évènements du mois sous la grille
struct CalListeMois: View {
    let date: CalDate
    let ouvrir: (CalDate) -> Void
    @ObservedObject private var magasin = MagasinCalendrier.partage
    @ObservedObject private var etat = CalEtat.partage

    var body: some View {
        let evts = magasin.duMois(date.a, date.m)
        VStack(alignment: .leading, spacing: 0) {
            if evts.isEmpty {
                Text("Aucun évènement").font(.system(size: 15)).foregroundStyle(CalTeinte.gris)
                    .padding(.vertical, 10)
            } else {
                ForEach(evts) { e in
                    ligne(e)
                }
            }
        }
        .padding(.top, 8).padding(.horizontal, 16)
    }

    private func ligne(_ e: Evenement) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Text("\(e.jour)").font(.system(size: 17, weight: .semibold)).foregroundStyle(CalTeinte.gris)
                    .frame(width: 28, alignment: .trailing)
                RoundedRectangle(cornerRadius: 2).fill(Color(hex: e.couleur)).frame(width: 3, height: 32)
                VStack(alignment: .leading, spacing: 1) {
                    Text(e.titre).font(.system(size: 17)).foregroundStyle(Color.white).lineLimit(1)
                    Text(CalOutils.heureTexte(e)).font(.system(size: 13)).foregroundStyle(CalTeinte.gris)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 7)
            .contentShape(Rectangle())
            .onTapGesture { ouvrir(CalDate(a: e.annee, m: e.mois, j: e.jour)) }
            Rectangle().fill(CalTeinte.separateur).frame(height: 1).padding(.leading, 38)
        }
    }
}

// ============================================================ VUE ANNÉE
struct AnneeVue: View {
    let ouvrirMois: (Int) -> Void
    @ObservedObject private var etat = CalEtat.partage
    @State private var visible: Int? = nil
    @State private var allerAuj = 0

    // ouvrirMois reçoit le numéro du mois touché ; l'année touchée est déposée dans CalEtat.partage.anneeChoisie
    init(ouvrirMois: @escaping (Int) -> Void) {
        self.ouvrirMois = ouvrirMois
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black
            VStack(spacing: 0) {
                Color.clear.frame(height: 113)
                defilement
            }
            .frame(maxHeight: .infinity, alignment: .top)
            LinearGradient(colors: [Color.black, Color.black.opacity(0)], startPoint: .top, endPoint: .bottom)
                .frame(height: 125)
                .allowsHitTesting(false)
            HStack {
                Spacer()
                CalBarreOutils(avecMode: false, creer: { etat.ouvrirCreation(CalDate.aujourdhui) })
            }
            .padding(.horizontal, 16).padding(.top, 62)
            VStack {
                Spacer()
                CalBarreBasse(aujourdhui: { allerAuj += 1 })
            }
        }
        .ignoresSafeArea()
    }

    private var defilement: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(CalOutils.annees, id: \.self) { a in
                    CalSectionAnnee(annee: a, ouvrirMois: { m in
                        etat.anneeChoisie = a
                        ouvrirMois(m)
                    })
                    .id(a)
                }
            }
            .scrollTargetLayout()
            .padding(.bottom, 150)
        }
        .scrollIndicators(.hidden)
        .scrollPosition(id: $visible, anchor: .top)
        .onAppear {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) { visible = etat.anneeChoisie }
        }
        .onChange(of: allerAuj) { _, _ in
            withAnimation(.easeInOut(duration: 0.3)) { visible = jeuAnnee }
        }
        .simultaneousGesture(MagnificationGesture().onEnded { v in
            if v > 1.25 { ouvrirMois(jeuMois) }
        })
    }
}

// Une année : titre 34 pt, filet, 4 lignes de 3 mois (pas de 150 pt) — 015
struct CalSectionAnnee: View {
    let annee: Int
    let ouvrirMois: (Int) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(annee)")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(annee == jeuAnnee ? CalTeinte.rouge : Color.white)
                .padding(.leading, 22)
                .frame(height: 39, alignment: .bottom)
            Rectangle().fill(CalTeinte.separateur).frame(height: 1).padding(.horizontal, 22)
            VStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { r in
                    HStack(alignment: .top, spacing: 7) {
                        ForEach(0..<3, id: \.self) { c in
                            MiniMois(annee: annee, mois: r * 3 + c + 1)
                                .contentShape(Rectangle())
                                .onTapGesture { ouvrirMois(r * 3 + c + 1) }
                        }
                    }
                    .frame(height: 150, alignment: .top)
                }
            }
            .padding(.horizontal, 22).padding(.top, 14)
        }
        .padding(.top, 19)
    }
}

struct MiniMois: View {
    let annee: Int
    let mois: Int
    private var estCourant: Bool { annee == jeuAnnee && mois == jeuMois }

    var body: some View {
        let semaines = CalOutils.semaines(annee, mois)
        VStack(alignment: .leading, spacing: 3) {
            Text(nomsMois[mois])
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(estCourant ? CalTeinte.rouge : Color.white)
                .lineLimit(1)
            VStack(spacing: 0) {
                ForEach(0..<semaines.count, id: \.self) { s in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { c in
                            cellule(semaines[s][c])
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func cellule(_ jour: Int?) -> some View {
        if let j = jour {
            let present = estCourant && j == jeuJour
            Text("\(j)")
                .font(.system(size: 10, weight: present ? Font.Weight.bold : Font.Weight.regular))
                .foregroundStyle(Color.white)
                .frame(width: 16, height: 16)
                .background(Circle().fill(present ? CalTeinte.rouge : Color.clear))
                .frame(maxWidth: .infinity)
                .frame(height: 17.5)
        } else {
            Color.clear.frame(maxWidth: .infinity).frame(height: 17.5)
        }
    }
}

// ============================================================ VUE JOUR
struct JourVue: View {
    let retour: ((CalDate) -> Void)?
    @ObservedObject private var etat = CalEtat.partage
    @ObservedObject private var magasin = MagasinCalendrier.partage
    @State private var choisi: CalDate

    init(annee: Int, mois: Int, jour: Int, retour: ((CalDate) -> Void)? = nil) {
        self.retour = retour
        _choisi = State(initialValue: CalDate(a: annee, m: mois, j: jour))
    }

    private var evts: [Evenement] { magasin.pour(choisi.a, choisi.m, choisi.j) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
            VStack(spacing: 0) {
                entete
                defilement
            }
            .frame(maxHeight: .infinity, alignment: .top)
            CalBarreBasse(aujourdhui: { choisi = CalDate.aujourdhui })
        }
        .ignoresSafeArea()
    }

    // — En-tête : capsules, initiales, jours de la semaine, bandeau de date (001 : filets à 183 et 219 pt)
    private var entete: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                CalBoutonRetour(titre: nomsMois[choisi.m], action: {
                    if let r = retour { r(choisi) }
                })
                Spacer()
                CalBarreOutils(avecMode: true, symboleMode: "list.bullet.below.rectangle",
                               creer: { etat.ouvrirCreation(choisi) })
            }
            .padding(.horizontal, 16).padding(.top, 62)
            bandeSemaine
            Rectangle().fill(CalTeinte.separateur).frame(height: 1)
            Text(CalOutils.titreJour(choisi))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 35)
            Rectangle().fill(CalTeinte.separateur).frame(height: 1)
        }
        .background(Color.black)
    }

    private var bandeSemaine: some View {
        let lundi = CalOutils.ajouter(choisi, jours: -CalOutils.colonne(choisi))
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { c in
                    Text(CalOutils.initiales[c])
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(c >= 5 ? CalTeinte.gris : Color.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 12).padding(.top, 12)
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { c in
                    chiffre(CalOutils.ajouter(lundi, jours: c), c)
                }
            }
            .padding(.top, 4).padding(.bottom, 9)
        }
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 24).onEnded { v in
            if v.translation.width < -40 { decaler(7) }
            else if v.translation.width > 40 { decaler(-7) }
        })
    }

    private func chiffre(_ d: CalDate, _ c: Int) -> some View {
        let estAuj = d == CalDate.aujourdhui
        let estSel = d == choisi
        var texte: Color = c >= 5 ? CalTeinte.gris : Color.white
        var fond: Color = Color.clear
        if estSel && estAuj {
            texte = Color.white
            fond = CalTeinte.rouge
        } else if estSel {
            texte = Color.black
            fond = Color.white
        } else if estAuj {
            texte = CalTeinte.rouge
        }
        return CalChiffre(jour: d.j, texte: texte, fond: fond, gras: estSel)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) { choisi = d }
            }
    }

    private func decaler(_ n: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            choisi = CalOutils.ajouter(choisi, jours: n)
        }
    }

    // — Grille des heures (50 pt par heure, filet à x = 63 pt, libellés alignés à droite jusqu'à 53 pt)
    private var defilement: some View {
        ScrollViewReader { lecteur in
            ScrollView {
                VStack(spacing: 0) {
                    journeeEntiere
                    CalGrilleHeures(evenements: evts.filter { $0.heure != nil },
                                    maintenant: choisi == CalDate.aujourdhui)
                }
                .padding(.bottom, 150)
            }
            .scrollIndicators(.hidden)
            .simultaneousGesture(DragGesture(minimumDistance: 30).onEnded { v in
                let h = abs(v.translation.height)
                if v.translation.width < -70 && h < 40 { decaler(1) }
                else if v.translation.width > 70 && h < 40 { decaler(-1) }
            })
            .onAppear {
                let heure = choisi == CalDate.aujourdhui ? 3 : 4
                DispatchQueue.main.async { lecteur.scrollTo(heure, anchor: .top) }
            }
        }
    }

    @ViewBuilder
    private var journeeEntiere: some View {
        let jour = evts.filter { $0.heure == nil }
        if !jour.isEmpty {
            VStack(spacing: 4) {
                ForEach(jour) { e in
                    CalBandeJourEntier(evenement: e)
                }
            }
            .padding(.horizontal, 16).padding(.top, 8)
        }
    }
}

struct CalBandeJourEntier: View {
    let evenement: Evenement
    var body: some View {
        let c = Color(hex: evenement.couleur)
        HStack(spacing: 6) {
            Circle().fill(c).frame(width: 8, height: 8)
            Text(evenement.titre).font(.system(size: 13, weight: .semibold)).foregroundStyle(c).lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 26)
        .background(RoundedRectangle(cornerRadius: 7).fill(c.opacity(0.22)))
    }
}

struct CalGrilleHeures: View {
    let evenements: [Evenement]
    let maintenant: Bool

    private var yMaintenant: CGFloat {
        return CGFloat(CalDonnees.maintenantMinutes) / 60 * 50
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(0..<24, id: \.self) { h in
                    ligneHeure(h)
                }
            }
            ForEach(evenements) { e in
                CalBlocHoraire(evenement: e)
            }
            if maintenant {
                repereMaintenant
            }
        }
        .padding(.top, 12)
    }

    private func ligneHeure(_ h: Int) -> some View {
        ZStack(alignment: .topLeading) {
            Rectangle().fill(CalTeinte.separateur).frame(height: 1).padding(.leading, 63)
            Text(String(format: "%02d:00", h))
                .font(.system(size: 11.5))
                .foregroundStyle(CalTeinte.gris)
                .frame(width: 53, alignment: .trailing)
                .offset(y: -7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50, alignment: .topLeading)
    }

    private var repereMaintenant: some View {
        HStack(spacing: 0) {
            Text(CalDonnees.heureAffichee)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 41, height: 16)
                .background(Capsule().fill(CalTeinte.rouge))
            Rectangle().fill(CalTeinte.rouge).frame(height: 2)
        }
        .padding(.leading, 17)
        .offset(y: yMaintenant - 8)
    }
}

struct CalBlocHoraire: View {
    let evenement: Evenement

    private var hauteur: CGFloat {
        return max(CGFloat(evenement.duree) / 60 * 50 - 1, 24)
    }
    private var decalage: CGFloat {
        return CGFloat((evenement.heure ?? 0) * 60 + evenement.minute) / 60 * 50
    }
    private var sousTitre: String {
        if let l = evenement.lieu { return CalOutils.plage(evenement) + " · " + l }
        return CalOutils.plage(evenement)
    }

    var body: some View {
        let c = Color(hex: evenement.couleur)
        VStack(alignment: .leading, spacing: 1) {
            Text(evenement.titre).font(.system(size: 12, weight: .semibold)).foregroundStyle(c).lineLimit(1)
            if hauteur > 36 {
                Text(sousTitre).font(.system(size: 11)).foregroundStyle(c.opacity(0.85)).lineLimit(1)
            }
        }
        .padding(.leading, 9).padding(.trailing, 6).padding(.top, 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 6).fill(c.opacity(0.22)))
        .overlay(alignment: .leading) {
            Rectangle().fill(c).frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .frame(height: hauteur)
        .padding(.leading, 66).padding(.trailing, 8)
        .offset(y: decalage)
    }
}

// ============================================================ FEUILLES (recouvrements internes, jamais .sheet)
struct CalHabillageFeuille<Contenu: View>: View {
    let contenu: Contenu
    init(@ViewBuilder contenu: () -> Contenu) {
        self.contenu = contenu()
    }
    var body: some View {
        contenu
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(CalTeinte.feuille)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 38, bottomLeadingRadius: 0,
                                              bottomTrailingRadius: 0, topTrailingRadius: 38))
            .padding(.top, 62)
    }
}

struct CalCoucheFeuille: View {
    let nouveau: () -> Void
    @ObservedObject private var etat = CalEtat.partage

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.4)
                .contentShape(Rectangle())
                .onTapGesture { }
            CalHabillageFeuille(contenu: { contenuFeuille })
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var contenuFeuille: some View {
        switch etat.feuille {
        case .creation:
            CalFeuilleCreation(jour: etat.jourCreation, fermer: { etat.feuille = .aucune })
        case .calendriers:
            CalFeuilleCalendriers(nouveau: nouveau)
        case .invitations:
            CalFeuilleInvitations()
        case .aucune:
            EmptyView()
        }
    }
}

struct CalBoutonRond: View {
    let symbole: String
    let fond: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: symbole)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(fond))
                .overlay(Circle().stroke(CalTeinte.bordCapsule, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// Ligne d'en-tête : (X) à gauche, centre libre, (✓) optionnel à droite — 013 : X en (16, 78), 44 pt
struct CalEnteteFeuille<Centre: View>: View {
    let fermer: () -> Void
    let valider: (() -> Void)?
    let valideActif: Bool
    let centre: Centre

    init(fermer: @escaping () -> Void, valider: (() -> Void)? = nil, valideActif: Bool = true,
         @ViewBuilder centre: () -> Centre) {
        self.fermer = fermer
        self.valider = valider
        self.valideActif = valideActif
        self.centre = centre()
    }

    var body: some View {
        ZStack {
            centre
            HStack {
                CalBoutonRond(symbole: "xmark", fond: CalTeinte.boutonRond, action: fermer)
                Spacer()
                if let v = valider {
                    CalBoutonRond(symbole: "checkmark",
                                  fond: valideActif ? CalTeinte.rouge : CalTeinte.boutonValider,
                                  action: v)
                }
            }
        }
        .padding(.horizontal, 16).padding(.top, 16)
        .frame(height: 60, alignment: .top)
    }
}

// — Calendriers (013 / 016)
struct CalFeuilleCalendriers: View {
    let nouveau: () -> Void
    @ObservedObject private var etat = CalEtat.partage
    @State private var plieIphone = false
    @State private var plieAutres = false

    var body: some View {
        VStack(spacing: 0) {
            CalEnteteFeuille(fermer: { etat.feuille = .aucune }, centre: {
                Text("Calendriers").font(.system(size: 17, weight: .semibold)).foregroundStyle(Color.white)
            })
            ScrollView {
                VStack(spacing: 0) {
                    CalTitreSection(titre: "Sur mon iPhone", plie: plieIphone, hauteur: 50, bas: 9,
                                    action: { plieIphone.toggle() })
                    if !plieIphone {
                        CalCarteCalendriers(lignes: etat.calendriers.filter { $0.groupe == 0 },
                                            basculer: { id in etat.basculer(id) })
                    }
                    CalTitreSection(titre: "Autres", plie: plieAutres, hauteur: 58, bas: 15,
                                    action: { plieAutres.toggle() })
                    if !plieAutres {
                        CalCarteCalendriers(lignes: etat.calendriers.filter { $0.groupe == 1 },
                                            basculer: { id in etat.basculer(id) })
                    }
                    ligneRappels.padding(.top, 35)
                    boutonNouveau.padding(.top, 35)
                }
                .padding(.bottom, 80)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var ligneRappels: some View {
        HStack {
            Text("Afficher les rappels terminés").font(.system(size: 17)).foregroundStyle(Color.white)
            Spacer(minLength: 8)
            Toggle("", isOn: $etat.rappelsTermines).labelsHidden().tint(CalTeinte.vert)
        }
        .padding(.horizontal, 17)
        .frame(height: 52)
        .background(RoundedRectangle(cornerRadius: 26).fill(CalTeinte.carte))
        .padding(.horizontal, 16)
    }

    private var boutonNouveau: some View {
        Button(action: nouveau) {
            HStack(spacing: 14) {
                Image(systemName: "calendar.badge.plus").font(.system(size: 20))
                Text("Nouv. calendrier").font(.system(size: 17))
                Spacer(minLength: 0)
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 20)
            .frame(height: 52)
            .background(RoundedRectangle(cornerRadius: 26).fill(CalTeinte.carte))
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}

struct CalTitreSection: View {
    let titre: String
    let plie: Bool
    let hauteur: CGFloat
    let bas: CGFloat
    let action: () -> Void
    var body: some View {
        HStack {
            Text(titre).font(.system(size: 17, weight: .semibold)).foregroundStyle(CalTeinte.grisTexte)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CalTeinte.rouge)
                .rotationEffect(.degrees(plie ? -90 : 0))
        }
        .padding(.leading, 33).padding(.trailing, 32)
        .padding(.bottom, bas)
        .frame(height: hauteur, alignment: .bottom)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) { action() }
        }
    }
}

struct CalCarteCalendriers: View {
    let lignes: [CalCalendrier]
    let basculer: (UUID) -> Void
    var body: some View {
        VStack(spacing: 0) {
            ForEach(lignes) { l in
                CalLigneCalendrier(calendrier: l, premiere: l.id == lignes.first?.id, basculer: { basculer(l.id) })
            }
        }
        .background(RoundedRectangle(cornerRadius: 26).fill(CalTeinte.carte))
        .padding(.horizontal, 16)
    }
}

struct CalLigneCalendrier: View {
    let calendrier: CalCalendrier
    let premiere: Bool
    let basculer: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if !premiere {
                Rectangle().fill(CalTeinte.separateurCarte).frame(height: 1)
                    .padding(.leading, 56).padding(.trailing, 17)
            }
            HStack(spacing: 0) {
                coche.padding(.trailing, 17)
                if calendrier.cadeau {
                    Image(systemName: "gift").font(.system(size: 15)).foregroundStyle(CalTeinte.rouge)
                        .padding(.trailing, 7)
                }
                libelle
                Spacer(minLength: 8)
                if calendrier.info {
                    Image(systemName: "info.circle").font(.system(size: 22, weight: .light))
                        .foregroundStyle(CalTeinte.rouge)
                }
            }
            .padding(.horizontal, 17).padding(.vertical, 14)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
            .onTapGesture { basculer() }
        }
    }

    private var coche: some View {
        ZStack {
            Circle().fill(calendrier.coche ? Color(hex: calendrier.couleur) : Color.clear)
            Circle().stroke(calendrier.coche ? Color.clear : CalTeinte.contourCoche, lineWidth: 1.5)
            if calendrier.coche {
                Image(systemName: "checkmark").font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.7))
            }
        }
        .frame(width: 22, height: 22)
    }

    private var libelle: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(calendrier.nom).font(.system(size: 17)).foregroundStyle(Color.white)
            if let s = calendrier.sousTitre {
                Text(s).font(.system(size: 17)).foregroundStyle(CalTeinte.grisTexte)
            }
        }
    }
}

// — Boîte de réception (014)
struct CalFeuilleInvitations: View {
    @ObservedObject private var etat = CalEtat.partage
    @State private var onglet = 0

    var body: some View {
        VStack(spacing: 0) {
            CalEnteteFeuille(fermer: { etat.feuille = .aucune }, centre: {
                CalSegmentInvitations(onglet: $onglet)
            })
            Text(onglet == 0 ? "Aucune invitation" : "Aucune réponse")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.white)
                .padding(.top, 354)
        }
    }
}

struct CalSegmentInvitations: View {
    @Binding var onglet: Int
    var body: some View {
        HStack(spacing: 0) {
            segment("Nouvelles", 0, 78)
            segment("Réponses", 1, 86)
        }
        .padding(4)
        .frame(width: 172, height: 47)
        .background(CalFondCapsule())
    }

    private func segment(_ titre: String, _ i: Int, _ largeur: CGFloat) -> some View {
        Text(titre)
            .font(.system(size: 17))
            .foregroundStyle(Color.white)
            .frame(width: largeur, height: 39)
            .background(Capsule().fill(onglet == i ? CalTeinte.segmentInvit : Color.clear))
            .contentShape(Capsule())
            .onTapGesture { onglet = i }
    }
}

// — Nouveau (005 / 017) : Évènement | Rappel
struct CalFeuilleCreation: View {
    let fermer: () -> Void
    @State private var rappel = false
    @State private var titre = ""
    @State private var lieu = ""
    @State private var toutelaJournee = false
    @State private var debut: Date
    @State private var fin: Date
    @State private var trajet = "Aucun"
    @FocusState private var titreActif: Bool

    init(jour: CalDate, fermer: @escaping () -> Void) {
        self.fermer = fermer
        let heure = jour == CalDate.aujourdhui ? 10 : 9
        let d = CalOutils.moment(jour, heure)
        _debut = State(initialValue: d)
        _fin = State(initialValue: d.addingTimeInterval(3600))
    }

    private var titreVide: Bool {
        return titre.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            CalEnteteFeuille(fermer: fermer, valider: { enregistrer() }, valideActif: !titreVide, centre: {
                Text("Nouveau").font(.system(size: 17, weight: .semibold)).foregroundStyle(Color.white)
            })
            segment.padding(.horizontal, 16).padding(.top, 10)
            ScrollView {
                VStack(spacing: 36) {
                    carteTitre
                    carteDates
                }
                .padding(.horizontal, 20).padding(.top, 30).padding(.bottom, 300)
            }
            .scrollIndicators(.hidden)
        }
        .onChange(of: debut) { _, nouveau in
            if fin <= nouveau { fin = nouveau.addingTimeInterval(3600) }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { titreActif = true }
        }
    }

    private var segment: some View {
        HStack(spacing: 0) {
            casSegment("Évènement", false)
            casSegment("Rappel", true)
        }
        .padding(2)
        .frame(height: 32)
        .background(Capsule().fill(CalTeinte.segment))
    }

    private func casSegment(_ t: String, _ valeur: Bool) -> some View {
        Text(t)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Capsule().fill(rappel == valeur ? CalTeinte.segmentActif : Color.clear))
            .contentShape(Capsule())
            .onTapGesture { rappel = valeur }
    }

    private var carteTitre: some View {
        VStack(spacing: 0) {
            TextField("", text: $titre, prompt: Text("Titre").foregroundColor(CalTeinte.placeholder))
                .focused($titreActif)
                .tint(CalTeinte.rouge)
                .foregroundStyle(Color.white)
                .font(.system(size: 17))
                .frame(height: 51).padding(.horizontal, 16)
            separateur
            TextField("", text: $lieu,
                      prompt: Text(rappel ? "Notes" : "Lieu ou appel vidéo").foregroundColor(CalTeinte.placeholder))
                .tint(CalTeinte.rouge)
                .foregroundStyle(Color.white)
                .font(.system(size: 17))
                .frame(height: 51).padding(.horizontal, 16)
        }
        .background(RoundedRectangle(cornerRadius: 26).fill(CalTeinte.carte))
    }

    private var carteDates: some View {
        VStack(spacing: 0) {
            ligne("Jour entier") {
                Toggle("", isOn: $toutelaJournee).labelsHidden().tint(CalTeinte.vert)
            }
            separateur
            ligne("Début") { selecteurs($debut) }
            if !rappel {
                separateur
                ligne("Fin") { selecteurs($fin) }
                separateur
                ligne("Temps de trajet") { menuTrajet }
            }
        }
        .background(RoundedRectangle(cornerRadius: 26).fill(CalTeinte.carte))
    }

    private var separateur: some View {
        Rectangle().fill(CalTeinte.separateurCarte).frame(height: 1).padding(.horizontal, 16)
    }

    private func ligne<D: View>(_ t: String, @ViewBuilder droite: () -> D) -> some View {
        HStack {
            Text(t).font(.system(size: 17)).foregroundStyle(Color.white)
            Spacer(minLength: 8)
            droite()
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }

    private func selecteurs(_ date: Binding<Date>) -> some View {
        HStack(spacing: 8) {
            DatePicker("", selection: date, displayedComponents: .date)
            if !toutelaJournee {
                DatePicker("", selection: date, displayedComponents: .hourAndMinute)
            }
        }
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "fr_FR"))
        .tint(CalTeinte.rouge)
        .fixedSize()
    }

    private var menuTrajet: some View {
        Menu {
            ForEach(["Aucun", "5 minutes", "15 minutes", "30 minutes", "1 heure"], id: \.self) { t in
                Button(t) { trajet = t }
            }
        } label: {
            HStack(spacing: 4) {
                Text(trajet).font(.system(size: 17)).foregroundStyle(CalTeinte.grisTexte)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CalTeinte.grisTexte)
            }
        }
    }

    private func enregistrer() {
        guard !titreVide else { return }
        let t = titre.trimmingCharacters(in: .whitespaces)
        let c = CalOutils.calendrier().dateComponents([.year, .month, .day, .hour, .minute], from: debut)
        let minutes = min(max(15, Int(fin.timeIntervalSince(debut) / 60)), 24 * 60)
        let h: Int? = toutelaJournee ? nil : (c.hour ?? 9)
        let l = lieu.trimmingCharacters(in: .whitespaces)
        let lieuFinal: String? = l.isEmpty ? nil : l
        let nomCal: String = rappel ? CalDonnees.nomRappels : CalDonnees.nomPerso
        MagasinCalendrier.partage.evenements.append(
            Evenement(titre: t, annee: c.year ?? jeuAnnee, mois: c.month ?? jeuMois, jour: c.day ?? jeuJour,
                      heure: h, minute: c.minute ?? 0, duree: minutes,
                      couleur: CalDonnees.couleurPerso, lieu: lieuFinal, calendrier: nomCal))
        titreActif = false
        fermer()
    }
}

// ============================================================ RECHERCHE (004)
struct CalRechercheCouche: View {
    let ouvrir: (CalDate) -> Void
    @ObservedObject private var etat = CalEtat.partage
    @ObservedObject private var magasin = MagasinCalendrier.partage
    @State private var texte = ""
    @FocusState private var actif: Bool

    private var texteNet: String {
        return texte.trimmingCharacters(in: .whitespaces)
    }

    private var resultats: [Evenement] {
        let t = texteNet
        guard !t.isEmpty else { return [] }
        let trouves = magasin.evenements.filter { e in
            let dansTitre = e.titre.localizedCaseInsensitiveContains(t)
            let dansLieu = (e.lieu ?? "").localizedCaseInsensitiveContains(t)
            return (dansTitre || dansLieu) && etat.estVisible(e.calendrier)
        }
        return trouves.sorted { CalOutils.cleTri($0) < CalOutils.cleTri($1) }
    }

    var body: some View {
        ZStack(alignment: .top) {
            fond
            if !texteNet.isEmpty {
                contenuResultats
            }
            bandeau
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { actif = true }
        }
    }

    @ViewBuilder
    private var fond: some View {
        if texteNet.isEmpty {
            Color.black.opacity(0.12).contentShape(Rectangle()).onTapGesture { }
        } else {
            Color.black.contentShape(Rectangle()).onTapGesture { }
        }
    }

    private var bandeau: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                champ
                CalBoutonRond(symbole: "xmark", fond: CalTeinte.capsule, action: { fermer() })
            }
            .padding(.horizontal, 16).padding(.top, 58).padding(.bottom, 15)
            .frame(maxWidth: .infinity)
            .background(CalTeinte.bandeau)
            Spacer()
        }
    }

    private var champ: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").font(.system(size: 18)).foregroundStyle(CalTeinte.gris)
            TextField("", text: $texte, prompt: Text("Recherche").foregroundColor(CalTeinte.placeholder))
                .focused($actif)
                .tint(CalTeinte.rouge)
                .foregroundStyle(Color.white)
                .font(.system(size: 17))
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(CalFondCapsule())
    }

    private var contenuResultats: some View {
        ScrollView {
            if resultats.isEmpty {
                Text("Aucun résultat").font(.system(size: 20, weight: .semibold)).foregroundStyle(Color.white)
                    .padding(.top, 200)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(resultats) { e in
                        ligne(e)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 125)
        .scrollIndicators(.hidden)
    }

    private func ligne(_ e: Evenement) -> some View {
        let d = CalDate(a: e.annee, m: e.mois, j: e.jour)
        return Button {
            texte = ""
            ouvrir(d)
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: e.couleur)).frame(width: 4, height: 38)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(e.titre).font(.system(size: 17)).foregroundStyle(Color.white).lineLimit(1)
                        Text(CalOutils.titreLong(d) + " · " + CalOutils.heureTexte(e))
                            .font(.system(size: 13)).foregroundStyle(CalTeinte.gris).lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 9)
                Rectangle().fill(CalTeinte.separateur).frame(height: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func fermer() {
        texte = ""
        actif = false
        etat.recherche = false
    }
}
