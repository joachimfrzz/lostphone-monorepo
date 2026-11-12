// Calendrier — CONTENU D'EXEMPLE (D59 : remplaçable). Aucune vue ne contient de texte d'histoire en dur :
// tout ce qui est propre à Sarah (évènements, noms de calendriers, lieux) vit ici.
// Présent du jeu : lundi 17 août 2026 (pastille rouge sur le 17), 09:41.
// R3 : RDV Banque 11:30 le 17, kiné les jeudis 17:30, brunch des filles le samedi 22 (groupe WhatsApp),
// anniversaire de Maman le 14 février (= P01-P05), et « MARC ARRIVE ⚓️ » le vendredi 28 août.
import SwiftUI

// Un calendrier de la feuille « Calendriers » (case à cocher, couleur, groupe)
struct CalCalendrier: Identifiable {
    let id = UUID()
    var nom: String
    var sousTitre: String? = nil
    var couleur: UInt
    var groupe: Int              // 0 = « Sur mon iPhone », 1 = « Autres »
    var cadeau: Bool = false     // petit cadeau rouge devant le nom (Anniversaires)
    var info: Bool = false       // bouton (i) à droite
    var coche: Bool = true
}

enum CalDonnees {
    // Le présent du jeu
    static let anneeJeu = 2026
    static let moisJeu = 8
    static let jourJeu = 17
    static let heureAffichee = "09:41"
    static let maintenantMinutes = 9 * 60 + 41

    // Noms des calendriers
    static let nomPerso = "Calendrier"
    static let nomFetes = "Fêtes (France)"
    static let nomRappels = "Rappels programmés"
    static let nomAnniv = "Anniversaires"
    static let nomSiri = "Suggestions de Siri"

    // Couleurs de calendrier (mesurées sur la référence : bleu 0088FF, violet D93CED, gris-bleu 8295AF)
    static let couleurPerso: UInt = 0x0A84FF
    static let couleurFetes: UInt = 0xD93CED
    static let couleurAnniv: UInt = 0x8295AF

    static func calendriers() -> [CalCalendrier] {
        return [
            CalCalendrier(nom: nomPerso, couleur: 0x0088FF, groupe: 0, info: true),
            CalCalendrier(nom: nomFetes, sousTitre: "Abonnements", couleur: couleurFetes, groupe: 1, info: true),
            CalCalendrier(nom: nomRappels, couleur: 0x0088FF, groupe: 1),
            CalCalendrier(nom: nomAnniv, couleur: couleurAnniv, groupe: 1, cadeau: true),
            CalCalendrier(nom: nomSiri, couleur: couleurAnniv, groupe: 1),
        ]
    }

    static func evenements() -> [Evenement] {
        var evts: [Evenement] = [
            // — Le cœur (août 2026)
            Evenement(titre: "Banque — plafond", annee: 2026, mois: 8, jour: 17, heure: 11, minute: 30,
                      couleur: 0xE84D6B, lieu: "LCL Agence Bellecour"),
            Evenement(titre: "Brunch les filles", annee: 2026, mois: 8, jour: 22, heure: 13,
                      couleur: 0x0A84FF, lieu: "Place Sathonay"),
            Evenement(titre: "MARC ARRIVE ⚓️", annee: 2026, mois: 8, jour: 28, heure: nil,
                      couleur: 0xE84D6B, lieu: "Marseille — port"),
            Evenement(titre: "L'Assomption", annee: 2026, mois: 8, jour: 15, heure: nil,
                      couleur: couleurFetes, calendrier: nomFetes, symbole: "star.fill"),
            // — Les anniversaires (R3 avec la pellicule)
            Evenement(titre: "Anniv Maman 🎂", annee: 2026, mois: 2, jour: 14, heure: nil,
                      couleur: couleurAnniv, calendrier: nomAnniv, symbole: "gift.fill"),
            Evenement(titre: "Anniv Chloé", annee: 2026, mois: 4, jour: 3, heure: nil,
                      couleur: couleurAnniv, calendrier: nomAnniv, symbole: "gift.fill"),
            // — La vie qui continue
            Evenement(titre: "Révision voiture", annee: 2026, mois: 9, jour: 8, heure: 9,
                      couleur: 0x0A84FF, lieu: "Garage Perret"),
            Evenement(titre: "Dr Pasquier", annee: 2026, mois: 10, jour: 9, heure: 14, minute: 30,
                      couleur: 0x0A84FF, lieu: "Cabinet médical"),
            Evenement(titre: "La Toussaint", annee: 2026, mois: 11, jour: 1, heure: nil,
                      couleur: couleurFetes, calendrier: nomFetes, symbole: "star.fill"),
            // — Fériés utiles
            Evenement(titre: "Fête nationale", annee: 2026, mois: 7, jour: 14, heure: nil,
                      couleur: couleurFetes, calendrier: nomFetes, symbole: "star.fill"),
        ]
        // Kiné : tous les jeudis 17:30 du 2 juillet au 24 septembre 2026 (raccord Marie kiné)
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        var d = DateComponents(year: 2026, month: 7, day: 2)
        while let date = cal.date(from: d),
              let fin = cal.date(from: DateComponents(year: 2026, month: 9, day: 24)),
              date <= fin {
            let c = cal.dateComponents([.year, .month, .day], from: date)
            evts.append(Evenement(titre: "Kiné", annee: c.year!, mois: c.month!, jour: c.day!,
                                  heure: 17, minute: 30, duree: 45, couleur: 0xE8873D,
                                  lieu: "12 rue des Fantasques"))
            d.day! += 7
        }
        return evts
    }
}
