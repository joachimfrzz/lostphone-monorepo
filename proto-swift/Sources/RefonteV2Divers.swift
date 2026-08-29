import SwiftUI

// ============================================================
// REFONTE V2 — LOT TRANSVERSAL (D80, nuit du 29/08)
// Les écrans-signatures identifiés MANQUANTS par les fiches S3-S6 :
// Messages (Suppressions récentes, Indésirables), Contacts (Listes),
// Mail (Boîte d'envoi), Dictaphone (Suppressions récentes).
// Données Sarah remplaçables (D59).
// ============================================================

struct DiversV2Capture: View {
    let cle: String
    var body: some View {
        switch cle {
        case "divers2.msg.suppressions": NavigationStack { MsgSuppressionsV2Vue() }
        case "divers2.msg.indesirables": NavigationStack { MsgIndesirablesV2Vue() }
        case "divers2.contacts.listes": NavigationStack { ContactsListesV2Vue() }
        case "divers2.mail.envoi": NavigationStack { MailBoiteEnvoiV2Vue() }
        case "divers2.dicta.suppressions": NavigationStack { DictaSuppressionsV2Vue() }
        default: MsgSuppressionsV2Vue()
        }
    }
}

// MARK: - Messages > Suppressions récentes (réf S3 — LA mécanique de l'or effacé D58/P66-68)
struct MsgSuppressionsV2Vue: View {
    var body: some View {
        List {
            Section(footer: Text("Les messages sont conservés 30 jours dans Suppressions récentes, puis supprimés définitivement.")) {
                LigneConvSupprimee(nom: "SecuriBQE", extrait: "Votre compte a été suspendu. Vérifiez vos informations : lcl-securite-clients.com", jours: "27 j")
                LigneConvSupprimee(nom: "+33 7 68 44 21 09", extrait: "Bonjour, c'est bien vous qui vendez la commode ? Je peux passer ce soir", jours: "12 j")
            }
        }
        .navigationTitle("Suppressions récentes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Text("Filtres").foregroundStyle(.blue) }
            ToolbarItem(placement: .topBarTrailing) { Text("Modifier").foregroundStyle(.blue) }
        }
        .preferredColorScheme(.dark)
    }
}

struct LigneConvSupprimee: View {
    let nom: String; let extrait: String; let jours: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(Color(white: 0.35))
                .frame(width: 45, height: 45)
                .overlay(Image(systemName: "person.fill").font(.system(size: 22)).foregroundStyle(Color(white: 0.65)))
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(nom).font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Text(jours).font(.system(size: 14)).foregroundStyle(.secondary)
                }
                Text(extrait).font(.system(size: 14)).foregroundStyle(.secondary).lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Messages > Indésirables (réf S3 — le canal du phishing)
struct MsgIndesirablesV2Vue: View {
    var body: some View {
        List {
            LigneConvSupprimee(nom: "COLIS-INFO", extrait: "Votre colis est en attente. Frais de douane : 1,99 € → suivi-colis-fr.net", jours: "mar.")
            LigneConvSupprimee(nom: "+229 91 04 42 18", extrait: "Félicitations !! Vous avez été tiré au sort pour recevoir un iPhone 17", jours: "12/08")
        }
        .navigationTitle("Indésirables")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Contacts > Listes (réf S3 — écran absent du clone)
struct ContactsListesV2Vue: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Tous les contacts").font(.system(size: 17))
                    Spacer()
                    Text("47").foregroundStyle(.secondary)
                    Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
                }
            }
            Section(header: Text("iCLOUD")) {
                HStack { Text("Famille"); Spacer(); Text("6").foregroundStyle(.secondary); Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5)) }
                HStack { Text("Kiné — patients"); Spacer(); Text("14").foregroundStyle(.secondary); Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5)) }
                HStack { Text("Les filles 💛"); Spacer(); Text("3").foregroundStyle(.secondary); Image(systemName: "chevron.forward").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5)) }
            }
        }
        .navigationTitle("Listes")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Text("Ajouter une liste").font(.system(size: 15)).foregroundStyle(.blue) } }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Mail > Boîte d'envoi (réf S4 — le mail jamais parti, or narratif)
struct MailBoiteEnvoiV2Vue: View {
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("À : Chloé Martin").font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Text("17/08").font(.system(size: 14)).foregroundStyle(.secondary)
                }
                Text("(aucun objet)").font(.system(size: 15)).foregroundStyle(.secondary)
                Text("Chloé. Tu avais raison depuis le début. Je crois que je").font(.system(size: 14)).foregroundStyle(.secondary).lineLimit(2)
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill").font(.system(size: 12)).foregroundStyle(.orange)
                    Text("Non envoyé — en attente de connexion").font(.system(size: 12)).foregroundStyle(.orange)
                }
            }
            .padding(.vertical, 3)
        }
        .navigationTitle("Boîte d'envoi")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Dictaphone > Suppressions récentes (réf S6 — 3e corbeille du motif transversal)
struct DictaSuppressionsV2Vue: View {
    var body: some View {
        List {
            Section(footer: Text("Les enregistrements sont conservés 30 jours, puis supprimés définitivement.")) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Répétition — ce que je dois dire à Marc").font(.system(size: 16))
                    HStack {
                        Text("14 août 2026").font(.system(size: 13)).foregroundStyle(.secondary)
                        Spacer()
                        Text("1:47").font(.system(size: 13)).foregroundStyle(.secondary)
                        Text("26 j").font(.system(size: 13)).foregroundStyle(.orange)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Suppressions récentes")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}
