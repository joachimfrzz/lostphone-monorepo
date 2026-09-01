# tools/ — scripts SideTap (régime D71)

Scripts du pilotage de l'iPhone réel de Joachim et des sessions de capture.
Ne pas confondre avec `outils/` (archives base64 pour la CI — voir `outils/README.md`).

| Fichier | Rôle | Statut |
|---|---|---|
| `Demarrer-LostPhone.cmd` | Rituel de démarrage côté PC (harness SideTap + tunnel cloudflared) — copie de référence du script du Bureau | ACTIF |
| `phone_monitor.py` | Moniteur tablette (port 8781) — surveillance visuelle pendant toute session de pilotage | ACTIF |
| `crawler_sidetap.py` | Crawler exhaustif d'écrans (doctrine D77) | ACTIF |
| `ecoute_passive.py` | Enregistreur passif « toi aux doigts, moi à l'écoute » (D78) — capture PNG+XML pendant que Joachim manipule | ACTIF |
| `prompt-carnet.txt` | Prompt du carnet parallèle des sessions (D79) | ACTIF |
| `archives/` | Scripts de sessions TERMINÉES, conservés comme modèles (voir `archives/README.md`) | HISTORIQUE |
