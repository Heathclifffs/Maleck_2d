extends Area2D

class_name PickupItem

@export var item_name := "Item"
@export var quantity := 1

@onready var label := $PickupLabel as Label
@onready var sprite := $Sprite2D as Sprite2D

func _ready():
	add_to_group("pickup")
	if sprite and not sprite.texture:
		var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 1, 0, 1))
		sprite.texture = ImageTexture.create_from_image(img)
	if label:
		label.hide()

func show_prompt():
	if label:
		label.text = "[E] " + item_name
		label.show()

func hide_prompt():
	if label:
		label.hide()
