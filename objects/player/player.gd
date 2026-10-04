class_name Player
extends CharacterBody2D

var my_stats : Dictionary = {
	'max_speed' = 165.0,
	'jump_power' = -300.0,
	'weight' = 650,
	'max_walljumps' = 3,
	'walljumps' = 3,
	'max_hp' = 100,
	'hp' = 100
}

var direction : int = 1
var last_animation : String = ""

var is_sliding : bool = false
var is_slamming : bool = false
var is_falling_fast : bool = false
var is_running : bool = false
var can_jump : bool = true
var falling_speed : float = 0.0
var current_gravity := Vector2(0, 980)
var throw_power : Vector2 = Vector2(-10000, -10000)
var is_debugging : bool = false
var is_noclipping : bool = false
var is_picking_up_weapon : bool = false

@onready var main : Node2D = $".."
@onready var HAND = preload("uid://bbxbw8j8ubuiv")
@onready var FALL_PARTICLES = preload("uid://3jklnx6aump3")
@onready var WEAPON = GlobalVars.WEAPON
@onready var Camera : Camera2D = $"../Camera2D"
@onready var SlotsHUD : Control = $"../UI/HUD/Slots"
@onready var Anims : AnimationPlayer = $AnimationPlayer
@onready var RunTiming : Timer = $RunTiming
@onready var wall_slide_loop : AudioStreamPlayer2D = $wall_slide_loop

func _ready() -> void:
	if OS.is_debug_build():
		is_debugging = true
	add_child(HAND.instantiate())
	GlobalVars.player = self

func _physics_process(delta: float) -> void:
	var previous_velocity = velocity
	
	if my_stats['hp'] > 0:
		walk(delta)
		slide(delta)
		jump()
		fall()
		move_and_slide()

	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var normal = collision.get_normal()
			if previous_velocity.x + previous_velocity.y > my_stats['max_speed'] * 2:
				collider.apply_impulse(previous_velocity * normal * -0.15)
			else:
				collider.apply_impulse(Vector2(my_stats['max_speed'], my_stats['max_speed']) * normal * -0.15)

func _process(_delta: float) -> void:
	if is_debugging:
		debug()

func debug():
	if Input.is_action_just_pressed('spawn_ENEMY'):
		var new_enemy = Debug.ENEMY.instantiate()
		new_enemy.global_position = get_global_mouse_position()
		get_parent().add_child(new_enemy)
	if Input.is_action_just_pressed("spawn_BOX"):
		var new_box = Debug.BOX.instantiate()
		new_box.global_position = get_global_mouse_position()
		get_parent().add_child(new_box)
	if Input.is_action_just_pressed("spawn_PISTOL"):
		var new_weapon = Debug.WEAPON.instantiate()
		new_weapon.weapon = ['pistol', 'shotgun', 'rocket_launcher'].pick_random()
		new_weapon.global_position = get_global_mouse_position()
		get_parent().add_child(new_weapon)
	
	if Input.is_action_just_pressed("debug_thingy"):
		Engine.time_scale = 0.0
	if Input.is_action_just_pressed("heal"):
		if my_stats['hp'] < 100:
			my_stats['hp'] = 100
		else:
			my_stats['hp'] = 999
	if Input.is_action_just_pressed('noclip'):
		rotation = 0.0
		is_sliding = false
		is_slamming = false
		is_falling_fast = false
		$slide.emitting = false
		$slam.emitting = false
		$Sprite2D.scale = Vector2.ONE
		set_physics_process(is_noclipping)
		is_noclipping = not is_noclipping
		$Sprite2D.self_modulate.a = 0.3 if is_noclipping else 1
		$Sprite2D.material.set('shader_parameter/intensity', 0.5 if is_noclipping else 0.0)
		$Collision.disabled = is_noclipping
	
	if is_noclipping:
		velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * 100
		if Input.is_action_pressed("slam"):
			velocity *= 4
		move_and_slide()

func walk(delta : float):
	if Input.is_action_just_pressed("move_down") and is_on_floor():
		Anims.play("squish")
	elif (Input.is_action_just_released("move_down") or not is_on_floor()) and\
		 (Anims.current_animation == "squish" or last_animation == "squish"):
		Anims.play("unsquish")
	if Input.is_action_just_pressed("move_left"):
		direction = -1
		velocity.x += 500 * direction
	elif Input.is_action_just_released("move_right") and Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_just_pressed("move_right"):
		direction = 1
		velocity.x += 500 * direction
	elif Input.is_action_just_released("move_left") and Input.is_action_pressed("move_right"):
		direction = 1
	elif Input.is_action_just_released("move_left") and direction == -1 or\
		 Input.is_action_just_released("move_right") and direction == 1:
			is_running = false
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		velocity.x += (my_stats['max_speed'] - abs(velocity.x)) * direction * delta * 5
		if sign(velocity.x) != direction and velocity.x != 0:
			velocity.x *= 0.8
	if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		if is_on_floor():
			velocity.x *= 0.8
		else:
			velocity.x *= 0.99

func slide(delta : float):
	if is_on_wall_only() and velocity.y > 0 and\
	Input.get_axis('move_left', 'move_right') == sign(get_wall_normal().x) * -1:
		is_sliding = true
		Anims.play('RESET')
		is_slamming = false
		$slam.emitting = false
		$SlideCoyoteTime.start()
		rotation = -0.2 * direction#* get_wall_normal().x
		
		$slide.emitting = true
		$slide.scale.x = direction * -1
		$slide.global_position = global_position + Vector2(-5 * get_wall_normal().x, 5)
		wall_slide_loop.volume_db = 0.0
		wall_slide_loop.pitch_scale = 1.0 + abs(velocity.y) / 100
	else:
		print(get_wall_normal().x)
		rotation = 0.0
		$slide.emitting = false
		wall_slide_loop.volume_db = -80.0
	velocity.y += current_gravity.y * delta * (0.1 if is_sliding else 1.0)

func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_jump:
		velocity += sign(current_gravity) * my_stats['jump_power']
		Anims.play("RESET")
	elif $JumpCoyoteTime.time_left > 0 and Input.is_action_just_pressed("jump") and can_jump:
		velocity.y += my_stats['jump_power']
		if Anims.current_animation == "slam_stop":
			Anims.play("RESET")
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		velocity.y *= 0.6
	elif Input.is_action_just_pressed("jump") and is_sliding and my_stats['walljumps'] > 0:
		Anims.stop()
		is_slamming = false
		velocity.x = sign(get_wall_normal().x) * 200
		velocity.y = -350
		my_stats['walljumps'] -= 1
	if is_on_floor():
		my_stats['walljumps'] = my_stats['max_walljumps']
		$JumpCoyoteTime.start()

func fall():
	# мультяшый эффект падения и свист воздуха
	if velocity.y > my_stats['weight']:
		falling_speed = velocity.y
		is_falling_fast = true
		$Sprite2D.scale = Vector2(
			clamp(500 / velocity.y * 1.5, 0.3, 1),
			clamp(velocity.y / 1000 * 1.5, 1, 5)
			)
		$wind.volume_db = min((abs(velocity.x) + abs(velocity.y)) * 0.025 - 35, 7.5)
		$wind.pitch_scale = (abs(velocity.x) + abs(velocity.y)) * 0.0001 + 1.0
	elif is_falling_fast and velocity.y <= my_stats['weight'] and not is_on_floor():
		is_falling_fast = false
		$Sprite2D.scale = Vector2(1, 1)
		$wind.volume_db = -80
	
	# тяжёлое приземление
	if is_falling_fast and is_on_floor():
		Camera.shake(0.1, 5)
		$fall.pitch_scale = randf_range(0.7, 1.3)
		$fall.play()
		var new_fall = FALL_PARTICLES.instantiate()
		new_fall.min_vel = 15 * (falling_speed / 50)
		new_fall.max_vel = new_fall.min_vel * 1.25
		new_fall.global_position = global_position
		get_parent().add_child(new_fall)
		$slam.emitting = false
		$Sprite2D.scale = Vector2(1, 1)
		Anims.play("slam_stop")
		is_falling_fast = false
		is_slamming = false
		
		for body in get_parent().get_children():
			if not (body is Enemy or body is RigidBody2D):
				continue
			if body.global_position.distance_to(global_position) > 200:
				continue
			match body.get_class():
				CharacterBody2D:
					body.velocity.y += -150
				RigidBody2D:
					body.apply_impulse(Vector2(0, -150))
			if body.global_position.distance_to(global_position) < 25 and\
			   body.has_method("damage"):
				body.damage(10, 'fall')

func push(pwr, _dir):
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		velocity += pwr * Vector2(-1, -1) / 2
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		velocity += pwr * Vector2(1, -1) / 2
	else:
		velocity += pwr * _dir / 2

func damage(amount, type):
	if $damage_cooldown.is_stopped():
		$damage_cooldown.start()
		my_stats['hp'] -= amount
		if my_stats['hp'] - amount > 0:
			my_stats['hp'] -= amount
		else:
			my_stats['hp'] = 0
			main.death()

func _input(event: InputEvent) -> void:
	var text = event.as_text()
	if Input.is_action_just_pressed("slam") and not is_on_floor() and\
	not Input.is_action_just_pressed("jump") and not is_slamming and not is_noclipping:
		velocity.y = 750
		velocity.x = 0
		is_slamming = true
		$slam.emitting = true
	elif (is_slamming or is_falling_fast) and is_on_floor():
		Anims.play("slam_stop")
		is_slamming = false
		$slam.emitting = false
	elif is_slamming and is_sliding:
		Anims.stop()
		$slam.emitting = false
		is_slamming = false
	if Anims.current_animation == "slam_stop" and Input.is_action_just_pressed("jump") and can_jump:
		velocity.y += my_stats['jump_power'] * 0.3
	
	if Input.is_action_just_released("scroll_up") and not Input.is_action_just_released("zoom_in"):
		# TODO
		GlobalVars.current_slot_num = (GlobalVars.current_slot_num + 1) % len(GlobalVars.slots)
		SlotsHUD.update()
		#match GlobalVars.current_slot_num:
			#"slot1":
				#GlobalVars.current_slot_num = "slot2"
			#"slot2":
				#GlobalVars.current_slot_num = "slot3"
			#"slot3":
				#GlobalVars.current_slot_num = "slot1"
	elif Input.is_action_just_released("scroll_down") and not Input.is_action_just_released("zoom_out"):
		GlobalVars.current_slot_num = (GlobalVars.current_slot_num - 1 if\
		GlobalVars.current_slot_num - 1 >= 0 else len(GlobalVars.slots) - 1) %\
		len(GlobalVars.slots)
		SlotsHUD.update()
		#match GlobalVars.current_slot_num:
			#"slot1":
				#GlobalVars.current_slot_num = "slot3"
			#"slot2":
				#GlobalVars.current_slot_num = "slot1"
			#"slot3":
				#GlobalVars.current_slot_num = "slot2"
	if text.is_valid_int():
		var num = int(text)
		if num <= 9 and num > 0:
			GlobalVars.current_slot_num = num - 1
			SlotsHUD.update()
	
	if Input.is_action_just_pressed("drop"):
		var item : Node2D = GlobalVars.slots[GlobalVars.current_slot_num]
		if item != null:
			print(item.my_name)
			$throw.play()
			GlobalVars.slots[GlobalVars.current_slot_num] = null
			var result = WEAPON.instantiate()
			result.weapon = item.my_name
			item.queue_free()
			result.global_position = global_position + Vector2(sign(global_position.x - get_global_mouse_position().x) * -10, -5)
			result.apply_force(throw_power * Vector2(sign(global_position.x - get_global_mouse_position().x), 1))
			get_parent().add_child(result)
			SlotsHUD.update()

func respawn():
	if Camera == null:
		Camera = $"../Camera2D"
	is_slamming = false
	is_sliding = false
	$slam.emitting = false
	velocity = Vector2(0, 0)
	global_position = Vector2(0, 0)
	Camera.global_position = global_position
	Camera.reset_smoothing()
	Anims.play("RESET")
	my_stats['hp'] = 100

func animation_finished(anim_name: StringName) -> void:
	last_animation = anim_name
func _on_slide_coyote_timeout() -> void:
	is_sliding = false
	$Sprite2D.rotation = 0
#func camera_impact(amount, dir):
	#Camera.global_position += amount * dir


func _on_pick_up_area_entered(body: Node2D) -> void:
	if body.has_method("pick_up") and not is_picking_up_weapon and GlobalVars.slots.values().has(null):
		is_picking_up_weapon = true
		body.pick_up(self)
		set_deferred("is_picking_up_weapon", false)
