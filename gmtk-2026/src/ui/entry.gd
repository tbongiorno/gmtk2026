extends RichTextLabel


func _set_pos(pos: int) -> void:
	text = text.replace("{pos}", str(pos + 1))

func _set_username(username: String) -> void:
	text = text.replace("{username}", username)

func _set_score(score: float) -> void:
	var min : int  = score / 60
	var sec : int = score - (min * 60)
	text = text.replace("{min}", str(min))
	text = text.replace("{sec}", str(sec))

func set_data(pos: int, username: String, score: float) -> void:
	_set_pos(pos)
	_set_username(username)
	_set_score(score)
