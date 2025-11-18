extends Node2D

@onready var questlog_item: Sprite2D = $QuestlogItem
@onready var questlog_item_2: Sprite2D = $QuestlogItem2
@onready var questlog_item_3: Sprite2D = $QuestlogItem3
@onready var questlog_item_4: Sprite2D = $QuestlogItem4
@onready var questlog_item_5: Sprite2D = $QuestlogItem5
@onready var questlog_item_6: Sprite2D = $QuestlogItem6


func _ready() -> void:
	Globals.checkpoint_collected.connect(show_questlog_item)


func show_questlog_item(checkpoint_number: int) -> void:
	print(checkpoint_number)
	match checkpoint_number:
		0:
			questlog_item.show()
		1:
			questlog_item_2.show()
		2:
			questlog_item_3.show()
		3:
			questlog_item_4.show()
		4:
			questlog_item_5.show()
		5:
			questlog_item_6.show()
