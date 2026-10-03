extends Control

@onready var slots_as_nodes : Array[Node2D] = [$Slot0, $Slot1, $Slot2]
@onready var Current: Sprite2D = $Current
@onready var Camera: Camera2D = $"../../../Camera2D"

func _ready() -> void:
	update()

func _process(delta: float) -> void:
	Current.global_position = lerp(
		Current.global_position,
		slots_as_nodes.get(GlobalVars.current_slot_num).global_position,
		25 * delta
	)

func update():
	GlobalVars.current_slot_node = GlobalVars.slots.get(GlobalVars.current_slot_num)
	if GlobalVars.current_slot_node == null:
		$empty.play()
		Camera.position_smoothing_speed = 2
	else:
		Camera.position_smoothing_speed = 10
	
	for slot in GlobalVars.slots:
		if GlobalVars.slots[slot] != null:
			print("yes")
			pass
	#if GlobalVars.slots["slot1"] != null:
		#Slot1.play(GlobalVars.slots["slot1"].my_name)
	#elif GlobalVars.slots["slot1"] == null:
		#Slot1.play("empty")
	#else:
		#Slot1.play("unknown")
		#push_error('unkown thing in slot 1: ', GlobalVars.slots["slot1"])
	#
	#if GlobalVars.slots["slot2"] != null:
		#Slot2.play(GlobalVars.slots["slot2"].my_name)
	#elif GlobalVars.slots["slot2"] == null:
		#Slot2.play("empty")
	#else:
		#Slot2.play("unknown")
		#push_error('unkown thing in slot 2: ', GlobalVars.slots["slot2"])
	#
	#if GlobalVars.slots["slot3"] != null:
		#Slot3.play(GlobalVars.slots["slot3"].my_name)
	#elif GlobalVars.slots["slot3"] == null:
		#Slot3.play("empty")
	#else:
		#Slot3.play("unknown")
		#push_error('unkown thing in slot 3: ', GlobalVars.slots["slot3"])
