extends Node2D
class_name ResourceActor

@export var data: ResourceData

@onready var _tilemap: Surface = get_tree().get_first_node_in_group("TileMap")

@onready var _origin_tile: Vector2i = GDUtil.get_tile_from_global_position(global_position, _tilemap)
@onready var _sprite: Sprite2D = %Sprite2D

@onready var _tilemap_actor_controller: TileMapActorController = get_tree().get_first_node_in_group(
	"TileMapActorController"
)


func get_resource_id() -> String:
	return data.id


func _ready():
	global_position = GDUtil.get_global_position_from_tile(_origin_tile, _tilemap)
	_sprite.texture = data.sprite
	_tilemap_actor_controller.add_actor_to_tile(_origin_tile, self)
