extends Node2D

const PLAYER_SCENE = preload("res://scene/player/player.tscn")
const OBS_SCENE = preload("res://scene/obs/obs.tscn")
const HEART_SCENE = preload("res://scene/heart/heart.tscn")
var chang_color:bool = true
var _start_time = 0
var _elapsed_time = 0
var _is_game_active = false
var _screen_size:Vector2
var _high_score:int
var dn_color:Array
var sun_color:Color
@onready var welcome: Control = $welcome
@onready var timer: Timer = $Timer
@onready var heart_timer: Timer = $heartTimer
@onready var scorelabel: Label = $scorelabel
@onready var highscorelabel: Label = $welcome/Panel/highscorelabel
@onready var instext: Label = $welcome/Panel/instext
@onready var gamefloor: Node2D = $floor

func _ready() -> void:
	_screen_size = get_viewport_rect().size
	sun_color = Color.WHITE
	dn_color= [Color.WHITE, Color.WHITE, Color.BLACK]
	_high_score = ScoreManager.get_high_score()
	highscorelabel.text = "BEST ATTEMPT %dm" %_high_score
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
		
func _process(_delta: float) -> void:
	queue_redraw()
	if _is_game_active:
		_elapsed_time = (Time.get_ticks_msec() - _start_time) / 2000.0
		_elapsed_time = floor(_elapsed_time)
		scorelabel.text = "%dm" % _elapsed_time

func _draw() -> void:
	var screen_width = _screen_size.x
	var screen_height = _screen_size.y
	var circle_center =  Vector2(screen_width / 2, 50)
	var circle_radius = 10
	var points:Array = [
		Vector2(0, screen_height),
		Vector2(screen_width, screen_height),
		Vector2(screen_width / 2, 50)
	]

	 

	draw_polygon(points, dn_color)
	draw_circle(circle_center, circle_radius, sun_color)



func _start_game() ->void:
	_start_time = 0
	_elapsed_time = 0
	scorelabel.text = "%dm" % _elapsed_time
	dn_color= [Color.WHITE, Color.WHITE, Color.BLACK]
	sun_color = Color.BLACK
	gamefloor.floor_color = Color.WHITE
	RenderingServer.set_default_clear_color(Color.WHITE)
	welcome.visible = false
	scorelabel.visible = true
	_start_time = Time.get_ticks_msec()
	_is_game_active = true
	_create_and_postion_plaeyr()
	timer.start(randi_range(1,4))
	#heart_timer.start(randi_range(3,5))
	set_process(true)
	
func _create_and_postion_plaeyr()->void:
	var p = PLAYER_SCENE.instantiate()
	add_child(p)
	p.position = Vector2(34, _screen_size.y-17)
	p.set_p_y_pos(p.position.y)
	p.on_dead.connect(_game_over)
	

func _create_and_postion_obs()->void:
	var o = OBS_SCENE.instantiate()
	add_child(o)
	o.position = Vector2(_screen_size.x+10, randi_range(20,_screen_size.y-20))


func _create_and_postion_hearts()->void:
	var h = HEART_SCENE.instantiate()
	add_child(h)
	h.position = Vector2(_screen_size.x+10, randi_range(20,60))


func _game_over():
	welcome.visible = true
	scorelabel.visible = false
	_handle_score()
	highscorelabel.text = "BEST ATTEMPT %dm" %_high_score
	
	timer.stop()
	heart_timer.stop()
	var obs = get_tree().get_nodes_in_group("obs")
	for ob in obs:
		ob.queue_free()
	var hearts = get_tree().get_nodes_in_group("heart")
	for h in hearts:
		h.queue_free()
	set_process(false)
	

func _handle_score()-> void:
	
	instext.text = "YOUR ATTEMPT "+str(_elapsed_time)+"m"
	if _elapsed_time > _high_score:
		ScoreManager.save_high_score(_elapsed_time)
		_high_score = ScoreManager.get_high_score()


func _on_button_pressed() -> void:
	_start_game()


func _on_timer_timeout() -> void:
	_create_and_postion_obs()


func _on_heart_timer_timeout() -> void:
	_create_and_postion_hearts()
