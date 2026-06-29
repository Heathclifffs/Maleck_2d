extends Control

@onready var riale_card := $HBox/Riale as Control
@onready var ouda_card := $HBox/Ouda as Control
@onready var riale_sprite := $HBox/Riale/Sprite as TextureRect
@onready var ouda_sprite := $HBox/Ouda/Sprite as TextureRect
@onready var riale_bg := $HBox/Riale/BgPanel as NinePatchRect
@onready var ouda_bg := $HBox/Ouda/BgPanel as NinePatchRect

var _hovered_card: String = ""

func _ready():
	$BackBtn.pressed.connect(_on_back_pressed)

	_theme_back_button()
	_load_sprite_frames()

	riale_card.gui_input.connect(_on_riale_gui_input)
	ouda_card.gui_input.connect(_on_ouda_gui_input)
	riale_card.mouse_entered.connect(_on_card_mouse_entered.bind("riale"))
	ouda_card.mouse_entered.connect(_on_card_mouse_entered.bind("ouda"))
	riale_card.mouse_exited.connect(_on_card_mouse_exited.bind("riale"))
	ouda_card.mouse_exited.connect(_on_card_mouse_exited.bind("ouda"))

func _load_sprite_frames():
	var r_tex := load("res://art/riale/idle/riale_down_Idle.png") as Texture2D
	if r_tex:
		var fw := r_tex.get_width() / 4
		var fh := r_tex.get_height() / 6
		var atlas := AtlasTexture.new()
		atlas.atlas = r_tex
		atlas.region = Rect2i(0, 0, fw, fh)
		riale_sprite.texture = atlas

	var o_tex := load("res://art/ouda/idle/down_idle.png") as Texture2D
	if o_tex:
		var fw := o_tex.get_width() / 4
		var fh := o_tex.get_height() / 8
		var atlas := AtlasTexture.new()
		atlas.atlas = o_tex
		atlas.region = Rect2i(0, 0, fw, fh)
		ouda_sprite.texture = atlas

func _theme_back_button():
	var border_tex := load("res://art/ui/border/panel-border-000.png") as Texture2D
	if not border_tex:
		return

	var normal := StyleBoxTexture.new()
	normal.texture = border_tex
	normal.content_margin_left = 32
	normal.content_margin_top = 32
	normal.content_margin_right = 32
	normal.content_margin_bottom = 32
	normal.modulate_color = Color(0.7, 0.55, 0.3)
	$BackBtn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxTexture.new()
	hover.texture = border_tex
	hover.content_margin_left = 32
	hover.content_margin_top = 32
	hover.content_margin_right = 32
	hover.content_margin_bottom = 32
	hover.modulate_color = Color(1.0, 0.8, 0.4)
	$BackBtn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxTexture.new()
	pressed.texture = border_tex
	pressed.content_margin_left = 32
	pressed.content_margin_top = 32
	pressed.content_margin_right = 32
	pressed.content_margin_bottom = 32
	pressed.modulate_color = Color(0.5, 0.4, 0.2)
	$BackBtn.add_theme_stylebox_override("pressed", pressed)

	$BackBtn.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	$BackBtn.add_theme_color_override("font_hover_color", Color(1, 1, 0.8))
	$BackBtn.add_theme_color_override("font_pressed_color", Color(0.8, 0.8, 0.6))

func _on_card_mouse_entered(card_name: String):
	_hovered_card = card_name
	var bg := riale_bg if card_name == "riale" else ouda_bg
	bg.modulate = Color(1.0, 0.8, 0.4, 0.35)

func _on_card_mouse_exited(card_name: String):
	_hovered_card = ""
	var bg := riale_bg if card_name == "riale" else ouda_bg
	bg.modulate = Color(0.6, 0.45, 0.25, 0.2)

func _on_riale_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_character("riale")

func _on_ouda_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_character("ouda")

func _select_character(who: String):
	GameState.selected_character = who
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
