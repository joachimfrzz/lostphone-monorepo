# Contraintes de projet

## Contraintes transverses (canon d'origine, amendé)

### Multi ia

D'autres modèles/outils IA interviendront selon les besoins (développement, design, rédaction, QA, génération de contenus). Le projet ne doit JAMAIS dépendre d'un agent, d'un modèle ou d'un fournisseur spécifique.

### Portabilite

Développement poursuivable avec un autre outil, un autre compte ou une autre équipe sans reconstruction. Connaissance documentée et transmissible.

### Github source de verite

AMENDÉ le 2026-07-20 (D23) : la source de vérité est un dépôt versionné au standard ouvert (Git) — historique, versions nommées, clonable intégralement ; l'hébergeur est librement remplaçable et son nom ne fait pas partie du canon. (Formulation d'origine, conservée pour historique : « GitHub source de vérité — le code source et son historique constituent la référence technique du projet. »)

### Notion organisation

Notion N'EST PAS la source de vérité. Usage : suivi d'avancement, documentation de certaines décisions, bugs, idées, préparation des futures histoires, informations de travail.

### Architecture multi histoires

Le projet est pensé dès le départ pour accueillir de nombreuses histoires. Aucune décision importante prise UNIQUEMENT pour les besoins du premier scénario.

### Documentation

Les choix importants sont expliqués et documentés. Une personne découvrant le projet des mois plus tard doit rapidement comprendre son fonctionnement, ses principes, ses décisions.


## Source de vérité et contenu (D23)

- Dépôt Git = source de vérité (hébergeur remplaçable, hors canon). Une histoire = un dossier auto-contenu versionné (textes, données, médias — gros fichiers en gestion adossée). Gel D20 = versions nommées.

## Langues (D22)

- Localisable dès la conception (rien en dur). Français = langue maîtresse d'écriture/curation ; dérivées par langue avec QA et suite d'évaluation propres. Lancement en français seul.

## Accessibilité (D22)

- Règle de design des indices : jamais uniquement couleur/son/lecture fine ; transcriptions de tous les vocaux. Un indice inaccessible = fair-play cassé.

## Éthique (D24)

- Voyeurisme assumé partout, jamais moralisé (la détection diégétique reste un ressort admis, distinct de la morale). Quatre principes plancher de contenu (durs suggérés ; interdits absolus ; souffrance jamais récompensée en spectacle ; sujets sensibles responsables). Vie privée du joueur par défaut (jamais de collecte des saisies).

## Modèle de production (C1/D06)

- **Équipe** : L'utilisateur seul.
- **Mode** : La majorité du travail est réalisée par IA ; l'utilisateur corrige ce qui ne lui convient pas et apporte ses idées. Rôle réel : directeur créatif / curateur d'une production IA.
- **Disponibilité** : Très disponible.
- **Échéance** : Aucune. (Risque de perfectionnisme identifié — la tranche verticale est proposée comme borne de réalité.)
- **Budget** : Pas d'enveloppe fixe. Services externes justifiés au cas par cas selon leur valeur.
- **Attente de débit (à valider sur la tranche verticale)** : Attente utilisateur (2026-07-20) : une histoire de qualité en quelques jours grâce à l'IA. À VALIDER par la mesure sur la tranche verticale — chiffre le plus important du projet (conditionne la date du day-one et la cadence du flux d'abonnement).

**Conséquences identifiées :**

- Le goût de l'utilisateur est le goulot de qualité : il faudra une charte éditoriale/de voix pour rendre ce goût exécutable par les IA.
- La cohérence référentielle devient encore plus critique avec du contenu généré par IA à grande échelle.
- Les outils de création doivent être pensés IA-in-the-loop dès l'origine.
- Les artefacts du projet (specs, formats, docs) doivent être lisibles et actionnables par des agents hétérogènes, humains ou IA.
