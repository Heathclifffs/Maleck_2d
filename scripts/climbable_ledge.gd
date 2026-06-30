extends Area2D

class_name ClimbableLedge

@export var climb_offset := Vector2(0, -100)
@export var climb_width := 64.0

@onready var label := $ClimbLabel as Label
@onready var sprite := $Sprite2D as Sprite2D

func _ready():
	add_to_group("climbable")
	if sprite and not sprite.texture:
		var img := Image.create(64, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.3, 0.5, 1, 1))
		sprite.texture = ImageTexture.create_from_image(img)
	if label:
		label.hide()

func show_prompt():
	if label:
		label.text = "[E] Climb"
		label.show()

func hide_prompt():
	if label:
		label.hide()
