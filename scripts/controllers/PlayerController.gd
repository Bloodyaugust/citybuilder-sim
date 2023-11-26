extends Node2D

@onready var _tilemap: TileMap = %TileMap

var _hovered_tile_position: Vector2

func _draw():
  draw_circle(to_local(_hovered_tile_position), 5.0, Color.RED)

func _process(delta):
  var _mouse_position: Vector2 = get_global_mouse_position()
  
  var _hovered_tile_location := _tilemap.local_to_map(_tilemap.to_local(_mouse_position))
  _hovered_tile_position = _tilemap.to_global(_tilemap.map_to_local(_hovered_tile_location))

  queue_redraw()
