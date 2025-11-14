extends Node

signal update_wind(wind)

@export var windStrength = 5
@export var windDirection = Vector2(1, 0)

func _ready() -> void:
	# TODO: strength and direction should be merged into the wind vector
	update_wind.emit(windDirection * windStrength)