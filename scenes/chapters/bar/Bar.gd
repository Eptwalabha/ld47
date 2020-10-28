extends Spatial

signal door_interacted_with(door)

func _on_Door_interacted_with() -> void:
	emit_signal("door_interacted_with", $BarStorageRoom/Door)


func _on_Bar_visibility_changed() -> void:
	print("bar visible %s" % visible)
