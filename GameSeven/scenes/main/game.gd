extends Panel


@onready var _main: Control = %Main
@onready var _fade: ColorRect = %Fade

func _ready() -> void:
	_fade.show()
	_main.show()
	_fade.to_clear()
	


func _on_start_button_pressed() -> void:
	await _fade.to_black()
	_main.hide()
	_fade.to_clear()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
