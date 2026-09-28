extends RefCounted

signal step_changed(step: Dictionary, index: int, total: int)
signal choices_requested(options: Array[Dictionary])
signal completed

var steps: Array[Dictionary] = []
var choices: Array[Dictionary] = []
var ending: Array[Dictionary] = []
var branches: Dictionary = {}
var current_index := -1
var awaiting_choice := false
var choice_made := false
var finished := false
var selected_choice_id := ""


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
	choices.clear()
	ending.clear()
	branches.clear()
	for item in content.get("steps", []):
		if typeof(item) == TYPE_DICTIONARY and item.has("id") and item.has("text"):
			steps.append(item)
	for option in content.get("choices", []):
		if typeof(option) == TYPE_DICTIONARY and option.has("id") and option.has("text"):
			choices.append(option)
	for item in content.get("ending", []):
		if typeof(item) == TYPE_DICTIONARY and item.has("id") and item.has("text"):
			ending.append(item)
	var branch_data: Variant = content.get("branches", {})
	if typeof(branch_data) == TYPE_DICTIONARY:
		branches = branch_data
	for option in choices:
		if not branches.has(option["id"]) or typeof(branches[option["id"]]) != TYPE_DICTIONARY:
			push_error("Missing branch for choice: " + str(option["id"]))
			return false
	current_index = -1
	awaiting_choice = false
	choice_made = false
	finished = false
	selected_choice_id = ""
	return not steps.is_empty() and choices.size() == 2 and not ending.is_empty()


func start() -> void:
	current_index = -1
	advance()


func advance() -> void:
	if awaiting_choice or finished:
		return
	if current_index + 1 < steps.size():
		current_index += 1
		step_changed.emit(steps[current_index], current_index, steps.size())
	elif not choice_made:
		awaiting_choice = true
		choices_requested.emit(choices)
	else:
		finished = true
		completed.emit()


func choose(choice_id: String) -> bool:
	if not awaiting_choice or not branches.has(choice_id):
		return false
	selected_choice_id = choice_id
	choice_made = true
	awaiting_choice = false
	steps.append(branches[choice_id])
	steps.append_array(ending)
	advance()
	return true


func current_step_id() -> String:
	if current_index < 0 or current_index >= steps.size():
		return ""
	return str(steps[current_index].get("id", ""))
