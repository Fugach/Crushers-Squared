extends CharacterBody2D

var stats : Dictionary = {
	'MAX_SPEED' = 165.0,
	'JUMP_POWER' = -300.0,
	'WEIGHT' = 650.0,
	'MAX_WALLJUMPS' = 3,
	'WALLJUMPS' = 3,
	'MAX_HP' = 100,
	'HP' = 100
}

var inventory : Dictionary[int, Node2D] = {
	0: null,
}
var current_weapon : Node2D

var direction : int = 1
var last_animation : String = ""

enum PlayerState {IDLE, SLIDING, SLAMMING, NOCLIPPING}
var state = PlayerState.IDLE
var is_falling_fast : bool = false
var is_running : bool = false
var can_jump : bool = true
var current_gravity := Vector2(0, 980)
var is_debugging : bool = false
var is_noclipping : bool = false
var is_picking_up_weapon : bool = false

@onready var Slots : Control = $"../UI/HUD/Slots"

@onready var FALL_PARTICLES = preload("uid://3jklnx6aump3")
@onready var WEAPON = GlobalVars.WEAPON
@onready var Camera : Camera2D = $"../Camera"
@onready var Anims : AnimationPlayer = $AnimationPlayer
@onready var RunTiming : Timer = $RunTiming
@onready var slide_loop : AudioStreamPlayer2D = $wall_slide_loop

@onready var RightHand = $RightHand
@onready var LeftHand = $LeftHand

func _ready() -> void:
	if OS.is_debug_build():
		is_debugging = true
	GlobalVars.player = self
	Slots.add_slot()
	Slots.add_slot()
	Slots.add_slot()
	
	for x in ['SHOTGUN', 'PISTOL']:
		var new = GlobalVars.WEAPON.instantiate()
		new.weapon = x
		new.global_position = global_position# + Vector2(0, -50)
		get_parent().add_child(new)
		new.SpawnCooldown.stop()

func _physics_process(delta: float) -> void:
	var previous_velocity = velocity
	
	if stats['HP'] > 0:
		walk(delta)
		slide(delta)
		jump()
		fall()
		use_weapon()
		move_and_slide()

	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var normal = collision.get_normal()
			if previous_velocity.x + previous_velocity.y > stats['MAX_SPEED'] * 2:
				collider.apply_impulse(previous_velocity * normal * -0.15)
			else:
				collider.apply_impulse(Vector2(stats['MAX_SPEED'], stats['MAX_SPEED']) * normal * -0.15)

func _process(_delta: float) -> void:
	if Input.is_action_just_released("scroll_up") and not Input.is_action_just_released("zoom_in"):
		switch_to((Slots.current + 1) % len(inventory))
	elif Input.is_action_just_released("scroll_down") and not Input.is_action_just_released("zoom_out"):
		switch_to(Slots.current - 1 if\
		Slots.current - 1 >= 0 else len(inventory) - 1)
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
		new_weapon.weapon = 'FLAMETHROWER'
		new_weapon.global_position = get_global_mouse_position()
		get_parent().add_child(new_weapon)
	
	if Input.is_action_just_pressed("debug_thingy"):
		Engine.time_scale = 0.0
	if Input.is_action_just_pressed("heal"):
		if stats['HP'] < 100:
			stats['HP'] = 100
		else:
			stats['HP'] = 999
	if Input.is_action_just_pressed('noclip'):
		rotation = 0.0
		is_falling_fast = false
		$slide.emitting = false
		$slam.emitting = false
		$Sprite.scale = Vector2.ONE
		set_physics_process(is_noclipping)
		is_noclipping = not is_noclipping
		
		state = PlayerState.NOCLIPPING if is_noclipping else PlayerState.IDLE
		$Sprite.self_modulate.a = 0.3 if is_noclipping else 1.0
		$Sprite.material.set('shader_parameter/intensity', 0.5 if is_noclipping else 0.0)
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
		velocity.x += stats["MAX_SPEED"] * direction
	elif Input.is_action_just_released("move_right") and Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_just_pressed("move_right"):
		direction = 1
		velocity.x += stats.MAX_SPEED * direction
	elif Input.is_action_just_released("move_left") and Input.is_action_pressed("move_right"):
		direction = 1
	elif Input.is_action_just_released("move_left") and direction == -1 or\
		 Input.is_action_just_released("move_right") and direction == 1:
			is_running = false
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		velocity.x += (stats['MAX_SPEED'] - abs(velocity.x)) * direction * delta * 5
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
		state = PlayerState.SLIDING
		Anims.play('RESET')
		$slam.emitting = false
		$SlideCoyoteTime.start()
		rotation = 0.2 * sign(get_wall_normal().x)
		
		$slide.emitting = true
		$slide.scale.x = direction * -1
		$slide.global_position = global_position + Vector2(-5 * get_wall_normal().x, 5)
		slide_loop.volume_db = 0.0
		slide_loop.pitch_scale = 1.0 + abs(velocity.y) / 100
	else:
		rotation = 0.0
		$slide.emitting = false
		slide_loop.volume_db = -80.0
	velocity.y += current_gravity.y * delta * (0.1 if state == PlayerState.SLIDING else 1.0)

func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_jump:
		if Anims.current_animation == "slam_stop":
			velocity.y += stats['JUMP_POWER'] * 1.3
		else:
			velocity += sign(current_gravity) * stats['JUMP_POWER']
		Anims.play("RESET")
	elif $JumpCoyoteTime.time_left > 0 and Input.is_action_just_pressed("jump") and can_jump:
		velocity.y += stats['JUMP_POWER']
		if Anims.current_animation == "slam_stop":
			Anims.play("RESET")
	
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		velocity.y *= 0.6
	elif Input.is_action_just_pressed("jump") and state == PlayerState.SLIDING and stats['WALLJUMPS'] > 0:
		Anims.stop()
		state = PlayerState.IDLE
		velocity.x = sign(get_wall_normal().x) * 200
		velocity.y = -350
		stats['WALLJUMPS'] -= 1
	if is_on_floor():
		stats['WALLJUMPS'] = stats['MAX_WALLJUMPS']
		$JumpCoyoteTime.start()

func fall():
	# мультяшый эффект падения и свист воздуха
	if velocity.y > stats['WEIGHT']:
		is_falling_fast = true
		$Sprite.scale = Vector2(
			clamp(500 / velocity.y * 1.5, 0.3, 1),
			clamp(velocity.y / 1000 * 1.5, 1, 5)
			)
		$wind.volume_db = min((abs(velocity.x) + abs(velocity.y)) * 0.025 - 35, 7.5)
		$wind.pitch_scale = (abs(velocity.x) + abs(velocity.y)) * 0.0001 + 1.0
	elif is_falling_fast and velocity.y <= stats['WEIGHT'] and not is_on_floor():
		is_falling_fast = false
		$Sprite.scale = Vector2(1, 1)
		$wind.volume_db = -80
	
	# тяжёлое приземление
	if is_falling_fast and is_on_floor():
		is_falling_fast = false
		state = PlayerState.SLAMMING
		$slam.emitting = false
		Camera.shake(0.1, 5)
		$Sprite.scale = Vector2(1, 1)
		Anims.play("slam_stop")
		
		$fall.pitch_scale = randf_range(0.7, 1.3)
		$fall.play()
		var new_fall = FALL_PARTICLES.instantiate()
		new_fall.global_position = global_position
		new_fall.min_vel = velocity.y * 10
		new_fall.max_vel = new_fall.min_vel * 1.25
		get_parent().add_child(new_fall)
		
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

func use_weapon():
	if current_weapon == null:
		return
	
	current_weapon.look_at(get_global_mouse_position())
	current_weapon.global_position = global_position + Vector2.RIGHT.rotated(current_weapon.global_rotation) * clamp(
		current_weapon.global_position.distance_to(get_global_mouse_position()) / 2,
		0,
		10
	)
	
	if Input.is_action_pressed('lmb'):
		current_weapon.shoot()

func push(pwr, dir):
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		velocity += pwr * Vector2(-1, -1) / 2
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		velocity += pwr * Vector2(1, -1) / 2
	else:
		velocity += pwr * dir / 2

func damage(amount, type):
	if $damage_cooldown.is_stopped():
		$damage_cooldown.start()
		stats['HP'] -= amount
		if stats['HP'] - amount > 0:
			stats['HP'] -= amount
		else:
			stats['HP'] = 0
			GlobalVars.main_node.death()

func _input(event: InputEvent) -> void:
	var text = event.as_text()
	if Input.is_action_just_pressed("slam") and not is_on_floor() and\
	not Input.is_action_just_pressed("jump") and\
	(state == PlayerState.IDLE or state == PlayerState.SLIDING):
		velocity.y = 750
		velocity.x = 0
		state = PlayerState.SLAMMING
		$slam.emitting = true
	elif (state == PlayerState.SLAMMING or is_falling_fast) and is_on_floor():
		Anims.play("slam_stop")
		state = PlayerState.IDLE
		is_falling_fast = false	
		$slam.emitting = false
	#elif state == PlayerState.SLIDING and\
	#Input.get_axis('move_left', 'move_right') != sign(get_wall_normal().x) * -1:
		#Anims.stop()
		#$slam.emitting = false
		#state = PlayerState.IDLE
	
	if text.is_valid_int():
		var num = int(text)
		if num <= 9 and num > 0 and num <= len(inventory) and num != (Slots.current + 1):
			switch_to(num % (len(inventory) + 1) - 1)
	
	if Input.is_action_just_pressed("drop"):
		var item : Node2D = inventory[Slots.current]
		if item != null:
			#$throw.play()
			RightHand.reparent(self)
			LeftHand.reparent(self)
			inventory[Slots.current] = null
			var result = WEAPON.instantiate()
			result.weapon = item.my_name.to_upper()
			item.queue_free()
			result.global_position = global_position + Vector2(sign(global_position.x - get_global_mouse_position().x) * -10, -5)
			result.apply_force(10000 * Vector2(1, 1) * Vector2(sign(global_position.x - get_global_mouse_position().x), 1))
			get_parent().add_child(result)
			Slots.update()
func switch_to(slot : int):
	if current_weapon != null:
		RightHand.reparent(self)
		LeftHand.reparent(self)
		current_weapon.hide()
		current_weapon.set_process(false)
		current_weapon.put_away()
	Slots.current = slot
	Slots.update()
	current_weapon = inventory[Slots.current]
	if current_weapon != null:
		current_weapon.show()
		current_weapon.set_process(true)
		current_weapon.pull_out()
		
		RightHand.reparent(current_weapon.GrabRight)
		RightHand.global_position = current_weapon.GrabRight.global_position
		
		LeftHand.reparent(current_weapon.GrabLeft)
		LeftHand.global_position = current_weapon.GrabLeft.global_position

func respawn():
	if Camera == null:
		Camera = $"../Camera2D"
	state = PlayerState.IDLE
	$slam.emitting = false
	velocity = Vector2(0, 0)
	global_position = Vector2(0, 0)
	Camera.global_position = global_position
	Camera.reset_smoothing()
	Anims.play("RESET")
	stats['HP'] = stats['MAX_HP']

func set_stat(what : String, amount):
	stats[what] = amount

func animation_finished(anim_name: StringName) -> void:
	last_animation = anim_name
func _on_slide_coyote_timeout() -> void:
	state = PlayerState.IDLE
	$Sprite.rotation = 0

func _on_pick_up_area_entered(body: Node2D) -> void:
	if body.has_method("pick_up") and not is_picking_up_weapon and inventory.values().has(null):
		is_picking_up_weapon = true
		body.pick_up(self)
		set_deferred("is_picking_up_weapon", false)
