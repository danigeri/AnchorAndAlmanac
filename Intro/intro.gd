extends Control

@onready var audio_player = $AspectRatioContainer/VideoStreamPlayer/AudioStreamPlayer2D
@onready var video_player = $AspectRatioContainer/VideoStreamPlayer


func _ready() -> void:
	video_player.play()
	video_player.paused = true


func _on_timer_timeout() -> void:
	video_player.paused = false
	audio_player.play()


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
