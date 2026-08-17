extends RigidBody2D

@onready var player = GlobalVars.player
const shotgun = preload("uid://bsecy8dw60b21")

var penetrable : bool = false
var check : bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if visible and body.name == "Player":
		check = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		check = false

func push(pwr, dir):
	linear_velocity += dir * pwr

func _process(_delta: float) -> void:
	if check:
		for x in GlobalVars.slots:
				if null == GlobalVars.slots[x]:
					$Area2D.set_deferred("monitoring", false)
					$Area2D.set_deferred("monitorable", false)
					collision_layer = 16
					$Sprite2D.self_modulate.a = 0.0
					var new_shotgun = shotgun.instantiate()
					new_shotgun.weapon_owner = "Player"
					new_shotgun.name = "Shotgun_" + str(x)
					new_shotgun.my_slot = x
					player.add_child(new_shotgun)
					$pickup.play()
					check = false
					break

func _on_pickup_finished() -> void:
	queue_free()
