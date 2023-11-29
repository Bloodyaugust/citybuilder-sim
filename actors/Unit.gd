extends Node2D
class_name Unit

@export var data: UnitData

var dispatch_building: Building
var target_building: Building

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _tilemap: Surface = get_tree().get_first_node_in_group("TileMap")

var _arrived_at_target: bool = false
var _current_path_index: int = 0
var _path: Array[Vector2]
var _stored_resources: Dictionary = {}


func _process(delta):
	var _tile_nav_weight: float = _tilemap.get_nav_weight_from_tile(
		GDUtil.get_tile_from_global_position(global_position, _tilemap)
	)

	global_position = global_position.move_toward(
		_path[_current_path_index],
		(
			delta
			* (
				data.speed
				/ (_tile_nav_weight / 4 if _tile_nav_weight > 1.0 else _tile_nav_weight * 4)
			)
		)
	)

	if global_position.is_equal_approx(_path[_current_path_index]):
		_current_path_index += 1

		if _current_path_index == _path.size():
			if _arrived_at_target:
				dispatch_building.store_resources(_stored_resources)
				queue_free()
			else:
				_arrived_at_target = true
				_stored_resources = target_building.pickup_stored_resources()

				_path = _tilemap.get_nav_path(
					target_building.get_origin_tile(), dispatch_building.get_origin_tile()
				)
				_current_path_index = 0


func _ready():
	_path = _tilemap.get_nav_path(
		dispatch_building.get_origin_tile(), target_building.get_origin_tile()
	)
	_sprite.texture = data.sprite
