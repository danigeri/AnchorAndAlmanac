extends Node2D

var last_boat_pos: Vector2
var fog_image: Image
var vision_image: Image
var world_position: Vector2

@onready var fog: Sprite2D = $Fog
@onready var temp_ground: Sprite2D = $TempGround
@onready var temp_boat: CharacterBody2D = $TempBoat
@onready var fog_texture := ImageTexture.new()


func _process(_delta):
	if temp_boat.global_position.distance_squared_to(last_boat_pos) > 1:
		update_fog()
		last_boat_pos = temp_boat.global_position


func _ready() -> void:
	generate_fog()
	update_fog()


func generate_fog():
	var world_dimension = Vector2(3000, 3000)
	world_position = Vector2(3000, 3000)

	fog_image = Image.create(world_dimension.x, world_dimension.y, false, Image.Format.FORMAT_RGBAH)
	fog_image.fill(Color.BLACK)
	fog_texture = ImageTexture.create_from_image(fog_image)
	fog.texture = fog_texture
	vision_image = temp_boat.vision.texture.get_image()
	vision_image.convert(Image.Format.FORMAT_RGBAH)
	var vision_scale = Vector2(vision_image.get_size()) * 5
	vision_image.resize(vision_scale.x, vision_scale.y)


func update_fog() -> void:
	var vision_rect = Rect2(Vector2.ZERO, vision_image.get_size())
	fog_image.blend_rect(
		vision_image, vision_rect, temp_boat.global_position - Vector2(vision_image.get_size() / 2)
	)
	fog_texture.update(fog_image)
	fog.texture = fog_texture
