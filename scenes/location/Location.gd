class_name Location
extends Spatial

func set_active(active: bool) -> void:
	_active_own_collision(active)
#	_active_child_location(active)

#func _active_child_location(active: bool) -> void:
#	for location in get_children():
#		if location is Location:
#			location.set_active(active)

func _active_own_collision(active: bool) -> void:
	for collision in get_children():
		if not collision is StaticBody:
			continue
		for shape in collision.get_children():
			if not shape is CollisionShape:
				continue
			shape.set_disabled(not active)
