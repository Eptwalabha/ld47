class_name InteractTrigger
extends Area

signal interacted_with()

export(String) var hover_key := "action_hover"
export(bool) var active := true setget set_active
export(String) var id := ""

var reset_active : bool

func _ready() -> void:
	reset_active = active

func set_active(is_active: bool) -> void:
	active = is_active
	for elem in get_children():
		if elem is CollisionShape:
			elem.disabled = not active

func reset() -> void:
	set_active(reset_active)

func interact() -> void:
	if not active:
		return
	emit_signal("interacted_with")
