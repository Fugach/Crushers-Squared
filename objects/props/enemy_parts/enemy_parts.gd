extends RigidBody2D

@onready var Splash_small: AnimatedSprite2D = $Sprite_small
@onready var Sprite_big: AnimatedSprite2D = $Sprite_big

const gravity : float = 9.8
var direction : Vector2 = Vector2(0, 0)
var power : float = 0.0
var heal : int = 0

func _ready() -> void:
	
	Splash_small.play(str(randi_range(1, 20)))
	Sprite_big.play(str(randi_range(1, 20)))
	Splash_small.modulate = Color.from_rgba8(210 + randi_range(-10, 10), 225 + randi_range(-10, 10), 38, 255)
	Sprite_big.modulate = Splash_small.modulate
	apply_impulse(power * direction)

func _process(_delta: float) -> void:
	pass
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		if GlobalVars.player_hp < 100:
			GlobalVars.heal(heal)
			$Anim.play("hide")
			freeze = true
	elif body is TileMapLayer:
		Splash_small.hide()
		$Area2D_small.hide()
		#call_deferred("freeze", true)
		#$Area2D_small.call_deferred("monitoring", false)

func _on_anim_animation_finished(_anim_name: StringName) -> void:
	queue_free()
