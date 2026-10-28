extends Node2D

var ROCKET = GlobalVars.ROCKET

@onready var Sprite : Node2D = $RL_sprite
@onready var ShootPos : Marker2D = $RL_sprite/shoot_pos
@onready var ShootCooldown = $ShootCooldown

var can_shoot: bool = true
var current_angle: float = 0.0
var my_owner
const my_name = "rocket_launcher"

func _process(delta: float) -> void:
	if my_owner == GlobalVars.player:
		logic_player()

func logic_player():
	var angle = int(global_rotation_degrees) % 360
	if abs(angle) < 90:
		Sprite.scale.y = 1
	else:
		Sprite.scale.y = -1

func shoot():
	if not can_shoot:
		return
	else:
		can_shoot = false
	ShootCooldown.start()
	$AnimationPlayer.play("shoot")
	$shoot.pitch_scale = randf_range(0.8, 1.2)
	$shoot.play()
	var new_rocket = ROCKET.instantiate()
	new_rocket.global_position = ShootPos.global_position
	new_rocket.global_rotation = ShootPos.global_rotation
	new_rocket.damage_amount = 25
	new_rocket.my_owner = my_owner
	get_node("/root/main").add_child(new_rocket)
	#$RL_sprite/Cloud.initial_velocity_max += (GlobalVars.player.velocity.x + GlobalVars.player.velocity.y) * 1.25
	#$RL_sprite/Cloud.initial_velocity_min += (GlobalVars.player.velocity.x + GlobalVars.player.velocity.y) * 1.25
	#$RL_sprite/Cloud.emitting = true
	#$RL_sprite/Clouds_small.amount = randi_range(1, 3)
	#$RL_sprite/Clouds_small.initial_velocity_max += (GlobalVars.player.velocity.x + GlobalVars.player.velocity.y) * 1.25
	#$RL_sprite/Clouds_small.initial_velocity_min += (GlobalVars.player.velocity.x + GlobalVars.player.velocity.y) * 1.25
	#$RL_sprite/Clouds_small.emitting = true
	
	can_shoot = false
	ShootCooldown.start()

func pull_out():
	pass
func put_away():
	pass

func _on_cooldown_timeout() -> void:
	can_shoot = true
