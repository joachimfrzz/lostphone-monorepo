// WhatsApp iOS 26 — catalogue COMPLET des types de médias (itération 5, règle D51-2)
// Tous les types observés dans la vidéo de référence, intégrés comme composants
// réutilisables. Contenu de démonstration sans signification narrative (conversation Thomas).
import SwiftUI

// ————— Enveloppe commune : aligne à gauche/droite avec marge
struct EnveloppeBulle<Contenu: View>: View {
    let recu: Bool
    @ViewBuilder let contenu: () -> Contenu
    var body: some View {
        HStack {
            if !recu { Spacer(minLength: 56) }
            contenu()
            if recu { Spacer(minLength: 56) }
        }
    }
}

// ————— Tampon heure + coches (réutilisé par les médias)
struct TamponHeure: View {
    let heure: String
    let recu: Bool
    var surImage: Bool = false
    var body: some View {
        HStack(spacing: 3) {
            Text(heure).font(.system(size: 11)).foregroundStyle(surImage ? .white : waTexte.opacity(0.55))
            if !recu {
                Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(surImage ? .white : cocheBleue)
                Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(surImage ? .white : cocheBleue).padding(.leading, -6)
            }
        }
        .padding(.horizontal, surImage ? 7 : 0).padding(.vertical, surImage ? 3 : 0)
        .background(surImage ? Color.black.opacity(0.45) : .clear, in: Capsule())
    }
}

// ————— PHOTO
struct BulleImage: View {
    let recu: Bool
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            Image("FondEcran")
                .resizable().scaledToFill()
                .frame(width: 240, height: 260).clipped()
                .overlay(alignment: .bottomTrailing) { TamponHeure(heure: heure, recu: recu, surImage: true).padding(6) }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(3)
                .background(recu ? waBulleRecu : waBulleEnvoi)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ————— VIDÉO (vignette + durée + lecture)
struct BulleVideo: View {
    let recu: Bool
    let duree: String
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            ZStack {
                Image("FondEcran").resizable().scaledToFill()
                    .frame(width: 240, height: 200).clipped()
                Color.black.opacity(0.35)
                Circle().fill(.ultraThinMaterial).frame(width: 52, height: 52)
                    .overlay(Image(systemName: "play.fill").font(.system(size: 20)).foregroundStyle(.white))
            }
            .frame(width: 240, height: 200)
            .overlay(alignment: .topLeading) {
                HStack(spacing: 4) {
                    Image(systemName: "video.fill").font(.system(size: 10))
                    Text(duree).font(.system(size: 11))
                }
                .foregroundStyle(.white).padding(6)
            }
            .overlay(alignment: .bottomTrailing) { TamponHeure(heure: heure, recu: recu, surImage: true).padding(6) }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(3)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ————— GIF (étiquette + tenor, flèche de transfert observée en vidéo)
struct BulleGIF: View {
    let recu: Bool
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            HStack(spacing: 8) {
                if recu {
                    Circle().fill(.ultraThinMaterial).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "arrowshape.turn.up.forward.fill").font(.system(size: 14)).foregroundStyle(.white.opacity(0.8)))
                }
                ZStack {
                    LinearGradient(colors: [Color(hex: 0x1B2A4A), Color(hex: 0x3A2A55)], startPoint: .top, endPoint: .bottom)
                    VStack(spacing: 8) {
                        Text("BONNE SOIRÉE").font(.system(size: 20, weight: .heavy)).foregroundStyle(.white)
                        Image(systemName: "moon.stars.fill").font(.system(size: 34)).foregroundStyle(Color(hex: 0xFFD60A))
                    }
                }
                .frame(width: 220, height: 180)
                .overlay(alignment: .bottomLeading) {
                    Text("tenor").font(.system(size: 12)).foregroundStyle(.white.opacity(0.7)).padding(8)
                }
                .overlay(alignment: .bottomTrailing) { TamponHeure(heure: heure, recu: recu, surImage: true).padding(6) }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(3)
                .background(recu ? waBulleRecu : waBulleEnvoi)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }
}

// ————— ALBUM (plusieurs photos, compteur)
struct BulleAlbum: View {
    let recu: Bool
    let total: Int
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            VStack(spacing: 3) {
                HStack(spacing: 3) {
                    Image("FondEcran").resizable().scaledToFill().frame(width: 118, height: 100).clipped()
                    Image("FondEcran").resizable().scaledToFill().frame(width: 118, height: 100).clipped().scaleEffect(x: -1)
                }
                HStack(spacing: 3) {
                    Image("FondEcran").resizable().scaledToFill().frame(width: 118, height: 100).clipped().scaleEffect(y: -1)
                    ZStack {
                        Image("FondEcran").resizable().scaledToFill().frame(width: 118, height: 100).clipped()
                        Color.black.opacity(0.55)
                        Text("+\(total - 4)").font(.system(size: 24, weight: .semibold)).foregroundStyle(.white)
                    }
                    .frame(width: 118, height: 100)
                }
            }
            .overlay(alignment: .bottomTrailing) { TamponHeure(heure: heure, recu: recu, surImage: true).padding(6) }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(3)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ————— DOCUMENT (PDF…)
struct BulleDocument: View {
    let recu: Bool
    let nom: String
    let details: String
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 8).fill(Color(hex: 0xE2574C))
                        .frame(width: 38, height: 44)
                        .overlay(Text("PDF").font(.system(size: 11, weight: .bold)).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(nom).font(.system(size: 15, weight: .semibold)).foregroundStyle(waTexte).lineLimit(1)
                        Text(details).font(.system(size: 12.5)).foregroundStyle(waTexte2)
                    }
                    Image(systemName: "arrow.down.circle").font(.system(size: 22)).foregroundStyle(waTexte2)
                }
                .padding(10)
                .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                TamponHeure(heure: heure, recu: recu).padding(.trailing, 4).padding(.bottom, 2)
            }
            .padding(5)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ————— MUSIQUE partagée
struct BulleMusique: View {
    let recu: Bool
    let titre: String
    let duree: String
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 8).fill(Color(hex: 0x2A2A2E))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "music.note").font(.system(size: 19)).foregroundStyle(Color(hex: 0xFA5A8E)))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(titre).font(.system(size: 15, weight: .semibold)).foregroundStyle(waTexte).lineLimit(1)
                        HStack(spacing: 2) {
                            ForEach(0..<18, id: \.self) { i in
                                Capsule().fill(waTexte2).frame(width: 2.5, height: [6,10,14,8,12,16,7,11,15,9,6,13,10,7,12,8,14,6][i])
                            }
                        }
                    }
                    Image(systemName: "play.fill").font(.system(size: 18)).foregroundStyle(waTexte2)
                }
                .padding(10)
                .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                HStack(spacing: 6) {
                    Text(duree).font(.system(size: 11)).foregroundStyle(waTexte2)
                    TamponHeure(heure: heure, recu: recu)
                }
                .padding(.trailing, 4).padding(.bottom, 2)
            }
            .padding(5)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ————— LIEN avec carte d'aperçu
struct BulleLien: View {
    let recu: Bool
    let titre: String
    let url: String
    let commentaire: String
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 0) {
                    LinearGradient(colors: [Color(hex: 0x2E4A33), Color(hex: 0x18301F)], startPoint: .top, endPoint: .bottom)
                        .frame(width: 244, height: 110)
                        .overlay(Image(systemName: "globe").font(.system(size: 30)).foregroundStyle(.white.opacity(0.5)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(titre).font(.system(size: 14, weight: .semibold)).foregroundStyle(waTexte).lineLimit(2)
                        Text(url).font(.system(size: 12)).foregroundStyle(waTexte2)
                    }
                    .padding(9)
                    .frame(width: 244, alignment: .leading)
                    .background(Color.black.opacity(0.25))
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                HStack(alignment: .bottom, spacing: 8) {
                    Text(commentaire).font(.system(size: 16.5)).foregroundStyle(Color(hex: 0x6EB1F7)).underline()
                    TamponHeure(heure: heure, recu: recu)
                }
            }
            .padding(7)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ————— LOCALISATION
struct BulleLocalisation: View {
    let recu: Bool
    let legende: String
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    LinearGradient(colors: [Color(hex: 0x27333A), Color(hex: 0x1B252B)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    // routes stylisées
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 66)); p.addLine(to: CGPoint(x: 244, y: 44))
                        p.move(to: CGPoint(x: 60, y: 0)); p.addLine(to: CGPoint(x: 96, y: 130))
                        p.move(to: CGPoint(x: 170, y: 0)); p.addLine(to: CGPoint(x: 150, y: 130))
                    }
                    .stroke(Color(hex: 0x4A585F), lineWidth: 5)
                    Image(systemName: "mappin.circle.fill").font(.system(size: 34))
                        .foregroundStyle(.white, Color(hex: 0xF25B5B))
                }
                .frame(width: 244, height: 130).clipped()
                VStack(alignment: .leading, spacing: 1) {
                    Text(legende).font(.system(size: 14, weight: .semibold)).foregroundStyle(waTexte)
                    HStack {
                        Text("Position").font(.system(size: 12)).foregroundStyle(waTexte2)
                        Spacer()
                        TamponHeure(heure: heure, recu: recu)
                    }
                }
                .padding(9).frame(width: 244)
                .background(Color.black.opacity(0.25))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(3)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ————— FICHE CONTACT partagée
struct BulleContactPartage: View {
    let recu: Bool
    let nom: String
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    AvatarSilhouette(taille: 42)
                    Text(nom).font(.system(size: 16, weight: .semibold)).foregroundStyle(waTexte)
                    Spacer()
                    TamponHeure(heure: heure, recu: recu)
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
                Divider().background(waTexte.opacity(0.15))
                Text("Voir la fiche de contact")
                    .font(.system(size: 15, weight: .semibold)).foregroundStyle(Color(hex: 0x6EB1F7))
                    .padding(.vertical, 9)
            }
            .frame(width: 250)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ————— STICKER (grand, sans bulle)
struct BulleSticker: View {
    let recu: Bool
    let emoji: String
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(emoji).font(.system(size: 84))
                TamponHeure(heure: heure, recu: recu, surImage: true)
            }
        }
    }
}

// ————— TEXTE TRANSFÉRÉ (étiquette « Transféré »)
struct BulleTransferee: View {
    let recu: Bool
    let texte: String
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.forward.fill").font(.system(size: 11))
                    Text("Transféré").font(.system(size: 12.5)).italic()
                }
                .foregroundStyle(waTexte2)
                HStack(alignment: .bottom, spacing: 8) {
                    Text(texte).font(.system(size: 17)).foregroundStyle(waTexte)
                    TamponHeure(heure: heure, recu: recu)
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 7)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ————— MESSAGE SYSTÈME (chiffrement, jaune sombre WhatsApp)
struct MessageSysteme: View {
    let texte: String
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock.fill").font(.system(size: 10))
            Text(texte).font(.system(size: 12.5))
        }
        .foregroundStyle(Color(hex: 0xD5C15C))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 13).padding(.vertical, 7)
        .background(Color(hex: 0x242018), in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 24).padding(.vertical, 6)
    }
}

// ————— MESSAGE SUPPRIMÉ
struct BulleSupprimee: View {
    let recu: Bool
    let heure: String
    var body: some View {
        EnveloppeBulle(recu: recu) {
            HStack(alignment: .bottom, spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: "nosign").font(.system(size: 13)).foregroundStyle(waTexte2)
                    Text(recu ? "Ce message a été supprimé." : "Vous avez supprimé ce message.")
                        .font(.system(size: 15.5)).italic().foregroundStyle(waTexte2)
                }
                TamponHeure(heure: heure, recu: recu)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(recu ? waBulleRecu : waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

