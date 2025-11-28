extends Node

signal checkpoint_collected(type: int)
signal all_checkpoints_collected
signal go_to_last_checkpoint(last_checkpoint_position: Vector2)

enum CheckpointType { FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH, SEVENTH }

#todo set starting position when map is built
var last_checkpoint_positon: Vector2 = Vector2(628, 355)

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
	print(current_hp)
	if current_hp == 0:
		go_to_last_checkpoint.emit(last_checkpoint_positon)


func restore_hp() -> void:
	current_hp = 3
