extends Control


func _on_state_changed(state_key, substate):
	match state_key:
		"game":
			match substate:
				GameConstants.GAME_STARTED:
					visible = true


func _ready():
	Store.state_changed.connect(self._on_state_changed)
