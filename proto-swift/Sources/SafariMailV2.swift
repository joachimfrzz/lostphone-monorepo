import SwiftUI

// ============================================================
// S4 V2 — SAFARI / MAIL (D80, réf XML S4 du 29/08)
// Structure réelle mesurée : démarrage (Favoris + Liste de lecture,
// barre basse + groupes d'onglets), grille onglets « Personnel »,
// navigation privée ; Mail : Boîtes (arborescence Gmail réelle),
// Réception (MÀJ à l'instant, 1 message non envoyé), lecture
// (Résumer iOS 26), rédaction (À/Cc,Cci,De/Objet).
// Données Sarah (D59) — les données réelles restent hors du jeu.
// ============================================================

struct SafariMailV2Capture: View {
    let cle: String
    var body: some View {
        switch cle {
        case "sm2.safari.demarrage": SafariDemarrageV2Vue()
        case "sm2.safari.onglets": SafariOngletsV2Vue()
        case "sm2.safari.privee": SafariPriveeV2Vue()
        case "sm2.mail.boites": NavigationStack { MailBoitesV2Vue() }
        case "sm2.mail.reception": NavigationStack { MailReceptionV2Vue() }
        case "sm2.mail.lecture": NavigationStack { MailLectureV2Vue() }
        case "sm2.mail.redaction": MailRedactionV2Vue()
        default: SafariDemarrageV2Vue()
        }
    }
}

// MARK: - Safari : page de démarrage (réf 022/024/039)
struct SafariDemarrageV2Vue: View {
    let favoris: [(String, String, Color)] = [
        ("Google", "G", .white),
        ("leboncoin", "lb", .orange),
        ("Doctolib", "D", Color(red: 0.0, green: 0.6, blue: 0.85)),
        ("Ameli", "a", Color(red: 0.0, green: 0.4, blue: 0.7)),
        ("Marmiton", "M", .red),
        ("SNCF", "S", Color(red: 0.5, green: 0.0, blue: 0.6)),
        ("Vinted", "V", Color(red: 0.0, green: 0.7, blue: 0.7)),
        ("YouTube", "▶", .red)
    ]
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Favoris")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 24)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 18) {
                        ForEach(favoris, id: \.0) { f in
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.17))
                                    .frame(width: 60, height: 60)
                                    .overlay(Text(f.1).font(.system(size: 24, weight: .semibold)).foregroundStyle(f.2))
                                Text(f.0).font(.system(size: 12)).foregroundStyle(.primary).lineLimit(1)
                            }
                        }
                    }
                    HStack {
                        Text("Liste de lecture")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Text("Tout afficher").font(.system(size: 15)).foregroundStyle(.blue)
                    }
                    .padding(.top, 8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Exercices épaule après séance — conseils kiné")
                            .font(.system(size: 15, weight: .semibold)).lineLimit(1)
                        Text("sante-pratique.fr")
                            .font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.13), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 18)
            }
            // Barre d'adresse basse iOS 26
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "square.grid.2x2").foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundStyle(.secondary)
                        Text("Rechercher ou saisir une URL")
                            .font(.system(size: 16)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "plus").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Color(white: 0.15), in: RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(white: 0.28), lineWidth: 0.5))
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 10)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Safari : grille des onglets (réf 027 — groupe « Personnel », 4 onglets)
struct SafariOngletsV2Vue: View {
    let onglets: [(String, String)] = [
        ("Recette rôti de bœuf en cocotte — Marmiton", "marmiton.org"),
        ("Kinésithérapeute Lyon 2e — Doctolib", "doctolib.fr"),
        ("Commode vintage teck — leboncoin", "leboncoin.fr"),
        ("Horaires TER Lyon–Mâcon — SNCF", "sncf-connect.com")
    ]
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                    ForEach(onglets, id: \.0) { o in
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(white: 0.16))
                                    .frame(height: 205)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "safari").font(.system(size: 30)).foregroundStyle(.secondary.opacity(0.4))
                                            Text(o.1).font(.system(size: 11)).foregroundStyle(.secondary.opacity(0.6))
                                        }
                                    )
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .padding(6)
                                    .background(Color(white: 0.25), in: Circle())
                                    .padding(8)
                            }
                            Text(o.0)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .padding(.horizontal, 4).padding(.top, 6)
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.top, 20)
            }
            HStack {
                Text("Privée").font(.system(size: 14)).foregroundStyle(.secondary)
                Spacer()
                VStack(spacing: 2) {
                    Text("Personnel").font(.system(size: 15, weight: .semibold))
                    Text("4 onglets").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "plus").font(.system(size: 18)).foregroundStyle(.primary)
            }
            .padding(.horizontal, 26).padding(.vertical, 12)
            HStack {
                Spacer()
                Text("OK").font(.system(size: 17, weight: .semibold)).foregroundStyle(.blue)
            }
            .padding(.horizontal, 20).padding(.bottom, 8)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Safari : navigation privée (réf 014)
struct SafariPriveeV2Vue: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 14) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 40)).foregroundStyle(.secondary)
                Text("Navigation privée")
                    .font(.system(size: 22, weight: .bold))
                Text("Safari ne mémorisera pas les pages que vous consultez, votre historique de recherche ni vos données de remplissage automatique.")
                    .font(.system(size: 14)).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            Spacer()
            HStack {
                Image(systemName: "square.grid.2x2").foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundStyle(.secondary)
                    Text("Rechercher ou saisir une URL").font(.system(size: 16)).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "plus").foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color(white: 0.13), in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(white: 0.3), lineWidth: 0.5))
            .padding(.horizontal, 12).padding(.bottom, 10)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Mail : Boîtes (réf 073 — arborescence réelle, compteurs adaptés Sarah)
struct MailBoitesV2Vue: View {
    var body: some View {
        List {
            Section {
                LigneBoiteV2(icone: "tray.fill", nom: "Réception", compte: "1 208", couleur: .blue)
                LigneBoiteV2(icone: "star.fill", nom: "VIP", compte: "", couleur: .blue)
                LigneBoiteV2(icone: "paperplane", nom: "Boîte d'envoi", compte: "1", couleur: .blue)
            }
            Section(header: Text("GMAIL")) {
                LigneBoiteV2(icone: "tray", nom: "Réception", compte: "1 208", couleur: .blue)
                LigneBoiteV2(icone: "doc", nom: "Brouillons", compte: "12", couleur: .blue)
                LigneBoiteV2(icone: "paperplane", nom: "Envoyés", compte: "", couleur: .blue)
                LigneBoiteV2(icone: "xmark.bin", nom: "Indésirables", compte: "7", couleur: .blue)
                LigneBoiteV2(icone: "trash", nom: "Corbeille", compte: "", couleur: .blue)
                LigneBoiteV2(icone: "archivebox", nom: "Tous les e-mails", compte: "3 641", couleur: .blue)
                LigneBoiteV2(icone: "folder", nom: "[Gmail]", compte: "", couleur: .blue)
                LigneBoiteV2(icone: "folder", nom: "Important", compte: "84", couleur: .blue)
                LigneBoiteV2(icone: "folder", nom: "Suivis", compte: "", couleur: .blue)
            }
        }
        .navigationTitle("Boîtes")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Text("Modifier").foregroundStyle(.blue).fixedSize() } }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Text("MÀJ à l'instant").font(.system(size: 12)).foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "square.and.pencil").font(.system(size: 20)).foregroundStyle(.blue)
            }
            .padding(.horizontal, 18).padding(.vertical, 8)
            .background(.black.opacity(0.92))
        }
        .preferredColorScheme(.dark)
    }
}

struct LigneBoiteV2: View {
    let icone: String; let nom: String; let compte: String; let couleur: Color
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icone).font(.system(size: 18)).foregroundStyle(couleur).frame(width: 26)
            Text(nom).font(.system(size: 17))
            Spacer()
            if !compte.isEmpty { Text(compte).font(.system(size: 16)).foregroundStyle(.secondary) }
            Image(systemName: "chevron.forward").font(.system(size: 13, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if nom == "Réception" { NavV2.partage.pousser("sm2.mail.reception") }
            if nom == "Boîte d'envoi" { NavV2.partage.pousser("divers2.mail.envoi") }
        }
    }
}

// MARK: - Mail : Réception (réf 046/056 — structure liste, données Sarah)
struct MailReceptionV2Vue: View {
    let mails: [(String, String, String, String, Bool)] = [
        ("Agence Bellecour", "Confirmation de votre rendez-vous — lundi 17 août, 11 h 30", "Madame Levasseur, nous vous confirmons votre rendez-vous à l'agence avec M. Vasseur pour l'estimation…", "16/08/2026", true),
        ("Doctolib", "Rappel : votre rendez-vous de jeudi", "Votre séance avec Marie Fabre, kinésithérapeute, est confirmée jeudi à 17 h 30…", "12/08/2026", false),
        ("Vinted", "Votre article a trouvé preneur ! 🎉", "Bonne nouvelle : « Robe d'été fleurie taille 38 » vient d'être vendue. Préparez votre colis…", "09/08/2026", false),
        ("SNCF Connect", "Votre billet Lyon → Mâcon du 21 août", "Votre e-billet est disponible. Départ 09 h 12, voie F, voiture 4, place 56…", "07/08/2026", false),
        ("Ameli", "Votre relevé de remboursement est disponible", "Un nouveau relevé est disponible dans votre compte ameli. Montant remboursé : 23,80 €…", "04/08/2026", false),
        ("Marmiton — newsletter", "10 idées pour un rôti du dimanche réussi", "Cette semaine : le rôti de bœuf en cocotte comme chez mamie, et nos accompagnements…", "02/08/2026", false)
    ]
    var body: some View {
        List {
            ForEach(mails, id: \.1) { m in
                HStack(alignment: .top, spacing: 10) {
                    Circle().fill(m.4 ? Color.blue : Color.clear).frame(width: 9, height: 9).padding(.top, 6)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(m.0).font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Text(m.3).font(.system(size: 14)).foregroundStyle(.secondary)
                            Image(systemName: "chevron.forward").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
                        }
                        Text(m.1).font(.system(size: 15)).lineLimit(1)
                        Text(m.2).font(.system(size: 14)).foregroundStyle(.secondary).lineLimit(2)
                    }
                }
                .padding(.vertical, 2)
                .contentShape(Rectangle())
                .onTapGesture {
                    if m.0 == "Agence Bellecour" { NavV2.partage.pousser("sm2.mail.lecture") }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Réception")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 3) {
                    Image(systemName: "chevron.backward").font(.system(size: 17, weight: .semibold))
                    Text("Boîtes").fixedSize()
                }
                .foregroundStyle(.blue)
            }
            ToolbarItem(placement: .topBarTrailing) { Image(systemName: "ellipsis.circle").foregroundStyle(.blue) }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle").font(.system(size: 20)).foregroundStyle(.blue)
                Spacer()
                VStack(spacing: 1) {
                    Text("MÀJ à l'instant").font(.system(size: 12)).foregroundStyle(.secondary)
                    Text("1 message non envoyé").font(.system(size: 11)).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "square.and.pencil").font(.system(size: 20)).foregroundStyle(.blue)
                    .onTapGesture { NavV2.partage.pousser("sm2.mail.redaction") }
            }
            .padding(.horizontal, 18).padding(.vertical, 6)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Mail : lecture (réf 042 — en-tête De/À, Résumer, barre Archiver/Déplacer/Rédiger)
struct MailLectureV2Vue: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Circle().fill(Color(white: 0.3))
                        .frame(width: 44, height: 44)
                        .overlay(Text("AB").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Agence Bellecour").font(.system(size: 16, weight: .semibold))
                        Text("À : Sarah Levasseur").font(.system(size: 14)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("16/08/2026").font(.system(size: 13)).foregroundStyle(.secondary)
                }
                Text("Confirmation de votre rendez-vous — lundi 17 août, 11 h 30")
                    .font(.system(size: 20, weight: .semibold))
                HStack(spacing: 6) {
                    Image(systemName: "text.append").font(.system(size: 13))
                    Text("Résumer").font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Color(white: 0.15), in: Capsule())
                Text("""
Madame Levasseur,

Nous vous confirmons votre rendez-vous à l'agence lundi 17 août à 11 h 30 avec M. Vasseur, pour l'estimation de l'appartement.

Merci d'apporter les documents évoqués au téléphone (titre de propriété, dernières charges).

Cordialement,
Agence Bellecour — Lyon 2e
04 78 42 11 30
""")
                    .font(.system(size: 16))
                    .lineSpacing(3)
            }
            .padding(.horizontal, 18).padding(.top, 12)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 3) {
                    Image(systemName: "chevron.backward").font(.system(size: 17, weight: .semibold))
                    Text("Réception").fixedSize()
                }
                .foregroundStyle(.blue)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 18) {
                    Image(systemName: "chevron.up").foregroundStyle(.blue)
                    Image(systemName: "chevron.down").foregroundStyle(.blue)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Image(systemName: "archivebox").font(.system(size: 20)).foregroundStyle(.blue)
                Spacer()
                Image(systemName: "folder").font(.system(size: 20)).foregroundStyle(.blue)
                Spacer()
                Image(systemName: "arrowshape.turn.up.left").font(.system(size: 20)).foregroundStyle(.blue)
                Spacer()
                Image(systemName: "square.and.pencil").font(.system(size: 20)).foregroundStyle(.blue)
            }
            .padding(.horizontal, 26).padding(.vertical, 8)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Mail : rédaction (réf 074 — Annuler/Envoyer, À, Cc/Cci De, Objet)
struct MailRedactionV2Vue: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Annuler").font(.system(size: 17)).foregroundStyle(.blue).onTapGesture { NavV2.partage.retour() }
                Spacer()
                Text("Nouveau message").font(.system(size: 17, weight: .semibold))
                Spacer()
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            VStack(spacing: 0) {
                HStack {
                    Text("À :").foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "plus.circle").foregroundStyle(.secondary)
                }
                .font(.system(size: 16))
                .padding(.horizontal, 16).padding(.vertical, 11)
                Divider().padding(.leading, 16)
                HStack {
                    Text("Cc/Cci, De : sarah.levasseur69@gmail.com").foregroundStyle(.secondary)
                    Spacer()
                }
                .font(.system(size: 16))
                .padding(.horizontal, 16).padding(.vertical, 11)
                Divider().padding(.leading, 16)
                HStack {
                    Text("Objet :").foregroundStyle(.secondary)
                    Spacer()
                }
                .font(.system(size: 16))
                .padding(.horizontal, 16).padding(.vertical, 11)
                Divider().padding(.leading, 16)
            }
            Spacer()
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
