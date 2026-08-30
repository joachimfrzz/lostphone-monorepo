// Lost Phone — Prototype-duel D49, prétendant SWIFTUI natif
// Verrouillage + Accueil + WhatsApp iOS (conversation « Marc ❤️ », contenu de Coches bleues).
// Différences voulues vs Flutter : matériaux système réels (.ultraThinMaterial),
// police SF native, AUCUNE barre d'état ni barre home dessinées (les vraies font foi).
import SwiftUI

@main
struct LPProtoApp: App {
    var body: some Scene {
        WindowGroup {
            // D63 (pipeline Miroir) : lancée avec ECRAN=<clé>, l'app s'ouvre directement
            // sur l'écran demandé — utilisé par le workflow Codemagic « miroir-captures ».
            if let ecran = ProcessInfo.processInfo.environment["ECRAN"] {
                // Chaque vue porte son propre schéma (Ma Banque est claire) — ne pas forcer ici
                EcranCapture(cle: ecran)
            } else {
                // D81 (30/08) : retour à la v1 interactive comme JEU — les écrans v2
                // (refonte capturée) restent dans le code comme matériau de référence
                // et banc d'essai (mode capture ECRAN=...). Les captures corrigent la
                // v1 détail par détail, elles ne la remplacent plus.
                VerrouillageView().preferredColorScheme(.dark)
            }
        }
    }
}


// ============================================================ MODE CAPTURE (D63 — pipeline Miroir)
// Registre EXHAUSTIF des écrans capturables (v2, 21/08). Clés = lignes de outils/ecrans.txt.
// Un suffixe #n sur la clé passe par la variable ONGLET (lue par les racines à onglets).
// Découpé par famille pour ménager le vérificateur de types.
struct EcranCapture: View {
    let cle: String
    private var famille: String { String(cle.split(separator: ".")[0].split(separator: "#")[0]) }
    var body: some View {
        switch famille {
        case "accueil": ecransAccueil()
        case "banque": ecransBanque()
        case "calculatrice": ecransCalculatrice()
        case "calendrier": ecransCalendrier()
        case "dictaphone": ecransDictaphone()
        case "horloge": ecransHorloge()
        case "localiser": ecransLocaliser()
        case "mail": ecransMail()
        case "messages": ecransMessages()
        case "meteo": ecransMeteo()
        case "notes": ecransNotes()
        case "partage": ecransPartage()
        case "photos": ecransPhotos()
        case "plans": ecransPlans()
        case "rappels": ecransRappels()
        case "reglages": ecransReglages()
        case "safari": ecransSafari()
        case "telephone": ecransTelephone()
        case "whatsapp": ecransWhatsapp()
        case "fichiers": ecransFichiers()
        case "sante": ecransSante()
        case "messenger": ecransMessenger()
        case "instagram": ecransInstagram()
        case "snapchat": ecransSnapchat()
        case "facebook": ecransFacebook()
        case "x": ecransX()
        case "coque2": CoqueV2Capture(cle: cle)
        case "reglages2": ReglagesV2Capture(cle: cle)
        case "divers2": DiversV2Capture(cle: cle)
        case "tcm2": TcmV2Capture(cle: cle)
        case "sm2": SafariMailV2Capture(cle: cle)
        case "pcnr2": PcnrV2Capture(cle: cle)
        case "mhdc2": MhdcV2Capture(cle: cle)
        case "chatgpt": ChatGPTVue()
        case "spotify": SpotifyVue()
        case "youtube": ecransYt()
        case "cartes": ecransCartes()
        default: VerrouillageView()
        }
    }

    @ViewBuilder
    private func ecransSante() -> some View {
        switch cle {
        case "sante.pas": FicheSanteVue(genre: "pas")
        case "sante.sommeil": FicheSommeilVue()
        case "sante.coeur": FicheSanteVue(genre: "coeur")
        case "sante.distance": FicheSanteVue(genre: "distance")
        case "sante.energie": FicheSanteVue(genre: "energie")
        case "sante.fcmarche": FicheSanteVue(genre: "fcmarche")
        case "sante.audition": FicheSanteVue(genre: "audition")
        case "sante.poids": FicheSanteVue(genre: "poids")
        case "sante.activite": CategorieSanteVue(nom: "Activité")
        case "sante.categorie.coeur": CategorieSanteVue(nom: "Cœur")
        case "sante.mesures": CategorieSanteVue(nom: "Mesures corporelles")
        case "sante.vide": CategorieVideSanteVue(nom: "Cycle menstruel")
        case "sante.tendances": TendancesSanteVue()
        case "sante.recherche": RechercheSanteVue()
        case "sante.profil": ProfilSanteVue()
        case "sante.medicale": FicheMedicaleVue()
        case "sante.urgence": ContactUrgenceSanteVue()
        case "sante.historique": HistoriqueSanteVue()
        default: SanteVue()
        }
    }

    @ViewBuilder
    private func ecransMessenger() -> some View {
        switch cle {
        case "messenger.chloe": MsgrConversationVue(conv: DonneesMessenger.conversations[0])
        case "messenger.filles": MsgrConversationVue(conv: DonneesMessenger.conversations[2])
        case "messenger.fiche": MsgrFicheVue(conv: DonneesMessenger.conversations[2])
        case "messenger.membres": MsgrMembresVue()
        case "messenger.medias": MsgrMediasVue(conv: DonneesMessenger.conversations[2])
        case "messenger.appel": MsgrAppelVue(conv: DonneesMessenger.conversations[0])
        case "messenger.parametres": MsgrParametresVue()
        case "messenger.invitations": MsgrInvitationsVue()
        case "messenger.archive": MsgrArchiveVue()
        case "messenger.nouveau": MsgrNouvelleDiscussionVue()
        default: MessengerVue()
        }
    }

    @ViewBuilder
    private func ecransInstagram() -> some View {
        switch cle {
        case "instagram.story": InstaStoryVue(compte: DonneesInsta.comptes[0])
        case "instagram.profilprive": InstaProfilTiersVue(compte: DonneesInsta.comptes[3])
        case "instagram.dm": InstaDMVue()
        case "instagram.activite": InstaActiviteVue()
        case "instagram.dmconv": FilGeneriqueVue(nom: "Chloé Berthier", teinte: 0xE64980, messages: [(false, "Regarde cette publication, ça m'a fait penser à toi 😍"), (true, "Ahah j'adore !! On y va ?"), (false, "Carrément, je regarde les dates")])
        default: InstagramVue()
        }
    }

    @ViewBuilder
    private func ecransSnapchat() -> some View {
        switch cle {
        case "snapchat.conv": SnapConversationVue(ami: DonneesSnap.amis[0])
        case "snapchat.story": VisualiseurContenuVue(titre: "Chloé 💛", sousTitre: "Story · il y a 3 h", emoji: "👩🏻‍🦰", teinte: 0xB84DFF)
        default: SnapchatVue()
        }
    }

    @ViewBuilder
    private func ecransFacebook() -> some View {
        switch cle {
        case "facebook.story": VisualiseurContenuVue(titre: "Chloé Berthier", sousTitre: "Story · il y a 5 h", imageCle: "p12")
        default: FacebookVue()
        }
    }

    @ViewBuilder
    private func ecransX() -> some View {
        switch cle {
        case "x.post": XPostDetailVue(post: DonneesX.posts[0])
        case "x.composer": XComposerVue()
        default: XVue()
        }
    }

    @ViewBuilder
    private func ecransYt() -> some View {
        switch cle {
        case "youtube.video": YtLecteurVue(video: DonneesYt.videos[0])
        case "youtube.notifications": YtNotificationsVue()
        default: YouTubeVue()
        }
    }

    @ViewBuilder
    private func ecransFichiers() -> some View {
        switch cle {
        case "fichiers.apercu": ApercuFichierVue(fichier: DonneesFichiers.tout[3])
        case "fichiers.infos": InfosFichierVue(fichier: DonneesFichiers.tout[7])
        case "fichiers.dossier": DossierFichiersVue(dossier: DonneesFichiers.tout[0])
        default: FichiersVue()
        }
    }

    @ViewBuilder
    private func ecransCartes() -> some View {
        switch cle {
        case "cartes.carte": CarteOuverteVue()
        case "cartes.transaction": TransactionVue(transaction: DonneesCartes.transactions[0])
        case "cartes.billet": BilletOuvertVue()
        case "cartes.ajout": AjoutCarteVue()
        case "cartes.reglages": ReglagesCartesVue()
        default: CartesVueWallet()
        }
    }

    @ViewBuilder
    private func ecransAccueil() -> some View {
        switch cle {
        case "accueil": AccueilView()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransBanque() -> some View {
        switch cle {
        case "banque": MaBanqueVue()
        case "banque.rib": RIBVue()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransCalculatrice() -> some View {
        switch cle {
        case "calculatrice": CalculatriceVue()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransCalendrier() -> some View {
        switch cle {
        case "calendrier": CalendrierVue()
        case "calendrier.annee": NavigationStack { AnneeVue(vueAnnee: .constant(true)) }
        case "calendrier.jour": JourVue(annee: 2026, mois: 8, jour: 17)
        case "calendrier.nouveau": NouvelEvenementVue()
        case "calendrier.recherche": RechercheCalendrierVue()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransDictaphone() -> some View {
        switch cle {
        case "dictaphone": DictaphoneVue()
        case "dictaphone.liste": ListeMemosVue(titre: "Tous les enregistrements", filtre: { _ in true })
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransHorloge() -> some View {
        switch cle {
        case "horloge": HorlogeVue()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransLocaliser() -> some View {
        switch cle {
        case "localiser": LocaliserVue()
        case "localiser.personne": PersonneDetailVue(personne: DonneesLocaliser.personnes[0])
        case "localiser.appareil": AppareilDetailVue(appareil: DonneesLocaliser.appareils[0])
        case "localiser.objet": ObjetDetailVue(objet: DonneesLocaliser.objets[0])
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransMail() -> some View {
        switch cle {
        case "mail": MailVue()
        case "mail.reception": NavigationStack { ListeMailVue(titre: "Réception", boite: "Réception") }
        case "mail.corbeille": NavigationStack { ListeMailVue(titre: "Corbeille", boite: "Corbeille") }
        case "mail.lecture": NavigationStack { LectureMailVue(courriel: MagasinMail.partage.courriels[0]) }
        case "mail.composer": ComposerMailVue()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransMessages() -> some View {
        switch cle {
        case "messages": MessagesVue()
        case "messages.conversation": NavigationStack { MsgConvVue(conv: DonneesMsg.convs[0]) }
        case "messages.marc": NavigationStack { MsgConvVue(conv: DonneesMsg.convs[min(7, DonneesMsg.convs.count - 1)]) }
        case "messages.fiche": NavigationStack { MsgFicheVue(conv: DonneesMsg.convs[0]) }
        case "messages.indesirables": NavigationStack { MsgIndesirablesVue() }
        case "messages.suppressions": NavigationStack { MsgSuppressionsVue() }
        case "messages.filtrage": GererFiltrageVue()
        case "messages.nouveau": NouveauMessageVue()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransMeteo() -> some View {
        switch cle {
        case "meteo": MeteoVue()
        case "meteo.villes": ListeVillesVue(page: .constant(0))
        case "meteo.conditions": ConditionsMeteoVue(ville: DonneesMeteo.villes[0])
        case "meteo.carte": NavigationStack { CarteMeteoVue() }
        case "meteo.signaler": NavigationStack { SignalerMeteoVue() }
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransNotes() -> some View {
        switch cle {
        case "notes": NotesVue()
        case "notes.note": NavigationStack { NoteEditionVue(noteId: MagasinNotes.partage.notes[0].id) }
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransPartage() -> some View {
        switch cle {
        case "partage": FeuillePartage(element: "Capture")
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransPhotos() -> some View {
        switch cle {
        case "photos": PhotosVue()
        case "photos.detail": NavigationStack { PhotoDetailVue(depart: DonneesPhotos.toutes[0]) }
        case "photos.recherche": NavigationStack { RecherchePhotosVue() }
        case "photos.album": NavigationStack { AlbumVue(titre: "Festival", items: Array(DonneesPhotos.toutes.prefix(9))) }
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransPlans() -> some View {
        switch cle {
        case "plans": PlansVue()
        case "plans.fiche": FicheLieuVue(lieu: DonneesPlans.proximite[0], itineraire: {})
        case "plans.itineraire": ItinerairePlanVue(lieu: DonneesPlans.proximite[0], demarrer: {})
        case "plans.navigation": NavigationStack { NavigationGuideeVue(lieu: DonneesPlans.recents[0]) }
        case "plans.noter": NavigationStack { NoterLieuVue(nom: "Boulangerie du Griffon") }
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransRappels() -> some View {
        switch cle {
        case "rappels": RappelsVue()
        case "rappels.tous": NavigationStack { FiltreVue(titre: "Tous", teinte: Color(hex: 0x8E8E93), filtre: { _ in true }) }
        case "rappels.termines": NavigationStack { TerminesVue() }
        case "rappels.detail": DetailRappelVue(rappelId: MagasinRappels.partage.rappels[0].id)
        case "rappels.nouveau": NouveauRappelVue()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransReglages() -> some View {
        switch cle {
        case "reglages": ReglagesVue()
        case "reglages.compte": NavigationStack { CompteAppleVue() }
        case "reglages.infosperso": NavigationStack { InfosPersoVue() }
        case "reglages.securite": NavigationStack { ConnexionSecuVue() }
        case "reglages.paiement": NavigationStack { PaiementVue() }
        case "reglages.abonnements": NavigationStack { AbonnementsVue() }
        case "reglages.icloud": NavigationStack { ICloudVue() }
        case "reglages.maj": NavigationStack { MiseAJourVue() }
        case "reglages.wifi": NavigationStack { WiFiVue() }
        case "reglages.bluetooth": NavigationStack { BluetoothVue() }
        case "reglages.cellulaire": NavigationStack { DonneesCellVue() }
        case "reglages.batterie": NavigationStack { BatterieVue() }
        case "reglages.batterie.utilisation": NavigationStack { UtilisationBatterieVue() }
        case "reglages.batterie.sante": NavigationStack { EtatSanteVue() }
        case "reglages.general": NavigationStack { GeneralVue() }
        case "reglages.infos": NavigationStack { InformationsVue() }
        case "reglages.stockage": NavigationStack { StockageVue() }
        case "reglages.tempsecran": NavigationStack { TempsEcranVue() }
        case "reglages.luminosite": NavigationStack { LuminositeVue() }
        case "reglages.fond": NavigationStack { FondEcranVue() }
        case "reglages.controle": NavigationStack { CentreControleVue() }
        case "reglages.ecranaccueil": NavigationStack { EcranAccueilVue() }
        case "reglages.notifications": NavigationStack { NotificationsVue() }
        case "reglages.sons": NavigationStack { SonsVue() }
        case "reglages.faceid": NavigationStack { FaceIDVue() }
        case "reglages.confidentialite": NavigationStack { ConfidentialiteVue() }
        case "reglages.cartes": NavigationStack { CartesPayVue() }
        case "reglages.recherche": RechercheReglagesVue()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransSafari() -> some View {
        switch cle {
        case "safari": SafariVue()
        case "safari.resultats": CaptureSafari(page: "resultats", url: "google.com")
        case "safari.vessel": CaptureSafari(page: "vessel", url: "vesselfinder.com")
        case "safari.fonfon": CaptureSafari(page: "fonfon", url: "chez-fonfon.com")
        case "safari.erreur": CaptureSafari(page: "erreur", url: "exemple.fr")
        case "safari.site": CaptureSafari(page: "site:Boulangerie du Griffon", url: "boulangeriedugriffon.fr")
        case "safari.onglets": OngletsVue { _ in }
        case "safari.historique": HistoriqueSafariVue()
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransTelephone() -> some View {
        switch cle {
        case "telephone": TelephoneVue()
        case "telephone.fiche": NavigationStack { TelFicheVue(nom: "Chloé") }.coquilleSarah(claire: true)
        case "telephone.appel": NavigationStack { AppelTelVue(destinataire: "Chloé", numero: "06 24 81 05 77") }
        default: VerrouillageView()
        }
    }
    @ViewBuilder
    private func ecransWhatsapp() -> some View {
        switch cle {
        case "whatsapp": WhatsAppListeView()
        case "whatsapp.marc": NavigationStack { ConversationVue(nomContact: "Marc \u{2764}\u{FE0F}") }
        case "whatsapp.chloe": NavigationStack { ConversationVue(nomContact: "Chloé") }
        case "whatsapp.filles": NavigationStack { ConversationVue(nomContact: "Les filles \u{1F483}") }
        case "whatsapp.thomas": NavigationStack { ConversationVue(nomContact: "Thomas") }
        case "whatsapp.maman": NavigationStack { ConversationVue(nomContact: "Maman") }
        case "whatsapp.fiche": NavigationStack { InfosContactVue(nom: "Marc \u{2764}\u{FE0F}", numero: "+33 7 49 12 53 08") }
        case "whatsapp.appel": AppelVue(nom: "Chloé")
        default: VerrouillageView()
        }
    }
}

// Safari pré-chargé sur une page donnée (capture des pages rendues)
struct CaptureSafari: View {
    init(page: String, url: String) {
        Routeur.partage.pageSafari = page
        Routeur.partage.urlSafari = url
    }
    var body: some View { SafariVue() }
}

// ============================================================ BARRE HOME FICTIVE (correctif P1, 20/08)
// Le jeu simule un iPhone moderne sur TOUT appareil (D47) : la barre home est LA NÔTRE.
// Zone de geste au-dessus du bord système -> aucun conflit avec le Centre de contrôle des iPhone à bouton.
// ============================================================
// D85 — Les barres système du jeu sont celles de SARAH, pas celles
// du joueur : la vraie barre d'état et le vrai indicateur home iOS
// sont masqués partout, et le jeu dessine les siens. Heure figée
// 19:47 (cohérente avec le verrouillage et les notifications).
// Ne JAMAIS dessiner ces éléments sans masquer les vrais (doublons).
// ============================================================
struct BarreSarah: View {
    var claire: Bool = false   // true = texte noir (apps à fond clair)
    var body: some View {
        HStack {
            Text("19:47")
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            HStack(spacing: 7) {
                Image(systemName: "cellularbars").font(.system(size: 14))
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100percent").font(.system(size: 16))
            }
        }
        .foregroundStyle(claire ? Color.black : Color.white)
        .padding(.leading, 39).padding(.trailing, 27)
        .padding(.top, 21)
        .allowsHitTesting(false)
    }
}

struct CoquilleSarah: ViewModifier {
    var claire: Bool = false
    func body(content: Content) -> some View {
        content
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
            .defersSystemGestures(on: .bottom)
            .overlay(alignment: .top) {
                BarreSarah(claire: claire)
                    .ignoresSafeArea(edges: .top)
            }
    }
}

extension View {
    // À appliquer sur la racine de CHAQUE app présentée en fullScreenCover.
    func coquilleSarah(claire: Bool = false) -> some View {
        modifier(CoquilleSarah(claire: claire))
    }
}

struct BarreHome: View {
    let action: () -> Void
    var sombre: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(sombre ? Color.black.opacity(0.75) : Color.white.opacity(0.92))
                .frame(width: 140, height: 5)
        }
        .padding(.top, 9)
        .padding(.bottom, 5)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { action() }
        .gesture(DragGesture(minimumDistance: 8).onEnded { v in
            if v.translation.height < -15 { action() }
        })
    }
}

// ============================================================ ROUTEUR INTER-APPS (correctif P3, 20/08)
// « Appeler » dans Ma Banque ouvre le clavier du Téléphone pré-rempli ; « Site web » dans Plans ouvre Safari.
enum CibleRouteur { case telephone, safari, plans, mail, messages }

final class Routeur: ObservableObject {
    static let partage = Routeur()
    @Published var demande: Int = 0
    var cible: CibleRouteur? = nil
    var numeroAppel: String? = nil
    var pageSafari: String? = nil
    var urlSafari: String? = nil

    func allerTelephone(_ numero: String) {
        numeroAppel = numero; cible = .telephone; demande += 1
    }
    func allerSafari(page: String, url: String) {
        pageSafari = page; urlSafari = url; cible = .safari; demande += 1
    }
    func allerPlans() { cible = .plans; demande += 1 }
    func allerMail() { cible = .mail; demande += 1 }
    func allerMessages() { cible = .messages; demande += 1 }
    func consommerNumero() -> String? { let n = numeroAppel; numeroAppel = nil; return n }
    func consommerPage() -> (String, String)? {
        guard let p = pageSafari, let u = urlSafari else { return nil }
        pageSafari = nil; urlSafari = nil
        return (p, u)
    }
}

// ============================================================ FEUILLE DE PARTAGE MAISON (anti-friction, 21/08)
// Remplace les popups « partage impossible » : une vraie feuille de partage, locale.
struct FeuillePartage: View {
    @Environment(\.dismiss) private var dismiss
    var element: String = "1 élément"
    @State private var copie = false
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10).fill(Color(hex: 0x2C2C2E))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "doc.fill").font(.system(size: 17)).foregroundStyle(.secondary))
                VStack(alignment: .leading, spacing: 2) {
                    Text(element).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                    Text("Options ›").font(.system(size: 12.5)).foregroundStyle(.secondary)
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                        .frame(width: 28, height: 28).background(Color(hex: 0x2C2C2E), in: Circle())
                }
            }
            .padding(16)
            Divider().overlay(Color(hex: 0x2C2C2E))

            HStack(spacing: 22) {
                DestinatairePartage(nom: "AirDrop", symbole: "wifi", fond: 0x1C7CF5)
                DestinatairePartage(nom: "Chloé", symbole: "message.fill", fond: 0x32D74B)
                DestinatairePartage(nom: "Mail", symbole: "envelope.fill", fond: 0x0A84FF)
                DestinatairePartage(nom: "WhatsApp", symbole: "phone.fill", fond: 0x25D366)
            }
            .padding(.vertical, 18)
            Divider().overlay(Color(hex: 0x2C2C2E))

            VStack(spacing: 0) {
                HStack {
                    Text(copie ? "Copié" : "Copier").foregroundStyle(copie ? Color.secondary : Color.white)
                    Spacer()
                    Image(systemName: copie ? "checkmark" : "doc.on.doc").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 18).padding(.vertical, 13)
                .contentShape(Rectangle())
                .onTapGesture {
                    copie = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { dismiss() }
                }
                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 18)
                HStack {
                    Text("Enregistrer dans Fichiers").foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "folder").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 18).padding(.vertical, 13)
                .contentShape(Rectangle())
                .onTapGesture { dismiss() }
            }
            Spacer()
        }
        .background(Color(hex: 0x1C1C1E))
        .presentationDetents([.height(320)])
        .preferredColorScheme(.dark)
    }
}

struct DestinatairePartage: View {
    @Environment(\.dismiss) private var dismiss
    let nom: String
    let symbole: String
    let fond: UInt
    var body: some View {
        VStack(spacing: 6) {
            Circle().fill(Color(hex: fond)).frame(width: 54, height: 54)
                .overlay(Image(systemName: symbole).font(.system(size: 21)).foregroundStyle(.white))
            Text(nom).font(.system(size: 11)).foregroundStyle(.white.opacity(0.85))
        }
        .onTapGesture { dismiss() }
    }
}

// ============================================================ VERROUILLAGE
struct VerrouillageView: View {
    @State private var deverrouille = false
    @State private var glisse: CGFloat = 0
    @State private var sortie = false
    @State private var whatsappNotifOuvert = false
    @State private var telephoneNotifOuvert = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // L'accueil vit SOUS le verrouillage : au déverrouillage, le
                // verrouillage glisse vers le haut et révèle l'accueil qui se
                // pose avec un léger zoom (comportement iOS réel).
                AccueilView()
                    .scaleEffect(deverrouille ? 1.0 : 1.12)
                    .opacity(deverrouille ? 1 : 0)
                    .animation(.easeOut(duration: 0.42), value: deverrouille)

                if !sortie {
                    ecranVerrouille
                        .overlay(alignment: .bottom) {
                            // Indicateur home de Sarah (le vrai est masqué — D85)
                            Capsule().fill(Color.white.opacity(0.92))
                                .frame(width: 140, height: 5)
                                .padding(.bottom, 9)
                                .ignoresSafeArea(edges: .bottom)
                                .allowsHitTesting(false)
                        }
                        .statusBarHidden(true)
                        .persistentSystemOverlays(.hidden)
                        .defersSystemGestures(on: .bottom)
                        .offset(y: deverrouille ? -geo.size.height : min(0, -glisse))
                        .animation(deverrouille ? .easeIn(duration: 0.38) : nil, value: deverrouille)
                }
            }
        }
        .fullScreenCover(isPresented: $whatsappNotifOuvert) {
            NavigationStack { ConversationVue(nomContact: "Marc ❤️") }.coquilleSarah()
        }
        .fullScreenCover(isPresented: $telephoneNotifOuvert) {
            NavigationStack { TelFicheVue(nom: "Chloé") }.coquilleSarah(claire: true)
        }
    }

    private func deverrouiller() {
        deverrouille = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { sortie = true }
    }

    private var ecranVerrouille: some View {
        ZStack {
            Color.clear.overlay(
                Image("FondEcran").resizable().scaledToFill()
            ).clipped().ignoresSafeArea()
            LinearGradient(
                stops: [.init(color: .black.opacity(0.38), location: 0),
                        .init(color: .black.opacity(0.05), location: 0.3),
                        .init(color: .black.opacity(0.05), location: 0.65),
                        .init(color: .black.opacity(0.35), location: 1)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                // Barre d'état verrouillée (mesures : Free x39 y24, cadenas x114 13x18)
                HStack {
                    Text("Free").font(.system(size: 15)).foregroundStyle(.white)
                    Spacer()
                    HStack(spacing: 7) {
                        Image(systemName: "cellularbars").font(.system(size: 14))
                        Image(systemName: "wifi").font(.system(size: 14))
                        Image(systemName: "battery.100percent").font(.system(size: 16))
                    }
                    .foregroundStyle(.white)
                }
                .padding(.leading, 39).padding(.trailing, 27).padding(.top, 20)

                Image(systemName: "lock.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .padding(.top, 4)
                // Date : mesuré y=72, h=37 (≈ SF 22 semibold)
                Text("lundi 17 août")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 14)
                // Horloge : cadre mesuré y=89 h=144 — chiffres ≈ 96 pt SF arrondi
                Text("19:47")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .kerning(-2)
                    .padding(.top, -8)

                Spacer()

                NotifCard(couleur: Color(hex: 0x25D366), symbole: "message.fill",
                          app: "WhatsApp · Marc ❤️", quand: "il y a 2 h",
                          corps: "N'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges co…")
                    .contentShape(RoundedRectangle(cornerRadius: 24))
                    .onTapGesture {
                        deverrouiller()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { whatsappNotifOuvert = true }
                    }
                NotifCard(couleur: Color(hex: 0x34C759), symbole: "phone.fill",
                          app: "Téléphone · Chloé", quand: "19:32",
                          corps: "2 appels manqués")
                    .padding(.top, 8)
                    .contentShape(RoundedRectangle(cornerRadius: 24))
                    .onTapGesture {
                        deverrouiller()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { telephoneNotifOuvert = true }
                    }

                // Lampe / Appareil photo : cercles mesurés à y=748 (94 pt de zone), x=28/280
                HStack {
                    RondVerre(symbole: "flashlight.on.fill")
                    Spacer()
                    RondVerre(symbole: "camera.fill")
                }
                .padding(.horizontal, 50)
                .padding(.top, 26)
                .padding(.bottom, 40)

            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { v in glisse = max(0, -v.translation.height) }
                .onEnded { _ in
                    if glisse > 90 {
                        deverrouiller()
                    } else {
                        withAnimation(.spring(duration: 0.35)) { glisse = 0 }
                    }
                }
        )
        .onTapGesture { deverrouiller() }
    }
}


struct NotifCard: View {
    let couleur: Color
    let symbole: String
    let app: String
    let quand: String
    let corps: String
    var body: some View {
        HStack(spacing: 11) {
            RoundedRectangle(cornerRadius: 9)
                .fill(couleur)
                .frame(width: 38, height: 38)
                .overlay(Image(systemName: symbole).foregroundStyle(.white).font(.system(size: 18)))
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(app).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    Spacer()
                    Text(quand).font(.system(size: 13)).foregroundStyle(.white.opacity(0.55))
                }
                Text(corps)
                    .font(.system(size: 14.5))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 15).padding(.vertical, 13)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 12)
    }
}

struct RondVerre: View {
    let symbole: String
    var body: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .frame(width: 52, height: 52)
            .overlay(Image(systemName: symbole).foregroundStyle(.white).font(.system(size: 20)))
    }
}

// ============================================================ ACCUEIL (mesures S1 : grille x=28/120/213/306, pas 100 ; widgets 169×192 y=88 ; Recherche 100×31 y=703 ; dock y=753 h=104)
struct AccueilView: View {
    @State private var whatsappOuvert = false
    @State private var telephoneOuvert = false
    @State private var messagesOuvert = false
    @State private var reglagesOuvert = false
    @State private var photosOuvert = false
    @State private var horlogeOuverte = false
    @State private var calculatriceOuverte = false
    @State private var meteoOuverte = false
    @State private var notesOuvertes = false
    @State private var rappelsOuverts = false
    @State private var dictaphoneOuvert = false
    @State private var banqueOuverte = false
    @State private var calendrierOuvert = false
    @State private var localiserOuvert = false
    @State private var mailOuvert = false
    @State private var plansOuverts = false
    @State private var safariOuvert = false
    @State private var fichiersOuverts = false
    @State private var cartesOuvertes = false
    @State private var santeOuverte = false
    @State private var messengerOuvert = false
    @State private var instagramOuvert = false
    @State private var snapchatOuvert = false
    @State private var facebookOuvert = false
    @State private var xOuvert = false
    @State private var chatgptOuvert = false
    @State private var spotifyOuvert = false
    @State private var youtubeOuvert = false
    @State private var page = 0
    @ObservedObject private var routeur = Routeur.partage

    // Page 1 : les apps « système » (ordre inspiré du réel) — Page 2 : le reste
    private let page1: [(String, Color, String, Color)] = [
        ("Horloge", Color(hex: 0x1C1C1E), "clock", .white),
        ("Calendrier", .white, "calendar", Color(hex: 0xFF3B30)),
        ("Photos", .white, "photo.on.rectangle.angled", Color(hex: 0xE64980)),
        ("Plans", Color(hex: 0x34C3FF), "location.north.circle.fill", .white),
        ("Météo", Color(hex: 0x54C7FC), "sun.max.fill", Color(hex: 0xFFD60A)),
        ("Notes", Color(hex: 0xFFCC00), "note.text", .white),
        ("Rappels", .white, "checklist", Color(hex: 0x0A84FF)),
        ("Calculatrice", Color(hex: 0x2C2C2E), "plus.slash.minus", Color(hex: 0xFF9F0A)),
        ("Réglages", Color(hex: 0x8E8E93), "gearshape.fill", .white),
        ("Localiser", Color(hex: 0x32D74B), "dot.radiowaves.left.and.right", .white),
        ("Santé", .white, "heart.fill", Color(hex: 0xFA5252)),
        ("Ma Banque", Color(hex: 0x123E6B), "building.columns.fill", .white),
        ("Cartes", .black, "wallet.pass.fill", .white),
        ("App Store", Color(hex: 0x0A84FF), "square.stack.3d.up.fill", .white),
        ("Fichiers", .white, "folder.fill", Color(hex: 0x0A84FF)),
        ("Dictaphone", Color(hex: 0x1C1C1E), "waveform", Color(hex: 0xFF3B30)),
    ]
    private let page2: [(String, Color, String, Color)] = [
        ("Mail", Color(hex: 0x0A84FF), "envelope.fill", .white),
        ("Musique", .white, "music.note", Color(hex: 0xFA2D48)),
        ("Messenger", Color(hex: 0x0084FF), "bolt.horizontal.circle.fill", .white),
        ("Instagram", Color(hex: 0xE1306C), "camera.circle", .white),
        ("Snapchat", Color(hex: 0xFFFC00), "bubble.left.fill", .black),
        ("Facebook", Color(hex: 0x0866FF), "f.circle.fill", .white),
        ("X", .black, "xmark", .white),
        ("ChatGPT", .white, "circle.hexagongrid.fill", .black),
        ("Spotify", .black, "circle.circle.fill", Color(hex: 0x1ED760)),
        ("YouTube", .white, "play.rectangle.fill", Color(hex: 0xFF0000)),
    ]

    private func fermerToutesLesApps() {
        whatsappOuvert = false; telephoneOuvert = false; messagesOuvert = false
        reglagesOuvert = false; photosOuvert = false; horlogeOuverte = false
        calculatriceOuverte = false; meteoOuverte = false; notesOuvertes = false
        rappelsOuverts = false; dictaphoneOuvert = false; banqueOuverte = false
        calendrierOuvert = false; localiserOuvert = false; mailOuvert = false
        plansOuverts = false; safariOuvert = false
        fichiersOuverts = false; cartesOuvertes = false; santeOuverte = false; messengerOuvert = false
        instagramOuvert = false; snapchatOuvert = false
        facebookOuvert = false; xOuvert = false; chatgptOuvert = false
        spotifyOuvert = false; youtubeOuvert = false
    }

    private func actionPour(_ nom: String) -> (() -> Void)? {
        switch nom {
        case "Réglages": return { reglagesOuvert = true }
        case "Photos": return { photosOuvert = true }
        case "Horloge": return { horlogeOuverte = true }
        case "Calculatrice": return { calculatriceOuverte = true }
        case "Météo": return { meteoOuverte = true }
        case "Notes": return { notesOuvertes = true }
        case "Rappels": return { rappelsOuverts = true }
        case "Dictaphone": return { dictaphoneOuvert = true }
        case "Ma Banque": return { banqueOuverte = true }
        case "Calendrier": return { calendrierOuvert = true }
        case "Localiser": return { localiserOuvert = true }
        case "Plans": return { plansOuverts = true }
        case "Fichiers": return { fichiersOuverts = true }
        case "Cartes": return { cartesOuvertes = true }
        case "Santé": return { santeOuverte = true }
        case "Messenger": return { messengerOuvert = true }
        case "Instagram": return { instagramOuvert = true }
        case "Snapchat": return { snapchatOuvert = true }
        case "Facebook": return { facebookOuvert = true }
        case "X": return { xOuvert = true }
        case "ChatGPT": return { chatgptOuvert = true }
        case "Spotify": return { spotifyOuvert = true }
        case "YouTube": return { youtubeOuvert = true }
        case "Mail": return { mailOuvert = true }
        case "WhatsApp": return { whatsappOuvert = true }
        case "Téléphone": return { telephoneOuvert = true }
        case "Messages": return { messagesOuvert = true }
        case "Safari": return { safariOuvert = true }
        default: return nil
        }
    }

    // Ouverture d'app : slide up natif du fullScreenCover, rien d'autre (retour Joachim 30/08)
    private func lancer(_ nom: String, depuis cadre: CGRect) {
        actionPour(nom)?()
    }

    private func grille(_ apps: [(String, Color, String, Color)]) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(62), spacing: 31), count: 4),
                  spacing: 20) {
            ForEach(apps, id: \.0) { a in
                AppIcone(nom: a.0, fond: a.1, symbole: a.2, teinte: a.3,
                         badge: a.0 == "WhatsApp" ? "3" : nil,
                         ouvrir: { cadre in lancer(a.0, depuis: cadre) },
                         inerte: actionPour(a.0) == nil)
            }
        }
        .padding(.horizontal, 24)
    }

    var body: some View {
        GeometryReader { geo in
        ZStack {
            Color.clear.overlay(
                Image("FondEcran").resizable().scaledToFill()
            ).clipped().ignoresSafeArea()
            Color.black.opacity(0.30).ignoresSafeArea()

            VStack(spacing: 0) {
                // Pas de fausse barre d'état : la vraie barre système iOS fait foi (D82)
                TabView(selection: $page) {
                    // -------- PAGE 1 : widgets + 16 apps --------
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            // Widget Météo (169×192 mesuré)
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 3) {
                                    Image(systemName: "location.fill").font(.system(size: 9))
                                    Text("Lyon").font(.system(size: 14, weight: .semibold))
                                }
                                Text("24°").font(.system(size: 38, weight: .light)).padding(.top, 2)
                                Spacer()
                                Image(systemName: "sun.max.fill").font(.system(size: 16))
                                    .foregroundStyle(.yellow)
                                Text("Ensoleillé").font(.system(size: 13, weight: .medium)).padding(.top, 2)
                                Text("Max. 29° Min. 18°").font(.system(size: 13)).opacity(0.85)
                            }
                            .foregroundStyle(.white)
                            .padding(15)
                            .frame(width: 169, height: 192, alignment: .topLeading)
                            .background(
                                LinearGradient(colors: [Color(hex: 0x3F7FD9), Color(hex: 0x2A5CA8)],
                                               startPoint: .top, endPoint: .bottom),
                                in: RoundedRectangle(cornerRadius: 24))
                            .onTapGesture { meteoOuverte = true }

                            // Widget Calendrier (169×192 mesuré)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("LUNDI").font(.system(size: 13, weight: .semibold)).foregroundStyle(.red)
                                Text("17").font(.system(size: 34, weight: .regular)).foregroundStyle(.black)
                                Spacer()
                                RoundedRectangle(cornerRadius: 3).fill(Color(hex: 0x0A84FF)).frame(width: 4, height: 30)
                                    .overlay(alignment: .leading) {
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("Agence Bellecour").font(.system(size: 12, weight: .semibold)).foregroundStyle(.black)
                                            Text("11:30 – 12:30").font(.system(size: 11)).foregroundStyle(.gray)
                                        }
                                        .padding(.leading, 10)
                                        .frame(width: 140, alignment: .leading)
                                    }
                                    .padding(.bottom, 4)
                            }
                            .padding(15)
                            .frame(width: 169, height: 192, alignment: .topLeading)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                            .onTapGesture { calendrierOuvert = true }
                        }
                        .padding(.top, 18)

                        grille(page1)
                            .padding(.top, 24)
                        Spacer(minLength: 0)
                    }
                    .tag(0)

                    // -------- PAGE 2 : le reste --------
                    VStack(spacing: 0) {
                        grille(page2)
                            .padding(.top, 30)
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(62), spacing: 31), count: 4), spacing: 20) {
                            AppIcone(nom: "WhatsApp", fond: Color(hex: 0x25D366),
                                     symbole: "message.fill", teinte: .white, badge: "3",
                                     ouvrir: { cadre in lancer("WhatsApp", depuis: cadre) })
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        Spacer(minLength: 0)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Points de page + pilule Recherche (100×31 mesuré)
                HStack(spacing: 8) {
                    Circle().fill(page == 0 ? .white : .white.opacity(0.4)).frame(width: 7, height: 7)
                    Circle().fill(page == 1 ? .white : .white.opacity(0.4)).frame(width: 7, height: 7)
                }
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").font(.system(size: 12)).foregroundStyle(.white.opacity(0.85))
                    Text("Recherche").font(.system(size: 13)).foregroundStyle(.white.opacity(0.9))
                }
                .frame(width: 100, height: 31)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 10)

                // Dock (mesuré : pleine largeur h=104, icônes à x=34/122/211/299)
                HStack {
                    Spacer()
                    AppIcone(nom: "", fond: Color(hex: 0x2FC74F), symbole: "phone.fill", teinte: .white, badge: "2",
                             ouvrir: { cadre in lancer("Téléphone", depuis: cadre) })
                    Spacer()
                    AppIcone(nom: "", fond: Color(hex: 0x2FC74F), symbole: "message.fill", teinte: .white, badge: "3",
                             ouvrir: { cadre in lancer("Messages", depuis: cadre) })
                    Spacer()
                    AppIcone(nom: "", fond: Color(hex: 0xF2F2F7), symbole: "safari.fill", teinte: Color(hex: 0x0A84FF),
                             ouvrir: { cadre in lancer("Safari", depuis: cadre) })
                    Spacer()
                    AppIcone(nom: "", fond: Color(hex: 0x0A84FF), symbole: "envelope.fill", teinte: .white,
                             ouvrir: { cadre in lancer("Mail", depuis: cadre) })
                    Spacer()
                }
                .padding(.vertical, 17)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 38))
                .padding(.horizontal, 10).padding(.top, 12).padding(.bottom, 4)
            }
            // Indicateur home de Sarah (le vrai est masqué — D85)
            VStack {
                Spacer()
                Capsule().fill(Color.white.opacity(0.92))
                    .frame(width: 140, height: 5)
                    .padding(.bottom, 9)
            }
            .ignoresSafeArea(edges: .bottom)

            // Barre d'état de Sarah (la vraie est masquée — D85)
            VStack {
                BarreSarah(claire: false)
                Spacer()
            }
            .ignoresSafeArea(edges: .top)
        }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .defersSystemGestures(on: .bottom)
        .fullScreenCover(isPresented: $whatsappOuvert) { WhatsAppListeView().coquilleSarah() }
        .fullScreenCover(isPresented: $telephoneOuvert) { TelephoneVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $messagesOuvert) { MessagesVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $reglagesOuvert) { ReglagesVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $photosOuvert) { PhotosVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $horlogeOuverte) { HorlogeVue().coquilleSarah() }
        .fullScreenCover(isPresented: $calculatriceOuverte) { CalculatriceVue().coquilleSarah() }
        .fullScreenCover(isPresented: $meteoOuverte) { MeteoVue().coquilleSarah() }
        .fullScreenCover(isPresented: $notesOuvertes) { NotesVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $rappelsOuverts) { RappelsVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $dictaphoneOuvert) { DictaphoneVue().coquilleSarah() }
        .fullScreenCover(isPresented: $banqueOuverte) { MaBanqueVue().coquilleSarah() }
        .fullScreenCover(isPresented: $calendrierOuvert) { CalendrierVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $localiserOuvert) { LocaliserVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $mailOuvert) { MailVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $plansOuverts) { PlansVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $safariOuvert) { SafariVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $fichiersOuverts) { FichiersVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $cartesOuvertes) { CartesVueWallet().coquilleSarah() }
        .fullScreenCover(isPresented: $santeOuverte) { SanteVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $messengerOuvert) { MessengerVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $instagramOuvert) { InstagramVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $snapchatOuvert) { SnapchatVue().coquilleSarah() }
        .fullScreenCover(isPresented: $facebookOuvert) { FacebookVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $xOuvert) { XVue().coquilleSarah() }
        .fullScreenCover(isPresented: $chatgptOuvert) { ChatGPTVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $spotifyOuvert) { SpotifyVue().coquilleSarah() }
        .fullScreenCover(isPresented: $youtubeOuvert) { YouTubeVue().coquilleSarah(claire: true) }
        .onChange(of: routeur.demande) { _, _ in
            // Navigation inter-apps : fermer l'app courante puis ouvrir la cible (P3)
            fermerToutesLesApps()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                switch routeur.cible {
                case .telephone: telephoneOuvert = true
                case .safari: safariOuvert = true
                case .plans: plansOuverts = true
                case .mail: mailOuvert = true
                case .messages: messagesOuvert = true
                case nil: break
                }
                routeur.cible = nil
            }
        }
    }
}

struct AppIcone: View {
    let nom: String
    let fond: Color
    let symbole: String
    let teinte: Color
    var badge: String? = nil
    var ouvrir: ((CGRect) -> Void)? = nil
    var inerte: Bool = false
    @State private var alerteVisible = false
    @State private var cadre: CGRect = .zero

    // Vraies icônes (pack5 : officielles simulateur + Wikimedia, carrés pleins
    // SANS alpha — l'unique rognage est fait ici en squircle continu).
    // Repli SF pour : Calculatrice, Dictaphone, Ma Banque (fictive), Musique dock.
    static let assets: [String: String] = [
        "Horloge": "horloge", "Calendrier": "calendrier", "Photos": "photos",
        "Plans": "plans", "Notes": "notes", "Rappels": "rappels",
        "Réglages": "reglages", "Santé": "sante", "Cartes": "cartes",
        "App Store": "app-store", "Fichiers": "fichiers", "ChatGPT": "chatgpt",
        "Mail": "mail", "Musique": "musique", "Messenger": "messenger",
        "Instagram": "instagram", "Facebook": "facebook", "X": "x",
        "TV": "tv", "Podcasts": "podcasts", "Contacts": "contacts",
        "FaceTime": "facetime", "Téléphone": "telephone", "Messages": "messages",
        "Safari": "safari", "Météo": "meteo", "Localiser": "localiser",
        "WhatsApp": "whatsapp", "Snapchat": "snapchat", "Spotify": "spotify",
        "YouTube": "youtube", "Telegram": "telegram",
    ]
    static func cleAsset(_ nom: String) -> String { assets[nom] ?? "" }

    private var vraieIcone: UIImage? {
        guard let cle = AppIcone.assets[nomAffiche] else { return nil }
        return chargerPellicule("ic-" + cle)
    }

    var body: some View {
        VStack(spacing: 6) {
            Group {
                if let ui = vraieIcone {
                    Image(uiImage: ui).resizable().scaledToFill()
                        .frame(width: 62, height: 62)
                        .clipShape(RoundedRectangle(cornerRadius: 14.5, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 14.5, style: .continuous)
                        .fill(fond)
                        .frame(width: 62, height: 62)
                        .overlay(Image(systemName: symbole).font(.system(size: 27)).foregroundStyle(teinte))
                }
            }
            .overlay(alignment: .topTrailing) {
                if let badge {
                    Text(badge)
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 7).frame(minWidth: 23, minHeight: 23)
                        .background(Color(hex: 0xFF3B30), in: Capsule())
                        .offset(x: 8, y: -8)
                }
            }
            .shadow(color: .black.opacity(0.35), radius: 10, y: 3)
            if !nom.isEmpty {
                Text(nom).font(.system(size: 11.5, weight: .medium)).foregroundStyle(.white)
                    .lineLimit(1).fixedSize()
            }
        }
        .background(
            GeometryReader { g in
                Color.clear.onAppear { cadre = g.frame(in: .global) }
                    .onChange(of: g.frame(in: .global)) { _, nv in cadre = nv }
            }
        )
        .onTapGesture {
            if inerte || ouvrir == nil { alerteVisible = true } else { ouvrir?(cadre) }
        }
        // D56 anneau 3 : cause système unique et cohérente pour toutes les apps pas encore construites
        .alert(nomAffiche, isPresented: $alerteVisible) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(nom == "App Store" ? ErreurLambda.reponse("appstore") : ErreurLambda.reponse("app.attente"))
        }
    }

    private var nomAffiche: String {
        if !nom.isEmpty { return nom }
        switch symbole {
        case "envelope.fill": return "Mail"
        case "safari.fill": return "Safari"
        case "phone.fill": return "Téléphone"
        case "message.fill": return "Messages"
        default: return "App"
        }
    }
}


// ============================================================ WHATSAPP (iOS 26, mesuré sur captures réelles du 16/08)
// Couleurs échantillonnées pixel par pixel dans references/whatsapp/ :
let waNoir = Color(hex: 0x0A0A0A)        // fond liste
let waChamp = Color(hex: 0x222222)       // barre de recherche
let waChipInactif = Color(hex: 0x161717)
let waChipActifFond = Color(hex: 0xE0FCD6)
let waChipActifTexte = Color(hex: 0x1A3429)
let waVertDoux = Color(hex: 0x5BBD6C)    // heures non-lues, badges
let waVertVif = Color(hex: 0x25D366)     // bouton +
let waBulleEnvoi = Color(hex: 0x144D37)
let waBulleRecu = Color(hex: 0x242626)
let waTabBar = Color(hex: 0x1D1D1D)
let waSaisie = Color(hex: 0x282828)
let waCarte = Color(hex: 0x1D1E1E)       // pilules de date, cartes d'appel
let waTexte = Color(hex: 0xF2F2F2)
let waTexte2 = Color(hex: 0x8E8E93)
let cocheBleue = Color(hex: 0x53BDEB)

struct WhatsAppListeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 3
    @State private var filtre = 0          // 0 Toutes, 1 Non lues, 2 Favoris, 3 Groupes
    @State private var recherche = ""
    @State private var menuPlus = false
    @State private var menuCamera = false
    @State private var menuPoints = false
    @ObservedObject private var envois = EnvoisJoueur.partage

    private let convs: [(String, String, String, String?, Bool)] = [
        ("Marc ❤️", "17:41", "N'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges co…", "1", true),
        ("Chloé", "19:33", "📞 Appel vocal manqué", "2", true),
        ("Les filles 💃", "19:40", "Chloé : Julie appelle-moi stp", nil, false),
        ("Thomas", "samedi", "🤙 Trop fort ce sticker 😂", nil, false),
        ("Maman", "dimanche", "tu viens dimanche ??? bisous maman", nil, false),
        ("Marie kiné", "vendredi", "✓✓ ok pour l'échange de créneaux jeudi 👍", nil, false),
    ]

    // L'aperçu de la liste reflète le dernier message envoyé par le joueur (persistant)
    private var convsVivantes: [(String, String, String, String?, Bool)] {
        convs.map { c in
            if let dernier = envois.parContact[c.0]?.last {
                if case .msgJoueur(let t, let h) = dernier { return (c.0, h, "Vous : " + t, nil, c.4) }
                if case .msg(_, let t, let h) = dernier { return (c.0, h, "Vous : " + t, nil, c.4) }
            }
            return c
        }
    }

    // D51-1 : les filtres et la recherche fonctionnent réellement
    private var convsFiltrees: [(String, String, String, String?, Bool)] {
        var r = convsVivantes
        if filtre == 1 { r = r.filter { $0.4 } }
        if filtre == 2 { r = r.filter { $0.0 == "Marc ❤️" || $0.0 == "Chloé" } }
        if filtre == 3 { r = r.filter { $0.0 == "Les filles 💃" } }
        if !recherche.isEmpty {
            r = r.filter { $0.0.localizedCaseInsensitiveContains(recherche) || $0.2.localizedCaseInsensitiveContains(recherche) }
        }
        return r
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                waNoir.ignoresSafeArea()
                Group {
                    switch onglet {
                    case 0: ActusVue()
                    case 1: AppelsVue()
                    case 2: CommunautesVue()
                    case 4: VousVue()
                    default: discussions
                    }
                }

                HStack(spacing: 10) {
                    HStack(spacing: 0) {
                        OngletFlottant(symbole: "circle.dashed", nom: "Actus", actif: onglet == 0, pointVert: true) { onglet = 0 }
                        OngletFlottant(symbole: "phone", nom: "Appels", actif: onglet == 1) { onglet = 1 }
                        OngletFlottant(symbole: "person.3", nom: "Communautés", actif: onglet == 2) { onglet = 2 }
                        OngletFlottant(symbole: "bubble.left.and.bubble.right.fill", nom: "Discussions", actif: onglet == 3, badge: "3") { onglet = 3 }
                    }
                    .padding(.vertical, 8).padding(.horizontal, 6)
                    .background(waTabBar, in: Capsule())
                    Button { onglet = 4 } label: {
                        VStack(spacing: 3) {
                            ZStack {
                                Circle().fill(Color(hex: 0x143D2B)).frame(width: 34, height: 34)
                                Image(systemName: "person.crop.circle.fill").font(.system(size: 20)).foregroundStyle(waVertDoux)
                            }
                            Text("Vous").font(.system(size: 10)).foregroundStyle(onglet == 4 ? waTexte : waTexte2)
                        }
                        .padding(.vertical, 6).padding(.horizontal, 10)
                        .background(waTabBar, in: Capsule())
                    }
                }
                .padding(.horizontal, 14).padding(.bottom, 6)

            BarreHome { dismiss() }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var discussions: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                RondAction(symbole: "ellipsis") { menuPoints = true }
                Spacer()
                RondAction(symbole: "camera.fill") { menuCamera = true }
                RondAction(symbole: "plus", fond: waVertVif, teinte: Color(hex: 0x062E1C), gras: true) { menuPlus = true }
            }
            .padding(.horizontal, 16).padding(.top, 8)
            // D51-1 : menus natifs plausibles sur chaque bouton
            .confirmationDialog("", isPresented: $menuPlus, titleVisibility: .hidden) {
                Button("Nouvelle discussion") {}
                Button("Nouveau groupe") {}
                Button("Nouvelle communauté") {}
                Button("Annuler", role: .cancel) {}
            }
            .confirmationDialog("", isPresented: $menuPoints, titleVisibility: .hidden) {
                Button("Sélectionner des discussions") {}
                Button("Tout marquer comme lu") {}
                Button("Réglages") {}
                Button("Annuler", role: .cancel) {}
            }
            .confirmationDialog("Appareil photo", isPresented: $menuCamera, titleVisibility: .visible) {
                Button("Prendre une photo") {}
                Button("Photothèque") {}
                Button("Annuler", role: .cancel) {}
            }
            HStack {
                Text("Discussions").font(.system(size: 34, weight: .bold)).foregroundStyle(waTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 12)

            // D51-1 : vraie recherche (clavier réel), placeholder adaptatif comme le vrai
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(waTexte2).font(.system(size: 17))
                TextField("", text: $recherche,
                          prompt: Text(filtre == 1 ? "Rechercher dans Non lues" : "Demander à Meta AI ou...")
                            .foregroundStyle(waTexte2))
                    .font(.system(size: 17)).foregroundStyle(waTexte)
            }
            .padding(.horizontal, 16).frame(height: 44)
            .background(waChamp, in: Capsule())
            .padding(.horizontal, 16).padding(.top, 14)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    PuceActive(texte: "Toutes", active: filtre == 0) { filtre = 0 }
                    PuceActive(texte: "Non lues 2", active: filtre == 1) { filtre = 1 }
                    PuceActive(texte: "Favoris", active: filtre == 2) { filtre = 2 }
                    PuceActive(texte: "Groupes 1", active: filtre == 3) { filtre = 3 }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 12)

            NavigationLink(destination: ArchiveesVue()) {
                HStack(spacing: 26) {
                    Image(systemName: "archivebox").font(.system(size: 17)).foregroundStyle(waTexte2)
                    Text("Archivées").font(.system(size: 16, weight: .semibold)).foregroundStyle(waTexte)
                    Spacer()
                }
                .padding(.horizontal, 26).padding(.vertical, 14)
            }

            if convsFiltrees.isEmpty {
                Spacer()
                Text(filtre == 3 ? "Aucun groupe" : "Aucun résultat")
                    .font(.system(size: 15)).foregroundStyle(waTexte2)
                Spacer()
            } else {
                List {
                    ForEach(convsFiltrees, id: \.0) { c in
                        NavigationLink(destination: ConversationVue(nomContact: c.0)) { LigneConv(c: c) }
                        .listRowBackground(waNoir)
                        .listRowSeparatorTint(Color(hex: 0x222222))
                        // D51-1 : balayages natifs (réponse plausible, logique moteur plus tard)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button { } label: { Label("Archiver", systemImage: "archivebox.fill") }.tint(Color(hex: 0x25303A))
                            Button { } label: { Label("Plus", systemImage: "ellipsis") }.tint(Color(hex: 0x3A3A3C))
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button { } label: { Label("Non lu", systemImage: "message.badge.filled.fill") }.tint(Color(hex: 0x1D6F4C))
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 70)
            }
        }
    }
}

struct PuceActive: View {
    let texte: String
    let active: Bool
    let action: () -> Void
    var body: some View {
        Text(texte)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(active ? waChipActifTexte : waTexte2)
            .padding(.horizontal, 15).padding(.vertical, 8)
            .background(active ? waChipActifFond : waChipInactif, in: Capsule())
            .contentShape(Capsule())
            .onTapGesture(perform: action)
    }
}

struct PlaceholderOnglet: View {
    let titre: String
    let message: String
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RondAction(symbole: "ellipsis")
                Spacer()
                RondAction(symbole: "plus", fond: waVertVif, teinte: Color(hex: 0x062E1C), gras: true)
            }
            .padding(.horizontal, 16).padding(.top, 8)
            HStack {
                Text(titre).font(.system(size: 34, weight: .bold)).foregroundStyle(waTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 12)
            Spacer()
            Text(message).font(.system(size: 15)).foregroundStyle(waTexte2)
            Spacer()
        }
    }
}

struct RondAction: View {
    let symbole: String
    var fond: Color = Color(hex: 0x1C1C1E)
    var teinte: Color = waTexte
    var gras: Bool = false
    var action: (() -> Void)? = nil
    @State private var alerteVisible = false
    var body: some View {
        Circle().fill(fond).frame(width: 40, height: 40)
            .overlay(Image(systemName: symbole)
                .font(.system(size: 17, weight: gras ? .bold : .semibold))
                .foregroundStyle(teinte))
            .onTapGesture {
                // D51-1 : aucun bouton mort — action réelle ou réponse banale variée
                if let action { action() } else { alerteVisible = true }
            }
            .alert(ErreurLambda.reponse(cleBanale), isPresented: $alerteVisible) {
                Button("OK", role: .cancel) {}
            }
    }

    // D56 : réponse déterministe propre à chaque bouton
    private var cleBanale: String {
        switch symbole {
        case "camera.fill": return "camera"
        case "ellipsis": return "menu.indisponible"
        case "plus": return "creation.indisponible"
        default: return "generique"
        }
    }
}

struct Puce: View {
    let texte: String
    let active: Bool
    var body: some View {
        Text(texte)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(active ? waChipActifTexte : waTexte2)
            .padding(.horizontal, 15).padding(.vertical, 8)
            .background(active ? waChipActifFond : waChipInactif, in: Capsule())
    }
}

struct OngletFlottant: View {
    let symbole: String
    let nom: String
    var actif: Bool = false
    var badge: String? = nil
    var pointVert: Bool = false
    var action: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbole)
                .font(.system(size: 20))
                .foregroundStyle(actif ? waTexte : waTexte2)
                .overlay(alignment: .topTrailing) {
                    if let badge {
                        Text(badge).font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: 0x062E1C))
                            .padding(.horizontal, 5).frame(minWidth: 17, minHeight: 17)
                            .background(waVertDoux, in: Capsule())
                            .offset(x: 12, y: -7)
                    } else if pointVert {
                        Circle().fill(waVertDoux).frame(width: 7, height: 7).offset(x: 4, y: -2)
                    }
                }
            Text(nom).font(.system(size: 10, weight: actif ? .semibold : .regular))
                .foregroundStyle(actif ? waTexte : waTexte2)
        }
        .padding(.horizontal, 10).padding(.vertical, 4)
        .background(actif ? Color(hex: 0x303030) : .clear, in: Capsule())
        .contentShape(Rectangle())
        .onTapGesture { action?() }
    }
}

struct LigneConv: View {
    let c: (String, String, String, String?, Bool)
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarSilhouette(taille: 56, image: c.0 == "Marc ❤️" ? "AvatarMarc" : nil)
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(c.0).font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                    Spacer()
                    Text(c.1).font(.system(size: 15)).foregroundStyle(c.4 ? waVertDoux : waTexte2)
                }
                HStack(alignment: .top) {
                    Text(c.2).font(.system(size: 15)).foregroundStyle(waTexte2)
                        .lineLimit(2).multilineTextAlignment(.leading)
                    Spacer()
                    if let p = c.3 {
                        Text(p).font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: 0x062E1C))
                            .padding(.horizontal, 6).frame(minWidth: 21, minHeight: 21)
                            .background(waVertDoux, in: Capsule())
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding(.vertical, 5)
    }
}

struct Bulle: View {
    let recu: Bool
    let texte: String
    let heure: String
    var distribue: Bool = true // D54 : faux = un seul ✓ gris (message du joueur, jamais distribué)
    var body: some View {
        HStack {
            if !recu { Spacer(minLength: 60) }
            VStack(alignment: .trailing, spacing: 0) {
                Text(texte).font(.system(size: 17)).foregroundStyle(waTexte)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 3) {
                    Text(heure).font(.system(size: 11.5)).foregroundStyle(waTexte.opacity(0.55))
                    if !recu {
                        if distribue {
                            Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue)
                            Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(cocheBleue).padding(.leading, -7)
                        } else {
                            Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(waTexte2)
                        }
                    }
                }
                .padding(.top, 3)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(.rect(topLeadingRadius: 18, bottomLeadingRadius: recu ? 5 : 18,
                             bottomTrailingRadius: recu ? 18 : 5, topTrailingRadius: 18))
            if recu { Spacer(minLength: 60) }
        }
    }
}

// ————— Motif de fond de discussion (approximation du doodle WhatsApp) —————
struct MotifDiscussion: View {
    private static let symboles = ["heart", "star", "cup.and.saucer", "leaf", "music.note",
                                   "moon", "paperplane", "camera", "gift", "sun.min",
                                   "cloud", "bicycle", "book", "airplane", "pawprint"]
    var body: some View {
        GeometryReader { geo in
            let cols = 6
            let lignes = 14
            ForEach(0..<(cols * lignes), id: \.self) { i in
                let c = i % cols
                let l = i / cols
                Image(systemName: Self.symboles[(i * 7) % Self.symboles.count])
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.035))
                    .rotationEffect(.degrees(Double((i * 37) % 60) - 30))
                    .position(
                        x: (CGFloat(c) + (l % 2 == 0 ? 0.5 : 1.0)) * geo.size.width / CGFloat(cols),
                        y: (CGFloat(l) + 0.5) * geo.size.height / CGFloat(lignes)
                    )
            }
        }
        .allowsHitTesting(false)
        .clipped()
    }
}

// ————— Utilitaire couleur hexadécimale —————
extension Color {
    init(hex: UInt) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
