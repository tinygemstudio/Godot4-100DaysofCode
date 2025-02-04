extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _draw() -> void:
	
	draw_circle(
		Vector2.ZERO,
		20,
		Color.RED
	)

func die():
	queue_free()
