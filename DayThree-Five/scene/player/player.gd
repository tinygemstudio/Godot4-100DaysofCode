extends Area2D
const BULLET_SCENE = preload("res://scene/bullet/bullet.tscn")

@export var up_speed:int = 100
@export var down_speed:int = 50
var _init_y_pos:float
var _is_flying:bool
signal on_dead
var _stress:int = 8
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: CPUParticles2D = $jetsnow
@onready var footSNOW: CPUParticles2D = $AnimatedSprite2D/footsnow
@onready var deathparicles: CPUParticles2D = $deathparicles
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var ject_pack_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var bullethoder: Node2D = $bullethoder

func _ready() -> void:
	anim.play("walking")
	_is_flying = false
	footSNOW.emitting = true

func _process(delta: float) -> void:
	progress_bar.value -= delta * _stress
	if progress_bar.value <=0:
		game_over()
	if progress_bar.value > 100:
		progress_bar.value = 100
	var distance_from_init = abs(position.y - _init_y_pos)
	if Input.is_action_pressed("boost") and not distance_from_init >200:
		ject_pack_sound.play()
		_is_flying = true
		_stress = 16
		particles.emitting = true       
		footSNOW.emitting = false
		anim.play("flying")
		position.y -= up_speed*delta
		var bullet = BULLET_SCENE.instantiate()
		add_child(bullet)
		bullet.position = bullethoder.position
	elif (Input.is_action_just_released("boost") or distance_from_init >=200) and _is_flying==true:
		ject_pack_sound.stop()
		_is_flying = false
		_stress = 8 
		particles.emitting = false
		anim.play("landing")
	elif position.y <= _init_y_pos and not _is_flying:
		position.y += down_speed*delta
	else:
		anim.play("walking")
		_stress = 4 
		footSNOW.emitting = true
	
func set_p_y_pos(value:float):
	_init_y_pos = value
	
func game_over():
	audio_stream_player_2d.play()
	deathparicles.emitting = true
	on_dead.emit()
	queue_free()
