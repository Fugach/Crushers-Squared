extends Node

var ENEMY : PackedScene
var BOX : PackedScene
var WEAPON : PackedScene

func _init() -> void:
	if OS.is_debug_build():
		print(" ||| RUNNING IN DEBUG MODE |||")
		var debug_thread = Thread.new()
		debug_thread.start(debug)

func debug():
	ENEMY = load("uid://dacw07jts5j8n")
	BOX = load("uid://bf1hvay56ii3f")
	WEAPON = load("uid://d18mm0obf3dqi")
