extends Area2D


var _speed:float = randf_range(100,150)
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_stream_player_2d_2: AudioStreamPlayer2D = $AudioStreamPlayer2D2

func _process(delta: float) -> void:
	position.x -= _speed * delta
	if position.x < -100:
		game_over()

func set_speed(value:float)->void:
	_speed = value


func game_over():
	cpu_particles_2d.emitting = true
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		audio_stream_player_2d.stop()
		audio_stream_player_2d_2.play()
		cpu_particles_2d.emitting = true
		await get_tree().create_timer(0.1).timeout
		area.game_over()
		queue_free()
	if area.is_in_group("heart"):
		area.queue_free()

func get_destroyed()->void:
	audio_stream_player_2d.stop()
	audio_stream_player_2d_2.play()
	cpu_particles_2d.emitting = true
	await get_tree().create_timer(0.1).timeout
	queue_free()
