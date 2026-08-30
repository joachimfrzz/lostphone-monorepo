import SwiftUI

// ============================================================
// INTÉGRATION V2 — PHASE 2 (30/08) : le jeu = refonte D80, avec
// navigation tactile réelle et gestes iOS :
//   verrouillage → glisser haut = déverrouiller (translation animée)
//   accueil → toucher une icône = ouverture animée de l'app v2
//   dans une app : toucher les rangées = pousse l'écran suivant
//   (transition latérale iOS), balayage depuis le bord gauche OU
//   toucher la zone retour en haut à gauche = retour
//   glisser haut depuis la barre home = retour accueil
//   glisser bas depuis le haut-droit = Centre de contrôle,
//   depuis le haut-gauche = centre de notifications (glisser haut = fermer)
// Les écrans v1 restent accessibles uniquement via le mode capture.
// ============================================================

final class NavV2: ObservableObject {
    static let partage = NavV2()
    @Published var verrouille = true
    @Published var appNom: String? = nil
    @Published var pile: [String] = []
    @Published var voletCC = false
    @Published var voletNotifs = false

    static let racines: [String: String] = [
        "Réglages": "reglages2.racine",
        "Messages": "tcm2.msg.liste",
        "Téléphone": "tcm2.messagerie",
        "Mail": "sm2.mail.boites",
        "Safari": "sm2.safari.demarrage",
        "Photos": "pcnr2.photos.phototheque",
        "Calendrier": "pcnr2.cal.mois",
        "Notes": "pcnr2.notes.dossiers",
        "Rappels": "pcnr2.rappels.accueil",
        "Météo": "mhdc2.meteo.accueil",
        "Horloge": "mhdc2.horloge.alarmes",
        "Dictaphone": "mhdc2.dicta.liste",
        "Calculatrice": "mhdc2.calc.elementaire",
        "Contacts": "divers2.contacts.listes"
    ]

    func ouvrir(_ nom: String) {
        guard let racine = NavV2.racines[nom] else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            appNom = nom
            pile = [racine]
        }
    }
    func pousser(_ cle: String) {
        withAnimation(.easeOut(duration: 0.28)) { pile.append(cle) }
    }
    func remplacer(_ cle: String) {
        withAnimation(.easeOut(duration: 0.18)) { pile = [cle] }
    }
    func retour() {
        guard pile.count > 1 else { return }
        withAnimation(.easeOut(duration: 0.26)) { pile.removeLast() }
    }
    func accueil() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            appNom = nil
            pile = []
            voletCC = false
            voletNotifs = false
        }
    }
}

struct TelephoneV2Racine: View {
    @ObservedObject var nav = NavV2.partage
    @State private var glisseVerrou: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // ---------- couche accueil ----------
                if !nav.verrouille {
                    AccueilV2View()
                }

                // ---------- couche app ouverte ----------
                if !nav.verrouille, nav.appNom != nil, let cle = nav.pile.last {
                    ZStack(alignment: .topLeading) {
                        EcranCapture(cle: cle)
                            .id(cle)
                            .transition(nav.pile.count > 1
                                ? .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing))
                                : .asymmetric(insertion: .scale(scale: 0.85).combined(with: .opacity), removal: .scale(scale: 0.85).combined(with: .opacity)))
                        // zone retour tactile (coin haut-gauche, invisible)
                        if nav.pile.count > 1 {
                            Color.clear
                                .frame(width: 130, height: 56)
                                .contentShape(Rectangle())
                                .padding(.top, 54)
                                .onTapGesture { nav.retour() }
                        }
                    }
                    // balayage retour depuis le bord gauche (geste iOS)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 25)
                            .onEnded { v in
                                if v.startLocation.x < 36, v.translation.width > 70 { nav.retour() }
                            }
                    )
                }

                // ---------- volets CC / notifications ----------
                if nav.voletCC {
                    EcranCapture(cle: "coque2.controle")
                        .transition(.move(edge: .top))
                        .zIndex(30)
                        .gesture(DragGesture(minimumDistance: 25).onEnded { v in
                            if v.translation.height < -50 {
                                withAnimation(.easeOut(duration: 0.25)) { nav.voletCC = false }
                            }
                        })
                }
                if nav.voletNotifs {
                    EcranCapture(cle: "coque2.notifs")
                        .transition(.move(edge: .top))
                        .zIndex(30)
                        .gesture(DragGesture(minimumDistance: 25).onEnded { v in
                            if v.translation.height < -50 {
                                withAnimation(.easeOut(duration: 0.25)) { nav.voletNotifs = false }
                            }
                        })
                }

                // ---------- bord haut : tirer CC (droite) / notifs (gauche) ----------
                if !nav.verrouille, !nav.voletCC, !nav.voletNotifs {
                    HStack(spacing: 0) {
                        Color.clear.frame(width: geo.size.width * 0.5, height: 30)
                            .contentShape(Rectangle())
                            .gesture(DragGesture(minimumDistance: 20).onEnded { v in
                                if v.translation.height > 45 {
                                    withAnimation(.easeOut(duration: 0.28)) { nav.voletNotifs = true }
                                }
                            })
                        Color.clear.frame(width: geo.size.width * 0.5, height: 30)
                            .contentShape(Rectangle())
                            .gesture(DragGesture(minimumDistance: 20).onEnded { v in
                                if v.translation.height > 45 {
                                    withAnimation(.easeOut(duration: 0.28)) { nav.voletCC = true }
                                }
                            })
                    }
                    .zIndex(40)
                }

                // ---------- barre home : glisser haut = accueil ----------
                if !nav.verrouille {
                    VStack {
                        Spacer()
                        Color.clear
                            .frame(height: 26)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .gesture(DragGesture(minimumDistance: 15).onEnded { v in
                                if v.translation.height < -30 { nav.accueil() }
                            })
                    }
                    .zIndex(50)
                }

                // ---------- couche verrouillage ----------
                if nav.verrouille {
                    EcranCapture(cle: "coque2.verrouillage")
                        .offset(y: min(0, glisseVerrou))
                        .zIndex(60)
                        .gesture(
                            DragGesture(minimumDistance: 15)
                                .onChanged { v in glisseVerrou = v.translation.height }
                                .onEnded { v in
                                    if v.translation.height < -110 {
                                        withAnimation(.easeOut(duration: 0.30)) {
                                            glisseVerrou = -geo.size.height
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                                            nav.verrouille = false
                                            glisseVerrou = 0
                                        }
                                    } else {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { glisseVerrou = 0 }
                                    }
                                }
                        )
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)
    }
}
