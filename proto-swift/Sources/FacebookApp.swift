// Facebook — v3 D91 (03/09) — reconstruit contre les 159 frames de Joachim, mesures audit/facebook.md
//
// Doctrines appliquées :
//  · D67 — la référence est l'enregistrement de Joachim (refs/t2/facebook/e001…e159, 1 pt = 1,5 px).
//           Tout ce qui n'a pas été filmé n'est PAS inventé : soit retiré, soit rendu sobre et
//           annoté « TODO tournage ».
//  · D82 — aucun bouton mort : chaque commande agit (A), répond par un message iOS crédible (B, rare),
//           ou a été retirée (C). Les retraits sont annotés « (C) » dans le code.
//  · D59 — contenu Sarah remplaçable (Lyon, Chloé Berthier, Sylvie Lavisse côté nom Facebook).
//           Marc n'apparaît NULLE PART sur Facebook : son absence est l'indice.
//
// Corrections majeures par rapport à la v1 auditée :
//  · 6ᵉ onglet = PROFIL (avatar), plus « Menu ».
//  · Le Menu est un TIROIR latéral gauche (358 pt) ouvert par ☰, présent sur les 5 onglets.
//  · Nouvel écran le plus filmé du corpus : FbPostDetailVue (post + commentaires, PLEINE PAGE poussée).
//  · Nouvelle feuille de partage fidèle à e021.
//  · Suppression du bug bloquant : la notification n'ouvre plus un 2ᵉ fil en fullScreenCover.
//  · Suppression du composeur plein écran inventé, des 3 feuilles « bientôt disponible »,
//    de la grille de raccourcis du Menu, du badge « 8 » inventé sur Messenger.
//
// Points d'entrée publics : FacebookVue() (racine appelée par la coque, LPProto l. 145) et les vues
// citées par EcranCapture.ecransFacebook() (registre mis à jour — cf. src/patches/facebook-lpproto.md).
import SwiftUI
import UIKit

// ============================================================================
// MARK: - 1. JETONS DE STYLE (§2.1 de l'audit — échantillonnés au pixel)
// ============================================================================

enum FbStyle {
    static let bleu         = Color(hex: 0x0C59FD)   // e147 (20 103 px), e130 (20 077 px)
    static let rouge        = Color(hex: 0xDF1C2D)   // badge Reels (e001)
    static let grisBouton   = Color(hex: 0xDCE0E3)   // Supprimer, Voir plus (e130, e103)
    static let pillBleu     = Color(hex: 0xD2E7FC)   // pill « Découvrir » / « Tous » (e147, e155)
    static let nonLu        = Color(hex: 0xE2EEFE)   // bloc continu des notifications (e152)
    static let filetBloc    = Color(hex: 0xC1C0C6)   // bande 4 pt entre deux blocs du fil (e001)
    static let fond         = Color.white            // #FEFEFE partout, Menu et Groupes inclus
    static let barreReels   = Color(hex: 0x202020)   // barre d'onglets sombre sur Reels (e112)
    static let champ        = Color(hex: 0xEFEFEF)   // capsule « Commentez… » (e015)
    static let texteGris    = Color(hex: 0x65676B)   // horodatages, sous-titres
    static let sepFin       = Color(hex: 0xE4E6EB)   // hairlines de carte
    static let bandeauSpons = Color(hex: 0xF0F1F3)   // bandeau APP STORE des posts sponsorisés (e003)
    static let vertBadge    = Color(hex: 0x1E7B34)   // badge horaire vert sur avatar (e130)
    static let vertBadgeFd  = Color(hex: 0xE8F3EA)

    static let margeH: CGFloat = 13                  // marge horizontale du fil (19 px)
    static let hauteurBarre: CGFloat = 52            // barre d'onglets hors BarreHome
}

// ============================================================================
// MARK: - 2. MODÈLE
// ============================================================================

struct FbSegment {
    let texte: String
    var gras: Bool = false
}

struct FbCommentaire: Identifiable {
    let id: String
    var auteur: String
    var photo: String? = nil
    var teinte: UInt = 0xB0B3B8
    var date: String
    var mention: String? = nil        // « Mathieu Guerin » en bleu en tête de texte (e015)
    var texte: String
    var likes: Int = 0
    var reponses: Int = 0
    var estAuteur: Bool = false       // pastille « ✎ Auteur » (e122)
}

struct FbPost: Identifiable {
    let id: String
    var auteur: String
    var photoAuteur: String? = nil
    var teinteAuteur: UInt = 0x0C59FD
    var verifie: Bool = false
    var suivre: Bool = false           // « · Suivre » en lien bleu à côté du nom
    var rejoindre: Bool = false        // post de groupe : « · Rejoindre » à la place de « Suivre »
    var sousLigne: String? = nil       // post de groupe : « Ghislaine Lacan · 3 h »
    var horaire: String = "5 h"
    var confidentialite: String = "globe.americas.fill"
    var sponsorise: Bool = false
    var texte: String
    var lien: String? = nil
    var photos: [String] = []
    var ratio: CGFloat = 1.0           // hauteur = largeur / ratio
    var bandeauTitre: String? = nil    // titre blanc incrusté sur l'image d'un post de lien (e011)
    var ctaBoutique: String? = nil     // « APP STORE » (e003)
    var ctaTexte: String? = nil
    var ctaBouton: String? = nil       // « Installer »
    var reactions: [String] = ["👍"]
    var nbReactions: Int = 0
    var nbCommentaires: Int = 0
    var nbPartages: Int = 0
    var estLien: Bool = false          // 4ᵉ bouton « Enregistrer »
    var commentaires: [FbCommentaire] = []
}

enum FbBlocFil: Identifiable {
    case post(FbPost)
    case reels
    case suggestionsAmis
    case groupeSuggere

    var id: String {
        switch self {
        case .post(let p): return "post-" + p.id
        case .reels: return "bloc-reels"
        case .suggestionsAmis: return "bloc-amis"
        case .groupeSuggere: return "bloc-groupe"
        }
    }
}

struct FbPersonne: Identifiable {
    let id: String
    var nom: String
    var photo: String? = nil
    var teinte: UInt = 0xB0B3B8
    var detail: String? = nil          // « Suivi(e) par 191 personnes »
    var badgeHoraire: String? = nil    // pill verte sur l'avatar (e130)
    var anciennete: String? = nil      // « 4 a » à droite de la ligne du nom
    var nbAmis: String = "76"
    var nbPublications: String = "42"
    var ville: String = "Lyon"
}

struct FbGroupe: Identifiable {
    let id: String
    var nom: String
    var detail: String
    var image: String
}

struct FbNotif: Identifiable {
    let id: String
    var photo: String? = nil
    var teinte: UInt = 0xB0B3B8
    var badge: String                  // glyphe SF du badge bleu de type (e152)
    var segments: [FbSegment]
    var horaire: String
    var postCible: String? = nil       // identifiant du post ouvert au tap (jamais un 2ᵉ fil)
}

struct FbStoryTuile: Identifiable {
    let id: String
    var titre: String
    var image: String
    var badge: String?                 // pastille ronde de la Page en haut à gauche
    var sousTitre: String              // « Suggestions »
}

struct FbReel: Identifiable {
    let id: String
    var image: String
    var page: String
    var pageTeinte: UInt
    var legende: String
    var audio: String
    var jaime: Int
    var commentaires: Int
    var partages: Int
    var enregistrements: Int
    var fils: [FbCommentaire]
}

// ============================================================================
// MARK: - 3. DONNÉES SARAH (D59 — Lyon, Chloé, Sylvie Lavisse ; aucun Marc)
// ============================================================================

enum DonneesFb {

    static let moiNom = "Sarah Levasseur"
    static let moiPhoto = "p04"

    // ---------------------------------------------------------------- posts

    static let postVille = FbPost(
        id: "ville",
        auteur: "Lyon Ma Ville",
        teinteAuteur: 0x0C59FD,
        verifie: true,
        suivre: true,
        horaire: "5 h",
        texte: "L'été indien s'installe sur les quais du Rhône 🌇 Les berges sont bondées depuis midi, les terrasses des péniches affichent complet et la Guillotière a sorti les tables sur le trottoir. Profitez-en ce week-end : la météo annonce 27 °C dimanche, et la Ville rouvre la baignade surveillée au parc de la Feyssine.",
        photos: ["p36", "p31"],
        ratio: 1.0,
        reactions: ["😮", "👍", "❤️"],
        nbReactions: 597,
        nbCommentaires: 36,
        nbPartages: 12,
        commentaires: [
            FbCommentaire(id: "v1", auteur: "Gaëlle Capitaine", photo: "p22", date: "3 h",
                          texte: "On y était hier soir, magique 😍", likes: 12),
            FbCommentaire(id: "v2", auteur: "Aurore Dauriac", teinte: 0xE64980, date: "4 h",
                          mention: "Chloé Berthier", texte: "on se refait les quais dimanche ?", likes: 3, reponses: 2),
            FbCommentaire(id: "v3", auteur: "Francis Baron", teinte: 0x5B7CFA, date: "5 h",
                          texte: "Et les vélos sur la piste piétonne, personne n'en parle…", likes: 8),
            FbCommentaire(id: "v4", auteur: "Paulette Vinot", teinte: 0xFF9F0A, date: "5 h",
                          texte: "Superbe photo, bravo au photographe 👏", likes: 2)
        ])

    static let postDeblock = FbPost(
        id: "deblock",
        auteur: "Déblock — Application bancaire",
        teinteAuteur: 0x1C1C1E,
        horaire: "Sponsorisée",
        sponsorise: true,
        texte: "Ta carte VISA, ton IBAN et tes cryptos, dans le compte courant #1",
        photos: ["p24"],
        ratio: 1.0,
        ctaBoutique: "APP STORE",
        ctaTexte: "Inscription gratuite et instantanée. ⚡",
        ctaBouton: "Installer",
        reactions: ["👍"],
        nbReactions: 597,
        nbCommentaires: 36,
        nbPartages: 1,
        commentaires: [
            FbCommentaire(id: "d1", auteur: "Sofiane Belkacem", teinte: 0x30D1C4, date: "2 j",
                          texte: "Attention aux frais cachés, lisez les CGV avant.", likes: 41),
            FbCommentaire(id: "d2", auteur: "Marie-Pierre Fourez", teinte: 0xE64980, date: "1 j",
                          texte: "J'ai jamais reçu la carte au bout de 3 semaines.", likes: 17)
        ])

    static let postPoterie = FbPost(
        id: "poterie",
        auteur: "Atelier Poterie Lyon 3",
        teinteAuteur: 0xFF9F0A,
        suivre: true,
        horaire: "1 j",
        texte: "Les inscriptions de septembre sont ouvertes ! Cours du mardi et du jeudi soir, tous niveaux, tour et modelage 🏺 Réservation par message, il reste 4 places au mardi 19 h.",
        photos: ["p33"],
        ratio: 1.0,
        reactions: ["👍", "❤️"],
        nbReactions: 118,
        nbCommentaires: 23,
        nbPartages: 4,
        commentaires: [
            FbCommentaire(id: "p1", auteur: "Chloé Berthier", photo: "p12", date: "1 j",
                          texte: "Je m'inscris au mardi, je viens avec Sarah 🙌", likes: 6),
            FbCommentaire(id: "p2", auteur: "Inès Djellal", photo: "p22", teinte: 0x8E44AD, date: "22 h",
                          texte: "Il reste de la place au jeudi ?", likes: 1, reponses: 1),
            FbCommentaire(id: "p3", auteur: "Léa Moreau", photo: "p18", teinte: 0x30D1C4, date: "20 h",
                          texte: "Le tour c'est vraiment accessible aux débutantes ?", likes: 4)
        ])

    static let postGroupe = FbPost(
        id: "retouches",
        auteur: "Retouches photos Lyon — Entraide",
        teinteAuteur: 0x8E44AD,
        rejoindre: true,
        sousLigne: "Ghislaine Lacan · 3 h",
        horaire: "3 h",
        texte: "Bonsoir, quelqu'un saurait ouvrir les boutons de la veste de mon fils sur la photo svp, merci 🙏",
        photos: ["p30"],
        ratio: 0.75,
        reactions: ["👍"],
        nbReactions: 24,
        nbCommentaires: 9,
        nbPartages: 0,
        commentaires: [
            FbCommentaire(id: "r1", auteur: "Didier Ovenberghe", teinte: 0x5B7CFA, date: "2 h",
                          texte: "Envoyé en message privé 👍", likes: 3),
            FbCommentaire(id: "r2", auteur: "Amélie Lalanne", teinte: 0xE64980, date: "1 h",
                          texte: "Joli travail sur la lumière, ça rend bien.", likes: 1)
        ])

    static let postLien = FbPost(
        id: "progres",
        auteur: "Le Progrès de Lyon",
        teinteAuteur: 0xDF1C2D,
        verifie: true,
        suivre: true,
        horaire: "3 j",
        texte: "Un cycliste de 22 ans grièvement blessé sur le pont Wilson : le jeune homme héliporté en pleine nuit vers Édouard-Herriot, deux autres blessés hospitalisés à Villeurbanne",
        lien: "https://l.leprogres.fr/lu8X",
        photos: ["p31"],
        ratio: 1.35,
        bandeauTitre: "Un cycliste de 22 ans grièvement blessé sur le pont Wilson…",
        reactions: ["😢", "👍", "😮"],
        nbReactions: 118,
        nbCommentaires: 23,
        nbPartages: 23,
        estLien: true,
        commentaires: [
            FbCommentaire(id: "l1", auteur: "Gaëlle Capitaine", photo: "p22", date: "3 j",
                          texte: "Courage à la famille", likes: 3),
            FbCommentaire(id: "l2", auteur: "Aurore Dauriac", teinte: 0xE64980, date: "2 j",
                          mention: "Mathieu Guerin", texte: "il y a eu ça aussi ....."),
            FbCommentaire(id: "l3", auteur: "Francis Baron", teinte: 0x5B7CFA, date: "2 j",
                          texte: "Par pitié, gardez vos commentaires nauséabonds. Dans pareil cas, la famille n'a pas besoin d'être « enfoncée » et qui sait (sans vous le souhaiter), ça peut vous arriver demain.",
                          likes: 16),
            FbCommentaire(id: "l4", auteur: "Paulette Vinot", teinte: 0xFF9F0A, date: "3 j",
                          texte: "Beaucoup trop d'accidents sur les quais 🙏 Vitesse, alcool, inconscience également.",
                          likes: 8, reponses: 1),
            FbCommentaire(id: "l5", auteur: "Karine Cabrero", teinte: 0x30D1C4, date: "3 j",
                          texte: "J'ai lu brièvement l'article, ce serait les pompiers de Caluire qui sont arrivés les premiers.",
                          likes: 2)
        ])

    // Vecteur narratif de l'arnaque (e003/e004 : « Un gain de 500 € vous appelle », « Accepter »).
    static let postGain = FbPost(
        id: "gain",
        auteur: "Gains Express",
        teinteAuteur: 0x2E7D32,
        horaire: "Sponsorisée",
        sponsorise: true,
        texte: "Un gain de 500 € vous appelle… Ouvrez un compte et restez actif pendant 7 jours consécutifs pour tenter de gagner jusqu'à 500 €. Voir CGV.",
        photos: ["p26"],
        ratio: 1.0,
        bandeauTitre: "Un gain de 500 € vous appelle…",
        ctaBoutique: "APP STORE",
        ctaTexte: "Inscription gratuite et instantanée. ⚡",
        ctaBouton: "Accepter",
        reactions: ["😮", "👍"],
        nbReactions: 4756,
        nbCommentaires: 502,
        nbPartages: 270,
        commentaires: [
            FbCommentaire(id: "g1", auteur: "Evelyne Guitonneau", teinte: 0xE64980, date: "6 j",
                          texte: "J'ai « gagné » et on m'a demandé mes coordonnées bancaires. Fuyez.", likes: 214),
            FbCommentaire(id: "g2", auteur: "Seb Cbien", teinte: 0x5B7CFA, date: "5 j",
                          texte: "Encore une arnaque, signalez la page.", likes: 96, reponses: 13)
        ])

    static let postChloe = FbPost(
        id: "chloe",
        auteur: "Chloé Berthier",
        photoAuteur: "p12",
        teinteAuteur: 0xE64980,
        horaire: "9 j",
        confidentialite: "person.2.fill",
        texte: "Week-end parfait au bord du lac avec la meilleure 💙",
        photos: ["p30", "p18"],
        ratio: 1.0,
        reactions: ["❤️", "👍"],
        nbReactions: 87,
        nbCommentaires: 14,
        nbPartages: 1,
        commentaires: [
            FbCommentaire(id: "c1", auteur: "Sarah Levasseur", photo: "p04", teinte: 0x5B7CFA, date: "9 j",
                          texte: "La meilleure c'est toi 💙", likes: 5),
            FbCommentaire(id: "c2", auteur: "Léa Moreau", photo: "p18", teinte: 0x30D1C4, date: "8 j",
                          texte: "Vous m'avez trop manqué les filles", likes: 2),
            FbCommentaire(id: "c3", auteur: "Julie Ferrand", teinte: 0xFF9F0A, date: "8 j",
                          texte: "Il est où ce lac ?? 😍", likes: 1, reponses: 3)
        ])

    static let posts: [FbPost] = [postVille, postDeblock, postPoterie, postGroupe, postLien, postGain, postChloe]

    static func post(_ id: String) -> FbPost {
        posts.first(where: { $0.id == id }) ?? postVille
    }

    static let blocs: [FbBlocFil] = [
        .post(postVille),
        .post(postDeblock),
        .reels,
        .post(postPoterie),
        .post(postGroupe),
        .suggestionsAmis,
        .post(postLien),
        .post(postGain),
        .groupeSuggere,
        .post(postChloe)
    ]

    // ---------------------------------------------------------------- stories (e001, e108)

    static let stories: [FbStoryTuile] = [
        FbStoryTuile(id: "s1", titre: "Le Bouchon des Terreaux", image: "p33", badge: "p33", sousTitre: "Suggestions"),
        FbStoryTuile(id: "s2", titre: "Studio Photo Croix-Rousse", image: "p26", badge: "p26", sousTitre: "Suggestions"),
        FbStoryTuile(id: "s3", titre: "Les Bâtisseurs du Vieux Lyon", image: "p31", badge: "p31", sousTitre: "Suggestions"),
        FbStoryTuile(id: "s4", titre: "Chloé Berthier", image: "p12", badge: nil, sousTitre: "il y a 5 h")
    ]

    // ---------------------------------------------------------------- personnes

    static let suggestionsFil: [FbPersonne] = [
        FbPersonne(id: "sf1", nom: "Marie-Pierre Fourez", teinte: 0xE64980),
        FbPersonne(id: "sf2", nom: "Manue Tempier", teinte: 0xE64980),
        FbPersonne(id: "sf3", nom: "Farouq Rana", teinte: 0x5B7CFA),
        FbPersonne(id: "sf4", nom: "Aurea Aurea", teinte: 0x30D1C4),
        FbPersonne(id: "sf5", nom: "Hafeez Ahmad", teinte: 0xFF9F0A)
    ]

    static let invitations: [FbPersonne] = [
        FbPersonne(id: "i1", nom: "Marie-Pierre Fourez", teinte: 0xE64980,
                   badgeHoraire: "2 h", anciennete: "4 a", nbAmis: "312", nbPublications: "18"),
        FbPersonne(id: "i2", nom: "Dorian Delzers", teinte: 0x5B7CFA, detail: "Suivi(e) par 191 personnes",
                   badgeHoraire: "1 h", anciennete: "1 a", nbAmis: "191", nbPublications: "64"),
        FbPersonne(id: "i3", nom: "Christiane Damotte", teinte: 0xFF9F0A,
                   badgeHoraire: "3 h", anciennete: "3 a", nbAmis: "88", nbPublications: "7"),
        FbPersonne(id: "i4", nom: "Seb Cbien", teinte: 0x30D1C4,
                   badgeHoraire: "33 min", anciennete: "4 a", nbAmis: "540", nbPublications: "129"),
        FbPersonne(id: "i5", nom: "Evelyne Guitonneau", teinte: 0x8E44AD,
                   badgeHoraire: "42 min", anciennete: "2 a", nbAmis: "76", nbPublications: "42")
    ]

    static let connaissezPeutEtre: [FbPersonne] = [
        FbPersonne(id: "c1", nom: "Manue Tempier", teinte: 0xE64980),
        FbPersonne(id: "c2", nom: "Sara-Marie Le Richeux", teinte: 0x8E44AD),
        FbPersonne(id: "c3", nom: "Tania LaQuinny", teinte: 0x30D1C4, detail: "Suivi(e) par 7,8 K personnes"),
        FbPersonne(id: "c4", nom: "Rifatul Islam", teinte: 0x5B7CFA),
        FbPersonne(id: "c5", nom: "Mohammad Sami", teinte: 0xFF9F0A, detail: "Suivi(e) par 3,3 K personnes")
    ]

    static let vosAmis: [FbPersonne] = [
        FbPersonne(id: "a1", nom: "Chloé Berthier", photo: "p12", teinte: 0xE64980),
        FbPersonne(id: "a2", nom: "Inès Djellal", photo: "p22", teinte: 0x8E44AD),
        FbPersonne(id: "a3", nom: "Léa Moreau", photo: "p18", teinte: 0x30D1C4),
        FbPersonne(id: "a4", nom: "Julie Ferrand", teinte: 0xFF9F0A),
        FbPersonne(id: "a5", nom: "Sylvie Lavisse", teinte: 0xE8A0A0)
    ]

    static let personnes: [FbPersonne] = invitations + connaissezPeutEtre + vosAmis

    static func personne(_ nom: String) -> FbPersonne {
        personnes.first(where: { $0.nom == nom })
            ?? FbPersonne(id: "inconnu", nom: nom, teinte: 0xB0B3B8)
    }

    // ---------------------------------------------------------------- groupes (e147)

    static let groupes: [FbGroupe] = [
        FbGroupe(id: "g1", nom: "Lyon 3e — Entre voisins", detail: "Groupe (Privé) · 8,9 K\nmembres", image: "p36"),
        FbGroupe(id: "g2", nom: "Céramique & Poterie France", detail: "Groupe (Public) · 24 K\nmembres", image: "p33"),
        FbGroupe(id: "g3", nom: "Randos autour de Lyon", detail: "Groupe (Public) · 11 K\nmembres", image: "p31"),
        FbGroupe(id: "g4", nom: "Vide-dressing Lyon", detail: "Groupe (Privé) · 3,4 K\nmembres", image: "p24"),
        FbGroupe(id: "g5", nom: "Retouches photos Lyon — Entraide", detail: "Groupe (Public) · 20 K\nmembres", image: "p30"),
        FbGroupe(id: "g6", nom: "Bons plans Lyon & alentours", detail: "Groupe (Privé) · 26 K\nmembres", image: "p26")
    ]

    // ---------------------------------------------------------------- notifications (e152, forme filmée)

    static let notifications: [FbNotif] = [
        FbNotif(id: "n1", photo: "p12", teinte: 0xE64980, badge: "person.fill.viewfinder",
                segments: [FbSegment(texte: "Vous avez de nouvelles suggestions d'ami(e)s : "),
                           FbSegment(texte: "Chloé Berthier", gras: true), FbSegment(texte: ", "),
                           FbSegment(texte: "Inès Djellal", gras: true),
                           FbSegment(texte: " et 12 autres personnes.")],
                horaire: "2 j"),
        FbNotif(id: "n2", teinte: 0x8E44AD, badge: "person.fill.viewfinder",
                segments: [FbSegment(texte: "Vous avez de nouvelles suggestions d'ami(e)s : "),
                           FbSegment(texte: "Marie-Pierre Fourez", gras: true), FbSegment(texte: ", "),
                           FbSegment(texte: "Dorian Delzers", gras: true),
                           FbSegment(texte: " et 27 autres personnes.")],
                horaire: "1 sem"),
        FbNotif(id: "n3", photo: "p04", teinte: 0x5B7CFA, badge: "f.square.fill",
                segments: [FbSegment(texte: "Remaniez votre souvenir de septembre 2021")],
                horaire: "1 sem"),
        FbNotif(id: "n4", photo: "p33", teinte: 0xFF9F0A, badge: "bell.fill",
                segments: [FbSegment(texte: "Atelier Poterie Lyon 3", gras: true),
                           FbSegment(texte: " a publié : « Les inscriptions de septembre sont ouvertes ! »")],
                horaire: "1 j", postCible: "poterie"),
        FbNotif(id: "n5", photo: "p36", teinte: 0x0C59FD, badge: "person.2.fill",
                segments: [FbSegment(texte: "Comme vous avez interagi avec "),
                           FbSegment(texte: "Lyon Ma Ville", gras: true), FbSegment(texte: " et "),
                           FbSegment(texte: "Atelier Poterie Lyon 3", gras: true),
                           FbSegment(texte: ", ces Creators similaires pourraient vous intéresser.")],
                horaire: "2 h", postCible: "ville"),
        FbNotif(id: "n6", photo: "p31", teinte: 0xDF1C2D, badge: "bubble.left.fill",
                segments: [FbSegment(texte: "Francis Baron", gras: true),
                           FbSegment(texte: " a commenté une publication de "),
                           FbSegment(texte: "Le Progrès de Lyon", gras: true), FbSegment(texte: ".")],
                horaire: "2 j", postCible: "progres")
    ]

    // ---------------------------------------------------------------- Reels (e112, e122)

    static let reels: [FbReel] = [
        FbReel(id: "rl1", image: "p27", page: "Radio Cool Direct", pageTeinte: 0xDF1C2D,
               legende: "La nuit est tombée sur l'élection Miss… voir plus",
               audio: "Radio Cool Direct · Audio d'origine",
               jaime: 959, commentaires: 65, partages: 42, enregistrements: 37,
               fils: [
                FbCommentaire(id: "rc0", auteur: "Radio Cool Direct", teinte: 0xDF1C2D, date: "11 sem.",
                              texte: "@super fans", estAuteur: true),
                FbCommentaire(id: "rc1", auteur: "Marina Valognes", teinte: 0xE64980, date: "11 sem.",
                              texte: "Tu n'étais pas là pour gagner ? Tu étais là pourquoi alors ? 😅",
                              likes: 20, reponses: 13),
                FbCommentaire(id: "rc2", auteur: "Olivier Marin", teinte: 0x5B7CFA, date: "11 sem.",
                              texte: "Et une pensée pour Lyhanna elle aussi du Gers.....",
                              likes: 12, reponses: 7),
                FbCommentaire(id: "rc3", auteur: "Christelle Riou", teinte: 0x30D1C4, date: "9 sem.",
                              texte: "Tu avais le rêve de gagner et tu avais des doutes, c'est ce que tu as voulu dire, sans prétention aucune. Quand on est belle et intelligente émotionnellement comme toi, on se pose beaucoup de questions, n'est-ce pas ?",
                              likes: 4)
               ]),
        FbReel(id: "rl2", image: "p26", page: "Aline Dessine", pageTeinte: 0x8E44AD,
               legende: "Bordel j'aurais jamais cru que ce truc marche… voir plus",
               audio: "Aline Dessine · Audio d'origine",
               jaime: 231, commentaires: 18, partages: 6, enregistrements: 9,
               fils: [
                FbCommentaire(id: "rd1", auteur: "Léa Moreau", photo: "p18", teinte: 0x30D1C4, date: "3 sem.",
                              texte: "J'ai testé, ça marche vraiment 😂", likes: 7)
               ])
    ]

    // ---------------------------------------------------------------- feuille de partage (e021)
    // Contacts Messenger de Sarah. Marc n'y figure PAS : son absence est l'indice narratif.

    static let contactsMessenger: [FbPersonne] = [
        FbPersonne(id: "m1", nom: "Chloé Berthier", photo: "p12", teinte: 0xE64980),
        FbPersonne(id: "m2", nom: "Sylvie Lavisse", teinte: 0xE8A0A0),
        FbPersonne(id: "m3", nom: "Les filles 🎉", photo: "p18", teinte: 0x30D1C4),
        FbPersonne(id: "m4", nom: "Inès Djellal", photo: "p22", teinte: 0x8E44AD),
        FbPersonne(id: "m5", nom: "Julie Ferrand", teinte: 0xFF9F0A)
    ]

    // Publications de Sarah sur son profil (e155-e158).
    static let postProfil = FbPost(
        id: "sarah1",
        auteur: "Sarah Levasseur",
        photoAuteur: "p04",
        teinteAuteur: 0x5B7CFA,
        horaire: "12 sept. 2021",
        texte: "Sarah Levasseur a ajouté une photo de profil.",
        photos: ["p04"],
        ratio: 0.85,
        reactions: ["👍", "❤️"],
        nbReactions: 43,
        nbCommentaires: 6,
        nbPartages: 0,
        commentaires: [
            FbCommentaire(id: "s1", auteur: "Chloé Berthier", photo: "p12", date: "12 sept. 2021",
                          texte: "Trop belle 😍", likes: 4)
        ])
}

// ============================================================================
// MARK: - 4. ÉTAT PARTAGÉ (survit aux bascules d'onglet — écart n° 41 de l'audit)
// ============================================================================

struct FbAlerte: Identifiable {
    let id = UUID()
    let titre: String
    let message: String
}

struct FbCibleVisionneuse: Identifiable {
    let id: String
    let post: FbPost
    let index: Int
}

enum FbRoute: Hashable {
    case detail(String)            // identifiant de post
    case partages(String)
    case profilPersonne(String)    // nom
    case vosAmis
    case recherche
    case voirInvitations
}

final class FbEtat: ObservableObject {
    @Published var onglet: Int = 0
    @Published var chemin: [FbRoute] = []
    @Published var tiroir: Bool = false

    @Published var aimes: Set<String> = []
    @Published var enregistres: Set<String> = []
    @Published var masques: Set<String> = []
    @Published var suivis: Set<String> = []
    @Published var rejoints: Set<String> = []
    @Published var groupesRejetes: Set<String> = []
    @Published var invitationsTraitees: [String: String] = [:]   // nom -> "confirmé" / "supprimé"
    @Published var ajoutes: Set<String> = []
    @Published var suggestionsRejetees: Set<String> = []
    @Published var commentairesAjoutes: [String: [FbCommentaire]] = [:]
    @Published var pouces: [String: Int] = [:]                   // id de commentaire -> +1 / -1
    @Published var likesCommentaires: Set<String> = []
    @Published var pillAmis: Int = 0                             // 0 = Suggestions, 1 = Vos ami(e)s
    @Published var pillProfil: Int = 0                           // Tous / Photos / Reels
    @Published var triCommentaires: String = "Plus pertinents"

    @Published var partage: FbPost? = nil
    @Published var visionneuse: FbCibleVisionneuse? = nil
    @Published var story: FbStoryTuile? = nil
    @Published var reelCommentaires: FbReel? = nil
    @Published var alerte: FbAlerte? = nil
    @Published var toast: String? = nil

    func basculerJaime(_ id: String) {
        Haptique.leger()
        if aimes.contains(id) { aimes.remove(id) } else { aimes.insert(id) }
    }

    func nbReactions(_ p: FbPost) -> Int {
        p.nbReactions + (aimes.contains(p.id) ? 1 : 0)
    }

    func commentaires(_ p: FbPost) -> [FbCommentaire] {
        p.commentaires + (commentairesAjoutes[p.id] ?? [])
    }

    func nbCommentaires(_ p: FbPost) -> Int {
        p.nbCommentaires + (commentairesAjoutes[p.id]?.count ?? 0)
    }

    func ajouterCommentaire(_ texte: String, sur post: FbPost) {
        let c = FbCommentaire(id: "moi-\(post.id)-\(UUID().uuidString)",
                              auteur: DonneesFb.moiNom, photo: DonneesFb.moiPhoto,
                              teinte: 0x5B7CFA, date: "À l'instant", texte: texte)
        commentairesAjoutes[post.id, default: []].append(c)
        Haptique.leger()
    }

    func afficherToast(_ message: String) {
        toast = message
        Haptique.leger()
    }

    func ouvrirMessenger() {
        Haptique.leger()
        Routeur.partage.allerMessenger()
    }
}

// ============================================================================
// MARK: - 5. BRIQUES PARTAGÉES
// ============================================================================

/// Image de pellicule sans `.scaledToFill()` direct sur l'Image dans une cellule.
struct FbImage: View {
    let cle: String?
    var teinte: UInt = 0xE4E6EB
    var body: some View {
        Color.clear
            .overlay {
                if let c = cle, let img = ChargeurPhoto.image(c) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Rectangle().fill(Color(hex: teinte))
                }
            }
            .clipped()
    }
}

struct FbAvatar: View {
    let photo: String?
    let nom: String
    var taille: CGFloat = 40
    var teinte: UInt = 0xB0B3B8

    var body: some View {
        Group {
            if let p = photo, ChargeurPhoto.image(p) != nil {
                FbImage(cle: p)
            } else {
                Circle()
                    .fill(Color(hex: teinte))
                    .overlay(
                        Text(String(nom.prefix(1)))
                            .font(.system(size: taille * 0.40, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            }
        }
        .frame(width: taille, height: taille)
        .clipShape(Circle())
    }
}

/// Bande de 4 pt #C1C0C6 entre deux blocs du fil (e001, y 267-272).
struct FbSeparateurBloc: View {
    var body: some View {
        Rectangle().fill(FbStyle.filetBloc).frame(height: 4)
    }
}

struct FbHairline: View {
    var indent: CGFloat = 0
    var body: some View {
        Rectangle().fill(FbStyle.sepFin).frame(height: 0.5).padding(.leading, indent)
    }
}

/// Icône Messenger : cercle noir plein, éclair blanc (e001 — sans badge, l'ancien « 8 » était inventé).
struct FbIconeMessenger: View {
    var taille: CGFloat = 30
    var body: some View {
        Circle()
            .fill(Color.black)
            .frame(width: taille, height: taille)
            .overlay(
                Image(systemName: "bolt.fill")
                    .font(.system(size: taille * 0.46, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(-12))
            )
    }
}

/// Bouton bleu plein, texte blanc (Rejoindre, Confirmer, Partager maintenant).
struct FbBoutonPlein: View {
    let titre: String
    var hauteur: CGFloat = 35
    var corps: CGFloat = 15
    var rayon: CGFloat = 6
    var couleur: Color = FbStyle.bleu
    var texte: Color = .white
    var glyphe: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let g = glyphe {
                    Image(systemName: g).font(.system(size: corps - 1, weight: .semibold))
                }
                Text(titre).font(.system(size: corps, weight: .semibold))
            }
            .foregroundStyle(texte)
            .frame(maxWidth: .infinity)
            .frame(height: hauteur)
            .background(RoundedRectangle(cornerRadius: rayon).fill(couleur))
        }
        .buttonStyle(.plain)
    }
}

/// Pill de filtre (« Découvrir », « Suggestions », « Tous ») — e147, e130, e155.
struct FbPill: View {
    let titre: String
    let actif: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(titre)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(actif ? FbStyle.bleu : Color.black)
                .padding(.horizontal, 16)
                .frame(height: 31)
                .background(Capsule().fill(actif ? FbStyle.pillBleu : FbStyle.grisBouton))
        }
        .buttonStyle(.plain)
    }
}

/// En-tête commune des 5 onglets : ☰ à gauche (19×17 pt, x = 12 pt), titre 28 pt, actions à droite.
struct FbBarreHaute<Actions: View>: View {
    let titre: String
    var wordmark: Bool = false
    var sombre: Bool = false
    var ouvrirTiroir: () -> Void
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        HStack(spacing: 0) {
            Button(action: ouvrirTiroir) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(sombre ? Color.white : Color.black)
                    .frame(width: 33, height: 33)
            }
            .buttonStyle(.plain)
            .padding(.leading, 12)

            if wordmark {
                Text("facebook")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(FbStyle.bleu)
                    .padding(.leading, 8)
            } else {
                Text(titre)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(sombre ? Color.white : Color.black)
                    .padding(.leading, 10)
            }
            Spacer(minLength: 6)
            actions()
                .padding(.trailing, 12)
        }
        .frame(height: 47)
    }
}

/// Bouton d'action rond de barre haute (loupe, ⋯ cerclé, ⊞).
struct FbActionBarre: View {
    let glyphe: String
    var cercle: Bool = false
    var sombre: Bool = false
    var taille: CGFloat = 21
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if cercle {
                    Circle()
                        .fill(sombre ? Color.white.opacity(0.22) : FbStyle.grisBouton)
                        .frame(width: 30, height: 30)
                }
                Image(systemName: glyphe)
                    .font(.system(size: cercle ? taille - 5 : taille, weight: .medium))
                    .foregroundStyle(sombre ? Color.white : Color.black)
            }
            .frame(width: 34, height: 34)
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 6. RACINE : 6 ONGLETS + TIROIR LATÉRAL + PILE DE NAVIGATION
// ============================================================================

struct FbOngletInfo: Identifiable {
    let id: Int
    let glyphe: String
    let glypheActif: String
    let titre: String
    var badge: Int? = nil
}

let fbOnglets: [FbOngletInfo] = [
    FbOngletInfo(id: 0, glyphe: "house", glypheActif: "house.fill", titre: "Accueil"),
    FbOngletInfo(id: 1, glyphe: "play.square", glypheActif: "play.square.fill", titre: "Reels", badge: 1),
    FbOngletInfo(id: 2, glyphe: "person.2", glypheActif: "person.2.fill", titre: "Ami(e)s"),
    FbOngletInfo(id: 3, glyphe: "person.2.circle", glypheActif: "person.2.circle.fill", titre: "Groupes"),
    FbOngletInfo(id: 4, glyphe: "bell", glypheActif: "bell.fill", titre: "Notifications"),
    FbOngletInfo(id: 5, glyphe: "person.circle", glypheActif: "person.circle.fill", titre: "Profil")
]

struct FacebookVue: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var etat = FbEtat()

    var ongletInitial: Int? = nil
    var tiroirInitial: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            FbStyle.fond.ignoresSafeArea()
            pile
            barresBasses
            voileTiroir
            tiroir
            toast
        }
        .preferredColorScheme(.light)
        .onAppear(perform: preparer)
        .sheet(item: $etat.partage) { p in
            FbPartageFeuille(post: p, etat: etat)
        }
        .sheet(item: $etat.reelCommentaires) { r in
            FbReelCommentairesVue(reel: r, etat: etat)
        }
        .fullScreenCover(item: $etat.visionneuse) { c in
            FbVisionneuseVue(cible: c, etat: etat)
        }
        .fullScreenCover(item: $etat.story) { s in
            FbStoryVue(tuile: s)
        }
        .alert(item: $etat.alerte) { a in
            Alert(title: Text(a.titre), message: Text(a.message), dismissButton: .default(Text("OK")))
        }
    }

    private func preparer() {
        if let o = ongletInitial {
            etat.onglet = o
        } else if let env = ProcessInfo.processInfo.environment["ONGLET"], let o = Int(env) {
            etat.onglet = o
        }
        if tiroirInitial { etat.tiroir = true }
    }

    // ---------------------------------------------------------------- pile

    private var pile: some View {
        NavigationStack(path: $etat.chemin) {
            contenuOnglet
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: FbRoute.self) { route in
                    destination(route)
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
    }

    @ViewBuilder
    private var contenuOnglet: some View {
        switch etat.onglet {
        case 1: FbReelsVue(etat: etat)
        case 2: FbAmisVue(etat: etat)
        case 3: FbGroupesVue(etat: etat)
        case 4: FbNotificationsVue(etat: etat)
        case 5: FbProfilVue(etat: etat)
        default: FbFilVue(etat: etat)
        }
    }

    @ViewBuilder
    private func destination(_ route: FbRoute) -> some View {
        switch route {
        case .detail(let id):
            FbPostDetailVue(post: DonneesFb.post(id), etat: etat)
        case .partages(let id):
            FbPartagesVue(post: DonneesFb.post(id), etat: etat)
        case .profilPersonne(let nom):
            FbProfilPersonneVue(personne: DonneesFb.personne(nom), etat: etat)
        case .vosAmis:
            FbVosAmisVue(etat: etat)
        case .recherche:
            FbRechercheVue(etat: etat)
        case .voirInvitations:
            FbInvitationsVue(etat: etat)
        }
    }

    // ---------------------------------------------------------------- barres basses

    private var reelsActif: Bool { etat.onglet == 1 && etat.chemin.isEmpty }

    @ViewBuilder
    private var barresBasses: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            if etat.chemin.isEmpty {
                FbBarreOnglets(etat: etat, sombre: reelsActif)
            }
            BarreHome(action: { dismiss() }, sombre: !reelsActif)
                .background(reelsActif ? FbStyle.barreReels : FbStyle.fond)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // ---------------------------------------------------------------- tiroir

    @ViewBuilder
    private var voileTiroir: some View {
        if etat.tiroir {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture { withAnimation(.easeOut(duration: 0.22)) { etat.tiroir = false } }
        }
    }

    @ViewBuilder
    private var tiroir: some View {
        if etat.tiroir {
            HStack(spacing: 0) {
                FbMenuTiroir(etat: etat)
                    .frame(width: 358)
                Spacer(minLength: 0)
            }
            .ignoresSafeArea(edges: .bottom)
            .transition(.move(edge: .leading))
        }
    }

    // ---------------------------------------------------------------- toast (D82-A : confirmation crédible)

    @ViewBuilder
    private var toast: some View {
        if let message = etat.toast {
            VStack {
                Spacer()
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.86)))
                    .padding(.bottom, 130)
            }
            .transition(.opacity)
            .allowsHitTesting(false)
            .task(id: message) {
                try? await Task.sleep(nanoseconds: 2_200_000_000)
                withAnimation(.easeOut(duration: 0.25)) { etat.toast = nil }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Barre d'onglets — ordre filmé, filet bleu 1,5 pt au-dessus de l'actif,
// badge rouge #DF1C2D sur Reels, fond #202020 sur l'onglet Reels (e112).
// ---------------------------------------------------------------------------

struct FbBarreOnglets: View {
    @ObservedObject var etat: FbEtat
    var sombre: Bool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(fbOnglets) { o in
                bouton(o)
            }
        }
        .frame(height: FbStyle.hauteurBarre)
        .background(sombre ? FbStyle.barreReels : FbStyle.fond)
        .overlay(alignment: .top) {
            if !sombre {
                Rectangle().fill(FbStyle.sepFin).frame(height: 0.5)
            }
        }
    }

    private func couleur(_ o: FbOngletInfo) -> Color {
        if etat.onglet == o.id { return sombre ? .white : FbStyle.bleu }
        return sombre ? Color.white.opacity(0.85) : Color(hex: 0x1C1C1E)
    }

    private func bouton(_ o: FbOngletInfo) -> some View {
        Button {
            Haptique.leger()
            etat.onglet = o.id
        } label: {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(etat.onglet == o.id ? FbStyle.bleu : Color.clear)
                    .frame(width: 48, height: 1.5)
                Spacer(minLength: 0)
                ZStack(alignment: .topTrailing) {
                    Image(systemName: etat.onglet == o.id ? o.glypheActif : o.glyphe)
                        .font(.system(size: 20, weight: .regular))
                        .frame(width: 26, height: 24)
                    if let b = o.badge {
                        Text("\(b)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 15, minHeight: 15)
                            .background(Circle().fill(FbStyle.rouge))
                            .offset(x: 9, y: -5)
                    }
                }
                Text(o.titre)
                    .font(.system(size: 9.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
            .foregroundStyle(couleur(o))
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 7. FIL D'ACTUALITÉ (e001, e006, e049, e069, e102, e108, e159)
// ============================================================================

struct FbMedia: View {
    let cle: String?
    var ratio: CGFloat = 1.0
    var body: some View {
        Color.clear
            .aspectRatio(ratio, contentMode: .fit)
            .overlay {
                if let c = cle, let img = ChargeurPhoto.image(c) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Rectangle().fill(Color(hex: 0xE4E6EB))
                }
            }
            .clipped()
    }
}

struct FbClusterReactions: View {
    let reactions: [String]
    var taille: CGFloat = 19

    var body: some View {
        HStack(spacing: -5) {
            ForEach(Array(reactions.enumerated()), id: \.offset) { _, r in
                pastille(r)
            }
        }
    }

    @ViewBuilder
    private func pastille(_ r: String) -> some View {
        if r == "👍" {
            Circle()
                .fill(FbStyle.bleu)
                .frame(width: taille, height: taille)
                .overlay(
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: taille * 0.52))
                        .foregroundStyle(.white)
                )
                .overlay(Circle().strokeBorder(Color.white, lineWidth: 1.2))
        } else {
            Text(r)
                .font(.system(size: taille * 0.85))
                .frame(width: taille, height: taille)
                .background(Circle().fill(Color.white))
                .overlay(Circle().strokeBorder(Color.white, lineWidth: 1.2))
        }
    }
}

struct FbFilVue: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                LazyVStack(spacing: 0) {
                    FbComposerFil(etat: etat)
                    FbSeparateurBloc()
                    FbRailStories(etat: etat)
                    FbSeparateurBloc()
                    ForEach(DonneesFb.blocs) { bloc in
                        FbBlocFilVue(bloc: bloc, etat: etat)
                        FbSeparateurBloc()
                    }
                    Color.clear.frame(height: 96)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var entete: some View {
        FbBarreHaute(titre: "facebook", wordmark: true,
                     ouvrirTiroir: { withAnimation(.easeOut(duration: 0.25)) { etat.tiroir = true } }) {
            HStack(spacing: 12) {
                // (A) Le ⊞ n'ouvre PAS de composeur plein écran (jamais filmé) : il propose
                // les actions réellement visibles dans l'app, sous forme de menu iOS.
                Menu {
                    Button("Publication") { etat.afficherToast("Publication : ouvrez « Quoi de neuf ? » dans le fil.") }
                    Button("Story") { etat.afficherToast("La caméra n'est pas disponible sur cet appareil.") }
                    Button("Reel") { etat.onglet = 1 }
                } label: {
                    Image(systemName: "plus.app")
                        .font(.system(size: 23, weight: .regular))
                        .foregroundStyle(.black)
                }
                FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
                Button {
                    etat.ouvrirMessenger()
                } label: {
                    FbIconeMessenger(taille: 30)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ---------------------------------------------------------------- composer du fil (e001)

struct FbComposerFil: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        HStack(spacing: 12) {
            FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 32, teinte: 0x5B7CFA)
            Text("Quoi de neuf ?")
                .font(.system(size: 17))
                .foregroundStyle(FbStyle.texteGris)
            Spacer()
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: 0x3A3B3C))
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        // (B) La création de publication n'a JAMAIS été filmée : pas de composeur inventé,
        //     un message iOS crédible à la place.
        .onTapGesture {
            etat.alerte = FbAlerte(titre: "Publication indisponible",
                                   message: "Vous n'êtes pas connecté à Internet. Réessayez lorsque la connexion sera rétablie.")
        }
    }
}

// ---------------------------------------------------------------- rail stories + suggestions (e001, e108)

struct FbRailStories: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tuileCreer
                ForEach(DonneesFb.stories) { s in
                    tuileStory(s)
                }
                ForEach(DonneesFb.suggestionsFil) { p in
                    if !etat.suggestionsRejetees.contains(p.id) {
                        FbCarteSuggestionAmi(personne: p, etat: etat)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
    }

    private var tuileCreer: some View {
        Button {
            // (B) La création de story n'a jamais été filmée.
            etat.alerte = FbAlerte(titre: "Appareil photo indisponible",
                                   message: "Facebook n'a pas accès à l'appareil photo. Vous pouvez l'autoriser dans Réglages.")
        } label: {
            VStack(spacing: 0) {
                FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 62, teinte: 0x5B7CFA)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity)
                    .frame(height: 88)
                    .background(Color(hex: 0xEDEFF3))
                ZStack(alignment: .top) {
                    Color.white
                    Text("Créer une\nstory")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                    Circle()
                        .fill(FbStyle.bleu)
                        .frame(width: 28, height: 28)
                        .overlay(Image(systemName: "plus").font(.system(size: 14, weight: .bold)).foregroundStyle(.white))
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: 3))
                        .offset(y: -14)
                }
                .frame(height: 51)
            }
            .frame(width: 69, height: 139)
            .clipShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
    }

    private func tuileStory(_ s: FbStoryTuile) -> some View {
        Button {
            Haptique.leger()
            etat.story = s
        } label: {
            ZStack(alignment: .bottomLeading) {
                FbImage(cle: s.image)
                LinearGradient(colors: [.clear, .black.opacity(0.62)], startPoint: .center, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 1) {
                    Text(s.titre)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(s.sousTitre)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(6)
                if let b = s.badge {
                    FbAvatar(photo: b, nom: s.titre, taille: 26)
                        .overlay(Circle().strokeBorder(FbStyle.bleu, lineWidth: 2))
                        .padding(6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .frame(width: 69, height: 139)
            .clipShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
    }
}

/// Carte « suggestion d'ami(e) » du rail (e069, e108) : avatar, nom sur 2 lignes, « Ajouter », ✕.
struct FbCarteSuggestionAmi: View {
    let personne: FbPersonne
    @ObservedObject var etat: FbEtat

    var body: some View {
        VStack(spacing: 6) {
            FbAvatar(photo: personne.photo, nom: personne.nom, taille: 54, teinte: personne.teinte)
                .padding(.top, 16)
            Text(personne.nom)
                .font(.system(size: 12.5, weight: .bold))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 4)
            Spacer(minLength: 0)
            bouton
                .padding(.horizontal, 6)
                .padding(.bottom, 8)
        }
        .frame(width: 108, height: 139)
        .background(RoundedRectangle(cornerRadius: 11).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(FbStyle.sepFin, lineWidth: 1))
        .overlay(alignment: .topTrailing) {
            Button {
                Haptique.leger()
                etat.suggestionsRejetees.insert(personne.id)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x3A3B3C))
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
        }
    }

    private var bouton: some View {
        Button {
            Haptique.leger()
            etat.ajoutes.insert(personne.id)
            etat.afficherToast("Invitation envoyée à \(personne.nom).")
        } label: {
            HStack(spacing: 5) {
                if !etat.ajoutes.contains(personne.id) {
                    Image(systemName: "person.badge.plus").font(.system(size: 12, weight: .semibold))
                }
                Text(etat.ajoutes.contains(personne.id) ? "Invitation envoyée" : "Ajouter")
                    .font(.system(size: 12.5, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(etat.ajoutes.contains(personne.id) ? FbStyle.texteGris : FbStyle.bleu)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(RoundedRectangle(cornerRadius: 6)
                .fill(etat.ajoutes.contains(personne.id) ? FbStyle.grisBouton : FbStyle.pillBleu))
        }
        .buttonStyle(.plain)
    }
}

// ---------------------------------------------------------------- blocs intercalaires

struct FbBlocFilVue: View {
    let bloc: FbBlocFil
    @ObservedObject var etat: FbEtat

    var body: some View {
        switch bloc {
        case .post(let p):
            FbPostVue(post: p, etat: etat)
        case .reels:
            FbCarrouselReels(etat: etat)
        case .suggestionsAmis:
            FbCarrouselSuggestions(etat: etat)
        case .groupeSuggere:
            FbCarteGroupeFil(etat: etat)
        }
    }
}

/// Carrousel Reels du fil (e049-e058) : « Reels » + ⋯ + ✕ + vignettes + « Accéder à Reels › ».
struct FbCarrouselReels: View {
    @ObservedObject var etat: FbEtat
    @State private var ferme = false

    var body: some View {
        if !ferme {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "play.square").font(.system(size: 19)).foregroundStyle(.black)
                    Text("Reels").font(.system(size: 17, weight: .semibold)).foregroundStyle(.black)
                    Spacer()
                    Menu {
                        Button("Masquer les Reels de mon fil") { ferme = true }
                        Button("Signaler ce contenu") { etat.afficherToast("Merci, nous avons reçu votre signalement.") }
                    } label: {
                        Image(systemName: "ellipsis").font(.system(size: 17)).foregroundStyle(Color(hex: 0x3A3B3C))
                    }
                    Button {
                        Haptique.leger(); ferme = true
                    } label: {
                        Image(systemName: "xmark").font(.system(size: 17, weight: .medium)).foregroundStyle(Color(hex: 0x3A3B3C))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, FbStyle.margeH)
                .padding(.vertical, 10)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DonneesFb.reels) { r in
                            Button {
                                Haptique.leger()
                                etat.onglet = 1
                            } label: {
                                FbImage(cle: r.image)
                                    .frame(width: 212, height: 372)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                        Button {
                            Haptique.leger(); etat.onglet = 1
                        } label: {
                            FbImage(cle: "p18")
                                .frame(width: 212, height: 372)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, FbStyle.margeH)
                }

                Button {
                    Haptique.leger(); etat.onglet = 1
                } label: {
                    HStack(spacing: 4) {
                        Text("Accéder à Reels").font(.system(size: 15, weight: .semibold))
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Color(hex: 0x3A3B3C))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .background(FbStyle.fond)
        }
    }
}

/// Carrousel de suggestions d'ami(e)s dans le fil (e069-e073).
struct FbCarrouselSuggestions: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Personnes que vous connaissez peut-être")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, FbStyle.margeH)
                .padding(.top, 12)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DonneesFb.connaissezPeutEtre) { p in
                        if !etat.suggestionsRejetees.contains(p.id) {
                            FbCarteSuggestionAmi(personne: p, etat: etat)
                        }
                    }
                }
                .padding(.horizontal, FbStyle.margeH)
                .padding(.vertical, 10)
            }
        }
        .background(FbStyle.fond)
    }
}

/// Carte de groupe suggéré dans le fil (e049-e060).
struct FbCarteGroupeFil: View {
    @ObservedObject var etat: FbEtat
    private var groupe: FbGroupe { DonneesFb.groupes[0] }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                FbAvatar(photo: groupe.image, nom: groupe.nom, taille: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text(groupe.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.black)
                    Text("Groupe suggéré").font(.system(size: 12.5)).foregroundStyle(FbStyle.texteGris)
                }
                Spacer()
            }
            FbMedia(cle: groupe.image, ratio: 2.1)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            FbBoutonPlein(titre: etat.rejoints.contains(groupe.id) ? "Demande envoyée" : "Rejoindre",
                          hauteur: 35,
                          couleur: etat.rejoints.contains(groupe.id) ? FbStyle.grisBouton : FbStyle.bleu,
                          texte: etat.rejoints.contains(groupe.id) ? Color.black : Color.white) {
                Haptique.leger()
                etat.rejoints.insert(groupe.id)
                etat.afficherToast("Votre demande a été envoyée aux modérateurs du groupe.")
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 12)
        .background(FbStyle.fond)
    }
}

// ============================================================================
// MARK: - 8. POST (e001, e003, e006, e011) — 3 ou 4 boutons selon le type
// ============================================================================

struct FbPostVue: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat
    var dansDetail: Bool = false
    @State private var deplie = false

    var body: some View {
        if etat.masques.contains(post.id) {
            FbRangeeMasquee(post: post, etat: etat)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                FbPostEntete(post: post, etat: etat)
                texte
                media
                bandeauCta
                FbPostStats(post: post, etat: etat)
                FbHairline(indent: FbStyle.margeH)
                    .padding(.horizontal, FbStyle.margeH)
                FbPostActions(post: post, etat: etat)
            }
            .padding(.top, 10)
            .background(FbStyle.fond)
            .contentShape(Rectangle())
            .onTapGesture {
                if !dansDetail { etat.chemin.append(.detail(post.id)) }
            }
        }
    }

    // -------- texte tronqué à 3 lignes + « Afficher la suite » (e001)

    private var limite: Int { 118 }

    @ViewBuilder
    private var texte: some View {
        if deplie || post.texte.count <= limite {
            VStack(alignment: .leading, spacing: 4) {
                Text(post.texte)
                    .font(.system(size: 15))
                    .foregroundStyle(.black)
                if let l = post.lien {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.right.square.fill")
                            .font(.system(size: 15)).foregroundStyle(Color(hex: 0x4A90D9))
                        Text(l).font(.system(size: 15)).foregroundStyle(FbStyle.bleu).lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, FbStyle.margeH)
            .padding(.bottom, 8)
        } else {
            (Text(String(post.texte.prefix(limite)) + "… ")
                .font(.system(size: 15)).foregroundColor(.black)
             + Text("Afficher la suite")
                .font(.system(size: 15)).foregroundColor(FbStyle.texteGris))
                .padding(.horizontal, FbStyle.margeH)
                .padding(.bottom, 8)
                .contentShape(Rectangle())
                .onTapGesture { deplie = true }
        }
    }

    // -------- média (ratio libre, jamais de hauteur fixe)

    @ViewBuilder
    private var media: some View {
        if let cle = post.photos.first {
            FbMedia(cle: cle, ratio: post.ratio)
                .overlay(alignment: .bottomLeading) {
                    if let t = post.bandeauTitre {
                        Text(t)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4, y: 1)
                            .padding(14)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if post.photos.count > 1 {
                        Text("1 de \(post.photos.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color.black.opacity(0.55)))
                            .padding(10)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    Haptique.leger()
                    etat.visionneuse = FbCibleVisionneuse(id: post.id, post: post, index: 0)
                }
        }
    }

    // -------- bandeau boutique des posts sponsorisés (e003, e004)

    @ViewBuilder
    private var bandeauCta: some View {
        if let boutique = post.ctaBoutique, let titre = post.ctaTexte, let bouton = post.ctaBouton {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(boutique).font(.system(size: 11)).foregroundStyle(FbStyle.texteGris)
                    Text(titre).font(.system(size: 15)).foregroundStyle(.black).lineLimit(1)
                }
                Spacer()
                Button {
                    // (B) Aucune frame ne montre la suite du CTA : message iOS crédible.
                    etat.alerte = FbAlerte(
                        titre: "Impossible d'ouvrir l'App Store",
                        message: "Cette page n'est pas disponible dans votre pays ou votre région.")
                } label: {
                    Text(bouton)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 14)
                        .frame(height: 32)
                        .background(RoundedRectangle(cornerRadius: 6).fill(FbStyle.grisBouton))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, FbStyle.margeH)
            .padding(.vertical, 9)
            .background(FbStyle.bandeauSpons)
        }
    }
}

// ---------------------------------------------------------------- en-tête du post

struct FbPostEntete: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Button {
                if !post.sponsorise { etat.chemin.append(.profilPersonne(post.auteur)) }
            } label: {
                FbAvatar(photo: post.photoAuteur ?? post.photos.first,
                         nom: post.auteur, taille: 40, teinte: post.teinteAuteur)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 1) {
                ligneNom
                ligneMeta
            }
            Spacer(minLength: 4)
            menuPost
            boutonMasquer
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 8)
    }

    private var suivi: Bool { etat.suivis.contains(post.id) }

    private var ligneNom: some View {
        HStack(spacing: 4) {
            Text(post.auteur)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
            if post.verifie {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(FbStyle.bleu)
            }
            if post.suivre || post.rejoindre {
                Text("·").font(.system(size: 15)).foregroundStyle(FbStyle.bleu)
                Button {
                    Haptique.leger()
                    if suivi { etat.suivis.remove(post.id) } else { etat.suivis.insert(post.id) }
                    etat.afficherToast(suivi
                                       ? (post.rejoindre ? "Demande envoyée au groupe." : "Vous suivez \(post.auteur).")
                                       : "Vous ne suivez plus \(post.auteur).")
                } label: {
                    Text(post.rejoindre
                         ? (suivi ? "Demandé" : "Rejoindre")
                         : (suivi ? "Suivi(e)" : "Suivre"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(suivi ? FbStyle.texteGris : FbStyle.bleu)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var ligneMeta: some View {
        HStack(spacing: 4) {
            if let s = post.sousLigne {
                Text(s).font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
            } else {
                Text(post.sponsorise ? "Sponsorisée" : post.horaire)
                    .font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
            }
            Text("·").font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
            Image(systemName: post.confidentialite)
                .font(.system(size: 11))
                .foregroundStyle(FbStyle.texteGris)
        }
    }

    private var menuPost: some View {
        Menu {
            Button {
                Haptique.leger()
                if etat.enregistres.contains(post.id) { etat.enregistres.remove(post.id) }
                else { etat.enregistres.insert(post.id) }
                etat.afficherToast(etat.enregistres.contains(post.id)
                                   ? "Publication enregistrée." : "Retirée de vos enregistrements.")
            } label: {
                Label(etat.enregistres.contains(post.id) ? "Retirer des enregistrements" : "Enregistrer la publication",
                      systemImage: "bookmark")
            }
            Button {
                Haptique.leger()
                etat.masques.insert(post.id)
            } label: {
                Label("Masquer la publication", systemImage: "eye.slash")
            }
            Button(role: .destructive) {
                etat.afficherToast("Merci, nous avons reçu votre signalement.")
            } label: {
                Label("Signaler la publication", systemImage: "flag")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: 0x3A3B3C))
                .frame(width: 28, height: 24)
        }
    }

    private var boutonMasquer: some View {
        Button {
            Haptique.leger()
            etat.masques.insert(post.id)
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(Color(hex: 0x3A3B3C))
                .frame(width: 26, height: 24)
        }
        .buttonStyle(.plain)
    }
}

/// Remplace un post masqué par le ✕ — avec « Annuler » (D82-A, pas de disparition muette).
struct FbRangeeMasquee: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Publication masquée").font(.system(size: 15, weight: .semibold)).foregroundStyle(.black)
                Text("Vous verrez moins de contenus de ce type.")
                    .font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
            }
            Spacer()
            Button("Annuler") {
                Haptique.leger()
                etat.masques.remove(post.id)
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(FbStyle.bleu)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 22)
        .background(FbStyle.fond)
    }
}

// ---------------------------------------------------------------- ligne de statistiques

struct FbPostStats: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat

    var body: some View {
        HStack(spacing: 6) {
            Button {
                etat.chemin.append(.detail(post.id))
            } label: {
                HStack(spacing: 6) {
                    FbClusterReactions(reactions: post.reactions)
                    Text(fbNombre(etat.nbReactions(post)))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
            .buttonStyle(.plain)
            Spacer()
            Button {
                etat.chemin.append(.detail(post.id))
            } label: {
                Text("\(etat.nbCommentaires(post)) commentaires")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .buttonStyle(.plain)
            if post.nbPartages > 0 {
                Button {
                    etat.chemin.append(.partages(post.id))
                } label: {
                    Text("\(post.nbPartages) partage\(post.nbPartages > 1 ? "s" : "")")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 9)
    }
}

func fbNombre(_ n: Int) -> String {
    if n >= 1000 {
        let milliers = Double(n) / 1000.0
        return String(format: "%.1f", milliers).replacingOccurrences(of: ".", with: ",") + " K"
    }
    return "\(n)"
}

// ---------------------------------------------------------------- barre d'actions

struct FbPostActions: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat

    private var aime: Bool { etat.aimes.contains(post.id) }
    private var enregistre: Bool { etat.enregistres.contains(post.id) }

    var body: some View {
        HStack(spacing: 0) {
            bouton(glyphe: aime ? "hand.thumbsup.fill" : "hand.thumbsup",
                   titre: "J'aime",
                   actif: aime) {
                etat.basculerJaime(post.id)
            }
            bouton(glyphe: "bubble.left", titre: "Commenter", actif: false) {
                Haptique.leger()
                etat.chemin.append(.detail(post.id))
            }
            bouton(glyphe: "arrowshape.turn.up.right", titre: "Partager", actif: false) {
                Haptique.leger()
                etat.partage = post
            }
            if post.estLien {
                bouton(glyphe: enregistre ? "bookmark.fill" : "bookmark",
                       titre: "Enregistrer", actif: enregistre) {
                    Haptique.leger()
                    if enregistre { etat.enregistres.remove(post.id) } else { etat.enregistres.insert(post.id) }
                    etat.afficherToast(enregistre ? "Retirée de vos enregistrements." : "Publication enregistrée.")
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private func bouton(glyphe: String, titre: String, actif: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: glyphe).font(.system(size: 18, weight: .regular))
                Text(titre).font(.system(size: 14.5, weight: .medium))
                    .lineLimit(1).minimumScaleFactor(0.8)
            }
            .foregroundStyle(actif ? FbStyle.bleu : Color(hex: 0x1C1C1E))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 9. POST EN DÉTAIL + COMMENTAIRES — écran le plus filmé (e013-e028, e044)
//         Pleine page POUSSÉE dans la pile, jamais une feuille.
// ============================================================================

struct FbPostDetailVue: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat
    @State private var saisie = ""

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    media
                    FbPostActions(post: post, etat: etat)
                    FbHairline()
                    resume
                    tri
                    ForEach(etat.commentaires(post)) { c in
                        FbCommentaireVue(commentaire: c, etat: etat)
                    }
                    Color.clear.frame(height: 24)
                }
            }
            .scrollIndicators(.visible)
            composer
        }
        .background(FbStyle.fond)
    }

    // -------- barre haute (e015) : ‹ · avatar · « Nom · Suivre » · « 3 j · 🌐 » · ⋯

    private var entete: some View {
        HStack(spacing: 10) {
            Button {
                Haptique.leger()
                if !etat.chemin.isEmpty { etat.chemin.removeLast() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(width: 30, height: 34)
            }
            .buttonStyle(.plain)

            FbAvatar(photo: post.photoAuteur ?? post.photos.first, nom: post.auteur,
                     taille: 36, teinte: post.teinteAuteur)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(post.auteur)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black).lineLimit(1)
                    if post.suivre {
                        Text("· Suivre")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(FbStyle.bleu)
                    }
                }
                HStack(spacing: 4) {
                    Text(post.horaire).font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
                    Text("·").font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
                    Image(systemName: post.confidentialite).font(.system(size: 11))
                        .foregroundStyle(FbStyle.texteGris)
                }
            }
            Spacer(minLength: 4)
            Menu {
                Button("Enregistrer la publication") { etat.afficherToast("Publication enregistrée.") }
                Button("Copier le lien") { etat.afficherToast("Lien copié.") }
                Button(role: .destructive) {
                    etat.afficherToast("Merci, nous avons reçu votre signalement.")
                } label: { Text("Signaler la publication") }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 32, height: 34)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(FbStyle.fond)
        .overlay(alignment: .bottom) { FbHairline() }
    }

    @ViewBuilder
    private var media: some View {
        if let cle = post.photos.first {
            FbMedia(cle: cle, ratio: post.ratio)
                .contentShape(Rectangle())
                .onTapGesture {
                    Haptique.leger()
                    etat.visionneuse = FbCibleVisionneuse(id: post.id, post: post, index: 0)
                }
        }
    }

    // -------- résumé : cluster + total à gauche, « N partages » à droite (e015)

    private var resume: some View {
        HStack {
            Button {
                etat.basculerJaime(post.id)
            } label: {
                HStack(spacing: 7) {
                    FbClusterReactions(reactions: post.reactions, taille: 21)
                    Text(fbNombre(etat.nbReactions(post)))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
            .buttonStyle(.plain)
            Spacer()
            if post.nbPartages > 0 {
                Button {
                    etat.chemin.append(.partages(post.id))
                } label: {
                    Text("\(post.nbPartages) partages")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
    }

    // -------- sélecteur de tri « Plus pertinents ⌄ » (e015)

    private var tri: some View {
        Menu {
            Button("Plus pertinents") { etat.triCommentaires = "Plus pertinents" }
            Button("Plus récents") { etat.triCommentaires = "Plus récents" }
            Button("Tous les commentaires") { etat.triCommentaires = "Tous les commentaires" }
        } label: {
            HStack(spacing: 5) {
                Text(etat.triCommentaires).font(.system(size: 16)).foregroundStyle(.black)
                Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .padding(.horizontal, FbStyle.margeH)
            .padding(.bottom, 8)
        }
    }

    // -------- composer capsule « Commentez… » avec 📷 et ⊕ DANS la capsule (e015)

    private var composer: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                TextField("", text: $saisie,
                          prompt: Text("Commentez…").foregroundColor(FbStyle.texteGris))
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
                    .submitLabel(.send)
                    .onSubmit(envoyer)
                Button {
                    etat.alerte = FbAlerte(titre: "Appareil photo indisponible",
                                           message: "Facebook n'a pas accès à l'appareil photo. Vous pouvez l'autoriser dans Réglages.")
                } label: {
                    Image(systemName: "camera").font(.system(size: 19)).foregroundStyle(Color(hex: 0x3A3B3C))
                }
                .buttonStyle(.plain)
                Button(action: envoyer) {
                    Image(systemName: saisie.isEmpty ? "plus.circle" : "arrow.up.circle.fill")
                        .font(.system(size: 21))
                        .foregroundStyle(saisie.isEmpty ? Color(hex: 0x3A3B3C) : FbStyle.bleu)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Capsule().fill(FbStyle.champ))
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 8)
        .background(FbStyle.fond)
    }

    private func envoyer() {
        let t = saisie.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else {
            etat.alerte = FbAlerte(titre: "Ajouter un contenu",
                                   message: "Écrivez un commentaire avant de l'envoyer.")
            return
        }
        etat.ajouterCommentaire(t, sur: post)
        saisie = ""
    }
}

// ---------------------------------------------------------------- un commentaire (e015, e044, e122)

struct FbCommentaireVue: View {
    let commentaire: FbCommentaire
    @ObservedObject var etat: FbEtat

    private var pouce: Int { etat.pouces[commentaire.id] ?? 0 }
    private var likes: Int {
        max(0, commentaire.likes + (etat.likesCommentaires.contains(commentaire.id) ? 1 : 0))
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            FbAvatar(photo: commentaire.photo, nom: commentaire.auteur,
                     taille: 41, teinte: commentaire.teinte)
            VStack(alignment: .leading, spacing: 4) {
                ligneNom
                corps
                actions
                if commentaire.reponses > 0 { voirReponses }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 14)
    }

    private var ligneNom: some View {
        HStack(spacing: 5) {
            Text(commentaire.auteur)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
            Text("· " + commentaire.date)
                .font(.system(size: 14))
                .foregroundStyle(FbStyle.texteGris)
            if commentaire.estAuteur {
                HStack(spacing: 3) {
                    Image(systemName: "pencil").font(.system(size: 11, weight: .semibold))
                    Text("Auteur").font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(FbStyle.bleu)
            }
        }
    }

    // Texte à plat sur fond blanc, SANS bulle grise ; mentions en bleu.
    private var corps: some View {
        Group {
            if let m = commentaire.mention {
                (Text(m + " ").font(.system(size: 16)).foregroundColor(FbStyle.bleu)
                 + Text(commentaire.texte).font(.system(size: 16)).foregroundColor(.black))
            } else {
                Text(commentaire.texte).font(.system(size: 16)).foregroundStyle(.black)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                Haptique.leger()
                etat.afficherToast("Réponse à \(commentaire.auteur) — écrivez dans « Commentez… ».")
            } label: {
                Text("Répondre")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FbStyle.texteGris)
            }
            .buttonStyle(.plain)

            if likes > 0 {
                HStack(spacing: 5) {
                    Circle().fill(FbStyle.bleu).frame(width: 17, height: 17)
                        .overlay(Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 9)).foregroundStyle(.white))
                    Text("\(likes)").font(.system(size: 14)).foregroundStyle(FbStyle.texteGris)
                }
            }
            Spacer()
            Button {
                Haptique.leger()
                if etat.likesCommentaires.contains(commentaire.id) {
                    etat.likesCommentaires.remove(commentaire.id)
                    etat.pouces[commentaire.id] = 0
                } else {
                    etat.likesCommentaires.insert(commentaire.id)
                    etat.pouces[commentaire.id] = 1
                }
            } label: {
                Image(systemName: pouce == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.system(size: 18))
                    .foregroundStyle(pouce == 1 ? FbStyle.bleu : Color(hex: 0x3A3B3C))
            }
            .buttonStyle(.plain)
            Button {
                Haptique.leger()
                etat.likesCommentaires.remove(commentaire.id)
                etat.pouces[commentaire.id] = (pouce == -1) ? 0 : -1
            } label: {
                Image(systemName: pouce == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .font(.system(size: 18))
                    .foregroundStyle(pouce == -1 ? FbStyle.bleu : Color(hex: 0x3A3B3C))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 2)
    }

    private var voirReponses: some View {
        Button {
            Haptique.leger()
            etat.afficherToast("Les réponses de ce fil ne sont pas disponibles hors connexion.")
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold))
                Text(commentaire.reponses == 1 ? "Voir 1 réponse" : "Voir les \(commentaire.reponses) réponses")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(FbStyle.texteGris)
            .padding(.top, 2)
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 10. « PERSONNES QUI ONT PARTAGÉ ÇA » (e039, e045-e048)
// ============================================================================

struct FbPartageur: Identifiable {
    let id: String
    let nom: String
    let teinte: UInt
    let reactions: [String]
    let nbReactions: Int
    let partages: Int
    let complet: Bool
}

struct FbPartagesVue: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat

    private let partageurs: [FbPartageur] = [
        FbPartageur(id: "pp1", nom: "Paul Hubert", teinte: 0x5B7CFA, reactions: ["👍", "😢"], nbReactions: 3, partages: 0, complet: true),
        FbPartageur(id: "pp2", nom: "Didier Ovenberghe", teinte: 0x30D1C4, reactions: ["😮", "😢"], nbReactions: 2, partages: 0, complet: true),
        FbPartageur(id: "pp3", nom: "Amélie Lalanne", teinte: 0xE64980, reactions: ["😢"], nbReactions: 1, partages: 2, complet: true),
        FbPartageur(id: "pp4", nom: "Aurélie Deyries", teinte: 0xFF9F0A, reactions: [], nbReactions: 0, partages: 0, complet: false)
    ]

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(partageurs) { p in
                        carte(p)
                    }
                    Text("Certaines publications n'apparaissent peut-être pas ici à cause de leurs paramètres de confidentialité.")
                        .font(.system(size: 15))
                        .foregroundStyle(FbStyle.texteGris)
                        .padding(.horizontal, FbStyle.margeH)
                        .padding(.top, 10)
                    Color.clear.frame(height: 96)
                }
                .padding(.top, 12)
            }
        }
        .background(FbStyle.fond)
    }

    private var entete: some View {
        HStack {
            Button {
                Haptique.leger()
                if !etat.chemin.isEmpty { etat.chemin.removeLast() }
            } label: {
                Image(systemName: "chevron.left").font(.system(size: 21, weight: .medium))
                    .foregroundStyle(.black).frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("Personnes qui ont partagé ça")
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(.black)
            Spacer()
            Button {
                Haptique.leger(); etat.partage = post
            } label: {
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .font(.system(size: 19)).foregroundStyle(.black).frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) { FbHairline() }
    }

    private func carte(_ p: FbPartageur) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                FbAvatar(photo: nil, nom: p.nom, taille: 40, teinte: p.teinte)
                VStack(alignment: .leading, spacing: 1) {
                    Text(p.nom).font(.system(size: 16, weight: .semibold)).foregroundStyle(.black)
                    HStack(spacing: 4) {
                        Text("3 j").font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
                        Text("·").font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
                        Image(systemName: "globe.americas.fill").font(.system(size: 11))
                            .foregroundStyle(FbStyle.texteGris)
                    }
                }
                Spacer()
                Menu {
                    Button("Copier le lien") { etat.afficherToast("Lien copié.") }
                    Button("Masquer cette publication") { etat.afficherToast("Publication masquée.") }
                } label: {
                    Image(systemName: "ellipsis").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x3A3B3C))
                }
            }
            if p.nbReactions > 0 {
                HStack(spacing: 6) {
                    FbClusterReactions(reactions: p.reactions, taille: 18)
                    Text("\(p.nbReactions)").font(.system(size: 15)).foregroundStyle(FbStyle.texteGris)
                    Spacer()
                    if p.partages > 0 {
                        Text("\(p.partages) partages").font(.system(size: 15)).foregroundStyle(FbStyle.texteGris)
                    }
                }
            }
            FbHairline()
            HStack(spacing: 0) {
                miniAction("hand.thumbsup", "J'aime")
                if p.complet { miniAction("bubble.left", "Commenter") }
                miniAction("arrowshape.turn.up.right", "Partager")
                miniAction("bookmark", "Enregistrer")
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(FbStyle.sepFin, lineWidth: 1))
        .padding(.horizontal, FbStyle.margeH)
    }

    private func miniAction(_ glyphe: String, _ titre: String) -> some View {
        Button {
            Haptique.leger()
            if titre == "Partager" { etat.partage = post }
            else { etat.afficherToast("\(titre) : action enregistrée.") }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: glyphe).font(.system(size: 16))
                Text(titre).font(.system(size: 13.5, weight: .medium))
                    .lineLimit(1).minimumScaleFactor(0.8)
            }
            .foregroundStyle(Color(hex: 0x1C1C1E))
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 11. FEUILLE DE PARTAGE (e021, e029-e032, e037-e038)
// ============================================================================

struct FbDestinationPartage: Identifiable {
    let id: String
    let titre: String
    let glyphe: String
    let fond: UInt
    let teinteGlyphe: UInt
    let contour: Bool
}

struct FbPartageFeuille: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat
    @Environment(\.dismiss) private var fermer
    @State private var mot = ""

    private let rangee1: [FbDestinationPartage] = [
        FbDestinationPartage(id: "story", titre: "Votre story", glyphe: "plus.circle", fond: 0xFFFFFF, teinteGlyphe: 0x1C1C1E, contour: true),
        FbDestinationPartage(id: "messenger", titre: "Messenger", glyphe: "bolt.fill", fond: 0x0C59FD, teinteGlyphe: 0xFFFFFF, contour: false),
        FbDestinationPartage(id: "whatsapp", titre: "WhatsApp", glyphe: "phone.fill", fond: 0x25D366, teinteGlyphe: 0xFFFFFF, contour: false),
        FbDestinationPartage(id: "lien", titre: "Copier le lien", glyphe: "link", fond: 0xFFFFFF, teinteGlyphe: 0x1C1C1E, contour: true),
        FbDestinationPartage(id: "statut", titre: "Statut WhatsApp", glyphe: "circle.dashed", fond: 0x4FCE5D, teinteGlyphe: 0xFFFFFF, contour: false)
    ]

    private let rangee2: [FbDestinationPartage] = [
        FbDestinationPartage(id: "groupes", titre: "Groupes", glyphe: "person.2.circle.fill", fond: 0x0C59FD, teinteGlyphe: 0xFFFFFF, contour: false),
        FbDestinationPartage(id: "messages", titre: "Messages", glyphe: "message.fill", fond: 0x4FCE5D, teinteGlyphe: 0xFFFFFF, contour: false),
        FbDestinationPartage(id: "threads", titre: "Threads", glyphe: "at", fond: 0x1C1C1E, teinteGlyphe: 0xFFFFFF, contour: false),
        FbDestinationPartage(id: "instagram", titre: "Instagram", glyphe: "camera.fill", fond: 0xE1306C, teinteGlyphe: 0xFFFFFF, contour: false),
        FbDestinationPartage(id: "plus", titre: "Plus", glyphe: "ellipsis", fond: 0xDCE0E3, teinteGlyphe: 0x1C1C1E, contour: false)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                carteComposeur
                titre("Envoyer dans Messenger")
                rangeeContacts
                titre("Partager sur")
                rangeeDestinations(rangee1)
                rangeeDestinations(rangee2)
                Color.clear.frame(height: 30)
            }
            .padding(.top, 14)
        }
        .background(Color(hex: 0xF0F2F5))
        .presentationDetents([.large])
        .preferredColorScheme(.light)
    }

    private func titre(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 21, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .padding(.top, 20)
            .padding(.bottom, 12)
    }

    // -------- carte composeur (e021)

    private var carteComposeur: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 46, teinte: 0x5B7CFA)
                VStack(alignment: .leading, spacing: 7) {
                    Text(DonneesFb.moiNom)
                        .font(.system(size: 19))
                        .foregroundStyle(.black)
                    HStack(spacing: 9) {
                        pillChoix(titre: "Fil", glyphe: nil)
                        pillChoix(titre: "Ami(e)s", glyphe: "person.2.fill")
                    }
                }
                Spacer(minLength: 0)
            }
            TextField("", text: $mot,
                      prompt: Text("Dites quelque chose à propos de ceci...").foregroundColor(FbStyle.texteGris),
                      axis: .vertical)
                .font(.system(size: 17))
                .foregroundStyle(.black)
                .lineLimit(1...4)
            HStack(spacing: 18) {
                Button {
                    etat.afficherToast("Les émojis sont accessibles depuis le clavier.")
                } label: {
                    Image(systemName: "face.smiling").font(.system(size: 21)).foregroundStyle(Color(hex: 0x3A3B3C))
                }
                .buttonStyle(.plain)
                Button {
                    etat.afficherToast("Identifiez un(e) ami(e) en écrivant @ suivi de son nom.")
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 21)).foregroundStyle(Color(hex: 0x3A3B3C))
                }
                .buttonStyle(.plain)
                Spacer()
                Button {
                    Haptique.leger()
                    fermer()
                    etat.afficherToast("Publication partagée dans votre fil.")
                } label: {
                    Text("Partager maintenant")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 8).fill(FbStyle.bleu))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .padding(.horizontal, 18)
    }

    private func pillChoix(titre: String, glyphe: String?) -> some View {
        Button {
            etat.afficherToast("Audience : \(titre).")
        } label: {
            HStack(spacing: 6) {
                if let g = glyphe {
                    Image(systemName: g).font(.system(size: 13)).foregroundStyle(.black)
                }
                Text(titre).font(.system(size: 16, weight: .medium)).foregroundStyle(.black)
                Image(systemName: "chevron.down").font(.system(size: 11, weight: .bold)).foregroundStyle(.black)
            }
            .padding(.horizontal, 13)
            .frame(height: 33)
            .background(Capsule().fill(FbStyle.grisBouton))
        }
        .buttonStyle(.plain)
    }

    // -------- « Envoyer dans Messenger » : contacts Messenger de Sarah (aucun Marc)

    private var rangeeContacts: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(DonneesFb.contactsMessenger) { c in
                    Button {
                        etat.ouvrirMessenger()
                    } label: {
                        VStack(spacing: 7) {
                            FbAvatar(photo: c.photo, nom: c.nom, taille: 68, teinte: c.teinte)
                            Text(c.nom)
                                .font(.system(size: 14))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(width: 76)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
    }

    private func rangeeDestinations(_ liste: [FbDestinationPartage]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(liste) { d in
                    Button {
                        actionDestination(d)
                    } label: {
                        VStack(spacing: 7) {
                            ZStack {
                                Circle().fill(Color(hex: d.fond)).frame(width: 62, height: 62)
                                if d.contour {
                                    Circle().strokeBorder(FbStyle.sepFin, lineWidth: 1).frame(width: 62, height: 62)
                                }
                                Image(systemName: d.glyphe)
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundStyle(Color(hex: d.teinteGlyphe))
                            }
                            Text(d.titre)
                                .font(.system(size: 14))
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(width: 74)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 8)
        }
    }

    private func actionDestination(_ d: FbDestinationPartage) {
        Haptique.leger()
        switch d.id {
        case "messenger":
            fermer()
            etat.ouvrirMessenger()
        case "lien":
            UIPasteboard.general.string = post.lien ?? "https://www.facebook.com/\(post.id)"
            fermer()
            etat.afficherToast("Lien copié dans le presse-papiers.")
        case "story":
            fermer()
            etat.afficherToast("Publication ajoutée à votre story.")
        default:
            etat.alerte = FbAlerte(titre: d.titre,
                                   message: "\(d.titre) n'est pas installé sur cet iPhone.")
        }
    }
}

// ============================================================================
// MARK: - 12. VISIONNEUSE PHOTO « 1 de 2 » (e034-e036, e041-e043)
// ============================================================================

struct FbVisionneuseVue: View {
    let cible: FbCibleVisionneuse
    @ObservedObject var etat: FbEtat
    @Environment(\.dismiss) private var fermer
    @State private var index: Int = 0

    private var photos: [String] { cible.post.photos.isEmpty ? ["p04"] : cible.post.photos }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                barreHaute
                Spacer(minLength: 0)
                FbMedia(cle: photos[min(index, photos.count - 1)], ratio: 0.78)
                    .gesture(glissement)
                Spacer(minLength: 0)
                basDePage
                // La BarreHome reste TOUJOURS accessible : aucun plein écran ne piège le joueur.
                BarreHome(action: { fermer() }, sombre: false)
                    .padding(.bottom, 6)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { index = cible.index }
    }

    private var glissement: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { v in
                if v.translation.width < -40, index < photos.count - 1 {
                    Haptique.leger(); index += 1
                } else if v.translation.width > 40, index > 0 {
                    Haptique.leger(); index -= 1
                }
            }
    }

    private var barreHaute: some View {
        HStack {
            Button { fermer() } label: {
                Image(systemName: "xmark").font(.system(size: 21, weight: .medium))
                    .foregroundStyle(.white).frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("\(index + 1) de \(photos.count)")
                .font(.system(size: 17, weight: .medium)).foregroundStyle(.white)
            Spacer()
            Menu {
                Button("Enregistrer la photo") { etat.afficherToast("Photo enregistrée dans Photos.") }
                Button("Copier le lien") { etat.afficherToast("Lien copié.") }
            } label: {
                Image(systemName: "ellipsis").font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white).frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 8)
    }

    private var basDePage: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(cible.post.auteur)
                .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
            HStack(spacing: 4) {
                Text(cible.post.horaire).font(.system(size: 13)).foregroundStyle(.white.opacity(0.65))
                Text("·").font(.system(size: 13)).foregroundStyle(.white.opacity(0.65))
                Image(systemName: cible.post.confidentialite).font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.65))
            }
            HStack {
                Button { etat.basculerJaime(cible.post.id) } label: {
                    HStack(spacing: 6) {
                        FbClusterReactions(reactions: cible.post.reactions, taille: 18)
                        Text(fbNombre(etat.nbReactions(cible.post)))
                            .font(.system(size: 15)).foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                Spacer()
                Button {
                    fermer()
                    etat.chemin.append(.detail(cible.post.id))
                } label: {
                    Text("\(etat.nbCommentaires(cible.post)) commentaires")
                        .font(.system(size: 15)).foregroundStyle(.white.opacity(0.75))
                }
                .buttonStyle(.plain)
            }
            Button {
                fermer()
                etat.partage = cible.post
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrowshape.turn.up.right").font(.system(size: 17))
                    Text("Partager").font(.system(size: 16, weight: .medium))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 24)
    }
}

// ============================================================================
// MARK: - 13. STORY (e074) — en-tête Page + pill « Suivre »
// ============================================================================

struct FbStoryVue: View {
    var tuile: FbStoryTuile = DonneesFb.stories[0]
    @Environment(\.dismiss) private var fermer
    @State private var suivi = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                carte
                Spacer(minLength: 0)
                // La BarreHome reste TOUJOURS accessible : aucun plein écran ne piège le joueur.
                BarreHome(action: { fermer() }, sombre: false)
                    .padding(.bottom, 6)
            }
        }
        .preferredColorScheme(.dark)
        .contentShape(Rectangle())
        .onTapGesture { fermer() }
    }

    private var carte: some View {
        ZStack(alignment: .top) {
            FbMedia(cle: tuile.image, ratio: 0.5625)
            VStack(alignment: .leading, spacing: 10) {
                Capsule().fill(Color.white.opacity(0.9)).frame(height: 2.5)
                    .padding(.horizontal, 8)
                HStack(alignment: .top, spacing: 9) {
                    FbAvatar(photo: tuile.badge ?? tuile.image, nom: tuile.titre, taille: 32)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 6) {
                            Text(tuile.titre)
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                                .lineLimit(1)
                            Text(tuile.sousTitre == "Suggestions" ? "8 h" : tuile.sousTitre)
                                .font(.system(size: 15)).foregroundStyle(.white.opacity(0.9))
                        }
                        if tuile.sousTitre == "Suggestions" {
                            Text("Suggestions").font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                        }
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.down").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                    Image(systemName: "ellipsis").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                    Button { fermer() } label: {
                        Image(systemName: "xmark").font(.system(size: 19, weight: .medium)).foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                Button {
                    Haptique.leger(); suivi.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: suivi ? "checkmark" : "plus.rectangle.on.folder")
                            .font(.system(size: 13, weight: .semibold))
                        Text(suivi ? "Suivi(e)" : "Suivre").font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 33)
                    .background(Capsule().fill(Color.black.opacity(0.55)))
                }
                .buttonStyle(.plain)
                .padding(.leading, 14)
            }
            .padding(.top, 8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 8)
    }
}

// ============================================================================
// MARK: - 14. REELS PLEIN ÉCRAN (e112, e126) + COMMENTAIRES DE REEL (e122)
// ============================================================================

/// Onglet Reels. Vidéo verticale plein cadre, barre haute translucide, rail droit
/// à 4 compteurs, bas de page « Page · Suivre / ♪ audio / légende ».
/// La barre d'onglets sombre #202020 est dessinée par `FacebookVue` (pas ici).
struct FbReelsVue: View {
    @ObservedObject var etat: FbEtat
    @State private var index: Int = 0

    private var reels: [FbReel] { DonneesFb.reels }
    private var reel: FbReel { reels[min(index, reels.count - 1)] }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            FbImage(cle: reel.image).ignoresSafeArea()
            voiles
            VStack(spacing: 0) {
                barreHaute
                Spacer(minLength: 0)
                bas
            }
            rail
        }
        .contentShape(Rectangle())
        .gesture(glissement)
    }

    // -------- dégradés haut et bas (le texte reste lisible sur toute image)

    private var voiles: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [Color.black.opacity(0.55), Color.clear],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 150)
            Spacer(minLength: 0)
            LinearGradient(colors: [Color.clear, Color.black.opacity(0.62)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 260)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // -------- glissement vertical : reel suivant / précédent (e112 → e126)

    private var glissement: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { v in
                if v.translation.height < -60, index < reels.count - 1 {
                    Haptique.leger()
                    index += 1
                } else if v.translation.height > 60, index > 0 {
                    Haptique.leger()
                    index -= 1
                }
            }
    }

    // -------- barre haute : ☰ · « Reels » 28 pt blanc · 🔍 · ⋯ (cercles sombres)

    private var barreHaute: some View {
        FbBarreHaute(titre: "Reels", sombre: true,
                     ouvrirTiroir: { withAnimation(.easeOut(duration: 0.25)) { etat.tiroir = true } }) {
            HStack(spacing: 10) {
                FbActionBarre(glyphe: "magnifyingglass", cercle: true, sombre: true) {
                    etat.chemin.append(.recherche)
                }
                Menu {
                    Button("Enregistrer le Reel") { etat.afficherToast("Reel enregistré.") }
                    Button("Copier le lien") { etat.afficherToast("Lien copié.") }
                    Button(role: .destructive) {
                        etat.afficherToast("Merci, nous avons reçu votre signalement.")
                    } label: { Text("Signaler ce Reel") }
                } label: {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.22)).frame(width: 30, height: 30)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 34, height: 34)
                }
            }
        }
    }

    // -------- rail droit : 4 items, tous avec compteur (e112)

    private var rail: some View {
        VStack(spacing: 20) {
            itemRail(glyphe: etat.aimes.contains(reel.id) ? "hand.thumbsup.fill" : "hand.thumbsup",
                     valeur: reel.jaime + (etat.aimes.contains(reel.id) ? 1 : 0),
                     actif: etat.aimes.contains(reel.id)) {
                etat.basculerJaime(reel.id)
            }
            itemRail(glyphe: "bubble.right", valeur: reel.commentaires, actif: false) {
                Haptique.leger()
                etat.reelCommentaires = reel
            }
            itemRail(glyphe: "arrowshape.turn.up.right", valeur: reel.partages, actif: false) {
                Haptique.leger()
                etat.partage = DonneesFb.postVille
            }
            itemRail(glyphe: etat.enregistres.contains(reel.id) ? "bookmark.fill" : "bookmark",
                     valeur: reel.enregistrements,
                     actif: etat.enregistres.contains(reel.id)) {
                Haptique.leger()
                if etat.enregistres.contains(reel.id) {
                    etat.enregistres.remove(reel.id)
                    etat.afficherToast("Reel retiré de vos enregistrements.")
                } else {
                    etat.enregistres.insert(reel.id)
                    etat.afficherToast("Reel enregistré.")
                }
            }
        }
        .padding(.trailing, 12)
        .padding(.bottom, FbStyle.hauteurBarre + 78)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }

    private func itemRail(glyphe: String, valeur: Int, actif: Bool,
                          action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: glyphe)
                    .font(.system(size: 27, weight: .regular))
                    .foregroundStyle(actif ? FbStyle.bleu : Color.white)
                Text(fbNombre(valeur))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
            .frame(width: 52)
            .shadow(color: Color.black.opacity(0.4), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }

    // -------- bas : avatar · nom 🌐 · pill Suivre · ♪ audio · légende

    private var bas: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 9) {
                FbAvatar(photo: nil, nom: reel.page, taille: 34, teinte: reel.pageTeinte)
                    .overlay(Circle().strokeBorder(Color.white, lineWidth: 1.5))
                Text(reel.page)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.85))
                pillSuivre
                Spacer(minLength: 0)
            }
            HStack(spacing: 6) {
                Image(systemName: "music.note")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.9))
                Text(reel.audio)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .lineLimit(1)
            }
            Text(reel.legende)
                .font(.system(size: 15))
                .foregroundStyle(Color.white)
                .lineLimit(2)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.trailing, 64)
        .padding(.bottom, FbStyle.hauteurBarre + 14)
    }

    private var pillSuivre: some View {
        Button {
            Haptique.leger()
            if etat.suivis.contains(reel.id) {
                etat.suivis.remove(reel.id)
                etat.afficherToast("Vous ne suivez plus \(reel.page).")
            } else {
                etat.suivis.insert(reel.id)
                etat.afficherToast("Vous suivez \(reel.page).")
            }
        } label: {
            Text(etat.suivis.contains(reel.id) ? "Suivi(e)" : "Suivre")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 15)
                .frame(height: 31)
                .background(Capsule().fill(Color.white.opacity(0.20)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// ---------------------------------------------------------------------------
// Commentaires d'un Reel — feuille basse « Plus pertinents ⌄ » (e122, e137-e140).
// Réutilise FbCommentaireVue : c'est exactement la rangée filmée (Répondre,
// pastille de likes, 👍/👎 en contour, « Voir les N réponses »).
// ---------------------------------------------------------------------------

struct FbReelCommentairesVue: View {
    let reel: FbReel
    @ObservedObject var etat: FbEtat
    @State private var saisie = ""

    private var liste: [FbCommentaire] {
        reel.fils + (etat.commentairesAjoutes[reel.id] ?? [])
    }

    var body: some View {
        VStack(spacing: 0) {
            tri
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(liste) { c in
                        FbCommentaireVue(commentaire: c, etat: etat)
                    }
                    Color.clear.frame(height: 16)
                }
                .padding(.top, 6)
            }
            .scrollIndicators(.hidden)
            composer
        }
        .background(FbStyle.fond)
        .presentationDetents([.fraction(0.72), .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.light)
    }

    private var tri: some View {
        Menu {
            Button("Plus pertinents") { etat.triCommentaires = "Plus pertinents" }
            Button("Plus récents") { etat.triCommentaires = "Plus récents" }
            Button("Tous les commentaires") { etat.triCommentaires = "Tous les commentaires" }
        } label: {
            HStack(spacing: 6) {
                Text(etat.triCommentaires)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.black)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.black)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 14)
            .padding(.bottom, 4)
        }
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("", text: $saisie,
                      prompt: Text("Commentez…").foregroundColor(FbStyle.texteGris))
                .font(.system(size: 16))
                .foregroundStyle(Color.black)
                .submitLabel(.send)
                .onSubmit(envoyer)
            Button(action: envoyer) {
                Image(systemName: saisie.isEmpty ? "plus.circle" : "arrow.up.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(saisie.isEmpty ? Color(hex: 0x3A3B3C) : FbStyle.bleu)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Capsule().fill(FbStyle.champ))
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 9)
    }

    private func envoyer() {
        let t = saisie.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else {
            etat.alerte = FbAlerte(titre: "Ajouter un contenu",
                                   message: "Écrivez un commentaire avant de l'envoyer.")
            return
        }
        let c = FbCommentaire(id: "moi-\(reel.id)-\(UUID().uuidString)",
                              auteur: DonneesFb.moiNom, photo: DonneesFb.moiPhoto,
                              teinte: 0x5B7CFA, date: "À l'instant", texte: t)
        etat.commentairesAjoutes[reel.id, default: []].append(c)
        Haptique.leger()
        saisie = ""
    }
}

// ============================================================================
// MARK: - 15. ONGLET AMI(E)S (e130, e145) + « Vos ami(e)s » (e146) + « Suggestions » (e144)
// ============================================================================

/// Rangée d'invitation / de suggestion : avatar 90 pt (badge horaire vert en bas-droite),
/// nom 17 pt à x = 116 pt, ancienneté grise à droite, 2 boutons 133×36 pt r 8 pt.
struct FbRangeeInvitation: View {
    let personne: FbPersonne
    let titrePrincipal: String        // « Confirmer » ou « Ajouter ami(e) »
    @ObservedObject var etat: FbEtat

    private var traitee: String? { etat.invitationsTraitees[personne.nom] }

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            avatar
            VStack(alignment: .leading, spacing: 4) {
                ligneNom
                if let d = personne.detail {
                    Text(d)
                        .font(.system(size: 15))
                        .foregroundStyle(FbStyle.texteGris)
                        .lineLimit(1)
                }
                if let t = traitee {
                    Text(t)
                        .font(.system(size: 15))
                        .foregroundStyle(FbStyle.texteGris)
                        .padding(.top, 6)
                        .padding(.bottom, 4)
                } else {
                    boutons
                }
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture { etat.chemin.append(.profilPersonne(personne.nom)) }
    }

    private var avatar: some View {
        FbAvatar(photo: personne.photo, nom: personne.nom, taille: 90, teinte: personne.teinte)
            .overlay(alignment: .bottomTrailing) {
                if let b = personne.badgeHoraire {
                    Text(b)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(FbStyle.vertBadge)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(FbStyle.vertBadgeFd))
                        .overlay(Capsule().strokeBorder(Color.white, lineWidth: 1))
                }
            }
    }

    private var ligneNom: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(personne.nom)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
                .lineLimit(1)
            Spacer(minLength: 0)
            if let a = personne.anciennete {
                Text(a)
                    .font(.system(size: 14))
                    .foregroundStyle(FbStyle.texteGris)
            }
        }
    }

    private var boutons: some View {
        HStack(spacing: 8) {
            FbBoutonPlein(titre: titrePrincipal, hauteur: 36, corps: 16, rayon: 8) {
                etat.invitationsTraitees[personne.nom] =
                    (titrePrincipal == "Confirmer") ? "Invitation acceptée" : "Invitation envoyée"
                Haptique.leger()
            }
            FbBoutonPlein(titre: "Supprimer", hauteur: 36, corps: 16, rayon: 8,
                          couleur: FbStyle.grisBouton, texte: Color.black) {
                etat.invitationsTraitees[personne.nom] = "Invitation supprimée"
                Haptique.leger()
            }
        }
        .padding(.top, 4)
    }
}

struct FbAmisVue: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    pills
                    titreSection("Invitations", lien: "Voir tout") {
                        etat.chemin.append(.voirInvitations)
                    }
                    ForEach(DonneesFb.invitations) { p in
                        FbRangeeInvitation(personne: p, titrePrincipal: "Confirmer", etat: etat)
                    }
                    FbSeparateurBloc().padding(.vertical, 6)
                    titreSection("Vous connaissez peut-être…", lien: nil, action: {})
                    ForEach(DonneesFb.connaissezPeutEtre) { p in
                        FbRangeeInvitation(personne: p, titrePrincipal: "Ajouter ami(e)", etat: etat)
                    }
                    Color.clear.frame(height: 96)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var entete: some View {
        FbBarreHaute(titre: "Ami(e)s",
                     ouvrirTiroir: { withAnimation(.easeOut(duration: 0.25)) { etat.tiroir = true } }) {
            FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
        }
    }

    // e145 : les deux pills sont grises au repos ; chacune POUSSE un écran filmé
    // (« Suggestions » = e144, « Vos ami(e)s » = e146). La pill visitée reste bleue.
    private var pills: some View {
        HStack(spacing: 9) {
            FbPill(titre: "Suggestions", actif: etat.pillAmis == 1) {
                etat.pillAmis = 1
                etat.chemin.append(.voirInvitations)
            }
            FbPill(titre: "Vos ami(e)s", actif: etat.pillAmis == 2) {
                etat.pillAmis = 2
                etat.chemin.append(.vosAmis)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 6)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func titreSection(_ titre: String, lien: String?,
                              action: @escaping () -> Void) -> some View {
        HStack {
            Text(titre)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Color.black)
            Spacer()
            if let l = lien {
                Button(action: action) {
                    Text(l)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(FbStyle.bleu)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 4)
    }
}

// ---------------------------------------------------------------------------
// « Suggestions » — écran poussé (e144) : ‹ · titre centré · 🔍
// ---------------------------------------------------------------------------

struct FbInvitationsVue: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        VStack(spacing: 0) {
            FbBarrePoussee(titre: "Suggestions", etat: etat) {
                FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text("Vous connaissez peut-être…")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, FbStyle.margeH)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                    ForEach(DonneesFb.connaissezPeutEtre) { p in
                        FbRangeeInvitation(personne: p, titrePrincipal: "Ajouter ami(e)", etat: etat)
                    }
                    ForEach(DonneesFb.invitations) { p in
                        FbRangeeInvitation(personne: p, titrePrincipal: "Ajouter ami(e)", etat: etat)
                    }
                    Color.clear.frame(height: 96)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }
}

/// Barre haute des écrans poussés : ‹ · titre centré 17 pt · slot d'actions (e144, e146).
struct FbBarrePoussee<Actions: View>: View {
    let titre: String
    @ObservedObject var etat: FbEtat
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        ZStack {
            Text(titre)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            HStack {
                Button {
                    Haptique.leger()
                    if !etat.chemin.isEmpty { etat.chemin.removeLast() }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(Color.black)
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                Spacer()
                actions()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(FbStyle.fond)
    }
}

// ---------------------------------------------------------------------------
// « Vos ami(e)s » — écran poussé (e146) : champ de recherche + section « Ami(e)s »
// ---------------------------------------------------------------------------

struct FbVosAmisVue: View {
    @ObservedObject var etat: FbEtat
    @State private var filtre = ""

    private var liste: [FbPersonne] {
        let t = filtre.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return DonneesFb.vosAmis }
        return DonneesFb.vosAmis.filter { $0.nom.localizedCaseInsensitiveContains(t) }
    }

    var body: some View {
        VStack(spacing: 0) {
            FbBarrePoussee(titre: "Vos ami(e)s", etat: etat) {
                FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
            }
            champ
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text("Ami(e)s")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, FbStyle.margeH)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    ForEach(liste) { p in
                        rangee(p)
                    }
                    if liste.isEmpty { vide }
                    Color.clear.frame(height: 96)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var champ: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(FbStyle.texteGris)
            TextField("", text: $filtre,
                      prompt: Text("Rechercher des ami(e)s").foregroundColor(FbStyle.texteGris))
                .font(.system(size: 17))
                .foregroundStyle(Color.black)
        }
        .padding(.horizontal, 15)
        .frame(height: 42)
        .background(Capsule().fill(FbStyle.champ))
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 8)
    }

    private var vide: some View {
        Text("Aucun résultat pour « \(filtre) ».")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 24)
    }

    private func rangee(_ p: FbPersonne) -> some View {
        HStack(spacing: 14) {
            FbAvatar(photo: p.photo, nom: p.nom, taille: 56, teinte: p.teinte)
            Text(p.nom)
                .font(.system(size: 17))
                .foregroundStyle(Color.black)
                .lineLimit(1)
            Spacer(minLength: 6)
            Button {
                etat.ouvrirMessenger()
            } label: {
                FbIconeMessenger(taille: 28)
            }
            .buttonStyle(.plain)
            Menu {
                Button("Voir le profil") { etat.chemin.append(.profilPersonne(p.nom)) }
                Button("Retirer de mes ami(e)s") {
                    etat.afficherToast("\(p.nom) a été retiré(e) de vos ami(e)s.")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x3A3B3C))
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { etat.chemin.append(.profilPersonne(p.nom)) }
    }
}

// ============================================================================
// MARK: - 16. PROFIL D'UNE AUTRE PERSONNE (e067, e040-e044)
// ============================================================================

struct FbProfilPersonneVue: View {
    let personne: FbPersonne
    @ObservedObject var etat: FbEtat

    private var ajoute: Bool { etat.ajoutes.contains(personne.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                couverture
                identite
                boutons
                pointsCommuns
                pills
                informations
                amis
                publications
                Color.clear.frame(height: 96)
            }
        }
        .scrollIndicators(.hidden)
        .background(FbStyle.fond)
        .overlay(alignment: .top) { barreFlottante }
    }

    // -------- bandeau de couverture + boutons flottants (e067)

    private var couverture: some View {
        FbMedia(cle: personne.photo ?? "p31", ratio: 2.6)
            .overlay { Color.black.opacity(0.18) }
    }

    private var barreFlottante: some View {
        HStack {
            Button {
                Haptique.leger()
                if !etat.chemin.isEmpty { etat.chemin.removeLast() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 34, height: 34)
                    .shadow(color: Color.black.opacity(0.5), radius: 3)
            }
            .buttonStyle(.plain)
            Spacer()
            FbActionBarre(glyphe: "magnifyingglass", sombre: true) {
                etat.chemin.append(.recherche)
            }
            Menu {
                Button("Copier le lien du profil") { etat.afficherToast("Lien copié.") }
                Button("Bloquer") { etat.afficherToast("\(personne.nom) a été bloqué(e).") }
                Button(role: .destructive) {
                    etat.afficherToast("Merci, nous avons reçu votre signalement.")
                } label: { Text("Signaler le profil") }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 21))
                    .foregroundStyle(Color.white)
                    .frame(width: 34, height: 34)
            }
        }
        .padding(.horizontal, 8)
    }

    // -------- carte blanche : avatar 90 pt, nom 24 pt, « 76 ami(e)s · 42 publications »

    private var identite: some View {
        HStack(alignment: .center, spacing: 14) {
            FbAvatar(photo: personne.photo, nom: personne.nom, taille: 90, teinte: personne.teinte)
                .overlay(Circle().strokeBorder(Color.white, lineWidth: 3))
            VStack(alignment: .leading, spacing: 3) {
                Text(personne.nom)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.black)
                    .lineLimit(2)
                sousTitre
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }

    private var sousTitre: some View {
        (Text(personne.nbAmis).font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
         + Text(" ami(e)s · ").font(.system(size: 16)).foregroundColor(.black)
         + Text(personne.nbPublications).font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
         + Text(" publications").font(.system(size: 16)).foregroundColor(.black))
    }

    private var boutons: some View {
        HStack(spacing: 10) {
            FbBoutonPlein(titre: ajoute ? "Invitation envoyée" : "Ajouter ami(e)",
                          hauteur: 42, corps: 17, rayon: 8,
                          couleur: ajoute ? FbStyle.grisBouton : FbStyle.bleu,
                          texte: ajoute ? Color.black : Color.white,
                          glyphe: ajoute ? "checkmark" : "person.badge.plus") {
                Haptique.leger()
                if ajoute {
                    etat.ajoutes.remove(personne.id)
                    etat.afficherToast("Invitation annulée.")
                } else {
                    etat.ajoutes.insert(personne.id)
                    etat.afficherToast("Invitation envoyée à \(personne.nom).")
                }
            }
            FbBoutonPlein(titre: "Message", hauteur: 42, corps: 17, rayon: 8,
                          couleur: FbStyle.grisBouton, texte: Color.black,
                          glyphe: "bolt.fill") {
                etat.ouvrirMessenger()
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 14)
    }

    private var pointsCommuns: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 9) {
                Image(systemName: "person.2")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.black)
                Text("Points communs")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.black)
            }
            (Text("Vous avez tou(te)s les deux ajouté ").font(.system(size: 16)).foregroundColor(.black)
             + Text(personne.ville).font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
             + Text(".").font(.system(size: 16)).foregroundColor(.black))
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(FbStyle.sepFin, lineWidth: 1))
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 14)
    }

    private var pills: some View {
        HStack(spacing: 9) {
            FbPillProfil(titre: "Tous", actif: etat.pillProfil == 0) { etat.pillProfil = 0 }
            FbPillProfil(titre: "Photos", actif: etat.pillProfil == 1) { etat.pillProfil = 1 }
            FbPillProfil(titre: "Reels", actif: etat.pillProfil == 2) { etat.pillProfil = 2 }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 16)
    }

    private var informations: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Informations personnelles")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Color.black)
                .padding(.bottom, 10)
            FbRangeeInfo(glyphe: "house", texte: personne.ville)
            FbRangeeInfo(glyphe: "circles.hexagonpath", texte: "Femme")
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 18)
    }

    private var amis: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Ami(e)s")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(Color.black)
                Spacer()
                Button {
                    etat.chemin.append(.vosAmis)
                } label: {
                    Text("Voir tout")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(FbStyle.bleu)
                }
                .buttonStyle(.plain)
            }
            HStack(alignment: .top, spacing: 12) {
                ForEach(DonneesFb.vosAmis.prefix(4), id: \.id) { a in
                    VStack(spacing: 6) {
                        FbAvatar(photo: a.photo, nom: a.nom, taille: 66, teinte: a.teinte)
                        Text(a.nom)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: 74)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 18)
    }

    private var publications: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Toutes les publications")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Color.black)
                .padding(.horizontal, FbStyle.margeH)
                .padding(.bottom, 6)
            FbPostVue(post: DonneesFb.postChloe, etat: etat)
            // TODO tournage — la suite du profil d'un tiers (publications au-delà de la
            // première, onglets Photos/Reels) n'a jamais été filmée : rien n'est inventé.
        }
    }
}

/// Pill d'onglet de profil : « Tous » actif = capsule #D2E7FC + texte bleu, sinon texte nu (e155, e158).
struct FbPillProfil: View {
    let titre: String
    let actif: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(titre)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(actif ? FbStyle.bleu : Color.black)
                .padding(.horizontal, actif ? 20 : 12)
                .frame(height: 36)
                .background(Capsule().fill(actif ? FbStyle.pillBleu : Color.clear))
        }
        .buttonStyle(.plain)
    }
}

/// Rangée « icône en contour + texte » des informations personnelles (e158, e067).
struct FbRangeeInfo: View {
    let glyphe: String
    let texte: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: glyphe)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.black)
                .frame(width: 28)
            Text(texte)
                .font(.system(size: 17))
                .foregroundStyle(Color.black)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 9)
    }
}

// ============================================================================
// MARK: - 17. ONGLET GROUPES (e147-e151)
// ============================================================================

struct FbGroupesVue: View {
    @ObservedObject var etat: FbEtat

    private let colonnes = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    private var visibles: [FbGroupe] {
        DonneesFb.groupes.filter { !etat.groupesRejetes.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    pill
                    Text("Suggestions")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, FbStyle.margeH)
                        .padding(.bottom, 12)
                    LazyVGrid(columns: colonnes, spacing: 14) {
                        ForEach(visibles) { g in
                            FbCarteGroupe(groupe: g, etat: etat)
                        }
                    }
                    .padding(.horizontal, FbStyle.margeH)
                    if visibles.isEmpty { vide }
                    Color.clear.frame(height: 96)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var entete: some View {
        FbBarreHaute(titre: "Groupes",
                     ouvrirTiroir: { withAnimation(.easeOut(duration: 0.25)) { etat.tiroir = true } }) {
            HStack(spacing: 11) {
                Button {
                    // (B) La création de groupe n'a jamais été filmée : message iOS crédible.
                    etat.alerte = FbAlerte(
                        titre: "Création indisponible",
                        message: "Vous n'êtes pas connecté à Internet. Réessayez lorsque la connexion sera rétablie.")
                } label: {
                    Image(systemName: "plus.app")
                        .font(.system(size: 23))
                        .foregroundStyle(Color.black)
                }
                .buttonStyle(.plain)
                FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
                Menu {
                    Button("Vos groupes") { etat.afficherToast("Vous n'avez rejoint aucun groupe.") }
                    Button("Invitations") { etat.afficherToast("Aucune invitation en attente.") }
                } label: {
                    ZStack {
                        Circle().fill(FbStyle.grisBouton).frame(width: 30, height: 30)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.black)
                    }
                    .frame(width: 34, height: 34)
                }
            }
        }
    }

    private var pill: some View {
        HStack(spacing: 9) {
            FbPill(titre: "Découvrir", actif: true) {
                etat.afficherToast("Vous consultez déjà les suggestions.")
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }

    private var vide: some View {
        Text("Plus aucune suggestion de groupe pour le moment.")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 28)
    }
}

/// Carte de groupe : image 118 pt + ✕ de rejet, titre 2 lignes, détail 2 lignes,
/// bouton « Rejoindre » BLEU PLEIN 35 pt qui bascule en « Demande envoyée » (e147).
struct FbCarteGroupe: View {
    let groupe: FbGroupe
    @ObservedObject var etat: FbEtat

    private var rejoint: Bool { etat.rejoints.contains(groupe.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            image
            Text(groupe.nom)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 11)
                .padding(.top, 10)
            Text(groupe.detail)
                .font(.system(size: 14))
                .foregroundStyle(FbStyle.texteGris)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 11)
                .padding(.top, 2)
            Spacer(minLength: 8)
            FbBoutonPlein(titre: rejoint ? "Demande envoyée" : "Rejoindre",
                          hauteur: 35, corps: 16, rayon: 5,
                          couleur: rejoint ? FbStyle.grisBouton : FbStyle.bleu,
                          texte: rejoint ? Color.black : Color.white) {
                Haptique.leger()
                if rejoint {
                    etat.rejoints.remove(groupe.id)
                    etat.afficherToast("Demande annulée.")
                } else {
                    etat.rejoints.insert(groupe.id)
                    etat.afficherToast("Votre demande a été envoyée aux modérateurs du groupe.")
                }
            }
            .padding(.horizontal, 11)
            .padding(.bottom, 11)
        }
        .frame(height: 244)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(FbStyle.sepFin, lineWidth: 1))
    }

    private var image: some View {
        FbImage(cle: groupe.image)
            .frame(height: 118)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) { croix }
            .padding(.horizontal, 1)
            .padding(.top, 1)
    }

    private var croix: some View {
        Button {
            Haptique.leger()
            etat.groupesRejetes.insert(groupe.id)
            etat.afficherToast("Ce groupe ne vous sera plus suggéré.")
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 26, height: 26)
                .background(Circle().fill(Color.black.opacity(0.5)))
        }
        .buttonStyle(.plain)
        .padding(8)
    }
}

// ============================================================================
// MARK: - 18. ONGLET NOTIFICATIONS (e152-e154)
//         Bloc #E2EEFE continu, avatar 60 pt + badge de type bleu 20 pt.
//         Le tap POUSSE le post concerné dans la pile : plus jamais de 2ᵉ fil
//         en fullScreenCover (bug bloquant n° 32 de l'audit).
// ============================================================================

struct FbNotificationsVue: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text("Nouveau")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, FbStyle.margeH)
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                    bloc
                    Color.clear.frame(height: 96)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var entete: some View {
        FbBarreHaute(titre: "Notifications",
                     ouvrirTiroir: { withAnimation(.easeOut(duration: 0.25)) { etat.tiroir = true } }) {
            HStack(spacing: 11) {
                FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
                Menu {
                    Button("Tout marquer comme lu") { etat.afficherToast("Notifications marquées comme lues.") }
                    Button("Paramètres de notification") {
                        etat.afficherToast("Les paramètres ne sont pas disponibles hors connexion.")
                    }
                } label: {
                    ZStack {
                        Circle().fill(FbStyle.grisBouton).frame(width: 30, height: 30)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.black)
                    }
                    .frame(width: 34, height: 34)
                }
            }
        }
    }

    // Un SEUL bloc bleu continu, sans séparateur ni alternance (mesure e152).
    private var bloc: some View {
        VStack(spacing: 0) {
            ForEach(DonneesFb.notifications) { n in
                FbRangeeNotification(notif: n, etat: etat)
            }
        }
        .background(FbStyle.nonLu)
    }
}

struct FbRangeeNotification: View {
    let notif: FbNotif
    @ObservedObject var etat: FbEtat

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            avatar
            texte
            Menu {
                Button("Masquer cette notification") { etat.afficherToast("Notification masquée.") }
                Button("Désactiver ce type de notification") {
                    etat.afficherToast("Vous ne recevrez plus ce type de notification.")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x3A3B3C))
                    .frame(width: 28, height: 22)
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture(perform: ouvrir)
    }

    // (A) Le tap ouvre le post concerné DANS la pile ; sinon il ramène au fil.
    private func ouvrir() {
        Haptique.leger()
        if let cible = notif.postCible {
            etat.chemin.append(.detail(cible))
        } else {
            etat.chemin.append(.voirInvitations)
        }
    }

    private var avatar: some View {
        FbAvatar(photo: notif.photo, nom: "F", taille: 60, teinte: notif.teinte)
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(FbStyle.bleu)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: notif.badge)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.white)
                    )
                    .overlay(Circle().strokeBorder(FbStyle.nonLu, lineWidth: 1.5))
            }
    }

    // Texte en UN bloc : noms en gras, horodatage gris EN FIN DE PHRASE (e152).
    private var texte: some View {
        phrase
            .font(.system(size: 16))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var phrase: Text {
        var t = Text("")
        for s in notif.segments {
            let poids: Font.Weight = s.gras ? Font.Weight.semibold : Font.Weight.regular
            t = t + Text(s.texte)
                .font(.system(size: 16, weight: poids))
                .foregroundColor(Color.black)
        }
        return t + Text(" " + notif.horaire)
            .font(.system(size: 16))
            .foregroundColor(FbStyle.texteGris)
    }
}

// ============================================================================
// MARK: - 19. ONGLET PROFIL (onglet 6) — fidèle à e155, e156, e158
// ============================================================================

struct FbProfilVue: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        VStack(spacing: 0) {
            entete
            pills
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    hautDuProfil
                    FbSeparateurBloc().padding(.vertical, 10)
                    zonePublications
                    // La publication est déjà affichée en entier ici : pas de push vers
                    // un détail dont le contenu n'a pas été filmé.
                    FbPostVue(post: DonneesFb.postProfil, etat: etat, dansDetail: true)
                    basTodo
                    Color.clear.frame(height: 96)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    // -------- barre haute : ☰ · « Sarah Levasseur ▾ » centré · ✏️ · 🔍 · ⋯ (e155)

    private var entete: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeOut(duration: 0.25)) { etat.tiroir = true }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(Color.black)
                    .frame(width: 33, height: 33)
            }
            .buttonStyle(.plain)
            .padding(.leading, 12)

            Spacer(minLength: 4)
            Menu {
                Button("Voir votre profil") { etat.afficherToast("Vous consultez déjà votre profil.") }
                Button("Créer une Page Facebook") {
                    etat.afficherToast("La création de Page n'est pas disponible hors connexion.")
                }
            } label: {
                HStack(spacing: 6) {
                    Text(DonneesFb.moiNom)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.black)
                }
            }
            Spacer(minLength: 4)

            HStack(spacing: 8) {
                FbActionBarre(glyphe: "pencil", taille: 19) {
                    etat.afficherToast("La modification du profil n'est pas disponible hors connexion.")
                }
                FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
                FbActionBarre(glyphe: "ellipsis.circle") {
                    etat.afficherToast("Les paramètres du profil ne sont pas disponibles hors connexion.")
                }
            }
            .padding(.trailing, 8)
        }
        .frame(height: 47)
        .background(FbStyle.fond)
    }

    private var pills: some View {
        HStack(spacing: 9) {
            FbPillProfil(titre: "Tous", actif: etat.pillProfil == 0) { etat.pillProfil = 0 }
            FbPillProfil(titre: "Photos", actif: etat.pillProfil == 1) { etat.pillProfil = 1 }
            FbPillProfil(titre: "Reels", actif: etat.pillProfil == 2) { etat.pillProfil = 2 }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 8)
        .background(FbStyle.fond)
    }

    private var hautDuProfil: some View {
        VStack(alignment: .leading, spacing: 0) {
            identite
            lieu
            boutons
            informations
            amis
        }
    }

    private var zonePublications: some View {
        VStack(alignment: .leading, spacing: 0) {
            toutesLesPublications
            composer
            chips
            gererLesPublications
        }
    }

    // -------- identité (e158) : avatar 90 pt, nom 24 pt, « 5 amis · 3 publications »

    private var identite: some View {
        HStack(alignment: .center, spacing: 14) {
            FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 90, teinte: 0x5B7CFA)
            VStack(alignment: .leading, spacing: 3) {
                Text(DonneesFb.moiNom)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                (Text("5").font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
                 + Text(" amis · ").font(.system(size: 16)).foregroundColor(.black)
                 + Text("3").font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
                 + Text(" publications").font(.system(size: 16)).foregroundColor(.black))
            }
            Spacer(minLength: 0)
            Menu {
                Button("Voir la photo de profil") {
                    etat.visionneuse = FbCibleVisionneuse(id: "moi", post: DonneesFb.postProfil, index: 0)
                }
                Button("Partager une note…") {
                    etat.afficherToast("Les notes ne sont pas disponibles hors connexion.")
                }
            } label: {
                ZStack {
                    Circle().fill(FbStyle.grisBouton).frame(width: 32, height: 32)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.black)
                }
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    private var lieu: some View {
        HStack(spacing: 9) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 16))
                .foregroundStyle(Color.black)
            Text("Lyon 3ᵉ")
                .font(.system(size: 17))
                .foregroundStyle(Color.black)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 12)
    }

    private var boutons: some View {
        HStack(spacing: 10) {
            FbBoutonPlein(titre: "Ajouter à la story", hauteur: 42, corps: 17, rayon: 8,
                          glyphe: "plus.circle") {
                etat.alerte = FbAlerte(titre: "Appareil photo indisponible",
                                       message: "Facebook n'a pas accès à l'appareil photo. Vous pouvez l'autoriser dans Réglages.")
            }
            FbBoutonPlein(titre: "Modifier le profil", hauteur: 42, corps: 17, rayon: 8,
                          couleur: FbStyle.grisBouton, texte: Color.black,
                          glyphe: "pencil") {
                etat.afficherToast("La modification du profil n'est pas disponible hors connexion.")
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 18)
    }

    private var informations: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Informations personnelles")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(Color.black)
                Spacer()
                Button {
                    etat.afficherToast("La modification du profil n'est pas disponible hors connexion.")
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.black)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
            FbRangeeInfo(glyphe: "mappin.and.ellipse", texte: "Lyon 3ᵉ")
            FbRangeeInfo(glyphe: "house", texte: "Lyon")
            FbRangeeInfo(glyphe: "birthday.cake", texte: "14 mars 1994")
            FbRangeeInfo(glyphe: "circles.hexagonpath", texte: "Femme")
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 18)
    }

    private var amis: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Ami(e)s")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(Color.black)
                Spacer()
                Button {
                    etat.chemin.append(.vosAmis)
                } label: {
                    Text("Voir tout")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(FbStyle.bleu)
                }
                .buttonStyle(.plain)
            }
            HStack(alignment: .top, spacing: 12) {
                ForEach(DonneesFb.vosAmis.prefix(4), id: \.id) { a in
                    Button {
                        etat.chemin.append(.profilPersonne(a.nom))
                    } label: {
                        VStack(spacing: 6) {
                            FbAvatar(photo: a.photo, nom: a.nom, taille: 66, teinte: a.teinte)
                            Text(a.nom)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(width: 74)
                        }
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 6)
    }

    // -------- « Toutes les publications » + « Filtres » (e155)

    private var toutesLesPublications: some View {
        HStack {
            Text("Toutes les publications")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Color.black)
            Spacer()
            Button {
                etat.afficherToast("Les filtres ne sont pas disponibles hors connexion.")
            } label: {
                Text("Filtres")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(FbStyle.bleu)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 10)
    }

    private var composer: some View {
        HStack(spacing: 12) {
            FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 40, teinte: 0x5B7CFA)
            Text("Quoi de neuf ?")
                .font(.system(size: 17))
                .foregroundStyle(Color.black)
            Spacer()
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: 0x3A3B3C))
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            etat.alerte = FbAlerte(titre: "Publication indisponible",
                                   message: "Vous n'êtes pas connecté à Internet. Réessayez lorsque la connexion sera rétablie.")
        }
    }

    // -------- chips « 📹 Réel » / « 🔴 En direct » sur bande grise (e155)

    private var chips: some View {
        HStack(spacing: 12) {
            chip(titre: "Reel", glyphe: "play.rectangle.fill", teinte: 0xF3425F) {
                etat.onglet = 1
            }
            chip(titre: "En direct", glyphe: "video.fill", teinte: 0xD62C2C) {
                etat.alerte = FbAlerte(titre: "Appareil photo indisponible",
                                       message: "Facebook n'a pas accès à l'appareil photo. Vous pouvez l'autoriser dans Réglages.")
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
        .background(Color(hex: 0xF0F1F3))
    }

    private func chip(titre: String, glyphe: String, teinte: UInt,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: glyphe)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: teinte))
                Text(titre)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.black)
            }
            .padding(.horizontal, 22)
            .frame(height: 42)
            .background(Capsule().fill(Color.white))
        }
        .buttonStyle(.plain)
    }

    private var gererLesPublications: some View {
        Button {
            etat.afficherToast("La gestion des publications n'est pas disponible hors connexion.")
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.on.rectangle")
                    .font(.system(size: 16, weight: .medium))
                Text("Gérer les publications")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(Color.black)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(RoundedRectangle(cornerRadius: 8).fill(FbStyle.grisBouton))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 12)
    }

    // TODO tournage : le bas du profil (au-delà de la 1ʳᵉ publication, onglets
    // Photos/Reels, menu du chevron ▾) n'a jamais été filmé — rien n'est inventé.
    private var basTodo: some View {
        Text("Vous avez tout vu.")
            .font(.system(size: 14))
            .foregroundStyle(FbStyle.texteGris)
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
    }
}

// ============================================================================
// MARK: - 20. RECHERCHE (e067) — écran jamais filmé en saisie : sobre + TODO
// ============================================================================

struct FbRechercheVue: View {
    @ObservedObject var etat: FbEtat
    @State private var saisie = ""
    @FocusState private var actif: Bool

    private var motsClefs: [String] {
        let t = saisie.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return [] }
        return DonneesFb.personnes.map { $0.nom }
            .filter { $0.localizedCaseInsensitiveContains(t) }
    }

    var body: some View {
        VStack(spacing: 0) {
            barre
            FbHairline()
            contenu
            Spacer(minLength: 0)
        }
        .background(FbStyle.fond)
        .onAppear { actif = true }
    }

    private var barre: some View {
        HStack(spacing: 8) {
            Button {
                Haptique.leger()
                if !etat.chemin.isEmpty { etat.chemin.removeLast() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(Color.black)
                    .frame(width: 32, height: 34)
            }
            .buttonStyle(.plain)
            champ
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    private var champ: some View {
        HStack(spacing: 9) {
            TextField("", text: $saisie,
                      prompt: Text("Rechercher sur Facebook").foregroundColor(FbStyle.texteGris))
                .font(.system(size: 17))
                .foregroundStyle(Color.black)
                .focused($actif)
                .submitLabel(.search)
            if !saisie.isEmpty {
                Button {
                    saisie = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(FbStyle.texteGris)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
        .background(Capsule().fill(FbStyle.champ))
    }

    @ViewBuilder
    private var contenu: some View {
        if saisie.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            vide
        } else if motsClefs.isEmpty {
            aucunResultat
        } else {
            resultats
        }
    }

    // État vide filmé (e067) : rien, pas d'historique inventé.
    private var vide: some View {
        VStack(spacing: 8) {
            Text("Recherches récentes")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Text("Aucune recherche récente.")
                .font(.system(size: 15))
                .foregroundStyle(FbStyle.texteGris)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 18)
        // TODO tournage : la saisie en cours, les suggestions et la page de
        // résultats n'ont jamais été filmées — l'écran reste volontairement sobre.
    }

    private var aucunResultat: some View {
        Text("Aucun résultat pour « \(saisie) ».")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 20)
    }

    private var resultats: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(motsClefs, id: \.self) { nom in
                    rangee(DonneesFb.personne(nom))
                }
                Color.clear.frame(height: 96)
            }
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
    }

    private func rangee(_ p: FbPersonne) -> some View {
        Button {
            etat.chemin.append(.profilPersonne(p.nom))
        } label: {
            HStack(spacing: 13) {
                FbAvatar(photo: p.photo, nom: p.nom, taille: 48, teinte: p.teinte)
                VStack(alignment: .leading, spacing: 2) {
                    Text(p.nom)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.black)
                    Text(p.detail ?? p.ville)
                        .font(.system(size: 14))
                        .foregroundStyle(FbStyle.texteGris)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, FbStyle.margeH)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 21. MENU = TIROIR LATÉRAL GAUCHE 358 pt (e103, e105, e106)
// ============================================================================

struct FbRaccourciMenu: Identifiable {
    let id: String            // le titre sert d'identifiant : il est unique dans la liste
    let glyphe: String
}

struct FbLienMeta: Identifiable {
    let id: String
    let titre: String
    let sousTitre: String?
    let glyphe: String
    let teinte: UInt
    let grande: Bool
}

struct FbMenuTiroir: View {
    @ObservedObject var etat: FbEtat
    @State private var misesANiveau = true        // e103 : déployée par défaut (chevron HAUT)
    @State private var produitsMeta = true        // e105 : déployée
    @State private var aide = false               // jamais filmée dépliée
    @State private var parametres = false         // jamais filmée dépliée

    private let raccourcis: [FbRaccourciMenu] = [
        FbRaccourciMenu(id: "Meta AI", glyphe: "sparkles"),
        FbRaccourciMenu(id: "Enregistrements", glyphe: "bookmark"),
        FbRaccourciMenu(id: "Souvenirs", glyphe: "clock.arrow.circlepath"),
        FbRaccourciMenu(id: "Marketplace", glyphe: "storefront"),
        FbRaccourciMenu(id: "Fils", glyphe: "dot.radiowaves.up.forward")
    ]

    private let promos: [FbLienMeta] = [
        FbLienMeta(id: "pp", titre: "Présence publique",
                   sousTitre: "Obtenez des outils qui vous aident à vous d…",
                   glyphe: "sparkles.rectangle.stack", teinte: 0x8E44AD, grande: true),
        FbLienMeta(id: "fp", titre: "Facebook Plus",
                   sousTitre: "Débloquez des fonctionnalités exclu…",
                   glyphe: "star.circle.fill", teinte: 0x0C59FD, grande: true)
    ]

    private let produits: [FbLienMeta] = [
        FbLienMeta(id: "quest", titre: "Meta Quest 3S",
                   sousTitre: "Découvrez notre dernier casque de ré…",
                   glyphe: "cube.transparent", teinte: 0x5B7CFA, grande: true),
        FbLienMeta(id: "rayban", titre: "Ray-Ban Meta",
                   sousTitre: "La nouvelle génération de lunettes IA",
                   glyphe: "eyeglasses", teinte: 0x1C1C1E, grande: true),
        FbLienMeta(id: "metaai", titre: "Meta AI",
                   sousTitre: "Obtenez des réponses, créez tout…",
                   glyphe: "sparkles", teinte: 0x8E44AD, grande: true),
        FbLienMeta(id: "whatsapp", titre: "WhatsApp", sousTitre: nil,
                   glyphe: "phone.circle.fill", teinte: 0x25D366, grande: false),
        FbLienMeta(id: "edits", titre: "Edits", sousTitre: nil,
                   glyphe: "wand.and.stars", teinte: 0xE1306C, grande: false),
        FbLienMeta(id: "threads", titre: "Threads", sousTitre: nil,
                   glyphe: "at", teinte: 0x1C1C1E, grande: false),
        FbLienMeta(id: "instagram", titre: "Instagram", sousTitre: nil,
                   glyphe: "camera.circle.fill", teinte: 0xE1306C, grande: false),
        FbLienMeta(id: "horizon", titre: "Meta Horizon", sousTitre: nil,
                   glyphe: "gamecontroller.fill", teinte: 0x0C59FD, grande: false)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                haut
                sectionsRepliables
                sectionsDepliees
                boutonDeconnexion
                Color.clear.frame(height: 60)
            }
            .padding(.top, 10)
        }
        .scrollIndicators(.hidden)
        .background(FbStyle.fond)
    }

    private var haut: some View {
        VStack(alignment: .leading, spacing: 0) {
            carteProfil
            listeRaccourcis
            boutonVoirPlus
        }
    }

    // « Aide et assistance » / « Paramètres et confidentialité » : jamais filmées dépliées.
    private var sectionsRepliables: some View {
        VStack(alignment: .leading, spacing: 0) {
            FbHairline()
            sectionChevron(titre: "Aide et assistance", glyphe: "questionmark.circle",
                           ouverte: aide) { aide.toggle() }
            contenuSobre(aide, "Centre d'aide indisponible hors connexion.")
            FbHairline()
            sectionChevron(titre: "Paramètres et confidentialité", glyphe: "gearshape",
                           ouverte: parametres) { parametres.toggle() }
            contenuSobre(parametres, "Les paramètres ne sont pas disponibles hors connexion.")
        }
    }

    // « Mises à niveau » et « Autres produits Meta » : filmées DÉPLIÉES (e103, e105).
    private var sectionsDepliees: some View {
        VStack(alignment: .leading, spacing: 0) {
            FbHairline()
            sectionChevron(titre: "Mises à niveau", glyphe: "square.on.circle",
                           ouverte: misesANiveau) { misesANiveau.toggle() }
            if misesANiveau { grille(promos) }
            FbHairline()
            sectionChevron(titre: "Autres produits Meta", glyphe: "square.grid.3x3.fill",
                           ouverte: produitsMeta) { produitsMeta.toggle() }
            if produitsMeta { grille(produits) }
        }
    }

    // -------- 1. carte blanche : avatar + nom + chevron cerclé / « Créer une Page Facebook »

    private var carteProfil: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeOut(duration: 0.22)) { etat.tiroir = false }
                etat.onglet = 5
            } label: {
                HStack(spacing: 12) {
                    FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 40, teinte: 0x5B7CFA)
                    Text(DonneesFb.moiNom)
                        .font(.system(size: 19))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    ZStack {
                        Circle().fill(FbStyle.grisBouton).frame(width: 32, height: 32)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.black)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            FbHairline()

            Button {
                etat.afficherToast("La création de Page n'est pas disponible hors connexion.")
            } label: {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: 0x3A3B3C))
                        .frame(width: 34, height: 34)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.white)
                        )
                    Text("Créer une Page Facebook")
                        .font(.system(size: 17))
                        .foregroundStyle(FbStyle.texteGris)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(FbStyle.sepFin, lineWidth: 1))
        .padding(.horizontal, 14)
        .padding(.bottom, 12)
    }

    // -------- 2. liste 60 pt, icônes NOIRES EN CONTOUR à x = 32 pt

    private var listeRaccourcis: some View {
        VStack(spacing: 0) {
            ForEach(raccourcis) { r in
                Button {
                    action(r.id)
                } label: {
                    HStack(spacing: 18) {
                        Image(systemName: r.glyphe)
                            .font(.system(size: 21, weight: .regular))
                            .foregroundStyle(Color.black)
                            .frame(width: 28)
                        Text(r.id)
                            .font(.system(size: 18))
                            .foregroundStyle(Color.black)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 60)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func action(_ titre: String) {
        Haptique.leger()
        switch titre {
        case "Enregistrements":
            etat.afficherToast(etat.enregistres.isEmpty
                               ? "Vous n'avez enregistré aucune publication."
                               : "\(etat.enregistres.count) publication(s) enregistrée(s).")
        case "Marketplace":
            etat.alerte = FbAlerte(titre: "Marketplace indisponible",
                                   message: "Marketplace n'est pas disponible dans votre pays ou votre région.")
        default:
            etat.alerte = FbAlerte(titre: titre,
                                   message: "\(titre) n'est pas disponible hors connexion.")
        }
    }

    // -------- 3. bouton « Voir plus » #DCE0E3, 33 pt, r 10 pt

    private var boutonVoirPlus: some View {
        FbBoutonPlein(titre: "Voir plus", hauteur: 33, corps: 16, rayon: 10,
                      couleur: FbStyle.grisBouton, texte: Color.black) {
            etat.afficherToast("Le reste du menu n'est pas disponible hors connexion.")
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }

    // -------- 4/5. sections à chevron

    private func sectionChevron(titre: String, glyphe: String, ouverte: Bool,
                                action: @escaping () -> Void) -> some View {
        Button {
            Haptique.leger()
            withAnimation(.easeOut(duration: 0.18)) { action() }
        } label: {
            HStack(spacing: 18) {
                Image(systemName: glyphe)
                    .font(.system(size: 21, weight: .regular))
                    .foregroundStyle(Color.black)
                    .frame(width: 28)
                Text(titre)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: ouverte ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.black)
            }
            .padding(.horizontal, 18)
            .frame(height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // Sections jamais filmées dépliées : contenu volontairement sobre (TODO tournage).
    @ViewBuilder
    private func contenuSobre(_ ouverte: Bool, _ message: String) -> some View {
        if ouverte {
            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(FbStyle.texteGris)
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
        }
    }

    // -------- grilles de cartes (promos e103/e105, produits Meta e105)

    private func grille(_ liste: [FbLienMeta]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                  alignment: .leading, spacing: 10) {
            ForEach(liste) { l in
                carteMeta(l)
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }

    private func carteMeta(_ l: FbLienMeta) -> some View {
        Button {
            etat.alerte = FbAlerte(titre: l.titre,
                                   message: "\(l.titre) n'est pas installé sur cet iPhone.")
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                if l.grande {
                    LinearGradient(colors: [Color(hex: l.teinte).opacity(0.85),
                                            Color(hex: l.teinte).opacity(0.45)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(height: 78)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(alignment: .bottomLeading) {
                            Image(systemName: l.glyphe)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color(hex: l.teinte))
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(Color.white))
                                .padding(8)
                        }
                } else {
                    Image(systemName: l.glyphe)
                        .font(.system(size: 21))
                        .foregroundStyle(Color(hex: l.teinte))
                        .padding(.top, 4)
                }
                Text(l.titre)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                if let s = l.sousTitre {
                    Text(s)
                        .font(.system(size: 13))
                        .foregroundStyle(FbStyle.texteGris)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(FbStyle.sepFin, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // -------- 6. déconnexion

    private var boutonDeconnexion: some View {
        FbBoutonPlein(titre: "Déconnexion", hauteur: 44, corps: 17, rayon: 8,
                      couleur: FbStyle.grisBouton, texte: Color.black) {
            etat.alerte = FbAlerte(titre: "Déconnexion impossible",
                                   message: "Vous n'êtes pas connecté à Internet. Réessayez lorsque la connexion sera rétablie.")
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
    }
}

// ============================================================================
// MARK: - 22. ACCÈS CAPTURE (registre EcranCapture.ecransFacebook — aucun état externe)
// ============================================================================

enum FbCapture {
    /// État neuf pour une capture isolée : aucune dépendance, aucun singleton mutable.
    static func etat() -> FbEtat { FbEtat() }

    static func post(_ id: String) -> FbPost { DonneesFb.post(id) }
}
