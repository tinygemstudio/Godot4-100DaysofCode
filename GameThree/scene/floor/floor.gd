extends Node2D

var floor_color:Color = Color.WHITE

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	var screen_size = get_viewport_rect().size
	var screen_width = screen_size.x

	draw_line(
		Vector2(0, 0),
		Vector2(screen_width, 0),
		floor_color,
		10,
		false
	)
