extends RigidBody2D
var PISTOL_PICKABLE = preload("uid://5j581geyyouk")
var RL_PICKABLE = preload("uid://b6yunx8h1pcdi")
var SHOTGUN_PICKABLE = preload("uid://dhjphrjas8n7d")
const ENEMY = preload("uid://dacw07jts5j8n")

var penetrable = true
var hp : int = 25

func damage(amount, type):
	hp -= amount
	$soft.pitch_scale = randf_range(0.7, 1.3)
	$soft.play()
	if hp <= 0 and modulate.a != 0:
		var chance = randi_range(1, 100)
		if chance < 20:
			var new_pistol = PISTOL_PICKABLE.instantiate()
			new_pistol.global_position = global_position
			get_parent().add_child(new_pistol)
			print("new_pistol")
		elif chance >= 20 and chance < 70:
			var new_shotgun = SHOTGUN_PICKABLE.instantiate()
			new_shotgun.global_position = global_position
			get_parent().add_child(new_shotgun)
			print("new_shotgun")
		elif chance >= 70 and chance < 100:
			var new_rl = RL_PICKABLE.instantiate()
			new_rl.global_position = global_position
			get_parent().add_child(new_rl)
			print("new_RL")
		else:
			var new_enemy = ENEMY.instantiate()
			new_enemy.global_position = global_position
			get_parent().add_child(new_enemy)
		$break.pitch_scale = randf_range(0.7, 1.3)
		$break.play()
		$CollisionPolygon2D.disabled = true
		modulate.a = 0


func _on_break_finished() -> void:
	queue_free()
