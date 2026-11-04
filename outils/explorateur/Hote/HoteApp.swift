import SwiftUI

// App hôte vide : le robot (cible ExplorateurUITests) pilote les vraies apps Apple.
@main
struct HoteApp: App {
    var body: some Scene {
        WindowGroup { Text("Explorateur Lost Phone") }
    }
}
