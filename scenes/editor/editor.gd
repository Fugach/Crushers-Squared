extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var moving_tip_visibility_time: Timer = $CanvasLayer/UI/MovingTip/VisibilityTime
@onready var camera_move_timeout: Timer = $Camera2D/MoveTimeout
@onready var Hotbar: Control = $CanvasLayer/UI/Hotbar
@onready var build_menu: HSplitContainer = $CanvasLayer/UI/BuildMenu
@onready var CategoriesCont: VBoxContainer = $CanvasLayer/UI/BuildMenu/Categories/VBoxContainer
@onready var ItemsCont: GridContainer = $CanvasLayer/UI/BuildMenu/Items/List


@onready var slots : Array = [
	$CanvasLayer/UI/Hotbar/Slot1, 
	$CanvasLayer/UI/Hotbar/Slot2, 
	$CanvasLayer/UI/Hotbar/Slot3, 
	$CanvasLayer/UI/Hotbar/Slot4, 
	$CanvasLayer/UI/Hotbar/Slot5, 
	$CanvasLayer/UI/Hotbar/Slot6, 
	$CanvasLayer/UI/Hotbar/Slot7, 
	$CanvasLayer/UI/Hotbar/Slot8, 
	$CanvasLayer/UI/Hotbar/Slot9,
]

var camera_acceleration : float = 1.0

func _ready() -> void:
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	for i in range(len(slots)):
		slots[i].position.x = (18 + 2) * i - 20 * len(slots) / 2
	$AnimationPlayer.play("how2move")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed('open_build_menu'):
		build_menu.show()
	elif Input.is_action_just_released('open_build_menu'):
		build_menu.hide()
	elif Input.get_vector('move_left', 'move_right', 'move_up', 'move_down') != Vector2.ZERO:
		camera_move_timeout.start()
		camera.global_position += camera_acceleration * Input.get_vector(
			'move_left',
			'move_right',
			'move_up',
			'move_down'
		)
		if Input.is_action_pressed('slam'):
			camera_acceleration = 5.0
		else:
			camera_acceleration = clampf(camera_acceleration + delta * 2, 1.0, 5.0)
		
		if is_instance_valid(moving_tip_visibility_time):
			if moving_tip_visibility_time.is_stopped():
				moving_tip_visibility_time.start()

#func _on_sub_viewport_size_changed() -> void:
	#print('hello')
	#print(sub_viewport.size)
	#Hotbar.position = Vector2(float(sub_viewport.size.x) / 2 - 9 * 10 + 2, float(sub_viewport.size.y) - 20)

# ------ СИГНАЛЫ ОТ ТАЙМЕРОВ ------

func _on_move_timeout_timeout() -> void:
	camera_acceleration = 0.0

func _on_visibility_time_timeout() -> void:
	$AnimationPlayer.stop()
	$CanvasLayer/UI/MovingTip.call_deferred('queue_free')
