# Documentation du Projet — Riale Isometric

## Architecture

```
game/
├── project.godot              # Configuration Godot 4.6
├── scripts/                   # GDScript jeux + preprocessing Python
├── scenes/                    # Scènes Godot (.tscn)
├── shaders/                   # Shaders canvas_item PBR
├── art/
│   ├── riale/                 # 15 × 8 = 120 spritesheets Riale
│   ├── ouda/                  # 3 × 8 = 24 spritesheets Ouda
│   ├── isometric_floor/       # 19 textures de sol
│   ├── props/                 # 248 sprites de décors
│   ├── ui/                    # Boutons, panneaux, séparateurs, police
│   └── water_spritesheet.png  # Animation d'eau 16 frames
├── .godot/imported/           # Cache d'import Godot
└── README.md                  # Vue d'ensemble du projet
```

---

## Moteur d'état (riale.gd)

### États (enum State, 15 valeurs)

| ID | Nom | Boucle | Description |
|----|-----|--------|-------------|
| 0 | `IDLE` | Oui | Repos, animation idle |
| 1 | `WALK` | Oui | Marche 35px/s |
| 2 | `RUN` | Oui | Course 140px/s (sprint) |
| 3 | `COMBAT_IDLE` | Oui | Posture de combat |
| 4 | `RUNNING_JUMP` | Non | Saut en courant (0.35s) |
| 5 | `SLIDE` | Non | Glissade |
| 6 | `ATTACK1` | Non | Attaque combo slot 0 |
| 7 | `ATTACK2` | Non | Attaque combo slot 1 |
| 8 | `PICKUP` | Non | Ramasser un objet |
| 9 | `PUSH` | Non | Pousser un bloc |
| 10 | `CLIMB_HANG` | Oui | Suspendu à une corniche |
| 11 | `CLIMB_UP` | Non | Monter sur la corniche |
| 12 | `DEATH` | Non | Mort (retour IDLE) |
| 13 | `SWIM` | Oui | Nage (20px/s) |
| 14 | `TAKEN_DAMAGE` | Non | Toucher (retour IDLE/COMBAT_IDLE) |

### Transitions automatiques

- **État → IDLE** : quand animation non-bouclante termine (`_on_animation_finished`)
- **WALK/RUN → SWIM** : quand `_in_water == true`
- **SWIM → IDLE/COMBAT_IDLE** : quand `_in_water == false`
- **IDLE → COMBAT_IDLE** : après 3s sans action en mode combat
- **ATTACK1 ↔ ATTACK2** : combo enchaîné via buffer d'entrée

### Ordre de priorité dans _physics_process

1. ATTACK1 / ATTACK2 / PICKUP / DEATH / TAKEN_DAMAGE → `move_and_slide()` uniquement
2. CLIMB_UP → `move_and_slide()` uniquement
3. CLIMB_HANG → `_handle_climb_hang()`
4. PUSH → `_handle_push()`
5. SLIDE → `move_and_slide()` uniquement
6. Water check (auto-transition SWIM)
7. SWIM → mouvement 20px/s 8 directions
8. RUNNING_JUMP → arc de saut
9. WALK / RUN / COMBAT_IDLE → mouvement normal + sprint + saut + glissade

---

## Animations (système de spritesheets)

### Prétraitement Python

Chaque animation suit le même pipeline :

```
Source (768×448 par cellule, 4×8 grille, 29 frames)
  → extract_frames_unified() — crop unifié par bounding box alpha
  → process_frame() — redimension à TARGET_H, centré sur canvas 768×448, pieds à y=344
  → build_spritesheet() — packing 4 colonnes × 8 lignes
  → mirror_img() — flip horizontal cellule par cellule pour les directions mirroir
```

### TARGET_H par animation

| Animation | down | up | left/right | down_left/down_right | up_left/up_right |
|-----------|------|----|------------|----------------------|-----------------|
| idle | 239 | 239 | 239 | 215 | 215 |
| walk | 239 | 239 | 215 | 215 | 215 |
| run | 205 | 235 | 205 | 185 | 200 |
| combat_idle | 205 | 235 | 205 | 185 | 200 |
| attack1 | 239 | 239 | 239 | 215 | 215 |
| attack2 | 239 | 239 | 239 | 215 | 215 |
| pickup | 239 | 239 | 239 | 215 | 215 |
| push | 239 | 239 | 239 | 215 | 215 |
| climb_hang | 239 | 239 | 215 | 215 | 215 |
| climb_up | 239 | 239 | 215 | 215 | 215 |
| death | 239 | 239 | 239 | 215 | 215 |
| swim | 130 | 130 | 130 | 120 | 120 |
| taken_damage | 215 | 215 | 215 | 200 | 200 |

### Sources → Directions (5 sources + 3 mirroirs)

Chaque animation préprocess utilise 5 fichiers source et génère 8 directions par mirroir :

```
Source originale → direction     Mirroir → direction opposée
down            → down          —                     —
down_right      → down_right    FLIP → down_left
right           → right         FLIP → left
up_right        → up_right      FLIP → up_left
up              → up            —                     —
```

Exception : `push` utilise seulement 3 sources (down, right, up) avec fallback down_right←down, up_right←up.

### Frames par animation

- **29 frames** : run, combat_idle, attack1, attack2, pickup, push, climb, death, swim, taken_damage
- **28 frames** : walk (cardinaux), idle
- **26 frames** : walk (diagonaux)
- **4 frames** : climb_hang (premières 4 frames de climb_up)

### FPS par animation

| Animation | FPS |
|-----------|-----|
| idle | 24 |
| walk | 30 |
| run | 70 |
| combat_idle | 24 |
| running_jump | 70 |
| slide | 70 |
| attack1 | 55 |
| attack2 | 55 |
| pickup | 24 |
| push | 24 |
| climb_hang | 24 |
| climb_up | 24 |
| death | 24 |
| swim | 24 |
| taken_damage | 24 |

### Stockage Godot

Les spritesheets sont chargées dynamiquement dans `_build_all_animations()` via `_build_anim_set()` :
- Chaque texture PNG est chargée depuis `res://art/riale/{state}/`
- La grille est découpée en `rows × cols` cellules
- Les cellules vides (pas de pixels alpha > 0) sont ignorées
- Les animations bouclantes (`loop=true`) : idle, walk, run, combat_idle, climb_hang, swim
- Les animations one-shot (`loop=false`) : running_jump, slide, attack1, attack2, pickup, push, climb_up, death, taken_damage

---

## Contrôles

| Action | Touche | Fonction |
|--------|--------|----------|
| Move | ZQSD / WASD / Flèches | Déplacement 8 directions isométriques |
| Sprint | Shift | Course (consomme stamina) |
| Attaque | Clic gauche | Combo ATTACK1 → ATTACK2 → ATTACK1... |
| Interagir | E | Ramasser / Pousser / Grimper (priorité : pickup > pushable > climbable) |
| Saut | Espace | Saut en courant (état RUNNING_JUMP) |
| Glissade | Ctrl | Glissade en courant (état SLIDE) |
| Mode combat | Tab | Active/désactive combat mode |
| Débug DMG | Entrée | -1 HP |
| Débug HEAL | F6 | +2 HP |
| Débug KILL | Échap | -10 HP |

---

## Détection d'interaction (rayon 80px)

Ordre de priorité dans `_unhandled_input()` touche E :

1. **Pickup** (`group "pickup"`) → objet détruit, état PICKUP
2. **Pushable** (`group "pushable"`) → `try_move()`, état PUSH
3. **Climbable** (`group "climbable"`) → `climb_offset`, état CLIMB_HANG

Chaque objet affiche un label "[E] {action}" quand le joueur est à portée.

---

## Corniches (ClimbableLedge)

```
ClimbableLedge (Area2D)
├── CollisionShape2D (Rectangle 64×16)
├── Sprite2D (visuel bleu procédural)
└── ClimbLabel (Label "[E] Climb")
```

- `climb_offset: Vector2` — décalage appliqué après l'animation CLIMB_UP
- `climb_width: float` — limite horizontale de mouvement en mode CLIMB_HANG
- 6 corniches placées aléatoirement sur la carte (distance > 4 du centre)

### Mécanique d'escalade

1. Joueur à portée + E → CLIMB_HANG (boucle, 4 frames)
2. En CLIMB_HANG : déplacement horizontal limité à `climb_width`, E ou ↑ pour monter
3. CLIMB_UP (one-shot, 29 frames) → téléportation via `climb_offset` → retour à l'état précédent

---

## Eau (water_zone + swim)

```
WaterZone (Node2D)
└── Area2D (monitoring=true, monitorable=false)
    └── CollisionShape2D (RectangleShape2D)
```

- 24 zones d'eau disposées en lac (donut autour du centre, `[0,0]` vide)
- `_water_count` gère les chevauchements de zones
- Détection par `body_entered`/`body_exited` → `_on_water_entered`/`_on_water_exited`
- Sprites d'eau animés (water_spritesheet.png, 16 frames, 130×130)

### Mécanique de nage

1. Entrée dans l'eau → SWIM state (20px/s)
2. Mouvement 8 directions avec animation swim_
3. Sortie de l'eau → retour IDLE ou COMBAT_IDLE
4. Transité seulement depuis IDLE/WALK/RUN/COMBAT_IDLE

---

## Santé et Stamina

### Health (health.gd)

```
signals:
  health_changed(current_hp, max_hp)
  died
  damage_taken(amount)
```

- `max_hp` = 10 (export)
- `take_damage(amount)` → réduit HP, émet `damage_taken` + si ≤0 → `died`
- `heal(amount)` → soigne, émet `health_changed`
- `TAKEN_DAMAGE` : animation one-shot, retour IDLE/COMBAT_IDLE
- `DEATH` : animation one-shot, retour IDLE (respawn simple)

### Stamina (stamina.gd)

```
signals:
  stamina_changed(current, max_value)
```

- `max_stamina` = 100, `drain_rate` = 20/s, `regen_rate` = 12/s
- Consommée par : sprint, saut, glissade
- `has_stamina()` → true si ≥ 1
- `consume(amount)` → réduction immédiate

---

## Génération de la carte (main.gd)

### Grille isométrique 25×25

- `step_x` = 65, `step_y` = 50
- Position d'un tile `(gx, gy)` : `((gx - gy) * step_x, (gx + gy) * step_y)`
- 3 types de sol : grass (90%+), dirt (~3%), stone (~0.5%)
- Chaque tile est un Sprite2D avec shader `tile_pbr.gdshader`
- Tile `z_index` = `(gx + gy) * 2 + 50`
- Player `z_index` = `floor(y / 50) * 2 + 1 + 50` (dynamique)

### Props (80 objets aléatoires)

- 4 catégories : plants, exotic, bamboo, trees
- Chaque prop : StaticBody2D + Sprite2D + CollisionShape2D
- Shader `prop_pbr.gdshader`
- Exclus zone centrale (distance < 4 de (3,1))

### Objets interactifs

- **40 pickups** (distance > 3 du centre)
- **12 pushable blocks** (distance > 3 du centre)
- **6 climbable ledges** (distance > 4 du centre)
- **24 water zones** (lac central en donut)

---

## Éclairage et jour/nuit

### Lumières

- **SunLight** : DirectionalLight2D, energy=0.7, rotation=135°, ombres PCF soft
- **FillLight** : DirectionalLight2D, energy=0.25, rotation=315°
- **PointLight2D** : sur chaque personnage (Riale : orange, Ouda : bleu)

### Cycle jour/nuit (day_night.gd)

- Durée : 120s par cycle complet
- T → avance rapide ×30
- Interpolation : rotation/énergie/couleur du soleil, énergie/couleur du fill light
- CanvasModulate : blanc → bleu foncé la nuit
- Particules d'ambiance (fireflies) : actives la nuit

### Shaders

| Shader | Effets |
|--------|--------|
| `riale_pbr.gdshader` | Pseudo-normales (gradient alpha), outline (8 voisins), rim light |
| `tile_pbr.gdshader` | Normales de bord/bump, effet dôme, AO d'arête |
| `prop_pbr.gdshader` | Normales de bord/bump, rim light |

---

## Menu principal et sélection

### MainMenu (main_menu.tscn)

- Titre "MALECK"
- Boutons : Continue (désactivé), NewGame, Quit
- Prompt animé (alpha oscillant)
- StyleBoxTexture 9-slice depuis `panel-border-000.png`

### CharacterSelect (character_select.tscn)

- Cartes Riale et Ouda avec sprite + nom + description
- Surbrillance dorée au survol
- `GameState.selected_character` (autoload) stocke le choix
- Chargement de la première frame de l'animation idle via AtlasTexture

---

## Préprocessing (scripts Python)

```bash
# Régénérer toutes les animations d'un personnage
cd /chemin/vers/game
python3 scripts/preprocess_walk.py
python3 scripts/preprocess_run.py
python3 scripts/preprocess_swim.py
# ... etc

# Effacer le cache Godot après modification
rm -f .godot/imported/*<anim>*
```

### Scripts Python

| Script | Source | Destination | Directions |
|--------|--------|-------------|------------|
| `preprocess_walk.py` | Riale/anim/Walk | art/riale/walk | 8 |
| `preprocess_run.py` | Riale/anim/run | art/riale/run | 8 |
| `preprocess_combat_idle.py` | Riale/anim/combat/combat_idle | art/riale/combat_idle | 8 |
| `preprocess_attack1.py` | Riale/anim/combat/attack1 | art/riale/attack1 | 8 |
| `preprocess_attack2.py` | Riale/anim/combat/attack2 | art/riale/attack2 | 8 |
| `preprocess_death.py` | Riale/anim/death | art/riale/death | 8 |
| `preprocess_pickup.py` | Riale/anim/pick up | art/riale/pickup | 8 |
| `preprocess_push.py` | Riale/anim/push | art/riale/push | 8 |
| `preprocess_climb.py` | Riale/anim/climb up | art/riale/climb_{hang,up} | 8+8 |
| `preprocess_swim.py` | Riale/anim/swim | art/riale/swim | 8 |
| `preprocess_taken_damage.py` | Riale/anim/taken_damage | art/riale/taken_damage | 8 |
| `preprocess_ouda.py` | Ouda/anim | art/ouda/{idle,walk} | 8+8 |
| `preprocess_ouda_run.py` | Ouda/anim/run | art/ouda/run | 8 |

---

## Riales sources (sprites bruts)

```
Riale/anim/
├── Walk/            ← idle + walk partagent ces sources
│   ├── riale_Down_walk_nobg.png      (3072×3136, 7 rows)
│   ├── riale_Down-left_walk_nobg.png (3072×3584, 8 rows)
│   ├── riale_Down-right_walk_nobg.png
│   ├── riale_Up_walk_nobg.png
│   ├── riale_Up-left_walk_nobg.png
│   ├── riale_Up-right_walk_nobg.png
│   ├── riale_left_walk_nobg.png
│   └── riale_right_walk_nobg.png
│   └── *.json (bbox data)
├── run/
│   ├── riale_down_running_nobg.png
│   ├── riale_down-right_running.png
│   ├── riale_right_running.png
│   ├── riale_up_running.png
│   └── riale_up-right_running.png
│   ├── run_to_slide/    (5 directions)
│   └── running_jump/    (5 directions)
├── Idle/              (8 sources)
├── combat/
│   ├── combat_idle/    (3 sources)
│   ├── attack1/        (5 sources, left traité comme right)
│   ├── attack2/        (5 sources)
│   └── attack3/        (up seulement, non utilisé)
├── death/             (5 sources)
├── pick up/           (5 sources)
├── push/              (3 sources)
├── climb up/          (5 sources)
├── swim/              (5 sources)
└── taken_damage/      (5 sources)
```

Taille standard d'une cellule source : **768×448**, grille **4 colonnes × 8 lignes**.

---

## Notes techniques

- **Texture filter** : NEAREST partout (pixel art)
- **Scale Godot** : 0.5 pour tous les personnages
- **Sprite position.y** : -59 pour idle/walk/pickup/push/climb/death/swim/taken_damage, -51 pour run, -55 pour combat_idle
- **Feet Y** dans preprocessing : 344 (sur canvas 768×448)
- **Cache Godot** : les `.ctex` et `.md5` dans `.godot/imported/` doivent être supprimés quand les spritesheets sont régénérées
- **Typage GDScript** : utiliser `var x: Type =` au lieu de `var x := expr as Type` pour les types valeur (float, Vector2)
- **`"prop" in obj`** : vérifier l'existence d'une propriété avant `obj.get("prop")` (Godot 4 `get()` prend 1 seul argument)
