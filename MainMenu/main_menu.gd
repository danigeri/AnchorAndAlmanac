extends Control


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game_loop.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game_loop.tscn")
