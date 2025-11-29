extends Node

signal update_wind(direction, power)

enum Directions { N, NE, E, SE, S, SW, W, NW }

const DIRECTION_ARRAY: Array[float] = [
	WIND_DIRECTION[Directions.E],
	WIND_DIRECTION[Directions.SE],
	WIND_DIRECTION[Directions.S],
	WIND_DIRECTION[Directions.SW],
	WIND_DIRECTION[Directions.W],
	WIND_DIRECTION[Directions.NW],
	WIND_DIRECTION[Directions.N],
	WIND_DIRECTION[Directions.NE]
]

const WIND_DIRECTION = {
	Directions.N: -PI / 2,
	Directions.NE: -PI / 4,
	Directions.E: 0.0,
	Directions.SE: PI / 4,
	Directions.S: PI / 2,
	Directions.SW: 3 * PI / 2,
	Directions.W: PI,
	Directions.NW: -3 * PI / 2,
}

@export var direction_idx: int = 0
@export var strength = 10

var wind_change_time_frequency = 25


func _ready() -> void:
	update_wind.emit(DIRECTION_ARRAY[0], strength)
	create_wind_timer()


func create_wind_timer():
	var timer := Timer.new()
	timer.wait_time = wind_change_time_frequency
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)

	timer.timeout.connect(_on_wind_change)


func _on_wind_change():
	var change = 1 if randi() % 2 == 0 else -1
	direction_idx = (direction_idx + change) % DIRECTION_ARRAY.size()
	var direction = DIRECTION_ARRAY[direction_idx]
	update_wind.emit(direction, strength)
