extends Control

enum Categories {BLOCKS, ENTITIES, OTHER}

@onready var blocks_btn = $HSplitContainer/Categories/VBoxContainer/Blocks
@onready var TilesBg: TileMapLayer = $"../../../TilesBg"
@onready var TileSetBg : TileSet = TilesBg.tile_set
@onready var ItemsList: GridContainer = $HSplitContainer/Items/List

var last_placed_block_coords : Vector2i = Vector2i.MAX
var items_group = ButtonGroup.new()
var current_choice : Categories = Categories.BLOCKS
var current_item = -1
var blocks : Array = []

func _ready() -> void:
	var category_buttons = blocks_btn.button_group
	blocks_btn.button_group.allow_unpress = true 
	category_buttons.pressed.connect(_on_category_selected)
	hide()
	for i in range(TileSetBg.get_source_count()):
		var source = TileSetBg.get_source(TileSetBg.get_source_id(i)) as TileSetAtlasSource
		var counter : int = 0
		for j in range(source.get_tiles_count()):
			var tile = source.get_tile_id(j)
			if len(blocks) == tile.x:
				blocks.append([tile])
			else:
				blocks[tile.x].append(tile)
	for tile in blocks:
		var tile_texture = TilesBg.get_tile_texture(0, tile[0])
		var btn = TextureButton.new()
		btn.set_meta('my_tile_coords', tile[0].x)
		btn.size = Vector2(32, 32)
		btn.toggle_mode = true
		btn.texture_normal = tile_texture
		btn.toggled.connect(func(is_pressed):
			if is_pressed:
				btn.modulate = Color(1.8, 1.8, 1.8)
				current_item = btn.get_meta('my_tile_coords', -1)
				$"../Tips/Hotkeys/Build".button_pressed = true
			else:
				btn.modulate = Color(1.0, 1.0, 1.0)
		)
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.button_group = items_group
		ItemsList.add_child(btn)

func _process(delta: float) -> void:
	var current_hovered_tile = TilesBg.local_to_map(TilesBg.to_local(TilesBg.get_global_mouse_position()))
	if not visible and\
	((Input.is_action_pressed('lmb') and last_placed_block_coords != current_hovered_tile) or\
	Input.is_action_just_pressed('lmb')):
		last_placed_block_coords = current_hovered_tile
		place(current_item, current_hovered_tile)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('open_build_menu'):
		show()
	elif Input.is_action_just_released('open_build_menu'):
		hide()
	elif Input.is_action_just_pressed('erase'):
		if items_group.get_pressed_button():
			items_group.get_pressed_button().button_pressed = false
		current_item = -1
		$"../Tips/Hotkeys/Erase".button_pressed = true

func place(tile : int, world_coords : Vector2i):
	TilesBg.set_cell(
			world_coords,
			0,
			Vector2i(tile, randi_range(0, len(blocks[tile]) - 1))
		)
	if current_item != -1:
		$"../../../place".play()

func _on_category_selected(button : Button) -> void:
	var new_choice : Categories
	match button.name:
		'Blocks':
			new_choice = Categories.BLOCKS
		'Entities':
			new_choice = Categories.ENTITIES
		'Other':
			new_choice = Categories.OTHER
	
	if new_choice == current_choice:
		return
	else:
		current_choice = new_choice
	
	print(Categories.keys()[current_choice]) 


func _on_build_pressed() -> void:
	show()

func _on_erase_pressed() -> void:
	if items_group.get_pressed_button():
		items_group.get_pressed_button().button_pressed = false
	current_item = -1
	$"../Tips/Hotkeys/Erase".button_pressed = true
