extends TileMapLayer
# типа кеш гыгыгы
var sources : Dictionary = {}
var textures : Dictionary = {} 

func _ready() -> void:
	if tile_set:
		for i in range(tile_set.get_source_count()):
			var id = tile_set.get_source_id(i)
			sources[id] = tile_set.get_source(id) as TileSetAtlasSource
	else:
		push_warning('tile set is empty, fill it already!')

func get_tile_texture(source_id : int, coords : Vector2i):
	var key = str(source_id, coords)
	if textures.has(key):
		return textures[key]
	var source = sources.get(source_id)
	if not source:
		source = tile_set.get_source(source_id) as TileSetAtlasSource
		if source:
			sources[source_id] = source
		else:
			push_error('where is the sauce?!')
			return null
	var texture = AtlasTexture.new()
	texture.atlas = source.get_texture()
	texture.region = source.get_tile_texture_region(coords)
	return texture
