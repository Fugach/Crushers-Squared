extends Node2D

var activation_range : Vector2 = Vector2(0, 0)
var door1 : Node2D = null
var door2 : Node2D = null
var room_number : int = 0
var pending_enemies : int = 0
var total_enemies : int = 0
var my_enemies = []
const ENEMY = preload("uid://dacw07jts5j8n")
const BOX = preload("uid://bf1hvay56ii3f")



@onready var Camera_pos: Marker2D = $Camera_pos
@onready var Camera: Camera2D = $"../../Camera2D"

func _ready() -> void:
	Camera_pos.global_position += activation_range / 2
	$move.global_position = Camera_pos.global_position
	$remind.global_position = Camera_pos.global_position
	$Area2D.global_position += activation_range / 2
	$Darkness.size = activation_range + Vector2(32, 0)
	$Darkness.global_position.x -= 16
	$Area2D/CollisionShape2D.shape.size = activation_range - Vector2(32, 32)
	$Darkness.set_anchors_preset(Control.PRESET_CENTER)
	$move.set_anchors_preset(Control.PRESET_CENTER)
	if room_number != 0:
		for x in range(randi_range(0, 15)):
			var new_BOX = BOX.instantiate()
			new_BOX.name = "Box_" + str(x)
			new_BOX.global_position = global_position + Vector2((activation_range.x / 2) + randi_range(activation_range.x / (-0.3 * x), activation_range.x / (0.3 * x)), activation_range.y - 20)
			$"..".add_child(new_BOX)

func _process(delta: float) -> void:
	while pending_enemies > 0:
		var new_enemy = ENEMY.instantiate()
		new_enemy.name = "Enemy" + str(total_enemies)
		total_enemies += 1
		new_enemy.global_position = global_position + Vector2((activation_range.x / 2) + randi_range(activation_range.x / -3, activation_range.x / 3), activation_range.y - 20)
		my_enemies.append(new_enemy)
		$"..".add_child(new_enemy)
		pending_enemies -= 1
	for i in range(len(my_enemies) - 1, -1, -1):
		if my_enemies[i] == null:
			my_enemies.remove_at(i)
			print("Enemy is dead! ", len(my_enemies), " left.")
		if my_enemies == []:
			GlobalVars.cleared_rooms[name] = true
			Engine.time_scale = 0.2
			AudioServer.playback_speed_scale = Engine.time_scale
			$move.global_position = GlobalVars.player.global_position - $move.size / 2
			$remind.play()
			$AnimationPlayer.play("remind")
			if door1.Collision.disabled == false:
				door1.call_deferred("lock", "open")
			if door2.Collision.disabled == false:
				door2.call_deferred("lock", "open")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		Camera.is_following = false
		Camera.global_position = Camera_pos.global_position
		$Darkness.hide()
		if GlobalVars.cleared_rooms.has(name) and GlobalVars.cleared_rooms[name] == false and my_enemies == []:
			if door1.Collision.disabled == true:
				door1.call_deferred("lock", "close")
			if door2.Collision.disabled == true:
				door2.call_deferred("lock", "close")
			pending_enemies = randi_range(1,  10)
