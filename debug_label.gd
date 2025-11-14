extends Label

# TODO: Optimization: Create an async update instead of sync
# TODO: Initialize local variables on _init
var _speed_mps: float = 0
var _sail_state: int = 0


func _on_ship_sail_state_change(sail_state: Variant) -> void:
	_sail_state = sail_state
	update_text()


func _on_ship_speed_change(speed: Variant) -> void:
	_speed_mps = speed
	update_text()


func update_text() -> void:
	text = (
		"speed: %.1f m/s\nsail state: %d"
		% [_speed_mps, _sail_state]
	)
