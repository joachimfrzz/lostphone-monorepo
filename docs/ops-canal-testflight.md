# Canal TestFlight — mode d'emploi (jalon-duel D49)

> Décision 2026-08-09 (option A) : verdict préliminaire web sauté (PC = serveur RDP, mauvais juge).
> Décision 2026-08-10 : RÉUTILISATION du canal Codemagic existant de l'ancienne piste SwiftUI
> plutôt qu'un nouveau canal GitHub Actions — l'intégration App Store Connect, le Bundle ID
> `com.lostphone.game`, la fiche app et TestFlight existent déjà et ont fonctionné (builds 1-27).

## Architecture du canal (principal : Codemagic)

```
push sur main
    → Codemagic (mac_mini_m2, workflow duel-flutter-testflight)
    → flutter build ipa (build number = 100 + numéro Codemagic, jamais en collision avec les builds SwiftUI 1-27)
    → signature via l'intégration App Store Connect « Codemagic » (clé API déjà stockée)
    → TestFlight de l'app existante (com.lostphone.game)
    → iPhone de Joachim (app TestFlight)
```

- Workflow : `codemagic.yaml` → `duel-flutter-testflight`
- Bundle ID : `com.lostphone.game` (réutilisé — la fiche TestFlight est la même que l'ancienne app ;
  le build Flutter s'installe PAR-DESSUS l'ancienne app SwiftUI si elle est encore sur le téléphone)
- Fallback documenté : `.github/workflows/testflight.yml` (déclenchement manuel uniquement,
  nécessiterait 4 secrets : ASC_KEY_ID, ASC_ISSUER_ID, ASC_API_KEY_P8, APPLE_TEAM_ID)

## Ce qui est déjà en place (hérité, rien à recréer)

| Élément | Où | État |
|---|---|---|
| Clé API App Store Connect | Codemagic → Teams → Integrations → App Store Connect (« Codemagic ») | Configurée |
| Bundle ID `com.lostphone.game` | developer.apple.com → Identifiers | Enregistré |
| Fiche app + TestFlight | App Store Connect | Actifs (builds 1-27) |
| Certificats / profils | Gérés par Codemagic | En place |

## Mise en route (une seule fois)

1. Connecter GitHub à Hyperagent (l'agent crée le repo privé et pousse le monorepo).
2. Dans Codemagic : **Add application** → choisir le nouveau repo privé → framework : Flutter.
3. Vérifier que l'intégration App Store Connect s'appelle bien « Codemagic »
   (Teams → Personal Team → Integrations). Si elle a un autre nom : remplacer la valeur
   de `integrations.app_store_connect` dans `codemagic.yaml`.
4. Lancer un build (push sur main, ou bouton « Start new build »).

## Dépannage attendu

- Échec signature au premier run : vérifier l'intégration App Store Connect dans Codemagic
  et que les contrats sont acceptés dans App Store Connect (Agreements, Tax, and Banking).
- Upload OK mais build invisible : traitement Apple 5-30 min → TestFlight → Builds iOS.
- Collision de numéro de build : impossible par construction (+100), sinon relancer un build.
- Version marketing : l'app Flutter part en 1.0.0 comme l'ancienne — TestFlight distingue par numéro de build.
