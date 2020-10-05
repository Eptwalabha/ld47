class_name UIContext
extends MarginContainer

onready var label := $Center/Label as Label

func display(key) -> void:
	show()
	label.text = tr(key)
