extends Node2D

const ROCKET = preload("uid://cfex0tmkaj6q4")

@onready var Sprite : Node2D = $RL_sprite
@onready var ShootPos : Marker2D = $RL_sprite/shoot_pos
@onready var Cooldown : Timer = $cooldown

var is_player_nearby : bool = false
var my_slot : String = ""
var can_shoot: bool = true
var current_angle: float = 0.0
var weapon_owner : String = ""
var is_friendly : bool = false
var is_player_colliding : bool = false
var total_rockets : int = 0
var my_name = "RL"

func _ready():
	GlobalVars.slots[str(my_slot)] = self
	get_node("/root/main/UI/HUD/Slots").update()

func _process(delta: float) -> void:
	match weapon_owner:
		"Player":
			if GlobalVars.current_slot_num == my_slot:
				visible = true
				RL_logic(delta)
			else:
				visible = false
		"Enemy":
			if is_player_colliding and can_shoot:
				is_player_nearby = true
			else:
				is_player_nearby = false
			RL_logic(delta)

func RL_logic(delta):
	if weapon_owner == "Player":
		look_at(get_global_mouse_position())
		current_angle = (get_global_mouse_position() - global_position).normalized().angle()
	elif weapon_owner == "Enemy":
		look_at(GlobalVars.player.global_position)
		current_angle = (GlobalVars.player.global_position - global_position).normalized().angle()
	
	if -1.5 <= current_angle and current_angle <= 1.5:
		Sprite.scale.y = 1
	else:
		Sprite.scale.y = -1

	if Input.is_action_pressed("lmb") and can_shoot and weapon_owner == "Player":
		shoot(25, true)

func shoot(damage_amount, is_friendly):
	$AnimationPlayer.play("shoot")
	$shoot.pitch_scale = randf_range(0.8, 1.2)
	$shoot.play()
	var new_rocket = ROCKET.instantiate()
	new_rocket.global_position = ShootPos.global_position
	new_rocket.global_rotation = ShootPos.global_rotation
	new_rocket.damage_amount = damage_amount
	new_rocket.is_friendly = is_friendly
	new_rocket.name = "Rocket" + str(total_rockets)
	total_rockets += 1
	get_node("/root/main").add_child(new_rocket)
	$RL_sprite/Clouds_small.amount = randi_range(1, 3)
	$RL_sprite/Cloud.initial_velocity_max += (GlobalVars.player_velocity.x + GlobalVars.player_velocity.y) * 1.25
	$RL_sprite/Cloud.initial_velocity_min += (GlobalVars.player_velocity.x + GlobalVars.player_velocity.y) * 1.25
	$RL_sprite/Clouds_small.initial_velocity_max += (GlobalVars.player_velocity.x + GlobalVars.player_velocity.y) * 1.25
	$RL_sprite/Clouds_small.initial_velocity_min += (GlobalVars.player_velocity.x + GlobalVars.player_velocity.y) * 1.25
	$RL_sprite/Cloud.emitting = true
	$RL_sprite/Clouds_small.emitting = true
	
	can_shoot = false
	Cooldown.start()

func _on_cooldown_timeout() -> void:
	can_shoot = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		is_player_colliding = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == GlobalVars.player:
		is_player_colliding = false
