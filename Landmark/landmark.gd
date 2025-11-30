extends Node2D

@export var landmark_audio: AudioStream
@export var landmark_texture: Texture2D

@onready var landmark_sound: AudioStreamPlayer2D = $LandmarkSound
@onready var landmark_picture: Sprite2D = $LandmarkPicture


func _ready() -> void:
	if landmark_audio:
		landmark_sound.stream = landmark_audio
		landmark_sound.play(0.0)
	if landmark_texture:
		landmark_picture.texture = landmark_texture


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("felho"):
		var felho_scene = area.get_parent()
		felho_scene.remove_felho()
