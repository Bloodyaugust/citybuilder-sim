extends TileMap
class_name Surface

var navigation: AStar2D = AStar2D.new()

var _used_cells: Array[Vector2i] = get_used_cells(0)
var _path_cache: Dictionary = {}


func get_nav_path(from_tile: Vector2i, to_tile: Vector2i) -> Array[Vector2]:
	var _returned_path: Array[Vector2]

	if _path_cache.has(from_tile) && _path_cache[from_tile].has(to_tile):
		_returned_path.assign(_path_cache[from_tile][to_tile])
		return _returned_path

	if !_path_cache.has(from_tile):
		_path_cache[from_tile] = {}

	_path_cache[from_tile][to_tile] = (
		Array(
			navigation.get_point_path(
				get_nav_point_index_from_tile(from_tile), get_nav_point_index_from_tile(to_tile)
			)
		)
		. map(
			func(path_point: Vector2): return GDUtil.get_global_position_from_tile(
				Vector2i(path_point), self
			)
		)
	)

	_returned_path.assign(_path_cache[from_tile][to_tile])
	return _returned_path


func get_nav_point_index_from_tile(tile: Vector2i) -> int:
	return _used_cells.find(tile)


func _init():
	for _tile_index in len(_used_cells):
		navigation.add_point(_tile_index, Vector2(_used_cells[_tile_index]))

	for _tile_index in len(_used_cells):
		var _neighboring_tiles: Array[Vector2i] = get_surrounding_cells(_used_cells[_tile_index])

		for _neighboring_tile in _neighboring_tiles:
			var _tile_nav_point_index: int = get_nav_point_index_from_tile(_neighboring_tile)

			if _tile_nav_point_index != -1:
				navigation.connect_points(_tile_index, _tile_nav_point_index)

	print(navigation.are_points_connected(0, 2))
