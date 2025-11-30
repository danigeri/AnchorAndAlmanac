extends Node2D

@onready var texture: TextureRect = $CanvasLayer/ImagePopup/TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture.modulate.a = 0
	fade_in()


func fade_in():
	show()
	var tween = create_tween()
	tween.tween_property(texture, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_IN_OUT)

func fade_out():
	var tween = create_tween()
	tween.tween_property(texture, "modulate:a", 0.0, 0.3)
	hide()
