extends CharacterBody2D

const Shotgun = preload("uid://bsecy8dw60b21")
const RL = preload("uid://brcehntt6lxn6")
const Pistol = preload("uid://cdavqdqek4rr5")
const PARTS = preload("uid://o34nfwjqh6ot")


@onready var weapons = [Shotgun, RL, Pistol]

@onready var my_weapon : PackedScene = weapons.pick_random()
@onready var player = GlobalVars.player
@onready var FloorLookerLeft = $FloorLookerLeft
var WEAPON : Node2D = null
const SPEED = 500.0
const JUMP_VELOCITY = -300.0
var direction = Vector2(0, 0)
var hp = 100
var total_damage : int = 0
var base_damage	 : int = 0
var parts_amount : int = 0
var is_following : bool = false

func _ready() -> void:
	var get_WEAPON = my_weapon.instantiate()
	get_WEAPON.weapon_owner = "Enemy"
	add_child(get_WEAPON)
	WEAPON = get_WEAPON.get_child(1).get_parent()
	if my_weapon == Shotgun:
		base_damage = 3
	elif my_weapon == RL:
		base_damage = 10
	elif my_weapon == Pistol:
		base_damage = 8
func _physics_process(delta: float) -> void:
	if not is_on_floor() and hp > 0:
		velocity += get_gravity() * delta
	if player != null and hp > 0:
		
		#if WEAPON.is_player_nearby and WEAPON.can_shoot and GlobalVars.player_hp > 0:
			#WEAPON.shoot(base_damage, false)
		if FloorLookerLeft.get_collider() == null and is_following:
			jump()
		
		#if global_position.y - player.global_position.y > 50 and is_on_floor() and $shock.is_stopped() and global_position.distance_to(player.global_position) < 100:
			#velocity.y = JUMP_VELOCITY
	
		direction = global_position.direction_to(player.global_position)
		if $shock.is_stopped():
			if (global_position.distance_to(player.global_position) < 300 and\
			global_position.distance_to(player.global_position) > 150) and abs(velocity.x) < 300:
				velocity.x += direction.x * SPEED * delta
				is_following = true
				if sign(velocity.x) != sign(global_position.direction_to(player.global_position).x):
					velocity.x += velocity.x * -0.05
			elif global_position.distance_to(player.global_position) < 50:
				velocity.x -= direction.x * SPEED * delta
				is_following = true
			else:
				is_following = false
		if hp > 0:
			velocity.x *= 0.9
	elif hp <= 0 and str(WEAPON) != "<Freed Object>":
		kill()
	
	var previous_velocity = velocity
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if collider is RigidBody2D:
			if velocity.x + velocity.y > SPEED * 2:
				collider.apply_impulse(previous_velocity * normal * -0.15)
			else:
				collider.apply_impulse(Vector2(SPEED, SPEED) * normal * -0.15)
		elif "Enemy" in str(collider):
			if velocity.x + velocity.y > SPEED:
				collider.velocity += previous_velocity * normal * -0.3
			else:
				collider.velocity += Vector2(SPEED, SPEED) * normal * -0.3

func kill():
	GlobalVars.killed += 1
	$Sprite2D.self_modulate = Color(1, 1, 1, 0)
	$CollisionShape2D.disabled = true
	$Label.add_theme_color_override("font_color", Color(1.535, 0.325, 0.325, 6.5))
	WEAPON.queue_free()
	velocity = Vector2(0, 0)
	queue_free()

func push(pwr, dir):
	velocity += pwr * dir
	$shock.start()

func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func damage(damage_amount, type):
	hp -= damage_amount
	match type:
		"bullet":
			GlobalVars.heal(int(damage_amount * 0.25))
		"explosion":
			if hp <= 0:
				GlobalVars.heal(int(damage_amount * 1.25))
		"hammer":
			GlobalVars.heal(damage_amount * 0.8)
	var new_splatter = Sprite2D.new()
	new_splatter.texture = load("res://textures/particles/enemy_parts/splash" +\
	str(randi_range(1, 41)) + ".png")
	new_splatter.global_position = global_position + Vector2(randi_range(-10, 10), randf_range(-10, 10))
	new_splatter.scale = Vector2(1, 1) * randf_range(1.0, 2.0)
	new_splatter.modulate = Color(1.0, 0.898, 0.414 + randf_range(-0.200, 0.200), randf_range(0.4, 0.7))
	new_splatter.z_index = -1
	get_parent().add_child(new_splatter)
	#var new_part = PARTS.instantiate()
	#new_part.power = damage_amount * 5
	#new_part.global_position = global_position
	#new_part.heal = damage_amount
	#new_part.name = name + "_part" + str(parts_amount)
	#parts_amount += 1
	#new_part.direction = Vector2(-1, -1)
	#get_parent().add_child.call_deferred(new_part)
	total_damage += damage_amount
	$Label.text = str(total_damage)
	$damage.start()
	if $AnimationPlayer.current_animation != "show_damage":
		$AnimationPlayer.play("show_damage")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "show_damage":
		$AnimationPlayer.play("hide")
	elif anim_name == "hide":
		$Label.text = ""
		total_damage = 0
