extends Node

signal checkpoint_collected(type: int)
signal all_checkpoints_collected
signal go_to_last_checkpoint(last_checkpoint_position: Vector2)

enum LandmarkType { FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH }

#todo set starting position when map is built
var last_checkpoint_positon: Vector2 = Vector2(628, 355)

var collected_landmarks := {
	LandmarkType.FIRST: false,
	LandmarkType.SECOND: false,
	LandmarkType.THIRD: false,
	LandmarkType.FOURTH: false,
	LandmarkType.FIFTH: false,
	LandmarkType.SIXTH: false
}

var current_hp: int = 3


func mark_collected(type: int, checkpoint_position: Vector2) -> void:
	if not collected_landmarks[type]:
		collected_landmarks[type] = true
		last_checkpoint_positon = checkpoint_position
		print("last checkpoint positon: ", last_checkpoint_positon)
		emit_signal("checkpoint_collected", type)

		if are_all_checkpoints_collected():
			all_checkpoints_collected.emit()


func are_all_checkpoints_collected() -> bool:
	for value in LandmarkType.values():
		if not collected_landmarks[value]:
			return false
	return true


func remove_hp() -> void:
	current_hp -= 1
	print(current_hp)
	if current_hp == 0:
		go_to_last_checkpoint.emit(last_checkpoint_positon)


func restore_hp() -> void:
	current_hp = 3
