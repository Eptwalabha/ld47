class_name DialogTrigger
extends InteractTrigger

signal dialog_start(trigger)

export(Array, String) var dialogs := []
export(String) var who := "someone"

export(bool) var multiple := false

var line_index = 0

func interact() -> void:
	if not active:
		return
	active = multiple
	emit_signal("dialog_start", self)

func start() -> void:
	line_index = 0

func next() -> Dictionary:
	if len(dialogs) <= line_index:
		return {}
	else:
		line_index += 1
		return {
			'who': who,
			'what': dialogs[line_index - 1],
		}

