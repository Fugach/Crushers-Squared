extends TileMapLayer

@onready var Elevator : Area2D = $"../Elevator"
@onready var Table: Sprite2D = $"../Table"
@onready var Elevator_fake: Node2D = $"../elevator_fake"
const LIGHTS = preload("uid://cp0ivvdcjm3h4")
const DOOR = preload("uid://lf2qgrhjy7sd")
const ROOM = preload("uid://cxn1pdnonmni6")

var total_rooms : int = 0
var player = CharacterBody2D
const ROOM_SIZE = Vector2i(12, 12)

func _ready() -> void:
	var generation = Thread.new()
	player = GlobalVars.player
	GlobalVars.passed_layers = 0
	generation.start(gen_dungeon.bind(15, Vector2(0, 0)))
	

func gen_dungeon(rooms_amount, start_pos):
	for x in range(-5, 5):
		for y in range(-5, 5):
			build(start_pos + Vector2(x, y))

func build(room_pos : Vector2):
	for x in range(1, ROOM_SIZE.x):
		# TODO: вставлять плитку через for?
		# TODO: дописать код, нужно делать длинный список на другом потоке, а
		# на основном уже set_cell()
		var cell_pos1 = room_to_map(room_pos) + Vector2i(x, 1)
		var cell_pos2 = room_to_map(room_pos) + Vector2i(x, ROOM_SIZE.y - 1)
		
		#var cells = []
		#cells.append_array([cell_pos1, cell_pos2])
		#cells.append_array(get_surrounding_cells(cell_pos1))
		#cells.append_array(get_surrounding_cells(cell_pos2))
		
		for cell in [cell_pos1, cell_pos2]:
			set_cell(cell, 0, Vector2(4, 2))
			set_cells_terrain_connect(get_surrounding_cells(cell), 0, 0, false)
		
	#for y in range(1, ROOM_SIZE.y):
		#var cell_pos1 = room_to_map(room_pos) + Vector2i(1, y)
		#var cell_pos2 = room_to_map(room_pos) + Vector2i(ROOM_SIZE.x - 1, y)
		#
		#for cell in [cell_pos1, cell_pos2]:
			#set_cell(cell, 0, Vector2(4, 2))
			#set_cells_terrain_connect(get_surrounding_cells(cell), 0, 0, false)

func room_to_map(room_position : Vector2i):
	return Vector2i(room_position * ROOM_SIZE)
func map_to_room(map_position : Vector2):
	return Vector2i(
		floori(map_position.x / ROOM_SIZE.x),
		floori(map_position.y / ROOM_SIZE.y)
		)

func _process(delta: float) -> void:
	var room_col = to_global(map_to_local(map_to_room(local_to_map(to_local(GlobalVars.player.global_position))) * ROOM_SIZE + ROOM_SIZE / 2))
	if $Area2D/CollisionShape2D.global_position != room_col:
		$Area2D/CollisionShape2D.global_position = room_col

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		clear()
		$bg.clear()
		Elevator.results()
