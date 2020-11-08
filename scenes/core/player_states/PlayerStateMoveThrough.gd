class_name PlayerStateMoveThrough
extends PlayerState

onready var tween := $Tween as Tween
var path = []

func _ready() -> void:
	tween.connect("tween_all_completed", self, "_on_Tween_tween_all_completed")

func set_route(new_path: Array) -> void:
	path = new_path

func enter(player: Player) -> void:
	player.can_control(false)
	match len(path):
		0:
			emit_signal("state_ended")
			return
		1:
			tween.interpolate_property(
				player,
				"translation",
				player.global_transform.origin,
				path[0],
				.8,
				Tween.TRANS_QUAD)
		_:
			tween.interpolate_property(
				player,
				"translation",
				player.global_transform.origin,
				path[0],
				.2,
				Tween.TRANS_QUAD,
				Tween.EASE_IN)
			tween.interpolate_property(
				player,
				"translation",
				path[0],
				path[1],
				.6,
				Tween.TRANS_QUAD,
				Tween.EASE_OUT,
				.2)
	tween.start()
	if player.has_method('move_through_window'):
		player.move_through_window()

func input(player: Player, event: InputEvent) -> void:
	player.input(event)

func _on_Tween_tween_all_completed() -> void:
	emit_signal("state_ended")
