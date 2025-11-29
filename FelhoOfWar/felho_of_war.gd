extends Node2D

@export var felho_texture: Texture2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var felho: Sprite2D = $Felho


func _ready() -> void:
	if felho_texture:
		felho.texture = felho_texture
	#await get_tree().create_timer(randf_range(0.6,1.2)).timeout
	#animation_player.play("wobble")
func remove_felho() -> void:
	Globals.felho_counter = Globals.felho_counter + 1
	animation_player.play("remove")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "remove":
		queue_free()
