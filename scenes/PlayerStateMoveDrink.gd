class_name PlayerStateMoveDrink
extends PlayerStateFPS

signal drink_timeout

var next_drinking : float = 0.0
var call : bool = false

func enter(player: Player) -> void:
	player.can_control(true)
	call = false
	next_drinking = Data.BAR_DRINK_DELAY_SECOND

func process(player: Player, delta: float) -> void:
	.process(player, delta)
	next_drinking -= delta
	if next_drinking <= 0.0 and not call:
		emit_signal("drink_timeout")
		call = true

func is_hint_activated() -> bool:
	return not is_drinking()

func is_drinking() -> bool:
	return false

func resume(player: Player, from_state: int) -> void:
	call = false
	if from_state == Data.GAME_STATE.ANIMATION:
		next_drinking = Data.BAR_DRINK_DELAY_SECOND
