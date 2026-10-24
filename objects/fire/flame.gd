extends CharacterBody2D
var frames : int = 0
const SPEED : float = 300
@onready var rc = $RayCast2D

func _ready() -> void:
	$AliveTime.start(randf_range(0.3, 0.6))
	velocity = SPEED * Vector2.RIGHT.rotated(global_rotation) + GlobalVars.player.velocity
	$Sound.pitch_scale = randf_range(0.8, 1.2)
	
func _physics_process(delta: float) -> void:
	
	velocity *= 0.99
	#$RayCast2D.force_raycast_update()
	move_and_slide()
	velocity.y -= 1.5
	if $AliveTime.time_left <= 0.2:
		pass

func _process(delta: float) -> void:
	pass


func _on_alive_time_timeout() -> void:
	queue_free()
