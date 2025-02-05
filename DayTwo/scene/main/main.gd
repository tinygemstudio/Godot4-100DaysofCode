extends Control

const PADDLE:PackedScene = preload("res://scene/paddle/paddle.tscn")
const BALL:PackedScene = preload("res://scene/ball/ball.tscn")

var _screen_size:Vector2
var _color:Color = Color.BLACK
var _paddles:Array  =[]

var _is_running:bool = false
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var panel: Panel = $Panel
@onready var win_text: Label = $Panel/Label4

func _ready() -> void:
	_screen_size = get_viewport_rect().size

func _draw() -> void:
	draw_line(Vector2(_screen_size.x/2,0), Vector2(_screen_size.x/2,_screen_size.y),_color, 1, true)

func _input(event: InputEvent) -> void:
	if not _is_running and event is InputEventKey and event.keycode  == KEY_SPACE:
		_is_running = true
		_start_game()
		
func _start_game()->void:
	panel.visible = false
	_create_and_position_paddle()
	_color= Color.WHITE
	queue_redraw()


func _create_and_position_paddle()->void:
	var player_pos:Vector2 = Vector2(20 ,_screen_size.y/2)
	var computer_pos:Vector2 = Vector2(_screen_size.x - 20 ,_screen_size.y/2)
	var b = BALL.instantiate()
	add_child(b)
	b.position=Vector2(_screen_size.x/2 ,_screen_size.y/2)
	b.on_dead.connect(_game_over)
	var p = PADDLE.instantiate()
	_paddles.append(p)
	var c = PADDLE.instantiate()
	_paddles.append(c)
	add_child(p)
	add_child(c)
	p.position = player_pos
	p.is_player =true
	c.position = computer_pos
	
	
func _game_over(value:bool)->void:
	audio_stream_player.play()
	if value:
		win_text.text = "Computer Wins"
	else:
		win_text.text = "Player Wins"
	panel.visible = true
	set_process(false)
	for paddle in _paddles:
		if paddle !=null:
			paddle.game_over()
	_color= Color.BLACK
	queue_redraw()
	_reset_game()


func _reset_game()->void:
	_is_running = false
