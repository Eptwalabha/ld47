class_name Game
extends Spatial

onready var ui := $UI as UI
onready var appartment := $Appartment as Appartment
onready var street := $StreetLevel as Spatial
onready var player := $Player as Player
onready var road := $Road

var lvl = -1

func _ready() -> void:
	reset_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	_check_triggers()

func _on_Area_body_entered(body: Node) -> void:
	if body is KinematicBody:
		get_tree().reload_current_scene()

func _on_TPDown_body_entered(body: Node) -> void:
	if body is Player:
		_update_back_building(-1)
		_tp_player(Vector3(0, 2.5, 0), body)

func _on_TPUp_body_entered(body: Node) -> void:
	if body is Player:
		_update_back_building(1)
		_tp_player(Vector3(0, -2.5, 0), body)

func _tp_player(direction: Vector3, player: Player) -> void:
	player.force_move(direction)

func _update_back_building(amount: int) -> void:
		var next_lvl = clamp(lvl + amount, -4, 2)
		if lvl != next_lvl:
			street.translate(Vector3(0, 2.5, 0) * amount)
		lvl = next_lvl
		appartment.set_level(lvl)

func reset_game() -> void:
	lvl = -2
	appartment.set_level(lvl)
	street.translation = Vector3(0, 2.5 * lvl, 0)
#	$Phone.ring()

func _check_triggers():
	if player.ray.is_colliding():
		var collider = player.ray.get_collider()
		if Input.is_action_just_pressed("ui_action"):
			pass
		else:
			if collider is InteractTrigger:
				ui.show_context(tr(collider.hover_key))
			else:
				ui.hide_context()
	else:
		ui.hide_context()
