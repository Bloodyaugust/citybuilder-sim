extends Node2D

enum BUILDING_TILE_TYPES {
	COLLISION,
	EFFECT,
}

@onready var _tilemap: TileMap = %TileMap

@onready var _save_button: Button = %SaveBuilding
@onready var _clear_button: Button = %ClearBuilding
@onready var _exit_button: Button = %ExitEditor
@onready var _set_collision_button: Button = %SetCollision
@onready var _set_effect_button: Button = %SetEffect

@onready var _file_name_edit: LineEdit = %FileNameEdit
@onready var _building_name_edit: LineEdit = %BuildingNameEdit
@onready var _building_description_edit: TextEdit = %BuildingDescriptionEdit

var _collision_tiles: Array[Vector2i] = []
var _current_tile_type: BUILDING_TILE_TYPES = BUILDING_TILE_TYPES.COLLISION
var _effect_tiles: Array[Vector2i] = []


func _on_save_button_pressed() -> void:
	var _new_building: BuildingData = BuildingData.new()
	var _collision_mask: Array[Vector2] = []
	var _effect_mask: Array[Vector2] = []

	_new_building.name = _building_name_edit.text
	_new_building.description = _building_description_edit.text
	_new_building.collision_mask = _collision_mask
	_new_building.effect_mask = _effect_mask

	ResourceSaver.save(_new_building, "res://data/buildings/" + _file_name_edit.text + ".tres")


func _on_clear_button_pressed() -> void:
	_collision_tiles = []
	_effect_tiles = []
	_file_name_edit.text = ""
	_building_name_edit.text = ""
	_building_description_edit.text = ""


func _on_exit_button_pressed() -> void:
	queue_free()

	ViewController.set_client_view(ViewController.CLIENT_VIEWS.MAIN_MENU)
	Store.set_state("game", GameConstants.GAME_OVER)


func _on_set_collision_button_pressed() -> void:
	_current_tile_type = BUILDING_TILE_TYPES.COLLISION


func _on_set_effect_button_pressed() -> void:
	_current_tile_type = BUILDING_TILE_TYPES.EFFECT


func _ready():
	_save_button.pressed.connect(_on_save_button_pressed)
	_clear_button.pressed.connect(_on_clear_button_pressed)
	_exit_button.pressed.connect(_on_exit_button_pressed)
	_set_collision_button.pressed.connect(_on_set_collision_button_pressed)
	_set_effect_button.pressed.connect(_on_set_effect_button_pressed)
