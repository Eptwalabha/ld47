class_name BarCorridor
extends Spatial

signal first_entrance

func reset() -> void:
	$Door.reset()

func _on_Door_door_opened() -> void:
	emit_signal("first_entrance")
