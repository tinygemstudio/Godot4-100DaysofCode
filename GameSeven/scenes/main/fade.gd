extends ColorRect

const CLEAR:Color = Color(0,0,0,0)
var _tween:Tween

func _tween_color(value:Color)->Signal:
	if _tween and _tween.is_running():
		_tween.kill()
		
	_tween = create_tween()
	_tween.tween_property(self, "color", value, 1)
	return _tween.finished
	
func to_clear()->Signal:
	return _tween_color(CLEAR)

func to_black()->Signal:
	return _tween_color(Color.BLACK)
