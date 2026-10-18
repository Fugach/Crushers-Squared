extends CanvasLayer

@onready var Player = GlobalVars.player
@onready var RestartUI : CanvasLayer = $"."
@onready var CRT : ColorRect = $CRT
@onready var choose : AudioStreamPlayer2D = $choose
@onready var noise : AudioStreamPlayer = $noise
@onready var No : Button = $ColorRect/No
@onready var Yes : Button = $ColorRect/Yes
@onready var Again: Label = $ColorRect/Again
@onready var Tries: Label = $ColorRect/Tries

func death():
	get_parent().get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	GlobalVars.apply_CRT($CRT.material)
	$AnimationPlayer.play("appear")
	show()
	noise.playing = true
	if GlobalVars.lifes != 0:
		if GlobalVars.lifes > 1:
			Tries.text = "У тебя есть ещё " + str(GlobalVars.lifes) + " шанса на победу"
		else:
			Tries.text = "Последний шанс. \n \n \n я верю в тебя."
	else:
		Tries.text = "мне очень жаль"
		Again.text = "Конец"
		No.text = "ВЫХОД"
		Yes.hide()

func _on_no_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
func _on_no_mouse_entered() -> void:
	choose.play()
	if GlobalVars.lifes != 0:
		No.text = ">НЕТ<"
	else:
		No.text = ">ВЫХОД<"
func _on_no_mouse_exited() -> void:
	if GlobalVars.lifes != 0:
		No.text = "НЕТ"
	else:
		No.text = "ВЫХОД"


func _on_yes_pressed() -> void:
	get_parent().get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	Player = GlobalVars.player
	get_tree().paused = false
	Player.respawn()
	GlobalVars.lifes -= 1
	$ColorRect.modulate.a = 0
	CRT.modulate.a = 0
	RestartUI.hide()
	$AnimationPlayer.stop()
	noise.stop()
func _on_yes_mouse_entered() -> void:
	choose.play()
	Yes.text = ">ДА<"
func _on_yes_mouse_exited() -> void:
	Yes.text = "ДА"
