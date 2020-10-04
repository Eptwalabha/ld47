class_name Key
extends Spatial

signal picked_up

func reset() -> void:
	visible = true
	$InteractTrigger.active = true

func _on_InteractTrigger_interacted_with() -> void:
	emit_signal("picked_up")
	visible = false
	$InteractTrigger.active = false
