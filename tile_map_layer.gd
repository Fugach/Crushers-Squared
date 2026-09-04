extends TileMapLayer

@onready var Elevator : Area2D = $"../Elevator"
@onready var Table: Sprite2D = $"../Table"
@onready var Elevator_fake: Node2D = $"../elevator_fake"
const LIGHTS = preload("uid://cp0ivvdcjm3h4")
const DOOR = preload("uid://lf2qgrhjy7sd")
const ROOM = preload("uid://cxn1pdnonmni6")

var prepared_cells : Array = []
var cells_to_be_removed : Array = []
var generation_thread : Thread
var rooms : Array = []

var total_rooms : int = 0
var player = CharacterBody2D
const ROOM_SIZE = Vector2i(12, 12)

func _ready() -> void:
	player = GlobalVars.player
	GlobalVars.passed_layers = 0
	new_dungeon()

func _process(delta: float) -> void:
	if generation_thread.is_started() and not generation_thread.is_alive():
		var plan = generation_thread.wait_to_finish()
		print("Generation is finished")
		if plan:
			build(plan)
	#var room_col = to_global(map_to_local(map_to_room(local_to_map(to_local(GlobalVars.player.global_position))) * ROOM_SIZE + ROOM_SIZE / 2))
	#if $Area2D/CollisionShape2D.global_position != room_col:
		#$Area2D/CollisionShape2D.global_position = room_col

func new_dungeon():
	clear()
	rooms.clear()
	prepared_cells.clear()
	cells_to_be_removed.clear()
	generation_thread = Thread.new()
	print("=== NEW DUNGEON ===")
	if generation_thread.is_alive():
		print("Killing old generation thread...")
		generation_thread.wait_to_finish()
		if not generation_thread.is_alive():
			print("Done, now making everything clean...")
			clear()
			rooms.clear()
			prepared_cells.clear()
			cells_to_be_removed.clear()
		else:
			push_error("Couldn't kill the thread!")
	print('Starting new generation thread...')
	collision_enabled = false
	var rooms_amount = randi_range(4, 100)
	generation_thread.start(generate.bind(rooms_amount, Vector2(0, 0)))
	if generation_thread.is_alive():
		print("Generation thread is alive!")
	else:
		print("Generarion thread is dead!")
		push_error("Generation thread is dead!")
	print("Planning ", rooms_amount, " rooms...")

func generate(rooms_amount, start_pos : Vector2i):
	var direction = [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT].pick_random()
	#plan_room(start_pos)
	var pos : Vector2i = start_pos
	for x in range(rooms_amount):
		if randi_range(1, 4) > 2:
			direction = direction.rotated([PI / 2, PI / -2].pick_random())
		while rooms.has(pos + Vector2i(direction)):
			direction = direction.rotated([PI / 2, PI / -2].pick_random())
			print("WRONG!")
		if len(rooms) == 0:
			plan_room(pos)
			pos += Vector2i(direction)
			continue
		plan_room(pos)
		connect_room(pos, rooms[x - 1])
		pos += Vector2i(direction)
	prepared_cells = prepared_cells.filter(func(cell): return not cells_to_be_removed.has(cell))
	print("Planning is finished, now waiting for build...")
	return prepared_cells

func plan_room(room_pos : Vector2):
	rooms.append(room_pos)
	for x in range(1, ROOM_SIZE.x - 1):
		# TODO: вставлять плитку через for?
		var cell_pos1 = room_to_map(room_pos) + Vector2i(x, 1)
		var cell_pos2 = room_to_map(room_pos) + Vector2i(x, ROOM_SIZE.y - 1)
		prepared_cells.append(cell_pos1)
		prepared_cells.append(cell_pos2)
		prepared_cells.append_array([
			cell_pos1 + Vector2i.RIGHT,
			cell_pos1 + Vector2i.LEFT,
			cell_pos1 + Vector2i.UP,
			cell_pos1 + Vector2i.DOWN,
			
			cell_pos2 + Vector2i.RIGHT,
			cell_pos2 + Vector2i.LEFT,
			cell_pos2 + Vector2i.UP,
			cell_pos2 + Vector2i.DOWN
		])
		
	for y in range(1, ROOM_SIZE.y):
		var cell_pos1 = room_to_map(room_pos) + Vector2i(1, y)
		var cell_pos2 = room_to_map(room_pos) + Vector2i(ROOM_SIZE.x - 1, y)
		prepared_cells.append(cell_pos1)
		prepared_cells.append(cell_pos2)
		prepared_cells.append_array([
			cell_pos1 + Vector2i.RIGHT,
			cell_pos1 + Vector2i.LEFT,
			cell_pos1 + Vector2i.UP,
			cell_pos1 + Vector2i.DOWN,
			
			cell_pos2 + Vector2i.RIGHT,
			cell_pos2 + Vector2i.LEFT,
			cell_pos2 + Vector2i.UP,
			cell_pos2 + Vector2i.DOWN
		])

func connect_room(room2_pos : Vector2i, room1_pos : Vector2i):
	#print('trying to connect room ', room1_pos, ' and ', room2_pos)
	if room1_pos.distance_to(room2_pos) > 1 or\
	(abs(room1_pos.x - room2_pos.x) > 0 and abs(room1_pos.y - room2_pos.y) > 0):
		#print("err, too far away")
		return -1
	var rooms_delta = room2_pos - room1_pos
	var door_pos : Vector2i = Vector2i.ZERO
	if rooms_delta.x > 0:
		door_pos = room_to_map(room1_pos) + Vector2i(ROOM_SIZE.x - 2, 3)
	elif rooms_delta.x < 0:
		door_pos = room_to_map(room2_pos) + Vector2i(ROOM_SIZE.x - 2, 3)
	elif rooms_delta.y < 0:
		door_pos = room_to_map(room2_pos) + Vector2i(3, ROOM_SIZE.y - 3)
	elif rooms_delta.y > 0:
		door_pos = room_to_map(room1_pos) + Vector2i(3, ROOM_SIZE.y - 3)
	
	for x in range(ROOM_SIZE.x - 5):
		for y in range(ROOM_SIZE.y - 5):
			cells_to_be_removed.append(door_pos + Vector2i(x, y))
	#print('success!')
	return 0

func build(cells : Array):
	set_cells_terrain_connect(cells, 0, 0)
	collision_enabled = true
	prepared_cells.clear()
	cells_to_be_removed.clear()

func room_to_map(room_position : Vector2i) -> Vector2i:
	return room_position * ROOM_SIZE + room_position
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
