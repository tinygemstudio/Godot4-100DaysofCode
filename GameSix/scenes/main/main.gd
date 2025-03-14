extends Node2D

var MAINUI:PackedScene = load("res://scenes/mainui/mainui.tscn")
var is_round_one:bool = true

@onready var card_manager: Node2D = $CardManager
@onready var input_manager: Node2D = $InputManager
@onready var next_round_manager: Node2D = $Next_round_manager
@onready var battle_bar: CanvasLayer = $BattleBar
@onready var button: Button = $Button
@onready var done_button: Button = $DoneButton
@onready var info_label: Label = $InfoLabel
@onready var bgmusic: AudioStreamPlayer = $bgmusic
@onready var buttonsound: AudioStreamPlayer = $buttonsound


func _ready() -> void:
	is_round_one= true
	info_label.text = "1-Put cards in 1st row.\n 2-Stacking cards boosts power.\n3-Control middle row to win\n4-ESC to quit."
	GameManager.coumputer_ready_to_battle.connect(ready_round)
	bgmusic.play()
	
	
func ready_round()->void:
	await get_tree().create_timer(0.8).timeout
	button.visible = true
	info_label.text = "Press Start to Battle"

func _on_button_pressed() -> void:
	
	if GameManager.is_round_started  == false:
		buttonsound.play()
		button.visible = false
		GameManager.is_round_started = true
		var size:int = GameManager.computer_battle_hand.size()
		for i:int in range(size-1, -1, -1):
			GameManager.computer_battle_hand[i].flip_card()
			await get_tree().create_timer(0.25).timeout
		
		battle()

func _on_done_button_pressed() -> void:
	done_button.visible = false
	if GameManager.is_game_over == false:
		buttonsound.play()
		if is_round_one:
			GameManager.player_ready_to_battle.emit()
			is_round_one = false
		else:
			GameManager.player_ready_to_battle_r2.emit()

		



func battle() -> void:
	var battle_slots: Array = get_tree().get_nodes_in_group("battlefild")
	
	# Loop through slots first
	for slot_idx: int in range(battle_slots.size()):
		var slot_position: Vector2 = battle_slots[slot_idx].global_position
		var current_slot = battle_slots[slot_idx]
		var player_card_value: int = 0
		var computer_card_value: int = 0
		var slot_owner: String = current_slot.get_slot_owner()
		var fight_cards: Array = []
		
		# Apply existing slot values based on owner
		if slot_owner == "player":
			player_card_value += current_slot.get_slot_value()
		elif slot_owner == "computer":
			computer_card_value += current_slot.get_slot_value()
		
		# Find player card for this slot (safely)
		var player_card = null
		var player_cards_to_remove = []
		for card in GameManager.player_battle_hand:
			if card.get_card_slot_no() == slot_idx:
				player_card = card
				player_cards_to_remove.append(card)
				player_card_value += card.get_card_value()
				animate_card_to_pos(card, slot_position)
				fight_cards.append(card)
				break  # Only process one card per slot
		
		# Find computer card for this slot (safely)
		var computer_card = null
		var computer_cards_to_remove = []
		for card in GameManager.computer_battle_hand:
			if card.get_card_slot_no() == slot_idx:
				computer_card = card
				computer_cards_to_remove.append(card)
				computer_card_value += card.get_card_value()
				animate_card_to_pos(card, slot_position)
				fight_cards.append(card)
				break  # Only process one card per slot
		
		# Remove the cards we processed (safely outside the loop)
		for card in player_cards_to_remove:
			GameManager.player_battle_hand.erase(card)
		
		for card in computer_cards_to_remove:
			GameManager.computer_battle_hand.erase(card)
		
		await get_tree().create_timer(0.25).timeout
		
		# Determine winner and update slot
		if player_card_value == computer_card_value:
			current_slot.playerowner.visible = false
			current_slot.computerowner.visible = false
			current_slot.set_slot_owner("none")
			current_slot.set_slot_vlaue(0)
			for fight_card in fight_cards:
				fight_card.queue_free()
		elif player_card_value > computer_card_value:
			current_slot.set_slot_owner("player")
			current_slot.playerowner.visible = true
			current_slot.computerowner.visible = false
			var diff_value = player_card_value - computer_card_value
			current_slot.player_label.text = str(diff_value)
			current_slot.set_slot_vlaue(diff_value)
			for fight_card in fight_cards:
				fight_card.queue_free()
		elif player_card_value < computer_card_value:
			current_slot.set_slot_owner("computer")
			current_slot.playerowner.visible = false
			current_slot.computerowner.visible = true
			var diff_value = computer_card_value - player_card_value
			current_slot.computer_label.text = str(diff_value)
			current_slot.set_slot_vlaue(diff_value)
			for fight_card in fight_cards:
				fight_card.queue_free()

	start_next_round()
		
func start_next_round()->void:
	info_label.text = "Simply repeat steps"
	done_button.visible = true
	GameManager.is_round_started = false
	battle_bar.hide_progress_bar_cover()
	GameManager.start_next_round.emit()
	
	
func animate_card_to_pos(card: Node2D, new_pos: Vector2) -> void:
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", new_pos, 0.1)


func _on_quit_button_pressed() -> void:
	#get_tree().quit()
	pass


func _on_restart_button_pressed() -> void:
	#get_tree().change_scene_to_packed(MAINUI)
	pass
