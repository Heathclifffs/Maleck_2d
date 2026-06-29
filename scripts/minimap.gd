extends Control

var floor_node: Node2D
var props_node: Node2D

var tile_size := 6
var grid_size := 25
var dot_radius := 5

const SX = 65.0
const SY = 50.0

var _setup_done := false

func _ready():
	call_deferred("_setup_nodes")

func _setup_nodes():
	floor_node = get_node_or_null("/root/Main/Floor")
	props_node = get_node_or_null("/root/Main/Props")
	_setup_done = true

func _process(_delta):
	if not _setup_done:
		return
	queue_redraw()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.2))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.6, 0.6, 0.6, 0.2), false, 1.0)

	if not floor_node:
		return

	var tiles = floor_node.get_meta("tile_grid")
	if typeof(tiles) != TYPE_ARRAY:
		return
	if tiles.is_empty():
		return

	var grid_px = grid_size * tile_size
	var ox = (size.x - grid_px) * 0.5
	var oy = (size.y - grid_px) * 0.5
	var ts = tile_size

	draw_rect(Rect2(ox, oy, grid_px, grid_px), Color(0, 0, 0, 0.3))

	for gx in grid_size:
		for gy in grid_size:
			var t = tiles[gx][gy]
			var col: Color
			match t:
				1: col = Color(0.5, 0.35, 0.2)
				2: col = Color(0.45, 0.45, 0.45)
				_: col = Color(0.3, 0.55, 0.2)
			draw_rect(Rect2(ox + gx * ts, oy + gy * ts, ts, ts), col)

	draw_rect(Rect2(ox, oy, grid_px, grid_px), Color(0.8, 0.8, 0.8, 0.25), false, 1.0)

	if props_node:
		var prop_positions = props_node.get_meta("prop_grid_positions")
		if typeof(prop_positions) == TYPE_ARRAY and not prop_positions.is_empty():
			for p in prop_positions:
				var pgx = p.x + 12.0
				var pgy = p.y + 12.0
				var px = ox + pgx * ts
				var py = oy + pgy * ts
				draw_rect(Rect2(px - 2, py - 2, 5, 5), Color(0.9, 0.9, 0.9, 0.6))
				draw_rect(Rect2(px - 1, py - 1, 3, 3), Color(0.3, 0.7, 0.2))

	for child in floor_node.get_children():
		if not (child.name == "Riale" or child.name == "Ouda"):
			continue
		var c = child as Node2D
		if not c:
			continue
		var cx = (c.global_position.x / SX + c.global_position.y / SY) / 2.0 + 12.0
		var cy = (c.global_position.y / SY - c.global_position.x / SX) / 2.0 + 12.0
		var px = ox + cx * ts
		var py = oy + cy * ts
		var col = Color(0.2, 0.6, 1.0) if c.name == "Riale" else Color(1.0, 0.5, 0.2)
		draw_circle(Vector2(px, py), dot_radius, Color.WHITE)
		draw_circle(Vector2(px, py), dot_radius - 1, col)
