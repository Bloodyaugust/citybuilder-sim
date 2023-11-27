extends Node2D

var data: BuildingData

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _tilemap: TileMap = get_tree().get_first_node_in_group("TileMap")

var _collision_tiles: Array[Vector2i]
var _effect_tiles: Array[Vector2i]
var _origin_tile: Vector2i

func is_buildable() -> bool:
  for _collision_tile in _collision_tiles:
    if BuildingController.building_dict.has(_collision_tile):
      return false

  return true

func _draw():
  for _collision_tile in _collision_tiles:
    draw_circle(to_local(GDUtil.get_global_position_from_tile(_collision_tile, _tilemap)), 35.0, Color.ORANGE_RED)

  for _effect_tile in _effect_tiles:
    draw_circle(to_local(GDUtil.get_global_position_from_tile(_effect_tile, _tilemap)), 5.0, Color.YELLOW_GREEN)

func _process(delta):
  var _mouse_position: Vector2 = get_global_mouse_position()
  
  _effect_tiles = []
  _collision_tiles = []

  _origin_tile = GDUtil.get_tile_from_global_position(_mouse_position, _tilemap)
  global_position = GDUtil.get_global_position_from_tile(_origin_tile, _tilemap)

  for _collision_tile_offset in data.collision_mask:
    _collision_tiles.append(GDUtil.get_tile_from_offset_global(global_position, _collision_tile_offset, _tilemap))

  for _effect_tile_offset in data.effect_mask:
    _effect_tiles.append(GDUtil.get_tile_from_offset_global(global_position, _effect_tile_offset, _tilemap))

  queue_redraw()

func _ready():
  _sprite.texture = data.sprite
