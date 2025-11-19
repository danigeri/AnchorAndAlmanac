extends Node2D

@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func remove_barrier() -> void:
	static_body_2d.queue_free()


func get_camera() -> Camera2D:
	return camera_2d


func _on_game_loop_endgame_barrier_destroy() -> void:
	print("destroy anim start")
	await get_tree().create_timer(1).timeout
	animation_player.play("destroy")
