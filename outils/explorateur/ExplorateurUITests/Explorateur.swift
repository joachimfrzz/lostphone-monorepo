import XCTest

// Robot explorateur (D95) : ouvre une vraie app Apple du simulateur, capture l'écran,
// relève chaque bouton / cellule / lien visible, puis rejoue chaque chemin depuis un
// lancement à neuf (exploration en largeur, profondeur bornée). Les écrans déjà vus
// (même signature de libellés) sont ignorés. Les actions destructrices sont exclues.
//
// Paramètres (variables TEST_RUNNER_* côté xcodebuild) :
//   SORTIE      dossier hôte où écrire <bundleId>/NNN.png + INDEX.tsv
//   APPS        bundle IDs séparés par des virgules
//   PROFONDEUR  nombre maximal d'appuis enchaînés (défaut 2)
//   MAX_ECRANS  plafond d'écrans par app (défaut 80)

struct Cible: Hashable {
    let type: UInt
    let label: String
    let x: Double
    let y: Double
}

final class Explorateur: XCTestCase {

    let interdits = ["supprim", "effac", "réinitialis", "reinitialis", "delete", "erase", "reset",
                     "déconnex", "deconnex", "sign out", "appeler", "envoyer", "acheter", "éteindre",
                     "eteindre", "redémarr", "transférer ou réinitialiser", "signaler"]
    let accueil = ["Continuer", "Continue", "Pas maintenant", "Plus tard", "Ignorer", "Commencer",
                   "OK", "Not Now", "Get Started", "Fermer"]
    let autorisations = ["Autoriser", "Autoriser lorsque l’app est active", "Autoriser une fois",
                         "Allow", "Allow While Using App", "OK"]

    override func setUp() {
        continueAfterFailure = true
    }

    func testExplorer() throws {
        let env = ProcessInfo.processInfo.environment
        let sortie = env["SORTIE"] ?? NSTemporaryDirectory()
        let apps = (env["APPS"] ?? "com.apple.mobilenotes")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let profondeur = Int(env["PROFONDEUR"] ?? "") ?? 2
        let maxEcrans = Int(env["MAX_ECRANS"] ?? "") ?? 80
        for id in apps {
            explorer(id, sortie: sortie, profondeur: profondeur, maxEcrans: maxEcrans)
        }
    }

    // MARK: - Exploration

    func explorer(_ id: String, sortie: String, profondeur: Int, maxEcrans: Int) {
        let dossier = (sortie as NSString).appendingPathComponent(id)
        try? FileManager.default.createDirectory(atPath: dossier, withIntermediateDirectories: true)
        var index = "fichier\tchemin\n"
        var vus = Set<String>()
        var file: [[Cible]] = [[]]
        var n = 0
        var essais = 0

        while !file.isEmpty && n < maxEcrans && essais < maxEcrans * 4 {
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

            var ok = true
            for c in chemin {
                if !taper(app, c) { ok = false; break }
                sleep(2)
                fermerAlertes()
            }
            if !ok { continue }

            guard let snap = try? app.snapshot() else { continue }
            let sig = signature(snap)
            if vus.contains(sig) { continue }
            vus.insert(sig)

            n += 1
            let nom = String(format: "%03d", n)
            let png = XCUIScreen.main.screenshot().pngRepresentation
            try? png.write(to: URL(fileURLWithPath: dossier + "/" + nom + ".png"))
            let libelle = chemin.isEmpty ? "(racine)" : chemin.map { $0.label }.joined(separator: " › ")
            index += "\(nom).png\t\(libelle)\n"
            try? index.write(toFile: dossier + "/INDEX.tsv", atomically: true, encoding: .utf8)

            if chemin.count < profondeur {
                var cibles: [Cible] = []
                var dejaVu = Set<String>()
                collecter(snap, ecran: snap.frame, into: &cibles, dejaVu: &dejaVu)
                for c in cibles.prefix(40) { file.append(chemin + [c]) }
            }
        }
        index += "# \(n) écrans, \(essais) lancements\n"
        try? index.write(toFile: dossier + "/INDEX.tsv", atomically: true, encoding: .utf8)
        XCUIApplication(bundleIdentifier: id).terminate()
    }

    // MARK: - Relevé des éléments

    func collecter(_ s: XCUIElementSnapshot, ecran: CGRect, into cibles: inout [Cible], dejaVu: inout Set<String>) {
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
                                    x: Double(f.midX), y: Double(f.midY)))
            }
        }
        for enfant in s.children {
            collecter(enfant, ecran: ecran, into: &cibles, dejaVu: &dejaVu)
        }
    }

    func signature(_ s: XCUIElementSnapshot) -> String {
        var libelles: [String] = []
        func parcourir(_ e: XCUIElementSnapshot) {
            if [.button, .cell, .link, .staticText, .navigationBar].contains(e.elementType) {
                let l = e.label.trimmingCharacters(in: .whitespacesAndNewlines)
                if !l.isEmpty, l.count < 80 { libelles.append("\(e.elementType.rawValue):\(l)") }
            }
            e.children.forEach(parcourir)
        }
        parcourir(s)
        return libelles.sorted().joined(separator: "|")
    }

    // MARK: - Actions

    func taper(_ app: XCUIApplication, _ c: Cible) -> Bool {
        let type = XCUIElement.ElementType(rawValue: c.type) ?? .any
        let e = app.descendants(matching: type)
            .matching(NSPredicate(format: "label == %@", c.label)).firstMatch
        if e.waitForExistence(timeout: 3), e.isHittable {
            e.tap()
            return true
        }
        let origine = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        origine.withOffset(CGVector(dx: c.x, dy: c.y)).tap()
        return true
    }

    func passerAccueil(_ app: XCUIApplication) {
        for _ in 0..<3 {
            fermerAlertes()
            var tape = false
            for l in accueil {
                let b = app.buttons[l]
                if b.exists, b.isHittable { b.tap(); tape = true; sleep(1); break }
            }
            if !tape { return }
        }
    }

    func fermerAlertes() {
        let sb = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for l in autorisations {
            let b = sb.alerts.buttons[l]
            if b.exists { b.tap(); sleep(1); return }
        }
    }
}
