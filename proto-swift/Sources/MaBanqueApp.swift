// Ma Banque — app BANCAIRE FICTIVE (aucune référence à filmer : c'est la banque du jeu).
// Style calé sur les captures validées P57 (virement refusé plafond) et P58 (RIB) : LCL, bleu #00184D.
// R3 : le RIB, le refus de virement, le bénéficiaire OKAFOR, le RDV Bellecour 11h30 — tout se recoupe.
// D51 : utilisable de A à Z (virement simulable avec vrai refus de plafond, historique vivant).
// v3 02/09 (retours Joachim, session 4) : virement = conséquence RÉELLE et PERSISTANTE sur le solde (affiché
// immédiatement, « Solde après opération » dans la confirmation) ; le pavé numérique se ferme d'un tap ailleurs
// ou par « OK » ; détail d'une opération au tap (référence, catégorie, solde après) ; Partager le RIB réel.
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct Operation: Identifiable {
    let id = UUID()
    var libelle: String
    var sousLibelle: String
    var date: String
    var montant: Double        // négatif = débit
    var refusee: Bool = false
    var reference: String = ""
    var categorie: String = ""
}

final class MagasinBanque: ObservableObject {
    static let partage = MagasinBanque()
    @Published var soldeCourant: Double = 132.60
    @Published var soldeLivretA: Double = 85.00
    @Published var operations: [Operation] = [
        Operation(libelle: "VIREMENT ÉMIS", sousLibelle: "M. OKAFOR AGENT MARITIME — CAUTION + FRAIS AGENT",
                  date: "16/08/2026", montant: -4850.00, refusee: true, reference: "VIR-2608160921-7845", categorie: "Virement externe (SEPA)"),
        Operation(libelle: "VIREMENT REÇU", sousLibelle: "Depuis Livret A",
                  date: "15/08/2026", montant: 3000.00, reference: "VIR-2608151902-3310", categorie: "Virement interne"),
        Operation(libelle: "RETRAIT DAB", sousLibelle: "LCL BELLECOUR 15/08 18:32",
                  date: "15/08/2026", montant: -300.00, reference: "DAB-00550-1832", categorie: "Retrait d'espèces"),
        Operation(libelle: "CARTE", sousLibelle: "PHARMACIE DU PARC LYON",
                  date: "12/08/2026", montant: -23.90, reference: "CB-4417-120826-01", categorie: "Santé"),
        Operation(libelle: "CARTE", sousLibelle: "CARREFOUR CITY LYON 1ER",
                  date: "11/08/2026", montant: -41.37, reference: "CB-4417-110826-02", categorie: "Alimentation"),
        Operation(libelle: "PRLV SEPA", sousLibelle: "LOYER AGENCE BEAULIEU IMMO",
                  date: "05/08/2026", montant: -745.00, reference: "PRLV-FR12ZZZ405-0805", categorie: "Logement"),
        Operation(libelle: "VIREMENT REÇU", sousLibelle: "SALAIRE — ATELIER GRAPHIK LYON",
                  date: "01/08/2026", montant: 2180.00, reference: "VIR-SAL-072026", categorie: "Revenus"),
        Operation(libelle: "CARTE", sousLibelle: "KINÉ M. DUPRÉ — TIERS PAYANT",
                  date: "23/07/2026", montant: -8.50, reference: "CB-4417-230726-01", categorie: "Santé"),
        Operation(libelle: "VIREMENT REÇU", sousLibelle: "Depuis Livret A",
                  date: "20/07/2026", montant: 2000.00, reference: "VIR-2607201044-3310", categorie: "Virement interne"),
        Operation(libelle: "CARTE", sousLibelle: "WESTERN UNION LYON PART-DIEU",
                  date: "13/06/2026", montant: -850.00, reference: "CB-4417-130626-01", categorie: "Transfert d'argent"),
        Operation(libelle: "VIREMENT ÉMIS", sousLibelle: "M. OKAFOR AGENT MARITIME — CONNEXION SATELLITE",
                  date: "08/05/2026", montant: -300.00, reference: "VIR-2605081547-7845", categorie: "Virement externe (SEPA)"),
    ]
    @Published var beneficiaires: [(String, String)] = [
        ("M. OKAFOR AGENT MARITIME", "FR76 •••• •••• •••• 5308"),
        ("Maman", "FR76 •••• •••• •••• 1174"),
        ("Chloé", "FR76 •••• •••• •••• 8842"),
    ]
    let plafondVirement7j: Double = 3000
    @Published var virementsSur7j: Double = 0   // rien d'abouti sur la fenêtre courante

    /// v3 : le virement a une conséquence RÉELLE et PERSISTANTE (solde + historique), ou un refus RÉEL (plafond / solde).
    /// Retour : (accepté, motif de refus éventuel)
    func virer(_ montant: Double, vers beneficiaire: String) -> (Bool, String?) {
        let ref = "VIR-" + String(Int(Date().timeIntervalSince1970) % 100_000_000) + "-7845"
        if virementsSur7j + montant > plafondVirement7j {
            operations.insert(Operation(libelle: "VIREMENT ÉMIS", sousLibelle: beneficiaire, date: "17/08/2026",
                                        montant: -montant, refusee: true, reference: ref, categorie: "Virement externe (SEPA)"), at: 0)
            return (false, "plafond")
        }
        if montant > soldeCourant + 200 {   // découvert autorisé 200 €
            operations.insert(Operation(libelle: "VIREMENT ÉMIS", sousLibelle: beneficiaire, date: "17/08/2026",
                                        montant: -montant, refusee: true, reference: ref, categorie: "Virement externe (SEPA)"), at: 0)
            return (false, "solde")
        }
        virementsSur7j += montant
        soldeCourant -= montant
        operations.insert(Operation(libelle: "VIREMENT ÉMIS", sousLibelle: beneficiaire, date: "17/08/2026",
                                    montant: -montant, reference: ref, categorie: "Virement externe (SEPA)"), at: 0)
        return (true, nil)
    }
}

let lclBleu = Color(hex: 0x00184D)
let lclJaune = Color(hex: 0xFFD100)

func euros(_ v: Double) -> String {
    let f = NumberFormatter()
    f.locale = Locale(identifier: "fr_FR")
    f.numberStyle = .decimal
    f.minimumFractionDigits = 2
    f.maximumFractionDigits = 2
    return (f.string(from: NSNumber(value: v)) ?? "0,00") + " €"
}

// ============================================================ APP
struct MaBanqueVue: View {
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0
    @Environment(\.dismiss) private var dismiss
    @State private var chargement = true

    var body: some View {
        ZStack(alignment: .bottom) {
            if chargement {
                // Écran d'accueil bancaire : session mémorisée (D57 : cette porte est OUVERTE — le jeu a besoin d'entrer)
                VStack(spacing: 18) {
                    Spacer()
                    Text("LCL").font(.system(size: 54, weight: .heavy)).foregroundStyle(.white)
                    Text("Mes Comptes").font(.system(size: 17)).foregroundStyle(.white.opacity(0.8))
                    ProgressView().tint(.white).padding(.top, 10)
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "faceid")
                        Text("Connexion automatique — Sarah L.")
                    }
                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(lclBleu.ignoresSafeArea())
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeOut(duration: 0.3)) { chargement = false }
                    }
                }
            } else {
                TabView(selection: $onglet) {
                    ComptesVue().tabItem { Label("Comptes", systemImage: "creditcard.fill") }.tag(0)
                    VirementsVue().tabItem { Label("Virements", systemImage: "arrow.left.arrow.right") }.tag(1)
                    CartesVue().tabItem { Label("Cartes", systemImage: "creditcard") }.tag(2)
                    MessagerieBanqueVue().tabItem { Label("Messagerie", systemImage: "envelope.fill") }.tag(3)
                }
                .tint(lclBleu)
                .preferredColorScheme(.light)
            }

            BarreHome(action: { dismiss() }, sombre: true)
        }
    }
}

// ============================================================ COMPTES
struct ComptesVue: View {
    @ObservedObject private var magasin = MagasinBanque.partage
    @State private var ribVisible = false
    @State private var livretVisible = false
    @State private var operationOuverte: Operation? = nil   // v3 : détail d'opération

    /// Solde du compte APRÈS chaque opération (recalculé en remontant depuis le solde actuel)
    private func soldeApres(_ op: Operation) -> Double {
        var solde = magasin.soldeCourant
        for o in magasin.operations {
            if o.id == op.id { return solde }
            if !o.refusee { solde -= o.montant }
        }
        return solde
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // Compte courant
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Compte de dépôt").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            Spacer()
                            Text("•••• 7845").font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
                        }
                        Text("MME SARAH LEVASSEUR").font(.system(size: 11)).foregroundStyle(.white.opacity(0.7))
                        Text(euros(magasin.soldeCourant))
                            .font(.system(size: 34, weight: .bold)).foregroundStyle(.white)
                            .contentTransition(.numericText())
                        HStack(spacing: 10) {
                            Button { ribVisible = true } label: {
                                Text("Mon RIB").font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(lclBleu)
                                    .padding(.horizontal, 14).padding(.vertical, 7)
                                    .background(.white, in: Capsule())
                            }
                            Text("Découvert autorisé : 200 €").font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(lclBleu, in: RoundedRectangle(cornerRadius: 16))

                    // Livret A
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Livret A").font(.system(size: 15, weight: .semibold)).foregroundStyle(Color(hex: 0x1A1A2E))
                            Text("•••• 3310").font(.system(size: 12)).foregroundStyle(Color(hex: 0x6E7480))
                        }
                        Spacer()
                        Text(euros(magasin.soldeLivretA)).font(.system(size: 22, weight: .bold)).foregroundStyle(Color(hex: 0x1A1A2E))
                        Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Color(hex: 0x6E7480))
                    }
                    .padding(16)
                    .background(Color(hex: 0xF2F4F8), in: RoundedRectangle(cornerRadius: 16))
                    .contentShape(Rectangle())
                    .onTapGesture { livretVisible = true }

                    // Historique
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Dernières opérations").font(.system(size: 17, weight: .bold)).foregroundStyle(Color(hex: 0x1A1A2E))
                            .padding(.bottom, 10)
                        ForEach(magasin.operations) { op in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(op.libelle).font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(op.refusee ? Color(hex: 0xD93025) : Color(hex: 0x1A1A2E))
                                        if op.refusee {
                                            Text("REFUSÉ").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                                                .padding(.horizontal, 6).padding(.vertical, 2)
                                                .background(Color(hex: 0xD93025), in: Capsule())
                                        }
                                    }
                                    Text(op.sousLibelle).font(.system(size: 12.5)).foregroundStyle(Color(hex: 0x6E7480))
                                    Text(op.date).font(.system(size: 11.5)).foregroundStyle(Color(hex: 0x8A909C))
                                }
                                Spacer()
                                Text((op.montant > 0 ? "+" : "") + euros(op.montant))
                                    .font(.system(size: 15, weight: .semibold)).monospacedDigit()
                                    .foregroundStyle(op.refusee ? Color(hex: 0x9AA0AC) : (op.montant > 0 ? Color(hex: 0x1E9E46) : Color(hex: 0x1A1A2E)))
                                    .strikethrough(op.refusee)
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(Color(hex: 0xB0B5C0)).padding(.top, 3)
                            }
                            .padding(.vertical, 9)
                            .contentShape(Rectangle())
                            .onTapGesture { operationOuverte = op }   // v3 : détail
                            Divider()
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(16)
            }
            .background(Color.white)
            .navigationTitle("Mes comptes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(lclBleu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $ribVisible) { RIBVue() }
            .sheet(isPresented: $livretVisible) { BanqueLivretAVue(solde: magasin.soldeLivretA) }
            .sheet(item: $operationOuverte) { op in DetailOperationVue(operation: op, soldeApres: soldeApres(op)) }
        }
    }
}

extension Operation: Hashable {
    static func == (a: Operation, b: Operation) -> Bool { a.id == b.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// v3 — Détail d'une opération (Joachim : « pouvoir cliquer sur certaines opérations pour en savoir plus »)
struct DetailOperationVue: View {
    @Environment(\.dismiss) private var dismiss
    let operation: Operation
    let soldeApres: Double
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text((operation.montant > 0 ? "+" : "") + euros(operation.montant))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(operation.refusee ? Color(hex: 0xD93025) : (operation.montant > 0 ? Color(hex: 0x1E9E46) : Color(hex: 0x1A1A2E)))
                            .strikethrough(operation.refusee)
                        Text(operation.sousLibelle).font(.system(size: 14)).foregroundStyle(Color(hex: 0x6E7480)).multilineTextAlignment(.center)
                        if operation.refusee {
                            Text("OPÉRATION REFUSÉE").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                                .padding(.horizontal, 10).padding(.vertical, 4).background(Color(hex: 0xD93025), in: Capsule())
                        }
                    }
                    .padding(.top, 10)
                    VStack(spacing: 0) {
                        LigneDetailOp(cle: "Type", valeur: operation.libelle.capitalized)
                        LigneDetailOp(cle: "Date d'opération", valeur: operation.date)
                        LigneDetailOp(cle: "Date de valeur", valeur: operation.date)
                        LigneDetailOp(cle: "Catégorie", valeur: operation.categorie.isEmpty ? "Autre" : operation.categorie)
                        LigneDetailOp(cle: "Référence", valeur: operation.reference.isEmpty ? "—" : operation.reference)
                        LigneDetailOp(cle: "Compte", valeur: "Compte de dépôt •••• 7845")
                        LigneDetailOp(cle: operation.refusee ? "Motif" : "Solde après opération",
                                      valeur: operation.refusee ? "Plafond de virement dépassé (3 000 € / 7 j)" : euros(soldeApres), derniere: true)
                    }
                    .background(Color(hex: 0xF9FAFC), in: RoundedRectangle(cornerRadius: 14))
                    if operation.libelle.hasPrefix("VIREMENT ÉMIS") && !operation.refusee {
                        Text("Virement SEPA exécuté. Délai de réception habituel : 1 jour ouvré.")
                            .font(.system(size: 12.5)).foregroundStyle(Color(hex: 0x6E7480)).multilineTextAlignment(.center)
                    }
                }
                .padding(16)
            }
            .background(Color.white)
            .navigationTitle("Détail de l'opération")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("OK") { dismiss() }.foregroundStyle(lclBleu) } }
        }
        .preferredColorScheme(.light)
        .presentationDetents([.medium, .large])
    }
}

struct LigneDetailOp: View {
    let cle: String; let valeur: String; var derniere: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(cle).font(.system(size: 14)).foregroundStyle(Color(hex: 0x6E7480))
                Spacer()
                Text(valeur).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color(hex: 0x1A1A2E)).multilineTextAlignment(.trailing)
            }
            .padding(14)
            if !derniere { Divider().padding(.leading, 14) }
        }
    }
}

// RIB — IDENTIQUE à la capture P58 (cohérence croisée R3)
struct RIBVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var copie = false
    @State private var partageVisible = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        Text("LCL").font(.system(size: 30, weight: .heavy)).foregroundStyle(lclBleu)
                        Spacer()
                        Text("Relevé d'Identité Bancaire").font(.system(size: 13)).foregroundStyle(Color(hex: 0x6E7480))
                    }
                    Groupe(titre: "TITULAIRE", valeur: "MME SARAH LEVASSEUR",
                           sous: "14 rue des Capucins, 69001 LYON")
                    Groupe(titre: "IBAN", valeur: "FR76 3000 2005 5000 0015 7845 Z02")
                    Groupe(titre: "BIC", valeur: "CRLYFRPP")
                    Groupe(titre: "DOMICILIATION", valeur: "LCL LYON REPUBLIQUE (00550)")
                    HStack(spacing: 12) {
                        Text(copie ? "IBAN copié" : "Copier l'IBAN").font(.system(size: 14, weight: .semibold)).foregroundStyle(lclBleu)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Color(hex: 0xF2F4F8), in: RoundedRectangle(cornerRadius: 12))
                            .onTapGesture { UIPasteboard.general.string = "FR76 3000 2005 5000 0015 7845 Z02"; copie = true; Haptique.leger() }
                        // v3 : Partager RÉEL (feuille de partage maison, avec le RIB en contenu)
                        Text("Partager").font(.system(size: 14, weight: .semibold)).foregroundStyle(lclBleu)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Color(hex: 0xF2F4F8), in: RoundedRectangle(cornerRadius: 12))
                            .onTapGesture { partageVisible = true }
                    }
                }
                .padding(20)
            }
            .background(Color.white)
            .navigationTitle("Mon RIB")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(lclBleu)
                }
            }
            .sheet(isPresented: $partageVisible) {
                FeuillePartage(element: "RIB — Sarah Levasseur",
                               contenu: "Relevé d'Identité Bancaire\nTitulaire : MME SARAH LEVASSEUR\nIBAN : FR76 3000 2005 5000 0015 7845 Z02\nBIC : CRLYFRPP\nDomiciliation : LCL LYON REPUBLIQUE (00550)",
                               type: .fichier)
            }
        }
        .preferredColorScheme(.light)
    }

    struct Groupe: View {
        let titre: String
        let valeur: String
        var sous: String? = nil
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(titre).font(.system(size: 11, weight: .semibold)).foregroundStyle(Color(hex: 0x6E7480)).kerning(0.5)
                Text(valeur).font(.system(size: 16, weight: .bold)).foregroundStyle(Color(hex: 0x1A1A2E))
                if let sous { Text(sous).font(.system(size: 13)).foregroundStyle(Color(hex: 0x6E7480)) }
            }
        }
    }
}

// ============================================================ VIREMENTS (le cœur du piège — fonctionnel)
struct VirementsVue: View {
    @ObservedObject private var magasin = MagasinBanque.partage
    @State private var beneficiaire = "M. OKAFOR AGENT MARITIME"
    @State private var montantTexte = ""
    @State private var resultat: Bool? = nil
    @State private var motifRefus: String? = nil
    @State private var montantVire: Double = 0
    @FocusState private var montantActif: Bool   // v3 : pavé numérique masquable

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Effectuer un virement").font(.system(size: 19, weight: .bold)).foregroundStyle(Color(hex: 0x1A1A2E))

                    // Rappel du solde disponible (le virement s'y répercute immédiatement)
                    HStack {
                        Text("Compte de dépôt •••• 7845").font(.system(size: 13)).foregroundStyle(Color(hex: 0x6E7480))
                        Spacer()
                        Text("Solde : " + euros(magasin.soldeCourant)).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color(hex: 0x1A1A2E))
                            .contentTransition(.numericText())
                    }
                    .padding(12)
                    .background(Color(hex: 0xF2F4F8), in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("BÉNÉFICIAIRE").font(.system(size: 11, weight: .semibold)).foregroundStyle(Color(hex: 0x6E7480))
                        Menu {
                            ForEach(magasin.beneficiaires, id: \.0) { b in
                                Button(b.0) { beneficiaire = b.0 }
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(beneficiaire).font(.system(size: 15, weight: .semibold)).foregroundStyle(Color(hex: 0x1A1A2E))
                                    Text(magasin.beneficiaires.first { $0.0 == beneficiaire }?.1 ?? "")
                                        .font(.system(size: 12)).foregroundStyle(Color(hex: 0x6E7480))
                                }
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down").font(.system(size: 12)).foregroundStyle(Color(hex: 0x6E7480))
                            }
                            .padding(14)
                            .background(Color(hex: 0xF2F4F8), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("MONTANT").font(.system(size: 11, weight: .semibold)).foregroundStyle(Color(hex: 0x6E7480))
                        HStack {
                            TextField("0,00", text: $montantTexte)
                                .keyboardType(.decimalPad)
                                .focused($montantActif)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(Color(hex: 0x1A1A2E))
                            Text("€").font(.system(size: 22, weight: .semibold)).foregroundStyle(Color(hex: 0x6E7480))
                        }
                        .padding(14)
                        .background(Color(hex: 0xF2F4F8), in: RoundedRectangle(cornerRadius: 12))
                    }

                    Text("Plafond de virement : 3 000 € sur 7 jours glissants.")
                        .font(.system(size: 12.5)).foregroundStyle(Color(hex: 0x6E7480))

                    Button {
                        montantActif = false
                        let m = Double(montantTexte.replacingOccurrences(of: ",", with: ".")
                                                  .replacingOccurrences(of: " ", with: "")) ?? 0
                        guard m > 0 else { return }
                        let (ok, motif) = magasin.virer(m, vers: beneficiaire)
                        withAnimation { resultat = ok; motifRefus = motif; montantVire = m }
                        Haptique.leger()
                        montantTexte = ""
                    } label: {
                        Text("Valider le virement").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(lclBleu, in: RoundedRectangle(cornerRadius: 30))
                    }

                    if let r = resultat {
                        // L'écran de refus = la capture P57 rejouée en vrai
                        VStack(spacing: 12) {
                            Circle().fill(r ? Color(hex: 0xE6F6EA) : Color(hex: 0xFDECEA))
                                .frame(width: 62, height: 62)
                                .overlay(Image(systemName: r ? "checkmark" : "xmark")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundStyle(r ? Color(hex: 0x1E9E46) : Color(hex: 0xD93025)))
                            Text(r ? "Virement enregistré" : "Virement refusé")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(r ? Color(hex: 0x1E9E46) : Color(hex: 0xD93025))
                            if r {
                                // v3 : la conséquence est visible ICI aussi
                                VStack(spacing: 4) {
                                    Text("\(euros(montantVire)) vers \(beneficiaire)").font(.system(size: 13)).foregroundStyle(Color(hex: 0x6E7480))
                                    Text("Solde après opération : \(euros(magasin.soldeCourant))").font(.system(size: 14, weight: .semibold)).foregroundStyle(Color(hex: 0x1A1A2E))
                                    Text("Exécution : 1 jour ouvré. L'opération apparaît dans « Dernières opérations ».").font(.system(size: 12)).foregroundStyle(Color(hex: 0x8A909C)).multilineTextAlignment(.center)
                                }
                            } else if motifRefus == "solde" {
                                Text("Solde insuffisant. Le montant demandé dépasse le solde disponible et le découvert autorisé (200 €).")
                                    .font(.system(size: 13)).foregroundStyle(Color(hex: 0x7A5D12))
                                    .padding(12)
                                    .background(Color(hex: 0xFFF8E8), in: RoundedRectangle(cornerRadius: 12))
                            } else {
                                Text("Plafond de virement dépassé. Votre plafond est fixé à 3 000 € sur 7 jours glissants. Pour effectuer cette opération, augmentez votre plafond ou rendez-vous en agence.")
                                    .font(.system(size: 13)).foregroundStyle(Color(hex: 0x7A5D12))
                                    .padding(12)
                                    .background(Color(hex: 0xFFF8E8), in: RoundedRectangle(cornerRadius: 12))
                                Text("Agence LYON BELLECOUR · à 400 m")
                                    .font(.system(size: 13)).foregroundStyle(Color(hex: 0x6E7480))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(hex: 0xF9FAFC), in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(16)
            }
            .background(Color.white)
            .scrollDismissesKeyboard(.interactively)
            // v3 : un tap hors du champ ferme le pavé numérique ; bouton « OK » au-dessus du clavier
            .simultaneousGesture(TapGesture().onEnded { montantActif = false })
            .navigationTitle("Virements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(lclBleu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { montantActif = false }.font(.system(size: 16, weight: .semibold)).foregroundStyle(lclBleu)
                }
            }
        }
    }
}

// ============================================================ CARTES
struct CartesVue: View {
    @State private var oppositionAlerte = false
    @State private var plafondAlerte = false
    @State private var sansContactActif = true
    @State private var paiementsEnLigneActifs = true
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Carte visuelle
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("LCL").font(.system(size: 20, weight: .heavy)).foregroundStyle(.white)
                            Spacer()
                            Text("VISA").font(.system(size: 16, weight: .bold)).italic().foregroundStyle(.white)
                        }
                        Spacer()
                        Text("•••• •••• •••• 4417").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white).kerning(2)
                        HStack {
                            Text("SARAH LEVASSEUR").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white.opacity(0.9))
                            Spacer()
                            Text("08/28").font(.system(size: 12)).foregroundStyle(.white.opacity(0.9))
                        }
                        .padding(.top, 6)
                    }
                    .padding(18)
                    .frame(height: 180)
                    .background(
                        LinearGradient(colors: [Color(hex: 0x0A2A6B), lclBleu], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 18))

                    VStack(spacing: 0) {
                        LigneBanque(titre: "Plafonds de paiement et retrait", valeur: "Gérer") { plafondAlerte = true }
                        Divider()
                        HStack {
                            Text("Paiement sans contact").font(.system(size: 15)).foregroundStyle(Color(hex: 0x1A1A2E))
                            Spacer()
                            Toggle("", isOn: $sansContactActif)
                                .labelsHidden()
                                .tint(Color(hex: 0x1E9E46))
                        }
                        .padding(14)
                        Divider()
                        HStack {
                            Text("Paiements en ligne").font(.system(size: 15)).foregroundStyle(Color(hex: 0x1A1A2E))
                            Spacer()
                            Toggle("", isOn: $paiementsEnLigneActifs)
                                .labelsHidden()
                                .tint(lclBleu)
                        }
                        .padding(14)
                        Divider()
                        LigneBanque(titre: "Faire opposition", valeur: "", destructif: true) { oppositionAlerte = true }
                    }
                    .background(Color(hex: 0xF9FAFC), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
            }
            .background(Color.white)
            .navigationTitle("Mes cartes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(lclBleu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Plafonds", isPresented: $plafondAlerte) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Pour modifier vos plafonds de paiement, de retrait ou de virement, prenez rendez-vous avec votre conseiller en agence.")
            }
            .alert("Faire opposition", isPresented: $oppositionAlerte) {
                Button("Annuler", role: .cancel) {}
                Button("Appeler le 09 69 36 30 30") { Routeur.partage.allerTelephone("09 69 36 30 30") }
            } message: {
                Text("En cas de perte ou de vol, l'opposition est immédiate et définitive.")
            }
        }
    }
}

struct LigneBanque: View {
    let titre: String
    let valeur: String
    var destructif: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Text(titre).font(.system(size: 15))
                    .foregroundStyle(destructif ? Color(hex: 0xD93025) : Color(hex: 0x1A1A2E))
                Spacer()
                Text(valeur).font(.system(size: 14)).foregroundStyle(Color(hex: 0x6E7480))
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(Color(hex: 0x6E7480))
            }
            .padding(14)
        }
    }
}

// ============================================================ MESSAGERIE (l'or : la confirmation du RDV)
struct MessagerieBanqueVue: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    MessageBanque(objet: "Confirmation de votre rendez-vous",
                                  corps: "Bonjour Madame Levasseur,\n\nVotre rendez-vous du lundi 17 août à 11h30 est confirmé avec M. Rossi, votre conseiller, à l'agence LYON BELLECOUR.\n\nMotif indiqué : augmentation de plafond de virement.\n\nPensez à vous munir d'une pièce d'identité, d'un justificatif de domicile et de vos trois derniers relevés.\n\nCordialement,\nVotre agence LCL",
                                  date: "14/08/2026", nonLu: true)
                    MessageBanque(objet: "Sécurité : rappel important",
                                  corps: "LCL ne vous demandera JAMAIS votre code de carte, vos identifiants ou un virement par téléphone, SMS ou e-mail. En cas de doute, ne répondez pas et contactez votre agence.\n\nSi vous pensez être victime d'une fraude, appelez immédiatement le 09 69 36 30 30.",
                                  date: "02/08/2026")
                    MessageBanque(objet: "Vos relevés de juillet sont disponibles",
                                  corps: "Votre relevé de compte du mois de juillet est disponible dans votre espace Documents.",
                                  date: "01/08/2026")
                }
                .padding(16)
            }
            .background(Color.white)
            .navigationTitle("Messagerie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(lclBleu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct MessageBanque: View {
    let objet: String
    let corps: String
    let date: String
    var nonLu: Bool = false
    @State private var ouvert = false
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                if nonLu && !ouvert { Circle().fill(lclBleu).frame(width: 8, height: 8) }
                Text(objet).font(.system(size: 15, weight: nonLu && !ouvert ? .bold : .semibold)).foregroundStyle(Color(hex: 0x1A1A2E))
                Spacer()
                Text(date).font(.system(size: 12)).foregroundStyle(Color(hex: 0x6E7480))
            }
            if ouvert {
                Text(corps).font(.system(size: 14)).foregroundStyle(Color(hex: 0x3C3C48))
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(corps).font(.system(size: 13)).foregroundStyle(Color(hex: 0x6E7480)).lineLimit(2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xF9FAFC), in: RoundedRectangle(cornerRadius: 14))
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { ouvert.toggle() } }
    }
}

// ============================================================ LIVRET A
struct BanqueLivretAVue: View {
    @Environment(\.dismiss) private var dismiss
    let solde: Double
    private func euros(_ v: Double) -> String {
        String(format: "%.2f €", v).replacingOccurrences(of: ".", with: ",")
    }
    private let historique: [(String, String, Double)] = [
        ("VIREMENT VERS COMPTE COURANT", "15/08/2026", -3000.0),
        ("VIREMENT VERS COMPTE COURANT", "20/07/2026", -2000.0),
        ("INTÉRÊTS 2026", "Crédit d'intérêts", 1.85),
        ("VIREMENT DEPUIS COMPTE COURANT", "Épargne mensuelle", 150.0),
        ("INTÉRÊTS 2025", "Crédit d'intérêts", 2.12),
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Livret A").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        Text("•••• 3310 · Taux : 3,00 %").font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                        Text(euros(solde)).font(.system(size: 34, weight: .bold)).foregroundStyle(.white)
                    }
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0x2F9E44), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Historique").font(.system(size: 17, weight: .bold)).foregroundStyle(Color(hex: 0x1A1A2E))
                            .padding(.bottom, 10)
                        ForEach(Array(historique.enumerated()), id: \.offset) { _, op in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(op.0).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color(hex: 0x1A1A2E))
                                    Text(op.1).font(.system(size: 12)).foregroundStyle(Color(hex: 0x6E7480))
                                }
                                Spacer()
                                Text((op.2 > 0 ? "+" : "−") + euros(abs(op.2))).font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(op.2 > 0 ? Color(hex: 0x1E9E46) : Color(hex: 0x1A1A2E))
                            }
                            .padding(.vertical, 8)
                            Divider()
                        }
                    }
                    .padding(16)
                    .background(Color(hex: 0xF9FAFC), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    Color.clear.frame(height: 30)
                }
                .padding(.top, 16)
            }
            .background(Color.white)
            .navigationTitle("Livret A")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(lclBleu)
                }
            }
        }
        .preferredColorScheme(.light)
        .presentationDetents([.large])
    }
}
