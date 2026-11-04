import XCTest

// Robot explorateur (D95) : ouvre une vraie app Apple du simulateur, capture l'écran,
// le fait défiler (pages suivantes capturées), relève chaque bouton / cellule / lien
// visible à chaque position de défilement, puis rejoue chaque chemin depuis un
// lancement à neuf (exploration en largeur, profondeur bornée). Les écrans déjà vus
// (même signature de libellés) sont ignorés. Les actions destructrices sont exclues.
// Les fenêtres d'autorisation (app ou système) sont fermées avant chaque capture.
//
// Paramètres (variables TEST_RUNNER_* côté xcodebuild) :
//   SORTIE      dossier hôte où écrire <bundleId>/NNN.png (+ NNN-p2.png… pages défilées) + INDEX.tsv
//   APPS        bundle IDs séparés par des virgules
//   PROFONDEUR  nombre maximal d'appuis enchaînés (défaut 2)
//   MAX_ECRANS  plafond d'écrans par app (défaut 80)
//   PAGES       nombre maximal de pages défilées par écran (défaut 4)
//   DUREE_MAX   secondes par lot d'apps (défaut 2400)

struct Cible: Hashable {
    let type: UInt
    let label: String
    let x: Double
    let y: Double
    let defil: Int      // nombre de défilements nécessaires avant l'appui
}

final class Explorateur: XCTestCase {

    let interdits = ["supprim", "effac", "réinitialis", "reinitialis", "delete", "erase", "reset",
                     "déconnex", "deconnex", "sign out", "appeler", "envoyer", "acheter", "éteindre",
                     "eteindre", "redémarr", "transférer ou réinitialiser", "signaler"]
    let accueil = ["Continuer", "Continue", "Pas maintenant", "Plus tard", "Ignorer", "Commencer",
                   "Not Now", "Get Started", "Fermer", "Terminé"]
    let autorisations = ["Autoriser", "Autoriser lorsque l’app est active", "Autoriser une fois",
                         "Autoriser l’accès complet", "Allow", "Allow While Using App", "OK",
                         "Continuer", "Refuser", "Ne pas autoriser"]

    override func setUp() {
        continueAfterFailure = true
    }

    func testExplorer() throws {
        let env = ProcessInfo.processInfo.environment
        let sortie = env["SORTIE"] ?? NSTemporaryDirectory()
        let apps = (env["APPS"] ?? "com.apple.Preferences")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let profondeur = Int(env["PROFONDEUR"] ?? "") ?? 2
        let maxEcrans = Int(env["MAX_ECRANS"] ?? "") ?? 80
        let pages = Int(env["PAGES"] ?? "") ?? 4
        let dureeMax = Double(env["DUREE_MAX"] ?? "") ?? 2400
        let fin = Date().addingTimeInterval(dureeMax)
        for id in apps {
            explorer(id, sortie: sortie, profondeur: profondeur, maxEcrans: maxEcrans, pages: pages, fin: fin)
        }
    }

    // MARK: - Exploration

    func explorer(_ id: String, sortie: String, profondeur: Int, maxEcrans: Int, pages: Int, fin: Date) {
        let dossier = (sortie as NSString).appendingPathComponent(id)
        try? FileManager.default.createDirectory(atPath: dossier, withIntermediateDirectories: true)
        var index = "fichier\tchemin\n"
        var vus = Set<String>()
        var file: [[Cible]] = [[]]
        var n = 0
        var essais = 0

        func ecrireIndex() {
            try? index.write(toFile: dossier + "/INDEX.tsv", atomically: true, encoding: .utf8)
        }

        // Premier lancement : laisser les fenêtres de bienvenue / autorisation apparaître et les fermer.
        let app0 = XCUIApplication(bundleIdentifier: id)
        app0.launchArguments = ["-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"]
        app0.launch()
        sleep(5)
        for _ in 0..<3 { passerAccueil(app0); fermerAlertes(app0); sleep(1) }

        while !file.isEmpty && n < maxEcrans && essais < maxEcrans * 4 && Date() < fin {
            essais += 1
            let chemin = file.removeFirst()
            let app = XCUIApplication(bundleIdentifier: id)
            app.terminate()
            app.launchArguments = ["-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"]
            app.launch()
            guard app.wait(for: .runningForeground, timeout: 15) else {
                index += "ABSENT\t\(id)\n"
                break
            }
            sleep(3)
            passerAccueil(app)
            fermerAlertes(app)

            var ok = true
            for c in chemin {
                if !taper(app, c) { ok = false; break }
                sleep(2)
                fermerAlertes(app)
            }
            if !ok { continue }

            fermerAlertes(app)
            guard let snap = try? app.snapshot() else { continue }
            let sig = signature(snap)
            if vus.contains(sig) { continue }
            vus.insert(sig)

            n += 1
            let nom = String(format: "%03d", n)
            let libelle = chemin.isEmpty ? "(racine)" : chemin.map { $0.label }.joined(separator: " › ")
            capturer(dossier + "/" + nom + ".png")
            index += "\(nom).png\t\(libelle)\n"
            ecrireIndex()

            var cibles: [Cible] = []
            var dejaVu = Set<String>()
            if chemin.count < profondeur {
                collecter(snap, ecran: snap.frame, defil: 0, into: &cibles, dejaVu: &dejaVu)
            }

            // Pages suivantes : défiler tant que le contenu change.
            var sigPrec = sig
            if pages > 1 {
                for p in 2...pages {
                    guard defiler(app) else { break }
                    sleep(1)
                    fermerAlertes(app)
                    guard let s2 = try? app.snapshot() else { break }
                    let sg2 = signature(s2)
                    if sg2 == sigPrec { break }
                    sigPrec = sg2
                    vus.insert(sg2)
                    let nomP = "\(nom)-p\(p).png"
                    capturer(dossier + "/" + nomP)
                    index += "\(nomP)\t\(libelle) (défilé \(p - 1))\n"
                    ecrireIndex()
                    if chemin.count < profondeur {
                        collecter(s2, ecran: s2.frame, defil: p - 1, into: &cibles, dejaVu: &dejaVu)
                    }
                }
            }
            for c in cibles.prefix(60) { file.append(chemin + [c]) }
        }
        index += "# \(n) écrans, \(essais) lancements\n"
        ecrireIndex()
        XCUIApplication(bundleIdentifier: id).terminate()
    }

    func capturer(_ chemin: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation
        try? png.write(to: URL(fileURLWithPath: chemin))
    }

    // MARK: - Relevé des éléments

    func collecter(_ s: XCUIElementSnapshot, ecran: CGRect, defil: Int,
                   into cibles: inout [Cible], dejaVu: inout Set<String>) {
        let types: [XCUIElement.ElementType] = [.button, .cell, .link]
        if types.contains(s.elementType), s.isEnabled {
            let label = s.label.trimmingCharacters(in: .whitespacesAndNewlines)
            let f = s.frame
            let visible = f.width > 4 && f.height > 4 && f.midY > 50 && f.midY < ecran.maxY - 20
                && f.midX > 0 && f.midX < ecran.maxX
            let bas = label.lowercased()
            let interdit = interdits.contains { bas.contains($0) }
            let cle = "\(s.elementType.rawValue)|\(label)"
            if !label.isEmpty, visible, !interdit, !dejaVu.contains(cle) {
                dejaVu.insert(cle)
                cibles.append(Cible(type: s.elementType.rawValue, label: label,
                                    x: Double(f.midX), y: Double(f.midY), defil: defil))
            }
        }
        for enfant in s.children {
            collecter(enfant, ecran: ecran, defil: defil, into: &cibles, dejaVu: &dejaVu)
        }
    }

    func signature(_ s: XCUIElementSnapshot) -> String {
        var libelles: [String] = []
        let h = s.frame.maxY
        func parcourir(_ e: XCUIElementSnapshot) {
            if [.button, .cell, .link, .staticText, .navigationBar].contains(e.elementType) {
                let l = e.label.trimmingCharacters(in: .whitespacesAndNewlines)
                let f = e.frame
                let visible = f.maxY > 0 && f.minY < h
                if !l.isEmpty, l.count < 80, visible { libelles.append("\(e.elementType.rawValue):\(l)") }
            }
            e.children.forEach(parcourir)
        }
        parcourir(s)
        return libelles.sorted().joined(separator: "|")
    }

    // MARK: - Actions

    /// Fait défiler le contenu principal d'environ une page. Faux si rien à défiler.
    func defiler(_ app: XCUIApplication) -> Bool {
        let conteneurs: [XCUIElementQuery] = [app.collectionViews, app.tables, app.scrollViews]
        for q in conteneurs {
            let c = q.firstMatch
            if c.exists, c.isHittable, c.frame.height > 300 {
                let haut = c.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.25))
                let bas = c.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
                bas.press(forDuration: 0.05, thenDragTo: haut, withVelocity: .slow, thenHoldFor: 0.2)
                return true
            }
        }
        return false
    }

    func taper(_ app: XCUIApplication, _ c: Cible) -> Bool {
        let type = XCUIElement.ElementType(rawValue: c.type) ?? .any
        let e = app.descendants(matching: type)
            .matching(NSPredicate(format: "label == %@", c.label)).firstMatch
        // Rejouer le défilement, puis défiler encore un peu si l'élément n'est pas atteignable.
        for _ in 0..<c.defil { _ = defiler(app); usleep(600_000) }
        for _ in 0..<3 {
            if e.waitForExistence(timeout: 2), e.isHittable {
                e.tap()
                return true
            }
            if !defiler(app) { break }
            usleep(600_000)
        }
        if c.defil == 0 {
            let origine = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            origine.withOffset(CGVector(dx: c.x, dy: c.y)).tap()
            return true
        }
        return false
    }

    func passerAccueil(_ app: XCUIApplication) {
        for _ in 0..<3 {
            fermerAlertes(app)
            var tape = false
            for l in accueil {
                let b = app.buttons[l]
                if b.exists, b.isHittable { b.tap(); tape = true; sleep(1); break }
            }
            if !tape { return }
        }
    }

    /// Ferme les alertes de l'app et du système (autorisations, notifications).
    func fermerAlertes(_ app: XCUIApplication) {
        let sb = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for _ in 0..<3 {
            var ferme = false
            for source in [sb, app] {
                let alerte = source.alerts.firstMatch
                guard alerte.exists else { continue }
                for l in autorisations {
                    let b = alerte.buttons[l]
                    if b.exists { b.tap(); ferme = true; break }
                }
                if !ferme, alerte.buttons.count > 0 {
                    alerte.buttons.element(boundBy: alerte.buttons.count - 1).tap()
                    ferme = true
                }
                if ferme { break }
            }
            if !ferme { return }
            sleep(1)
        }
    }
}
