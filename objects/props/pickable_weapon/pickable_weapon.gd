extends RigidBody2D

var weapon = ''
@onready var SpawnCooldown = $SpawnCooldown
const weapons : Dictionary = {
	'PISTOL' : "uid://cdavqdqek4rr5",
	'SHOTGUN' : "uid://bsecy8dw60b21",
	'ROCKET_LAUNCHER' : "uid://brcehntt6lxn6",
	'FLAMETHROWER' : "uid://dpyw2wrkrp64a",
}

@onready var Sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var player = GlobalVars.player

func _ready() -> void:
	SpawnCooldown.start()
	for node in get_children():
		if node is CollisionPolygon2D:
			node.disabled = true
	if weapon in weapons.keys():
		name = weapon
		Sprite.animation = weapon.to_lower()
		get_node("Collision_" + str(weapon).to_lower()).disabled = false
	else:
		push_error("Unknown weapon: ", weapon)

func _physics_process(_delta: float) -> void:
	if global_position.y > 5000 and linear_velocity.y > 5000:
		print('bye-bye!')
		queue_free()

func push(pwr, dir):
	linear_velocity += dir * pwr

func pick_up(character : Node2D):
	if not SpawnCooldown.is_stopped():
		return
	set_deferred("freeze", true)
	hide()
	if character == GlobalVars.player:
		for x in GlobalVars.player.inventory:
				if null == GlobalVars.player.inventory[x]:
					var new_weapon = load(weapons[weapon]).instantiate()
					new_weapon.my_owner = character
					#new_weapon.my_slot = x
					player.call_deferred("add_child", new_weapon)
					GlobalVars.player.inventory.set(x, new_weapon)
					GlobalVars.slots_node.call_deferred('update')
					GlobalVars.player.call_deferred('switch_to', x)
					queue_free()
					return
