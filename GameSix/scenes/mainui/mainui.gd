extends Control

var main_scene:PackedScene = load("res://scenes/main/main.tscn")
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)
