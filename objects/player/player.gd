extends CharacterBody2D
class_name Player

var SPEED : float = 165.0
var SPEED_buffer : float = SPEED
var JUMP_VELOCITY : float = -300.0
var JUMP_VELOCITY_buffer : float = JUMP_VELOCITY
var WEIGHT : float = 500
var WALLJUMPS : int = 3
var AVAILABLE_WALLJUMPS : int = 3
var direction : int = 1
var last_animation : String = ""

var RL : PackedScene
var SHOTGUN : PackedScene
var PISTOL : PackedScene
var ENEMY : PackedScene
var BOX : PackedScene

@onready var HAND = preload("uid://bbxbw8j8ubuiv")
@onready var FALL_PARTICLES = preload("uid://3jklnx6aump3")

@onready var Camera: Camera2D = $"../Camera2D"
@onready var SlotsHUD: Node2D = $"../UI/HUD/Slots"
@onready var Elevator: Area2D = $"../Elevator"
@onready var Anims: AnimationPlayer = $AnimationPlayer

var is_going_to_elevator : bool = false
var is_sliding : bool = false
var is_slamming : bool = false
var is_falling_fast : bool = false
var can_jump : bool = true
var falling_speed : float = 0.0

var throw_power : Vector2 = Vector2(-10000, -10000)
@onready var main: Node2D = $".."
@onready var steps: AudioStreamPlayer2D = $steps
@onready var wall_slide_loop: AudioStreamPlayer2D = $wall_slide_loop
@onready var wind: AudioStreamPlayer2D = $wind

func _ready() -> void:
	var hand = HAND.instantiate()
	add_child(hand)
	GlobalVars.player = self
	RL = load("uid://b6yunx8h1pcdi")
	SHOTGUN = load("uid://dhjphrjas8n7d")
	PISTOL = load("uid://5j581geyyouk")
	ENEMY = load("uid://dacw07jts5j8n")
	BOX = load("uid://bf1hvay56ii3f")

func _physics_process(delta: float) -> void:
	if velocity.y > WEIGHT:
		falling_speed = velocity.y
		is_falling_fast = true
		
	if is_falling_fast and velocity.y <= 0 and is_on_floor():
		Camera.shake(0.1, 5)
		$fall.pitch_scale = randf_range(0.7, 1.3)
		$fall.play()
		var new_fall = FALL_PARTICLES.instantiate()
		new_fall.min_vel = 15 * (falling_speed / 50)
		new_fall.max_vel = new_fall.min_vel * 1.25
		new_fall.global_position = global_position
		get_parent().add_child(new_fall)
		is_falling_fast = false
		for body in get_parent().get_children():
			if ("Enemy" in str(body) or body is RigidBody2D) and body.global_position.distance_to(global_position) < 100:
				if not (body is RigidBody2D):
					body.velocity.y += -150
				else:
					body.apply_impulse(Vector2(0, -150))
				if body.global_position.distance_to(global_position) < 25:
					if body.has_method("damage"):
						body.damage(10, 'fall')
	if is_on_wall_only() and (not is_on_floor()) and velocity.y > 0 and\
	(Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		is_sliding = true
		$SlideCoyote.start()
		if Input.is_action_pressed("move_left"):
			rotation = 0.2
		elif Input.is_action_pressed("move_right"):
			rotation = -0.2
		if randi_range(1, 8) == 6:
			$slide.global_position = global_position + Vector2(5 * direction, 5)
			$slide.scale.x = direction * -1
			$slide.amount = 5 + int(velocity.y / 100)
			$slide.emitting = true
		
		velocity.y += get_gravity().y * delta * 0.1 # скользим по стенам
	elif not is_on_floor():
		rotation = 0.0
		$slide.emitting = false
		velocity.y += get_gravity().y * delta # базовое падение
	else:
		rotation = 0.0
		$slide.emitting = false
	
	if is_sliding and GlobalVars.player_hp > 0:
		wall_slide_loop.volume_db = 0.0
		wall_slide_loop.pitch_scale = 1.0 + abs(velocity.y) / 100
	else:
		wall_slide_loop.volume_db = -80.0
	
	var previous_velocity = velocity
	
	if GlobalVars.player_hp > 0:
		get_input(delta)
		fall()
		move_and_slide()

	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var normal = collision.get_normal()
			if velocity.x + velocity.y > SPEED * 2:
				collider.apply_impulse(previous_velocity * normal * -0.15)
			else:
				collider.apply_impulse(Vector2(SPEED, SPEED) * normal * -0.15)

func _process(_delta: float) -> void:
	jump()
	debug()

func debug():
	if Input.is_action_just_pressed('spawn_ENEMY'):
		var new_enemy = ENEMY.instantiate()
		new_enemy.global_position = get_global_mouse_position()
		get_parent().add_child(new_enemy)
	if Input.is_action_just_pressed("spawn_BOX"):
		var new_box = BOX.instantiate()
		new_box.global_position = get_global_mouse_position()
		get_parent().add_child(new_box)
	if Input.is_action_just_pressed('spawn_PISTOL'):
		var new_pistol = PISTOL.instantiate()
		new_pistol.global_position = get_global_mouse_position()
		get_parent().add_child(new_pistol)
	if Input.is_action_just_pressed('spawn_SHOTGUN'):
		var new_shotgun = SHOTGUN.instantiate()
		new_shotgun.global_position = get_global_mouse_position()
		get_parent().add_child(new_shotgun)
func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_jump:
		velocity.y += JUMP_VELOCITY
		Anims.play("RESET")
	elif $Coyote.time_left > 0 and Input.is_action_just_pressed("jump") and can_jump:
		velocity.y += JUMP_VELOCITY
		if Anims.current_animation == "slam_stop":
			Anims.play("RESET")
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		velocity.y *= 0.6
	elif Input.is_action_just_pressed("jump") and is_sliding and AVAILABLE_WALLJUMPS > 0:
		if is_slamming:
			is_slamming = false
			Anims.stop()
		velocity.x = sign(get_wall_normal().x) * 200
		velocity.y = -350
		AVAILABLE_WALLJUMPS -= 1
	if is_on_floor():
		AVAILABLE_WALLJUMPS = WALLJUMPS
		$Coyote.start()

func fall():
	if not is_on_floor() and not is_on_ceiling():
		wind.volume_db = min((abs(velocity.x) + abs(velocity.y)) * 0.025 - 35, 7.5)
		wind.pitch_scale = (abs(velocity.x) + abs(velocity.y)) * 0.0001 + 1.0
	else:
		wind.volume_db = -80
	if Input.is_action_just_pressed("debug_thingy"):
		Engine.time_scale = 0.0
	if position.y > 5000:
		respawn()
		is_sliding = false
		is_slamming = false
		Camera.reset_smoothing()
		Anims.play("RESET")

func push(pwr, _dir):
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		velocity += pwr * Vector2(-1, -1) / 2
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		velocity += pwr * Vector2(1, -1) / 2
	else:
		velocity += pwr * _dir / 2

func damage(amount, type):
	if $damage_cooldown.is_stopped():
		GlobalVars.player_hp -= amount
		if GlobalVars.player_hp - amount > 0:
			GlobalVars.player_hp -= amount
		else:
			GlobalVars.player_hp = 0
			main.death()
		show_damage()
		$damage_cooldown.start()

func get_input(delta: float) -> void:
	if is_going_to_elevator:
		if abs(global_position.x - Elevator.global_position.x) > 0.1:
			velocity.x += 10 * (Elevator.global_position.x - global_position.x)
		else:
			Anims.play("hide")
			$"../Elevator/Outside/Elevator".play("close")
			is_going_to_elevator = false
			$"../TileMapLayer/AnimationPlayer".play("hide")
			for body in get_parent().get_children():
				if "Light" in str(body):
					body.queue_free()
	
	if Input.is_action_just_pressed("down") and is_on_floor():
		Anims.play("squish")
	elif Input.is_action_just_released("down") and (Anims.current_animation == "squish" or last_animation == "squish"):
		Anims.play("unsquish")
	
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		direction = -1
		if sign(velocity.x) != direction:
			velocity.x *= 0.8
		velocity.x += (SPEED - abs(velocity.x)) * direction * delta * 5
	if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		direction = 1
		if sign(velocity.x) != direction:
			velocity.x *= 0.8
		velocity.x += (SPEED - abs(velocity.x)) * direction * delta * 10
	if not steps.is_playing() and is_on_floor() and abs(round(velocity.x)) > 10:
			steps.play()
	if Input.is_action_just_pressed("slam") and not is_on_floor() and not Input.is_action_just_pressed("jump"):
		Anims.play("slam_start")
		velocity.y = 750
		velocity.x = 0
		is_slamming = true
		$slam.emitting = true
	elif is_slamming and is_on_floor():
		Anims.play("slam_stop")
		is_slamming = false
		$slam.emitting = false
	elif is_slamming and is_sliding:
		Anims.stop()
		$slam.emitting = false
		is_slamming = false
	if Anims.current_animation == "slam_stop" and Input.is_action_just_pressed("jump") and can_jump:
		velocity.y += JUMP_VELOCITY * 0.3
	
	if int(Input.is_action_pressed("move_left")) == int(Input.is_action_pressed("move_right")):
		if is_on_floor():
			velocity.x *= 0.8
		else:
			velocity.x *= 0.99
	if Input.is_action_just_released("scroll_up"):
		match GlobalVars.current_slot_num:
			"slot1":
				GlobalVars.current_slot_num = "slot2"
			"slot2":
				GlobalVars.current_slot_num = "slot3"
			"slot3":
				GlobalVars.current_slot_num = "slot1"
	elif Input.is_action_just_released("scroll_down"):
		match GlobalVars.current_slot_num:
			"slot1":
				GlobalVars.current_slot_num = "slot3"
			"slot2":
				GlobalVars.current_slot_num = "slot1"
			"slot3":
				GlobalVars.current_slot_num = "slot2"
	if Input.is_action_just_pressed("slot1"):
		GlobalVars.current_slot_num = "slot1"
		SlotsHUD.update()
	elif Input.is_action_just_pressed("slot2"):
		GlobalVars.current_slot_num = "slot2"
		SlotsHUD.update()
	elif Input.is_action_just_pressed("slot3"):
		GlobalVars.current_slot_num = "slot3"
		SlotsHUD.update()
	
	if Input.is_action_just_pressed("throw_item"):
		var item : Node2D = GlobalVars.slots[GlobalVars.current_slot_num]
		if item != null:
			$throw.play()
			match item.name.left(-6):
				"Shotgun":
					var new_shogun = SHOTGUN.instantiate()
					new_shogun.global_position = global_position + Vector2(0, -15)
					new_shogun.apply_force(throw_power * Vector2(sign(global_position.x - get_global_mouse_position().x), 1))
					get_parent().add_child(new_shogun)
				"RL":
					var new_RL = RL.instantiate()
					new_RL.global_position = global_position + Vector2(0, -15)
					new_RL.apply_force(throw_power * Vector2(sign(global_position.x - get_global_mouse_position().x), 1))
					get_parent().add_child(new_RL)
				"Pistol":
					var new_pistol = PISTOL.instantiate()
					new_pistol.global_position = global_position + Vector2(0, -15)
					new_pistol.apply_force(throw_power * Vector2(sign(global_position.x - get_global_mouse_position().x), 1))
					get_parent().add_child(new_pistol)
			item.queue_free()
			GlobalVars.slots[GlobalVars.current_slot_num] = null
			Camera.position_smoothing_speed = 2
			SlotsHUD.update()

func respawn():
	if Camera == null:
		Camera = $"../Camera2D"
		Anims = $AnimationPlayer

	for body in get_node("../TileMapLayer").get_children():
		if "Bullet" in body.name or "Rocket" in body.name or "Enemy" in body.name or "Bullet" in body.name:
			body.free()
	is_slamming = false
	is_sliding = false
	$slam.emitting = false
	velocity = Vector2(0, 0)
	global_position = GlobalVars.spawn_pos
	Camera.global_position = global_position
	Camera.reset_smoothing()
	Anims.play("RESET")
	GlobalVars.player_hp = 100
func show_damage():
	$damage.play()
	#$blood.emitting = true
	pass

func animation_finished(anim_name: StringName) -> void:
	last_animation = anim_name
	if anim_name == "slam_start" and is_on_floor():
		Anims.play("slam_stop")
func _on_slide_coyote_timeout() -> void:
	is_sliding = false
	$Sprite2D.rotation = 0
func goto_elevator():
	for body in get_node("../TileMapLayer").get_children():
		if "Bullet" in body.name or "Rocket" in body.name or "Enemy" in body.name or "Bullet" in body.name:
			body.free()
	SPEED_buffer = SPEED
	can_jump = false
	SPEED = 0
	is_going_to_elevator = true
func camera_impact(amount, dir):
	Camera.global_position += amount * dir
