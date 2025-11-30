extends Node2D

signal endgame_barrier_destroy

var ship_camera: Camera2D
var endgame_barrier_camera: Camera2D
@onready var ship: CharacterBody2D = $Ship
@onready var endgame_barrier: Node2D = $EndgameBarrier
@onready var felho_of_war_container: Node2D = $FelhoOfWarContainer

@onready var starting_popup: Control = $StartingPopup



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
	await get_tree().create_timer(0.6).timeout
	get_tree().paused = true
	
	# 1. Start Camera Transition
	CameraTransition.transition_camera(ship_camera, endgame_barrier_camera)
	
	# 2. Fade OUT the felho container (after camera transition starts)
	# We create a tween that runs even while the game is paused
	var tween_out = create_tween()
	tween_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_out.tween_property(felho_of_war_container, "modulate:a", 0.0, 1.0) # Fades to alpha 0 over 1 second
	
	endgame_barrier_destroy.emit()
	
	await get_tree().create_timer(3).timeout
	
	# 3. Transition Camera Back
	CameraTransition.transition_camera(endgame_barrier_camera, ship_camera)
	
	# 4. Fade IN the felho container
	var tween_in = create_tween()
	tween_in.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_in.tween_property(felho_of_war_container, "modulate:a", 1.0, 1.0) # Fades to alpha 1 over 1 second

	await get_tree().create_timer(1).timeout
	get_tree().paused = false


func _on_go_to_last_checkpoint(last_checkpoint_position: Vector2):
	await get_tree().create_timer(1.0).timeout
	ship_camera.position_smoothing_enabled = true
	ship_camera.position_smoothing_speed = 2.5
	ship.position = last_checkpoint_position
