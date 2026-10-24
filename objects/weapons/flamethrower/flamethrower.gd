extends Node2D

var my_owner
var can_shoot : bool = false
var my_slot : int
var temperature : float = 25
var FIRE = GlobalVars.FIRE
const my_name = 'flamethrower'

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func shoot():
	if $ShootDelay.time_left > 0 or $OverheatCooldown.time_left > 0 or not can_shoot:
		return
	for i in range(1):
		var new = FIRE.instantiate()
		new.global_position = $ShootPosition.global_position + Vector2.RIGHT.rotated(global_rotation) * randf_range(0, 20)
		new.global_rotation = global_rotation + randf_range(-0.075, 0.075)
		get_node("/root/main").add_child(new)
	$ShootDelay.start()
	#temperature += 25
	if temperature >= 5000:
		$OverheatCooldown.start()

func pull_out():
	$DrawTime.start()
	$AnimationPlayer.play("pull_out")
	show()
	set_process(true)

func put_away():
	can_shoot = false
	hide()
	set_process(false)


func _on_draw_time_timeout() -> void:
	can_shoot = true
func _on_shoot_delay_timeout() -> void:
	can_shoot = true


func _on_overheat_cooldown_timeout() -> void:
	temperature = 25
