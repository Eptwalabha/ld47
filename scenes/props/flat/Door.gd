class_name Door
extends Spatial

signal interacted_with(door)

onready var animation := $AnimationPlayer as AnimationPlayer
onready var tween := $Tween as Tween
onready var hinge := $Hinge as Spatial
onready var trigger := $Hinge/InteractTrigger as InteractTrigger

export(String) var id := ""
export(bool) var opened := false
export(int, -150, 150) var max_angle := 150

func _ready() -> void:
	set_state(opened)
	trigger.id = id

func toggle() -> void:
	if opened:
		close()
	else:
		open()

func set_state(is_open: bool) -> void:
	opened = is_open
	tween.stop_all()
	animation.stop(true)
	hinge.rotation_degrees.y = max_angle if opened else 0
	$Hinge/InteractTrigger/Trigger.disabled = false
	$StaticBody/Collision.disabled = opened

func close() -> void:
	if opened:
		opened = false
		tween.interpolate_property(hinge, "rotation_degrees", Vector3(0, max_angle, 0), Vector3.ZERO, .7, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		animation.play("closing")

func open() -> void:
	if not opened:
		opened = true
		tween.interpolate_property(hinge, "rotation_degrees", Vector3.ZERO, Vector3(0, max_angle, 0), .7, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		animation.play("opening")

func _on_InteractTrigger_interacted_with() -> void:
	emit_signal("interacted_with", self)
