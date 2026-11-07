extends CharacterBody2D
class_name Enemy

@onready var player = GlobalVars.player
@onready var FloorLookerLeft = $FloorLookerLeft
@onready var FloorLookerRight = $FloorLookerRight
@onready var PlayerLooker: RayCast2D = $PlayerLooker
@onready var Visualiser: Line2D = $Visualiser
@onready var UniLooker: RayCast2D = $UniLooker
@onready var Splashes : MultiMeshInstance2D = get_node(str(GlobalVars.main_node.get_path()) + '/EnemySplashes')

var is_player_straight : bool = false
var WEAPON : Node2D = null
const ACCELERATION = 1.75
const MAX_SPEED = 750.0
const JUMP_VELOCITY = -300.0
var hp = 100
var total_damage : int = 0
var base_damage	 : int = 0
var parts_amount : int = 0
var is_following : bool = false

func _ready() -> void:
	var Shotgun = load("uid://bsecy8dw60b21")
	var RL = load("uid://brcehntt6lxn6")
	var Pistol = load("uid://cdavqdqek4rr5")
	
	var my_weapon = [Shotgun, RL, Pistol].pick_random().instantiate()
	my_weapon.my_owner = self
	add_child(my_weapon)
	WEAPON = my_weapon.get_child(1).get_parent() 
	#WEAPON.hide()
	if my_weapon == Shotgun:
		base_damage = 3
	elif my_weapon == RL:
		base_damage = 10
	elif my_weapon == Pistol:
		base_damage = 8
func _physics_process(delta: float) -> void:
	
	var distance = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)
	PlayerLooker.target_position = PlayerLooker.to_local(player.global_position)
	match PlayerLooker.get_collider():
		player:
			Visualiser.default_color = Color('#f181ff')
			is_player_straight = true
		_:
			Visualiser.default_color = Color('#ffffff')
			is_player_straight = false
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	walk(delta, distance, direction)
	velocity.x *= 0.90
	#if WEAPON.is_player_nearby and WEAPON.can_shoot and GlobalVars.player_hp > 0:
		#WEAPON.shoot(base_damage, false)
	if hp <= 0 and str(WEAPON) != "<Freed Object>":
		kill()
	
	var previous_velocity = velocity
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		# TODO: протестировать изменение
		if collider is RigidBody2D:
			if velocity.x + velocity.y > MAX_SPEED * 2:
				collider.apply_impulse(previous_velocity * normal * -0.15)
			else:
				collider.apply_impulse(Vector2(MAX_SPEED, MAX_SPEED) * normal * -0.15)
		elif "Enemy" in str(collider):
			if velocity.x + velocity.y > MAX_SPEED:
				collider.velocity += previous_velocity * normal * -0.3
			else:
				collider.velocity += Vector2(MAX_SPEED, MAX_SPEED) * normal * -0.3

func walk(delta, distance, direction):
	var is_floor = [FloorLookerLeft.get_collider() != null, FloorLookerRight.get_collider() != null]
	if is_player_straight and abs(player.global_position.y - global_position.y) < 75 and\
	distance > 50:
		velocity.x += (MAX_SPEED - abs(velocity.x)) * delta * direction.x * ACCELERATION
		if (is_floor[0] == false and direction.x < 0) or\
		(is_floor[1] == false and direction.x > 0) and is_on_floor():
			jump()
			while not is_on_floor():
				
				FloorLookerLeft.target_position = Vector2(0, 50)
				FloorLookerRight.target_position = Vector2(0, 50)
				if velocity.y > 0 and not (is_floor[0] == true and is_floor[1] == true):
					if is_floor[1] == true:
						velocity.x += (MAX_SPEED - abs(velocity.x)) * delta * 1 * ACCELERATION
					elif is_floor[0] == true:
						velocity.x += (MAX_SPEED - abs(velocity.x)) * delta * -1 * ACCELERATION
					else:
						velocity.x += (MAX_SPEED - abs(velocity.x)) * delta * sign(velocity.x) * -1 * ACCELERATION
				else:
					break
				await get_tree().process_frame
	if not is_player_straight and "Enemy" in str(PlayerLooker.get_collider()):
		jump()
func kill():
	GlobalVars.stats['kills'] += 1
	$Sprite2D.self_modulate = Color(1, 1, 1, 0)
	$EnemyCollision.disabled = true
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
