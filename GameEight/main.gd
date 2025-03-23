extends Node2D

const SNAKE_HEAD = preload("res://snake_head.tscn")
const SNAKE_BODY = preload("res://snake_body.tscn")


func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("quit"):
		get_tree().quit()


func _ready() -> void:
	var s:Node2D = SNAKE_HEAD.instantiate()
	s.position = get_viewport_rect().size/2
	add_child(s)
	
func _create_body()->void:
	var b:Node2D = SNAKE_BODY.instantiate()
	
