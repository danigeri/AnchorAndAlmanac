extends Node2D

signal endgame_barrier_destroy

var ship_camera: Camera2D
var endgame_barrier_camera: Camera2D

@onready var ship: CharacterBody2D = $Ship
@onready var endgame_barrier: Node2D = $EndgameBarrier
@onready var felho_of_war_container: Node2D = $FelhoOfWarContainer
@onready var starting_popup: Control = $UI/StartingPopup
@onready
var world_shader_material: ShaderMaterial = $CanvasLayer/VignetteFilter.material as ShaderMaterial
@onready var base_music_player: AudioStreamPlayer = $BaseMusicPlayer
@onready var ui: CanvasLayer = $UI

@onready var storm_trigger_area: CollisionPolygon2D = $EndGameStuff/StormTrigger/CollisionPolygon2D

@onready var challange_music_player: AudioStreamPlayer = $EndGameStuff/ChallangeMusicPlayer


# Storm control variables
var is_storm_active: bool = false
var current_storm_value: float = 0.0
@export var storm_transition_speed: float = 1.0

@export var idle_music: AudioStream
@onready var wave_atmo_storm = $EndGameStuff/WaveAtmoStorm
@onready var wind_atmo_storm = $EndGameStuff/WindAtmoStorm

@onready var wave_default: AudioStreamPlayer = $WaveDefault

const lightning_sounds := {
	1: preload("uid://c4fbkv12ogdbm"),
	2: preload("uid://bp61l4eutnbux")
}

@onready var lightning_player: AudioStreamPlayer = $EndGameStuff/LightningPlayer

var lightning_loop_running := false
@export var lightning_min_delay := 6.0
@export var lightning_max_delay := 8.0

func _lightning_loop() -> void:
	lightning_loop_running = true

	while is_storm_active:
		var delay = randf_range(lightning_min_delay, lightning_max_delay)
		await get_tree().create_timer(delay).timeout

		# Storm ended mid-wait → exit safely
		if !is_storm_active:
			break

		# Pick random lightning sound
		var keys = lightning_sounds.keys()
		var random_key = keys[randi() % keys.size()]
		lightning_player.stream = lightning_sounds[random_key]

		lightning_player.play()

	lightning_loop_running = false


func _ready() -> void:
	Globals.all_checkpoints_collected.connect(_on_all_checkpoints_collected)
	Globals.go_to_last_checkpoint.connect(_on_go_to_last_checkpoint)
	Globals.last_audio_finsihed.connect(_on_last_audio_finished)
	ship_camera = ship.get_camera()
	endgame_barrier_camera = endgame_barrier.get_camera()
	base_music_player.play()
	# Initialize storm mode to 0
	if world_shader_material:
		world_shader_material.set_shader_parameter("storm_mode", 0.0)

	starting_popup.start()
	
	storm_trigger_area.disabled = true
	#enter_storm()
	#exit_storm()
	#base_music_player.stop()


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


# ===== STORM CONTROL METHODS =====


func enter_storm():
	"""Call this when the boat enters a storm zone"""
	is_storm_active = true
	ship.enter_storm()
	base_music_player.stop()
	challange_music_player.play()
	wave_atmo_storm.play()
	wind_atmo_storm.play()
	wave_default.stop()
	
	if !lightning_loop_running:
		_lightning_loop()
	


func exit_storm():
	"""Call this when the boat leaves a storm zone"""
	is_storm_active = false
	ship.exit_storm()
	challange_music_player.stop()
	wave_atmo_storm.stop()
	wind_atmo_storm.stop()
	



func set_storm_instant(active: bool):
	"""Instantly set storm without transition"""
	is_storm_active = active
	current_storm_value = 1.0 if active else 0.0
	if world_shader_material:
		world_shader_material.set_shader_parameter("storm_mode", current_storm_value)


# Optional: Customize storm parameters
func set_storm_intensity(
	darkness: float = 0.5, lightning_freq: float = 2.0, lightning_intensity: float = 3.0
):
	"""Adjust storm appearance on the fly"""
	if world_shader_material:
		world_shader_material.set_shader_parameter("storm_darkness", darkness)
		world_shader_material.set_shader_parameter("lightning_frequency", lightning_freq)
		world_shader_material.set_shader_parameter("lightning_intensity", lightning_intensity)


# ===== EXISTING METHODS =====


func _on_all_checkpoints_collected():
	trigger_barrier_remove()
	#enter_storm() #TODO ezt majd rendes helyre tenni
	storm_trigger_area.disabled = false
	

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

func _on_last_audio_finished() -> void:
	ui.fade_out()
	pass


func _on_storm_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		enter_storm()


func _on_storm_out_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		exit_storm()
