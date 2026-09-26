extends Node2D

@onready var Slot1 : AnimatedSprite2D = $Slot1
@onready var Slot2 : AnimatedSprite2D = $Slot2
@onready var Slot3 : AnimatedSprite2D = $Slot3
@onready var Current: Sprite2D = $Current
@onready var Camera: Camera2D = $"../../../Camera2D"

func _ready() -> void:
	update()

func _process(delta: float) -> void:
	match GlobalVars.current_slot_num:
		"slot1":
			Current.global_position = lerp(Current.global_position, Slot1.global_position, 15 * delta)
		"slot2":
			Current.global_position = lerp(Current.global_position, Slot2.global_position, 15 * delta)
		"slot3":
			Current.global_position = lerp(Current.global_position, Slot3.global_position, 15 * delta)

func update():
	GlobalVars.current_slot_node = GlobalVars.slots[GlobalVars.current_slot_num]
	if GlobalVars.current_slot_node == null:
		$empty.play()
		Camera.position_smoothing_speed = 2
	else:
		Camera.position_smoothing_speed = 10
	
	if GlobalVars.slots["slot1"] != null:
		Slot1.play(GlobalVars.slots["slot1"].my_name)
	elif GlobalVars.slots["slot1"] == null:
		Slot1.play("empty")
	else:
		Slot1.play("unknown")
		push_error('unkown thing in slot 1: ', GlobalVars.slots["slot1"])
	
	if GlobalVars.slots["slot2"] != null:
		Slot2.play(GlobalVars.slots["slot2"].my_name)
	elif GlobalVars.slots["slot2"] == null:
		Slot2.play("empty")
	else:
		Slot2.play("unknown")
		push_error('unkown thing in slot 2: ', GlobalVars.slots["slot2"])
	
	if GlobalVars.slots["slot3"] != null:
		Slot3.play(GlobalVars.slots["slot3"].my_name)
	elif GlobalVars.slots["slot3"] == null:
		Slot3.play("empty")
	else:
		Slot3.play("unknown")
		push_error('unkown thing in slot 3: ', GlobalVars.slots["slot3"])
