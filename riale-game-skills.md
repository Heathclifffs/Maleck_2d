# Projet Riale — Jeu Isométrique 2D Pixel Art

## Vision
> Un jeu 2D isométrique pixel art dans l'esprit et le monde de **Zelda: Breath of the Wild**, mais avec une difficulté **Dark Souls** — tout peut devenir source de mort à tout moment. Survie, exploration, combat exigeant.

## Univers
- Hyrule-like : champs, forêts, montagnes, déserts, lacs, donjons
- Météo dynamique, cycle jour/nuit, température
- Exploration libre, monde gigantesque (BotW-scale)
- Vie sauvage, monstres, boss, secrets

## Gameplay Pillars
1. **Survie** — faim, température, stamina, santé limitée
2. **Combat exigeant** — esquives, parades, endurance, punitif
3. **Exploration** — monde ouvert sans marqueurs, découverte naturelle
4. **Craft/Inventaire** — à la BotW : armes qui cassent, cuisine, élixirs
5. **Atmosphère** — solitude, danger constant, moments de calme

## Roadmap

### Phase 1 — Fondations (fait)
- [x] Projet Godot, CharacterBody2D, AnimatedSprite2D
- [x] Idle 8 directions Riale (spritesheets + animation, 21 frames, 20 FPS)
- [x] Walk 8 directions Riale (spritesheets + animation, 28 frames, 24 FPS, 35 px/s)
- [x] Run 8 directions Riale (spritesheets + animation, 29 frames, 35 FPS, 70 px/s)
- [x] Combat idle Riale (8 directions, 29 frames, 20 FPS, tailles run)
- [x] Sprint avec Shift + stamina (drain=20/s, regen=12/s, regen_delay=0)
- [x] Contrôles ZQSD/WASD/Flèches + Shift, machine à états Idle↔Walk↔Run
- [x] Camera2D attachée au personnage avec smoothing
- [x] Sprite scale = 0.75, texture_filter = NEAREST
- [x] Ouda idle 8 directions (29 frames, 20 FPS, 239px)
- [x] Ouda walk 8 directions (29 frames, 24 FPS, cardinaux 239/diagonaux 215)

### Phase 2 — Core Gameplay
- [x] Système de santé (cœurs à la Zelda, max_hp=10)
- [x] Stamina (course)
- [x] Combat idle (état COMBAT, Tab toggle, sprint auto-activation, timeout 3s, animations 8 dir, 29 frames, 20 FPS, tailles run)
- [ ] Attaques (light attack 1/2/3, hitbox, dégâts)
- [ ] Inventaire + items (Resources Godot)
- [ ] Ramassage d'objets (ramassable générique)
- [ ] Armes qui se cassent (durabilité)
- [ ] Cuisine / élixirs (craft)

### Phase 3 — Combat avancé
- [ ] Esquive / roulade
- [ ] Parade / contre
- [ ] Arc / projectiles
- [ ] Ennemis basiques (IA, patrouille, aggro)
- [ ] Boss (pattern, phases)

### Phase 4 — Survie & Exploration
- [ ] Cycle jour/nuit
- [ ] Météo (pluie, orage, tempête)
- [ ] Température (froid, chaleur → vêtements, élixirs)
- [ ] Faim / endurance
- [ ] Carte du monde (minimap + carte complète)

### Phase 5 — Monde & Environnement
- [ ] Tilemap isométrique (terrains, hauteurs)
- [ ] Biomes (plaine, forêt, désert, montagne, lac)
- [ ] Donjons / sanctuaires / grottes
- [ ] Points de téléportation (tours / feux de camp)
- [ ] PNJ / quêtes minimales

### Phase 6 — Polish
- [ ] Sons / musique (ambiance, combat, exploration)
- [ ] Particles (pluie, neige, feu, magie)
- [ ] Écran-titre, menus, game over
- [ ] Dialogues / cinématiques minimales
- [ ] Optimisation, tests, équilibrage

## Stack Technique
- **Moteur** : Godot Engine 4.x (GDScript)
- **Art** : Pixel art isométrique 2D (NEAREST filtering, 768×448 frames)
- **Taille perso** : cardinaux 239/idle-walk, 205/run, 205/combat-idle ; diagonaux 215/walk, 185/run, 185/combat-idle ; up 235/run
- **Langage** : GDScript (scripts), Python (preprocessing spritesheets)
- **Dépendances** : Pillow, numpy

## Décisions Clés
- Le personnage avance dans la direction visée (pas de strafe)
- Sprite scale = 0.75 (était 0.5)
- Animations nerveuses : IDLE_FPS=20, WALK_FPS=24, RUN_FPS=35
- Toutes les spritesheets en 8 rows (3072×3584) pour uniformité
- Walk diagonaux : cell_h=448, pas de compositing (gap=0 avec 8 rows)
- Walk left = mirror de right (la source left a les frames en ordre grid → moonwalk)
- Stamina regen_delay=0 (régénération instantanée dès l'arrêt)
- Barre stamina invisible quand stamina=max
- Inventaire à la BotW (grille, catégories, armes cassables)
- Difficulté Dark Souls (pas de mini-map, pas de marqueurs, combat punitif)
- Monde gigantesque, pas de loading screens si possible

## Fichiers Importants
- `scripts/riale.gd` — personnage principal (machine à états, animations)
- `scripts/main.gd` — scène de test (debug info, touches test)
- `scripts/stamina.gd` — gestion stamina (drain, regen, signal)
- `scripts/health.gd` — système de santé (cœurs, signaux)
- `scripts/preprocess_walk.py` — preprocessing spritesheets walk
- `scripts/preprocess_run.py` — preprocessing spritesheets run
- `scripts/preprocess_idle.py` — preprocessing spritesheets idle
- `scenes/riale.tscn` — scène personnage (Sprite, Collision, Camera, Health, Stamina)
- `scenes/main.tscn` — scène de test (+ HeartDisplay, + StaminaBar)
- `scenes/heart_display.gd` + `.tscn` — UI cœurs
- `scenes/stamina_bar.gd` + `.tscn` — barre stamina HUD
- `art/riale/walk/` — spritesheets walk (3072×3584, 28 frames, 8 rows)
- `art/riale/run/` — spritesheets run (3072×3584, 29 frames, 8 rows)
- `art/riale/combat_idle/` — spritesheets combat idle (3072×3584, 29 frames, 8 rows)
- `art/riale/combat_idle/` — spritesheets combat idle (3072×3584, 29 frames, 8 rows)
- `art/riale/idle/` — spritesheets idle (768×...)
- `art/ouda/idle/` — spritesheets Ouda idle (3072×3584, 29 frames, 8 rows)
- `art/ouda/walk/` — spritesheets Ouda walk (3072×3584, 29 frames, 8 rows)
- `riale-game-skills.md` — ce fichier (vision + roadmap)

## Personnages
### Riale
- Idle (8 dir, 21 frames, 20 FPS, 239px)
- Walk (8 dir, 28 frames, 24 FPS, cardinaux 239/diagonaux 215)
- Run (8 dir, 29 frames, 35 FPS, tailles variables)
- Combat idle (8 dir, 29 frames, 20 FPS, tailles run)
- Sprint + stamina + santé (cœurs)
- Tab → combat mode (auto au sprint, timeout 3s)

### Ouda
- Idle (8 dir, 29 frames, 20 FPS, 239px)
- Walk (8 dir, 29 frames, 24 FPS, cardinaux 239/diagonaux 215)
- Mêmes contrôles que Riale (ZQSD/WASD/Flèches)
- Mêmes tailles que Riale (scale 0.75, cellules 768×448)
- Sources : down, down-right, up-right, up, right → mirroring pour les 8 directions

## Sources Art
- `Riale/anim/` — animations Riale (Walk, run, Idle, combat/)
- `Ouda/anim/` — animations Ouda (Idle/, Walk/)
