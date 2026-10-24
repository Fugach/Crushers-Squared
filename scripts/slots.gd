extends Control

@onready var ui_slots : Array[Node2D] = [get_node("0")]
@onready var Border: Sprite2D = $Current

var current : int = 0
const SLOT = preload("uid://c3qxg2ahr7shg")

func _ready() -> void:
	update()
	Border.global_position = ui_slots.get(current).global_position


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		add_slot()
	Border.global_position = lerp(
		Border.global_position,
		ui_slots.get(current).global_position,
		25 * delta
	)

func add_slot():
	if len(ui_slots) > 8:
		return
	GlobalVars.player.inventory[len(GlobalVars.player.inventory)] = null
	var new_slot = SLOT.instantiate()
	new_slot.name = str(int(ui_slots[len(ui_slots) - 1].name) + 1)
	new_slot.play('empty')
	add_child(new_slot)
	ui_slots.append(new_slot)
	update()

func update():
	for i in len(ui_slots):
		match GlobalConfig.get_value('hud', 'Hotbar_layout'):
			'VERTICAL':
				ui_slots[i].position = Vector2(
					10,
					get_viewport_rect().size.y / 2.0 + i * 18 + (2 * i) - (len(ui_slots) * 18 / 2.0)
				)
			'HORIZONTAL':
				ui_slots[i].position = Vector2(
					get_viewport_rect().size.x / 2.0 + i * 18 + (2 * i) - (len(ui_slots) * 18 / 2.0),
					10
				)
	if GlobalVars.player == null:
		return
	for i in len(ui_slots):
		if GlobalVars.player.inventory[i] != null:
			if ui_slots[i].sprite_frames.has_animation(GlobalVars.player.inventory[i].my_name):
				ui_slots[i].play(GlobalVars.slots[i].my_name)
			else:
				ui_slots[i].play('unknown')
		else:
			ui_slots[i].play('empty')
