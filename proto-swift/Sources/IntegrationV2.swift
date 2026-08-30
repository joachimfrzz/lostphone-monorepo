import SwiftUI

// ============================================================
// INTÉGRATION V2 (phase 1, 30/08) — l'app sur device démarre sur
// l'expérience v2 (refonte D80 S1→S6). Les écrans v1 sortent du jeu
// (conservés dans le code, accessibles uniquement via le mode capture).
// Navigation phase 1 :
//   verrouillage v2 → glisser vers le haut → accueil v2
//   toucher une icône → écran racine v2 de l'app
//   balayage horizontal → écrans suivants/précédents de l'app
//   glisser vers le haut depuis le bas → retour accueil
// Phase 2 (à venir) : câblage tactile réel écran par écran + animations.
// ============================================================

final class NavV2: ObservableObject {
    static let partage = NavV2()
    @Published var verrouille = true
    @Published var app: String? = nil
    @Published var index = 0

    // app de l'accueil/dock → séquence d'écrans v2 (clés du registre EcranCapture)
    static let ecrans: [String: [String]] = [
        "Réglages": ["reglages2.racine", "reglages2.luminosite", "reglages2.batterie", "reglages2.general", "reglages2.infos", "reglages2.notifications", "reglages2.sons"],
        "Messages": ["tcm2.msg.liste", "tcm2.msg.conv", "divers2.msg.suppressions", "divers2.msg.indesirables"],
        "Téléphone": ["tcm2.messagerie"],
        "Mail": ["sm2.mail.boites", "sm2.mail.reception", "sm2.mail.lecture", "divers2.mail.envoi", "sm2.mail.redaction"],
        "Safari": ["sm2.safari.demarrage", "sm2.safari.onglets", "sm2.safari.privee"],
        "Photos": ["pcnr2.photos.phototheque", "pcnr2.photos.collections", "pcnr2.photos.detail"],
        "Calendrier": ["pcnr2.cal.mois", "pcnr2.cal.jour"],
        "Notes": ["pcnr2.notes.dossiers", "pcnr2.notes.liste"],
        "Rappels": ["pcnr2.rappels.accueil", "pcnr2.rappels.liste"],
        "Météo": ["mhdc2.meteo.accueil", "mhdc2.meteo.lieux"],
        "Horloge": ["mhdc2.horloge.alarmes", "mhdc2.horloge.minuteurs", "mhdc2.horloge.chrono"],
        "Dictaphone": ["mhdc2.dicta.liste", "divers2.dicta.suppressions"],
        "Calculatrice": ["mhdc2.calc.elementaire", "mhdc2.calc.modes"],
        "Contacts": ["divers2.contacts.listes"]
    ]

    func ouvrir(_ nom: String) {
        if NavV2.ecrans[nom] != nil {
            app = nom
            index = 0
        }
    }
}

struct TelephoneV2Racine: View {
    @ObservedObject var nav = NavV2.partage
    @State private var glisse: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            if nav.verrouille {
                EcranCapture(cle: "coque2.verrouillage")
                    .offset(y: min(0, glisse))
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onChanged { v in glisse = v.translation.height }
                            .onEnded { v in
                                if v.translation.height < -90 {
                                    withAnimation(.easeOut(duration: 0.25)) { nav.verrouille = false }
                                }
                                glisse = 0
                            }
                    )
            } else if let app = nav.app, let seq = NavV2.ecrans[app] {
                EcranCapture(cle: seq[min(nav.index, seq.count - 1)])
                    .id(app + String(nav.index))
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 35)
                            .onEnded { v in
                                let dx = v.translation.width
                                let dy = v.translation.height
                                if abs(dx) > abs(dy) * 1.4 {
                                    if dx < -50, nav.index < seq.count - 1 { withAnimation { nav.index += 1 } }
                                    if dx > 50, nav.index > 0 { withAnimation { nav.index -= 1 } }
                                }
                            }
                    )
            } else {
                AccueilV2View()
            }

            // Zone barre home : glisser vers le haut = retour accueil (ou rien si déjà accueil)
            if !nav.verrouille {
                Color.clear
                    .frame(height: 26)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 15)
                            .onEnded { v in
                                if v.translation.height < -30 {
                                    withAnimation(.easeOut(duration: 0.22)) {
                                        nav.app = nil
                                        nav.index = 0
                                    }
                                }
                            }
                    )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)
    }
}
