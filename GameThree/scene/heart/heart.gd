extends Node2D

var _speed:int = randf_range(150,200)

func _draw():
	var heart_points = [
		Vector2(0, -5),      # Top center dip
		Vector2(-3.75, -7.5),  # Left top curve
		Vector2(-7.5, -3.75),  # Left side
		Vector2(-5, 5),     # Bottom left
		Vector2(0, 7.5),    # Bottom point
		Vector2(5, 5),      # Bottom right
		Vector2(7.5, -3.75),  # Right side
		Vector2(3.75, -7.5),  # Right top curve
	]

	
	var heart_color = Color.BLACK
	draw_polygon(heart_points, [heart_color])

func _process(delta: float) -> void:
	position.x -= _speed * delta
	if position.x < -100:
		queue_free()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		area.progress_bar.value += 50
		queue_free()
	if area.is_in_group("obs"):
		pass
