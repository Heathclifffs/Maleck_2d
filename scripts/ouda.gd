extends CharacterBody2D

enum State { IDLE, WALK }

const SPEED := 35.0
const IDLE_FPS := 20.0
const WALK_FPS := 24.0

const DIRECTIONS := ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]
const IDLE_FILES := {
	"down": "down_idle.png",
	"down_left": "down_left_idle.png",
	"left": "left_idle.png",
	"up_left": "up_left_idle.png",
	"up": "up_idle.png",
	"up_right": "up_right_idle.png",
	"right": "right_idle.png",
	"down_right": "down_right_idle.png",
}
const WALK_FILES := {
	"down": "down_walk.png",
	"down_left": "down_left_walk.png",
	"down_right": "down_right_walk.png",
	"left": "left_walk.png",
	"right": "right_walk.png",
	"up": "up_walk.png",
	"up_left": "up_left_walk.png",
	"up_right": "up_right_walk.png",
}

@onready var sprite := $Sprite as AnimatedSprite2D

var state := State.IDLE
var direction := "down"


func _ready():
	_setup_input()
	_build_all_animations()
	sprite.play("idle_" + direction)
	_update_sprite_offset()


func _setup_input():
	for name in ["move_left", "move_right", "move_up", "move_down"]:
		if not InputMap.has_action(name):
			InputMap.add_action(name)

	_add_key("move_left", KEY_A)
	_add_key("move_right", KEY_D)
	_add_key("move_up", KEY_W)
	_add_key("move_down", KEY_S)
	_add_key("move_up", KEY_Z)
	_add_key("move_left", KEY_Q)
	_add_key("move_left", KEY_LEFT)
	_add_key("move_right", KEY_RIGHT)
	_add_key("move_up", KEY_UP)
	_add_key("move_down", KEY_DOWN)


static func _add_key(action: String, keycode: Key):
	var ev := InputEventKey.new()
	ev.keycode = keycode
	InputMap.action_add_event(action, ev)


func _build_all_animations():
	var sf := SpriteFrames.new()
	_build_anim_set(sf, "idle_", "res://art/ouda/idle/", IDLE_FILES, 4, 8, IDLE_FPS)
	_build_anim_set(sf, "walk_", "res://art/ouda/walk/", WALK_FILES, 4, 8, WALK_FPS)
	sprite.sprite_frames = sf


func _build_anim_set(sf: SpriteFrames, prefix: String, base_path: String,
files: Dictionary, cols: int, rows: int, fps: float):
	for dir_name in files.keys():
		var tex := load(base_path + files[dir_name]) as Texture2D
		if tex == null:
			push_error("Missing: " + base_path + files[dir_name])
			continue
		var src_h := tex.get_height()
		var row_h := src_h / rows
		var fw := tex.get_width() / cols

		sf.add_animation(prefix + dir_name)
		sf.set_animation_loop(prefix + dir_name, true)
		sf.set_animation_speed(prefix + dir_name, fps)

		var src_image := tex.get_image()

		for row in rows:
			for col in cols:
				var rect := Rect2i(col * fw, row * row_h, fw, row_h)
				var frame_image := src_image.get_region(rect)
				if _is_empty(frame_image):
					continue
				sf.add_frame(prefix + dir_name,
					ImageTexture.create_from_image(frame_image))


static func _is_empty(img: Image) -> bool:
	var count := 0
	for y in range(0, img.get_height(), 4):
		for x in range(0, img.get_width(), 4):
			if img.get_pixel(x, y).a > 0.0:
				count += 1
				if count >= 10:
					return false
	return true


func _physics_process(delta: float):
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if input_dir.length() > 0.2:
		direction = _dir_from_input(input_dir)
		_change_to(State.WALK)
		velocity = input_dir.normalized() * SPEED
		move_and_slide()
	else:
		if state != State.IDLE:
			_change_to(State.IDLE)
			velocity = Vector2.ZERO


func _update_sprite_offset():
	match state:
		State.IDLE:
			sprite.position.y = -88
		State.WALK:
			sprite.position.y = -86

func _change_to(new_state: State):
	state = new_state
	_update_sprite_offset()
	var prefix := "idle_"
	match state:
		State.WALK: prefix = "walk_"
	var anim := prefix + direction
	if sprite.animation != anim:
		sprite.play(anim)


func _dir_from_input(input: Vector2) -> String:
	var idx := roundi(rad_to_deg(input.angle()) / 45.0)
	return DIRECTIONS[posmod(idx + 6, 8)]
