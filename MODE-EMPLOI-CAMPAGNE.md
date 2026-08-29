# Mode d emploi de campagne (D79) — rituel definitif

## Prerequis (une fois par jour)
1. iPhone branche USB + deverrouille + app WebDriverAgent ouverte une fois
2. Double-clic Demarrer-LostPhone.cmd -> coller l URL tunnel dans le fil principal
3. Mode Concentration ON (bloque les bannieres)
4. (Optionnel) Fil Carnet ouvert (tools/prompt-carnet.txt)

## Debut de session
1. Checklist de session publiee/validee au prealable
2. Centre de controle -> Enregistrement de l ecran
3. Message « GO Sx » dans le fil principal -> l agent lance l ecoute passive (tools/ecoute_passive.py)
4. Derouler la checklist app par app

## Pendant
- ~1 s sur chaque page JAMAIS VUE ; vitesse naturelle pour tout le reste (gestes, toggles, scrolls, messages)
- Remarques/idees/incidents -> fil Carnet (l analyse de l agent est APRES coup : il n a jamais de question en live)

## Cas particuliers
- Changer d app : retour accueil, ouvrir la suivante
- Sauter une app : la sauter + le noter au Carnet (reste a_faire au registre)
- Pause : poser le telephone (ecran immobile = rien generé) ; pause longue : reprendre — les trous remontent en passe 2 via la video
- Tunnel/PC mort : LA VIDEO EST INDEPENDANTE DU PC et continue -> aucune session ne peut etre perdue ; XML manquant rattrape en passe 2
- STOP absolu : debrancher le cable USB

## Fin de session
1. Stop enregistrement
2. Message « FIN Sx » (+ digest Carnet eventuel)
3. Video brute -> SwissTransfer -> lien dans le fil

## Cloture (agent, sans Joachim)
Fusion video+XML -> fiche(s) par app (+ section Possibilites narratives) -> verification d exhaustivite -> liste passe 2 + questions -> push repo (references/ + fiches + cartographie-narrative.md) -> registre campagne-analyse.yaml mis a jour -> diff P5 -> correctifs -> run miroir.

## Passe 2 (si manquants)
Mini-checklist publiee -> meme rituel en 3-5 min.
