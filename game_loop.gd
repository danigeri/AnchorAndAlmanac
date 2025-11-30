extends Node2D

signal endgame_barrier_destroy

var ship_camera: Camera2D
var endgame_barrier_camera: Camera2D
@onready var ship: CharacterBody2D = $Ship
@onready var endgame_barrier: Node2D = $EndgameBarrier
@onready var felho_of_war_container: Node2D = $FelhoOfWarContainer

@onready var starting_popup: Control = $StartingPopup
@onready
var world_shader_material: ShaderMaterial = $CanvasLayer/VignetteFilter.material as ShaderMaterial


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.all_checkpoints_collected.connect(_on_all_checkpoints_collected)
	Globals.go_to_last_checkpoint.connect(_on_go_to_last_checkpoint)
	ship_camera = ship.get_camera()
	endgame_barrier_camera = endgame_barrier.get_camera()
	# starting_popup.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# print("fps: ", Engine.get_frames_per_second())
func _process(_delta: float) -> void:
	pass


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()


func _on_all_checkpoints_collected():
	trigger_barrier_remove()


func trigger_barrier_remove() -> void:
	# 0. Initial wait and pause
	await get_tree().create_timer(0.6).timeout
	get_tree().paused = true

	# 1. Start Camera Transition AND WAIT FOR IT
	await CameraTransition.transition_camera(ship_camera, endgame_barrier_camera, 1.0)

	# --- SHAKE & DESTRUCTION START ---

	# 2. Fade OUT the felho container
	var tween_out = create_tween()
	tween_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_out.tween_property(felho_of_war_container, "modulate:a", 0.0, 1.0)

	endgame_barrier_destroy.emit()
	# 4. START SHADER SHAKE (Animate the ShakeStrength uniform)
	var shake_tween = create_tween()
	shake_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	# Instant maximum shake (1.0)
	var max_shake_strength: float = 1
	var fade_out_time = 3

	# MODIFICATION: Add .set_delay(1.0) to the first property tween
	(
		shake_tween
		. tween_property(
			world_shader_material, "shader_parameter/ShakeStrength", max_shake_strength, 0.01
		)
		. set_trans(Tween.TRANS_LINEAR)
		. set_delay(1.0)
	)  # <--- ADD THIS LINE FOR 1-SECOND DELAY

	# Then fade the shake out over the duration
	(
		shake_tween
		. tween_property(
			world_shader_material, "shader_parameter/ShakeStrength", 0.0, fade_out_time
		)
		. set_delay(0.01)
	)  # Hold max shake briefly

	# 5. Wait for the sequence to complete (Total wait: 1 second delay + 4 seconds duration)
	await get_tree().create_timer(1.0 + fade_out_time, true, false, true).timeout

	# 6. Transition Camera Back
	await CameraTransition.transition_camera(endgame_barrier_camera, ship_camera, 1.0)

	# 7. Unpause and Cleanup
	get_tree().paused = false


func _on_go_to_last_checkpoint(last_checkpoint_position: Vector2):
	await get_tree().create_timer(1.0).timeout
	ship_camera.position_smoothing_enabled = true
	ship_camera.position_smoothing_speed = 2.5
	ship.position = last_checkpoint_position
