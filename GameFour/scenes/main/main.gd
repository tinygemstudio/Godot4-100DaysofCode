extends Node2D

const BALL:PackedScene = preload("res://scenes/ball/ball.tscn")

var _this_ball:RigidBody2D
var _ball_start_pos:Vector2
var _rope_stretch:Vector2
var _r1_point1:Vector2
var _r2_point1:Vector2
var ball_in_group:Array
var nodes_in_group :Array

@onready var ball_box: Marker2D = $Slingshot/BallBox
@onready var rope_1: Line2D = $Slingshot/rope1
@onready var rope_2: Line2D = $Slingshot/rope2
@onready var panel: Panel = $Panel
@onready var stretchsound: AudioStreamPlayer = $stretchsound


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()

func _ready() -> void:
	_create_and_position_bird()
	GameManager.on_animal_died.connect(_create_and_position_bird)
	_r1_point1 = rope_1.get_point_position(1) - Vector2(35,0)
	_r2_point1 = rope_1.get_point_position(1) - Vector2(35,0)
	panel.visible = false

func _process(_delta: float) -> void:
	ball_in_group = get_tree().get_nodes_in_group("ball")
	_this_ball = get_tree().get_first_node_in_group("ball")
	nodes_in_group = get_tree().get_nodes_in_group("woodblock")
	if _this_ball:
		if Input.is_action_pressed("drag") and GameManager.is_grabgrabable:
			_rope_stretch  = _ball_start_pos - _this_ball.position
			rope_1.set_point_position(1, _r1_point1 - _rope_stretch)
			rope_2.set_point_position(1, _r2_point1 - _rope_stretch)
			stretchsound.play()
			if rope_2.z_index !=20:
				rope_2.z_index = 20
	if Input.is_action_just_released("drag"):
		rope_1.set_point_position(1, _r1_point1)
		rope_2.set_point_position(1, _r2_point1)
		rope_2.z_index = 0
		stretchsound.stop()
	
	if nodes_in_group.size() == 0 and not panel.visible:
		panel.visible = true
		
func _create_and_position_bird()->void:
	nodes_in_group = get_tree().get_nodes_in_group("woodblock")
	
	for node in nodes_in_group:
		if  node.rotation > deg_to_rad(-1) and node.rotation < deg_to_rad(1):
			if ball_in_group.size() > 1:
				return
			var b: RigidBody2D = BALL.instantiate()
			b.position = ball_box.position
			_ball_start_pos = ball_box.position
			b.rotation = ball_box.rotation
			add_child(b)
			return
	
	panel.visible = true


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
