extends Control

var BUILD_OPTION_COMPONENT = preload("res://views/components/BuildOption.tscn")

@onready var _build_options_logistics: HBoxContainer = %BuildOptionsLogistics
@onready var _build_options_resources: HBoxContainer = %BuildOptionsResources
@onready var _build_options_civic: HBoxContainer = %BuildOptionsCivic
@onready var _build_options_misc: HBoxContainer = %BuildOptionsMisc

var _building_controller: BuildingController


func _reset_options() -> void:
	GDUtil.free_children(_build_options_logistics)
	GDUtil.free_children(_build_options_resources)
	GDUtil.free_children(_build_options_civic)
	GDUtil.free_children(_build_options_misc)

	for _building_data in _building_controller.BUILDING_DATA:
		var _new_build_option_component: Control = BUILD_OPTION_COMPONENT.instantiate()

		_new_build_option_component.data = _building_data

		match _building_data.building_tab:
			"logistics":
				_build_options_logistics.add_child(_new_build_option_component)
			"resources":
				_build_options_resources.add_child(_new_build_option_component)
			"civic":
				_build_options_civic.add_child(_new_build_option_component)
			_:
				_build_options_misc.add_child(_new_build_option_component)


func _on_state_changed(state_key, substate):
	match state_key:
		"game":
			match substate:
				GameConstants.GAME_STARTED:
					_building_controller = get_tree().get_first_node_in_group("BuildingController")
					_reset_options()


func _ready():
	Store.state_changed.connect(self._on_state_changed)
