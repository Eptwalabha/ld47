class_name Player
extends KinematicBody

signal drink_ended

onready var head := $Head as Spatial
onready var camera := $Head/Camera as Camera
onready var ray := $Head/Camera/RayCast as RayCast
onready var phone := $Head/Camera/phone
onready var glass := $Head/Camera/Glass

export(float) var mouse_sensitivity := 0.3
export(float) var speed := 3.0
export(float) var acceleration := 10.0

var has_control: bool = true
var camera_angle: float = 0
var velocity = Vector3()

const GRAVITY : int = -5
const MAX_GRAVITY : int = -140
const MAX_SLOP : float = deg2rad(45.0)

func _ready() -> void:
	mouse_sensitivity = mouse_sensitivity * -1

func reset() -> void:
	head.rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	camera_angle = 0
	camera.make_current()
	hangup_phone()
	glass.hide()

func input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Data.using_controller = false
		head.rotate_y(deg2rad(event.relative.x * mouse_sensitivity))

		var change = event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			camera.rotate_x(deg2rad(change))
			camera_angle = camera_angle + change
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		Data.using_controller = true

func input_controller() -> void:
	if Data.using_controller:
		var y = (Input.get_action_strength("look_left") - Input.get_action_strength("look_right")) * acceleration
		head.rotate_y(deg2rad(y))
		var x = - (Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * acceleration
		if x + camera_angle < 90 and x + camera_angle > -90:
			camera.rotate_x(deg2rad(x))
			camera_angle = camera_angle + x

func physics_process(delta: float) -> void:
	var direction := Vector3()
	var aim = camera.get_global_transform().basis
	
	if has_control:
		if Input.is_action_pressed("move_forward"):
			direction -= aim.z
		if Input.is_action_pressed("move_backward"):
			direction += aim.z
		if Input.is_action_pressed("move_left"):
			direction -= aim.x
		if Input.is_action_pressed("move_right"):
			direction += aim.x

	var dir = Vector2(direction.x, direction.z).normalized()
	velocity.x = lerp(velocity.x, dir.x * speed, acceleration * delta)
	velocity.z = lerp(velocity.z, dir.y * speed, acceleration * delta)
	
	input_controller()
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if velocity.y < MAX_GRAVITY:
		velocity.y = MAX_GRAVITY

	var m = move_and_slide_with_snap(velocity, Vector3(0, -1, 0), Vector3.UP, true, 4, MAX_SLOP)

	if is_on_wall():
		velocity = m
	else:
		velocity.y = m.y

func get_trigger_hover() -> InteractTrigger:
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider is InteractTrigger and collider.active:
			return collider
	return null

func can_control(control: bool) -> void:
	has_control = control

func force_move(direction: Vector3) -> void:
	translate(direction)

func force_move_to(spatial: Spatial) -> void:
	global_transform.origin = spatial.global_transform.origin
	rotation = spatial.global_transform.basis.get_euler()
	head.rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	camera_angle = 0

func answer_phone() -> void:
	phone.show()

func hangup_phone() -> void:
	phone.hide()

func drink() -> void:
	$AnimationPlayer.play("drink")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("drink_ended")

func move_through_window() -> void:
	$AnimationPlayer.play("move_through_window")
