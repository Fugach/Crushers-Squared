extends RigidBody2D

@onready var player = GlobalVars.player
var is_touching_cursor : bool = false
var is_grabbed : bool = false
var max_hp : int = 25
var hp : int = 0
var penetrable : bool = false

func _ready() -> void:
	hp = max_hp
	update()

func push(pwr, dir):
	linear_velocity += dir * pwr

func _on_area_2d_mouse_entered() -> void:
	is_touching_cursor = true
func _on_area_2d_mouse_exited() -> void:
	is_touching_cursor = false

func damage(amount, type):
	hp -= amount
	if hp > 0:
		$soft.play()
	else:
		$break.play()
		$CollisionShape2D.set_deferred("disabled", true)
		modulate.a = 0
	update()

func _on_break_finished() -> void:
	queue_free()

func update():
	print(max_hp / 1.1)
	if hp > max_hp / 1.1:
		$AnimatedSprite2D.play("normal")
		$CollisionPolygon0.show()
		$CollisionPolygon1.hide()
		$CollisionPolygon2.hide()
	elif hp < max_hp / 1.1 and hp > max_hp / 5:
		$AnimatedSprite2D.play("a_little_damaged")
		$CollisionPolygon0.hide()
		$CollisionPolygon1.show()
		$CollisionPolygon2.hide()
	else:
		$AnimatedSprite2D.play("almost_broken")
		$CollisionPolygon0.hide()
		$CollisionPolygon1.hide()
		$CollisionPolygon2.show()
	print($AnimatedSprite2D.frame, " | ", hp)
