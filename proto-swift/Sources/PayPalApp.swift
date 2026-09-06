// PayPal v1 D92 (06/09) — construit contre les 263 frames de Joachim
//
// D67 : la référence est /refs/vagueA/paypal/e001…e263.jpg (603×1311 px, 1 pt = 1,5 px).
//   Écrans FILMÉS reproduits : Accueil (e044/e106/e263), Solde PayPal (e106/e107),
//   Transactions de solde PayPal (e049…e077), détail de transaction « Argent envoyé /
//   Argent reçu / Argent reçu · Remboursé » (e091), détail « Paiement » marchand (e127),
//   Historique « Vous et X » (e082), Activité + recherche + filtres (e116/e135),
//   Notifications (e141), Profil (e147), Coordonnées (e150), Paramètres (e151),
//   Abonnements (e181), Comptes + carte bancaire (e249/e243), Envoyer et demander (e196),
//   Montant + pavé (e215), feuille Type de paiement (e226), feuille Vérifier (e225),
//   feuille Comment voulez-vous payer ? (e228), paiement interrompu (e209),
//   confirmation d'envoi (e086), Menu (e256).
//   Écrans NON filmés : aucun n'a été inventé.
//
// D82/D92 : chaque affordance affichée a une conséquence réelle. Tout ce qui, dans les
//   frames, ne peut pas exister ici (Récompenses, Paiement différé, Suivi de colis,
//   guichets de retail, recharges de téléphone, QR vendeur, dons, Devises, Préférences
//   marketing, Données et confidentialité, Inviter des proches, Se déconnecter, Fermer
//   votre compte, « Ajouter les détails du compte 1/3 », carrousel « Paiement en
//   plusieurs fois »…) est RETIRÉ plutôt que mort. Détail dans audit/paypal-livraison.md.
//
// D59 : les données visibles dans les frames (Jean Bertin, Jolien-Host, 0,00 €, cartes
//   Wise/bunq…) ne sont que des gabarits. Tout est remplacé par le contenu de Sarah
//   Levasseur, cohérent avec Ma Banque (LCL Visa •••• 4417), Mail (Western Union du
//   13/06, Meetic du 12/03) et WhatsApp (« Marc ❤️ »).
//
// Aucun micro de dictée. Retour = chevron. Barres au-dessus de BarreHome.
// Préfixe de types : Pp — aucune collision avec LPProto / Messenger / Instagram /
// Snapchat / Facebook / Notes.
import SwiftUI

// ============================================================ PALETTE (mesurée au pixel sur les frames)
enum PpTeinte {
    static let fond = Color(hex: 0xEDEDF7)        // e091 : (237,237,247)
    static let carte = Color.white
    static let texte = Color(hex: 0x0B0B0C)
    static let gris = Color(hex: 0x5C5C5C)        // e049 : sous-titres (92,92,92)
    static let grisClair = Color(hex: 0x8A8A8E)
    static let lien = Color(hex: 0x1053CE)        // « Afficher l'historique », « Tout afficher »
    static let bleu = Color(hex: 0x0070E0)        // icônes d'en-tête, pictogrammes d'aide
    static let vert = Color(hex: 0x0A8754)        // montants reçus (+8 €)
    static let rouge = Color(hex: 0xC0043A)       // pastille de la cloche
    static let phare = Color(hex: 0xE0F4FB)       // bandeau « Produit phare »
    static let violetHaut = Color(hex: 0x6503C8)  // bandeau de profil (e147)
    static let violetBas = Color(hex: 0x4C00A3)
    static let voile = Color(hex: 0xF1F1F5)       // fonds de pastilles rondes des actions
}

// ============================================================ DONNÉES (remplaçables — D59)

enum PpGenre {
    case envoi
    case reception
    case paiement
    case rembourse
    case interrompu
    case demandeEnvoyee
}

struct PpTx: Identifiable {
    let id = UUID()
    var tiers: String
    var email: String = ""
    var teinte: UInt = 0x111214
    var initiales: String = ""
    var marchand: Bool = false
    var genre: PpGenre
    var montant: Double            // signé : négatif = débit
    var date: String               // « 9 août 2026 »
    var heure: String = ""
    var mois: String               // regroupement de l'onglet Activité
    var note: String = ""
    var source: String = "Solde PayPal"
    var reference: String = ""
    var entreProches: Bool = false
    var commande: String = ""      // récapitulatif marchand (e127)

    var sousTitre: String {
        switch genre {
        case .envoi: return "Argent envoyé"
        case .reception: return "Argent reçu"
        case .paiement: return "Paiement"
        case .rembourse: return "Argent reçu - Remboursé"
        case .interrompu: return "Paiement interrompu"
        case .demandeEnvoyee: return "Demande envoyée"
        }
    }
    var titreEcran: String {
        switch genre {
        case .envoi: return "Argent envoyé"
        case .reception: return "Argent reçu"
        case .paiement: return "Paiement"
        case .rembourse: return "Argent reçu · Remboursé"
        case .interrompu: return "Paiement interrompu"
        case .demandeEnvoyee: return "Demande envoyée"
        }
    }
    var estAchat: Bool { genre == .paiement || genre == .rembourse }
}

enum PpEtatDemande {
    case attente
    case refusee
}

struct PpDemande: Identifiable {
    let id = UUID()
    var tiers: String
    var email: String
    var teinte: UInt
    var initiales: String
    var montant: Double
    var date: String
    var motif: String
    var etat: PpEtatDemande = .attente
}

struct PpContact: Identifiable {
    let id = UUID()
    var nom: String
    var pseudo: String = ""
    var email: String
    var teinte: UInt
    var initiales: String
    var marchand: Bool = false
}

struct PpSource: Identifiable {
    let id = UUID()
    var nom: String
    var detail: String
    var carte: Bool
}

struct PpAbonnement: Identifiable {
    let id = UUID()
    var nom: String
    var montant: Double
    var periode: String
    var source: String
    var depuis: String
}

// ============================================================ MAGASIN (état réel, persistant dans la session)
final class PpMagasin: ObservableObject {
    static let partage = PpMagasin()

    @Published var solde: Double = 12.40
    @Published var transactions: [PpTx] = PpMagasin.transactionsInitiales()
    @Published var demandes: [PpDemande] = [
        PpDemande(tiers: "GLOBAL MARINE CREW SUPPORT",
                  email: "crew.support@marine-logistics-intl.com",
                  teinte: 0x1F3A5F, initiales: "GM", montant: 480.00,
                  date: "15 août 2026",
                  motif: "Frais de rapatriement d'équipage — dossier 7845")
    ]
    @Published var abonnements: [PpAbonnement] = [
        PpAbonnement(nom: "Spotify AB", montant: 11.99, periode: "par mois",
                     source: "Solde PayPal", depuis: "5 février 2024")
    ]
    @Published var notificationsVues = false
    @Published var alerteReceptionArgent = true
    @Published var alerteDemandeArgent = true
    @Published var alerteEnvoiArgent = false
    @Published var faceIdActif = true

    // Sources de paiement de Sarah : le solde PayPal et la Visa LCL de Ma Banque.
    let sources: [PpSource] = [
        PpSource(nom: "Solde PayPal", detail: "Solde disponible", carte: false),
        PpSource(nom: "Visa LCL", detail: "Carte (4417)", carte: true)
    ]

    let contacts: [PpContact] = [
        PpContact(nom: "Chloé", pseudo: "@chloe.bnv", email: "chloe.bnv@gmail.com",
                  teinte: 0xE17BB2, initiales: "C"),
        PpContact(nom: "Marc", pseudo: "@marc.dlc", email: "marc.dlc.officier@gmail.com",
                  teinte: 0x2F6F5F, initiales: "M"),
        PpContact(nom: "Maman", pseudo: "", email: "famille.levasseur@orange.fr",
                  teinte: 0x8B5CF6, initiales: "M"),
        PpContact(nom: "Thomas", pseudo: "@thomas.rey", email: "thomas.rey69@gmail.com",
                  teinte: 0x3B5DF6, initiales: "T"),
        PpContact(nom: "Camille Roux", pseudo: "@camille.rx", email: "camille.roux69@gmail.com",
                  teinte: 0xE8863D, initiales: "CR"),
        PpContact(nom: "SNCF Connect", pseudo: "", email: "paiement@sncf-connect.com",
                  teinte: 0x111214, initiales: "SC", marchand: true),
        PpContact(nom: "Vinted", pseudo: "", email: "paiement@vinted.fr",
                  teinte: 0x111214, initiales: "V", marchand: true)
    ]

    var notificationsNonLues: Int {
        if notificationsVues { return 0 }
        return 1 + demandes.filter { $0.etat == .attente }.count
    }

    /// L'envoi débite RÉELLEMENT le solde (ou passe par la carte) et crée une ligne d'activité.
    /// Retour : message de refus, ou nil si l'envoi est passé.
    func envoyer(_ montant: Double, a contact: PpContact,
                 note: String, source: PpSource, entreProches: Bool) -> String? {
        if montant <= 0 { return "Saisissez un montant supérieur à 0,00 €." }
        if !source.carte && montant > solde {
            return "Solde PayPal insuffisant (\(PpFormat.montant(solde))). Choisissez un autre mode de paiement ou réduisez le montant."
        }
        if !source.carte { solde -= montant }
        let tx = PpTx(tiers: contact.nom, email: contact.email, teinte: contact.teinte,
                      initiales: contact.initiales, marchand: contact.marchand,
                      genre: .envoi, montant: -montant,
                      date: "17 août 2026", heure: "19:47", mois: "août 2026",
                      note: note, source: source.carte ? "Carte Visa LCL" : "Solde PayPal",
                      reference: PpFormat.reference(), entreProches: entreProches)
        transactions.insert(tx, at: 0)
        return nil
    }

    /// La demande d'argent laisse elle aussi une trace réelle dans l'activité.
    func demander(_ montant: Double, a contact: PpContact, note: String) -> String? {
        if montant <= 0 { return "Saisissez un montant supérieur à 0,00 €." }
        let tx = PpTx(tiers: contact.nom, email: contact.email, teinte: contact.teinte,
                      initiales: contact.initiales, marchand: contact.marchand,
                      genre: .demandeEnvoyee, montant: montant,
                      date: "17 août 2026", heure: "19:47", mois: "août 2026",
                      note: note, source: "—", reference: PpFormat.reference())
        transactions.insert(tx, at: 0)
        return nil
    }

    func refuser(_ demande: PpDemande) {
        guard let i = demandes.firstIndex(where: { $0.id == demande.id }) else { return }
        demandes[i].etat = .refusee
    }

    func lignes(pour tiers: String) -> [PpTx] {
        transactions.filter { $0.tiers == tiers }
    }

    /// PayPal a déjà bloqué un paiement vers « Marc » le 16/08 : tout nouvel envoi vers
    /// ce destinataire déclenche le même écran de protection (e209). Cohérence D92.
    func paiementBloque(pour contact: PpContact) -> Bool {
        contact.email == "marc.dlc.officier@gmail.com"
    }

    static func transactionsInitiales() -> [PpTx] {
        [
            PpTx(tiers: "Marc", email: "marc.dlc.officier@gmail.com", teinte: 0x2F6F5F,
                 initiales: "M", genre: .interrompu, montant: -300.00,
                 date: "16 août 2026", heure: "21:04", mois: "août 2026",
                 note: "dernière avance, promis",
                 source: "Solde PayPal", reference: "8PN44M2C9RT01", entreProches: true),
            PpTx(tiers: "Camille Roux", email: "camille.roux69@gmail.com", teinte: 0xE8863D,
                 initiales: "CR", genre: .reception, montant: 35.00,
                 date: "12 août 2026", heure: "14:22", mois: "août 2026",
                 note: "objectif 50 mm", source: "Solde PayPal",
                 reference: "3KQ71D8V4LM22", entreProches: true),
            PpTx(tiers: "Marc", email: "marc.dlc.officier@gmail.com", teinte: 0x2F6F5F,
                 initiales: "M", genre: .envoi, montant: -200.00,
                 date: "9 août 2026", heure: "22:41", mois: "août 2026",
                 note: "connexion satellite", source: "Solde PayPal",
                 reference: "6TR03B5K7WD18", entreProches: true),
            PpTx(tiers: "Spotify AB", email: "billing@spotify.com", teinte: 0x111214,
                 initiales: "S", marchand: true, genre: .paiement, montant: -11.99,
                 date: "5 août 2026", heure: "03:12", mois: "août 2026",
                 source: "Solde PayPal", reference: "9LM52X1P6QA07",
                 commande: "Spotify Premium — abonnement mensuel"),
            PpTx(tiers: "Chloé", email: "chloe.bnv@gmail.com", teinte: 0xE17BB2,
                 initiales: "C", genre: .envoi, montant: -16.50,
                 date: "28 juillet 2026", heure: "23:05", mois: "juillet 2026",
                 note: "le resto des quais", source: "Solde PayPal",
                 reference: "2WD68F4J9NB35", entreProches: true),
            PpTx(tiers: "Marc", email: "marc.dlc.officier@gmail.com", teinte: 0x2F6F5F,
                 initiales: "M", genre: .envoi, montant: -150.00,
                 date: "21 juillet 2026", heure: "20:18", mois: "juillet 2026",
                 note: "avance frais de douane", source: "Carte Visa LCL",
                 reference: "5HB19C7T2ZS64", entreProches: true),
            PpTx(tiers: "Maman", email: "famille.levasseur@orange.fr", teinte: 0x8B5CF6,
                 initiales: "M", genre: .reception, montant: 50.00,
                 date: "13 juillet 2026", heure: "10:47", mois: "juillet 2026",
                 note: "pour l'encadrement des photos", source: "Solde PayPal",
                 reference: "7JC30N6R8XF91", entreProches: true),
            PpTx(tiers: "SNCF Connect", email: "paiement@sncf-connect.com", teinte: 0x111214,
                 initiales: "SC", marchand: true, genre: .paiement, montant: -47.00,
                 date: "2 juillet 2026", heure: "18:36", mois: "juillet 2026",
                 source: "Carte Visa LCL", reference: "4VF85K2M1DH70",
                 commande: "TGV INOUI 6173 — Lyon Part-Dieu → Marseille St-Charles"),
            PpTx(tiers: "Atelier Céramique Croix-Rousse", email: "contact@ceram-cx.fr",
                 teinte: 0x111214, initiales: "AC", marchand: true, genre: .rembourse,
                 montant: 24.90, date: "24 juin 2026", heure: "16:02", mois: "juin 2026",
                 source: "Carte Visa LCL", reference: "1QS47L9G5YB28",
                 commande: "Bol émaillé — commande annulée"),
            PpTx(tiers: "Marc", email: "marc.dlc.officier@gmail.com", teinte: 0x2F6F5F,
                 initiales: "M", genre: .envoi, montant: -120.00,
                 date: "12 juin 2026", heure: "21:53", mois: "juin 2026",
                 note: "caution transporteur", source: "Carte Visa LCL",
                 reference: "8ZX26T3W7CE49", entreProches: true),
            PpTx(tiers: "Spotify AB", email: "billing@spotify.com", teinte: 0x111214,
                 initiales: "S", marchand: true, genre: .paiement, montant: -11.99,
                 date: "5 juin 2026", heure: "03:11", mois: "juin 2026",
                 source: "Solde PayPal", reference: "6BD91V4H2KP53",
                 commande: "Spotify Premium — abonnement mensuel"),
            PpTx(tiers: "Chloé", email: "chloe.bnv@gmail.com", teinte: 0xE17BB2,
                 initiales: "C", genre: .reception, montant: 20.00,
                 date: "20 mai 2026", heure: "12:29", mois: "mai 2026",
                 note: "ma part du cadeau", source: "Solde PayPal",
                 reference: "3NF74Q8S6TM10", entreProches: true)
        ]
    }
}

// ============================================================ CAPTURE (D63 — pipeline Miroir)
// Accesseurs NON optionnels : aucun indice nu, aucune force-unwrap dans le registre d'écrans.
enum PpCapture {
    static func transaction() -> PpTx {
        PpMagasin.partage.transactions.first(where: { $0.genre == .envoi })
            ?? PpMagasin.transactionsInitiales()[2]
    }
    static func paiement() -> PpTx {
        PpMagasin.partage.transactions.first(where: { $0.genre == .paiement })
            ?? PpMagasin.transactionsInitiales()[3]
    }
    static func interrompue() -> PpTx {
        PpMagasin.partage.transactions.first(where: { $0.genre == .interrompu })
            ?? PpMagasin.transactionsInitiales()[0]
    }
    static func demande() -> PpDemande {
        PpMagasin.partage.demandes.first
            ?? PpDemande(tiers: "GLOBAL MARINE CREW SUPPORT",
                         email: "crew.support@marine-logistics-intl.com",
                         teinte: 0x1F3A5F, initiales: "GM", montant: 480,
                         date: "15 août 2026", motif: "Frais de rapatriement d'équipage")
    }
    static func contact() -> PpContact {
        PpMagasin.partage.contacts.first(where: { $0.nom == "Chloé" })
            ?? PpContact(nom: "Chloé", email: "chloe.bnv@gmail.com",
                         teinte: 0xE17BB2, initiales: "C")
    }
    static func abonnement() -> PpAbonnement {
        PpMagasin.partage.abonnements.first
            ?? PpAbonnement(nom: "Spotify AB", montant: 11.99, periode: "par mois",
                            source: "Solde PayPal", depuis: "5 février 2024")
    }
    static var ongletDemande: Int {
        Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "0") ?? 0
    }
}

/// Enveloppe de capture d'un écran POUSSÉ : dans le jeu, la BarreHome est portée par
/// `PayPalVue` (hors NavigationStack). En capture isolée, cette enveloppe la restitue,
/// pour que la capsule soit visible sur toutes les images du pipeline Miroir.
struct PpEcranCapture<Contenu: View>: View {
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack { contenu() }
                .tint(PpTeinte.bleu)
            BarreHome { }
        }
        .background(PpTeinte.fond)
    }
}

// ============================================================ FORMATS
enum PpFormat {
    static func montant(_ v: Double) -> String {
        let absolu = abs(v)
        let entier = absolu.rounded()
        if abs(absolu - entier) < 0.005 {
            return String(format: "%.0f €", absolu)
        }
        return String(format: "%.2f €", absolu).replacingOccurrences(of: ".", with: ",")
    }
    static func signe(_ v: Double) -> String {
        if v > 0 { return "+" + montant(v) }
        if v < 0 { return "−" + montant(v) }
        return montant(v)
    }
    static func solde(_ v: Double) -> String {
        String(format: "%.2f €", v).replacingOccurrences(of: ".", with: ",")
    }
    static func reference() -> String {
        let lettres = "ABCDEFGHJKLMNPQRSTVWXYZ"
        let chiffres = "0123456789"
        var s = ""
        for i in 0..<13 {
            if i % 3 == 0 {
                s.append(lettres.randomElement() ?? "A")
            } else {
                s.append(chiffres.randomElement() ?? "0")
            }
        }
        return s
    }
}

// ============================================================ BRIQUES VISUELLES

// Avatar : rond noir « boutique » pour les marchands (e049), rond de couleur + initiales sinon.
struct PpAvatar: View {
    let initiales: String
    let teinte: UInt
    let marchand: Bool
    var diametre: CGFloat = 47

    var body: some View {
        Circle()
            .fill(marchand ? Color(hex: 0x111214) : Color(hex: teinte))
            .frame(width: diametre, height: diametre)
            .overlay {
                if marchand {
                    Image(systemName: "storefront.fill")
                        .font(.system(size: diametre * 0.42))
                        .foregroundStyle(Color.white)
                } else {
                    Text(initiales)
                        .font(.system(size: diametre * 0.36, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
            }
    }
}

// Carte blanche à coins 16 pt (24 px sur les frames)
struct PpCarte<Contenu: View>: View {
    var marge: CGFloat = 14
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { contenu() }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(marge)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(PpTeinte.carte)
            }
            .padding(.horizontal, 16)
    }
}

// Titre de section hors carte : « De », « Comment pouvons-nous vous aider ? »
struct PpTitreSection: View {
    let texte: String
    var body: some View {
        Text(texte)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(PpTeinte.texte)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 8)
    }
}

// Barre de titre des écrans poussés : chevron de retour + titre centré (e049/e091/e215)
struct PpBarreTitre: View {
    let titre: String
    @Environment(\.dismiss) private var revenir
    var body: some View {
        ZStack {
            Text(titre)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(PpTeinte.texte)
            HStack {
                Button {
                    revenir()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(PpTeinte.texte)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }
}

// En-tête des 4 onglets racines : ≡ à gauche, cloche + profil à droite (e044/e116/e196)
struct PpEnTeteRacine: View {
    @ObservedObject private var magasin = PpMagasin.partage
    var body: some View {
        HStack {
            NavigationLink {
                PpMenuVue()
            } label: {
                PpRondEnTete(systeme: "line.3.horizontal")
            }
            .buttonStyle(.plain)
            Spacer()
            NavigationLink {
                PpNotificationsVue()
            } label: {
                PpRondEnTete(systeme: "bell")
                    .overlay(alignment: .topTrailing) {
                        if magasin.notificationsNonLues > 0 {
                            Text("\(magasin.notificationsNonLues)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.white)
                                .frame(width: 19, height: 19)
                                .background { Circle().fill(PpTeinte.rouge) }
                                .offset(x: 2, y: -2)
                        }
                    }
            }
            .buttonStyle(.plain)
            NavigationLink {
                PpProfilVue()
            } label: {
                PpRondEnTete(systeme: "person")
            }
            .buttonStyle(.plain)
            .padding(.leading, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }
}

struct PpRondEnTete: View {
    let systeme: String
    var body: some View {
        Circle()
            .fill(PpTeinte.carte)
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: systeme)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(PpTeinte.bleu)
            }
    }
}

// Grand titre d'onglet : « Activité », « Comptes », « Envoyer et demander » (e116/e196/e249)
struct PpGrandTitre: View {
    let texte: String
    var body: some View {
        Text(texte)
            .font(.system(size: 28, weight: .heavy))
            .foregroundStyle(PpTeinte.texte)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 6)
    }
}

// Champ de recherche en pilule (e116/e196) — sans micro de dictée
struct PpChampRecherche: View {
    let invite: String
    @Binding var texte: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(PpTeinte.gris)
            TextField(invite, text: $texte)
                .font(.system(size: 16))
                .foregroundStyle(PpTeinte.texte)
                .autocorrectionDisabled(true)
            if !texte.isEmpty {
                Button {
                    texte = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(PpTeinte.grisClair)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
        .background {
            Capsule().fill(PpTeinte.carte)
        }
        .overlay {
            Capsule().stroke(Color(hex: 0xD6D6E0), lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }
}

// Rangée d'une transaction (e049/e116)
struct PpLigneTx: View {
    let tx: PpTx
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            PpAvatar(initiales: tx.initiales, teinte: tx.teinte, marchand: tx.marchand)
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.tiers)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PpTeinte.texte)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(tx.date)
                    .font(.system(size: 13))
                    .foregroundStyle(PpTeinte.gris)
                Text(tx.sousTitre)
                    .font(.system(size: 13))
                    .foregroundStyle(PpTeinte.gris)
                if !tx.note.isEmpty {
                    Text("« " + tx.note + " »")
                        .font(.system(size: 13))
                        .foregroundStyle(PpTeinte.texte)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            Text(PpFormat.signe(tx.montant))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tx.montant > 0 ? PpTeinte.vert : PpTeinte.texte)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

// Bouton noir pleine largeur (e209 « OK », e225 « Envoyer »)
struct PpBoutonNoir: View {
    let titre: String
    var actif: Bool = true
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(titre)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    Capsule().fill(actif ? Color(hex: 0x0B0B0C) : Color(hex: 0x9A9AA0))
                }
        }
        .buttonStyle(.plain)
        .disabled(!actif)
    }
}

// Rangée de réglage / de menu, avec pictogramme (e151/e256)
struct PpLigneMenu: View {
    let systeme: String
    let titre: String
    var chevron: Bool = false
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systeme)
                .font(.system(size: 18))
                .foregroundStyle(PpTeinte.texte)
                .frame(width: 26)
            Text(titre)
                .font(.system(size: 16))
                .foregroundStyle(PpTeinte.texte)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 6)
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PpTeinte.grisClair)
            }
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

// Groupe de rangées dans une carte blanche (e151)
struct PpGroupe<Contenu: View>: View {
    @ViewBuilder var contenu: () -> Contenu
    var body: some View {
        VStack(spacing: 0) { contenu() }
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(PpTeinte.carte)
            }
            .padding(.horizontal, 16)
    }
}

// ============================================================ RACINE

struct PayPalVue: View {
    @Environment(\.dismiss) private var quitter
    @State private var onglet: Int

    init(onglet: Int = 0) {
        _onglet = State(initialValue: onglet)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                ZStack {
                    PpTeinte.fond.ignoresSafeArea()
                    VStack(spacing: 0) {
                        contenuOnglet
                        PpBarreOnglets(onglet: $onglet)
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
            }
            .tint(PpTeinte.bleu)
            BarreHome { quitter() }
        }
        .background(PpTeinte.fond)
    }

    @ViewBuilder
    private var contenuOnglet: some View {
        switch onglet {
        case 1: PpComptesVue()
        case 2: PpEnvoyerVue()
        case 3: PpActiviteVue()
        default: PpAccueilVue(onglet: $onglet)
        }
    }
}

// Barre d'onglets : Accueil / Comptes / Envoyer/demander / Activité (e044)
// Elle est placée AU-DESSUS de BarreHome (marge basse de 22 pt).
struct PpBarreOnglets: View {
    @Binding var onglet: Int
    private let items: [(String, String)] = [
        ("Accueil", "house"),
        ("Comptes", "wallet.pass"),
        ("Envoyer/demander", "arrow.up.arrow.down"),
        ("Activité", "text.below.photo")
    ]
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { paire in
                let index = paire.offset
                let item = paire.element
                Button {
                    onglet = index
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: item.1)
                            .font(.system(size: 20,
                                          weight: onglet == index ? Font.Weight.semibold : Font.Weight.regular))
                        Text(item.0)
                            .font(.system(size: 11,
                                          weight: onglet == index ? Font.Weight.bold : Font.Weight.regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(onglet == index ? PpTeinte.texte : PpTeinte.gris)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 10)
        .padding(.bottom, 22)
        .background(PpTeinte.fond)
        .overlay(alignment: .top) {
            Rectangle().fill(Color(hex: 0xDCDCE6)).frame(height: 0.5)
        }
    }
}

// ============================================================ ONGLET 1 — ACCUEIL (e044 / e106 / e263)

struct PpAccueilVue: View {
    @Binding var onglet: Int
    @ObservedObject private var magasin = PpMagasin.partage

    private var recentes: [PpTx] { Array(magasin.transactions.prefix(3)) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PpEnTeteRacine()
                carteSolde
                PpTitreSection(texte: "Produit phare")
                cartePhare
                enTeteActivite
                listeRecente
                Spacer(minLength: 24)
            }
        }
    }

    private var carteSolde: some View {
        NavigationLink {
            PpSoldeVue()
        } label: {
            PpCarte(marge: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "p.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(hex: 0x003087))
                    Text("Solde PayPal")
                        .font(.system(size: 16))
                        .foregroundStyle(PpTeinte.texte)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(PpTeinte.grisClair)
                }
                Spacer(minLength: 34)
                Text(PpFormat.solde(magasin.solde))
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(PpTeinte.texte)
            }
            .frame(height: 150)
        }
        .buttonStyle(.plain)
        .padding(.top, 14)
    }

    // « Tous vos abonnements, zéro complication » — le bouton Démarrer mène à un écran RÉEL.
    private var cartePhare: some View {
        NavigationLink {
            PpAbonnementsVue()
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                Text("Tous vos abonnements,\nzéro complication")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(PpTeinte.texte)
                    .multilineTextAlignment(.leading)
                HStack(alignment: .center) {
                    Text("Gérez vos abonnements\nau même endroit.")
                        .font(.system(size: 15))
                        .foregroundStyle(PpTeinte.texte)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("Démarrer")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 20)
                        .frame(height: 42)
                        .background { Capsule().fill(Color(hex: 0x0B0B0C)) }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(PpTeinte.phare)
            }
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }

    private var enTeteActivite: some View {
        HStack {
            Text("Activité récente")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(PpTeinte.texte)
            Spacer()
            Button {
                onglet = 3
            } label: {
                HStack(spacing: 4) {
                    Text("Afficher plus")
                        .font(.system(size: 15))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(PpTeinte.gris)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    private var listeRecente: some View {
        VStack(spacing: 10) {
            ForEach(recentes) { tx in
                NavigationLink {
                    PpTransactionVue(tx: tx)
                } label: {
                    PpCarte { PpLigneTx(tx: tx) }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ------------------------------------------------------------ Solde PayPal (e106)

struct PpSoldeVue: View {
    @ObservedObject private var magasin = PpMagasin.partage
    private var recentes: [PpTx] { Array(magasin.transactions.prefix(2)) }

    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Solde PayPal")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        carte
                        onglets
                        lignes
                        NavigationLink {
                            PpToutesTransactionsVue()
                        } label: {
                            Text("Tout afficher")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(PpTeinte.lien)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var carte: some View {
        PpCarte(marge: 16) {
            HStack(spacing: 10) {
                Image(systemName: "p.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color(hex: 0x003087))
                Text("Solde PayPal")
                    .font(.system(size: 16))
                    .foregroundStyle(PpTeinte.texte)
            }
            Spacer(minLength: 24)
            Text(PpFormat.solde(magasin.solde))
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(PpTeinte.texte)
            Spacer(minLength: 24)
        }
        .frame(height: 200)
        .padding(.top, 8)
    }

    // Le sélecteur « Activité / Devises » des frames est réduit à son seul onglet réel :
    // Sarah n'a qu'un solde en euros (D92 — pas d'onglet vide).
    private var onglets: some View {
        HStack {
            Text("Activité")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background { Capsule().fill(Color(hex: 0x0B0B0C)) }
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    private var lignes: some View {
        VStack(spacing: 10) {
            ForEach(recentes) { tx in
                NavigationLink {
                    PpTransactionVue(tx: tx)
                } label: {
                    PpCarte {
                        HStack(spacing: 14) {
                            PpAvatar(initiales: tx.initiales, teinte: tx.teinte, marchand: tx.marchand)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tx.tiers)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(PpTeinte.texte)
                                Text(tx.sousTitre)
                                    .font(.system(size: 14))
                                    .foregroundStyle(PpTeinte.gris)
                            }
                            Spacer()
                            Text(PpFormat.signe(tx.montant))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(tx.montant > 0 ? PpTeinte.vert : PpTeinte.texte)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ------------------------------------------------------------ Transactions de solde PayPal (e049)

struct PpToutesTransactionsVue: View {
    @ObservedObject private var magasin = PpMagasin.partage
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Transactions de solde PayPal")
                ScrollView(showsIndicators: false) {
                    PpCarte(marge: 0) {
                        ForEach(Array(magasin.transactions.enumerated()), id: \.element.id) { paire in
                            NavigationLink {
                                PpTransactionVue(tx: paire.element)
                            } label: {
                                PpLigneTx(tx: paire.element)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                            if paire.offset < magasin.transactions.count - 1 {
                                Rectangle().fill(Color(hex: 0xEFEFF4))
                                    .frame(height: 1)
                                    .padding(.leading, 74)
                            }
                        }
                    }
                    .padding(.top, 8)
                    Spacer(minLength: 40)
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ------------------------------------------------------------ Détail d'une transaction (e091 / e127)

struct PpTransactionVue: View {
    let tx: PpTx
    @State private var infosPaiement = false

    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: tx.titreEcran)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        carteEnTete
                        if tx.genre == .interrompu { bandeauInterrompu }
                        if tx.genre == .rembourse { bandeauRembourse }
                        if !tx.commande.isEmpty { blocCommande }
                        blocSource
                        blocReference
                        blocAide
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $infosPaiement) {
            PpInfosPaiementFeuille(tx: tx)
        }
    }

    private var carteEnTete: some View {
        PpCarte(marge: 16) {
            HStack(alignment: .top, spacing: 14) {
                PpAvatar(initiales: tx.initiales, teinte: tx.teinte, marchand: tx.marchand)
                VStack(alignment: .leading, spacing: 4) {
                    Text(tx.tiers)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(PpTeinte.texte)
                        .multilineTextAlignment(.leading)
                    Text(tx.date + (tx.heure.isEmpty ? "" : ", " + tx.heure))
                        .font(.system(size: 14))
                        .foregroundStyle(PpTeinte.gris)
                    NavigationLink {
                        PpHistoriqueVue(tiers: tx.tiers, initiales: tx.initiales,
                                        teinte: tx.teinte, marchand: tx.marchand)
                    } label: {
                        Text("Afficher l'historique")
                            .font(.system(size: 15, weight: .semibold))
                            .underline()
                            .foregroundStyle(PpTeinte.lien)
                    }
                    .buttonStyle(.plain)
                    if !tx.note.isEmpty {
                        Text("« " + tx.note + " »")
                            .font(.system(size: 15))
                            .foregroundStyle(PpTeinte.texte)
                            .padding(.top, 2)
                    }
                }
                Spacer(minLength: 6)
                Text(PpFormat.signe(tx.montant))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(tx.montant > 0 ? PpTeinte.vert : PpTeinte.texte)
            }
        }
        .padding(.top, 8)
    }

    private var bandeauInterrompu: some View {
        PpCarte {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 19))
                    .foregroundStyle(PpTeinte.texte)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nous avons interrompu ce paiement pour vous protéger.")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(PpTeinte.texte)
                    Text("Aucun montant n'a été débité. Nous pensons que ce paiement pourrait être une arnaque.")
                        .font(.system(size: 14))
                        .foregroundStyle(PpTeinte.gris)
                }
            }
        }
        .padding(.top, 10)
    }

    private var bandeauRembourse: some View {
        PpCarte {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "arrow.uturn.backward.circle")
                    .font(.system(size: 19))
                    .foregroundStyle(PpTeinte.texte)
                Text("Cet achat a été remboursé le " + tx.date + ".")
                    .font(.system(size: 15))
                    .foregroundStyle(PpTeinte.texte)
            }
        }
        .padding(.top, 10)
    }

    private var blocCommande: some View {
        VStack(alignment: .leading, spacing: 0) {
            PpTitreSection(texte: "Récapitulatif de la commande")
            PpCarte {
                Text(tx.commande)
                    .font(.system(size: 15))
                    .foregroundStyle(PpTeinte.texte)
            }
        }
    }

    private var blocSource: some View {
        VStack(alignment: .leading, spacing: 0) {
            PpTitreSection(texte: "De")
            PpCarte {
                Text(tx.source)
                    .font(.system(size: 16))
                    .foregroundStyle(PpTeinte.texte)
                if tx.source.contains("Visa") {
                    Text("••••4417")
                        .font(.system(size: 15))
                        .foregroundStyle(PpTeinte.texte)
                        .padding(.top, 2)
                }
                Button {
                    infosPaiement = true
                } label: {
                    Text("Afficher les informations de paiement")
                        .font(.system(size: 15, weight: .semibold))
                        .underline()
                        .foregroundStyle(PpTeinte.lien)
                        .padding(.top, 6)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var blocReference: some View {
        VStack(alignment: .leading, spacing: 0) {
            PpTitreSection(texte: "Vous et " + tx.tiers)
            PpCarte {
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .font(.system(size: 17))
                        .foregroundStyle(PpTeinte.bleu)
                    Text(tx.email.isEmpty ? "Adresse email" : tx.email)
                        .font(.system(size: 15))
                        .foregroundStyle(PpTeinte.texte)
                }
                Rectangle().fill(Color(hex: 0xEFEFF4)).frame(height: 1).padding(.vertical, 12)
                Text("Numéro de transaction")
                    .font(.system(size: 14))
                    .foregroundStyle(PpTeinte.gris)
                Text(tx.reference)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(PpTeinte.texte)
                    .textSelection(.enabled)
            }
        }
    }

    private var blocAide: some View {
        VStack(alignment: .leading, spacing: 0) {
            PpTitreSection(texte: "Comment pouvons-nous vous aider ?")
            PpCarte {
                NavigationLink {
                    PpAideVue(sujet: tx.tiers, reference: tx.reference)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 19))
                            .foregroundStyle(PpTeinte.bleu)
                        Text("Obtenir des réponses")
                            .font(.system(size: 16))
                            .foregroundStyle(PpTeinte.texte)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                NavigationLink {
                    PpSignalerVue(sujet: tx.tiers, reference: tx.reference)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 19))
                            .foregroundStyle(PpTeinte.bleu)
                        Text("Signaler un problème")
                            .font(.system(size: 16))
                            .foregroundStyle(PpTeinte.texte)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// Feuille « Informations de paiement » (e090)
struct PpInfosPaiementFeuille: View {
    let tx: PpTx
    @Environment(\.dismiss) private var fermer
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Informations de paiement")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(PpTeinte.texte)
                Spacer()
                Button {
                    fermer()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PpTeinte.texte)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 18)

            VStack(spacing: 0) {
                PpLigneInfo(cle: tx.source, valeur: PpFormat.montant(tx.montant))
                PpLigneInfo(cle: "Frais PayPal", valeur: "0,00 €")
                PpLigneInfo(cle: "Type de paiement",
                            valeur: tx.entreProches ? "Entre proches" : "Biens et services")
                PpLigneInfo(cle: "Numéro de transaction", valeur: tx.reference)
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .background(PpTeinte.carte)
        .presentationDetents([.height(320)])
    }
}

struct PpLigneInfo: View {
    let cle: String
    let valeur: String
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(cle)
                    .font(.system(size: 15))
                    .foregroundStyle(PpTeinte.gris)
                Spacer(minLength: 12)
                Text(valeur)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(PpTeinte.texte)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 12)
            Rectangle().fill(Color(hex: 0xEFEFF4)).frame(height: 1)
        }
    }
}

// ------------------------------------------------------------ Historique « Vous et X » (e082)

struct PpHistoriqueVue: View {
    let tiers: String
    let initiales: String
    let teinte: UInt
    let marchand: Bool
    @ObservedObject private var magasin = PpMagasin.partage

    private var lignes: [PpTx] { magasin.lignes(pour: tiers) }

    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Historique")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        bandeau
                        PpCarte(marge: 0) {
                            ForEach(Array(lignes.enumerated()), id: \.element.id) { paire in
                                NavigationLink {
                                    PpTransactionVue(tx: paire.element)
                                } label: {
                                    ligne(paire.element)
                                }
                                .buttonStyle(.plain)
                                if paire.offset < lignes.count - 1 {
                                    Rectangle().fill(Color(hex: 0xEFEFF4))
                                        .frame(height: 1).padding(.horizontal, 14)
                                }
                            }
                        }
                        .padding(.top, 14)
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var bandeau: some View {
        VStack(spacing: 10) {
            HStack(spacing: -14) {
                PpAvatar(initiales: "SL", teinte: 0x1053CE, marchand: false, diametre: 48)
                PpAvatar(initiales: initiales, teinte: teinte, marchand: marchand, diametre: 48)
            }
            Text("Vous et " + tiers)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PpTeinte.texte)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(PpTeinte.carte)
    }

    private func ligne(_ tx: PpTx) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(tx.tiers)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PpTeinte.texte)
                Text(tx.date + " • " + tx.sousTitre)
                    .font(.system(size: 13))
                    .foregroundStyle(PpTeinte.gris)
            }
            Spacer(minLength: 8)
            Text(PpFormat.signe(tx.montant))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tx.montant > 0 ? PpTeinte.vert : PpTeinte.texte)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// ------------------------------------------------------------ Aide (2 pages sobres, filmées en libellé)

struct PpAideVue: View {
    let sujet: String
    let reference: String
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Obtenir des réponses")
                ScrollView(showsIndicators: false) {
                    PpCarte {
                        Text("Transaction " + reference)
                            .font(.system(size: 14))
                            .foregroundStyle(PpTeinte.gris)
                        Text("Un paiement envoyé « entre proches » n'est pas couvert par la Protection des Acheteurs. Il ne peut pas être annulé une fois qu'il a été accepté par le destinataire.")
                            .font(.system(size: 15))
                            .foregroundStyle(PpTeinte.texte)
                            .padding(.top, 10)
                        Text("Si vous pensez avoir été victime d'une arnaque, signalez le paiement : nous transmettons le dossier à notre service Sécurité.")
                            .font(.system(size: 15))
                            .foregroundStyle(PpTeinte.texte)
                            .padding(.top, 10)
                    }
                    .padding(.top, 10)
                    Spacer(minLength: 40)
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PpSignalerVue: View {
    let sujet: String
    let reference: String
    @Environment(\.dismiss) private var revenir
    @State private var envoye = false

    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Signaler un problème")
                ScrollView(showsIndicators: false) {
                    PpCarte {
                        Text("Transaction " + reference)
                            .font(.system(size: 14))
                            .foregroundStyle(PpTeinte.gris)
                        Text("Je n'ai pas reçu ce que j'ai payé, ou je pense avoir été victime d'une arnaque impliquant " + sujet + ".")
                            .font(.system(size: 15))
                            .foregroundStyle(PpTeinte.texte)
                            .padding(.top, 10)
                    }
                    .padding(.top, 10)
                    if envoye {
                        PpCarte {
                            Text("Signalement enregistré. Notre service Sécurité revient vers vous sous 48 h à l'adresse sarah.levasseur@icloud.com.")
                                .font(.system(size: 15))
                                .foregroundStyle(PpTeinte.texte)
                        }
                        .padding(.top, 12)
                    }
                    Spacer(minLength: 30)
                }
                PpBoutonNoir(titre: envoye ? "Terminé" : "Envoyer le signalement") {
                    if envoye { revenir() } else { envoye = true }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ============================================================ ONGLET 2 — COMPTES (e249 / e243)

struct PpComptesVue: View {
    @ObservedObject private var magasin = PpMagasin.partage
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PpEnTeteRacine()
                PpGrandTitre(texte: "Comptes")
                carteSolde
                PpTitreSection(texte: "Comptes et cartes bancaires")
                carteBancaire
                PpTitreSection(texte: "Préférences")
                preferences
                Spacer(minLength: 30)
            }
        }
    }

    private var carteSolde: some View {
        NavigationLink {
            PpSoldeVue()
        } label: {
            PpCarte(marge: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "p.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(hex: 0x003087))
                    Text("Solde PayPal")
                        .font(.system(size: 16))
                        .foregroundStyle(PpTeinte.texte)
                    Spacer()
                    Text(PpFormat.solde(magasin.solde))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PpTeinte.texte)
                }
                Spacer(minLength: 26)
                Text(PpFormat.solde(magasin.solde))
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(PpTeinte.texte)
            }
            .frame(height: 170)
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
    }

    private var carteBancaire: some View {
        NavigationLink {
            PpCarteBancaireVue()
        } label: {
            PpVisuelCarteLCL()
                .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }

    private var preferences: some View {
        PpGroupe {
            HStack(spacing: 14) {
                Image(systemName: "cart")
                    .font(.system(size: 18))
                    .foregroundStyle(PpTeinte.texte)
                    .frame(width: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achats en ligne")
                        .font(.system(size: 16))
                        .foregroundStyle(PpTeinte.texte)
                    Text("Solde PayPal")
                        .font(.system(size: 13))
                        .foregroundStyle(PpTeinte.gris)
                }
                Spacer()
            }
            .padding(.vertical, 14)
        }
    }
}

// Visuel de la Visa LCL de Sarah (D59 : remplace les cartes Wise/CA/bunq des frames)
struct PpVisuelCarteLCL: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0x0B2E5C), Color(hex: 0x061C3A)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text("LCL")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(Color(hex: 0xF5C400))
                    Spacer()
                    Text("VISA")
                        .font(.system(size: 17, weight: .heavy))
                        .italic()
                        .foregroundStyle(Color.white)
                }
                Spacer()
                Text("•••• •••• •••• 4417")
                    .font(.system(size: 17, weight: .semibold))
                    .kerning(1.5)
                    .foregroundStyle(Color.white)
                Text("SARAH LEVASSEUR")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.top, 6)
            }
            .padding(16)
        }
        .frame(height: 130)
    }
}

// Détail d'une carte (e243) — en lecture seule (Renommer / Modifier / Supprimer retirés, D92)
struct PpCarteBancaireVue: View {
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "••••4417")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        PpVisuelCarteLCL().padding(.horizontal, 16).padding(.top, 8)
                        PpGroupe {
                            PpLigneCle(cle: "Nom", valeur: "Visa LCL ••••4417")
                            PpLigneCle(cle: "Date d'expiration", valeur: "11/28")
                            PpLigneCle(cle: "Adresse de facturation",
                                       valeur: "14 rue des Fantasques\n69001 Lyon")
                            PpLigneCle(cle: "Devise", valeur: "EUR", dernier: true)
                        }
                        .padding(.top, 18)
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PpLigneCle: View {
    let cle: String
    let valeur: String
    var dernier: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(cle)
                    .font(.system(size: 15))
                    .foregroundStyle(PpTeinte.gris)
                Spacer(minLength: 12)
                Text(valeur)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(PpTeinte.texte)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 14)
            if !dernier {
                Rectangle().fill(Color(hex: 0xEFEFF4)).frame(height: 1)
            }
        }
    }
}

// ============================================================ ONGLET 3 — ENVOYER ET DEMANDER (e196)

struct PpEnvoyerVue: View {
    @ObservedObject private var magasin = PpMagasin.partage
    @State private var recherche = ""

    private var suggestions: [PpContact] {
        if recherche.isEmpty { return magasin.contacts }
        let q = recherche.lowercased()
        return magasin.contacts.filter {
            $0.nom.lowercased().contains(q) || $0.email.lowercased().contains(q)
                || $0.pseudo.lowercased().contains(q)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PpEnTeteRacine()
                PpGrandTitre(texte: "Envoyer et demander")
                PpChampRecherche(invite: "Nom, adresse email…", texte: $recherche)
                    .padding(.top, 14)
                PpCarte(marge: 0) {
                    Text("Suggestions")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(PpTeinte.texte)
                        .padding(.horizontal, 16)
                        .padding(.top, 18)
                        .padding(.bottom, 6)
                    if suggestions.isEmpty {
                        Text("Aucun destinataire ne correspond à « " + recherche + " ».")
                            .font(.system(size: 15))
                            .foregroundStyle(PpTeinte.gris)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 24)
                    }
                    ForEach(suggestions) { contact in
                        NavigationLink {
                            PpMontantVue(contact: contact)
                        } label: {
                            ligne(contact)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 16)
                Spacer(minLength: 30)
            }
        }
    }

    private func ligne(_ contact: PpContact) -> some View {
        HStack(spacing: 14) {
            PpAvatar(initiales: contact.initiales, teinte: contact.teinte,
                     marchand: contact.marchand, diametre: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.nom)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PpTeinte.texte)
                Text(contact.pseudo.isEmpty ? contact.email : contact.pseudo)
                    .font(.system(size: 13))
                    .foregroundStyle(PpTeinte.gris)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(PpTeinte.grisClair)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

// ------------------------------------------------------------ Montant + pavé (e215)

struct PpMontantVue: View {
    let contact: PpContact
    @Environment(\.dismiss) private var revenir
    @ObservedObject private var magasin = PpMagasin.partage

    @State private var saisie = "0"
    @State private var note = ""
    @State private var feuilleEnvoi = false
    @State private var interrompu = false
    @State private var confirmation = false
    @State private var montantEnvoye = ""
    @State private var messageLocal: String? = nil

    private var montant: Double {
        Double(saisie.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    private var montantAffiche: String { "€" + saisie }

    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Montant")
                enTeteDestinataire
                montantLigne
                if let messageLocal {
                    Text(messageLocal)
                        .font(.system(size: 14))
                        .foregroundStyle(PpTeinte.rouge)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                }
                Spacer(minLength: 10)
                champNote
                boutons
                PpPave(saisie: $saisie, avantSaisie: { messageLocal = nil })
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $feuilleEnvoi) {
            PpFeuilleEnvoi(contact: contact, montant: montant, note: note,
                           surRefus: { texte in messageLocal = texte },
                           surInterruption: { interrompu = true },
                           surSucces: {
                               montantEnvoye = PpFormat.solde(montant)
                               confirmation = true
                           })
        }
        // Recouvrements internes (et non fullScreenCover) : la BarreHome de la coque
        // reste visible et fonctionnelle sur ces deux écrans (bug de navigation Facebook).
        .overlay {
            if interrompu {
                PpInterrompuVue { interrompu = false }
            }
        }
        .overlay {
            if confirmation {
                PpConfirmationVue(destinataire: contact.nom, montant: montantEnvoye) {
                    confirmation = false
                    revenir()
                }
            }
        }
    }

    private var enTeteDestinataire: some View {
        HStack(spacing: 16) {
            PpAvatar(initiales: contact.initiales, teinte: contact.teinte,
                     marchand: contact.marchand, diametre: 64)
            Text(contact.nom)
                .font(.system(size: 20))
                .foregroundStyle(PpTeinte.texte)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 26)
    }

    private var montantLigne: some View {
        HStack(alignment: .center) {
            Text(montantAffiche)
                .font(.system(size: 46, weight: .regular))
                .foregroundStyle(PpTeinte.texte)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Spacer()
            Text("EUR")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(PpTeinte.texte)
                .padding(.horizontal, 18)
                .frame(height: 36)
                .overlay { Capsule().stroke(PpTeinte.texte, lineWidth: 1) }
        }
        .padding(.horizontal, 16)
        .padding(.top, 22)
    }

    private var champNote: some View {
        TextField("Ajouter une note", text: $note)
            .font(.system(size: 16))
            .foregroundStyle(PpTeinte.texte)
            .padding(.horizontal, 18)
            .frame(height: 50)
            .background { Capsule().fill(Color(hex: 0xF3F3F7)) }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
    }

    private var boutons: some View {
        HStack(spacing: 14) {
            Button {
                messageLocal = magasin.demander(montant, a: contact, note: note)
                if messageLocal == nil { revenir() }
            } label: {
                Text("Demander")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background { Capsule().fill(Color(hex: 0x0B0B0C)) }
            }
            .buttonStyle(.plain)
            Button {
                if montant <= 0 {
                    messageLocal = "Saisissez un montant supérieur à 0,00 €."
                } else {
                    messageLocal = nil
                    feuilleEnvoi = true
                }
            } label: {
                Text("Envoyer")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background { Capsule().fill(Color(hex: 0x0B0B0C)) }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

// Pavé numérique du montant (e215) — pas de clavier système, pas de micro
struct PpPave: View {
    @Binding var saisie: String
    var avantSaisie: () -> Void = {}
    private let touches: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [",", "0", "⌫"]
    ]
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(touches.enumerated()), id: \.offset) { rangee in
                HStack(spacing: 0) {
                    ForEach(rangee.element, id: \.self) { touche in
                        Button {
                            avantSaisie()
                            appuyer(touche)
                        } label: {
                            Group {
                                if touche == "⌫" {
                                    Image(systemName: "delete.left")
                                        .font(.system(size: 20))
                                } else {
                                    Text(touche)
                                        .font(.system(size: 26, weight: .regular))
                                }
                            }
                            .foregroundStyle(PpTeinte.texte)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
    }

    private func appuyer(_ touche: String) {
        switch touche {
        case "⌫":
            if saisie.count <= 1 { saisie = "0" } else { saisie.removeLast() }
            if saisie.isEmpty { saisie = "0" }
        case ",":
            if !saisie.contains(",") { saisie += "," }
        default:
            if saisie == "0" {
                saisie = touche
            } else if saisie.count < 8 {
                if let virgule = saisie.firstIndex(of: ",") {
                    let decimales = saisie.distance(from: virgule, to: saisie.endIndex) - 1
                    if decimales < 2 { saisie += touche }
                } else {
                    saisie += touche
                }
            }
        }
    }
}

// ------------------------------------------------------------ Feuille d'envoi (e226 → e225 → e228)

enum PpEtapeEnvoi {
    case type
    case verifier
    case source
}

struct PpFeuilleEnvoi: View {
    let contact: PpContact
    let montant: Double
    let note: String
    let surRefus: (String) -> Void
    let surInterruption: () -> Void
    let surSucces: () -> Void

    @Environment(\.dismiss) private var fermer
    @ObservedObject private var magasin = PpMagasin.partage
    @State private var etape: PpEtapeEnvoi = .type
    @State private var entreProches = true
    @State private var indexSource = 0
    @State private var refusLocal: String? = nil

    private var source: PpSource { magasin.sources[indexSource] }

    var body: some View {
        VStack(spacing: 0) {
            barre
            ScrollView(showsIndicators: false) {
                switch etape {
                case .type: etapeType
                case .verifier: etapeVerifier
                case .source: etapeSource
                }
            }
            piedDePage
        }
        .background(PpTeinte.carte)
        .presentationDetents([.height(520)])
    }

    private var titre: String {
        switch etape {
        case .type: return "Type de paiement"
        case .verifier: return "Vérifier"
        case .source: return "Comment voulez-vous payer ?"
        }
    }

    private var barre: some View {
        ZStack {
            Text(titre)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(PpTeinte.texte)
                .multilineTextAlignment(.center)
            HStack {
                if etape != .type {
                    Button {
                        etape = etape == PpEtapeEnvoi.source ? PpEtapeEnvoi.verifier : PpEtapeEnvoi.type
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(PpTeinte.texte)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Button {
                    fermer()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(PpTeinte.texte)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    private var etapeType: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Nous enregistrerons cette sélection pour tous les paiements à " + contact.nom + ". Vous pouvez la modifier sur l'écran de vérification.")
                .font(.system(size: 15))
                .foregroundStyle(PpTeinte.gris)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
            choixType(systeme: "storefront",
                      titre: "Pour des biens et services",
                      detail: "Obtenez un remboursement intégral si un objet éligible est perdu ou endommagé. Le vendeur paie de faibles frais.",
                      selection: !entreProches) { entreProches = false }
            choixType(systeme: "person.2",
                      titre: "Pour vos proches",
                      detail: "La Protection des Acheteurs ne s'applique pas pour ce paiement.",
                      selection: entreProches) { entreProches = true }
        }
    }

    private func choixType(systeme: String, titre: String, detail: String,
                           selection: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: systeme)
                    .font(.system(size: 20))
                    .foregroundStyle(PpTeinte.bleu)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 4) {
                    Text(titre)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PpTeinte.texte)
                    Text(detail)
                        .font(.system(size: 14))
                        .foregroundStyle(PpTeinte.gris)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                if selection {
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(PpTeinte.texte)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var etapeVerifier: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                etape = .source
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: source.carte ? "creditcard" : "p.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(source.carte ? PpTeinte.texte : Color(hex: 0x003087))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(source.nom)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PpTeinte.texte)
                        Text(source.detail)
                            .font(.system(size: 14))
                            .foregroundStyle(PpTeinte.gris)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PpTeinte.grisClair)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 14) {
                Image(systemName: entreProches ? "person.2" : "storefront")
                    .font(.system(size: 20))
                    .foregroundStyle(PpTeinte.texte)
                Text(entreProches ? "Entre proches" : "Biens et services")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PpTeinte.texte)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Text(entreProches
                 ? "La Protection des Acheteurs ne s'applique pas pour ce paiement."
                 : "La Protection des Acheteurs s'applique aux objets éligibles.")
                .font(.system(size: 14))
                .foregroundStyle(PpTeinte.gris)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            PpLigneTotal(cle: "Frais PayPal", valeur: "0,00 € EUR", gras: false)
            PpLigneTotal(cle: "Total", valeur: PpFormat.solde(montant) + " EUR", gras: true)
            PpLigneTotal(cle: "Date de versement estimée", valeur: "En quelques secondes", gras: false)

            if let refusLocal {
                Text(refusLocal)
                    .font(.system(size: 14))
                    .foregroundStyle(PpTeinte.rouge)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
            }
        }
    }

    private var etapeSource: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Nous nous en souviendrons la prochaine fois.")
                .font(.system(size: 14))
                .foregroundStyle(PpTeinte.gris)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            ForEach(Array(magasin.sources.enumerated()), id: \.element.id) { paire in
                Button {
                    indexSource = paire.offset
                    refusLocal = nil
                    etape = .verifier
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: paire.element.carte ? "creditcard" : "p.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(paire.element.carte ? PpTeinte.texte : Color(hex: 0x003087))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(paire.element.nom)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(PpTeinte.texte)
                            Text(paire.element.carte
                                 ? paire.element.detail
                                 : paire.element.detail + " : " + PpFormat.solde(magasin.solde))
                                .font(.system(size: 14))
                                .foregroundStyle(PpTeinte.gris)
                        }
                        Spacer()
                        if indexSource == paire.offset {
                            Image(systemName: "checkmark")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(PpTeinte.texte)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 13)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var piedDePage: some View {
        VStack(spacing: 0) {
            switch etape {
            case .type:
                PpBoutonNoir(titre: "Suivant") { etape = .verifier }
            case .verifier:
                PpBoutonNoir(titre: "Envoyer") { valider() }
            case .source:
                PpBoutonNoir(titre: "Terminé") { etape = .verifier }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 26)
    }

    private func valider() {
        if magasin.paiementBloque(pour: contact) {
            fermer()
            surInterruption()
            return
        }
        if let refus = magasin.envoyer(montant, a: contact, note: note,
                                       source: source, entreProches: entreProches) {
            refusLocal = refus
            surRefus(refus)
            return
        }
        fermer()
        surSucces()
    }
}

struct PpLigneTotal: View {
    let cle: String
    let valeur: String
    let gras: Bool
    var body: some View {
        HStack {
            Text(cle)
                .font(.system(size: 15, weight: gras ? Font.Weight.bold : Font.Weight.regular))
                .foregroundStyle(PpTeinte.texte)
            Spacer()
            Text(valeur)
                .font(.system(size: 15, weight: gras ? Font.Weight.bold : Font.Weight.regular))
                .foregroundStyle(PpTeinte.texte)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 9)
    }
}

// ------------------------------------------------------------ Paiement interrompu (e209)

struct PpInterrompuVue: View {
    let fermer: () -> Void
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 60)
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 46, weight: .regular))
                    .foregroundStyle(PpTeinte.texte)
                Text("Nous avons interrompu ce paiement pour vous protéger")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(PpTeinte.texte)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                    .padding(.top, 26)
                Text("Nous pensons que ce paiement pourrait être une arnaque. C'est pourquoi nous avons pris des mesures pour protéger votre argent.")
                    .font(.system(size: 16))
                    .foregroundStyle(PpTeinte.texte)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.top, 22)
                Text("Aucun montant n'a été débité de votre solde ni de votre carte.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PpTeinte.texte)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                Spacer()
                PpBoutonNoir(titre: "OK") { fermer() }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 12)
            }
            .padding(.bottom, 22)
        }
    }
}

// ------------------------------------------------------------ Confirmation d'envoi (e086)

struct PpConfirmationVue: View {
    let destinataire: String
    let montant: String
    let terminer: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        terminer()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(PpTeinte.texte)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                Spacer()
                Circle()
                    .fill(Color(hex: 0x111214))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                Text("Vous avez envoyé à " + destinataire)
                    .font(.system(size: 16))
                    .foregroundStyle(PpTeinte.texte)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                Text(montant)
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(PpTeinte.texte)
                    .padding(.top, 6)
                Spacer()
                PpBoutonNoir(titre: "Terminé") { terminer() }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 12)
            }
            .padding(.bottom, 22)
        }
    }
}

// ============================================================ ONGLET 4 — ACTIVITÉ (e116 / e135)

enum PpFiltreActivite: String, CaseIterable {
    case tout = "Tout"
    case achats = "Achats"
    case envoyesRecus = "Envoyés et reçus"
}

struct PpActiviteVue: View {
    @ObservedObject private var magasin = PpMagasin.partage
    @State private var recherche = ""
    @State private var filtre: PpFiltreActivite = .tout

    private var lignes: [PpTx] {
        var l = magasin.transactions
        switch filtre {
        case .tout: break
        case .achats: l = l.filter { $0.estAchat }
        case .envoyesRecus: l = l.filter { !$0.estAchat }
        }
        if !recherche.isEmpty {
            let q = recherche.lowercased()
            l = l.filter {
                $0.tiers.lowercased().contains(q) || $0.email.lowercased().contains(q)
                    || $0.note.lowercased().contains(q)
            }
        }
        return l
    }

    private var moisOrdonnes: [String] {
        var vus: [String] = []
        for tx in lignes where !vus.contains(tx.mois) { vus.append(tx.mois) }
        return vus
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PpEnTeteRacine()
                PpGrandTitre(texte: "Activité")
                PpChampRecherche(invite: "Recherchez par nom ou adresse email", texte: $recherche)
                    .padding(.top, 14)
                filtres
                demandesEnAttente
                if lignes.isEmpty { vide }
                ForEach(moisOrdonnes, id: \.self) { mois in
                    section(mois)
                }
                Spacer(minLength: 30)
            }
        }
    }

    private var filtres: some View {
        HStack(spacing: 10) {
            ForEach(PpFiltreActivite.allCases, id: \.rawValue) { f in
                Button {
                    filtre = f
                } label: {
                    Text(f.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(filtre == f ? Color.white : PpTeinte.texte)
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                        .background {
                            Capsule().fill(filtre == f ? Color(hex: 0x0B0B0C) : PpTeinte.carte)
                        }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private var demandesEnAttente: some View {
        let attente = magasin.demandes.filter { $0.etat == .attente }
        if !attente.isEmpty && filtre != .achats && recherche.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("En attente")
                    .font(.system(size: 14))
                    .foregroundStyle(PpTeinte.gris)
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                ForEach(attente) { demande in
                    NavigationLink {
                        PpDemandeVue(demande: demande)
                    } label: {
                        PpCarte {
                            HStack(alignment: .top, spacing: 14) {
                                PpAvatar(initiales: demande.initiales, teinte: demande.teinte,
                                         marchand: false)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(demande.tiers)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(PpTeinte.texte)
                                        .multilineTextAlignment(.leading)
                                    Text(demande.date)
                                        .font(.system(size: 13))
                                        .foregroundStyle(PpTeinte.gris)
                                    Text("Demande d'argent reçue")
                                        .font(.system(size: 13))
                                        .foregroundStyle(PpTeinte.gris)
                                }
                                Spacer(minLength: 8)
                                Text(PpFormat.montant(demande.montant))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(PpTeinte.texte)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var vide: some View {
        Text("Aucune opération ne correspond à cette recherche.")
            .font(.system(size: 15))
            .foregroundStyle(PpTeinte.gris)
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
    }

    private func section(_ mois: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(mois)
                .font(.system(size: 14))
                .foregroundStyle(PpTeinte.gris)
                .padding(.horizontal, 16)
                .padding(.top, 18)
            ForEach(lignes.filter { $0.mois == mois }) { tx in
                NavigationLink {
                    PpTransactionVue(tx: tx)
                } label: {
                    PpCarte { PpLigneTx(tx: tx) }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ------------------------------------------------------------ Demande d'argent reçue

struct PpDemandeVue: View {
    let demande: PpDemande
    @Environment(\.dismiss) private var revenir
    @ObservedObject private var magasin = PpMagasin.partage
    @State private var interrompu = false

    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Demande d'argent")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        carteEnTete
                        PpTitreSection(texte: "Motif indiqué")
                        PpCarte {
                            Text(demande.motif)
                                .font(.system(size: 15))
                                .foregroundStyle(PpTeinte.texte)
                        }
                        PpTitreSection(texte: "Comment pouvons-nous vous aider ?")
                        PpCarte {
                            Text("Une demande d'argent ne débite rien tant que vous ne l'avez pas payée. Vous pouvez la refuser sans justification.")
                                .font(.system(size: 15))
                                .foregroundStyle(PpTeinte.texte)
                        }
                        Spacer(minLength: 30)
                    }
                }
                boutons
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if interrompu {
                PpInterrompuVue { interrompu = false }
            }
        }
    }

    private var carteEnTete: some View {
        PpCarte(marge: 16) {
            HStack(alignment: .top, spacing: 14) {
                PpAvatar(initiales: demande.initiales, teinte: demande.teinte, marchand: false)
                VStack(alignment: .leading, spacing: 4) {
                    Text(demande.tiers)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(PpTeinte.texte)
                        .multilineTextAlignment(.leading)
                    Text(demande.email)
                        .font(.system(size: 14))
                        .foregroundStyle(PpTeinte.gris)
                    Text(demande.date)
                        .font(.system(size: 14))
                        .foregroundStyle(PpTeinte.gris)
                }
                Spacer(minLength: 6)
                Text(PpFormat.montant(demande.montant))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(PpTeinte.texte)
            }
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var boutons: some View {
        if demande.etat == .attente {
            HStack(spacing: 14) {
                Button {
                    magasin.refuser(demande)
                    revenir()
                } label: {
                    Text("Refuser")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(PpTeinte.texte)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .overlay { Capsule().stroke(PpTeinte.texte, lineWidth: 1.5) }
                }
                .buttonStyle(.plain)
                Button {
                    interrompu = true
                } label: {
                    Text("Payer")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background { Capsule().fill(Color(hex: 0x0B0B0C)) }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        } else {
            Text("Demande refusée.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(PpTeinte.gris)
                .padding(.bottom, 18)
        }
    }
}

// ============================================================ NOTIFICATIONS (e141)

struct PpNotificationsVue: View {
    @ObservedObject private var magasin = PpMagasin.partage

    private var interrompue: PpTx? {
        magasin.transactions.first { $0.genre == .interrompu }
    }

    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Notifications")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        if let interrompue {
                            NavigationLink {
                                PpTransactionVue(tx: interrompue)
                            } label: {
                                carte(systeme: "checkmark.shield",
                                      titre: "Nous avons interrompu un paiement",
                                      corps: "Votre paiement de " + PpFormat.montant(interrompue.montant)
                                        + " à " + interrompue.tiers
                                        + " a été interrompu : il présente les signes d'une arnaque.",
                                      quand: "16 août")
                            }
                            .buttonStyle(.plain)
                        }
                        ForEach(magasin.demandes) { demande in
                            NavigationLink {
                                PpDemandeVue(demande: demande)
                            } label: {
                                carte(systeme: "arrow.down.circle",
                                      titre: demande.etat == .attente
                                        ? "Demande d'argent reçue"
                                        : "Demande d'argent refusée",
                                      corps: demande.tiers + " vous demande "
                                        + PpFormat.montant(demande.montant) + ".",
                                      quand: "15 août")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 10)
                    Spacer(minLength: 40)
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { magasin.notificationsVues = true }
    }

    private func carte(systeme: String, titre: String, corps: String, quand: String) -> some View {
        PpCarte {
            HStack(alignment: .top, spacing: 14) {
                Circle()
                    .fill(PpTeinte.voile)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: systeme)
                            .font(.system(size: 18))
                            .foregroundStyle(PpTeinte.texte)
                    }
                VStack(alignment: .leading, spacing: 4) {
                    Text(titre)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PpTeinte.texte)
                        .multilineTextAlignment(.leading)
                    Text(corps)
                        .font(.system(size: 14))
                        .foregroundStyle(PpTeinte.gris)
                        .multilineTextAlignment(.leading)
                    Text(quand)
                        .font(.system(size: 13))
                        .foregroundStyle(PpTeinte.grisClair)
                }
                Spacer(minLength: 4)
            }
        }
    }
}

// ============================================================ MENU (e256) — réduit aux rangées qui mènent quelque part

struct PpMenuVue: View {
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Menu")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        PpTitreSection(texte: "Gérer vos finances")
                        PpGroupe {
                            NavigationLink {
                                PpAbonnementsVue()
                            } label: {
                                PpLigneMenu(systeme: "arrow.triangle.2.circlepath",
                                            titre: "Abonnements", chevron: true)
                            }
                            .buttonStyle(.plain)
                            Rectangle().fill(Color(hex: 0xEFEFF4)).frame(height: 1)
                            NavigationLink {
                                PpCarteBancaireVue()
                            } label: {
                                PpLigneMenu(systeme: "creditcard",
                                            titre: "Cartes et comptes bancaires", chevron: true)
                            }
                            .buttonStyle(.plain)
                        }
                        PpTitreSection(texte: "Profil et aide")
                        PpGroupe {
                            NavigationLink {
                                PpProfilVue()
                            } label: {
                                PpLigneMenu(systeme: "person.crop.circle",
                                            titre: "Votre profil", chevron: true)
                            }
                            .buttonStyle(.plain)
                            Rectangle().fill(Color(hex: 0xEFEFF4)).frame(height: 1)
                            NavigationLink {
                                PpParametresVue()
                            } label: {
                                PpLigneMenu(systeme: "gearshape",
                                            titre: "Paramètres", chevron: true)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ============================================================ PROFIL (e147)

struct PpProfilVue: View {
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Compte Particulier")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        carteIdentite
                        PpGroupe {
                            NavigationLink {
                                PpAbonnementsVue()
                            } label: {
                                PpLigneMenu(systeme: "arrow.triangle.2.circlepath",
                                            titre: "Abonnements", chevron: true)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 16)
                        Text("Version 8.107.2")
                            .font(.system(size: 14))
                            .foregroundStyle(PpTeinte.gris)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 26)
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var carteIdentite: some View {
        VStack(alignment: .leading, spacing: 0) {
            LinearGradient(colors: [PpTeinte.violetHaut, PpTeinte.violetBas],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 92)
            VStack(alignment: .leading, spacing: 4) {
                Text("Sarah Levasseur")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(PpTeinte.texte)
                Text("@sarahlev69")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PpTeinte.lien)
                Text("Membre PayPal depuis 2019")
                    .font(.system(size: 15))
                    .foregroundStyle(PpTeinte.texte)
                HStack(spacing: 12) {
                    NavigationLink {
                        PpCoordonneesVue()
                    } label: {
                        PpPiluleProfil(systeme: "person", titre: "Coordonnées")
                    }
                    .buttonStyle(.plain)
                    NavigationLink {
                        PpParametresVue()
                    } label: {
                        PpPiluleProfil(systeme: "gearshape", titre: "Paramètres")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 14)
            }
            .padding(16)
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(PpTeinte.carte)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(PpTeinte.carte)
                .frame(width: 72, height: 72)
                .overlay {
                    Circle()
                        .fill(Color(hex: 0x1053CE))
                        .frame(width: 62, height: 62)
                        .overlay {
                            Text("SL")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                }
                .offset(x: 18, y: 56)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

struct PpPiluleProfil: View {
    let systeme: String
    let titre: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systeme)
                .font(.system(size: 15))
            Text(titre)
                .font(.system(size: 15, weight: .bold))
        }
        .foregroundStyle(PpTeinte.texte)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .overlay { Capsule().stroke(Color(hex: 0xC9C9D2), lineWidth: 1) }
    }
}

// ------------------------------------------------------------ Coordonnées (e150)

struct PpCoordonneesVue: View {
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Coordonnées")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        PpTitreSection(texte: "Emails")
                        PpGroupe {
                            PpLigneCoordonnee(etiquette: "Principal",
                                              valeur: "sarah.levasseur@icloud.com",
                                              dernier: true)
                        }
                        PpTitreSection(texte: "Téléphones")
                        PpGroupe {
                            PpLigneCoordonnee(etiquette: "Principal",
                                              valeur: "06 •• •• •• 42 — Mobile",
                                              dernier: true)
                        }
                        PpTitreSection(texte: "Adresses")
                        PpGroupe {
                            PpLigneCoordonnee(etiquette: "Principal",
                                              valeur: "14 rue des Fantasques\n69001 Lyon",
                                              dernier: true)
                        }
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PpLigneCoordonnee: View {
    let etiquette: String
    let valeur: String
    var dernier: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(etiquette)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background { Capsule().fill(Color(hex: 0x111214)) }
                Text(valeur)
                    .font(.system(size: 15))
                    .foregroundStyle(PpTeinte.texte)
            }
            .padding(.vertical, 14)
            if !dernier {
                Rectangle().fill(Color(hex: 0xEFEFF4)).frame(height: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ------------------------------------------------------------ Paramètres (e151) — 1re page + sous-pages réelles

struct PpParametresVue: View {
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Paramètres")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        PpTitreSection(texte: "Communications")
                        PpGroupe {
                            NavigationLink {
                                PpCoordonneesVue()
                            } label: {
                                PpLigneMenu(systeme: "person", titre: "Coordonnées", chevron: true)
                            }
                            .buttonStyle(.plain)
                            Rectangle().fill(Color(hex: 0xEFEFF4)).frame(height: 1)
                            NavigationLink {
                                PpNotifsReglagesVue()
                            } label: {
                                PpLigneMenu(systeme: "bell.badge",
                                            titre: "Préférences de notification", chevron: true)
                            }
                            .buttonStyle(.plain)
                        }
                        PpTitreSection(texte: "Informations de compte")
                        PpGroupe {
                            NavigationLink {
                                PpSecuriteVue()
                            } label: {
                                PpLigneMenu(systeme: "shield",
                                            titre: "Connexion et sécurité", chevron: true)
                            }
                            .buttonStyle(.plain)
                        }
                        PpTitreSection(texte: "Finances")
                        PpGroupe {
                            NavigationLink {
                                PpCarteBancaireVue()
                            } label: {
                                PpLigneMenu(systeme: "creditcard",
                                            titre: "Préférences de paiement", chevron: true)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PpNotifsReglagesVue: View {
    @ObservedObject private var magasin = PpMagasin.partage
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Préférences de notification")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Choisissez les notifications que vous souhaitez recevoir dans votre application.")
                            .font(.system(size: 14))
                            .foregroundStyle(PpTeinte.gris)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                        PpGroupe {
                            PpInterrupteur(titre: "Réception d'argent",
                                           valeur: $magasin.alerteReceptionArgent)
                            Rectangle().fill(Color(hex: 0xEFEFF4)).frame(height: 1)
                            PpInterrupteur(titre: "Demande d'argent",
                                           valeur: $magasin.alerteDemandeArgent)
                            Rectangle().fill(Color(hex: 0xEFEFF4)).frame(height: 1)
                            PpInterrupteur(titre: "Envoi d'argent",
                                           valeur: $magasin.alerteEnvoiArgent)
                        }
                        .padding(.top, 14)
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PpInterrupteur: View {
    let titre: String
    @Binding var valeur: Bool
    var body: some View {
        Toggle(isOn: $valeur) {
            Text(titre)
                .font(.system(size: 16))
                .foregroundStyle(PpTeinte.texte)
        }
        .tint(Color(hex: 0x111214))
        .padding(.vertical, 12)
    }
}

struct PpSecuriteVue: View {
    @ObservedObject private var magasin = PpMagasin.partage
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Connexion et sécurité")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        PpGroupe {
                            PpInterrupteur(titre: "Face ID", valeur: $magasin.faceIdActif)
                        }
                        .padding(.top, 14)
                        Text(magasin.faceIdActif
                             ? "Face ID est activé : vous vous connectez sans saisir votre mot de passe."
                             : "Face ID est désactivé : votre mot de passe sera demandé à chaque connexion.")
                            .font(.system(size: 14))
                            .foregroundStyle(PpTeinte.gris)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        PpTitreSection(texte: "Dernière connexion")
                        PpGroupe {
                            PpLigneCle(cle: "Appareil", valeur: "iPhone de Sarah")
                            PpLigneCle(cle: "Date", valeur: "17 août 2026, 19:31", dernier: true)
                        }
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// ============================================================ ABONNEMENTS (e181)

struct PpAbonnementsVue: View {
    @ObservedObject private var magasin = PpMagasin.partage
    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: "Abonnements")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(magasin.abonnements) { abonnement in
                            NavigationLink {
                                PpAbonnementDetailVue(abonnement: abonnement)
                            } label: {
                                PpCarte {
                                    HStack(spacing: 14) {
                                        Circle()
                                            .fill(Color(hex: 0x111214))
                                            .frame(width: 44, height: 44)
                                            .overlay {
                                                Image(systemName: "music.note")
                                                    .font(.system(size: 18))
                                                    .foregroundStyle(Color.white)
                                            }
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(abonnement.nom)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(PpTeinte.texte)
                                            Text(abonnement.source)
                                                .font(.system(size: 13))
                                                .foregroundStyle(PpTeinte.gris)
                                        }
                                        Spacer()
                                        Text("Lié")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(PpTeinte.lien)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        Text("Vous ne trouvez pas votre abonnement ? Il n'est pas payé avec PayPal.")
                            .font(.system(size: 13))
                            .foregroundStyle(PpTeinte.gris)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.top, 18)
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PpAbonnementDetailVue: View {
    let abonnement: PpAbonnement
    @ObservedObject private var magasin = PpMagasin.partage

    private var paiements: [PpTx] {
        magasin.transactions.filter { $0.tiers == abonnement.nom }
    }

    var body: some View {
        ZStack {
            PpTeinte.fond.ignoresSafeArea()
            VStack(spacing: 0) {
                PpBarreTitre(titre: abonnement.nom)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        PpGroupe {
                            PpLigneCle(cle: "Montant",
                                       valeur: PpFormat.solde(abonnement.montant) + " " + abonnement.periode)
                            PpLigneCle(cle: "Payé avec", valeur: abonnement.source)
                            PpLigneCle(cle: "Actif depuis", valeur: abonnement.depuis, dernier: true)
                        }
                        .padding(.top, 12)
                        PpTitreSection(texte: "Activité")
                        VStack(spacing: 10) {
                            ForEach(paiements) { tx in
                                NavigationLink {
                                    PpTransactionVue(tx: tx)
                                } label: {
                                    PpCarte { PpLigneTx(tx: tx) }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Spacer(minLength: 40)
                    }
                }
            }
            .padding(.bottom, 22)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
