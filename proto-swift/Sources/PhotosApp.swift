// App PHOTOS iOS 26 — construite contre refs-photos/ (vidéo réelle du 17/08, 244 s)
// Photothèque (grille + pilule de date + Années/Mois/Toutes), détail avec fiche technique,
// Recherche, Collections (Souvenirs, Épinglées, Albums, Personnes, Plan, Types, Autres),
// Masquées VERROUILLÉE (D57), Suppr. récemment OUVERTE (D57 — Sarah avait désactivé le verrou).
// La pellicule est un MANIFESTE DE DONNÉES (préfiguration ARCH-1) : les vagues d'images s'y ajoutent.
import SwiftUI
import MapKit

let phFond = Color(hex: 0x000000)
let phTexte = Color(hex: 0xF2F2F2)
let phTexte2 = Color(hex: 0x8E8E93)
let phCarte = Color(hex: 0x1C1C1E)
let phBleu = Color(hex: 0x0A84FF)

// ============================================================ MANIFESTE DE LA PELLICULE
struct PhotoItem: Identifiable {
    let id: String            // nom du fichier dans Ressources ("p01")
    let nomFichier: String    // "IMG_3021"
    let date: String          // "14 févr. 2025 · 20:12"
    let mois: String          // "Févr. 2025"
    let annee: String
    let lieu: String
    let legende: String       // sert la recherche
    let motsCles: [String]
    var favori: Bool = false
    var selfie: Bool = false
    var capture: Bool = false
    let iso: String
    let taille: String
}

enum DonneesPhotos {
    // Ordre chronologique (le plus ancien en premier, comme la vraie photothèque)
    static let toutes: [PhotoItem] = [
        PhotoItem(id: "p01", nomFichier: "IMG_2841", date: "14 févr. 2025 · 19:48", mois: "Févr. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Table d'anniversaire chez les parents",
                  motsCles: ["anniversaire", "maman", "famille", "table", "dîner"], iso: "ISO 250", taille: "2,1 Mo"),
        PhotoItem(id: "p02", nomFichier: "IMG_2844", date: "14 févr. 2025 · 21:03", mois: "Févr. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Maman souffle ses bougies 🎂",
                  motsCles: ["anniversaire", "maman", "gâteau", "bougies"], iso: "ISO 400", taille: "1,8 Mo"),
        PhotoItem(id: "p03", nomFichier: "IMG_2846", date: "14 févr. 2025 · 21:12", mois: "Févr. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Papa 😄",
                  motsCles: ["papa", "famille", "dîner", "vin"], iso: "ISO 320", taille: "1,7 Mo"),
        PhotoItem(id: "p04", nomFichier: "IMG_2851", date: "14 févr. 2025 · 21:40", mois: "Févr. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Avec maman ❤️",
                  motsCles: ["maman", "selfie", "famille", "anniversaire"], favori: true, selfie: true, iso: "ISO 500", taille: "1,6 Mo"),
        PhotoItem(id: "p05", nomFichier: "IMG_2853", date: "14 févr. 2025 · 21:55", mois: "Févr. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Le gâteau a survécu (presque)",
                  motsCles: ["gâteau", "anniversaire", "raté", "drôle"], iso: "ISO 400", taille: "1,9 Mo"),
        PhotoItem(id: "p06", nomFichier: "IMG_2967", date: "12 avr. 2025 · 11:20", mois: "Avr. 2025", annee: "2025",
                  lieu: "Parc de la Tête d'Or, Lyon", legende: "Le printemps est là",
                  motsCles: ["parc", "fleurs", "printemps", "lyon", "arbres"], iso: "ISO 32", taille: "3,4 Mo"),
        PhotoItem(id: "p07", nomFichier: "IMG_2969", date: "12 avr. 2025 · 11:47", mois: "Avr. 2025", annee: "2025",
                  lieu: "Parc de la Tête d'Or, Lyon", legende: "Avec Chloé au parc ☀️",
                  motsCles: ["chloé", "selfie", "parc", "amies", "lyon"], favori: false, selfie: true, iso: "ISO 25", taille: "1,8 Mo"),
        PhotoItem(id: "p08", nomFichier: "IMG_2972", date: "12 avr. 2025 · 12:05", mois: "Avr. 2025", annee: "2025",
                  lieu: "Parc de la Tête d'Or, Lyon", legende: "Chloé vs les cygnes 😂",
                  motsCles: ["chloé", "cygnes", "parc", "drôle", "lac"], iso: "ISO 40", taille: "2,2 Mo"),
        PhotoItem(id: "p09", nomFichier: "IMG_2974", date: "12 avr. 2025 · 12:30", mois: "Avr. 2025", annee: "2025",
                  lieu: "Parc de la Tête d'Or, Lyon", legende: "Pistache-fraise, comme toujours",
                  motsCles: ["glace", "parc", "été", "gourmandise"], iso: "ISO 25", taille: "1,6 Mo"),
        PhotoItem(id: "p10", nomFichier: "IMG_3021", date: "12 mai 2025 · 19:02", mois: "Mai 2025", annee: "2025",
                  lieu: "Quais de Saône, Lyon", legende: "Golden hour sur les quais",
                  motsCles: ["quais", "saône", "lyon", "coucher de soleil", "photo"], iso: "ISO 50", taille: "3,1 Mo"),
        PhotoItem(id: "p11", nomFichier: "IMG_3024", date: "12 mai 2025 · 19:15", mois: "Mai 2025", annee: "2025",
                  lieu: "Quais de Saône, Lyon", legende: "Essai reflets — pas si mal ?",
                  motsCles: ["quais", "péniche", "reflets", "photo"], iso: "ISO 64", taille: "2,8 Mo"),
        PhotoItem(id: "p12", nomFichier: "IMG_3025", date: "12 mai 2025 · 19:21", mois: "Mai 2025", annee: "2025",
                  lieu: "Quais de Saône, Lyon", legende: "La photographe au travail 📷",
                  motsCles: ["selfie", "quais", "appareil photo", "photo"], selfie: true, iso: "ISO 40", taille: "1,7 Mo"),
        PhotoItem(id: "p13", nomFichier: "IMG_3029", date: "12 mai 2025 · 19:40", mois: "Mai 2025", annee: "2025",
                  lieu: "Croix-Rousse, Lyon", legende: "Les façades de la Croix-Rousse",
                  motsCles: ["architecture", "croix-rousse", "façades", "photo"], iso: "ISO 80", taille: "2,9 Mo"),
        PhotoItem(id: "p14", nomFichier: "IMG_3031", date: "12 mai 2025 · 19:58", mois: "Mai 2025", annee: "2025",
                  lieu: "Quais de Saône, Lyon", legende: "Pose longue ratée 😅",
                  motsCles: ["flou", "essai", "quais", "photo", "raté"], iso: "ISO 320", taille: "2,2 Mo"),
        PhotoItem(id: "p15", nomFichier: "IMG_3186", date: "19 juil. 2025 · 21:34", mois: "Juil. 2025", annee: "2025",
                  lieu: "Décines-Charpieu, Rhône", legende: "Le plus beau soir de l'été ✨",
                  motsCles: ["festival", "chloé", "concert", "musique", "été", "soir"], favori: true, selfie: true, iso: "ISO 640", taille: "1,4 Mo"),
        PhotoItem(id: "p16", nomFichier: "IMG_3187", date: "19 juil. 2025 · 21:52", mois: "Juil. 2025", annee: "2025",
                  lieu: "Décines-Charpieu, Rhône", legende: "LE son de l'été 🎶",
                  motsCles: ["festival", "concert", "scène", "musique", "été"], iso: "ISO 800", taille: "1,9 Mo"),
        PhotoItem(id: "p17", nomFichier: "IMG_3190", date: "19 juil. 2025 · 22:15", mois: "Juil. 2025", annee: "2025",
                  lieu: "Décines-Charpieu, Rhône", legende: "Au cœur de la fosse",
                  motsCles: ["festival", "foule", "concert", "été"], iso: "ISO 1000", taille: "1,8 Mo"),
        PhotoItem(id: "p18", nomFichier: "IMG_3195", date: "19 juil. 2025 · 22:41", mois: "Juil. 2025", annee: "2025",
                  lieu: "Décines-Charpieu, Rhône", legende: "Paillettes obligatoires ✨",
                  motsCles: ["festival", "chloé", "selfie", "paillettes", "été"], selfie: true, iso: "ISO 640", taille: "1,5 Mo"),
        PhotoItem(id: "p19", nomFichier: "IMG_3201", date: "19 juil. 2025 · 23:30", mois: "Juil. 2025", annee: "2025",
                  lieu: "Décines-Charpieu, Rhône", legende: "Le final 🎆",
                  motsCles: ["festival", "feu d'artifice", "concert", "nuit"], iso: "ISO 500", taille: "2,0 Mo"),
        PhotoItem(id: "p20", nomFichier: "IMG_3218", date: "24 août 2025 · 10:34", mois: "Août 2025", annee: "2025",
                  lieu: "Lyon 1er", legende: "Dimanche parfait",
                  motsCles: ["café", "terrasse", "croissant", "brunch"], iso: "ISO 25", taille: "2,4 Mo"),
        PhotoItem(id: "p21", nomFichier: "IMG_3225", date: "31 août 2025 · 16:02", mois: "Août 2025", annee: "2025",
                  lieu: "Lyon 1er", legende: "Home sweet home",
                  motsCles: ["appartement", "salon", "maison", "plante"], iso: "ISO 125", taille: "2,6 Mo"),
        PhotoItem(id: "p22", nomFichier: "IMG_3231", date: "7 sept. 2025 · 20:11", mois: "Sept. 2025", annee: "2025",
                  lieu: "Lyon 1er", legende: "Le gratin de mamie, réussi du premier coup 👩‍🍳",
                  motsCles: ["cuisine", "gratin", "recette", "maison"], iso: "ISO 200", taille: "2,1 Mo"),
        PhotoItem(id: "p23", nomFichier: "IMG_3236", date: "14 sept. 2025 · 11:47", mois: "Sept. 2025", annee: "2025",
                  lieu: "Lyon 1er", legende: "Prête pour le brunch",
                  motsCles: ["selfie", "miroir", "tenue"], selfie: true, iso: "ISO 160", taille: "1,6 Mo"),
        PhotoItem(id: "p24", nomFichier: "IMG_3240", date: "21 sept. 2025 · 20:26", mois: "Sept. 2025", annee: "2025",
                  lieu: "Lyon 1er", legende: "La vue ne vieillit jamais",
                  motsCles: ["toits", "lyon", "fenêtre", "coucher de soleil", "fourvière"], iso: "ISO 100", taille: "2,7 Mo"),
        PhotoItem(id: "p25", nomFichier: "IMG_3247", date: "12 oct. 2025 · 11:15", mois: "Oct. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Le jardinier en chef 🌱",
                  motsCles: ["papa", "jardin", "famille", "potager"], iso: "ISO 64", taille: "2,5 Mo"),
        PhotoItem(id: "p26", nomFichier: "IMG_3249", date: "12 oct. 2025 · 12:38", mois: "Oct. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Le poulet du dimanche",
                  motsCles: ["famille", "repas", "dimanche", "table"], iso: "ISO 250", taille: "2,2 Mo"),
        PhotoItem(id: "p27", nomFichier: "IMG_3252", date: "12 oct. 2025 · 12:50", mois: "Oct. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "La cheffe ❤️",
                  motsCles: ["maman", "cuisine", "famille"], iso: "ISO 320", taille: "1,9 Mo"),
        PhotoItem(id: "p28", nomFichier: "IMG_3253", date: "12 oct. 2025 · 15:04", mois: "Oct. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "LE tupperware bleu (à rendre sous peine de mort)",
                  motsCles: ["tupperware", "maman", "restes", "drôle", "famille"], iso: "ISO 200", taille: "1,8 Mo"),
        PhotoItem(id: "p29", nomFichier: "IMG_3259", date: "15 nov. 2025 · 10:20", mois: "Nov. 2025", annee: "2025",
                  lieu: "Parc de la Tête d'Or, Lyon", legende: "L'automne fait bien les choses",
                  motsCles: ["parc", "automne", "feuilles", "photo", "brume"], iso: "ISO 125", taille: "3,0 Mo"),
        PhotoItem(id: "p30", nomFichier: "IMG_3262", date: "15 nov. 2025 · 15:33", mois: "Nov. 2025", annee: "2025",
                  lieu: "Lyon 1er", legende: "Débrief de la semaine ☕️",
                  motsCles: ["chloé", "café", "amies", "automne"], iso: "ISO 250", taille: "1,8 Mo"),
        PhotoItem(id: "p31", nomFichier: "IMG_3264", date: "15 nov. 2025 · 16:41", mois: "Nov. 2025", annee: "2025",
                  lieu: "Quais du Rhône, Lyon", legende: "Novembre sur les quais",
                  motsCles: ["quais", "automne", "feuilles", "photo"], iso: "ISO 160", taille: "2,6 Mo"),
        PhotoItem(id: "p32", nomFichier: "IMG_3267", date: "15 nov. 2025 · 16:58", mois: "Nov. 2025", annee: "2025",
                  lieu: "Quais du Rhône, Lyon", legende: "Elle me fait toujours autant rire 😂",
                  motsCles: ["chloé", "amies", "rire", "banc", "complicité"], favori: true, iso: "ISO 200", taille: "1,9 Mo"),
        PhotoItem(id: "p33", nomFichier: "IMG_3271", date: "24 déc. 2025 · 18:47", mois: "Déc. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Le sapin de maman, égal à lui-même",
                  motsCles: ["noël", "sapin", "famille", "fêtes"], iso: "ISO 400", taille: "2,3 Mo"),
        PhotoItem(id: "p34", nomFichier: "IMG_3274", date: "24 déc. 2025 · 20:30", mois: "Déc. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Réveillon 🎄",
                  motsCles: ["noël", "réveillon", "famille", "table", "fêtes"], iso: "ISO 500", taille: "2,1 Mo"),
        PhotoItem(id: "p35", nomFichier: "IMG_3276", date: "25 déc. 2025 · 14:12", mois: "Déc. 2025", annee: "2025",
                  lieu: "Theizé, Rhône", legende: "Noël avec mes deux préférés ❤️",
                  motsCles: ["noël", "famille", "maman", "papa", "selfie"], selfie: true, iso: "ISO 320", taille: "1,7 Mo"),
        PhotoItem(id: "p36", nomFichier: "IMG_3280", date: "31 déc. 2025 · 23:05", mois: "Déc. 2025", annee: "2025",
                  lieu: "Lyon 3e", legende: "Les filles 💃 Prêtes pour 2026",
                  motsCles: ["nouvel an", "julie", "chloé", "amies", "fête"], iso: "ISO 640", taille: "1,8 Mo"),
        PhotoItem(id: "p37", nomFichier: "IMG_3283", date: "31 déc. 2025 · 23:58", mois: "Déc. 2025", annee: "2025",
                  lieu: "Lyon 3e", legende: "3… 2… 1…",
                  motsCles: ["nouvel an", "champagne", "fête", "amies"], iso: "ISO 800", taille: "1,6 Mo"),
        PhotoItem(id: "p38", nomFichier: "IMG_3284", date: "1 janv. 2026 · 00:00", mois: "Janv. 2026", annee: "2026",
                  lieu: "Lyon 3e", legende: "BONNE ANNÉE 🎉 (floue mais parfaite)",
                  motsCles: ["nouvel an", "julie", "chloé", "amies", "selfie", "flou"], selfie: true, iso: "ISO 1000", taille: "1,4 Mo"),
        PhotoItem(id: "p39", nomFichier: "IMG_3295", date: "12 mars 2026 · 21:12", mois: "Mars 2026", annee: "2026",
                  lieu: "—", legende: "Capture d'écran — profil Meetic",
                  motsCles: ["capture", "meetic", "marc", "profil"], capture: true, iso: "—", taille: "1,1 Mo"),
        PhotoItem(id: "p69", nomFichier: "IMG_3298", date: "26 mars 2026 · 14:12", mois: "Mars 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "Nouvelle photo de profil ?",
                  motsCles: ["selfie", "portrait", "café", "profil"], selfie: true, iso: "ISO 100", taille: "1,3 Mo"),
        PhotoItem(id: "p40", nomFichier: "IMG_3305", date: "11 avr. 2026 · 14:22", mois: "Avr. 2026", annee: "2026",
                  lieu: "Lyon 2e", legende: "Nouvelle robe… il va adorer",
                  motsCles: ["selfie", "robe", "shopping", "miroir"], selfie: true, iso: "ISO 200", taille: "1,7 Mo"),
        PhotoItem(id: "p41", nomFichier: "IMG_3309", date: "18 avr. 2026 · 19:50", mois: "Avr. 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "Ce soir on se fait belle",
                  motsCles: ["selfie", "maquillage", "soirée"], selfie: true, iso: "ISO 250", taille: "1,5 Mo"),
        PhotoItem(id: "p42", nomFichier: "IMG_3312", date: "25 avr. 2026 · 16:36", mois: "Avr. 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "Merci Julien pour le brushing ✨",
                  motsCles: ["selfie", "coiffeur", "cheveux"], selfie: true, iso: "ISO 320", taille: "1,6 Mo"),
        PhotoItem(id: "p49", nomFichier: "IMG_3334", date: "3 mai 2026 · 22:41", mois: "Mai 2026", annee: "2026",
                  lieu: "—", legende: "Marc ❤️",
                  motsCles: ["marc", "marin", "bateau", "uniforme"], favori: true, iso: "—", taille: "212 Ko"),
        PhotoItem(id: "p43", nomFichier: "IMG_3341", date: "9 mai 2026 · 11:05", mois: "Mai 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "Livrées ce matin. « Pour la reine de mon cœur »",
                  motsCles: ["fleurs", "roses", "bouquet", "marc", "cadeau"], iso: "ISO 125", taille: "2,2 Mo"),
        PhotoItem(id: "p44", nomFichier: "IMG_3342", date: "9 mai 2026 · 11:12", mois: "Mai 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "Il m'envoie des fleurs depuis l'autre bout du monde ❤️",
                  motsCles: ["selfie", "fleurs", "roses", "marc", "bonheur"], selfie: true, iso: "ISO 160", taille: "1,6 Mo"),
        PhotoItem(id: "p45", nomFichier: "IMG_3347", date: "11 mai 2026 · 21:18", mois: "Mai 2026", annee: "2026",
                  lieu: "—", legende: "Le coucher de soleil depuis le pont ❤️",
                  motsCles: ["marc", "coucher de soleil", "mer", "bateau"], favori: true, iso: "—", taille: "486 Ko"),
        PhotoItem(id: "p46", nomFichier: "IMG_3352", date: "24 mai 2026 · 22:02", mois: "Mai 2026", annee: "2026",
                  lieu: "—", legende: "Sa mer à lui",
                  motsCles: ["marc", "coucher de soleil", "mer", "bateau"], iso: "—", taille: "412 Ko"),
        PhotoItem(id: "p47", nomFichier: "IMG_3358", date: "3 juin 2026 · 21:47", mois: "Juin 2026", annee: "2026",
                  lieu: "—", legende: "« Il ne manque que toi »",
                  motsCles: ["marc", "coucher de soleil", "mer", "ciel"], iso: "—", taille: "437 Ko"),
        PhotoItem(id: "p48", nomFichier: "IMG_3363", date: "12 juin 2026 · 22:15", mois: "Juin 2026", annee: "2026",
                  lieu: "—", legende: "Le dernier rayon 🌅",
                  motsCles: ["marc", "coucher de soleil", "mer", "nuit"], iso: "—", taille: "358 Ko"),
        PhotoItem(id: "p67", nomFichier: "IMG_3364", date: "13 juin 2026 · 16:40", mois: "Juin 2026", annee: "2026",
                  lieu: "—", legende: "Capture d'écran — reçu Western Union",
                  motsCles: ["capture", "western union", "transfert", "argent"], capture: true, iso: "—", taille: "512 Ko"),
        PhotoItem(id: "p50", nomFichier: "IMG_3365", date: "14 juin 2026 · 23:20", mois: "Juin 2026", annee: "2026",
                  lieu: "—", legende: "Mon officier ⚓️",
                  motsCles: ["marc", "marin", "bateau", "uniforme"], iso: "—", taille: "198 Ko"),
        PhotoItem(id: "p51", nomFichier: "IMG_3369", date: "21 juin 2026 · 17:42", mois: "Juin 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "",
                  motsCles: ["pluie", "fenêtre", "gris"], iso: "ISO 250", taille: "2,4 Mo"),
        PhotoItem(id: "p52", nomFichier: "IMG_3372", date: "28 juin 2026 · 20:54", mois: "Juin 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "",
                  motsCles: ["repas", "soir"], iso: "ISO 500", taille: "1,9 Mo"),
        PhotoItem(id: "p53", nomFichier: "IMG_3375", date: "4 juil. 2026 · 01:13", mois: "Juil. 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "",
                  motsCles: ["nuit", "insomnie"], iso: "ISO 3200", taille: "1,2 Mo"),
        PhotoItem(id: "p54", nomFichier: "IMG_3376", date: "5 juil. 2026 · 20:32", mois: "Juil. 2026", annee: "2026",
                  lieu: "—", legende: "Capture d'écran — appel vidéo",
                  motsCles: ["capture", "marc", "visio", "appel"], capture: true, iso: "—", taille: "486 Ko"),
        PhotoItem(id: "p55", nomFichier: "IMG_3378", date: "9 juil. 2026 · 14:05", mois: "Juil. 2026", annee: "2026",
                  lieu: "Lyon 4e", legende: "L'attente…",
                  motsCles: ["kiné", "salle d'attente", "santé"], iso: "ISO 320", taille: "2,0 Mo"),
        PhotoItem(id: "p56", nomFichier: "IMG_3379", date: "9 juil. 2026 · 15:22", mois: "Juil. 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "Le programme des 3 prochaines semaines 🙃",
                  motsCles: ["kiné", "ordonnance", "genouillère", "santé"], iso: "ISO 200", taille: "1,8 Mo"),
        PhotoItem(id: "p66", nomFichier: "IMG_3381", date: "17 juil. 2026 · 09:12", mois: "Juil. 2026", annee: "2026",
                  lieu: "—", legende: "Capture d'écran — WhatsApp",
                  motsCles: ["capture", "whatsapp", "marc", "argent"], capture: true, iso: "—", taille: "894 Ko"),
        PhotoItem(id: "p61", nomFichier: "IMG_3384", date: "9 août 2026 · 15:30", mois: "Août 2026", annee: "2026",
                  lieu: "Quais de Saône, Lyon", legende: "",
                  motsCles: ["quais", "gris", "photo"], iso: "ISO 100", taille: "2,5 Mo"),
        PhotoItem(id: "p62", nomFichier: "IMG_3386", date: "9 août 2026 · 15:47", mois: "Août 2026", annee: "2026",
                  lieu: "Quais de Saône, Lyon", legende: "",
                  motsCles: ["banc", "quais", "pigeons"], iso: "ISO 125", taille: "2,3 Mo"),
        PhotoItem(id: "p63", nomFichier: "IMG_3387", date: "9 août 2026 · 15:52", mois: "Août 2026", annee: "2026",
                  lieu: "Quais de Saône, Lyon", legende: "",
                  motsCles: ["reflet", "eau", "gris"], iso: "ISO 100", taille: "2,2 Mo"),
        PhotoItem(id: "p64", nomFichier: "IMG_3390", date: "12 août 2026 · 09:41", mois: "Août 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "",
                  motsCles: ["document", "carte"], iso: "ISO 400", taille: "1,4 Mo"),
        PhotoItem(id: "p58", nomFichier: "IMG_3391", date: "12 août 2026 · 09:44", mois: "Août 2026", annee: "2026",
                  lieu: "—", legende: "Capture d'écran — RIB",
                  motsCles: ["capture", "rib", "banque", "lcl"], capture: true, iso: "—", taille: "428 Ko"),
        PhotoItem(id: "p59", nomFichier: "IMG_3393", date: "16 août 2026 · 09:30", mois: "Août 2026", annee: "2026",
                  lieu: "—", legende: "Capture d'écran — SMS",
                  motsCles: ["capture", "sms", "banque", "sécurité"], capture: true, iso: "—", taille: "402 Ko"),
        PhotoItem(id: "p57", nomFichier: "IMG_3394", date: "16 août 2026 · 18:12", mois: "Août 2026", annee: "2026",
                  lieu: "—", legende: "Capture d'écran — virement",
                  motsCles: ["capture", "virement", "banque", "lcl", "argent"], capture: true, iso: "—", taille: "631 Ko"),
        PhotoItem(id: "p60", nomFichier: "IMG_3395", date: "16 août 2026 · 22:47", mois: "Août 2026", annee: "2026",
                  lieu: "—", legende: "Capture d'écran — Notes",
                  motsCles: ["capture", "note", "documents", "banque"], capture: true, iso: "—", taille: "398 Ko"),
        PhotoItem(id: "p65", nomFichier: "IMG_3392", date: "15 août 2026 · 21:08", mois: "Août 2026", annee: "2026",
                  lieu: "Lyon 1er", legende: "",
                  motsCles: ["fenêtre", "soir", "attente"], iso: "ISO 640", taille: "1,6 Mo"),
        PhotoItem(id: "p68", nomFichier: "IMG_3396", date: "16 août 2026 · 23:12", mois: "Août 2026", annee: "2026",
                  lieu: "—", legende: "Capture d'écran — Safari",
                  motsCles: ["capture", "safari", "recherche"], capture: true, iso: "—", taille: "917 Ko"),
    ]

    static func parMois() -> [(String, [PhotoItem])] {
        var ordre: [String] = []
        var groupes: [String: [PhotoItem]] = [:]
        for p in toutes {
            if groupes[p.mois] == nil { ordre.append(p.mois) }
            groupes[p.mois, default: []].append(p)
        }
        return ordre.map { ($0, groupes[$0]!) }
    }

    static func parAnnee() -> [(String, [PhotoItem])] {
        var ordre: [String] = []
        var groupes: [String: [PhotoItem]] = [:]
        for p in toutes {
            if groupes[p.annee] == nil { ordre.append(p.annee) }
            groupes[p.annee, default: []].append(p)
        }
        return ordre.map { ($0, groupes[$0]!) }
    }
}

// Chargeur d'images de la pellicule (Ressources/, avec repli sous-dossier — même piège que l'audio)
enum ChargeurPhoto {
    private static var cache: [String: UIImage] = [:]
    static func image(_ nom: String) -> UIImage? {
        if let c = cache[nom] { return c }
        let url = Bundle.main.url(forResource: nom, withExtension: "jpg")
            ?? Bundle.main.url(forResource: nom, withExtension: "jpg", subdirectory: "Ressources")
        guard let url, let img = UIImage(contentsOfFile: url.path) else { return nil }
        cache[nom] = img
        return img
    }
}

// État vivant de la pellicule (favoris, suppressions, légendes du joueur)
final class MagasinPhotos: ObservableObject {
    static let partage = MagasinPhotos()
    @Published var favoris: Set<String> = Set(DonneesPhotos.toutes.filter { $0.favori }.map { $0.id })
    @Published var supprimees: Set<String> = ["p66", "p67", "p68"]

    var visibles: [PhotoItem] { DonneesPhotos.toutes.filter { !supprimees.contains($0.id) } }
    var lesFavoris: [PhotoItem] { visibles.filter { favoris.contains($0.id) } }
    var corbeille: [PhotoItem] { DonneesPhotos.toutes.filter { supprimees.contains($0.id) } }
}

// ============================================================ RACINE
struct PhotosVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onglet = Int(ProcessInfo.processInfo.environment["ONGLET"] ?? "") ?? 0
    @State private var rechercheVisible = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                phFond.ignoresSafeArea()
                Group {
                    if onglet == 0 { PhototequeVue() } else { CollectionsPhotosVue() }
                }

                HStack(spacing: 10) {
                    HStack(spacing: 0) {
                        OngletPhotos(symbole: "photo.on.rectangle", nom: "Photothèque", actif: onglet == 0) { onglet = 0 }
                        OngletPhotos(symbole: "square.stack", nom: "Collections", actif: onglet == 1) { onglet = 1 }
                    }
                    .padding(.vertical, 8).padding(.horizontal, 8)
                    .background(Color(hex: 0x1D1D1D), in: Capsule())
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18)).foregroundStyle(phTexte)
                        .padding(13).background(Color(hex: 0x1D1D1D), in: Circle())
                        .onTapGesture { Haptique.leger(); rechercheVisible = true }
                }
                .padding(.bottom, 6)

            BarreHome { dismiss() }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $rechercheVisible) { RecherchePhotosVue() }
        }
        .preferredColorScheme(.dark)
    }
}

struct OngletPhotos: View {
    let symbole: String
    let nom: String
    let actif: Bool
    let action: () -> Void
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbole).font(.system(size: 19))
                .foregroundStyle(actif ? phBleu : phTexte2)
            Text(nom).font(.system(size: 10, weight: actif ? .semibold : .regular))
                .foregroundStyle(actif ? phBleu : phTexte2)
        }
        .padding(.horizontal, 16).padding(.vertical, 4)
        .background(actif ? Color(hex: 0x303030) : .clear, in: Capsule())
        .contentShape(Rectangle())
        .onTapGesture { Haptique.leger(); action() }
    }
}

// ============================================================ PHOTOTHÈQUE
struct PhototequeVue: View {
    @ObservedObject private var magasin = MagasinPhotos.partage
    @State private var portee = 2 // 0 Années, 1 Mois, 2 Toutes
    @State private var moisVisible = ""
    @State private var photoOuverte: PhotoItem? = nil

    private let colonnes = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // En-tête
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Photothèque").font(.system(size: 26, weight: .bold)).foregroundStyle(phTexte)
                        HStack(spacing: 4) {
                            Image(systemName: "icloud.slash").font(.system(size: 11))
                            Text("Synchronisation suspendue")
                            Image(systemName: "chevron.right").font(.system(size: 9, weight: .semibold))
                        }
                        .font(.system(size: 12.5)).foregroundStyle(phTexte2)
                    }
                    Spacer()
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(phTexte)
                        .padding(10).background(phCarte, in: Circle())
                    Text("Sélect.").font(.system(size: 15)).foregroundStyle(phTexte)
                        .padding(.horizontal, 13).padding(.vertical, 8)
                        .background(phCarte, in: Capsule())
                }
                .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)

                switch portee {
                case 0: vueAnnees
                case 1: vueMois
                default: vueToutes
                }
            }

            // Pilule de date flottante (suit le scroll)
            if portee == 2 && !moisVisible.isEmpty {
                Text(moisVisible)
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(phTexte)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 74)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .bottom) {
            // Segments Années / Mois / Toutes
            HStack(spacing: 0) {
                SegmentPhotos(nom: "Années", actif: portee == 0) { portee = 0 }
                SegmentPhotos(nom: "Mois", actif: portee == 1) { portee = 1 }
                SegmentPhotos(nom: "Toutes", actif: portee == 2) { portee = 2 }
            }
            .padding(4)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 74)
        }
        .fullScreenCover(item: $photoOuverte) { photo in
            PhotoDetailVue(depart: photo)
        }
    }

    private var vueToutes: some View {
        ScrollViewReader { lecteur in
            ScrollView {
                LazyVGrid(columns: colonnes, spacing: 2) {
                    ForEach(magasin.visibles) { p in
                        TuilePhoto(item: p)
                            .onAppear { moisVisible = p.mois }
                            .onTapGesture { Haptique.leger(); photoOuverte = p }
                            .id(p.id)
                    }
                }
                Color.clear.frame(height: 130).id("bas")
            }
            .scrollIndicators(.hidden)
            .onAppear { lecteur.scrollTo("bas", anchor: .bottom) }
        }
    }

    private var vueMois: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ForEach(DonneesPhotos.parMois(), id: \.0) { mois, items in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mois).font(.system(size: 22, weight: .bold)).foregroundStyle(phTexte)
                            .padding(.horizontal, 16)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 2), spacing: 2) {
                            ForEach(items.filter { !magasin.supprimees.contains($0.id) }) { p in
                                TuilePhoto(item: p, ratio: 1.0)
                                    .onTapGesture { Haptique.leger(); photoOuverte = p }
                            }
                        }
                    }
                }
                Color.clear.frame(height: 130)
            }
            .padding(.top, 6)
        }
        .scrollIndicators(.hidden)
    }

    private var vueAnnees: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(DonneesPhotos.parAnnee(), id: \.0) { annee, items in
                    ZStack(alignment: .topLeading) {
                        if let img = ChargeurPhoto.image(items.first!.id) {
                            Image(uiImage: img).resizable().scaledToFill()
                                .frame(height: 220).clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [.black.opacity(0.45), .clear],
                                                         startPoint: .top, endPoint: .center)))
                        }
                        Text(annee).font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            .padding(14)
                    }
                    .padding(.horizontal, 16)
                }
                Color.clear.frame(height: 130)
            }
            .padding(.top, 6)
        }
        .scrollIndicators(.hidden)
    }
}

struct SegmentPhotos: View {
    let nom: String
    let actif: Bool
    let action: () -> Void
    var body: some View {
        Text(nom).font(.system(size: 14, weight: .semibold))
            .foregroundStyle(actif ? .black : phTexte)
            .padding(.horizontal, 16).padding(.vertical, 7)
            .background(actif ? Color(hex: 0xE8E8E8) : .clear, in: Capsule())
            .contentShape(Capsule())
            .onTapGesture { Haptique.leger(); action() }
    }
}

struct TuilePhoto: View {
    let item: PhotoItem
    var ratio: CGFloat = 1.0
    var body: some View {
        GeometryReader { geo in
            if let img = ChargeurPhoto.image(item.id) {
                Image(uiImage: img)
                    .resizable().scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.width * ratio)
                    .clipped()
            } else {
                Rectangle().fill(phCarte)
                    .overlay(Image(systemName: "photo").foregroundStyle(phTexte2))
            }
        }
        .aspectRatio(1/ratio, contentMode: .fit)
        .overlay(alignment: .bottomLeading) {
            if MagasinPhotos.partage.favoris.contains(item.id) {
                Image(systemName: "heart.fill").font(.system(size: 11)).foregroundStyle(.white)
                    .shadow(radius: 2).padding(5)
            }
        }
    }
}

// ============================================================ DÉTAIL PHOTO
struct PhotoDetailVue: View {
    @Environment(\.dismiss) private var dismiss
    let depart: PhotoItem
    @ObservedObject private var magasin = MagasinPhotos.partage
    @State private var courante: String = ""
    @State private var infosVisibles = false
    @State private var confirmationSuppr = false
    @State private var partageErreur = false

    private var items: [PhotoItem] { magasin.visibles }
    private var item: PhotoItem { items.first(where: { $0.id == courante }) ?? depart }

    var body: some View {
        ZStack {
            phFond.ignoresSafeArea()
            VStack(spacing: 0) {
                // Barre du haut : retour, pilule date, menu
                HStack {
                    Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(phTexte)
                        .padding(10).contentShape(Rectangle())
                        .onTapGesture { dismiss() }
                    Spacer()
                    VStack(spacing: 1) {
                        Text(String(item.date.split(separator: "·").first ?? ""))
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(phTexte)
                        Text(String(item.date.split(separator: "·").last ?? ""))
                            .font(.system(size: 11)).foregroundStyle(phTexte2)
                    }
                    Spacer()
                    Image(systemName: "ellipsis").font(.system(size: 17)).foregroundStyle(phTexte)
                        .padding(10).background(phCarte, in: Circle())
                        .onTapGesture { infosVisibles = true }
                }
                .padding(.horizontal, 8)

                // Pagination entre photos
                TabView(selection: $courante) {
                    ForEach(items) { p in
                        Group {
                            if let img = ChargeurPhoto.image(p.id) {
                                Image(uiImage: img).resizable().scaledToFit()
                            }
                        }
                        .tag(p.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Vignettes
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 3) {
                        ForEach(items) { p in
                            if let img = ChargeurPhoto.image(p.id) {
                                Image(uiImage: img).resizable().scaledToFill()
                                    .frame(width: p.id == courante ? 34 : 24, height: 40).clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .onTapGesture { withAnimation { courante = p.id } }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 48)

                // Barre d'actions
                HStack {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 19)).foregroundStyle(phTexte)
                        .padding(10).contentShape(Rectangle())
                        .onTapGesture { partageErreur = true }
                    Spacer()
                    Image(systemName: magasin.favoris.contains(item.id) ? "heart.fill" : "heart")
                        .font(.system(size: 19))
                        .foregroundStyle(magasin.favoris.contains(item.id) ? Color(hex: 0xFF453A) : phTexte)
                        .padding(10).contentShape(Rectangle())
                        .onTapGesture {
                            Haptique.leger()
                            if magasin.favoris.contains(item.id) { magasin.favoris.remove(item.id) }
                            else { magasin.favoris.insert(item.id) }
                        }
                    Spacer()
                    Image(systemName: "info.circle").font(.system(size: 19)).foregroundStyle(phTexte)
                        .padding(10).contentShape(Rectangle())
                        .onTapGesture { infosVisibles = true }
                    Spacer()
                    Image(systemName: "slider.horizontal.3").font(.system(size: 19)).foregroundStyle(phTexte2)
                        .padding(10)
                    Spacer()
                    Image(systemName: "trash").font(.system(size: 19)).foregroundStyle(phTexte)
                        .padding(10).contentShape(Rectangle())
                        .onTapGesture { confirmationSuppr = true }
                }
                .padding(.horizontal, 14).padding(.bottom, 6)
            }
        }
        .onAppear { courante = depart.id }
        .sheet(isPresented: $infosVisibles) { FichePhotoVue(item: item) }
        .confirmationDialog("Supprimer la photo ?", isPresented: $confirmationSuppr, titleVisibility: .visible) {
            Button("Supprimer la photo", role: .destructive) {
                magasin.supprimees.insert(item.id)
                if magasin.visibles.isEmpty { dismiss() }
                else { courante = magasin.visibles.last!.id }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette photo sera conservée 30 jours dans Suppr. récemment.")
        }
        .sheet(isPresented: $partageErreur) { FeuillePartage(element: "1 photo") }
    }
}

struct FichePhotoVue: View {
    @Environment(\.dismiss) private var dismiss
    let item: PhotoItem
    var body: some View {
        NavigationStack {
            ZStack {
                phFond.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(item.legende.isEmpty ? "Ajouter une légende" : item.legende)
                            .font(.system(size: 15))
                            .foregroundStyle(item.legende.isEmpty ? phTexte2 : phTexte)
                            .padding(.top, 8)
                        HStack {
                            Text(item.date).font(.system(size: 15, weight: .semibold)).foregroundStyle(phTexte)
                            Spacer()
                            Text("Ajuster").font(.system(size: 14)).foregroundStyle(phBleu)
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo").foregroundStyle(phTexte2)
                                Text(item.nomFichier).font(.system(size: 14.5)).foregroundStyle(phTexte)
                                Text("HEIF").font(.system(size: 10, weight: .bold)).foregroundStyle(phTexte2)
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(Color(hex: 0x3A3A3E), in: RoundedRectangle(cornerRadius: 4))
                                Spacer()
                            }
                            Divider().overlay(Color.white.opacity(0.1))
                            Text("Apple iPhone 15 — 26 mm ƒ1,6").font(.system(size: 14)).foregroundStyle(phTexte)
                            Text("12 MP · 3024 × 4032 · \(item.taille)").font(.system(size: 13)).foregroundStyle(phTexte2)
                            HStack(spacing: 14) {
                                Text(item.iso).font(.system(size: 12.5)).foregroundStyle(phTexte2)
                                Text("26 mm").font(.system(size: 12.5)).foregroundStyle(phTexte2)
                                Text("0 ev").font(.system(size: 12.5)).foregroundStyle(phTexte2)
                                Text("ƒ1,6").font(.system(size: 12.5)).foregroundStyle(phTexte2)
                            }
                        }
                        .padding(14)
                        .background(phCarte, in: RoundedRectangle(cornerRadius: 12))
                        if item.lieu != "—" {
                            HStack {
                                Image(systemName: "mappin.circle.fill").foregroundStyle(phTexte2)
                                Text(item.lieu).font(.system(size: 14.5)).foregroundStyle(phTexte)
                                Spacer()
                            }
                            .padding(14)
                            .background(phCarte, in: RoundedRectangle(cornerRadius: 12))
                        } else {
                            Text("Ajouter un lieu…").font(.system(size: 14.5)).foregroundStyle(phBleu)
                                .padding(.horizontal, 4)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Infos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }.foregroundStyle(phBleu)
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
    }
}

// ============================================================ RECHERCHE
struct RecherchePhotosVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var saisie = ""
    @FocusState private var focalise: Bool
    @State private var photoOuverte: PhotoItem? = nil

    private var resultats: [PhotoItem] {
        guard !saisie.isEmpty else { return [] }
        return MagasinPhotos.partage.visibles.filter { p in
            p.legende.localizedCaseInsensitiveContains(saisie)
            || p.lieu.localizedCaseInsensitiveContains(saisie)
            || p.motsCles.contains(where: { $0.localizedCaseInsensitiveContains(saisie) })
        }
    }

    var body: some View {
        ZStack {
            phFond.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Recherche").font(.system(size: 26, weight: .bold)).foregroundStyle(phTexte)
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.top, 14)
                HStack(spacing: 4) {
                    Text("Certains résultats peuvent ne pas apparaître.")
                        .font(.system(size: 12.5)).foregroundStyle(phTexte2)
                    Image(systemName: "info.circle").font(.system(size: 11)).foregroundStyle(phTexte2)
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.top, 2)

                if saisie.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Suggestions").font(.system(size: 15, weight: .semibold)).foregroundStyle(phTexte)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(["Chloé", "Festival", "Parc", "Selfies", "Maman"], id: \.self) { s in
                                    Text(s).font(.system(size: 14)).foregroundStyle(phTexte)
                                        .padding(.horizontal, 13).padding(.vertical, 8)
                                        .background(phCarte, in: Capsule())
                                        .onTapGesture { saisie = s }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 22)
                    Spacer()
                } else if resultats.isEmpty {
                    Spacer()
                    Text("Aucun résultat").font(.system(size: 17, weight: .semibold)).foregroundStyle(phTexte)
                    Text("Essayez « festival », « parc », « maman »…")
                        .font(.system(size: 13.5)).foregroundStyle(phTexte2)
                    Spacer()
                } else {
                    HStack {
                        Text("\(resultats.count) résultat\(resultats.count > 1 ? "s" : "")")
                            .font(.system(size: 15, weight: .semibold)).foregroundStyle(phTexte)
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.top, 14)
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                            ForEach(resultats) { p in
                                TuilePhoto(item: p)
                                    .onTapGesture { photoOuverte = p }
                            }
                        }
                        Color.clear.frame(height: 80)
                    }
                    .padding(.top, 8)
                }

                // Champ bas
                HStack(spacing: 8) {
                    HStack(spacing: 7) {
                        Image(systemName: "magnifyingglass").font(.system(size: 15)).foregroundStyle(phTexte2)
                        TextField("", text: $saisie,
                                  prompt: Text("Rechercher dans votre photothèque").foregroundStyle(phTexte2))
                            .font(.system(size: 15.5)).foregroundStyle(phTexte)
                            .focused($focalise)
                        if !saisie.isEmpty {
                            Image(systemName: "xmark.circle.fill").font(.system(size: 15)).foregroundStyle(phTexte2)
                                .onTapGesture { saisie = "" }
                        }
                    }
                    .padding(.horizontal, 13).padding(.vertical, 11)
                    .background(Color(hex: 0x1F1F21), in: Capsule())
                    Image(systemName: "xmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(phTexte)
                        .padding(12).background(Color(hex: 0x1F1F21), in: Circle())
                        .onTapGesture { dismiss() }
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
            }
        }
        .onAppear { focalise = true }
        .fullScreenCover(item: $photoOuverte) { p in PhotoDetailVue(depart: p) }
    }
}

// ============================================================ COLLECTIONS
struct CollectionsPhotosVue: View {
    @ObservedObject private var magasin = MagasinPhotos.partage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Collections").font(.system(size: 26, weight: .bold)).foregroundStyle(phTexte)
                        HStack(spacing: 4) {
                            Image(systemName: "icloud.slash").font(.system(size: 11))
                            Text("Synchronisation suspendue")
                            Image(systemName: "chevron.right").font(.system(size: 9, weight: .semibold))
                        }
                        .font(.system(size: 12.5)).foregroundStyle(phTexte2)
                    }
                    Spacer()
                    AvatarMsg(nom: "Sarah Levasseur", taille: 34)
                }
                .padding(.horizontal, 16).padding(.top, 8)

                // Souvenirs
                SectionTitrePhotos(nom: "Souvenirs")
                NavigationLink { SouvenirVue() } label: {
                    ZStack(alignment: .bottomLeading) {
                        if let img = ChargeurPhoto.image("p15") {
                            Image(uiImage: img).resizable().scaledToFill()
                                .frame(height: 190).clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Festival 2025").font(.system(size: 19, weight: .bold)).foregroundStyle(.white)
                            Text("ÉTÉ 2025").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(12)
                        Image(systemName: "play.circle.fill").font(.system(size: 28)).foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(12)
                    }
                    .padding(.horizontal, 16)
                }.buttonStyle(.plain)

                // Épinglées
                SectionTitrePhotos(nom: "Épinglées", accessoire: "Modifier")
                HStack(spacing: 10) {
                    CarteEpinglee(nom: "Favorites", symbole: "heart.fill", photo: magasin.lesFavoris.first?.id) {
                        AlbumVue(titre: "Favorites", items: magasin.lesFavoris)
                    }
                    CarteEpinglee(nom: "Suppr. récemment", symbole: "trash", photo: nil) {
                        SupprRecemmentVue()
                    }
                    CarteEpinglee(nom: "Plan", symbole: "map", photo: nil) {
                        PlanPhotosVue()
                    }
                }
                .padding(.horizontal, 16)

                // Albums
                SectionTitrePhotos(nom: "Albums")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        NavigationLink {
                            AlbumVue(titre: "Festival 2025",
                                     items: magasin.visibles.filter { $0.motsCles.contains("festival") })
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Group {
                                    if let img = ChargeurPhoto.image("p15") {
                                        Image(uiImage: img).resizable().scaledToFill()
                                    } else { Rectangle().fill(phCarte) }
                                }
                                .frame(width: 150, height: 150).clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                Text("Festival 2025").font(.system(size: 14)).foregroundStyle(phTexte)
                                Text("\(magasin.visibles.filter { $0.motsCles.contains("festival") }.count)")
                                    .font(.system(size: 12.5)).foregroundStyle(phTexte2)
                            }
                        }.buttonStyle(.plain)
                        NavigationLink {
                            AlbumVue(titre: "Famille",
                                     items: magasin.visibles.filter { $0.motsCles.contains("famille") || $0.motsCles.contains("maman") || $0.motsCles.contains("papa") })
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Group {
                                    if let img = ChargeurPhoto.image("p04") {
                                        Image(uiImage: img).resizable().scaledToFill()
                                    } else { Rectangle().fill(phCarte) }
                                }
                                .frame(width: 150, height: 150).clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                Text("Famille").font(.system(size: 14)).foregroundStyle(phTexte)
                                Text("\(magasin.visibles.filter { $0.motsCles.contains("famille") || $0.motsCles.contains("maman") || $0.motsCles.contains("papa") }.count)")
                                    .font(.system(size: 12.5)).foregroundStyle(phTexte2)
                            }
                        }.buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                }

                // Personnes
                SectionTitrePhotos(nom: "Personnes")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        PersonnePhotos(nom: "Sarah", photo: "p69")
                        PersonnePhotos(nom: "Chloé", photo: "p08")
                        PersonnePhotos(nom: "Maman", photo: "p02")
                        PersonnePhotos(nom: "Papa", photo: "p03")
                        PersonnePhotos(nom: "", photo: "p49") // non nommé : « Marc »…
                    }
                    .padding(.horizontal, 16)
                }

                // Types de média
                SectionTitrePhotos(nom: "Types de média")
                VStack(spacing: 0) {
                    LigneTypeMedia(symbole: "video", nom: "Vidéos", compte: "0")
                    Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 44)
                    NavigationLink {
                        AlbumVue(titre: "Selfies", items: magasin.visibles.filter { $0.selfie })
                    } label: {
                        LigneTypeMedia(symbole: "person.crop.square", nom: "Selfies",
                                       compte: "\(magasin.visibles.filter { $0.selfie }.count)")
                    }.buttonStyle(.plain)
                    Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 44)
                    LigneTypeMedia(symbole: "camera.viewfinder", nom: "Captures d'écran", compte: "0")
                }
                .background(phCarte, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                // Autres
                SectionTitrePhotos(nom: "Autres")
                VStack(spacing: 0) {
                    NavigationLink {
                        AlbumVue(titre: "Favorites", items: magasin.lesFavoris)
                    } label: {
                        LigneTypeMedia(symbole: "heart", nom: "Favorites", compte: "\(magasin.lesFavoris.count)")
                    }.buttonStyle(.plain)
                    Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 44)
                    LigneTypeMedia(symbole: "square.on.square", nom: "Doublons", compte: "0")
                    Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 44)
                    NavigationLink { MasqueesVue() } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "eye.slash").font(.system(size: 15)).foregroundStyle(phTexte2)
                                .frame(width: 26)
                            Text("Masquées").font(.system(size: 16)).foregroundStyle(phTexte)
                            Spacer()
                            Image(systemName: "lock.fill").font(.system(size: 12)).foregroundStyle(phTexte2)
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(phTexte2.opacity(0.6))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 11)
                        .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    Divider().overlay(Color.white.opacity(0.08)).padding(.leading, 44)
                    NavigationLink { SupprRecemmentVue() } label: {
                        LigneTypeMedia(symbole: "trash", nom: "Suppr. récemment", compte: "\(magasin.corbeille.count)")
                    }.buttonStyle(.plain)
                }
                .background(phCarte, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                Color.clear.frame(height: 120)
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct SectionTitrePhotos: View {
    let nom: String
    var accessoire: String? = nil
    var body: some View {
        HStack {
            Text(nom).font(.system(size: 19, weight: .bold)).foregroundStyle(phTexte)
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(phTexte2)
            Spacer()
            if let accessoire {
                Text(accessoire).font(.system(size: 14)).foregroundStyle(phBleu)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct CarteEpinglee<Destination: View>: View {
    let nom: String
    let symbole: String
    let photo: String?
    @ViewBuilder let destination: () -> Destination
    var body: some View {
        NavigationLink { destination() } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack {
                    if let photo, let img = ChargeurPhoto.image(photo) {
                        Image(uiImage: img).resizable().scaledToFill()
                    } else {
                        Rectangle().fill(phCarte)
                        Image(systemName: symbole).font(.system(size: 22)).foregroundStyle(phTexte2)
                    }
                }
                .frame(height: 100).clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(nom).font(.system(size: 12.5)).foregroundStyle(phTexte)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

struct PersonnePhotos: View {
    let nom: String
    let photo: String
    var body: some View {
        VStack(spacing: 6) {
            Group {
                if let img = ChargeurPhoto.image(photo) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else { Circle().fill(phCarte) }
            }
            .frame(width: 72, height: 72).clipped()
            .clipShape(Circle())
            Text(nom.isEmpty ? "Nommer" : nom)
                .font(.system(size: 12.5))
                .foregroundStyle(nom.isEmpty ? phBleu : phTexte)
        }
    }
}

struct LigneTypeMedia: View {
    let symbole: String
    let nom: String
    let compte: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbole).font(.system(size: 15)).foregroundStyle(phTexte2)
                .frame(width: 26)
            Text(nom).font(.system(size: 16)).foregroundStyle(phTexte)
            Spacer()
            Text(compte).font(.system(size: 15)).foregroundStyle(phTexte2)
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(phTexte2.opacity(0.6))
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

// ============================================================ ALBUM GÉNÉRIQUE / SOUVENIR / PLAN / VERROUS
struct AlbumVue: View {
    let titre: String
    let items: [PhotoItem]
    @State private var photoOuverte: PhotoItem? = nil
    var body: some View {
        ZStack {
            phFond.ignoresSafeArea()
            if items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle").font(.system(size: 34)).foregroundStyle(phTexte2)
                    Text("Aucune photo").font(.system(size: 15)).foregroundStyle(phTexte2)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                        ForEach(items) { p in
                            TuilePhoto(item: p)
                                .onTapGesture { photoOuverte = p }
                        }
                    }
                    Color.clear.frame(height: 60)
                }
            }
        }
        .navigationTitle("\(titre) · \(items.count)")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $photoOuverte) { p in PhotoDetailVue(depart: p) }
    }
}

// Souvenir « Festival 2025 » : diaporama plein écran
struct SouvenirVue: View {
    @Environment(\.dismiss) private var dismiss
    @State private var indice = 0
    private let ids = ["p15", "p07", "p08", "p06", "p09"]
    private let tic = Timer.publish(every: 2.6, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            phFond.ignoresSafeArea()
            if let img = ChargeurPhoto.image(ids[indice]) {
                Image(uiImage: img).resizable().scaledToFill()
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .id(indice)
            }
            LinearGradient(colors: [.black.opacity(0.55), .clear, .clear, .black.opacity(0.4)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack {
                HStack {
                    Image(systemName: "xmark").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        .padding(11).background(.ultraThinMaterial, in: Circle())
                        .onTapGesture { dismiss() }
                    Spacer()
                }
                .padding(.horizontal, 14)
                Spacer()
                VStack(spacing: 2) {
                    Text("Festival 2025").font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                    Text("ÉTÉ 2025").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white.opacity(0.8))
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onReceive(tic) { _ in
            withAnimation(.easeInOut(duration: 0.6)) { indice = (indice + 1) % ids.count }
        }
    }
}

// Plan : carte avec grappes de photos géolocalisées
struct PlanPhotosVue: View {
    @State private var photoOuverte: PhotoItem? = nil
    private let grappes: [(String, CLLocationCoordinate2D, String, Int)] = [
        ("p06", CLLocationCoordinate2D(latitude: 45.7772, longitude: 4.8558), "Parc de la Tête d'Or", 4),
        ("p15", CLLocationCoordinate2D(latitude: 45.7647, longitude: 4.9532), "Décines-Charpieu", 1),
        ("p01", CLLocationCoordinate2D(latitude: 45.9405, longitude: 4.6108), "Theizé", 5),
        ("p69", CLLocationCoordinate2D(latitude: 45.7679, longitude: 4.8320), "Lyon 1er", 1),
    ]
    var body: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.83, longitude: 4.80),
            span: MKCoordinateSpan(latitudeDelta: 0.55, longitudeDelta: 0.55)))) {
            ForEach(Array(grappes.enumerated()), id: \.offset) { _, g in
                Annotation(g.2, coordinate: g.1) {
                    ZStack(alignment: .topTrailing) {
                        Group {
                            if let img = ChargeurPhoto.image(g.0) {
                                Image(uiImage: img).resizable().scaledToFill()
                            } else { Rectangle().fill(phCarte) }
                        }
                        .frame(width: 52, height: 52).clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(.white, lineWidth: 2))
                        if g.3 > 1 {
                            Text("\(g.3)").font(.system(size: 10, weight: .bold)).foregroundStyle(.black)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(.white, in: Capsule())
                                .offset(x: 7, y: -7)
                        }
                    }
                }
            }
        }
        .navigationTitle("Plan")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Masquées : VERROUILLÉE et le reste (D57) — 648 éléments derrière le cadenas
struct MasqueesVue: View {
    @State private var codeVisible = false
    var body: some View {
        ZStack {
            phFond.ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "lock.fill").font(.system(size: 38)).foregroundStyle(phTexte2)
                Text("Utilisez Face ID ou saisissez votre code pour afficher cet album.")
                    .font(.system(size: 15)).foregroundStyle(phTexte)
                    .multilineTextAlignment(.center).padding(.horizontal, 50)
                Text("Afficher l'album").font(.system(size: 15)).foregroundStyle(phBleu)
                    .onTapGesture { codeVisible = true }
                Spacer()
                Text("648 éléments").font(.system(size: 13)).foregroundStyle(phTexte2)
                    .padding(.bottom, 30)
            }
        }
        .navigationTitle("Masquées")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $codeVisible) {
            NavigationStack {
                FaceIDVue()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Annuler") { codeVisible = false }.foregroundStyle(phBleu)
                        }
                    }
            }
            .preferredColorScheme(.dark)
        }
    }
}

// Suppr. récemment : OUVERTE (D57 — Sarah avait désactivé Face ID pour cet album)
struct SupprRecemmentVue: View {
    @ObservedObject private var magasin = MagasinPhotos.partage
    @State private var photoOuverte: PhotoItem? = nil
    var body: some View {
        ZStack {
            phFond.ignoresSafeArea()
            VStack(spacing: 0) {
                Text("Les photos et vidéos affichent le nombre de jours restant avant leur suppression. Une fois ce délai écoulé, les éléments seront définitivement supprimés. Cela peut prendre jusqu'à 40 jours.")
                    .font(.system(size: 12.5)).foregroundStyle(phTexte2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26).padding(.top, 12).padding(.bottom, 14)
                if magasin.corbeille.isEmpty {
                    Spacer()
                    Image(systemName: "trash").font(.system(size: 34)).foregroundStyle(phTexte2)
                    Text("Aucune photo supprimée récemment")
                        .font(.system(size: 15)).foregroundStyle(phTexte2).padding(.top, 8)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                            ForEach(magasin.corbeille) { p in
                                TuilePhoto(item: p)
                                    .overlay(alignment: .bottomLeading) {
                                        Text("29 jours").font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(.white).shadow(radius: 2).padding(4)
                                    }
                                    .onTapGesture { photoOuverte = p }
                            }
                        }
                        Color.clear.frame(height: 60)
                    }
                }
            }
        }
        .navigationTitle("Suppr. récemment")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $photoOuverte) { p in
            RecupPhotoVue(item: p)
        }
    }
}

struct RecupPhotoVue: View {
    @Environment(\.dismiss) private var dismiss
    let item: PhotoItem
    @ObservedObject private var magasin = MagasinPhotos.partage
    var body: some View {
        ZStack {
            phFond.ignoresSafeArea()
            VStack {
                HStack {
                    Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(phTexte)
                        .padding(10).contentShape(Rectangle())
                        .onTapGesture { dismiss() }
                    Spacer()
                }
                .padding(.horizontal, 8)
                Spacer()
                if let img = ChargeurPhoto.image(item.id) {
                    Image(uiImage: img).resizable().scaledToFit()
                }
                Spacer()
                HStack {
                    Text("Supprimer").font(.system(size: 16)).foregroundStyle(Color(hex: 0xFF453A))
                        .padding(.horizontal, 8).padding(.vertical, 10)
                    Spacer()
                    Text("Récupérer").font(.system(size: 16)).foregroundStyle(phTexte)
                        .padding(.horizontal, 8).padding(.vertical, 10)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            magasin.supprimees.remove(item.id)
                            dismiss()
                        }
                }
                .padding(.horizontal, 16).padding(.bottom, 8)
            }
        }
    }
}
