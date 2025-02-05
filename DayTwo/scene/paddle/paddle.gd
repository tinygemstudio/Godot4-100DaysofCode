extends Area2D

const COLOR:Color = Color.WHITE

var _x:int = 10
var _y:int = 70
var _rect:Rect2 = Rect2(-5, -35, _x, _y)
var is_player:bool = false
var _temp_pos:float
@export var _speed:float = 500
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _draw() -> void:
	_rect= Rect2(-5, -35, _x, _y)
	collision_shape_2d.shape.size.x = _x
	collision_shape_2d.shape.size.y = _y
	draw_rect(_rect,COLOR,true)
	

func _process(delta: float) -> void:
	_temp_pos = get_tree().get_root().size.y-35
	if is_player:
		if Input.is_action_pressed("up") and position.y > 35:
			position.y -= _speed*delta
		if Input.is_action_pressed("down"):
			
			if position.y < _temp_pos:
				position.y += _speed*delta
	else:
		var ball = get_parent().get_node("ball")
		if ball:
			if ball.position.x > get_viewport().size.x/2:
				if position.y > 35 or position.y < _temp_pos:
					position.y = lerp(position.y, ball.position.y, 0.1)
			
					
func game_over()->void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ball"):
		audio_stream_player_2d.play()
		area.increase_speed()
