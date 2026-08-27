extends Node2D

@onready var Sprite : Sprite2D = $Sprite2D
@onready var Spawnpoint : Marker2D = $Sprite2D/spawnpoint
@onready var Cooldown : Timer = $cooldown

var BULLET : PackedScene
var my_slot : String = ""
var can_shoot : bool = true
var weapon_owner : String = ""
var current_angle = null
var is_player_nearby : bool = false
var is_player_colliding : bool = false
var my_name = "shotgun"
var accuracy : float = 0.05 # default: 0.05 

func _ready():
	BULLET = preload("uid://csr8w1qcnqlbd")
	GlobalVars.slots[str(my_slot)] = self
	get_node("/root/main/UI/HUD/Slots").update()

func _process(delta: float) -> void:
	match weapon_owner:
		"Player":
			if GlobalVars.current_slot_num == my_slot:
				visible = true
				logic(delta)
			else:
				visible = false
		"Enemy":
			if is_player_colliding and can_shoot:
				is_player_nearby = true
			else:
				is_player_nearby = false
			logic(delta)

func logic(delta):
	if weapon_owner == "Player":
		look_at(get_global_mouse_position())
		current_angle = (get_global_mouse_position() - global_position).normalized().angle()
	elif weapon_owner == "Enemy":
		look_at(GlobalVars.player.global_position)
		current_angle = (GlobalVars.player.global_position - global_position).normalized().angle()
	
	if -1.5 <= current_angle and current_angle <= 1.5:
		Sprite.flip_v = false
		Spawnpoint.position.y = -1
		$Sprite2D/Area2D.position.y = 0
	else:
		Sprite.flip_v = true
		Spawnpoint.position.y = 2
		$Sprite2D/Area2D.position.y = 3
	
	if Input.is_action_pressed("lmb") and can_shoot and weapon_owner == "Player":
		shoot(7, true)

func shoot(damage_amount, is_friendly):
	$shoot.pitch_scale = randf_range(0.8, 1.2)
	$shoot.play()
	if Sprite.flip_v == false:
		$AnimationPlayer.play("shoot_right")
		$GPUParticles2D.global_rotation = global_rotation
	else:
		$AnimationPlayer.play("shoot_left")
		$GPUParticles2D.global_rotation = global_rotation + PI
	$GPUParticles2D.restart()
	for x in range(5):
		var new_bullet = BULLET.instantiate()
		new_bullet.damage_amount = damage_amount
		new_bullet.is_friendly = is_friendly
		new_bullet.global_position = Spawnpoint.global_position
		new_bullet.global_rotation = Sprite.global_rotation + x * accuracy - 2 * accuracy
		get_node("/root/main").add_child(new_bullet)
	can_shoot = false
	if weapon_owner == 'Player':
		GlobalVars.player.velocity += Vector2(-100, 0).rotated(rotation)
	Cooldown.start()

func _on_cooldown_timeout() -> void:
	can_shoot = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		is_player_colliding = true
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == GlobalVars.player:
		is_player_colliding = false
