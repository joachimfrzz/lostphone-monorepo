# outils/ — archives base64 (entrées de build CI + références historiques)

⚠️ **Plusieurs fichiers de ce dossier sont des ENTRÉES DE BUILD** : `codemagic.yaml` /
`decode-binaires.sh` les décodent vers `proto-swift/Ressources/` à chaque build.
**Ne rien déplacer/renommer ici sans mettre à jour ces chemins**, sinon builds cassés.
Ne pas confondre avec `tools/` (scripts SideTap — voir `tools/README.md`).

## Entrées de build (ACTIVES — ne pas toucher)
| Archive | Contenu |
|---|---|
| `pellicule.tar.b64`, `pellicule2.tar.b64.part1-5`, `pellicule3.tar.b64` | Photos de la pellicule de Sarah (Photos, avatars…) |
| `binaires.tar.b64` | Binaires du prototype |
| `icones-apps.tar.b64` | Icônes d'apps |
| `memos.tar.b64` | Mémos vocaux (Dictaphone) |
| `ciel.tar.b64` | Assets ciel/météo |
| `decode-binaires.sh`, `decode-references.sh` | Décodeurs (CI et local) |
| `ecrans.txt` | Registre des écrans |

## Références historiques pré-SideTap (HISTORIQUE — seules copies survivantes, ne pas supprimer)
Capturées avant le régime D71 (enregistrements d'écran de Joachim, cercles 1 et 2).
Les liens d'origine (SwissTransfer/filebin) sont morts : ces archives sont les seules
copies (risque R9). Les références actuelles vivent dans `references/` (sessions SideTap).

| Archive | Contenu |
|---|---|
| `references.tar.b64.part1-4` | Références cercle 1 |
| `references-c2.tar.b64.part1-5` | Références cercle 2 (Fichiers, Cartes, Santé, Wallet…) |
| `references-messages.tar.b64`, `references-reglages.tar.b64` | Références dédiées Messages / Réglages |
| `refs-tierces-c2.tar.b64.part00-13`, `refs-tierces2.tar.b64.part00-22` | Références d'apps tierces (enregistrements d'écran de Joachim, doctrine D67) |
