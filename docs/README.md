# Lost Phone — Socle documentaire

> **Titre de travail interne — jamais public** (décision D21 : nommage différé, six critères pré-validés).

Ce dossier est le socle documentaire versionnable du projet **Lost Phone**, produit le 2026-07-20 à la clôture
de la phase d'arbitrage des fondations (décisions D01 à D27). Il est conçu pour vivre dans le dépôt Git du
projet (décision D23 : le dépôt est la source de vérité ; l'hébergeur est remplaçable).

## Comment lire ce dossier

| Fichier | Contenu |
|---|---|
| `00-vision.md` | Identité, essence, pitch, vision produit complète |
| `01-principes.md` | Les 7 principes fondamentaux + règle de préséance + jurisprudence |
| `02-canon-design.md` | Toutes les règles de game design actées |
| `03-economie-diffusion.md` | Modèle économique, IA d'exécution, compatibilité, nommage |
| `04-contraintes-projet.md` | Contraintes transverses : portabilité, langues, accessibilité, éthique, production |
| `05-risques.md` | Registre des risques et mitigations actées |
| `06-registre-et-chantiers.md` | Questions ouvertes routées + briefs des chantiers à venir |
| `07-glossaire.md` | Vocabulaire du projet |
| `08-grammaire-enquete.md` | La grammaire de l'enquête : briques, mécanismes, règles transverses, checklist (D29-D32) |
| `09-chartes.md` | Charte de contenu (D34) et charte éditoriale (D36) |
| `10-portefeuille-scenarios.md` | Les cinq esquisses contrastées, banc d'essai du socle (D33) |
| `decisions/` | Le journal des décisions au format ADR : un fichier daté par décision |
| `chantiers/` | Briefs des chantiers promus (grammaire, chartes, portefeuille, tranche verticale) |

## Règles de gouvernance de ce socle

- **Le canon ne s'écrase pas : il se complète par décisions datées** (nouveaux fichiers ADR).
- Toute collision de principes tranchée devient une décision documentée qui fait précédent (D16, jurisprudence).
- Ce qui devient obsolète est marqué comme tel, jamais supprimé.
- Tant que le dépôt Git n'existe pas, `project_memory.json` (maintenu en continu, D15) reste la mémoire vivante ;
  à la création du dépôt, ce socle devient la référence et le JSON un instantané de migration.

## État du projet à la clôture des arbitrages

- Blocs A (design joueur), B (économie/diffusion), C (projet) : **entièrement arbitrés** (D08-D24).
- Lot des 15 propositions : **soldé** (D25-D26). Registre : **traité** (D27).
- Aucune ligne de code, aucun choix technique : la phase architecture s'ouvre après validation de la clôture.
- Grammaire de l'enquête : RÉALISÉE (D29-D32, voir `08-grammaire-enquete.md`). Prochains chantiers :
  chartes + portefeuille de scénarios → tranche verticale (voir `chantiers/`).
