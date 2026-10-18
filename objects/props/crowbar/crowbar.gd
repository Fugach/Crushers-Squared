extends RigidBody2D

@onready var player = GlobalVars.player
var is_touching_cursor : bool = false
var is_grabbed : bool = false
var is_holding : bool = false
func _ready() -> void:
	scale *= 2.0

func _process(delta: float) -> void:
	pass
func push(pwr, dir):
	linear_velocity += dir * pwr

func _on_control_mouse_entered() -> void:
	is_touching_cursor = true


func _on_control_mouse_exited() -> void:
	is_touching_cursor = false
