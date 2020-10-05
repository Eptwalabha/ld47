class_name UIDialog
extends MarginContainer

onready var label := $Center/Label as Label

func display(who, what) -> void:
	show()
	if who == '':
		label.text = tr(what)
	else:
		label.text = "%s: %s" % [tr(who), tr(what)]
