extends Control

@onready var Percent: ProgressBar = $percent
@onready var Progress: TextureProgressBar = $progress
@onready var Db: Label = $db
@onready var Blip: AudioStreamPlayer2D = $blip
@onready var Vol_window: AnimatedSprite2D = $Window
@onready var Infinity: Sprite2D = $infinity
@onready var Vol_timer: Timer = $display_timer
@onready var Anim: AnimationPlayer = $anim
@onready var Cooldown: Timer = $cooldown

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), GlobalConfig.get_value("audio", "Master_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), GlobalConfig.get_value("audio", "Music_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), GlobalConfig.get_value("audio", "Sound_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Atmosphere"), GlobalConfig.get_value("audio", "Atmosphere_volume_db"))
	Vol_window.play("default")
	Anim.play("RESET")
	update()

func update():
	Blip.pitch_scale = 1.0 + AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) * 0.01
	Percent.value = round((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) + 25) / 50 * 100)
	if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) > 0:
		Infinity.hide()
		Db.text = "|    +" + str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) + " дб"
	elif AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) == -80:
		Infinity.show()
		Db.text = "|     -                дб"
	elif AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) < 0:
		Infinity.hide()
		Db.text = "|    " + str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) + " дб"
	elif AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) == 0:
		Infinity.hide()
		Db.text = "|         0.0 дб"
	Progress.value = Percent.value
	
	GlobalConfig.save_audio(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Atmosphere")))

func _process(_delta: float) -> void:
	if Input.is_action_pressed("vol_up") and Cooldown.is_stopped():
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), min(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) + 1, 25))
		if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) <= -75:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -25)
		if modulate == Color("ffffff00"):
			Anim.play("show")
		elif Anim.current_animation == "hide":
			Anim.play_backwards("hide")
		Blip.play()
		update()
		Cooldown.start()
		Vol_timer.start()
	elif Input.is_action_pressed("vol_down") and Cooldown.is_stopped():
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), max(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) - 1, -26))
		if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) == -26:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80.0)
		if modulate == Color("ffffff00"):
			Anim.play("show")
		elif Anim.current_animation == "hide":
			Anim.play_backwards("hide")
		Blip.play()
		update()
		Cooldown.start()
		Vol_timer.start()


func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "show":
		$display_timer.start()


func _on_display_timer_timeout() -> void:
	Anim.play("hide")
	GlobalConfig.save_audio(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Atmosphere")))
