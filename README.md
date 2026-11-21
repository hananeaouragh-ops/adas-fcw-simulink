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

## Origine et fichiers AEB de référence

Cette adaptation par **Hanane Aouragh** s’appuie sur le projet original de **Kaoutar Amid** : [adas-aeb-simulink](https://github.com/KaoutarAmid/adas-aeb-simulink), distribué sous [licence MIT](LICENSE).

Les dossiers suivants proviennent de l’archive du projet original (commit `1d1b641ed40db25ba6479dc6a285bfb9d37928c7`) :

- `src/aeb_logic.m` : décision MATLAB à quatre niveaux, avec seuils TTC de 1,5 s, 2,5 s et 4 s.
- `src/compute_ttc.m` : calcul du TTC.
- `src/run_demo.m` : démonstration MATLAB.
- `tests/AEBLogicTest.m` : tests unitaires de la logique MATLAB d’origine.
- `docs/architecture.md` : architecture AEB de référence, avec une note précisant sa portée.

Les sources MATLAB et tests d’origine sont conservés sans modification. Ils ne sont pas raccordés au modèle FCW et leurs tests n’ont pas été exécutés dans le cadre de cette publication. Les cinq résultats présentés plus haut concernent uniquement `test_fcw_scenarios.m`.

Pour exécuter séparément la démonstration et les tests AEB d’origine, depuis la racine du dépôt dans MATLAB :

```matlab
addpath('src');
run_demo
results = runtests('tests/AEBLogicTest.m');
disp(table(results));
```

Les contributions de cette adaptation sont le modèle `fcw_model.slx`, les cinq scénarios FCW, leurs résultats de console et la documentation correspondante. Le copyright d’origine de Kaoutar Amid est conservé dans `LICENSE`.
