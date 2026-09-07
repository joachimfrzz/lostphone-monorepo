# Refs vague B — Uber & SNCF Connect

Ce dossier contient les frames de référence (vague B) pour les flux Uber et SNCF Connect,
ainsi que les icônes officielles en 180x180.

## Contenu

- `outils/refs-vagueB.tar.b64.part00` à `part10` : archive tar des frames, encodée en base64
  et découpée en 11 parts pour respecter la limite de taille des requêtes GitHub.
  - 56 frames Uber (`refs/vagueB/uber/e001.jpg` à `e056.jpg`)
  - 196 frames SNCF Connect (`refs/vagueB/sncf/e001.jpg` à `e196.jpg`)
  - Résolution des frames : 603x1311
  - Source : vidéos de Joachim du 07/09/2026
  - Aucune vidéo FaceTime : les captures officielles Apple sont dans `refs-officiel/`
- `outils/icones-vagueB.tar.b64` : archive tar des icônes officielles en 180x180
  (`ic-uber-180.png`, `ic-sncf-180.png`), encodée en base64.

## Reconstitution

Frames :

```
cat outils/refs-vagueB.tar.b64.part* | base64 -d > refs-vagueB.tar
tar -xf refs-vagueB.tar
```

Icônes :

```
base64 -d outils/icones-vagueB.tar.b64 > icones-vagueB.tar
tar -xf icones-vagueB.tar
```
