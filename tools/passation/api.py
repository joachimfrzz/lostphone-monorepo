#!/usr/bin/env python3
"""Pilote Codemagic pour Lost Phone (D65 — boucle autonome).

Compte Codemagic 3 — APP_ID lostphone-monorepo : 6a9454919667617e9cf9743e
(vérifié le 2026-09-01 via GET /apps avec le token actif ; offset builds +260).
OBSOLÈTES : compte 2 = 6a8f67340674263dd88340ad ; compte 1 = 6a80d5e4... (404).

Auth : header `x-auth-token` = CODEMAGIC_API_TOKEN (env, injecté par RunWithCredentials).

Usage :
  python3 api.py apps                      # liste les apps du compte (vérifie token + APP_ID)
  python3 api.py builds [N]                # N derniers builds (défaut 10) : id, workflow, statut, index
  python3 api.py status <buildId>          # statut détaillé d'un build
  python3 api.py start <workflow> [branch] # lance un build (défaut branch: main)
  python3 api.py cancel <buildId>          # annule un build

Workflows connus du codemagic.yaml : duel-swift-testflight (build TestFlight,
GARDE-FOU D65 : uniquement sur GO explicite de Joachim), miroir (captures
simulateur D63), icones-sim (extraction d'icônes officielles du simulateur).

Quota : ~500 min gratuites/mois. Vérifier le reliquat avant tout build non critique.
"""
import json
import os
import sys
import urllib.request

API = "https://api.codemagic.io"
APP_ID = os.environ.get("CODEMAGIC_APP_ID", "6a9454919667617e9cf9743e")


def token():
    t = os.environ.get("CODEMAGIC_API_TOKEN")
    if not t:
        sys.exit("CODEMAGIC_API_TOKEN absent — lancer via RunWithCredentials.")
    return t


def call(method, path, body=None):
    req = urllib.request.Request(
        API + path,
        data=json.dumps(body).encode() if body is not None else None,
        method=method,
        headers={"x-auth-token": token(), "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        sys.exit(f"HTTP {e.code} sur {path} : {e.read().decode()[:500]}")


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "builds"
    if cmd == "apps":
        data = call("GET", "/apps")
        for a in data.get("applications", []):
            print(a["_id"], a.get("appName"))
    elif cmd == "builds":
        n = int(sys.argv[2]) if len(sys.argv) > 2 else 10
        data = call("GET", f"/builds?appId={APP_ID}")
        for b in data.get("builds", [])[:n]:
            print(b["_id"], b.get("workflowId") or b.get("config", {}).get("name"),
                  b.get("status"), "index:", b.get("index"), b.get("startedAt", ""))
    elif cmd == "status":
        data = call("GET", f"/builds/{sys.argv[2]}")
        b = data.get("build", data)
        print(json.dumps({k: b.get(k) for k in
                          ("_id", "status", "index", "workflowId", "startedAt",
                           "finishedAt", "message", "artefacts")},
                         indent=1, ensure_ascii=False, default=str))
    elif cmd == "start":
        wf = sys.argv[2]
        branch = sys.argv[3] if len(sys.argv) > 3 else "main"
        body = {"appId": APP_ID, "workflowId": wf, "branch": branch}
        # Variables d'environnement optionnelles : start <wf> <branche> CLE=VALEUR ...
        variables = dict(a.split("=", 1) for a in sys.argv[4:] if "=" in a)
        if variables:
            body["environment"] = {"variables": variables}
        data = call("POST", "/builds", body)
        print("Build lancé :", data.get("buildId", data))
    elif cmd == "cancel":
        print(call("POST", f"/builds/{sys.argv[2]}/cancel"))
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
