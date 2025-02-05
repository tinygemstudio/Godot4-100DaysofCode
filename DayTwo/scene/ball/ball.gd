extends Area2D

var _speed:int = 250
var _dx:int = [-1, 1].pick_random()
var _dy:int = 1
signal on_dead(value:bool)

func _process(delta: float) -> void:
	position.x += _dx*_speed*delta
	position .y -= _dy*_speed*delta



func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.WHITE)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("wall"):
		_dy *= -1
	if area.is_in_group("paddle"):
		_dx *=  -1
		_dy *=  [-1, 1].pick_random()
	if area.is_in_group("death"):
		on_dead.emit(true)
		queue_free()
	if area.is_in_group("c_death"):
		on_dead.emit(false)
		queue_free()
		
func increase_speed()->void:
	_speed += 50
