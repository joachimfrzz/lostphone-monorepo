# Lost Phone — monorepo

Jeu narratif d'investigation sur smartphone simulé. Repo **privé** (D40 : rien de public avant révision juridique).

> **Nouvel agent / nouveau compte Hyperagent ? Lire `PASSATION.md` en premier.**

## Carte du repo

| Zone | Contenu | Statut |
|---|---|---|
| `project_memory.json` | **Source de vérité projet** — mémoire vivante complète (D15), TOUTES les décisions (D01→D8x), re-poussée ici à chaque mise à jour | VIVANT |
| `PASSATION.md` | Mode d'emploi de reprise (passation Hyperagent ET Codemagic) | VIVANT |
| `FEUILLE-DE-ROUTE.md` | Feuille de route validée (D87) | VIVANT |
| `proto-swift/` | **LE JEU** — prototype SwiftUI (D50), ~29 apps, sources + assets | VIVANT |
| `codemagic.yaml` | CI : workflows `duel-swift-testflight` (TestFlight, sur GO de Joachim uniquement — D65), `miroir` (captures simulateur D63), `icones-sim` | VIVANT |
| `histoires/coches-bleues/` | Tranche verticale : format d'histoire (YAML) + conception | VIVANT |
| `references/` | Références du VRAI iPhone capturées via SideTap (sessions S1→S6, crawl) — régime D71 | VIVANT |
| `tools/` | Scripts SideTap côté PC/agent : `Demarrer-LostPhone.cmd`, crawler, écoute passive, moniteur tablette | VIVANT |
| `outils/` | Archives base64 pour la CI (pellicule, binaires, icônes — décodées au build par `decode-binaires.sh`) + références historiques pré-SideTap | VIVANT (entrées de build — ne pas déplacer sans mettre à jour `codemagic.yaml`) |
| `docs/` | Socle documentaire des fondations (juillet 2026) + ops. Les fiches de décision s'arrêtent à D27 : depuis, le registre canonique est `project_memory.json` (voir `docs/decisions/README.md`) | HISTORIQUE UTILE |
| `interactions.yaml`, `corrections.yaml`, `liste-apps.yaml`, `marques.yaml` | Doctrine des interactions (D69), correctifs, catalogue des ~68 apps (D47/D48), assets de marque (D40) | VIVANT |
| `CAMPAGNE-VERIFICATION.md`, `GUIDE-VERIFICATION-COMPLET.md`, `MODE-EMPLOI-CAMPAGNE.md`, `campagne-analyse.yaml`, `cartographie-narrative.md` | Campagne de vérification totale (D84) + campagne d'analyse (D79) | VIVANT |
| `moteur/` | **OBSOLÈTE** — prototype Flutter du jalon-duel D49, perdu contre SwiftUI (D50). Conservé : référence possible pour le re-arbitrage ARCH-2 (Android, D11) | OBSOLÈTE |

**Canal de build** : `codemagic.yaml` → workflow `duel-swift-testflight` → TestFlight (`com.lostphone.game`). *(L'ancien canal `duel-flutter-testflight` est obsolète depuis D50.)*

**Régime de références D71** : l'agent pilote l'iPhone réel de Joachim via SideTap/WDA, en LECTURE SEULE stricte (voir `PASSATION.md` et D71 dans `project_memory.json`).
