extends Node2D

@export var data: BuildingData

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _tilemap: TileMap = get_tree().get_first_node_in_group("TileMap")

var _collision_tiles: Array[Vector2i]
var _draw_details: bool = false
var _effect_tiles: Array[Vector2i]
var _origin_tile: Vector2i

func get_collision_tiles() -> Array[Vector2i]:
  return _collision_tiles

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

func _process(_delta) -> void:
  queue_redraw()

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  
  _origin_tile = GDUtil.get_tile_from_global_position(global_position, _tilemap)
  global_position = GDUtil.get_global_position_from_tile(_origin_tile, _tilemap)

  for _collision_tile_offset in data.collision_mask:
    _collision_tiles.append(GDUtil.get_tile_from_offset_global(global_position, _collision_tile_offset, _tilemap))

  for _effect_tile_offset in data.effect_mask:
    _effect_tiles.append(GDUtil.get_tile_from_offset_global(global_position, _effect_tile_offset, _tilemap))

  _sprite.texture = data.sprite

  BuildingController.add_building(self)
  queue_redraw()
