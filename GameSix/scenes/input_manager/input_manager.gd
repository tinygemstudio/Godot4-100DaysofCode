extends Node2D

const CARD_COL_MASK: int = 32
const BATTLE_SLOT_COL_MASKS: int = 3
const SLOT_COL_MASKS: int = 2
const PLAYER_HOME_COL_MASK: int = 1


var current_card: Node2D
var is_selected: bool = false

@onready var card_manager: Node2D = $"../CardManager"
@onready var button: Button = $"../Button"


func  _ready() -> void:
	GameManager.player_ready_to_battle.connect(on_player_ready_to_battle)

func on_player_ready_to_battle()->void:
	GameManager.is_player_ready_to_move = false
	_on_move_to_com_battle_timeout()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if GameManager.is_player_ready_to_move:
				raycast_check_at_cursor()
			
			
# Card selection and movement
func raycast_check_at_cursor() -> void:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	
	var result: Array[Dictionary] = space_state.intersect_point(parameters)
	if result.size() > 0:
		var obj_found: Node2D = get_top_card(result)
		card_movement_controller(obj_found)
	else:
		cancel_movement()


func get_top_card(cards: Array[Dictionary]) -> Node2D:
	var top_card: Node2D = cards[0].collider.get_parent()
	var top_z_index: int = top_card.z_index

	for i: int in range(1, cards.size()):
		var this_card: Node2D = cards[i].collider.get_parent()
		if this_card.z_index > top_z_index:
			top_card = this_card
			top_z_index = this_card.z_index
	return top_card


func cancel_movement() -> void:
	if is_selected:
		current_card.toggle_selection(false)
		current_card = null
		is_selected = false
		reset_all_slots()


func reset_all_slots() -> void:
	var other_nodes: Array = get_tree().get_nodes_in_group("p_battlefild")
	for nodes: Node2D in other_nodes:
		nodes.set_slot_occupied(false)
		nodes.toggle_highlight(false)


func get_collision_mask(obj: Node2D) -> int:
	var col_mask: int = 0
	if obj.has_method("get_col_mask"):
		col_mask = obj.get_col_mask()
	elif "collision_mask" in obj:
		col_mask = obj.collision_mask
	return col_mask



func card_movement_controller(obj: Node2D) -> void:
	var col_mask: int = get_collision_mask(obj)
	
	if col_mask == CARD_COL_MASK:
		handle_card_selection(obj)
	elif col_mask == PLAYER_HOME_COL_MASK and not GameManager.is_round_started:
		handle_player_home_movement(obj)
	elif col_mask == SLOT_COL_MASKS and not GameManager.is_round_started:
		handle_slot_movement(obj)
	else:
		cancel_movement()
		

func handle_card_selection(obj: Node2D) -> void:
	if not is_selected:
		# First card selection
		current_card = obj
		is_selected = true
		current_card.toggle_selection(true)
		highlight_valid_slots()
		card_manager.position_card()
		return
	if is_selected and not GameManager.is_round_started:
		var current_card_label:int = current_card.get_card_level()
		var obj_label:int = obj.get_card_level()
		
		if current_card_label == 1 and obj_label== 1:
			current_card.toggle_selection(false)
			current_card = null
			is_selected = false
			current_card = obj
			is_selected = true
			current_card.toggle_selection(true)
			highlight_valid_slots()
			card_manager.position_card()
			return
		
		if current_card_label == 1 and obj_label== 2:
			# Stack the cards
			var new_value:int = current_card.get_card_value() + obj.get_card_value()
			obj.set_card_value(new_value)
			obj.set_label_text()
			
			# Update game state
			GameManager.player_hand.erase(current_card)
			current_card.toggle_selection(false)
			current_card.queue_free()
			
			# Reset selection state
			current_card = obj
			is_selected = false
			reset_all_slots()
			card_manager.position_card()
			return
		if current_card_label == 2 and obj_label== 1:
			current_card.toggle_selection(false)
			current_card = null
			is_selected = false
			current_card = obj
			is_selected = true
			current_card.toggle_selection(true)
			highlight_valid_slots()
			card_manager.position_card()
			return

	cancel_movement()
	
	
func handle_player_home_movement(obj: Node2D) -> void:

	if is_selected == true and not GameManager.is_round_started:
		var current_card_level: int = current_card.get_card_level()
		var level_dif: int = abs(current_card_level - obj.get_col_mask())

		if level_dif == 1:
			if not obj.has_method("get_slot_occupied"):
					
				if current_card_level == 2:
					GameManager.player_battle_hand.erase(current_card)
					GameManager.player_hand.insert(0,current_card)
					
				#current_card.global_position = obj.global_position
				if obj.has_method("get_slot_no"):
					current_card.set_card_slot_no(obj.get_slot_no())
				card_manager.position_card()
				current_card.set_card_level(obj.get_col_mask())
				current_card.toggle_selection(false)
				current_card = null
				is_selected = false
				reset_all_slots()
				card_manager.position_card()
		else:
			cancel_movement()


func handle_slot_movement(obj: Node2D) -> void:
	if is_selected == true and not GameManager.is_round_started:
		var current_card_level: int = current_card.get_card_level()
		var level_dif: int = abs(current_card_level - obj.get_col_mask())

		if level_dif == 1:
			if obj.has_method("get_slot_occupied") and not obj.get_slot_occupied():
				if current_card_level == 1:
					GameManager.player_hand.erase(current_card)
					GameManager.player_battle_hand.insert(0,current_card)
					
				if current_card_level == 2:
					GameManager.player_battle_hand.erase(current_card)
					GameManager.player_hand.insert(0,current_card)
					
				#current_card.global_position = obj.global_position
				current_card.set_card_slot_no(obj.get_slot_no())
				animate_card_to_pos(current_card, obj.global_position)
				current_card.set_card_level(obj.get_col_mask())
				current_card.toggle_selection(false)
				current_card = null
				is_selected = false
				if obj.has_method("set_slot_occupied"):
					reset_all_slots()
					obj.set_slot_occupied(true)
				card_manager.position_card()
		else:
			cancel_movement()


func highlight_valid_slots() -> void:
	var other_nodes: Array = get_tree().get_nodes_in_group("p_battlefild")
	for nodes: Node2D in other_nodes:
		if abs(nodes.get_col_mask() - current_card.get_card_level()) == 1:
			if GameManager.is_round_started == true:
				if nodes.get_col_mask() != 4 and not nodes.get_slot_occupied():
					nodes.toggle_highlight(true)
			else:
				if nodes.get_col_mask() not in [3, 4] and not nodes.get_slot_occupied():
					nodes.toggle_highlight(true)
			
			

	
#### computer must try to occupy all slots on the 1st round
func _on_move_to_com_battle_timeout() -> void:
	# Get all cards and battle slots
	var com_cards: Array = get_tree().get_nodes_in_group("card")
	var com_battle_slots: Array = get_tree().get_nodes_in_group("c_battlefild")
	var occupied_slots_count: int = 0
	
	# Process each computer card
	for card: Node2D in com_cards:
		if not card.get_is_player():
			# First try to place cards in empty slots
			if occupied_slots_count < 4:
				var placed: bool = try_place_card_in_empty_slot(card, com_battle_slots)
				if placed:
					occupied_slots_count += 1
					continue
			
			# If all slots are occupied (or we couldn't place in empty), try stacking
			if occupied_slots_count >= 4:
				try_stack_card_on_existing(card, com_battle_slots)
	
	# Reposition remaining computer cards
	card_manager.position_computer_card()
	# Signal that computer is ready for battle
	GameManager.coumputer_ready_to_battle.emit()


# Try to place a card in an empty battle slot
func try_place_card_in_empty_slot(card: Node2D, battle_slots: Array) -> bool:
	for battle_slot: Node2D in battle_slots:
		if not battle_slot.get_slot_occupied():
			# Move card to this empty battle slot
			place_card_in_slot(card, battle_slot)
			
			# Update game state
			battle_slot.set_slot_occupied(true)
			GameManager.computer_hand.erase(card)
			GameManager.computer_battle_hand.append(card)
			
			return true  # Card was placed successfully
	
	return false  # No empty slot was found


# Try to stack a card on an existing card in a battle slot
func try_stack_card_on_existing(card: Node2D, battle_slots: Array) -> bool:
	for battle_slot: Node2D in battle_slots:
		# Only stack if the slot's current value is below a threshold
		if battle_slot.get_slot_occupied() and battle_slot.get_slot_value() < random_int_17_to_100():
			# Find the existing card in this slot
			var existing_card = find_card_in_slot(battle_slot.get_slot_no())
			
			if existing_card:
				# Calculate new combined value
				var combined_value: int = card.get_card_value() + battle_slot.get_slot_value()
				
				# Update the existing card's value
				existing_card.set_card_value(combined_value)
				existing_card.set_label_text()
				
				# Update the slot's value
				battle_slot.set_slot_vlaue(combined_value)
				
				# Remove the stacking card
				GameManager.computer_hand.erase(card)
				card.queue_free()
				
				return true  # Successfully stacked
	
	return false  # No suitable slot for stacking


# Find a card in the computer's battle hand by slot number
func find_card_in_slot(slot_no: int) -> Node2D:
	for battle_card in GameManager.computer_battle_hand:
		if battle_card.get_card_slot_no() == slot_no:
			return battle_card
	return null


# Place a card in a battle slot and set its properties
func place_card_in_slot(card: Node2D, battle_slot: Node2D) -> void:
	# Set card properties
	card.set_card_slot_no(battle_slot.get_slot_no())
	card.set_card_level(battle_slot.get_col_mask())
	
	# Add slot bonus to card value
	var new_value: int = card.get_card_value() + battle_slot.get_slot_value()
	card.set_card_value(new_value)
	card.set_label_text()
	
	# Update slot with new value
	battle_slot.set_slot_vlaue(new_value)
	
	# Animate card movement
	animate_card_to_pos(card, battle_slot.global_position)

#### plyer must try to occpy all slots from the 2nd round with this 
func _on_move_to_com_battle_second_round() -> void:
	#for card in GameManager.computer_hand:
	make_computer_move()

	# Reposition remaining computer cards
	card_manager.position_computer_card()
	# Signal that computer is ready for battle
	GameManager.coumputer_ready_to_battle.emit()

# This function makes decisions about card placement for the computer player

func make_computer_move() -> void:
	# Get all available computer cards and their values
	var computer_cards = []
	for card in get_tree().get_nodes_in_group("card"):
		if not card.get_is_player():
			computer_cards.append(card)
			
	var battle_slots = get_tree().get_nodes_in_group("c_battlefild")
	
	# Continue placing cards until we run out or have no good moves left
	while computer_cards.size() > 0:
		var moved = try_place_next_card(computer_cards,battle_slots)
		if not moved:
			break  # No more beneficial moves available
	
	# After all card placements, update UI and emit signal
	card_manager.position_computer_card()
	GameManager.coumputer_ready_to_battle.emit()


# Try to place the next best card based on current game state
func try_place_next_card(computer_cards,battle_slots) -> bool:
	# Count current ownership
	var battlefield_slots = get_tree().get_nodes_in_group("battlefild")
	var computer_slots = []
	var player_slots = []
	var empty_slots = []
	
	for slot in battle_slots:
		if slot.get_slot_owner() == "computer":
			computer_slots.append(slot)

		elif slot.get_slot_owner() == "player":
			player_slots.append(slot)
		else:  # Empty slot
			empty_slots.append(slot)
	
	# PRIORITY 1: Fill empty slots if available
	if empty_slots.size() > 0:
		# Sort empty slots by bonus value (descending)
		empty_slots.sort_custom(func(a, b): return a.get_slot_value() > b.get_slot_value())
		
		var best_card = find_highest_value_card(computer_cards)
		if best_card:
			place_card_on_slot(best_card, empty_slots[0])
			computer_cards.erase(best_card)  # Remove card from available cards
			return true
	
	# PRIORITY 2: If player is winning (3+ slots), try to take back at least one
	elif player_slots.size() >= 3:
		# Sort player slots by value (ascending)
		player_slots.sort_custom(func(a, b): return a.get_slot_value() < b.get_slot_value())
		
		# Try to take over player's weakest slot
		for player_slot in player_slots:
			var player_slot_value = player_slot.get_slot_value()
			var suitable_card = find_card_to_beat_value(computer_cards, player_slot_value)
			
			if suitable_card:
				place_card_on_slot(suitable_card, player_slot)
				computer_cards.erase(suitable_card)
				return true
	
	# PRIORITY 3: Try to take over any player slot if we can
	elif player_slots.size() > 0:
		# Sort player slots by value (ascending)
		player_slots.sort_custom(func(a, b): return a.get_slot_value() < b.get_slot_value())
		
		for player_slot in player_slots:
			var player_slot_value = player_slot.get_slot_value()
			var suitable_card = find_card_to_beat_value(computer_cards, player_slot_value)
			
			if suitable_card:
				place_card_on_slot(suitable_card, player_slot)
				computer_cards.erase(suitable_card)
				return true
	
	# PRIORITY 4: Strengthen our weakest slots if we have any
	elif computer_slots.size() > 0:
		# Filter out slots that already have value over 60
		var slots_to_strengthen = []
		for slot in computer_slots:
			###temp sol
			print("here")
			for s in battlefield_slots:
				if s.get_slot_no() == slot.get_slot_no():
					if s.get_slot_owner() =="computer":
						if s.get_slot_value() <= 60:
							print(s.get_slot_value())
							slots_to_strengthen.append(slot)
		
		# If we have slots below the threshold, strengthen the weakest one
		if slots_to_strengthen.size() > 0:
			# Sort filtered computer slots by value (ascending)
			slots_to_strengthen.sort_custom(func(a, b): return a.get_slot_value() < b.get_slot_value())
			
			var weakest_slot = slots_to_strengthen[0]
			var best_card = find_highest_value_card(computer_cards)
			
			if best_card:
				place_card_on_slot(best_card, weakest_slot)
				computer_cards.erase(best_card)
				return true
	
	# If we get here, no beneficial move was found
	return false

# Find the highest value card in the computer's hand
func find_highest_value_card(computer_cards) -> Node2D:
	if computer_cards.size() == 0:
		return null
		
	var highest_card = computer_cards[0]
	for card in computer_cards:
		if card.get_card_value() > highest_card.get_card_value():
			highest_card = card
	
	return highest_card


# Find a card that can beat the given value
func find_card_to_beat_value(computer_cards, target_value) -> Node2D:
	# Sort cards by value (ascending)
	var sorted_cards = computer_cards.duplicate()
	sorted_cards.sort_custom(func(a, b): return a.get_card_value() < b.get_card_value())
	
	# Find the lowest card that can beat the target value
	for card in sorted_cards:
		if card.get_card_value() > target_value:
			return card
	
	# If no card can beat the target value, return the highest card
	if sorted_cards.size() > 0:
		return sorted_cards[sorted_cards.size() - 1]
	
	return null


# Place a card on a slot, handling all the necessary updates
func place_card_on_slot(card, slot) -> void:
	# Calculate new value
	var new_value = card.get_card_value() + slot.get_slot_value()
	
	# Update card
	card.set_card_slot_no(slot.get_slot_no())
	card.set_card_level(slot.get_col_mask())
	card.set_card_value(new_value)
	card.set_label_text()
	
	# Update slot
	slot.set_slot_vlaue(new_value)
	slot.set_slot_occupied(true)
	slot.set_slot_owner("computer")
	
	# Animate card movement
	animate_card_to_pos(card, slot.global_position)
	
	# Update game state
	GameManager.computer_hand.erase(card)
	GameManager.computer_battle_hand.append(card)
################################################################
func animate_card_to_pos(card: Node2D, new_pos: Vector2) -> void:
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", new_pos, 0.1)

func random_int_17_to_100() -> int:
	return int(randf_range(17, 101))
