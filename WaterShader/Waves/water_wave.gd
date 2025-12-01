extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

# List all wave image paths
const WAVE_TEXTURES := [
	"res://WaterShader/Waves/wave_blue_1.png",
	"res://WaterShader/Waves/wave_blue_2.png",
	"res://WaterShader/Waves/wave_blue_3.png",
	"res://WaterShader/Waves/wave_blue_5.png",
	"res://WaterShader/Waves/wave_blue_6.png",
	"res://WaterShader/Waves/wave_blue_7.png",
	"res://WaterShader/Waves/wave_blue_8.png",
	"res://WaterShader/Waves/wave_white_1.png",
	"res://WaterShader/Waves/wave_white_2.png",
	"res://WaterShader/Waves/wave_white_3.png",
	"res://WaterShader/Waves/wave_white_4.png",
	"res://WaterShader/Waves/wave_white_5.png",
	"res://WaterShader/Waves/wave_white_6.png",
	"res://WaterShader/Waves/wave_white_7.png",
	"res://WaterShader/Waves/wave_white_8.png",
]

func _ready() -> void:
	# Pick a random texture
	var random_path = WAVE_TEXTURES.pick_random()
	var random_texture: Texture2D = load(random_path)
	sprite_2d.texture = random_texture

	# Play wobble if enabled
	if Globals.wave_wobble:
		animation_player.play("wobble")
