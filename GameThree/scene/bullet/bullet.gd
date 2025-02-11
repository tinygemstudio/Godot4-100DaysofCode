extends Node2D


func _process(delta: float) -> void:
	position.y += 1000*delta
	await get_tree().create_timer(0.05).timeout
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("obs"):
		area.get_destroyed()
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.progress_bar.value += 10
