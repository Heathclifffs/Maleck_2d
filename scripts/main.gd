extends Node2D

@onready var riale := $Riale
@onready var info := $UI/InfoLabel as Label


func _process(_delta: float):
	var dir_name: String = riale.direction.capitalize().replace("_", " ")
	var state_name: String = "Idle" if riale.state == 0 else "Walk"
	info.text = state_name + " " + dir_name + "   |   ZQSD/WASD/Flèches"
