extends Node

## Future narrative events can call this boundary without knowing the interaction implementation.
signal interaction_requested(id: String)


func start_interaction(id: String) -> void:
	interaction_requested.emit(id)
