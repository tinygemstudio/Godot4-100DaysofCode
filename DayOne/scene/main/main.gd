extends Node


@export var _grace_space:int= 5
@export var _speed:float = 0
var _is_running:bool = false
var _screen_size:Vector2
var _dx:int = _speed
var _dy:int = _speed
var _radius:int = 52
var _target_pos:Vector2
var _event_pos:Vector2
var _distance:float
var _life_count:Array
var _score:int = 0
@onready var label: Label = $Label
@onready var control: Control = $Control
@onready var target: Node2D = $target
@onready var life:PackedScene = preload("res://scene/life/life.tscn")
#sound
const DEAD = preload("res://assets/dead.mp3")
const SCORE = preload("res://assets/score.mp3")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	set_process(false)
	#_start_game()

	
func _process(delta: float) -> void:
	target.position.x -= _dx
	target.position.y += _dy
	if (target.position.x-_radius) <0 or (target.position.x+_radius)>_screen_size.x:
		_dx *= -1
	if (target.position.y-_radius) <0 or (target.position.y+_radius)>_screen_size.y:
		_dy *= -1
func _input(event: InputEvent) -> void:
	if _is_running and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_target_pos = target.global_position
		_event_pos = event.global_position
		_distance = _event_pos.distance_to(_target_pos)
		if _distance <= _radius+_grace_space:
			_dx *= [1,-1].pick_random()
			_dy *=[ 1,-1].pick_random()
			audio_stream_player.stream = SCORE
			audio_stream_player.play()
			_score +=1
			label.text = str(_score)
		else:
			audio_stream_player.stream = DEAD
			audio_stream_player.play()
			var temp = _life_count.pop_front()
			temp.die()
			if _life_count.size() ==0:
				_is_running = false
				_speed = 0
				label.visible = false
				control.visible = true
				set_process(false)
	elif !_is_running and event is InputEventKey and event.keycode  == KEY_SPACE:
		_start_game()
			
		
	
func _on_window_size_changed()->void:
	_screen_size = get_viewport().get_visible_rect().size
	#this is so that target do not get lost on screen size changed
	var new_pos = Vector2(_screen_size.x/2,_screen_size.y/2)
	var tween = get_tree().create_tween()
	tween.tween_property(target, "position", new_pos, 0.4)
	_position_life_indicator(_life_count)

func _create_life_indicator()->void:
	for i in range(3):
		var n = life.instantiate()
		add_child(n)
		_life_count.append(n)
	_position_life_indicator(_life_count)
	
	
func _position_life_indicator(list:Array)->void:
	var set_x_pos:float = 150
	label.position = Vector2 (_screen_size.x/2, 50)
	for i in range(_life_count.size()):
		_life_count[i].position = Vector2((_screen_size.x - set_x_pos), 50)
		set_x_pos -=   50

func _reset_game()->void:
	_is_running = true
	_on_window_size_changed()
	_score = 0
	_create_life_indicator()
	
func _start_game()->void:
	set_process(true)
	_speed = 5
	_dx =5
	_dy = 5
	_is_running = true
	control.visible = false
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	_screen_size = get_viewport().get_visible_rect().size
	target.position = Vector2(_screen_size.x/2,_screen_size.y/2)
	label.text = "0"
	label.visible = true
	_create_life_indicator()
