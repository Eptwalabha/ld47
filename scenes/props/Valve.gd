class_name Valve
extends Spatial

signal picked_up

func reset() -> void:
	display(false)

func display(is_visible: bool) -> void:
	visible = is_visible
	$InteractTrigger.set_active(visible)

func _on_InteractTrigger_interacted_with() -> void:
	emit_signal("picked_up")
	display(false)
