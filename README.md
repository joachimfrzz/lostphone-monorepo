# Lost Phone — monorepo

Jeu narratif d'investigation sur smartphone simulé. Repo **privé** (D40 : rien de public avant révision juridique).

> **Nouvel agent / nouveau fil / nouveau compte Hyperagent ? Lire `PASSATION.md` en premier**, puis `project_memory.json`, puis `docs/PROCEDURES-AGENT.md`.

## Carte du repo

| Zone | Contenu | Statut |
|---|---|---|
| `project_memory.json` | **Source de vérité projet** — mémoire vivante complète (D15), TOUTES les décisions (D01→D94), état exact dans `etat_conversation`, re-poussée ici à chaque mise à jour | VIVANT |
| `PASSATION.md` | Mode d'emploi de reprise (passation Hyperagent ET Codemagic) — V5 du 10/09/2026 | VIVANT |
| `docs/PROCEDURES-AGENT.md` | Savoir-faire opérationnel de l'agent : cycle d'un lot d'apps, vidéos SwissTransfer → frames, push par morceaux, sous-agents, miroir, fiche | VIVANT |
| `docs/regles-constructeur.md` | Règles données aux sous-agents qui construisent une app (compilation sans compilateur, D59/D67/D92/D93, conventions de coque) | VIVANT |
| `FEUILLE-DE-ROUTE.md` | Feuille de route validée (D87) | VIVANT |
| `proto-swift/` | **LE JEU** — prototype SwiftUI (D50), ~35 apps, sources + assets. Coque : `LPProto.swift` (+ `CoqueV2.swift`) | VIVANT |
| `codemagic.yaml` | CI : `duel-swift-testflight` (TestFlight, sur GO de Joachim uniquement — D65), `miroir-captures` (captures simulateur D63, registre `ECRANS_FICHIER`), `icones-sim` | VIVANT |
| `FICHES-VERIFICATION-APPS.md`, `fiches-verification.html`, `CAMPAGNE-VERIFICATION.md` | Fiche de vérification vivante (D89 : section « Dernier build » + checklist) et état de la campagne D84 (`tools/build_fiche_html.js` génère la page) | VIVANT |
| `docs/audit-sociales/`, `docs/vague-a/`, `docs/vague-b/` | Livraisons d'apps (écrans reproduits, retraits à arbitrer, registres), retours de Joachim par build, relecture D94 | VIVANT |
| `outils/` | Archives base64 pour la CI (pellicule, binaires, icônes, **frames de référence** `refs-*.tar.b64.part*` — décodées au build par `decode-binaires.sh`), registres d'écrans `ecrans*.txt`, vérificateurs `verif_*.py` | VIVANT (entrées de build — ne pas déplacer sans mettre à jour `codemagic.yaml`) |
| `refs-officiel/*/SOURCES.md` | Sources des captures officielles utilisées à défaut de vidéo (D93) | VIVANT |
| `tools/` | Scripts : `build_fiche_html.js`, `passation/api.py` (copie du script de la skill Codemagic) ; scripts SideTap historiques (régime D71, non utilisé depuis septembre) | VIVANT / HISTORIQUE |
| `histoires/coches-bleues/` | Tranche verticale : format d'histoire (YAML) + conception | VIVANT |
| `references/` | Références du VRAI iPhone capturées via SideTap (sessions S1→S6) — régime D71, historique | HISTORIQUE UTILE |
| `docs/` (autres) | Socle documentaire des fondations (juillet 2026). Les fiches de décision s'arrêtent à D27 : depuis, le registre canonique est `project_memory.json` | HISTORIQUE UTILE |
| `interactions.yaml`, `corrections.yaml`, `liste-apps.yaml`, `marques.yaml` | Doctrine des interactions (D69), correctifs, catalogue des 70 apps (cercles 1-3, D47/D48), assets de marque (D40) | VIVANT |
| `moteur/` | **OBSOLÈTE** — prototype Flutter du jalon-duel D49, perdu contre SwiftUI (D50) | OBSOLÈTE |

**Canal de build** : `codemagic.yaml` → `duel-swift-testflight` → TestFlight (`com.lostphone.game`), numéros = 260 + index Codemagic (dernier : 282, 08/09/2026).

**Références (D67/D93)** : les enregistrements d'écran de Joachim (SwissTransfer → frames 603×1311 archivées dans `outils/refs-*`), à défaut les captures officielles de l'éditeur. Jamais la mémoire du web.
