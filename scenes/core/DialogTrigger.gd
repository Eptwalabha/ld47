class_name DialogTrigger
extends InteractTrigger

signal dialog_start(trigger)

export(Array, String) var dialogs := []
export(String) var who := "someone"

export(bool) var multiple := false

var line_index = 0

var dialog : Dialog

func _ready() -> void:
	dialog = Dialog.new()
	for line in dialogs:
		dialog.push(who, line)

func interact() -> void:
	if not active:
		return
	active = multiple
	emit_signal("dialog_start", self)
