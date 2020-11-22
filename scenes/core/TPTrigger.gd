class_name TPTrigger
extends Area

signal player_entered
signal player_exited

onready var to : Spatial = $To

export(bool) var oriented := false
export(float, 0.2, 1.0) var orientation_angle := 0.5
export(String) var id := ""

var player_to_check : Player

func _ready() -> void:
	set_process(false)
	if not Data.DEBUG:
		$Forward.queue_free()

func _process(_delta: float) -> void:
	if player_to_check != null and _is_body_aligned(player_to_check):
		player_to_check = null
		set_process(false)
		emit_signal("player_entered")

func _is_global_basis_aligned(body: Spatial) -> bool:
	var q1 : Quat = body.global_transform.basis.get_rotation_quat()
	var q2 : Quat = global_transform.basis.get_rotation_quat()
	return abs(q1.dot(q2)) < orientation_angle

func destination_translation() -> Vector3:
	return to.global_transform.origin - global_transform.origin

func _on_TPTrigger_body_entered(body: Spatial) -> void:
	if body.is_in_group("player"):
		if _is_body_aligned(body):
			set_process(false)
			emit_signal("player_entered")
		else:
			player_to_check = body
			set_process(true)

func _on_TPTrigger_body_exited(body: Spatial) -> void:
	if body.is_in_group("player"):
		set_process(false)
		player_to_check = null
		emit_signal("player_exited")

func _is_body_aligned(player: Player) -> bool:
	return not oriented or _is_global_basis_aligned(player.head)
