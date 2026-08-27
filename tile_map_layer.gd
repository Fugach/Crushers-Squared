extends TileMapLayer

@onready var Elevator : Area2D = $"../Elevator"
@onready var Table: Sprite2D = $"../Table"
@onready var Elevator_fake: Node2D = $"../elevator_fake"
const LIGHTS = preload("uid://cp0ivvdcjm3h4")
const DOOR = preload("uid://lf2qgrhjy7sd")
const ROOM = preload("uid://cxn1pdnonmni6")


var room_anchor = Vector2(0, 0)
var room_size = Vector2(0, 0)
var room_doors = "right"
var doors_height = 0
var hall_length = 0
var hall_tilt = 0
var old_room_size = Vector2(0, 0)
var old_room_doors_height = 0
var old_room_anchor = Vector2(0, 0)
var stairs_length : int = 0
var gen_direction := Vector2(0, 0)
var hall_pos1 = Vector2(0, 0)
var hall_pos2 = Vector2(0, 0)
var total_lights : int = 0
var total_rooms : int = 0
var total_doors : int = 0
var del_list = ["Enemy", "Rocket", "Bullet", "Light", "Door", "Room"]
var player = CharacterBody2D

func _ready() -> void:
	player = GlobalVars.player
	GlobalVars.passed_layers = 0
	var rooms_amount = randi_range(3, 15)
	for x in range(50):
		set_cell(Vector2(x - 25, 50), 0, Vector2(0, 0))
	#gen_dungeon(rooms_amount, Vector2(3, 2))

func gen_dungeon(rooms_amount, start_pos):
	for x in range(30):
		set_cell(Vector2(x - 5, 15), 1, Vector2(0, 0))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		clear()
		$bg.clear()
		Elevator.results()
