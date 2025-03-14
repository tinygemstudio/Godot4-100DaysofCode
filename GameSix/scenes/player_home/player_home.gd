extends Node2D
@onready var player_home: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func get_col_mask()->int:
	return player_home.collision_mask

func toggle_collision(value:bool)->void:
	collision_shape_2d.disabled = value
