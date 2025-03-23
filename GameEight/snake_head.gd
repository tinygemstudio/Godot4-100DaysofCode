extends Node2D


@onready var snake_speed_timer: Timer = $SnakeSpeedTimer
var velocity:Vector2 = Vector2.ZERO
var move_dir:Vector2 = Vector2(1,0)
var _going_up:bool = false
var _going_down:bool = false
var _going_right:bool = true
var _going_left:bool = false

func _on_snake_speed_timer_timeout() -> void:
	print("here")
	#_movement()


func _input(_event: InputEvent) -> void:
	
	if Input.is_action_pressed("right"):
		if not _going_left:
			velocity.x = 1
			velocity.y = 0
			_going_left = false
			_going_right =true
			_going_up = false
			_going_down =false
	if Input.is_action_pressed("left"):
		if not _going_right:
			velocity.x = -1
			velocity.y = 0
			_going_left = true
			_going_right =false
			_going_up = false
			_going_down =false
	if Input.is_action_pressed("down"):
		if not _going_up:
			velocity.x = 0
			velocity.y = 1
			_going_left = false
			_going_right =false
			_going_up = false
			_going_down =true
	if Input.is_action_pressed("up"):
		if not _going_down:
			velocity.x = 0
			velocity.y = -1
			_going_left = false
			_going_right =false
			_going_up = false
			_going_down =true
			
	if velocity.length() > 0:
		move_dir = velocity.normalized()


func _movement()->void:
	position += move_dir*Vector2(16,16)
