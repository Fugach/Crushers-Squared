extends Sprite2D

@onready var Tip : Sprite2D = $tip
@onready var Table : Node2D = $"../UI/HUD/Table"
@onready var Paper_button : TextureButton = $"../UI/HUD/Table/paper_button"
@onready var Anim : AnimationPlayer = $"../UI/HUD/Table/animations"
@onready var Upgrade1 : Button = $"../UI/HUD/Table/Upgrade1"
@onready var Upgrade2 : Button = $"../UI/HUD/Table/Upgrade2"
@onready var Upgrade3 : Button = $"../UI/HUD/Table/Upgrade3"
@onready var WEAPON_BOX = preload("uid://bamk8gm2akgdj")

var all_upgrades = ["SPEED_UP", "JUMP_UP", "FREE_WEAPON", "WALLJUMPS_UP"]
var upgrades = []
var rerolling_upgrade = ""
var last_finished_animation : String = ""
var names = {
	"SPEED_UP" : "СКОРОСТЬ\n\nСкорость бега +10%",
	"JUMP_UP" : "ПРЫЖОК\n\nВысота прыжка +10%\nЛёгкость +10%",
	"FREE_WEAPON" : "ОРУЖИЕ\n\nСлучайное оружие БЕСПЛАТНО",
	"WALLJUMPS_UP" : "ПАРКУР\n\n1 дополнительный прыжок от стены"
}
var titles = {
	"1" : "Какое улучшение распечатать?",
	"2" : "Чего желаете?",
	"3" : "Чё надо?",
	"4" : "Выберите улучшение",
	"5" : "Оно того стоит?",
	"6" : "Выбор?",
	"7" : "ПЕЧАТЬ?",
	"8" : "Печать",
	"9" : "Upgrades.html",
	"10" : "Улучшения",
	"11" : "Upgrades.py",
	"12" : "ааа куда жмять",
	"13" : "Так тяжело выбрать..."
}

func _ready() -> void:
	Table.hide()
	$"../UI/HUD/AnimationPlayer".play_backwards("show_table")

func _process(_delta: float) -> void:
	get_input()

func get_input():
	if Tip.visible and Input.is_action_just_pressed("rmb") and Table.visible == false:
		$"../UI/HUD/Table/table/Title".text = titles[str(randi_range(1, len(titles)))]
		$"../UI/HUD/AnimationPlayer".play("show_table")
		Table.show()
		get_parent().get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		GlobalVars.player.SPEED_buffer = GlobalVars.player.SPEED
		GlobalVars.player.SPEED = 0
		GlobalVars.player.JUMP_VELOCITY_buffer = GlobalVars.player.JUMP_VELOCITY
		GlobalVars.player.JUMP_VELOCITY = 0
		GlobalVars.player.can_jump = false
	if Table.visible and Input.is_action_just_pressed("esc"):
		$"../UI/HUD/Table/close".play()
		get_parent().get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		Table.hide()
		GlobalVars.player.JUMP_VELOCITY = GlobalVars.player.JUMP_VELOCITY_buffer
		GlobalVars.player.SPEED = GlobalVars.player.SPEED_buffer
		GlobalVars.player.can_jump = true

func reroll():
	Upgrade1.disabled = false
	Upgrade2.disabled = false
	Upgrade3.disabled = false
	upgrades = []
	while len(upgrades) < 3:
		var repeated = false
		while not repeated:
			rerolling_upgrade = all_upgrades.pick_random()
			for thing in upgrades:
				if thing == rerolling_upgrade:
					repeated = true
			if not repeated:
				upgrades.append(rerolling_upgrade)
				break
	print("Current options: ", upgrades)
	Upgrade1.text = names[upgrades[0]]
	Upgrade2.text = names[upgrades[1]]
	Upgrade3.text = names[upgrades[2]]
func _on_activation_range_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		$tip.show()
func _on_activation_range_body_exited(body: Node2D) -> void:
	if body == GlobalVars.player:
		$tip.hide()

func _on_paper_button_pressed() -> void:
	if Anim.current_animation != "paper_show" and last_finished_animation != "paper_show":
		Anim.play("paper_show")
		$"../UI/HUD/Table/paper_sfx".play()
	else:
		Anim.play("paper_hide")
		$"../UI/HUD/Table/paper_sfx".play()

func _on_animations_animation_finished(anim_name: StringName) -> void:
	last_finished_animation = anim_name

func _on_upgrade_1_pressed() -> void:
	Upgrade1.disabled = true
	Upgrade2.disabled = true
	Upgrade3.disabled = true
	upgrade(upgrades[0])
func _on_upgrade_2_pressed() -> void:
	Upgrade1.disabled = true
	Upgrade2.disabled = true
	Upgrade3.disabled = true
	upgrade(upgrades[1])
func _on_upgrade_3_pressed() -> void:
	Upgrade1.disabled = true
	Upgrade2.disabled = true
	Upgrade3.disabled = true
	upgrade(upgrades[2])

func _on_texture_button_pressed() -> void:
	$"../UI/HUD/Table/close".play()
	get_parent().get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	Table.hide()
	GlobalVars.player.can_jump = true
	GlobalVars.player.JUMP_VELOCITY = GlobalVars.player.JUMP_VELOCITY_buffer
	GlobalVars.player.SPEED = GlobalVars.player.SPEED_buffer

func upgrade(text):
	match text:
		"SPEED_UP":
			GlobalVars.player.SPEED_buffer *= 1.1
		"JUMP_UP":
			GlobalVars.player.JUMP_VELOCITY_buffer *= 1.1
			GlobalVars.player.WEIGHT *= 1.1
		"WALLJUMPS_UP":
			GlobalVars.player.WALLJUMPS += 1
		"FREE_WEAPON":
			var new_box = WEAPON_BOX.instantiate()
			new_box.global_position = global_position - Vector2(0, 8)
			get_parent().add_child(new_box)
