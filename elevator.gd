extends Area2D

@onready var Tip: Sprite2D = $Outside/tip
@onready var Elevator: AnimatedSprite2D = $Outside/Elevator
@onready var Tile_map_layer : TileMapLayer = $"../TileMapLayer"
@onready var Tile_map_layer_bg : TileMapLayer = $"../TileMapLayer/bg"
@onready var Inside : StaticBody2D = $Inside
@onready var Outside: Node2D = $Outside
@onready var Camera: Camera2D = $"../Camera"
@onready var HUD: CanvasLayer = $"../UI/HUD"

func _ready() -> void:
	$Inside.modulate.a = 0
func _on_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		Elevator.play("open")
		Tip.show()

func _on_body_exited(body: Node2D) -> void:
	if body == GlobalVars.player:
		Tip.hide()
		Elevator.play("close")

func _process(_delta: float):
	if Input.is_action_just_pressed("rmb") and Tip.visible:
		GlobalVars.is_time_running = false
		GlobalVars.player.goto_elevator()
		Tip.hide()

func results():
	$noise.play()
	$Inside/CollisionPolygon2D.disabled = false
	$AnimationPlayer.play("show_inside")
	GlobalVars.player.velocity = Vector2(0, 0)

func outside():
	$noise.stop()
	$"../elevator_fake/done".play()
	$AnimationPlayer.play("show_outside")
	GlobalVars.player.can_jump = true
	Camera.is_following = true
	$Inside/CollisionPolygon2D.disabled = true
	GlobalVars.time = 0.0
	GlobalVars.is_time_running = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "show_inside":
		HUD.results()
		Camera.is_following = false
		Camera.global_position = global_position + Vector2(0, -85)
		GlobalVars.player.Anims.play("show")
		GlobalVars.player.SPEED = GlobalVars.player.SPEED_buffer
		GlobalVars.player.can_jump = false
