extends Control

enum Categories {BLOCKS, ENTITIES, OTHER}

@onready var blocks_btn = $HSplitContainer/Categories/VBoxContainer/Blocks
@onready var TilesBg: TileMapLayer = $"../../../TilesBg"
@onready var TileSetBg : TileSet = TilesBg.tile_set
@onready var ItemsList: GridContainer = $HSplitContainer/Items/List

var items_group = ButtonGroup.new()
var current_choice : Categories = Categories.BLOCKS
var current_item = Vector2(0, 0)
#var Blocks : Array = []

func _ready() -> void:
	var category_buttons = blocks_btn.button_group
	category_buttons.pressed.connect(_on_category_selected)
	hide()
	for i in range(TileSetBg.get_source_count()):
		var source = TileSetBg.get_source(TileSetBg.get_source_id(i))
		var atlas_source = source as TileSetAtlasSource
		var atlas_texture_base = atlas_source.texture
		var tiles_count = atlas_source.get_tiles_count()
		for n in range(tiles_count):
			var coords = atlas_source.get_tile_id(n)
			var region = atlas_source.get_tile_texture_region(coords)
			
			var texture = AtlasTexture.new()
			texture.atlas = atlas_texture_base
			texture.region = region
			
			var btn = TextureButton.new()
			btn.set_meta('my_tile_coords', coords)
			btn.size = Vector2(32, 32)
			btn.toggle_mode = true
			btn.texture_normal = texture
			btn.toggled.connect(func(is_pressed):
				if is_pressed:
					btn.modulate = Color(1.8, 1.8, 1.8)
					current_item = btn.get_meta('my_tile_coords', Vector2(0, 0))
				else:
					btn.modulate = Color(1.0, 1.0, 1.0)
			)
			btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			btn.button_group = items_group
			ItemsList.add_child(btn)

func _process(delta: float) -> void:
	if Input.is_action_pressed('lmb') and not visible:
		var pos = TilesBg.local_to_map(TilesBg.to_local(TilesBg.get_global_mouse_position()))
		if TilesBg.get_cell_atlas_coords(pos) != Vector2i(current_item):
			TilesBg.set_cell(
				pos,
				0,
				current_item
			)
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
