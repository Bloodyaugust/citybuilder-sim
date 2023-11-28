extends Control

@onready var _selection_detail_inner: Control = %SelectionDetailInner
@onready var _selection_detail_texture: TextureRect = %SelectionDetailTexture
@onready var _selection_detail_name: Label = %SelectionDetailName
@onready var _selection_detail_description: Label = %SelectionDetailDescription


func _on_state_changed(state_key, substate):
	match state_key:
		"selected_actor":
			_update_details(substate)


func _process(_delta):
	if Store.state.selected_actor:
		_update_details(Store.state.selected_actor)


func _ready():
	Store.state_changed.connect(self._on_state_changed)


func _update_details(actor: Variant):
	if actor && actor.has_method("get_selection_details"):
		var _actor_details: Dictionary = actor.get_selection_details()
		_selection_detail_inner.visible = true
		_selection_detail_texture.texture = _actor_details.sprite
		_selection_detail_name.text = _actor_details.name
		_selection_detail_description.text = _actor_details.description
	else:
		_selection_detail_inner.visible = false
