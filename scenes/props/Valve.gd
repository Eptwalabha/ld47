class_name Valve
extends Spatial

signal picked_up

var id : String = 'valve'

func reset() -> void:
	set_active(false)

func _on_InteractTrigger_interacted_with() -> void:
	emit_signal("picked_up")

func set_active(active) -> void:
	visible = active
	$InteractTrigger.set_active(active)
