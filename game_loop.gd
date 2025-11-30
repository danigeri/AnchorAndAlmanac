extends Node2D

signal endgame_barrier_destroy

var ship_camera: Camera2D
var endgame_barrier_camera: Camera2D

@onready var ship: CharacterBody2D = $Ship
@onready var endgame_barrier: Node2D = $EndgameBarrier
@onready var felho_of_war_container: Node2D = $FelhoOfWarContainer
@onready var starting_popup: Control = $StartingPopup
@onready var world_shader_material: ShaderMaterial = $CanvasLayer/VignetteFilter.material as ShaderMaterial

# Storm control variables
var is_storm_active: bool = false
var current_storm_value: float = 0.0
@export var storm_transition_speed: float = 1.0

func _ready() -> void:
	Globals.all_checkpoints_collected.connect(_on_all_checkpoints_collected)
	Globals.go_to_last_checkpoint.connect(_on_go_to_last_checkpoint)
	ship_camera = ship.get_camera()
	endgame_barrier_camera = endgame_barrier.get_camera()
	
	# Initialize storm mode to 0
	if world_shader_material:
		world_shader_material.set_shader_parameter("storm_mode", 0.0)
	
	# starting_popup.start()
	
	enter_storm()

func _process(delta: float) -> void:
	# Smoothly transition storm mode
	if world_shader_material:
		var target = 1.0 if is_storm_active else 0.0
		current_storm_value = lerp(current_storm_value, target, storm_transition_speed * delta)
		world_shader_material.set_shader_parameter("storm_mode", current_storm_value)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		# Debug key to test storm (optional - remove in production)
		if event.keycode == KEY_T:
			toggle_storm()

# ===== STORM CONTROL METHODS =====

func enter_storm():
	"""Call this when the boat enters a storm zone"""
	is_storm_active = true
	ship.enter_storm()

func exit_storm():
	"""Call this when the boat leaves a storm zone"""
	is_storm_active = false
	ship.exit_storm()

func toggle_storm():
	"""Toggle storm on/off (useful for testing)"""
	is_storm_active = !is_storm_active

func set_storm_instant(active: bool):
	"""Instantly set storm without transition"""
	is_storm_active = active
	current_storm_value = 1.0 if active else 0.0
	if world_shader_material:
		world_shader_material.set_shader_parameter("storm_mode", current_storm_value)

# Optional: Customize storm parameters
func set_storm_intensity(darkness: float = 0.5, lightning_freq: float = 2.0, lightning_intensity: float = 3.0):
	"""Adjust storm appearance on the fly"""
	if world_shader_material:
		world_shader_material.set_shader_parameter("storm_darkness", darkness)
		world_shader_material.set_shader_parameter("lightning_frequency", lightning_freq)
		world_shader_material.set_shader_parameter("lightning_intensity", lightning_intensity)

# ===== EXISTING METHODS =====

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
	var max_shake_strength: float = 1.0
	var fade_out_time = 3.0
	
	shake_tween.tween_property(world_shader_material, "shader_parameter/ShakeStrength", max_shake_strength, 0.01) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_delay(1.0)
	
	# Then fade the shake out over the duration
	shake_tween.tween_property(world_shader_material, "shader_parameter/ShakeStrength", 0.0, fade_out_time) \
		.set_delay(0.01)
	
	# 5. Wait for the sequence to complete
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
