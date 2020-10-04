class_name Game
extends Spatial

onready var chapter_01 := $Chapter1 as Chapter01

var current_chapter := 'home'
var chapters = {}

func _ready() -> void:

	chapters = {
		'home': chapter_01,
		'bar': chapter_01,
		'road': chapter_01,
		'hospital': chapter_01,
	}

	reset_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	chapters[current_chapter].process(delta)
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()

func _physics_process(delta: float) -> void:
	chapters[current_chapter].physics_process(delta)

func _input(event: InputEvent) -> void:
	chapters[current_chapter].input(event)

func reset_game() -> void:
	current_chapter = 'home'
	chapters[current_chapter].start()

func _on_end_of_chapter(chapter: int) -> void:
	print("next %s" % chapter)


func _on_Chapter1_end_of_chapter() -> void:
	pass # Replace with function body.

func _on_End_of_chapter(chapter_name: String) -> void:
	print("end of %s" % chapter_name)
	reset_game()
