extends Control

@export var bar_width := 160
@export var bar_height := 12

var _stamina = null

func _ready():
	_stamina = get_node("/root/Main/Riale/Stamina")
	if _stamina:
		_stamina.stamina_changed.connect(_on_stamina_changed)
	visible = false

func _on_stamina_changed(st: float, mst: float):
	visible = st < mst
	if visible:
		queue_redraw()

func _draw():
	if _stamina == null or not visible:
		return
	var st: float = _stamina.current
	var mst: float = _stamina.max_stamina
	var ratio: float = st / mst
	var sw := size.x
	var ox := (sw - bar_width) / 2.0
	var oy := size.y - bar_height - 8

	draw_rect(Rect2(ox, oy, bar_width, bar_height), Color(0.1, 0.1, 0.1, 0.8))
	draw_rect(Rect2(ox + 1, oy + 1, (bar_width - 2) * ratio, bar_height - 2),
			  Color(0.3, 0.85, 0.3))
