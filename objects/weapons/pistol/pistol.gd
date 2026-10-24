extends Node2D

@onready var Sprite : Sprite2D = $Sprite2D
@onready var Spawnpoint : Marker2D = $Sprite2D/Spawnpoint
@onready var ShootCooldown : Timer = $ShootCooldown

var BULLET : PackedScene
var my_slot : int
var my_owner
var slots_ui
var can_shoot : bool = false
var current_angle : float
var is_player_nearby : bool = false
var is_player_colliding : bool = false
var total_bullets : int = 0
const my_name = "pistol"

func _ready():
	BULLET = load("uid://csr8w1qcnqlbd")
	if my_owner == GlobalVars.player:
		$Sprite2D/Area2D.hide()
		$Sprite2D/Area2D.monitoring = false
		$Sprite2D/Area2D.monitorable = false

func _process(delta: float) -> void:
	if my_owner == GlobalVars.player:
		if GlobalVars.current_slot_num == my_slot:
			visible = true
			logic()
		else:
			visible = false
	elif my_owner is Enemy:
		if is_player_colliding and can_shoot:
			is_player_nearby = true
		else:
			is_player_nearby = false
		logic()

func logic():
	if my_owner == GlobalVars.player:
		current_angle = deg_to_rad(rotation)
	
	if -1.5 <= current_angle and current_angle <= 1.5:
		Sprite.flip_v = false
		Spawnpoint.position.y = -1
		$Sprite2D/Area2D.position.y = 0
	else:
		Sprite.flip_v = true
		Spawnpoint.position.y = 2
		$Sprite2D/Area2D.position.y = 3
	
	if Input.is_action_pressed("lmb") and can_shoot and my_owner == GlobalVars.player:
		shoot(15)

func shoot(damage_amount):
	$shoot.pitch_scale = randf_range(0.8, 1.2)
	$shoot.play()
	if Sprite.flip_v == false:
		$AnimationPlayer.play("shoot_right")
	else:
		$AnimationPlayer.play("shoot_left")
	var new_bullet = BULLET.instantiate()
	new_bullet.damage_amount = damage_amount
	new_bullet.my_owner = my_owner
	new_bullet.global_position = Spawnpoint.global_position
	new_bullet.global_rotation = Sprite.global_rotation
	new_bullet.name = "Bullet" + str(total_bullets)
	#new_bullet.SPEED = 1250
	total_bullets += 1
	get_node("/root/main").add_child(new_bullet)
	can_shoot = false
	ShootCooldown.start()

func _on_cooldown_timeout() -> void:
	can_shoot = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		is_player_colliding = true
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == GlobalVars.player:
		is_player_colliding = false
