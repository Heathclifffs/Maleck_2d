extends Control

@onready var label := $Label as Label
@onready var day_night := get_node("/root/Main/DayNight")

func _process(_delta: float):
	var t := float(day_night.time)
	var total_hours := t * 24.0
	var hours := int(total_hours)
	var minutes := int((total_hours - hours) * 60)
	label.text = "%02d:%02d" % [hours, minutes]
	queue_redraw()

func _draw():
	var w := size.x
	var bar_w := w - 20.0
	var bar_y := 50.0
	var bar_h := 8.0
	var bar_x := 10.0

	draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.15, 0.15, 0.2, 0.7))
	draw_rect(Rect2(bar_x, bar_y, bar_w * 0.5, bar_h), Color(0.4, 0.6, 1.0, 0.4), false, 1.0)

	var t := float(day_night.time)
	var sun_x := bar_x + t * bar_w
	var sun_color := Color(1.0, 0.8, 0.2) if t > 0.2 and t < 0.8 else Color(0.7, 0.7, 1.0)
	draw_circle(Vector2(sun_x, bar_y + bar_h * 0.5), 6.0, sun_color)
