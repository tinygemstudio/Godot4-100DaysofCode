extends Node2D

const CARD: PackedScene = preload("res://scenes/card/card.tscn")

const CARD_SIZE: Vector2 = Vector2(130, 202)
const CARD_SPACING: float = 20
var screen_size: Vector2
@onready var table: Panel = $"../Table"


func _ready() -> void:
	screen_size = get_viewport().size
	GameManager.player_deck = generate_countdown_numbers(8)
	GameManager.computer_deck = generate_countdown_numbers(8)
	#print(GameManager.computer_deck)
	create_cards()
	create_computer_cards()
	
func generate_countdown_numbers(card_count:int) -> Array:
	var large_numbers: Array = [25, 50]
	var small_numbers: Array = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10]
	var selected_numbers: Array = []
	
	# Ensure 1 or 2 large numbers (with higher probability for 1)
	var large_count: int = 1
	if randf() < 0.3:  # 30% chance to have 2 large numbers
		large_count = 2
	
	# Ensure we don't try to select more cards than are available
	large_count = min(large_count, card_count)
	
	# Select large numbers without repetition
	var available_large = large_numbers.duplicate()
	for i in range(large_count):
		var index = randi() % available_large.size()
		selected_numbers.append(available_large[index])
		available_large.remove_at(index)
	
	# Fill remaining slots with small numbers
	for i in range(card_count - large_count):
		var index = randi() % small_numbers.size()
		selected_numbers.append(small_numbers[index])
	
	# Shuffle the final selection
	selected_numbers.shuffle()
	return selected_numbers
	
# Card creation and positioning
func create_cards() -> void:
	var cards: int = GameManager.player_deck.size()
	for i: int in range(cards):
		var card: Node2D = CARD.instantiate()
		card.set_card_value(GameManager.player_deck[0])
		GameManager.player_deck.remove_at(0)
		GameManager.player_hand.insert(0, card)
		table.add_child(card)
	position_card()

func position_card() -> void:
	var cards: int = GameManager.player_hand.size()
	var start_x: float = calculate_start_x(cards)
	
	# Position cards at the bottom of the screen with 10px spacing from bottom
	var y_pos: float = table.size.y + 5
	
	for i: int in range(cards):
		var x_pos: float = start_x + (CARD_SIZE.x + CARD_SPACING) * i
		var new_pos:Vector2 = Vector2(x_pos, y_pos)
		
		# Use tween to animate the card to the new position
		animate_card_to_pos(GameManager.player_hand[i], new_pos)
		
		
		
# Card creation and positioning
func create_computer_cards() -> void:
	var cards: int = GameManager.computer_deck.size()
	for i: int in range(cards):
		var card: Node2D = CARD.instantiate()
		card.set_card_value(GameManager.computer_deck[0])
		card.set_is_player(false)
		GameManager.computer_deck.remove_at(0)
		GameManager.computer_hand.insert(0, card)
		table.add_child(card)
	position_computer_card()

func position_computer_card() -> void:
	var cards: int = GameManager.computer_hand.size()
	var start_x: float = calculate_start_x(cards)
	
	# Position cards at the bottom of the screen with 10px spacing from bottom
	var y_pos: float = -(CARD_SIZE.y + 5)
	
	for i: int in range(cards):
		var x_pos: float = start_x + (CARD_SIZE.x + CARD_SPACING) * i
		var new_pos:Vector2 = Vector2(x_pos, y_pos)
		
		# Use tween to animate the card to the new position
		animate_card_to_pos(GameManager.computer_hand[i], new_pos)

func calculate_start_x(total_slots: int) -> float:
	var total_width: float = (CARD_SIZE.x * total_slots) + (CARD_SPACING * (total_slots - 1))
	return (table.size.x - total_width) / 2

func animate_card_to_pos(card: Node2D, new_pos: Vector2) -> void:
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, 0.1)
