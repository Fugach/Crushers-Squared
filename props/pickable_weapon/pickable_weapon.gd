extends RigidBody2D

var weapon = null
const weapons : Dictionary = {
	'pistol' : "uid://cdavqdqek4rr5",
	'shotgun' : "uid://bsecy8dw60b21",
	'rocket_launcher' : "uid://brcehntt6lxn6",
}

@onready var Sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var player = GlobalVars.player

func _ready() -> void:
	$SpawnCooldown.start()
	for node in get_children():
		if node is CollisionPolygon2D:
			node.disabled = true
	if weapon in ['pistol', 'shotgun', 'rocket_launcher']:
		name = weapon
		Sprite.animation = weapon
		get_node("Collision_" + str(weapon)).disabled = false
	else:
		push_error("Unknown weapon: ", weapon)

func _physics_process(_delta: float) -> void:
	if global_position.y > 5000 and linear_velocity.y > 5000:
		print('bye-bye!')
		queue_free()

func push(pwr, dir):
	linear_velocity += dir * pwr

func pick_up(character : Node2D):
	if not $SpawnCooldown.is_stopped():
		return
	set_deferred("freeze", true)
	hide()
	if character is Player:
		for x in GlobalVars.slots:
				if null == GlobalVars.slots[x]:
					var new_weapon = load(weapons[weapon]).instantiate()
					new_weapon.my_owner = character
					new_weapon.my_slot = x
					player.call_deferred("add_child", new_weapon)
					queue_free()
					return
