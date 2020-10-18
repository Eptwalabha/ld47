extends Node

enum LEVEL {
	HOME,
	BAR,
	ROAD,
	HOSPITAL
}

var first_time : bool = true
var using_controller : bool = false
var debug : bool = false
var first_level : int = LEVEL.BAR
