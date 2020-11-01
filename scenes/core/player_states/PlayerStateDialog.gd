class_name PlayerStateDialog
extends PlayerState

var dialogs := {}
var dialog : Dialog

func _ready() -> void:
	_build_dialogs()

func set_dialog(dialog_id: String) -> void:
	if dialogs.has(dialog_id):
		dialog = dialogs[dialog_id]
	else:
		dialog = null

func enter() -> void:
	if dialog == null:
		emit_signal("state_ended")
	else:
		player.can_control(false)
		player.velocity = Vector3.ZERO
		ui.hide_context()
		dialog.start()
		# warning-ignore:return_value_discarded
		_print_next_bit()

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("context_action"):
		if not _print_next_bit():
			player.can_control(true)
			ui.hide_dialog()
			emit_signal("state_ended")

func _print_next_bit() -> bool:
	var d = dialog.next()
	if not d.has('what'):
		return false
	ui.display_dialog(d.who, d.what)
	return true

func _build_dialogs() -> void:
	dialogs = {}
