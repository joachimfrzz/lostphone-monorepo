# Lost Phone — monorepo

Jeu narratif d'investigation sur smartphone simulé. Repo **privé** (D40 : rien de public avant révision juridique).

| Zone | Contenu |
|---|---|
| `moteur/` | Prototype Flutter du jalon-duel D49 (verrouillage, accueil, WhatsApp/« Marc ») |
| `histoires/coches-bleues/` | Tranche verticale : format d'histoire (YAML) + conception |
| `docs/` | Socle documentaire + ops (dont `docs/ops-canal-testflight.md`) |
| `liste-apps.yaml` | Les ~68 applications du chantier design (D47/D48) |
| `marques.yaml` | Couche d'assets de marque (doctrine D40) |
| `outils/` | Outillage (dont restauration des binaires : `decode-binaires.sh`) |

**Canal de build** : `codemagic.yaml` → workflow `duel-flutter-testflight` → TestFlight (`com.lostphone.game`).
**Source de vérité projet** : `project_memory.json` (maintenu dans le thread Hyperagent).
