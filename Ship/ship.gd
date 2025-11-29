extends CharacterBody2D

signal speed_change(speed)
signal sail_state_change(sail_state)
signal steering_state_change(steering_state)

enum SailStates { SAIL_STATE_ANCHORED, SAIL_STATE_DOWN, SAIL_STATE_MID, SAIL_STATE_UP }
enum SteeringStates { MAX_LEFT, MID_LEFT, SMALL_LEFT, FORWARD, SMALL_RIGHT, MID_RIGHT, MAX_RIGHT }
enum { LEFT = -1, RIGHT = 1 }

const SAIL_SPEED_DICT = {
	SailStates.SAIL_STATE_ANCHORED: 0.0,
	SailStates.SAIL_STATE_DOWN: 0.1,
	SailStates.SAIL_STATE_MID: 0.5,
	SailStates.SAIL_STATE_UP: 1,
}

const STEERING_DICT = {
	SteeringStates.MAX_LEFT: deg_to_rad(-30),
	SteeringStates.MID_LEFT: deg_to_rad(-20),
	SteeringStates.SMALL_LEFT: deg_to_rad(-10),
	SteeringStates.FORWARD: 0.0,
	SteeringStates.SMALL_RIGHT: deg_to_rad(10),
	SteeringStates.MID_RIGHT: deg_to_rad(20),
	SteeringStates.MAX_RIGHT: deg_to_rad(30)
}

const PADDLE_ROTATE_DICT = {
	SteeringStates.MAX_LEFT: 260,
	SteeringStates.MID_LEFT: 230,
	SteeringStates.SMALL_LEFT: 200,
	SteeringStates.FORWARD: 180,
	SteeringStates.SMALL_RIGHT: 160,
	SteeringStates.MID_RIGHT: 130,
	SteeringStates.MAX_RIGHT: 100
}

# The quotient of how the turn speed is dependent of the current speed.
const TURN_SPEED_QUOTIENT: float = 0.01

@export var max_speed_mps: int = 50
@export var min_speed_mps: int = 0
@export var inertia: float = 50

var current_speed_mps: float
var direction: Vector2
var facing_rad: float
var sail_state: SailStates
var wind_direction: float
var wind_strength: int
var steering_state: SteeringStates = SteeringStates.FORWARD

var ship_sail_textures = {
	0: preload("uid://bbieh6ykr1utn"),
	1: preload("uid://2dmopix4411b"),
	2: preload("uid://2y2bbaay71to"),
	3: preload("uid://dro2oifwem04m")
}

var ship_sail_sounds = {
	1: preload("uid://ce7gsd31giuvq"),
	2: preload("uid://d0nlo66t4scg4"),
	3: preload("uid://d4iceoqtmnb1a")
}

var ship_hit_sounds = {
	0: preload("uid://cbhmfjjb8hueo"),
	1: preload("uid://dw5chvmbl7qrh"),
	2: preload("uid://kkwqnuq1fbac")  #sink sound
}

@onready var camera_2d: Camera2D = $Camera2D
@onready var hitbox: Area2D = $Hitbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var paddle: Sprite2D = $Sprite2D/Paddle
@onready var sail_sounds_player: AudioStreamPlayer = $SailSoundsPlayer
@onready var ship_move_sound_player: AudioStreamPlayer = $ShipMoveSoundPlayer
@onready var ship_hit_sound_player: AudioStreamPlayer = $ShipHitSoundPlayer


func _ready() -> void:
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	Globals.go_to_last_checkpoint.connect(_on_go_to_last_checkpoint)
	camera_2d.make_current()
	current_speed_mps = 0

	sail_state = SailStates.SAIL_STATE_ANCHORED
	sail_state_change.emit(sail_state)

	direction = Vector2.RIGHT
	facing_rad = direction.angle()

	set_rotation_degrees(90)


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		set_sail_state(event)
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		set_steering_state(event)


# Input polling: something to do as long as the key is pressed
func _physics_process(delta: float) -> void:
	move(delta)


func set_sail_state(event: InputEvent) -> void:
	if (event as InputEvent).is_action_pressed("ui_up") and sail_state < SailStates.SAIL_STATE_UP:
		sail_state += 1

	if (
		(event as InputEvent).is_action_pressed("ui_down")
		and sail_state > SailStates.SAIL_STATE_ANCHORED
	):
		sail_state -= 1

	sail_state_change.emit(sail_state)

	set_max_speed(sail_state)
	set_ship_texture(sail_state)
	play_sail_sound(sail_state)


func play_sail_sound(sail_state: int) -> void:
	if sail_state == 0:
		return  # no sound for anchoring yet
	sail_sounds_player.stream = (ship_sail_sounds[sail_state])
	if sail_state == 3:
		## az effekt az mp3 felénél kezdődik
		sail_sounds_player.play(1)
	else:
		sail_sounds_player.play(0.0)


func move(delta: float) -> void:
	var turning_inertia
	
	if SAIL_SPEED_DICT[sail_state] != 0.0:
		turning_inertia = 1/SAIL_SPEED_DICT[sail_state]
	else:
		turning_inertia = 0.1
		
	var facing_change_rad: float = (
		STEERING_DICT[steering_state] * delta * turning_inertia
	)
	facing_rad += facing_change_rad
	rotate(facing_change_rad)

	direction.x = cos(facing_rad)
	direction.y = sin(facing_rad)
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	_set_speed(delta)

	velocity.x = direction.x * current_speed_mps
	velocity.y = direction.y * current_speed_mps
	move_and_slide()
	handle_move_sound(velocity)


func get_camera() -> Camera2D:
	return camera_2d


func _set_speed(delta: float) -> void:
	var target_speed_mps: float = (
		max_speed_mps * SAIL_SPEED_DICT[sail_state] * _wind_angle_to_power()
	)

	if target_speed_mps > max_speed_mps:
		target_speed_mps = max_speed_mps

	if target_speed_mps < min_speed_mps:
		target_speed_mps = min_speed_mps

	if current_speed_mps != target_speed_mps:
		var prefix = 1 if current_speed_mps < target_speed_mps else -1

		current_speed_mps += prefix * inertia * delta

		# The delta multiplier can lead to very low very precise differences in
		# equality checks causing the speed to update in every frame, hence the rounding.
		current_speed_mps = snapped(current_speed_mps, 0.0000001)
		if current_speed_mps > max_speed_mps:
			current_speed_mps = move_toward(current_speed_mps, max_speed_mps, 0.05)
		speed_change.emit(current_speed_mps)
		#_animate_speed(current_speed_mps)


func _wind_angle_to_power() -> float:
	var wind_bonus

	var diff: float = direction.angle() - wind_direction
	diff = atan2(sin(diff), cos(diff))

	if abs(diff) < PI / 4:
		wind_bonus = 1
	elif abs(diff) < PI / 2:
		wind_bonus = 0.75
	else:
		wind_bonus = 0.5

	return wind_bonus


func _animate_speed(speed: float) -> void:
	var speed_scale = speed / max_speed_mps
	print("Speed scale changed to %s" % speed_scale)
	$AnimationPlayer.speed_scale = speed_scale


func _on_wind_update_wind(dir, strength) -> void:
	wind_direction = dir
	wind_strength = strength


func _on_hitbox_body_entered(body):
	print(body)
	if body.is_in_group("damaging"):
		Globals.remove_hp()
		animation_player.play("hit")
		handle_hit_sound()


func _on_go_to_last_checkpoint(_last_cp_position: Vector2) -> void:
	await animation_player.animation_finished
	sink_ship()
	current_speed_mps = 0
	sail_state = SailStates.SAIL_STATE_DOWN
	sail_state_change.emit(0)
	Globals.restore_hp()


func sink_ship() -> void:
	print("sink")
	animation_player.play("sink")
	await animation_player.animation_finished
	sprite_2d.scale = Vector2(1, 1)


func set_max_speed(sail_state: SailStates) -> void:
	match sail_state:
		0:
			max_speed_mps = 0
			min_speed_mps = 0
		1:
			max_speed_mps = 10
			min_speed_mps = 5
		2:
			max_speed_mps = 50
			min_speed_mps = 25
		3:
			max_speed_mps = 400
			min_speed_mps = 200


func set_steering_state(event):
	if event.is_action_pressed("ui_right") and steering_state < SteeringStates.MAX_RIGHT:
		steering_state += 1
	if event.is_action_pressed("ui_left") and steering_state > SteeringStates.MAX_LEFT:
		steering_state -= 1
	steering_state_change.emit(steering_state)
	update_paddle_angle(steering_state)


func set_ship_texture(state: int) -> void:
	sprite_2d.texture = ship_sail_textures[state]


func update_paddle_angle(state: SteeringStates) -> void:
	paddle.set_rotation_degrees(PADDLE_ROTATE_DICT[state])


func handle_move_sound(velocity: Vector2) -> void:
	if velocity.x > 0 or velocity.y > 0:
		if !ship_move_sound_player.playing:
			ship_move_sound_player.play(0.0)
	else:
		sail_sounds_player.playing = false


func handle_hit_sound() -> void:
	print("play sound: ", Globals.current_hp)
	ship_hit_sound_player.stream = ship_hit_sounds[Globals.current_hp]
	ship_hit_sound_player.play(0.0)
