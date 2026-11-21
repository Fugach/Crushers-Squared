extends Control

var sizes : Array = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
@onready var slots : Array = [$Slot1, $Slot2, $Slot3, $Slot4, $Slot5, $Slot6, $Slot7, $Slot8, $Slot9]

func _process(delta: float) -> void:
	for i in range(len(slots)):
		slots[i].scale = Vector2.ONE * lerpf(slots[i].scale.x, sizes[i], 0.5)


func _on_slot_1_mouse_entered() -> void:
	sizes[0] = 1.2
func _on_slot_1_mouse_exited() -> void:
	sizes[0] = 1.0

func _on_slot_2_mouse_entered() -> void:
	sizes[1] = 1.2
func _on_slot_2_mouse_exited() -> void:
	sizes[1] = 1.0

func _on_slot_3_mouse_entered() -> void:
	sizes[2] = 1.2
func _on_slot_3_mouse_exited() -> void:
	sizes[2] = 1.0

func _on_slot_4_mouse_entered() -> void:
	sizes[3] = 1.2
func _on_slot_4_mouse_exited() -> void:
	sizes[3] = 1.0

func _on_slot_5_mouse_entered() -> void:
	sizes[4] = 1.2
func _on_slot_5_mouse_exited() -> void:
	sizes[4] = 1.0

func _on_slot_6_mouse_entered() -> void:
	sizes[5] = 1.2
func _on_slot_6_mouse_exited() -> void:
	sizes[5] = 1.0

func _on_slot_7_mouse_entered() -> void:
	sizes[6] = 1.2
func _on_slot_7_mouse_exited() -> void:
	sizes[6] = 1.0

func _on_slot_8_mouse_entered() -> void:
	sizes[7] = 1.2
func _on_slot_8_mouse_exited() -> void:
	sizes[7] = 1.0

func _on_slot_9_mouse_entered() -> void:
	sizes[8] = 1.2
func _on_slot_9_mouse_exited() -> void:
	sizes[8] = 1.0
