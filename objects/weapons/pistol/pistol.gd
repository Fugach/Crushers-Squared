extends Node2D

@onready var Sprite : Sprite2D = $Sprite2D
@onready var Spawnpoint : Marker2D = $Sprite2D/Spawnpoint
@onready var ShootCooldown : Timer = $ShootCooldown
@onready var Anims = $AnimationPlayer
@onready var GrabLeft = $Sprite2D/GrabLeft
@onready var GrabRight = $Sprite2D/GrabRight

var BULLET = GlobalVars.BULLET
var my_owner
var can_shoot : bool = false
const my_name = "pistol"

func _process(delta: float) -> void:
	logic()

func logic():
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
	$shoot.pitch_scale = randf_range(0.8, 1.2)
	$shoot.play()
	if Sprite.scale.y == 1:
		$AnimationPlayer.play("shoot_right")
	else:
		$AnimationPlayer.play("shoot_left")
	var new_bullet = BULLET.instantiate()
	new_bullet.damage_amount = 15
	new_bullet.my_owner = my_owner
	new_bullet.global_position = Spawnpoint.global_position
	new_bullet.global_rotation = global_rotation
	get_node("/root/main").add_child(new_bullet)
	ShootCooldown.start()

func pull_out():
	can_shoot = false
	Anims.play('pull_out')
func put_away():
	pass


func _on_cooldown_timeout() -> void:
	can_shoot = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'pull_out':
		can_shoot = true
