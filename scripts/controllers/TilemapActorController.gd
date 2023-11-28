extends Node2D

signal tile_actor_changed(tile: Vector2i)

var actor_dict: Dictionary = {}

@onready var _tilemap: TileMap = get_tree().get_first_node_in_group("TileMap")


func add_actor_to_tile(tile: Vector2i, actor: Variant) -> void:
	actor_dict[tile] = actor
	tile_actor_changed.emit(tile)


func get_tile_actor(tile: Vector2i) -> Variant:
	if actor_dict.has(tile):
		return actor_dict[tile]

	return false


func get_tilemap() -> TileMap:
	return _tilemap


func remove_actor_from_tile(tile: Vector2i) -> void:
	actor_dict.erase(tile)
	tile_actor_changed.emit(tile)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("select_actor") && !Store.state.selected_build_option:
		var _selecting_tile: Vector2i = GDUtil.get_tile_from_global_position(
			get_global_mouse_position(), _tilemap
		)
		var _selected_actor: Variant = TilemapActorController.get_tile_actor(_selecting_tile)

		if _selected_actor:
			Store.set_state("selected_actor", _selected_actor)

	if event.is_action_released("clear_selection"):
		Store.set_state("selected_actor", null)
