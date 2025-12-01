# ObstacleBase.gd
extends Node2D

@export var texture: Texture2D:
	set(value):
		$Sprite2D.texture = value

@export var collision_shape: Shape2D:
	set(value):
		$CollisionShape2D.shape = value

@export var sound: AudioStream
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var wobble: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var obstacle_image: Sprite2D = $ObstacleImage

var animal_sounds := {
	1:preload("uid://dobib2vet26rp"),
	2:preload("uid://cp7qb0jhr6mdt"),
	3:preload("uid://du3bqhsexn77a"),
	4:preload("uid://d3njeqgfcxhg")
}

func _ready() -> void:
	if sound:
		audio_stream_player_2d.stream = sound
	if obstacle_image.texture:
		if "allat" in str(obstacle_image.texture.resource_path):
			wobble = true
	if wobble:
		animation_player.play("new_animation")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		audio_stream_player_2d.stream = (animal_sounds[randi_range(1,4)])
