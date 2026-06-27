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
- [x] Rendu 2.5D : shader PBR (pseudo-normals + outline) sur Riale + Ouda
- [x] Éclairage 2D directionnel (DirectionalLight2D, 135°, energy=1.8)
- [x] Post-processing : WorldEnvironment (ACES tonemap + glow bloom)

### Phase 2 — Rendu 2.5D & Polish Visuel
- [x] Shader PBR (pseudo-normal + outline) sur Riale + Ouda
- [x] Éclairage directionnel 2D (DirectionalLight2D)
- [x] WorldEnvironment (ACES tonemap + glow bloom)
- [ ] Ombres portées (LightOccluder2D) sur persos + tilemap
- [ ] Rim light dans le shader (highlight bordure côté lumière)
- [ ] PointLight2D dynamique (torche, aura, magie)
- [ ] Particules d'ambiance (poussière, feuilles, lucioles, pluie)
- [ ] Color grading custom (LUT) pour palette stylisée unique
- [ ] Vignette dynamique (s'intensifie en combat / basse vie)
- [ ] Chromatic aberration sur actions (coups, magie)

### Phase 3 — Tilemap & Environnement
- [ ] Tilemap isométrique avec hauteurs + Z-index auto
- [ ] Biomes variés (plaine, forêt, désert, montagne, lac, donjon)
- [ ] Collisions + occlusions sur le tilemap
- [ ] LightOccluder2D sur le terrain pour ombres portées
- [ ] Parallax multi-plan (fond lointain, medium, premier plan)

### Phase 4 — Core Gameplay
- [x] Système de santé (cœurs à la Zelda, max_hp=10)
- [x] Stamina (course)
- [x] Combat idle (état COMBAT, Tab toggle, sprint auto-activation, timeout 3s)
- [ ] Attaques (light attack 1/2/3, hitbox, dégâts)
- [ ] Run + combat idle pour Ouda
- [ ] Inventaire + items (Resources Godot)
- [ ] Ramassage d'objets (ramassable générique)
- [ ] Armes qui se cassent (durabilité)
- [ ] Cuisine / élixirs (craft)

### Phase 5 — Combat avancé
- [ ] Esquive / roulade
- [ ] Parade / contre
- [ ] Arc / projectiles
- [ ] Ennemis basiques (IA, patrouille, aggro)
- [ ] Boss (pattern, phases)

### Phase 6 — Survie & Exploration
- [ ] Cycle jour/nuit (lumière directionnelle dynamique)
- [ ] Météo (pluie, orage, tempête → particules + audio)
- [ ] Température (froid, chaleur → vêtements, élixirs)
- [ ] Faim / endurance
- [ ] Carte du monde (minimap + carte complète)
- [ ] Points de téléportation (tours / feux de camp)

### Phase 7 — Monde & Narration
- [ ] PNJ / quêtes minimales
- [ ] Dialogues
- [ ] Donjons / sanctuaires / grottes procéduraux
- [ ] Boss et arènes

### Phase 8 — Polish Final
- [ ] Sons / musique (ambiance, combat, exploration)
- [ ] Écran-titre, menus, game over
- [ ] Optimisation, tests, équilibrage

## Stack Technique
- **Moteur** : Godot Engine 4.x (GDScript, shaders GLSL)
- **Art** : Pixel art isométrique 2D (NEAREST filtering, 768×448 frames)
- **Taille perso** : cardinaux 239/idle-walk, 205/run, 205/combat-idle ; diagonaux 215/walk, 185/run, 185/combat-idle ; up 235/run
- **Langage** : GDScript (scripts), Python (preprocessing spritesheets), GLSL (shaders)
- **Dépendances** : Pillow, numpy

## Rendu 2.5D (PoC)

Shader PBR appliqué sur Riale ET Ouda pour un rendu stylisé façon 3D.

### Techniques

1. **Pseudo-normal maps from alpha** — shader canvas_item qui calcule les normales en temps réel à partir du gradient d'alpha du sprite (échantillonnage 4 pixels cardinaux). L'éclairage 2D directionnel réagit aux normales, donnant du volume aux personnages pixel art.

2. **Outline shader** — détection de bord par échantillonnage des 8 pixels voisins. Si un voisin a alpha < seuil (0.15 par défaut), le pixel est en bordure et reçoit une couleur d'outline (noir semi-transparent). Donne un rendu "bande dessinée" qui fait ressortir le personnage.

3. **Éclairage directionnel 2D** — DirectionalLight2D (soleil, energy=1.8, rotation=135°). Éclaire uniformément la scène. Les normales calculées par le shader font varier la réflexion de la lumière sur les sprites.

4. **Post-processing** — WorldEnvironment avec :
   - ACES Fitted tonemap (rendu cinématique, courbes de couleur style film)
   - Glow bloom (intensité=0.3, blend mode=Screen) pour les zones lumineuses
   - Exposure = 1.1

### Shader

- `shaders/riale_pbr.gdshader` — shader réutilisable (Riale + Ouda)
- Uniforms configurables dans l'inspecteur Godot :
  - `normal_strength` (0.0–5.0) : intensité de l'effet de volume
  - `outline_color` : couleur de l'outline (noir par défaut)
  - `outline_threshold` (0.0–1.0) : seuil de détection des bords
  - `sample_radius` (0.0–5.0) : distance d'échantillonnage pour normal + outline

### Scène

- `scenes/main.tscn` — contient WorldEnvironment + DirectionalLight2D
- Riale et Ouda sont côte à côte avec le même shader pour comparaison visuelle

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
- `shaders/riale_pbr.gdshader` — shader PBR (pseudo-normal + outline)
- `scripts/riale.gd` — personnage Riale (machine à états, animations, combat)
- `scripts/ouda.gd` — personnage Ouda (idle + walk 8 dir)
- `scripts/main.gd` — scène de test (debug info, touches test)
- `scripts/stamina.gd` — gestion stamina (drain, regen, signal)
- `scripts/health.gd` — système de santé (cœurs, signaux)
- `scripts/preprocess_walk.py` — preprocessing spritesheets walk Riale
- `scripts/preprocess_run.py` — preprocessing spritesheets run Riale
- `scripts/preprocess_idle.py` — preprocessing spritesheets idle Riale
- `scripts/preprocess_combat_idle.py` — preprocessing combat idle Riale
- `scripts/preprocess_ouda.py` — preprocessing Ouda idle + walk
- `scenes/riale.tscn` — scène Riale (Sprite shader, Collision, Camera, Health, Stamina)
- `scenes/ouda.tscn` — scène Ouda (Sprite shader, Collision, Camera)
- `scenes/main.tscn` — scène de test (WorldEnvironment, SunLight, Riale + Ouda)
- `scenes/heart_display.gd` + `.tscn` — UI cœurs
- `scenes/stamina_bar.gd` + `.tscn` — barre stamina HUD
- `art/riale/` — spritesheets Riale (idle, walk, run, combat_idle)
- `art/ouda/` — spritesheets Ouda (idle, walk)
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
- Même shader PBR que Riale (normales + outline)
- Sources : down, down-right, up-right, up, right → mirroring pour les 8 directions

## Sources Art
- `Riale/anim/` — animations Riale (Walk, run, Idle, combat/)
- `Ouda/anim/` — animations Ouda (Idle/, Walk/)
