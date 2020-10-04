class_name BackStreetBuilding
extends Spatial

signal go_to(place)
signal end_of_chapter_one

func _on_StreetTrigger_interacted_with() -> void:
	emit_signal("go_to", "street")

func _on_BarTrigger_interacted_with() -> void:
	emit_signal("go_to", "bar")


func _on_TPTrigger_body_entered(body: Node) -> void:
	if body is Player:
		emit_signal("end_of_chapter_one")
