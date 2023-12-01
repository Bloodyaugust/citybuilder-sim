extends Resource
class_name BuildingData

@export var sprite: Texture2D
@export var collision_mask: Array[Vector2]
@export var effect_mask: Array[Vector2]
@export var name: String
@export var description: String
@export var resources_collected: Array[String]
@export var resource_collection_rate_per_tile: float
@export var building_flags: Array[GameConstants.BUILDING_FLAGS]
@export var building_cost: Dictionary
@export var resources_generated: Array[String]
@export var resource_generation_rate: Array[String]
@export var building_tab: String
