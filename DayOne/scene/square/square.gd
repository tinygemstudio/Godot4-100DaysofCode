extends Node2D


func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	
	#draw face circle = draw_circle(center, radius, color)
	draw_circle(
		Vector2.ZERO,
		52,
		Color.YELLOW
	)
	
	#draw eyes
	draw_circle(
		Vector2(-15,-10),
		10,
		Color.BLACK
	)
	draw_circle(
		Vector2(15,-10),
		10,
		Color.BLACK
	)
	
	#draw nose = draw_line(from, to, color, width, antialiased)
	draw_line(
		Vector2(0,2),
		Vector2(0,22),
		Color.BLACK,
		10,
		true
	)
	
	#draw smile= half circle = arc
	#draw_arc(center, radius, start_angle, end_angle, points, color, width)
	draw_arc(
		Vector2(0,25),
		20,
		deg_to_rad(0),
		deg_to_rad(180),
		100,
		Color.BLACK,
		10
	)
	
	#draw hair = line
	for i in range(-10,20,10):
		draw_line(
			Vector2(i,-52),
			Vector2(i*-1,-82),
			Color.BLACK,
			5,
			true
		)
