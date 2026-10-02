extends CanvasLayer

@onready var Console : RichTextLabel = $Console
@onready var Anim : AnimationPlayer = $AnimationPlayer
@onready var Tiles : TileMapLayer = $"../../TileMapLayer"
@onready var TilesAnim : AnimationPlayer = $"../../TileMapLayer/AnimationPlayer"
@onready var Elevator : Area2D = $"../../Elevator"
@onready var Camera : Camera2D = $"../../Camera2D"

func wait(time):
	await get_tree().create_timer(time).timeout
func repeat(text, amount):
	for x in range(amount):
		Console.text += text
func _process(delta: float) -> void:
	scale = Camera.scale
	hpbar_update()
func results():
	$"../MUSIC/results".play()
	$"../..".get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	Console.text = "                         -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                      РРРРРРР    ЕЕЕЕЕЕЕЕ   ЗЗЗЗЗЗ       УУ       УУ        ЛЛЛЛЛЛЛ       ЬЬ                 ТТТТТТТТТТ       АААААА      ТТТТТТТТТТ   ЫЫ                   ЫЫ          
                                       РР           Р  ЕЕ                         ЗЗ   УУ       УУ       ЛЛ        ЛЛ       ЬЬ                        ТТ            АА         АА           ТТ         ЫЫ                  ЫЫ      
                                        РРРРРРР    ЕЕЕЕЕЕЕ      ЗЗЗЗЗ          УУУУУУ        ЛЛ        ЛЛ      ЬЬЬЬЬЬЬ           ТТ            АААААААА          ТТ         ЫЫЫЫЫЫ      ЫЫ      
                                         РР               ЕЕ                         ЗЗ              УУ        ЛЛ        ЛЛ     ЬЬ         ЬЬ      ТТ            АА         АА         ТТ         ЫЫ         ЫЫ   ЫЫ           
                                           РР              ЕЕЕЕЕЕЕЕ   ЗЗЗЗЗЗ       УУУУУУ      ЛЛЛ         ЛЛ    ЬЬЬЬЬЬЬ        ТТ           АА         АА        ТТ         ЫЫЫЫЫЫ      ЫЫ          
                         ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
"
	Anim.play("hide_hud")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide_hud":
		Console.text += "\n\n\n\n"
		repeat(" ", 125)
		Console.text += "ВРЕМЯ |"
		await wait(0.5)
		repeat(" ", 35)
		if GlobalVars.time >= 60:
			Console.text += str(int(GlobalVars.time) / 60)
		else:
			Console.text += "00"
		Console.text += " : "
		await wait(0.5)
		if GlobalVars.time >= 10:
			Console.text += str(int(GlobalVars.time) % 60)
		else:
			Console.text += "0" + str(int(GlobalVars.time) % 60)
		await wait(0.5)
		Console.text += "\n"
		repeat(" ", 125)
		Console.text += "ВРАГОВ УНИЧТОЖЕНО"
		await wait(0.5)
		Console.text += "             " + str(GlobalVars.killed)
		Console.text += "\n"
		repeat(" ", 125)
		await wait(0.5)
		Console.text += "ДО КОНЦА ОСТАЛОСЬ"
		await wait(0.5)
		Console.text += "              " + str(3 - GlobalVars.passed_layers)

func hpbar_update():
	var lab = $HPBar/HPLabel
	var bar = $HPBar
	var bar_sm = $HPBar_smooth
	var hp = GlobalVars.player.my_stats['hp']
	lab.text = str(hp)
	if bar.value != float(hp):
		bar.value = lerp(bar.value, float(hp), 0.5)
		print(bar.value - float(hp))

func _on_timer_timeout() -> void:
	var bar = $HPBar
	var bar_sm = $HPBar_smooth
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
	$HPBar/Timer.start()
	if $HPBar.value <= 0:
		$HPBar.value = 0
		$HPBar/HPLabel.text = "0"
		GlobalVars.player_hp = 0
		get_parent().get_parent().death()
