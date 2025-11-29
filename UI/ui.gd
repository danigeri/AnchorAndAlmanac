extends CanvasLayer

@export var player: CharacterBody2D
var _speed_mps: float = 0
var _sail_state: int = 0
var _steering_state: int = 0

@onready var debug_label: Label = $UserInterface/DebugPanel/MarginContainer/VBoxContainer/DebugLabel
@onready var questlog: Node2D = $Questlog
@onready var minimap: Node2D = $Minimap
@onready var minimap_icon: Sprite2D = $UserInterface/MinimapIcon
@onready var barrell: Sprite2D = $Barrell
@onready var barrell_2: Sprite2D = $Barrell2
@onready var barrell_3: Sprite2D = $Barrell3
@onready var subtitle: MarginContainer = $Subtitle


func _ready() -> void:
	## set to always so unpause is possible with InputEvent
	process_mode = Node.PROCESS_MODE_ALWAYS
	minimap.player = player
	Globals.hp_changed.connect(on_hp_changed)
	Globals.checkpoint_collected.connect(on_play_subtitle)
	

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
			"speed: %.1f m/s\nsail state: %d\nsteering state: %d\n felho: %d /3750"
			% [_speed_mps, _sail_state, _steering_state, Globals.felho_counter]
		)

func on_play_subtitle(checkpoint_text_number: int) -> void:
	print("play subtitle", checkpoint_text_number)
	subtitle.type_text(checkpoint_text_number)

func on_hp_changed() -> void:
	if Globals.current_hp < 3:
		barrell_3.hide()
	if Globals.current_hp < 2:
		barrell_2.hide()
	if Globals.current_hp < 1:
		barrell.hide()
	if Globals.current_hp == 3:
		barrell.show()
		barrell_2.show()
		barrell_3.show()
