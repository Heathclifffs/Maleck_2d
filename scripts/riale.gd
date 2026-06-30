extends CharacterBody2D

enum State { IDLE, WALK, RUN, COMBAT_IDLE, RUNNING_JUMP, SLIDE, ATTACK1, ATTACK2, PICKUP, PUSH, CLIMB_HANG, CLIMB_UP, DEATH, SWIM, TAKEN_DAMAGE }

const SPEED := 35.0
const RUN_SPEED := 140.0
const IDLE_FPS := 24.0
const WALK_FPS := 30.0
const RUN_FPS := 70.0
const COMBAT_IDLE_FPS := 24.0
const RUNNING_JUMP_FPS := 70.0
const SLIDE_FPS := 70.0
const ATTACK1_FPS := 55.0
const ATTACK2_FPS := 55.0
const PICKUP_FPS := 24.0
const PUSH_FPS := 24.0
const CLIMB_HANG_FPS := 24.0
const CLIMB_UP_FPS := 24.0
const DEATH_FPS := 24.0
const SWIM_FPS := 24.0
const SWIM_SPEED := 20.0
const TAKEN_DAMAGE_FPS := 24.0
const CLIMB_SPEED := 40.0
const CLIMB_EDGE_MARGIN := 20.0
const COMBAT_TIMEOUT := 3.0
const PUSH_SPEED := 20.0

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
const ATTACK1_FILES := {
	"down": "down_attack1.png",
	"down_left": "down_left_attack1.png",
	"down_right": "down_right_attack1.png",
	"left": "left_attack1.png",
	"right": "right_attack1.png",
	"up": "up_attack1.png",
	"up_left": "up_left_attack1.png",
	"up_right": "up_right_attack1.png",
}
const ATTACK2_FILES := {
	"down": "down_attack2.png",
	"down_left": "down_left_attack2.png",
	"down_right": "down_right_attack2.png",
	"left": "left_attack2.png",
	"right": "right_attack2.png",
	"up": "up_attack2.png",
	"up_left": "up_left_attack2.png",
	"up_right": "up_right_attack2.png",
}
const PICKUP_FILES := {
	"down": "down_pickup.png",
	"down_left": "down_left_pickup.png",
	"down_right": "down_right_pickup.png",
	"left": "left_pickup.png",
	"right": "right_pickup.png",
	"up": "up_pickup.png",
	"up_left": "up_left_pickup.png",
	"up_right": "up_right_pickup.png",
}
const PUSH_FILES := {
	"down": "down_push.png",
	"down_left": "down_left_push.png",
	"down_right": "down_right_push.png",
	"left": "left_push.png",
	"right": "right_push.png",
	"up": "up_push.png",
	"up_left": "up_left_push.png",
	"up_right": "up_right_push.png",
}
const CLIMB_HANG_FILES := {
	"down": "down_climb_hang.png",
	"down_left": "down_left_climb_hang.png",
	"down_right": "down_right_climb_hang.png",
	"left": "left_climb_hang.png",
	"right": "right_climb_hang.png",
	"up": "up_climb_hang.png",
	"up_left": "up_left_climb_hang.png",
	"up_right": "up_right_climb_hang.png",
}
const CLIMB_UP_FILES := {
	"down": "down_climb_up.png",
	"down_left": "down_left_climb_up.png",
	"down_right": "down_right_climb_up.png",
	"left": "left_climb_up.png",
	"right": "right_climb_up.png",
	"up": "up_climb_up.png",
	"up_left": "up_left_climb_up.png",
	"up_right": "up_right_climb_up.png",
}
const DEATH_FILES := {
	"down": "down_death.png",
	"down_left": "down_left_death.png",
	"down_right": "down_right_death.png",
	"left": "left_death.png",
	"right": "right_death.png",
	"up": "up_death.png",
	"up_left": "up_left_death.png",
	"up_right": "up_right_death.png",
}
const SWIM_FILES := {
	"down": "down_swim.png",
	"down_left": "down_left_swim.png",
	"down_right": "down_right_swim.png",
	"left": "left_swim.png",
	"right": "right_swim.png",
	"up": "up_swim.png",
	"up_left": "up_left_swim.png",
	"up_right": "up_right_swim.png",
}
const TAKEN_DAMAGE_FILES := {
	"down": "down_taken_damage.png",
	"down_left": "down_left_taken_damage.png",
	"down_right": "down_right_taken_damage.png",
	"left": "left_taken_damage.png",
	"right": "right_taken_damage.png",
	"up": "up_taken_damage.png",
	"up_left": "up_left_taken_damage.png",
	"up_right": "up_right_taken_damage.png",
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

var _combo_queued := false
var _combo_index := 0  # 0 → ATTACK1, 1 → ATTACK2

var state := State.IDLE
var direction := "down"

var _previous_state := State.IDLE
var _nearest_pickup: Node2D = null
var _pushing_block: Node2D = null
var _climbing_target: Node2D = null
var _in_water := false
var _water_count := 0

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
	var health := get_node_or_null("Health")
	if health:
		health.died.connect(_on_died)
		health.damage_taken.connect(_on_damage_taken)
	_update_sprite_offset()


func _on_water_entered():
	_water_count += 1
	_in_water = true


func _on_water_exited():
	_water_count -= 1
	if _water_count <= 0:
		_water_count = 0
		_in_water = false


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

	if not InputMap.has_action("attack"):
		InputMap.add_action("attack")
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("attack", mouse)

	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
	_add_key("interact", KEY_E)


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
	_build_anim_set(sf, "attack1_", "res://art/riale/attack1/", ATTACK1_FILES, 4, 8, ATTACK1_FPS, false)
	_build_anim_set(sf, "attack2_", "res://art/riale/attack2/", ATTACK2_FILES, 4, 8, ATTACK2_FPS, false)
	_build_anim_set(sf, "pickup_", "res://art/riale/pickup/", PICKUP_FILES, 4, 8, PICKUP_FPS, false)
	_build_anim_set(sf, "push_", "res://art/riale/push/", PUSH_FILES, 4, 8, PUSH_FPS, true)
	_build_anim_set(sf, "climb_hang_", "res://art/riale/climb_hang/", CLIMB_HANG_FILES, 4, 2, CLIMB_HANG_FPS, true)
	_build_anim_set(sf, "climb_up_", "res://art/riale/climb_up/", CLIMB_UP_FILES, 4, 8, CLIMB_UP_FPS, false)
	_build_anim_set(sf, "death_", "res://art/riale/death/", DEATH_FILES, 4, 8, DEATH_FPS, false)
	_build_anim_set(sf, "swim_", "res://art/riale/swim/", SWIM_FILES, 4, 8, SWIM_FPS, true)
	_build_anim_set(sf, "taken_damage_", "res://art/riale/taken_damage/", TAKEN_DAMAGE_FILES, 4, 8, TAKEN_DAMAGE_FPS, false)
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
	if event.is_action_pressed("attack"):
		if state == State.ATTACK1 or state == State.ATTACK2:
			_combo_queued = true
			return
		combat_mode = true
		combat_idle_timer = 0.0
		_previous_state = State.COMBAT_IDLE
		_combo_queued = false
		_combo_index = 0
		_change_to(State.ATTACK1)
		velocity = Vector2.ZERO
		return

	if event.is_action_pressed("toggle_combat"):
		combat_mode = not combat_mode
		combat_idle_timer = 0.0
		if state == State.IDLE or state == State.COMBAT_IDLE:
			_change_to(State.IDLE)

	if event.is_action_pressed("interact"):
		if state == State.PICKUP or state == State.PUSH or state == State.CLIMB_HANG:
			return
		_nearest_pickup = _find_nearest_pickup()
		if _nearest_pickup:
			_previous_state = state
			_face_toward(_nearest_pickup.global_position)
			_change_to(State.PICKUP)
			velocity = Vector2.ZERO
			return
		_pushing_block = _find_nearest_pushable()
		if _pushing_block:
			_previous_state = state
			_face_toward(_pushing_block.global_position)
			_change_to(State.PUSH)
			velocity = Vector2.ZERO
			return
		_climbing_target = _find_nearest_climbable()
		if _climbing_target:
			_previous_state = state
			_face_toward(_climbing_target.global_position)
			_change_to(State.CLIMB_HANG)
			velocity = Vector2.ZERO


func _on_died():
	if state == State.DEATH:
		return
	_change_to(State.DEATH)


func _on_damage_taken(_amount: int):
	if state == State.DEATH or state == State.TAKEN_DAMAGE:
		return
	_change_to(State.TAKEN_DAMAGE)


func _on_animation_finished():
	if state == State.RUNNING_JUMP or state == State.SLIDE:
		_change_to(State.RUN)
	elif state == State.ATTACK1 or state == State.ATTACK2:
		if _combo_queued:
			_combo_queued = false
			_combo_index = 1 if state == State.ATTACK1 else 0
			_change_to(State.ATTACK1 if _combo_index == 0 else State.ATTACK2)
		else:
			_combo_index = 0
			_change_to(State.COMBAT_IDLE)
	elif state == State.PICKUP:
		if _nearest_pickup and is_instance_valid(_nearest_pickup):
			_nearest_pickup.queue_free()
		_nearest_pickup = null
		_change_to(State.COMBAT_IDLE if combat_mode else State.IDLE)
	elif state == State.CLIMB_UP:
		_climb_teleport_up()
	elif state == State.DEATH:
		_change_to(State.IDLE)
	elif state == State.TAKEN_DAMAGE:
		_change_to(State.COMBAT_IDLE if combat_mode else State.IDLE)


func _physics_process(delta: float):
	if state == State.ATTACK1 or state == State.ATTACK2 or state == State.PICKUP or state == State.DEATH or state == State.TAKEN_DAMAGE:
		move_and_slide()
		return

	if state == State.CLIMB_UP:
		move_and_slide()
		return

	if state == State.CLIMB_HANG:
		_handle_climb_hang()
		return

	if state == State.PUSH:
		_handle_push()
		return

	# Update pickup prompt labels
	_update_pickup_prompts()
	_update_climbable_prompts()

	if state == State.SLIDE:
		move_and_slide()
		return

	if _in_water and state in [State.IDLE, State.WALK, State.RUN, State.COMBAT_IDLE]:
		_change_to(State.SWIM)
		return
	if not _in_water and state == State.SWIM:
		_change_to(State.COMBAT_IDLE if combat_mode else State.IDLE)
		return

	if state == State.SWIM:
		var input_dir := Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
		)
		if input_dir.length() > 0.2:
			var new_dir := _dir_from_input(input_dir)
			if new_dir != direction:
				direction = new_dir
				sprite.play("swim_" + direction)
			velocity = input_dir.normalized() * SWIM_SPEED
		else:
			velocity = Vector2.ZERO
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
		State.ATTACK1:      prefix = "attack1_"
		State.ATTACK2:      prefix = "attack2_"
		State.PICKUP:       prefix = "pickup_"
		State.PUSH:         prefix = "push_"
		State.CLIMB_HANG:   prefix = "climb_hang_"
		State.CLIMB_UP:     prefix = "climb_up_"
		State.DEATH:        prefix = "death_"
		State.SWIM:         prefix = "swim_"
		State.TAKEN_DAMAGE: prefix = "taken_damage_"
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
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.WALK:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.RUN:
			sprite.position.y = -51
			sprite.scale = Vector2(0.5, 0.5)
		State.COMBAT_IDLE:
			sprite.position.y = -55
			sprite.scale = Vector2(0.5, 0.5)
		State.RUNNING_JUMP:
			var s := 0.5
			var off := -51
			match direction:
				"down":
					s = 0.275
					off = -45
				"up":
					s = 0.347
					off = -53
				"down_right", "down_left":
					s = 0.375
					off = -37
				"right", "left":
					s = 0.424
					off = -45
				"up_right", "up_left":
					s = 0.424
					off = -46
			jump_base_offset = off
			sprite.scale = Vector2(s, s)
			sprite.position.y = off
		State.ATTACK1:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.ATTACK2:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.PICKUP:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.PUSH:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.CLIMB_HANG:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.CLIMB_UP:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.DEATH:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.SWIM:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.TAKEN_DAMAGE:
			sprite.position.y = -59
			sprite.scale = Vector2(0.5, 0.5)
		State.SLIDE:
			var s := 0.5
			var off := -51
			match direction:
				"down":
					s = 0.283
					off = -45
				"down_right", "down_left":
					s = 0.382
					off = -37
				"right", "left":
					s = 0.434
					off = -45
				"up_right", "up_left":
					s = 0.411
					off = -45
				"up":
					s = 0.467
					off = -54
			sprite.scale = Vector2(s, s)
			sprite.position.y = off


func _dir_from_input(input: Vector2) -> String:
	var idx := roundi(rad_to_deg(input.angle()) / 45.0)
	return DIRECTIONS[posmod(idx + 6, 8)]


func _dir_to_vector(dir_name: String) -> Vector2:
	var idx := DIRECTIONS.find(dir_name)
	if idx < 0:
		return Vector2.ZERO
	var rad := deg_to_rad(idx * 45.0)
	return Vector2(cos(rad), sin(rad)).normalized()


func _face_toward(target_pos: Vector2):
	var d := global_position.direction_to(target_pos)
	direction = _dir_from_input(d)


func _find_nearest_pickup() -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for area in get_tree().get_nodes_in_group("pickup"):
		var d := global_position.distance_to(area.global_position)
		if d < best_dist:
			best_dist = d
			best = area
	return best if best_dist <= 80.0 else null


func _find_nearest_pushable() -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for area in get_tree().get_nodes_in_group("pushable"):
		var d := global_position.distance_to(area.global_position)
		if d < best_dist:
			best_dist = d
			best = area
	return best if best_dist <= 80.0 else null


func _find_nearest_climbable() -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for area in get_tree().get_nodes_in_group("climbable"):
		var d := global_position.distance_to(area.global_position)
		if d < best_dist:
			best_dist = d
			best = area
	return best if best_dist <= 80.0 else null


func _update_pickup_prompts():
	for area in get_tree().get_nodes_in_group("pickup"):
		var d := global_position.distance_to(area.global_position)
		if d <= 80.0 and area.has_method("show_prompt"):
			area.show_prompt()
		elif area.has_method("hide_prompt"):
			area.hide_prompt()


func _update_climbable_prompts():
	for area in get_tree().get_nodes_in_group("climbable"):
		var d := global_position.distance_to(area.global_position)
		if d <= 80.0 and area.has_method("show_prompt"):
			area.show_prompt()
		elif area.has_method("hide_prompt"):
			area.hide_prompt()


func _climb_teleport_up():
	if _climbing_target and is_instance_valid(_climbing_target):
		var offset: Vector2 = Vector2(0, -100)
		if "climb_offset" in _climbing_target:
			offset = _climbing_target.get("climb_offset")
		global_position += offset
	_climbing_target = null
	_change_to(State.COMBAT_IDLE if combat_mode else State.IDLE)


func _handle_climb_hang():
	if not _climbing_target or not is_instance_valid(_climbing_target):
		_climbing_target = null
		_change_to(State.COMBAT_IDLE if combat_mode else State.IDLE)
		return

	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("move_up"):
		_change_to(State.CLIMB_UP)
		return

	var input_x := Input.get_axis("move_left", "move_right")
	var dir_vec := Vector2(input_x, 0)
	velocity = dir_vec * CLIMB_SPEED

	var prev_pos := global_position
	move_and_slide()

	# Constrain to climbable bounds
	var ctarget: Node2D = _climbing_target
	var half_w: float = 32.0
	if "climb_width" in ctarget:
		half_w = ctarget.get("climb_width")
	var cx: float = ctarget.global_position.x
	global_position.x = clamp(global_position.x, cx - half_w, cx + half_w)

	# Check if near stable edge → auto climb up
	var dist_to_left: float = abs(global_position.x - (cx - half_w))
	var dist_to_right: float = abs(global_position.x - (cx + half_w))
	var margin: float = CLIMB_EDGE_MARGIN
	if dist_to_left <= margin or dist_to_right <= margin:
		_change_to(State.CLIMB_UP)
		return

	# Update direction and animation for horizontal movement
	var new_dir := direction
	if input_x > 0.1:
		new_dir = "right"
	elif input_x < -0.1:
		new_dir = "left"
	if new_dir != direction:
		direction = new_dir
		var anim := "climb_hang_" + direction
		if sprite.sprite_frames.has_animation(anim):
			sprite.play(anim)


func _handle_push():
	if not _pushing_block or not is_instance_valid(_pushing_block):
		_pushing_block = null
		_change_to(State.COMBAT_IDLE if combat_mode else State.IDLE)
		return

	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if input_dir.length() < 0.2:
		_pushing_block = null
		_change_to(State.COMBAT_IDLE if combat_mode else State.IDLE)
		return

	# Check if input is roughly toward the push direction
	var input_dir_name := _dir_from_input(input_dir)
	if input_dir_name != direction:
		_pushing_block = null
		_change_to(State.COMBAT_IDLE if combat_mode else State.IDLE)
		return

	var spd := PUSH_SPEED
	var dir_vec := _dir_to_vector(direction)
	velocity = dir_vec * spd
	var prev_pos := global_position
	move_and_slide()
	var displacement := global_position - prev_pos
	if displacement.length() > 0.0:
		var block := _pushing_block as PushableBlock
		if block and block.try_move(displacement) == false:
			global_position = prev_pos
			velocity = Vector2.ZERO
