extends TileMap
class_name Surface

const BUILDING_SCENE: PackedScene = preload("res://actors/Building.tscn")
const RESOURCE_SCENE: PackedScene = preload("res://actors/Resource.tscn")

var navigation: AStar2D = AStar2D.new()

@onready var _starting_buildings_container: Node2D = %StartingBuildings
@onready var _starting_resources_container: Node2D = %StartingResources

var _used_cells: Array[Vector2i] = get_used_cells(0)
var _path_cache: Dictionary = {}


func get_tile_is_used(tile: Vector2i) -> bool:
	return tile in _used_cells


func get_nav_path(from_tile: Vector2i, to_tile: Vector2i) -> Array[Vector2]:
	var _returned_path: Array[Vector2] = []

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


func get_nav_weight_from_tile(tile: Vector2i) -> float:
	return navigation.get_point_weight_scale(get_nav_point_index_from_tile(tile))


func set_nav_point_non_tile_weight_by_tile(tile: Vector2i, weight: float) -> void:
	var _nav_point_index: int = get_nav_point_index_from_tile(tile)

	navigation.set_point_weight_scale(
		_nav_point_index, weight + get_cell_tile_data(0, tile).get_custom_data("nav_weight")
	)


func _on_store_state_changed(state_key: String, substate) -> void:
	match state_key:
		"game":
			match substate:
				GameConstants.GAME_STARTED:
					for _starting_building in _starting_buildings_container.get_children():
						var _new_building: Building = BUILDING_SCENE.instantiate()

						_new_building.data = _starting_building.data
						_new_building.global_position = _starting_building.global_position

						add_child(_new_building)

					for _starting_resource in _starting_resources_container.get_children():
						var _new_resource: ResourceActor = RESOURCE_SCENE.instantiate()

						_new_resource.data = _starting_resource.data
						_new_resource.global_position = _starting_resource.global_position

						add_child(_new_resource)


func _init():
	for _tile_index in len(_used_cells):
		navigation.add_point(
			_tile_index,
			Vector2(_used_cells[_tile_index]),
			get_cell_tile_data(0, _used_cells[_tile_index]).get_custom_data("nav_weight")
		)

	for _tile_index in len(_used_cells):
		var _neighboring_tiles: Array[Vector2i] = get_surrounding_cells(_used_cells[_tile_index])

		for _neighboring_tile in _neighboring_tiles:
			var _tile_nav_point_index: int = get_nav_point_index_from_tile(_neighboring_tile)

			if _tile_nav_point_index != -1:
				navigation.connect_points(_tile_index, _tile_nav_point_index)


func _ready():
	Store.state_changed.connect(_on_store_state_changed)
