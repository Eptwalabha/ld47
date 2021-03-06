class_name UI
extends Control

# warning-ignore:unused_signal
signal blink

onready var dialog := $VBoxContainer/Dialog as UIDialog
onready var context := $VBoxContainer/Context as UIContext

func reset() -> void:
	show()

func show_context(key: String) -> void:
	context.display(key)

func hide_context() -> void:
	context.hide()

func display_dialog(who: String, what: String) -> void:
	hide_context()
	dialog.display(who, what)

func hide_dialog() -> void:
	dialog.hide()

func blink() -> void:
	$AnimationPlayer.play("blink")

func fade(fade_in: bool) -> void:
	if fade_in:
		$AnimationPlayer.play("fade-in")
	else:
		$AnimationPlayer.play("fade-out")

func black() -> void:
	$ColorRect.color.a = 1.0
