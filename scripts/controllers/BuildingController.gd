extends Node2D

signal building_added(building: Node2D)

var BUILDING_DATA: Array[BuildingData]
var BUILDING_ACTOR: PackedScene = preload("res://actors/Building.tscn")
var BUILDING_GHOST: PackedScene = preload("res://doodads/BuildingGhost.tscn")

@onready var _tilemap: TileMap = get_tree().get_first_node_in_group("TileMap")

var _current_ghost = null


func add_building(building: Node2D) -> void:
	for _collision_tile in building.get_collision_tiles():
		TilemapActorController.add_actor_to_tile(_collision_tile, building)

	building_added.emit(building)


func remove_building(building: Node2D) -> void:
	for _collision_tile in building.get_collision_tiles():
		TilemapActorController.remove_actor_from_tile(_collision_tile)


func _on_store_state_changed(state_key: String, substate) -> void:
	match state_key:
		"selected_build_option":
			if _current_ghost:
				_current_ghost.queue_free()
				_current_ghost = null

			if substate:
				_current_ghost = BUILDING_GHOST.instantiate()
				_current_ghost.data = substate
				add_child(_current_ghost)


func _init():
	BUILDING_DATA.assign(GDUtil.load_directory("res://data/buildings/"))


func _ready():
	Store.state_changed.connect(_on_store_state_changed)


func _unhandled_input(event: InputEvent) -> void:
	if _current_ghost:
		if event.is_action_released("confirm_building") && _current_ghost.is_buildable():
			var _new_building: Node2D = BUILDING_ACTOR.instantiate()

			_new_building.global_position = _current_ghost.global_position
			_new_building.data = _current_ghost.data
			get_tree().get_root().add_child(_new_building)

			_current_ghost.queue_free()
			_current_ghost = null
			Store.set_state("selected_build_option", null)

		if event.is_action_released("clear_selection"):
			Store.set_state("selected_build_option", null)
