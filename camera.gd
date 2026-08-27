extends Camera2D

var is_following : bool = true
var is_shaking : bool = false
var shake_power : float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_following:
		#global_position = (GlobalVars.player.global_position + global_position) / 2
		global_position = GlobalVars.player.global_position
		position_smoothing_speed = 10
	if is_shaking:
		global_position += Vector2(randf_range(shake_power * -1, shake_power), randf_range(shake_power * -1, shake_power))
	if Input.is_action_just_released("zoom_in"):
		zoom.x = min(zoom.x + 1.5 * delta, 1.0)
		zoom.y = min(zoom.y + 1.5 * delta, 1.0)
	elif Input.is_action_just_released("zoom_out"):
		zoom.x = max(zoom.x - 1.5 * delta, 0.4)
		zoom.y = max(zoom.y - 1.5 * delta, 0.4)
	if Input.is_action_just_pressed("test1"):
		$AudioStreamPlayer2D.play()
		rotation -= PI / 2
		GlobalVars.player.current_gravity = round(GlobalVars.player.current_gravity.rotated(PI / -2))
		GlobalVars.player.global_rotation = round(rotation)
		#print(GlobalVars.player.global_rotation)
	elif Input.is_action_just_pressed("test2"):
		$AudioStreamPlayer2D.play()
		rotation += PI / 2
		GlobalVars.player.current_gravity = round(GlobalVars.player.current_gravity.rotated(PI / 2))
		GlobalVars.player.global_rotation = round(rotation)
		#print(GlobalVars.player.global_rotation)
func shake(time, power):
	#var last_pos = global_position
	is_shaking = true
	shake_power = power
	position_smoothing_enabled = false
	await get_tree().create_timer(time).timeout
	position_smoothing_enabled = true
	is_shaking = false
	#global_position = last_pos
