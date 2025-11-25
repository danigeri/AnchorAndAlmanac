extends Node2D

@export var temp_boat: CharacterBody2D

var last_boat_pos: Vector2
var fog_image: Image
var vision_image: Image
var vision_size: int = 12
var update_interval: float = 1
var time_since_last_update: float = 0.0
@onready var fog: Sprite2D = $Fog
@onready var fog_texture := ImageTexture.new()
@onready var vision: Sprite2D = %Vision


func _process(delta):
	time_since_last_update += delta
	if time_since_last_update >= update_interval:
		update_fog()
		update_interval = randf_range(0.2, 0.5)
		last_boat_pos = temp_boat.global_position
		time_since_last_update = 0.0


func _ready() -> void:
	generate_fog()
	update_fog()


func generate_fog():
	var world_dimension = Vector2(5000, 5000)

	fog_image = Image.create(world_dimension.x, world_dimension.y, false, Image.Format.FORMAT_RGBAH)
	fog_image.fill(Color.BLACK)
	fog_texture = ImageTexture.create_from_image(fog_image)
	fog.texture = fog_texture
	vision_image = vision.texture.get_image()
	vision_image.convert(Image.Format.FORMAT_RGBAH)
	var vision_scale = Vector2(vision_image.get_size()) * vision_size
	vision_image.resize(vision_scale.x, vision_scale.y)


func update_fog() -> void:
	var vision_rect = Rect2(Vector2.ZERO, vision_image.get_size())
	fog_image.blend_rect(
		vision_image, vision_rect, temp_boat.global_position - Vector2(vision_image.get_size() / 2)
	)
	fog_texture.update(fog_image)
	fog.texture = fog_texture
