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
    case msgJoueur(String, String) // message tapé par le joueur : ✓ gris, jamais distribué (D54)
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
    case imageJoueur(String, String)   // photo réellement envoyée par le joueur (fichier pellicule, heure)
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
        case "Yoga du mardi 🧘‍♀️": return yoga
        case "Copro Bât. B": return copro
        case "+33 7 55 10 92 33": return livreur
        default: return [.systeme("Les messages et les appels sont chiffrés de bout en bout.")]
        }
    }

    // ——— Discussions archivées (v2 étape 3 : elles ont un vrai contenu)
    static let yoga: [ElementConv] = [
        .systeme("Les messages et les appels sont chiffrés de bout en bout."),
        .jour("10 juillet"),
        .msgGroupe("Émilie", 0x6EB1F7, "Dernière séance mardi avant la pause de l'été ! Pensez à vos tapis 🧘‍♀️", "18:02"),
        .msg(false, "Je serai là ! Merci pour cette super année Émilie 🙏", "18:30"),
        .jour("12 juillet"),
        .msgGroupe("Émilie", 0x6EB1F7, "Merci à toutes pour cette belle saison. On reprend le 2 septembre !", "10:14"),
    ]
    static let copro: [ElementConv] = [
        .systeme("Les messages et les appels sont chiffrés de bout en bout."),
        .jour("26 juin"),
        .msgGroupe("M. Perrin", 0xE1A95F, "Bonjour à tous, coupure d'eau prévue jeudi de 9h à 12h pour travaux sur la colonne.", "09:20"),
        .msgGroupe("Mme Diallo", 0x8FD08F, "Merci pour l'info ! Les compteurs seront relevés aussi ?", "11:47"),
        .jour("28 juin"),
        .msg(false, "Merci pour l'info", "08:12"),
    ]
    static let livreur: [ElementConv] = [
        .systeme("Les messages et les appels sont chiffrés de bout en bout."),
        .jour("13 juin"),
        .msg(true, "Bonjour, votre livreur est en route. Votre code de livraison est le 4471", "11:05"),
        .msg(false, "Merci, je suis à la maison jusqu'à midi", "11:08"),
    ]

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
    @Published var ordreActivite: [String] = []   // v2 étape 3 : contacts par récence d'envoi
    func ajouter(_ contact: String, _ element: ElementConv) {
        parContact[contact, default: []].append(element)
        ordreActivite.removeAll { $0 == contact }
        ordreActivite.insert(contact, at: 0)
    }
    func supprimer(_ contact: String, texte: String) {
        parContact[contact]?.removeAll { el in
            if case .msgJoueur(let t, _) = el { return t == texte }
            return false
        }
    }
    // Aperçu du dernier envoi pour la liste des discussions
    func dernierApercu(_ contact: String) -> (String, String)? {
        guard let el = parContact[contact]?.last else { return nil }
        switch el {
        case .msgJoueur(let t, let h): return ("Vous : " + t, h)
        case .msg(_, let t, let h): return ("Vous : " + t, h)
        case .riche(_, let t, let h, _, _, _): return ("Vous : " + t, h)
        case .vocal(_, let d, let h): return ("🎤 " + d, h)
        case .imageJoueur(_, let h): return ("📷 Photo", h)
        case .contactPartage(_, let n, let h): return ("👤 " + n, h)
        case .transfere(_, let t, let h): return ("Vous : " + t, h)
        default: return nil
        }
    }
}

// ============================================================ MAGASIN LISTE WA (v2 étape 3)
// Non-lues, archivées, épinglées, nouvelles discussions et communautés créées par le joueur.
final class MagasinWA: ObservableObject {
    static let partage = MagasinWA()
    @Published var nonLues: [String: String] = ["Marc ❤️": "1", "Chloé": "2"]
    @Published var archiveesJoueur: [String] = []
    @Published var epinglees: Set<String> = []
    @Published var nouvelles: [String] = []       // discussions créées par le joueur (nom)
    @Published var communautes: [String] = []     // communautés créées par le joueur

    func marquerLue(_ nom: String) { nonLues.removeValue(forKey: nom) }
    func basculerNonLue(_ nom: String) {
        if nonLues[nom] != nil { nonLues.removeValue(forKey: nom) }
        else { nonLues[nom] = "" }   // "" = pastille sans nombre (marquée à la main, comme WhatsApp)
    }
    func archiver(_ nom: String) {
        if !archiveesJoueur.contains(nom) { archiveesJoueur.append(nom) }
    }
    func desarchiver(_ nom: String) { archiveesJoueur.removeAll { $0 == nom } }
    func basculerEpingle(_ nom: String) {
        if epinglees.contains(nom) { epinglees.remove(nom) } else { epinglees.insert(nom) }
    }
    func enregistrerNouvelle(_ nom: String) {
        guard DonneesWA.fiches[nom] == nil || DonneesWA.conversation(nom).count <= 1 else { return }
        if !nouvelles.contains(nom) { nouvelles.insert(nom, at: 0) }
    }
}

// ============================================================ VUE GÉNÉRIQUE
struct ConversationVue: View {
    @Environment(\.dismiss) private var dismiss
    let nomContact: String
    @ObservedObject private var envois = EnvoisJoueur.partage
    @ObservedObject private var magasinWA = MagasinWA.partage   // compteur retour en temps réel
    @State private var saisie = ""
    @State private var appelVisible = false
    @State private var appelVideoActif = false
    @State private var citation: String? = nil
    @State private var transfertVisible = false
    @State private var transfertTexte = ""
    @State private var enregistrement = false
    @State private var debutEnreg: Date? = nil
    @State private var toastMic: String? = nil
    @State private var tempsEnreg = 0
    // v2 étape 3 : pièces jointes réelles
    @State private var menuJoint = false
    @State private var photosVisibles = false
    @State private var viseurVisible = false
    @State private var contactPartageVisible = false
    @State private var erreurJointe = ""
    @State private var erreurJointeVisible = false
    private let ticEnreg = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

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
                        // v2 correctifs 31/08 : compteur RÉEL de non-lues (disparaît à zéro)
                        if !MagasinWA.partage.nonLues.isEmpty {
                            Text("\(MagasinWA.partage.nonLues.count)").font(.system(size: 15))
                        }
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
                        .onTapGesture { appelVideoActif = true }   // v2 étape 3 : écran vidéo distinct
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

            // ——— Bandeau de citation (si une bulle a été visée via « Répondre »)
            if let cit = citation {
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: 0xB48EF0)).frame(width: 4)
                    Text(cit).font(.system(size: 13.5)).foregroundStyle(waTexte2).lineLimit(2)
                        .padding(.horizontal, 9).padding(.vertical, 6)
                    Spacer(minLength: 0)
                    Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(waTexte2)
                        .padding(.horizontal, 10)
                        .contentShape(Rectangle())
                        .onTapGesture { citation = nil }
                }
                .background(Color(hex: 0x1C201E))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 14).padding(.top, 4)
            }

            // ——— Saisie FONCTIONNELLE : écrire envoie vraiment (heure réelle)
            HStack(spacing: 14) {
                Image(systemName: "plus").font(.system(size: 24)).foregroundStyle(waTexte)
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); menuJoint = true }   // v2 étape 3 : pièces jointes réelles
                HStack {
                    TextField("", text: $saisie).font(.system(size: 16.5)).foregroundStyle(waTexte)
                    Image(systemName: "theatermask.and.paintbrush").font(.system(size: 17)).foregroundStyle(waTexte2)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(waSaisie, in: Capsule())
                if saisie.trimmingCharacters(in: .whitespaces).isEmpty {
                    Image(systemName: "camera").font(.system(size: 21)).foregroundStyle(waTexte)
                    Image(systemName: enregistrement ? "mic.fill" : "mic")
                        .font(.system(size: 21)).foregroundStyle(enregistrement ? Color.red : waTexte)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Comportement WhatsApp réel : un tap court affiche le rappel du geste
                            toastMic = "Maintenez pour enregistrer, relâchez pour envoyer"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { toastMic = nil }
                        }
                        .onLongPressGesture(minimumDuration: 0.35, pressing: { presse in
                            if presse {
                                enregistrement = true
                                debutEnreg = Date()
                                tempsEnreg = 0
                            } else if enregistrement {
                                enregistrement = false
                                let d = max(1, Int(Date().timeIntervalSince(debutEnreg ?? Date())))
                                let duree = String(format: "0:%02d", min(d, 59))
                                let heure = { let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: Date()) }()
                                envois.ajouter(nomContact, .vocal(true, duree, heure))
                                Haptique.leger()
                            }
                        }, perform: {})
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
        .onAppear { MagasinWA.partage.marquerLue(nomContact) }          // ouvrir = lire (v2 étape 3)
        .onDisappear { LecteurAudio.partage.arret() }                   // l'audio s'arrête en quittant l'écran
        .onReceive(ticEnreg) { _ in
            if enregistrement, let d = debutEnreg { tempsEnreg = Int(Date().timeIntervalSince(d)) }
        }
        .fullScreenCover(isPresented: $appelVisible) {
            // Règle 16/08 : soit l'appel fait partie de l'histoire, soit personne ne décroche.
            AppelVue(nom: nomContact)
        }
        .fullScreenCover(isPresented: $appelVideoActif) {
            AppelVideoVue(nom: nomContact)
        }
        // ——— v2 étape 3 : menu pièces jointes (Photos / Appareil photo réels)
        .confirmationDialog("", isPresented: $menuJoint, titleVisibility: .hidden) {
            Button("Photos") { photosVisibles = true }
            Button("Appareil photo") { viseurVisible = true }
            Button("Document") {
                erreurJointe = ErreurLambda.reponse("generique"); erreurJointeVisible = true
            }
            Button("Contact") { contactPartageVisible = true }
            Button("Sondage") {
                erreurJointe = ErreurLambda.reponse("sondage"); erreurJointeVisible = true
            }
            Button("Annuler", role: .cancel) {}
        }
        .sheet(isPresented: $photosVisibles) {
            SelecteurPhotosMsg { nomFichier in
                envois.ajouter(nomContact, .imageJoueur(nomFichier, heureActuelle()))
                photosVisibles = false
            }
        }
        .fullScreenCover(isPresented: $viseurVisible) {
            ViseurCameraVue { nomFichier in
                if let nf = nomFichier { envois.ajouter(nomContact, .imageJoueur(nf, heureActuelle())) }
                viseurVisible = false
            }
        }
        .sheet(isPresented: $contactPartageVisible) {
            PartageContactWAVue(nomSource: nomContact) { nomChoisi in
                envois.ajouter(nomContact, .contactPartage(false, nomChoisi, heureActuelle()))
                contactPartageVisible = false
            }
        }
        .alert("WhatsApp", isPresented: $erreurJointeVisible) {
            Button("OK", role: .cancel) {}
        } message: { Text(erreurJointe) }
        .overlay(alignment: .bottom) {
            if enregistrement || toastMic != nil {
                HStack(spacing: 8) {
                    if enregistrement {
                        Circle().fill(.red).frame(width: 9, height: 9)
                        Text(chronoEnreg).font(.system(size: 15, weight: .medium)).monospacedDigit().foregroundStyle(waTexte)
                        Text("Relâchez pour envoyer").font(.system(size: 14)).foregroundStyle(waTexte2)
                    } else if let t = toastMic {
                        Text(t).font(.system(size: 14)).foregroundStyle(waTexte)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(Color(hex: 0x2A2A2E), in: Capsule())
                .padding(.bottom, 64)
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: enregistrement)
        .animation(.easeOut(duration: 0.2), value: toastMic)
        .sheet(isPresented: $transfertVisible) {
            TransfertContactVue(texte: transfertTexte, nomSource: nomContact)
        }
    }

    // v2 étape 3 : le chrono est piloté par l'état tempsEnreg (mis à jour par le minuteur)
    private var chronoEnreg: String {
        String(format: "0:%02d", max(0, min(tempsEnreg, 59)))
    }

    private func heureActuelle() -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: Date())
    }

    private func envoyer() {
        let t = saisie.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        let element: ElementConv
        if let cit = citation {
            // D54 : envoi joueur avec citation — bulle riche, coche gris (non-distribuée)
            element = .riche(false, t, heureActuelle(), "Moi", cit, nil)
        } else {
            element = ElementConv.msgJoueur(t, heureActuelle())
        }
        withAnimation(.spring(duration: 0.3)) {
            envois.ajouter(nomContact, element)
        }
        MagasinWA.partage.enregistrerNouvelle(nomContact)   // nouvelle discussion → entre dans la liste
        saisie = ""
        citation = nil
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
            Bulle(recu: r, texte: t, heure: h).contextMenu { menuPourTexte(t) }
        case .msgJoueur(let t, let h):
            // D54 : hors des moments d'histoire, l'envoi reste en non-distribution discrète (✓ gris)
            Bulle(recu: false, texte: t, heure: h, distribue: false).contextMenu { menuPourTexte(t) }
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
            .contextMenu { menuPourTexte(t) }
        case .riche(let r, let t, let h, let cn, let ct, let re):
            BulleRiche(recu: r, texte: t, heure: h, citationNom: cn, citationTexte: ct, reaction: re, distribue: r)
                .contextMenu { menuPourTexte(t) }
        case .vocal(let r, let d, let h): BulleVocale(recu: r, duree: d, heure: h)
        case .vocalAudio(let r, let d, let h, let f, let tr):
            BulleVocaleAudio(recu: r, duree: d, heure: h, fichier: f, transcription: tr)
        case .appel(let r, let s, let t, let st, let h, let rouge):
            BulleAppel(recu: r, symbole: s, titre: t, sousTitre: st, heure: h, rouge: rouge)
                .contentShape(Rectangle())
                .onTapGesture {
                    // v2 étape 3 : rappeler en vidéo si l'événement était un appel vidéo
                    if s.contains("video") { appelVideoActif = true } else { appelVisible = true }
                }
        case .image(let r, let h): BulleImage(recu: r, heure: h).contextMenu { menuPourTexte("📷 Photo") }
        case .album(let r, let n, let h): BulleAlbum(recu: r, total: n, heure: h)
        case .video(let r, let d, let h):
            BulleVideo(recu: r, duree: d, heure: h)
                .contentShape(Rectangle())
                .onTapGesture { appelVisible = true }
        case .gif(let r, let h): BulleGIF(recu: r, heure: h)
        case .document(let r, let n, let det, let h): BulleDocument(recu: r, nom: n, details: det, heure: h)
        case .musique(let r, let t, let d, let h): BulleMusique(recu: r, titre: t, duree: d, heure: h)
        case .lien(let r, let t, let u, let c, let h): BulleLien(recu: r, titre: t, url: u, commentaire: c, heure: h)
        case .localisation(let r, let l, let h): BulleLocalisation(recu: r, legende: l, heure: h)
        case .contactPartage(let r, let n, let h): BulleContactPartage(recu: r, nom: n, heure: h)
        case .sticker(let r, let e2, let h): BulleSticker(recu: r, emoji: e2, heure: h)
        case .transfere(let r, let t, let h): BulleTransferee(recu: r, texte: t, heure: h)
        case .supprime(let r, let h): BulleSupprimee(recu: r, heure: h)
        case .imageJoueur(let f, let h): BulleImageJoueurWA(fichier: f, heure: h)
        }
    }

    @ViewBuilder
    private func menuPourTexte(_ texte: String) -> some View {
        Button {
            let tronque = texte.count > 60 ? String(texte.prefix(60)) + "…" : texte
            citation = tronque
        } label: { Label("Répondre", systemImage: "arrowshape.turn.up.left") }
        Button { UIPasteboard.general.string = texte } label: { Label("Copier", systemImage: "doc.on.doc") }
        Button {
            transfertTexte = texte
            transfertVisible = true
        } label: { Label("Transférer", systemImage: "arrowshape.turn.up.forward") }
        Button { } label: { Label("Épingler", systemImage: "pin") }
        Button(role: .destructive) {
            withAnimation {
                envois.supprimer(nomContact, texte: texte)
            }
        } label: { Label("Supprimer", systemImage: "trash") }
    }
}

// ============================================================ v2 ÉTAPE 3 — PHOTO ENVOYÉE (pellicule réelle, style WA)
struct BulleImageJoueurWA: View {
    let fichier: String
    let heure: String
    var body: some View {
        HStack {
            Spacer(minLength: 60)
            ZStack(alignment: .bottomTrailing) {
                if let img = ChargeurPhoto.image(fichier) {
                    Image(uiImage: img).resizable().scaledToFill()
                        .frame(width: 216, height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                HStack(spacing: 3) {
                    Text(heure).font(.system(size: 11)).foregroundStyle(.white.opacity(0.9))
                    Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(.white.opacity(0.75))
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.black.opacity(0.35), in: Capsule())
                .padding(7)
            }
            .padding(3)
            .background(waBulleEnvoi)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// ============================================================ v2 ÉTAPE 3 — PARTAGER UN CONTACT
struct PartageContactWAVue: View {
    @Environment(\.dismiss) private var dismiss
    let nomSource: String
    let choisir: (String) -> Void
    private var noms: [String] { DonneesWA.fiches.keys.sorted().filter { $0 != nomSource } }
    var body: some View {
        NavigationStack {
            ZStack {
                waNoir.ignoresSafeArea()
                List {
                    ForEach(noms, id: \.self) { nom in
                        HStack(spacing: 12) {
                            AvatarSilhouette(taille: 40)
                            Text(nom).font(.system(size: 17)).foregroundStyle(waTexte)
                        }
                        .listRowBackground(waNoir)
                        .listRowSeparatorTint(Color(hex: 0x222222))
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); choisir(nom) }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Partager un contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }.foregroundStyle(waVertDoux)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ ONGLET ACTUS (statuts + chaînes)
struct ActusVue: View {
    @State private var suivies: Set<String> = []
    @State private var statutChloeVisible = false
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
                    .contentShape(Rectangle())
                    .onTapGesture { Haptique.leger(); statutChloeVisible = true }
                    .fullScreenCover(isPresented: $statutChloeVisible) {
                        VisualiseurContenuVue(titre: "Chloé", sousTitre: "il y a 43 min",
                                              emoji: "🤍", teinte: 0xE17BB2, avecMessage: true)
                    }

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

// ============================================================ ONGLET COMMUNAUTÉS (v2 étape 3 : création réelle)
struct CommunautesVue: View {
    @ObservedObject private var magasin = MagasinWA.partage
    @State private var creationVisible = false
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RondAction(symbole: "ellipsis")
                Spacer()
                RondAction(symbole: "plus", fond: waVertVif, teinte: Color(hex: 0x062E1C), gras: true) {
                    creationVisible = true
                }
            }
            .padding(.horizontal, 16).padding(.top, 8)
            HStack {
                Text("Communautés").font(.system(size: 34, weight: .bold)).foregroundStyle(waTexte)
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 12)

            if magasin.communautes.isEmpty {
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
                    .contentShape(Capsule())
                    .onTapGesture { Haptique.leger(); creationVisible = true }
                Spacer()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(magasin.communautes, id: \.self) { c in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 12).fill(Color(hex: 0x1C242B))
                                    .frame(width: 52, height: 52)
                                    .overlay(Image(systemName: "person.3.fill").font(.system(size: 20)).foregroundStyle(waTexte2))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(c).font(.system(size: 17, weight: .semibold)).foregroundStyle(waTexte)
                                    HStack(spacing: 6) {
                                        Image(systemName: "megaphone.fill").font(.system(size: 11)).foregroundStyle(waVertDoux)
                                        Text("Annonces").font(.system(size: 14.5)).foregroundStyle(waTexte2)
                                    }
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
                        }
                        HStack(spacing: 10) {
                            Image(systemName: "plus").font(.system(size: 15, weight: .semibold))
                            Text("Nouvelle communauté").font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(waVertDoux)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 14))
                        .contentShape(Rectangle())
                        .onTapGesture { Haptique.leger(); creationVisible = true }
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 16).padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $creationVisible) { NouvelleCommunauteVue() }
    }
}

// v2 étape 3 — création de communauté (réelle, session)
struct NouvelleCommunauteVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var nom = ""
    var body: some View {
        NavigationStack {
            ZStack {
                waNoir.ignoresSafeArea()
                VStack(spacing: 18) {
                    RoundedRectangle(cornerRadius: 20).fill(Color(hex: 0x1C242B))
                        .frame(width: 90, height: 90)
                        .overlay(Image(systemName: "camera.fill").font(.system(size: 26)).foregroundStyle(waTexte2))
                        .padding(.top, 26)
                    TextField("", text: $nom,
                              prompt: Text("Nom de la communauté").foregroundStyle(waTexte2))
                        .font(.system(size: 17)).foregroundStyle(waTexte)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(Color(hex: 0x161717), in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                    Text("Exemples : votre quartier, votre école, vos collègues.")
                        .font(.system(size: 13.5)).foregroundStyle(waTexte2)
                    Spacer()
                }
            }
            .navigationTitle("Nouvelle communauté")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }.foregroundStyle(waVertDoux)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        let n = nom.trimmingCharacters(in: .whitespaces)
                        guard !n.isEmpty else { return }
                        Haptique.leger()
                        MagasinWA.partage.communautes.append(n)
                        dismiss()
                    }
                    .foregroundStyle(nom.trimmingCharacters(in: .whitespaces).isEmpty ? waTexte2 : waVertDoux)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// ============================================================ TRANSFERT — sélection de contact
struct TransfertContactVue: View {
    @Environment(\.dismiss) private var dismiss
    let texte: String
    let nomSource: String
    @State private var confirme: String? = nil
    private let destinataires = DonneesWA.fiches.keys.sorted()

    var body: some View {
        NavigationStack {
            ZStack {
                waNoir.ignoresSafeArea()
                List {
                    ForEach(destinataires, id: \.self) { nom in
                        if nom != nomSource {
                            HStack(spacing: 12) {
                                AvatarSilhouette(taille: 40)
                                Text(nom).font(.system(size: 17)).foregroundStyle(waTexte)
                            }
                            .listRowBackground(waNoir)
                            .listRowSeparatorTint(Color(hex: 0x222222))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Haptique.leger()
                                EnvoisJoueur.partage.ajouter(nom, .transfere(false, texte, DateFormatter().string(from: Date())))
                                confirme = nom
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                if let c = confirme {
                    Text("Transféré à \(c) ✓")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(waTexte)
                        .padding(.horizontal, 18).padding(.vertical, 10)
                        .background(Color(hex: 0x1C201E), in: Capsule())
                }
            }
            .navigationTitle("Transférer à")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }.foregroundStyle(waVertDoux)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
