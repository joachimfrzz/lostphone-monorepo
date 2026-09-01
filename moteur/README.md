# ⚠️ OBSOLÈTE — Prototype Flutter du jalon-duel (D49)

**Ce dossier n'est PLUS le jeu.** Il contient le prototype Flutter construit pour le
jalon-duel D49 (verrouillage + accueil + WhatsApp « Marc » de Coches bleues), compilé
en web puis sur TestFlight (builds série 1xx).

**Verdict du duel (D50, 2026-08) : SwiftUI retenu.** Le jeu vit dans `proto-swift/`.

## Pourquoi ce dossier est conservé (décision de tri du 2026-09-01, ne pas supprimer)
- Témoin historique du duel D49/D50 (les justifications du choix SwiftUI s'y comparent) ;
- Référence possible pour le re-arbitrage **ARCH-2** (moteur d'histoires + portage
  Android, D11) : si Android redevient d'actualité, ce code montre ce que Flutter
  donnait sur ce projet ;
- Supprimer ne libérerait aucun espace (l'historique git conserve tout).

Ne pas builder, ne pas maintenir. Le workflow CI `duel-flutter-testflight` associé est
lui aussi obsolète.
