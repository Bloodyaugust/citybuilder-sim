extends Node2D

var data: BuildingData

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _tilemap: Surface = get_tree().get_first_node_in_group("TileMap")

@onready var _logistics_controller: LogisticsController = get_tree().get_first_node_in_group(
	"LogisticsController"
)
@onready var _tilemap_actor_controller: TileMapActorController = get_tree().get_first_node_in_group(
	"TileMapActorController"
)

var _collision_tiles: Array[Vector2i]
var _effect_tiles: Array[Vector2i]
var _origin_tile: Vector2i


func is_buildable() -> bool:
	for _collision_tile in _collision_tiles:
		if (
			!_tilemap.get_tile_is_used(_collision_tile)
			|| _tilemap_actor_controller.get_tile_actor(_collision_tile)
		):
			return false

	var _tile_network: Variant = _logistics_controller.get_tile_logistic_network_id(_origin_tile)

	# TODO: Figure out where to spend resources from when building in a new logistics network
	if !GameConstants.BUILDING_FLAGS.NO_LOGISTICS_REQUIREMENT in data.building_flags:
		if !_tile_network:
			return false

		var _network_resources: Dictionary = (
			_logistics_controller.get_logistic_network_resources_by_id(_tile_network)
		)

		for _resource_id in data.building_cost.keys():
			if !_network_resources.has(_resource_id):
				return false

			if data.building_cost[_resource_id] > _network_resources[_resource_id]:
				return false

	return true


func _draw():
	for _collision_tile in _collision_tiles:
		draw_circle(
			to_local(GDUtil.get_global_position_from_tile(_collision_tile, _tilemap)),
			35.0,
			Color.ORANGE_RED
		)

	for _effect_tile in _effect_tiles:
		draw_circle(
			to_local(GDUtil.get_global_position_from_tile(_effect_tile, _tilemap)),
			5.0,
			Color.YELLOW_GREEN
		)


func _process(_delta):
	var _mouse_position: Vector2 = get_global_mouse_position()

	_effect_tiles = []
	_collision_tiles = []

	_origin_tile = GDUtil.get_tile_from_global_position(_mouse_position, _tilemap)
	global_position = GDUtil.get_global_position_from_tile(_origin_tile, _tilemap)

	for _collision_tile_offset in data.collision_mask:
		_collision_tiles.append(
			GDUtil.get_tile_from_offset_global(global_position, _collision_tile_offset, _tilemap)
		)

	for _effect_tile_offset in data.effect_mask:
		_effect_tiles.append(
			GDUtil.get_tile_from_offset_global(global_position, _effect_tile_offset, _tilemap)
		)

	queue_redraw()


func _ready():
	_sprite.texture = data.sprite
