extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func drop_barrel()-> void:
	animated_sprite_2d.show()
	animated_sprite_2d.play("default")
	await get_tree().create_timer(2.0).timeout
	animated_sprite_2d.hide()
