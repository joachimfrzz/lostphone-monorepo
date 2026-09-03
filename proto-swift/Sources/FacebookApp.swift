// Facebook — v3.1 D92 (03/09 soir) — retours 279
//
// Base : v3 D91 (build 279), reconstruite contre les 159 frames de Joachim (mesures audit/facebook.md).
//
// Doctrines appliquées :
//  · D67 — la référence est l'enregistrement de Joachim (refs/t2/facebook/e001…e159, 1 pt = 1,5 px).
//  · D82 — aucun bouton mort : chaque commande agit (A), répond par un message iOS crédible (B, rare),
//           ou a été retirée (C). Les retraits sont annotés « (C) » dans le code.
//  · D59 — contenu Sarah remplaçable (Lyon, Chloé Berthier, Sylvie Lavisse côté nom Facebook).
//           Marc n'apparaît NULLE PART sur Facebook : son absence est l'indice.
//  · D92 — « juste milieu » : moins de fonctionnalités, mais une expérience cohérente. Tout compteur
//           affiché est égal au contenu RÉELLEMENT accessible ; toute action produit un état qui change
//           et persiste ; aucun état (message, feuille, toast) ne survit à l'écran qui l'a produit.
//
// ---------------------------------------------------------------------------------------------------
// CORRECTIF PRIORITAIRE DU LOT 280 — BUG DE NAVIGATION (Joachim sortait sur son VRAI iPhone)
// ---------------------------------------------------------------------------------------------------
// Diagnostic (comparaison avec MailApp.swift, app claire validée) :
//   1. Mail pose `BarreHome { dismiss() }` DANS la zone sûre (dernier élément d'un ZStack .bottom,
//      sans `.ignoresSafeArea`). La v3 de Facebook posait `barresBasses` avec
//      `.ignoresSafeArea(edges: .bottom)` : la fausse capsule descendait EXACTEMENT dans la bande de
//      gestes système du bas d'écran. Le geste de balayage vers le haut y est capté par iOS
//      (`.defersSystemGestures` ne fait que retarder d'un balayage) → sortie vers l'accueil réel.
//      → CORRIGÉ : `FbPiedHome` garde la capsule dans la zone sûre, à la même hauteur que Mail ;
//        seul le FOND s'étend sous la zone sûre.
//   2. Le tiroir latéral (358 pt) était dessiné APRÈS `barresBasses` dans le ZStack et couvrait la
//      fausse capsule : tiroir ouvert, plus aucune barre home visible → le joueur visait la vraie.
//      → CORRIGÉ : le tiroir est dessiné SOUS la barre d'onglets et SOUS `FbPiedHome`, qui est
//        le DERNIER calque du ZStack (c'est aussi le comportement du vrai Facebook : la barre
//        d'onglets reste visible quand le Menu est ouvert).
//   3. `.persistentSystemOverlays(.hidden)` et `.defersSystemGestures(on: .bottom)` posés par
//      `coquilleSarah(claire: true)` sur `FacebookVue` NE SE PROPAGENT PAS aux vues présentées
//      (`sheet` / `fullScreenCover`) : dans la feuille de partage, les commentaires de reel, la
//      visionneuse et la story, la VRAIE barre home iOS réapparaissait.
//      → CORRIGÉ À LA RACINE : Facebook n'utilise PLUS AUCUN `sheet` ni `fullScreenCover`.
//        Les cinq vues « présentées » (partage, composeur, commentaires de reel, visionneuse,
//        story) sont des CALQUES de la ZStack de `FacebookVue` : elles héritent donc de
//        `coquilleSarah`, et `fbCoquePresentee()` ne sert plus que de ceinture de sécurité
//        pour les captures isolées du registre `EcranCapture`.
//   4. Les deux feuilles (partage, commentaires de reel) n'avaient AUCUNE `BarreHome`.
//      → CORRIGÉ : il n'existe plus qu'UNE capsule, dessinée par `FacebookVue` au-dessus de
//        tous les calques (tiroir et vues présentées inclus) ; chaque calque lui réserve
//        `FbStyle.hauteurPied` en bas. Une seule capsule, toujours visible, jamais doublée.
//   5. Contraste : sur fond blanc la capsule doit être NOIRE (`sombre: true`), sur fond noir BLANCHE
//      (`sombre: false`). Vérifié écran par écran.
// Un correctif de racine reste à appliquer dans LPProto (fond `.ultraThinMaterial` de `BarreSarah`
// qui avale les taps du haut d'écran) : diff proposé dans src/patches/facebook-lpproto-v31.md.
// ---------------------------------------------------------------------------------------------------
//
// Points d'entrée publics : FacebookVue() (racine appelée par la coque) et les vues citées par
// EcranCapture.ecransFacebook() (cf. src/patches/facebook-lpproto-v31.md, corps EXACT à coller).
//
// v3.1 D92 (03/09 soir) — retours 279
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
    static let filReponse   = Color(hex: 0xCED0D4)   // filet vertical des réponses dépliées

    static let margeH: CGFloat = 13                  // marge horizontale du fil (19 px)
    static let hauteurBarre: CGFloat = 52            // barre d'onglets hors BarreHome
    /// Hauteur occupée par la capsule home de Sarah (BarreHome : 9 + 5 + 5 pt), à réserver
    /// en bas de tout écran poussé pour ne jamais passer sous elle.
    static let hauteurPied: CGFloat = 24
    /// Hauteur réservée en bas des listes d'onglet : barre d'onglets + pied home.
    static let reserveBas: CGFloat = 104
}

// ============================================================================
// MARK: - 2. MODÈLE
// ============================================================================

struct FbSegment {
    let texte: String
    var gras: Bool = false
}

/// Un commentaire. `fils` = les réponses RÉELLES : le compteur « Voir les N réponses »
/// vaut `fils.count`, et le dépliage affiche ces réponses (D92 — plus jamais de message
/// « hors connexion » à la place du contenu annoncé).
struct FbCommentaire: Identifiable {
    let id: String
    var auteur: String
    var photo: String? = nil
    var teinte: UInt = 0xB0B3B8
    var date: String
    var mention: String? = nil        // « Mathieu Guerin » en bleu en tête de texte (e015)
    var texte: String
    var likes: Int = 0
    var estAuteur: Bool = false       // pastille « ✎ Auteur » (e122)
    var fils: [FbCommentaire] = []

    var nbReponses: Int { fils.count }
}

struct FbPost: Identifiable {
    let id: String
    var auteur: String
    var photoAuteur: String? = nil
    var teinteAuteur: UInt = 0x0C59FD
    var verifie: Bool = false
    var suivre: Bool = false           // « · Suivre » en lien bleu à côté du nom
    var groupeId: String? = nil        // post de groupe : « · Rejoindre » lié à ce groupe
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
    var estLien: Bool = false          // 4ᵉ bouton « Enregistrer »
    var commentaires: [FbCommentaire] = []
    /// Noms des personnes qui ont partagé la publication. D92 : le compteur « N partages »
    /// vaut `partages.count` et l'écran « Personnes qui ont partagé ça » liste EXACTEMENT ces noms.
    var partages: [String] = []
    /// Publication créée par Sarah depuis le composeur minimal (pas de menu ⋯ / ✕ dessus).
    var deSarah: Bool = false

    var nbPartages: Int { partages.count }
    var rejoindre: Bool { groupeId != nil }
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
    var ville: String = "Lyon"
    var estPage: Bool = false          // Page / Créateur (Reels, actualités) et non une personne
}

struct FbGroupe: Identifiable {
    let id: String
    var nom: String
    var type: String                   // « Privé » / « Public »
    var membres: String                // « 8,9 K membres »
    var image: String

    var detail: String { "Groupe (" + type + ") · " + membres }
}

struct FbNotif: Identifiable {
    let id: String
    var photo: String? = nil
    var teinte: UInt = 0xB0B3B8
    var badge: String                  // glyphe SF du badge bleu de type (e152)
    var segments: [FbSegment]
    var horaire: String
    var postCible: String? = nil       // identifiant du post ouvert au tap (jamais un 2ᵉ fil)
    var personneCible: String? = nil   // ou nom de profil ouvert au tap
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
    var partages: Int
    var enregistrements: Int
    var fils: [FbCommentaire]

    /// D92 : « N commentaires » = nombre de commentaires réellement ouvrables.
    var nbCommentaires: Int { fils.count }
}

// ============================================================================
// MARK: - 3. DONNÉES SARAH (D59 — Lyon, Chloé, Sylvie Lavisse ; aucun Marc)
// ============================================================================

enum DonneesFb {

    static let moiNom = "Sarah Levasseur"
    static let moiPhoto = "p04"
    static let moiVille = "Lyon 3ᵉ"

    /// Clés de pellicule proposées par le composeur minimal (filtrées à l'affichage
    /// selon ce que ChargeurPhoto sait charger : jamais de vignette vide).
    static let pellicule: [String] = ["p04", "p12", "p18", "p22", "p24", "p26", "p27", "p30", "p31", "p33", "p36"]

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
        commentaires: [
            FbCommentaire(id: "v1", auteur: "Gaëlle Capitaine", photo: "p22", date: "3 h",
                          texte: "On y était hier soir, magique 😍", likes: 12),
            FbCommentaire(id: "v2", auteur: "Aurore Dauriac", teinte: 0xE64980, date: "4 h",
                          mention: "Chloé Berthier", texte: "on se refait les quais dimanche ?", likes: 3,
                          fils: [
                            FbCommentaire(id: "v2r1", auteur: "Chloé Berthier", photo: "p12", teinte: 0xE64980,
                                          date: "3 h", texte: "Carrément, je ramène le thermos ☕", likes: 2),
                            FbCommentaire(id: "v2r2", auteur: "Aurore Dauriac", teinte: 0xE64980, date: "3 h",
                                          texte: "Rendez-vous 10 h passerelle du Palais de Justice alors.", likes: 1)
                          ]),
            FbCommentaire(id: "v3", auteur: "Francis Baron", teinte: 0x5B7CFA, date: "5 h",
                          texte: "Et les vélos sur la piste piétonne, personne n'en parle…", likes: 8),
            FbCommentaire(id: "v4", auteur: "Paulette Vinot", teinte: 0xFF9F0A, date: "5 h",
                          texte: "Superbe photo, bravo au photographe 👏", likes: 2),
            FbCommentaire(id: "v5", auteur: "Karine Cabrero", teinte: 0x30D1C4, date: "4 h",
                          texte: "La Feyssine c'est ouvert jusqu'à quelle heure le dimanche ?", likes: 1,
                          fils: [
                            FbCommentaire(id: "v5r1", auteur: "Lyon Ma Ville", teinte: 0x0C59FD, date: "4 h",
                                          texte: "Baignade surveillée de 11 h à 19 h tout le week-end.",
                                          likes: 6, estAuteur: true)
                          ]),
            FbCommentaire(id: "v6", auteur: "Didier Ovenberghe", teinte: 0x5B7CFA, date: "2 h",
                          texte: "27 °C en septembre… on s'habitue trop vite.", likes: 4)
        ],
        partages: ["Paul Hubert", "Didier Ovenberghe", "Amélie Lalanne", "Aurélie Deyries"])

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
        commentaires: [
            FbCommentaire(id: "d1", auteur: "Sofiane Belkacem", teinte: 0x30D1C4, date: "2 j",
                          texte: "Attention aux frais cachés, lisez les CGV avant.", likes: 41,
                          fils: [
                            FbCommentaire(id: "d1r1", auteur: "Marie-Pierre Fourez", teinte: 0xE64980, date: "2 j",
                                          texte: "Merci du conseil, j'allais m'inscrire.", likes: 7)
                          ]),
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
        commentaires: [
            FbCommentaire(id: "p1", auteur: "Chloé Berthier", photo: "p12", date: "1 j",
                          texte: "Je m'inscris au mardi, je viens avec Sarah 🙌", likes: 6),
            FbCommentaire(id: "p2", auteur: "Inès Djellal", photo: "p22", teinte: 0x8E44AD, date: "22 h",
                          texte: "Il reste de la place au jeudi ?", likes: 1,
                          fils: [
                            FbCommentaire(id: "p2r1", auteur: "Atelier Poterie Lyon 3", teinte: 0xFF9F0A, date: "21 h",
                                          texte: "Oui, 2 places au jeudi 19 h. Envoyez-nous un message 🙂",
                                          likes: 3, estAuteur: true)
                          ]),
            FbCommentaire(id: "p3", auteur: "Léa Moreau", photo: "p18", teinte: 0x30D1C4, date: "20 h",
                          texte: "Le tour c'est vraiment accessible aux débutantes ?", likes: 4)
        ],
        partages: ["Chloé Berthier", "Inès Djellal"])

    static let postGroupe = FbPost(
        id: "retouches",
        auteur: "Retouches photos Lyon — Entraide",
        teinteAuteur: 0x8E44AD,
        groupeId: "g5",
        sousLigne: "Ghislaine Lacan · 3 h",
        horaire: "3 h",
        texte: "Bonsoir, quelqu'un saurait ouvrir les boutons de la veste de mon fils sur la photo svp, merci 🙏",
        photos: ["p30"],
        ratio: 0.75,
        reactions: ["👍"],
        nbReactions: 24,
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
                          likes: 8,
                          fils: [
                            FbCommentaire(id: "l4r1", auteur: "Karine Cabrero", teinte: 0x30D1C4, date: "3 j",
                                          texte: "La piste cyclable du quai est un vrai danger la nuit, sans éclairage.",
                                          likes: 5)
                          ]),
            FbCommentaire(id: "l5", auteur: "Karine Cabrero", teinte: 0x30D1C4, date: "3 j",
                          texte: "J'ai lu brièvement l'article, ce serait les pompiers de Caluire qui sont arrivés les premiers.",
                          likes: 2)
        ],
        partages: ["Paul Hubert", "Karine Cabrero", "Francis Baron"])

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
        commentaires: [
            FbCommentaire(id: "gn1", auteur: "Evelyne Guitonneau", teinte: 0xE64980, date: "6 j",
                          texte: "J'ai « gagné » et on m'a demandé mes coordonnées bancaires. Fuyez.", likes: 214),
            FbCommentaire(id: "gn2", auteur: "Seb Cbien", teinte: 0x5B7CFA, date: "5 j",
                          texte: "Encore une arnaque, signalez la page.", likes: 96,
                          fils: [
                            FbCommentaire(id: "gn2r1", auteur: "Sofiane Belkacem", teinte: 0x30D1C4, date: "5 j",
                                          texte: "Signalée. Ils changent de nom toutes les deux semaines.", likes: 31),
                            FbCommentaire(id: "gn2r2", auteur: "Christiane Damotte", teinte: 0xFF9F0A, date: "4 j",
                                          texte: "Ma voisine a perdu 900 € avec le même genre de page 😞", likes: 44),
                            FbCommentaire(id: "gn2r3", auteur: "Paul Hubert", teinte: 0x5B7CFA, date: "4 j",
                                          texte: "Ne cliquez jamais sur « Accepter ». Jamais.", likes: 18)
                          ])
        ],
        partages: ["Evelyne Guitonneau", "Seb Cbien"])

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
        commentaires: [
            FbCommentaire(id: "cl1", auteur: "Sarah Levasseur", photo: "p04", teinte: 0x5B7CFA, date: "9 j",
                          texte: "La meilleure c'est toi 💙", likes: 5),
            FbCommentaire(id: "cl2", auteur: "Léa Moreau", photo: "p18", teinte: 0x30D1C4, date: "8 j",
                          texte: "Vous m'avez trop manqué les filles", likes: 2),
            FbCommentaire(id: "cl3", auteur: "Julie Ferrand", teinte: 0xFF9F0A, date: "8 j",
                          texte: "Il est où ce lac ?? 😍", likes: 1,
                          fils: [
                            FbCommentaire(id: "cl3r1", auteur: "Chloé Berthier", photo: "p12", teinte: 0xE64980,
                                          date: "8 j", texte: "Lac des Sapins, à 1 h de Lyon 🌲",
                                          likes: 4, estAuteur: true),
                            FbCommentaire(id: "cl3r2", auteur: "Julie Ferrand", teinte: 0xFF9F0A, date: "8 j",
                                          texte: "Noté pour le prochain week-end !", likes: 1),
                            FbCommentaire(id: "cl3r3", auteur: "Inès Djellal", photo: "p22", teinte: 0x8E44AD,
                                          date: "7 j", texte: "On y va toutes les quatre alors 🙌", likes: 3)
                          ])
        ],
        partages: ["Léa Moreau"])

    // ------------------------------------------------ publications de Sarah (e155-e158)
    // D92 : « 3 publications » sur le profil = ces 3 publications, réellement ouvrables.

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
        commentaires: [
            FbCommentaire(id: "sp1", auteur: "Chloé Berthier", photo: "p12", date: "12 sept. 2021",
                          texte: "Trop belle 😍", likes: 4),
            FbCommentaire(id: "sp2", auteur: "Léa Moreau", photo: "p18", teinte: 0x30D1C4, date: "12 sept. 2021",
                          texte: "Enfin une vraie photo de toi 🙌", likes: 2)
        ],
        deSarah: true)

    static let postSarahPoterie = FbPost(
        id: "sarah2",
        auteur: "Sarah Levasseur",
        photoAuteur: "p04",
        teinteAuteur: 0x5B7CFA,
        horaire: "4 juin",
        confidentialite: "person.2.fill",
        texte: "Premier bol qui tient debout après six mois de tour 🏺 L'atelier de la rue Paul Bert a ma reconnaissance éternelle.",
        photos: ["p33"],
        ratio: 1.0,
        reactions: ["❤️", "👍"],
        nbReactions: 61,
        commentaires: [
            FbCommentaire(id: "sp3", auteur: "Chloé Berthier", photo: "p12", date: "4 juin",
                          texte: "Il est magnifique !! Tu m'en fais un ? 🙏", likes: 6,
                          fils: [
                            FbCommentaire(id: "sp3r1", auteur: "Sarah Levasseur", photo: "p04", teinte: 0x5B7CFA,
                                          date: "4 juin", texte: "Le prochain est pour toi, promis 💙",
                                          likes: 3, estAuteur: true)
                          ]),
            FbCommentaire(id: "sp4", auteur: "Inès Djellal", photo: "p22", teinte: 0x8E44AD, date: "4 juin",
                          texte: "Bravo Sarah 👏", likes: 2)
        ],
        partages: [],
        deSarah: true)

    static let postSarahQuais = FbPost(
        id: "sarah3",
        auteur: "Sarah Levasseur",
        photoAuteur: "p04",
        teinteAuteur: 0x5B7CFA,
        horaire: "21 mai",
        confidentialite: "person.2.fill",
        texte: "Les quais à 7 h du matin, personne, juste la brume sur le Rhône. Lyon sait faire ça.",
        photos: ["p31"],
        ratio: 1.35,
        reactions: ["❤️", "😮"],
        nbReactions: 38,
        commentaires: [
            FbCommentaire(id: "sp5", auteur: "Léa Moreau", photo: "p18", teinte: 0x30D1C4, date: "21 mai",
                          texte: "Cette lumière 😍", likes: 4),
            FbCommentaire(id: "sp6", auteur: "Julie Ferrand", teinte: 0xFF9F0A, date: "21 mai",
                          texte: "Tu te lèves à 7 h un dimanche, toi ?", likes: 3,
                          fils: [
                            FbCommentaire(id: "sp6r1", auteur: "Sarah Levasseur", photo: "p04", teinte: 0x5B7CFA,
                                          date: "21 mai", texte: "Une fois par an, il faut bien 😅",
                                          likes: 2, estAuteur: true)
                          ])
        ],
        partages: [],
        deSarah: true)

    static let postsSarah: [FbPost] = [postSarahPoterie, postSarahQuais, postProfil]

    static let posts: [FbPost] = [postVille, postDeblock, postPoterie, postGroupe,
                                  postLien, postGain, postChloe] + postsSarah

    static func post(_ id: String) -> FbPost {
        posts.first(where: { $0.id == id }) ?? postVille
    }

    /// Publications d'un auteur donné (profil : « N publications » → cette liste exactement).
    static func publications(de nom: String) -> [FbPost] {
        posts.filter { $0.auteur == nom }
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
        FbPersonne(id: "sf1", nom: "Manue Tempier", teinte: 0xE64980),
        FbPersonne(id: "sf2", nom: "Farouq Rana", teinte: 0x5B7CFA),
        FbPersonne(id: "sf3", nom: "Aurea Aurea", teinte: 0x30D1C4),
        FbPersonne(id: "sf4", nom: "Hafeez Ahmad", teinte: 0xFF9F0A)
    ]

    static let invitations: [FbPersonne] = [
        FbPersonne(id: "i1", nom: "Marie-Pierre Fourez", teinte: 0xE64980,
                   badgeHoraire: "2 h", anciennete: "4 a"),
        FbPersonne(id: "i2", nom: "Dorian Delzers", teinte: 0x5B7CFA, detail: "Suivi(e) par 191 personnes",
                   badgeHoraire: "1 h", anciennete: "1 a"),
        FbPersonne(id: "i3", nom: "Christiane Damotte", teinte: 0xFF9F0A,
                   badgeHoraire: "3 h", anciennete: "3 a"),
        FbPersonne(id: "i4", nom: "Seb Cbien", teinte: 0x30D1C4,
                   badgeHoraire: "33 min", anciennete: "4 a"),
        FbPersonne(id: "i5", nom: "Evelyne Guitonneau", teinte: 0x8E44AD,
                   badgeHoraire: "42 min", anciennete: "2 a")
    ]

    static let connaissezPeutEtre: [FbPersonne] = [
        FbPersonne(id: "cp1", nom: "Sara-Marie Le Richeux", teinte: 0x8E44AD),
        FbPersonne(id: "cp2", nom: "Tania LaQuinny", teinte: 0x30D1C4, detail: "Suivi(e) par 7,8 K personnes"),
        FbPersonne(id: "cp3", nom: "Rifatul Islam", teinte: 0x5B7CFA),
        FbPersonne(id: "cp4", nom: "Mohammad Sami", teinte: 0xFF9F0A, detail: "Suivi(e) par 3,3 K personnes"),
        FbPersonne(id: "cp5", nom: "Paul Hubert", teinte: 0x5B7CFA),
        FbPersonne(id: "cp6", nom: "Karine Cabrero", teinte: 0x30D1C4)
    ]

    /// Les 5 ami(e)s de Sarah — « 5 amis » sur son profil ouvre EXACTEMENT cette liste.
    static let vosAmis: [FbPersonne] = [
        FbPersonne(id: "a1", nom: "Chloé Berthier", photo: "p12", teinte: 0xE64980),
        FbPersonne(id: "a2", nom: "Inès Djellal", photo: "p22", teinte: 0x8E44AD),
        FbPersonne(id: "a3", nom: "Léa Moreau", photo: "p18", teinte: 0x30D1C4),
        FbPersonne(id: "a4", nom: "Julie Ferrand", teinte: 0xFF9F0A),
        FbPersonne(id: "a5", nom: "Sylvie Lavisse", teinte: 0xE8A0A0)
    ]

    /// Pages et créateurs cités par le fil, les Reels et les stories : le tap sur l'auteur
    /// ouvre une fiche cohérente et non un profil vide (D92).
    static let pages: [FbPersonne] = [
        FbPersonne(id: "pg1", nom: "Lyon Ma Ville", photo: "p36", teinte: 0x0C59FD,
                   detail: "Suivi(e) par 84 K personnes", ville: "Lyon", estPage: true),
        FbPersonne(id: "pg2", nom: "Atelier Poterie Lyon 3", photo: "p33", teinte: 0xFF9F0A,
                   detail: "Suivi(e) par 3,1 K personnes", ville: "Lyon 3ᵉ", estPage: true),
        FbPersonne(id: "pg3", nom: "Le Progrès de Lyon", photo: "p31", teinte: 0xDF1C2D,
                   detail: "Suivi(e) par 212 K personnes", ville: "Lyon", estPage: true),
        FbPersonne(id: "pg4", nom: "Radio Cool Direct", photo: "p27", teinte: 0xDF1C2D,
                   detail: "Suivi(e) par 47 K personnes", ville: "Auch", estPage: true),
        FbPersonne(id: "pg5", nom: "Aline Dessine", photo: "p26", teinte: 0x8E44AD,
                   detail: "Suivi(e) par 12 K personnes", ville: "Villeurbanne", estPage: true),
        FbPersonne(id: "pg6", nom: "Le Bouchon des Terreaux", photo: "p33", teinte: 0xE64980,
                   detail: "Suivi(e) par 2,4 K personnes", ville: "Lyon 1ᵉʳ", estPage: true),
        FbPersonne(id: "pg7", nom: "Studio Photo Croix-Rousse", photo: "p26", teinte: 0x5B7CFA,
                   detail: "Suivi(e) par 1,8 K personnes", ville: "Lyon 4ᵉ", estPage: true),
        FbPersonne(id: "pg8", nom: "Les Bâtisseurs du Vieux Lyon", photo: "p31", teinte: 0x8E44AD,
                   detail: "Suivi(e) par 5,6 K personnes", ville: "Lyon 5ᵉ", estPage: true)
    ]

    /// Personnes citées uniquement dans les commentaires et les partages : elles existent
    /// donc réellement quand on tape leur nom (aucun cul-de-sac).
    static let secondaires: [FbPersonne] = [
        FbPersonne(id: "x1", nom: "Gaëlle Capitaine", photo: "p22", teinte: 0xB0B3B8),
        FbPersonne(id: "x2", nom: "Aurore Dauriac", teinte: 0xE64980),
        FbPersonne(id: "x3", nom: "Francis Baron", teinte: 0x5B7CFA),
        FbPersonne(id: "x4", nom: "Paulette Vinot", teinte: 0xFF9F0A),
        FbPersonne(id: "x5", nom: "Sofiane Belkacem", teinte: 0x30D1C4),
        FbPersonne(id: "x6", nom: "Didier Ovenberghe", teinte: 0x5B7CFA),
        FbPersonne(id: "x7", nom: "Amélie Lalanne", teinte: 0xE64980),
        FbPersonne(id: "x8", nom: "Aurélie Deyries", teinte: 0xFF9F0A),
        FbPersonne(id: "x9", nom: "Ghislaine Lacan", teinte: 0x8E44AD),
        FbPersonne(id: "x10", nom: "Marina Valognes", teinte: 0xE64980),
        FbPersonne(id: "x11", nom: "Olivier Marin", teinte: 0x5B7CFA),
        FbPersonne(id: "x12", nom: "Christelle Riou", teinte: 0x30D1C4)
    ]

    static let personnes: [FbPersonne] =
        vosAmis + invitations + connaissezPeutEtre + suggestionsFil + secondaires + pages

    /// D92 (cohérence Messenger → Facebook) : un nom qui n'existe pas côté Facebook reçoit un
    /// profil minimal COHÉRENT (initiale, Lyon, 0 publication) plutôt que d'être ignoré.
    static func personne(_ nom: String) -> FbPersonne {
        if let p = personnes.first(where: { $0.nom == nom }) { return p }
        return FbPersonne(id: "ext-" + nom, nom: nom, teinte: 0xB0B3B8, ville: "Lyon")
    }

    static func existe(_ nom: String) -> Bool {
        personnes.contains(where: { $0.nom == nom })
    }

    /// Les ami(e)s affiché(e)s sur le profil d'un tiers : sous-ensemble stable et non vide,
    /// dérivé du nom (aucun aléa, aucune liste vide annoncée comme pleine).
    static func amis(de personne: FbPersonne) -> [FbPersonne] {
        if personne.nom == moiNom { return vosAmis }
        let pool = vosAmis + Array(connaissezPeutEtre.prefix(3))
        let bases = pool.filter { $0.nom != personne.nom }
        let n = 3 + (abs(personne.nom.hashValue) % 3)          // 3 à 5, stable pour un nom donné
        return Array(bases.prefix(min(n, bases.count)))
    }

    // ---------------------------------------------------------------- groupes (e147)

    static let groupes: [FbGroupe] = [
        FbGroupe(id: "g1", nom: "Lyon 3e — Entre voisins", type: "Privé", membres: "8,9 K membres", image: "p36"),
        FbGroupe(id: "g2", nom: "Céramique & Poterie France", type: "Public", membres: "24 K membres", image: "p33"),
        FbGroupe(id: "g3", nom: "Randos autour de Lyon", type: "Public", membres: "11 K membres", image: "p31"),
        FbGroupe(id: "g4", nom: "Vide-dressing Lyon", type: "Privé", membres: "3,4 K membres", image: "p24"),
        FbGroupe(id: "g5", nom: "Retouches photos Lyon — Entraide", type: "Public", membres: "20 K membres", image: "p30"),
        FbGroupe(id: "g6", nom: "Bons plans Lyon & alentours", type: "Privé", membres: "26 K membres", image: "p26")
    ]

    /// Groupe déjà rejoint par Sarah au démarrage (cohérent avec le fil poterie).
    static let groupesInitiaux: Set<String> = ["g2"]

    static func groupe(_ id: String) -> FbGroupe? {
        groupes.first(where: { $0.id == id })
    }

    // ---------------------------------------------------------------- notifications (e152, forme filmée)

    static let notifications: [FbNotif] = [
        FbNotif(id: "n1", photo: "p12", teinte: 0xE64980, badge: "person.fill.viewfinder",
                segments: [FbSegment(texte: "Vous avez de nouvelles suggestions d'ami(e)s : "),
                           FbSegment(texte: "Sara-Marie Le Richeux", gras: true), FbSegment(texte: " et "),
                           FbSegment(texte: "Paul Hubert", gras: true),
                           FbSegment(texte: ".")],
                horaire: "2 j"),
        FbNotif(id: "n2", teinte: 0x8E44AD, badge: "person.badge.plus",
                segments: [FbSegment(texte: "Marie-Pierre Fourez", gras: true),
                           FbSegment(texte: " souhaite vous ajouter à ses ami(e)s.")],
                horaire: "2 h", personneCible: "Marie-Pierre Fourez"),
        FbNotif(id: "n3", photo: "p33", teinte: 0xFF9F0A, badge: "bell.fill",
                segments: [FbSegment(texte: "Atelier Poterie Lyon 3", gras: true),
                           FbSegment(texte: " a publié : « Les inscriptions de septembre sont ouvertes ! »")],
                horaire: "1 j", postCible: "poterie"),
        FbNotif(id: "n4", photo: "p12", teinte: 0xE64980, badge: "heart.fill",
                segments: [FbSegment(texte: "Chloé Berthier", gras: true),
                           FbSegment(texte: " a commenté votre publication : « Il est magnifique !! Tu m'en fais un ? »")],
                horaire: "1 sem", postCible: "sarah2"),
        FbNotif(id: "n5", photo: "p36", teinte: 0x0C59FD, badge: "globe.europe.africa.fill",
                segments: [FbSegment(texte: "Lyon Ma Ville", gras: true),
                           FbSegment(texte: " a publié : « L'été indien s'installe sur les quais du Rhône »")],
                horaire: "5 h", postCible: "ville"),
        FbNotif(id: "n6", photo: "p31", teinte: 0xDF1C2D, badge: "bubble.left.fill",
                segments: [FbSegment(texte: "Francis Baron", gras: true),
                           FbSegment(texte: " a commenté une publication de "),
                           FbSegment(texte: "Le Progrès de Lyon", gras: true), FbSegment(texte: ".")],
                horaire: "2 j", postCible: "progres")
    ]

    // ---------------------------------------------------------------- Reels (e112, e122)
    // D92 : chaque reel a un fil de commentaires réel ; « N commentaires » = fils.count.

    static let reels: [FbReel] = [
        FbReel(id: "rl1", image: "p27", page: "Radio Cool Direct", pageTeinte: 0xDF1C2D,
               legende: "La nuit est tombée sur l'élection Miss… voir plus",
               audio: "Radio Cool Direct · Audio d'origine",
               jaime: 959, partages: 42, enregistrements: 37,
               fils: [
                FbCommentaire(id: "rc0", auteur: "Radio Cool Direct", photo: "p27", teinte: 0xDF1C2D,
                              date: "11 sem.", texte: "@super fans", estAuteur: true),
                FbCommentaire(id: "rc1", auteur: "Marina Valognes", teinte: 0xE64980, date: "11 sem.",
                              texte: "Tu n'étais pas là pour gagner ? Tu étais là pourquoi alors ? 😅",
                              likes: 20,
                              fils: [
                                FbCommentaire(id: "rc1r1", auteur: "Christelle Riou", teinte: 0x30D1C4,
                                              date: "11 sem.", texte: "Elle a dit l'inverse, réécoute 🙄", likes: 8),
                                FbCommentaire(id: "rc1r2", auteur: "Olivier Marin", teinte: 0x5B7CFA,
                                              date: "10 sem.", texte: "On peut rêver ET douter, non ?", likes: 5)
                              ]),
                FbCommentaire(id: "rc2", auteur: "Olivier Marin", teinte: 0x5B7CFA, date: "11 sem.",
                              texte: "Et une pensée pour Lyhanna elle aussi du Gers.....",
                              likes: 12,
                              fils: [
                                FbCommentaire(id: "rc2r1", auteur: "Marina Valognes", teinte: 0xE64980,
                                              date: "11 sem.", texte: "Ah oui, elle était superbe aussi ❤️", likes: 3)
                              ]),
                FbCommentaire(id: "rc3", auteur: "Christelle Riou", teinte: 0x30D1C4, date: "9 sem.",
                              texte: "Tu avais le rêve de gagner et tu avais des doutes, c'est ce que tu as voulu dire, sans prétention aucune. Quand on est belle et intelligente émotionnellement comme toi, on se pose beaucoup de questions, n'est-ce pas ?",
                              likes: 4)
               ]),
        FbReel(id: "rl2", image: "p26", page: "Aline Dessine", pageTeinte: 0x8E44AD,
               legende: "Bordel j'aurais jamais cru que ce truc marche… voir plus",
               audio: "Aline Dessine · Audio d'origine",
               jaime: 231, partages: 6, enregistrements: 9,
               fils: [
                FbCommentaire(id: "rd1", auteur: "Léa Moreau", photo: "p18", teinte: 0x30D1C4, date: "3 sem.",
                              texte: "J'ai testé, ça marche vraiment 😂", likes: 7,
                              fils: [
                                FbCommentaire(id: "rd1r1", auteur: "Aline Dessine", photo: "p26", teinte: 0x8E44AD,
                                              date: "3 sem.", texte: "Je te l'avais dit 😌", likes: 4, estAuteur: true)
                              ]),
                FbCommentaire(id: "rd2", auteur: "Inès Djellal", photo: "p22", teinte: 0x8E44AD, date: "2 sem.",
                              texte: "Le papier tient combien de temps après ?", likes: 2)
               ]),
        FbReel(id: "rl3", image: "p36", page: "Lyon Ma Ville", pageTeinte: 0x0C59FD,
               legende: "Les quais du Rhône vus de la passerelle, 6 h 40… voir plus",
               audio: "Lyon Ma Ville · Audio d'origine",
               jaime: 1842, partages: 96, enregistrements: 210,
               fils: [
                FbCommentaire(id: "rv1", auteur: "Gaëlle Capitaine", photo: "p22", date: "1 sem.",
                              texte: "La brume sur le fleuve, rien à ajouter 🤍", likes: 41),
                FbCommentaire(id: "rv2", auteur: "Karine Cabrero", teinte: 0x30D1C4, date: "6 j",
                              texte: "C'est filmé depuis quelle passerelle exactement ?", likes: 5,
                              fils: [
                                FbCommentaire(id: "rv2r1", auteur: "Lyon Ma Ville", photo: "p36", teinte: 0x0C59FD,
                                              date: "6 j", texte: "Passerelle du Palais de Justice, côté Saône.",
                                              likes: 12, estAuteur: true)
                              ]),
                FbCommentaire(id: "rv3", auteur: "Chloé Berthier", photo: "p12", teinte: 0xE64980, date: "5 j",
                              texte: "Sarah, c'est exactement ta photo de mai 😍", likes: 9)
               ]),
        FbReel(id: "rl4", image: "p33", page: "Atelier Poterie Lyon 3", pageTeinte: 0xFF9F0A,
               legende: "Centrer une boule de 2 kg, au ralenti… voir plus",
               audio: "Atelier Poterie Lyon 3 · Audio d'origine",
               jaime: 407, partages: 18, enregistrements: 64,
               fils: [
                FbCommentaire(id: "rp1", auteur: "Inès Djellal", photo: "p22", teinte: 0x8E44AD, date: "2 sem.",
                              texte: "Vous rendez ça tellement simple, c'est vexant 😅", likes: 15),
                FbCommentaire(id: "rp2", auteur: "Julie Ferrand", teinte: 0xFF9F0A, date: "12 j",
                              texte: "Il reste des places au mardi ?", likes: 3,
                              fils: [
                                FbCommentaire(id: "rp2r1", auteur: "Atelier Poterie Lyon 3", photo: "p33",
                                              teinte: 0xFF9F0A, date: "12 j",
                                              texte: "4 places, réservation par message 🙂", likes: 6, estAuteur: true)
                              ])
               ])
    ]

    static func reel(_ id: String) -> FbReel {
        reels.first(where: { $0.id == id }) ?? reels[0]
    }

    /// Publication équivalente à un reel, pour la feuille de partage (le partage d'un reel
    /// ne doit plus proposer par erreur la publication d'une autre Page).
    static func postDeReel(_ r: FbReel) -> FbPost {
        FbPost(id: "reel-" + r.id, auteur: r.page, photoAuteur: r.image, teinteAuteur: r.pageTeinte,
               horaire: "Reel", texte: r.legende, photos: [r.image], ratio: 0.5625,
               reactions: ["👍"], nbReactions: r.jaime)
    }

    // ---------------------------------------------------------------- feuille de partage (e021)
    // Contacts Messenger de Sarah. Marc n'y figure PAS : son absence est l'indice narratif.

    static let contactsMessenger: [FbPersonne] = [
        FbPersonne(id: "m1", nom: "Chloé Berthier", photo: "p12", teinte: 0xE64980),
        FbPersonne(id: "m2", nom: "Sylvie Lavisse", teinte: 0xE8A0A0),
        FbPersonne(id: "m3", nom: "Inès Djellal", photo: "p22", teinte: 0x8E44AD),
        FbPersonne(id: "m4", nom: "Léa Moreau", photo: "p18", teinte: 0x30D1C4),
        FbPersonne(id: "m5", nom: "Julie Ferrand", teinte: 0xFF9F0A)
    ]

    /// Personnes qui ont partagé une publication : construites depuis `post.partages`,
    /// donc le compteur et la liste ne peuvent plus diverger (D92).
    static func partageurs(_ p: FbPost) -> [FbPartageur] {
        p.partages.enumerated().map { paire in
            let nom = paire.element
            let fiche = personne(nom)
            return FbPartageur(id: p.id + "-pp" + String(paire.offset),
                               nom: nom,
                               photo: fiche.photo,
                               teinte: fiche.teinte,
                               reactions: paire.offset % 2 == 0 ? ["👍", "😮"] : ["😢"],
                               nbReactions: 3 - min(2, paire.offset),
                               horaire: p.horaire,
                               commentable: paire.offset % 3 != 2)
        }
    }
}

// ============================================================================
// MARK: - 4. ÉTAT PARTAGÉ (survit aux bascules d'onglet — écart n° 41 de l'audit)
//         D92 : AUCUN message ni feuille ne survit à l'écran qui l'a produit
//         (`nettoyerEcran()` est appelé à chaque changement d'onglet et de pile).
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

/// Cible du composeur minimal (D92 — « Quoi de neuf ? » produit une vraie publication).
struct FbCibleComposeur: Identifiable {
    let id: String
    var photoPrechargee: String? = nil
}

enum FbRoute: Hashable {
    case detail(String)                 // identifiant de post
    case partages(String)               // identifiant de post
    case profilPersonne(String)         // nom
    case publications(String)           // nom de l'auteur → « N publications »
    case personnes(String, String)      // (clé de liste, titre) — amis / invitations / suggestions
    case amisDe(String)                 // nom → « N ami(e)s » d'un profil
    case recherche
    case enregistrements
    case vosGroupes
}

final class FbEtat: ObservableObject {
    @Published var onglet: Int = 0
    @Published var chemin: [FbRoute] = []
    @Published var tiroir: Bool = false

    @Published var aimes: Set<String> = []
    @Published var enregistres: Set<String> = []
    @Published var masques: Set<String> = []
    @Published var suivis: Set<String> = []
    @Published var rejoints: Set<String> = DonneesFb.groupesInitiaux
    @Published var groupesRejetes: Set<String> = []
    @Published var invitationsTraitees: [String: String] = [:]   // nom -> « Invitation acceptée »…
    @Published var ajoutes: Set<String> = []
    @Published var amisAjoutes: [FbPersonne] = []                // invitations acceptées
    @Published var suggestionsRejetees: Set<String> = []
    @Published var reelsMasques: Bool = false

    @Published var commentairesAjoutes: [String: [FbCommentaire]] = [:]   // id de post/reel -> commentaires
    @Published var reponsesAjoutees: [String: [FbCommentaire]] = [:]      // id de commentaire -> réponses
    @Published var reponsesDepliees: Set<String> = []                     // ids de commentaires dépliés
    @Published var pouces: [String: Int] = [:]                            // id de commentaire -> +1 / -1
    @Published var likesCommentaires: Set<String> = []
    @Published var cibleReponse: FbCommentaire? = nil                     // « Répondre » en cours

    @Published var postsAjoutes: [FbPost] = []                            // publications créées par Sarah

    @Published var pillAmis: Int = 0                             // 0 = aucune, 1 = Suggestions, 2 = Vos ami(e)s
    @Published var pillProfil: Int = 0                           // 0 = Tous, 1 = Photos
    @Published var triCommentaires: String = "Plus pertinents"

    @Published var partage: FbPost? = nil
    @Published var visionneuse: FbCibleVisionneuse? = nil
    @Published var story: FbStoryTuile? = nil
    @Published var reelCommentaires: FbReel? = nil
    @Published var composeur: FbCibleComposeur? = nil
    @Published var alerte: FbAlerte? = nil
    @Published var toast: String? = nil

    // ------------------------------------------------------------ réactions

    func basculerJaime(_ id: String) {
        Haptique.leger()
        if aimes.contains(id) { aimes.remove(id) } else { aimes.insert(id) }
    }

    func nbReactions(_ p: FbPost) -> Int {
        p.nbReactions + (aimes.contains(p.id) ? 1 : 0)
    }

    // ------------------------------------------------------------ commentaires

    func commentaires(_ p: FbPost) -> [FbCommentaire] {
        p.commentaires + (commentairesAjoutes[p.id] ?? [])
    }

    func commentairesReel(_ r: FbReel) -> [FbCommentaire] {
        r.fils + (commentairesAjoutes[r.id] ?? [])
    }

    /// D92 : « N commentaires » = nombre de commentaires réellement affichés sous la publication.
    func nbCommentaires(_ p: FbPost) -> Int {
        commentaires(p).count
    }

    /// Réponses d'un commentaire : celles des données + celles écrites par Sarah.
    func reponses(_ c: FbCommentaire) -> [FbCommentaire] {
        c.fils + (reponsesAjoutees[c.id] ?? [])
    }

    func basculerReponses(_ c: FbCommentaire) {
        Haptique.leger()
        if reponsesDepliees.contains(c.id) { reponsesDepliees.remove(c.id) }
        else { reponsesDepliees.insert(c.id) }
    }

    private func commentaireDeSarah(_ texte: String, cle: String) -> FbCommentaire {
        FbCommentaire(id: "moi-" + cle + "-" + UUID().uuidString,
                      auteur: DonneesFb.moiNom, photo: DonneesFb.moiPhoto,
                      teinte: 0x5B7CFA, date: "À l'instant", texte: texte)
    }

    /// Ajoute un commentaire — ou une RÉPONSE si « Répondre » a été utilisé (la réponse
    /// apparaît alors sous le commentaire visé, déplié automatiquement).
    func ajouterCommentaire(_ texte: String, sur cle: String) {
        if let cible = cibleReponse {
            reponsesAjoutees[cible.id, default: []].append(commentaireDeSarah(texte, cle: cible.id))
            reponsesDepliees.insert(cible.id)
            cibleReponse = nil
        } else {
            commentairesAjoutes[cle, default: []].append(commentaireDeSarah(texte, cle: cle))
        }
        Haptique.leger()
    }

    func viserReponse(_ c: FbCommentaire) {
        Haptique.leger()
        cibleReponse = c
    }

    // ------------------------------------------------------------ publications de Sarah

    /// Publications d'un auteur, publications créées dans la partie incluses.
    func publications(de nom: String) -> [FbPost] {
        let creees = postsAjoutes.filter { $0.auteur == nom }
        return creees + DonneesFb.publications(de: nom)
    }

    func nbPublications(de nom: String) -> Int {
        publications(de: nom).count
    }

    func publier(texte: String, photo: String?) {
        let p = FbPost(id: "moi-" + UUID().uuidString,
                       auteur: DonneesFb.moiNom,
                       photoAuteur: DonneesFb.moiPhoto,
                       teinteAuteur: 0x5B7CFA,
                       horaire: "À l'instant",
                       confidentialite: "person.2.fill",
                       texte: texte,
                       photos: photo.map { [$0] } ?? [],
                       ratio: 1.0,
                       reactions: [],
                       nbReactions: 0,
                       deSarah: true)
        postsAjoutes.insert(p, at: 0)
        Haptique.leger()
        afficherToast("Publication en ligne. Elle est en tête de votre fil.")
    }

    // ------------------------------------------------------------ ami(e)s

    /// D92 : accepter une invitation AJOUTE réellement la personne à la liste d'ami(e)s,
    /// donc le compteur « N amis » du profil et la liste ouverte par ce compteur restent
    /// égaux (retours 279 — « Tap 5 amis → voir les 5 amis »).
    var mesAmis: [FbPersonne] { DonneesFb.vosAmis + amisAjoutes }

    func estAmie(_ nom: String) -> Bool {
        mesAmis.contains(where: { $0.nom == nom })
    }

    func accepterInvitation(_ p: FbPersonne) {
        Haptique.leger()
        invitationsTraitees[p.nom] = "Vous êtes ami(e)s"
        if !estAmie(p.nom) {
            amisAjoutes.append(FbPersonne(id: "ajoute-" + p.id, nom: p.nom, photo: p.photo,
                                          teinte: p.teinte, ville: p.ville))
        }
        afficherToast("Vous êtes désormais ami(e) avec " + p.nom + ".")
    }

    func refuserInvitation(_ p: FbPersonne) {
        Haptique.leger()
        invitationsTraitees[p.nom] = "Invitation supprimée"
        amisAjoutes.removeAll(where: { $0.nom == p.nom })
    }

    /// « Ajouter ami(e) » sur une suggestion : invitation envoyée (état qui persiste),
    /// sans mentir sur une amitié qui n'existe pas encore.
    func basculerAjout(_ p: FbPersonne) {
        Haptique.leger()
        if ajoutes.contains(p.id) {
            ajoutes.remove(p.id)
            afficherToast("Invitation annulée.")
        } else {
            ajoutes.insert(p.id)
            afficherToast("Invitation envoyée à " + p.nom + ".")
        }
    }

    // ------------------------------------------------------------ groupes

    func estMembre(_ groupeId: String) -> Bool { rejoints.contains(groupeId) }

    /// D92 : « Rejoindre » bascule RÉELLEMENT, et le groupe apparaît dans « Vos groupes ».
    func basculerGroupe(_ groupeId: String, nom: String) {
        Haptique.leger()
        if rejoints.contains(groupeId) {
            rejoints.remove(groupeId)
            afficherToast("Vous avez quitté « " + nom + " ».")
        } else {
            rejoints.insert(groupeId)
            groupesRejetes.remove(groupeId)
            afficherToast("Vous avez rejoint « " + nom + " ». Retrouvez-le dans Vos groupes.")
        }
    }

    var mesGroupes: [FbGroupe] {
        DonneesFb.groupes.filter { rejoints.contains($0.id) }
    }

    // ------------------------------------------------------------ divers

    func afficherToast(_ message: String) {
        toast = message
        Haptique.leger()
    }

    /// CORRECTIF LOT 280 — ferme TOUTE vue présentée.
    /// Les cinq vues « présentées » de Facebook ne sont plus des `sheet` / `fullScreenCover`
    /// mais des calques de la ZStack racine (cause n° 3 du bug de barre home : les
    /// modificateurs `persistentSystemOverlays` / `defersSystemGestures` de `coquilleSarah`
    /// ne traversent PAS une présentation, et la vraie barre iOS réapparaissait). Un calque
    /// se ferme donc en remettant son état à `nil`, pas avec `dismiss()`.
    func fermerPresentation() {
        partage = nil
        visionneuse = nil
        story = nil
        reelCommentaires = nil
        composeur = nil
    }

    /// Appelé à CHAQUE changement d'écran : plus aucun message, brouillon ni calque rémanent
    /// (D92 — aucun état ne survit à l'écran qui l'a produit).
    func nettoyerEcran() {
        toast = nil
        alerte = nil
        cibleReponse = nil
        fermerPresentation()
    }

    func ouvrirProfil(_ nom: String) {
        Haptique.leger()
        chemin.append(.profilPersonne(nom))
    }

    func ouvrirMessenger() {
        Haptique.leger()
        Routeur.partage.allerMessenger()
    }

    /// Partage RÉEL d'une publication vers une conversation Messenger (contrat inter-apps D92).
    func partagerDansMessenger(_ post: FbPost, destinataire: String) {
        Haptique.leger()
        MessengerStore.partage.recevoirPartagePost(
            titre: post.auteur,
            sousTitre: String(post.texte.prefix(110)),
            imageCle: post.photos.first ?? "",
            destinataire: destinataire)
        Routeur.partage.allerMessenger(conversation: destinataire)
    }
}

// ============================================================================
// MARK: - 5. BRIQUES PARTAGÉES
// ============================================================================

/// CORRECTIF LOT 280 — coque des vues PRÉSENTÉES (sheet / fullScreenCover).
/// `coquilleSarah(claire:)` est posée sur `FacebookVue` par LPProto, mais ses modificateurs
/// ne traversent PAS une présentation : sans ce modificateur, la VRAIE barre home iOS
/// réapparaissait dans la feuille de partage, les commentaires de reel, la visionneuse et la
/// story — et le balayage vers le haut sortait de Lost Phone.
struct FbCoquePresentee: ViewModifier {
    func body(content: Content) -> some View {
        content
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
            .defersSystemGestures(on: .bottom)
    }
}

extension View {
    func fbCoquePresentee() -> some View { modifier(FbCoquePresentee()) }
}

/// CORRECTIF LOT 280 — pied de page commun.
/// La capsule reste DANS la zone sûre (exactement comme `BarreHome { dismiss() }` dans Mail) :
/// elle n'empiète plus sur la bande de gestes système du bas d'écran, où iOS captait le
/// balayage vers le haut. Seul le FOND s'étend sous la zone sûre.
/// `sombre: true` = capsule NOIRE (fond clair) ; `sombre: false` = capsule BLANCHE (fond noir).
struct FbPiedHome: View {
    var sombre: Bool = true
    var fond: Color = FbStyle.fond
    let action: () -> Void

    var body: some View {
        BarreHome(action: action, sombre: sombre)
            .frame(maxWidth: .infinity)
            .background {
                fond.ignoresSafeArea(edges: .bottom)
            }
    }
}

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
    var texte: Color = Color.white
    var glyphe: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let g = glyphe {
                    Image(systemName: g).font(.system(size: corps - 1, weight: .semibold))
                }
                Text(titre).font(.system(size: corps, weight: .semibold))
                    .lineLimit(1).minimumScaleFactor(0.75)
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

/// Barre haute des écrans poussés : ‹ · titre centré 17 pt · slot d'actions (e144, e146).
/// `.padding(.top, 6)` maintenu : la barre reste SOUS la bande d'état de la coque, dont le
/// fond `.ultraThinMaterial` capte les taps (cf. patch LPProto proposé).
struct FbBarrePoussee<Actions: View>: View {
    let titre: String
    @ObservedObject var etat: FbEtat
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        ZStack {
            Text(titre)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .padding(.horizontal, 44)
            HStack {
                FbBoutonRetour(etat: etat)
                Spacer()
                actions()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(FbStyle.fond)
    }
}

/// Chevron Retour unique de l'app : dépile TOUJOURS (corrige « la flèche Retour ne
/// fonctionne pas » sur le profil d'un tiers) et n'est jamais placé dans la bande d'état.
struct FbBoutonRetour: View {
    @ObservedObject var etat: FbEtat
    var clair: Bool = false

    var body: some View {
        Button {
            Haptique.leger()
            etat.nettoyerEcran()
            if !etat.chemin.isEmpty { etat.chemin.removeLast() }
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 21, weight: clair ? Font.Weight.semibold : Font.Weight.medium))
                .foregroundStyle(clair ? Color.white : Color.black)
                .shadow(color: clair ? Color.black.opacity(0.5) : Color.clear, radius: 3)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

func fbNombre(_ n: Int) -> String {
    if n >= 1000 {
        let milliers = Double(n) / 1000.0
        return String(format: "%.1f", milliers).replacingOccurrences(of: ".", with: ",") + " K"
    }
    return String(n)
}

func fbPluriel(_ n: Int, _ singulier: String, _ pluriel: String) -> String {
    String(n) + " " + (n > 1 ? pluriel : singulier)
}

// ============================================================================
// MARK: - 6. RACINE : 6 ONGLETS + TIROIR LATÉRAL + PILE DE NAVIGATION
// ============================================================================

struct FbOngletInfo: Identifiable {
    let id: Int
    let glyphe: String
    let glypheActif: String
    let titre: String
}

// (C) Le badge rouge « 1 » de l'onglet Reels était inventé (aucune logique de non-lu) : retiré.
let fbOnglets: [FbOngletInfo] = [
    FbOngletInfo(id: 0, glyphe: "house", glypheActif: "house.fill", titre: "Accueil"),
    FbOngletInfo(id: 1, glyphe: "play.square", glypheActif: "play.square.fill", titre: "Reels"),
    FbOngletInfo(id: 2, glyphe: "person.2", glypheActif: "person.2.fill", titre: "Ami(e)s"),
    FbOngletInfo(id: 3, glyphe: "person.2.circle", glypheActif: "person.2.circle.fill", titre: "Groupes"),
    FbOngletInfo(id: 4, glyphe: "bell", glypheActif: "bell.fill", titre: "Notifications"),
    FbOngletInfo(id: 5, glyphe: "person.circle", glypheActif: "person.circle.fill", titre: "Profil")
]

struct FacebookVue: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var etat = FbEtat()
    @ObservedObject private var routeur = Routeur.partage

    var ongletInitial: Int? = nil
    var tiroirInitial: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            FbStyle.fond.ignoresSafeArea()
            pile
            voileTiroir
            // CORRECTIF LOT 280, cause n° 2 : le tiroir (358 pt) était dessiné APRÈS les
            // barres basses et recouvrait la fausse capsule — tiroir ouvert, le joueur ne
            // voyait plus AUCUNE barre home de Sarah et visait la vraie. Il est désormais
            // dessiné SOUS la barre d'onglets et SOUS le pied home (c'est d'ailleurs le
            // comportement du vrai Facebook : la barre d'onglets reste visible sur Menu).
            tiroir
            barreOnglets
            // CORRECTIF LOT 280, causes n° 3 et 4 : plus AUCUN `sheet` ni `fullScreenCover`
            // dans Facebook. Les cinq vues présentées sont des calques de cette ZStack :
            // elles héritent donc de `coquilleSarah(claire:)` (vraie barre home iOS masquée,
            // gestes du bas différés) et partagent l'unique `FbPiedHome` ci-dessous.
            presentations
            // Le pied home est le DERNIER calque : ni le tiroir, ni une feuille, ni un plein
            // écran ne peut le recouvrir. Le joueur a TOUJOURS une capsule visible à viser,
            // et elle reste DANS la zone sûre (cause n° 1).
            piedHome
            toast
        }
        .preferredColorScheme(.light)
        .onAppear(perform: preparer)
        .onChange(of: routeur.demande) { _, _ in consommerRoutage() }
        .onChange(of: etat.onglet) { _, _ in etat.nettoyerEcran() }
        .onChange(of: etat.chemin) { _, _ in etat.nettoyerEcran() }
        .alert(etat.alerte?.titre ?? "", isPresented: liaisonAlerte) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(etat.alerte?.message ?? "")
        }
    }

    private var liaisonAlerte: Binding<Bool> {
        Binding(get: { etat.alerte != nil },
                set: { nouvelle in if !nouvelle { etat.alerte = nil } })
    }

    private func preparer() {
        if let o = ongletInitial {
            etat.onglet = o
        } else if let env = ProcessInfo.processInfo.environment["ONGLET"], let o = Int(env) {
            etat.onglet = o
        }
        if tiroirInitial { etat.tiroir = true }
        consommerRoutage()
    }

    /// CONTRAT INTER-APPS (D92) — Messenger « Voir le profil Facebook » ouvre RÉELLEMENT
    /// le profil de la personne concernée. Si elle n'existe pas dans les données Facebook,
    /// `DonneesFb.personne(_:)` fabrique un profil minimal cohérent : jamais d'écran vide.
    private func consommerRoutage() {
        guard let nom = Routeur.partage.consommerProfilFacebook() else { return }
        etat.nettoyerEcran()
        etat.tiroir = false
        etat.onglet = 0
        etat.chemin = [.profilPersonne(nom)]
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
            FbPostDetailVue(post: etat.postParId(id), etat: etat)
        case .partages(let id):
            FbPartagesVue(post: etat.postParId(id), etat: etat)
        case .profilPersonne(let nom):
            FbProfilPersonneVue(personne: DonneesFb.personne(nom), etat: etat)
        case .publications(let nom):
            FbPublicationsVue(nom: nom, etat: etat)
        case .personnes(let cle, let titre):
            FbListePersonnesVue(cle: cle, titre: titre, etat: etat)
        case .amisDe(let nom):
            FbListePersonnesVue(cle: "amisDe:" + nom, titre: "Ami(e)s", etat: etat)
        case .recherche:
            FbRechercheVue(etat: etat)
        case .enregistrements:
            FbEnregistrementsVue(etat: etat)
        case .vosGroupes:
            FbVosGroupesVue(etat: etat)
        }
    }

    // ---------------------------------------------------------------- barres basses

    private var reelsActif: Bool { etat.onglet == 1 && etat.chemin.isEmpty }

    @ViewBuilder
    private var barreOnglets: some View {
        if etat.chemin.isEmpty {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                FbBarreOnglets(etat: etat, sombre: reelsActif)
                Color.clear.frame(height: 24)      // place du pied home, jamais recouverte
            }
        }
    }

    /// Un fond noir est présenté (visionneuse, story, onglet Reels) : la capsule doit être
    /// BLANCHE. Sur tout fond clair elle doit être NOIRE (contraste vérifié écran par écran).
    private var fondNoir: Bool {
        if etat.visionneuse != nil || etat.story != nil { return true }
        return reelsActif && etat.partage == nil && etat.composeur == nil
            && etat.reelCommentaires == nil
    }

    private var fondPied: Color {
        if etat.visionneuse != nil || etat.story != nil { return Color.black }
        if etat.partage != nil { return Color(hex: 0xF0F2F5) }
        if etat.composeur != nil || etat.reelCommentaires != nil { return FbStyle.fond }
        return reelsActif ? FbStyle.barreReels : FbStyle.fond
    }

    private var piedHome: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            FbPiedHome(sombre: !fondNoir, fond: fondPied, action: { dismiss() })
        }
    }

    // ---------------------------------------------------------------- calques présentés

    @ViewBuilder
    private var presentations: some View {
        if let c = etat.visionneuse {
            FbVisionneuseVue(cible: c, etat: etat)
        } else if let s = etat.story {
            FbStoryVue(tuile: s, etat: etat)
        } else if let p = etat.partage {
            FbPartageFeuille(post: p, etat: etat)
        } else if let c = etat.composeur {
            FbComposeurVue(cible: c, etat: etat)
        } else if let r = etat.reelCommentaires {
            FbReelCommentairesVue(reel: r, etat: etat)
        }
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
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.86)))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 130)
            }
            .transition(.opacity)
            .allowsHitTesting(false)
            .task(id: message) {
                try? await Task.sleep(nanoseconds: 2_400_000_000)
                withAnimation(.easeOut(duration: 0.25)) { etat.toast = nil }
            }
        }
    }
}

extension FbEtat {
    /// Résolution d'un identifiant de post : données de base OU publication créée par Sarah.
    func postParId(_ id: String) -> FbPost {
        if let p = postsAjoutes.first(where: { $0.id == id }) { return p }
        return DonneesFb.post(id)
    }
}

// ---------------------------------------------------------------------------
// Barre d'onglets — ordre filmé, filet bleu 1,5 pt au-dessus de l'actif,
// fond #202020 sur l'onglet Reels (e112).
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
        if etat.onglet == o.id { return sombre ? Color.white : FbStyle.bleu }
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
                Image(systemName: etat.onglet == o.id ? o.glypheActif : o.glyphe)
                    .font(.system(size: 20, weight: .regular))
                    .frame(width: 26, height: 24)
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
            ForEach(Array(reactions.enumerated()), id: \.offset) { paire in
                pastille(paire.element)
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
                    // D92 : la publication créée par Sarah apparaît EN TÊTE du fil.
                    ForEach(etat.postsAjoutes) { p in
                        FbPostVue(post: p, etat: etat)
                        FbSeparateurBloc()
                    }
                    ForEach(DonneesFb.blocs) { bloc in
                        FbBlocFilVue(bloc: bloc, etat: etat)
                        FbSeparateurBloc()
                    }
                    Color.clear.frame(height: FbStyle.reserveBas)
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
                // (A) Le ⊞ propose les deux seules créations qui ont une conséquence réelle.
                //     (C) « Story » retiré : la création de story n'a aucune conséquence dans le jeu.
                Menu {
                    Button("Publication") { etat.composeur = FbCibleComposeur(id: "fil") }
                    Button("Voir les Reels") { etat.onglet = 1 }
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

/// D92 : « Quoi de neuf ? » ouvre le composeur MINIMAL et la publication apparaît réellement
/// en tête du fil et dans « N publications » du profil. Plus aucun message « hors connexion ».
struct FbComposerFil: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        HStack(spacing: 12) {
            FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 32, teinte: 0x5B7CFA)
            Text("Quoi de neuf ?")
                .font(.system(size: 17))
                .foregroundStyle(FbStyle.texteGris)
            Spacer()
            Button {
                Haptique.leger()
                etat.composeur = FbCibleComposeur(id: "fil-photo",
                                                  photoPrechargee: DonneesFb.pellicule.first)
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: 0x3A3B3C))
                    .frame(width: 34, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptique.leger()
            etat.composeur = FbCibleComposeur(id: "fil")
        }
    }
}

// ---------------------------------------------------------------- rail stories + suggestions (e001, e108)

struct FbRailStories: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // (C) « Créer une story » retiré : aucune conséquence possible sans appareil
                //     photo, et la caméra ne sert à aucune histoire (signalé à Joachim).
                ForEach(DonneesFb.stories) { s in
                    tuileStory(s)
                }
                ForEach(DonneesFb.suggestionsFil) { p in
                    if !etat.suggestionsRejetees.contains(p.id) {
                        FbCarteSuggestionAmi(personne: p, etat: etat)
                    }
                }
            }
            .padding(.horizontal, FbStyle.margeH)
            .padding(.vertical, 8)
        }
    }

    private func tuileStory(_ s: FbStoryTuile) -> some View {
        Button {
            Haptique.leger()
            etat.story = s
        } label: {
            ZStack(alignment: .bottomLeading) {
                FbImage(cle: s.image)
                LinearGradient(colors: [Color.clear, Color.black.opacity(0.62)],
                               startPoint: .center, endPoint: .bottom)
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
            Button {
                etat.ouvrirProfil(personne.nom)
            } label: {
                FbAvatar(photo: personne.photo, nom: personne.nom, taille: 54, teinte: personne.teinte)
                    .padding(.top, 16)
            }
            .buttonStyle(.plain)
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

    private var ajoute: Bool { etat.ajoutes.contains(personne.id) }

    private var bouton: some View {
        Button {
            Haptique.leger()
            if ajoute {
                etat.ajoutes.remove(personne.id)
                etat.afficherToast("Invitation annulée.")
            } else {
                etat.ajoutes.insert(personne.id)
                etat.afficherToast("Invitation envoyée à " + personne.nom + ".")
            }
        } label: {
            HStack(spacing: 5) {
                if !ajoute {
                    Image(systemName: "person.badge.plus").font(.system(size: 12, weight: .semibold))
                }
                Text(ajoute ? "Invitation envoyée" : "Ajouter")
                    .font(.system(size: 12.5, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(ajoute ? FbStyle.texteGris : FbStyle.bleu)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(RoundedRectangle(cornerRadius: 6)
                .fill(ajoute ? FbStyle.grisBouton : FbStyle.pillBleu))
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

/// Carrousel Reels du fil (e049-e058). D92 : il montre EXACTEMENT les reels existants
/// (plus de vignette de remplissage), et « Masquer » est un état porté par l'app
/// (`etat.reelsMasques`) et non un `@State` réinitialisé par le recyclage de la liste.
struct FbCarrouselReels: View {
    @ObservedObject var etat: FbEtat

    var body: some View {
        if !etat.reelsMasques {
            VStack(spacing: 0) {
                entete
                rail
                bas
            }
            .background(FbStyle.fond)
        }
    }

    private var entete: some View {
        HStack(spacing: 8) {
            Image(systemName: "play.square").font(.system(size: 19)).foregroundStyle(.black)
            Text("Reels").font(.system(size: 17, weight: .semibold)).foregroundStyle(.black)
            Spacer()
            Button {
                Haptique.leger()
                etat.reelsMasques = true
                etat.afficherToast("Les Reels n'apparaîtront plus dans votre fil.")
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color(hex: 0x3A3B3C))
                    .frame(width: 30, height: 26)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
    }

    private var rail: some View {
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
                            .overlay(alignment: .bottomLeading) {
                                Text(r.page)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.6), radius: 3)
                                    .padding(10)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, FbStyle.margeH)
        }
    }

    private var bas: some View {
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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Carrousel de suggestions d'ami(e)s dans le fil (e069-e073).
struct FbCarrouselSuggestions: View {
    @ObservedObject var etat: FbEtat

    private var visibles: [FbPersonne] {
        DonneesFb.connaissezPeutEtre.filter { !etat.suggestionsRejetees.contains($0.id) }
    }

    var body: some View {
        if !visibles.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Personnes que vous connaissez peut-être")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, FbStyle.margeH)
                    .padding(.top, 12)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(visibles) { p in
                            FbCarteSuggestionAmi(personne: p, etat: etat)
                        }
                    }
                    .padding(.horizontal, FbStyle.margeH)
                    .padding(.vertical, 10)
                }
            }
            .background(FbStyle.fond)
        }
    }
}

/// Carte de groupe suggéré dans le fil (e049-e060). D92 : « Rejoindre » bascule réellement
/// et le groupe rejoint apparaît dans « Vos groupes ».
struct FbCarteGroupeFil: View {
    @ObservedObject var etat: FbEtat
    private var groupe: FbGroupe { DonneesFb.groupes[0] }

    private var membre: Bool { etat.estMembre(groupe.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                FbAvatar(photo: groupe.image, nom: groupe.nom, taille: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text(groupe.nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(.black)
                    Text(membre ? "Vous êtes membre" : "Groupe suggéré")
                        .font(.system(size: 12.5)).foregroundStyle(FbStyle.texteGris)
                }
                Spacer()
            }
            FbMedia(cle: groupe.image, ratio: 2.1)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            FbBoutonPlein(titre: membre ? "Membre" : "Rejoindre",
                          hauteur: 35,
                          couleur: membre ? FbStyle.grisBouton : FbStyle.bleu,
                          texte: membre ? Color.black : Color.white,
                          glyphe: membre ? "checkmark" : nil) {
                etat.basculerGroupe(groupe.id, nom: groupe.nom)
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 12)
        .background(FbStyle.fond)
        .contentShape(Rectangle())
        .onTapGesture { etat.chemin.append(.vosGroupes) }
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

    // -------- texte tronqué + « Afficher la suite » (e001)

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
                .font(.system(size: 15)).foregroundColor(Color.black)
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
                        Text("1 de " + String(post.photos.count))
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
                    // (B) Message iOS crédible et vrai : l'App Store n'existe pas dans la coque.
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
                if !post.sponsorise { etat.ouvrirProfil(post.auteur) }
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
            // Profil épuré (retours 279) : sur SES publications, Sarah n'a ni ⋯ ni ✕.
            if !post.deSarah {
                menuPost
                boutonMasquer
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 8)
    }

    private var suivi: Bool { etat.suivis.contains(post.id) }
    private var membre: Bool {
        guard let g = post.groupeId else { return false }
        return etat.estMembre(g)
    }

    private var ligneNom: some View {
        HStack(spacing: 4) {
            Button {
                if !post.sponsorise { etat.ouvrirProfil(post.auteur) }
            } label: {
                Text(post.auteur)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }
            .buttonStyle(.plain)
            if post.verifie {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(FbStyle.bleu)
            }
            if let g = post.groupeId, let groupe = DonneesFb.groupe(g) {
                Text("·").font(.system(size: 15)).foregroundStyle(FbStyle.bleu)
                Button {
                    etat.basculerGroupe(g, nom: groupe.nom)
                } label: {
                    Text(membre ? "Membre" : "Rejoindre")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(membre ? FbStyle.texteGris : FbStyle.bleu)
                }
                .buttonStyle(.plain)
            } else if post.suivre {
                Text("·").font(.system(size: 15)).foregroundStyle(FbStyle.bleu)
                Button {
                    Haptique.leger()
                    if suivi {
                        etat.suivis.remove(post.id)
                        etat.afficherToast("Vous ne suivez plus " + post.auteur + ".")
                    } else {
                        etat.suivis.insert(post.id)
                        etat.afficherToast("Vous suivez " + post.auteur + ".")
                    }
                } label: {
                    Text(suivi ? "Suivi(e)" : "Suivre")
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
                if etat.enregistres.contains(post.id) {
                    etat.enregistres.remove(post.id)
                    etat.afficherToast("Retirée de vos enregistrements.")
                } else {
                    etat.enregistres.insert(post.id)
                    etat.afficherToast("Publication enregistrée. Menu ☰ › Enregistrements.")
                }
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
// D92 : les deux compteurs de droite mènent à un contenu qui EXISTE et dont le nombre
// est celui affiché (commentaires réellement listés, partageurs réellement listés).

struct FbPostStats: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat

    private var nbCom: Int { etat.nbCommentaires(post) }

    var body: some View {
        HStack(spacing: 6) {
            if etat.nbReactions(post) > 0 {
                Button {
                    etat.chemin.append(.detail(post.id))
                } label: {
                    HStack(spacing: 6) {
                        FbClusterReactions(reactions: post.reactions.isEmpty ? ["👍"] : post.reactions)
                        Text(fbNombre(etat.nbReactions(post)))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
            if nbCom > 0 {
                Button {
                    etat.chemin.append(.detail(post.id))
                } label: {
                    Text(fbPluriel(nbCom, "commentaire", "commentaires"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }
            if post.nbPartages > 0 {
                Button {
                    etat.chemin.append(.partages(post.id))
                } label: {
                    Text(fbPluriel(post.nbPartages, "partage", "partages"))
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
                    if enregistre {
                        etat.enregistres.remove(post.id)
                        etat.afficherToast("Retirée de vos enregistrements.")
                    } else {
                        etat.enregistres.insert(post.id)
                        etat.afficherToast("Publication enregistrée. Menu ☰ › Enregistrements.")
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private func bouton(glyphe: String, titre: String, actif: Bool,
                        action: @escaping () -> Void) -> some View {
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

    private var liste: [FbCommentaire] { etat.commentaires(post) }

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    texte
                    media
                    FbPostActions(post: post, etat: etat)
                    FbHairline()
                    resume
                    tri
                    ForEach(liste) { c in
                        FbCommentaireVue(commentaire: c, etat: etat)
                    }
                    if liste.isEmpty { aucunCommentaire }
                    Color.clear.frame(height: 24)
                }
            }
            .scrollIndicators(.visible)
            FbComposeurCommentaire(cle: post.id, etat: etat, saisie: $saisie)
            // La capsule home de la coque est dessinée par FacebookVue AU-DESSUS de la pile :
            // on lui réserve sa place au lieu d'en ajouter une deuxième.
            Color.clear.frame(height: FbStyle.hauteurPied)
        }
        .background(FbStyle.fond)
    }

    // -------- barre haute (e015) : ‹ · avatar · « Nom · Suivre » · « 3 j · 🌐 » · ⋯

    private var entete: some View {
        HStack(spacing: 6) {
            FbBoutonRetour(etat: etat)

            Button {
                if !post.sponsorise { etat.ouvrirProfil(post.auteur) }
            } label: {
                HStack(spacing: 10) {
                    FbAvatar(photo: post.photoAuteur ?? post.photos.first, nom: post.auteur,
                             taille: 36, teinte: post.teinteAuteur)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(post.auteur)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.black).lineLimit(1)
                        HStack(spacing: 4) {
                            Text(post.horaire).font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
                            Text("·").font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
                            Image(systemName: post.confidentialite).font(.system(size: 11))
                                .foregroundStyle(FbStyle.texteGris)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer(minLength: 4)
            if !post.deSarah {
                Menu {
                    Button {
                        Haptique.leger()
                        etat.enregistres.insert(post.id)
                        etat.afficherToast("Publication enregistrée. Menu ☰ › Enregistrements.")
                    } label: { Label("Enregistrer la publication", systemImage: "bookmark") }
                    Button {
                        UIPasteboard.general.string = post.lien ?? ("https://www.facebook.com/" + post.id)
                        etat.afficherToast("Lien copié dans le presse-papiers.")
                    } label: { Label("Copier le lien", systemImage: "link") }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 32, height: 34)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(FbStyle.fond)
        .overlay(alignment: .bottom) { FbHairline() }
    }

    @ViewBuilder
    private var texte: some View {
        if !post.texte.isEmpty {
            Text(post.texte)
                .font(.system(size: 16))
                .foregroundStyle(.black)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, FbStyle.margeH)
                .padding(.top, 12)
                .padding(.bottom, 10)
        }
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
            if etat.nbReactions(post) > 0 {
                Button {
                    etat.basculerJaime(post.id)
                } label: {
                    HStack(spacing: 7) {
                        FbClusterReactions(reactions: post.reactions.isEmpty ? ["👍"] : post.reactions,
                                           taille: 21)
                        Text(fbNombre(etat.nbReactions(post)))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
            if post.nbPartages > 0 {
                Button {
                    etat.chemin.append(.partages(post.id))
                } label: {
                    Text(fbPluriel(post.nbPartages, "partage", "partages"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
    }

    // -------- sélecteur de tri « Plus pertinents ⌄ » (e015) — il TRIE réellement

    private var tri: some View {
        HStack(spacing: 8) {
            Menu {
                Button("Plus pertinents") { etat.triCommentaires = "Plus pertinents" }
                Button("Plus récents") { etat.triCommentaires = "Plus récents" }
            } label: {
                HStack(spacing: 5) {
                    Text(etat.triCommentaires).font(.system(size: 16)).foregroundStyle(.black)
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
            Spacer()
            Text(fbPluriel(liste.count, "commentaire", "commentaires"))
                .font(.system(size: 14))
                .foregroundStyle(FbStyle.texteGris)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 8)
    }

    private var aucunCommentaire: some View {
        Text("Aucun commentaire pour le moment. Soyez la première à réagir.")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.vertical, 24)
    }
}

// ---------------------------------------------------------------------------
// Composeur de commentaire (e015) — capsule « Commentez… ».
// (C) Le 📷 de la capsule est retiré : un commentaire photo n'avait aucune conséquence.
// D92 : « Répondre » vise réellement un commentaire ; le bandeau de réponse s'annule
// et disparaît avec l'écran (`nettoyerEcran`).
// ---------------------------------------------------------------------------

struct FbComposeurCommentaire: View {
    let cle: String
    @ObservedObject var etat: FbEtat
    @Binding var saisie: String

    var body: some View {
        VStack(spacing: 0) {
            if let cible = etat.cibleReponse {
                bandeauReponse(cible)
            }
            capsule
        }
        .background(FbStyle.fond)
    }

    private func bandeauReponse(_ c: FbCommentaire) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "arrowshape.turn.up.left.fill")
                .font(.system(size: 12)).foregroundStyle(FbStyle.texteGris)
            Text("Réponse à " + c.auteur)
                .font(.system(size: 13)).foregroundStyle(FbStyle.texteGris).lineLimit(1)
            Spacer()
            Button {
                Haptique.leger()
                etat.cibleReponse = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(FbStyle.texteGris)
                    .frame(width: 26, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 6)
    }

    private var capsule: some View {
        HStack(spacing: 10) {
            TextField("", text: $saisie,
                      prompt: Text(etat.cibleReponse == nil ? "Commentez…" : "Écrivez votre réponse…")
                        .foregroundColor(FbStyle.texteGris))
                .font(.system(size: 16))
                .foregroundStyle(.black)
                .submitLabel(.send)
                .onSubmit(envoyer)
            Button(action: envoyer) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(saisie.isEmpty ? Color(hex: 0xB0B3B8) : FbStyle.bleu)
            }
            .buttonStyle(.plain)
            .disabled(saisie.isEmpty)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Capsule().fill(FbStyle.champ))
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 8)
    }

    private func envoyer() {
        let t = saisie.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        etat.ajouterCommentaire(t, sur: cle)
        saisie = ""
    }
}

// ---------------------------------------------------------------- un commentaire (e015, e044, e122)
// D92 : « Voir les N réponses » DÉPLIE réellement les N réponses — plus jamais
// « Les réponses de ce fil ne sont pas disponibles hors connexion ».

struct FbCommentaireVue: View {
    let commentaire: FbCommentaire
    @ObservedObject var etat: FbEtat
    var niveau: Int = 0

    private var pouce: Int { etat.pouces[commentaire.id] ?? 0 }
    private var likes: Int {
        max(0, commentaire.likes + (etat.likesCommentaires.contains(commentaire.id) ? 1 : 0))
    }
    private var reponses: [FbCommentaire] { etat.reponses(commentaire) }
    private var deplie: Bool { etat.reponsesDepliees.contains(commentaire.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            rangee
            if deplie {
                filsDeplies
            }
        }
    }

    private var rangee: some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                etat.ouvrirProfil(commentaire.auteur)
            } label: {
                FbAvatar(photo: commentaire.photo, nom: commentaire.auteur,
                         taille: niveau == 0 ? 41 : 32, teinte: commentaire.teinte)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 4) {
                ligneNom
                corps
                actions
                if !reponses.isEmpty && niveau == 0 { boutonReponses }
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, FbStyle.margeH + CGFloat(niveau) * 30)
        .padding(.trailing, FbStyle.margeH)
        .padding(.bottom, 14)
    }

    private var filsDeplies: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(reponses) { r in
                FbCommentaireVue(commentaire: r, etat: etat, niveau: niveau + 1)
            }
            Button {
                etat.basculerReponses(commentaire)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.up").font(.system(size: 12, weight: .semibold))
                    Text("Masquer les réponses").font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(FbStyle.texteGris)
                .padding(.leading, FbStyle.margeH + 30)
                .padding(.bottom, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var ligneNom: some View {
        HStack(spacing: 5) {
            Text(commentaire.auteur)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
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
                 + Text(commentaire.texte).font(.system(size: 16)).foregroundColor(Color.black))
            } else {
                Text(commentaire.texte).font(.system(size: 16)).foregroundStyle(.black)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                etat.viserReponse(commentaire)
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
                    Text(String(likes)).font(.system(size: 14)).foregroundStyle(FbStyle.texteGris)
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

    private var boutonReponses: some View {
        Button {
            etat.basculerReponses(commentaire)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold))
                Text(reponses.count == 1 ? "Voir 1 réponse"
                     : "Voir les " + String(reponses.count) + " réponses")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(FbStyle.texteGris)
            .padding(.top, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 10. « PERSONNES QUI ONT PARTAGÉ ÇA » (e039, e045-e048)
//         D92 : la liste est construite depuis `post.partages` — le compteur
//         « N partages » et cette liste ne peuvent plus diverger.
// ============================================================================

struct FbPartageur: Identifiable {
    let id: String
    let nom: String
    var photo: String? = nil
    let teinte: UInt
    let reactions: [String]
    let nbReactions: Int
    let horaire: String
    let commentable: Bool
}

struct FbPartagesVue: View {
    let post: FbPost
    @ObservedObject var etat: FbEtat

    private var partageurs: [FbPartageur] { DonneesFb.partageurs(post) }

    var body: some View {
        VStack(spacing: 0) {
            FbBarrePoussee(titre: "Personnes qui ont partagé ça", etat: etat) {
                Button {
                    Haptique.leger(); etat.partage = post
                } label: {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .font(.system(size: 19)).foregroundStyle(.black)
                        .frame(width: 36, height: 36).contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .overlay(alignment: .bottom) { FbHairline() }
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(partageurs) { p in
                        carte(p)
                    }
                    if partageurs.isEmpty { vide }
                    Text("Certaines publications n'apparaissent peut-être pas ici à cause de leurs paramètres de confidentialité.")
                        .font(.system(size: 15))
                        .foregroundStyle(FbStyle.texteGris)
                        .padding(.horizontal, FbStyle.margeH)
                        .padding(.top, 10)
                    Color.clear.frame(height: FbStyle.hauteurPied + 24)
                }
                .padding(.top, 12)
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var vide: some View {
        Text("Personne n'a encore partagé cette publication.")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 24)
    }

    private func carte(_ p: FbPartageur) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    etat.ouvrirProfil(p.nom)
                } label: {
                    HStack(spacing: 10) {
                        FbAvatar(photo: p.photo, nom: p.nom, taille: 40, teinte: p.teinte)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(p.nom).font(.system(size: 16, weight: .semibold)).foregroundStyle(.black)
                            HStack(spacing: 4) {
                                Text(p.horaire).font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
                                Text("·").font(.system(size: 13)).foregroundStyle(FbStyle.texteGris)
                                Image(systemName: "globe.americas.fill").font(.system(size: 11))
                                    .foregroundStyle(FbStyle.texteGris)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                Spacer()
                Button {
                    UIPasteboard.general.string = "https://www.facebook.com/" + post.id
                    etat.afficherToast("Lien copié dans le presse-papiers.")
                } label: {
                    Image(systemName: "link").font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(hex: 0x3A3B3C))
                        .frame(width: 30, height: 26).contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            if p.nbReactions > 0 {
                HStack(spacing: 6) {
                    FbClusterReactions(reactions: p.reactions, taille: 18)
                    Text(String(p.nbReactions)).font(.system(size: 15)).foregroundStyle(FbStyle.texteGris)
                    Spacer()
                }
            }
            FbHairline()
            HStack(spacing: 0) {
                miniAction("hand.thumbsup", "J'aime")
                if p.commentable { miniAction("bubble.left", "Commenter") }
                miniAction("arrowshape.turn.up.right", "Partager")
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
            if titre == "Partager" {
                etat.partage = post
            } else if titre == "Commenter" {
                etat.chemin.append(.detail(post.id))
            } else {
                etat.basculerJaime(post.id + "-partage")
            }
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
//
// D92 / D82-C — la rangée « Partager sur » a été RAMENÉE aux destinations qui ont une
// conséquence réelle : Messenger (la publication arrive VRAIMENT dans la conversation) et
// Copier le lien (presse-papiers réel). Les icônes retirées — Votre story, WhatsApp, Statut
// WhatsApp, Messages, Threads, Instagram, Groupes, Plus — ne produisaient qu'un message
// ou un toast mensonger. Signalées à Joachim dans audit/facebook-lot280.md.
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
    @State private var mot = ""
    @State private var choixMessenger = false

    /// CORRECTIF LOT 280 : calque de la ZStack racine, plus une `sheet` — on se ferme
    /// en remettant l'état à nil, jamais avec `dismiss()` (qui fermerait TOUTE l'app).
    private func fermer() { etat.fermerPresentation() }

    private let destinations: [FbDestinationPartage] = [
        FbDestinationPartage(id: "messenger", titre: "Messenger", glyphe: "bolt.fill",
                             fond: 0x0C59FD, teinteGlyphe: 0xFFFFFF, contour: false),
        FbDestinationPartage(id: "lien", titre: "Copier le lien", glyphe: "link",
                             fond: 0xFFFFFF, teinteGlyphe: 0x1C1C1E, contour: true)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    carteComposeur
                    titre("Envoyer dans Messenger")
                    rangeeContacts
                    titre("Partager sur")
                    rangeeDestinations
                    Color.clear.frame(height: 24)
                }
                .padding(.top, 14)
            }
            .scrollIndicators(.hidden)
            // Place réservée à l'UNIQUE capsule home, dessinée par FacebookVue au-dessus
            // de ce calque : aucun contenu ne passe sous elle, et il n'y en a pas deux.
            Color.clear.frame(height: FbStyle.hauteurPied)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: 0xF0F2F5))
        .preferredColorScheme(.light)
        .fbCoquePresentee()
        .confirmationDialog("Envoyer dans Messenger",
                            isPresented: $choixMessenger, titleVisibility: .visible) {
            ForEach(DonneesFb.contactsMessenger) { c in
                Button(c.nom) { envoyerA(c.nom) }
            }
            Button("Annuler", role: .cancel) {}
        }
    }

    private func titre(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 21, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .padding(.top, 20)
            .padding(.bottom, 12)
    }

    // -------- carte composeur (e021) — « Partager maintenant » publie RÉELLEMENT dans le fil

    private var carteComposeur: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 46, teinte: 0x5B7CFA)
                VStack(alignment: .leading, spacing: 7) {
                    Text(DonneesFb.moiNom)
                        .font(.system(size: 19))
                        .foregroundStyle(.black)
                    Text("Ami(e)s")
                        .font(.system(size: 15))
                        .foregroundStyle(FbStyle.texteGris)
                }
                Spacer(minLength: 0)
            }
            apercu
            TextField("", text: $mot,
                      prompt: Text("Dites quelque chose à propos de ceci...").foregroundColor(FbStyle.texteGris),
                      axis: .vertical)
                .font(.system(size: 17))
                .foregroundStyle(.black)
                .lineLimit(1...4)
            FbBoutonPlein(titre: "Partager maintenant", hauteur: 44, corps: 17, rayon: 8) {
                partagerDansLeFil()
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .padding(.horizontal, 18)
    }

    private var apercu: some View {
        HStack(spacing: 10) {
            FbImage(cle: post.photos.first)
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(post.auteur)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black).lineLimit(1)
                Text(post.texte)
                    .font(.system(size: 13))
                    .foregroundStyle(FbStyle.texteGris).lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(9)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: 0xF0F2F5)))
    }

    private func partagerDansLeFil() {
        let t = mot.trimmingCharacters(in: .whitespacesAndNewlines)
        let texte = t.isEmpty
            ? ("Sarah Levasseur a partagé la publication de " + post.auteur + ".")
            : t
        fermer()
        etat.publier(texte: texte, photo: post.photos.first)
    }

    // -------- « Envoyer dans Messenger » : contacts Messenger de Sarah (aucun Marc)
    //          CONTRAT INTER-APPS : la carte du post arrive réellement dans la conversation.

    private var rangeeContacts: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(DonneesFb.contactsMessenger) { c in
                    Button {
                        envoyerA(c.nom)
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

    private func envoyerA(_ nom: String) {
        fermer()
        etat.partagerDansMessenger(post, destinataire: nom)
    }

    private var rangeeDestinations: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(destinations) { d in
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
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 8)
    }

    private func actionDestination(_ d: FbDestinationPartage) {
        Haptique.leger()
        switch d.id {
        case "messenger":
            choixMessenger = true
        default:
            UIPasteboard.general.string = post.lien ?? ("https://www.facebook.com/" + post.id)
            fermer()
            etat.afficherToast("Lien copié dans le presse-papiers.")
        }
    }
}

// ============================================================================
// MARK: - 11 bis. COMPOSEUR MINIMAL (D92 — « Quoi de neuf ? » qui fonctionne)
//         Texte + éventuellement UNE photo de la pellicule. Rien d'autre :
//         pas d'audience, pas d'identification, pas de gestion de publications.
// ============================================================================

struct FbComposeurVue: View {
    let cible: FbCibleComposeur
    @ObservedObject var etat: FbEtat
    @State private var texte = ""
    @State private var photo: String? = nil
    @FocusState private var champActif: Bool

    private var cles: [String] {
        DonneesFb.pellicule.filter { ChargeurPhoto.image($0) != nil }
    }

    private var pretAPublier: Bool {
        !texte.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || photo != nil
    }

    private func fermer() { etat.fermerPresentation() }

    var body: some View {
        VStack(spacing: 0) {
            entete
            FbHairline()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    auteur
                    champ
                    if let p = photo { apercu(p) }
                    pellicule
                    Color.clear.frame(height: 20)
                }
                .padding(.top, 14)
            }
            .scrollIndicators(.hidden)
            Color.clear.frame(height: FbStyle.hauteurPied)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FbStyle.fond)
        .preferredColorScheme(.light)
        .fbCoquePresentee()
        .onAppear {
            photo = cible.photoPrechargee
            champActif = true
        }
    }

    private var entete: some View {
        HStack(spacing: 8) {
            Button {
                Haptique.leger(); fermer()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(width: 38, height: 38)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Text("Créer une publication")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)
            Spacer()
            Button {
                publier()
            } label: {
                Text("Publier")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(pretAPublier ? Color.white : FbStyle.texteGris)
                    .padding(.horizontal, 16)
                    .frame(height: 34)
                    .background(RoundedRectangle(cornerRadius: 7)
                        .fill(pretAPublier ? FbStyle.bleu : FbStyle.grisBouton))
            }
            .buttonStyle(.plain)
            .disabled(!pretAPublier)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    private var auteur: some View {
        HStack(spacing: 12) {
            FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 44, teinte: 0x5B7CFA)
            VStack(alignment: .leading, spacing: 2) {
                Text(DonneesFb.moiNom)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                HStack(spacing: 5) {
                    Image(systemName: "person.2.fill").font(.system(size: 11))
                    Text("Ami(e)s").font(.system(size: 14))
                }
                .foregroundStyle(FbStyle.texteGris)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
    }

    private var champ: some View {
        TextField("", text: $texte,
                  prompt: Text("Quoi de neuf, Sarah ?").foregroundColor(FbStyle.texteGris),
                  axis: .vertical)
            .font(.system(size: 19))
            .foregroundStyle(.black)
            .lineLimit(3...10)
            .focused($champActif)
            .padding(.horizontal, FbStyle.margeH)
    }

    private func apercu(_ p: String) -> some View {
        FbMedia(cle: p, ratio: 1.0)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .topTrailing) {
                Button {
                    Haptique.leger(); photo = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.black.opacity(0.55)))
                }
                .buttonStyle(.plain)
                .padding(10)
            }
            .padding(.horizontal, FbStyle.margeH)
    }

    private var pellicule: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vos photos")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, FbStyle.margeH)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(cles, id: \.self) { c in
                        Button {
                            Haptique.leger()
                            photo = (photo == c) ? nil : c
                        } label: {
                            FbImage(cle: c)
                                .frame(width: 92, height: 92)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(photo == c ? FbStyle.bleu : Color.clear, lineWidth: 3))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, FbStyle.margeH)
            }
        }
    }

    private func publier() {
        guard pretAPublier else { return }
        let t = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        let corps = t.isEmpty ? "Sarah Levasseur a ajouté une photo." : t
        let image = photo
        fermer()
        etat.publier(texte: corps, photo: image)
    }
}

// ============================================================================
// MARK: - 12. VISIONNEUSE PHOTO « 1 de 2 » (e034-e036, e041-e043)
// ============================================================================

struct FbVisionneuseVue: View {
    let cible: FbCibleVisionneuse
    @ObservedObject var etat: FbEtat
    @State private var index: Int = 0

    private var photos: [String] { cible.post.photos.isEmpty ? ["p04"] : cible.post.photos }

    private func fermer() { etat.fermerPresentation() }

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
                // Capsule BLANCHE sur fond noir : dessinée par FacebookVue au-dessus de ce
                // calque, dans la zone sûre. Aucun plein écran ne piège plus le joueur.
                Color.clear.frame(height: FbStyle.hauteurPied)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
        .fbCoquePresentee()
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
                    .foregroundStyle(.white).frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Spacer()
            Text(String(index + 1) + " de " + String(photos.count))
                .font(.system(size: 17, weight: .medium)).foregroundStyle(.white)
            Spacer()
            Button {
                UIPasteboard.general.string = "https://www.facebook.com/" + cible.post.id
                etat.afficherToast("Lien copié dans le presse-papiers.")
            } label: {
                Image(systemName: "link").font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.white).frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .padding(.top, 26)
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
                        FbClusterReactions(reactions: cible.post.reactions.isEmpty
                                           ? ["👍"] : cible.post.reactions, taille: 18)
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
                    Text(fbPluriel(etat.nbCommentaires(cible.post), "commentaire", "commentaires"))
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
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 14)
    }
}

// ============================================================================
// MARK: - 13. STORY (e074)
//         Retours 279 : la flèche ⌄, les 3 points et le bouton « Suivre » au petit
//         dossier sont RETIRÉS (C) ; le tap sur l'auteur ouvre RÉELLEMENT son profil.
// ============================================================================

struct FbStoryVue: View {
    var tuile: FbStoryTuile = DonneesFb.stories[0]
    var etat: FbEtat = FbEtat()

    private func fermer() { etat.fermerPresentation() }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                carte
                Spacer(minLength: 0)
                Color.clear.frame(height: FbStyle.hauteurPied)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
        .fbCoquePresentee()
    }

    private var carte: some View {
        ZStack(alignment: .top) {
            FbMedia(cle: tuile.image, ratio: 0.5625)
                .contentShape(Rectangle())
                .onTapGesture { fermer() }
            VStack(alignment: .leading, spacing: 10) {
                Capsule().fill(Color.white.opacity(0.9)).frame(height: 2.5)
                    .padding(.horizontal, 8)
                entete
            }
            .padding(.top, 8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 8)
    }

    private var entete: some View {
        HStack(alignment: .top, spacing: 9) {
            // Retours 279 : le tap sur le profil de la personne / de la Page l'OUVRE.
            Button {
                ouvrirProfil()
            } label: {
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
                        Text(tuile.sousTitre == "Suggestions" ? "Suggestions · Voir le profil"
                             : "Voir le profil")
                            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Spacer(minLength: 0)
            Button { fermer() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
    }

    private func ouvrirProfil() {
        Haptique.leger()
        // Le calque n'est plus un `fullScreenCover` : `nettoyerEcran()` (déclenché par le
        // changement de pile) le referme dans le même cycle — plus aucun délai artificiel.
        etat.chemin.append(.profilPersonne(tuile.titre))
    }
}

// ============================================================================
// MARK: - 14. ONGLET REELS (e112, e126) + COMMENTAIRES DE REEL (e122, e137-e140)
//
// D92 / retours 279 — corrections de cohérence :
//  · 4 reels au lieu de 2 (le glissement vertical parcourt réellement la série) ;
//  · le compteur de commentaires vaut `etat.commentairesReel(reel).count` : « 3 commentaires »
//    ouvre bien 3 commentaires, et les réponses annoncées se déplient (FbCommentaireVue) ;
//  · le tap sur l'avatar OU sur le nom de la Page ouvre RÉELLEMENT son profil ;
//  · le partage propose la publication du reel (`DonneesFb.postDeReel`) et non celle,
//    absurde, d'une autre Page ;
//  · (C) le menu ⋯ de la barre haute est retiré : le rail droit porte déjà J'aime,
//    Commenter, Partager et Enregistrer, et « Signaler » n'avait aucune conséquence.
// ============================================================================

struct FbReelsVue: View {
    @ObservedObject var etat: FbEtat
    @State private var index: Int = 0

    private var reels: [FbReel] { DonneesFb.reels }
    private var reel: FbReel { reels[min(max(0, index), reels.count - 1)] }

    private var nbCommentaires: Int { etat.commentairesReel(reel).count }

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

    // -------- barre haute : ☰ · « Reels » 28 pt blanc · 🔍

    private var barreHaute: some View {
        FbBarreHaute(titre: "Reels", sombre: true,
                     ouvrirTiroir: { withAnimation(.easeOut(duration: 0.25)) { etat.tiroir = true } }) {
            FbActionBarre(glyphe: "magnifyingglass", cercle: true, sombre: true) {
                etat.chemin.append(.recherche)
            }
        }
    }

    // -------- rail droit : 4 items, tous avec un compteur VRAI (e112)

    private var rail: some View {
        VStack(spacing: 20) {
            itemRail(glyphe: etat.aimes.contains(reel.id) ? "hand.thumbsup.fill" : "hand.thumbsup",
                     valeur: reel.jaime + (etat.aimes.contains(reel.id) ? 1 : 0),
                     actif: etat.aimes.contains(reel.id)) {
                etat.basculerJaime(reel.id)
            }
            itemRail(glyphe: "bubble.right", valeur: nbCommentaires, actif: false) {
                Haptique.leger()
                etat.reelCommentaires = reel
            }
            itemRail(glyphe: "arrowshape.turn.up.right", valeur: reel.partages, actif: false) {
                Haptique.leger()
                etat.partage = DonneesFb.postDeReel(reel)
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
                    etat.afficherToast("Reel enregistré. Menu ☰ › Enregistrements.")
                }
            }
        }
        .padding(.trailing, 12)
        .padding(.bottom, FbStyle.reserveBas + 26)
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
                // Retours 279 : le tap sur l'auteur du reel ouvre son profil.
                Button {
                    etat.ouvrirProfil(reel.page)
                } label: {
                    HStack(spacing: 9) {
                        FbAvatar(photo: reel.image, nom: reel.page, taille: 34, teinte: reel.pageTeinte)
                            .overlay(Circle().strokeBorder(Color.white, lineWidth: 1.5))
                        Text(reel.page)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .lineLimit(1)
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.85))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
        .padding(.bottom, FbStyle.reserveBas - 24)
    }

    private var pillSuivre: some View {
        Button {
            Haptique.leger()
            if etat.suivis.contains(reel.id) {
                etat.suivis.remove(reel.id)
                etat.afficherToast("Vous ne suivez plus " + reel.page + ".")
            } else {
                etat.suivis.insert(reel.id)
                etat.afficherToast("Vous suivez " + reel.page + ".")
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
// Commentaires d'un Reel (e122) — calque bas de la ZStack racine, plus une `sheet`.
// Réutilise FbCommentaireVue : la rangée filmée exactement (Répondre, pastille de
// likes, 👍/👎 en contour, « Voir les N réponses » qui DÉPLIE les réponses).
// ---------------------------------------------------------------------------

struct FbReelCommentairesVue: View {
    let reel: FbReel
    @ObservedObject var etat: FbEtat
    @State private var saisie = ""

    private var liste: [FbCommentaire] { etat.commentairesReel(reel) }

    private func fermer() { etat.fermerPresentation() }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            feuille
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { fermer() }
        }
        .preferredColorScheme(.light)
        .fbCoquePresentee()
    }

    private var feuille: some View {
        VStack(spacing: 0) {
            poignee
            entete
            FbHairline()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(liste) { c in
                        FbCommentaireVue(commentaire: c, etat: etat)
                    }
                    if liste.isEmpty { aucun }
                    Color.clear.frame(height: 16)
                }
                .padding(.top, 10)
            }
            .scrollIndicators(.hidden)
            FbComposeurCommentaire(cle: reel.id, etat: etat, saisie: $saisie)
            // Place réservée à l'unique capsule home dessinée par FacebookVue.
            Color.clear.frame(height: FbStyle.hauteurPied)
        }
        .frame(height: 560)
        .background(
            FbStyle.fond
                .clipShape(RoundedRectangle(cornerRadius: 14))
        )
    }

    private var poignee: some View {
        Capsule()
            .fill(Color(hex: 0xC1C0C6))
            .frame(width: 40, height: 4)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private var entete: some View {
        HStack(spacing: 8) {
            Menu {
                Button("Plus pertinents") { etat.triCommentaires = "Plus pertinents" }
                Button("Plus récents") { etat.triCommentaires = "Plus récents" }
            } label: {
                HStack(spacing: 6) {
                    Text(etat.triCommentaires)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.black)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.black)
                }
            }
            Spacer(minLength: 0)
            Text(fbPluriel(liste.count, "commentaire", "commentaires"))
                .font(.system(size: 14))
                .foregroundStyle(FbStyle.texteGris)
            Button {
                Haptique.leger()
                fermer()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.black)
                    .frame(width: 34, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 8)
    }

    private var aucun: some View {
        Text("Aucun commentaire pour le moment. Soyez la première à réagir.")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.vertical, 24)
    }
}

// ============================================================================
// MARK: - 15. ONGLET AMI(E)S (e130, e145) + LISTES DE PERSONNES (e144, e146)
//
// Retours 279 : « Page Amis : bonne » — la structure filmée est conservée, seules les
// destinations mortes sont réparées. D92 :
//  · « Confirmer » ajoute RÉELLEMENT la personne aux ami(e)s (elle apparaît ensuite dans
//    « Vos ami(e)s » et dans le compteur du profil) ;
//  · les deux pills et « Voir tout » poussent une liste COMPLÈTE et non un toast ;
//  · une seule vue de liste (`FbListePersonnesVue`) sert Invitations, Suggestions,
//    « Vos ami(e)s » et « Ami(e)s de X » : aucune divergence possible entre les écrans.
// ============================================================================

/// Rangée d'invitation / de suggestion : avatar 90 pt (badge horaire vert en bas-droite),
/// nom 17 pt, ancienneté grise à droite, 2 boutons 36 pt r 8 pt.
struct FbRangeeInvitation: View {
    let personne: FbPersonne
    let titrePrincipal: String        // « Confirmer » ou « Ajouter ami(e) »
    @ObservedObject var etat: FbEtat

    private var traitee: String? { etat.invitationsTraitees[personne.nom] }
    private var invite: Bool { etat.ajoutes.contains(personne.id) }
    private var confirmation: Bool { titrePrincipal == "Confirmer" }

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
        .onTapGesture { etat.ouvrirProfil(personne.nom) }
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

    @ViewBuilder
    private var boutons: some View {
        if confirmation {
            HStack(spacing: 8) {
                FbBoutonPlein(titre: "Confirmer", hauteur: 36, corps: 16, rayon: 8) {
                    etat.accepterInvitation(personne)
                }
                FbBoutonPlein(titre: "Supprimer", hauteur: 36, corps: 16, rayon: 8,
                              couleur: FbStyle.grisBouton, texte: Color.black) {
                    etat.refuserInvitation(personne)
                }
            }
            .padding(.top, 4)
        } else {
            HStack(spacing: 8) {
                FbBoutonPlein(titre: invite ? "Invitation envoyée" : "Ajouter ami(e)",
                              hauteur: 36, corps: 16, rayon: 8,
                              couleur: invite ? FbStyle.grisBouton : FbStyle.bleu,
                              texte: invite ? Color.black : Color.white,
                              glyphe: invite ? "checkmark" : nil) {
                    etat.basculerAjout(personne)
                }
                FbBoutonPlein(titre: "Retirer", hauteur: 36, corps: 16, rayon: 8,
                              couleur: FbStyle.grisBouton, texte: Color.black) {
                    Haptique.leger()
                    etat.suggestionsRejetees.insert(personne.id)
                }
            }
            .padding(.top, 4)
        }
    }
}

struct FbAmisVue: View {
    @ObservedObject var etat: FbEtat

    private var invitations: [FbPersonne] {
        DonneesFb.invitations.filter { etat.invitationsTraitees[$0.nom] == nil }
    }

    private var suggestions: [FbPersonne] {
        DonneesFb.connaissezPeutEtre.filter { !etat.suggestionsRejetees.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    pills
                    titreSection("Invitations",
                                 lien: invitations.isEmpty ? nil : "Voir tout") {
                        etat.chemin.append(.personnes("invitations", "Invitations"))
                    }
                    ForEach(invitations) { p in
                        FbRangeeInvitation(personne: p, titrePrincipal: "Confirmer", etat: etat)
                    }
                    if invitations.isEmpty { aucuneInvitation }
                    FbSeparateurBloc().padding(.vertical, 6)
                    titreSection("Vous connaissez peut-être…", lien: nil, action: {})
                    ForEach(suggestions) { p in
                        FbRangeeInvitation(personne: p, titrePrincipal: "Ajouter ami(e)", etat: etat)
                    }
                    Color.clear.frame(height: FbStyle.reserveBas)
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

    // e145 : les deux pills poussent chacune un écran filmé (e144, e146).
    private var pills: some View {
        HStack(spacing: 9) {
            FbPill(titre: "Suggestions", actif: etat.pillAmis == 1) {
                etat.pillAmis = 1
                etat.chemin.append(.personnes("suggestions", "Suggestions"))
            }
            FbPill(titre: "Vos ami(e)s", actif: etat.pillAmis == 2) {
                etat.pillAmis = 2
                etat.chemin.append(.personnes("vosAmis", "Vos ami(e)s"))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 6)
        .padding(.bottom, 12)
    }

    private var aucuneInvitation: some View {
        Text("Aucune invitation en attente.")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.vertical, 14)
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
// Liste de personnes POUSSÉE (e144 « Suggestions », e146 « Vos ami(e)s »,
// « Ami(e)s de X » depuis le profil d'un tiers, « Invitations » depuis « Voir tout »).
// Une seule vue, quatre clés : le compteur qui a mené ici et la liste affichée
// proviennent de la même source (D92).
// ---------------------------------------------------------------------------

struct FbListePersonnesVue: View {
    let cle: String
    let titre: String
    @ObservedObject var etat: FbEtat
    @State private var filtre = ""

    /// Les rangées « avec boutons » (invitations, suggestions) contre les rangées simples.
    private var avecBoutons: Bool { cle == "invitations" || cle == "suggestions" }

    private var source: [FbPersonne] {
        if cle == "invitations" { return DonneesFb.invitations }
        if cle == "suggestions" {
            return DonneesFb.connaissezPeutEtre.filter { !etat.suggestionsRejetees.contains($0.id) }
                + DonneesFb.suggestionsFil.filter { !etat.suggestionsRejetees.contains($0.id) }
        }
        if cle.hasPrefix("amisDe:") {
            let nom = String(cle.dropFirst("amisDe:".count))
            if nom == DonneesFb.moiNom { return etat.mesAmis }
            return DonneesFb.amis(de: DonneesFb.personne(nom))
        }
        return etat.mesAmis
    }

    private var liste: [FbPersonne] {
        let t = filtre.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return source }
        return source.filter { $0.nom.localizedCaseInsensitiveContains(t) }
    }

    var body: some View {
        VStack(spacing: 0) {
            FbBarrePoussee(titre: titre, etat: etat) {
                FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
            }
            .overlay(alignment: .bottom) { FbHairline() }
            if !avecBoutons { champ }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    enTeteCompteur
                    if avecBoutons {
                        ForEach(liste) { p in
                            FbRangeeInvitation(personne: p,
                                               titrePrincipal: cle == "invitations" ? "Confirmer" : "Ajouter ami(e)",
                                               etat: etat)
                        }
                    } else {
                        ForEach(liste) { p in
                            rangee(p)
                        }
                    }
                    if liste.isEmpty { vide }
                    Color.clear.frame(height: FbStyle.hauteurPied + 30)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var enTeteCompteur: some View {
        Text(fbPluriel(source.count, "personne", "personnes"))
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 12)
            .padding(.bottom, 6)
    }

    private var champ: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(FbStyle.texteGris)
            TextField("", text: $filtre,
                      prompt: Text("Rechercher dans la liste").foregroundColor(FbStyle.texteGris))
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
        Text(filtre.isEmpty
             ? "Cette liste est vide."
             : "Aucun résultat pour « " + filtre + " ».")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 24)
    }

    private func rangee(_ p: FbPersonne) -> some View {
        HStack(spacing: 14) {
            FbAvatar(photo: p.photo, nom: p.nom, taille: 56, teinte: p.teinte)
            VStack(alignment: .leading, spacing: 2) {
                Text(p.nom)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                Text(p.detail ?? p.ville)
                    .font(.system(size: 14))
                    .foregroundStyle(FbStyle.texteGris)
                    .lineLimit(1)
            }
            Spacer(minLength: 6)
            Button {
                etat.ouvrirMessenger()
            } label: {
                FbIconeMessenger(taille: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { etat.ouvrirProfil(p.nom) }
    }
}

// ============================================================================
// MARK: - 16. ONGLET GROUPES (e147-e151) + « VOS GROUPES »
//
// Retours 279 : « impossible de réellement rejoindre un groupe ; le groupe rejoint n'est
// ensuite pas visible ». D92 :
//  · « Rejoindre » bascule en « Membre » et le groupe entre dans « Vos groupes » ;
//  · « Vos groupes » est un écran RÉEL (route .vosGroupes) alimenté par `etat.mesGroupes`,
//    dont le compteur du titre vaut la longueur de la liste ;
//  · (C) le « + » de création de groupe et l'entrée « Invitations » sont retirés : ils ne
//    produisaient qu'un message « hors connexion » (banni du lot 280).
// ============================================================================

struct FbGroupesVue: View {
    @ObservedObject var etat: FbEtat

    private let colonnes = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    private var visibles: [FbGroupe] {
        DonneesFb.groupes.filter { !etat.groupesRejetes.contains($0.id) && !etat.estMembre($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            entete
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    pills
                    if !etat.mesGroupes.isEmpty { railMesGroupes }
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
                    Color.clear.frame(height: FbStyle.reserveBas)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var entete: some View {
        FbBarreHaute(titre: "Groupes",
                     ouvrirTiroir: { withAnimation(.easeOut(duration: 0.25)) { etat.tiroir = true } }) {
            FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
        }
    }

    // e147 : pill bleue « Découvrir » ; « Vos groupes » POUSSE la liste réelle.
    private var pills: some View {
        HStack(spacing: 9) {
            FbPill(titre: "Découvrir", actif: true) {
                Haptique.leger()
            }
            FbPill(titre: "Vos groupes", actif: false) {
                etat.chemin.append(.vosGroupes)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }

    /// Rail des groupes réellement rejoints : la preuve visible que « Rejoindre » a agi.
    private var railMesGroupes: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Vos groupes")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.black)
                Spacer()
                Button {
                    etat.chemin.append(.vosGroupes)
                } label: {
                    Text("Voir tout")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(FbStyle.bleu)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, FbStyle.margeH)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(etat.mesGroupes) { g in
                        Button {
                            etat.chemin.append(.vosGroupes)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                FbImage(cle: g.image)
                                    .frame(width: 150, height: 96)
                                    .clipShape(RoundedRectangle(cornerRadius: 9))
                                Text(g.nom)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.black)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 150, alignment: .leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, FbStyle.margeH)
            }
            FbSeparateurBloc().padding(.vertical, 10)
        }
        .padding(.bottom, 4)
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
/// bouton « Rejoindre » BLEU PLEIN 35 pt qui bascule en « Membre » (e147).
struct FbCarteGroupe: View {
    let groupe: FbGroupe
    @ObservedObject var etat: FbEtat

    private var membre: Bool { etat.estMembre(groupe.id) }

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
            FbBoutonPlein(titre: membre ? "Membre" : "Rejoindre",
                          hauteur: 35, corps: 16, rayon: 5,
                          couleur: membre ? FbStyle.grisBouton : FbStyle.bleu,
                          texte: membre ? Color.black : Color.white,
                          glyphe: membre ? "checkmark" : nil) {
                etat.basculerGroupe(groupe.id, nom: groupe.nom)
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

// ---------------------------------------------------------------------------
// « Vos groupes » — écran POUSSÉ. Contient EXACTEMENT les groupes rejoints, avec
// « Quitter » qui les en retire (l'état persiste dans les deux sens).
// ---------------------------------------------------------------------------

struct FbVosGroupesVue: View {
    @ObservedObject var etat: FbEtat

    private var liste: [FbGroupe] { etat.mesGroupes }

    var body: some View {
        VStack(spacing: 0) {
            FbBarrePoussee(titre: "Vos groupes", etat: etat) {
                FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
            }
            .overlay(alignment: .bottom) { FbHairline() }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text(fbPluriel(liste.count, "groupe rejoint", "groupes rejoints"))
                        .font(.system(size: 15))
                        .foregroundStyle(FbStyle.texteGris)
                        .padding(.horizontal, FbStyle.margeH)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    ForEach(liste) { g in
                        rangee(g)
                        FbHairline(indent: FbStyle.margeH)
                    }
                    if liste.isEmpty { vide }
                    Color.clear.frame(height: FbStyle.hauteurPied + 30)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var vide: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Vous n'avez rejoint aucun groupe.")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Text("Ouvrez l'onglet Groupes et touchez « Rejoindre » sur une suggestion.")
                .font(.system(size: 15))
                .foregroundStyle(FbStyle.texteGris)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 20)
    }

    private func rangee(_ g: FbGroupe) -> some View {
        HStack(spacing: 12) {
            FbImage(cle: g.image)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 3) {
                Text(g.nom)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .lineLimit(2)
                Text(g.detail)
                    .font(.system(size: 13.5))
                    .foregroundStyle(FbStyle.texteGris)
                    .lineLimit(1)
            }
            Spacer(minLength: 6)
            Button {
                etat.basculerGroupe(g.id, nom: g.nom)
            } label: {
                Text("Quitter")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 14)
                    .frame(height: 32)
                    .background(RoundedRectangle(cornerRadius: 6).fill(FbStyle.grisBouton))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
    }
}

// ============================================================================
// MARK: - 17. ONGLET NOTIFICATIONS (e152-e154)
//
// Bloc #E2EEFE continu, avatar 60 pt + badge de type bleu. Retours 279 : « Notifications :
// bon » — seule la destination du tap est réparée. Le tap POUSSE la publication concernée
// dans la pile (jamais un 2ᵉ fil en plein écran), ou le profil de la personne citée.
// (C) le ⋯ de rangée et « Paramètres de notification » sont retirés : aucune conséquence.
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
                    Color.clear.frame(height: FbStyle.reserveBas)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var entete: some View {
        FbBarreHaute(titre: "Notifications",
                     ouvrirTiroir: { withAnimation(.easeOut(duration: 0.25)) { etat.tiroir = true } }) {
            FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
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
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(FbStyle.texteGris)
                .padding(.top, 3)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture(perform: ouvrir)
    }

    /// (A) Chaque notification mène à un contenu qui EXISTE : la publication citée, le
    /// profil de la personne citée, ou la liste des suggestions d'ami(e)s.
    private func ouvrir() {
        Haptique.leger()
        if let cible = notif.postCible {
            etat.chemin.append(.detail(cible))
        } else if let nom = notif.personneCible {
            etat.chemin.append(.profilPersonne(nom))
        } else {
            etat.chemin.append(.personnes("suggestions", "Suggestions"))
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
// MARK: - 18. ONGLET PROFIL DE SARAH (e155, e156, e158) — ÉPURÉ (retours 279)
//
// RETIRÉS (C), sur demande explicite de Joachim :
//   · le stylo « modifier le profil » (barre haute ET section Informations) ;
//   · la petite croix et les 3 points de la barre haute ;
//   · la flèche ▾ à côté de « Sarah Levasseur » ;
//   · l'autre flèche grise (chevron cerclé de la ligne d'identité) ;
//   · « Créer en direct » (chip « En direct ») ;
//   · « Gérer les publications » ;
//   · « Filtres », « Ajouter à la story », « Partager une note », « Créer une Page ».
// AJOUTÉS / RÉPARÉS (D92) :
//   · « N amis » ouvre la liste des N ami(e)s, « N publications » ouvre les N publications ;
//   · les deux compteurs sont CALCULÉS (`etat.mesAmis`, `etat.publications(de:)`) ;
//   · « Quoi de neuf ? » ouvre le composeur minimal, et la publication créée apparaît
//     immédiatement ici comme dans le fil ;
//   · la pill « Photos » filtre RÉELLEMENT les publications avec image.
// ============================================================================

struct FbProfilVue: View {
    @ObservedObject var etat: FbEtat

    private var mesPublications: [FbPost] { etat.publications(de: DonneesFb.moiNom) }

    private var affichees: [FbPost] {
        etat.pillProfil == 1 ? mesPublications.filter { !$0.photos.isEmpty } : mesPublications
    }

    var body: some View {
        VStack(spacing: 0) {
            entete
            pills
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    identite
                    lieu
                    boutonPublier
                    informations
                    amis
                    FbSeparateurBloc().padding(.vertical, 10)
                    titrePublications
                    composer
                    chipReel
                    ForEach(affichees) { p in
                        FbPostVue(post: p, etat: etat)
                        FbSeparateurBloc()
                    }
                    if affichees.isEmpty { aucune }
                    Color.clear.frame(height: FbStyle.reserveBas)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    // -------- barre haute : ☰ · « Sarah Levasseur » centré · 🔍 (rien d'autre)

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
            Text(DonneesFb.moiNom)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.black)
                .lineLimit(1)
            Spacer(minLength: 4)

            FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
                .padding(.trailing, 8)
        }
        .frame(height: 47)
        .background(FbStyle.fond)
    }

    private var pills: some View {
        HStack(spacing: 9) {
            FbPillProfil(titre: "Tous", actif: etat.pillProfil == 0) { etat.pillProfil = 0 }
            FbPillProfil(titre: "Photos", actif: etat.pillProfil == 1) { etat.pillProfil = 1 }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 8)
        .background(FbStyle.fond)
    }

    // -------- identité (e158) : avatar 90 pt, nom 24 pt, « N amis · N publications »

    private var identite: some View {
        HStack(alignment: .center, spacing: 14) {
            Button {
                Haptique.leger()
                etat.visionneuse = FbCibleVisionneuse(id: "moi",
                                                      post: DonneesFb.postProfil, index: 0)
            } label: {
                FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 90, teinte: 0x5B7CFA)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(DonneesFb.moiNom)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                compteurs
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    /// Retours 279 : « Tap 5 amis → voir les 5 amis », « Tap 3 publications → voir les 3
    /// publications ». Les deux nombres viennent des listes qui s'ouvrent au tap.
    private var compteurs: some View {
        HStack(spacing: 5) {
            Button {
                etat.chemin.append(.personnes("amisDe:" + DonneesFb.moiNom, "Ami(e)s"))
            } label: {
                Text(fbPluriel(etat.mesAmis.count, "ami", "amis"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
            }
            .buttonStyle(.plain)
            Text("·")
                .font(.system(size: 16))
                .foregroundStyle(Color.black)
            Button {
                etat.chemin.append(.publications(DonneesFb.moiNom))
            } label: {
                Text(fbPluriel(mesPublications.count, "publication", "publications"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
            }
            .buttonStyle(.plain)
        }
    }

    private var lieu: some View {
        HStack(spacing: 9) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 16))
                .foregroundStyle(Color.black)
            Text(DonneesFb.moiVille)
                .font(.system(size: 17))
                .foregroundStyle(Color.black)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 12)
    }

    /// Unique bouton d'action du profil : il PUBLIE réellement (D92).
    private var boutonPublier: some View {
        FbBoutonPlein(titre: "Créer une publication", hauteur: 42, corps: 17, rayon: 8,
                      glyphe: "plus.circle") {
            Haptique.leger()
            etat.composeur = FbCibleComposeur(id: "profil")
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 18)
    }

    private var informations: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Informations personnelles")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Color.black)
                .padding(.bottom, 8)
            FbRangeeInfo(glyphe: "mappin.and.ellipse", texte: DonneesFb.moiVille)
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
                    etat.chemin.append(.personnes("amisDe:" + DonneesFb.moiNom, "Ami(e)s"))
                } label: {
                    Text("Voir tout")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(FbStyle.bleu)
                }
                .buttonStyle(.plain)
            }
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(etat.mesAmis.prefix(4))) { a in
                    Button {
                        etat.ouvrirProfil(a.nom)
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

    private var titrePublications: some View {
        Button {
            etat.chemin.append(.publications(DonneesFb.moiNom))
        } label: {
            HStack {
                Text("Toutes les publications")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(Color.black)
                Spacer()
                Text(fbPluriel(mesPublications.count, "publication", "publications"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(FbStyle.bleu)
            }
            .padding(.horizontal, FbStyle.margeH)
            .padding(.bottom, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var composer: some View {
        HStack(spacing: 12) {
            FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 40, teinte: 0x5B7CFA)
            Text("Quoi de neuf ?")
                .font(.system(size: 17))
                .foregroundStyle(FbStyle.texteGris)
            Spacer()
            Button {
                Haptique.leger()
                etat.composeur = FbCibleComposeur(id: "profil-photo",
                                                  photoPrechargee: DonneesFb.pellicule.first)
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: 0x3A3B3C))
                    .frame(width: 34, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptique.leger()
            etat.composeur = FbCibleComposeur(id: "profil")
        }
    }

    // e155 : bande grise à chips. (C) « En direct » retiré — l'appareil photo ne sert
    // à aucune histoire. Seul « Reel » reste, et il MÈNE à l'onglet Reels.
    private var chipReel: some View {
        HStack(spacing: 12) {
            Button {
                Haptique.leger()
                etat.onglet = 1
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: 0xF3425F))
                    Text("Reels")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.black)
                }
                .padding(.horizontal, 22)
                .frame(height: 42)
                .background(Capsule().fill(Color.white))
            }
            .buttonStyle(.plain)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
        .background(Color(hex: 0xF0F1F3))
    }

    private var aucune: some View {
        Text(etat.pillProfil == 1
             ? "Aucune publication avec photo pour le moment."
             : "Vous n'avez encore rien publié.")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.vertical, 26)
    }
}

// ---------------------------------------------------------------------------
// « N publications » — écran POUSSÉ (Sarah ou un tiers).
// La liste est EXACTEMENT celle comptée par le compteur qui a mené ici.
// ---------------------------------------------------------------------------

struct FbPublicationsVue: View {
    let nom: String
    @ObservedObject var etat: FbEtat

    private var liste: [FbPost] { etat.publications(de: nom) }

    var body: some View {
        VStack(spacing: 0) {
            FbBarrePoussee(titre: "Publications", etat: etat) {
                FbActionBarre(glyphe: "magnifyingglass") { etat.chemin.append(.recherche) }
            }
            .overlay(alignment: .bottom) { FbHairline() }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    entete
                    ForEach(liste) { p in
                        FbPostVue(post: p, etat: etat)
                        FbSeparateurBloc()
                    }
                    if liste.isEmpty { vide }
                    Color.clear.frame(height: FbStyle.hauteurPied + 30)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var entete: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(nom)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.black)
            Text(fbPluriel(liste.count, "publication", "publications"))
                .font(.system(size: 15))
                .foregroundStyle(FbStyle.texteGris)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var vide: some View {
        Text(nom + " n'a aucune publication visible par vous.")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 24)
    }
}

// ============================================================================
// MARK: - 19. PROFIL D'UNE AUTRE PERSONNE (e067, e040-e044)
//
// Retours 279 : « la flèche Retour ne fonctionne pas ». Trois causes cumulées, corrigées :
//  1. le chevron était collé au bord haut, sous la bande d'état de la coque, dont le fond
//     `.ultraThinMaterial` capte les taps → `.padding(.top, 10)` défensif + zone 44×44
//     (`FbBoutonRetour`, avec `contentShape`). Le diff LPProto qui supprime la cause à la
//     racine est proposé dans src/patches/facebook-lpproto-v31.md, LPProto n'est PAS modifié ;
//  2. le chevron flottant était posé en `.overlay` d'un ScrollView : il est désormais un
//     calque de ZStack au-dessus de la couverture, jamais recouvert par le contenu défilant ;
//  3. il n'appelait pas `nettoyerEcran()` : un toast pouvait survivre au dépilement.
// Ce profil sert AUSSI le contrat Messenger → Facebook (« Voir le profil Facebook »).
// ============================================================================

struct FbProfilPersonneVue: View {
    let personne: FbPersonne
    @ObservedObject var etat: FbEtat

    private var ajoute: Bool { etat.ajoutes.contains(personne.id) }
    private var amie: Bool { etat.estAmie(personne.nom) }
    private var sesAmis: [FbPersonne] { DonneesFb.amis(de: personne) }
    private var sesPublications: [FbPost] { etat.publications(de: personne.nom) }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    couverture
                    identite
                    boutons
                    pointsCommuns
                    informations
                    amis
                    publications
                    Color.clear.frame(height: FbStyle.hauteurPied + 30)
                }
            }
            .scrollIndicators(.hidden)
            barreFlottante
        }
        .background(FbStyle.fond)
    }

    // -------- bandeau de couverture

    private var couverture: some View {
        FbMedia(cle: personne.photo ?? "p31", ratio: 2.6)
            .overlay { Color.black.opacity(0.18) }
    }

    /// Calque de retour : TOUJOURS au-dessus du contenu, jamais dans la bande d'état.
    private var barreFlottante: some View {
        HStack {
            FbBoutonRetour(etat: etat, clair: true)
            Spacer()
            FbActionBarre(glyphe: "magnifyingglass", sombre: true) {
                etat.chemin.append(.recherche)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 10)
    }

    // -------- identité : avatar 90 pt, nom 24 pt, « N ami(e)s · N publications »

    private var identite: some View {
        HStack(alignment: .center, spacing: 14) {
            FbAvatar(photo: personne.photo, nom: personne.nom, taille: 90, teinte: personne.teinte)
                .overlay(Circle().strokeBorder(Color.white, lineWidth: 3))
            VStack(alignment: .leading, spacing: 3) {
                Text(personne.nom)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.black)
                    .lineLimit(2)
                compteurs
                if let d = personne.detail {
                    Text(d)
                        .font(.system(size: 14))
                        .foregroundStyle(FbStyle.texteGris)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }

    /// D92 : les deux compteurs ouvrent les deux listes correspondantes, et valent leur taille.
    private var compteurs: some View {
        HStack(spacing: 5) {
            Button {
                etat.chemin.append(.amisDe(personne.nom))
            } label: {
                Text(fbPluriel(sesAmis.count, "ami(e)", "ami(e)s"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
            }
            .buttonStyle(.plain)
            Text("·")
                .font(.system(size: 16))
                .foregroundStyle(Color.black)
            Button {
                etat.chemin.append(.publications(personne.nom))
            } label: {
                Text(fbPluriel(sesPublications.count, "publication", "publications"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
            }
            .buttonStyle(.plain)
        }
    }

    private var boutons: some View {
        HStack(spacing: 10) {
            if amie {
                FbBoutonPlein(titre: "Ami(e)s", hauteur: 42, corps: 17, rayon: 8,
                              couleur: FbStyle.grisBouton, texte: Color.black,
                              glyphe: "person.2.fill") {
                    Haptique.leger()
                    etat.chemin.append(.amisDe(personne.nom))
                }
            } else {
                FbBoutonPlein(titre: ajoute ? "Invitation envoyée" : "Ajouter ami(e)",
                              hauteur: 42, corps: 17, rayon: 8,
                              couleur: ajoute ? FbStyle.grisBouton : FbStyle.bleu,
                              texte: ajoute ? Color.black : Color.white,
                              glyphe: ajoute ? "checkmark" : "person.badge.plus") {
                    etat.basculerAjout(personne)
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
            (Text("Vous habitez tou(te)s les deux à ").font(.system(size: 16)).foregroundColor(Color.black)
             + Text(personne.ville).font(.system(size: 16, weight: .semibold)).foregroundColor(Color.black)
             + Text(".").font(.system(size: 16)).foregroundColor(Color.black))
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(FbStyle.sepFin, lineWidth: 1))
        .padding(.horizontal, FbStyle.margeH)
        .padding(.bottom, 14)
    }

    private var informations: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Informations personnelles")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Color.black)
                .padding(.bottom, 8)
            FbRangeeInfo(glyphe: "house", texte: personne.ville)
            if personne.estPage {
                FbRangeeInfo(glyphe: "flag", texte: "Page")
            } else {
                FbRangeeInfo(glyphe: "circles.hexagonpath", texte: "Femme")
            }
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
                    etat.chemin.append(.amisDe(personne.nom))
                } label: {
                    Text("Voir tout")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(FbStyle.bleu)
                }
                .buttonStyle(.plain)
            }
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(sesAmis.prefix(4))) { a in
                    Button {
                        etat.ouvrirProfil(a.nom)
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
        .padding(.bottom, 18)
    }

    private var publications: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Publications")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Color.black)
                .padding(.horizontal, FbStyle.margeH)
                .padding(.bottom, 6)
            ForEach(sesPublications) { p in
                FbPostVue(post: p, etat: etat)
                FbSeparateurBloc()
            }
            if sesPublications.isEmpty {
                Text("Aucune publication visible par vous.")
                    .font(.system(size: 15))
                    .foregroundStyle(FbStyle.texteGris)
                    .padding(.horizontal, FbStyle.margeH)
                    .padding(.vertical, 22)
            }
        }
    }
}

/// Pill d'onglet de profil : actif = capsule #D2E7FC + texte bleu, sinon texte nu (e155, e158).
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
// MARK: - 20. RECHERCHE (e067)
//
// D92 : la recherche ne promet rien qu'elle ne tienne. Elle cherche dans les deux
// ensembles qui EXISTENT réellement dans l'app — les personnes/Pages et les groupes —
// et chaque résultat mène à un écran réel. Aucun historique inventé, aucun message
// « hors connexion ».
// ============================================================================

struct FbRechercheVue: View {
    @ObservedObject var etat: FbEtat
    @State private var saisie = ""
    @FocusState private var actif: Bool

    private var terme: String {
        saisie.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var personnes: [FbPersonne] {
        guard !terme.isEmpty else { return [] }
        var vues: Set<String> = []
        var sortie: [FbPersonne] = []
        for p in DonneesFb.personnes where p.nom.localizedCaseInsensitiveContains(terme) {
            if vues.contains(p.nom) { continue }
            vues.insert(p.nom)
            sortie.append(p)
        }
        return sortie
    }

    private var groupes: [FbGroupe] {
        guard !terme.isEmpty else { return [] }
        return DonneesFb.groupes.filter { $0.nom.localizedCaseInsensitiveContains(terme) }
    }

    private var vide: Bool { personnes.isEmpty && groupes.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            barre
            FbHairline()
            contenu
            Spacer(minLength: 0)
            Color.clear.frame(height: FbStyle.hauteurPied)
        }
        .background(FbStyle.fond)
        .onAppear { actif = true }
    }

    private var barre: some View {
        HStack(spacing: 8) {
            FbBoutonRetour(etat: etat)
            champ
        }
        .padding(.horizontal, 6)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var champ: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(FbStyle.texteGris)
            TextField("", text: $saisie,
                      prompt: Text("Rechercher sur Facebook").foregroundColor(FbStyle.texteGris))
                .font(.system(size: 17))
                .foregroundStyle(Color.black)
                .focused($actif)
                .submitLabel(.search)
            if !saisie.isEmpty {
                Button {
                    Haptique.leger()
                    saisie = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(FbStyle.texteGris)
                        .frame(width: 26, height: 26)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 40)
        .background(Capsule().fill(FbStyle.champ))
    }

    @ViewBuilder
    private var contenu: some View {
        if terme.isEmpty {
            invite
        } else if vide {
            aucunResultat
        } else {
            resultats
        }
    }

    /// État de départ (e067) : la recherche annonce seulement ce qu'elle sait faire.
    private var invite: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Rechercher")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Text("Tapez le nom d'une personne, d'une Page ou d'un groupe.")
                .font(.system(size: 15))
                .foregroundStyle(FbStyle.texteGris)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 18)
    }

    private var aucunResultat: some View {
        Text("Aucun résultat pour « " + terme + " ».")
            .font(.system(size: 15))
            .foregroundStyle(FbStyle.texteGris)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 20)
    }

    private var resultats: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if !personnes.isEmpty {
                    titre("Personnes et Pages")
                    ForEach(personnes) { p in
                        rangeePersonne(p)
                    }
                }
                if !groupes.isEmpty {
                    titre("Groupes")
                    ForEach(groupes) { g in
                        rangeeGroupe(g)
                    }
                }
                Color.clear.frame(height: 30)
            }
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
    }

    private func titre(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Color.black)
            .padding(.horizontal, FbStyle.margeH)
            .padding(.top, 8)
            .padding(.bottom, 6)
    }

    private func rangeePersonne(_ p: FbPersonne) -> some View {
        Button {
            etat.ouvrirProfil(p.nom)
        } label: {
            HStack(spacing: 13) {
                FbAvatar(photo: p.photo, nom: p.nom, taille: 48, teinte: p.teinte)
                VStack(alignment: .leading, spacing: 2) {
                    Text(p.nom)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                    Text(p.detail ?? p.ville)
                        .font(.system(size: 14))
                        .foregroundStyle(FbStyle.texteGris)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, FbStyle.margeH)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func rangeeGroupe(_ g: FbGroupe) -> some View {
        HStack(spacing: 13) {
            FbImage(cle: g.image)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 2) {
                Text(g.nom)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .lineLimit(2)
                Text(g.detail)
                    .font(.system(size: 14))
                    .foregroundStyle(FbStyle.texteGris)
                    .lineLimit(1)
            }
            Spacer(minLength: 6)
            Button {
                etat.basculerGroupe(g.id, nom: g.nom)
            } label: {
                Text(etat.estMembre(g.id) ? "Membre" : "Rejoindre")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(etat.estMembre(g.id) ? Color.black : Color.white)
                    .padding(.horizontal, 14)
                    .frame(height: 32)
                    .background(RoundedRectangle(cornerRadius: 6)
                        .fill(etat.estMembre(g.id) ? FbStyle.grisBouton : FbStyle.bleu))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { etat.chemin.append(.vosGroupes) }
    }
}

// ============================================================================
// MARK: - 21. ENREGISTREMENTS (Menu ☰ › Enregistrements)
//         D92 : « Enregistrer » ne se contentait plus d'un toast — la publication
//         se retrouve RÉELLEMENT ici, et « Retirer » l'en enlève.
// ============================================================================

struct FbEnregistrementsVue: View {
    @ObservedObject var etat: FbEtat

    private var posts: [FbPost] {
        (etat.postsAjoutes + DonneesFb.posts).filter { etat.enregistres.contains($0.id) }
    }

    private var reels: [FbReel] {
        DonneesFb.reels.filter { etat.enregistres.contains($0.id) }
    }

    private var total: Int { posts.count + reels.count }

    var body: some View {
        VStack(spacing: 0) {
            FbBarrePoussee(titre: "Enregistrements", etat: etat) {
                EmptyView()
            }
            .overlay(alignment: .bottom) { FbHairline() }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text(fbPluriel(total, "élément enregistré", "éléments enregistrés"))
                        .font(.system(size: 15))
                        .foregroundStyle(FbStyle.texteGris)
                        .padding(.horizontal, FbStyle.margeH)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    ForEach(posts) { p in
                        rangeePost(p)
                        FbHairline(indent: FbStyle.margeH)
                    }
                    ForEach(reels) { r in
                        rangeeReel(r)
                        FbHairline(indent: FbStyle.margeH)
                    }
                    if total == 0 { vide }
                    Color.clear.frame(height: FbStyle.hauteurPied + 30)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(FbStyle.fond)
    }

    private var vide: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Aucun enregistrement.")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Text("Touchez le signet d'une publication ou d'un Reel pour la retrouver ici.")
                .font(.system(size: 15))
                .foregroundStyle(FbStyle.texteGris)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.top, 20)
    }

    private func rangeePost(_ p: FbPost) -> some View {
        HStack(spacing: 12) {
            FbImage(cle: p.photos.first, teinte: p.teinteAuteur)
                .frame(width: 66, height: 66)
                .clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 3) {
                Text(p.auteur)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                Text(p.texte)
                    .font(.system(size: 13.5))
                    .foregroundStyle(FbStyle.texteGris)
                    .lineLimit(2)
            }
            Spacer(minLength: 6)
            boutonRetirer(p.id)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { etat.chemin.append(.detail(p.id)) }
    }

    private func rangeeReel(_ r: FbReel) -> some View {
        HStack(spacing: 12) {
            FbImage(cle: r.image)
                .frame(width: 66, height: 66)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white)
                        .shadow(color: Color.black.opacity(0.5), radius: 3)
                }
            VStack(alignment: .leading, spacing: 3) {
                Text(r.page)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                Text(r.legende)
                    .font(.system(size: 13.5))
                    .foregroundStyle(FbStyle.texteGris)
                    .lineLimit(2)
            }
            Spacer(minLength: 6)
            boutonRetirer(r.id)
        }
        .padding(.horizontal, FbStyle.margeH)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            etat.nettoyerEcran()
            etat.chemin = []
            etat.onglet = 1
        }
    }

    private func boutonRetirer(_ cle: String) -> some View {
        Button {
            Haptique.leger()
            etat.enregistres.remove(cle)
        } label: {
            Text("Retirer")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 14)
                .frame(height: 32)
                .background(RoundedRectangle(cornerRadius: 6).fill(FbStyle.grisBouton))
        }
        .buttonStyle(.plain)
    }
}

// ============================================================================
// MARK: - 22. MENU = TIROIR LATÉRAL GAUCHE 358 pt (e103, e105, e106)
//
// CORRECTIF LOT 280 : le tiroir est dessiné par `FacebookVue` SOUS la barre d'onglets et
// SOUS le pied home — la fausse capsule reste donc visible et cliquable tiroir ouvert.
// D92 — ne restent que les entrées qui MÈNENT quelque part :
//   · Enregistrements → la liste réelle des publications/Reels enregistrés ;
//   · Vos groupes → la liste réelle des groupes rejoints ;
//   · Ami(e)s / Reels / Votre profil → les onglets correspondants ;
//   · « Autres produits Meta » : conservé, mais chaque carte répond par un message VRAI
//     (« … n'est pas installé sur cet iPhone »), jamais « hors connexion ».
// (C) RETIRÉS : « Voir plus », « Créer une Page Facebook », « Meta AI », « Souvenirs »,
//     « Marketplace », « Fils », « Mises à niveau » (Présence publique / Facebook Plus),
//     « Aide et assistance », « Paramètres et confidentialité », « Déconnexion ».
//     Tous ne produisaient qu'un message « hors connexion ». Signalés à Joachim :
//     Marketplace et Souvenirs pourraient servir à une histoire (cf. audit/facebook-lot280.md).
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
    @State private var produitsMeta = true        // e105 : filmée DÉPLIÉE

    private let raccourcis: [FbRaccourciMenu] = [
        FbRaccourciMenu(id: "Enregistrements", glyphe: "bookmark"),
        FbRaccourciMenu(id: "Vos groupes", glyphe: "person.2.circle"),
        FbRaccourciMenu(id: "Ami(e)s", glyphe: "person.2"),
        FbRaccourciMenu(id: "Reels", glyphe: "play.square")
    ]

    private let produits: [FbLienMeta] = [
        FbLienMeta(id: "quest", titre: "Meta Quest 3S",
                   sousTitre: "Découvrez notre dernier casque de ré…",
                   glyphe: "cube.transparent", teinte: 0x5B7CFA, grande: true),
        FbLienMeta(id: "rayban", titre: "Ray-Ban Meta",
                   sousTitre: "La nouvelle génération de lunettes IA",
                   glyphe: "eyeglasses", teinte: 0x1C1C1E, grande: true),
        FbLienMeta(id: "whatsapp", titre: "WhatsApp", sousTitre: nil,
                   glyphe: "phone.circle.fill", teinte: 0x25D366, grande: false),
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
                carteProfil
                listeRaccourcis
                sectionProduits
                // Place réservée à la barre d'onglets ET au pied home, tous deux dessinés
                // AU-DESSUS du tiroir : aucun lien du menu ne passe sous eux.
                Color.clear.frame(height: FbStyle.reserveBas)
            }
            .padding(.top, 10)
        }
        .scrollIndicators(.hidden)
        .background(FbStyle.fond)
    }

    // -------- carte blanche : avatar + nom (→ onglet Profil)

    private var carteProfil: some View {
        Button {
            withAnimation(.easeOut(duration: 0.22)) { etat.tiroir = false }
            etat.nettoyerEcran()
            etat.chemin = []
            etat.onglet = 5
        } label: {
            HStack(spacing: 12) {
                FbAvatar(photo: DonneesFb.moiPhoto, nom: DonneesFb.moiNom, taille: 40, teinte: 0x5B7CFA)
                VStack(alignment: .leading, spacing: 1) {
                    Text(DonneesFb.moiNom)
                        .font(.system(size: 19))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                    Text("Voir votre profil")
                        .font(.system(size: 14))
                        .foregroundStyle(FbStyle.texteGris)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FbStyle.texteGris)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(FbStyle.sepFin, lineWidth: 1))
        .padding(.horizontal, 14)
        .padding(.bottom, 12)
    }

    // -------- liste 60 pt, icônes NOIRES EN CONTOUR

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
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(FbStyle.texteGris)
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 60)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// Chaque entrée du menu POUSSE un écran réel ou change d'onglet. Aucun toast d'excuse.
    private func action(_ titre: String) {
        Haptique.leger()
        withAnimation(.easeOut(duration: 0.22)) { etat.tiroir = false }
        etat.nettoyerEcran()
        switch titre {
        case "Enregistrements":
            etat.chemin.append(.enregistrements)
        case "Vos groupes":
            etat.chemin.append(.vosGroupes)
        case "Ami(e)s":
            etat.chemin = []
            etat.onglet = 2
        default:
            etat.chemin = []
            etat.onglet = 1
        }
    }

    // -------- « Autres produits Meta » (e105), filmée dépliée

    private var sectionProduits: some View {
        VStack(alignment: .leading, spacing: 0) {
            FbHairline()
            sectionChevron(titre: "Autres produits Meta", glyphe: "square.grid.3x3.fill",
                           ouverte: produitsMeta) { produitsMeta.toggle() }
            if produitsMeta { grille(produits) }
        }
    }

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
            // (B) Message VRAI : ces apps ne sont pas sur l'iPhone de Sarah.
            etat.alerte = FbAlerte(titre: l.titre,
                                   message: l.titre + " n'est pas installé sur cet iPhone.")
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
}

// ============================================================================
// MARK: - 23. ACCÈS CAPTURE (registre EcranCapture.ecransFacebook — aucun état externe)
// ============================================================================

enum FbCapture {
    /// État neuf pour une capture isolée : aucune dépendance, aucun singleton mutable.
    static func etat() -> FbEtat { FbEtat() }

    static func post(_ id: String) -> FbPost { DonneesFb.post(id) }

    /// État préparé pour la capture d'un écran POUSSÉ : la pile contient déjà la route,
    /// donc le chevron Retour est cohérent et la capture ne dépend d'aucune interaction.
    static func etat(route: FbRoute) -> FbEtat {
        let e = FbEtat()
        e.chemin = [route]
        return e
    }
}
