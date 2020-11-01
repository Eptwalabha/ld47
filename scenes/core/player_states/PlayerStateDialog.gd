class_name PlayerStateDialog
extends PlayerState

signal dialog_ended(dialog_id)

var dialogs := {}
var dialog : Dialog
var current_dialog_id: String = ''

func _ready() -> void:
	_build_dialogs()

func set_dialog(dialog_id: String) -> void:
	if dialogs.has(dialog_id):
		current_dialog_id = dialog_id
		dialog = dialogs[dialog_id]
	else:
		current_dialog_id = ''
		dialog = Dialog.new()
		dialog.push('', dialog_id)

func enter() -> void:
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
			emit_signal("dialog_ended", current_dialog_id)
			emit_signal("state_ended")

func _print_next_bit() -> bool:
	var d = dialog.next()
	if not d.has('what'):
		return false
	ui.display_dialog(d.who, d.what)
	return true

func _build_dialogs() -> void:
	dialogs = {}
	var regex = RegEx.new()
	regex.compile("((?<who>[a-zA-Z-_0-9]+):)?(?<dialog_key>.*)")
	for dialog_id in Data.dialogs:
		var d = Data.dialogs[dialog_id]
		var dialog = Dialog.new()
		if d is String:
			var r = regex.search(d)
			if r:
				dialog.push(r.get_string("who"), r.get_string("dialog_key"))
				dialogs[dialog_id] = dialog
		elif d.has('text'):
			for line in d.text:
				var r = regex.search(line)
				if r:
					dialog.push(r.get_string("who"), r.get_string("dialog_key"))
					dialogs[dialog_id] = dialog
