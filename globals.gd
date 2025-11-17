extends Node

signal checkpoint_collected(type: int)

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
		print("collected checkpoints: ",collected_landmarks)
		print("last checkpoint positon: ", last_checkpoint_positon)
		are_all_checkpoints_collected()
		## later can be used for UI updates and checkpoint related tasks like ship journey dialog
		emit_signal("checkpoint_collected", type)


func all_checkpoints_collected() -> bool:
	for value in LandmarkType.values():
		if not collected_landmarks[value]:
			return false
	return true

func are_all_checkpoints_collected() -> bool:
	if all_checkpoints_collected() == true:
		print("all checkpoints collected")
		return true
	print("1 or more checkpoints are not collected yet")
	return false
