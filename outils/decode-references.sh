#!/usr/bin/env bash
# Restaure les captures de référence (references/) depuis outils/references.tar.b64
set -e
cd "$(dirname "$0")/.."
python3 -c "import base64; open('/tmp/references.tar','wb').write(base64.b64decode(open('outils/references.tar.b64').read()))"
tar xf /tmp/references.tar
echo "Références restaurées ($(tar tf /tmp/references.tar | wc -l | tr -d ' ') entrées)."
