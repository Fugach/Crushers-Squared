extends RigidBody2D

@onready var player = GlobalVars.player
const pistol = preload("uid://cdavqdqek4rr5")

var check : bool = false
var penetrable : bool = false

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
					var new_pistol = pistol.instantiate()
					new_pistol.weapon_owner = "Player"
					new_pistol.name = "Pistol_" + str(x)
					new_pistol.my_slot = x
					player.add_child(new_pistol)
					$pickup.play()
					check = false
					break

func _on_pickup_finished() -> void:
	queue_free()
