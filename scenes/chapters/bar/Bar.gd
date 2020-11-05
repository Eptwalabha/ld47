extends Spatial

signal door_interacted_with(door)
signal tp_entered(trigger)
signal tp_exited(trigger)
signal dialog_triggered(dialog_trigger)
signal window_triggered(window_trigger)
signal item_picked_up(item)

onready var pivot := $Pivot as Spatial
onready var restroom_door := $Pivot/Door as Door
onready var start := $StartPoint as Spatial
onready var drink := $Pivot/Bartender/Drink as Spatial

enum CHARACTERS {
	FRIEND,
	BARTENDER,
}
enum ITEMS {
	KEY,
	VALVE,
}

func _ready() -> void:
	for trigger in get_tree().get_nodes_in_group('bar-tp-trigger'):
		if trigger is TPTrigger:
			trigger.connect("player_entered", self, "emit_signal", ["tp_entered", trigger])
			trigger.connect("player_exited", self, "emit_signal", ["tp_exited", trigger])
	for trigger in get_tree().get_nodes_in_group('bar-dialog'):
		if trigger is DialogTriggerArea:
			trigger.connect("interacted_with", self, "emit_signal", ["dialog_triggered", trigger])
	for trigger in get_tree().get_nodes_in_group('bar-window'):
		if trigger is WindowTrigger:
			trigger.connect("interacted_with", self, "emit_signal", ["window_triggered", trigger])

func reset() -> void:
	show()
	restroom_door.set_state(false)
	_set_active($RestroomLocation, false)
	_set_active($RestroomLocationReverse, false)
	_set_active($BarStorageRoom, true)
	enable_dialog(CHARACTERS.BARTENDER, false)
	enable_item(ITEMS.KEY, false)
	enable_item(ITEMS.VALVE, false)
	pivot.scale.z = 1
	Data.reset_game(Data.LEVEL.BAR)

func enable_dialog(who: int, enable: bool) -> void:
	match who:
		CHARACTERS.BARTENDER:
			$Pivot/Bartender/Dialog.set_active(enable)
		CHARACTERS.FRIEND:
			$Pivot/Friend/Dialog.set_active(enable)

func enable_item(what: int, enable: bool) -> void:
	match what:
		ITEMS.VALVE:
			$Valve.set_active(enable)
		_:
			pass

func _on_Door_interacted_with() -> void:
	emit_signal("door_interacted_with", restroom_door)

func show_restroom() -> void:
	restroom_door.close()
	_set_active($RestroomLocation, true)
	_set_active($RestroomLocationReverse, true)
	_set_active($BarStorageRoom, false)

func _set_active(location: Location, active: bool) -> void:
	location.set_active(active)
	location.visible = active

func _on_ToiletWindow_went_through() -> void:
	pivot.scale.z = -1 if pivot.scale.z > 0 else 1

func is_reverted() -> bool:
	return pivot.scale.z < 0

func _on_Valve_picked_up() -> void:
	emit_signal("item_picked_up", $Valve)
