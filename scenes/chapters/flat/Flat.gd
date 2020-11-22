class_name Flat
extends GameChapter

signal phone_picked_up

onready var phone := $Appartment/Phone as Phone
onready var appartment_door := $Door as Door
onready var appartment_window := $Appartment/Window as WindowTrigger
onready var backstreet_building := $BackStreetBuilding as BackStreetBuilding

func _ready() -> void:
	_connect_triggers('flat')
	phone.connect("picked_up", self, "_on_Phone_picked_up")

func reset() -> void:
	if not visible:
		show()
	phone.set_active(true)
	appartment_door.set_state(false)
	Data.reset_game(Data.CHAPTER.FLAT)
	set_level(Data.flat_level)
	emit_signal("fade_in_requested")
	emit_signal("night_environment", false)

func set_level(level: int) -> void:
	var delta_elevation : float = level * 2.5 - backstreet_building.global_transform.origin.y
	backstreet_building.translate(Vector3(0, delta_elevation, 0))
	appartment_window.set_active(level == 0 || level == 2)

func _on_Door_interacted_with(door: Door) -> void:
	emit_signal("door_interacted_with", door)

func _on_Phone_picked_up() -> void:
	phone.set_active(false)
	emit_signal("phone_picked_up")

func get_start_origin() -> Vector3:
	return start.global_transform.origin
