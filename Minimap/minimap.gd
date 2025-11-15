extends Node2D

@export var player: CharacterBody2D
@onready var minimap_camera: Camera2D = $CanvasLayer/SubViewportContainer/SubViewport/MinimapCamera

func _process(_delta: float) -> void:
	if(player):
		minimap_camera.position = player.position
