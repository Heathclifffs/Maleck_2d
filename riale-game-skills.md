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
- [x] Idle 8 directions (spritesheets + animation)
- [x] Walk 8 directions (spritesheets + animation) — cardinaux OK, diagonaux à améliorer
- [x] Contrôles ZQSD/WASD/Flèches, machine à états Idle↔Walk
- [x] Camera2D attachée au personnage
- [x] Vitesse marche = 35 px/s

### Phase 2 — Core Gameplay
- [ ] Système de santé (cœurs à la Zelda)
- [ ] Stamina (course, escalade, combat)
- [ ] Inventaire + items (Resources Godot)
- [ ] Ramassage d'objets (ramassable générique)
- [ ] Armes qui se cassent (durabilité)
- [ ] Cuisine / élixirs (craft)

### Phase 3 — Combat
- [ ] Système de combat mêlée (armes)
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
- **Taille perso** : ~239px de haut, 35 px/s marche
- **Langage** : GDScript (scripts), Python (preprocessing spritesheets)
- **Dépendances** : Pillow, numpy

## Décisions Clés
- Le personnage avance dans la direction visée (pas de strafe)
- Inventaire à la BotW (grille, catégories, armes cassables)
- Difficulté Dark Souls (pas de mini-map, pas de marqueurs, combat punitif)
- Monde gigantesque, pas de loading screens si possible

## Fichiers Importants
- `scripts/riale.gd` — personnage principal
- `scripts/main.gd` — scène de test
- `scripts/preprocess_walk.py` — preprocessing spritesheets walk
- `scripts/preprocess_idle.py` — preprocessing spritesheets idle
- `scenes/riale.tscn` — scène personnage
- `scenes/main.tscn` — scène de test
- `art/riale/walk/` — spritesheets walk générées
- `art/riale/idle/` — spritesheets idle générées
