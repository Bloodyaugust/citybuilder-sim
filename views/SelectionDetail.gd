extends Control

@onready var _selection_detail_inner: Control = %SelectionDetailInner
@onready var _selection_detail_texture: TextureRect = %SelectionDetailTexture
@onready var _selection_detail_name: Label = %SelectionDetailName
@onready var _selection_detail_description: Label = %SelectionDetailDescription

func _on_state_changed(state_key, substate):
  match state_key:
    "selected_actor":
      if substate:
        _selection_detail_inner.visible = true
        _selection_detail_texture.texture = substate.data.sprite
        _selection_detail_name.text = substate.data.name
        _selection_detail_description.text = substate.data.description
      else:
        _selection_detail_inner.visible = false

func _ready():
  Store.state_changed.connect(self._on_state_changed)

