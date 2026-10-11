extends Control

@onready var slots_as_nodes : Array[Node2D] = [get_node("0")]
@onready var Current: Sprite2D = $Current
@onready var Camera: Camera2D = $"../../../Camera2D"
const SLOT = preload("uid://c3qxg2ahr7shg")

func _ready() -> void:
	update()
	Current.global_position = slots_as_nodes.get(GlobalVars.current_slot_num).global_position


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		add_slot()
	Current.global_position = lerp(
		Current.global_position,
		slots_as_nodes.get(GlobalVars.current_slot_num).global_position,
		25 * delta
	)

func add_slot():
	if len(slots_as_nodes) > 8:
		return
	GlobalVars.slots[len(GlobalVars.slots)] = null
	var new_slot = SLOT.instantiate()
	new_slot.name = str(int(slots_as_nodes[len(slots_as_nodes) - 1].name) + 1)
	new_slot.play('empty')
	add_child(new_slot)
	slots_as_nodes.append(new_slot)
	update()
	print(GlobalVars.slots)
	print(slots_as_nodes)

func update():
	print("TEST ", GlobalConfig.set_value('hud', 'Hotbar_layout', 'HORIZONTAL'))
	for i in len(slots_as_nodes):
		match GlobalConfig.get_value('hud', 'Hotbar_layout'):
			'VERTICAL':
				slots_as_nodes[i].position = Vector2(
					10,
					get_viewport_rect().size.y / 2 + i * 18 + (2 * i) - (len(slots_as_nodes) * 18 / 2)
				)
			'HORIZONTAL':
				slots_as_nodes[i].position = Vector2(
					get_viewport_rect().size.x / 2 + i * 18 + (2 * i) - (len(slots_as_nodes) * 18 / 2),
					10
				)
	GlobalVars.current_slot_node = GlobalVars.slots.get(GlobalVars.current_slot_num)
	for i in len(slots_as_nodes):
		if GlobalVars.slots[i] != null:
			print(GlobalVars.current_slot_node)
			slots_as_nodes[i].play(GlobalVars.slots[i].my_name)
		else:
			slots_as_nodes[i].play('empty')
