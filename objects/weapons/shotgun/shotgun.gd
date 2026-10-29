extends Node2D

@onready var Sprite : Sprite2D = $Sprite2D
@onready var Spawnpoint : Marker2D = $Sprite2D/spawnpoint
@onready var ShootCooldown : Timer = $ShootCooldown
@onready var Anims = $AnimationPlayer
@onready var GrabLeft = $Sprite2D/GrabLeft
@onready var GrabRight = $Sprite2D/GrabRight

var BULLET : PackedScene = GlobalVars.BULLET
var my_owner
var can_shoot : bool = true
const my_name = "shotgun"
var accuracy : float = 0.05 # default: 0.05

func _process(delta: float) -> void:
	if my_owner == GlobalVars.player:
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
	ShootCooldown.start()
	$shoot.pitch_scale = randf_range(0.8, 1.2)
	$shoot.play()
	if Sprite.flip_v == false:
		Anims.play("shoot_right")
		$GPUParticles2D.global_rotation = global_rotation
	else:
		$AnimationPlayer.play("shoot_left")
		$GPUParticles2D.global_rotation = global_rotation + PI
	$GPUParticles2D.restart()
	for x in range(5):
		var new_bullet = BULLET.instantiate()
		new_bullet.damage_amount = 7
		new_bullet.my_owner = my_owner
		new_bullet.global_position = Spawnpoint.global_position
		new_bullet.global_rotation = Sprite.global_rotation + x * accuracy - 2 * accuracy
		get_node("/root/main").add_child(new_bullet)
	can_shoot = false
	if my_owner == GlobalVars.player:
		GlobalVars.player.velocity += Vector2(-100, 0).rotated(rotation)

func pull_out():
	can_shoot = false
	Anims.play("pull_out")
func put_away():
	pass

func _on_cooldown_timeout() -> void:
	can_shoot = true
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'pull_out':
		can_shoot = true
