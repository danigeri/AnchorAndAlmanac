extends CanvasLayer

@export var player: CharacterBody2D
var _speed_mps: float = 0
var _sail_state: int = 0
var _steering_degrees: int = 0

@onready var debug_label: Label = $UserInterface/DebugPanel/MarginContainer/VBoxContainer/DebugLabel
@onready var questlog: Node2D = $Questlog
@onready var barrell: Sprite2D = $Barrell
@onready var barrell_2: Sprite2D = $Barrell2
@onready var barrell_3: Sprite2D = $Barrell3
@onready var subtitle: MarginContainer = $Subtitle
@onready var fps_label: Label = $UserInterface/DebugPanel/MarginContainer/VBoxContainer/fps_Label
@onready var fade_rect: ColorRect = $FadeRect



func _ready() -> void:

	Globals.hp_changed.connect(on_hp_changed)
	Globals.checkpoint_collected.connect(on_play_subtitle)
	fade_rect.color.a = 0.0  # Start fully transparent


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			show_quest_log()
		if event.is_action_pressed("ui_cancel"): # disable esc key
			pass


func _on_ship_sail_state_change(sail_state: Variant) -> void:
	_sail_state = sail_state
	update_text()


func _on_ship_speed_change(speed: Variant) -> void:
	_speed_mps = speed
	update_text()


func _on_ship_steering_degrees_change(steering_degrees: Variant) -> void:
	_steering_degrees = steering_degrees
	update_text()


func update_text() -> void:
	if debug_label:
		debug_label.text = (
			"speed: %.1f m/s\nsail state: %d\nsteering degrees: %d\n felho: %d /3750"
			% [_speed_mps, _sail_state, _steering_degrees, Globals.felho_counter]
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


func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())


func _on_check_button_toggled(toggled_on: bool) -> void:
	Globals.emit_wobble_toggle(toggled_on)


func _on_complete_all_pressed() -> void:
	Globals.all_checkpoints_collected.emit()
	pass  # Replace with function body.
	
func fade_out_to_black(duration: float = 2.0) -> void:
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "color:a", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
	# Optional: do something after fade completes
	tween.connect("finished", Callable(self, "_on_fade_complete"))

func fade_out() -> void:
	fade_out_to_black(2.0)
	
func _on_fade_complete() -> void:
	# Reload the scene or go to end screen
	get_tree().reload_current_scene()


func show_quest_log() -> void:
	questlog.visible = !questlog.visible
	get_tree().paused = questlog.visible

func _on_button_pressed() -> void:
	questlog.visible = !questlog.visible
	get_tree().paused = questlog.visible


func _on_starting_popup_intro_finished() -> void:
	## set to always so unpause is possible with InputEvent
	process_mode = Node.PROCESS_MODE_ALWAYS
