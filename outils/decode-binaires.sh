#!/usr/bin/env bash
# Les images (icônes iOS/web) ne transitent pas par l'API GitHub en texte :
# elles sont stockées dans outils/binaires.tar.b64 et restaurées par ce script
# (exécuté par codemagic.yaml avant le build, ou à la main après un clone).
set -e
cd "$(dirname "$0")/.."
python3 -c "import base64; open('/tmp/binaires.tar','wb').write(base64.b64decode(open('outils/binaires.tar.b64').read()))"
tar xf /tmp/binaires.tar
echo "Binaires restaurés ($(tar tf /tmp/binaires.tar | wc -l | tr -d ' ') fichiers)."
