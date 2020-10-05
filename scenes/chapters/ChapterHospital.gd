class_name ChapterHospital
extends Chapter

onready var ui := $UI as UI
onready var camera := $Spatial/Camera as Camera
onready var timer := $Timer as Timer

var dialogs = [
	{ "what": "dialog_4_01", "duration": 2 },
	{ "what": "dialog_4_02", "duration": 1 },
	{ "what": "dialog_4_03", "duration": 1 },
	{ "what": "dialog_4_04", "duration": 3 },
]

var corridors = []
var current_line := 0

func _ready() -> void:
	hide()
	$Control.hide()
	ui.hide()

func end() -> void:
	hide()
	ui.hide()
	$Control.hide()
	timer.stop()

func start() -> void:
	show()
	ui.reset()
	current_line = 0
	$CutScene.play("final")
	$Control.show()
	camera.make_current()

func open_doors() -> void:
	pass

func display_next_dialog_line() -> void:
	timer.stop()
	if current_line >= len(dialogs):
		ui.hide_dialog()
		return
	current_line += 1
	var line = dialogs[current_line - 1]
	if line.has("duration"):
		timer.start(line.duration)
	ui.display_dialog('', line.what)

func _on_CutScene_animation_finished(anim_name: String) -> void:
	if anim_name == "final":
		timer.stop()
		emit_signal("chapter_ended")

func _on_Timer_timeout() -> void:
	ui.hide_dialog()
