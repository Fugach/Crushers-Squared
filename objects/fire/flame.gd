extends CharacterBody2D

const SPEED : float = 400
var blacklist = []
@onready var area = $Area2D

func _ready() -> void:
	$AliveTime.start()
	velocity = SPEED * Vector2.RIGHT.rotated(global_rotation) + GlobalVars.player.velocity / 4
	$Sound.pitch_scale = randf_range(0.8, 1.2)
	$SpriteFlame.global_rotation = PI / 2 * randi_range(0, 3)
	$SpriteSmoke.global_rotation = PI / 2 * randi_range(0, 3)
	$SpriteSmoke.self_modulate.a = 0.0
	
func _physics_process(delta: float) -> void:
	# Старый метод, при замедлении времени огонь останавливается КУДА быстрее
	#velocity *= 0.98
	
	# Другой метод, но если игра зависнет то кабзда
	#velocity *= 1.0 - 1.2 * delta
	
	# Вроде норм, некое "экспоненциальное затухание".
	# Я слишком тупой для того, чтобы понять, каким образом это получается.
	# Но оно работает, и проблем не должно вызывать
	velocity *= pow(0.5, 1.2 * delta)
	
	velocity.y -= 1.5 * delta
	
	move_and_slide()
	
	if $AliveTime.time_left <= 0.2 + randf_range(-0.05, 0.05):
		var percent = $AliveTime.time_left / 0.2
		var percent_backwards = abs($AliveTime.time_left - 0.2) / 0.2
		$SpriteFlame.self_modulate.a = $AliveTime.time_left / (0.2  + randf_range(-0.05, 0.05))
		$SpriteSmoke.self_modulate.a = percent_backwards
		$SpriteFlame.self_modulate = Color(percent_backwards, percent_backwards, percent_backwards)
		$SpriteSmoke.self_modulate = Color(percent, percent, percent)
		#print(percent)

func _on_alive_time_timeout() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body in blacklist:
		return
	else:
		blacklist.append(body)
	velocity *= 0.7
	if body.has_method('damage'):
		body.damage(5, 'fire')
	
