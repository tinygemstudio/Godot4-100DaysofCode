extends Node2D

var is_player:bool = true
var card_level:int = 1
var is_selected:bool = false
var card_value:int = 0
var my_slot:Node2D = null
var card_slot_no:int

@onready var area_2d: Area2D = $Area2D
@onready var card_face: Sprite2D = $CardFace
@onready var card_back: Sprite2D = $CardBack
@onready var selected: Sprite2D = $Selected
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var label: Label = $CardFace/Label
@onready var debuglabel: Label = $debuglabel

func _ready() -> void:
	
	set_card_level(1)
	set_label_text()
	card_face.scale.x = 1.02
	card_back.scale.x = 1.02
	if is_player:
		card_face.visible = true
		card_back.visible = false
		set_col_shape(false)
	else :
		card_face.visible = false
		card_back.visible = true
		set_col_shape(true)
		
		
func set_label_text()->void:
	label.text = str(card_value)
	debuglabel.text = str(card_value)
func toggle_collision(value:bool)->void:
	collision_shape_2d.disabled = value
	
func set_is_player(value:bool)->void:
	is_player = value

func get_is_player()->bool:
	return is_player

func set_col_shape(value:bool)->void:
	collision_shape_2d.disabled = value


func toggle_selection(value:bool)->void:
	selected.visible = value
	if value:
		card_face.scale = Vector2(1.08,1.08)
		selected.scale =Vector2(1.07136,1.08)
		#label.size = Vector2(1.05,1.05)
	else :
		card_face.scale = Vector2(1.02,1)
		selected.scale =Vector2(0.992,1)
		#label.size = Vector2(1.0,1.0)

func get_col_mask()->int:
	return area_2d.collision_mask
	
func  set_card_level(value:int)->void:
	card_level = value

func  get_card_level()->int:
	return card_level

func set_card_value(value:int)->void:
	card_value = value

func get_card_value()->int:
	return card_value
	
func set_my_slot(value:Node2D)->void:
	my_slot = value
	
func get_my_slot()->Node2D:
	return my_slot

func flip_card()->void:
	card_back.visible = false
	card_face.visible = true

func set_card_slot_no(value:int)->void:
	card_slot_no = value

func get_card_slot_no()->int:
	return card_slot_no
