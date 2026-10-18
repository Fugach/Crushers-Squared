extends Node2D

var is_spamming : bool = false
func _ready():
	$stop_sign.play("1")
func _process(_delta: float):
	if Input.is_action_just_pressed("rmb") and $tip.visible:
		if is_spamming:
			$stop_sign.play(str(randi_range(3, 7)))
			$Timer.start()
		else:
			$stop_sign.play("2")
			$Timer.start()
			is_spamming = true
		$stop_sign/no.play()

func _on_area_2d_body_entered(body: Node2D):
	if body == GlobalVars.player:
		$tip.show()
func _on_area_2d_body_exited(body: Node2D):
	if body == GlobalVars.player:
		$tip.hide()

func _on_timer_timeout() -> void:
	$stop_sign.play("1")
	is_spamming = false

func _on_no_finished() -> void:
	$stop_sign.play("1")
