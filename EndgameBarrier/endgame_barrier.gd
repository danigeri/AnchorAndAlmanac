extends Node2D

@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	## set to always so barrier animation is possible while paused
	process_mode = Node.PROCESS_MODE_ALWAYS


func remove_barrier() -> void:
	static_body_2d.queue_free()
	Globals.last_checkpoint_positon = position


func get_camera() -> Camera2D:
	return camera_2d


func _on_game_loop_endgame_barrier_destroy() -> void:
	await get_tree().create_timer(1).timeout
	animation_player.play("destroy")
	audio_stream_player.play()
