extends Node

signal checkpoint_collected(type: int)
signal all_checkpoints_collected
signal go_to_last_checkpoint(last_checkpoint_position: Vector2)
signal hp_changed

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
	CheckpointType.SEVENTH: false
}

var current_hp: int = 3
var felho_counter: int = 0

func present_opening_subtitle() -> void:
	checkpoint_collected.emit(8) # The subtitle index for the starting monlogue
	

func mark_collected(type: int, checkpoint_position: Vector2) -> void:
	if not collected_checkpoints[type]:
		collected_checkpoints[type] = true
		last_checkpoint_positon = checkpoint_position
		print("last checkpoint positon: ", last_checkpoint_positon)
		emit_signal("checkpoint_collected", type)

		if are_all_checkpoints_collected():
			all_checkpoints_collected.emit()


func are_all_checkpoints_collected() -> bool:
	for value in CheckpointType.values():
		if not collected_checkpoints[value]:
			return false
	return true


func remove_hp() -> void:
	current_hp -= 1
	if current_hp == 0:
		go_to_last_checkpoint.emit(last_checkpoint_positon)
	hp_changed.emit()


func restore_hp() -> void:
	current_hp = 3
	hp_changed.emit()
