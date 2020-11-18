class_name CarPlayer
extends Player

onready var steer_wheel = $car_inside/valve

var velocity_x : float = 0.0
var x : float = 0.0
var stuck := 0.0

func reset() -> void:
	velocity_x = 0.0
	x = 0.0
	hide_particles()

func steer(amount: float) -> void:
	steer_wheel.rotate_object_local(Vector3.UP, -1.5 * amount)

func physics_process(delta: float) -> void:
	if stuck > 0.0:
		stuck -= delta
		if stuck <= 0:
			hide_particles()
		return
	x = 0.0
	if Input.is_action_pressed("move_left"):
		x = -Data.ROAD_CAR_SPEED
	if Input.is_action_pressed("move_right"):
		x = Data.ROAD_CAR_SPEED

	velocity_x = lerp(velocity_x, x, Data.ROAD_CAR_ACCELERATION * delta) * .95 + Data.road_car_drag
	steer(velocity_x)
	translate(Vector3(velocity_x, 0, 0))

func bounce(left: bool) -> void:
	stuck = .7
	$car_inside/Particles/Left.emitting = left
	$car_inside/Particles/Right.emitting = not left
	$AnimationPlayer.play("grind")
	var v = abs(velocity_x) * 3
	if left:
		velocity_x = v
	else:
		velocity_x = -v


func hide_particles() -> void:
	$car_inside/Particles/Left.emitting = false
	$car_inside/Particles/Right.emitting = false


func pause_animation() -> void:
	$AnimationPlayer.stop(false)

func resume_animation() -> void:
	$AnimationPlayer.play()
