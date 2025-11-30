# ObstacleBase.gd
extends Node2D

@export var texture: Texture2D:
	set(value):
		$Sprite2D.texture = value

@export var collision_shape: Shape2D:
	set(value):
		$CollisionShape2D.shape = value
