extends CanvasLayer

var _speed_mps: float = 0
var _sail_state: int = 0
@onready var checkpoint_counter: Label = $UserInterface/CheckpointCounter
@onready var debug_label: Label = $UserInterface/DebugPanel/MarginContainer/VBoxContainer/DebugLabel
@onready var questlog: Node2D = $Questlog


func _ready() -> void:
	Globals.checkpoint_collected.connect(_on_checkpoint_collected)
	
func _on_checkpoint_collected(_type: int) -> void:
	## temp code to show collected checkpoints on the UI
	var collected_names = ""
	for landmark_enum in Globals.collected_landmarks.keys():
		if Globals.collected_landmarks[landmark_enum]:
			collected_names += str(landmark_enum) + ", "
	checkpoint_counter.text = (
		"Landmarks collected: " + collected_names.substr(0, collected_names.length() - 2)
	)


func _on_ship_sail_state_change(sail_state: Variant) -> void:
	_sail_state = sail_state
	update_text()


func _on_ship_speed_change(speed: Variant) -> void:
	_speed_mps = speed
	update_text()


func update_text() -> void:
	if debug_label:
		debug_label.text = ("speed: %.1f m/s\nsail state: %d" % [_speed_mps, _sail_state])


func _on_questlog_button_pressed() -> void:
	questlog.visible = !questlog.visible
	get_tree().paused = questlog.visible
