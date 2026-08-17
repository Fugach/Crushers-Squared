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
	gen_dungeon(rooms_amount, Vector2(3, 2))

func gen_dungeon(rooms_amount, start_pos):
	GlobalVars.passed_layers += 1
	total_rooms = 0
	total_lights = 0
	total_doors = 0
	clear()
	for body in get_children():
		if body is RigidBody2D:
			body.queue_free()
		else:
			for thing in del_list:
				if str(thing) in str(body):
					body.free()
			#if body.is_queued_for_deletion():
				#pass
			#else:
				#print("SAVING", body)
	$bg.clear()
	
	room_anchor = start_pos
	room_size = Vector2(15, 8)
	gen_direction.x = [-1, 1].pick_random()
	print("Generating ", str(rooms_amount),  " rooms", " ||| Direction: ", gen_direction)
	Table.reroll()
	generate_room(room_anchor, room_size, room_doors, doors_height, false)
	Table.global_position = (room_anchor + room_size + Vector2(-5, -1)) * 16 + Vector2(8, 6)
	Elevator_fake.global_position = (room_anchor + room_size + Vector2(-7, -1)) * 16 + Vector2(-8, 0)
	GlobalVars.spawn_pos = Elevator_fake.global_position + Vector2(0, 12)
	player = GlobalVars.player
	#player.respawn()
	
	for o in range(rooms_amount):
		old_room_anchor = room_anchor
		old_room_size = room_size
		old_room_doors_height = doors_height
		
		room_size = Vector2(randi_range(10, 20), randi_range(8, 15))
		if gen_direction.x == 1:
			room_anchor += Vector2(old_room_size.x + 5, old_room_size.y - room_size.y)
		elif gen_direction.x == -1:
			room_anchor += Vector2(-5 + room_size.x * -1, old_room_size.y - room_size.y)
		
		if o != rooms_amount - 1:
			generate_room(room_anchor, room_size, "both", doors_height, true)
			if gen_direction.x == 1:
				hall_pos1 = old_room_anchor + old_room_size
				hall_pos2 = room_anchor + Vector2(0, room_size.y)
				generate_hall(hall_pos1, hall_pos2)
			elif gen_direction.x == -1:
				hall_pos1 = room_anchor + room_size
				hall_pos2 = old_room_anchor + Vector2(0, old_room_size.y)
				generate_hall(hall_pos1, hall_pos2)
		else:
			if gen_direction.x == 1:
				Elevator.global_position = (room_anchor - Vector2(3, 1) + room_size) * Vector2(16, 16)
				generate_room(room_anchor, room_size, "left", doors_height, false)
				hall_pos1 = old_room_anchor + old_room_size
				hall_pos2 = room_anchor + Vector2(0, room_size.y)
				generate_hall(hall_pos1, hall_pos2)
			elif gen_direction.x == -1:
				Elevator.global_position = (room_anchor + Vector2(4, room_size.y - 1)) * Vector2(16, 16)
				generate_room(room_anchor, room_size, "right", doors_height, false)
				hall_pos1 = room_anchor + room_size
				hall_pos2 = old_room_anchor + Vector2(0, old_room_size.y)
				generate_hall(hall_pos1, hall_pos2)
	
	print("Generation is finished")
	GlobalVars.time = 0.0
	GlobalVars.is_time_running = true

func generate_room(pos, size, doors, height, enemies):
	var new_room = ROOM.instantiate()
	new_room.activation_range = (room_size + Vector2(1, 1)) * 16
	new_room.global_position = room_anchor * 16
	new_room.name = "Room" + str(total_rooms)
	new_room.room_number = total_rooms
	total_rooms += 1
	add_child(new_room)
	
	if gen_direction.x == -1 or total_rooms > 1:
		var new_door = DOOR.instantiate()
		new_door.scale.x = [-1, 1].pick_random()
		new_door.global_position = (pos + Vector2(0, size.y - 1)) * Vector2(16, 16)
		new_door.name = "Door" + str(total_doors)
		total_doors += 1
		new_room.door1 = new_door
		add_child(new_door)
	if gen_direction.x == 1 or total_rooms > 1:
		var new_door = DOOR.instantiate()
		new_door.scale.x = [-1, 1].pick_random()
		new_door.global_position = (pos + Vector2(size.x + 1, size.y - 1)) * Vector2(16, 16)
		new_door.name = "Door" + str(total_doors)
		total_doors += 1
		new_room.door2 = new_door
		add_child(new_door)
	
	if total_rooms > 0:
		GlobalVars.cleared_rooms["Room" + str(total_rooms)] = false
	var new_light = LIGHTS.instantiate()
	new_light.global_position = pos * 16 + Vector2(size.x / 2, 1) * 16
	new_light.light_scale = size.y / 5
	new_light.name = "Light_" + str(total_lights)
	total_lights += 1
	add_child(new_light)
	
	for x in range(size.x):
		if x == 0:
			set_cell(pos + Vector2(x, -1), 0, Vector2(6, 0))
			set_cell(pos + Vector2(x, size.y + 1), 0, Vector2(6, 0))
			set_cell(pos + Vector2(size.x, -1), 0, Vector2(6, 0))
			set_cell(pos + Vector2(size.x, size.y + 1), 0, Vector2(6, 0))
			
			set_cell(pos + Vector2(x, 0), 0, Vector2(3, 3))
			set_cell(pos + Vector2(x, size.y), 0, Vector2(3, 4))
			
			set_cell(pos + Vector2(x, -2), 0, Vector2(8, 1))
			set_cell(pos + Vector2(x, size.y + 2), 0, Vector2(7, 1))
			continue
		set_cell(pos + Vector2(x, -1), 0, Vector2(6, 0))
		set_cell(pos + Vector2(x, size.y + 1), 0, Vector2(6, 0))
		
		set_cell(pos + Vector2(x, 0), 0, Vector2(1, 2))
		set_cell(pos + Vector2(x, size.y), 0, Vector2(2, 2))
		set_cell(pos + Vector2(x, -2), 0, Vector2(8, 1))
		set_cell(pos + Vector2(x, size.y + 2), 0, Vector2(7, 1))
	for y in range(size.y):
		if y == 0:
			set_cell(pos + Vector2(size.x + 1, y), 0, Vector2(6, 0))
			set_cell(pos + Vector2(size.x + 1, size.y), 0, Vector2(6, 0))
			set_cell(pos + Vector2(-1, y), 0, Vector2(6, 0))
			set_cell(pos + Vector2(-1, size.y), 0, Vector2(6, 0))
			
			set_cell(pos + Vector2(size.x, y), 0, Vector2(4, 3))
			set_cell(pos + Vector2(size.x, size.y), 0, Vector2(4, 4))
			
			set_cell(pos + Vector2(-2, y), 0, Vector2(7, 2))
			set_cell(pos + Vector2(size.x + 2, y), 0, Vector2(8, 2))
			continue
		set_cell(pos + Vector2(size.x + 1, y), 0, Vector2(6, 0))
		set_cell(pos + Vector2(-1, y), 0, Vector2(6, 0))
		
		set_cell(pos + Vector2(0, y), 0, Vector2(3, 2))
		set_cell(pos + Vector2(size.x, y), 0, Vector2(4, 2))
		set_cell(pos + Vector2(-2, y), 0, Vector2(7, 2))
		set_cell(pos + Vector2(size.x + 2, y), 0, Vector2(8, 2))
	
	for x in range(size.x):
		for y in range(size.y):
			if total_rooms > 1:
				$bg.set_cell(pos + Vector2(x, y), 0, Vector2(0, randi_range(0, 15)))
			else:
				$bg.set_cell(pos + Vector2(x, y), 0, Vector2(1, 0))
				if y > size.y - 4:
					if gen_direction.x == -1 and x == 1:
						$bg.set_cell(pos + Vector2(x, y), 0, Vector2(1, 1))
					elif gen_direction.x == 1 and x == size.x - 1:
						$bg.set_cell(pos + Vector2(x, y), 0, Vector2(1, 2))
	
	set_cell(pos + Vector2(-1, -1), 0, Vector2(6, 0))
	set_cell(pos + Vector2(-1, size.y + 1), 0, Vector2(6, 0))
	set_cell(pos + Vector2(size.x + 1, -1), 0, Vector2(6, 0))
	set_cell(pos + size + Vector2(1, 1), 0, Vector2(6, 0))
	
	set_cell(pos + Vector2(-2, -1), 0, Vector2(7, 2))
	set_cell(pos + Vector2(-1, -2), 0, Vector2(8, 1))
	set_cell(pos + Vector2(-2, -2), 0, Vector2(8, 3))
	
	set_cell(pos + size + Vector2(2, 0), 0, Vector2(8, 2))
	set_cell(pos + size + Vector2(2, 1), 0, Vector2(8, 2))
	set_cell(pos + size + Vector2(0, 2), 0, Vector2(7, 1))
	set_cell(pos + size + Vector2(1, 2), 0, Vector2(7, 1))
	set_cell(pos + size + Vector2(2, 2), 0, Vector2(7, 3))
	
	set_cell(pos + Vector2(-1, size.y + 2), 0, Vector2(7, 1))
	set_cell(pos + Vector2(-2, size.y + 1), 0, Vector2(7, 2))
	set_cell(pos + Vector2(-2, size.y), 0, Vector2(7, 2))
	set_cell(pos + Vector2(-2, size.y + 2), 0, Vector2(7, 4))
	
	set_cell(pos + Vector2(size.x + 1, -2), 0, Vector2(8, 1))
	set_cell(pos + Vector2(size.x, -2), 0, Vector2(8, 1))
	set_cell(pos + Vector2(size.x + 2, -1), 0, Vector2(8, 2))
	set_cell(pos + Vector2(size.x + 2, -2), 0, Vector2(8, 4))
	
func generate_hall(pos1, pos2):
	for x in range(3):
		for y in range(-1, 3):
			erase_cell(pos1 + Vector2(x, y - 3))
			$bg.set_cell(pos1 + Vector2(x, y - 3), 0, Vector2(0, randi_range(0, 15)))
	set_cell(pos1 + Vector2(0, -4), 0, Vector2(6, 1))
	set_cell(pos1 + Vector2(1, -4), 0, Vector2(1, 2))
	set_cell(pos1 + Vector2(2, -4), 0, Vector2(9, 1))
	set_cell(pos1 + Vector2(0, 0), 0, Vector2(2, 2))
	set_cell(pos1 + Vector2(1, 0), 0, Vector2(2, 2))
	set_cell(pos1 + Vector2(2, 0), 0, Vector2(2, 2))
	
	for x in range(3):
		for y in range(3):
			erase_cell(pos2 + Vector2(x - 2, y - 3))
			$bg.set_cell(pos1 + Vector2(x + 3, y - 3), 0, Vector2(0, randi_range(0, 15)))
	set_cell(pos2 + Vector2(0, -4), 0, Vector2(5, 1))
	set_cell(pos2 + Vector2(-1, -4), 0, Vector2(1, 2))
	set_cell(pos2 + Vector2(-2, -4), 0, Vector2(9, 2))
	set_cell(pos2 + Vector2(0, 0), 0, Vector2(2, 2))
	set_cell(pos2 + Vector2(-1, 0), 0, Vector2(2, 2))
	set_cell(pos2 + Vector2(-2, 0), 0, Vector2(2, 2))
	
	set_cell(pos1 + Vector2(1, -4), 0, Vector2(2, 1))
	set_cell(pos2 + Vector2(-1, -4), 0, Vector2(3, 1))
	
	set_cell(pos1 + Vector2(1, -3), 0, Vector2(1, 1))
	set_cell(pos2 + Vector2(-1, -3), 0, Vector2(4, 1))
	var new_light = LIGHTS.instantiate()
	new_light.global_position = pos1 * 16 + Vector2(1, -3) * 16 - Vector2(2, -8)
	new_light.global_rotation = PI / 2
	new_light.light_scale = 0.8
	new_light.name = "Light_" + str(total_lights)
	total_lights += 1
	add_child(new_light)
	
	new_light = LIGHTS.instantiate()
	new_light.global_position = pos2 * 16 - Vector2(0, 3) * 16 + Vector2(2, 8)
	new_light.global_rotation = PI / -2
	new_light.light_scale = 0.8
	new_light.name = "Light_" + str(total_lights)
	total_lights += 1
	add_child(new_light)

func command():
	#     ____________
	#   /   П П П П    \
	#  |    П П П П     |
	#  |    П_П_П_П  Л  |
	#  |   |=======~//  |
	#   \  |========/  /
	#     -------------
	while true:
		set_cell(Vector2(randi_range(-50, 50), randi_range(-50, 50)), 0, Vector2(7, 0))
		await get_tree().process_frame

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		clear()
		$bg.clear()
		Elevator.results()
