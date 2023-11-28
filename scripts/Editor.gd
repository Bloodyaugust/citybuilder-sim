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
@onready var _building_logistics_checkbox: CheckBox = %BuildingLogisticsCheckbox

var _collision_tiles: Array[Vector2i] = [Vector2i(0, 0)]
var _current_tile_type: BUILDING_TILE_TYPES = BUILDING_TILE_TYPES.COLLISION
var _effect_tiles: Array[Vector2i] = []
var _hovered_tile: Vector2i


func _draw():
	draw_circle(
		to_local(GDUtil.get_global_position_from_tile(_hovered_tile, _tilemap)), 5.0, Color.RED
	)

	for _collision_tile in _collision_tiles:
		draw_circle(
			to_local(GDUtil.get_global_position_from_tile(_collision_tile, _tilemap)),
			35.0,
			Color.ORANGE_RED
		)
	for _effect_tile in _effect_tiles:
		draw_circle(
			to_local(GDUtil.get_global_position_from_tile(_effect_tile, _tilemap)),
			5.0,
			Color.YELLOW_GREEN
		)


func _on_save_button_pressed() -> void:
	var _new_building: BuildingData = BuildingData.new()
	var _collision_mask: Array[Vector2] = []
	var _effect_mask: Array[Vector2] = []
	var _building_flags: Array[GameConstants.BUILDING_FLAGS] = []

	_building_flags.assign(
		(
			[GameConstants.BUILDING_FLAGS.LOGISTICS]
			if _building_logistics_checkbox.button_pressed
			else []
		)
	)

	_collision_mask.assign(
		_collision_tiles.map(
			func(_tile: Vector2i): return (
				(
					GDUtil.get_global_position_from_tile(_tile, _tilemap)
					- GDUtil.get_global_position_from_tile(Vector2i(0, 0), _tilemap)
				)
				/ Vector2(_tilemap.tile_set.tile_size)
			)
		)
	)
	_effect_mask.assign(
		_effect_tiles.map(
			func(_tile: Vector2i): return (
				(
					GDUtil.get_global_position_from_tile(_tile, _tilemap)
					- GDUtil.get_global_position_from_tile(Vector2i(0, 0), _tilemap)
				)
				/ Vector2(_tilemap.tile_set.tile_size)
			)
		)
	)

	_new_building.name = _building_name_edit.text
	_new_building.description = _building_description_edit.text
	_new_building.collision_mask = _collision_mask
	_new_building.effect_mask = _effect_mask
	_new_building.building_flags = _building_flags

	ResourceSaver.save(_new_building, "res://data/buildings/" + _file_name_edit.text + ".tres")


func _on_clear_button_pressed() -> void:
	_collision_tiles = [Vector2i(0, 0)]
	_effect_tiles = []
	_file_name_edit.text = ""
	_building_name_edit.text = ""
	_building_description_edit.text = ""
	_building_logistics_checkbox.button_pressed = false


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


func _process(_delta):
	var _mouse_position: Vector2 = get_global_mouse_position()

	_hovered_tile = GDUtil.get_tile_from_global_position(_mouse_position, _tilemap)

	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("confirm_building"):
		if _hovered_tile in _collision_tiles:
			_collision_tiles.erase(_hovered_tile)

		if _hovered_tile in _effect_tiles:
			_effect_tiles.erase(_hovered_tile)

		if _current_tile_type == BUILDING_TILE_TYPES.COLLISION:
			_collision_tiles.append(_hovered_tile)
		else:
			_effect_tiles.append(_hovered_tile)
