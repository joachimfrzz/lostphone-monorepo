import SwiftUI

// ============================================================
// S3 V2 — TÉLÉPHONE / MESSAGES (D80, réf XML S3 du 29/08)
// Détails iOS 26 nouveaux : « iMessage Chiffré », « Message texte • RCS »,
// « Signaler comme indésirable », messagerie vocale à l'idiome exact.
// Données Sarah (D59).
// ============================================================

struct TcmV2Capture: View {
    let cle: String
    var body: some View {
        switch cle {
        case "tcm2.messagerie": NavigationStack { MessagerieV2Vue() }
        case "tcm2.msg.liste": NavigationStack { MessagesListeV2Vue() }
        case "tcm2.msg.conv": NavigationStack { MessagesConvV2Vue() }
        default: MessagerieV2Vue()
        }
    }
}

// MARK: - Messagerie vocale v2 (réf S3 : Modifier/Annonce, lignes nom/date/durée/ⓘ)
struct MessagerieV2Vue: View {
    let messages: [(String, String, String, String)] = [
        ("Agence Bellecour", "16/08/2026", "00:25", "Confirmation de votre rendez-vous de lundi à 11 h 30…"),
        ("Maman", "12/08/2026", "00:19", "C'est maman, rappelle-moi pour le rôti de dimanche…"),
        ("Chloé", "29/07/2026", "00:12", "Sarah décroche s'il te plaît, faut qu'on parle de…"),
        ("N° masqué", "10/07/2026", "01:08", ""),
        ("Marie kiné", "25/05/2026", "00:35", "Bonjour Sarah, c'est le cabinet, votre séance de jeudi…")
    ]
    var body: some View {
        List {
            ForEach(messages, id: \.1) { m in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(m.0).font(.system(size: 17, weight: .semibold))
                        Spacer()
                        Text(m.1).font(.system(size: 15)).foregroundStyle(.secondary)
                        Image(systemName: "info.circle").font(.system(size: 18)).foregroundStyle(.blue)
                    }
                    HStack {
                        if !m.3.isEmpty {
                            Text(m.3).font(.system(size: 14)).foregroundStyle(.secondary).lineLimit(1)
                        } else {
                            Text("Transcription indisponible").font(.system(size: 14)).foregroundStyle(.secondary.opacity(0.6)).italic()
                        }
                        Spacer()
                        Text(m.2).font(.system(size: 14)).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Messagerie")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Text("Modifier").foregroundStyle(.blue).fixedSize() }
            ToolbarItem(placement: .topBarTrailing) { Text("Annonce").foregroundStyle(.blue) }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Messages liste v2 (réf S3 : épinglés, aperçus, RCS)
struct MessagesListeV2Vue: View {
    let convs: [(String, String, String, Bool)] = [
        ("Maman", "Tu as pensé au rôti pour dimanche ? 🍖", "19:02", true),
        ("SecuriBQE", "⚠️ Votre carte sera suspendue. Confirmez vos infos : lcl-securite-clients.com", "16:44", false),
        ("Chloé", "Je passe te prendre à 9h45 lundi. On y va ENSEMBLE.", "14:31", true),
        ("Thomas", "Vocal de 0:42", "hier", false),
        ("Marie kiné", "Votre séance de jeudi 17 h 30 est confirmée", "jeu.", false),
        ("38200", "Votre code de vérification est 448202. Ne le partagez jamais.", "12/08", false)
    ]
    var body: some View {
        List {
            ForEach(convs, id: \.0) { c in
                HStack(alignment: .top, spacing: 12) {
                    Circle().fill(Color(white: 0.35))
                        .frame(width: 45, height: 45)
                        .overlay(Image(systemName: "person.fill").font(.system(size: 22)).foregroundStyle(Color(white: 0.65)))
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(c.0).font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Text(c.2).font(.system(size: 14)).foregroundStyle(.secondary)
                            Image(systemName: "chevron.forward").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary.opacity(0.5))
                        }
                        HStack(spacing: 5) {
                            if c.3 { Image(systemName: "pin.fill").font(.system(size: 11)).foregroundStyle(.secondary) }
                            Text(c.1).font(.system(size: 14)).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Messages")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Text("Modifier").foregroundStyle(.blue).fixedSize() }
            ToolbarItem(placement: .topBarTrailing) { Image(systemName: "square.and.pencil").foregroundStyle(.blue) }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Messages conversation v2 (réf S3 : « iMessage  Chiffré », « Distribué », RCS)
struct MessagesConvV2Vue: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 8) {
                    Text("ven. 14 août à 19:02")
                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                        .padding(.top, 14)
                    Text("iMessage  Chiffré")
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                    BulleMsgV2(texte: "Coucou ma chérie, tu viens toujours dimanche ?", envoye: false)
                    BulleMsgV2(texte: "Oui maman, promis 🙂", envoye: true)
                    BulleMsgV2(texte: "Tu as pensé au rôti pour dimanche ? 🍖", envoye: false)
                    BulleMsgV2(texte: "Je m'en occupe samedi !", envoye: true)
                    Text("Distribué")
                        .font(.system(size: 11, weight: .medium)).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 18)
                }
            }
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .medium)).foregroundStyle(.secondary)
                    .frame(width: 34, height: 34)
                    .background(Color(white: 0.2), in: Circle())
                HStack {
                    Text("Message texte • RCS").font(.system(size: 16)).foregroundStyle(.secondary.opacity(0.7))
                    Spacer()
                    Image(systemName: "mic.fill").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Color(white: 0.14), in: Capsule())
                .overlay(Capsule().stroke(Color(white: 0.3), lineWidth: 0.5))
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
        }
        .navigationTitle("Maman")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct BulleMsgV2: View {
    let texte: String; let envoye: Bool
    var body: some View {
        HStack {
            if envoye { Spacer(minLength: 60) }
            Text(texte)
                .font(.system(size: 16.5))
                .foregroundStyle(.white)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(envoye ? Color.blue : Color(white: 0.22), in: RoundedRectangle(cornerRadius: 18))
            if !envoye { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 14)
    }
}
