class_name PlayerStateMoveDrink
extends PlayerStateFPS

signal drink_timeout

var next_drinking : float = 0.0
var drinking : bool = false

func enter(player: Player) -> void:
	player.can_control(true)
	drinking = false
	next_drinking = Data.BAR_DRINK_DELAY_SECOND

func process(player: Player, delta: float) -> void:
	.process(player, delta)
	next_drinking -= delta
	if next_drinking <= 0.0 and not drinking:
		emit_signal("drink_timeout")
		drinking = true

func is_hint_activated() -> bool:
	return not is_drinking()

func is_drinking() -> bool:
	return drinking

func resume(player: Player, from_state: int) -> void:
	drinking = false
	if from_state == Data.GAME_STATE.ANIMATION:
		next_drinking = Data.BAR_DRINK_DELAY_SECOND
