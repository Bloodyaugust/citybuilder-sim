extends Node2D

@export var data: ResourceData

@onready var _tilemap: TileMap = TilemapActorController.get_tilemap()
@onready var _origin_tile: Vector2i = GDUtil.get_tile_from_global_position(global_position, _tilemap)
@onready var _sprite: Sprite2D = %Sprite2D

func get_resource_id() -> String:
  return data.id

func _ready():
  global_position = GDUtil.get_global_position_from_tile(_origin_tile, _tilemap)
  _sprite.texture = data.sprite
  
  TilemapActorController.add_actor_to_tile(_origin_tile, self)
