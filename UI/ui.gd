extends CanvasLayer

var _speed_mps: float = 0
var _sail_state: int = 0
var _steering_state: int = 0
@onready var debug_label: Label = $UserInterface/DebugPanel/MarginContainer/VBoxContainer/DebugLabel
@onready var questlog: Node2D = $Questlog
@onready var minimap: Node2D = $Minimap
@onready var minimap_icon: Sprite2D = $UserInterface/MinimapIcon


func _ready() -> void:
	## set to always so unpause is possible with InputEvent
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			questlog.visible = !questlog.visible
			get_tree().paused = questlog.visible
		if event.keycode == KEY_M:
			minimap.visible = !minimap.visible
			minimap_icon.visible = !minimap_icon.visible


func _on_ship_sail_state_change(sail_state: Variant) -> void:
	_sail_state = sail_state
	update_text()


func _on_ship_speed_change(speed: Variant) -> void:
	_speed_mps = speed
	update_text()


func _on_ship_steering_state_change(steering_state: Variant) -> void:
	_steering_state = steering_state
	update_text()


func update_text() -> void:
	if debug_label:
		debug_label.text = (
			"speed: %.1f m/s\nsail state: %d\nsteering state: %d"
			% [_speed_mps, _sail_state, _steering_state]
		)
