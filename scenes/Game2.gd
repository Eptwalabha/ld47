class_name Game2
extends Spatial

onready var current_player : Player = $Player/Player as Player
onready var ui := $UI as UI

var triggers := {}

func _ready() -> void:
	ui.capture_mouse()
	$Map/Flat.set_level(Data.flat_level)

func _physics_process(delta: float) -> void:
	current_player.physics_process(delta)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		ui.show_mouse_capture()
	_check_triggers()
	for trigger_id in triggers:
		var trigger = triggers[trigger_id]
		if trigger.is_well_oriented(current_player.head.global_transform.basis):
			active_tp(trigger)
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
		if collider is InteractTrigger:
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
		active_tp(trigger)
	else:
		triggers[trigger.id] = trigger

func active_tp(trigger: TPTrigger) -> void:
	_before_tp(trigger)
	current_player.force_move(trigger.destination_translation())
	_after_tp(trigger)

func _before_tp(trigger: TPTrigger) -> void:
	match trigger.id:
		"bar/tp":
			$Map/Bar.show()
		"flat/stairs-up":
			Data.flat_level = int(clamp(Data.flat_level + 1, -4, 2))
			$Map/Flat.set_level(Data.flat_level)
		"flat/stairs-down":
			Data.flat_level = int(clamp(Data.flat_level - 1, -4, 2))
			$Map/Flat.set_level(Data.flat_level)
		_ : pass

func _after_tp(trigger: TPTrigger) -> void:
	match trigger.id:
		"bar/tp":
			$Map/Flat.hide()
		_: pass

func _on_Appartment_tp_exited(trigger) -> void:
	if triggers.has(trigger.id):
		triggers.erase(trigger.id)

func _on_Flat_dialog_triggered(dialog_trigger: DialogTriggerArea) -> void:
	print("request flat's dialog %s" % dialog_trigger.id)

func _on_Bar_dialog_triggered(dialog_trigger: DialogTriggerArea) -> void:
	match dialog_trigger.id:
		"bar/friend":
			if not Data.friend_intro_bar:
				Data.friend_intro_bar = true
				$Map/Bar.show_restroom()
			else:
				print("request bar's dialog with friend")
		var dialog_id:
			print("request bar's dialog %s" % dialog_id)

func _on_Bar_door_interacted_with(door) -> void:
	door.toggle()


func _on_Flat_window_triggered(window_trigger: WindowTrigger) -> void:
	var path = window_trigger.get_path_points(current_player.global_transform.origin, .3)
	_update_path(path)

func _on_Bar_window_triggered(window_trigger: WindowTrigger) -> void:
	var path = window_trigger.get_path_points(current_player.global_transform.origin, .3)
	_update_path(path)

func _update_path(path: Array) -> void:
	var DebugPoint = preload("res://scenes/core/debug/DebugPoint.tscn")
	for n in $Path.get_children():
		n.queue_free()

	for v in path:
		var point = DebugPoint.instance()
		$Path.add_child(point)
		point.global_transform.origin = v
