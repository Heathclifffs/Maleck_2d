# Riale — Jeu Isométrique 2D Pixel Art

Jeu d'action-aventure isométrique pixel art dans l'esprit de Zelda: BotW avec difficulté Dark Souls.

## Stack

- **Moteur** : Godot 4.x (GDScript)
- **Art** : Pixel art isométrique, spritesheets 768×448 cells, NEAREST filtering
- **Preprocessing** : Python (Pillow, numpy) — bbox extraction, unified crop, mirroring, scaling

## Animations

| État | Directions | Frames | FPS | Taille (cardinaux) | Taille (diagonaux) |
|------|-----------|--------|-----|-------------------|-------------------|
| Idle | 8 | 21 | 20 | 239px | 239px |
| Walk | 8 | 28 | 24 | 239px | 215px |
| Run | 8 | 29 | 35 | 205px | 185-200px |
| Combat idle | 8 | 29 | 20 | 205px | 185-200px |

## Contrôles

- ZQSD / WASD / Flèches — déplacement
- Shift — sprint (consomme stamina)
- Tab — toggle mode combat

## Structure

```
game/
├── scripts/          # GDScript + preprocessing Python
│   ├── riale.gd      # CharacterBody2D (états, animations, combat)
│   ├── stamina.gd    # Gestion stamina
│   ├── health.gd     # Système de santé (cœurs)
│   ├── preprocess_*.py  # Génération spritesheets
│   └── main.gd       # Scène de test
├── scenes/           # Scènes Godot
├── art/riale/        # Spritesheets générées
│   ├── idle/         # 8 directions, 768×... 
│   ├── walk/         # 8 directions, 3072×3584
│   ├── run/          # 8 directions, 3072×3584
│   └── combat_idle/  # 8 directions, 3072×3584
└── riale-game-skills.md  # Vision + roadmap détaillée
```

## Prérequis

```sh
pip install Pillow numpy
```

## Générer les spritesheets

```sh
python3 scripts/preprocess_combat_idle.py
python3 scripts/preprocess_walk.py
python3 scripts/preprocess_run.py
python3 scripts/preprocess_idle.py
```

Si Godot montre des spriteshes corrompues après regénération :
```sh
rm -rf .godot/imported/
```
