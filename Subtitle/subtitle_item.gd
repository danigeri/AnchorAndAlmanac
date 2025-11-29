class_name SubtitleItem

var subtitle: String = ""
var duration: int = 0


func _init(
	_duration: int = 30,
	_subtitle_text: String = "",
):
	duration = _duration
	subtitle = _subtitle_text
