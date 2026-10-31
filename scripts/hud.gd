extends CanvasLayer

@onready var Console : RichTextLabel = $Console
@onready var Camera : Camera2D = $"../../Camera"

func _process(delta: float) -> void:
	scale = Camera.scale
	update_hpbar()

func update_hpbar():
	var label = $HP/HPBar/HPLabel
	var bar = $HP/HPBar
	var bar_sm = $HP/HPBar_smooth
	var hp = GlobalVars.player.stats['HP']
	label.text = str(hp)
	if bar.value != float(hp):
		bar.value = lerp(bar.value, float(hp), 0.5)

func _on_timer_timeout() -> void:
	var bar = $HP/HPBar
	var bar_sm = $HP/HPBar_smooth
	while bar_sm.value != bar.value:
		bar_sm.value = lerp(bar_sm.value, bar.value, 0.5)
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
	$HP/HPBar/Timer.start()
	if $HP/HPBar.value <= 0:
		$HP/HPBar.value = 0
		$HP/HPBar/HPLabel.text = "0"
		GlobalVars.player.stats['HP'] = 0
		get_parent().get_parent().death()
