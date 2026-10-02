extends Area2D
var frames : int = 0
var MAX_SPEED : float = 450
var SPEED : float

func _ready() -> void:
	SPEED = MAX_SPEED
	$Sound.pitch_scale = randf_range(0.8, 1.2)

func _physics_process(delta: float) -> void:
	global_position += SPEED * Vector2.RIGHT.rotated(rotation) * delta

func _process(delta: float) -> void:
	if SPEED > 0:
		SPEED -= 10
		$Sprite2D.self_modulate.a = (SPEED / MAX_SPEED) * 255
		print($Sprite2D.self_modulate)
	else:
		SPEED = 0

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
