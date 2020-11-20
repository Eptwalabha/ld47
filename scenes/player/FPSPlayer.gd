class_name FPSPlayer
extends Player

signal drink_ended

onready var phone := $Head/Camera/phone
onready var glass := $Head/Camera/Glass
onready var ground := $Ground as RayCast
onready var key := $Head/HandBone/key
onready var valve := $Head/HandBone/valve

export(float) var speed := 3.0
export(float) var acceleration := 10.0

var velocity = Vector3()
var gravity_vector : Vector3 = Vector3.ZERO

func _ready() -> void:
	glass.hide()
	phone.hide()

func reset() -> void:
	head.rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	zeroed_velocity()
	camera_angle = 0
	glass.hide()
	phone.hide()
	key.visible = false
	valve.visible = false

func zeroed_velocity() -> void:
	velocity = Vector3.ZERO
	gravity_vector = Vector3.ZERO

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
		gravity_vector += Vector3.DOWN * Data.GRAVITY * delta
	elif is_on_floor() and ground.is_colliding():
		gravity_vector = -get_floor_normal() * -Data.GRAVITY
	else:
		gravity_vector = -get_floor_normal()
	
	if gravity_vector.y > Data.MAX_GRAVITY:
		gravity_vector.y = Data.MAX_GRAVITY
	
	velocity.x += gravity_vector.x
	velocity.y = gravity_vector.y
	velocity.z += gravity_vector.z

	velocity = move_and_slide_with_snap(velocity, Vector3(0, -1, 0), Vector3.UP, true, 4, Data.MAX_SLOP)

func answer_phone() -> void:
	phone.show()

func hangup_phone() -> void:
	phone.hide()

func drink() -> void:
	$AnimationPlayer.play("drink")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("drink_ended")

func empty(empty_glass: bool) -> void:
	glass.empty(empty_glass)

func move_through_window() -> void:
	$AnimationPlayer.play("move_through_window")

func show_item(item_name : String, visible: bool) -> void:
	key.visible = (visible and item_name == 'key')
	valve.visible = (visible and item_name == 'valve')
	phone.visible = (visible and item_name == 'phone')

func pause_animation() -> void:
	$AnimationPlayer.stop(false)

func resume_animation() -> void:
	$AnimationPlayer.play()
