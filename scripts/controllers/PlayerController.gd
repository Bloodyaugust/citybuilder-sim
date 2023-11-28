extends Node2D

@onready var _tilemap: Surface = %TileMap

var _hovered_tile_position: Vector2


func _draw():
	draw_circle(to_local(_hovered_tile_position), 5.0, Color.RED)


func _process(_delta):
	var _mouse_position: Vector2 = get_global_mouse_position()

	var _hovered_tile := GDUtil.get_tile_from_global_position(_mouse_position, _tilemap)
	_hovered_tile_position = GDUtil.get_global_position_from_tile(_hovered_tile, _tilemap)

	queue_redraw()
