# WhatsApp iOS 26 — carte de navigation et composants (vidéo du 2026-08-16)

> Source : enregistrement d'écran réel de 93 s (iPhone de Joachim), analysé image par image.
> Complète les 9 captures de `references/whatsapp/`. Référence pour le clone SwiftUI (D47/D50).

## Écrans observés et navigation

```
Discussions ──────────┬─→ Archivées (push, titre centré « Archivées », retour < 20)
  (onglet actif)      ├─→ Conversation groupe (push latéral)
                      │       └─→ Infos groupe (tap sur header) → Membres → retour
                      ├─→ Conversation 1-à-1 (push latéral)
                      │       └─→ Infos du contact (tap header) → actions → retour
                      ├─→ [onglet] Appels
                      ├─→ [onglet] Vous (profil + réglages)
                      └─→ [chip] Non lues / Favoris / Groupes (filtre in-place, PAS de navigation)
```

## Détails par écran (au-delà des captures statiques)

### Discussions
- Le chip filtre change la liste EN PLACE et adapte le placeholder de recherche :
  « Rechercher dans Non lues » (au lieu de « Demander à Meta AI ou... »)
- Ligne « Archivées » toujours en tête de liste
- Groupe suspendu affiché avec 🚫 « Ce groupe est suspendu » + badge @ jaune

### Archivées
- Header : « < 20 » (badge non-lus) | titre centré | « Modifier »
- Bandeau explicatif gris : « Ces discussions restent archivées lorsque vous recevez… »

### Conversation (groupe et 1-à-1)
- Header : chevron + badge non-lus « 20 », avatar, nom + sous-titre
  (« en ligne aujourd'hui à 18:08 » / liste des membres / « appuyez pour consulter les infos »)
  — 1-à-1 : pilule vidéo+téléphone ; GROUPE : icône vidéo avec chevron (menu)
- Bulles groupées : coins réduits entre messages consécutifs du même expéditeur
- Groupe : nom de l'expéditeur coloré (couleur stable par membre) + numéro gris à droite
- Réponses citées : barre verticale colorée + nom + extrait, fond assombri dans la bulle
- Réactions : pilule emoji accolée au coin bas de la bulle (chevauche légèrement)
- Vocaux : lecteur waveform + durée + bouton vitesse « 1x » + petit avatar à droite
- Partage musique : vignette + note de musique rose ; vidéos : vignette + durée + ▶
- Aperçu de lien : carte avec image + URL
- ÉVÉNEMENTS D'APPEL (bulles, PAS cartes pleine largeur) :
  - reçus (gris) : « Appel vidéo manqué / Appuyez pour rappeler » (icône rouge),
    « Appel vidéo 22 min », « Appel vocal 25 min », « Appel vidéo en silencieux / Mode Concentration »
  - envoyés (verts) : « Appel vidéo Sans réponse », « Appel vidéo 28 s », « Appel vocal 4 min »
- Pilules de date : « sam. 18 juil. », « jeu. 9 juil. », « Aujourd'hui »

### Infos du contact / Infos groupe
- Grand avatar centré, nom, numéro (contact) / « Groupe · 11 membres » + description (groupe)
- Boutons : Audio | Vidéo | (Ajouter) | Rechercher
- Sections : Médias, liens et documents (n) / Gérer le stockage (Mo) / Important
  / Notifications / Thème de la discussion / Enregistrer (Photos) / Messages éphémères
  / Verrouiller la discussion / Confidentialité avancée / Chiffrement / Détails du contact
- Contact : Aucun groupe en commun, Créer un groupe, Partager (vert), Ajouter aux favoris,
  Exporter, Effacer (rouge), Bloquer, Signaler (rouge)
- Groupe : liste des membres avec « Admin », Voir tout, Enregistrer dans les contacts

### Onglet Appels
- Header rond « ⋯ » + « + » vert ; grand titre « Appels »
- Rangée d'actions rondes : Appeler | Planifier | Clavier | [contact favori] | Favoris
- « Récents » : avatar, nom (ROUGE si manqué), icône type (📹/📞) + Entrant/Sortant/Manqué/
  Mode Concentration, « (2) » si multiple, date à droite, bouton ⓘ

### Onglet Vous
- Recherche (loupe) + QR + crayon en haut ; grand avatar vert + prénom + ✓
- Sections : Abonnements (point vert) / Listes / Messages de diffusion / Important /
  Appareils connectés — puis Compte / Confidentialité / Discussions / Apparence /
  Notifications / Stockage et données — puis Aide / Inviter un proche / Espace Comptes /
  Autres produits Meta (Instagram, Facebook, Threads, Meta AI App)

## Transitions mesurées
- Push de navigation : glissement latéral iOS standard (~0,35 s), le parent glisse partiellement
- Changement d'onglet : bascule immédiate sans animation latérale (fondu quasi nul)
- Le clavier et les chips filtrent sans transition d'écran
- Scroll : physique iOS standard, rebond aux extrémités

## Reste à couvrir (pas dans cette vidéo)
- Écran verrouillé et écran d'accueil (captures à recevoir)
- Onglets Actus (statuts) et Communautés
- Caméra, envoi de message en direct, appel en cours
