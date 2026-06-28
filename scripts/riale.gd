extends CharacterBody2D

enum State { IDLE, WALK, RUN, COMBAT_IDLE, RUNNING_JUMP, SLIDE }

const SPEED := 35.0
const RUN_SPEED := 140.0
const IDLE_FPS := 24.0
const WALK_FPS := 30.0
const RUN_FPS := 70.0
const COMBAT_IDLE_FPS := 24.0
const RUNNING_JUMP_FPS := 70.0
const SLIDE_FPS := 70.0
const COMBAT_TIMEOUT := 3.0

const DIRECTIONS := ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]
const IDLE_FILES := {
	"down": "riale_down_Idle.png",
	"down_left": "riale_down-left_Idle.png",
	"left": "riale_left_Idle.png",
	"up_left": "riale_up-left_Idle.png",
	"up": "riale_up_Idle.png",
	"up_right": "riale_up-right_Idle.png",
	"right": "riale_right_Idle.png",
	"down_right": "riale_down-right_Idle.png",
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
const RUN_FILES := {
	"down": "down_run.png",
	"down_left": "down_left_run.png",
	"down_right": "down_right_run.png",
	"left": "left_run.png",
	"right": "right_run.png",
	"up": "up_run.png",
	"up_left": "up_left_run.png",
	"up_right": "up_right_run.png",
}
const COMBAT_IDLE_FILES := {
	"down": "down_combat_idle.png",
	"down_left": "down_left_combat_idle.png",
	"down_right": "down_right_combat_idle.png",
	"left": "left_combat_idle.png",
	"right": "right_combat_idle.png",
	"up": "up_combat_idle.png",
	"up_left": "up_left_combat_idle.png",
	"up_right": "up_right_combat_idle.png",
}
const RUNNING_JUMP_FILES := {
	"down": "down_running_jump.png",
	"down_left": "down_left_running_jump.png",
	"down_right": "down_right_running_jump.png",
	"left": "left_running_jump.png",
	"right": "right_running_jump.png",
	"up": "up_running_jump.png",
	"up_left": "up_left_running_jump.png",
	"up_right": "up_right_running_jump.png",
}
const SLIDE_FILES := {
	"down": "down_running_slide.png",
	"down_left": "down_left_running_slide.png",
	"down_right": "down_right_running_slide.png",
	"left": "left_running_slide.png",
	"right": "right_running_slide.png",
	"up": "up_running_slide.png",
	"up_left": "up_left_running_slide.png",
	"up_right": "up_right_running_slide.png",
}

@onready var sprite := $Sprite as AnimatedSprite2D
@onready var stamina := $Stamina

var is_sprinting := false
var combat_mode := false
var combat_idle_timer := 0.0

var state := State.IDLE
var direction := "down"

var jump_timer := 0.0
var jump_base_offset := 0.0
var jump_visual_offset := 0.0
const JUMP_HEIGHT := 30.0
const JUMP_DURATION := 0.35


func _ready():
	_setup_input()
	_build_all_animations()
	sprite.play("idle_" + direction)
	sprite.animation_finished.connect(_on_animation_finished)
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

	if not InputMap.has_action("sprint"):
		InputMap.add_action("sprint")
	_add_key("sprint", KEY_SHIFT)

	if not InputMap.has_action("toggle_combat"):
		InputMap.add_action("toggle_combat")
	_add_key("toggle_combat", KEY_TAB)

	if not InputMap.has_action("jump"):
		InputMap.add_action("jump")
	_add_key("jump", KEY_SPACE)

	if not InputMap.has_action("slide"):
		InputMap.add_action("slide")
	_add_key("slide", KEY_CTRL)


static func _add_key(action: String, keycode: Key):
	var ev := InputEventKey.new()
	ev.keycode = keycode
	InputMap.action_add_event(action, ev)


func _build_all_animations():
	var sf := SpriteFrames.new()
	_build_anim_set(sf, "idle_", "res://art/riale/idle/", IDLE_FILES, 4, 6, IDLE_FPS)
	_build_anim_set(sf, "walk_", "res://art/riale/walk/", WALK_FILES, 4, 8, WALK_FPS)
	_build_anim_set(sf, "run_", "res://art/riale/run/", RUN_FILES, 4, 8, RUN_FPS)
	_build_anim_set(sf, "combat_idle_", "res://art/riale/combat_idle/", COMBAT_IDLE_FILES, 4, 8, COMBAT_IDLE_FPS)
	_build_anim_set(sf, "running_jump_", "res://art/riale/running_jump/", RUNNING_JUMP_FILES, 4, 8, RUNNING_JUMP_FPS, false)
	_build_anim_set(sf, "slide_", "res://art/riale/running_slide/", SLIDE_FILES, 4, 8, SLIDE_FPS, false)
	sprite.sprite_frames = sf


func _build_anim_set(sf: SpriteFrames, prefix: String, base_path: String,
files: Dictionary, cols: int, rows: int, fps: float, looping: bool = true):
	for dir_name in files.keys():
		var tex := load(base_path + files[dir_name]) as Texture2D
		if tex == null:
			push_error("Missing: " + base_path + files[dir_name])
			continue
		var src_h := tex.get_height()
		var row_h := src_h / rows
		var fw := tex.get_width() / cols

		sf.add_animation(prefix + dir_name)
		sf.set_animation_loop(prefix + dir_name, looping)
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


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("toggle_combat"):
		combat_mode = not combat_mode
		combat_idle_timer = 0.0
		if state == State.IDLE or state == State.COMBAT_IDLE:
			_change_to(State.IDLE)


func _on_animation_finished():
	if state == State.RUNNING_JUMP or state == State.SLIDE:
		_change_to(State.RUN)
func _physics_process(delta: float):
	if state == State.SLIDE:
		move_and_slide()
		return

	if state == State.RUNNING_JUMP:
		jump_timer += delta
		var t := jump_timer / JUMP_DURATION
		if t < 1.0:
			jump_visual_offset = -JUMP_HEIGHT * 4.0 * t * (1.0 - t)
		else:
			jump_visual_offset = 0.0
		sprite.position.y = jump_base_offset + jump_visual_offset
		move_and_slide()
		# Auto-return if no animation frames (fallback)
		if t >= 1.0:
			var anim := "running_jump_" + direction
			if not sprite.sprite_frames.has_animation(anim) or sprite.sprite_frames.get_frame_count(anim) == 0:
				_change_to(State.RUN)
				return
		return

	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	is_sprinting = Input.is_action_pressed("sprint") and stamina.has_stamina()

	if input_dir.length() > 0.2:
		direction = _dir_from_input(input_dir)
		var move_state := State.RUN if is_sprinting else State.WALK

		if move_state == State.RUN or state == State.RUN:
			if Input.is_action_just_pressed("jump") and RUNNING_JUMP_FILES.has(direction):
				_change_to(State.RUNNING_JUMP)
				velocity = input_dir.normalized() * RUN_SPEED
				move_and_slide()
				stamina.start_deplete()
				combat_mode = true
				combat_idle_timer = 0.0
				return
			if Input.is_action_just_pressed("slide") and SLIDE_FILES.has(direction):
				_change_to(State.SLIDE)
				velocity = input_dir.normalized() * RUN_SPEED
				move_and_slide()
				stamina.start_deplete()
				combat_mode = true
				combat_idle_timer = 0.0
				return

		_change_to(move_state)
		var spd := RUN_SPEED if is_sprinting else SPEED
		velocity = input_dir.normalized() * spd
		move_and_slide()
		if is_sprinting:
			stamina.start_deplete()
			combat_mode = true
			combat_idle_timer = 0.0
		else:
			stamina.stop_deplete()
		combat_idle_timer = 0.0
	else:
		stamina.stop_deplete()
		if state != State.IDLE and state != State.COMBAT_IDLE:
			_change_to(State.IDLE)
			velocity = Vector2.ZERO
		combat_idle_timer += delta
		if combat_mode and combat_idle_timer >= COMBAT_TIMEOUT:
			combat_mode = false
			if state == State.COMBAT_IDLE:
				_change_to(State.IDLE)


func _change_to(new_state: State):
	state = new_state
	if new_state == State.RUNNING_JUMP:
		jump_timer = 0.0
		jump_visual_offset = 0.0
	_update_sprite_offset()
	var prefix := "idle_"
	match state:
		State.WALK:         prefix = "walk_"
		State.RUN:          prefix = "run_"
		State.COMBAT_IDLE:  prefix = "combat_idle_"
		State.RUNNING_JUMP: prefix = "running_jump_"
		State.SLIDE:        prefix = "slide_"
		_:
			prefix = "combat_idle_" if combat_mode else "idle_"
			if combat_mode:
				state = State.COMBAT_IDLE
	var anim := prefix + direction
	if sprite.sprite_frames.has_animation(anim) and sprite.sprite_frames.get_frame_count(anim) > 0:
		if sprite.animation != anim:
			sprite.play(anim)


func _update_sprite_offset():
	match state:
		State.IDLE:
			sprite.position.y = -89
			sprite.scale = Vector2(0.75, 0.75)
		State.WALK:
			sprite.position.y = -88
			sprite.scale = Vector2(0.75, 0.75)
		State.RUN:
			sprite.position.y = -76
			sprite.scale = Vector2(0.75, 0.75)
		State.COMBAT_IDLE:
			sprite.position.y = -82
			sprite.scale = Vector2(0.75, 0.75)
		State.RUNNING_JUMP:
			var s := 0.75
			var off := -76
			match direction:
				"down":
					s = 0.413
					off = -68
				"up":
					s = 0.521
					off = -79
				"down_right", "down_left":
					s = 0.562
					off = -56
				"right", "left":
					s = 0.637
					off = -67
				"up_right", "up_left":
					s = 0.636
					off = -69
			jump_base_offset = off
			sprite.scale = Vector2(s, s)
			sprite.position.y = off
		State.SLIDE:
			var s := 0.75
			var off := -76
			match direction:
				"down":
					s = 0.425
					off = -68
				"down_right", "down_left":
					s = 0.573
					off = -56
				"right", "left":
					s = 0.651
					off = -68
				"up_right", "up_left":
					s = 0.617
					off = -68
				"up":
					s = 0.701
					off = -81
			sprite.scale = Vector2(s, s)
			sprite.position.y = off


func _dir_from_input(input: Vector2) -> String:
	var idx := roundi(rad_to_deg(input.angle()) / 45.0)
	return DIRECTIONS[posmod(idx + 6, 8)]
