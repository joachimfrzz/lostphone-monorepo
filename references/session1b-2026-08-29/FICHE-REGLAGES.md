# Fiche de référence — Réglages (iPhone réel, iOS 26.6.1)

Session 1b du 2026-08-29 (protocole D75, dossier de référence D72). Sources : 16 écrans PNG 1206×2622 + arbres UI XML, capturés en lecture seule via SideTap/WDA. Tout élément non testé est marqué `[INFÉRÉ]`.

## Carte de navigation (liens VÉRIFIÉS par tap)

```
Racine ──▶ Wi-Fi
       ──▶ Bluetooth
       ──▶ Général ──▶ Informations
       ──▶ Luminosité et affichage
       ──▶ Fond d'écran
       ──▶ Batterie
       ──▶ Confidentialité et sécurité
       ──▶ Notifications
       ──▶ Sons et vibrations
```
Retour : BackButton en haut à gauche (nom accessible `BackButton`). Tous les autres liens de la racine : `[INFÉRÉ]` (non tapés dans cette session).

## Racine (08 → 08f, 6 états de scroll)

- **Structure** : grand titre « Réglages » → carte Compte Apple (avatar Memoji + nom + « Compte Apple, iCloud+ et autres ») → groupes de cartes sombres à coins arrondis, séparés par du fond noir.
- **Ordre exact des groupes/lignes observé** :
  1. Carte compte
  2. Connectivité : Mode Avion (toggle), Wi-Fi (valeur = SSID), Bluetooth (« Oui »), Données cellulaires, Partage de connexion (« Non »), Batterie, VPN (« Déconnecté »)
  3. Général, Accessibilité, Apple Intelligence et Siri, Appareil photo, Bouton Action, Centre de contrôle, Écran d'accueil et bibliothèque d'apps, En veille, Fond d'écran, Luminosité et affichage, Recherche
  4. Notifications, Sons et vibrations, Concentration, Temps d'écran
  5. Face ID et code, Appel d'urgence, Confidentialité et sécurité
  6. Cartes et Apple Pay, puis groupe Apps `[INFÉRÉ : sous le bord en 08f]`
- **Pilule « Recherche » FLOTTANTE en bas d'écran** (loupe + micro), au-dessus du contenu — elle masque les lignes du bas (voir Pièges).
- Batterie apparaît DANS le groupe connectivité (remontée iOS 26), en plus d'exister comme page.
- Barre de statut : heure à gauche + cloche barrée (silence), retour « ◀ Safari » possible en haut à gauche (lien d'app précédente).

## Pages capturées — contenu notable

- **Wi-Fi (10)** : toggle Wi‑Fi, réseau connecté avec ⓘ « Plus d'infos », bouton Modifier en haut à droite, sections MES RÉSEAUX / AUTRES RÉSEAUX `[INFÉRÉ pour les libellés de section exacts : voir XML]`.
- **Bluetooth (11)** : toggle, appareils appairés avec état (« Non connecté ») + ⓘ.
- **Général (12)** : Informations, Mise à jour logicielle, Stockage de l'iPhone, AirDrop, AirPlay… (ordre dans le XML).
- **Informations (13)** : 39 lignes — Nom (« iPhone de Joachim »), versions, modèle, numéro de série, réseau… C'est LA source pour notre écran Informations (remplacer par les données Sarah).
- **Luminosité (14)** : Claire/Sombre (sélecteur visuel), Automatique (toggle), **« Liquid Glass : Transparent »** (réglage iOS 26 nouveau — absent de notre clone), Taille du texte, True Tone…
- **Fond d'écran (15)** : aperçus verrouillage + accueil côte à côte, « Personnaliser » sous chacun, « ACTUEL » en étiquette.
- **Batterie (16)** : « 43 % — En charge », graphique, **« Limite de 100 % »** et « Niveau de la batterie : 80 % » (recharge optimisée iOS 26), liste par app `[INFÉRÉ : plus bas]`.
- **Confidentialité et sécurité (17)** : Service de localisation (« 32 pendant l'utilisation »), Suivi (« 157 »), puis catégories (Contacts, Calendriers…). ⚠️ Valeurs personnelles = mesure uniquement.
- **Notifications (18)** : styles d'affichage (Nombre/Liste/Pile `[INFÉRÉ pour Pile]`), Résumé programmé (« Non »), Aperçus, puis liste des apps.
- **Sons et vibrations (19)** : Mode Silence + « Afficher dans la barre d'état », Entrée (« Micro de l'iPhone »), sonneries, vibrations.

## Implications pour ReglagesApp (diff P5 à dérouler)

1. **Pilule Recherche flottante en bas de la racine** : notre clone l'a — vérifier position/taille/matériau exacts contre 08*.
2. **Ordre des groupes de la racine** : à superposer ligne à ligne (notre racine date des vidéos du 17/08 ; iOS 26.6 a remonté Batterie et ajouté En veille/Bouton Action).
3. **« Liquid Glass : Transparent »** dans Luminosité : absent de notre clone — à ajouter (marqueur d'iOS 26 très visible).
4. **Batterie** : « Limite de 100 % » + état de charge dans l'en-tête — comparer à notre reglages.batterie.
5. **Informations** : 39 lignes réelles — notre écran doit avoir la même densité (données Sarah).
6. La carte Compte Apple : avatar photo (déjà corrigé p04) + sous-titre exact « Compte Apple, iCloud+ et autres ».

## Pièges de pilotage consignés (leçons de séance)

- **Une ligne sous la pilule Recherche flottante reçoit le tap SANS naviguer** → toujours repositionner la ligne au milieu de l'écran avant de taper, puis **vérifier la navigation** (header du XML) avant de capturer.
- Préférer `label == 'Sons et vibrations'` (exact) à `CONTAINS 'Sons'` : un CONTAINS peut matcher une ligne d'une toute autre page (capture Aippy).
- Après un swipe, **1,5 s de pose** avant capture (inertie).
- Réglages rouvre sur la dernière page visitée → toujours `to_root()` + vérifier « Mode Avion » présent avant de commencer.
