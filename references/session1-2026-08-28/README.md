# Session 1 (2026-08-28) — coque iOS + Réglages (partiel)
Captures de l'iPhone réel (iOS 26.6.1) via SideTap/WDA. PNG encodés en base64
(.b64, découpés en .partN si gros) car l'API GitHub MCP ne pousse que du texte.
RECONSTITUER : `python3 DECODER.py` dans ce dossier.

Contenu : coque complète (accueil p1-p2, bibliothèque d'apps, centre de contrôle,
centre de notifications, multitâche) + Réglages PARTIEL (3 captures prises par
erreur sur la sous-page « VPN et gestion de l'appareil » — À REFAIRE depuis la
racine avec tools/session1b_driver.py qui contient le correctif to_root()).
Défaut connu : XML de 02/03 identiques entre eux, idem 05/06 (arbre lu avant
stabilisation de l'animation) — reprendre ces 4 XML à la prochaine session.
