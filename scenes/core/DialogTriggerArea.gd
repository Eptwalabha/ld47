class_name DialogTriggerArea
extends InteractTrigger

func interact() -> void:
	if not active:
		return
	emit_signal("interacted_with")
