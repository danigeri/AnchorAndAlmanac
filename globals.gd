extends Node

signal checkpoint_collected(type: int)

enum LandmarkType { FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH }

var collected_landmarks := {
	LandmarkType.FIRST: false,
	LandmarkType.SECOND: false,
	LandmarkType.THIRD: false,
	LandmarkType.FOURTH: false,
	LandmarkType.FIFTH: false,
	LandmarkType.SIXTH: false
}


func mark_collected(type: int) -> void:
	if not collected_landmarks[type]:
		collected_landmarks[type] = true
		print(collected_landmarks)
		## later can be used for UI updates and checkpoint related tasks like ship journey dialog
		emit_signal("checkpoint_collected", type)

func all_checkpoints_collected() -> bool:
	for value in LandmarkType.values():
		if not collected_landmarks[value]:
			return false
	return true
