> **Document du projet original de Kaoutar Amid, conservé comme référence.**
> L’architecture AEB/Stateflow/CAN décrite ci-dessous n’est pas implémentée ni validée par le modèle FCW de cette adaptation. Les fichiers `src/*.m` sont une logique MATLAB indépendante du modèle `fcw_model.slx`.

# Architecture Simulink / Stateflow — AEB

Ce document décrit l'architecture du modèle Model-Based Design du système de
freinage d'urgence automatique (AEB) et la machine d'états Stateflow associée.

## Vue d'ensemble du modèle Simulink

Le modèle est organisé en une chaîne de traitement linéaire, des capteurs
jusqu'au bus CAN :

```
+-----------+     +-------------+     +--------------------+     +---------------+     +---------+
|  Capteurs | --> | Calcul TTC  | --> | Machine d'états    | --> | Commande de   | --> |   CAN   |
| (radar/   |     | (subsystem  |     | AEB (Stateflow)    |     | freinage      |     | (encode |
|  caméra)  |     |  compute_ttc|     |                    |     |               |     |  trame) |
+-----------+     +-------------+     +--------------------+     +---------------+     +---------+
```

### 1. Capteurs

Source des signaux d'entrée. En simulation, ces signaux proviennent du
**Driving Scenario Designer** (Automated Driving Toolbox) qui génère un
scénario avec véhicule égo et cibles. Signaux produits :

- `distance` : distance relative à la cible la plus proche (m) ;
- `ego_speed` : vitesse longitudinale du véhicule égo (m/s) ;
- `obstacle_speed` : vitesse longitudinale de l'obstacle (m/s).

### 2. Calcul TTC

Sous-système (MATLAB Function block) appelant la logique de `compute_ttc.m`.
Il calcule :

```
TTC = distance / (ego_speed - obstacle_speed)
```

Si la vitesse relative est nulle ou négative, le TTC est saturé à `Inf`
(aucun risque de collision). Cela évite toute division par zéro.

### 3. Machine d'états AEB (Stateflow)

Chart Stateflow implémentant la stratégie de décision (voir `aeb_logic.m`).
Quatre états mutuellement exclusifs :

| État | Niveau de freinage | Signification |
|------|--------------------|---------------|
| `SAFE` | 0.0 | Pas de risque, aucune action. |
| `WARNING` | 0.0 | Alerte Forward Collision Warning au conducteur. |
| `PARTIAL_BRAKE` | 0.5 | Freinage partiel anticipé. |
| `FULL_BRAKE` | 1.0 | Freinage d'urgence maximal. |

#### Transitions de la machine d'états

Les transitions sont pilotées par la valeur de `TTC` (en secondes) :

```
            TTC >= 4.0
        +---------------------> [ SAFE ]
        |                          |  ^
        |              TTC < 4.0   |  | TTC >= 4.0
        |                          v  |
        |                     [ WARNING ]
        |              TTC < 2.5   |  ^  TTC >= 2.5
        |                          v  |
        |                  [ PARTIAL_BRAKE ]
        |              TTC < 1.5   |  ^  TTC >= 1.5
        |                          v  |
        +-------------------- [ FULL_BRAKE ]
```

Règles de transition (évaluées à chaque pas de simulation) :

- `SAFE` -> `WARNING` quand `2.5 <= TTC < 4.0`.
- `WARNING` -> `PARTIAL_BRAKE` quand `1.5 <= TTC < 2.5`.
- `PARTIAL_BRAKE` -> `FULL_BRAKE` quand `TTC < 1.5`.
- Transitions inverses (désescalade) quand le TTC augmente au-dessus du seuil
  correspondant, jusqu'au retour à `SAFE` lorsque `TTC >= 4.0`.

La machine peut passer directement à un état plus critique (par exemple
`SAFE` -> `FULL_BRAKE`) si le TTC chute brutalement (obstacle surgissant),
puisque l'état est déterminé par la valeur courante du TTC.

### 4. Commande de freinage

Convertit le niveau de freinage normalisé (`brake_level` dans `[0, 1]`) en
consigne physique : décélération cible (m/s²) ou pression de freinage,
envoyée à l'actionneur. Une rampe / saturation peut être appliquée pour le
confort et la sécurité.

### 5. CAN

Encodage de l'état du système dans des trames CAN pour le reste du véhicule
(diffusion vers le tableau de bord, l'ESP, etc.). Signaux typiques :

- `AEB_Status` : état courant (0=SAFE, 1=WARNING, 2=PARTIAL_BRAKE, 3=FULL_BRAKE) ;
- `Brake_Request` : niveau de freinage demandé ;
- `TTC_Value` : Time-To-Collision courant (diagnostic).

Le mapping signal -> trame est défini dans une base de données CAN (`.dbc`)
et réalisé via les blocs **CAN Pack / CAN Transmit** (Vehicle Network Toolbox).
