extends CharacterBody2D

class_name PushableBlock

@onready var sprite := $Sprite2D as Sprite2D

const DIRECTIONS := ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]

func _ready():
	add_to_group("pushable")
	if sprite and not sprite.texture:
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.6, 0.4, 0.2, 1))
		sprite.texture = ImageTexture.create_from_image(img)

func try_move(velocity: Vector2) -> bool:
	var col := move_and_collide(velocity)
	return col == null
