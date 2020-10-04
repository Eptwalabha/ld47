class_name UI
extends Control


func show_context(text: String) -> void:
	$VBoxContainer/Context/Label.text = text
	$VBoxContainer/Context.show()

func hide_context() -> void:
	$VBoxContainer/Context.hide()

func display_dialog(who: String, what: String) -> void:
	$VBoxContainer/Dialog.show()
	$VBoxContainer/Dialog/Center/Label.text = "%s: '%s'" % [who, what]

func hide_dialog() -> void:
	$VBoxContainer/Dialog.hide()
