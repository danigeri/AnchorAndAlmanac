extends Node2D

func _on_storm_trigger_body_entered(body: Node2D) -> void:
	print("endgame trigger")
	if body.is_in_group("player"):
		get_parent().enter_storm()


func _on_storm_out_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("endgame trigger off")
		get_parent().exit_storm()
