extends Node

signal update_wind(direction, power)

@export var direction = Vector2.RIGHT
@export var strength = 50

@onready var timer: Timer = $Timer


func _ready() -> void:
	update_wind.emit(direction, strength)
	update_wind.emit(direction, strength)
	timer.timeout.connect(_on_wind_change)


func _on_wind_change():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	strength = randi_range(10, 100)

	# @todo: This should change incrementally
	update_wind.emit(direction, strength)
