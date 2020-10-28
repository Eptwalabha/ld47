class_name TPTrigger
extends Area

signal player_entered
signal player_exited

export(bool) var oriented := false
export(float, 0.2, 1.0) var orientation_angle := 0.5
export(String) var id := ""
export(NodePath) var external_to

var to : Spatial

func _ready() -> void:
	if external_to:
		to = get_node(external_to)
	else:
		to = $To
	if not Data.debug:
		$Forward.queue_free()

func is_well_oriented(basis: Basis) -> bool:
	return not oriented or _is_basis_aligned(basis)

func _is_basis_aligned(basis: Basis) -> bool:
	var q1 := basis.get_rotation_quat()
	var q2 := global_transform.basis.get_rotation_quat()
	return abs(q1.dot(q2)) < orientation_angle

func destination_translation() -> Vector3:
	return to.global_transform.origin - global_transform.origin
#	return to_local(to.global_transform.origin)

func _on_TPTrigger_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		emit_signal("player_entered")

func _on_TPTrigger_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		emit_signal("player_exited")
