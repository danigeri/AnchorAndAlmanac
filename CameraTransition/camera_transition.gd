extends Node

@onready var camera2D: Camera2D = $Camera2D

var transitioning: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var viewport_size = get_viewport().get_visible_rect().size
	camera2D.global_position = viewport_size / 2

func transition_camera2D(from: Camera2D, to: Camera2D, duration: float = 1.0) -> void:
	if transitioning:
		return

	# Copy camera parameters from the first camera
	camera2D.zoom = from.zoom
	camera2D.offset = from.offset
	camera2D.light_mask = from.light_mask

	# Move transition camera to the starting camera's position
	camera2D.global_transform = from.global_transform

	# Make this camera the active runtime camera
	camera2D.make_current()

	transitioning = true

	# Create a new tween (Godot 4.x way)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Tween properties
	tween.tween_property(camera2D, "global_transform", to.global_transform, duration)
	tween.parallel().tween_property(camera2D, "zoom", to.zoom, duration)
	tween.parallel().tween_property(camera2D, "offset", to.offset, duration)

	# Wait until the tween finishes
	await tween.finished

	# Make the target camera current
	to.make_current()

	transitioning = false
