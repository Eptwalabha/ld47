class_name BackStreetBuilding
extends Spatial

signal end_of_chapter_one


func _on_TPTrigger_body_entered(body: Node) -> void:
	if body is Player:
		emit_signal("end_of_chapter_one")
