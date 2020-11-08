class_name Car
extends Area

signal crashed_on_player

export(int) var turn_before_active

var current_turn : int = 0

func _ready() -> void:
	check_active()

func reset() -> void:
	current_turn = 0
	check_active()

func new_turn() -> void:
	if not visible:
		current_turn += 1
		check_active()

func _on_Car_body_entered(body: Node) -> void:
	if current_turn >= turn_before_active and body.is_in_group('player'):
		emit_signal('crashed_on_player')

func check_active() -> void:
	var active = current_turn >= turn_before_active
	visible = active
	$SpotLight.visible = active
