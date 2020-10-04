class_name Car
extends Spatial

signal crash

func turn_light_on(on: bool) -> void:
	$SpotLight.visible = on


func _on_Area_area_entered(area: Area) -> void:
	if area is LightTrigger:
		turn_light_on(area.turn_on_light)
	else:
		emit_signal("crash")
