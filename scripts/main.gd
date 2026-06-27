extends Node2D

@onready var riale := $Riale
@onready var ouda := $Ouda
@onready var info := $UI/InfoLabel as Label

var rng := RandomNumberGenerator.new()
var hp_text := ""
var stamina_text := ""

var grass_tex: Array[Texture2D] = []
var dirt_tex: Array[Texture2D] = []
var stone_tex: Array[Texture2D] = []
var stair_tex: Texture2D
var floor_material: ShaderMaterial
var step_y := 50.0

func _ready():
	var shader := load("res://shaders/tile_pbr.gdshader") as Shader
	if shader:
		floor_material = ShaderMaterial.new()
		floor_material.shader = shader

	riale.get_node("Health").health_changed.connect(_on_health_changed)
	riale.get_node("Stamina").stamina_changed.connect(_on_stamina_changed)
	_on_health_changed(riale.get_node("Health").current_hp, riale.get_node("Health").max_hp)
	_on_stamina_changed(riale.get_node("Stamina").current, riale.get_node("Stamina").max_stamina)
	_load_textures()
	_build_floor()

func _load_textures():
	var dir := DirAccess.open("res://art/isometric_floor/")
	if not dir:
		return
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir() and f.get_extension().to_lower() == "png" and f != "spritesheet_nature-blocks.png":
			var tex := load("res://art/isometric_floor/" + f) as Texture2D
			if tex:
				if f.begins_with("grass"):
					grass_tex.append(tex)
				elif f.begins_with("dirt"):
					dirt_tex.append(tex)
				elif f.begins_with("stone"):
					stone_tex.append(tex)
				elif f.begins_with("stair"):
					stair_tex = tex
		f = dir.get_next()

func _build_floor():
	if grass_tex.is_empty():
		return

	var floor_node := Node2D.new()
	floor_node.name = "Floor"
	add_child(floor_node)
	move_child(floor_node, 0)

	var step_x := 65.0

	for x in range(-12, 13):
		for y in range(-12, 13):
			var pos := Vector2((x - y) * step_x, (x + y) * step_y)
			var tex := grass_tex[rng.randi_range(0, grass_tex.size() - 1)]
			var spr := Sprite2D.new()
			spr.texture = tex
			spr.position = pos
			spr.z_index = (x + y) * 2 + 50
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			if floor_material:
				spr.material = floor_material
			floor_node.add_child(spr)

	if riale:
		riale.reparent(floor_node, true)
	if ouda:
		ouda.reparent(floor_node, true)
		var cam := ouda.get_node_or_null("Camera2D") as Camera2D
		if cam:
			cam.enabled = false

func _update_z_indices():
	riale.z_index = floori((riale.global_position.y + 65.0) / step_y) * 2 + 1 + 50
	if ouda:
		ouda.z_index = floori((ouda.global_position.y + 65.0) / step_y) * 2 + 1 + 50

func _process(_delta: float):
	_update_z_indices()
	var dir_name: String = riale.direction.capitalize().replace("_", " ")
	var state_names := {0: "Idle", 1: "Walk", 2: "Run", 3: "Combat"}
	var state_name: String = state_names.get(riale.state, "?")
	var sprint_tag := " [SPRINT]" if riale.is_sprinting else ""
	var combat_tag := " [⚔]" if riale.combat_mode else ""
	info.text = state_name + " " + dir_name + sprint_tag + combat_tag + hp_text + stamina_text

	if Input.is_action_just_pressed("ui_accept"):
		riale.get_node("Health").take_damage(1)
	if Input.is_action_just_pressed("ui_focus_next"):
		riale.get_node("Health").heal(2)
	if Input.is_action_just_pressed("ui_cancel"):
		riale.get_node("Health").take_damage(10)

func _on_health_changed(hp, mhp):
	hp_text = "   HP: %d/%d" % [hp, mhp]

func _on_stamina_changed(st, mst):
	stamina_text = "   ST: %d/%d" % [st, mst]
