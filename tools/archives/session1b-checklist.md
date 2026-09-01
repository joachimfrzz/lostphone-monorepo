# Checklist fermée — Session 1b : Réglages (protocole D75)

**But de production** : diff P5 de ReglagesApp.swift (27 sous-pages construites, jugée « C'est good » le 17/08 avec D56) contre l'iPhone réel de Joachim. La coque est déjà capturée (session 1) ; Réglages est à refaire (captures prises sur la sous-page VPN par erreur).

**Rappels D75** : aucune capture hors liste ; écran imprévu = noté ci-dessous, jamais exploré ; ligne ratée = `--ligne N`, pas d'exploration libre ; arrêt = checklist terminée (cible indicative 45-60 min).

| # | Écran / geste | Ce qu'on cherche | Ce que ça changera dans notre app |
|---|---|---|---|
| 10 | Racine + 3 scrolls | Ordre exact des sections, libellés, icônes, espacement des groupes | Ordre/regroupement de la racine de ReglagesApp |
| 11 | Wi-Fi | Structure liste réseaux, toggles, pied de page | Fidélité écran Wi-Fi |
| 12 | Bluetooth | Structure appareils, états connecté/non connecté | Fidélité écran Bluetooth |
| 13 | Général → Informations | Lignes exactes d'Informations (nom, version, modèle...) | Contenu réel de l'écran Informations |
| 14 | Luminosité et affichage | Sliders, modes apparence, True Tone | Fidélité Luminosité |
| 15 | Fond d'écran | Aperçus verrouillage/accueil, boutons | Fidélité Fond d'écran |
| 16 | Batterie | Graphique 24h/10j, liste apps consommatrices | Diff avec notre reglages.batterie (validé vidéo 17/08, contrôle arbre UI) |
| 17 | Confidentialité et sécurité | Ordre des catégories, libellés iOS 26 | Fidélité Confidentialité |
| 18 | Notifications | Liste apps, styles d'aperçu | Fidélité Notifications |
| 19 | Sons et vibrations | Sliders, liste sonneries | Fidélité Sons |

**Livrable** : PNG+XML par ligne → `references/session1-2026-08-28/reglages/` + fiche Réglages (carte navigation, observations, implications) + liste d'écarts P5 → correctifs → run miroir.

**Imprévus notés (jamais explorés en séance)** :
- (à remplir en séance)
