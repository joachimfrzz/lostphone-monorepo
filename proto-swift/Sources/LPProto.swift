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
        case "musique": ecransMusique()
        case "paypal": ecransPaypal()
        case "appstore": ecransAppstore()
        case "uber": ecransUber()
        case "sncf": ecransSncf()
        case "facetime": ecransFacetime()
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

    // Messenger v3.1 (03/09 soir, D92 — retours 279) : le registre suit la simplification
    // de MessengerApp.swift. Écrans retirés : Communautés, « menuplus » (doublon de
    // messenger#3). Écrans ajoutés : les listes complètes Invitations / Suggestions.
    // Les données viennent du store partagé via des accesseurs NON optionnels
    // (MessengerStore.convCapture/noteCapture/storyCapture/messageCapture) : aucun
    // état externe, aucun binding, aucune force-unwrap.
    // Les clés « messenger#0..3 » passent par ONGLET et retombent sur la racine.
    @ViewBuilder
    private func ecransMessenger() -> some View {
        switch cle {
        case "messenger.chloe":
            MsgrConversationVue(conv: MessengerStore.convCapture("chloe"))
        case "messenger.filles":
            MsgrConversationVue(conv: MessengerStore.convCapture("filles"))
        case "messenger.fiche":
            MsgrFicheVue(conv: MessengerStore.convCapture("filles"))
        case "messenger.membres":
            MsgrMembresVue(conv: MessengerStore.convCapture("filles"))
        case "messenger.medias":
            MsgrMediasVue(conv: MessengerStore.convCapture("filles"))
        case "messenger.appel":
            MsgrAppelVue(conv: MessengerStore.convCapture("chloe"), mode: .vocal)
        case "messenger.appelvideo":
            MsgrAppelVue(conv: MessengerStore.convCapture("chloe"), mode: .video)
        case "messenger.parametres":
            MsgrParametresVue()
        case "messenger.invitations":
            MsgrInvitationsFacebookVue()
        case "messenger.invitationstout":
            MsgrListeCompleteVue(genre: .invitations)
        case "messenger.suggestionstout":
            MsgrListeCompleteVue(genre: .suggestions)
        case "messenger.invitationsmessage":
            MsgrInvitationsMessageVue()
        case "messenger.archive":
            MsgrArchiveVue()
        case "messenger.nouveau":
            MsgrNouveauMessageVue(ouvrir: { _ in })
        case "messenger.notifications":
            MsgrNotificationsVue().preferredColorScheme(.dark)
        case "messenger.story":
            MsgrVisionneuseStoryVue(story: MessengerStore.storyCapture())
        case "messenger.note":
            MsgrNoteAmieVue(note: MessengerStore.noteCapture())
        case "messenger.reactions":
            MsgrFeuilleReactionsVue(message: MessengerStore.messageCapture(),
                                    conv: MessengerStore.convCapture("filles"),
                                    retirer: { _ in })
        default:
            MessengerVue()
        }
    }

    // Instagram v3.1 (03/09 soir, D92 — retours 279) : le registre suit la refonte
    // d'InstagramApp.swift. Chaque clé pointe une vue de capture Ig… qui possède SON PROPRE
    // IgEtat (@StateObject) : aucun état externe, aucun binding, aucune valeur force-déballée,
    // la capture ne dépend d'aucune interaction préalable. Les identifiants sont résolus par
    // les accesseurs NON optionnels d'IgCatalogue / DonneesInsta.
    // Écrans ajoutés au lot 280 : listes de relations, navigateur interne des liens de bio,
    // appels audio et vidéo, « nouveau message », Enregistrements / Archives / Paramètres.
    // Les clés « instagram#0..4 » passent par SIMCTL_CHILD_ONGLET et retombent sur la racine
    // InstagramVue, qui lit ONGLET (0 feed · 1 reels · 2 DM · 3 recherche · 4 profil).
    @ViewBuilder
    private func ecransInstagram() -> some View {
        switch cle {
        case "instagram.commentaires": IgCaptureCommentaires()
        case "instagram.partage": IgCapturePartage()
        case "instagram.detail": IgCaptureDetail()
        case "instagram.notifications": IgCaptureNotifications()
        case "instagram.activite": IgCaptureNotifications()
        case "instagram.reels": IgCaptureReels()
        case "instagram.recherche": IgCaptureRecherche()
        case "instagram.profil": IgCaptureProfil()
        case "instagram.profilprive": IgCaptureProfilPrive()
        case "instagram.story": IgCaptureStory()
        case "instagram.dm": IgCaptureDM()
        case "instagram.dmconv": IgCaptureDMConv()
        case "instagram.relations": IgCaptureRelations()
        case "instagram.navigateur": IgCaptureNavigateur()
        case "instagram.appel": IgCaptureAppel()
        case "instagram.appelvideo": IgCaptureAppelVideo()
        case "instagram.nouveau": IgCaptureNouveauMessage()
        case "instagram.enregistrements": IgCaptureEnregistrements()
        case "instagram.archives": IgCaptureArchives()
        case "instagram.parametres": IgCaptureParametres()
        default: InstagramVue()
        }
    }

    // Snapchat v3.1 D92 (03/09 soir) : registre aligné sur la simplification du lot 280.
    // Retiré : « snapchat.reglages » (l'écran de réglages a disparu de l'app — D92).
    // Ajouté : appel audio, appel vidéo, fiche d'ami·e, listes d'ami·es, demandes, notifications.
    // Les données viennent d'accesseurs NON optionnels de DonneesSnap
    // (convCapture / storyCapture / decouvrirCapture / maStory) : aucun indice nu,
    // aucun binding externe, aucune force-unwrap.
    // Les clés « snapchat#0..4 » retombent sur la racine SnapchatVue(), qui lit ONGLET dans son init.
    // snapchat.camera / snapchat.spotlight passent par la COQUILLE (SnapchatVue(onglet:))
    // pour que la barre d'onglets et la BarreHome restent visibles sur la capture.
    @ViewBuilder
    private func ecransSnapchat() -> some View {
        switch cle {
        case "snapchat.conv":
            SnapConversationVue(ami: DonneesSnap.convCapture())
        case "snapchat.appelaudio":
            SnapAppelAudioVue(ami: DonneesSnap.convCapture())
        case "snapchat.appelvideo":
            SnapAppelVideoVue(ami: DonneesSnap.convCapture())
        case "snapchat.ficheami":
            SnapFicheAmiVue(ami: DonneesSnap.convCapture(), surCarte: { })
        case "snapchat.profil":
            SnapProfilVue()
        case "snapchat.amis":
            SnapListeAmisVue(titre: "Mes amis·es", meilleurs: false)
        case "snapchat.demandes":
            SnapDemandesVue()
        case "snapchat.notifications":
            SnapNotificationsVue()
        case "snapchat.recherche":
            SnapRechercheVue()
        case "snapchat.nouveauchat":
            SnapNouveauChatVue()
        case "snapchat.story":
            SnapVisionneuseVue(story: DonneesSnap.storyCapture())
        case "snapchat.decouvrir":
            SnapVisionneuseVue(story: DonneesSnap.decouvrirCapture())
        case "snapchat.envoyer":
            SnapEnvoyerAVue(cleImage: "p12")
        case "snapchat.camera":
            SnapchatVue(onglet: 2)
        case "snapchat.spotlight":
            SnapchatVue(onglet: 4)
        default:
            SnapchatVue()
        }
    }

    // Facebook v3.1 D92 (03/09 soir) : plus aucune feuille/cover — les écrans présentés sont des calques
    // de la ZStack racine ; les captures utilisent FbCapture.etat() (état neuf, aucun singleton mutable).
    @ViewBuilder
    private func ecransFacebook() -> some View {
        switch cle {
        case "facebook.story":
            FbStoryVue()
        case "facebook.detail":
            FbPostDetailVue(post: DonneesFb.posts[0], etat: FbCapture.etat())
        case "facebook.partage":
            FbPartageFeuille(post: DonneesFb.posts[0], etat: FbCapture.etat())
        case "facebook.menu":
            FacebookVue(tiroirInitial: true)
        case "facebook.recherche":
            FbRechercheVue(etat: FbCapture.etat())
        case "facebook.profil":
            FacebookVue(ongletInitial: 5)
        case "facebook.reels":
            FacebookVue(ongletInitial: 1)
        case "facebook.amis":
            FacebookVue(ongletInitial: 2)
        case "facebook.groupes":
            FacebookVue(ongletInitial: 3)
        case "facebook.notifications":
            FacebookVue(ongletInitial: 4)
        default:
            FacebookVue()
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
        case "cartes.reglages": RechercheCartesVue()
        default: CartesVueWallet()
        }
    }

    // PayPal v1 D92 (06/09) — registre aligné sur les 263 frames de Joachim.
    // Les clés « paypal#0..3 » retombent sur la racine PayPalVue(onglet:) : Accueil,
    // Comptes, Envoyer/demander, Activité. Les données viennent d'accesseurs NON
    // optionnels de PpCapture (aucun indice nu, aucune force-unwrap).
    @ViewBuilder
    private func ecransPaypal() -> some View {
        switch cle {
        case "paypal.solde":
            PpEcranCapture { PpSoldeVue() }
        case "paypal.transactions":
            PpEcranCapture { PpToutesTransactionsVue() }
        case "paypal.transaction":
            PpEcranCapture { PpTransactionVue(tx: PpCapture.transaction()) }
        case "paypal.paiement":
            PpEcranCapture { PpTransactionVue(tx: PpCapture.paiement()) }
        case "paypal.historique":
            PpEcranCapture {
                PpHistoriqueVue(tiers: "Marc", initiales: "M", teinte: 0x2F6F5F, marchand: false)
            }
        case "paypal.montant":
            PpEcranCapture { PpMontantVue(contact: PpCapture.contact()) }
        case "paypal.verifier":
            PpFeuilleEnvoi(contact: PpCapture.contact(), montant: 25, note: "",
                           surRefus: { _ in }, surInterruption: {}, surSucces: {})
        case "paypal.interrompu":
            PpInterrompuVue {}
        case "paypal.confirmation":
            PpConfirmationVue(destinataire: "Chloé", montant: "25,00 €") {}
        case "paypal.demande":
            PpEcranCapture { PpDemandeVue(demande: PpCapture.demande()) }
        case "paypal.notifications":
            PpEcranCapture { PpNotificationsVue() }
        case "paypal.menu":
            PpEcranCapture { PpMenuVue() }
        case "paypal.profil":
            PpEcranCapture { PpProfilVue() }
        case "paypal.coordonnees":
            PpEcranCapture { PpCoordonneesVue() }
        case "paypal.parametres":
            PpEcranCapture { PpParametresVue() }
        case "paypal.notifsreglages":
            PpEcranCapture { PpNotifsReglagesVue() }
        case "paypal.securite":
            PpEcranCapture { PpSecuriteVue() }
        case "paypal.abonnements":
            PpEcranCapture { PpAbonnementsVue() }
        case "paypal.abonnement":
            PpEcranCapture { PpAbonnementDetailVue(abonnement: PpCapture.abonnement()) }
        case "paypal.portefeuille", "paypal.carte":
            PpEcranCapture { PpCarteBancaireVue() }
        default:
            PayPalVue(onglet: PpCapture.ongletDemande)
        }
    }

    // App Store v1 D92 (06/09) — 226 frames. Les clés « appstore#0..4 » passent par la COQUILLE
    // (AppStoreVue(onglet:)) pour que la barre d'onglets flottante et la BarreHome restent visibles.
    @ViewBuilder
    private func ecransAppstore() -> some View {
        switch cle {
        case "appstore#0": AppStoreVue(onglet: 0).coquilleSarah()
        case "appstore#1": AppStoreVue(onglet: 1).coquilleSarah()
        case "appstore#2": AppStoreVue(onglet: 2).coquilleSarah()
        case "appstore#3": AppStoreVue(onglet: 3).coquilleSarah()
        case "appstore#4": AppStoreVue(onglet: 4).coquilleSarah()
        case "appstore.recherche": AppStoreVue(onglet: 4).coquilleSarah()
        default: AsCapture(cle: cle).coquilleSarah()
        }
    }

    // Musique v1 D92 (06/09) — 180 frames de référence.
    // Les écrans poussés passent par MuPile (le NavigationStack + son UNIQUE navigationDestination).
    // « musique#0..4 » retombe sur la racine, qui lit ONGLET dans son init (comme SnapchatVue).
    @ViewBuilder
    private func ecransMusique() -> some View {
        switch cle {
        case "musique.album":
            MuPile { MuAlbumVue(indice: 10) }
        case "musique.playlist":
            MuPile { MuPlaylistVue(indice: 0) }
        case "musique.artiste":
            MuPile { MuArtisteVue(nom: "Jul") }
        case "musique.morceaux":
            MuPile { MuListeMorceauxVue() }
        case "musique.albums":
            MuPile { MuListeAlbumsVue() }
        case "musique.artistes":
            MuPile { MuListeArtistesVue() }
        case "musique.playlists":
            MuPile { MuListePlaylistsVue() }
        case "musique.favoris":
            MuPile { MuFavorisVue() }
        case "musique.telechargements":
            MuPile { MuTelechargementsVue() }
        case "musique.recents":
            MuPile { MuRecentsVue() }
        case "musique.titresmoment":
            MuPile { MuTitresMomentVue() }
        case "musique.station":
            MuPile { MuStationVue(indice: 0) }
        case "musique.genre":
            MuPile { MuGenreVue(genre: "Électronique") }
        case "musique.recherche":
            MusiqueVue(onglet: 4).coquilleSarah()
        case "musique.lecteur":
            MuLecteurVueCapture()
        case "musique.file":
            MuFileVue()
        default:
            MusiqueVue().coquilleSarah()
        }
    }

    // Vague B (07/09) — Uber (56 frames), SNCF Connect (196 frames), FaceTime (captures officielles Apple, D93).
    // Registres remplis à l'intégration à partir des livraisons docs/vague-b/*-livraison.md.
    @ViewBuilder
    private func ecransUber() -> some View {
        switch cle {
        case "uber#0": UberVue(onglet: 0).coquilleSarah(claire: true)
        case "uber#1": UberVue(onglet: 1).coquilleSarah(claire: true)
        case "uber#2": UberVue(onglet: 2).coquilleSarah(claire: true)
        case "uber#3": UberVue(onglet: 3).coquilleSarah(claire: true)
        case "uber.destination": UbEcranCapture { UbDestinationVue(quand: "") }
        case "uber.courses": UbEcranCapture { UbCoursesVue(destination: UbCapture.lieu(), quand: "") }
        case "uber.reserver": UbEcranCapture { UbReserveVue() }
        case "uber.heure": UbEcranCapture { UbHeureVue(destination: UbCapture.lieu()) }
        case "uber.confirmation": UbEcranCapture { UbConfirmationVue(destination: UbCapture.lieu(), option: UbCapture.option()) }
        case "uber.activite": UbEcranCapture { UbActiviteVue() }
        case "uber.course": UbEcranCapture { UbCourseVue(course: UbCapture.course()) }
        case "uber.reservation": UbEcranCapture { UbReservationVue(reservation: UbCapture.reservation()) }
        case "uber.compte": UbEcranCapture { UbCompteVue() }
        case "uber.wallet": UbEcranCapture { UbWalletVue() }
        case "uber.parametres": UbEcranCapture { UbParametresVue() }
        case "uber.coordonnees": UbEcranCapture { UbCoordonneesVue() }
        case "uber.aide": UbEcranCapture { UbAideVue() }
        case "uber.securite": UbEcranCapture { UbSecuriteVue() }
        case "uber.messages": UbEcranCapture { UbMessagesVue() }
        case "uber.message": UbEcranCapture { UbMessageVue(message: UbCapture.message()) }
        case "uber.uberone": UbEcranCapture { UbUberOneVue() }
        case "uber.services": UbEcranCapture { UbServicesVue() }
        default: UberVue(onglet: UbCapture.ongletDemande).coquilleSarah(claire: true)
        }
    }

    @ViewBuilder
    private func ecransSncf() -> some View {
        switch cle {
        case "sncf.recherche":
            SnEcranCapture {
                SnRechercheVue(depart: "Lyon Part-Dieu",
                               arrivee: "Marseille Saint-Charles", mode: .train)
            }
        case "sncf.destination":
            SnEcranCapture {
                SnDestinationVue(titre: "Rechercher", versRecherche: true, choisir: { _ in })
            }
        case "sncf.calendrier":
            SnEcranCapture { SnCalendrierVue(offset: 0, heure: 10) { _, _ in } }
        case "sncf.resultats":
            SnEcranCapture {
                SnResultatsVue(depart: "Lyon Part-Dieu", arrivee: "Marseille Saint-Charles",
                               offset: 0, voyageurs: 1, directs: false, mode: .train)
            }
        case "sncf.trajet":
            SnEcranCapture { SnTarifVue(trajet: SnCapture.trajet(), voyageurs: 1) }
        case "sncf.tarif":
            SnEcranCapture { SnConditionsVue() }
        case "sncf.train":
            SnEcranCapture { SnTrainVue(trajet: SnCapture.trajet()) }
        case "sncf.panier":
            SnEcranCapture { SnPanierVue() }
                .onAppear { SnCapture.preparerPanier() }
        case "sncf.paiement":
            SnEcranCapture { SnPaiementVue() }
                .onAppear { SnCapture.preparerPanier() }
        case "sncf.billet":
            SnEcranCapture { SnBilletVue(voyage: SnCapture.voyage()) }
        case "sncf.voyages":
            SnEcranCapture { SnVoyageVue(voyage: SnCapture.voyage()) }
        case "sncf.horaires":
            SnEcranCapture { SnHorairesVue(gare: "Lyon Part-Dieu") }
        case "sncf.gare":
            SnEcranCapture { SnGareRechercheVue() }
        case "sncf.trafic":
            SnEcranCapture { SnTraficVue() }
        case "sncf.perturbation":
            SnEcranCapture { SnPerturbationVue(perturbation: SnCapture.perturbation()) }
        case "sncf.compte":
            SnEcranCapture { SnCompteVue(onglet: .constant(3)) }
        case "sncf.coordonnees":
            SnEcranCapture { SnCoordonneesVue() }
        case "sncf.identite":
            SnEcranCapture { SnIdentiteVue { } }
        case "sncf.parametres":
            SnEcranCapture { SnParametresVue() }
        case "sncf.affichage":
            SnEcranCapture { SnAffichageVue() }
        case "sncf.cartes":
            SnEcranCapture { SnCartesReductionVue() }
        case "sncf.qr":
            SnEcranCapture { SnQrCartesVue() }
        case "sncf.paiements":
            SnEcranCapture { SnMoyensPaiementVue() }
        case "sncf.alertes":
            SnEcranCapture { SnAlertesBilletsVue() }
        case "sncf.compagnons":
            SnEcranCapture { SnCompagnonsVue() }
        case "sncf.offre":
            SnEcranCapture { SnOffreVue(offre: SnCapture.offre()) }
        case "sncf.alerte3117":
            SnEcranCapture { SnAlerteVue() }
        case "sncf.notifications":
            SnEcranCapture { SnNotificationsVue() }
        case "sncf.aide":
            SnEcranCapture { SnAideVue(question: "Comment fonctionne une option ?") }
        default: SncfVue(onglet: SnCapture.ongletDemande).coquilleSarah()
        }
    }

    @ViewBuilder
    private func ecransFacetime() -> some View {
        switch cle {
        case "facetime#0":
            FaceTimeVue().coquilleSarah()
        case "facetime.nouveau":
            FtEcranCapture { FtNouveauVue() }
        case "facetime.appel":
            FtEcranCapture { FtAppelVue(noms: ["Marc ❤️"], mode: .video) }
        case "facetime.indisponible":
            FtEcranCapture { FtAppelVue(noms: ["Marc ❤️"], mode: .video, indisponibleInitiale: true) }
        case "facetime.enregistrement":
            FtEcranCapture { FtEnregistrementVue(destinataire: "Marc ❤️", phaseInitiale: .relecture) }
        case "facetime.messagevideo":
            FtEcranCapture { FtLecteurMessageVue(message: FtCapture.message()) }
        case "facetime.detail":
            FtEcranCapture { FtDetailVue(appel: FtCapture.appel()) }
        case "facetime.lien":
            FtEcranCapture { FtLienVue() }
        case "facetime.modifier":
            FtEcranCapture { FtListeVue(chemin: .constant([]), editionInitiale: true) }
        default: FaceTimeVue().coquilleSarah()
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
        case "calendrier.annee": NavigationStack { AnneeVue { _ in } }
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
        case "safari.onglets": OngletsVue(onglets: .constant(DonneesSafari.onglets), ongletsPrives: .constant([]), modePrive: .constant(false), ouvrir: { _ in }, nouveau: {}, fermer: { _ in })
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
                // v2 02/09 (retour Joachim, Safari puis Santé) : la zone système n'est PLUS traversée par le contenu
                // qui défile — bande de matériau (comme la barre d'état iOS au-dessus d'une liste) sous l'heure/batterie.
                BarreSarah(claire: claire)
                    .background(
                        (claire ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.black.opacity(0.72)))
                    )
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
        // v2 Safari 31/08 : la zone tactile est limitée à la capsule elle-même (+5 pt de marge),
        // plus JAMAIS toute la largeur de l'écran — les contrôles bas des apps (Safari…) restent utilisables.
        VStack(spacing: 0) {
            Capsule()
                .fill(sombre ? Color.black.opacity(0.75) : Color.white.opacity(0.92))
                .frame(width: 140, height: 5)
        }
        .padding(.top, 9)
        .padding(.bottom, 5)
        .frame(width: 150)
        .contentShape(Rectangle())
        .onTapGesture { action() }
        .gesture(DragGesture(minimumDistance: 8).onEnded { v in
            if v.translation.height < -15 { action() }
        })
        .frame(maxWidth: .infinity)   // centrage seulement, sans zone tactile
    }
}

// ============================================================ ROUTEUR INTER-APPS (correctif P3, 20/08)
// « Appeler » dans Ma Banque ouvre le clavier du Téléphone pré-rempli ; « Site web » dans Plans ouvre Safari.
enum CibleRouteur { case telephone, safari, plans, mail, messages, facebook, messenger }

final class Routeur: ObservableObject {
    static let partage = Routeur()
    @Published var demande: Int = 0
    var cible: CibleRouteur? = nil
    var numeroAppel: String? = nil
    var pageSafari: String? = nil
    var urlSafari: String? = nil
    var mailCompose: String? = nil   // v2 correctifs 31/08 : composer préadressé
    var itineraire: (nom: String, lat: Double, lon: Double)? = nil   // v3 02/09 : Localiser → Plans avec la destination

    func allerTelephone(_ numero: String) {
        numeroAppel = numero; cible = .telephone; demande += 1
    }
    func allerSafari(page: String, url: String) {
        pageSafari = page; urlSafari = url; cible = .safari; demande += 1
    }
    func allerPlans() { cible = .plans; demande += 1 }
    // v3 02/09 : ouvre Plans DIRECTEMENT sur l'itinéraire vers une personne/un appareil (demande Joachim, Localiser)
    func allerPlans(itineraireVers nom: String, lat: Double, lon: Double) {
        itineraire = (nom, lat, lon); cible = .plans; demande += 1
    }
    func consommerItineraire() -> (nom: String, lat: Double, lon: Double)? { let i = itineraire; itineraire = nil; return i }
    func allerMail() { cible = .mail; demande += 1 }
    // v2 correctifs 31/08 : ouvre Mail directement sur un nouveau message préadressé
    func allerMail(composePour adresse: String) {
        mailCompose = adresse; cible = .mail; demande += 1
    }
    func allerMessages() { cible = .messages; demande += 1 }
    // v3 03/09 (refonte Messenger) : le logo Facebook de Messenger ouvre RÉELLEMENT
    // l'app Facebook de la coque, et réciproquement.
    func allerFacebook() { cible = .facebook; demande += 1 }
    func allerMessenger() { cible = .messenger; demande += 1 }
    // D92 03/09 : cohérence Messenger → Facebook — ouvre Facebook DIRECTEMENT sur le profil d'une personne
    // (nom affiché, ex. « Vincent Berthier »). FacebookVue consomme la demande à l'apparition.
    var profilFacebookDemande: String? = nil
    func allerFacebook(profil nom: String) { profilFacebookDemande = nom; cible = .facebook; demande += 1 }
    func consommerProfilFacebook() -> String? { let n = profilFacebookDemande; profilFacebookDemande = nil; return n }
    // D92 03/09 : cohérence Facebook → Messenger — ouvre Messenger DIRECTEMENT sur une conversation
    // (nom Facebook du contact) après un partage de publication.
    var conversationMessengerDemande: String? = nil
    func allerMessenger(conversation nom: String) { conversationMessengerDemande = nom; cible = .messenger; demande += 1 }
    func consommerConversationMessenger() -> String? { let n = conversationMessengerDemande; conversationMessengerDemande = nil; return n }
    func consommerNumero() -> String? { let n = numeroAppel; numeroAppel = nil; return n }
    func consommerMailCompose() -> String? { let a = mailCompose; mailCompose = nil; return a }
    func consommerPage() -> (String, String)? {
        guard let p = pageSafari, let u = urlSafari else { return nil }
        pageSafari = nil; urlSafari = nil
        return (p, u)
    }
}

// ============================================================ FEUILLE DE PARTAGE MAISON (anti-friction, 21/08)
// v2 02/09 (principe Joachim : toute action annoncée produit son résultat ou une réaction cohérente) :
// AirDrop → recherche puis « Aucun appareil à proximité » ; WhatsApp → choix du contact et VRAI envoi dans la
// conversation ; Mail → ouvre un nouveau message ; Messages → ouvre l'app Messages ; Copier → presse-papiers RÉEL ;
// Enregistrer dans Fichiers → le fichier APPARAÎT dans Fichiers (Récents + Documents) ; Imprimer → recherche
// puis « Aucune imprimante AirPrint détectée ».
enum TypePartage { case note, liste, fichier, lien, photo }

struct FeuillePartage: View {
    @Environment(\.dismiss) private var dismiss
    var element: String = "1 élément"
    var contenu: String = ""
    var type: TypePartage = .fichier
    @State private var copie = false
    @State private var enregistre = false
    @State private var airdrop: String? = nil       // « Recherche… » → « Aucun appareil à proximité »
    @State private var impression: String? = nil
    @State private var choixWhatsApp = false
    @State private var envoyeA: String? = nil

    private var icone: String {
        switch type { case .note: return "note.text"; case .liste: return "checklist"; case .lien: return "link"; case .photo: return "photo"; case .fichier: return "doc.fill" }
    }
    private var genreFichier: String {
        switch type { case .note, .liste: return "txt"; case .lien: return "webloc"; case .photo: return "image"; case .fichier: return "pdf" }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10).fill(Color(hex: 0x2C2C2E))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: icone).font(.system(size: 17)).foregroundStyle(.secondary))
                VStack(alignment: .leading, spacing: 2) {
                    Text(element).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                    Text(contenu.isEmpty ? "Options ›" : String(contenu.prefix(60)).replacingOccurrences(of: "\n", with: " ") + " ›")
                        .font(.system(size: 12.5)).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                        .frame(width: 28, height: 28).background(Color(hex: 0x2C2C2E), in: Circle())
                }
            }
            .padding(16)
            Divider().overlay(Color(hex: 0x2C2C2E))

            if let a = airdrop {
                // AirDrop : recherche réelle d'appareils… il n'y en a aucun (Sarah est seule)
                VStack(spacing: 10) {
                    if a == "Recherche…" { ProgressView().tint(.white) } else { Image(systemName: "wifi.slash").font(.system(size: 26)).foregroundStyle(.secondary) }
                    Text(a).font(.system(size: 15)).foregroundStyle(.white)
                    if a != "Recherche…" {
                        Text("Assurez-vous que l'appareil est à proximité, déverrouillé et que AirDrop est activé.")
                            .font(.system(size: 12.5)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 30)
                    }
                }
                .frame(height: 96)
            } else if let e = envoyeA {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 30)).foregroundStyle(Color(hex: 0x25D366))
                    Text("Envoyé à \(e)").font(.system(size: 15)).foregroundStyle(.white)
                }
                .frame(height: 96)
            } else if choixWhatsApp {
                // Choix du destinataire WhatsApp — l'envoi est RÉEL (le message apparaît dans la conversation)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18) {
                        ForEach(["Chloé", "Maman", "Les filles 💃", "Thomas", "Marie kiné", "Marc ❤️"], id: \.self) { c in
                            VStack(spacing: 6) {
                                AvatarSilhouette(taille: 50, image: c == "Marc ❤️" ? "AvatarMarc" : nil)
                                Text(c.components(separatedBy: " ").first ?? c).font(.system(size: 11)).foregroundStyle(.white.opacity(0.85))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                let f = DateFormatter(); f.dateFormat = "HH:mm"
                                let texte = contenu.isEmpty ? element : "\(element)\n\(contenu)"
                                EnvoisJoueur.partage.ajouter(c, .msgJoueur(String(texte.prefix(600)), f.string(from: Date())))
                                Haptique.leger()
                                withAnimation { envoyeA = c }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { dismiss() }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                }
                .padding(.vertical, 18)
            } else {
                HStack(spacing: 22) {
                    DestinatairePartage(nom: "AirDrop", symbole: "wifi", fond: 0x1C7CF5) {
                        withAnimation { airdrop = "Recherche…" }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { withAnimation { airdrop = "Aucun appareil à proximité" } }
                    }
                    DestinatairePartage(nom: "Messages", symbole: "message.fill", fond: 0x32D74B) {
                        dismiss()
                        Routeur.partage.allerMessages()
                    }
                    DestinatairePartage(nom: "Mail", symbole: "envelope.fill", fond: 0x0A84FF) {
                        dismiss()
                        Routeur.partage.allerMail(composePour: "")
                    }
                    DestinatairePartage(nom: "WhatsApp", symbole: "phone.fill", fond: 0x25D366) {
                        withAnimation { choixWhatsApp = true }
                    }
                }
                .padding(.vertical, 18)
            }
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
                    UIPasteboard.general.string = contenu.isEmpty ? element : contenu   // presse-papiers RÉEL
                    copie = true; Haptique.leger()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { dismiss() }
                }
                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 18)
                HStack {
                    Text(enregistre ? "Enregistré dans Fichiers › Documents" : "Enregistrer dans Fichiers").foregroundStyle(enregistre ? Color.secondary : Color.white)
                    Spacer()
                    Image(systemName: enregistre ? "checkmark" : "folder").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 18).padding(.vertical, 13)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !enregistre else { return }
                    MagasinFichiers.partage.ajouter(nom: element, genre: genreFichier, contenu: contenu)   // le fichier APPARAÎT dans Fichiers
                    enregistre = true; Haptique.leger()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { dismiss() }
                }
                Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 18)
                HStack {
                    Text(impression ?? "Imprimer").foregroundStyle(impression == nil ? Color.white : Color.secondary)
                    Spacer()
                    Image(systemName: "printer").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 18).padding(.vertical, 13)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard impression == nil else { return }
                    impression = "Recherche d'imprimantes…"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { impression = "Aucune imprimante AirPrint détectée" }
                }
            }
            Spacer()
        }
        .background(Color(hex: 0x1C1C1E))
        .presentationDetents([.height(372)])
        .preferredColorScheme(.dark)
    }
}

struct DestinatairePartage: View {
    let nom: String
    let symbole: String
    let fond: UInt
    var action: () -> Void = {}
    var body: some View {
        VStack(spacing: 6) {
            Circle().fill(Color(hex: fond)).frame(width: 54, height: 54)
                .overlay(Image(systemName: symbole).font(.system(size: 21)).foregroundStyle(.white))
            Text(nom).font(.system(size: 11)).foregroundStyle(.white.opacity(0.85))
        }
        .contentShape(Rectangle())
        .onTapGesture { action() }
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
    @State private var paypalOuvert = false
    @State private var musiqueOuverte = false
    @State private var appStoreOuvert = false
    @State private var uberOuvert = false
    @State private var sncfOuvert = false
    @State private var facetimeOuvert = false
    @State private var page = 0
    // v2 correctifs 31/08 : badge WhatsApp de l'accueil = vraies non-lues (disparaît à zéro)
    @ObservedObject private var magasinWA = MagasinWA.partage
    private var badgeWA: String? { magasinWA.nonLues.isEmpty ? nil : "\(magasinWA.nonLues.count)" }
    @ObservedObject private var routeur = Routeur.partage
    @ObservedObject private var pontAppStore = PontAppStore.partage

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
        // PayPal v1 (06/09) — asset ic-paypal (carré plein 180×180, squircle appliqué par AppIcone)
        ("PayPal", Color(hex: 0x002484), "p.circle.fill", .white),
        ("Musique", .white, "music.note", Color(hex: 0xFA2D48)),
        ("Messenger", Color(hex: 0x0084FF), "bolt.horizontal.circle.fill", .white),
        ("Instagram", Color(hex: 0xE1306C), "camera.circle", .white),
        ("Snapchat", Color(hex: 0xFFFC00), "bubble.left.fill", .black),
        ("Facebook", Color(hex: 0x0866FF), "f.circle.fill", .white),
        ("X", .black, "xmark", .white),
        ("ChatGPT", .white, "circle.hexagongrid.fill", .black),
        ("Spotify", .black, "circle.circle.fill", Color(hex: 0x1ED760)),
        ("YouTube", .white, "play.rectangle.fill", Color(hex: 0xFF0000)),
        // Vague B (07/09) : FaceTime (asset simulateur facetime) + icônes officielles App Store (ic-uber, ic-sncf, 180×180)
        ("FaceTime", Color(hex: 0x30D158), "video.fill", .white),
        ("Uber", .black, "car.fill", .white),
        ("SNCF Connect", Color(hex: 0x0C131F), "tram.fill", Color(hex: 0x5FE3FF)),
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
        paypalOuvert = false; musiqueOuverte = false; appStoreOuvert = false
        uberOuvert = false; sncfOuvert = false; facetimeOuvert = false
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
        case "Musique": return { musiqueOuverte = true }
        case "PayPal": return { paypalOuvert = true }
        case "App Store": return { appStoreOuvert = true }
        case "Uber": return { uberOuvert = true }
        case "SNCF Connect": return { sncfOuvert = true }
        case "FaceTime": return { facetimeOuvert = true }
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
                         badge: a.0 == "WhatsApp" ? badgeWA : nil,
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
                                     symbole: "message.fill", teinte: .white, badge: badgeWA,
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
        .fullScreenCover(isPresented: $paypalOuvert) { PayPalVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $musiqueOuverte) { MusiqueVue().coquilleSarah() }
        .fullScreenCover(isPresented: $appStoreOuvert) { AppStoreVue().coquilleSarah() }
        .fullScreenCover(isPresented: $uberOuvert) { UberVue().coquilleSarah(claire: true) }
        .fullScreenCover(isPresented: $sncfOuvert) { SncfVue().coquilleSarah() }
        .fullScreenCover(isPresented: $facetimeOuvert) { FaceTimeVue().coquilleSarah() }
        // D82 : « Ouvrir » dans l'App Store ouvre RÉELLEMENT l'app du jeu (relais PontAppStore).
        .onChange(of: pontAppStore.demande) { _, _ in
            guard let nom = PontAppStore.partage.consommer() else { return }
            appStoreOuvert = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { actionPour(nom)?() }
        }
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
                case .facebook: facebookOuvert = true
                case .messenger: messengerOuvert = true
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
        "PayPal": "paypal",
        "Uber": "uber", "SNCF Connect": "sncf",
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
    @State private var nouvelleDiscussionVisible = false
    @State private var nouveauGroupeVisible = false
    @State private var nouvelleCommunauteVisible = false
    @State private var viseurListeVisible = false
    @State private var photosListeVisibles = false
    @State private var photoAEnvoyer: PhotoAPartagerWA? = nil
    @State private var nomConvOuverte: String? = nil
    @State private var nomInfosOuvert: InfosContactCible? = nil   // fix 02/09 : infos routées au niveau liste
    @State private var modeSelection = false
    @State private var selectionWA = Set<String>()
    @ObservedObject private var envois = EnvoisJoueur.partage
    @ObservedObject private var magasin = MagasinWA.partage

    // v2 étape 3 : ordre de base PAR RÉCENCE (aujourd'hui 19:40 > 19:33 > 17:41 > dim. > sam. > ven.)
    private let convs: [(String, String, String, Bool)] = [
        ("Les filles 💃", "19:40", "Chloé : Julie appelle-moi stp", false),
        ("Chloé", "19:33", "📞 Appel vocal manqué", true),
        ("Marc ❤️", "17:41", "N'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges co…", true),
        ("Maman", "dimanche", "tu viens dimanche ??? bisous maman", false),
        ("Thomas", "samedi", "🤙 Trop fort ce sticker 😂", false),
        ("Marie kiné", "vendredi", "✓✓ ok pour l'échange de créneaux jeudi 👍", false),
    ]

    // Aperçu vivant + nouvelles discussions du joueur + tri (épinglées > activité > récence de base)
    private var convsVivantes: [(String, String, String, Bool)] {
        var toutes: [(String, String, String, Bool)] =
            magasin.nouvelles.map { ($0, "", "", false) } + convs
        toutes = toutes.map { c in
            if let (apercu, heure) = envois.dernierApercu(c.0) { return (c.0, heure, apercu, c.3) }
            return c
        }
        let rang = Dictionary(uniqueKeysWithValues: envois.ordreActivite.enumerated().map { ($1, $0) })
        var indexees = Array(toutes.enumerated())
        indexees.sort { a, b in
            let pa = magasin.epinglees.contains(a.element.0), pb = magasin.epinglees.contains(b.element.0)
            if pa != pb { return pa }
            let ra = rang[a.element.0] ?? Int.max, rb = rang[b.element.0] ?? Int.max
            return ra == rb ? a.offset < b.offset : ra < rb
        }
        return indexees.map { $0.element }.filter { !magasin.archiveesJoueur.contains($0.0) }
    }

    // D51-1 : les filtres et la recherche fonctionnent réellement
    private var convsFiltrees: [(String, String, String, Bool)] {
        var r = convsVivantes
        if filtre == 1 { r = r.filter { magasin.nonLues[$0.0] != nil } }
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
                // v2 correctifs 31/08 ANTI-CRASH : destination déclarée UNE fois, sur une vue
                // toujours montée (plus jamais dans une branche du switch qui disparaît)
                .navigationDestination(item: $nomConvOuverte) { nom in
                    ConversationVue(nomContact: nom)
                }
                // fix 02/09 (retour Joachim : le tap de rangée ouvrait les infos au lieu de la discussion) :
                // le lien caché par rangée créait DEUX NavigationLink dans une même rangée de List —
                // SwiftUI en déclenchait un au hasard. « Infos du contact » passe désormais par cette
                // destination UNIQUE, déclarée une fois sur la vue toujours montée (même motif que la conv).
                .navigationDestination(item: $nomInfosOuvert) { cible in
                    InfosContactVue(nom: cible.nom, numero: DonneesWA.fiches[cible.nom]?.numero ?? "")
                }

                HStack(spacing: 10) {
                    HStack(spacing: 0) {
                        OngletFlottant(symbole: "circle.dashed", nom: "Actus", actif: onglet == 0, pointVert: true) { onglet = 0 }
                        OngletFlottant(symbole: "phone", nom: "Appels", actif: onglet == 1) { onglet = 1 }
                        OngletFlottant(symbole: "person.3", nom: "Communautés", actif: onglet == 2) { onglet = 2 }
                        OngletFlottant(symbole: "bubble.left.and.bubble.right.fill", nom: "Discussions", actif: onglet == 3,
                                       badge: magasin.nonLues.isEmpty ? nil : "\(magasin.nonLues.count)") { onglet = 3 }
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
            // v2 étape 3 : les menus AGISSENT vraiment
            .confirmationDialog("", isPresented: $menuPlus, titleVisibility: .hidden) {
                Button("Nouvelle discussion") { nouvelleDiscussionVisible = true }
                Button("Nouveau groupe") { nouveauGroupeVisible = true }
                Button("Nouvelle communauté") { nouvelleCommunauteVisible = true }
                Button("Annuler", role: .cancel) {}
            }
            .confirmationDialog("", isPresented: $menuPoints, titleVisibility: .hidden) {
                Button("Sélectionner des discussions") { modeSelection = true; selectionWA.removeAll() }
                Button("Tout marquer comme lu") { magasin.nonLues.removeAll() }
                Button("Réglages") { onglet = 4 }
                Button("Annuler", role: .cancel) {}
            }
            .confirmationDialog("Appareil photo", isPresented: $menuCamera, titleVisibility: .visible) {
                Button("Prendre une photo") { viseurListeVisible = true }
                Button("Photothèque") { photosListeVisibles = true }
                Button("Annuler", role: .cancel) {}
            }
            .sheet(isPresented: $nouvelleDiscussionVisible) {
                NouvelleDiscussionWAVue { nom in
                    nouvelleDiscussionVisible = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { nomConvOuverte = nom }
                }
            }
            .sheet(isPresented: $nouveauGroupeVisible) {
                NouveauGroupeWAVue { nom in
                    nouveauGroupeVisible = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { nomConvOuverte = nom }
                }
            }
            .sheet(isPresented: $nouvelleCommunauteVisible) { NouvelleCommunauteVue() }
            .fullScreenCover(isPresented: $viseurListeVisible) {
                ViseurCameraVue { nomFichier in
                    viseurListeVisible = false
                    if let nf = nomFichier { photoAEnvoyer = PhotoAPartagerWA(fichier: nf) }
                }
            }
            .sheet(isPresented: $photosListeVisibles) {
                SelecteurPhotosMsg { nomFichier in
                    photosListeVisibles = false
                    photoAEnvoyer = PhotoAPartagerWA(fichier: nomFichier)
                }
            }
            .sheet(item: $photoAEnvoyer) { photo in
                // La photo prise/choisie part RÉELLEMENT chez le contact choisi
                PartageContactWAVue(nomSource: "") { nom in
                    let f = DateFormatter(); f.dateFormat = "HH:mm"
                    envois.ajouter(nom, .imageJoueur(photo.fichier, f.string(from: Date())))
                    photoAEnvoyer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { nomConvOuverte = nom }
                }
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
                    PuceActive(texte: magasin.nonLues.isEmpty ? "Non lues" : "Non lues \(magasin.nonLues.count)",
                               active: filtre == 1) { filtre = 1 }
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
                        if modeSelection {
                            // v2 étape 3 : mode sélection réel (archivage groupé)
                            HStack(spacing: 10) {
                                Image(systemName: selectionWA.contains(c.0) ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(selectionWA.contains(c.0) ? waVertDoux : waTexte2)
                                LigneConv(c: (c.0, c.1, c.2, nil, c.3))
                            }
                            .listRowBackground(waNoir)
                            .listRowSeparatorTint(Color(hex: 0x222222))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectionWA.contains(c.0) { selectionWA.remove(c.0) } else { selectionWA.insert(c.0) }
                            }
                        } else {
                            LigneConvWARangee(c: c, infosPour: $nomInfosOuvert)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 70)
                .overlay(alignment: .bottom) {
                    if modeSelection {
                        HStack {
                            Text("Archiver")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(selectionWA.isEmpty ? waTexte2 : waVertDoux)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard !selectionWA.isEmpty else { return }
                                    withAnimation { for n in selectionWA { magasin.archiver(n) } }
                                    selectionWA.removeAll(); modeSelection = false
                                }
                            Spacer()
                            Text("\(selectionWA.count) sélectionnée\(selectionWA.count > 1 ? "s" : "")")
                                .font(.system(size: 14)).foregroundStyle(waTexte2)
                            Spacer()
                            Text("Terminé")
                                .font(.system(size: 16, weight: .semibold)).foregroundStyle(waVertDoux)
                                .contentShape(Rectangle())
                                .onTapGesture { modeSelection = false; selectionWA.removeAll() }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(waTabBar, in: Capsule())
                        .padding(.horizontal, 14).padding(.bottom, 78)
                    }
                }
            }
        }
    }
}

// v2 étape 3 — identifiant de photo à partager (sheet(item:))
struct PhotoAPartagerWA: Identifiable {
    let id = UUID()
    let fichier: String
}

// v2 étape 3 — rangée de discussion avec balayages RÉELS (non lu / archiver / plus)
// fix 02/09 : cible d’« Infos du contact » (type dédié pour ne pas entrer en conflit
// avec la destination String de la conversation)
struct InfosContactCible: Identifiable, Hashable {
    let nom: String
    var id: String { nom }
}

struct LigneConvWARangee: View {
    let c: (String, String, String, Bool)
    @Binding var infosPour: InfosContactCible?
    @ObservedObject private var magasin = MagasinWA.partage
    @State private var menuPlusVisible = false

    private var estNonLue: Bool { magasin.nonLues[c.0] != nil }

    var body: some View {
        NavigationLink(destination: ConversationVue(nomContact: c.0)) {
            // v2 correctifs 31/08 : l'heure suit l'état non-lu RÉEL (repasse en gris une fois lue)
            LigneConv(c: (c.0, c.1, c.2, magasin.nonLues[c.0].flatMap { $0.isEmpty ? "•" : $0 }, estNonLue),
                      epinglee: magasin.epinglees.contains(c.0))
        }
        .listRowBackground(waNoir)
        .listRowSeparatorTint(Color(hex: 0x222222))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                withAnimation { magasin.archiver(c.0) }
            } label: { Label("Archiver", systemImage: "archivebox.fill") }.tint(Color(hex: 0x25303A))
            Button { menuPlusVisible = true } label: { Label("Plus", systemImage: "ellipsis") }.tint(Color(hex: 0x3A3A3C))
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            // v2 étape 3 : bascule réelle, libellé adapté à l'état actuel
            Button {
                magasin.basculerNonLue(c.0)
            } label: {
                Label(estNonLue ? "Lu" : "Non lu",
                      systemImage: estNonLue ? "message.badge" : "message.badge.filled.fill")
            }.tint(Color(hex: 0x1D6F4C))
        }
        .confirmationDialog(c.0, isPresented: $menuPlusVisible, titleVisibility: .visible) {
            Button(magasin.epinglees.contains(c.0) ? "Désépingler" : "Épingler") {
                magasin.basculerEpingle(c.0)
            }
            Button("Infos du contact") { infosPour = InfosContactCible(nom: c.0) }
            Button("Annuler", role: .cancel) {}
        }
        // fix 02/09 : plus AUCUN second NavigationLink dans la rangée (voir WhatsAppListeView).
        // Piège consigné : dans une List, une rangée = UN seul NavigationLink, sinon le tap
        // de rangée déclenche le mauvais lien (ici : les infos s’ouvraient au lieu de la discussion).
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
    var epinglee: Bool = false
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
                    if epinglee {
                        Image(systemName: "pin.fill").font(.system(size: 12))
                            .foregroundStyle(waTexte2).padding(.top, 6)
                    }
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

// v2 étape 3 — nouvelle discussion : choisir un contact, la discussion s'ouvre vraiment
struct NouvelleDiscussionWAVue: View {
    @Environment(\.dismiss) private var dismiss
    let choisir: (String) -> Void
    @State private var recherche = ""
    private var noms: [String] {
        var vus = Set<String>()
        var out: [String] = []
        for n in DonneesWA.fiches.keys.sorted() where n != "Les filles 💃" {
            if vus.insert(n).inserted { out.append(n) }
        }
        for c in DonneesTel.contacts {
            if vus.insert(c.0).inserted { out.append(c.0) }
        }
        guard !recherche.isEmpty else { return out }
        return out.filter { $0.localizedCaseInsensitiveContains(recherche) }
    }
    var body: some View {
        NavigationStack {
            ZStack {
                waNoir.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundStyle(waTexte2)
                        TextField("", text: $recherche,
                                  prompt: Text("Rechercher un nom ou un numéro").foregroundStyle(waTexte2))
                            .font(.system(size: 16)).foregroundStyle(waTexte)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 9)
                    .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 14).padding(.top, 10)
                    List {
                        ForEach(noms, id: \.self) { nom in
                            HStack(spacing: 12) {
                                AvatarSilhouette(taille: 44)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(nom).font(.system(size: 17)).foregroundStyle(waTexte)
                                    Text("Salut ! J'utilise WhatsApp.").font(.system(size: 13.5)).foregroundStyle(waTexte2)
                                }
                            }
                            .listRowBackground(waNoir)
                            .listRowSeparatorTint(Color(hex: 0x222222))
                            .contentShape(Rectangle())
                            .onTapGesture { Haptique.leger(); choisir(nom) }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Nouvelle discussion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }.foregroundStyle(waVertDoux)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// v2 étape 3 — nouveau groupe : sélection multiple, le groupe se crée vraiment
struct NouveauGroupeWAVue: View {
    @Environment(\.dismiss) private var dismiss
    let creer: (String) -> Void
    @State private var selection: [String] = []
    @State private var nomGroupe = ""
    private var noms: [String] {
        DonneesWA.fiches.keys.sorted().filter { $0 != "Les filles 💃" } + ["Julie"]
    }
    var body: some View {
        NavigationStack {
            ZStack {
                waNoir.ignoresSafeArea()
                VStack(spacing: 0) {
                    TextField("", text: $nomGroupe,
                              prompt: Text("Sujet du groupe (facultatif)").foregroundStyle(waTexte2))
                        .font(.system(size: 16)).foregroundStyle(waTexte)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color(hex: 0x1C1C1E), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 14).padding(.top, 10)
                    List {
                        ForEach(noms, id: \.self) { nom in
                            HStack(spacing: 12) {
                                Image(systemName: selection.contains(nom) ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(selection.contains(nom) ? waVertDoux : waTexte2)
                                AvatarSilhouette(taille: 40)
                                Text(nom).font(.system(size: 17)).foregroundStyle(waTexte)
                            }
                            .listRowBackground(waNoir)
                            .listRowSeparatorTint(Color(hex: 0x222222))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Haptique.leger()
                                if let i = selection.firstIndex(of: nom) { selection.remove(at: i) }
                                else { selection.append(nom) }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Nouveau groupe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }.foregroundStyle(waVertDoux)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        guard !selection.isEmpty else { return }
                        Haptique.leger()
                        let nom = nomGroupe.trimmingCharacters(in: .whitespaces).isEmpty
                            ? selection.prefix(3).joined(separator: ", ")
                            : nomGroupe.trimmingCharacters(in: .whitespaces)
                        MagasinWA.partage.enregistrerNouvelle(nom)
                        creer(nom)
                    }
                    .foregroundStyle(selection.isEmpty ? waTexte2 : waVertDoux)
                }
            }
        }
        .preferredColorScheme(.dark)
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
