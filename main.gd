extends Node2D

@onready var CRT : ColorRect = $UI/Restart/CRT
@onready var CRT_mat: ShaderMaterial = CRT.material as ShaderMaterial
@onready var RestartUI : CanvasLayer = $UI/Restart
@onready var PauseUI : CanvasLayer = $UI/Pause
@onready var HUD : CanvasLayer = $UI/HUD
@onready var HPBar : TextureProgressBar = $UI/HUD/HPBar
@onready var HPLabel : Label = $UI/HUD/HPBar/HPLabel

@onready var Table: Node2D = $UI/HUD/Table

@onready var Camera: Camera2D = $Camera2D

var default = preload("res://textures/cursors/default.png")
var pointer = preload("res://textures/cursors/pointer.png")
var grabbing = preload("res://textures/cursors/grabbing.png")
var text = preload("res://textures/cursors/text.png")
var no = preload("res://textures/cursors/no.png")

const PLAYER = preload("uid://7pwfca8tanen")

func _ready() -> void:
	var player = PLAYER.instantiate()
	player.name = 'Player'
	add_child(player)
	player = $Player
	GlobalVars.player = player
	GlobalVars.slots = {
	"slot1": null,
	"slot2": null,
	"slot3": null
	}
	GlobalVars.current_slot_node = null
	GlobalVars.current_slot_num = "slot1"
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	load_config()
	GlobalVars.main = self
	player.respawn()
	$SubViewport.use_hdr_2d = true
	$UI/Pause/AnimationPlayer.play_backwards("appear")
	

func load_config():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), GlobalConfig.get_value("audio", "Master_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), GlobalConfig.get_value("audio", "Music_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), GlobalConfig.get_value("audio", "Sound_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Atmosphere"), GlobalConfig.get_value("audio", "Atmosphere_volume_db"))

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("crash"):
		get_tree().quit(0)

func _process(_delta: float) -> void:
	HUD.scale = Camera.scale
	HPLabel.text = str(GlobalVars.player_hp)
	HPBar.value = float(GlobalVars.player_hp)
	if GlobalVars.passed_layers > 3:
		get_tree().paused = false
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		get_tree().change_scene_to_file("res://main_menu.tscn")
	if GlobalVars.player.global_position.y > 2000:
		GlobalVars.player.respawn()
		if not $UI/HUD/QuickVolume/lost.playing:
			$UI/HUD/QuickVolume/lost.play()
		Input.set_custom_mouse_cursor(no)
		$TileMapLayer.command()
		
	if Input.is_action_just_pressed("mmb"):
		$TileMapLayer.gen_dungeon(1, Vector2(3, 2))
		GlobalVars.player.respawn()
		GlobalVars.time = 0.0
	if Input.is_action_just_pressed("esc"):
		if not Table.visible and not get_tree().paused:
			get_tree().paused = true
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
			$UI/Pause.show()
			$UI/Pause/AnimationPlayer.play("appear")
		#else:
			#Engine.time_scale = 0.5
			#$UI/Pause.hide()
			#get_tree().paused = false
			#get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	if Engine.time_scale != 1.0:
		if Engine.time_scale < 0.5:
			Engine.time_scale = lerpf(Engine.time_scale, 1.0, 0.005)
		else:
			Engine.time_scale = lerpf(Engine.time_scale, 1.0, 0.2)
		AudioServer.playback_speed_scale = Engine.time_scale
func death():
	GlobalVars.player_hp = 0
	$UI/HUD/HPBar/HPLabel.text = str(GlobalVars.player_hp)
	$UI/HUD/HPBar.value =  GlobalVars.player_hp
	$UI/Restart.death()
	get_tree().paused = true


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_continue_pressed() -> void:
	Engine.time_scale = 0.5
	$UI/Pause.hide()
	get_tree().paused = false
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT


func _on_hp_bar_value_changed(value: float) -> void:
	if not HPBar.value > 0:
		HPBar.value = 0
		HPLabel.text = "0"
		GlobalVars.player_hp = 0
		death()

func _on_lost_finished() -> void:
	get_tree().quit(-1)


func _on_exit_mouse_entered() -> void:
	$UI/Pause/ColorRect/exit.text = ">> ВЫХОД <<"
func _on_exit_mouse_exited() -> void:
	$UI/Pause/ColorRect/exit.text = "ВЫХОД"


func _on_continue_mouse_entered() -> void:
	$UI/Pause/ColorRect/continue.text = ">> ПРОДОЛЖИТЬ <<"
func _on_continue_mouse_exited() -> void:
	$UI/Pause/ColorRect/continue.text = "ПРОДОЛЖИТЬ"

func _on_restart_pressed() -> void:
	GlobalVars.player.respawn()
func _on_restart_mouse_entered() -> void:
	$UI/Pause/ColorRect/restart.text = ">> ПЕРЕЗАПУСК <<"
func _on_restart_mouse_exited() -> void:
	$UI/Pause/ColorRect/restart.text = "ПЕРЕЗАПУСК"
