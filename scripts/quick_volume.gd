extends Control

@onready var Percent: Label = $Percent
@onready var Progress: TextureProgressBar = $Progress
@onready var Blip: AudioStreamPlayer2D = $Blip
@onready var Bg: AnimatedSprite2D = $Bg
@onready var DisplayTimer: Timer = $Display_timer
@onready var Cooldown: Timer = $Cooldown

var volume : float
var target_pos : Vector2 = Vector2(0, 0)
@onready var hidden_pos : Vector2 = Vector2(get_viewport().size.x / 4, -50)
@onready var shown_pos : Vector2 = Vector2(get_viewport().size.x / 4, 35)

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), GlobalConfig.get_value("audio", "Master_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), GlobalConfig.get_value("audio", "Music_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), GlobalConfig.get_value("audio", "Sound_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Atmosphere"), GlobalConfig.get_value("audio", "Atmosphere_volume_db"))
	Bg.play("default")
	position = hidden_pos
	target_pos = hidden_pos
	update()

func update():
	volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	Blip.pitch_scale = 1.0 + volume * 0.01
	Percent.text = str(clampi(int((volume + 25) / 50 * 100), 0, 100)) + ' %'
	Progress.value = (volume + 25) / 50 * 100
	
	GlobalConfig.save_audio(
		volume,
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")),
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Atmosphere"))
	)

func _process(_delta: float) -> void:
	position = lerp(
		position,
		target_pos,
		0.1
	)
	modulate.a = position.distance_to(hidden_pos) / hidden_pos.distance_to(shown_pos)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed('vol_up') and Cooldown.is_stopped():
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), min(volume + 1, 25))
		if volume <= -26:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -25)
		target_pos = shown_pos
		Blip.play()
		update()
		Cooldown.start()
		DisplayTimer.start()
	elif Input.is_action_pressed('vol_down')  and Cooldown.is_stopped():
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), max(volume - 1, -26))
		if volume <= -26:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80.0)
		target_pos = shown_pos
		Blip.play()
		update()
		Cooldown.start()
		DisplayTimer.start()

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "show":
		$display_timer.start()


func _on_display_timer_timeout() -> void:
	target_pos = hidden_pos
	#Anim.play("hide")
	GlobalConfig.save_audio(
		volume,
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")),
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Atmosphere"))
	)


func _on_sub_viewport_size_changed() -> void:
	hidden_pos = Vector2(get_viewport().size.x / 2, -40)
	shown_pos = Vector2(get_viewport().size.x / 2, 35)
