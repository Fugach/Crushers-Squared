extends Node2D
@onready var Sprite: AnimatedSprite2D = $Sprite
@onready var Occluder: LightOccluder2D = $LightOccluder2D
@onready var Collision: CollisionShape2D = $StaticBody2D/Collision
var opened = true
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player or body is RigidBody2D or "Enemy" in str(body):
		if opened:
			Collision.set_deferred("disabled", true)
			Occluder.hide()
			Sprite.speed_scale = 1.0 + (body.global_position.x / global_position.x)
			Sprite.play("open")
			$open.pitch_scale = randf_range(0.7, 1.3)
			$open.play()
		else:
			$locked.pitch_scale = randf_range(0.7, 1.3)
			$locked.play()
func lock(state):
	if state == "close":
		opened = false
		$open.stop()
		Sprite.play("close", 3.0)
		Collision.set_deferred("disabled", false)
	elif state == "open":
		opened = true
func _on_open_finished() -> void:
	Sprite.play("close")
	$close.pitch_scale = randf_range(0.7, 1.3)
	$close.play()
	Occluder.show()
	Collision.set_deferred("disabled", false)
