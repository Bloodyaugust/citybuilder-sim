extends Control

var BUILD_OPTION_COMPONENT = preload("res://views/components/BuildOption.tscn")

@onready var _buildOptionsHBox: HBoxContainer = %BuildOptionsHBox

var _building_controller: BuildingController


func _reset_options() -> void:
	GDUtil.free_children(_buildOptionsHBox)

	for _building_data in _building_controller.BUILDING_DATA:
		var _new_build_option_component: Control = BUILD_OPTION_COMPONENT.instantiate()

		_new_build_option_component.data = _building_data
		_buildOptionsHBox.add_child(_new_build_option_component)


func _on_state_changed(state_key, substate):
	match state_key:
		"game":
			match substate:
				GameConstants.GAME_STARTED:
					_building_controller = get_tree().get_first_node_in_group("BuildingController")
					_reset_options()


func _ready():
	Store.state_changed.connect(self._on_state_changed)
