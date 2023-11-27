extends Node2D

var BUILDING_DATA: Array[BuildingData]
var BUILDING_GHOST: PackedScene = preload("res://doodads/BuildingGhost.tscn")

var _current_ghost = null

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "selected_build_option":
      if _current_ghost:
        _current_ghost.queue_free()
        _current_ghost = null
      _current_ghost = BUILDING_GHOST.instantiate()
      _current_ghost.data = substate
      add_child(_current_ghost)

func _init():
  BUILDING_DATA.assign(GDUtil.load_directory("res://data/buildings/"))

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
