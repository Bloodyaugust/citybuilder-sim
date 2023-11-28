extends Control

var data: BuildingData

@onready var _texture_rect: TextureRect = %TextureRect
@onready var _name: Label = %Name
@onready var _description: Label = %Description


func _on_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		Store.set_state("selected_build_option", data)
		Store.set_state("selected_actor", null)


func _ready():
	gui_input.connect(_on_clicked)

	_texture_rect.texture = data.sprite
	_name.text = data.name
	_description.text = data.description
