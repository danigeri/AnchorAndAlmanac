extends Control

@onready var audio_player = $MarginContainer/AspectRatioContainer/VideoStreamPlayer/AudioStreamPlayer2D
@onready var video_player = $MarginContainer/AspectRatioContainer/VideoStreamPlayer


func _ready() -> void:
	var is_debug: bool = OS.is_debug_build()
	if is_debug:
		call_deferred("go_to_main_menu")
	else:
		video_player.play()
		video_player.paused = true
		await get_tree().create_timer(2.0).timeout
		video_player.paused = false
		audio_player.play()


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	go_to_main_menu()
	pass


func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn")
