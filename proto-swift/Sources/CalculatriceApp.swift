// Calculatrice — construite contre la vidéo de référence du 18/08 (8 écrans, iOS 26)
// Moteur réellement fonctionnel (D51 A à Z) : opérations chaînées, %, +/-, virgule,
// C/AC contextuel, retour arrière, expression en cours affichée en haut à droite,
// historique de session consultable, copie du résultat par appui long.
import SwiftUI

struct CalculatriceVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var affichage = "0"
    @State private var expression = ""          // petit rappel gris au-dessus (ex. « 82%×98% »)
    @State private var accumulateur: Double? = nil
    @State private var operation: String? = nil
    @State private var enSaisie = false
    @State private var historique: [String] = []
    @State private var historiqueVisible = false
    @State private var copie = false

    private let orange = Color(hex: 0xFF9F0A)
    private let grisFonce = Color(hex: 0x2A2A2C)
    private let grisClair = Color(hex: 0x5C5C5F)

    // ————— Moteur —————
    private var valeurCourante: Double {
        Double(affichage.replacingOccurrences(of: ",", with: ".")
                        .replacingOccurrences(of: " ", with: "")) ?? 0
    }
    private func formate(_ v: Double) -> String {
        if v.isNaN || v.isInfinite { return "Erreur" }
        let f = NumberFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        f.maximumFractionDigits = 8
        f.minimumFractionDigits = 0
        return f.string(from: NSNumber(value: v)) ?? "0"
    }
    private func chiffre(_ c: String) {
        if !enSaisie { affichage = (c == ",") ? "0," : c; enSaisie = true; return }
        if c == "," && affichage.contains(",") { return }
        if affichage == "0" && c != "," { affichage = c; return }
        if affichage.filter({ $0.isNumber }).count >= 9 && c != "," { return }
        affichage += c
    }
    private func applique(_ a: Double, _ op: String, _ b: Double) -> Double {
        switch op {
        case "÷": return b == 0 ? Double.nan : a / b
        case "×": return a * b
        case "−": return a - b
        default:  return a + b
        }
    }
    private func opere(_ op: String) {
        if let acc = accumulateur, let opEnCours = operation, enSaisie {
            let r = applique(acc, opEnCours, valeurCourante)
            affichage = formate(r)
            accumulateur = r
        } else {
            accumulateur = valeurCourante
        }
        expression = formate(accumulateur ?? 0) + op
        operation = op
        enSaisie = false
    }
    private func egal() {
        guard let acc = accumulateur, let op = operation else { return }
        let b = valeurCourante
        let r = applique(acc, op, b)
        let ligne = formate(acc) + op + formate(b) + " = " + formate(r)
        historique.insert(ligne, at: 0)
        expression = formate(acc) + op + formate(b)
        affichage = formate(r)
        accumulateur = nil
        operation = nil
        enSaisie = false
    }
    private func pourcent() {
        // Comportement iOS : % seul divise par 100 ; après + ou −, % s'applique à l'accumulateur
        if let acc = accumulateur, let op = operation, (op == "+" || op == "−"), enSaisie {
            affichage = formate(acc * valeurCourante / 100)
        } else {
            affichage = formate(valeurCourante / 100)
        }
        enSaisie = true
    }
    private func efface() {
        if enSaisie && affichage != "0" {
            affichage = "0"; enSaisie = false                 // C : entrée seule
        } else {
            affichage = "0"; expression = ""; accumulateur = nil; operation = nil; enSaisie = false // AC : tout
        }
    }
    private func retour() {
        guard enSaisie, affichage.count > 0 else { return }
        affichage.removeLast()
        if affichage.isEmpty || affichage == "-" { affichage = "0"; enSaisie = false }
    }

    // ————— UI —————
    private var texteC: String { (enSaisie && affichage != "0") ? "C" : "AC" }
    private var tailleAffichage: CGFloat {
        let n = affichage.count
        if n > 12 { return 44 }
        if n > 9 { return 58 }
        if n > 6 { return 72 }
        return 88
    }

    var body: some View {
        VStack(spacing: 0) {
            // Barre haute : historique (à gauche) + mode (à droite), comme la référence
            HStack {
                Button { historiqueVisible = true } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 19)).foregroundStyle(.white.opacity(0.85))
                        .frame(width: 40, height: 40)
                        .background(Color(hex: 0x1C1C1E), in: Circle())
                }
                Spacer()
                Image(systemName: "list.number")
                    .font(.system(size: 17)).foregroundStyle(.white.opacity(0.85))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: 0x1C1C1E), in: Circle())
            }
            .padding(.horizontal, 18).padding(.top, 6)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(expression)
                    .font(.system(size: 20)).foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(expression.isEmpty ? 0 : 1)
                Text(affichage)
                    .font(.system(size: tailleAffichage, weight: .regular))
                    .foregroundStyle(.white)
                    .lineLimit(1).minimumScaleFactor(0.4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .contentShape(Rectangle())
                    .onLongPressGesture {
                        UIPasteboard.general.string = affichage
                        copie = true
                    }
            }
            .padding(.horizontal, 30).padding(.bottom, 12)

            // Clavier 5 rangées comme la référence (⌫ C % ÷ / 789× / 456− / 123+ / +/- 0 , =)
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ToucheCalc(t: "⌫", fond: grisFonce) { retour() }
                    ToucheCalc(t: texteC, fond: grisFonce) { efface() }
                    ToucheCalc(t: "%", fond: grisFonce) { pourcent() }
                    ToucheCalc(t: "÷", fond: orange, actif: operation == "÷" && !enSaisie) { opere("÷") }
                }
                HStack(spacing: 12) {
                    ToucheCalc(t: "7", fond: grisClair) { chiffre("7") }
                    ToucheCalc(t: "8", fond: grisClair) { chiffre("8") }
                    ToucheCalc(t: "9", fond: grisClair) { chiffre("9") }
                    ToucheCalc(t: "×", fond: orange, actif: operation == "×" && !enSaisie) { opere("×") }
                }
                HStack(spacing: 12) {
                    ToucheCalc(t: "4", fond: grisClair) { chiffre("4") }
                    ToucheCalc(t: "5", fond: grisClair) { chiffre("5") }
                    ToucheCalc(t: "6", fond: grisClair) { chiffre("6") }
                    ToucheCalc(t: "−", fond: orange, actif: operation == "−" && !enSaisie) { opere("−") }
                }
                HStack(spacing: 12) {
                    ToucheCalc(t: "1", fond: grisClair) { chiffre("1") }
                    ToucheCalc(t: "2", fond: grisClair) { chiffre("2") }
                    ToucheCalc(t: "3", fond: grisClair) { chiffre("3") }
                    ToucheCalc(t: "+", fond: orange, actif: operation == "+" && !enSaisie) { opere("+") }
                }
                HStack(spacing: 12) {
                    ToucheCalc(t: "+/-", fond: grisClair) {
                        if affichage.hasPrefix("-") { affichage.removeFirst() }
                        else if affichage != "0" { affichage = "-" + affichage }
                    }
                    ToucheCalc(t: "0", fond: grisClair) { chiffre("0") }
                    ToucheCalc(t: ",", fond: grisClair) { chiffre(",") }
                    ToucheCalc(t: "=", fond: orange) { egal() }
                }
            }
            .padding(.horizontal, 14).padding(.bottom, 10)

            BarreHome { dismiss() }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .alert("Copié", isPresented: $copie) { Button("OK", role: .cancel) {} } message: {
            Text("Le résultat a été copié dans le presse-papiers.")
        }
        .sheet(isPresented: $historiqueVisible) {
            NavigationStack {
                Group {
                    if historique.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 40)).foregroundStyle(.secondary)
                            Text("Aucun calcul récent").font(.system(size: 16)).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hex: 0x1C1C1E))
                    } else {
                        List {
                            ForEach(historique, id: \.self) { l in
                                Text(l).foregroundStyle(.white).monospacedDigit()
                                    .listRowBackground(Color(hex: 0x2C2C2E))
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color(hex: 0x1C1C1E))
                    }
                }
                .navigationTitle("Historique")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("OK") { historiqueVisible = false }.foregroundStyle(orange)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .presentationDetents([.medium])
        }
    }
}

struct ToucheCalc: View {
    let t: String
    let fond: Color
    var actif: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(t)
                .font(.system(size: t == "+/-" ? 26 : 34, weight: .medium))
                .foregroundStyle(actif ? Color(hex: 0xFF9F0A) : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 78)
                .background(actif ? Color.white : fond, in: Circle())
        }
        .buttonStyle(.plain)
    }
}
