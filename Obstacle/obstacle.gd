extends Node2D

@export var obstacle_texture: Texture2D
@onready var obstacle_image: Sprite2D = $ObstacleImage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	obstacle_image.texture = obstacle_texture
