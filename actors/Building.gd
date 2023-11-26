extends Node2D

@export var data: BuildingData

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _tilemap: TileMap = get_tree().get_first_node_in_group("TileMap")

var _collision_tiles: Array[Vector2i]
var _effect_tiles: Array[Vector2i]
var _origin_tile: Vector2i

func _draw():
  for _collision_tile in _collision_tiles:
    draw_circle(to_local(_tilemap.to_global(_tilemap.map_to_local(_collision_tile))), 35.0, Color.ORANGE_RED)

  for _effect_tile in _effect_tiles:
    draw_circle(to_local(_tilemap.to_global(_tilemap.map_to_local(_effect_tile))), 5.0, Color.YELLOW_GREEN)

func _ready():
  _origin_tile = _tilemap.local_to_map(_tilemap.to_local(global_position))

  for _collision_tile in data.collision_mask:
    _collision_tiles.append(_origin_tile + _collision_tile)

  for _effect_tile in data.effect_mask:
    _effect_tiles.append(_origin_tile + _effect_tile)

  _sprite.texture = data.sprite

  queue_redraw()
