class_name CarPlayer
extends Player

onready var steer_wheel = $car_inside/valve

var velocity_x : float = 0.0
var x : float = 0.0

func steer(amount: float) -> void:
	steer_wheel.rotate_object_local(Vector3.UP, -1.5 * amount)

func physics_process(delta: float) -> void:
	x = 0.0
	if Input.is_action_pressed("move_left"):
		x = -Data.ROAD_CAR_SPEED
	if Input.is_action_pressed("move_right"):
		x = Data.ROAD_CAR_SPEED

	velocity_x = lerp(velocity_x, x, Data.ROAD_CAR_ACCELERATION * delta) * .95 + Data.road_car_drag
	steer(velocity_x)
	translate(Vector3(velocity_x, 0, 0))
