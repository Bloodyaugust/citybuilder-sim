extends Node2D

signal request_logistics_pickup(building: Node2D)

@export var data: BuildingData

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _tilemap: Surface = get_tree().get_first_node_in_group("TileMap")

var _collision_tiles: Array[Vector2i]
var _draw_details: bool = false
var _effect_tiles: Array[Vector2i]
var _origin_tile: Vector2i
var _collecting_resources: Dictionary
var _stored_resources: Dictionary
var _logistics_children: Array[Node2D]
var _logistics_pickup_requested: bool = false


func get_collision_tiles() -> Array[Vector2i]:
	return _collision_tiles


func get_effect_tiles() -> Array[Vector2i]:
	return _effect_tiles


func get_origin_tile() -> Vector2i:
	return _origin_tile


func get_selection_details() -> Dictionary:
	var _used_stored_resources: Dictionary = get_stored_resources()
	var _resources_string: String = "\r\n".join(
		PackedStringArray(
			_collecting_resources.keys().map(
				func(resource): return "- {id} x{num} tiles ({total}/sec)".format(
					{
						"id": resource,
						"num": _collecting_resources[resource],
						"total":
						_collecting_resources[resource] * data.resource_collection_rate_per_tile
					}
				)
			)
		)
	)
	var _stored_resources_string: String = "\r\n".join(
		PackedStringArray(
			_used_stored_resources.keys().map(
				func(resource): return "- {id}: {num}".format(
					{"id": resource, "num": "%d" % _used_stored_resources[resource]}
				)
			)
		)
	)

	return {
		"name": data.name,
		"sprite": data.sprite,
		"description":
		(
			data.description
			+ "\r\nCollecting:\r\n"
			+ _resources_string
			+ "\r\nStored:\r\n"
			+ _stored_resources_string
		)
	}


func get_stored_resources() -> Dictionary:
	if GameConstants.BUILDING_FLAGS.LOGISTICS in data.building_flags:
		return LogisticsController.get_logistic_network_resources_by_id(
			LogisticsController.get_building_logistic_network_id(self)
		)

	return _stored_resources


func pickup_stored_resources() -> Dictionary:
	var _resources_copy: Dictionary = _stored_resources.duplicate()

	_stored_resources = {}
	_logistics_pickup_requested = false
	return _resources_copy


func _draw():
	if _draw_details:
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


func _exit_tree() -> void:
	BuildingController.remove_building(self)


func _on_request_logistics_pickup(building: Node2D) -> void:
	var _requesting_building_stored_resources: Dictionary = building.pickup_stored_resources()

	print(_tilemap.get_nav_path(_origin_tile, building.get_origin_tile()))

	LogisticsController.add_resources_to_logistic_network_by_id(
		LogisticsController.get_building_logistic_network_id(self),
		_requesting_building_stored_resources
	)


func _on_store_state_changed(state_key, substate):
	match state_key:
		"selected_actor":
			if substate && substate == self:
				_draw_details = true
			else:
				_draw_details = false


func _on_tilemap_tile_actor_changed(tile: Vector2i) -> void:
	if tile in _effect_tiles:
		_recalculate_resources()
		_recalculate_logistics_children()


func _process(delta) -> void:
	for _resource_id in _collecting_resources.keys():
		if _stored_resources.has(_resource_id):
			_stored_resources[_resource_id] = (
				_stored_resources[_resource_id]
				+ (
					_collecting_resources[_resource_id]
					* data.resource_collection_rate_per_tile
					* delta
				)
			)

			if _stored_resources[_resource_id] > 1.0:
				_logistics_pickup_requested = true
				request_logistics_pickup.emit(self)
		else:
			_stored_resources[_resource_id] = (
				_collecting_resources[_resource_id] * data.resource_collection_rate_per_tile * delta
			)

	queue_redraw()


func _ready():
	Store.state_changed.connect(_on_store_state_changed)
	TilemapActorController.tile_actor_changed.connect(_on_tilemap_tile_actor_changed)

	_origin_tile = GDUtil.get_tile_from_global_position(global_position, _tilemap)
	global_position = GDUtil.get_global_position_from_tile(_origin_tile, _tilemap)

	for _collision_tile_offset in data.collision_mask:
		_collision_tiles.append(
			GDUtil.get_tile_from_offset_global(global_position, _collision_tile_offset, _tilemap)
		)

	for _effect_tile_offset in data.effect_mask:
		_effect_tiles.append(
			GDUtil.get_tile_from_offset_global(global_position, _effect_tile_offset, _tilemap)
		)

	_sprite.texture = data.sprite

	BuildingController.add_building(self)
	queue_redraw()
	_recalculate_resources()
	_recalculate_logistics_children()


func _recalculate_logistics_children() -> void:
	for _child in _logistics_children:
		_child.request_logistics_pickup.disconnect(_on_request_logistics_pickup)

	_logistics_children = []

	for _effect_tile in _effect_tiles:
		var _tile_actor: Variant = TilemapActorController.get_tile_actor(_effect_tile)

		if (
			_tile_actor
			&& _tile_actor.has_method("get_stored_resources")
			&& GameConstants.BUILDING_FLAGS.LOGISTICS not in _tile_actor.data.building_flags
			&& _tile_actor not in _logistics_children
		):
			_logistics_children.append(_tile_actor)
			_tile_actor.request_logistics_pickup.connect(_on_request_logistics_pickup)


func _recalculate_resources() -> void:
	_collecting_resources = {}

	for _effect_tile in _effect_tiles:
		var _tile_actor: Variant = TilemapActorController.get_tile_actor(_effect_tile)

		if _tile_actor && _tile_actor.has_method("get_resource_id"):
			var _resource_id: String = _tile_actor.get_resource_id()

			if _resource_id in data.resources_collected:
				if _collecting_resources.has(_resource_id):
					_collecting_resources[_resource_id] = _collecting_resources[_resource_id] + 1
				else:
					_collecting_resources[_resource_id] = 1
