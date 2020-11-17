class_name PauseMenu
extends MarginContainer

signal continue_clicked
signal options_clicked
signal quit_clicked

func open() -> void:
	visible = true

func _on_Continue_pressed() -> void:
	emit_signal("continue_clicked")

func _on_Options_pressed() -> void:
	emit_signal("options_clicked")

func _on_Quit_pressed() -> void:
	emit_signal("quit_clicked")
