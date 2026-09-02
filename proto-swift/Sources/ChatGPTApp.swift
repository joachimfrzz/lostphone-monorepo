// ChatGPT — construit contre les références vidéo de Joachim du 26/08 (D67, 120 écrans mesurés).
// v1 : accueil (Chat/Work, champ « Demander à ChatGPT »), conversation (réponses locales scriptées),
// panneau latéral (Images/Bibliothèque/Projets/Planifié + Récents), bibliothèque, projets, recherche.
// Thème sombre. Données Sarah = jeu plausible remplaçable (D59).
import SwiftUI

// ============================================================ DONNÉES
enum DonneesGPT {
    static let recents = [
        "Idée cadeau anniversaire maman", "Recette risotto champignons", "Étirements après rando",
        "Traduire un mail en anglais", "Plan d'entraînement course", "Idées week-end Annecy",
    ]
    static let projets: [(String, String)] = [
        ("Appartement", "il y a 2 sem"), ("Voyage Écosse", "il y a 1 mois"), ("Poterie", "il y a 3 mois"),
    ]
    static let conversation: [(Bool, String)] = [
        (true, "Idée de cadeau pour l'anniversaire de ma mère ? Elle aime le jardin et la lecture."),
        (false, "Voici quelques idées qui combinent ses deux passions :\n\n1. Un abonnement à une box lecture avec un marque-page personnalisé\n2. Une jardinière d'herbes aromatiques d'intérieur\n3. Un beau livre illustré sur les jardins remarquables\n4. Un banc de jardin gravé\n\nVoulez-vous que je détaille un budget pour chaque option ?"),
        (true, "La jardinière c'est une super idée, tu as des modèles ?"),
        (false, "Excellente idée ! Pour une jardinière d'intérieur, regardez du côté des modèles en bois clair avec réserve d'eau — simples, jolis et sans entretien. Comptez entre 25 et 60 € selon la taille. Les jardineries lyonnaises en ont souvent en rayon en cette saison."),
    ]
}

let gptFond: UInt = 0x0D0D0D
let gptCarte: UInt = 0x1E1E1E

// ============================================================ APP
struct ChatGPTVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0
    @State private var menuVisible = false
    @State private var convVisible = false
    @State private var saisie = ""
    @State private var modeWork = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: gptFond).ignoresSafeArea()
            VStack(spacing: 0) {
                // En-tête : menu, Chat/Work, historique
                HStack {
                    Image(systemName: "line.3.horizontal").font(.system(size: 19)).foregroundStyle(.white)
                        .contentShape(Rectangle())
                        .onTapGesture { menuVisible = true }
                    Spacer()
                    HStack(spacing: 0) {
                        Text("Chat").font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(modeWork ? Color.white : Color.black)
                            .padding(.horizontal, 16).padding(.vertical, 6)
                            .background(modeWork ? Color.clear : Color.white, in: Capsule())
                            .contentShape(Rectangle())
                            .onTapGesture { withAnimation { modeWork = false } }
                        Text("Work").font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(modeWork ? Color.black : Color.white)
                            .padding(.horizontal, 16).padding(.vertical, 6)
                            .background(modeWork ? Color.white : Color.clear, in: Capsule())
                            .contentShape(Rectangle())
                            .onTapGesture { withAnimation { modeWork = true } }
                    }
                    .padding(3)
                    .background(Color(hex: gptCarte), in: Capsule())
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath").font(.system(size: 18)).foregroundStyle(.white)
                        .contentShape(Rectangle())
                        .onTapGesture { menuVisible = true }
                }
                .padding(.horizontal, 16).padding(.top, 6)

                Spacer()
                Text(modeWork ? "Mode Work — Qu'est-ce qu'on accomplit aujourd'hui ?" : "Salut Sarah 😊 Qu'est-ce qu'on fait ce soir ?")
                    .font(.system(size: 21, weight: .semibold)).foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .animation(.easeInOut(duration: 0.2), value: modeWork)
                Spacer()

                // Champ de saisie
                HStack(spacing: 10) {
                    Image(systemName: "plus").font(.system(size: 18)).foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(hex: gptCarte), in: Circle())
                    TextField("", text: $saisie, prompt: Text("Demander à ChatGPT").foregroundStyle(.gray))
                        .font(.system(size: 15)).foregroundStyle(.white)
                        .onSubmit { convVisible = true }
                }
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(Color(hex: gptCarte), in: RoundedRectangle(cornerRadius: 26))
                .padding(.horizontal, 14)
                .padding(.bottom, 58)
            }

            BarreHome { dismiss() }
        }
        .sheet(isPresented: $menuVisible) { GPTMenuVue() }
        .fullScreenCover(isPresented: $convVisible) { GPTConversationVue(question: saisie) }
        .onAppear {
            let cle = ProcessInfo.processInfo.environment["ECRAN"] ?? ""
            if cle == "chatgpt.menu" { menuVisible = true }
            if cle == "chatgpt.conv" { convVisible = true }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ PANNEAU LATÉRAL
struct GPTMenuVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bibliotheque = false
    @State private var projets = false
    @State private var recherche = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.gray)
                        TextField("Rechercher", text: $recherche).font(.system(size: 14.5)).foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12).frame(height: 38)
                    .background(Color(hex: gptCarte), in: RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 10)

                    GPTLigneMenu(symbole: "photo", titre: "Images") {}
                    GPTLigneMenu(symbole: "books.vertical", titre: "Bibliothèque") { bibliotheque = true }
                    GPTLigneMenu(symbole: "folder", titre: "Projets") { projets = true }
                    GPTLigneMenu(symbole: "calendar", titre: "Planifié") {}
                    GPTLigneMenu(symbole: "ellipsis", titre: "Plus") {}

                    Text("Récents").font(.system(size: 13, weight: .semibold)).foregroundStyle(.gray)
                        .padding(.top, 14).padding(.bottom, 4)
                    ForEach(DonneesGPT.recents.filter { recherche.isEmpty || $0.lowercased().contains(recherche.lowercased()) }, id: \.self) { r in
                        Text(r).font(.system(size: 15)).foregroundStyle(.white)
                            .padding(.vertical, 9)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
            }
            .background(Color(hex: gptFond))
            .navigationTitle("ChatGPT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(.white)
                }
            }
            .sheet(isPresented: $bibliotheque) { GPTBibliothequeVue() }
            .sheet(isPresented: $projets) { GPTProjetsVue() }
        }
        .preferredColorScheme(.dark)
    }
}

struct GPTLigneMenu: View {
    let symbole: String
    let titre: String
    let action: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbole).font(.system(size: 16)).foregroundStyle(.white).frame(width: 24)
            Text(titre).font(.system(size: 15.5)).foregroundStyle(.white)
            Spacer()
        }
        .padding(.vertical, 9)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// ============================================================ CONVERSATION
struct GPTConversationVue: View {
    @Environment(\.dismiss) private var dismiss
    var question: String = ""
    @State private var saisie = ""
    @State private var envoyes: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.left").font(.system(size: 19, weight: .semibold)).foregroundStyle(.white)
                    .contentShape(Rectangle())
                    .onTapGesture { dismiss() }
                Spacer()
                Text("ChatGPT").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                Spacer()
                Image(systemName: "square.and.pencil").font(.system(size: 17)).foregroundStyle(.white)
            }
            .padding(.horizontal, 16).padding(.vertical, 9)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(DonneesGPT.conversation.enumerated()), id: \.offset) { _, m in
                        if m.0 {
                            HStack {
                                Spacer(minLength: 60)
                                Text(m.1).font(.system(size: 15)).foregroundStyle(.white)
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(Color(hex: gptCarte), in: RoundedRectangle(cornerRadius: 18))
                            }
                        } else {
                            Text(m.1).font(.system(size: 15)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    ForEach(Array(envoyes.enumerated()), id: \.offset) { _, t in
                        HStack {
                            Spacer(minLength: 60)
                            Text(t).font(.system(size: 15)).foregroundStyle(.white)
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(Color(hex: gptCarte), in: RoundedRectangle(cornerRadius: 18))
                        }
                        // D18 : pas d'IA d'exécution — réponse locale plausible unique
                        Text("Je note ! Dites-m'en un peu plus et je vous propose des pistes concrètes.")
                            .font(.system(size: 15)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
            }

            HStack(spacing: 10) {
                Image(systemName: "plus").font(.system(size: 18)).foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color(hex: gptCarte), in: Circle())
                TextField("", text: $saisie, prompt: Text("Demander à ChatGPT").foregroundStyle(.gray))
                    .font(.system(size: 15)).foregroundStyle(.white)
                    .onSubmit { if !saisie.isEmpty { envoyes.append(saisie); saisie = "" } }
                Image(systemName: "arrow.up").font(.system(size: 16, weight: .semibold)).foregroundStyle(.black)
                    .frame(width: 34, height: 34)
                    .background(Color.white, in: Circle())
                    .contentShape(Circle())
                    .onTapGesture { if !saisie.isEmpty { envoyes.append(saisie); saisie = "" } }
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Color(hex: gptCarte), in: RoundedRectangle(cornerRadius: 26))
            .padding(.horizontal, 14).padding(.bottom, 8)

            BarreHome { dismiss() }
        }
        .background(Color(hex: gptFond))
        .preferredColorScheme(.dark)
    }
}

// ============================================================ BIBLIOTHÈQUE + PROJETS
struct GPTBibliothequeVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ongletB = 0
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(Array(["Tous", "Images", "Documents"].enumerated()), id: \.offset) { i, t in
                        Text(t).font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ongletB == i ? Color.black : Color.white)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(ongletB == i ? Color.white : Color(hex: gptCarte), in: Capsule())
                            .contentShape(Capsule())
                            .onTapGesture { ongletB = i }
                    }
                }
                .padding(.horizontal, 16)
                if ongletB == 2 {
                    VStack(spacing: 8) {
                        Image(systemName: "doc").font(.system(size: 36)).foregroundStyle(.gray)
                        Text("Aucun document").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 90)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                        ForEach(Array(["p31", "p34"].enumerated()), id: \.offset) { _, cle in
                            Group {
                                if let img = ChargeurPhoto.image(cle) {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else { Rectangle().fill(Color(hex: gptCarte)) }
                            }
                            .frame(height: 170).clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                Spacer()
            }
            .padding(.top, 10)
            .background(Color(hex: gptFond))
            .navigationTitle("Bibliothèque")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct GPTProjetsVue: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Text("Tous").font(.system(size: 13, weight: .semibold)).foregroundStyle(.black)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Color.white, in: Capsule())
                        Text("Créés par vous").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Color(hex: gptCarte), in: Capsule())
                    }
                    .padding(.bottom, 14)
                    ForEach(Array(DonneesGPT.projets.enumerated()), id: \.offset) { _, p in
                        HStack(spacing: 12) {
                            Image(systemName: "folder.fill").font(.system(size: 17)).foregroundStyle(Color(hex: 0x8B8B8B))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(p.0).font(.system(size: 15.5)).foregroundStyle(.white)
                                Text(p.1).font(.system(size: 12.5)).foregroundStyle(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                }
                .padding(16)
            }
            .background(Color(hex: gptFond))
            .navigationTitle("Projets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
