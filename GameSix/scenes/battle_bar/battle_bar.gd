extends CanvasLayer
var player_value:int = 0
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var progress_bar_cover: ProgressBar = $ProgressBarCover
#@onready var bgmusic: AudioStreamPlayer = $"../bgmusic"

func hide_progress_bar_cover()->void:
	progress_bar_cover.visible = false
	calculate_vlue()
	
func set_progress_bar_value(value:int)->void:
	progress_bar.value = value
	
func calculate_vlue()->void:
	player_value = 0
	var battlefild_slots:Array = get_tree().get_nodes_in_group("battlefild")
	for battlefild_slot in battlefild_slots:
		if battlefild_slot.get_slot_owner() == "player":
			player_value +=1
	
	set_progress_bar_value((100/4)*player_value)
	
	if player_value == 4:
		GameManager.on_player_victory.emit()
		GameManager.is_round_started = false
		GameManager.is_game_over = true
	elif player_value == 0:
			GameManager.on_player_defeat.emit()
			GameManager.is_round_started = false
			GameManager.is_game_over = true
	#elif player_value in [1,2,3]:
		#if(GameManager.player_hand.size() ==0 and GameManager.computer_hand.size() > 0) or (GameManager.player_hand.size() > 0 and GameManager.computer_hand.size() == 0):
			#GameManager.on_draw.emit()
			#GameManager.is_round_started = false
