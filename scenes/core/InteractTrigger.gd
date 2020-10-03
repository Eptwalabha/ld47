class_name InteractTrigger
extends Area

signal interacted_with()

export(String) var hover_key := "action_hover"
export(bool) var active := true

func set_active(is_active: bool) -> void:
	active = is_active
	for elem in get_children():
		if elem is CollisionShape:
			elem.disabled = not active

func interact() -> void:
	if not active:
		return
	emit_signal("interacted_with")
