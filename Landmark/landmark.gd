extends Node2D

@export var landmark_audio : AudioStream
@export var landmark_texture: Texture2D

@onready var landmark_sound: AudioStreamPlayer2D = $LandmarkSound
@onready var landmark_picture: Sprite2D = $LandmarkPicture

func _ready() -> void:
	if landmark_audio:
		landmark_sound.stream = landmark_audio
		landmark_sound.play(0.0)
	if landmark_texture:
		landmark_picture.texture = landmark_texture
