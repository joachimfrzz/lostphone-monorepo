# FICHES DE VÉRIFICATION — LES 28 APPS (campagne D84)

Document unique, généré le 2026-09-02 depuis la mémoire projet (rapports S1→S6, chantier design, cercle 2, retests 271/272). Remplace le dossier `fiches-verification/` (conservé une itération, puis à supprimer sur arbitrage).

## Comment utiliser ce document
- **Une app à la fois**, dans l'ordre des sessions. Tour de **5 min max** par app.
- Pour chaque écart : **une paire de photos** (vrai iPhone / Lost Phone) **ou une ligne de frustration** (vocal ou texte). Pas besoin de rédiger.
- **Les 5 axes** à garder en tête : pixel · touchers · navigation & gestes · contenu Sarah · animations.
- **Doctrine D82 (zéro bouton menteur)** : chaque bouton doit soit **A** marcher vraiment, soit **B** répondre par un message crédible iOS (avec parcimonie), soit **C** avoir été retiré avec ton accord. Un bouton qui ne fait rien = frustration à signaler.
- **Pièges connus** : liste par app de ce qui est déjà assumé/connu — ne le re-signale pas, ça pollue.
- **Une app validée = on n'y revient plus.**
- Comparaison sur ton vrai iPhone : régime **D71** — lecture seule, sociales via tes comptes B, jamais Ma Banque, jamais d'action Localiser réelle.

## 🔔 DERNIER BUILD — à vérifier en priorité
> Cette section est MISE À JOUR À CHAQUE BUILD (règle D89, 02/09). Tu l'ouvres, tu sais quel build tu testes, ce qui a changé, et exactement quoi contrôler.

**Build : TestFlight n° 278 — lancé le 02/09 à 19h14, compilé 19h15-19h21, publication TestFlight ~19h22 (disponible ~10 min après).**

✅ **278 VALIDÉ par Joachim le 02/09 à 20h10 — 16/16 points.** Fichiers, Localiser, Cartes, Ma Banque validées (14/28). Reste à faire : la **checklist du 275 (13 points)** ci-dessous dans l'historique, puis la session 5. Retours de la **session 4** (Fichiers, Localiser, Santé, Cartes, Ma Banque) + 2 corrections globales. Les 276 (19h05) et 277 (19h13) ont échoué à la compilation et n'apparaîtront pas dans TestFlight. Précédent valide : 275 (02/09 18h45) — ses 13 points restent à vérifier si tu ne l'as pas encore fait.

### Ce que tu avais demandé (retours session 4)
- Fichiers : Sélectionner mort ; Se connecter au serveur / Scanner / Compresser / Dupliquer inutiles ; « Ouvrir » (Infos) mort ; flèche muette dans Supprimés récemment ; micro dans la recherche ; iCloud Drive et Sur mon iPhone morts
- Localiser : retirer les « + » ; 2 boutons de carte morts ; recentrer la carte à la sélection ; Memoji Apple au lieu d'emojis ; Itinéraire doit ouvrir Plans AVEC la destination ; « Étiquette de localisation » à retirer ; bouton « Localiser » (À proximité) artificiel
- Santé : ✅ VALIDÉE (à enrichir plus tard selon les histoires) ; contenu qui remonte dans la zone heure/batterie (constaté aussi Safari)
- Cartes/Wallet : QR codes et codes-barres visiblement faux ; cartes trop simples ; menus « … » au milieu de l'écran + « Supprimer la carte » inutile
- Ma Banque : le virement doit avoir une conséquence réelle et persistante ; pavé numérique impossible à fermer ; (plus tard) détail des opérations
- Global : plus aucun bouton vocal dans aucune app

### Ce qui a été modifié dans ce build
- **Global — zone système** : la bande heure/batterie de Sarah a maintenant un fond (matériau) dans TOUTES les apps : le contenu défile DESSOUS, jamais dedans (Santé, Safari, Mail, listes…)
- **Global — micros** : 9 icônes de dictée retirées (Messages, Météo villes, Spotlight, Téléphone ×2, Messenger, Snapchat, ChatGPT ×2, Plans, Fichiers ×3) ; les micros « couper le son » des écrans d'appel restent (ce ne sont pas des boutons vocaux)
- **Fichiers** : Sélectionner RÉEL (cocher → Partager / Supprimer) ; Scanner, Se connecter, Compresser, Dupliquer RETIRÉS ; « Ouvrir » ouvre le fichier ; Supprimés récemment → bouton **Récupérer** réel ; iCloud Drive et Sur mon iPhone ouvrent leur contenu ; micro retiré
- **Localiser** : « + » retirés ; bouton carte pliée = **plan / satellite** réel ; bouton localisation = **recentre sur moi** ; toucher Chloé / Maman / un appareil / les clés **recentre la carte** dessus ; **Memoji** (Chloé, Maman, Sarah dans Moi) ; **Itinéraire ouvre Plans directement sur l'itinéraire** vers la personne/l'appareil ; « Étiquette de localisation » retirée ; bouton « Localiser » retiré
- **Cartes/Wallet** : **vrai QR code** (généré par iOS, lisible) sur le billet TGV ; **vrai code-barres Code 128** sur la carte Phox ; cartes redessinées (puce, sans-contact, trame, Visa, logo SNCF, membre/points) ; « … » retirés ; clavier de l'ajout de carte masquable
- **Ma Banque** : virement → **solde diminué immédiatement** + « Solde après opération » dans la confirmation + refus réel si solde insuffisant (découvert 200 €) ; pavé numérique fermé d'un tap ailleurs ou par « OK » ; **détail d'opération** au tap (type, dates, catégorie, référence, solde après) ; Partager le RIB réel
- **Plans** : reçoit les demandes d'itinéraire de Localiser ; micro retiré ; « Ajouter » (bouton mort) retiré
- **Notes — jaune** : INCHANGÉ. Ta vidéo SwissTransfer est bloquée pour mon environnement (protection anti-robot) — envoie-moi une **capture d'écran** (image) de l'écran Dossiers de la vraie app Notes, je prélèverai la couleur au pixel

### ✅ À VÉRIFIER DANS CE BUILD (checklist)
- [ ] Global — Santé, Safari, Mail, Réglages : faire défiler → le contenu passe SOUS la zone heure/batterie (fond visible), jamais dedans
- [ ] Global — barres de recherche de Téléphone, Messages, Plans, Fichiers, Spotlight, Météo (villes) et champs de saisie Messenger / Snapchat / ChatGPT : plus aucun micro
- [ ] Fichiers — … → Sélectionner → cocher 2 fichiers → corbeille : ils partent ; Explorer → Suppressions récentes → **Récupérer** les ramène
- [ ] Fichiers — Infos d'un PDF → **Ouvrir** ouvre l'aperçu ; appui long : plus de Compresser/Dupliquer ; menu … : plus de Scanner / Se connecter
- [ ] Fichiers — Explorer → Sur mon iPhone et iCloud Drive s'ouvrent avec leurs dossiers/fichiers
- [ ] Localiser — plus de « + » ; bouton carte pliée bascule plan/satellite ; bouton localisation recentre sur le domicile
- [ ] Localiser — toucher Chloé → la carte glisse sur Croix-Rousse ; toucher Maman → Théizé ; toucher AirPods → domicile
- [ ] Localiser — Chloé et Maman ont un **Memoji** (visage 3D), Moi aussi ; Marc reste en silhouette (invitation)
- [ ] Localiser — fiche Chloé → **Itinéraire** → Plans s'ouvre SUR l'itinéraire vers Chloé (destination déjà remplie)
- [ ] Localiser — Moi : plus de ligne « Étiquette de localisation » ; Clés : plus de bouton « Localiser », mais Émettre un son + Itinéraire
- [ ] Wallet — billet TGV : le QR ressemble à un vrai (essaie même de le scanner avec l'appareil photo de ton iPad : il contient la référence du billet) ; carte Phox : vrai code-barres avec chiffres dessous
- [ ] Wallet — cartes : puce, sans-contact, trame, logos ; plus aucun « … »
- [ ] Ma Banque — virement de 400 € à Maman → « Solde après opération » affiché, le solde du compte baisse de 400 € et l'opération est en tête de l'historique ; revenir dans Comptes : le solde reste diminué
- [ ] Ma Banque — taper un montant → toucher ailleurs ou « OK » au-dessus du clavier → le pavé se ferme
- [ ] Ma Banque — toucher une opération → fiche détail (catégorie, référence, solde après)
- [ ] Régression — Notes, Rappels, Calendrier, Horloge, Dictaphone, Météo, Calculatrice : tour rapide

---

## Sessions et builds (méthode D86)
| Session | Apps | Build |
|---|---|---|
| RE-TEST | Messages · WhatsApp · Téléphone · Photos · Mail | TestFlight **272** (dehors) |
| 2 | Safari (re-test) · Notes · Rappels · Calendrier | TestFlight **275** (02/09 18h41) |
| 3 | Horloge · Dictaphone (Météo ✅, Calculatrice ✅) | TestFlight **275** (02/09 18h41) |
| finale | Réglages (passe dédiée, D89) | dernier lot |
| 4 | Fichiers ✅ · Localiser ✅ · Cartes ✅ · Ma Banque ✅ (Santé ✅) | TestFlight **278** (02/09 19h14) — ✅ validé 20h10 |
| 5 | Messenger · Instagram · Snapchat · Facebook | lot session 5 |
| 6 | X · ChatGPT · Spotify · YouTube | lot session 6 |

---

# 0. COQUE (verrouillage + accueil) — ✅ VALIDÉE 30/08 18h02
On n'y revient pas, **sauf régression**. Si tu vois l'un de ces points cassé par un build ultérieur, signale-le :
- Ouverture d'app = slide up seul (pas de zoom/fondu de logo) — D85
- Icônes : carrés pleins, un seul rognage squircle, aucun halo de wallpaper, aucun badge incrusté
- Barres système = celles de SARAH (19:47 figé, capsule dessinée), la vraie barre d'état iOS masquée partout
- 1er glissé-haut depuis le bas = retour à l'accueil du JEU ; le 2e quitte vraiment (sécurité iOS, voulu)
- Zone tactile de la capsule home réduite à ~150 pt au centre (correctif Safari 31/08 — s'applique aux 29 apps)
- Déverrouillage : écran verrouillé suit le doigt puis translate vers le haut, accueil se pose en dézoomant
- Pages d'accueil : page 1 widgets Météo + Calendrier (évènement Agence Bellecour 11:30) + 16 apps ; page 2 Mail/Musique/sociales/WhatsApp ; dock Téléphone/Messages/Safari/Mail
- Centre de contrôle sombre (blur + voile), centre de notifications, multitâche, bibliothèque d'apps
- Pièges connus : fermeture d'app encore en glissade par défaut (zoom inverse = reste) ; icônes manquantes en repli SF : Calculatrice, Dictaphone, Ma Banque, Musique

---

# RE-TEST BUILD 272 (tes 15 points du retest 271 — tous codés)

## 1. MESSAGES
**Points précis à re-tester (272)**
- Les 2 commandes vocales sont RETIRÉES (recherche + champ de saisie) ; la flèche d'envoi n'apparaît que s'il y a du texte
- Nouvelle discussion : elle apparaît dans la liste dès le 1er message
- Envoi à un numéro non répertorié : ligne « Envoyer à “num” » puis conversation créée ; bulle SMS **verte** pour un numéro brut, **bleue** iMessage pour un contact (comme iOS)
- Aperçu de liste vivant : dernier envoi visible, tri par activité, heure à jour
- Balayage sur une ligne : cloche (masquer alertes) + corbeille (suppression récupérable) — ne doit PAS ouvrir la conversation
- Appui long sur une bulle : tapback ❤️👍👎😂‼️❓
- Viseur caméra : s'ouvre vraiment (flash, photo sombre envoyée dans la conv) ; « Envoyer plus tard » programme vraiment (feuille + toast)
**Tour général**
- Liste : épinglés Maman/Chloé, phishing SecuriBQE (code 38200), séparateurs, « iMessage · Chiffré », « Distribué », champ « Message texte • RCS »
- Conversation : bulles envoyées **bleues** iMessage (correctif S3), ordre date → « iMessage Chiffré »
- « Modifier » non tronqué dans les toolbars
**Contenu Sarah** : le fil de phishing SecuriBQE = pièce d'enquête ; les conversations racontent la vie de Sarah (Maman, Chloé, kiné)
**Pièges connus** : Sondages/Genmoji/Playground en B validé (wording iOS authentique) ; message libre du joueur = non-distribution discrète hors moments d'histoire (D54)

## 2. WHATSAPP
**Points précis à re-tester (272)**
- **CRASHS RÉPARÉS** : ouvrir Abonnements, Listes, et le menu Nouveau — le jeu ne doit plus se fermer. Teste-les 3 fois chacun
- Heure verte dans la liste = non lu ; redevient grise après lecture
- Compteurs 100 % dynamiques et masqués à zéro : badge onglet Discussions, puce « Non lues N », chevron retour de conversation, retour Archivées, badges WhatsApp sur l'accueil (grille + page 2)
**Tour général (lot étape 3)**
- Tri par récence (Les filles > Chloé > Marc > Maman > Thomas > Marie), ton activité en tête, épinglées
- Archivées : vraies conversations (Yoga/Copro/livreur) + désarchiver
- Menu + : Nouvelle discussion (picker contacts réel), Nouveau groupe (multi-sélection), Nouvelle communauté (création réelle, visible dans l'onglet)
- Caméra de la liste : Prendre une photo (viseur) / Photothèque → destinataire → la photo part vraiment
- Balayages : Non lu (bascule réelle, libellé Lu/Non lu), Archiver réel, Plus → Épingler/Infos
- Mode « Sélectionner des discussions » : archivage groupé
- Micro : tap court = « Maintenez pour enregistrer », appui long = chrono, relâcher = vraie bulle vocale ; audio s'arrête en quittant la conversation
- Bouton vidéo = appel qui sonne dans le vide (comme l'audio) ; écran d'appel vidéo distinct (caméra sombre, PIP)
- Rechercher dans la conversation = vraie recherche filtrante
- Fiche contact : plus aucun chargement infini ; écran Médias/Liens/Docs réel ; réglages (stockage, verrouiller → Face ID non configuré, thème, éphémères…)
- « + » dans une discussion : Photos / Appareil photo / Contact réels ; Document / Sondage en réponse D56
**Contenu Sarah** : la conversation « Marc » = cœur de Coches bleues ; « Les filles », Maman, Chloé, Thomas, Marie kiné
**Pièges connus** : « + » création groupe retiré (C validé) ; WhatsApp affiche « en ligne » sur le vrai (zone rouge D71 — compare avec prudence)

## 3. TÉLÉPHONE (+ Contacts)
**Points précis à re-tester (272)**
- Récents triés par VRAIE récence (Chloé 19:33 en tête … Marc 6 mai en bas)
- Le bouton ≡ « Effacer les appels récents » est SUPPRIMÉ
- Date/heure à droite ne se coupe plus (Récents et Favoris), ⓘ bien placé
- Fiche contact → rond Mail = ouvre Mail sur un Nouveau message préadressé
- « Partager cette fiche » = partage réel (carte contact via Messages ou WhatsApp)
**Tour général**
- Favoris / Récents / Contacts / Clavier / Messagerie : favoris, listes, urgence, blocage basculent réellement
- Messagerie vocale visuelle : Agence Bellecour 00:25, transcription, ⓘ, Modifier/Annonce
- Clavier : composer un numéro, appel qui sonne dans le vide (audio réel D52)
- Enveloppe → ouvre Mail
**Contenu Sarah** : l'appel manqué de l'Agence Bellecour, les appels à Marc (dont le dernier daté), Maman, Chloé
**Pièges connus** : appels vidéo interactifs écartés (D52)

## 4. PHOTOS
**Points précis à re-tester (272)**
- Années CLIQUABLES : tap → bascule sur Mois, défilé sur cette année
- Sélectionner fiabilisé (vrai bouton) ; depuis Années il bascule sur Toutes
- Sélection possible aussi dans Mois (cercles + bascule)
- Filtres Favorites/Captures appliqués aussi dans Mois et Années (sections vides masquées)
**Tour général (lot étape 5 : 11 corrections)**
- Photothèque : compteur 1 243 éléments, Trier et filtrer, Sélect., badge vidéo 0:35, onglets Photothèque/Collections/Recherche
- VRAIES photos de la pellicule (fête, selfies mère/fille, quais de Lyon, cerisiers) — plus de dégradés colorés
- Collections : Souvenirs, Types de média, Plan (868 photos)
- Détail photo : zoom, infos, favori, partage, suppression → Suppressions récentes
**Contenu Sarah** : P58 (RIB photographié), P64 (pièce d'identité), P57 (écran de virement refusé), P60 (note), captures d'écran de l'arnaque = pièces d'enquête, datées en cohérence avec Rappels/Terminés
**Pièges connus** : vignettes du Plan = placeholder carte

## 5. MAIL
**Points précis à re-tester (272)**
- **BUG CRITIQUE RÉPARÉ** : les mails s'ouvrent de nouveau au tap (rangée entière)
**Tour général (lot étape 6 : 13 corrections)**
- Ouverture directe sur Réception ; un mail devient lu à l'ouverture
- Sélectionner réel : marquer lu + corbeille avec confirmation ; « … » = menu réel ; filtre non-lus réel
- Micro retiré ; composer branché en bas ; plus de recouvrement de la dernière rangée
- Nouveau message : « + destinataire » réel (contacts mail connus dont marc.dlc.officier@gmail.com ⭐), envoi → en tête d'Envoyés avec destinataire visible
- Fiche expéditeur réelle (adresse, dates, VIP basculable)
- Boîtes : arborescence Gmail (Réception 1208, Boîte d'envoi 1, Brouillons 12, Indésirables 7, Tous 3641, Important 84, Suivis) ; footer « MÀJ à l'instant / 1 message non envoyé »
- Lecture : bouton Résumer iOS 26, barre Archiver/Déplacer/Répondre/Rédiger
**Contenu Sarah** : mail Agence Bellecour non lu, mail Phox (recoupe Wallet), échanges avec Marc — TOUT le contenu est Sarah, jamais un mail réel
**Pièges connus** : favicons/avatars expéditeurs en repli (chantier assets)

---

# SESSION 2

## 6. SAFARI (re-test des 5 correctifs du 31/08 — au build du lot session 2)
- **Barre home** : zone tactile réduite à la capsule (~150 pt) → les boutons de la barre d'outils Safari juste au-dessus sont cliquables sans quitter l'app (vérifie aussi dans 2-3 autres apps)
- **Onglets réels** : + ouvre un onglet (page de démarrage à favoris/suggestions tappables), × ferme, compteur vivant, bascule normal/privé avec onglets privés réels, l'onglet actif suit la navigation
- **Bouton aA** : zoom texte 70–130 %, Afficher le lecteur (version texte des pages d'enquête), Masquer la barre d'outils (pilule pour restaurer) ; recharger et chevrons arrière/avant réels
- **Recherche contrôlée** : ~14 requêtes de l'histoire → vraies pages (arnaque, OKAFOR, Marc Delacroix, hôtel, LCL, TGV, meetic, gratin, navire, victimes, cyber, forum, fonfon) ; requête inconnue → « Aucun résultat pertinent » + recherches associées ; texte qui ressemble à une URL → erreur serveur ; CHAQUE résultat Google est ouvrable
- **Beat d'enquête** : « Marc Delacroix officier marine » → 7 résultats qui ne collent pas (chauffagiste, homonyme, annuaire Marine vide, defense.gouv « aucun officier à ce nom »)
- Sites : service-public (loi, numéros), France Victimes, Cybermalveillance, forum Doctissimo (témoignage miroir), VesselFinder (navires au nom proche), Fonfon (carte, adresse, avis)
**Tour général** : démarrage (8 favoris + Liste de lecture + barre d'adresse basse iOS 26), grille d'onglets « Personnel », navigation privée
**Pièges connus** : favicons = lettres colorées sur tuile ; vignettes d'onglets = placeholder + domaine

## 7. NOTES
**Écrans** : liste iCloud (sections Épinglées / Aujourd'hui / 7 jours / 30 jours — ordre, dates, aperçus 2 lignes) ; dossiers ; note ouverte ; recherche
**Gestes & touchers** : créer une note → elle PERSISTE après sortie/retour ; l'éditer → la modification persiste ; recherche plein texte (mot connu → résultat, mot inconnu → état vide) ; note « Perso 🔒 » → demande de code crédible (porte fermée D57), pas de crash ; barre basse recherche + composer ; toolbar de note (partager, terminé) ; appui long sur une note si le vrai l'a
**Contenu Sarah** : P60 « Documents pour lundi » MOT POUR MOT (recoupe la pellicule), Exercices épaule S32 (Marie kiné), « Idées week-end Marseille » (l'espoir du 28), recette gratin, Questions kiné, Livres (« Le vieil homme et la mer recommandé par M. »), « Objectifs 2026 » avec « Rencontrer quelqu'un de bien ✓ »
**Animations** : ouverture/fermeture de note, apparition du clavier
**Pièges connus** : icônes de rangées en SF approximatifs (chantier assets global)

## 8. RAPPELS
**Écrans** : accueil (6 tuiles Aujourd'hui / Programmés / Tous / Avec drapeau / Terminés + Suppressions récentes 15 — compteurs JUSTES) ; Mes listes (Rappels + Courses avec pastille carotte) ; liste Courses à sections ; détails d'un rappel
**Gestes & touchers** : COCHER un rappel → il bascule vraiment dans Terminés ; créer inline + via la feuille Nouveau rappel ; toggles Date/Urgent/Drapeau réels ; toutes les tuiles s'ouvrent ; balayages sur une ligne si le vrai les a
**Contenu Sarah** : Terminés = la préparation du dossier bancaire EN CREUX — « Imprimer le RIB » (16/08 21h38) et « Photographier pièce d'identité » (12/08 09h41) aux MÊMES dates que les captures P58/P64 ; « Rendre le tupperware à maman » terminé (boucle G6)
**Pièges connus** : vignettes/icônes de listes approximatives (chantier assets)

## 9. CALENDRIER
**Écrans** : MOIS (scroll continu fév 2025 → déc 2026, 17 août en rouge = présent du jeu, pastilles d'évènements, grille juste : 1er août 2026 = samedi) ; ANNÉE (12 mini-mois, mois courant rouge) ; JOUR (00–23 h, évènements positionnés avec durée/lieu, journée entière, auto-scroll ~8 h) ; fiche d'évènement ; recherche
**Gestes & touchers** : bascules Mois/Année/Jour, « Aujourd'hui » ; tap sur un mois de la vue Année → il s'ouvre ; tap sur chaque évènement → sa fiche ; CRÉER un évènement (titre/lieu/date/heure) → il persiste et apparaît dans Mois/Jour ; RECHERCHE « banque » → le RDV du 17/08
**Contenu Sarah** : « Banque — plafond » lundi 17/08 11h30 Agence Bellecour (rose) ; kiné tous les jeudis 17h30 (12 rue des Fantasques) ; « Brunch les filles » sam 22/08 13h Place Sathonay ; « MARC ARRIVE ⚓️ » vendredi 28/08 journée entière Marseille-port ; anniv Maman 14/02, anniv Chloé 3/04, L'Assomption 15/08 + fériés verts ; révision voiture ; Dr Pasquier
**Pièges connus** : aucun assumé — signale tout

## 10. RÉGLAGES (~85 pages — concentre-toi sur ces points)
**Écrans** : RACINE (ordre exact iOS 26.6, avatar Sarah = VRAIE photo p04 — plus les initiales SL, VPN Déconnecté, Recherche) ; Général → Informations (iPhone de Sarah, iOS 26.6.1, iPhone 16, MYED3F/A, 127 morceaux / 58 vidéos / 1243 photos / 31 apps, 128 Go / 41,7 Go) ; Notifications (Nombre/Liste avec coche, Prioriser/Résumer/Annoncer) ; Luminosité ; Batterie (graphique 24 h/10 j + apps consommatrices) ; Sons ; Fond d'écran ; Confidentialité ; Wi-Fi ; Bluetooth
**Gestes & touchers** : CHAQUE rangée testée doit ouvrir SA page (pas une page générique) — note la rangée sinon ; toggles basculent et RESTENT ; sliders luminosité/volume ; boutons à code (Face ID…) → demande de code crédible (D57), pas de crash ; retour = balayage bord gauche OU zone retour haut-gauche
**Contenu Sarah** : aucune donnée de Joachim ; compteurs cohérents avec Photos (1243) et Musique (127) ; nom de l'appareil « iPhone de Sarah »
**Pièges connus** : icônes de rangées SF approximatifs ; vignettes Nombre/Liste simplifiées (rectangles gris) ; certains réglages « code requis » en B validé (D82)

---

# SESSION 3

## 11. HORLOGE
**Écrans** : 4 onglets teinte orange — Horloges (Paris « Aujourd'hui, +0h », heure VIVE qui avance) ; Alarmes (Sommeil|Réveil « CONFIGURER » + 5 alarmes) ; Chronomètre ; Minuteurs (roues + anneau + Récents)
**Gestes & touchers** : + Horloges → vraie recherche de ~50 villes (dont Marseille) ; toggles d'alarmes réels ; créer/éditer/supprimer une alarme (roues) → tri chrono refait ; champs Récurrence/Sonnerie/Durée = vrais menus qui répondent (D56) ; chrono au centième, Tour/Effacer contextuels, liste des tours ; minuteur : lancement réel, anneau orange + heure de fin, Pause/Reprendre/Annuler, Récents relançables et réordonnés
**Contenu Sarah** : 6:45 réveil semaine OFF, 8:30 kiné ON, 11:00 brunch filles OFF, 11:15 « Banque !! » ON, 21:30 « Appel Marc » ON quotidienne
**Animations** : anneau du minuteur, bascule d'onglets
**Pièges connus** : aucun assumé

## 12. MÉTÉO
**Écrans** : page DOMICILE Lyon (température, condition, ↑↓, bande horaire scrollable avec Coucher, prévisions 10 jours avec barres + point du jour + % pluie, qualité de l'air, 8 tuiles ressenti/UV/vent/coucher/précipitations/visibilité/humidité/pression) ; pages Théizé et MARSEILLE (le port du 28) ; feuille CONDITIONS MÉTÉO (sélecteur de jours, graphe de courbe, bascule Réelle/Ressentie) ; LISTE DES VILLES (cartes dégradées, recherche) ; CARTE plein écran (pastilles de température des 3 villes) ; footer « Météo pour le domicile 14 rue des Capucins »
**Gestes & touchers** : pagination points + flèche localisation ; tap sur chaque tuile ; l'AJOUT d'une ville échoue en réseau après spinner ~1,4 s = VOULU (app en ligne, anneau 3 D56) ; « Signaler un problème » → alerte réseau (voulu)
**Contenu Sarah** : Marseille dans les villes = or narratif gratuit ; cohérence du 27°/ensoleillé avec le widget de l'accueil
**Pièges connus** : icônes météo SF multicolores proches mais pas identiques aux glyphes Apple ; îlot dynamique noir = artefact simulateur (vérifier absent sur device)

## 13. CALCULATRICE
**Écrans** : élémentaire (clavier exact, 162+98 → 260, expression grise rappelée au-dessus) ; menu de modes (Élémentaire ✓ / Scientifique / Notes mathématiques / Convertir) ; historique de session
**Gestes & touchers** : calcul chaîné ; C/AC contextuel ; ⌫ ; +/- ; % iOS (contextuel après +/-) ; virgule française + séparateur milliers (espace) ; touche opérateur active inversée (fond blanc) ; police adaptative sur longs nombres ; appui long résultat → copie ; glyphe bas-gauche = glyphe DESSINÉ (plus de carré tofu) ; paysage → comportement B validé (vérifie le message)
**Contenu Sarah** : pur clone sans état narratif — rien à vérifier côté histoire
**Pièges connus** : Scientifique/Convertir — vérifier que chaque entrée du menu répond A, B ou C (rien ne ment)

## 14. DICTAPHONE
**Écrans** : Tous les enregistrements (Tous/Favoris/Mes dossiers avec compteurs) ; rangée dépliée avec lecteur ±15 s ; feuille transcription ; feuille d'enregistrement (chrono + onde animée)
**Gestes & touchers** : LECTURE RÉELLE de « Nouvel enregistrement 14 » (16 août, 0:22 — Sarah répète son RDV bancaire : « c'est pour des travaux… 5000 euros… onze heures trente ») ; seek ±15 s ; transcription pendant la lecture ; menu contextuel Renommer (champ réel) / Dupliquer / Supprimer / Favori réels ; BOUTON ROUGE enregistre VRAIMENT → crée « Nouvel enregistrement N » en tête ; « Remplacer » → réponse matérielle déterministe (« micro utilisé par une autre app ») = voulu, juge le wording
**Contenu Sarah** : le mémo bancaire = OR NARRATIF (recoupe P60 mot pour mot) — audio audible, transcription juste ; « Idée photo quais » (12 oct 2025, favori, dossier Idées photo)
**Pièges connus** : « Remplacement impossible » conservé (rare, D82)

---

# SESSION 4

## 15. FICHIERS — ✅ VALIDÉE 02/09 20h10 (build 278)
**Écrans** : Récents (grille avec VRAIES vignettes photo, bascule Icônes/Liste, tri Nom/Type/Date/Taille/Tags) ; fiche Infos complète ; aperçu plein écran (image / page PDF) ; recherche à jetons « Le nom contient “x” » + état vide ; Partagé (état vide) ; Explorer (favoris, emplacements, Suppressions récentes RÉCUPÉRABLES, 10 tags colorés) ; dossiers Documents / Kiné / Billets
**Gestes & touchers** : appui long → Coup d'œil, Ouvrir avec, Lire les informations, Renommer, Compresser, Dupliquer, Afficher dans le dossier parent, Tags ; barre d'onglets en pilule flottante (3 onglets) ; bouton Ouvrir dans Infos ; chaque emplacement s'ouvre ; FeuillePartage
**Contenu Sarah** : 12 fichiers recoupant Mail/Banque/Kiné/pellicule ; « billet-tgv-28-aout » tag Important = or narratif ; emplacements réduits à un jeu crédible (pas les apps tierces du vrai iPhone)
**Pièges connus** : aucun assumé

## 16. LOCALISER — ✅ VALIDÉE 02/09 20h10 (build 278)
**Écrans** : carte MapKit plein écran + pastilles par onglet ; PERSONNES (Chloé partage vivant Croix-Rousse « Maintenant », Maman Théizé « il y a 40 min », **« Marc ❤️ — Invitation envoyée le 12 mai · En attente »**) ; fiche personne (Contacter / Itinéraire / Me prévenir toggle / Cesser de partager) ; fiche invitation (Renvoyer) ; APPAREILS (iPhone de Sarah « Cet iPhone » 14 rue des Capucins, AirPods Domicile il y a 2 h, MacBook Air « Aucune position trouvée ») ; fiche appareil complète (Émettre un son avec réponses distinctes cet-appareil/distant, Itinéraire, Mode Perdu → code requis, Me prévenir, Effacer/Supprimer avec messages iOS) ; OBJETS (AirTag « Clés 🔑 » entier : Émettre un son à portée, Recherche de précision, Mode Perdu, Retirer) ; MOI (Ma position, Partager toggle, Étiquette, Autoriser les demandes d'amis)
**Gestes & touchers** : chaque action de fiche répond (A ou B crédible — « mise à jour iOS nocturne » validée en B)
**Contenu Sarah** : l'invitation Marc en attente depuis le 12 mai = l'indice en creux (il n'a JAMAIS accepté de partager sa position)
**Pièges connus** : sur TON iPhone, les actions Localiser sont zone INTERDITE D71 — compare avec des captures, ne déclenche rien

## 17. SANTÉ — ✅ VALIDÉE 02/09 18h50 (build 274) — à enrichir selon les histoires
**Écrans** : Résumé (cartes épinglées avec mini-graphes, Points forts 2 cartes, Tendances 5 lignes avec flèches) ; Parcourir (catégories) ; Activité (pas/distance/étages/énergie active) ; SOMMEIL (phases éveil/paradoxal/léger/profond, horaires coucher/lever, historique S/M — durée totale cohérente avec les phases) ; Cœur (FC repos + FC marche) ; Audition (dB casque) ; Mesures corporelles (poids : courbe à points, 4 pesées + liste) ; états vides Alimentation / Cycle / Pleine conscience / Respiratoire ; Fiche médicale ; Contact d'urgence Maman ; Historique de santé (vaccins/antécédents)
**Gestes & touchers** : sélecteurs J/S/M (chaque échelle) ; barres interactives au tap ; tap Tendance → fiche ; loupe → recherche RÉELLE (D62) ; « Appeler » du contact d'urgence → route vers Téléphone ; barre d'onglets pilule flottante + loupe ronde séparée
**Contenu Sarah** : 35 jours (14 juil → 17 août) — nuit de 3 h 10 le 17 juil (le virement), FC 71 le 18, Western Union le 24 juil visibles dans la vue M ; nuit du 16 août 2 h 34 ; pic de pas le 11 août (banque) : l'anxiété de l'arnaque doit se LIRE dans les courbes
**Pièges connus** : pas de référence réelle (aucune donnée Santé chez Joachim) — juge la fidélité à la structure iOS et la lisibilité narrative

## 18. CARTES (Wallet) — ✅ VALIDÉE 02/09 20h10 (build 278)
**Écrans** : pile DENSE de 3 cartes (LCL Visa •••• 4417 = la MÊME que Ma Banque, fidélité Phox Photo = recoupe le mail Phox, billet TGV violet du 28 août) ; carte ouverte pleine largeur + 5 dernières transactions (recoupent Plans + l'achat SNCF) ; DÉTAIL transaction (gros montant, marchand/ville, « État : accepté », MINI-CARTE Plans du lieu, « Contacter LCL », « Signaler des informations incorrectes ») ; billet plein écran avec QR ; flux d'ajout ; réglages
**Gestes & touchers** : « Contacter LCL » → route vers Téléphone ; menu … (Commandes, Paiements préautorisés, Remplissage automatique, Expirées, Notifications, En savoir plus) : chaque entrée répond ; flux d'ajout va jusqu'au REFUS émetteur (fidèle iOS, voulu) ; bascules réelles
**Contenu Sarah** : cohérence croisée STRICTE avec Ma Banque et Plans (mêmes montants/commerces) ; billet du 28 = or narratif
**Pièges connus** : aucun assumé

## 19. MA BANQUE — ✅ VALIDÉE 02/09 20h10 (build 278)
**Écrans** : splash LCL « Connexion automatique Sarah L. » (porte ouverte D57) ; 4 onglets ; COMPTES (dépôt 132,60 € vidé par l'arnaque + Livret A 85 € vidé de 5000 en 2 virements 20/07 et 15/08) ; HISTORIQUE (OKAFOR 300 € 08/05, CB WESTERN UNION 850 € 13/06 = P67, virements Livret A → compte 2000 + 3000, retrait DAB 300, **VIREMENT 4850 REFUSÉ 16/08** badge rouge = P57, + vie normale : loyer 745, salaire ATELIER GRAPHIK 2180, kiné 8,50, pharmacie, Carrefour) ; RIB = P58 à l'identique (FR76 3000 2005…, CRLYFRPP, Lyon République) ; CARTES (Visa 4417, plafonds, opposition) ; MESSAGERIE
**Gestes & touchers** : VIREMENT FONCTIONNEL — bénéficiaires (OKAFOR « ajouté le 8 mai » !, Maman, Chloé), saisie montant, **REFUS RÉEL si plafond 3000 €/7 j dépassé** : RETENTE le virement de Sarah, l'écran P57 doit se rejouer ; succès → persiste dans l'historique ; copie IBAN réelle ; plafonds → « prenez RDV en agence » ; opposition → numéro
**Contenu Sarah** : messagerie = confirmation RDV lundi 17/08 11h30 M. Rossi agence LYON BELLECOUR « augmentation de plafond » + message sécurité « LCL ne vous demandera JAMAIS… » (ironie tragique) ; l'écart de 750 € entre le virement 4850 et les demandes WhatsApp (D58 option B)
**Pièges connus** : marque LCL = tension juridique consignée (révision D40) — pas ton sujet au test ; alertes bancaires en B validé

---

# SESSION 5 (sociales — comparaison via tes comptes B, D71)

## 20. MESSENGER
**Écrans** : Discussions (recherche Meta AI réelle + rangée notes) ; Stories ; Notifications + suggestions ; Menu ; conversation Chloé (réactions, appel manqué + Rappeler, « Vu », séparateurs datés) ; groupe « Les filles » (auteurs + avatars) ; fiche de conversation ; membres (Tous/Admins) ; contenus multimédias (3 onglets pilules) ; appel vocal (minuteur, raccrocher) ; paramètres ; invitations (2 onglets) ; archive ; nouveau message (« À : » + suggestions)
**Gestes & touchers** : bascules de fiche réelles (D62) ; envoi d'un message libre (D54 : non-distribution discrète hors moments d'histoire) ; chaque icône de la barre basse
**Contenu Sarah** : Chloé, Maman, Les filles, Thomas, Julie kiné, Nadia, Léa ; suggestion « Marc Delorme » en clin d'œil
**Pièges connus** : emojis en « ? » = artefact SIMULATEUR — sur device ils doivent être normaux, signale sinon

## 21. INSTAGRAM
**Écrans** : feed (stories à anneau dégradé + publications) ; recherche (mosaïque 3 col / Récent / résultats comptes / Annuler) ; Reels (plein écran + rail cœur-commentaire-partage) ; profil Sarah « sarah.lvsr » (12 publications, 143 followers, 187 suivis, bio, Modifier/Partager, 3 onglets grille/reels/identifications avec états vides) ; profil tiers PRIVÉ (« Ce profil est privé » + Suivre à bascule) ; visionneuse de story (barre de progression + champ message) ; DM (liste) ; activité
**Gestes & touchers** : DOUBLE-TAP j'aime réel ; chaque icône du rail Reels et de la barre basse (A/B, jamais mort) ; balayage entre stories
**Contenu Sarah** : grille cohérente avec la pellicule (photographe amateur, quais de Lyon, brume) ; profil de Marc ? (à vérifier : ce qu'il montre ou cache)
**Pièges connus** : zone orange D71 côté réel — jamais de like/follow avec ton identité réelle

## 22. SNAPCHAT
**Écrans** : Chat (thème CLAIR ; chips My AI / Groupes / Près de moi ; statuts Reçu carré bleu / Remis flèche violette / « Appuyer pour Chatter » ; badge C+ 47) ; conversation (noms colorés MOI rouge / ami bleu + barre verticale, champ « Envoyer un Chat ») ; Snap Map (MapKit Lyon réel en CLAIR + épingles amis + chips + pilule % exploré + rangée amis) ; caméra (SOMBRE, viseur diégétique + capture) ; Stories (Amis·es ronds violets + Découvrir grille 2 col) ; Spotlight (SOMBRE, plein écran + rail)
**Gestes & touchers** : balayages latéraux entre les 5 volets comme le vrai ; capture caméra ; envoi d'un chat
**Contenu Sarah** : avatars Bitmoji rendus en émojis (décision D55 fabrication maison) — juge la cohérence, pas l'absence de Bitmoji
**Pièges connus** : sur le VRAI Snapchat le chat est INTERDIT (D71 — présence + captures détectées) : compare depuis ton compte B avec prudence

## 23. FACEBOOK
**Écrans** : fil clair (stories + posts) ; commentaires ; Reels ; Ami(e)s ; Groupes ; Notifications ; Menu
**Gestes & touchers** : J'AIME réel ; commentaire AVEC ENVOI réel ; Ami(e)s Confirmer/Supprimer RÉELS ; Groupes Rejoindre ; barre de navigation complète ; chaque action bascule et reste dans la session
**Contenu Sarah** : casting cohérent (Chloé, Maman, la vie lyonnaise) ; ce que Facebook dit — ou ne dit pas — de Marc
**Pièges connus** : zone orange D71 côté réel — compte B uniquement

---

# SESSION 6

## 24. X
**Écrans** : fil (Pour vous / Abonnements) ; post détail ; Explore (tendances) ; Notifications (2 onglets) ; DM (conversation) ; composer ; bouton + flottant
**Gestes & touchers** : RÉPONSE réelle à un post ; rail d'un post (like/repost/réponse/partage) A ou B crédible partout ; composer → publication visible dans le fil ?
**Contenu Sarah** : compte discret (elle consomme plus qu'elle ne poste) ; fils suivis cohérents (photo, Lyon)
**Pièges connus** : zone orange D71 côté réel — compte B

## 25. CHATGPT
**Écrans** : accueil Chat/Work « Salut Sarah » ; conversation scriptée « cadeau maman » ; panneau latéral ; bibliothèque ; projets
**Gestes & touchers** : MESSAGE LIBRE → une réponse locale unique (D18 : AUCUNE IA d'exécution — c'est une décision de fond, juge la crédibilité du wording, pas « l'IA répond pas comme la vraie ») ; micro/casque et autres icônes → B crédible ou C, jamais mort
**Contenu Sarah** : historique de conversations qui raconte Sarah (recherches cadeau, questions du quotidien — et peut-être des questions sur Marc ?)
**Pièges connus** : voir D18 ci-dessus

## 26. SPOTIFY
**Écrans** : accueil (chips + grille reprise + radios + « Conçu pour Sarah ») ; MINI-LECTEUR ; LECTEUR plein écran (progression ANIMÉE + carte paroles) ; artiste (GIMS) ; bibliothèque ; recherche par genres ; Premium
**Gestes & touchers** : play/pause/suivant — cohérence d'état entre mini-lecteur et plein écran ; shuffle/repeat A ou B ; tap artiste/album/playlist
**Contenu Sarah** : 127 morceaux annoncés dans Réglages → cohérence d'univers musical
**Pièges connus** : pas d'audio réel attendu à ce stade (catalogue médias D51) — juge l'UI et les états, note si un son te manque pour y croire

## 27. YOUTUBE
**Écrans** : accueil (cartes + rangée Shorts) ; LECTEUR complet (actions, commentaires, suggestions) ; Shorts plein écran ; Abonnements ; Vous ; notifications
**Gestes & touchers** : S'ABONNER réel ; rail du lecteur (like, partager, télécharger…) A ou B ; navigation pendant « lecture » ; balayage entre Shorts
**Contenu Sarah** : historique/abonnements qui racontent Sarah (photo, Lyon, tutos)
**Pièges connus** : vignettes vidéo = images fixes (pas de vraie vidéo à ce stade, D51) — juge la crédibilité de l'ensemble

---

# APRÈS LES 28 : les apps NON encore construites (pour info — hors campagne)
Plans (construite v1 20/08, pas dans la liste des 28 : à intégrer en session 4 si tu veux — écrans : recherche, lieux rapides Domicile/Kiné/Transports, fiche lieu, itinéraires multimodes 2-3 alternatives, navigation guidée ; récents narratifs : « LCL Agence Bellecour », « Gare Part-Dieu il y a 7 jours », « Western Union Part-Dieu 13 juin », « 12 rue des Fantasques jeudi »). Puis vague A du catalogue (D87) : Tinder, SNCF, PayPal, FaceTime, LinkedIn, Uber, App Store, Musique — chacune naîtra avec ce niveau d'exigence.
