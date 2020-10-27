class_name Game2
extends Spatial

onready var current_player : Player = $Player/Player as Player
onready var ui := $UI as UI
var triggers := {}


func _physics_process(delta: float) -> void:
	current_player.physics_process(delta)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		ui.show_mouse_capture()
	_check_triggers()
	for trigger_id in triggers:
		var trigger = triggers[trigger_id]
		if trigger.is_well_oriented(current_player.head.global_transform.basis):
			current_player.force_move(trigger.destination_translation())
			triggers = {}
			break

func _input(event: InputEvent) -> void:
	current_player.input(event)

func _on_Appartment_door_interacted_with(door: Door2) -> void:
	
	if not Data.phone_picked_up:
		door.close()
		Data.phone_picked_up = true
	else:
		door.toggle()

func _check_triggers():
	if current_player.ray.is_colliding():
		var collider = current_player.ray.get_collider()
		if collider is InteractTrigger and collider.active:
			if Input.is_action_just_pressed("context_action"):
				collider.interact()
			else:
				ui.show_context(collider.id)
#				ui.show_context(collider.hover_key)
		else:
			ui.hide_context()
	else:
		ui.hide_context()


func _on_Appartment_tp_entered(trigger: TPTrigger) -> void:
	if trigger.is_well_oriented(current_player.head.global_transform.basis):
		current_player.force_move(trigger.destination_translation())
	else:
		triggers[trigger.id] = trigger


func _on_Appartment_tp_exited(trigger) -> void:
	if triggers.has(trigger.id):
		triggers.erase(trigger.id)
