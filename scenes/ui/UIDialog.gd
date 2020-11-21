class_name UIDialog
extends MarginContainer

onready var label_text := $Container/Center/Label as Label
onready var label_who := $Container/Name as Label

func display(who, what) -> void:
	show()
	label_who.text = tr(who)
	label_text.text = tr(what)
