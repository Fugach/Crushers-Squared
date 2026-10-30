extends Node2D

var ROCKET = GlobalVars.ROCKET

@onready var Sprite : Node2D = $Sprite2D
@onready var Spawnpoint : Marker2D = $Sprite2D/Spawnpoint
@onready var ShootCooldown = $ShootCooldown
@onready var GrabLeft = $Sprite2D/GrabLeft
@onready var GrabRight = $Sprite2D/GrabRight
@onready var Anims: AnimationPlayer = $AnimationPlayer


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
	Anims.play("shoot")
	$shoot.pitch_scale = randf_range(0.8, 1.2)
	$shoot.play()
	var new_rocket = ROCKET.instantiate()
	new_rocket.global_position = Spawnpoint.global_position
	new_rocket.global_rotation = Spawnpoint.global_rotation
	new_rocket.damage_amount = 25
	new_rocket.my_owner = my_owner
	get_node("/root/main").add_child(new_rocket)
	#$Sprite2D/Cloud.initial_velocity_max += (GlobalVars.player.velocity.x + GlobalVars.player.velocity.y) * 1.25
	#$Sprite2D/Cloud.initial_velocity_min += (GlobalVars.player.velocity.x + GlobalVars.player.velocity.y) * 1.25
	#$Sprite2D/Cloud.emitting = true
	#$Sprite2D/Clouds_small.amount = randi_range(1, 3)
	#$Sprite2D/Clouds_small.initial_velocity_max += (GlobalVars.player.velocity.x + GlobalVars.player.velocity.y) * 1.25
	#$Sprite2D/Clouds_small.initial_velocity_min += (GlobalVars.player.velocity.x + GlobalVars.player.velocity.y) * 1.25
	#$Sprite2D/Clouds_small.emitting = true

func pull_out():
	Anims.play("pull_out")
func put_away():
	Anims.play("put_away")

func _on_cooldown_timeout() -> void:
	can_shoot = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'pull_out':
		can_shoot = true
