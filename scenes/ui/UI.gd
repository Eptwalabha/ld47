class_name UI
extends Control

# warning-ignore:unused_signal
signal blink

func show_context(text: String) -> void:
	$VBoxContainer/Context/Label.text = tr(text)
	$VBoxContainer/Context.show()

func hide_context() -> void:
	$VBoxContainer/Context.hide()

func display_dialog(who: String, what: String) -> void:
	hide_context()
	$VBoxContainer/Dialog.show()
	$VBoxContainer/Dialog/Center/Label.text = "%s: '%s'" % [tr(who), tr(what)]

func hide_dialog() -> void:
	$VBoxContainer/Dialog.hide()

func blink() -> void:
	$AnimationPlayer.play("blink")

func fade(fade_in: bool) -> void:
	if fade_in:
		$AnimationPlayer.play("fade-in")
	else:
		$AnimationPlayer.play("fade-out")

func black() -> void:
	$ColorRect.color.a = 1.0
