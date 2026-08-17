extends Sprite2D

@onready var RayCast: RayCast2D = $RayCast2D
@onready var Particles: CPUParticles2D = $CPUParticles2D
@onready var ExplosionPos: Sprite2D = $Babax
@onready var Collision: Area2D = $Babax/BabaxCollision

var damage_amount : int = -5
var can_push : bool = true
var speed = 100
var direction = 1
var is_emitting : bool = false
const SPEED: float = 500.0
var is_friendly : bool = false
var targets = []

func _ready():
	Collision.monitoring = false
	Particles.emitting = false
	ExplosionPos.hide()
func _physics_process(delta: float):
	if not is_emitting:
		if RayCast.is_colliding():
			destroy()
		else:
			global_position += Vector2(1, 0).rotated(rotation) * SPEED * delta

func destroy():
	self_modulate.a = 0
	$fire.self_modulate.a = 0
	Particles.global_position = RayCast.get_collision_point() + RayCast.get_collision_normal() * 5.0
	ExplosionPos.global_position = RayCast.get_collision_point() + RayCast.get_collision_normal() * 5.0
	Particles.amount = randi_range(5, 20)
	ExplosionPos.global_rotation = 0
	
	Collision.monitoring = true
	Particles.emitting = true
	is_emitting = true
	ExplosionPos.rotate(randf_range(0.00, 2.00 * PI))
	ExplosionPos.show()
	$Babax/AnimationPlayer.play("explostion_increasing")
	$Babax/AudioStreamPlayer2D.pitch_scale = randfn(1.0, 0.2)
	$Babax/AudioStreamPlayer2D.play()
	GlobalVars.player.Camera.shake(0.05, clamp((1 - (global_position.distance_to(GlobalVars.player.global_position) / 500)) * 3, 0.0, 1.0))

func _on_distance_timeout():
	queue_free()

func _on_cpu_particles_2d_finished():
	queue_free()

func _on_collision_body_entered(body: Node2D):
	if ((body is CharacterBody2D) or (body is RigidBody2D) or ("Bullet" in body.name) or body is StaticBody2D or "Door" in str(body)) and can_push:
		if body.has_method("damage") and body not in targets:
			targets.append(body)
			if body == GlobalVars.player and is_friendly:
				body.damage(8, "explosion")
			else:
				body.damage(25, "explosion")
		var explosion_pos = ExplosionPos.global_position
		var dir = (body.global_position - explosion_pos).normalized()
		var distance = explosion_pos.distance_to(body.global_position)
		var force = 800.0 / max(distance * 0.08, 1.0)
		if body.has_method("push"):
			body.push(force, dir)
func _on_animation_finished(_anim_name: StringName) -> void:
	can_push = false
