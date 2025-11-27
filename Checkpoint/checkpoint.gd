extends Node2D

@export var checkpoint_texture: Texture2D
@export var checkpoint_type: Globals.CheckpointType
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var checkpoint: Sprite2D = $Area2D/Checkpoint


func _ready() -> void:
	if checkpoint_texture:
		checkpoint.texture = checkpoint_texture


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.mark_collected(checkpoint_type, position)
		animation_player.play("pickup")


func remove_checkpont() -> void:
	queue_free()
