extends Control

@onready var prompt := $Prompt as Label
@onready var continue_btn := $VBox/Continue as Button
@onready var new_game_btn := $VBox/NewGame as Button
@onready var quit_btn := $VBox/Quit as Button

var elapsed := 0.0

func _ready():
	continue_btn.disabled = true
	new_game_btn.pressed.connect(_on_new_game_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

	_theme_button(continue_btn)
	_theme_button(new_game_btn)
	_theme_button(quit_btn)

func _theme_button(btn: Button):
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
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxTexture.new()
	hover.texture = border_tex
	hover.content_margin_left = 32
	hover.content_margin_top = 32
	hover.content_margin_right = 32
	hover.content_margin_bottom = 32
	hover.modulate_color = Color(1.0, 0.8, 0.4)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxTexture.new()
	pressed.texture = border_tex
	pressed.content_margin_left = 32
	pressed.content_margin_top = 32
	pressed.content_margin_right = 32
	pressed.content_margin_bottom = 32
	pressed.modulate_color = Color(0.5, 0.4, 0.2)
	btn.add_theme_stylebox_override("pressed", pressed)

	var disabled := StyleBoxTexture.new()
	disabled.texture = border_tex
	disabled.content_margin_left = 32
	disabled.content_margin_top = 32
	disabled.content_margin_right = 32
	disabled.content_margin_bottom = 32
	disabled.modulate_color = Color(0.3, 0.25, 0.15)
	btn.add_theme_stylebox_override("disabled", disabled)

	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.8))
	btn.add_theme_color_override("font_pressed_color", Color(0.8, 0.8, 0.6))
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5, 0.5))

func _process(delta):
	elapsed += delta
	prompt.modulate.a = 0.55 + sin(elapsed * 0.6) * 0.08

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")

func _on_quit_pressed():
	get_tree().quit()
