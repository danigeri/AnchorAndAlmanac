extends Node

signal checkpoint_collected(type: int)
signal all_checkpoints_collected
signal go_to_last_checkpoint(last_checkpoint_position: Vector2)
signal hp_changed
signal wobble_toggle(on: bool)
signal last_audio_finsihed

enum CheckpointType { FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH, SEVENTH, EIGHT }

#todo set starting position when map is built
var last_checkpoint_positon: Vector2 = Vector2(628, 355)

# add 8th but camera pans on 7th
var collected_checkpoints := {
	CheckpointType.FIRST: false,
	CheckpointType.SECOND: false,
	CheckpointType.THIRD: false,
	CheckpointType.FOURTH: false,
	CheckpointType.FIFTH: false,
	CheckpointType.SIXTH: false,
	CheckpointType.SEVENTH: false,
	CheckpointType.EIGHT: true,
}

var current_hp: int = 3
var felho_counter: int = 0


func present_opening_subtitle() -> void:
	checkpoint_collected.emit(8)  # The subtitle index for the starting monlogue


func mark_collected(type: int, checkpoint_position: Vector2) -> void:
	collected_checkpoints[type] = true
	last_checkpoint_positon = checkpoint_position
	emit_signal("checkpoint_collected", type)
	print("checkpoint_to_collect", type)
	if type != CheckpointType.EIGHT:
		if are_all_checkpoints_collected():
			all_checkpoints_collected.emit()


func are_all_checkpoints_collected() -> bool:
	print(collected_checkpoints)
	for value in CheckpointType.values():
		if not collected_checkpoints[value]:
			return false
	return true


func remove_hp() -> void:
	current_hp -= 1
	if current_hp == 0:
		go_to_last_checkpoint.emit(last_checkpoint_positon)
	hp_changed.emit()

func instakill() -> void:
	current_hp = 0
	go_to_last_checkpoint.emit(last_checkpoint_positon)
	hp_changed.emit()



func restore_hp() -> void:
	current_hp = 3
	hp_changed.emit()


func emit_wobble_toggle(on: bool) -> void:
	emit_signal("wobble_toggle", on)
