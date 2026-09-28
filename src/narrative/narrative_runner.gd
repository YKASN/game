extends RefCounted

signal step_changed(step: Dictionary, index: int, total: int)
signal completed

var steps: Array[Dictionary] = []
var current_index := -1


func load_chapter(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open chapter: " + path)
		return false
	var content: Variant = JSON.parse_string(file.get_as_text())
	if typeof(content) != TYPE_DICTIONARY:
		push_error("Invalid chapter JSON: " + path)
		return false
	steps.clear()
	for item in content.get("steps", []):
		if typeof(item) == TYPE_DICTIONARY and item.has("text"):
			steps.append(item)
	current_index = -1
	return not steps.is_empty()


func start() -> void:
	current_index = -1
	advance()


func advance() -> void:
	if current_index + 1 >= steps.size():
		completed.emit()
		return
	current_index += 1
	step_changed.emit(steps[current_index], current_index, steps.size())
