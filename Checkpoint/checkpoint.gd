extends Node2D

@export var landmark_texture: Texture2D
@export var landmark_type: Globals.LandmarkType
@onready var landmark: Sprite2D = $Area2D/Landmark
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	landmark.texture = landmark_texture


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.mark_collected(landmark_type, position)
		animation_player.play("pickup")


func remove_checkpont() -> void:
	queue_free()
