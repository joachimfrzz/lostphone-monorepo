// WhatsApp iOS 26 — conversations EN DONNÉES + vue générique (itération 6)
// « Utilisable de A à Z » (D51) : chaque conversation s'ouvre, chaque contact a sa fiche,
// et ON PEUT ÉCRIRE (le message part réellement dans le fil, à l'heure réelle).
// Préfiguration d'ARCH-1 : le contenu est de la donnée, la vue est générique.
import SwiftUI

// ============================================================ MODÈLE
enum ElementConv {
    case jour(String)
    case systeme(String)
    case msg(Bool, String, String)
    case msgGroupe(String, UInt, String, String) // expéditeur, couleur, texte, heure
    case riche(Bool, String, String, String?, String?, String?)
    case vocal(Bool, String, String)
    case vocalAudio(Bool, String, String, String, String) // recu, durée, heure, fichier, transcription
    case appel(Bool, String, String, String?, String, Bool)
    case image(Bool, String)
    case album(Bool, Int, String)
    case video(Bool, String, String)
    case gif(Bool, String)
    case document(Bool, String, String, String)
    case musique(Bool, String, String, String)
    case lien(Bool, String, String, String, String)
    case localisation(Bool, String, String)
    case contactPartage(Bool, String, String)
    case sticker(Bool, String, String)
    case transfere(Bool, String, String)
    case supprime(Bool, String)
}

struct FicheContact {
    let nom: String
    let sousTitre: String
    let numero: String
}

// ============================================================ CONTENU (Coches bleues)
enum DonneesWA {
    static let fiches: [String: FicheContact] = [
        "Marc ❤️": FicheContact(nom: "Marc ❤️", sousTitre: "en ligne aujourd'hui à 17:41", numero: "+33 7 49 12 53 08"),
        "Chloé": FicheContact(nom: "Chloé", sousTitre: "en ligne", numero: "+33 6 24 81 05 77"),
        "Thomas": FicheContact(nom: "Thomas", sousTitre: "vu aujourd'hui à 15:12", numero: "+33 6 51 33 90 12"),
        "Maman": FicheContact(nom: "Maman", sousTitre: "vu aujourd'hui à 12:04", numero: "+33 6 88 41 27 30"),
        "Marie kiné": FicheContact(nom: "Marie kiné", sousTitre: "vu hier à 18:40", numero: "+33 6 02 55 18 64"),
        "Les filles 💃": FicheContact(nom: "Les filles 💃", sousTitre: "Chloé, Julie, Vous", numero: "Groupe · 3 membres"),
    ]

    static func conversation(_ nom: String) -> [ElementConv] {
        switch nom {
        case "Les filles 💃": return filles
        case "Marc ❤️": return marc
        case "Chloé": return chloe
        case "Thomas": return thomas
        case "Maman": return maman
        case "Marie kiné": return marie
        default: return [.systeme("Les messages et les appels sont chiffrés de bout en bout.")]
        }
    }

    // ——— Le fil de l'arnaque (cœur de Coches bleues)
    static let marc: [ElementConv] = [
        .systeme("Les messages et les appels sont chiffrés de bout en bout."),
        .jour("14 mars"),
        .msg(true, "Bonjour Sarah ❤️ Je suis très heureux de ton message. Comment se passe ta journée à toi ?", "10:12"),
        .msg(false, "Bien ! C'est bizarre, j'ai l'impression qu'on se connaît depuis longtemps. Bref 😊 Tu es où là, en mer ?", "12:40"),
        .jour("2 avril"),
        .riche(true, "Ma chérie ❤️🌹🌹 Cette nuit j'ai pensé à notre maison près de Cassis. Tu es la reine de mon cœur.", "09:03", nil, nil, "❤️"),
        .image(true, "09:05"),
        .msg(true, "Le coucher de soleil depuis le pont. Il ne manque que toi.", "09:05"),
        .jour("19 avril"),
        .msg(false, "Tu me manques. C'est ridicule non ? On s'est jamais vus et tu me manques ❤️", "22:51"),
        .sticker(true, "🥰", "23:02"),
        .jour("6 mai"),
        .appel(true, "video.slash.fill", "Appel vidéo manqué", "Appuyez pour rappeler", "09:47", true),
        .msg(true, "Mon amour, la connexion satellite du navire est suspendue. 300 euros pour la rétablir. Sans cela nous ne pouvons plus parler… Je rembourse à Marseille, promis de mon cœur.", "11:20"),
        .jour("11 juin"),
        .msg(true, "Un colis pour toi est bloqué en douane ma reine. 800 euros de frais. C'est mon cadeau pour toi, j'ai honte de demander.", "14:47"),
        .jour("28 juin"),
        .msg(true, "Bonne nuit, chère Monique.", "21:58"),
        .msg(true, "Pardon ma chérie !! Je pensais à ma tante Monique, je suis fatigué ce soir. Bonne nuit mon trésor ❤️", "21:59"),
        .vocalAudio(true, "0:18", "22:03", "vocal-marc", "Ma chérie… c'est moi. Écoute, pour le prénom tout à l'heure… je suis confus. Monique, c'est ma tante, je pense beaucoup à elle en ce moment, elle est souffrante. Toi, tu es mon seul amour, Sarah. Ne doute jamais de moi. Dors bien mon trésor… à demain."),
        .jour("5 juillet"),
        .appel(true, "video.fill", "Appel vidéo", "19 s", "20:31", false),
        .msg(false, "C'était court 😢 Je t'ai à peine vu, ça coupait tout le temps", "20:34"),
        .msg(true, "Le réseau du navire mon amour. Bientôt tu me verras en vrai, plus d'écran entre nous ❤️", "20:41"),
        .jour("16 juillet"),
        .msg(true, "Ma solde est bloquée par la compagnie. Il faut payer la caution de débarquement : 3000 euros. Sinon pas de Marseille le 28… Voici le compte de l'agent maritime : FR76 XXXX (M. OKAFOR AGENT MARITIME).", "10:31"),
        .riche(false, "D'accord mon amour. J'ai rendez-vous à la banque lundi à 11h30, tout sera réglé ❤️", "11:02",
               "Marc ❤️", "Ma solde est bloquée par la compagnie. Il faut payer la caution de débarquement : 3000 euros…", nil),
        .jour("aujourd'hui"),
        .msg(true, "N'oublie pas : 11h30. Après-demain je te tiens dans mes bras. Supprime bien nos échanges comme je t'ai dit ❤️", "17:41"),
    ]

    // ——— Le groupe (noms colorés par membre, comme le vrai)
    static let filles: [ElementConv] = [
        .systeme("Les messages et les appels sont chiffrés de bout en bout."),
        .jour("mardi"),
        .msgGroupe("Julie", 0x6EB1F7, "Brunch samedi ?? Le nouveau place Sathonay, il paraît que c'est incroyable", "12:41"),
        .msgGroupe("Chloé", 0xE17BB2, "OUI. J'ai besoin de potins et de pancakes", "12:44"),
        .msg(false, "Je peux pas avant 13h, j'ai un truc le matin 🙈", "13:02"),
        .msgGroupe("Chloé", 0xE17BB2, "Un « truc ». Bien mystérieuse la meuf depuis des mois 👀", "13:04"),
        .msgGroupe("Julie", 0x6EB1F7, "C'est quand que tu nous le présentes ton marin là ?? 😏⚓️", "13:05"),
        .msg(false, "Bientôt ! Il arrive le 28 😍", "13:11"),
        .msgGroupe("Julie", 0x6EB1F7, "ENFIN. Bon 13h alors, je réserve", "13:12"),
        .jour("aujourd'hui"),
        .msgGroupe("Chloé", 0xE17BB2, "Julie appelle-moi stp", "19:40"),
    ]

    // ——— La meilleure amie qui s'inquiète (porteuse du joueur)
    static let chloe: [ElementConv] = [
        .systeme("Les messages et les appels sont chiffrés de bout en bout."),
        .jour("12 juillet"),
        .album(true, 6, "18:22"),
        .msg(true, "Les photos du festival !! Meilleure soirée de l'année 🥹", "18:22"),
        .riche(false, "On les encadre celles-là ❤️", "18:40", nil, nil, "🥹"),
        .jour("jeudi"),
        .msg(true, "Bon. Faut qu'on parle de « Marc ». Tu l'as toujours pas vu en vrai Sarah. Huit mois.", "21:14"),
        .msg(false, "Tu recommences… Il débarque à Marseille le 28. Tu verras bien.", "21:26"),
        .msg(true, "Et c'est quoi cette histoire de caution de 3000 € ?? C'est PAS normal", "21:27"),
        .supprime(false, "21:31"),
        .msg(true, "T'as effacé quoi là ?", "21:32"),
        .jour("aujourd'hui"),
        .msg(true, "Sarah. Réponds-moi. T'es passée à la banque ???", "19:12"),
        .appel(true, "phone.arrow.down.left", "Appel vocal manqué", "Appuyez pour rappeler", "19:32", true),
        .appel(true, "phone.arrow.down.left", "Appel vocal manqué", "Appuyez pour rappeler", "19:33", true),
        .vocalAudio(true, "0:08", "19:34", "vocal-chloe", "Sarah, c'est moi. Bon, tu réponds pas… Rappelle-moi dès que t'as mon message, d'accord ? C'est important. C'est à propos de Marc. S'il te plaît… rappelle-moi."),
        .msg(true, "Je passe chez toi demain matin. On va vérifier ce mec ENSEMBLE. Ne vire RIEN d'ici là, promets-le moi.", "19:35"),
    ]

    // ——— Vitrine complète des médias (contenu anodin, D51-2)
    static let thomas: [ElementConv] = [
        .systeme("Les messages et les appels sont chiffrés de bout en bout."),
        .jour("samedi"),
        .msg(true, "Regarde tout ce qu'on peut s'envoyer 😄", "14:02"),
        .image(true, "14:03"),
        .album(true, 7, "14:03"),
        .video(false, "0:23", "14:05"),
        .gif(true, "14:06"),
        .vocal(false, "0:42", "14:08"),
        .musique(true, "Mistral gagnant", "2:19", "14:10"),
        .document(false, "Recette_tiramisu.pdf", "2 pages · PDF · 1,2 Mo", "14:12"),
        .lien(true, "La météo du week-end s'annonce superbe", "meteo-france.com", "https://meteo-france.com/we", "14:15"),
        .localisation(false, "Parc de la Tête d'Or", "14:18"),
        .contactPartage(true, "Marie kiné", "14:20"),
        .sticker(false, "🤙", "14:21"),
        .transfere(true, "Concert gratuit dimanche aux Berges du Rhône !", "14:24"),
        .supprime(true, "14:25"),
        .riche(false, "Trop fort ce sticker 😂", "14:26", "Thomas", "🤙", "😂"),
    ]

    // ——— La famille (texture innocentable)
    static let maman: [ElementConv] = [
        .systeme("Les messages et les appels sont chiffrés de bout en bout."),
        .jour("mercredi"),
        .image(true, "11:30"),
        .msg(true, "les hortensias de cette année !! ton père est trop fier", "11:31"),
        .msg(false, "Magnifiques 😍 Vous me gardez des boutures hein", "12:15"),
        .jour("vendredi"),
        .vocalAudio(true, "0:19", "17:44", "vocal-maman", "Allô ma chérie, c'est maman ! Alors dis-moi, pour dimanche… le rôti, je le mets au four à quelle heure ? Ton père dit midi, moi je dis onze heures et demie… Rappelle-moi ! Ah, et ramène-moi mon tupperware, le bleu. Bisous bisous ma chérie."),
        .msg(false, "Maman on a dit : tu ÉCRIS tes messages 😂 Un vocal entier pour un rôti", "18:01"),
        .jour("dimanche"),
        .msg(true, "tu viens dimanche ??? bisous maman", "10:05"),
    ]

    // ——— Le quotidien (texture innocentable)
    static let marie: [ElementConv] = [
        .systeme("Les messages et les appels sont chiffrés de bout en bout."),
        .jour("mardi"),
        .msg(false, "Bonjour Marie, est-ce qu'on peut décaler jeudi ? J'ai un empêchement à 14h", "09:12"),
        .msg(true, "Bonjour Sarah ! Oui bien sûr, je vous propose jeudi 17h30 ?", "09:40"),
        .msg(false, "Parfait merci !", "09:41"),
        .document(true, "Exercices_epaule_S32.pdf", "3 pages · PDF · 840 Ko", "10:02"),
        .msg(true, "Les exercices à faire d'ici jeudi, 2 séries chaque matin 💪", "10:02"),
        .jour("vendredi"),
        .localisation(true, "Cabinet — 12 rue des Fantasques", "08:15"),
        .msg(true, "Pour rappel on a déménagé au 12 ! Même code, 2e étage.", "08:15"),
        .msg(false, "✓✓ ok pour l'échange de créneaux jeudi 👍", "11:20"),
    ]
}

// ============================================================ MESSAGES ENVOYÉS (persistants)
final class EnvoisJoueur: ObservableObject {
    static let partage = EnvoisJoueur()
    @Published var parContact: [String: [ElementConv]] = [:]
    func ajouter(_ contact: String, _ element: ElementConv) {
        parContact[contact, default: []].append(element)
    }
}

// ============================================================ VUE GÉNÉRIQUE
struct ConversationVue: View {
    @Environment(\.dismiss) private var dismiss
    let nomContact: String
    @ObservedObject private var envois = EnvoisJoueur.partage
    @State private var saisie = ""
    @State private var appelVisible = false

    // Le fil = données d'histoire + envois persistants du joueur (observés en direct,
    // plus d'instantané figé : la vue pré-créée par la liste reste toujours à jour)
    private var elements: [ElementConv] {
        DonneesWA.conversation(nomContact) + (envois.parContact[nomContact] ?? [])
    }

    init(nomContact: String) {
        self.nomContact = nomContact
    }

    private var fiche: FicheContact {
        DonneesWA.fiches[nomContact] ?? FicheContact(nom: nomContact, sousTitre: "", numero: "")
    }

    var body: some View {
        VStack(spacing: 0) {
            // ——— Header (tap → fiche contact)
            HStack(spacing: 9) {
                Button { dismiss() } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left").font(.system(size: 22, weight: .semibold))
                        Text("3").font(.system(size: 15))
                    }
                    .foregroundStyle(waTexte)
                }
                .padding(.leading, 8)
                NavigationLink(destination: InfosContactVue(nom: fiche.nom, numero: fiche.numero)) {
                    HStack(spacing: 9) {
                        AvatarSilhouette(taille: 38, image: nomContact == "Marc ❤️" ? "AvatarMarc" : nil)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(fiche.nom).font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                            Text(fiche.sousTitre).font(.system(size: 12.5)).foregroundStyle(waTexte2)
                        }
                    }
                }
                Spacer()
                HStack(spacing: 22) {
                    Image(systemName: "video").font(.system(size: 19))
                        .contentShape(Rectangle())
                        .onTapGesture { appelVisible = true }
                    Image(systemName: "phone").font(.system(size: 17))
                        .contentShape(Rectangle())
                        .onTapGesture { appelVisible = true }
                }
                .foregroundStyle(waTexte)
                .padding(.horizontal, 18).padding(.vertical, 10)
                .background(Color(hex: 0x1C201E), in: Capsule())
            }
            .padding(.horizontal, 8).padding(.vertical, 6)
            .background(Color(hex: 0x111312))

            // ——— Fil
            ScrollViewReader { defileur in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(0..<elements.count, id: \.self) { i in
                            rendu(elements[i]).id(i)
                        }
                        Spacer(minLength: 6).id("fin")
                    }
                    .padding(.horizontal, 12).padding(.vertical, 12)
                }
                .background(ZStack { waNoir; MotifDiscussion() })
                .onAppear { defileur.scrollTo("fin", anchor: .bottom) }
                .onChange(of: envois.parContact[nomContact]?.count ?? 0) { defileur.scrollTo("fin", anchor: .bottom) }
            }

            // ——— Saisie FONCTIONNELLE : écrire envoie vraiment (heure réelle)
            HStack(spacing: 14) {
                Image(systemName: "plus").font(.system(size: 24)).foregroundStyle(waTexte)
                HStack {
                    TextField("", text: $saisie).font(.system(size: 16.5)).foregroundStyle(waTexte)
                    Image(systemName: "theatermask.and.paintbrush").font(.system(size: 17)).foregroundStyle(waTexte2)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(waSaisie, in: Capsule())
                if saisie.trimmingCharacters(in: .whitespaces).isEmpty {
                    Image(systemName: "camera").font(.system(size: 21)).foregroundStyle(waTexte)
                    Image(systemName: "mic").font(.system(size: 21)).foregroundStyle(waTexte)
                } else {
                    Button(action: envoyer) {
                        Circle().fill(waVertVif).frame(width: 34, height: 34)
                            .overlay(Image(systemName: "arrow.up").font(.system(size: 17, weight: .bold)).foregroundStyle(Color(hex: 0x062E1C)))
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(waNoir)
        }
        .background(waNoir)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $appelVisible) {
            // Règle 16/08 : soit l'appel fait partie de l'histoire, soit personne ne décroche.
            AppelVue(nom: nomContact)
        }
    }

    private func envoyer() {
        let t = saisie.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let element = ElementConv.msg(false, t, df.string(from: Date()))
        withAnimation(.spring(duration: 0.3)) {
            envois.ajouter(nomContact, element)
        }
        saisie = ""
    }

    // ——— Rendu d'un élément (menu contextuel natif sur les bulles : D51-1)
    @ViewBuilder
    private func rendu(_ e: ElementConv) -> some View {
        switch e {
        case .jour(let j):
            Text(j).font(.system(size: 12.5)).foregroundStyle(waTexte2)
                .padding(.horizontal, 13).padding(.vertical, 5)
                .background(waCarte, in: RoundedRectangle(cornerRadius: 10))
                .padding(.top, 12).padding(.bottom, 8)
        case .systeme(let t): MessageSysteme(texte: t)
        case .msg(let r, let t, let h):
            Bulle(recu: r, texte: t, heure: h).contextMenu { menuMessage }
        case .msgGroupe(let exp, let coul, let t, let h):
            EnveloppeBulle(recu: true) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exp).font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(Color(hex: coul))
                    HStack(alignment: .bottom, spacing: 8) {
                        Text(t).font(.system(size: 17)).foregroundStyle(waTexte)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(h).font(.system(size: 11.5)).foregroundStyle(waTexte.opacity(0.55))
                    }
                }
                .padding(.horizontal, 10).padding(.vertical, 7)
                .background(waBulleRecu)
                .clipShape(.rect(topLeadingRadius: 5, bottomLeadingRadius: 18,
                                 bottomTrailingRadius: 18, topTrailingRadius: 18))
            }
            .contextMenu { menuMessage }
        case .riche(let r, let t, let h, let cn, let ct, let re):
            BulleRiche(recu: r, texte: t, heure: h, citationNom: cn, citationTexte: ct, reaction: re)
                .contextMenu { menuMessage }
        case .vocal(let r, let d, let h): BulleVocale(recu: r, duree: d, heure: h)
        case .vocalAudio(let r, let d, let h, let f, let tr):
            BulleVocaleAudio(recu: r, duree: d, heure: h, fichier: f, transcription: tr)
        case .appel(let r, let s, let t, let st, let h, let rouge):
            BulleAppel(recu: r, symbole: s, titre: t, sousTitre: st, heure: h, rouge: rouge)
                .contentShape(Rectangle())
                .onTapGesture { appelVisible = true }
        case .image(let r, let h): BulleImage(recu: r, heure: h).contextMenu { menuMessage }
        case .album(let r, let n, let h): BulleAlbum(recu: r, total: n, heure: h)
        case .video(let r, let d, let h): BulleVideo(recu: r, duree: d, heure: h)
        case .gif(let r, let h): BulleGIF(recu: r, heure: h)
        case .document(let r, let n, let det, let h): BulleDocument(recu: r, nom: n, details: det, heure: h)
        case .musique(let r, let t, let d, let h): BulleMusique(recu: r, titre: t, duree: d, heure: h)
        case .lien(let r, let t, let u, let c, let h): BulleLien(recu: r, titre: t, url: u, commentaire: c, heure: h)
        case .localisation(let r, let l, let h): BulleLocalisation(recu: r, legende: l, heure: h)
        case .contactPartage(let r, let n, let h): BulleContactPartage(recu: r, nom: n, heure: h)
        case .sticker(let r, let e2, let h): BulleSticker(recu: r, emoji: e2, heure: h)
        case .transfere(let r, let t, let h): BulleTransferee(recu: r, texte: t, heure: h)
        case .supprime(let r, let h): BulleSupprimee(recu: r, heure: h)
        }
    }

    @ViewBuilder
    private var menuMessage: some View {
        Button { } label: { Label("Répondre", systemImage: "arrowshape.turn.up.left") }
        Button { } label: { Label("Copier", systemImage: "doc.on.doc") }
        Button { } label: { Label("Transférer", systemImage: "arrowshape.turn.up.forward") }
        Button { } label: { Label("Épingler", systemImage: "pin") }
        Button(role: .destructive) { } label: { Label("Supprimer", systemImage: "trash") }
    }
}

// ============================================================ ONGLET ACTUS (statuts + chaînes)
struct ActusVue: View {
    @State private var suivies: Set<String> = []
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RondAction(symbole: "ellipsis")
                Spacer()
                RondAction(symbole: "camera.fill")
                RondAction(symbole: "plus", fond: waVertVif, teinte: Color(hex: 0x062E1C), gras: true)
            }
            .padding(.horizontal, 16).padding(.top, 8)
            HStack {
                Text("Actus").font(.system(size: 34, weight: .bold)).foregroundStyle(waTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Statut").font(.system(size: 20, weight: .bold)).foregroundStyle(waTexte)
                        .padding(.horizontal, 20).padding(.top, 16)
                    HStack(spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            AvatarSilhouette(taille: 52)
                            Circle().fill(waVertVif).frame(width: 20, height: 20)
                                .overlay(Image(systemName: "plus").font(.system(size: 11, weight: .bold)).foregroundStyle(Color(hex: 0x062E1C)))
                                .overlay(Circle().stroke(waNoir, lineWidth: 2))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Votre statut").font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                            Text("Ajoutez une mise à jour").font(.system(size: 14.5)).foregroundStyle(waTexte2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.vertical, 12)

                    HStack(spacing: 12) {
                        Circle().stroke(waVertDoux, lineWidth: 2.5).frame(width: 54, height: 54)
                            .overlay(AvatarSilhouette(taille: 46))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Chloé").font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                            Text("il y a 43 min").font(.system(size: 14.5)).foregroundStyle(waTexte2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.vertical, 8)

                    Text("Chaînes").font(.system(size: 20, weight: .bold)).foregroundStyle(waTexte)
                        .padding(.horizontal, 20).padding(.top, 22)
                    Text("Restez informée sur les sujets qui vous intéressent.")
                        .font(.system(size: 14.5)).foregroundStyle(waTexte2)
                        .padding(.horizontal, 20).padding(.top, 4)
                    ForEach(["Le Monde", "Météo France", "OL Féminin"], id: \.self) { c in
                        HStack(spacing: 12) {
                            AvatarSilhouette(taille: 44)
                            Text(c).font(.system(size: 16.5, weight: .semibold)).foregroundStyle(waTexte)
                            Spacer()
                            Text(suivies.contains(c) ? "Suivi ✓" : "Suivre")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(suivies.contains(c) ? waTexte2 : Color(hex: 0x062E1C))
                                .padding(.horizontal, 16).padding(.vertical, 7)
                                .background(suivies.contains(c) ? Color(hex: 0x1C242B) : waVertVif, in: Capsule())
                                .onTapGesture {
                                    if suivies.contains(c) { suivies.remove(c) } else { suivies.insert(c) }
                                }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 8)
                    }
                    Spacer(minLength: 90)
                }
            }
        }
    }
}

// ============================================================ ONGLET COMMUNAUTÉS
struct CommunautesVue: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RondAction(symbole: "ellipsis")
                Spacer()
                RondAction(symbole: "plus", fond: waVertVif, teinte: Color(hex: 0x062E1C), gras: true)
            }
            .padding(.horizontal, 16).padding(.top, 8)
            HStack {
                Text("Communautés").font(.system(size: 34, weight: .bold)).foregroundStyle(waTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 12)
            Spacer()
            Image(systemName: "person.3.fill").font(.system(size: 56)).foregroundStyle(waTexte2)
            Text("Restez en contact avec une communauté")
                .font(.system(size: 19, weight: .semibold)).foregroundStyle(waTexte)
                .multilineTextAlignment(.center).padding(.horizontal, 40).padding(.top, 16)
            Text("Les communautés rassemblent les membres dans des groupes par thème.")
                .font(.system(size: 14.5)).foregroundStyle(waTexte2)
                .multilineTextAlignment(.center).padding(.horizontal, 40).padding(.top, 6)
            Text("Nouvelle communauté").font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: 0x062E1C))
                .padding(.horizontal, 22).padding(.vertical, 12)
                .background(waVertVif, in: Capsule())
                .padding(.top, 20)
            Spacer()
            Spacer()
        }
    }
}
