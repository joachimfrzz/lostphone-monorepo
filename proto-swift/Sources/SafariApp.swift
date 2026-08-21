// Safari — construit contre la vidéo de référence du 20/08 (96 écrans, iOS 26)
// D51-2 : barre d'adresse fonctionnelle, onglets, HISTORIQUE par jours (le composant d'enquête),
// signets, pages rendues. R3 : l'historique du 16 août au soir = la capture P68 rejouée en vrai
// (« arnaque sentimentale officier marine », service-public.fr encore ouvert dans les onglets).
import SwiftUI

// ============================================================ DONNÉES (remplaçables — D59)
struct EntreeHistorique: Identifiable {
    let id = UUID()
    var titre: String
    var url: String
    var heure: String
    var section: String
}

struct OngletSafari: Identifiable {
    let id = UUID()
    var titre: String
    var url: String
    var page: String     // identifiant de rendu
}

enum DonneesSafari {
    static let historique: [EntreeHistorique] = [
        // — Dimanche soir (16 août) : la nuit où elle a douté (= P68)
        EntreeHistorique(titre: "position navire MV Beaumont — VesselFinder", url: "vesselfinder.com", heure: "23:31", section: "Dimanche soir"),
        EntreeHistorique(titre: "compagnie maritime agent OKAFOR — Recherche Google", url: "google.com", heure: "23:26", section: "Dimanche soir"),
        EntreeHistorique(titre: "Arnaque aux sentiments : reconnaître les signes — France Victimes", url: "france-victimes.fr", heure: "23:17", section: "Dimanche soir"),
        EntreeHistorique(titre: "Escroquerie sentimentale (romance scam) : que faire ?", url: "service-public.fr", heure: "23:14", section: "Dimanche soir"),
        EntreeHistorique(titre: "arnaque sentimentale officier marine — Recherche Google", url: "google.com", heure: "23:12", section: "Dimanche soir"),
        // — Dimanche après-midi : l'espoir intact
        EntreeHistorique(titre: "Chez Fonfon — Restaurant Marseille Vieux-Port", url: "chez-fonfon.com", heure: "16:40", section: "Dimanche après-midi"),
        EntreeHistorique(titre: "hôtel vieux port marseille 28 août — Recherche Google", url: "google.com", heure: "16:32", section: "Dimanche après-midi"),
        // — La semaine
        EntreeHistorique(titre: "horaires LCL agence Bellecour — Recherche Google", url: "google.com", heure: "12 août", section: "Semaine dernière"),
        EntreeHistorique(titre: "TGV Lyon Marseille vendredi 28 août — SNCF Connect", url: "sncf-connect.com", heure: "10 août", section: "Semaine dernière"),
        EntreeHistorique(titre: "augmenter plafond virement LCL — Recherche Google", url: "google.com", heure: "10 août", section: "Semaine dernière"),
        EntreeHistorique(titre: "recette gratin courgettes mamie — Recherche Google", url: "google.com", heure: "7 août", section: "Semaine dernière"),
        // — Mars : le début
        EntreeHistorique(titre: "meetic avis site sérieux ? — Recherche Google", url: "google.com", heure: "8 mars", section: "Mars"),
        EntreeHistorique(titre: "que répondre premier message site de rencontre", url: "google.com", heure: "13 mars", section: "Mars"),
    ]
    static let sectionsHistorique = ["Dimanche soir", "Dimanche après-midi", "Semaine dernière", "Mars"]

    static let onglets: [OngletSafari] = [
        OngletSafari(titre: "Escroquerie sentimentale (romance scam) : que faire ?", url: "service-public.fr", page: "servicepublic"),
        OngletSafari(titre: "arnaque sentimentale officier marine — Recherche", url: "google.com", page: "resultats"),
        OngletSafari(titre: "Chez Fonfon — Marseille", url: "chez-fonfon.com", page: "fonfon"),
    ]
}

// ============================================================ APP
struct SafariVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pageActive = "servicepublic"
    @State private var urlActive = "service-public.fr"
    @State private var saisie = ""
    @State private var saisieActive = false
    @State private var ongletsVisibles = false
    @State private var historiqueVisible = false
    @State private var partageAlerte = false
    @FocusState private var champFocalise: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0x1C1C1E).ignoresSafeArea()

            // Page rendue
            ScrollView {
                PageRendueVue(page: pageActive)
                    .padding(.bottom, 110)
            }

            // Suggestions de saisie
            if saisieActive {
                VStack(spacing: 0) {
                    Spacer()
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Suggestions Google").font(.system(size: 12)).foregroundStyle(.secondary)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                        ForEach(suggestions, id: \.self) { s in
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundStyle(.secondary)
                                Text(s).font(.system(size: 15)).foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .contentShape(Rectangle())
                            .onTapGesture { naviguer(s) }
                        }
                    }
                    .background(.ultraThinMaterial)
                }
                .padding(.bottom, 108)
            }

            // Barre d'adresse basse (iOS)
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "textformat.size").font(.system(size: 15)).foregroundStyle(.white.opacity(0.85))
                    if saisieActive {
                        TextField("Rechercher ou saisir une adresse", text: $saisie)
                            .focused($champFocalise)
                            .font(.system(size: 15)).foregroundStyle(.white)
                            .autocapitalization(.none)
                            .onSubmit { naviguer(saisie) }
                    } else {
                        Text(urlActive).font(.system(size: 15)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture { saisieActive = true; champFocalise = true; saisie = "" }
                    }
                    Image(systemName: "arrow.clockwise").font(.system(size: 14)).foregroundStyle(.white.opacity(0.85))
                }
                .padding(.horizontal, 14).frame(height: 44)
                .background(Color(hex: 0x3A3A3C), in: RoundedRectangle(cornerRadius: 13))
                .padding(.horizontal, 12)

                HStack {
                    Image(systemName: "chevron.left").font(.system(size: 19))
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 19)).opacity(0.35)
                    Spacer()
                    Image(systemName: "square.and.arrow.up").font(.system(size: 18))
                        .onTapGesture { partageAlerte = true }
                    Spacer()
                    Image(systemName: "book").font(.system(size: 18))
                        .onTapGesture { historiqueVisible = true }
                    Spacer()
                    Image(systemName: "square.on.square").font(.system(size: 18))
                        .onTapGesture { ongletsVisibles = true }
                }
                .foregroundStyle(Color(hex: 0x0A84FF))
                .padding(.horizontal, 28).padding(.bottom, 4)
            }
            .padding(.top, 8)
            .background(.ultraThinMaterial)

            BarreHome { dismiss() }
        }
        .onAppear {
            // P3 : si une autre app (Plans, Mail…) a demandé une page, on l'ouvre
            if let (p, u) = Routeur.partage.consommerPage() { pageActive = p; urlActive = u }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $ongletsVisibles) {
            OngletsVue { o in
                pageActive = o.page
                urlActive = o.url
                ongletsVisibles = false
            }
        }
        .sheet(isPresented: $historiqueVisible) {
            HistoriqueSafariVue { e in
                naviguer(e.titre)
                historiqueVisible = false
            }
        }
        .sheet(isPresented: $partageAlerte) { FeuillePartage(element: urlActive) }
    }

    private var suggestions: [String] {
        let base = ["arnaque sentimentale officier marine", "position navire MV Beaumont",
                    "horaires LCL agence Bellecour", "hôtel vieux port marseille"]
        guard !saisie.isEmpty else { return base }
        return base.filter { $0.localizedCaseInsensitiveContains(saisie) } + [saisie]
    }

    private func naviguer(_ requete: String) {
        saisieActive = false
        champFocalise = false
        let r = requete.lowercased()
        if r.contains("arnaque") || r.contains("officier") {
            pageActive = "resultats"; urlActive = "google.com"
        } else if r.contains("navire") || r.contains("beaumont") || r.contains("vessel") {
            pageActive = "vessel"; urlActive = "vesselfinder.com"
        } else if r.contains("fonfon") || r.contains("marseille") {
            pageActive = "fonfon"; urlActive = "chez-fonfon.com"
        } else if r.contains("escroquerie") || r.contains("service-public") || r.contains("victimes") {
            pageActive = "servicepublic"; urlActive = "service-public.fr"
        } else if r.contains("okafor") || r.contains("compagnie") {
            pageActive = "resultats"; urlActive = "google.com"
        } else {
            // Anneau 3 : le réseau du téléphone retrouvé est instable — état d'erreur Safari réel
            pageActive = "erreur"; urlActive = requete
        }
        saisie = ""
    }
}

// ============================================================ PAGES RENDUES
struct PageRendueVue: View {
    let page: String
    var body: some View {
        switch page {
        case "resultats": ResultatsGoogleVue()
        case "vessel": VesselVue()
        case "fonfon": FonfonVue()
        case "erreur": ErreurSafariVue()
        case let p where p.hasPrefix("site:"): SiteGeneriqueVue(nom: String(p.dropFirst(5)))
        default: ServicePublicVue()
        }
    }
}

// Gabarit de site local (P4) : la page « Site web » de n'importe quel lieu de Plans.
// Données remplaçables (D59) — le rendu est générique, le nom vient du lieu.
struct SiteGeneriqueVue: View {
    let nom: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                LinearGradient(colors: [Color(hex: 0x2C3E50), Color(hex: 0x1A252F)], startPoint: .top, endPoint: .bottom)
                VStack(spacing: 8) {
                    Image(systemName: "storefront.fill").font(.system(size: 34)).foregroundStyle(.white.opacity(0.9))
                    Text(nom).font(.system(size: 24, weight: .bold)).foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text("Lyon 1er — depuis 1987").font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 24)
            }
            .frame(height: 190)

            VStack(alignment: .leading, spacing: 14) {
                Text("Bienvenue").font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
                Text("Retrouvez-nous en plein cœur de Lyon. Notre équipe vous accueille toute la semaine et vous conseille avec plaisir.")
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.85)).lineSpacing(3)

                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "clock.fill").foregroundStyle(.secondary).frame(width: 26)
                        Text("Lun – Sam · 8h00 – 19h30").font(.system(size: 14.5)).foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(12)
                    Divider().overlay(Color(hex: 0x3A3A3C))
                    HStack {
                        Image(systemName: "mappin.circle.fill").foregroundStyle(.secondary).frame(width: 26)
                        Text("Quartier des Capucins, 69001 Lyon").font(.system(size: 14.5)).foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(12)
                }
                .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 12))

                Text("© \(nom) — mentions légales · plan du site")
                    .font(.system(size: 11.5)).foregroundStyle(.secondary)
                    .padding(.top, 6)
            }
            .padding(16)
        }
    }
}

// service-public.fr — l'onglet resté ouvert (cohérent avec P68)
struct ServicePublicVue: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Rectangle().fill(Color(hex: 0x000091)).frame(width: 44, height: 30)
                    .overlay(Text("RF").font(.system(size: 13, weight: .bold)).foregroundStyle(.white))
                Text("service-public.fr").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                Spacer()
            }
            .padding(.top, 14)
            Text("Escroquerie sentimentale (romance scam) : que faire ?")
                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
            Text("Vérifié le 12 février 2026 — Direction de l'information légale et administrative")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Text("L'escroquerie sentimentale consiste à gagner la confiance et l'affection d'une personne pour lui soutirer de l'argent. L'escroc se fait souvent passer pour un militaire, un officier de marine ou un ingénieur travaillant à l'étranger.")
                .font(.system(size: 15.5)).foregroundStyle(.white.opacity(0.92)).lineSpacing(3)
            VStack(alignment: .leading, spacing: 8) {
                Text("Les signes qui doivent alerter").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                PuceTexte("Il ne peut jamais vous rencontrer ni faire d'appel vidéo net.")
                PuceTexte("Les demandes d'argent passent par des mandats (Western Union) ou un « agent ».")
                PuceTexte("Les sommes augmentent : frais de douane, caution, frais de change…")
                PuceTexte("Il vous demande de garder la relation secrète.")
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Que faire ?").font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                PuceTexte("Cessez immédiatement tout envoi d'argent.")
                PuceTexte("Conservez toutes les preuves : messages, reçus de transfert.")
                PuceTexte("Déposez plainte et signalez sur THESEE (service-public.fr).")
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
    }
    struct PuceTexte: View {
        let t: String
        init(_ t: String) { self.t = t }
        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                Text("•").foregroundStyle(Color(hex: 0x000091))
                Text(t).font(.system(size: 15)).foregroundStyle(.white.opacity(0.9))
            }
        }
    }
}

// Résultats Google — la même recherche que la capture P68
struct ResultatsGoogleVue: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Text("Google").font(.system(size: 22, weight: .semibold)).foregroundStyle(.white)
                HStack {
                    Text("arnaque sentimentale officier marine").font(.system(size: 13)).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "xmark").font(.system(size: 11)).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10).frame(height: 34)
                .background(Color(hex: 0x303134), in: Capsule())
            }
            .padding(.top, 14)
            Text("Environ 148 000 résultats").font(.system(size: 12)).foregroundStyle(.secondary)
            ResultatGoogle(site: "service-public.fr",
                           titre: "Escroquerie sentimentale (romance scam) : que faire ?",
                           extrait: "L'escroc se fait passer pour un militaire, un officier de marine ou un ingénieur à l'étranger. Il demande de l'argent pour des frais de douane, une caution…")
            ResultatGoogle(site: "france-victimes.fr",
                           titre: "Arnaque aux sentiments : reconnaître les signes",
                           extrait: "Il ne peut jamais vous rencontrer ni faire de visio nette. Les demandes d'argent passent par Western Union ou un « agent »…")
            ResultatGoogle(site: "forum.doctissimo.fr",
                           titre: "Mon histoire : il disait être officier en mer depuis 8 mois",
                           extrait: "Il m'appelait sa reine. J'ai envoyé 6 000 € en tout. Le jour où il devait débarquer à Marseille, plus aucune nouvelle…")
            ResultatGoogle(site: "cybermalveillance.gouv.fr",
                           titre: "Fraude à la romance : comment réagir et signaler",
                           extrait: "Cessez tout contact et tout envoi d'argent. Conservez les preuves : messages, reçus de transfert…")
        }
        .padding(.horizontal, 16)
    }
}

struct ResultatGoogle: View {
    let site: String
    let titre: String
    let extrait: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(site).font(.system(size: 12)).foregroundStyle(.secondary)
            Text(titre).font(.system(size: 17, weight: .semibold)).foregroundStyle(Color(hex: 0x6CB2FF))
            Text(extrait).font(.system(size: 13.5)).foregroundStyle(.white.opacity(0.8)).lineSpacing(2)
        }
    }
}

// VesselFinder — la recherche du navire (introuvable, évidemment)
struct VesselVue: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("VesselFinder").font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
                Spacer()
            }
            .padding(.top, 14)
            RoundedRectangle(cornerRadius: 12).fill(Color(hex: 0x14202B))
                .frame(height: 220)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "questionmark.circle").font(.system(size: 34)).foregroundStyle(.secondary)
                        Text("« MV Beaumont »").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        Text("Aucun navire trouvé sous ce nom").font(.system(size: 13.5)).foregroundStyle(.secondary)
                    }
                )
            Text("Vérifiez l'orthographe ou essayez avec le numéro IMO du navire. Les navires marchands en activité sont tous répertoriés.")
                .font(.system(size: 13.5)).foregroundStyle(.secondary)
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
    }
}

// Chez Fonfon — l'onglet de l'espoir
struct FonfonVue: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [Color(hex: 0x2E4A6B), Color(hex: 0x14202B)], startPoint: .top, endPoint: .bottom))
                .frame(height: 170)
                .overlay(
                    VStack(spacing: 4) {
                        Text("Chez Fonfon").font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                        Text("Bouillabaisse depuis 1952 — Vallon des Auffes, Marseille")
                            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.85))
                    }
                )
                .padding(.top, 14)
            Text("Réserver une table").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(Color(hex: 0x0A84FF), in: RoundedRectangle(cornerRadius: 12))
            Text("Le restaurant emblématique du Vallon des Auffes vous accueille tous les jours, midi et soir. Notre bouillabaisse traditionnelle est servie en deux services, comme le veut la charte.")
                .font(.system(size: 15)).foregroundStyle(.white.opacity(0.9)).lineSpacing(3)
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
    }
}

// État d'erreur réseau (réel iOS)
struct ErreurSafariVue: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 120)
            Text("Safari ne parvient pas à ouvrir la page")
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("Le serveur est introuvable. Vérifiez la connexion Internet et réessayez.")
                .font(.system(size: 14)).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

// ============================================================ ONGLETS
struct OngletsVue: View {
    @Environment(\.dismiss) private var dismiss
    let ouvrir: (OngletSafari) -> Void
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 14) {
                    ForEach(DonneesSafari.onglets) { o in
                        Button { ouvrir(o) } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(o.titre).font(.system(size: 11, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                                    Spacer()
                                    Image(systemName: "xmark").font(.system(size: 9)).foregroundStyle(.secondary)
                                }
                                .padding(8)
                                .background(Color(hex: 0x3A3A3C))
                                RoundedRectangle(cornerRadius: 0).fill(Color(hex: 0x1C1C1E))
                                    .frame(height: 130)
                                    .overlay(
                                        VStack(spacing: 5) {
                                            Image(systemName: "globe").font(.system(size: 24)).foregroundStyle(.secondary)
                                            Text(o.url).font(.system(size: 11)).foregroundStyle(.secondary)
                                        }
                                    )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(hex: 0x1C1C1E))
            .navigationTitle("3 onglets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "plus").foregroundStyle(Color(hex: 0x0A84FF))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ HISTORIQUE (le composant d'enquête)
struct HistoriqueSafariVue: View {
    @Environment(\.dismiss) private var dismiss
    var ouvrir: (EntreeHistorique) -> Void = { _ in }
    @State private var recherche = ""

    private func entrees(_ section: String) -> [EntreeHistorique] {
        var l = DonneesSafari.historique.filter { $0.section == section }
        if !recherche.isEmpty {
            l = l.filter { $0.titre.localizedCaseInsensitiveContains(recherche) }
        }
        return l
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(DonneesSafari.sectionsHistorique, id: \.self) { section in
                    let items = entrees(section)
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { e in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(e.titre).font(.system(size: 15)).foregroundStyle(.white).lineLimit(2)
                                    Text("\(e.url) · \(e.heure)").font(.system(size: 12.5)).foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture { ouvrir(e) }
                                .listRowBackground(Color(hex: 0x2C2C2E))
                            }
                        } header: {
                            Text(section).font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary).textCase(nil)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0x1C1C1E))
            .searchable(text: $recherche, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher l'historique")
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Effacer").foregroundStyle(Color(hex: 0xFF453A)).fixedSize()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }.foregroundStyle(Color(hex: 0x0A84FF))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
