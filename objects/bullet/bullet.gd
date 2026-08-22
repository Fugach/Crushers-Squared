extends Node2D
class_name Bullet
@onready var Line : Line2D = $Line2D
@onready var Particles : GPUParticles2D = $GPUParticles2D
@onready var Raycast : RayCast2D = $RayCast2D
@onready var Ricoshet: AudioStreamPlayer2D = $Ricoshet

var flying : bool = true
var damage_amount : int = 0
var is_friendly : bool = false
var blacklist = []
var SPEED = 3000

func _ready() -> void:
	await get_tree().create_timer(60).timeout
	kill()

func _physics_process(delta: float) -> void:
	if not flying:
		return
	
	Raycast.target_position += Vector2.RIGHT * SPEED * delta
	Raycast.force_raycast_update()
	if Raycast.is_colliding():
		var body = Raycast.get_collider()
		if body and body not in blacklist:
			blacklist.append(body)
			hit(body)
			if not flying:
				return
	if flying:
		Line.set_point_position(1, Raycast.target_position)

func hit(body):
	Line.set_point_position(1, Line.to_local(Raycast.get_collision_point()))
	if body == GlobalVars.player and not is_friendly:
		GlobalVars.player.damage(damage_amount, "bullet")
		kill()
	elif body is TileMapLayer or body is StaticBody2D:
		flying = false
		Raycast.enabled = false
		Raycast.target_position = Vector2.ZERO
		wall_particles()
	elif body is Enemy:
		body.damage(damage_amount, "bullet")
		body.push(75, Vector2(1, 0).rotated(global_rotation))
		Raycast.enabled = false
		Raycast.target_position = Vector2.ZERO
		kill()
	elif body is RigidBody2D:# or "Door" in str(body):
		if body.has_method("damage"):
			body.damage(damage_amount, "bullet")
		if body.has_method("push"):
			body.push(50, Vector2(1, 0).rotated(global_rotation))
		kill()
		# старый код рикошета
		#if body.penetrable == false:
			#if randi_range(1, 4) > 1:
				#print('DEATH')
				#Raycast.enabled = false
				#kill()
			#else:
				#print('RICO')
				#Ricoshet.play()
				#global_position = Raycast.get_collision_point()
				#Line.set_point_position(1, Vector2.ZERO)
				#Raycast.target_position = Vector2.ZERO
				#global_rotation += PI + randf_range(PI * -0.5, PI * 0.5)
	elif body is CharacterBody2D and body.name not in ['Elevator']:
		Raycast.enabled = false
		kill()
	else:
		print('Hey, what is the ', body.get_class(), '?')
func wall_particles():
	Particles.global_position = Raycast.get_collision_point()
	Particles.emitting = true
	for x in range(2):
		await get_tree().process_frame
	Line.hide()

func _on_gpu_particles_2d_finished() -> void:
	kill()

func kill():
	flying = false
	set_physics_process(false)
	Raycast.enabled = false
	for x in range(2):
		await get_tree().process_frame
	Line.hide()
	queue_free()
