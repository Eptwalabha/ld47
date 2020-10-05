class_name Dialog
extends Node

var lines = []
var line_index := 0

func reset() -> void:
	line_index = 0

func push(who: String, line: String) -> void:
	lines.append({
		'who': who,
		'what': line,
	})

func start() -> void:
	line_index = 0

func next() -> Dictionary:
	if len(lines) <= line_index:
		return {}
	else:
		line_index += 1
		return lines[line_index - 1]
