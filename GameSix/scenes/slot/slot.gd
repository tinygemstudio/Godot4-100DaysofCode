extends Node2D

var is_occupied:bool = false
var slot_value:int = 0
var is_player_owner:bool = false
var is_computer_owner:bool = false

@onready var green: Sprite2D = $green
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	slot_value = 0
	
func get_slot_value()->int:
	return slot_value
	
func set_slot_vlaue(value:int)->void:
	slot_value = value

func set_col_mask(value:int)->void:
	area_2d.set_collision_mask(value)
	area_2d.set_collision_layer(value)

func get_col_mask()->int:
	return area_2d.collision_mask
	

func set_col_shape(value:bool)->void:
	collision_shape_2d.disabled = value



func set_slot_occupied(value:bool)->void:
	is_occupied = value

func get_slot_occupied()->bool:
	return is_occupied
	
func toggle_highlight(value:bool)->void:
	green.visible  = value

func set_slot_owner(value:String)->void:
	if value =="player":
		is_player_owner = true
		is_computer_owner = false
	else:
		is_computer_owner = true
		is_player_owner  = false
