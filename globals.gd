extends Node

signal checkpoint_collected(type: int)
signal all_checkpoints_collected

enum LandmarkType { FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH }

var last_checkpoint_positon: Vector2

var collected_landmarks := {
	LandmarkType.FIRST: false,
	LandmarkType.SECOND: false,
	LandmarkType.THIRD: false,
	LandmarkType.FOURTH: false,
	LandmarkType.FIFTH: false,
	LandmarkType.SIXTH: false
}

func mark_collected(type: int, checkpoint_position: Vector2) -> void:
	if not collected_landmarks[type]:
		collected_landmarks[type] = true
		last_checkpoint_positon = checkpoint_position
		print("collected checkpoints: ", collected_landmarks)
		print("last checkpoint positon: ", last_checkpoint_positon)
		emit_signal("checkpoint_collected", type)
		if are_all_checkpoints_collected():
			all_checkpoints_collected.emit()


func are_all_checkpoints_collected() -> bool:
	for value in LandmarkType.values():
		if not collected_landmarks[value]:
			return false
	return true
