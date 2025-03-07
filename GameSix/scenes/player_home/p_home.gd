extends Node2D
@onready var player_home: Area2D = $PlayerHomeArea
@onready var collision_shape_2d: CollisionShape2D = $PlayerHomeArea/CollisionShape2D

func get_col_mask()->int:
	return player_home.collision_mask

func toggle_collision(value:bool)->void:
	collision_shape_2d.disabled = value
