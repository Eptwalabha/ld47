class_name ChapterRoad
extends Chapter

onready var player := $CarInside as CarInside
onready var road := $Road as Road
onready var line_a := $Road/LineA as Spatial
onready var line_b := $Road/LineB as Spatial
onready var ui := $UI as UI

export(float) var speed := .6
export(float) var acceleration := 1

var speed_lane := .2
var c_speed := 0.0
var velocity_x := 0.0
var nbr_car := 0
var crashed := false

var reset_player_transform : Transform
var reset_line_a_transform : Transform
var reset_line_b_transform : Transform

func _ready() -> void:
	hide()
	reset_player_transform = player.global_transform
	reset_line_a_transform = line_a.global_transform
	reset_line_b_transform = line_b.global_transform
	for car in get_tree().get_nodes_in_group("cars"):
		if car is Car:
			car.connect("crash", self, "_on_Car_crash")
	$CarEngine.stop()
	$Crash.stop()

func end() -> void:
	hide()
	ui.hide()

func start() -> void:
	show()
	ui.reset()
	ui.fade(true)
	emit_signal("night_environment", true)
	$CarEngine.play()
	nbr_car = 0
	crashed = false
	c_speed = 0.0
	player.reset()
	for car in get_tree().get_nodes_in_group("cars"):
		if car is Car:
			car.reset()
	for dialog in get_tree().get_nodes_in_group("dialog_trigger"):
		if dialog is DialogTrigger:
			dialog.reset()
	line_a.global_transform = reset_line_a_transform
	line_b.global_transform = reset_line_b_transform
	player.global_transform = reset_player_transform

func process(delta: float) -> void:
	if crashed:
		return
	c_speed += delta * 0.01
	road.rotate_y((.4 + c_speed) * delta)
	line_a.rotate_y(-.2 * delta)
	line_b.rotate_y(+.2 * delta)
	
	var x = 0
	if Input.is_action_pressed("move_left"):
		x += 1.0
	if Input.is_action_pressed("move_right"):
		x = -1.0
	velocity_x = lerp(velocity_x, x * speed, acceleration * delta) * .95 + .005
	player.steer(velocity_x)
	player.translate(Vector3(velocity_x, 0, 0))

func input(event: InputEvent) -> void:
	player.input(event)

func _on_Car_crash() -> void:
	crashed = true
	ui.black()
	$Crash.play()
	$CarEngine.stop()
	yield($Crash, "finished")
	emit_signal("chapter_ended")

func _on_LeftSide_area_entered(_area: Area) -> void:
	_on_Car_crash()

func _on_RightSide_area_entered(_area: Area) -> void:
	_on_Car_crash()
