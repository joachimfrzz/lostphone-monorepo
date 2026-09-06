#!/usr/bin/env bash
# Les images (icônes iOS/web, pellicule Photos) ne transitent pas par l'API GitHub en texte :
# elles sont stockées dans outils/*.tar.b64 et restaurées par ce script
# (exécuté par codemagic.yaml avant le build, ou à la main après un clone).
set -e
cd "$(dirname "$0")/.."
python3 -c "import base64; open('/tmp/binaires.tar','wb').write(base64.b64decode(open('outils/binaires.tar.b64').read()))"
tar xf /tmp/binaires.tar
echo "Binaires restaurés ($(tar tf /tmp/binaires.tar | wc -l | tr -d ' ') fichiers)."
if [ -f outils/pellicule.tar.b64 ]; then
  python3 -c "import base64; open('/tmp/pellicule.tar','wb').write(base64.b64decode(open('outils/pellicule.tar.b64').read()))"
  tar xf /tmp/pellicule.tar
  echo "Pellicule restaurée ($(tar tf /tmp/pellicule.tar | wc -l | tr -d ' ') photos)."
fi
if ls outils/pellicule2.tar.b64.part* >/dev/null 2>&1; then
  cat outils/pellicule2.tar.b64.part* > /tmp/pellicule2.b64
  python3 -c "import base64; open('/tmp/pellicule2.tar','wb').write(base64.b64decode(open('/tmp/pellicule2.b64').read()))"
  tar xf /tmp/pellicule2.tar
  echo "Pellicule vague 2 restaurée ($(tar tf /tmp/pellicule2.tar | wc -l | tr -d ' ') photos)."
fi
if [ -f outils/pellicule3.tar.b64 ]; then
  python3 -c "import base64; open('/tmp/pellicule3.tar','wb').write(base64.b64decode(open('outils/pellicule3.tar.b64').read()))"
  tar xf /tmp/pellicule3.tar
  echo "Captures restaurées ($(tar tf /tmp/pellicule3.tar | wc -l | tr -d ' ') images)."
fi
if [ -f outils/memos.tar.b64 ]; then
  python3 -c "import base64; open('/tmp/memos.tar','wb').write(base64.b64decode(open('outils/memos.tar.b64').read()))"
  tar xf /tmp/memos.tar
  echo "Mémos vocaux restaurés ($(tar tf /tmp/memos.tar | wc -l | tr -d ' ') fichiers)."
fi
if [ -f outils/ciel.tar.b64 ]; then
  python3 -c "import base64; open('/tmp/ciel.tar','wb').write(base64.b64decode(open('outils/ciel.tar.b64').read()))"
  tar xf /tmp/ciel.tar
  echo "Ciel Météo restauré ($(tar tf /tmp/ciel.tar | wc -l | tr -d ' ') image)."
fi
if ls outils/icones-apps.tar.b64.part* >/dev/null 2>&1; then
  cat outils/icones-apps.tar.b64.part* > /tmp/icones.b64
  python3 -c "import base64; open('/tmp/icones.tar','wb').write(base64.b64decode(open('/tmp/icones.b64').read()))"
  tar xf /tmp/icones.tar
  echo "Icônes d'apps restaurées ($(tar tf /tmp/icones.tar | wc -l | tr -d ' ') fichiers)."
elif [ -f outils/icones-apps.tar.b64 ]; then
  python3 -c "import base64; open('/tmp/icones.tar','wb').write(base64.b64decode(open('outils/icones-apps.tar.b64').read()))"
  tar xf /tmp/icones.tar
  echo "Icônes d'apps restaurées ($(tar tf /tmp/icones.tar | wc -l | tr -d ' ') fichiers)."
fi
# v3 02/09 : Memoji des personnes de Localiser (Chloé, Maman, Sarah) — générés, style Apple Memoji
if [ -f outils/memoji.tar.b64 ]; then
  python3 -c "import base64; open('/tmp/memoji.tar','wb').write(base64.b64decode(open('outils/memoji.tar.b64').read()))"
  tar xf /tmp/memoji.tar
  echo "Memoji restaurés ($(tar tf /tmp/memoji.tar | wc -l | tr -d ' ') images)."
fi
