extends Node2D

@export var player: CharacterBody2D
@onready var camera_2d: Camera2D = $CanvasLayer/SubViewportContainer/SubViewport/Camera2D
@onready var sub_viewport: SubViewport = $CanvasLayer/SubViewportContainer/SubViewport

func _ready():
	sub_viewport.world_2d = get_world_2d()
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _process(_delta):
	if player:
		camera_2d.global_position = player.global_position
