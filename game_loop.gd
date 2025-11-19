extends Node2D

signal endgame_barrier_destroy

var ship_camera: Camera2D
var endgame_barrier_camera: Camera2D
@onready var ship: CharacterBody2D = $Ship
@onready var endgame_barrier: Node2D = $EndgameBarrier
@onready var fog_of_war: Node2D = $FogOfWar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.all_checkpoints_collected.connect(_on_all_checkpoints_collected)
	ship_camera = ship.get_camera()
	endgame_barrier_camera = endgame_barrier.get_camera()


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	fog_of_war.hide()
	CameraTransition.transition_camera(ship_camera, endgame_barrier_camera)
	endgame_barrier_destroy.emit()
	await get_tree().create_timer(3).timeout
	CameraTransition.transition_camera(endgame_barrier_camera, ship_camera)
	fog_of_war.show()
	await get_tree().create_timer(1).timeout
	get_tree().paused = false
