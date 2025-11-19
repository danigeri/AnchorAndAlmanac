extends Node

var transitioning: bool = false
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	## set to always so camera movement is possible while paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	var viewport_size = get_viewport().get_visible_rect().size
	camera.global_position = viewport_size / 2


func transition_camera(from: Camera2D, to: Camera2D, duration: float = 1.0) -> void:
	if transitioning:
		return

	# Copy camera parameters from the first camera
	camera.zoom = from.zoom
	camera.offset = from.offset
	camera.light_mask = from.light_mask

	# Move transition camera to the starting camera's position
	camera.global_transform = from.global_transform

	# Make this camera the active runtime camera
	camera.make_current()

	transitioning = true

	# Create a new tween (Godot 4.x way)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Tween properties
	tween.tween_property(camera, "global_transform", to.global_transform, duration)
	tween.parallel().tween_property(camera, "zoom", to.zoom, duration)
	tween.parallel().tween_property(camera, "offset", to.offset, duration)

	# Wait until the tween finishes
	await tween.finished

	# Make the target camera current
	to.make_current()

	transitioning = false
