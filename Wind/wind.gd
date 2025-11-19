extends Node

signal update_wind(direction, power)

@export var direction = Vector2.RIGHT
@export var strength = 50
var wind_change_time_frequency = 15


func _ready() -> void:
	update_wind.emit(direction, strength)
	create_wind_timer()


func create_wind_timer():
	var timer := Timer.new()
	timer.wait_time = wind_change_time_frequency
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)

	timer.timeout.connect(_on_wind_change)


func _on_wind_change():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	strength = randi_range(10, 100)

	# @todo: This should change incrementally
	update_wind.emit(direction, strength)
