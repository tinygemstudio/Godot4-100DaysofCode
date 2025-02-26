extends RigidBody2D

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var wood_sprite: Sprite2D = $WoodSprite
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _physics_process(_delta: float) -> void:
	if rotation < deg_to_rad(1):
		return
	if rotation > deg_to_rad(88) and rotation < deg_to_rad(91):
		return
	wood_sprite.visible = false
	#position = Vector2(-1000,-1000)
	cpu_particles_2d.emitting = true
	audio_stream_player.play()
	var timer = get_tree().create_timer(0.12)
	timer.timeout.connect(audio_stream_player.stop)
	timer.timeout.connect(queue_free)


func _on_body_entered(_body: Node) -> void:
	if rotation > deg_to_rad(88) and rotation < deg_to_rad(91):
		cpu_particles_2d.emitting = true
		wood_sprite.visible = false
		#position = Vector2(-1000,-1000)
		cpu_particles_2d.emitting = true
		audio_stream_player.play()
		var timer = get_tree().create_timer(0.12)
		timer.timeout.connect(audio_stream_player.stop)
		timer.timeout.connect(queue_free)
