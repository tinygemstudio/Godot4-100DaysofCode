extends Node

signal coumputer_ready_to_battle
signal player_ready_to_battle
signal player_ready_to_battle_r2
signal start_next_round
signal on_player_victory
signal on_player_defeat
signal on_draw
signal on_game_over(value)


var player_deck: Array = []
var player_hand: Array = []
var player_battle_hand: Array = []

var computer_deck: Array = []
var computer_hand: Array = []
var computer_battle_hand: Array = []
var battle_field: Array = []

var is_round_started: bool = false
var is_player_ready_to_move:bool = true
var is_game_over:bool = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("quit"):
		get_tree().quit()
