class_name Bar
extends Spatial

signal end_of_chapter


func _on_TPTrigger_body_entered(body: Node) -> void:
	if body is Player:
		emit_signal("end_of_chapter")
