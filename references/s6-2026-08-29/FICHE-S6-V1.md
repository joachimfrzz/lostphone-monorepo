# Fiche de référence — MÉTÉO / DICTAPHONE / HORLOGE+ / CALCULATRICE+ (S6, 2026-08-29)

Sources : vidéo 13 min 35 @60fps → 539 états distincts + 163 arbres XML.

## Couverture
- **Météo** (~40 états) : page ville complète (bande horaire, 10 jours, tuiles), feuille Conditions, liste des villes, carte — l'arbre XML de Météo est ÉNORME (cause des timeouts bénins du polling, consignés)
- **Dictaphone** : Tous les enregistrements, un mémo ouvert (« Oral anglais »), Favoris, **Suppressions récentes**, dossiers
- **Horloge (compléments)** : Minuteurs (roues + « 5 min et 4 s » en marche), Alarmes, Horloges, chrono
- **Calculatrice (compléments)** : **« Notes mathématiques »** (nouveauté iOS 26), feuilles de conversion/modes

## Or narratif (cartographie D79)
- **Suppressions récentes du Dictaphone** : 3e app avec corbeille récupérable (Photos, Messages, Dictaphone) — motif transversal de l'or effacé
- Titres des mémos vocaux (« Oral anglais ») : la vie par ses enregistrements
- Minuteur en marche : l'activité interrompue du propriétaire (que chronométrait-il ?)

## Implications refonte D80
1. MeteoApp : refonte contre les ~40 états réels (notre v1 était déjà mesurée sur vidéo — re-valider les tuiles iOS 26)
2. DictaphoneApp : ajouter Suppressions récentes + dossiers réels
3. HorlogeApp : re-valider Minuteurs (roues, récents) ; CalculatriceApp : ajouter l'écran Notes mathématiques (au moins la porte)
