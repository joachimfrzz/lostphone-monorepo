// Rappels — contenu d'exemple de Sarah (D59 : données remplaçables).
// Les vues (RappelsApp.swift) ne contiennent AUCUN texte d'histoire : tout passe par DonneesRappels.
// R3 : les Terminés racontent la préparation du dossier bancaire (recoupe P60).
import Foundation

enum DonneesRappels {
    // « Aujourd'hui » dans le jeu : mardi 18 août 2026 (les sections de Programmés se calculent depuis cette date).
    static let annee = 2026
    static let mois = 8
    static let jour = 18

    // Liste qui reçoit les nouveaux rappels par défaut.
    static let listeParDefaut = "Rappels"

    static let listes: [ListeRappels] = [
        ListeRappels(nom: "Rappels", couleur: 0xE8873D, symbole: "list.bullet"),
        ListeRappels(nom: "Courses", couleur: 0x30D158, symbole: "cart.fill"),
    ]

    static let rappels: [Rappel] = [
        Rappel(titre: "Rappeler Chloé", liste: "Rappels", aujourdhui: true),
        Rappel(titre: "Banque — dossier complet !!", sousTexte: "Demain, 11:15 🔁", liste: "Rappels",
               urgent: true, drapeau: true, programme: true, jour: 1),
        Rappel(titre: "Kiné jeudi", sousTexte: "20/08/2026, 17:30", liste: "Rappels", programme: true, jour: 2),
        Rappel(titre: "Carottes", liste: "Courses"),
        // Terminés — la préparation du dossier, en creux (R3 avec la note P60)
        Rappel(titre: "Imprimer le RIB", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 16/08/2026 21:38"),
        Rappel(titre: "Photographier pièce d'identité", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 12/08/2026 09:41"),
        Rappel(titre: "Acheter enveloppe A4", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 12/08/2026 18:02"),
        Rappel(titre: "Rendre le tupperware à maman 😅", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 09/08/2026 14:20"),
        Rappel(titre: "Kiné", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 06/08/2026 17:35"),
        Rappel(titre: "Photos du festival à Chloé", liste: "Rappels", termine: true,
               termineTexte: "Terminé : 12/07/2026 18:24"),
    ]
}
