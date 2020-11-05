class_name DoorTrigger
extends InteractTrigger

var change_id_on_state : bool = true
var opened : bool = true

func get_id() -> String:
	if change_id_on_state:
		return id + ("_close" if opened else "_open")
	return id
