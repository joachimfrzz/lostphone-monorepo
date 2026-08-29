# Fiche de référence — TÉLÉPHONE / CONTACTS / MESSAGES (S3, 2026-08-29)

Sources : vidéo 7 min 11 @60fps → 335 états distincts + 32 arbres XML (écoute D78). Apps construites concernées : TelephoneApp (validée 17/08), MessagesApp (validée 17/08), Contacts (onglet de Téléphone).

## Couverture
- **Téléphone** : Récents (filtres), Favoris, Contacts (liste + fiche), fiche détail d'appel (CommunicationDetails), **Messagerie vocale + lecteur détaillé (VoicemailDetailView)**
- **Contacts** : liste, fiche, **Listes** (écran de listes de contacts)
- **Messages** : liste conversations, conversation, **Suppressions récentes**, **Indésirables**
- Exhaustivité fine (onglets/composeur/détails) à confronter aux 335 états vidéo lors du diff — reliquats éventuels en passe 2 avec S4.

## Or narratif (cartographie D79)
- **Messages > Suppressions récentes** : LA mécanique canonique pour l'or effacé-récupérable (P66-P68, D58) existe nativement dans Messages — notre clone doit l'avoir (conversations supprimées D69 déjà ouvrables : à aligner sur cet écran réel)
- **Messages > Indésirables** : le canal naturel des SMS de phishing (SecuriBQE/P59)
- **Listes de contacts** : le tri social du propriétaire (Famille/Travail/...) = caractérisation
- **Fiche détail d'appel** : durées et récurrences = la texture d'une relation

## Implications diff P5
1. TelephoneApp : confronter Récents/fiche/messagerie aux états réels (notre app validée 9,8 mais construite sur vidéo 16/08 — iOS 26.6 a pu bouger)
2. MessagesApp : ajouter Suppressions récentes + Indésirables à l'idiome exact ; vérifier le composeur
3. Contacts : écran Listes absent de notre clone (onglet Contacts de Téléphone) — à créer
