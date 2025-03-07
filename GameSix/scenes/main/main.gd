extends Node2D

# Constants
const CARD: PackedScene = preload("res://scenes/card/card.tscn")
const CARD_SIZE: Vector2 = Vector2(130, 202)
const CARD_SPACING: float = 20
const CARD_COL_MASK: int = 32
const BATTLE_SLOT_COL_MASKS: int = 3
const SLOT_COL_MASKS: int = 2
const PLAYER_HOME_COL_MASK: int = 1

# Variables
var is_selected: bool = false
var is_round_started: bool = false
var current_card: Node2D
var drag_offset: Vector2 = Vector2.ZERO
var card_size: Vector2 = Vector2(90, 132)
var screen_size: Vector2
var player_deck: Array
var player_hand: Array = []
var player_battle_hand: Array = []
var battle_field: Array = []

# Node references
@onready var table: Panel = $Table

# Lifecycle methods
func _ready() -> void:
	screen_size = get_viewport().size
	player_deck = CardManager.generate_countdown_numbers(3)
	create_cards()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			raycast_check_at_cursor()

# Card creation and positioning
func create_cards() -> void:
	var cards: int = player_deck.size()

	for i: int in range(cards):
		var card: Node2D = CARD.instantiate()
		card.set_card_value(player_deck[0])
		player_deck.remove_at(0)
		player_hand.insert(0, card)
		table.add_child(card)
	position_card()

func position_card() -> void:
	var cards: int = player_hand.size()
	var start_x: float = calculate_start_x(cards)
	for i: int in range(cards):
		var x_pos: float = start_x + (CARD_SIZE.x + CARD_SPACING) * i
		player_hand[i].position = Vector2(x_pos, screen_size.y-(CARD_SIZE.y/3)+10)

func calculate_start_x(total_slots: int) -> float:
	var total_width: float = (CARD_SIZE.x * total_slots) + (CARD_SPACING * (total_slots - 1))
	return (table.size.x - total_width) / 2

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

func card_movement_controller(obj: Node2D) -> void:
	var col_mask: int = _get_collision_mask(obj)
	
	if col_mask == CARD_COL_MASK:
		_handle_card_selection(obj)
	elif col_mask == PLAYER_HOME_COL_MASK and not is_round_started:
		_handle_player_home_movement()
	elif col_mask == SLOT_COL_MASKS:
		_handle_slot_movement(obj)
	elif col_mask == BATTLE_SLOT_COL_MASKS and is_round_started:
		_handle_battle_slot_movement(obj)
	else:
		cancel_movement()

func _get_collision_mask(obj: Node2D) -> int:
	var col_mask: int = 0
	if obj.has_method("get_col_mask"):
		col_mask = obj.get_col_mask()
	elif "collision_mask" in obj:
		col_mask = obj.collision_mask
	return col_mask

func _handle_card_selection(obj: Node2D) -> void:
	if not is_selected:
		# First card selection
		current_card = obj
		is_selected = true
		current_card.toggle_selection(true)
		_highlight_valid_slots()
		return
		
	if !is_round_started and obj != current_card:
		# Potential card stacking during a round
		print("Selected card level: ", current_card.get_card_level())
		print("Target card level: ", obj.get_card_level())
		
		# Check if cards can be stacked (same level or whatever your game rules require)
		if current_card.get_card_level() == 1 and obj.get_card_level() == 2:
			# Stack the cards
			var new_value = current_card.get_card_value() + obj.get_card_value()
			obj.set_card_value(new_value)
			obj.set_label_text()
			
			# Update game state
			battle_field.erase(current_card)
			current_card.toggle_selection(false)
			current_card.queue_free()
			
			# Reset selection state
			current_card = null
			is_selected = false
			_reset_all_slots()
			return
	
	# If we reach here, either deselect or reselect
	if is_selected and not is_round_started:
		cancel_movement()
		current_card = obj
		is_selected = true
		current_card.toggle_selection(true)
		_highlight_valid_slots()
	else:
		# Cancel current selection if clicking somewhere invalid
		cancel_movement()
	cancel_movement()

func _highlight_valid_slots() -> void:
	var other_nodes: Array = get_tree().get_nodes_in_group("slot")
	for nodes: Node2D in other_nodes:
		if abs(nodes.get_col_mask() - current_card.get_card_level()) == 1:
			if is_round_started == true:
				if nodes.get_col_mask() != 4 and not nodes.get_slot_occupied():
					nodes.toggle_highlight(true)
			else:
				if nodes.get_col_mask() not in [3, 4] and not nodes.get_slot_occupied():
					nodes.toggle_highlight(true)

func _handle_player_home_movement() -> void:
	if is_selected == true:
		if current_card in player_battle_hand:
			player_battle_hand.erase(current_card)
		
		if current_card not in player_hand:
			player_hand.append(current_card)
		
		current_card.set_card_level(1)
		current_card.toggle_selection(false)
		
		current_card = null
		is_selected = false
		position_card()
		_reset_all_slots()

func _handle_slot_movement(obj: Node2D) -> void:
	if is_selected == true:
		var current_card_level: int = current_card.get_card_level()
		var level_dif: int = abs(current_card_level - obj.get_col_mask())

		if level_dif == 1:
			if obj.has_method("get_slot_occupied") and not obj.get_slot_occupied():
				if current_card_level == 1:
					player_hand.erase(current_card)
				if current_card_level == 1:
					battle_field.erase(current_card)
				player_battle_hand.append(current_card)
				current_card.global_position = obj.global_position
				current_card.set_card_level(obj.get_col_mask())
				current_card.toggle_selection(false)
				current_card = null
				is_selected = false
				if obj.has_method("set_slot_occupied"):
					_reset_all_slots()
					obj.set_slot_occupied(true)
		else:
			cancel_movement()
			
			
func _handle_battle_slot_movement(obj: Node2D) -> void:
	if is_selected == true:
		var level_dif: int = abs(current_card.get_card_level() - obj.get_col_mask())
		if level_dif == 1:
			if obj.has_method("get_slot_occupied") and not obj.get_slot_occupied():
				player_battle_hand.erase(current_card)
				battle_field.append(current_card)
				current_card.global_position = obj.global_position
				current_card.set_card_level(obj.get_col_mask())
				current_card.toggle_selection(false)
				if obj.has_method("set_slot_occupied"):
					_reset_all_slots()
					obj.set_slot_occupied(true)
					obj.set_slot_owner("player")
					obj.set_slot_vlaue(current_card.get_card_value())
				current_card = null
				is_selected = false
		
			
		# These are placeholders for future expansion
		elif level_dif == 0 and obj.get_slot_occupied() == false:
			pass
		elif level_dif == 0 and obj.get_slot_occupied() == true:
			pass
		else:
			cancel_movement()

func _reset_all_slots() -> void:
	var other_nodes: Array = get_tree().get_nodes_in_group("slot")
	for nodes: Node2D in other_nodes:
		nodes.set_slot_occupied(false)
		nodes.toggle_highlight(false)

func cancel_movement() -> void:
	if is_selected:
		current_card.toggle_selection(false)
		current_card = null
		is_selected = false
		_reset_all_slots()

# Round control
func _on_round_start_button_pressed() -> void:
	if !is_round_started:
		_start_round()
	else:
		_end_round()

func _start_round() -> void:
	is_round_started = true
	_toggle_player_home_collision(true)
	_toggle_player_hand_cards_collision(true)

func _end_round() -> void:
	is_round_started = false
	_toggle_player_home_collision(false)
	_toggle_player_hand_cards_collision(false)

func _toggle_player_home_collision(enabled: bool) -> void:
	var playerhome_nodes: Array = get_tree().get_nodes_in_group("playerhome")
	if playerhome_nodes.size() > 0:
		var first_node:Node2D = playerhome_nodes[0]
		if first_node.has_method("toggle_collision"):
			first_node.toggle_collision(enabled)

func _toggle_player_hand_cards_collision(enabled: bool) -> void:
	var card_nodes: Array = get_tree().get_nodes_in_group("card")
	if card_nodes.size() > 0:
		for nodes: Node2D in card_nodes:
			var card_level: int = nodes.get_card_level()
			if card_level == 1:
				if nodes.has_method("toggle_collision"):
					nodes.toggle_collision(enabled)
