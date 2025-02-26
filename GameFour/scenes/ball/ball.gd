extends RigidBody2D

enum BALL_STATE { READY, DRAG, RELEASE }

const DRAG_LIM_MAX: Vector2 = Vector2(10, 40)
const DRAG_LIM_MIN: Vector2 = Vector2(-120, -40)
const IMPULSE_MULT: float = 30.0
const IMPULSE_MAX: float = 1200.0

@onready var label: Label = $Label
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _state: BALL_STATE = BALL_STATE.READY
var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _last_dragged_vector: Vector2 = Vector2.ZERO


func _ready() -> void:
	if sleeping == false:
		sleeping = true
	GameManager.is_grabgrabable = true
	_start = position
	
	
func _physics_process(delta):
	_update(delta)
	label.text = "%s\n" % BALL_STATE.keys()[_state]
	label.text += "%.1f,%.1f" % [_dragged_vector.x, _dragged_vector.y]
	
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _state == BALL_STATE.READY and event.is_action_pressed("drag"):
		_set_new_state(BALL_STATE.DRAG)
		

func _set_new_state(new_state: BALL_STATE) -> void:
	_state = new_state
	if _state == BALL_STATE.RELEASE:
		_set_release()
	elif _state == BALL_STATE.DRAG:
		_set_drag()


func _set_drag()->void:
	_drag_start = get_global_mouse_position()


func _update_drag() -> void:
	if _detect_release() == true:
		return
	var gmp = get_global_mouse_position()
	_dragged_vector = _get_dragged_vector(gmp)
	_drag_in_limits()

func _update(_delta: float) -> void:
	match _state:
		BALL_STATE.DRAG:
			_update_drag()
		BALL_STATE.RELEASE:
			
			var cb = get_colliding_bodies()
			for c in cb:
				if c.name == "Floor":
					if sleeping == true:
						sleeping = false
						
					if linear_velocity.x < 30.0:
						die()
					
func _get_dragged_vector(gmp: Vector2) -> Vector2:
	return gmp - _drag_start


func _drag_in_limits() -> void:	
	_last_dragged_vector = _dragged_vector
	_dragged_vector.x = clampf(
		_dragged_vector.x,
		DRAG_LIM_MIN.x, 
		DRAG_LIM_MAX.x
	)
	_dragged_vector.y = clampf(
		_dragged_vector.y,
		DRAG_LIM_MIN.y, 
		DRAG_LIM_MAX.y
	)
	position = _start + _dragged_vector


func _detect_release() -> bool:
	if _state == BALL_STATE.DRAG:
		if Input.is_action_just_released("drag") == true:
			_set_new_state(BALL_STATE.RELEASE)
			GameManager.is_grabgrabable = false
			return true
	return false

func _set_release()->void:
	apply_central_impulse(get_impulse())


func get_impulse() -> Vector2:
	return _dragged_vector * -1 * IMPULSE_MULT


func die() -> void:
	
	cpu_particles_2d.emitting = true
	sprite_2d.visible = false
	audio_stream_player.play()
	var timer = get_tree().create_timer(0.12)
	GameManager.on_animal_died.emit()
	timer.timeout.connect(queue_free)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	die()
