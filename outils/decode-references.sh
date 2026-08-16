#!/usr/bin/env bash
# Restaure les captures de référence (references/) depuis les tranches outils/references.tar.b64.part*
set -e
cd "$(dirname "$0")/.."
cat outils/references.tar.b64.part* | python3 -c "import base64,sys; open('/tmp/references.tar','wb').write(base64.b64decode(sys.stdin.read()))"
tar xf /tmp/references.tar
echo "Références restaurées ($(tar tf /tmp/references.tar | wc -l | tr -d ' ') entrées)."
