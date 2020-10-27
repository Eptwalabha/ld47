class_name TPTrigger
extends Area

signal player_entered
signal player_exited

export(bool) var oriented := false
export(float, 0.2, 1.0) var orientation_angle := 0.8
export(String) var id := ""

func _ready() -> void:
	if not Data.debug:
		$Angle.queue_free()

func is_well_oriented(basis: Basis) -> bool:
	return not oriented or _is_basis_aligned(basis)

func _is_basis_aligned(basis: Basis) -> bool:
	var q1 := basis.get_rotation_quat()
	var q2 := global_transform.basis.get_rotation_quat()
	return abs(q1.dot(q2)) >= orientation_angle

func destination_translation() -> Vector3:
	return $To.transform.origin

func _on_TPTrigger_body_entered(_body: Node) -> void:
	emit_signal("player_entered")

func _on_TPTrigger_body_exited(_body: Node) -> void:
	emit_signal("player_exited")
