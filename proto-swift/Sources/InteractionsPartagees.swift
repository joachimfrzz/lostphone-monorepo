// Composants partagés du chantier interactions (D69, vague 1 — 26/08).
// R1 : VisualiseurContenuVue — visualiseur plein écran générique (stories, cartes Découvrir, contenus).
// R3 : FilGeneriqueVue — fil de conversation court générique (DM Instagram, lignes sans fil dédié).
// R10 : chaque réponse tient sa promesse — pas de faux-semblant.
import SwiftUI

// ============================================================ R1 — VISUALISEUR DE CONTENU
struct VisualiseurContenuVue: View {
    @Environment(\.dismiss) private var dismiss
    var titre: String
    var sousTitre: String = "Il y a 4 h"
    var imageCle: String? = nil
    var emoji: String? = nil
    var teinte: UInt = 0x5B7CFA
    var avecMessage: Bool = true
    @State private var saisie = ""
    @State private var progression: CGFloat = 0.12
    private let minuteur = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Group {
                if let cle = imageCle, let img = ChargeurPhoto.image(cle) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    LinearGradient(colors: [Color(hex: teinte), Color(hex: teinte).opacity(0.45)],
                                   startPoint: .top, endPoint: .bottom)
                }
            }
            .ignoresSafeArea()
            if imageCle == nil, let e = emoji {
                Text(e).font(.system(size: 110))
            }
            Color.black.opacity(0.10).ignoresSafeArea()

            VStack(spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.35)).frame(height: 2.5)
                        Capsule().fill(Color.white).frame(width: geo.size.width * progression, height: 2.5)
                    }
                }
                .frame(height: 2.5)
                .padding(.horizontal, 10).padding(.top, 8)

                HStack(spacing: 9) {
                    Group {
                        if let cle = imageCle, let img = ChargeurPhoto.image(cle) {
                            Image(uiImage: img).resizable().scaledToFill()
                                .frame(width: 34, height: 34).clipShape(Circle())
                        } else {
                            Circle().fill(Color(hex: teinte)).frame(width: 34, height: 34)
                                .overlay(Text(emoji ?? String(titre.prefix(1)))
                                    .font(.system(size: emoji != nil ? 17 : 15, weight: .semibold)).foregroundStyle(.white))
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(titre).font(.system(size: 13.5, weight: .semibold)).foregroundStyle(.white)
                        Text(sousTitre).font(.system(size: 12)).foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: "xmark").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                        .contentShape(Rectangle())
                        .onTapGesture { dismiss() }
                }
                .padding(.horizontal, 12)
                Spacer()
                if avecMessage {
                    HStack(spacing: 12) {
                        TextField("", text: $saisie, prompt: Text("Envoyer un message…").foregroundStyle(.white.opacity(0.8)))
                            .font(.system(size: 14)).foregroundStyle(.white)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
                        Image(systemName: "heart").font(.system(size: 24)).foregroundStyle(.white)
                        Image(systemName: "paperplane").font(.system(size: 23)).foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12).padding(.bottom, 24)
                }
            }
        }
        .onReceive(minuteur) { _ in
            if progression < 1 { progression += 0.0012 } else { dismiss() }
        }
        .contentShape(Rectangle())
        .onTapGesture { progression = min(progression + 0.3, 0.999) }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ R3 — FIL DE CONVERSATION GÉNÉRIQUE
struct FilGeneriqueVue: View {
    @Environment(\.dismiss) private var dismiss
    var nom: String
    var photo: String? = nil
    var teinte: UInt = 0x5B7CFA
    var accent: UInt = 0x0095F6
    var messages: [(deMoi: Bool, texte: String)]
    @State private var saisie = ""
    @State private var envoyes: [String] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { _, m in
                            HStack {
                                if m.deMoi { Spacer(minLength: 60) }
                                Text(m.texte).font(.system(size: 14.5)).foregroundStyle(.white)
                                    .padding(.horizontal, 13).padding(.vertical, 9)
                                    .background(m.deMoi ? Color(hex: accent) : Color(hex: 0x262626),
                                                in: RoundedRectangle(cornerRadius: 18))
                                if !m.deMoi { Spacer(minLength: 60) }
                            }
                        }
                        ForEach(Array(envoyes.enumerated()), id: \.offset) { _, t in
                            HStack {
                                Spacer(minLength: 60)
                                Text(t).font(.system(size: 14.5)).foregroundStyle(.white)
                                    .padding(.horizontal, 13).padding(.vertical, 9)
                                    .background(Color(hex: accent), in: RoundedRectangle(cornerRadius: 18))
                            }
                        }
                    }
                    .padding(14)
                }
                HStack(spacing: 10) {
                    TextField("Message…", text: $saisie)
                        .font(.system(size: 14)).foregroundStyle(.white)
                        .padding(.horizontal, 13).padding(.vertical, 9)
                        .background(Color(hex: 0x262626), in: Capsule())
                        .onSubmit { if !saisie.isEmpty { envoyes.append(saisie); saisie = "" } }
                    Image(systemName: "paperplane.fill").foregroundStyle(Color(hex: accent))
                        .contentShape(Rectangle())
                        .onTapGesture { if !saisie.isEmpty { envoyes.append(saisie); saisie = "" } }
                }
                .padding(12)
            }
            .background(Color.black)
            .navigationTitle(nom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: accent))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
