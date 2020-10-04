class_name Car
extends Spatial

signal crash
export(int) var turn_before_active

var reset_turn_before_active : int = 0
var current_turn : int = 0

func _ready() -> void:
	reset_turn_before_active = turn_before_active
	hide()

func reset() -> void:
	turn_before_active = reset_turn_before_active
	current_turn = 0
	_update_car_visiblity()

func _update_car_visiblity() -> void:
	if current_turn < turn_before_active:
		hide()
	else:
		show()

func _on_Area_area_entered(area: Area) -> void:
	if area is TurnTrigger:
		current_turn += 1
		_update_car_visiblity()
		$SpotLight.visible = true
	elif area is CarInsideArea:
		if current_turn >= turn_before_active:
			emit_signal("crash")
