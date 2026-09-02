// Safari — construit contre la vidéo de référence du 20/08 (96 écrans, iOS 26)
// D51-2 : barre d'adresse fonctionnelle, onglets, HISTORIQUE par jours (le composant d'enquête),
// signets, pages rendues. R3 : l'historique du 16 août au soir = la capture P68 rejouée en vrai.
// v2 Safari 31/08 (retours Joachim, session 2) :
//   1. barre home : zone tactile réduite (correctif global dans LPProto)
//   2. onglets RÉELS : « + » ouvre un nouvel onglet (normal ET privé), fermeture ×, compteur vivant
//   3. bouton aA RÉEL : zoom du texte, lecteur, masquer la barre d'outils
//   4. recherche CONTRÔLÉE : ~12 requêtes liées à l'histoire → vraies pages de résultats ;
//      le reste → page Google « aucun résultat » crédible (ou erreur serveur si ça ressemble à une URL)
//   5. sites d'enquête ÉTOFFÉS : service-public, France Victimes, cybermalveillance, forum Doctissimo,
//      VesselFinder, Chez Fonfon + articles génériques ouvrables depuis chaque résultat Google
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct EntreeHistorique: Identifiable {
    let id = UUID()
    var titre: String
    var url: String
    var heure: String
    var section: String
}

struct OngletSafari: Identifiable {
    let id = UUID()
    var titre: String
    var url: String
    var page: String     // identifiant de rendu
}

enum DonneesSafari {
    static let historique: [EntreeHistorique] = [
        // — Dimanche soir (16 août) : la nuit où elle a douté (= P68)
        EntreeHistorique(titre: "position navire MV Beaumont — VesselFinder", url: "vesselfinder.com", heure: "23:31", section: "Dimanche soir"),
        EntreeHistorique(titre: "compagnie maritime agent OKAFOR — Recherche Google", url: "google.com", heure: "23:26", section: "Dimanche soir"),
        EntreeHistorique(titre: "Arnaque aux sentiments : reconnaître les signes — France Victimes", url: "france-victimes.fr", heure: "23:17", section: "Dimanche soir"),
        EntreeHistorique(titre: "Escroquerie sentimentale (romance scam) : que faire ?", url: "service-public.fr", heure: "23:14", section: "Dimanche soir"),
        EntreeHistorique(titre: "arnaque sentimentale officier marine — Recherche Google", url: "google.com", heure: "23:12", section: "Dimanche soir"),
        // — Dimanche après-midi : l'espoir intact
        EntreeHistorique(titre: "Chez Fonfon — Restaurant Marseille Vieux-Port", url: "chez-fonfon.com", heure: "16:40", section: "Dimanche après-midi"),
        EntreeHistorique(titre: "hôtel vieux port marseille 28 août — Recherche Google", url: "google.com", heure: "16:32", section: "Dimanche après-midi"),
        // — La semaine
        EntreeHistorique(titre: "horaires LCL agence Bellecour — Recherche Google", url: "google.com", heure: "12 août", section: "Semaine dernière"),
        EntreeHistorique(titre: "TGV Lyon Marseille vendredi 28 août — SNCF Connect", url: "sncf-connect.com", heure: "10 août", section: "Semaine dernière"),
        EntreeHistorique(titre: "augmenter plafond virement LCL — Recherche Google", url: "google.com", heure: "10 août", section: "Semaine dernière"),
        EntreeHistorique(titre: "recette gratin courgettes mamie — Recherche Google", url: "google.com", heure: "7 août", section: "Semaine dernière"),
        // — Mars : le début
        EntreeHistorique(titre: "meetic avis site sérieux ? — Recherche Google", url: "google.com", heure: "8 mars", section: "Mars"),
        EntreeHistorique(titre: "que répondre premier message site de rencontre", url: "google.com", heure: "13 mars", section: "Mars"),
    ]
    static let sectionsHistorique = ["Dimanche soir", "Dimanche après-midi", "Semaine dernière", "Mars"]

    static let onglets: [OngletSafari] = [
        OngletSafari(titre: "Escroquerie sentimentale (romance scam) : que faire ?", url: "service-public.fr", page: "servicepublic"),
        OngletSafari(titre: "arnaque sentimentale officier marine — Recherche", url: "google.com", page: "google:arnaque"),
        OngletSafari(titre: "Chez Fonfon — Marseille", url: "chez-fonfon.com", page: "fonfon"),
    ]
}

// ============================================================ RECHERCHE CONTRÔLÉE (v2 Safari, point 4)
struct ResultatRecherche: Identifiable {
    let id = UUID()
    var site: String
    var titre: String
    var extrait: String
    var page: String      // destination réelle au tap (page dédiée ou "article:<clé>")
    var url: String
}

enum CatalogueRecherches {
    struct Requete { var affichee: String; var nb: String; var resultats: [ResultatRecherche] }

    static let requetes: [String: Requete] = [
        "arnaque": Requete(
            affichee: "arnaque sentimentale officier marine",
            nb: "Environ 148 000 résultats",
            resultats: [
                ResultatRecherche(site: "service-public.fr",
                    titre: "Escroquerie sentimentale (romance scam) : que faire ?",
                    extrait: "L'escroc se fait passer pour un militaire, un officier de marine ou un ingénieur à l'étranger. Il demande de l'argent pour des frais de douane, une caution…",
                    page: "servicepublic", url: "service-public.fr"),
                ResultatRecherche(site: "france-victimes.fr",
                    titre: "Arnaque aux sentiments : reconnaître les signes",
                    extrait: "Il ne peut jamais vous rencontrer ni faire de visio nette. Les demandes d'argent passent par Western Union ou un « agent »…",
                    page: "victimes", url: "france-victimes.fr"),
                ResultatRecherche(site: "forum.doctissimo.fr",
                    titre: "Mon histoire : il disait être officier en mer depuis 8 mois",
                    extrait: "Il m'appelait sa reine. J'ai envoyé 6 000 € en tout. Le jour où il devait débarquer à Marseille, plus aucune nouvelle…",
                    page: "forum", url: "forum.doctissimo.fr"),
                ResultatRecherche(site: "cybermalveillance.gouv.fr",
                    titre: "Fraude à la romance : comment réagir et signaler",
                    extrait: "Cessez tout contact et tout envoi d'argent. Conservez les preuves : messages, reçus de transfert…",
                    page: "cyber", url: "cybermalveillance.gouv.fr"),
            ]),
        "okafor": Requete(
            affichee: "compagnie maritime agent OKAFOR",
            nb: "Environ 2 340 résultats",
            resultats: [
                ResultatRecherche(site: "cybermalveillance.gouv.fr",
                    titre: "Le faux « agent maritime », rouage classique de la fraude à la romance",
                    extrait: "Un prétendu agent (douane, port, compagnie) réclame des frais pour débloquer un colis, une prime ou un débarquement. Aucune compagnie sérieuse ne procède ainsi…",
                    page: "cyber", url: "cybermalveillance.gouv.fr"),
                ResultatRecherche(site: "registre-maritime.org",
                    titre: "Registre des agents maritimes agréés — recherche « OKAFOR »",
                    extrait: "Aucune entrée ne correspond à votre recherche dans le registre international des agents consignataires…",
                    page: "article:registre", url: "registre-maritime.org"),
                ResultatRecherche(site: "forum.doctissimo.fr",
                    titre: "« L'agent » m'a demandé 2 800 € de frais de douane — témoignages",
                    extrait: "Même mode opératoire pour nous toutes : l'officier ne peut pas payer lui-même, c'est toujours « l'agent » qui écrit…",
                    page: "forum", url: "forum.doctissimo.fr"),
            ]),
        "hotel": Requete(
            affichee: "hôtel vieux port marseille 28 août",
            nb: "Environ 1 260 000 résultats",
            resultats: [
                ResultatRecherche(site: "booking.com",
                    titre: "Hôtel Belle Vue — Vieux-Port, Marseille · dès 142 €/nuit",
                    extrait: "Vue sur le port, à 2 min du quai des Belges. Il reste 3 chambres pour le 28 août…",
                    page: "article:bellevue", url: "booking.com"),
                ResultatRecherche(site: "hotel-residence-marseille.fr",
                    titre: "La Résidence du Vieux-Port ★★★★ — site officiel",
                    extrait: "Chambres avec balcon face à Notre-Dame de la Garde. Meilleur tarif garanti en réservant en direct…",
                    page: "article:residence", url: "hotel-residence-marseille.fr"),
                ResultatRecherche(site: "tripadvisor.fr",
                    titre: "Les 10 meilleurs hôtels près du Vieux-Port — avis voyageurs",
                    extrait: "Comparez 1 847 avis. N°1 : La Résidence du Vieux-Port ; n°2 : Hôtel Belle Vue ; n°3 : Escale Oceania…",
                    page: "article:tripadvisor", url: "tripadvisor.fr"),
            ]),
        "lcl": Requete(
            affichee: "horaires LCL agence Bellecour",
            nb: "Environ 18 700 résultats",
            resultats: [
                ResultatRecherche(site: "lcl.fr",
                    titre: "Agence LCL Lyon Bellecour — horaires et rendez-vous",
                    extrait: "12 place Bellecour, 69002 Lyon. Ouvert du mardi au samedi. Conseillers sur rendez-vous à partir de 9h00…",
                    page: "article:lclagence", url: "lcl.fr"),
                ResultatRecherche(site: "lcl.fr",
                    titre: "Augmenter le plafond de virement — LCL Mon Compte",
                    extrait: "Le relèvement temporaire du plafond s'effectue en agence ou depuis l'application, rubrique Virements > Plafonds. Un délai de 48 h peut s'appliquer…",
                    page: "article:lclplafond", url: "lcl.fr"),
                ResultatRecherche(site: "moneyvox.fr",
                    titre: "Virement bancaire : plafonds, délais et précautions",
                    extrait: "Avant un virement important vers un compte inconnu, les banques recommandent de vérifier l'identité réelle du bénéficiaire…",
                    page: "article:moneyvox", url: "moneyvox.fr"),
            ]),
        "tgv": Requete(
            affichee: "TGV Lyon Marseille vendredi 28 août",
            nb: "Environ 412 000 résultats",
            resultats: [
                ResultatRecherche(site: "sncf-connect.com",
                    titre: "Lyon Part-Dieu → Marseille St-Charles — ven. 28 août",
                    extrait: "TGV INOUI 6173 · 09:04 → 10:47 · dès 49 €. TGV INOUI 6177 · 11:04 → 12:47 · dès 62 €…",
                    page: "article:sncf", url: "sncf-connect.com"),
                ResultatRecherche(site: "trainline.fr",
                    titre: "Billets Lyon – Marseille : comparez les horaires",
                    extrait: "1 h 43 de trajet direct. Les billets du vendredi partent vite en été, réservez tôt…",
                    page: "article:trainline", url: "trainline.fr"),
            ]),
        "meetic": Requete(
            affichee: "meetic avis site sérieux ?",
            nb: "Environ 96 300 résultats",
            resultats: [
                ResultatRecherche(site: "60millions-mag.com",
                    titre: "Sites de rencontre : notre enquête sur les profils trompeurs",
                    extrait: "Sur les plateformes testées, une part notable de profils présente des photos invérifiables. Méfiance si la personne refuse la visio…",
                    page: "article:60millions", url: "60millions-mag.com"),
                ResultatRecherche(site: "avis-verifies.com",
                    titre: "Meetic — 4 100 avis clients",
                    extrait: "Note moyenne 3,6/5. « J'y ai rencontré mon mari » ; « attention aux faux profils, signalez-les »…",
                    page: "article:avismeetic", url: "avis-verifies.com"),
                ResultatRecherche(site: "forum.doctissimo.fr",
                    titre: "Rencontre en ligne à 50 ans : vos expériences ?",
                    extrait: "Ne donnez jamais d'argent, même après des mois. Une amie s'est fait piéger par un « militaire en mission »…",
                    page: "forum", url: "forum.doctissimo.fr"),
            ]),
        "marc": Requete(
            affichee: "Marc Delacroix officier marine",
            nb: "7 résultats",
            resultats: [
                ResultatRecherche(site: "linkedin.com",
                    titre: "Marc Delacroix — Chauffagiste, Valenciennes",
                    extrait: "Expérience : SARL Thermiconfort (2011 – aujourd'hui). 12 relations…",
                    page: "article:linkedin", url: "linkedin.com"),
                ResultatRecherche(site: "copainsdavant.fr",
                    titre: "Marc Delacroix — Lycée Jean Moulin, promo 1988",
                    extrait: "A rejoint le site en 2009. Dernière connexion il y a 11 ans…",
                    page: "article:copains", url: "copainsdavant.fr"),
                ResultatRecherche(site: "defense.gouv.fr",
                    titre: "Annuaire des officiers de la Marine nationale — recherche",
                    extrait: "Aucun officier en activité ne correspond à « Delacroix, Marc ». Les personnels déployés restent joignables par les canaux officiels…",
                    page: "article:defense", url: "defense.gouv.fr"),
                // v2 02/09 : les 4 résultats manquants (la page annonçait 7, n'en montrait que 3)
                ResultatRecherche(site: "pagesjaunes.fr",
                    titre: "DELACROIX Marc — 3 résultats en France",
                    extrait: "Valenciennes (59), Bourges (18), Quimper (29). Aucun résultat à Toulon, Brest ou Lyon…",
                    page: "article:pagesjaunes", url: "pagesjaunes.fr"),
                ResultatRecherche(site: "facebook.com",
                    titre: "Marc Delacroix — Profils | Facebook",
                    extrait: "Afficher les profils des personnes qui s'appellent Marc Delacroix. 14 profils. Aucun n'indique la Marine nationale…",
                    page: "article:fbprofils", url: "facebook.com"),
                ResultatRecherche(site: "cybermalveillance.gouv.fr",
                    titre: "Faux militaires en mission : reconnaître l'usurpation d'identité",
                    extrait: "Les escrocs utilisent des photos volées d'officiers réels et des noms plausibles. Vérifiez toujours par un canal officiel…",
                    page: "cyber", url: "cybermalveillance.gouv.fr"),
                ResultatRecherche(site: "forum.doctissimo.fr",
                    titre: "« Il s'appelait Marc, officier en mer » — témoignage",
                    extrait: "Même prénom, même histoire de mission, même demande d'argent pour rentrer. Ne payez rien…",
                    page: "forum", url: "forum.doctissimo.fr"),
            ]),
        "recette": Requete(
            affichee: "recette gratin courgettes mamie",
            nb: "Environ 803 000 résultats",
            resultats: [
                ResultatRecherche(site: "marmiton.org",
                    titre: "Gratin de courgettes de mamie — recette facile",
                    extrait: "4,7/5 (1 213 avis). Courgettes, crème, gruyère, muscade. Cuisson 35 min à 180 °C…",
                    page: "article:gratin", url: "marmiton.org"),
                ResultatRecherche(site: "cuisineaz.com",
                    titre: "Gratin de courgettes léger au chèvre",
                    extrait: "Une variante plus légère, sans crème, avec du fromage de chèvre frais et de la menthe…",
                    page: "article:gratin2", url: "cuisineaz.com"),
            ]),
    ]

    // Résout une saisie libre vers une page rendue. Retourne (page, url, titre d'onglet).
    static func resoudre(_ saisie: String) -> (String, String, String) {
        let r = saisie.lowercased()
        func google(_ cle: String) -> (String, String, String) {
            ("google:\(cle)", "google.com", "\(requetes[cle]?.affichee ?? saisie) — Recherche")
        }
        if r.contains("beaumont") || r.contains("navire") || r.contains("vessel") || r.contains("imo") {
            return ("vessel", "vesselfinder.com", "MV Beaumont — VesselFinder")
        }
        if r.contains("okafor") || r.contains("agent maritime") || r.contains("compagnie maritime") { return google("okafor") }
        if r.contains("victimes") { return ("victimes", "france-victimes.fr", "Arnaque aux sentiments — France Victimes") }
        if r.contains("escroquerie") || r.contains("service-public") || r.contains("service public") {
            return ("servicepublic", "service-public.fr", "Escroquerie sentimentale : que faire ?")
        }
        if r.contains("cybermalveillance") || r.contains("thesee") || r.contains("signaler") {
            return ("cyber", "cybermalveillance.gouv.fr", "Fraude à la romance — Cybermalveillance")
        }
        if r.contains("doctissimo") || r.contains("témoignage") || r.contains("temoignage") {
            return ("forum", "forum.doctissimo.fr", "Il disait être officier en mer — Doctissimo")
        }
        if r.contains("fonfon") || r.contains("bouillabaisse") { return ("fonfon", "chez-fonfon.com", "Chez Fonfon — Marseille") }
        if r.contains("tgv") || r.contains("sncf") || r.contains("train") { return google("tgv") }
        if r.contains("hôtel") || r.contains("hotel") || r.contains("vieux port") || r.contains("vieux-port") { return google("hotel") }
        if r.contains("lcl") || r.contains("bellecour") || r.contains("plafond") || r.contains("virement") { return google("lcl") }
        if r.contains("meetic") || r.contains("rencontre") { return google("meetic") }
        let compact = r.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        if r.contains("delacroix") || compact.contains("delacroix") || compact.contains("marquedelacroix")
            || compact.contains("marcdelacroix") || r.contains("dlc.officier") || r.contains("marc.dlc") { return google("marc") }
        if r.contains("arnaque") || r.contains("sentimental") || r.contains("romance") || r.contains("officier") || r.contains("militaire") {
            return google("arnaque")
        }
        if r.contains("recette") || r.contains("gratin") || r.contains("courgette") { return google("recette") }
        if r.contains("marseille") { return google("hotel") }
        // Rien de prévu : une adresse → erreur serveur ; une recherche → Google sans résultat pertinent
        if r.contains(".") && !r.contains(" ") { return ("erreur", saisie, saisie) }
        return ("google:vide:\(saisie)", "google.com", "\(saisie) — Recherche")
    }
}

// ============================================================ ARTICLES GÉNÉRIQUES (v2 Safari, point 5)
// Chaque résultat Google mène quelque part : soit une page dédiée, soit un de ces articles.
enum ArticlesSafari {
    struct Article { var site: String; var titre: String; var sousTitre: String; var corps: [String] }
    static let tous: [String: Article] = [
        "registre": Article(site: "registre-maritime.org", titre: "Recherche : « OKAFOR »",
            sousTitre: "Registre international des agents consignataires",
            corps: ["Aucune entrée ne correspond à votre recherche.",
                    "Tous les agents maritimes agréés opérant dans les ports européens figurent dans ce registre, mis à jour mensuellement par les autorités portuaires.",
                    "Si un « agent » vous contacte au nom d'une compagnie sans figurer ici, il ne dispose d'aucune accréditation."]),
        "bellevue": Article(site: "booking.com", titre: "Hôtel Belle Vue — Vieux-Port",
            sousTitre: "4 rue Beauvau, 13001 Marseille · 8,4 Très bien (2 130 avis)",
            corps: ["Vue sur le port depuis les chambres des étages supérieurs, à deux minutes à pied du quai des Belges et de l'ombrière.",
                    "Vendredi 28 août : il reste 3 chambres. Chambre double classique 142 € · Chambre vue port 189 €.",
                    "Annulation gratuite jusqu'à 48 h avant l'arrivée. Petit-déjeuner en terrasse 16 €."]),
        "residence": Article(site: "hotel-residence-marseille.fr", titre: "La Résidence du Vieux-Port ★★★★",
            sousTitre: "18 quai du Port, 13002 Marseille — site officiel",
            corps: ["Face au Vieux-Port, toutes nos chambres offrent un balcon avec vue sur Notre-Dame de la Garde.",
                    "Meilleur tarif garanti en réservant en direct : chambre double dès 215 € en août.",
                    "Restaurant panoramique au 5ᵉ étage, ouvert midi et soir."]),
        "tripadvisor": Article(site: "tripadvisor.fr", titre: "Les 10 meilleurs hôtels près du Vieux-Port",
            sousTitre: "Classement selon 1 847 avis de voyageurs",
            corps: ["1. La Résidence du Vieux-Port — « la vue du balcon vaut chaque euro »",
                    "2. Hôtel Belle Vue — « emplacement parfait, accueil charmant »",
                    "3. Escale Oceania — « bon rapport qualité-prix à 5 min du port »",
                    "Conseil des voyageurs : en été, réservez plusieurs semaines à l'avance, surtout le week-end."]),
        "lclagence": Article(site: "lcl.fr", titre: "Agence LCL Lyon Bellecour",
            sousTitre: "12 place Bellecour, 69002 Lyon · 04 72 41 63 00",
            corps: ["Horaires : mardi–vendredi 9h00–12h30 / 13h45–18h00 · samedi 9h00–12h45 · fermé dimanche et lundi.",
                    "Les rendez-vous conseillers se prennent en ligne ou par téléphone. Prochain créneau conseillé : en matinée dès l'ouverture.",
                    "Services en agence : virements exceptionnels, relèvement de plafonds, retraits supérieurs à 2 000 €."]),
        "lclplafond": Article(site: "lcl.fr", titre: "Augmenter le plafond de virement",
            sousTitre: "LCL Mon Compte — aide en ligne",
            corps: ["Le relèvement temporaire du plafond de virement s'effectue depuis l'application (Virements > Plafonds) ou en agence.",
                    "Au-delà de 3 000 € vers un nouveau bénéficiaire, une validation renforcée est demandée et un délai de 48 h peut s'appliquer.",
                    "Attention : LCL ne vous demandera jamais d'effectuer un virement « urgent » vers un compte tiers, même au nom d'un proche."]),
        "moneyvox": Article(site: "moneyvox.fr", titre: "Virement bancaire : plafonds, délais et précautions",
            sousTitre: "Guide pratique — mis à jour en juin",
            corps: ["Avant un virement important vers un compte inconnu, vérifiez l'identité réelle du bénéficiaire : un RIB étranger au nom d'un tiers doit alerter.",
                    "Les escroqueries « aux sentiments » représentent plusieurs dizaines de millions d'euros de préjudice par an en France.",
                    "Un virement SEPA exécuté ne peut être rappelé qu'avec l'accord du bénéficiaire : en pratique, l'argent est rarement récupéré."]),
        "sncf": Article(site: "sncf-connect.com", titre: "Lyon Part-Dieu → Marseille St-Charles",
            sousTitre: "Vendredi 28 août — trajets directs",
            corps: ["TGV INOUI 6173 · 09:04 → 10:47 · à partir de 49 €",
                    "TGV INOUI 6177 · 11:04 → 12:47 · à partir de 62 €",
                    "TGV INOUI 6181 · 13:04 → 14:47 · à partir de 45 €",
                    "1 h 43 de trajet. Les places du vendredi d'été partent vite : les meilleurs prix s'affichent le matin."]),
        "trainline": Article(site: "trainline.fr", titre: "Billets Lyon – Marseille",
            sousTitre: "Comparez horaires et prix en un coup d'œil",
            corps: ["Trajet direct en 1 h 43 par TGV INOUI, jusqu'à 14 départs par jour depuis Lyon Part-Dieu.",
                    "Prix moyen constaté en août : 58 €. Réserver 3 semaines à l'avance fait économiser en moyenne 31 %."]),
        "60millions": Article(site: "60millions-mag.com", titre: "Sites de rencontre : notre enquête sur les profils trompeurs",
            sousTitre: "60 Millions de consommateurs — dossier",
            corps: ["Sur les plateformes testées, une part notable des profils présente des photos invérifiables ou volées à des tiers.",
                    "Signes récurrents des faux profils : photos très avantageuses, profession « prestigieuse » à l'étranger (militaire, ingénieur offshore, chirurgien humanitaire), déclaration d'amour très rapide.",
                    "Règle d'or : tant que la personne refuse une rencontre ou une visio spontanée, ne partagez ni argent ni documents."]),
        "avismeetic": Article(site: "avis-verifies.com", titre: "Meetic — 4 100 avis clients",
            sousTitre: "Note moyenne : 3,6 / 5",
            corps: ["« J'y ai rencontré mon mari, il faut être patiente et prudente. » — Nadine, 54 ans",
                    "« Attention aux faux profils, signalez-les dès le moindre doute. » — Patricia, 49 ans",
                    "« Fuyez ceux qui veulent tout de suite passer sur WhatsApp. » — Sylvie, 57 ans"]),
        "linkedin": Article(site: "linkedin.com", titre: "Marc Delacroix",
            sousTitre: "Chauffagiste — Valenciennes · 12 relations",
            corps: ["Expérience : SARL Thermiconfort, chauffagiste (2011 – aujourd'hui).",
                    "Formation : CAP installateur thermique, lycée professionnel de Denain.",
                    "Ce profil n'a aucun lien avec la marine marchande ni avec la Marine nationale."]),
        "copains": Article(site: "copainsdavant.fr", titre: "Marc Delacroix — promo 1988",
            sousTitre: "Lycée Jean Moulin",
            corps: ["A rejoint le site en 2009. Dernière connexion : il y a 11 ans.",
                    "Aucune photo publiée. Aucun message public."]),
        "defense": Article(site: "defense.gouv.fr", titre: "Annuaire des officiers — recherche",
            sousTitre: "Marine nationale — service d'information",
            corps: ["Aucun officier en activité ne correspond à « Delacroix, Marc ».",
                    "Les personnels déployés en mer restent joignables par les canaux officiels ; aucune solde n'est jamais « bloquée » au point de nécessiter un virement d'un particulier.",
                    "Si une personne se présentant comme militaire vous demande de l'argent, il s'agit d'une usurpation : signalez-la."]),
        "gratin": Article(site: "marmiton.org", titre: "Gratin de courgettes de mamie",
            sousTitre: "4,7/5 · 1 213 avis · 20 min de préparation",
            corps: ["Ingrédients (4 pers.) : 4 courgettes, 20 cl de crème, 120 g de gruyère, 2 œufs, muscade, sel, poivre.",
                    "Faire revenir les courgettes en rondelles 10 min. Mélanger crème, œufs, muscade. Verser sur les courgettes, couvrir de gruyère.",
                    "Cuire 35 min à 180 °C, jusqu'à ce que le dessus soit bien doré."]),
        "gratin2": Article(site: "cuisineaz.com", titre: "Gratin de courgettes léger au chèvre",
            sousTitre: "Variante sans crème",
            corps: ["Remplacez la crème par du fromage de chèvre frais détendu avec un peu de lait, ajoutez de la menthe ciselée.",
                    "Comptez 30 min à 180 °C. Servir avec une salade de roquette."]),
    ]
}

// ============================================================ LECTEUR (v2 Safari, point 3)
enum LecteurSafari {
    // Pages disposant d'une version « lecteur » (texte seul). nil = lecteur indisponible.
    static func contenu(pour page: String) -> (titre: String, source: String, corps: [String])? {
        if page.hasPrefix("article:"), let a = ArticlesSafari.tous[String(page.dropFirst(8))] {
            return (a.titre, a.site, [a.sousTitre] + a.corps)
        }
        switch page {
        case "servicepublic":
            return ("Escroquerie sentimentale (romance scam) : que faire ?", "service-public.fr",
                    ["L'escroquerie sentimentale consiste à gagner la confiance et l'affection d'une personne pour lui soutirer de l'argent. L'escroc se fait souvent passer pour un militaire, un officier de marine ou un ingénieur travaillant à l'étranger.",
                     "Les signes qui doivent alerter : il ne peut jamais vous rencontrer ni faire d'appel vidéo net ; les demandes d'argent passent par des mandats ou un « agent » ; les sommes augmentent (frais de douane, caution, frais de change) ; il demande de garder la relation secrète.",
                     "Que faire : cessez immédiatement tout envoi d'argent ; conservez toutes les preuves (messages, reçus de transfert) ; déposez plainte et signalez les faits sur la plateforme THESEE."])
        case "victimes":
            return ("Arnaque aux sentiments : reconnaître les signes", "france-victimes.fr",
                    ["La honte est l'arme principale de l'escroc : les victimes n'osent pas en parler, ce qui retarde la découverte des faits.",
                     "Le scénario type dure des mois : déclaration d'amour rapide, projet de rencontre sans cesse repoussé, premier « imprévu » financier, puis escalade.",
                     "Vous n'êtes pas seule : appelez le 116 006 (appel gratuit, 7 j/7). Une association près de chez vous peut vous accompagner, y compris pour le dépôt de plainte."])
        case "cyber":
            return ("Fraude à la romance : comment réagir et signaler", "cybermalveillance.gouv.fr",
                    ["Cessez tout contact et tout envoi d'argent, sans prévenir l'escroc de vos démarches.",
                     "Conservez toutes les preuves : conversations, adresses e-mail, numéros, RIB utilisés, reçus de transfert.",
                     "Signalez le profil à la plateforme de rencontre, déposez plainte via THESEE, et prévenez votre banque : certains virements récents peuvent parfois faire l'objet d'un rappel."])
        case "forum":
            return ("Mon histoire : il disait être officier en mer depuis 8 mois", "forum.doctissimo.fr",
                    ["Il m'appelait sa reine. Des messages magnifiques, tous les matins, tous les soirs. Il disait qu'il n'avait jamais ressenti ça.",
                     "D'abord 400 € pour « des frais de connexion satellite ». Puis 1 200 € pour la douane. Puis 4 400 € via son agent, pour débloquer sa prime de fin de mission. 6 000 € en tout.",
                     "Le jour où il devait débarquer à Marseille, plus aucune nouvelle. Le numéro ne répondait plus. Si mon histoire peut éviter ça à une seule d'entre vous, alors elle aura servi."])
        case "fonfon":
            return ("Chez Fonfon — Vallon des Auffes", "chez-fonfon.com",
                    ["Le restaurant emblématique du Vallon des Auffes vous accueille tous les jours, midi et soir.",
                     "Notre bouillabaisse traditionnelle est servie en deux services, comme le veut la charte : le bouillon et ses croûtons, puis les poissons.",
                     "Réservations par téléphone au 04 91 52 14 38."])
        default: return nil
        }
    }
}

// ============================================================ ZOOM DE PAGE (v2 Safari, point 3 — bouton aA)
private struct ClefHauteurPage: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

struct PageZoomee<Contenu: View>: View {
    var zoom: CGFloat
    @ViewBuilder var contenu: () -> Contenu
    @State private var hauteur: CGFloat = 400
    var body: some View {
        let largeur = UIScreen.main.bounds.width
        contenu()
            .background(GeometryReader { g in
                Color.clear.preference(key: ClefHauteurPage.self, value: g.size.height)
            })
            .onPreferenceChange(ClefHauteurPage.self) { hauteur = $0 }
            .frame(width: largeur / zoom)
            .scaleEffect(zoom, anchor: .top)
            .frame(width: largeur, height: hauteur * zoom, alignment: .top)
    }
}

// ============================================================ APP
struct SafariVue: View {
    @Environment(\.dismiss) private var dismiss
    // Onglets réels (v2 Safari, point 2)
    @State private var onglets: [OngletSafari] = DonneesSafari.onglets
    @State private var ongletsPrives: [OngletSafari] = []
    @State private var modePrive = false
    @State private var ongletActif: UUID? = DonneesSafari.onglets.first?.id

    @State private var pageActive = "servicepublic"
    @State private var urlActive = "service-public.fr"
    @State private var saisie = ""
    @State private var saisieActive = false
    @State private var ongletsVisibles = false
    @State private var historiqueVisible = false
    @State private var partageAlerte = false
    @FocusState private var champFocalise: Bool

    // Historique de navigation (chevrons réels)
    @State private var pileArriere: [(String, String)] = []
    @State private var pileAvant: [(String, String)] = []

    // Bouton aA (v2 Safari, point 3)
    @State private var zoom: CGFloat = 1.0
    @State private var lecteurActif = false
    @State private var barreReduite = false
    @State private var rechargement = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0x1C1C1E).ignoresSafeArea()

            // Page rendue (zoomable, ou version lecteur)
            // v2 02/09 : la page défile SOUS la zone système (heure/batterie), jamais dedans
            ScrollView {
                Group {
                    if lecteurActif, let l = LecteurSafari.contenu(pour: pageActive) {
                        LecteurVue(titre: l.titre, source: l.source, corps: l.corps)
                    } else {
                        PageZoomee(zoom: zoom) {
                            PageRendueVue(page: pageActive) { p, u, t in aller(page: p, url: u, titre: t) }
                        }
                    }
                }
                .padding(.bottom, barreReduite ? 60 : 118)
            }
            .id(rechargement)

            // Suggestions de saisie
            if saisieActive {
                VStack(spacing: 0) {
                    Spacer()
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Suggestions Google").font(.system(size: 12)).foregroundStyle(.secondary)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                        ForEach(suggestions, id: \.self) { s in
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundStyle(.secondary)
                                Text(s).font(.system(size: 15)).foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .contentShape(Rectangle())
                            .onTapGesture { naviguer(s) }
                        }
                    }
                    .background(.ultraThinMaterial)
                }
                .padding(.bottom, 108)
            }

            // Barre du bas : complète, ou réduite (aA > Masquer la barre d'outils)
            if barreReduite {
                Text(urlActive.isEmpty ? "Recherche" : urlActive)
                    .font(.system(size: 12.5)).foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 16).padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .contentShape(Capsule())
                    .onTapGesture { withAnimation(.easeOut(duration: 0.15)) { barreReduite = false } }
                    .padding(.bottom, 22)
            } else {
                barreBasse
            }

            BarreHome { dismiss() }
        }
        .overlay(alignment: .top) {
            // v2 02/09 : bande opaque de la zone système — le contenu passe dessous (comme Safari sous la barre d'état)
            Color(hex: 0x1C1C1E).frame(height: 6).frame(maxWidth: .infinity)
                .background(Color(hex: 0x1C1C1E).ignoresSafeArea(edges: .top))
                .allowsHitTesting(false)
        }
        .onAppear {
            // P3 : si une autre app (Plans, Mail…) a demandé une page, on l'ouvre
            if let (p, u) = Routeur.partage.consommerPage() { aller(page: p, url: u, titre: u) }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $ongletsVisibles) {
            OngletsVue(onglets: $onglets,
                       ongletsPrives: $ongletsPrives,
                       modePrive: $modePrive,
                       ouvrir: { o in
                           ongletActif = o.id
                           pageActive = o.page
                           urlActive = o.url
                           pileArriere = []; pileAvant = []
                           lecteurActif = false
                           ongletsVisibles = false
                       },
                       nouveau: { nouvelOnglet() },
                       fermer: { o in fermerOnglet(o) })
        }
        .sheet(isPresented: $historiqueVisible) {
            // v2 02/09 : le bouton Livre ouvre les SIGNETS complets (Favoris / Liste de lecture / Historique), comme Safari
            SignetsSafariVue(
                ouvrirPage: { p, u, t in aller(page: p, url: u, titre: t); historiqueVisible = false },
                ouvrirHistorique: { e in naviguer(e.titre); historiqueVisible = false })
        }
        .sheet(isPresented: $partageAlerte) { FeuillePartage(element: urlActive) }
    }

    // ——— Barre d'adresse + contrôles bas
    private var barreBasse: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                // v2 Safari : bouton aA RÉEL (zoom, lecteur, barre d'outils)
                Menu {
                    Text("Zoom \(Int(zoom * 100)) %")
                    Button { Haptique.leger(); zoom = min(1.3, zoom + 0.15) } label: {
                        Label("Agrandir le texte", systemImage: "textformat.size.larger")
                    }
                    Button { Haptique.leger(); zoom = max(0.7, zoom - 0.15) } label: {
                        Label("Réduire le texte", systemImage: "textformat.size.smaller")
                    }
                    if zoom != 1.0 {
                        Button("Taille réelle (100 %)") { Haptique.leger(); zoom = 1.0 }
                    }
                    Divider()
                    if LecteurSafari.contenu(pour: pageActive) != nil {
                        Button { Haptique.leger(); lecteurActif.toggle() } label: {
                            Label(lecteurActif ? "Masquer le lecteur" : "Afficher le lecteur", systemImage: "doc.plaintext")
                        }
                    }
                    Button { Haptique.leger(); withAnimation(.easeOut(duration: 0.15)) { barreReduite = true } } label: {
                        Label("Masquer la barre d'outils", systemImage: "arrow.down.right.and.arrow.up.left")
                    }
                } label: {
                    Image(systemName: "textformat.size").font(.system(size: 15))
                        .foregroundStyle(lecteurActif || zoom != 1.0 ? Color(hex: 0x0A84FF) : .white.opacity(0.85))
                        .frame(width: 30, height: 44)
                        .contentShape(Rectangle())
                }
                if saisieActive {
                    TextField("Rechercher ou saisir une adresse", text: $saisie)
                        .focused($champFocalise)
                        .font(.system(size: 15)).foregroundStyle(.white)
                        .autocapitalization(.none)
                        .onSubmit { naviguer(saisie) }
                } else {
                    Text(urlActive.isEmpty ? "Rechercher ou saisir une adresse" : urlActive)
                        .font(.system(size: 15))
                        .foregroundStyle(urlActive.isEmpty ? Color.secondary : Color.white)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { saisieActive = true; champFocalise = true; saisie = "" }
                }
                Image(systemName: "arrow.clockwise").font(.system(size: 14)).foregroundStyle(.white.opacity(0.85))
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); rechargement += 1 }
            }
            .padding(.horizontal, 14).frame(height: 44)
            .background(Color(hex: 0x3A3A3C), in: RoundedRectangle(cornerRadius: 13))
            .padding(.horizontal, 12)

            HStack {
                Image(systemName: "chevron.left").font(.system(size: 19))
                    .opacity(pileArriere.isEmpty ? 0.35 : 1)
                    .contentShape(Rectangle())
                    .onTapGesture { arriere() }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 19))
                    .opacity(pileAvant.isEmpty ? 0.35 : 1)
                    .contentShape(Rectangle())
                    .onTapGesture { avant() }
                Spacer()
                Image(systemName: "square.and.arrow.up").font(.system(size: 18))
                    .contentShape(Rectangle())
                    .onTapGesture { partageAlerte = true }
                Spacer()
                Image(systemName: "book").font(.system(size: 18))
                    .contentShape(Rectangle())
                    .onTapGesture { historiqueVisible = true }
                Spacer()
                Image(systemName: "square.on.square").font(.system(size: 18))
                    .contentShape(Rectangle())
                    .onTapGesture { ongletsVisibles = true }
            }
            .foregroundStyle(Color(hex: 0x0A84FF))
            .padding(.horizontal, 28)
            .padding(.bottom, 12)   // v2 Safari : dégagé de la zone home
        }
        .padding(.top, 8)
        .background(.ultraThinMaterial)
        .padding(.bottom, 18)       // v2 Safari : la barre d'outils s'arrête AU-DESSUS de la capsule home
        .background(Color(hex: 0x1C1C1E).opacity(0.9).ignoresSafeArea(edges: .bottom))
    }

    private var suggestions: [String] {
        let base = ["arnaque sentimentale officier marine", "position navire MV Beaumont",
                    "compagnie maritime agent OKAFOR", "Marc Delacroix officier marine",
                    "horaires LCL agence Bellecour", "hôtel vieux port marseille"]
        guard !saisie.isEmpty else { return Array(base.prefix(4)) }
        return base.filter { $0.localizedCaseInsensitiveContains(saisie) } + [saisie]
    }

    // ——— Navigation (met à jour l'onglet actif + les piles arrière/avant)
    private func aller(page: String, url: String, titre: String) {
        if page != pageActive || url != urlActive {
            pileArriere.append((pageActive, urlActive))
            pileAvant = []
        }
        pageActive = page
        urlActive = url
        lecteurActif = false
        if let i = listeActive.firstIndex(where: { $0.id == ongletActif }) {
            majOnglet(i, page: page, url: url, titre: titre)
        }
    }

    private func arriere() {
        guard let d = pileArriere.popLast() else { return }
        Haptique.leger()
        pileAvant.append((pageActive, urlActive))
        pageActive = d.0; urlActive = d.1; lecteurActif = false
    }

    private func avant() {
        guard let d = pileAvant.popLast() else { return }
        Haptique.leger()
        pileArriere.append((pageActive, urlActive))
        pageActive = d.0; urlActive = d.1; lecteurActif = false
    }

    private func naviguer(_ requete: String) {
        saisieActive = false
        champFocalise = false
        let cible = CatalogueRecherches.resoudre(requete)
        aller(page: cible.0, url: cible.1, titre: cible.2)
        saisie = ""
    }

    // ——— Onglets réels
    private var listeActive: [OngletSafari] { modePrive ? ongletsPrives : onglets }

    private func majOnglet(_ i: Int, page: String, url: String, titre: String) {
        if modePrive { ongletsPrives[i].page = page; ongletsPrives[i].url = url; ongletsPrives[i].titre = titre }
        else { onglets[i].page = page; onglets[i].url = url; onglets[i].titre = titre }
    }

    private func nouvelOnglet() {
        Haptique.leger()
        let o = OngletSafari(titre: "Page de démarrage", url: "", page: "demarrage")
        if modePrive { ongletsPrives.append(o) } else { onglets.append(o) }
        ongletActif = o.id
        pageActive = "demarrage"; urlActive = ""
        pileArriere = []; pileAvant = []; lecteurActif = false
        ongletsVisibles = false
    }

    private func fermerOnglet(_ o: OngletSafari) {
        Haptique.leger()
        if modePrive { ongletsPrives.removeAll { $0.id == o.id } }
        else { onglets.removeAll { $0.id == o.id } }
        if ongletActif == o.id {
            if let dernier = listeActive.last {
                ongletActif = dernier.id
                pageActive = dernier.page; urlActive = dernier.url
            } else {
                // Plus aucun onglet : on en rouvre un sur la page de démarrage (comme iOS)
                let n = OngletSafari(titre: "Page de démarrage", url: "", page: "demarrage")
                if modePrive { ongletsPrives.append(n) } else { onglets.append(n) }
                ongletActif = n.id
                pageActive = "demarrage"; urlActive = ""
            }
            pileArriere = []; pileAvant = []; lecteurActif = false
        }
    }
}

// ============================================================ PAGES RENDUES
struct PageRendueVue: View {
    let page: String
    var onNaviguer: (String, String, String) -> Void = { _, _, _ in }
    var body: some View {
        switch page {
        case "demarrage": DemarrageVue(onNaviguer: onNaviguer)
        case "vessel": VesselVue()
        case "fonfon": FonfonVue()
        case "victimes": FranceVictimesVue()
        case "cyber": CybermalveillanceVue()
        case "forum": ForumDoctissimoVue()
        case "erreur": ErreurSafariVue()
        case let p where p.hasPrefix("google:vide:"):
            GoogleVideVue(requete: String(p.dropFirst(12)), onNaviguer: onNaviguer)
        case let p where p.hasPrefix("google:"):
            ResultatsGoogleVue(cle: String(p.dropFirst(7)), onNaviguer: onNaviguer)
        case let p where p.hasPrefix("article:"):
            ArticleVue(cle: String(p.dropFirst(8)))
        case let p where p.hasPrefix("site:"):
            SiteGeneriqueVue(nom: String(p.dropFirst(5)))
        default: ServicePublicVue()
        }
    }
}

// Page de démarrage (v2 Safari) : les favoris de Sarah — chaque tuile ouvre une vraie page
struct DemarrageVue: View {
    var onNaviguer: (String, String, String) -> Void
    private let favoris: [(String, String, UInt, String, String, String)] = [
        ("RF", "service-public", 0x000091, "servicepublic", "service-public.fr", "Escroquerie sentimentale : que faire ?"),
        ("V", "VesselFinder", 0x0E7490, "vessel", "vesselfinder.com", "MV Beaumont — VesselFinder"),
        ("F", "Chez Fonfon", 0x1E5B8A, "fonfon", "chez-fonfon.com", "Chez Fonfon — Marseille"),
        ("S", "SNCF Connect", 0x6E1E78, "article:sncf", "sncf-connect.com", "Lyon → Marseille — SNCF Connect"),
        ("L", "LCL", 0x00427A, "article:lclagence", "lcl.fr", "Agence LCL Bellecour"),
        ("FV", "France Victimes", 0x8B2635, "victimes", "france-victimes.fr", "France Victimes"),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Favoris").font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
                .padding(.top, 18)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 18) {
                ForEach(favoris, id: \.1) { f in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 12).fill(Color(hex: f.2))
                            .frame(width: 54, height: 54)
                            .overlay(Text(f.0).font(.system(size: 16, weight: .bold)).foregroundStyle(.white))
                        Text(f.1).font(.system(size: 11)).foregroundStyle(.white.opacity(0.85)).lineLimit(1)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); onNaviguer(f.3, f.4, f.5) }
                }
            }
            Text("Suggestions").font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
                .padding(.top, 8)
            VStack(spacing: 0) {
                ForEach(["arnaque sentimentale officier marine", "position navire MV Beaumont", "hôtel vieux port marseille"], id: \.self) { s in
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundStyle(.secondary)
                        Text(s).font(.system(size: 14.5)).foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.vertical, 11).padding(.horizontal, 12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Haptique.leger()
                        let c = CatalogueRecherches.resoudre(s)
                        onNaviguer(c.0, c.1, c.2)
                    }
                    if s != "hôtel vieux port marseille" { Divider().overlay(Color(hex: 0x3A3A3C)).padding(.leading, 12) }
                }
            }
            .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
    }
}

// Gabarit de site local (P4) : la page « Site web » de n'importe quel lieu de Plans.
struct SiteGeneriqueVue: View {
    let nom: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                LinearGradient(colors: [Color(hex: 0x2C3E50), Color(hex: 0x1A252F)], startPoint: .top, endPoint: .bottom)
                VStack(spacing: 8) {
                    Image(systemName: "storefront.fill").font(.system(size: 34)).foregroundStyle(.white.opacity(0.9))
                    Text(nom).font(.system(size: 24, weight: .bold)).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text("Lyon 1er — depuis 1987").font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 24)
            }
            .frame(height: 190)

            VStack(alignment: .leading, spacing: 14) {
                Text("Bienvenue").font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
                Text("Retrouvez-nous en plein cœur de Lyon. Notre équipe vous accueille toute la semaine et vous conseille avec plaisir.")
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.85)).lineSpacing(3)

                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "clock.fill").foregroundStyle(.secondary).frame(width: 26)
                        Text("Lun – Sam · 8h00 – 19h30").font(.system(size: 14.5)).foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(12)
                    Divider().overlay(Color(hex: 0x3A3A3C))
                    HStack {
                        Image(systemName: "mappin.circle.fill").foregroundStyle(.secondary).frame(width: 26)
                        Text("Quartier des Capucins, 69001 Lyon").font(.system(size: 14.5)).foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(12)
                }
                .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))

                Text("© \(nom) — mentions légales · plan du site")
                    .font(.system(size: 11.5)).foregroundStyle(.secondary)
                    .padding(.top, 6)
            }
            .padding(16)
        }
    }
}

// ——— En-tête de site commun (v2 Safari, point 5 : crédibilité)
struct EnTeteSite: View {
    var logo: String
    var couleur: UInt
    var domaine: String
    var fil: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Rectangle().fill(Color(hex: couleur)).frame(width: 44, height: 30)
                    .overlay(Text(logo).font(.system(size: 12, weight: .bold)).foregroundStyle(.white))
                Text(domaine).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "line.3.horizontal").font(.system(size: 16)).foregroundStyle(.secondary)
            }
            Text(fil).font(.system(size: 11.5)).foregroundStyle(.secondary)
        }
        .padding(.top, 14)
    }
}

// service-public.fr — l'onglet resté ouvert (cohérent avec P68) — étoffé v2 Safari
struct ServicePublicVue: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            EnTeteSite(logo: "RF", couleur: 0x000091, domaine: "service-public.fr",
                       fil: "Accueil › Justice › Infractions › Escroquerie")
            Text("Escroquerie sentimentale (romance scam) : que faire ?")
                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
            Text("Vérifié le 12 février 2026 — Direction de l'information légale et administrative")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Text("L'escroquerie sentimentale consiste à gagner la confiance et l'affection d'une personne pour lui soutirer de l'argent. L'escroc se fait souvent passer pour un militaire, un officier de marine ou un ingénieur travaillant à l'étranger.")
                .font(.system(size: 15.5)).foregroundStyle(.white.opacity(0.92)).lineSpacing(3)
            VStack(alignment: .leading, spacing: 8) {
                Text("Les signes qui doivent alerter").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                PuceTexte("Il ne peut jamais vous rencontrer ni faire d'appel vidéo net.")
                PuceTexte("Les demandes d'argent passent par des mandats (Western Union) ou un « agent ».")
                PuceTexte("Les sommes augmentent : frais de douane, caution, frais de change…")
                PuceTexte("Il vous demande de garder la relation secrète.")
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Que faire ?").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                PuceTexte("Cessez immédiatement tout envoi d'argent.")
                PuceTexte("Conservez toutes les preuves : messages, reçus de transfert.")
                PuceTexte("Déposez plainte et signalez sur THESEE (service-public.fr).")
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Ce que dit la loi").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                Text("L'escroquerie est punie de 5 ans d'emprisonnement et de 375 000 € d'amende (article 313-1 du Code pénal). La tentative est punissable des mêmes peines.")
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.9)).lineSpacing(3)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Où s'adresser ?").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                HStack(spacing: 10) {
                    Image(systemName: "phone.fill").font(.system(size: 13)).foregroundStyle(Color(hex: 0x000091))
                    Text("Info Escroqueries : 0 805 805 817 (gratuit, lun–ven 9h–18h30)")
                        .font(.system(size: 14)).foregroundStyle(.white.opacity(0.9))
                }
                HStack(spacing: 10) {
                    Image(systemName: "phone.fill").font(.system(size: 13)).foregroundStyle(Color(hex: 0x000091))
                    Text("France Victimes : 116 006 (gratuit, 7 j/7)")
                        .font(.system(size: 14)).foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
            Text("République Française — service-public.fr · legifrance.gouv.fr · gouvernement.fr")
                .font(.system(size: 11)).foregroundStyle(.secondary)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
    }
}

struct PuceTexte: View {
    let t: String
    init(_ t: String) { self.t = t }
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•").foregroundStyle(Color(hex: 0x6CB2FF))
            Text(t).font(.system(size: 15)).foregroundStyle(.white.opacity(0.9))
        }
    }
}

// France Victimes (v2 Safari — nouvelle page dédiée)
struct FranceVictimesVue: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            EnTeteSite(logo: "FV", couleur: 0x8B2635, domaine: "france-victimes.fr",
                       fil: "Accueil › S'informer › Escroqueries")
            Text("Arnaque aux sentiments : reconnaître les signes")
                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
            Text("La honte est l'arme principale de l'escroc : les victimes n'osent pas en parler, ce qui retarde la découverte des faits. Vous n'y êtes pour rien — ces escroqueries sont menées par des réseaux organisés et rodés.")
                .font(.system(size: 15.5)).foregroundStyle(.white.opacity(0.92)).lineSpacing(3)
            VStack(alignment: .leading, spacing: 8) {
                Text("Le scénario type").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                PuceTexte("Une déclaration d'amour très rapide, des messages quotidiens intenses.")
                PuceTexte("Un projet de rencontre sans cesse repoussé pour des raisons « professionnelles ».")
                PuceTexte("Un premier imprévu financier modeste… puis une escalade.")
                PuceTexte("Un tiers (« agent », « notaire », « douanier ») qui prend le relais pour les paiements.")
            }
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "phone.circle.fill").font(.system(size: 30)).foregroundStyle(Color(hex: 0x8B2635))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("116 006 — appel gratuit, 7 j/7").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                        Text("Une association près de chez vous peut vous accompagner, y compris pour le dépôt de plainte.")
                            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
            Text("« On croit que ça n'arrive qu'aux autres. Ça arrive à des gens intelligents, sensibles, qui avaient juste envie d'aimer. » — Témoignage recueilli par l'association")
                .font(.system(size: 14, weight: .medium)).italic().foregroundStyle(.white.opacity(0.85)).lineSpacing(3)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
    }
}

// Cybermalveillance (v2 Safari — nouvelle page dédiée)
struct CybermalveillanceVue: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            EnTeteSite(logo: "C", couleur: 0x1D4ED8, domaine: "cybermalveillance.gouv.fr",
                       fil: "Accueil › Fiches réflexes › Fraude à la romance")
            Text("Fraude à la romance : comment réagir et signaler")
                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Cessez tout contact").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Text("N'envoyez plus d'argent et ne prévenez pas l'escroc de vos démarches : il tenterait une dernière manœuvre (« l'agent » propose souvent un « remboursement » contre de nouveaux frais).")
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.9)).lineSpacing(3)
                Text("2. Conservez les preuves").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Text("Conversations, adresses e-mail, numéros de téléphone, RIB utilisés, reçus de transfert : tout peut servir à l'enquête.")
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.9)).lineSpacing(3)
                Text("3. Signalez et déposez plainte").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                Text("Signalez le profil à la plateforme de rencontre et déposez plainte en ligne via THESEE. Prévenez immédiatement votre banque : un virement très récent peut parfois faire l'objet d'une demande de rappel.")
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.9)).lineSpacing(3)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Le saviez-vous ?").font(.system(size: 14, weight: .bold)).foregroundStyle(Color(hex: 0x6CB2FF))
                Text("Les photos utilisées par les escrocs sont presque toujours volées à des tiers. Une recherche d'image inversée révèle souvent la supercherie en quelques secondes.")
                    .font(.system(size: 14)).foregroundStyle(.white.opacity(0.9)).lineSpacing(3)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
    }
}

// Forum Doctissimo (v2 Safari — nouvelle page dédiée : le témoignage miroir)
struct ForumDoctissimoVue: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            EnTeteSite(logo: "D", couleur: 0xE91E63, domaine: "forum.doctissimo.fr",
                       fil: "Forums › Psychologie › Relations")
            Text("Mon histoire : il disait être officier en mer depuis 8 mois")
                .font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
            HStack(spacing: 8) {
                Circle().fill(Color(hex: 0xE91E63)).frame(width: 30, height: 30)
                    .overlay(Text("M").font(.system(size: 14, weight: .bold)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 1) {
                    Text("Mireille62").font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                    Text("Posté le 3 mars · 214 réponses").font(.system(size: 11.5)).foregroundStyle(.secondary)
                }
                Spacer()
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Il m'appelait sa reine. Des messages magnifiques, tous les matins, tous les soirs. Il disait qu'il n'avait jamais ressenti ça. Moi non plus, je crois.")
                Text("D'abord 400 € pour « des frais de connexion satellite ». Puis 1 200 € pour la douane. Puis 4 400 € via son agent, pour débloquer sa prime de fin de mission. 6 000 € en tout.")
                Text("Le jour où il devait débarquer à Marseille, plus aucune nouvelle. Le numéro ne répondait plus. L'agent non plus.")
                Text("Si mon histoire peut éviter ça à une seule d'entre vous, alors elle aura servi. Les signes étaient là. Je ne voulais pas les voir.")
            }
            .font(.system(size: 15)).foregroundStyle(.white.opacity(0.92)).lineSpacing(3)
            Divider().overlay(Color(hex: 0x3A3A3C))
            VStack(alignment: .leading, spacing: 12) {
                ReponseForum(pseudo: "Annelise", texte: "Courage Mireille. Même schéma pour ma sœur : « officier », « agent », Marseille aussi. C'est un script, mot pour mot.")
                ReponseForum(pseudo: "Jipé54", texte: "Merci pour ce témoignage. Signalez sur THESEE, même sans espoir de récupérer : ça alimente les enquêtes.")
                ReponseForum(pseudo: "Clairette", texte: "Le coup de la prime bloquée, ils me l'ont fait aussi. J'ai arrêté à temps grâce à un post comme le vôtre. Merci.")
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
    }
}

struct ReponseForum: View {
    let pseudo: String
    let texte: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pseudo).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color(hex: 0x6CB2FF))
            Text(texte).font(.system(size: 14)).foregroundStyle(.white.opacity(0.88)).lineSpacing(2)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 10))
    }
}

// Résultats Google — générique (v2 Safari) : chaque résultat est OUVRABLE
struct ResultatsGoogleVue: View {
    let cle: String
    var onNaviguer: (String, String, String) -> Void = { _, _, _ in }
    var body: some View {
        let r = CatalogueRecherches.requetes[cle]
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Text("Google").font(.system(size: 22, weight: .semibold)).foregroundStyle(.white)
                HStack {
                    Text(r?.affichee ?? "").font(.system(size: 13)).foregroundStyle(.white).lineLimit(1)
                    Spacer()
                    Image(systemName: "xmark").font(.system(size: 11)).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10).frame(height: 34)
                .background(Color(hex: 0x303134), in: Capsule())
            }
            .padding(.top, 14)
            Text(r?.nb ?? "").font(.system(size: 12)).foregroundStyle(.secondary)
            ForEach(r?.resultats ?? []) { res in
                VStack(alignment: .leading, spacing: 4) {
                    Text(res.site).font(.system(size: 12)).foregroundStyle(.secondary)
                    Text(res.titre).font(.system(size: 17, weight: .semibold)).foregroundStyle(Color(hex: 0x6CB2FF))
                    Text(res.extrait).font(.system(size: 13.5)).foregroundStyle(.white.opacity(0.8)).lineSpacing(2)
                }
                .contentShape(Rectangle())
                .onTapGesture { Haptique.leger(); onNaviguer(res.page, res.url, res.titre) }
            }
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
    }
}

// Google sans résultat pertinent (v2 Safari, point 4 : liberté contrôlée)
struct GoogleVideVue: View {
    let requete: String
    var onNaviguer: (String, String, String) -> Void = { _, _, _ in }
    private let associees = ["arnaque sentimentale officier marine", "position navire MV Beaumont", "compagnie maritime agent OKAFOR"]
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Text("Google").font(.system(size: 22, weight: .semibold)).foregroundStyle(.white)
                HStack {
                    Text(requete).font(.system(size: 13)).foregroundStyle(.white).lineLimit(1)
                    Spacer()
                    Image(systemName: "xmark").font(.system(size: 11)).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10).frame(height: 34)
                .background(Color(hex: 0x303134), in: Capsule())
            }
            .padding(.top, 14)
            VStack(alignment: .leading, spacing: 10) {
                Text("Aucun résultat pertinent pour « \(requete) »")
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                Text("Suggestions :").font(.system(size: 13.5)).foregroundStyle(.secondary)
                PuceTexte("Vérifiez l'orthographe des mots-clés.")
                PuceTexte("Essayez des mots-clés plus généraux.")
                PuceTexte("Essayez moins de mots-clés.")
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Recherches associées").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                ForEach(associees, id: \.self) { s in
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundStyle(.secondary)
                        Text(s).font(.system(size: 14.5)).foregroundStyle(Color(hex: 0x6CB2FF))
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Haptique.leger()
                        let c = CatalogueRecherches.resoudre(s)
                        onNaviguer(c.0, c.1, c.2)
                    }
                }
            }
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
    }
}

// Article générique (v2 Safari) : rendu crédible pour tout résultat sans page dédiée
struct ArticleVue: View {
    let cle: String
    var body: some View {
        let a = ArticlesSafari.tous[cle]
        VStack(alignment: .leading, spacing: 14) {
            EnTeteSite(logo: String((a?.site.prefix(1) ?? "W")).uppercased(), couleur: 0x3B4A5A,
                       domaine: a?.site ?? "", fil: "Accueil › Article")
            Text(a?.titre ?? "").font(.system(size: 21, weight: .bold)).foregroundStyle(.white)
            Text(a?.sousTitre ?? "").font(.system(size: 13)).foregroundStyle(.secondary)
            ForEach(a?.corps ?? [], id: \.self) { p in
                Text(p).font(.system(size: 15.5)).foregroundStyle(.white.opacity(0.92)).lineSpacing(3)
            }
            Text("© \(a?.site ?? "") — tous droits réservés")
                .font(.system(size: 11)).foregroundStyle(.secondary)
                .padding(.top, 8).padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
    }
}

// Vue lecteur (v2 Safari, point 3) : texte seul, typographie de lecture
struct LecteurVue: View {
    let titre: String
    let source: String
    let corps: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(source).font(.system(size: 12.5)).foregroundStyle(.secondary)
                .padding(.top, 18)
            Text(titre).font(.system(size: 24, weight: .bold, design: .serif)).foregroundStyle(.white)
            ForEach(corps, id: \.self) { p in
                Text(p).font(.system(size: 17, design: .serif)).foregroundStyle(.white.opacity(0.94)).lineSpacing(6)
            }
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 20)
    }
}

// VesselFinder — la recherche du navire (introuvable, évidemment) — étoffé v2 Safari
struct VesselVue: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("VesselFinder").font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
                Spacer()
                Text("Live Map").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color(hex: 0x0E7490), in: Capsule())
            }
            .padding(.top, 14)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundStyle(.secondary)
                Text("MV Beaumont").font(.system(size: 14.5)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12).frame(height: 38)
            .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 10))
            RoundedRectangle(cornerRadius: 12).fill(Color(hex: 0x14202B))
                .frame(height: 220)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.circle").font(.system(size: 34)).foregroundStyle(.secondary)
                        Text("« MV Beaumont »").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        Text("Aucun navire trouvé sous ce nom").font(.system(size: 13.5)).foregroundStyle(.secondary)
                    }
                )
            Text("Vérifiez l'orthographe ou essayez avec le numéro IMO du navire. Les navires marchands en activité sont tous répertoriés : plus de 550 000 navires suivis en temps réel par AIS.")
                .font(.system(size: 13.5)).foregroundStyle(.secondary).lineSpacing(2)
            VStack(alignment: .leading, spacing: 8) {
                Text("Navires au nom proche").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                LigneNavire(nom: "BEAUMONT", type: "Remorqueur portuaire", pavillon: "🇬🇧", statut: "À quai — Southampton")
                LigneNavire(nom: "BEAUMONDE", type: "Chimiquier", pavillon: "🇲🇹", statut: "En mer — Méditerranée occ.")
                LigneNavire(nom: "MONT BEAU", type: "Cargo général", pavillon: "🇵🇦", statut: "Signal AIS perdu depuis 41 j")
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
            Text("Aucun de ces navires ne correspond à un porte-conteneurs en approche de Marseille.")
                .font(.system(size: 12.5)).italic().foregroundStyle(.secondary)
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
    }
}

struct LigneNavire: View {
    let nom: String
    let type: String
    let pavillon: String
    let statut: String
    var body: some View {
        HStack(spacing: 10) {
            Text(pavillon).font(.system(size: 20))
            VStack(alignment: .leading, spacing: 1) {
                Text(nom).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                Text(type).font(.system(size: 12)).foregroundStyle(.secondary)
            }
            Spacer()
            Text(statut).font(.system(size: 11.5)).foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// Chez Fonfon — l'onglet de l'espoir — étoffé v2 Safari
struct FonfonVue: View {
    @State private var reservationVisible = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [Color(hex: 0x2E4A6B), Color(hex: 0x14202B)], startPoint: .top, endPoint: .bottom))
                .frame(height: 170)
                .overlay(
                    VStack(spacing: 4) {
                        Text("Chez Fonfon").font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                        Text("Bouillabaisse depuis 1952 — Vallon des Auffes, Marseille")
                            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.85))
                    }
                )
                .padding(.top, 14)
            Text("Réserver une table").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(Color(hex: 0x0A84FF), in: RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
                .onTapGesture { reservationVisible = true }
            Text("Le restaurant emblématique du Vallon des Auffes vous accueille tous les jours, midi et soir. Notre bouillabaisse traditionnelle est servie en deux services, comme le veut la charte : le bouillon et ses croûtons à la rouille, puis les poissons découpés en salle.")
                .font(.system(size: 15)).foregroundStyle(.white.opacity(0.9)).lineSpacing(3)
            VStack(alignment: .leading, spacing: 0) {
                Text("La carte").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                    .padding(.bottom, 8)
                LignePlat(nom: "Bouillabaisse traditionnelle (charte)", prix: "78 €")
                LignePlat(nom: "Bourride de baudroie à l'aïoli", prix: "52 €")
                LignePlat(nom: "Poissons de petits bateaux, selon pêche", prix: "38–64 €")
                LignePlat(nom: "Soupe de poissons de roche", prix: "19 €")
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "mappin.circle.fill").foregroundStyle(.secondary).frame(width: 24)
                    Text("140 rue du Vallon des Auffes, 13007 Marseille").font(.system(size: 14)).foregroundStyle(.white)
                }
                HStack(spacing: 10) {
                    Image(systemName: "clock.fill").foregroundStyle(.secondary).frame(width: 24)
                    Text("Mardi – samedi · 12h–14h et 19h30–22h").font(.system(size: 14)).foregroundStyle(.white)
                }
                HStack(spacing: 10) {
                    Image(systemName: "star.fill").foregroundStyle(Color(hex: 0xFFD60A)).frame(width: 24)
                    Text("4,6/5 — 1 320 avis · « la vraie bouillabaisse, face aux barques »").font(.system(size: 13.5)).foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $reservationVisible) { SafariReservationVue() }
    }
}

struct LignePlat: View {
    let nom: String
    let prix: String
    var body: some View {
        HStack {
            Text(nom).font(.system(size: 14.5)).foregroundStyle(.white.opacity(0.92))
            Spacer()
            Text(prix).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(.white)
        }
        .padding(.vertical, 5)
    }
}

struct SafariReservationVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Les réservations se font par téléphone au 04 91 52 14 38.")
                        .font(.system(size: 16)).foregroundStyle(.white.opacity(0.9)).lineSpacing(3)
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill").foregroundStyle(.secondary).font(.system(size: 14))
                        Text("Ouvert du mardi au samedi, 12h–14h et 19h30–22h")
                            .font(.system(size: 14)).foregroundStyle(.secondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 14))

                Button {
                    dismiss()
                    Routeur.partage.allerTelephone("04 91 52 14 38")
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill").font(.system(size: 15))
                        Text("Appeler le restaurant").font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Color(hex: 0x30D158), in: RoundedRectangle(cornerRadius: 14))
                }

                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: 0x1C1C1E).ignoresSafeArea())
            .navigationTitle("Réservations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// État d'erreur réseau (réel iOS)
struct ErreurSafariVue: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 120)
            Text("Safari ne parvient pas à ouvrir la page")
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("Le serveur est introuvable. Vérifiez la connexion Internet et réessayez.")
                .font(.system(size: 14)).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

// ============================================================ ONGLETS (v2 Safari : réels)
struct OngletsVue: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var onglets: [OngletSafari]
    @Binding var ongletsPrives: [OngletSafari]
    @Binding var modePrive: Bool
    let ouvrir: (OngletSafari) -> Void
    let nouveau: () -> Void
    let fermer: (OngletSafari) -> Void
    @State private var priveDeverrouille = false

    private var liste: [OngletSafari] { modePrive ? ongletsPrives : onglets }
    private var titreCompte: String { "\(liste.count) onglet\(liste.count > 1 ? "s" : "")" }

    var body: some View {
        NavigationStack {
            if modePrive && (!priveDeverrouille || ongletsPrives.isEmpty) {
                // Navigation privée : verrouillée puis vide — le « + » y est RÉEL aussi
                VStack(spacing: 14) {
                    Spacer()
                    if priveDeverrouille {
                        Image(systemName: "square.on.square").font(.system(size: 40)).foregroundStyle(.secondary)
                        Text("Aucun onglet privé").font(.system(size: 18, weight: .semibold)).foregroundStyle(.white)
                    } else {
                        Image(systemName: "lock.fill").font(.system(size: 40)).foregroundStyle(.secondary)
                        Text("La navigation privée est verrouillée")
                            .font(.system(size: 16)).foregroundStyle(.white.opacity(0.9))
                        Button { Haptique.leger(); priveDeverrouille = true } label: {
                            Text("Déverrouiller").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                                .padding(.horizontal, 18).padding(.vertical, 9)
                                .background(Color(hex: 0x0A84FF), in: Capsule())
                        }
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        Button {
                            if priveDeverrouille { nouveau() } else { Haptique.leger(); priveDeverrouille = true }
                        } label: {
                            Image(systemName: "plus").font(.system(size: 18)).foregroundStyle(.white)
                                .frame(width: 44, height: 44).background(Color(hex: 0x38385C), in: Circle())
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Text("Privée").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(Color(hex: 0x4A4A70), in: Capsule())
                            Text("\(onglets.count) onglet\(onglets.count > 1 ? "s" : "")")
                                .font(.system(size: 14)).foregroundStyle(.white.opacity(0.7))
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .contentShape(Capsule())
                                .onTapGesture { modePrive = false }
                        }
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "checkmark").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                                .frame(width: 44, height: 44).background(Color(hex: 0x38385C), in: Circle())
                        }
                    }
                    .padding(.horizontal, 18).padding(.bottom, 14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LinearGradient(colors: [Color(hex: 0x2A2438), Color(hex: 0x161320)], startPoint: .top, endPoint: .bottom))
            } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 14) {
                    ForEach(liste) { o in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text(o.titre).font(.system(size: 11, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                                Spacer()
                                // v2 Safari : la croix FERME vraiment l'onglet
                                Button { fermer(o) } label: {
                                    Image(systemName: "xmark").font(.system(size: 9)).foregroundStyle(.secondary)
                                        .frame(width: 22, height: 22)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.leading, 8).padding(.vertical, 4)
                            .background(Color(hex: modePrive ? 0x38385C : 0x3A3A3C))
                            RoundedRectangle(cornerRadius: 0).fill(Color(hex: 0x1C1C1E))
                                .frame(height: 130)
                                .overlay(
                                    VStack(spacing: 5) {
                                        Image(systemName: o.page == "demarrage" ? "star" : "globe")
                                            .font(.system(size: 24)).foregroundStyle(.secondary)
                                        Text(o.url.isEmpty ? "Page de démarrage" : o.url)
                                            .font(.system(size: 11)).foregroundStyle(.secondary)
                                    }
                                )
                                .contentShape(Rectangle())
                                .onTapGesture { ouvrir(o) }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(16)
            }
            .background(modePrive
                        ? Color(hex: 0x1D1A28)
                        : Color(hex: 0x1C1C1E))
            .overlay(alignment: .bottom) {
                HStack {
                    Spacer()
                    Text(modePrive ? "Onglets" : "Privée").font(.system(size: 14)).foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Color(hex: 0x2C2C2E), in: Capsule())
                        .contentShape(Capsule())
                        .onTapGesture { Haptique.leger(); modePrive.toggle() }
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .navigationTitle(titreCompte)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // v2 Safari : le « + » OUVRE vraiment un nouvel onglet
                    Button { nouveau() } label: {
                        Image(systemName: "plus").foregroundStyle(Color(hex: 0x0A84FF))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ HISTORIQUE (le composant d'enquête)
// ============================================================ v2 02/09 — SIGNETS (Favoris / Liste de lecture / Historique)
struct SignetsSafariVue: View {
    @Environment(\.dismiss) private var dismiss
    var ouvrirPage: (String, String, String) -> Void
    var ouvrirHistorique: (EntreeHistorique) -> Void
    @State private var onglet = 0
    // Favoris de Sarah (mêmes que la page de démarrage) + dossiers
    private let favoris: [(String, UInt, String, String, String)] = [
        ("service-public — Escroquerie sentimentale", 0x000091, "servicepublic", "service-public.fr", "Escroquerie sentimentale : que faire ?"),
        ("VesselFinder — MV Beaumont", 0x0E7490, "vessel", "vesselfinder.com", "MV Beaumont — VesselFinder"),
        ("Chez Fonfon — Marseille", 0x1E5B8A, "fonfon", "chez-fonfon.com", "Chez Fonfon — Marseille"),
        ("SNCF Connect — Lyon → Marseille", 0x6E1E78, "article:sncf", "sncf-connect.com", "Lyon → Marseille — SNCF Connect"),
        ("LCL — Agence Bellecour", 0x00427A, "article:lclagence", "lcl.fr", "Agence LCL Bellecour"),
        ("France Victimes", 0x8B2635, "victimes", "france-victimes.fr", "France Victimes"),
    ]
    // Liste de lecture : ce que Sarah a mis de côté (or narratif en creux)
    private let lecture: [(String, String, String, String, String)] = [
        ("Arnaque aux sentiments : les 7 signes qui doivent alerter", "france-victimes.fr", "victimes", "france-victimes.fr", "Arnaque aux sentiments — France Victimes"),
        ("Il disait être officier en mer — témoignage", "forum.doctissimo.fr", "forum", "forum.doctissimo.fr", "Il disait être officier en mer — Doctissimo"),
        ("Chez Fonfon — réserver une table", "chez-fonfon.com", "fonfon", "chez-fonfon.com", "Chez Fonfon — Marseille"),
    ]
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $onglet) {
                    Image(systemName: "book").tag(0)
                    Image(systemName: "eyeglasses").tag(1)
                    Image(systemName: "clock").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
                switch onglet {
                case 1:
                    List {
                        ForEach(0..<lecture.count, id: \.self) { i in
                            let l = lecture[i]
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8).fill(Color(hex: 0x3A3A3C)).frame(width: 52, height: 40)
                                    .overlay(Image(systemName: "doc.text").foregroundStyle(.secondary))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(l.0).font(.system(size: 15)).foregroundStyle(.white).lineLimit(2)
                                    Text(l.1).font(.system(size: 12.5)).foregroundStyle(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { ouvrirPage(l.2, l.3, l.4) }
                            .listRowBackground(Color(hex: 0x2C2C2E))
                        }
                    }
                    .scrollContentBackground(.hidden).background(Color(hex: 0x1C1C1E))
                    .navigationTitle("Liste de lecture")
                case 2:
                    HistoriqueContenuVue(ouvrir: ouvrirHistorique)
                        .navigationTitle("Historique")
                default:
                    List {
                        Section {
                            ForEach(0..<favoris.count, id: \.self) { i in
                                let f = favoris[i]
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 7).fill(Color(hex: f.1)).frame(width: 30, height: 30)
                                        .overlay(Text(String(f.0.prefix(1))).font(.system(size: 13, weight: .bold)).foregroundStyle(.white))
                                    Text(f.0).font(.system(size: 15)).foregroundStyle(.white).lineLimit(1)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture { ouvrirPage(f.2, f.3, f.4) }
                                .listRowBackground(Color(hex: 0x2C2C2E))
                            }
                        } header: { Text("Favoris").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary).textCase(nil) }
                    }
                    .scrollContentBackground(.hidden).background(Color(hex: 0x1C1C1E))
                    .navigationTitle("Signets")
                }
            }
            .background(Color(hex: 0x1C1C1E))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Contenu de l'historique réutilisable (sans sa propre NavigationStack)
struct HistoriqueContenuVue: View {
    var ouvrir: (EntreeHistorique) -> Void
    @State private var recherche = ""
    private func couleurDomaine(_ url: String) -> UInt {
        switch true {
        case url.contains("google"): return 0x4285F4
        case url.contains("vessel"): return 0x0E7490
        case url.contains("service-public"): return 0x000091
        case url.contains("victimes"): return 0x8B2635
        case url.contains("fonfon"): return 0x1E5B8A
        case url.contains("sncf"): return 0x6E1E78
        default: return 0x5A5A5E
        }
    }
    private func entrees(_ section: String) -> [EntreeHistorique] {
        var l = DonneesSafari.historique.filter { $0.section == section }
        if !recherche.isEmpty { l = l.filter { $0.titre.localizedCaseInsensitiveContains(recherche) } }
        return l
    }
    var body: some View {
        List {
            ForEach(DonneesSafari.sectionsHistorique, id: \.self) { section in
                let items = entrees(section)
                if !items.isEmpty {
                    Section {
                        ForEach(items) { e in
                            HStack(spacing: 10) {
                                Circle().fill(Color(hex: couleurDomaine(e.url))).frame(width: 26, height: 26)
                                    .overlay(Text(String(e.url.prefix(1)).uppercased()).font(.system(size: 12, weight: .bold)).foregroundStyle(.white))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(e.titre).font(.system(size: 15)).foregroundStyle(.white).lineLimit(2)
                                    Text("\(e.url) · \(e.heure)").font(.system(size: 12.5)).foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture { ouvrir(e) }
                            .listRowBackground(Color(hex: 0x2C2C2E))
                        }
                    } header: {
                        Text(section).font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary).textCase(nil)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(hex: 0x1C1C1E))
        .searchable(text: $recherche, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher l'historique")
    }
}

struct HistoriqueSafariVue: View {
    @Environment(\.dismiss) private var dismiss
    var ouvrir: (EntreeHistorique) -> Void = { _ in }
    @State private var recherche = ""

    private func couleurDomaine(_ url: String) -> UInt {
        switch true {
        case url.contains("google"): return 0x4285F4
        case url.contains("vessel"): return 0x0E7490
        case url.contains("service-public"): return 0x000091
        case url.contains("victimes"): return 0x8B2635
        case url.contains("fonfon"): return 0x1E5B8A
        case url.contains("sncf"): return 0x6E1E78
        default: return 0x5A5A5E
        }
    }

    private func entrees(_ section: String) -> [EntreeHistorique] {
        var l = DonneesSafari.historique.filter { $0.section == section }
        if !recherche.isEmpty {
            l = l.filter { $0.titre.localizedCaseInsensitiveContains(recherche) }
        }
        return l
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(DonneesSafari.sectionsHistorique, id: \.self) { section in
                    let items = entrees(section)
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { e in
                                HStack(spacing: 10) {
                                    // Miroir lot 3 : favicon coloré par domaine (référence v12)
                                    Circle().fill(Color(hex: couleurDomaine(e.url)))
                                        .frame(width: 26, height: 26)
                                        .overlay(Text(String(e.url.prefix(1)).uppercased())
                                            .font(.system(size: 12, weight: .bold)).foregroundStyle(.white))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(e.titre).font(.system(size: 15)).foregroundStyle(.white).lineLimit(2)
                                        Text("\(e.url) · \(e.heure)").font(.system(size: 12.5)).foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture { ouvrir(e) }
                                .listRowBackground(Color(hex: 0x2C2C2E))
                            }
                        } header: {
                            Text(section).font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary).textCase(nil)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0x1C1C1E))
            .searchable(text: $recherche, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher l'historique")
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // v2 02/09 : bouton « Effacer » RETIRÉ (demande Joachim — l'historique peut porter des indices)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
