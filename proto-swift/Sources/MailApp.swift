// Mail — construit contre les vidéos de référence du 20/08 (57 + 10 écrans, iOS 26)
// D51-2 : tous les composants (boîtes, VIP, lecture, composition réelle, brouillons, indésirables).
// R3 : la confirmation LCL du RDV, le reçu Western Union (= P67), le premier mail Meetic du 12 mars,
// le billet SNCF Lyon → Marseille du 28 août… et le brouillon jamais envoyé à Chloé.
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct Courriel: Identifiable {
    let id = UUID()
    var expediteur: String
    var adresse: String
    var objet: String
    var apercu: String
    var corps: String
    var date: String
    var nonLu: Bool = false
    var vip: Bool = false
    var boite: String = "Réception"   // Réception / Indésirables / Envoyés / Brouillons / Envoi
    var couleur: UInt = 0x5B7CFA
}

final class MagasinMail: ObservableObject {
    static let partage = MagasinMail()
    @Published var courriels: [Courriel] = [
        Courriel(expediteur: "LCL", adresse: "no-reply@lcl.fr",
                 objet: "Confirmation de votre rendez-vous",
                 apercu: "Votre rendez-vous du lundi 17 août à 11h30 est confirmé avec M. Rossi…",
                 corps: "Bonjour Madame Levasseur,\n\nVotre rendez-vous du lundi 17 août à 11h30 est confirmé avec M. Rossi, votre conseiller, à l'agence LYON BELLECOUR.\n\nMotif indiqué : augmentation de plafond de virement.\n\nPensez à vous munir d'une pièce d'identité, d'un justificatif de domicile et de vos trois derniers relevés.\n\nCordialement,\nVotre agence LCL",
                 date: "14/08/2026", nonLu: true, couleur: 0x00184D),
        Courriel(expediteur: "SNCF Connect", adresse: "confirmation@sncf-connect.com",
                 objet: "Votre billet : Lyon → Marseille, ven. 28 août",
                 apercu: "Confirmation de votre e-billet — Lyon Part-Dieu 08:04 → Marseille St-Charles 09:47…",
                 corps: "Bonjour Sarah,\n\nVotre e-billet est confirmé.\n\nTGV INOUI 6173\nVendredi 28 août 2026\nLyon Part-Dieu 08:04 → Marseille St-Charles 09:47\nVoiture 12, place 74 (fenêtre)\n\n1 passager · 47,00 €\nRéférence : QVRTGB\n\nBon voyage !",
                 date: "10/08/2026", couleur: 0x8B5CF6),
        Courriel(expediteur: "Chloé", adresse: "chloe.bnv@gmail.com",
                 objet: "Photos du festival (les dernières promis)",
                 apercu: "J'ai fini de trier !! Il y en a 6 où on est magnifiques, je te les mets là…",
                 corps: "J'ai fini de trier !! Il y en a 6 où on est magnifiques, je te les mets là.\n\nOn les encadre celles-là ❤️\n\nC.",
                 date: "13/07/2026", vip: true, couleur: 0xE17BB2),
        Courriel(expediteur: "Western Union", adresse: "receipts@westernunion.com",
                 objet: "Reçu de votre transfert — MTCN 738-421-9905",
                 apercu: "Votre transfert de 800,00 EUR a bien été envoyé. Frais : 50,00 EUR…",
                 corps: "Bonjour SARAH LEVASSEUR,\n\nVotre transfert a bien été envoyé.\n\nMontant : 800,00 EUR\nFrais : 50,00 EUR\nTotal : 850,00 EUR\nDestinataire : OKAFOR M.\nRetrait : en espèces — international\nMTCN : 738-421-9905\n\nCommuniquez le MTCN uniquement au destinataire.",
                 date: "13/06/2026", couleur: 0xE8C33D),
        Courriel(expediteur: "Meetic", adresse: "notification@meetic.fr",
                 objet: "Marc vous a envoyé un message 💬",
                 apercu: "Un membre qui vous correspond à 92 % vous a écrit. Découvrez son message…",
                 corps: "Bonne nouvelle Sarah !\n\nMarc, 54 ans, vous a envoyé un message :\n\n« Bonjour Sarah. Votre sourire sur la photo du port m'a arrêté net. Je suis officier de marine marchande, souvent en mer, mais je crois aux belles rencontres. Accepteriez-vous de faire connaissance ? »\n\nRépondez-lui sur Meetic.",
                 date: "12/03/2026", couleur: 0x3B5DF6),
        Courriel(expediteur: "Phox Photo", adresse: "news@phox.fr",
                 objet: "Nouveautés hybrides : jusqu'à -30 % cet été",
                 apercu: "Les meilleurs boîtiers hybrides de l'été sont arrivés, et les optiques 50 mm…",
                 corps: "Les meilleurs boîtiers hybrides de l'été sont arrivés.\n\nJusqu'à -30 % sur une sélection d'optiques, dont le 50 mm f/1.8 que vous avez consulté.\n\nÀ très vite dans votre magasin de Lyon.",
                 date: "02/08/2026", couleur: 0x30D158),
        Courriel(expediteur: "EDF", adresse: "serviceclient@edf.fr",
                 objet: "Votre facture d'août est disponible",
                 apercu: "Votre facture de 64,12 € sera prélevée le 28/08/2026…",
                 corps: "Bonjour,\n\nVotre facture d'électricité d'août (64,12 €) est disponible dans votre espace client. Elle sera prélevée le 28/08/2026.\n\nEDF",
                 date: "08/08/2026", couleur: 0x0A84FF),
        Courriel(expediteur: "Vinted", adresse: "no-reply@vinted.fr",
                 objet: "Votre article « Robe fleurie T38 » a été vendu !",
                 apercu: "Félicitations ! Envoyez le colis avant le 20 août pour recevoir votre paiement de 14 €…",
                 corps: "Félicitations !\n\nVotre article « Robe fleurie T38 » a été vendu 14,00 €.\nEnvoyez le colis avant le 20 août.\n\nVinted",
                 date: "16/08/2026", nonLu: true, couleur: 0x2FBFAD),
        // — Indésirables (les échos du thème)
        Courriel(expediteur: "M. Ibrahim Diallo", adresse: "barrister.diallo@consultant-intl.biz",
                 objet: "RE: SUCCESSION 2.400.000 USD — RÉPONSE URGENTE",
                 apercu: "Cher ami, je vous contacte au sujet d'un héritage sans bénéficiaire…",
                 corps: "Cher ami,\n\nJe suis avocat et je vous contacte au sujet d'un héritage de 2.400.000 USD sans bénéficiaire. Votre aide sera récompensée à hauteur de 30 %.\n\nRépondez vite et en toute confidentialité.",
                 date: "11/08/2026", boite: "Indésirables", couleur: 0x8E8E93),
        Courriel(expediteur: "LCL Sécurité", adresse: "alerte@lcl-securite-clients.com",
                 objet: "Votre accès sera suspendu sous 24h",
                 apercu: "Suite a un controle de securite, verifiez immediatement vos informations…",
                 corps: "LCL-INFO : Suite a un controle de securite, votre acces sera suspendu sous 24h. Verifiez immediatement vos informations : lcl-securite-clients.com/verif",
                 date: "16/08/2026", boite: "Indésirables", couleur: 0x8E8E93),
        // — Envoyés
        Courriel(expediteur: "Moi", adresse: "sarah.levasseur@icloud.com",
                 objet: "Re: Photos du festival (les dernières promis)",
                 apercu: "Je les aime tellement. La 4 en fond d'écran immédiatement…",
                 corps: "Je les aime tellement. La 4 en fond d'écran immédiatement.\n\nMerci d'être toi. ❤️\n\nS.",
                 date: "13/07/2026", boite: "Envoyés", couleur: 0x5B7CFA),
        // — Le brouillon jamais envoyé (l'or)
        Courriel(expediteur: "Moi", adresse: "sarah.levasseur@icloud.com",
                 objet: "(Aucun objet)",
                 apercu: "Chloé. Tu avais raison depuis le début. Je crois que je",
                 corps: "Chloé. Tu avais raison depuis le début. Je crois que je",
                 date: "17/08/2026", boite: "Brouillons", couleur: 0x5B7CFA),
    ]

    func boite(_ nom: String) -> [Courriel] {
        courriels.filter { $0.boite == nom }
    }
}

// ============================================================ APP (Boîtes)
struct MailVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinMail.partage
    @State private var composer = false
    @State private var modifierVisible = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Boîtes").font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                            Text("MÀJ à l'instant").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)

                        VStack(spacing: 1) {
                            LigneBoite(symbole: "envelope.fill", couleur: 0x0A84FF, nom: "Réception",
                                       compte: magasin.boite("Réception").count,
                                       destination: ListeMailVue(titre: "Réception", boite: "Réception"))
                            LigneBoite(symbole: "star.fill", couleur: 0xE8C33D, nom: "VIP", compte: nil,
                                       destination: ListeMailVue(titre: "VIP", boite: "VIP"))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(spacing: 1) {
                            LigneBoite(symbole: "paperplane", couleur: 0x8E8E93, nom: "Boîte d'envoi", compte: nil,
                                       destination: ListeMailVue(titre: "Boîte d'envoi", boite: "Envoi"))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        HStack {
                            Text("iCloud").font(.system(size: 15, weight: .semibold)).foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "chevron.down").font(.system(size: 12)).foregroundStyle(Color(hex: 0x0A84FF))
                        }
                        .padding(.top, 6)
                        VStack(spacing: 1) {
                            LigneBoite(symbole: "doc.fill", couleur: 0x8E8E93, nom: "Brouillons",
                                       compte: magasin.boite("Brouillons").count,
                                       destination: ListeMailVue(titre: "Brouillons", boite: "Brouillons"))
                            LigneBoite(symbole: "trash.fill", couleur: 0x8E8E93, nom: "Corbeille",
                                       compte: magasin.boite("Corbeille").count,
                                       destination: ListeMailVue(titre: "Corbeille", boite: "Corbeille"))
                            LigneBoite(symbole: "paperplane.fill", couleur: 0x0A84FF, nom: "Envoyés",
                                       compte: magasin.boite("Envoyés").count,
                                       destination: ListeMailVue(titre: "Envoyés", boite: "Envoyés"))
                            LigneBoite(symbole: "xmark.bin.fill", couleur: 0x8E8E93, nom: "Indésirables",
                                       compte: magasin.boite("Indésirables").count,
                                       destination: ListeMailVue(titre: "Indésirables", boite: "Indésirables"))
                            LigneBoite(symbole: "tray.2.fill", couleur: 0x8E8E93, nom: "Tous les e-mails",
                                       compte: magasin.courriels.count,
                                       destination: ListeMailVue(titre: "Tous les e-mails", boite: "*"))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 16)
                }

                HStack {
                    Spacer()
                    Button { composer = true } label: {
                        Image(systemName: "square.and.pencil").font(.system(size: 19))
                            .foregroundStyle(Color(hex: 0x0A84FF))
                            .frame(width: 46, height: 46)
                            .background(Color(hex: 0x1C1C1E), in: Circle())
                    }
                }
                .padding(.horizontal, 18).padding(.bottom, 10)

            BarreHome { dismiss() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Modifier") { modifierVisible = true }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
            .sheet(isPresented: $composer) { ComposerMailVue() }
            .sheet(isPresented: $modifierVisible) {
                NavigationStack {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        VStack(spacing: 8) {
                            Image(systemName: "tray.2.fill").font(.system(size: 30)).foregroundStyle(.secondary)
                            Text("Modifier les boîtes").font(.system(size: 16)).foregroundStyle(.white)
                            Text("Réception, Envoyés, Corbeille — aucune boîte supprimable dans cette configuration.")
                                .font(.system(size: 13)).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 30)
                        }
                    }
                    .navigationTitle("Modifier").navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("OK") { modifierVisible = false }.foregroundStyle(Color(hex: 0x0A84FF)) } }
                }
                .preferredColorScheme(.dark)
                .presentationDetents([.medium])
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct LigneBoite<D: View>: View {
    let symbole: String
    let couleur: UInt
    let nom: String
    let compte: Int?
    let destination: D
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: symbole).font(.system(size: 16)).foregroundStyle(Color(hex: couleur))
                    .frame(width: 26)
                Text(nom).font(.system(size: 16)).foregroundStyle(.white)
                Spacer()
                if let compte, compte > 0 {
                    Text("\(compte)").font(.system(size: 15)).foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(Color(hex: 0x1C1C1E))
        }
    }
}

// ============================================================ LISTE
struct ListeMailVue: View {
    let titre: String
    let boite: String
    @ObservedObject private var magasin = MagasinMail.partage
    @State private var recherche = ""
    @State private var selectionActive = false

    private var items: [Courriel] {
        var l: [Courriel]
        switch boite {
        case "*": l = magasin.courriels
        case "VIP": l = magasin.courriels.filter { $0.vip }
        case "Envoi": l = []
        default: l = magasin.boite(boite)
        }
        if !recherche.isEmpty {
            l = l.filter { $0.objet.localizedCaseInsensitiveContains(recherche)
                        || $0.expediteur.localizedCaseInsensitiveContains(recherche)
                        || $0.corps.localizedCaseInsensitiveContains(recherche) }
        }
        return l
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(titre).font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
                Text(boite == "Envoi" ? "Aucun message non envoyé" : "iCloud · MÀJ à l'instant")
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                    .padding(.bottom, 10)
                if items.isEmpty {
                    Text(boite == "Corbeille" ? "La corbeille est vide" : "Aucun message")
                        .font(.system(size: 15)).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity).padding(.top, 80)
                }
                ForEach(items) { c in
                    NavigationLink(destination: LectureMailVue(courriel: c)) {
                        HStack(alignment: .top, spacing: 10) {
                            if c.nonLu {
                                Circle().fill(Color(hex: 0x0A84FF)).frame(width: 9, height: 9).padding(.top, 6)
                            } else {
                                Color.clear.frame(width: 9, height: 9)
                            }
                            Circle().fill(Color(hex: c.couleur))
                                .frame(width: 38, height: 38)
                                .overlay(Text(String(c.expediteur.prefix(1))).font(.system(size: 16, weight: .bold)).foregroundStyle(.white))
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(c.expediteur).font(.system(size: 15.5, weight: .semibold)).foregroundStyle(.white)
                                    Spacer()
                                    Text(c.date).font(.system(size: 13)).foregroundStyle(.secondary)
                                    Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(.secondary)
                                }
                                Text(c.objet).font(.system(size: 14)).foregroundStyle(.white.opacity(0.9)).lineLimit(1)
                                Text(c.apercu).font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(2)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    Divider().overlay(Color(hex: 0x2C2C2E)).padding(.leading, 55)
                }
                Spacer(minLength: 60)
            }
            .padding(.horizontal, 16)
        }
        .background(Color.black)
        .overlay(alignment: .bottom) {
            // Miroir lot 3 : la recherche vit EN BAS dans la vraie app (pilule + filtre + composition)
            HStack(spacing: 10) {
                Image(systemName: "line.3.horizontal.decrease").font(.system(size: 16))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color(hex: 0x1F1F21), in: Circle())
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Recherche", text: $recherche).foregroundStyle(.white)
                    Image(systemName: "mic.fill").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 13).frame(height: 42)
                .background(Color(hex: 0x1F1F21), in: Capsule())
                Image(systemName: "square.and.pencil").font(.system(size: 17))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color(hex: 0x1F1F21), in: Circle())
            }
            .padding(.horizontal, 14).padding(.bottom, 12)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 14) {
                    Button(selectionActive ? "Annuler" : "Sélectionner") {
                        selectionActive.toggle()
                    }
                    .font(.system(size: 14)).foregroundStyle(Color(hex: 0x0A84FF))
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
    }
}

// ============================================================ LECTURE
struct LectureMailVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinMail.partage
    let courriel: Courriel
    @State private var alerte: String? = nil
    @State private var dossierDialog = false
    @State private var repondreVisible = false
    @State private var nouveauVisible = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Circle().fill(Color(hex: courriel.couleur))
                        .frame(width: 40, height: 40)
                        .overlay(Text(String(courriel.expediteur.prefix(1))).font(.system(size: 17, weight: .bold)).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(courriel.expediteur).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        Text("À : Sarah Levasseur").font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(courriel.date).font(.system(size: 12.5)).foregroundStyle(.secondary)
                }
                Text(courriel.objet).font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
                Divider().overlay(Color(hex: 0x2C2C2E))
                Text(courriel.corps).font(.system(size: 16)).foregroundStyle(.white.opacity(0.92))
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tint(.white.opacity(0.92))
                Spacer(minLength: 80)
            }
            .padding(16)
        }
        .background(Color.black)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Image(systemName: "trash").onTapGesture { deplacer(vers: "Corbeille"); dismiss() }
                Spacer()
                Image(systemName: "folder").onTapGesture { dossierDialog = true }
                Spacer()
                Image(systemName: "arrowshape.turn.up.left").onTapGesture { repondreVisible = true }
                Spacer()
                Image(systemName: "square.and.pencil").onTapGesture { nouveauVisible = true }
            }
        }
        .alert(titreAlerte, isPresented: Binding(get: { alerte != nil }, set: { if !$0 { alerte = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(messageAlerte) }
        .sheet(isPresented: $repondreVisible) {
            ComposerMailVue(destinataire: courriel.adresse, objet: "Re : " + courriel.objet)
        }
        .sheet(isPresented: $nouveauVisible) { ComposerMailVue() }
        .confirmationDialog("Déplacer vers…", isPresented: $dossierDialog, titleVisibility: .visible) {
            Button("Réception") { deplacer(vers: "Réception"); dismiss() }
            Button("Indésirables") { deplacer(vers: "Indésirables"); dismiss() }
            Button("Corbeille", role: .destructive) { deplacer(vers: "Corbeille"); dismiss() }
            Button("Annuler", role: .cancel) {}
        }
    }

    private func deplacer(vers boite: String) {
        Haptique.leger()
        if let i = magasin.courriels.firstIndex(where: { $0.id == courriel.id }) {
            magasin.courriels[i].boite = boite
        }
    }

    private var titreAlerte: String {
        switch alerte {
        case "corbeille": return "Corbeille"
        case "dossier": return "Déplacer"
        default: return "Répondre"
        }
    }
    private var messageAlerte: String {
        switch alerte {
        case "corbeille": return "Le message sera placé dans la corbeille."
        case "dossier": return "Choisissez une boîte aux lettres de destination."
        default: return "Utilisez le bouton Nouveau message pour écrire — les réponses arrivent avec le moteur d'histoire."
        }
    }
}

// ============================================================ COMPOSITION (réelle — D51)
struct ComposerMailVue: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var magasin = MagasinMail.partage
    @State private var destinataire: String
    @State private var objet: String

    init(destinataire: String = "", objet: String = "") {
        _destinataire = State(initialValue: destinataire)
        _objet = State(initialValue: objet)
    }
    @State private var corps = "\n\nEnvoyé de mon iPhone"
    @State private var brouillonAlerte = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        Text("À :").foregroundStyle(.secondary)
                        TextField("", text: $destinataire).foregroundStyle(Color(hex: 0x0A84FF))
                            .keyboardType(.emailAddress).autocapitalization(.none)
                        Image(systemName: "plus.circle").foregroundStyle(Color(hex: 0x0A84FF))
                    }
                    .padding(.horizontal, 16).padding(.vertical, 11)
                    Divider().overlay(Color(hex: 0x2C2C2E))
                    HStack {
                        Text("Cc/Cci, De : sarah.levasseur@icloud.com")
                            .font(.system(size: 14)).foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 11)
                    Divider().overlay(Color(hex: 0x2C2C2E))
                    HStack {
                        Text("Objet :").foregroundStyle(.secondary)
                        TextField("", text: $objet).foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 11)
                    Divider().overlay(Color(hex: 0x2C2C2E))
                }
                TextEditor(text: $corps)
                    .font(.system(size: 16)).foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
            }
            .background(Color.black)
            .navigationTitle(objet.isEmpty ? "Nouv. message" : objet)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { brouillonAlerte = true } label: {
                        Image(systemName: "xmark").foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // D54 transposé au mail : l'envoi part en Boîte d'envoi, jamais distribué
                        let c = Courriel(expediteur: "Moi", adresse: "sarah.levasseur@icloud.com",
                                         objet: objet.isEmpty ? "(Aucun objet)" : objet,
                                         apercu: corps.replacingOccurrences(of: "\n\nEnvoyé de mon iPhone", with: ""),
                                         corps: corps, date: "Maintenant", boite: "Envoyés")
                        magasin.courriels.append(c)
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(destinataire.isEmpty ? Color(hex: 0x5A5A5E) : Color(hex: 0x0A84FF))
                    }
                    .disabled(destinataire.isEmpty)
                }
            }
            .confirmationDialog("", isPresented: $brouillonAlerte, titleVisibility: .hidden) {
                Button("Effacer le brouillon", role: .destructive) { dismiss() }
                Button("Enregistrer le brouillon") {
                    let c = Courriel(expediteur: "Moi", adresse: "sarah.levasseur@icloud.com",
                                     objet: objet.isEmpty ? "(Aucun objet)" : objet,
                                     apercu: corps.replacingOccurrences(of: "\n\nEnvoyé de mon iPhone", with: ""),
                                     corps: corps, date: "Maintenant", boite: "Brouillons")
                    magasin.courriels.append(c)
                    dismiss()
                }
                Button("Annuler", role: .cancel) {}
            }
        }
        .preferredColorScheme(.dark)
    }
}
