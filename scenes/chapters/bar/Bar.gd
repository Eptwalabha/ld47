class_name Bar
extends GameChapter

onready var start := $StartPoint as Spatial

onready var pivot := $Pivot as Spatial
onready var restroom_door := $Pivot/Door as Door
onready var exit_door := $Pivot/ExitDoor as Door
onready var drink := $Pivot/Bartender/Drink as Spatial
onready var friend := $Pivot/Friend as Character
onready var bartender := $Pivot/Bartender as Bartender
onready var friend_dialog := $Pivot/Friend/Dialog as DialogTriggerArea
onready var bartender_dialog := $Pivot/Bartender/Dialog as DialogTriggerArea
onready var dancers := $Pivot/Dancers as Spatial

onready var item_key := $Key as Key
onready var item_valve := $Valve as Valve
onready var door_item_key := $Pivot/ExitDoor/DoorItems/key as Spatial
onready var door_item_valve := $Pivot/ExitDoor/DoorItems/valve as Spatial

enum CHARACTERS {
	FRIEND,
	BARTENDER,
	TOILET_DANCER,
}
enum ITEMS {
	KEY,
	VALVE,
	EXIT_DOOR,
	EXIT_DOOR_KEY,
	EXIT_DOOR_VALVE,
}

func _ready() -> void:
	_connect_triggers('bar')

func reset() -> void:
	if not visible:
		show()
	restroom_door.set_state(false)
	restroom_door.set_active(true)
	_set_location_active($RestroomLocation, false)
	_set_location_active($RestroomLocationReverse, false)
	_set_location_active($BarStorageRoom, true)
	for character in CHARACTERS:
		enable_dialog(CHARACTERS[character], false)
	for item in ITEMS:
		enable_item(ITEMS[item], false)
	enable_dialog(CHARACTERS.FRIEND, true)
	bartender.visible = true
	dancers.visible = true
	set_character_animation(CHARACTERS.FRIEND, 'sit-stool-idle')
	pivot.scale.z = 1
	Data.reset_game(Data.LEVEL.BAR)

func enable_dialog(who: int, enable: bool) -> void:
	match who:
		CHARACTERS.BARTENDER:
			bartender_dialog.set_active(enable)
		CHARACTERS.FRIEND:
			friend_dialog.set_active(enable)

func enable_item(what: int, enable: bool) -> void:
	match what:
		ITEMS.KEY:
			item_key.set_active(enable)
		ITEMS.VALVE:
			item_valve.set_active(enable)
		ITEMS.EXIT_DOOR:
			exit_door.set_active(enable)
		ITEMS.EXIT_DOOR_KEY:
			door_item_key.visible = enable
		ITEMS.EXIT_DOOR_VALVE:
			door_item_valve.visible = enable

func _on_Door_interacted_with(door: Door) -> void:
	emit_signal("door_interacted_with", door)

func show_restroom() -> void:
	restroom_door.close()
	_set_location_active($RestroomLocation, true)
	_set_location_active($RestroomLocationReverse, true)
	_set_location_active($BarStorageRoom, false)

func close_bar() -> void:
	enable_dialog(CHARACTERS.BARTENDER, false)
	bartender.visible = false
	dancers.visible = false
	emit_signal("night_environment", true)

func set_character_animation(who: int, animation: String) -> void:
	match who:
		CHARACTERS.FRIEND:
			friend.play(animation)

func _on_ToiletWindow_went_through() -> void:
	pivot.scale.z = -1 if pivot.scale.z > 0 else 1

func is_reverted() -> bool:
	return pivot.scale.z < 0

func _on_Valve_picked_up() -> void:
	emit_signal("item_picked_up", item_valve)

func _on_Key_picked_up() -> void:
	emit_signal("item_picked_up", item_key)

func get_start_origin() -> Vector3:
	return start.global_transform.origin
