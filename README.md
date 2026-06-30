# Riale — Jeu Isométrique 2D Pixel Art

Jeu d'action-aventure isométrique pixel art dans l'esprit de Zelda: BotW avec difficulté Dark Souls.

## Stack

- **Moteur** : Godot 4.6 (GDScript, shaders GLSL canvas_item)
- **Art** : Pixel art isométrique, spritesheets 768×448 cells, NEAREST filtering
- **Preprocessing** : Python (Pillow, numpy) — bbox extraction, unified crop, mirroring, scaling
- **Rendu 2.5D** : Shader pseudo-normal maps from alpha + outline detect, éclairage 2D directionnel (sun + fill), WorldEnvironment (ACES tonemap + glow bloom + vignette + chromatic aberration)
- **Cycle jour/nuit** : 120s, interpolation soleil/lumière, particules nocturnes

## Animations Riale (15 états, 8 directions chacun)

| État | Boucle | FPS | TARGET_H down/up | TARGET_H left/right | TARGET_H diagonaux |
|------|--------|-----|-----------------|--------------------|-------------------|
| Idle | Oui | 24 | 239 | 239 | 215 |
| Walk | Oui | 30 | 239 | 215 | 215 |
| Run | Oui | 70 | 205 | 205 | 185-200 |
| Combat idle | Oui | 24 | 205 | 205 | 185-200 |
| Running jump | Non | 70 | — | — | — |
| Slide | Non | 70 | — | — | — |
| Attack1 | Non | 55 | 239 | 239 | 215 |
| Attack2 | Non | 55 | 239 | 239 | 215 |
| Pickup | Non | 24 | 239 | 239 | 215 |
| Push | Non | 24 | 239 | 239 | 215 |
| Climb hang | Oui | 24 | 239 | 215 | 215 |
| Climb up | Non | 24 | 239 | 215 | 215 |
| Death | Non | 24 | 239 | 239 | 215 |
| Swim | Oui | 24 | 130 | 130 | 120 |
| Taken damage | Non | 24 | 215 | 215 | 200 |

## Animations Ouda (3 états, 8 directions chacun)

| État | Boucle | FPS |
|------|--------|-----|
| Idle | Oui | 20 |
| Walk | Oui | 24 |
| Run | Oui | 48 |

## Contrôles

| Action | Touche | Description |
|--------|--------|-------------|
| Déplacement | ZQSD / WASD / Flèches | 8 directions isométriques |
| Sprint | Shift | Course, consomme stamina |
| Attaque | Clic gauche | Combo 2 coups |
| Interagir | E | Ramasser / Pousser / Grimper |
| Saut | Espace | Saut en courant |
| Glissade | Ctrl | Glissade en courant |
| Mode combat | Tab | Active/désactive posture combat |
| Débug DMG | Entrée | -1 HP |
| Débug HEAL | F6 | +2 HP |
| Débug KILL | Échap | -10 HP |
| Avance rapide | T | Accélère cycle jour/nuit ×30 |

## Scènes

- **main_menu.tscn** — Menu titre avec New Game / Quit
- **character_select.tscn** — Sélection Riale ou Ouda
- **main.tscn** — Monde de jeu (25×25 tuiles, props, interactions, éclairage)
- **riale.tscn** / **ouda.tscn** — Personnages jouables

## Structure

```
game/
├── project.godot
├── scripts/
│   ├── riale.gd              # Moteur d'état Riale (15 états)
│   ├── ouda.gd               # Moteur d'état Ouda (3 états)
│   ├── main.gd               # Génération carte + spawning
│   ├── health.gd             # Santé (HP, signaux died/damage_taken)
│   ├── stamina.gd            # Stamina (drain/regen)
│   ├── game_state.gd         # Autoload (sélection personnage)
│   ├── day_night.gd          # Cycle jour/nuit 120s
│   ├── clock_ui.gd           # Horloge + barre jour/nuit
│   ├── minimap.gd            # Mini-carte
│   ├── ambient_particles.gd  # Particules (fireflies)
│   ├── climbable_ledge.gd    # Corniche escaladable
│   ├── pickup_item.gd        # Objet ramassable
│   ├── pushable_block.gd     # Bloc poussable
│   ├── water_tile.gd         # Tuile d'eau animée
│   ├── water_zone.gd         # Zone d'eau (détection)
│   ├── heart_display.gd      # Affichage cœurs
│   ├── stamina_bar.gd        # Barre de stamina
│   ├── main_menu.gd          # Menu principal
│   ├── character_select.gd   # Sélection personnage
│   ├── preprocess_*.py       # 13 scripts Python preprocessing
│   └── preprocess_ouda_run.py
├── scenes/                   # 10 scènes Godot
├── shaders/
│   ├── riale_pbr.gdshader    # Pseudo-normales + outline + rim light
│   ├── tile_pbr.gdshader     # PBR sol isométrique
│   └── prop_pbr.gdshader     # PBR props + rim light
├── art/
│   ├── riale/                # 15 dossiers × 8 PNG = 120 spritesheets
│   ├── ouda/                 # 3 dossiers × 8 PNG = 24 spritesheets
│   ├── isometric_floor/      # 10 grass + 4 dirt + 4 stone + 1 stair
│   ├── props/                # 248 sprites (plants/exotic/bamboo/trees)
│   ├── ui/                   # 76 PNG (borders/panels/dividers) + police
│   └── water_spritesheet.png # Animation eau 16 frames
├── DOCUMENTATION.md          # Documentation complète du projet
└── riale-game-skills.md      # Vision + roadmap détaillée
```

## Prérequis

```sh
pip install Pillow numpy
```

## Générer les spritesheets

```sh
# Riale
python3 scripts/preprocess_walk.py
python3 scripts/preprocess_run.py
python3 scripts/preprocess_combat_idle.py
python3 scripts/preprocess_attack1.py
python3 scripts/preprocess_attack2.py
python3 scripts/preprocess_pickup.py
python3 scripts/preprocess_push.py
python3 scripts/preprocess_climb.py
python3 scripts/preprocess_death.py
python3 scripts/preprocess_swim.py
python3 scripts/preprocess_taken_damage.py

# Ouda
python3 scripts/preprocess_ouda.py
python3 scripts/preprocess_ouda_run.py
```

Si Godot montre des spritesheets corrompues après regénération :
```sh
rm -rf .godot/imported/
```
