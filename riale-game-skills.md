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
- [x] Tilemap isométrique (mewki Nature Blocks ~130×130, TileSet Isometric 128×64)
- [x] 19 tuiles sol (herbe, terre, pierre, escalier) dans `art/isometric_floor/`
- [x] TileMapLayer dans main.tscn avec grille 40×40 générée procéduralement
- [ ] Biomes variés (plaine, forêt, désert, montagne, lac, donjon)
- [ ] Collisions + occlusions sur le tilemap
- [ ] LightOccluder2D sur le terrain pour ombres portées
- [ ] Parallax multi-plan (fond lointain, medium, premier plan)

### Phase 4 — Core Gameplay
- [x] Système de santé (cœurs à la Zelda, max_hp=10)
- [x] Stamina (course)
- [x] Combat idle (état COMBAT, Tab toggle, sprint auto-activation, timeout 3s)
- [x] Running Jump (Space en sprint, animation 29 frames, jump visuel parabolique, 8 directions dont 3 mirror)
- [x] Slide (LCtrl en sprint, animation 29 frames, 8 directions dont 3 mirror)
- [x] Attack1 (8 dir, 29 frames, 55 FPS, non-loop, déclenchable depuis tout état, retour état précédent)
- [x] Run Ouda (8 dir, 25 frames, 48 FPS, sprint + stamina)
- [ ] Attaques (attack 2/3, hitbox, dégâts)
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
- **Taille perso** : cardinaux 239/idle-walk-run, 205/combat-idle ; diagonaux 215/idle-walk-run, 185/combat-idle ; up 235/combat-idle
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
- Animations nerveuses : IDLE_FPS=24, WALK_FPS=30, RUN_FPS=70, COMBAT_IDLE_FPS=24, RUNNING_JUMP_FPS=70, SLIDE_FPS=70, ATTACK1_FPS=55
- Toutes les spritesheets en 8 rows (3072×3584) pour uniformité
- Walk diagonaux : cell_h=448, pas de compositing (gap=0 avec 8 rows)
- Walk left = mirror de right (la source left a les frames en ordre grid → moonwalk)
**→ Solution : flip cellule par cellule (PIL Image.FLIP_LEFT_RIGHT sur chaque crop), jamais flip entier**
- Stamina regen_delay=0 (régénération instantanée dès l'arrêt)
- Barre stamina invisible quand stamina=max
- **Jump visuel : pas de gravité/gameplay Y. Parabole `4*t*(1-t)*30px` ajoutée au sprite.position.y sur 0.35s. La cellule contient déjà le mouvement vertical dans ses frames (feet_row varie), la parabole du code ajoute le "saut" global**
- **Slide/Jump non-loop : animation_finished → retour à State.RUN**
- **Collisions désactivées pendant SLIDE (move_and_slide + return)**
- **Bug fix : après SLIDE/JUMP → `_change_to(State.RUN)`, la condition `if move_state == State.RUN` échouait si Shift relâché. Solution : `if move_state == State.RUN or state == State.RUN` pour rattraper la frame transitoire où state est encore RUN avant que `_change_to(WALK)` ne soit appelé**
- **Attack1** : non-looping, `_on_animation_finished` → retour à `_previous_state`. `_unhandled_input` capture clic gauche, sauvegarde l'état courant, passe en ATTACK1. Pendant l'attaque, `_physics_process` fait juste `move_and_slide()` sans bouger.
- **Source inversion attack1 left/right** : le fichier source `riale_attack_1_left.png` contient l'animation **face à droite** (pas à gauche). Le preprocessing traite donc ce fichier comme la direction `right` et le mirrore pour produire `left`. Ne PAS suivre le nom du fichier.
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
- `scripts/preprocess_ouda_run.py` — preprocessing Ouda run (5 sources → 8 dir via mirror)
- `scripts/preprocess_attack1.py` — preprocessing Riale attack1 (5 sources → 8 dir, left source = right-facing)
- `scenes/riale.tscn` — scène Riale (Sprite shader, Collision, Camera, Health, Stamina)
- `scenes/ouda.tscn` — scène Ouda (Sprite shader, Collision, Stamina, Camera)
- `scenes/main.tscn` — scène de test (WorldEnvironment, SunLight, Riale + Ouda)
- `scenes/heart_display.gd` + `.tscn` — UI cœurs
- `scenes/stamina_bar.gd` + `.tscn` — barre stamina HUD
- `art/riale/` — spritesheets Riale (idle, walk, run, combat_idle, running_jump, running_slide, attack1)
- `art/ouda/` — spritesheets Ouda (idle, walk, run)
- `riale-game-skills.md` — ce fichier (vision + roadmap)

## Personnages
### Riale
- Idle (8 dir, 21 frames, 24 FPS, 239px)
- Walk (8 dir, 28 frames, 30 FPS, cardinaux 239/diagonaux 215)
- Run (8 dir, 29 frames, 70 FPS, cardinaux 239/diagonaux 215)
- Combat idle (8 dir, 29 frames, 24 FPS, tailles run)
- **Running jump** (Space en sprint, 8 dir, 29 frames, 70 FPS, non-loop → retour RUN)
- **Slide** (LCtrl en sprint, 8 dir, 29 frames, 70 FPS, non-loop → retour RUN)
- **Attack1** (clic gauche, 8 dir, 29 frames, 55 FPS, non-loop → retour état précédent)
- Sprint + stamina + santé (cœurs)
- Tab → combat mode (auto au sprint, timeout 3s)

### Running Jump & Slide — Scaling
Quand on ajoute une animation qui **transitionne depuis un état existant** (ex: Run → Jump), il faut scaler la nouvelle animation pour que sa **taille visuelle** au premier frame soit identique à l'animation source.

Principe : `scale_jump = (content_height_run × 0.75) / content_height_jump`

Ceci assure une transition transparente sans changement brusque de taille à l'écran. Voici les valeurs calculées :

| Direction | run content | jump content | jump scale | jump offset | slide content | slide scale | slide offset |
|-----------|-------------|--------------|------------|-------------|---------------|-------------|--------------|
| down | 186 | 338 | 0.413 | -68 | 328 | 0.425 | -68 |
| down_right/left | 165 | 220 | 0.562 | -56 | 216 | 0.573 | -56 |
| right/left | 191 | 225 | 0.637 | -67 | 220 | 0.651 | -68 |
| up_right/left | 190 | 224 | 0.636 | -69 | 231 | 0.617 | -68 |
| up | 227 | 327 | 0.521 | -79 | 243 | 0.701 | -81 |

Calcul de l'offset : `offset = -(feet_row - cell_h/2) × scale` pour que les pieds touchent le sol (y=0).

### Attack1 — Déclenchable depuis tout état
L'attaque de base (clic gauche) peut interrompre n'importe quel état (IDLE, WALK, RUN, COMBAT_IDLE, RUNNING_JUMP, SLIDE). Mécanique :
1. L'état courant est sauvegardé dans `_previous_state`
2. `velocity = Vector2.ZERO` (le personnage s'arrête)
3. L'animation attack1 non-looping se joue
4. `_physics_process` fait juste `move_and_slide()` (maintient la collision)
5. `_on_animation_finished` → `_change_to(_previous_state)`
6. Scale = 0.75 (identique idle/walk, target_h=239/215)
7. **⚠️ Source inversion** : `riale_attack_1_left.png` montre le personnage face à droite. Le preprocessing traite ce fichier comme la direction `right` et le mirrore pour produire `left`. Voir `preprocess_attack1.py`.

### Création d'animations manquantes par Mirroring
Toutes les animations Riale/Ouda n'ont que 5 directions en source : **down, down_right, right, up_right, up**. Les 3 directions manquantes (left, down_left, up_left) sont obtenues par **mirroir horizontal** des directions right correspondantes.

**⚠️ RÈGLE CRITIQUE — Toujours faire un flip cellule par cellule, JAMAIS un flip de l'image entière :**

```
# ❌ MAUVAIS — flip de l'image entière
Image.FLIP_LEFT_RIGHT  # inverse aussi l'ordre des cellules dans la grille

# ✅ BON — flip chaque cellule individuellement
for row in range(rows):
    for col in range(cols):
        cell = img.crop((col * fw, row * fh, (col+1) * fw, (row+1) * fh))
        flipped = cell.transpose(Image.FLIP_LEFT_RIGHT)
        result.paste(flipped, (col * fw, row * fh))
```

Pourquoi ? Les spritesheets utilisent une grille 4×8 (ou 4×6). Si on flip l'image entière, la cellule en colonne 0 devient la colonne 3, inversant l'ordre temporel des frames de l'animation → le personnage fait moonwalk ou des sauts incohérents. En flipant chaque cellule dans sa propre grille, on préserve l'ordre des frames.

### Règle d'Or du Scaling
1. **Toujours scaler une nouvelle animation par rapport à l'état qu'elle remplace** (transition smoothe)
2. **Toujours utiliser `content_height × 0.75` comme référence** (le scale de base du projet)
3. **Ne JAMAIS appliquer de scale spécial sans offset correspondant** (les pieds doivent toujours toucher le sol)
4. **Les directions down et up ont les plus grands contenus** (338-328px) → les plus petits scales (0.41-0.55)
5. **Les directions diagonales ont des contenus moyens** (216-231px) → scales moyens (0.56-0.70)
6. **Les directions latérales (right/left) ont les plus petits contenus** (220-231px) → scales proches de 0.65

### Ouda
- Idle (8 dir, 29 frames, 20 FPS, 239px)
- Walk (8 dir, 29 frames, 24 FPS, cardinaux 239/diagonaux 215)
- Run (8 dir, 25 frames, 48 FPS, cardinaux 239/diagonaux 215, sprint + stamina)
- Mêmes contrôles que Riale (ZQSD/WASD/Flèches + Shift sprint)
- Mêmes tailles que Riale (scale 0.75, cellules 768×448)
- Même shader PBR que Riale (normales + outline)
- Sources run : down, down-right, right, up-right, up → mirror pour left, down_left, up_left

## Sources Art
- `Riale/anim/` — animations Riale (Walk, run, Idle, combat/)
- `Ouda/anim/` — animations Ouda (Idle/, Walk/)
