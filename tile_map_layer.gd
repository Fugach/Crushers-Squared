extends TileMapLayer

@onready var Elevator : Area2D = $"../Elevator"
@onready var Table: Sprite2D = $"../Table"
@onready var Elevator_fake: Node2D = $"../elevator_fake"
const LIGHTS = preload("uid://cp0ivvdcjm3h4")
const DOOR = preload("uid://lf2qgrhjy7sd")
const ROOM = preload("uid://cxn1pdnonmni6")

var prepared_cells : Array = []
var generation_thread : Thread

var total_rooms : int = 0
var player = CharacterBody2D
const ROOM_SIZE = Vector2i(12, 12)

func _ready() -> void:
	player = GlobalVars.player
	GlobalVars.passed_layers = 0
	generation_thread = Thread.new()
	print('Starting generation thread...')
	generation_thread.start(gen_dungeon.bind(15, Vector2(0, 0)))
	if generation_thread.is_alive():
		print('Generation thread is alive!')
	else:
		print('Generarion thread is dead!')

func _process(delta: float) -> void:
	if generation_thread and not generation_thread.is_alive() and prepared_cells:
		var plan = generation_thread.wait_to_finish()
		print("Generation is finished")
		if plan:
			build(plan)
	#var room_col = to_global(map_to_local(map_to_room(local_to_map(to_local(GlobalVars.player.global_position))) * ROOM_SIZE + ROOM_SIZE / 2))
	#if $Area2D/CollisionShape2D.global_position != room_col:
		#$Area2D/CollisionShape2D.global_position = room_col
func gen_dungeon(rooms_amount, start_pos):
	for x in range(-25, 25):
		for y in range(-25, 25):
			plan_room(start_pos + Vector2(x, y))
	return prepared_cells

func plan_room(room_pos : Vector2):
	for x in range(1, ROOM_SIZE.x):
		# TODO: вставлять плитку через for?
		var cell_pos1 = room_to_map(room_pos) + Vector2i(x, 1)
		var cell_pos2 = room_to_map(room_pos) + Vector2i(x, ROOM_SIZE.y - 1)
		prepared_cells.append(cell_pos1)
		prepared_cells.append(cell_pos2)
		prepared_cells.append_array([
			cell_pos1 + Vector2i(1, 0),
			cell_pos1 + Vector2i(-1, 0),
			cell_pos1 + Vector2i(0, 1),
			cell_pos1 + Vector2i(0, -1)
		])
		prepared_cells.append_array([
			cell_pos2 + Vector2i(1, 0),
			cell_pos2 + Vector2i(-1, 0),
			cell_pos2 + Vector2i(0, 1),
			cell_pos2 + Vector2i(0, -1)
		])
		
	for y in range(1, ROOM_SIZE.y):
		var cell_pos1 = room_to_map(room_pos) + Vector2i(1, y)
		var cell_pos2 = room_to_map(room_pos) + Vector2i(ROOM_SIZE.x - 1, y)
		prepared_cells.append(cell_pos1)
		prepared_cells.append(cell_pos2)
		prepared_cells.append_array([
			cell_pos1 + Vector2i(1, 0),
			cell_pos1 + Vector2i(-1, 0),
			cell_pos1 + Vector2i(0, 1),
			cell_pos1 + Vector2i(0, -1)
		])
		prepared_cells.append_array([
			cell_pos2 + Vector2i(1, 0),
			cell_pos2 + Vector2i(-1, 0),
			cell_pos2 + Vector2i(0, 1),
			cell_pos2 + Vector2i(0, -1)
		])

func build(cells : Array):
	set_cells_terrain_connect(cells, 0, 0, false)
	prepared_cells.clear()

func room_to_map(room_position : Vector2i) -> Vector2i:
	return room_position * ROOM_SIZE
func map_to_room(map_position : Vector2) -> Vector2i:
	return Vector2i(
		floori(map_position.x / ROOM_SIZE.x),
		floori(map_position.y / ROOM_SIZE.y)
		)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		clear()
		$bg.clear()
		Elevator.results()
func _exit_tree() -> void:
	generation_thread.wait_to_finish()
