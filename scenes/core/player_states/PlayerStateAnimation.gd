class_name PlayerStateAnimation
extends PlayerState

var player_control_state : bool

func enter(p: Player) -> void:
	player_control_state = p.has_control
	p.can_control(false)
	if p is FPSPlayer:
		p.velocity = Vector3.ZERO

func exit(p: Player) -> void:
	p.can_control(player_control_state)

func pause(player: Player, _state: int) -> void:
	player.pause_animation()

func resume(player: Player, _state: int) -> void:
	player.resume_animation()
