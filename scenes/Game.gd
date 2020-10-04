class_name Game
extends Spatial

onready var ui := $UI as UI
onready var appartment := $Appartment as Appartment
onready var street := $StreetLevel as Spatial
onready var player := $Player as Player
onready var road := $Road
onready var tween_move_player := $Appartment/MovePlayer as Tween

var lvl = -1
var player_is_inside = true

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
	lvl = 0
#	lvl = -2
	player_is_inside = true
	appartment.set_level(lvl)
	street.translation = Vector3(0, 2.5 * lvl, 0)
#	$Phone.ring()

func _check_triggers():
	if player.ray.is_colliding():
		var collider = player.ray.get_collider()
		if collider is InteractTrigger:
			if Input.is_action_just_pressed("context_action"):
				collider.interact()
			else:
				ui.show_context(tr(collider.hover_key))
		else:
			ui.hide_context()
	else:
		ui.hide_context()


func _on_BackStreetBuilding_go_to(place) -> void:
	if player_is_inside:
		player_is_inside = false
		_move_player_from_to($Appartment/In, $Appartment/Out)
	else:
		player_is_inside = true
		_move_player_from_to($Appartment/Out, $Appartment/In)

func _move_player_from_to(from: Spatial, to: Spatial) -> void:
	player.can_control(false)
	player.move_through_window()
	tween_move_player.interpolate_property(
		player,
		"translation",
		player.global_transform.origin,
		to.global_transform.origin,
		.8,
		Tween.TRANS_QUAD,
		Tween.EASE_IN)
	tween_move_player.start()


func _on_MovePlayer_tween_completed(object: Object, key: NodePath) -> void:
	player.can_control(true)
