class_name DialogTrigger
extends InteractTrigger

signal dialog_start(trigger)

export(Array, Dictionary) var dialogs := []
export(bool) var multiple := false

var i = 0

func interact() -> void:
	if not active:
		return
	active = multiple
	emit_signal("dialog_start", self)

func start() -> void:
	var i = 0

func next() -> Dictionary:
	if len(dialogs) <= i:
		return {}
	else:
		i += 1
		return dialogs[i - 1]

