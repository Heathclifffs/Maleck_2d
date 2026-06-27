# Riale — Jeu Isométrique 2D Pixel Art

Jeu d'action-aventure isométrique pixel art dans l'esprit de Zelda: BotW avec difficulté Dark Souls.

## Stack

- **Moteur** : Godot 4.x (GDScript)
- **Art** : Pixel art isométrique, spritesheets 768×448 cells, NEAREST filtering
- **Preprocessing** : Python (Pillow, numpy) — bbox extraction, unified crop, mirroring, scaling

## Animations

| État | Personnage | Directions | Frames | FPS | Taille (cardinaux) | Taille (diagonaux) |
|------|-----------|-----------|--------|-----|-------------------|-------------------|
| Idle | Riale | 8 | 21 | 20 | 239px | 239px |
| Walk | Riale | 8 | 28 | 24 | 239px | 215px |
| Run | Riale | 8 | 29 | 35 | 205px | 185-200px |
| Combat idle | Riale | 8 | 29 | 20 | 205px | 185-200px |
| Idle | Ouda | 8 | 29 | 20 | 239px | 239px |
| Walk | Ouda | 8 | 29 | 24 | 239px | 215px |

## Contrôles

- ZQSD / WASD / Flèches — déplacement
- Shift — sprint (consomme stamina)
- Tab — toggle mode combat

## Structure

```
game/
├── scripts/                # GDScript + preprocessing Python
│   ├── riale.gd            # Riale (états, animations, combat)
│   ├── ouda.gd             # Ouda (états, animations)
│   ├── stamina.gd          # Gestion stamina
│   ├── health.gd           # Système de santé (cœurs)
│   ├── preprocess_*.py     # Génération spritesheets
│   └── main.gd             # Scène de test
├── scenes/                 # Scènes Godot
│   ├── riale.tscn          # Personnage Riale
│   ├── ouda.tscn           # Personnage Ouda
│   └── main.tscn           # Scène de test (Riale + Ouda)
├── art/
│   ├── riale/              # Spritesheets Riale
│   │   ├── idle/           # 8 directions
│   │   ├── walk/           # 8 directions, 3072×3584
│   │   ├── run/            # 8 directions, 3072×3584
│   │   └── combat_idle/    # 8 directions, 3072×3584
│   └── ouda/               # Spritesheets Ouda
│       ├── idle/           # 8 directions, 3072×3584
│       └── walk/           # 8 directions, 3072×3584
└── riale-game-skills.md    # Vision + roadmap détaillée
```

## Prérequis

```sh
pip install Pillow numpy
```

## Générer les spritesheets

```sh
python3 scripts/preprocess_combat_idle.py   # Riale combat idle
python3 scripts/preprocess_walk.py          # Riale walk
python3 scripts/preprocess_run.py           # Riale run
python3 scripts/preprocess_idle.py          # Riale idle
python3 scripts/preprocess_ouda.py          # Ouda idle + walk
```

Si Godot montre des spriteshes corrompues après regénération :
```sh
rm -rf .godot/imported/
```
