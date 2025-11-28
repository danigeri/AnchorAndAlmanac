extends Node2D

@export var felho_texture : Texture2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var felho: Sprite2D = $Felho

func _ready() -> void:
	if felho_texture:
		felho.texture = felho_texture

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player")):
		animation_player.play("remove")
		
func remove_felho() -> void:
	queue_free()
