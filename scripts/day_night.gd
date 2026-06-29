extends Node

@onready var sun := $"../SunLight" as DirectionalLight2D
@onready var fill := $"../FillLight" as DirectionalLight2D
@onready var mod := $"../CanvasModulate" as CanvasModulate

var day_duration := 120.0
var time := 0.25

func _process(delta):
	var dt: float = delta / day_duration
	if Input.is_key_pressed(KEY_T):
		dt *= 30.0
	time = fmod(time + dt, 1.0)

	var raw := sin((time - 0.25) * TAU)
	var sun_height := clampf(raw * 1.4 + 0.2, 0.0, 1.0)

	sun.energy = 0.7 * sun_height

	if sun.energy > 0.01:
		sun.rotation = PI * (0.25 + time)
		var warmth := 1.0 - sun_height
		sun.color = Color(1, 1, 1).lerp(Color(1.0, 0.55, 0.2), warmth * 0.55)
	else:
		sun.color = Color(0.4, 0.5, 0.8, 1)

	var night := 1.0 - sun_height
	fill.energy = 0.3 * night
	fill.color = Color(1, 1, 1).lerp(Color(0.4, 0.5, 0.9, 1), night * 0.7)

	mod.color = Color(1, 1, 1).lerp(Color(0.25, 0.25, 0.5, 1), night * 0.8)
