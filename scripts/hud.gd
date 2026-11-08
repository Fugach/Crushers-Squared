extends CanvasLayer

@onready var Console : RichTextLabel = $Console
@onready var Camera : Camera2D = $"../../Camera"
@onready var label = $HP/Label
@onready var Bar = $HP/HPBar
@onready var Bar_sm = $HP/HPBar_smooth
@onready var Delay = $HP/Delay

func _process(delta: float) -> void:
	scale = Camera.scale
	update_hpbar()

func _physics_process(delta: float) -> void:
	#print($Ammo.position)
	$Ammo.position = lerp(
			$Ammo.position,
			Vector2(get_viewport().size) / 2 + GlobalVars.player.velocity / -50,
			0.2
		)

func update_hpbar():
	var hp = GlobalVars.player.stats['HP']
	label.text = str(hp)
	if Bar.value != float(hp):
		Bar.value = lerp(Bar.value, float(hp), 0.5)

func _on_timer_timeout() -> void:
	while not (Bar_sm.value - 1 == Bar.value) and not (Bar_sm.value == Bar.value):
		Bar_sm.value = lerp(Bar_sm.value, Bar.value, 0.5)
		await get_tree().process_frame

func _on_upgrade_1_mouse_entered() -> void:
	if not $Table/Upgrade1.disabled:
		$Table/Upgrade1/choose.play()
func _on_upgrade_2_mouse_entered() -> void:
	if not $Table/Upgrade1.disabled:
		$Table/Upgrade2/choose.play()
func _on_upgrade_3_mouse_entered() -> void:
	if not $Table/Upgrade1.disabled:
		$Table/Upgrade3/choose.play()


func _on_hp_bar_value_changed(value: float) -> void:
	Delay.start()
	if Bar.value <= 0:
		Bar.value = 0
		label.text = "0"
		GlobalVars.player.stats['HP'] = 0
		get_parent().get_parent().death()
