# ADAS — Forward Collision Warning (FCW)

Modélisation et vérification en simulation d’une fonction d’alerte de collision frontale, avec MATLAB/Simulink.

## Fonctionnement

Le modèle `fcw_model.slx` reçoit la distance (m), la vitesse du véhicule égo (m/s) et celle du véhicule devant lui (m/s).

- Vitesse relative : `ego_speed - obstacle_speed`.
- Si la vitesse relative est supérieure à `1e-6 m/s` : `TTC = distance / vitesse_relative`.
- Sinon : `TTC = Inf`.
- Alerte : `TTC < 4 s`. À exactement 4 s, aucune alerte.

Les entrées sont produites par un bloc Ramp et deux constantes. Un bloc MATLAB Function calcule le TTC et l’alerte ; les sorties sont visualisées par des Display et un Scope. L’alerte est enregistrée dans `alerte_log`.

## Exécuter

Le modèle fourni a été sauvegardé avec **MATLAB/Simulink R2026b Update 2**. La compatibilité avec des versions antérieures n’a pas été vérifiée. MATLAB et Simulink sont nécessaires ; aucun matériel externe n’est utilisé pour ces tests.

Télécharger le dépôt et ouvrir son dossier dans MATLAB, puis exécuter :

```matlab
open_system('fcw_model')
test_fcw_scenarios
```

Le script règle les entrées pour chaque simulation avec `Simulink.SimulationInput` : aucune modification manuelle des blocs n’est nécessaire. Le modèle sauvegardé contient le cas d’éloignement (20 et 30 m/s, pente +10 m/s, distance initiale 50 m).

## Résultats observés — 18 novembre 2026

Les cinq scénarios ont réussi dans MATLAB Online, selon la sortie de console fournie par Hanane Aouragh. Le modèle et le script ont été examinés avant publication ; aucune nouvelle exécution MATLAB n’a été effectuée dans l’environnement de publication.

| Scénario | Distance initiale | Égo | Obstacle | Pente de distance | Résultat observé |
|---|---:|---:|---:|---:|---|
| Rapprochement | 50 m | 20 m/s | 10 m/s | -10 m/s | Première alerte à 1,010 s |
| Même vitesse | 50 m | 20 m/s | 20 m/s | 0 m/s | Aucune alerte |
| Éloignement | 50 m | 20 m/s | 30 m/s | +10 m/s | Aucune alerte |
| Seuil TTC = 4 s | 40 m | 20 m/s | 10 m/s | 0 m/s | Aucune alerte |
| Alerte initiale, TTC = 3 s | 30 m | 20 m/s | 10 m/s | 0 m/s | Alerte dès t = 0 s |

Les deux derniers scénarios imposent une distance constante pour isoler la logique de seuil. Ils ne représentent pas des trajectoires physiques complètes.

La sortie de console du dernier test réussi est conservée dans [results/test_output.txt](results/test_output.txt).

## Portée de la validation

Les assertions vérifient la sortie d’alerte sur ces cinq scénarios. Elles ne constituent pas une preuve de couverture exhaustive. Les entrées invalides (distance négative, NaN, etc.) ne sont pas traitées ni testées dans cette version.

Cette version ne valide pas de détection radar/caméra, de machine d’états Stateflow explicite, de freinage automatique, de communication CAN, de génération de code, de déploiement STM32 ou de tests sur matériel.

## Fichiers

| Fichier | Contenu |
|---|---|
| `fcw_model.slx` | Modèle Simulink fourni par Hanane |
| `test_fcw_scenarios.m` | Script des cinq scénarios exécutés |
| `results/test_output.txt` | Résultats de console communiqués |
| `LICENSE` | Licence MIT et attribution d’origine |

