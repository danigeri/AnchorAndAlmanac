extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("connect to signal")
	Globals.checkpoint_collected.connect(_on_checkpoint_collected)


func _on_checkpoint_collected(_type: int) -> void:
	print("call check")
	is_checkpoints_collected()
	
func is_checkpoints_collected() -> bool:
	if (Globals.all_checkpoints_collected() == true):
		print("all checkpoints collected")
		return true
	else: 
		print("1 or more checkpoints are not collected yet")
		return false
