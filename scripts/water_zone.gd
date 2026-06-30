extends Node2D

@onready var area := $Area2D
@onready var collision_shape := $Area2D/CollisionShape2D

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func set_rect(size: Vector2):
	var shape := RectangleShape2D.new()
	shape.size = size
	collision_shape.shape = shape

func _on_body_entered(body):
	if body.has_method("_on_water_entered"):
		body._on_water_entered()

func _on_body_exited(body):
	if body.has_method("_on_water_exited"):
		body._on_water_exited()
