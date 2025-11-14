extends Label

# TODO: Optimization: Create an async update instead of sync
# TODO: Initialize local variables on _init
var _speed_mps : float = 0
var _sail_state : int = 0
var _wind := Vector3.ZERO

# TODO: remove vector from wind_vector because it is redundant
func _on_wind_update_wind(wind : Vector3) -> void:
	_wind = wind
	updateText()


func _on_ship_sail_state_change(sail_state: Variant) -> void:
	_sail_state = sail_state
	updateText()


func _on_ship_speed_change(speed: Variant) -> void:
	_speed_mps = speed
	updateText()


func updateText() -> void:
	text = "speed: %.1f m/s\nsail state: %d\nWind (%s, %s)" % \
			[_speed_mps, _sail_state, _wind.x, _wind.z]
