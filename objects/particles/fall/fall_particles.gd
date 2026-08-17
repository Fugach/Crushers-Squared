extends GPUParticles2D
var max_vel : float = 0.0
var min_vel : float = 0.0
func _ready() -> void:
	process_material.initial_velocity_min = min_vel
	process_material.initial_velocity_max = max_vel
	emitting = true
func _on_finished() -> void:
	queue_free()
