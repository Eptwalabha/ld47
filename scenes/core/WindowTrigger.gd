class_name WindowTrigger
extends InteractTrigger

signal went_through

onready var box := $Area.shape as BoxShape
export(float) var dist := 0.5

func _ready() -> void:
	if not Data.debug:
		$VisualDebug.queue_free()

func get_window_width() -> float:
	return box.extents.x

func get_next(global_from: Vector3) -> Vector3:
	if to_local(global_from).z > 0:
		return to_global(Vector3(0, 0, -1))
	else:
		return to_global(Vector3(0, 0, 1))

func get_path_points(global_from: Vector3, width: float) -> Array:
	var local = to_local(global_from)
	if abs(local.x) > get_window_width() - width:
		var corrected = _corrected(local, width)
		return [to_global(corrected), to_global(_end_point(corrected))]
	else:
		return [to_global(_end_point(local))]

func _end_point(local_from: Vector3) -> Vector3:
	var z := -dist if local_from.z > 0.0 else dist
	return Vector3(local_from.x, local_from.y, z)

func _corrected(local_from: Vector3, width: float) -> Vector3:
	var limit = get_window_width() - width
	var z := .2 if local_from.z > 0.0 else -.2
	if local_from.x < 0:
		return Vector3(-limit, local_from.y, z)
	else:
		return Vector3(limit, local_from.y, z)

func through() -> void:
	emit_signal("went_through")
