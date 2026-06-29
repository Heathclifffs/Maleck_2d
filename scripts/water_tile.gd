extends Sprite2D

var frame_index := 0
var frame_count := 16
var frame_w := 130
var speed := 8.0 + randf() * 5.0
var elapsed := randf() * 100.0

func _ready():
	region_enabled = true
	region_rect = Rect2(0, 0, frame_w, texture.get_height())
	frame_index = randi() % frame_count
	region_rect.position.x = frame_index * frame_w

func _process(delta):
	elapsed += delta * speed
	frame_index = int(elapsed) % frame_count
	region_rect.position.x = frame_index * frame_w
