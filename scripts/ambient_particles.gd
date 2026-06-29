extends GPUParticles2D

@onready var day_night := $"../DayNight" as Node

func _process(_delta):
	if not day_night:
		return
	var t: float = day_night.get("time")
	var raw := sin(t * TAU)
	var night := 1.0 - clampf(raw * 1.4 + 0.2, 0.0, 1.0)
	emitting = night > 0.4
