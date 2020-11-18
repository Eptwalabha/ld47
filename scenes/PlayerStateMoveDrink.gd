class_name PlayerStateMoveDrink
extends PlayerStateFPS

signal drink_timeout

var next_drinking : float = 0.0
var call : bool = false
var reset_timeout_on_resume : bool = true

func enter(player: Player) -> void:
	player.can_control(true)
	call = false
	reset_timeout_on_resume = true
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

func pause(player: Player, next_state: String) -> void:
	reset_timeout_on_resume = (next_state == 'animation')

func resume(player: Player) -> void:
	player.can_control(true)
	call = false
	if reset_timeout_on_resume:
		next_drinking = Data.BAR_DRINK_DELAY_SECOND
