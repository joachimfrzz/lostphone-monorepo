# Registre des risques

## R1 — Le pari des checkpoints sémantiques (criticité : MAJEURE)

Signature potentielle ET premier point de défaillance : faux négatifs (joueur qui a compris mais rejeté = pire frustration possible, pire qu'un QCM car il SAIT qu'il a raison), énumération/brute-force des noms, multilinguisme (la tolérance sémantique doit marcher dans chaque langue), coût d'exécution, dépendance réseau, exigence d'indépendance fournisseur appliquée au jeu. Nécessite doctrine de repli et suite d'évaluation.

**mitigations actees 2026 07 20** : D14 : co-priorité de la preuve par le geste (réduit l'exposition au texte libre, sans ambiguïté dans toutes les langues) ; sortie de secours diégétique obligatoire (aucun blocage dur) ; validation par raisonnement contre l'énumération ; porteur personnage (jamais de rejet mécanique bonne/mauvaise réponse). Restent ouverts : multilinguisme de la validation sémantique, coût d'exécution, dépendance réseau, indépendance fournisseur → B1 + suite d'évaluation.

**note 2026 07 20 b1** : D18 concentre R1 sur la QUALITÉ DE L'INTERPRÉTATION LOCALE : la suite d'évaluation devient l'instrument critique ; la tranche verticale (P09) gagne un objectif prioritaire — prouver l'interprétation locale tôt. Coût d'exécution, réseau et dépendance fournisseur : réglés.

## R2 — Économie unitaire du contenu (criticité : MAJEURE)

Chaque histoire re-coûte (toile référentielle dense, médias, embranchements) ; les anthologies sont historiquement dures à rentabiliser. Le rêve de plateforme vit ou meurt sur le coût marginal d'une histoire de qualité. Réponses : outils (canon) + discipline de périmètre par histoire.

**note 2026 07 20 b1** : B1 favorable : coût variable d'exécution ≈ nul → la soutenabilité du gratuit généreux ne dépend plus que du coût de PRODUCTION par histoire (le cœur de R2).

**note 2026 07 20 b2** : La direction abonnement-flux hebdomadaire transformerait R2 en engagement commercial : cadence à ne chiffrer qu'après mesure du temps de production réel par histoire (tranche verticale). Buffer d'histoires d'avance recommandé avant tout lancement d'abonnement.

## R3 — Cohérence référentielle à l'échelle (criticité : MAJEURE)

La proposition de valeur EST la cohérence ; chaque incohérence (date, prénom, recoupement photo/agenda) est une fissure d'immersion. Aggravé par la production IA. La vérification de cohérence doit être une discipline de premier ordre, pas une relecture.

**controles actees 2026 07 20** : Discipline d'horodatage = point de contrôle nommé (D10) ; atteignabilité des vérités et réfutations = exigence vérifiable en QA (D13) ; contenu immuable (D12) réduit la combinatoire d'états à vérifier.

## R4 — Piège de la plateforme (et son miroir) (criticité : ÉLEVÉE)

Généralisation spéculative payée deux fois vs sur-spécialisation sur l'histoire 1. Réponse proposée : P03 + P04.

## R5 — Bords de la simulation (criticité : ÉLEVÉE)

Plus le téléphone est crédible, plus le joueur teste les limites (appeler un numéro, fouiller le navigateur, supprimer). Chaque limite rencontrée doit être invisible ou justifiée diégétiquement, sinon l'illusion casse là où elle a le plus de valeur.

**reponse actee 2026 07 20** : Doctrine des bords complète actée (D12) : trois niveaux + jamais de mur hors-fiction.

## R6 — Homogénéisation par l'outillage (criticité : MOYENNE)

Les outils standardisent ce qu'ils touchent ; des histoires au gabarit se ressemblent. Ligne à tracer : standardiser la plomberie (cohérence, liens, validation, médias), jamais la voix (ton, structure, personnalité).

## R7 — Juridique et éthique (criticité : ÉLEVÉE)

Marques/trade dress (imiter iOS/apps réelles), visages et personnes réalistes (droit à l'image), RGPD sur le texte libre du joueur, thèmes durs vs classification d'âge.

## R8 — Nom et découvrabilité (criticité : MOYENNE)

Collision frontale avec 'A Normal Lost Phone' / 'Another Lost Phone' (2017) : confusion, SEO, marque. Décision B4 à programmer avant communication publique.

**reponse actee 2026 07 20** : D21 : nommage différé avec déclencheur défini (premier besoin public) + six critères pré-validés. Titre de travail jamais public.

## R9 — Continuité de la connaissance en contexte multi-IA (criticité : ÉLEVÉE)

Sans documentation exécutable et versionnée, des agents hétérogènes produisent des décisions incohérentes. Réponse : P05 (docs-as-code + ADR). Le présent export en est la première brique.

## R10 — Perfectionnisme sans échéance (criticité : MOYENNE)

Pas d'échéance + solo + qualité avant rapidité = risque de ne jamais livrer. Borne de réalité recommandée : tranche verticale (P09).

**note 2026 07 20 b2** : L'architecture day-one (D19 : ~20-25 histoires avant lancement) allonge le tunnel sans feedback — mitigations à prévoir au plan de release (betas fermées, soft launch). Le débit réel par histoire (tranche verticale) devient le chiffre clef du projet.

## R11 — Goulot éditorial (criticité : ÉLEVÉE)

Production IA-majoritaire : la qualité finale = la curation de l'utilisateur. Sans charte éditoriale (P10), le goût reste implicite et la qualité incohérente.
