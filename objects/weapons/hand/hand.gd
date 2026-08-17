extends Node2D

@onready var Raycast: RayCast2D = $Raycast
@onready var Camera: Camera2D = $"../../Camera2D"
@onready var Animations: AnimationPlayer = $AnimationPlayer
@onready var Hammer: AnimatedSprite2D = $Hammer

var last_slot_num = ""
var is_spinning : bool = false
var blacklist = []

func _ready() -> void:
	Raycast.enabled = false
	Hammer.visible = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shift") and $AttackCooldown.time_left <= 0:
		attack()
	#if not Input.is_action_pressed("shift") and is_spinning:
		#Raycast.enabled = false
		#$attack_cooldown.start()
		#is_spinning = false
		#GlobalVars.player.can_jump = true
		#Animations.stop()
		#$spin_sfx.stop()

func _process(_delta: float) -> void:
	if Hammer.frame > 8:
		Hammer.z_index = -1
	else:
		Hammer.z_index = 1
	if Animations.is_playing():
		hammer_logic(Raycast.get_collider())
	#if Raycast.enabled and $attack_cooldown.time_left <= 0:
		#hammer_logic(hammer_raycast1.get_collider(), hammer_raycast1)
		#if is_spinning and Raycast.enabled:
			#hammer_logic(hammer_raycast2.get_collider(), hammer_raycast2)

func hammer_logic(body):
	#if is_spinning:
		#if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			#rotation = PI / -12
		#if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			#rotation = PI / 12
		#if Input.is_action_pressed("move_right") == Input.is_action_pressed("move_left"):
			#rotation = 0
	if body == null or body in blacklist:
		return
	blacklist.append(body)
	if body is TileMapLayer:
		GlobalVars.player.velocity += 250 * Raycast.get_collision_normal()
		$wall_hit_sfx.pitch_scale = randf_range(0.7, 1.3)
		$wall_hit_sfx.play()
		return
	elif body is RigidBody2D:
		if body.has_method("damage"):
			body.damage(10, "hammer")
		body.apply_central_impulse(250 * -1 * Raycast.get_collision_normal())
		return
	elif "Enemy" in str(body):
		Camera.shake(0.1, 3)
		body.damage(10, "hammer")
		body.push(100, Raycast.get_collision_normal() + Vector2(PI, 0).rotated(global_rotation))
		$damage_sfx.pitch_scale = randf_range(0.7, 1.3)
		$damage_sfx.play()
	#elif body is TileMapLayer:
		#$wall_hit_sfx.pitch_scale = randf_range(0.7, 1.3)
		#$wall_hit_sfx.play()
		#GlobalVars.player.push(400, raycast.get_collision_normal())
		#hammer_raycast1.enabled = false
		#hammer_raycast2.enabled = false
		#$damage_cooldown.start()
	#elif body is RigidBody2D:
		#if body.has_method("damage"):
			#body.damage(10, "hammer")
		#body.apply_central_impulse(250 * raycast.get_collision_normal() + Vector2(PI, 0).rotated(global_rotation))
		#hammer_raycast1.enabled = false
		#hammer_raycast2.enabled = false
		#$damage_cooldown.start()
	#elif "Bullet" in str(body):
		#body.Ricoshet.play()
		#body.global_rotation += PI + randf_range(PI * -0.5, PI * 0.5)

	#if not Input.is_action_pressed("shift"):
		#GlobalVars.player.can_jump = true
		##hammer_raycast1.enabled = false
		#$AttackCooldown.start()
	#else:
		#global_rotation = 0.0
		#hammer_anim.play("loop")
		#is_spinning = true
		#$spin_sfx.play()
		#hammer_raycast2.enabled = true

func attack():
	GlobalVars.player.can_jump = false
	GlobalVars.player.velocity += 25 * GlobalVars.player.global_position.direction_to(get_global_mouse_position())
	look_at(get_global_mouse_position())
	Raycast.enabled = true
	Animations.play("hit")
	$attack_sfx.play()

func _on_damage_cooldown_timeout() -> void:
	pass
	#if is_spinning:
		#hammer_raycast1.enabled = true
		#hammer_raycast2.enabled = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	Raycast.enabled = false
	GlobalVars.player.can_jump = true
	blacklist.clear()
