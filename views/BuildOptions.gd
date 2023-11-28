extends Control

var BUILD_OPTION_COMPONENT = preload("res://views/components/BuildOption.tscn")

@onready var _buildOptionsHBox: HBoxContainer = %BuildOptionsHBox


func _reset_options() -> void:
	GDUtil.free_children(_buildOptionsHBox)

	for _building_data in BuildingController.BUILDING_DATA:
		var _new_build_option_component: Control = BUILD_OPTION_COMPONENT.instantiate()

		_new_build_option_component.data = _building_data
		_buildOptionsHBox.add_child(_new_build_option_component)


func _on_state_changed(_state_key, _substate):
	pass


func _ready():
	Store.state_changed.connect(self._on_state_changed)

	_reset_options()
