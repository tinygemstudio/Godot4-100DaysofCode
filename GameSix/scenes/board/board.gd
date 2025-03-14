extends Node2D

const SLOT: PackedScene = preload("res://scenes/slot/slot.tscn")
const SLOT_SIZE: Vector2 = Vector2(130, 202)
const SLOT_SPACING: float = 20

var screen_size: Vector2
var slot_no:int
@export var table:Panel

enum SlotType {
	PLAYER_HOME = 1,
	PLAYER_BATTLE = 2,
	NEUTRAL_BATTLE = 3,
	COMPUTER_BATTLE = 4,
	COMPUTER_HOME = 5
}

func _ready() -> void:
	screen_size = get_viewport().size
	center_panel()
	create_slots()


		
func center_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = Vector2(946, 660)
	table.position = (viewport_size - panel_size) / 2



func calculate_start_x(total_slots: int) -> float:
	var total_width: float = (SLOT_SIZE.x * total_slots) + (SLOT_SPACING * (total_slots - 1))
	return (table.size.x - total_width) / 2



func create_slots() -> void:
	# Battle rows and home rows
	var slot_configurations: Array = [
		{
			"slot_count": 4, 
			"y_pos": (table.size.y - SLOT_SIZE.y) / 2, 
			"col_mask": SlotType.NEUTRAL_BATTLE,
			"is_col":false,
			"group":"battlefild"
		},
		{
			"slot_count": 4, 
			"y_pos": (table.size.y - SLOT_SIZE.y) - 10, 
			"col_mask": SlotType.PLAYER_BATTLE,
			"is_col":false,
			"group":"p_battlefild"
		},
		{
			"slot_count": 4, 
			"y_pos": 10, 
			"col_mask": SlotType.COMPUTER_BATTLE,
			"is_col":false,
			"group":"c_battlefild"
		},
		#{
			#"slot_count": 8, 
			#"y_pos": -202, 
			#"col_mask": SlotType.COMPUTER_HOME,
			#"is_col":false,
			#"group":"c_home"
		#},
		#{
			#"slot_count": 8, 
			#"y_pos": table.size.y, 
			#"col_mask": SlotType.PLAYER_HOME,
			#"is_col":false,
			#"group":"p_home"
		#},
	]
	
	
	for config:Dictionary in slot_configurations:
		var start_x: float = calculate_start_x(config["slot_count"])
		slot_no = 0
		for i:int in range(config["slot_count"]):
			var slot: Node2D = SLOT.instantiate()
			var x_pos: float = start_x + (SLOT_SIZE.x + SLOT_SPACING) * i
			slot.position = Vector2(x_pos, config["y_pos"])
			slot.set_slot_no(slot_no)
			slot_no += 1
			slot.call_deferred("set_col_mask", config["col_mask"])
			slot.call_deferred("set_col_shape", config["is_col"])
			slot.add_to_group(config["group"])
			table.add_child(slot)
