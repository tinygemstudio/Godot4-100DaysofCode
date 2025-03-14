extends Node2D

var player_cards: int = 0
var computer_cards: int = 0
var is_game_ended: bool = false
var attepmts:int
@onready var card_manager: Node2D = $"../CardManager"
@onready var input_manager: Node2D = $"../InputManager"
@onready var game_over_panel: Panel = $"../GameOverPanel"
@onready var game_over_label: Label = $"../GameOverPanel/Label"
@onready var bgmusic: AudioStreamPlayer = $"../bgmusic"


func _ready() -> void:
	attepmts = 0
	GameManager.start_next_round.connect(start_round)
	GameManager.on_player_victory.connect(on_player_win)
	GameManager.on_player_defeat.connect(on_player_defeat)
	GameManager.player_ready_to_battle_r2.connect(start_fight)
	GameManager.on_draw.connect(on_draw)
	
	# Connect reset button if it exists
	
func start_round() -> void:
	if is_game_ended == false:
		if attepmts > 20:
			GameManager.on_draw.emit()
			return
		attepmts += 1
		#print(attepmts)
		for slot in get_tree().get_nodes_in_group("p_battlefild"):
			slot.set_slot_vlaue(0)
		for slot in get_tree().get_nodes_in_group("c_battlefild"):
			slot.set_slot_vlaue(0)
		GameManager.is_player_ready_to_move = true
		
		GameManager.computer_deck.clear()
		GameManager.player_deck.clear()
		player_cards = 0
		computer_cards = 0
		
		var battlefild_slots: Array = get_tree().get_nodes_in_group("battlefild")
		for battlefild_slot in battlefild_slots:
			if battlefild_slot.get_slot_owner() == "player":
				player_cards += 1
			elif battlefild_slot.get_slot_owner() == "computer":
				computer_cards += 1
			else:
				pass
				
		if player_cards > 0 :
			#var remaining_space = 8 - GameManager.player_hand.size()
			#var actual_add = min(player_cards, remaining_space)
			GameManager.player_deck = card_manager.generate_countdown_numbers(player_cards)
		if computer_cards > 0:
			#var remaining_space = 8 - GameManager.computer_hand.size()
			#var actual_add = min(computer_cards, remaining_space)
			GameManager.computer_deck = card_manager.generate_countdown_numbers(computer_cards)
			#print(GameManager.computer_deck)
			
		card_manager.create_cards()
		card_manager.create_computer_cards()
		
		var com_battle_slots: Array = get_tree().get_nodes_in_group("c_battlefild")
		for slot in com_battle_slots:
			slot.set_slot_occupied(false)
			
		var p_battle_slots: Array = get_tree().get_nodes_in_group("p_battlefild")
		for slot in p_battle_slots:
			slot.set_slot_occupied(false)


func start_fight()->void:
	GameManager.is_player_ready_to_move = false
	await get_tree().create_timer(1).timeout
	input_manager._on_move_to_com_battle_second_round()

func on_player_win():
	#print("win")
	bgmusic.stop()
	is_game_ended = true
	game_over_panel.visible = true
	game_over_label.text = "You Win!"
	
	
func on_player_defeat():
	#print("defeat")
	bgmusic.stop()
	is_game_ended = true
	game_over_panel.visible = true
	game_over_label.text = "You Lost!"
	
func on_draw():
	#print("draw")
	bgmusic.stop()
	is_game_ended = true
	game_over_panel.visible = true
	game_over_label.text = "Attempts Exceeded"
