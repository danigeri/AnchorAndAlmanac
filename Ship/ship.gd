extends CharacterBody2D

signal speed_change(speed)
signal sail_state_change(sail_state)

enum SailStates { SAIL_STATE_ANCHORED, SAIL_STATE_DOWN, SAIL_STATE_MID, SAIL_STATE_UP }
enum { LEFT = -1, RIGHT = 1 }

const SAIL_SPEED_DICT = {
	SailStates.SAIL_STATE_ANCHORED: 0.0,
	SailStates.SAIL_STATE_DOWN: 0.1,
	SailStates.SAIL_STATE_MID: 0.5,
	SailStates.SAIL_STATE_UP: 1,
}

# The quotient of how the turn speed is dependent of the current speed.
const TURN_SPEED_QUOTIENT: float = 0.5

@export var max_speed_mps: int = 50
@export var turn_rad: float = PI / 12
@export var inertia: float = 0.1

var current_speed_mps: float
var direction: Vector2
var facing_rad: float
var sail_state: SailStates
var wind_direction: Vector2
var wind_strength: int


func _ready() -> void:
	current_speed_mps = 0
	
	sail_state = SailStates.SAIL_STATE_ANCHORED
	sail_state_change.emit(sail_state)

	direction = Vector2.RIGHT
	facing_rad = direction.angle()
	
	set_rotation_degrees(90)


func _input(event: InputEvent) -> void:
	if (event as InputEvent).is_action_pressed("ui_up") and sail_state < SailStates.SAIL_STATE_UP:
		sail_state += 1
		sail_state_change.emit(sail_state)

	if (
		(event as InputEvent).is_action_pressed("ui_down")
		and sail_state > SailStates.SAIL_STATE_DOWN
	):
		sail_state -= 1
		sail_state_change.emit(sail_state)

	if (
		(event as InputEvent).is_action_pressed("ui_accept")
		and sail_state == SailStates.SAIL_STATE_DOWN
	):
		sail_state -= 1
		sail_state_change.emit(sail_state)


# Input polling: something to do as long as the key is pressed
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		turn(RIGHT, delta)

	if Input.is_action_pressed("ui_left"):
		turn(LEFT, delta)

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	_set_speed(delta)

	velocity.x = direction.x * current_speed_mps
	velocity.y = direction.y * current_speed_mps
	move_and_slide()


func turn(directional_multiplier: int, delta: float) -> void:
	var facing_chage_rad: float = (
		directional_multiplier * turn_rad * delta * current_speed_mps * TURN_SPEED_QUOTIENT
	)

	facing_rad += facing_chage_rad
	rotate(facing_chage_rad)

	direction.x = cos(facing_rad)
	direction.y = sin(facing_rad)


func _set_speed(delta: float) -> void:
	var dummy_wind_strenght: float = (wind_strength/10.0)
	var target_speed_mps: float = (
		max_speed_mps * SAIL_SPEED_DICT[sail_state] * _wind_angle_to_power() * dummy_wind_strenght
	)

	if current_speed_mps != target_speed_mps:
		var prefix = 1 if current_speed_mps < target_speed_mps else -1

		current_speed_mps += prefix * inertia * delta

		# The delta multiplier can lead to very low very precise differences in
		# equality checks causing the speed to update in every frame, hence the rounding.
		current_speed_mps = snapped(current_speed_mps, 0.0000001)

		speed_change.emit(current_speed_mps)
		#_animate_speed(current_speed_mps)


func _wind_angle_to_power() -> float:
	var angle: float = direction.dot(wind_direction)
	var wind_power: float = (2 * angle + 1) / 3 if angle > -0.5 else 0.01
	var dummy_wind_strenght: float = (wind_strength/10.0)

	return wind_power * dummy_wind_strenght


func _animate_speed(speed: float) -> void:
	var speed_scale = speed / max_speed_mps
	print("Speed scale changed to %s" % speed_scale)
	$AnimationPlayer.speed_scale = speed_scale


func _on_wind_update_wind(dir, strength) -> void:
	wind_direction = dir
	wind_strength = strength
