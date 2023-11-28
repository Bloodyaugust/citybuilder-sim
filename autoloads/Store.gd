extends Node

const CONTROLLER_CONTAINER_SCENE: PackedScene = preload("res://doodads/ControllerContainer.tscn")
const LEVEL_0_SCENE: PackedScene = preload("res://scenes/levels/level-0.tscn")
const PersistentStore := preload("res://scripts/classes/PersistentStore.gd")

signal state_changed(state_key, substate)

var persistent_store: Resource
var state: Dictionary = {
	"client_view": ViewController.CLIENT_VIEWS.NONE,
	"game": "",
	"debug": true,
	"selected_actor": null,
	"selected_build_option": null,
}

@onready var _level_container: Node2D = get_tree().get_first_node_in_group("LevelContainer")


func start_game() -> void:
	ViewController.set_client_view(ViewController.CLIENT_VIEWS.NONE)
	set_state("game", GameConstants.GAME_STARTING)

	var _new_level = LEVEL_0_SCENE.instantiate()
	var _new_controller_container = CONTROLLER_CONTAINER_SCENE.instantiate()

	_level_container.add_child(_new_level)
	_level_container.add_child(_new_controller_container)

	set_state("game", GameConstants.GAME_STARTED)


func save_persistent_store() -> void:
	if ResourceSaver.save(persistent_store, ClientConstants.CLIENT_PERSISTENT_STORE_PATH) != OK:
		print("Failed to save persistent store")


func set_state(state_key: String, new_state) -> void:
	state[state_key] = new_state
	emit_signal("state_changed", state_key, state[state_key])
	print("State changed: ", state_key, " -> ", state[state_key])


func _initialize():
	set_state("game", GameConstants.GAME_OVER)

	(
		(func(): ViewController.set_client_view(
			(
				ViewController.CLIENT_VIEWS.SPLASH
				if !state.debug
				else ViewController.CLIENT_VIEWS.MAIN_MENU
			),
			ViewController.TRANSITION_TYPES.FADE
		))
		. call_deferred()
	)


func _ready():
	if FileAccess.file_exists(ClientConstants.CLIENT_PERSISTENT_STORE_PATH):
		persistent_store = load(ClientConstants.CLIENT_PERSISTENT_STORE_PATH)

	if !persistent_store:
		persistent_store = PersistentStore.new()
		save_persistent_store()

	call_deferred("_initialize")
