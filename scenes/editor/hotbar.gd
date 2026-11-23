extends Control

var sizes : Array = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
@onready var slots : Array = [$Slot1, $Slot2, $Slot3, $Slot4, $Slot5, $Slot6, $Slot7, $Slot8, $Slot9]

func _ready() -> void:
	for i in range(len(slots)):
		slots[i].mouse_entered.connect(func(id = i): sizes[id] = 1.2)
		slots[i].mouse_exited.connect(func(id = i): sizes[id] = 1.0)

func _process(delta: float) -> void:
	for i in range(len(slots)):
		slots[i].scale = Vector2.ONE * lerpf(slots[i].scale.x, sizes[i], 0.5)
