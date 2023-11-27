extends Node2D

@export var data: BuildingData

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _tilemap: TileMap = get_tree().get_first_node_in_group("TileMap")

var _collision_tiles: Array[Vector2i]
var _draw_details: bool = false
var _effect_tiles: Array[Vector2i]
var _origin_tile: Vector2i
var _collecting_resources: Dictionary
var _stored_resources: Dictionary

func get_collision_tiles() -> Array[Vector2i]:
  return _collision_tiles

func get_selection_details() -> Dictionary:
  var _resources_string: String = "\r\n".join(PackedStringArray(_collecting_resources.keys().map(func (resource): return "- {id} x{num} tiles ({total}/sec)".format({"id": resource, "num": _collecting_resources[resource], "total": _collecting_resources[resource] * data.resource_collection_rate_per_tile}))))
  var _stored_resources_string: String = "\r\n".join(PackedStringArray(_stored_resources.keys().map(func (resource): return "- {id}: {num}".format({"id": resource, "num": "%d" % _stored_resources[resource]}))))
  return {
    "name": data.name,
    "sprite": data.sprite,
    "description": data.description + "\r\nCollecting:\r\n" + _resources_string + "\r\nStored:\r\n" + _stored_resources_string
  }

func _draw():
  if _draw_details:
    for _collision_tile in _collision_tiles:
      draw_circle(to_local(GDUtil.get_global_position_from_tile(_collision_tile, _tilemap)), 35.0, Color.ORANGE_RED)

    for _effect_tile in _effect_tiles:
      draw_circle(to_local(GDUtil.get_global_position_from_tile(_effect_tile, _tilemap)), 5.0, Color.YELLOW_GREEN)

func _exit_tree() -> void:
  BuildingController.remove_building(self)

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

func _process(delta) -> void:
  for _resource_id in _collecting_resources.keys():
    if _stored_resources.has(_resource_id):
      _stored_resources[_resource_id] = _stored_resources[_resource_id] + (_collecting_resources[_resource_id] * data.resource_collection_rate_per_tile * delta)
    else:
      _stored_resources[_resource_id] = _collecting_resources[_resource_id] * data.resource_collection_rate_per_tile * delta

  queue_redraw()

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  TilemapActorController.tile_actor_changed.connect(_on_tilemap_tile_actor_changed)

  _origin_tile = GDUtil.get_tile_from_global_position(global_position, _tilemap)
  global_position = GDUtil.get_global_position_from_tile(_origin_tile, _tilemap)

  for _collision_tile_offset in data.collision_mask:
    _collision_tiles.append(GDUtil.get_tile_from_offset_global(global_position, _collision_tile_offset, _tilemap))

  for _effect_tile_offset in data.effect_mask:
    _effect_tiles.append(GDUtil.get_tile_from_offset_global(global_position, _effect_tile_offset, _tilemap))

  _sprite.texture = data.sprite

  BuildingController.add_building(self)
  queue_redraw()
  _recalculate_resources()

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
