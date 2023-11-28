extends Node2D

var logistics_networks: Dictionary = {}
var logistics_network_storages: Dictionary = {}


func add_resources_to_logistic_network_by_id(network_id: int, resources: Dictionary) -> void:
	if logistics_network_storages.has(network_id):
		for _resource_id in resources.keys():
			if logistics_network_storages[network_id].has(_resource_id):
				logistics_network_storages[network_id][_resource_id] = (
					logistics_network_storages[network_id][_resource_id] + resources[_resource_id]
				)
			else:
				logistics_network_storages[network_id][_resource_id] = resources[_resource_id]


func get_building_logistic_network(building: Node2D) -> Variant:
	var _network_id: Variant = get_building_logistic_network_id(building)

	if _network_id:
		return logistics_networks[_network_id]

	return false


func get_building_logistic_network_id(building: Node2D) -> Variant:
	for _network in logistics_networks.keys():
		for _network_building in logistics_networks[_network]:
			if _network_building == building:
				return _network

	for _network in logistics_networks.keys():
		for _network_building in logistics_networks[_network]:
			var _building_collision_tiles: Array[Vector2i] = building.get_collision_tiles()

			for _building_collision_tile in _building_collision_tiles:
				if _building_collision_tile in _network_building.get_effect_tiles():
					return _network

	return false


func get_logistic_network_resources_by_id(network_id: int) -> Dictionary:
	if logistics_network_storages.has(network_id):
		return logistics_network_storages[network_id]

	return {}


func get_tile_logistic_network(tile: Vector2i) -> Variant:
	var _network_id: Variant = get_tile_logistic_network_id(tile)

	if _network_id:
		return logistics_networks[_network_id]

	return false


func get_tile_logistic_network_id(tile: Vector2i) -> Variant:
	for _network in logistics_networks.keys():
		for _network_building in logistics_networks[_network]:
			if tile in _network_building.get_effect_tiles():
				return _network

	return false


func _on_building_added(building: Node2D) -> void:
	if GameConstants.BUILDING_FLAGS.LOGISTICS in building.data.building_flags:
		var _found_network: Variant = get_building_logistic_network(building)

		if _found_network:
			_found_network.append(building)
		else:
			for _effect_tile in building.get_effect_tiles():
				var _tile_actor: Variant = TilemapActorController.get_tile_actor(_effect_tile)

				if (
					_tile_actor
					&& _tile_actor.has_method("get_stored_resources")
					&& GameConstants.BUILDING_FLAGS.LOGISTICS in _tile_actor.data.building_flags
				):
					_found_network = get_building_logistic_network(_tile_actor)

			if _found_network:
				_found_network.append(building)
			else:
				logistics_networks[building.get_instance_id()] = [building]
				logistics_network_storages[building.get_instance_id()] = {}


func _ready():
	BuildingController.building_added.connect(_on_building_added)
