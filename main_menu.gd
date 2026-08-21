extends Node2D

@onready var text: RichTextLabel = $RichTextLabel
@onready var CRT: ColorRect = $CanvasLayer/CRT
@onready var CRT_mat: ShaderMaterial = CRT.material as ShaderMaterial

@onready var mus_volume: HSlider = $settings_things/mus_volume
@onready var snd_volume: HSlider = $settings_things/snd_volume
@onready var atm_volume: HSlider = $settings_things/atm_volume


func _ready() -> void:
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	GlobalVars.apply_CRT(CRT_mat)
	
	load_config()
	$settings_things.hide()
	$start.disabled = true
	$settings.disabled = true
	$exit.disabled = true
	text.text = ""
	#text.default_color = Color(1.0, 0.635, 0.227, 1.0)
	await wait(0.5)
	text.text += "(🄯)20XX UNNAMED COMPANY, Inc."
	await wait(0.1)
	text.text += "\n" + "\n" + "CPU: " + str(OS.get_processor_name())
	text.text += "\n" + "GPU: " + str(RenderingServer.get_video_adapter_name()) + "\n"
	await wait(0.5)
	repeat("---", 45)
	# SHOW VULKAN LOGO ASCII ART
	if str(RenderingServer.get_current_rendering_method()) == "forward_plus":
		text.text += "\n" +\
		"                   .+++++++++++++++++++++++.                                              " + "\n" +\
		"         .+++++++++++++++++++++++++++++++.                                         " + "\n" +\
		"      ++++++++++-                                                .++++++                                      " + "\n" +\
		"      ++++++++         +++                 +++.                    ====            -++                               " + "\n" +\
		"         .++++++            .+++             .+++                               --  +++    +                               " + "\n" +\
		"             +++++             +++.          +++   ++-          ++.        -++      +           +++          +++++++-      +++   +++++  " + "\n" +\
		"                  +++               +++       ++++  ++-          ++.        -++      -+       +++          +++         .++.     ++++        +++ " + "\n" +\
		"                        -+.            ++++   +++      ++-          ++.        -++      -+ + +++                      .+++++.    +++           +++ " + "\n" +\
		"                                           ++++++         ++-         .++.         -++      -+ +   +++-        +++          ++.     +++           +++ " + "\n" +\
		"                                           .+++++           +++      +++.         -++      -+ +      ++++    ++-         +++.    +++            +++ " + "\n" +\
		"                                             ++++               +++++ ++.         -++      - ++         -+++  -+++++  +++    +++            +++ " + "\n"
	elif str(RenderingServer.get_current_rendering_method()) == "gl_compatibility":
		text.text += "\n" +\
		"                                                    @@@@@@@@@@@@@@@@@@@" + "\n" +\
		"                               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" + "\n" +\
		"                      @@@++++@@@@                                                                               @@" + "\n" +\
		"             @@+++++++@                                                                                                     @" + "\n" +\
		"          @+++++++@@@@@@                                                                                               @@@@@@          @@" + "\n" +\
		"       @+++++++@                   @                                                                                       @@@            @@@   @@" + "\n" +\
		"    @+++++++@                         @     @@@@@        @@@@        @   @@@@         @@@                               @@" + "\n" +\
		"    @+++++++@                         @     @              @  @            @     @@           @@   @@              @@@@@    @@" + "\n" +\
		"    @+++++++@                         @     @              @  @@@@@@   @@           @@   @@@                     @@    @@" + "\n" +\
		"    @@+++++++@                   @        @ @@@@    @                    @@           @@       @@@           @@   @    @@" + "\n" +\
		"           @+++++++@@@@@@         @                       @@@@      @@           @@              @@@@@       @    @@@@@@@@" + "\n" +\
		"              @@@+++++++               	     @" + "\n" +\
		"                        @@@+++@@@@@                      @@@" + "\n" +\
		"                                  @@@@@@@@@@@@@@@@@@++++@@@@@@@@@" + "\n" +\
		"                                                    @@@@@@@@@@@@@@@@@@@@@" + "\n"
	repeat("---", 45)
	await wait(0.5)
	text.text += "\n" + "SYSTEM: " + str(OS.get_distribution_name()) + str(OS.get_version())
	await wait(0.1)
	text.text += "\n" + "PROCESS ID: " + str(OS.get_process_id())
	await wait(0.1)
	text.text += "\n" + "importing random, ez-crasher, genpiper-2, noob-noiser, uaudio, mus-bad-lib, and 13 other" + "\n"
	await wait(0.1)
	for x in range(10):
		text.text += ">"
		await wait(0.01)
	text.text += "\ndone\n"
	await wait(0.3)
	for x in range(10):
		text.text += "finishing up" + "\n"
		await wait(0.01)
	$music.play()
	main_menu()

func repeat(input, amount):
	for x in amount:
		text.text += input
func wait(x):
	await get_tree().create_timer(x).timeout

func main_menu():
	$settings_things.hide()
	text.text = ""
	#text.horizontal_alignment = HO
	text.text = "-".repeat(155)
	await wait(0.2)
	text.text += "\n"
	text.text += "   ##         -=     ##-=-=        #           #      #                #     ##             ##     -=-=-=-=-=      ##-=-=-=           -=-=-=-=      ##             ##       2
    ##     -=         ##       #     #           #      #       #      #     ##        -= ##             #             ##                     #          #     ##        -= ##            
    ##-=-=           ##==-=       #=-=-=#       #       #      #     ##    -=     ##             #             ##-=-=              #          #     ##    -=     ##         
     ##     -=         ##                            #     #       #      #     ## -=        ##             #             ##                    #          #     ## -=        ##
     ##         -=     ##                =-=-=-=-      #=-= #-=-#      ##             ##             #             ##-=-=-=      =-#          #    ##             ## "
	await wait(0.2)
	text.text += "\n" + "-".repeat(155)
	text.text += "\n\n\n" + "         НАЧАТЬ"
	text.text += "\n\n\n" + "         НАСТРОЙКИ"
	text.text += "\n\n\n" + "         ВЫХОД"
	$settings.disabled = false
	$start.disabled = false
	$exit.disabled = false
func settings():
	$settings.disabled = true
	$start.disabled = true
	$exit.disabled = true
	$settings.text = ""
	$start.text = ""
	$exit.text = ""
	text.text = ""
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	await wait(0.2)
	$settings_things.show()
	text.text += "\n\n"
	repeat(" ", 141)
	text.text += "СОХРАНИТЬ\n\n\n\n"
	repeat(" ", 10)
	text.text += "Общая громкость\n"
	repeat(" ", 10)
	text.text += "Громкость музыки\n"
	repeat(" ", 10)
	text.text += "Громкость звуков\n"
	repeat(" ", 10)
	text.text += "Громкость эффектов\n"

func load_config():
	$settings_things/global_volume.value = round((GlobalConfig.get_value("audio", "Master_volume_db") + 25) / 50 * 100)
	$settings_things/mus_volume.value = round((GlobalConfig.get_value("audio", "Music_volume_db") + 25) / 50 * 100)
	$settings_things/snd_volume.value = round((GlobalConfig.get_value("audio", "Sound_volume_db") + 25) / 50 * 100)
	$settings_things/atm_volume.value = round((GlobalConfig.get_value("audio", "Atmosphere_volume_db") + 25) / 50 * 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), GlobalConfig.get_value("audio", "Master_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), GlobalConfig.get_value("audio", "Music_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), GlobalConfig.get_value("audio", "Sound_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Atmosphere"), GlobalConfig.get_value("audio", "Atmosphere_volume_db"))

func _on_start_button_pressed() -> void:
	GlobalVars.lifes = 3
	get_tree().change_scene_to_file("res://main.tscn")
func _on_start_button_mouse_entered() -> void:
	if not $start.disabled:
		$choose.play()
		$start.text = ">>"
func _on_start_button_mouse_exited() -> void:
	$start.text = ""

func _on_settings_pressed() -> void:
	$settings_things/global_volume.value = round((GlobalConfig.get_value("audio", "Master_volume_db") + 25) / 50 * 100)
	$settings_things/mus_volume.value = round((GlobalConfig.get_value("audio", "Music_volume_db") + 25) / 50 * 100)
	$settings_things/snd_volume.value = round((GlobalConfig.get_value("audio", "Sound_volume_db") + 25) / 50 * 100)
	$settings_things/atm_volume.value = round((GlobalConfig.get_value("audio", "Atmosphere_volume_db") + 25) / 50 * 100)
	settings()
func _on_settings_mouse_entered() -> void:
	if not $settings.disabled:
		$choose.play()
		$settings.text = ">>"
func _on_settings_mouse_exited() -> void:
	$settings.text = ""

func _on_settings_back_pressed() -> void:
	GlobalConfig.save_audio(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Atmosphere")))
	main_menu()
func _on_settings_back_mouse_entered() -> void:
	$settings_things/back.text = ">>                        <<"
func _on_settings_back_mouse_exited() -> void:
	$settings_things/back.text = ""

func _on_global_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), round(50 * (value / 100) - 25))
func _on_mus_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), round(50 * (value / 100) - 25))
func _on_snd_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), round(50 * (value / 100) - 25))
func _on_atm_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Atmosphere"), round(50 * (value / 100) - 25))


func _on_exit_pressed() -> void:
	get_tree().quit(0)
func _on_exit_mouse_entered() -> void:
	if not $exit.disabled:
		$choose.play()
		$exit.text = ">>"
func _on_exit_mouse_exited() -> void:
	$exit.text = ""
