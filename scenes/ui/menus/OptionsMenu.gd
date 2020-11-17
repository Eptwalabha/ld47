class_name OptionsMenu
extends MarginContainer

signal continue_clicked
signal options_clicked
signal back_clicked

func open() -> void:
	visible = true

func _on_Back_pressed() -> void:
	emit_signal("back_clicked")
