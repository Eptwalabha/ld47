class_name UI
extends Control


func show_context(text: String) -> void:
	$VBoxContainer/Context/Label.text = text
	$VBoxContainer/Context/Label.show()

func hide_context() -> void:
	$VBoxContainer/Context/Label.hide()
