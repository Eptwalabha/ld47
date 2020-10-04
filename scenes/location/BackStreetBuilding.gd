class_name BackStreetBuilding
extends Spatial

signal go_to(place)


func _on_StreetTrigger_interacted_with() -> void:
	emit_signal("go_to", "street")

func _on_BarTrigger_interacted_with() -> void:
	emit_signal("go_to", "bar")
