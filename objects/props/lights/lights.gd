extends Sprite2D

var light_scale : float = 0.0
func _ready() -> void:
	$PointLight2D.texture_scale = light_scale
