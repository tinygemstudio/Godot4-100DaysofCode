extends Node


var save_path = "user://survivethewar.dat"

func save_high_score(value:int):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(value)

func get_high_score()->int:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		return file.get_var()
	else:
		return 0
