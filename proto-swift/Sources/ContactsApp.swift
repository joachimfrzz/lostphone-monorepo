import SwiftUI

// ============================================================
// CONTACTS — app Apple iOS 26 (référence : robot com.apple.MobileAddressBook,
// captures 001 liste, 002 Listes, 003 fiche). Mesures prises sur l'écran 402 × 874 pt.
// Le contenu de Sarah vit dans DonneesContacts (remplaçable, décision 3).
// ============================================================

// MARK: - Contenu d'exemple (Sarah)

struct CtChamp: Hashable {
    let etiquette: String
    let valeur: String
}

struct CtContact: Identifiable, Hashable {
    let prenom: String
    var nom: String = ""
    var telephones: [CtChamp] = []
    var courriels: [CtChamp] = []

    var id: String { prenom + "|" + nom }
    var nomComplet: String { nom.isEmpty ? prenom : prenom + " " + nom }
    var cleTri: String { nom.isEmpty ? prenom : nom }
    var lettre: String {
        let premier = String(cleTri.prefix(1)).folding(options: .diacriticInsensitive, locale: .current).uppercased()
        return premier.first?.isLetter == true ? premier : "#"
    }
    var initiales: String {
        let mots = nomComplet.split(separator: " ").filter { $0.first?.isLetter == true }
        return mots.prefix(2).compactMap { $0.first }.map { String($0).uppercased() }.joined()
    }
}

struct CtListe: Identifiable {
    let nom: String
    let membres: [String]
    var id: String { nom }
}

struct CtSection: Identifiable {
    let lettre: String
    let items: [CtContact]
    var id: String { lettre }
}

enum DonneesContacts {
    // Numéros et adresses repris de FaceTime (DonneesFt) et Mail (AnnuaireMail).
    static let tous: [CtContact] = [
        CtContact(prenom: "Agence Bellecour",
                  courriels: [CtChamp(etiquette: "bureau", valeur: "bellecour@lcl.fr")]),
        CtContact(prenom: "Chloé",
                  telephones: [CtChamp(etiquette: "portable", valeur: "+33 6 24 81 05 77")],
                  courriels: [CtChamp(etiquette: "domicile", valeur: "chloe.bnv@gmail.com")]),
        CtContact(prenom: "Julie",
                  telephones: [CtChamp(etiquette: "portable", valeur: "+33 6 47 92 33 08")]),
        CtContact(prenom: "Marc ❤️",
                  telephones: [CtChamp(etiquette: "portable", valeur: "+33 7 49 12 53 08")],
                  courriels: [CtChamp(etiquette: "domicile", valeur: "marc.dlc.officier@gmail.com")]),
        CtContact(prenom: "Maman",
                  telephones: [CtChamp(etiquette: "portable", valeur: "+33 6 88 41 27 30")],
                  courriels: [CtChamp(etiquette: "domicile", valeur: "famille.levasseur@orange.fr")]),
        CtContact(prenom: "Marie kiné",
                  courriels: [CtChamp(etiquette: "bureau", valeur: "cabinet.kine.fantasques@gmail.com")]),
        CtContact(prenom: "Papa",
                  telephones: [CtChamp(etiquette: "portable", valeur: "+33 6 71 05 44 92")]),
        CtContact(prenom: "Camille", nom: "Roux",
                  courriels: [CtChamp(etiquette: "domicile", valeur: "camille.roux69@gmail.com")]),
        CtContact(prenom: "Thomas",
                  telephones: [CtChamp(etiquette: "portable", valeur: "+33 6 51 33 90 12")],
                  courriels: [CtChamp(etiquette: "domicile", valeur: "thomas.rey69@gmail.com")])
    ]

    /// Listes iCloud : les effectifs sont calculés à partir des membres.
    static let listes: [CtListe] = [
        CtListe(nom: "Famille", membres: ["Maman", "Papa"]),
        CtListe(nom: "Les filles 💛", membres: ["Chloé", "Julie"]),
        CtListe(nom: "Kiné", membres: ["Marie kiné"])
    ]

    static func contact(_ id: String) -> CtContact {
        tous.first { $0.id == id } ?? tous[0]
    }

    static func contacts(dansListe nom: String) -> [CtContact] {
        if let l = listes.first(where: { $0.nom == nom }) {
            return tous.filter { l.membres.contains($0.prenom) }
        }
        return tous
    }
}

// MARK: - Styles communs

private let ctGris = Color(hex: 0x8E8E93)
private let ctBleu = Color(hex: 0x0A84FF)
private let ctViolet = Color(hex: 0x8E72DD)
private let ctCarte = Color(hex: 0x1C1C1E)

struct CtBoutonRond: View {
    let symbole: String
    var verre: Bool = false
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Image(systemName: symbole)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(verre ? Color.black.opacity(0.28) : Color(hex: 0x1C1C1E), in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(verre ? 0.18 : 0.10), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct CtCapsule: View {
    let texte: String
    var verre: Bool = false
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Text(texte)
                .font(.system(size: 17))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(verre ? Color.black.opacity(0.28) : Color(hex: 0x1C1C1E), in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(verre ? 0.18 : 0.10), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct CtAvatar: View {
    let initiales: String
    var taille: CGFloat = 40
    var body: some View {
        Circle()
            .fill(LinearGradient(colors: [Color(hex: 0x57567F), Color(hex: 0x2B2150)],
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: taille, height: taille)
            .overlay(Text(initiales).font(.system(size: taille * 0.5, weight: .bold)).foregroundStyle(.white))
    }
}

// MARK: - Racine : pile de navigation

enum CtDest: Hashable {
    case liste(String)
    case fiche(String)
}

struct ContactsVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var chemin: [CtDest]

    init(chemin: [CtDest] = [.liste("Tous les contacts")]) {
        _chemin = State(initialValue: chemin)
    }

    private func retour() {
        if !chemin.isEmpty { chemin.removeLast() }
    }

    var body: some View {
        NavigationStack(path: $chemin) {
            ContactsListesVue(ouvrir: { chemin.append(.liste($0)) }, accueil: { dismiss() })
                .navigationDestination(for: CtDest.self) { dest in
                    switch dest {
                    case .liste(let nom):
                        ContactsListeVue(titre: nom,
                                         contacts: DonneesContacts.contacts(dansListe: nom),
                                         retour: { retour() },
                                         ouvrir: { chemin.append(.fiche($0.id)) },
                                         accueil: { dismiss() })
                    case .fiche(let id):
                        ContactFicheVue(contact: DonneesContacts.contact(id),
                                        retour: { retour() },
                                        accueil: { dismiss() })
                    }
                }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Liste alphabétique (réf 001)

struct ContactsListeVue: View {
    let titre: String
    let contacts: [CtContact]
    let retour: () -> Void
    let ouvrir: (CtContact) -> Void
    let accueil: () -> Void
    @State private var recherche = ""

    private var filtres: [CtContact] {
        recherche.isEmpty ? contacts : contacts.filter { $0.nomComplet.localizedCaseInsensitiveContains(recherche) }
    }
    private var sections: [CtSection] {
        let groupes = Dictionary(grouping: filtres) { $0.lettre }
        return groupes.keys.sorted().map { cle in
            let items = (groupes[cle] ?? []).sorted { $0.cleTri.localizedCaseInsensitiveCompare($1.cleTri) == .orderedAscending }
            return CtSection(lettre: cle, items: items)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack {
                    Text(titre == "Tous les contacts" ? "Contacts" : titre)
                        .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                    HStack { CtBoutonRond(symbole: "chevron.left", action: retour); Spacer() }
                }
                .padding(.horizontal, 16).frame(height: 44)
                corps
            }
            indexLateral
            barreBasse
            BarreHome { accueil() }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder private var corps: some View {
        if contacts.isEmpty {
            vide
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(sections) { section in
                        Text(section.lettre)
                            .font(.system(size: 17)).foregroundStyle(ctGris)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 18).frame(height: 38)
                        Rectangle().fill(Color.white.opacity(0.16)).frame(height: 0.7).padding(.leading, 18)
                        ForEach(Array(section.items.enumerated()), id: \.element.id) { index, c in
                            if index > 0 {
                                Rectangle().fill(Color.white.opacity(0.16)).frame(height: 0.7).padding(.leading, 68)
                            }
                            ligne(c)
                        }
                    }
                    Color.clear.frame(height: 140)
                }
                .padding(.top, 10)
            }
        }
    }

    private func ligne(_ c: CtContact) -> some View {
        Button { ouvrir(c) } label: {
            HStack(spacing: 10) {
                CtAvatar(initiales: c.initiales)
                nomAffiche(c)
                Spacer()
            }
            .padding(.leading, 18)
            .frame(height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func nomAffiche(_ c: CtContact) -> Text {
        if c.nom.isEmpty {
            return Text(c.prenom).font(.system(size: 18, weight: .semibold))
        }
        return Text(c.prenom + " ").font(.system(size: 18)) + Text(c.nom).font(.system(size: 18, weight: .semibold))
    }

    private var vide: some View {
        VStack(spacing: 6) {
            Spacer()
            Circle().fill(ctGris).frame(width: 48, height: 48)
                .overlay(Image(systemName: "person.fill").font(.system(size: 26)).foregroundStyle(.black.opacity(0.75)))
            Text("Aucun contact").font(.system(size: 22, weight: .bold)).foregroundStyle(.white).padding(.top, 10)
            Text("Les contacts ajoutés apparaîtront ici.").font(.system(size: 17)).foregroundStyle(ctGris)
            Text("Ajouter des contacts").font(.system(size: 17)).foregroundStyle(ctBleu).padding(.top, 12)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var indexLateral: some View {
        VStack(spacing: 0) {
            ForEach(Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ#"), id: \.self) { l in
                Text(String(l)).font(.system(size: 12, weight: .semibold)).foregroundStyle(ctBleu)
                    .frame(height: 13.75)
            }
        }
        .padding(.top, 266).padding(.trailing, 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .opacity(contacts.isEmpty ? 0 : 1)
    }

    private var barreBasse: some View {
        HStack(spacing: 13) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").font(.system(size: 19)).foregroundStyle(.white)
                TextField("", text: $recherche, prompt: Text("Recherche").foregroundStyle(ctGris))
                    .font(.system(size: 18)).foregroundStyle(.white)
                Image(systemName: "mic.fill").font(.system(size: 19)).foregroundStyle(.white)
            }
            .padding(.horizontal, 16).frame(height: 47)
            .background(ctCarte, in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
            Image(systemName: "plus").font(.system(size: 24, weight: .regular)).foregroundStyle(.white)
                .frame(width: 47, height: 47)
                .background(ctCarte, in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))
        }
        .padding(.leading, 28).padding(.trailing, 29)
        .padding(.bottom, 29)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Fiche contact (réf 003)

struct ContactFicheVue: View {
    let contact: CtContact
    let retour: () -> Void
    let accueil: () -> Void

    private var fond: LinearGradient {
        LinearGradient(stops: [
            .init(color: Color(hex: 0x8FA1A6), location: 0.0),
            .init(color: Color(hex: 0x6D6890), location: 0.30),
            .init(color: Color(hex: 0x3A2F63), location: 0.42),
            .init(color: Color(hex: 0x1A1240), location: 0.55),
            .init(color: Color(hex: 0x150C2B), location: 1.0)
        ], startPoint: .top, endPoint: .bottom)
    }
    private let carte = Color(hex: 0x2B2251).opacity(0.6)

    var body: some View {
        ZStack(alignment: .bottom) {
            fond.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    gros
                    nomEtActions
                    carteAffiche
                    carteChamps
                    carteNotes
                    carteActions
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 17)
            }
            VStack {
                HStack {
                    CtBoutonRond(symbole: "chevron.left", verre: true, action: retour)
                    Spacer()
                    CtCapsule(texte: "Modifier", verre: true)
                }
                .padding(.horizontal, 16)
                Spacer()
            }
            BarreHome { accueil() }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var gros: some View {
        Circle().fill(Color.white.opacity(0.10))
            .frame(width: 202, height: 202)
            .overlay(Circle().stroke(Color.white.opacity(0.28), lineWidth: 1.5))
            .overlay(Text(contact.initiales).font(.system(size: 84, weight: .medium)).foregroundStyle(.white))
            .padding(.top, 79)
    }

    private var nomEtActions: some View {
        VStack(spacing: 21) {
            Text(contact.nomComplet)
                .font(.system(size: 37, weight: .bold)).foregroundStyle(.white)
                .lineLimit(1).minimumScaleFactor(0.6)
                .padding(.top, 35)
            HStack(spacing: 24) {
                boutonAction("message.fill")
                boutonAction("phone.fill")
                boutonAction("video.fill")
                boutonAction("envelope.fill")
            }
        }
    }

    private func boutonAction(_ symbole: String) -> some View {
        Image(systemName: symbole).font(.system(size: 26)).foregroundStyle(.white)
            .frame(width: 64, height: 64)
            .background(Color.white.opacity(0.08), in: Circle())
            .overlay(Circle().stroke(ctViolet.opacity(0.45), lineWidth: 1))
    }

    private var carteAffiche: some View {
        HStack(spacing: 12) {
            CtAvatar(initiales: contact.initiales, taille: 40)
            Text("Photo et affiche du contact").font(.system(size: 16)).foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
        }
        .padding(.horizontal, 16).frame(height: 74)
        .background(carte, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.top, 14)
    }

    private var carteChamps: some View {
        let champs: [(CtChamp, String)] = contact.telephones.map { ($0, "phone.fill") }
            + contact.courriels.map { ($0, "envelope.fill") }
        return VStack(spacing: 0) {
            ForEach(Array(champs.enumerated()), id: \.offset) { index, paire in
                if index > 0 {
                    Rectangle().fill(Color.white.opacity(0.14)).frame(height: 0.7).padding(.leading, 15)
                }
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(paire.0.etiquette).font(.system(size: 15)).foregroundStyle(ctViolet)
                        Text(paire.0.valeur).font(.system(size: 18)).foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: paire.1).font(.system(size: 16)).foregroundStyle(ctViolet)
                }
                .padding(.horizontal, 15).padding(.vertical, 13)
            }
        }
        .background(carte, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.top, 12)
    }

    private var carteNotes: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Notes").font(.system(size: 15)).foregroundStyle(ctViolet)
            Text(" ").font(.system(size: 18))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 15).padding(.vertical, 13)
        .background(carte, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.top, 12)
    }

    // Partie basse non couverte par la référence robot (capture coupée) : à vérifier sur une vidéo.
    private var carteActions: some View {
        VStack(spacing: 0) {
            ligneAction("Envoyer un message", Color.white)
            ligneAction("Partager le contact", Color.white)
            ligneAction("Ajouter aux favoris", Color.white)
            ligneAction("Partager ma position", Color.white)
            ligneAction("Bloquer ce contact", Color(hex: 0xFF453A), dernier: true)
        }
        .background(carte, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.top, 12)
    }

    private func ligneAction(_ texte: String, _ couleur: Color, dernier: Bool = false) -> some View {
        VStack(spacing: 0) {
            Text(texte).font(.system(size: 18)).foregroundStyle(couleur)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15).frame(height: 52)
            if !dernier {
                Rectangle().fill(Color.white.opacity(0.14)).frame(height: 0.7).padding(.leading, 15)
            }
        }
    }
}

// MARK: - Listes (réf 002)

struct ContactsListesVue: View {
    let ouvrir: (String) -> Void
    let accueil: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 13) {
                    CtCapsule(texte: "Modifier")
                    Text("Listes").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                    Spacer()
                    CtCapsule(texte: "Ajouter une liste")
                }
                .padding(.horizontal, 16).frame(height: 44)

                ligneCarte(icone: "person.2.fill", texte: "Tous les contacts",
                           nombre: DonneesContacts.tous.count, titre: "Tous les contacts")
                    .background(ctCarte, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .padding(.horizontal, 16).padding(.top, 45)

                HStack {
                    Text("iCloud").font(.system(size: 18, weight: .semibold)).foregroundStyle(ctGris)
                    Spacer()
                    Image(systemName: "chevron.down").font(.system(size: 15, weight: .semibold)).foregroundStyle(ctGris)
                }
                .padding(.horizontal, 32).frame(height: 56).padding(.top, 10)

                VStack(spacing: 0) {
                    ligneCarte(icone: nil, texte: "iCloud (tous)", nombre: DonneesContacts.tous.count, titre: "Tous les contacts")
                    ForEach(DonneesContacts.listes) { l in
                        Rectangle().fill(Color.white.opacity(0.14)).frame(height: 0.7).padding(.leading, 32)
                        ligneCarte(icone: nil, texte: l.nom,
                                   nombre: DonneesContacts.contacts(dansListe: l.nom).count, titre: l.nom)
                    }
                }
                .background(ctCarte, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .padding(.horizontal, 16)
                Spacer()
            }
            BarreHome { accueil() }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func ligneCarte(icone: String?, texte: String, nombre: Int, titre: String) -> some View {
        Button { ouvrir(titre) } label: {
            HStack(spacing: 12) {
                if let icone = icone {
                    Image(systemName: icone).font(.system(size: 20)).foregroundStyle(.white)
                }
                Text(texte).font(.system(size: 18)).foregroundStyle(.white)
                Spacer()
                Text("\(nombre)").font(.system(size: 18)).foregroundStyle(ctGris)
                Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold)).foregroundStyle(ctGris)
            }
            .padding(.horizontal, 16).frame(height: 51)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
