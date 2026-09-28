extends Control

signal menu_requested
signal restart_requested

const RUNNER_SCRIPT = preload("res://src/narrative/narrative_runner.gd")
const CHAPTER_PATH := "res://content/chapters/seventh_awakening.json"
const METRICS_PATH := "user://demo_sessions.jsonl"

@onready var scene_area: Control = $Layout/Column/SceneArea
@onready var story_panel: VBoxContainer = $Layout/Column/StoryPanel
@onready var story_scroll: ScrollContainer = $Layout/Column/StoryPanel/StoryScroll
@onready var story_lines: VBoxContainer = $Layout/Column/StoryPanel/StoryScroll/StoryLines
@onready var progress: Label = $Layout/Column/StoryPanel/StoryHeader/Progress
@onready var hint: Label = $Layout/Column/StoryPanel/StoryFooter/Hint
@onready var advance_button: Button = $Layout/Column/StoryPanel/StoryFooter/AdvanceButton
@onready var back_button: Button = $Layout/Column/Header/BackButton
@onready var choice_bar: HBoxContainer = $Layout/Column/ChoiceBar
@onready var choice_left: Button = $Layout/Column/ChoiceBar/ChoiceLeft
@onready var choice_right: Button = $Layout/Column/ChoiceBar/ChoiceRight
@onready var choice_stage: Control = $Layout/Column/ChoiceStage
@onready var selected_bubble: Button = $Layout/Column/ChoiceStage/SelectedBubble
@onready var choice_editor: LineEdit = $Layout/Column/ChoiceStage/SelectedBubble/ChoiceEditor
@onready var end_panel: VBoxContainer = $Layout/Column/EndPanel
@onready var replay_button: Button = $Layout/Column/EndPanel/ReplayButton
@onready var presentation: Node = $Presentation

var runner = RUNNER_SCRIPT.new()
var current_line: RichTextLabel
var selected_line: RichTextLabel
var type_tween: Tween
var selected_text := ""
var selected_choice_id := ""
var current_pause_ms := 0
var pause_locked := false
var choice_transitioning := false
var started_ms := 0
var early_reveals := 0
var advance_times_ms: Array[int] = []
var metrics_saved := false
var step_revision := 0


func _ready() -> void:
	started_ms = Time.get_ticks_msec()
	_style_chrome()
	back_button.pressed.connect(_on_back_pressed)
	replay_button.pressed.connect(_on_replay_pressed)
	advance_button.pressed.connect(_advance_story)
	choice_left.pressed.connect(func() -> void: _choose(choice_left))
	choice_right.pressed.connect(func() -> void: _choose(choice_right))
	selected_bubble.pressed.connect(_begin_edit)
	choice_editor.text_submitted.connect(_on_edit_submitted)
	choice_editor.focus_exited.connect(_commit_edit)
	runner.step_changed.connect(_show_step)
	runner.choices_requested.connect(_show_choices)
	runner.completed.connect(_show_end)
	if runner.load_chapter(CHAPTER_PATH):
		runner.start()
	else:
		_append_line("章节载入失败。", false)
		hint.text = "请返回封面。"
		advance_button.hide()


func _exit_tree() -> void:
	_save_metrics(runner.finished)


func _style_chrome() -> void:
	for label in [
		$Layout/Column/Header/SceneLabel,
		$Layout/Column/StoryPanel/StoryHeader/StoryTitle,
		progress,
		hint,
		$Layout/Column/Footer
	]:
		label.add_theme_color_override("font_color", Color(0.62, 0.62, 0.62))
		label.add_theme_font_size_override("font_size", 13)
	$Layout/Column/EndPanel/EndTitle.add_theme_color_override("font_color", Color.WHITE)
	$Layout/Column/EndPanel/EndTitle.add_theme_font_size_override("font_size", 24)
	for button in [back_button, advance_button, replay_button]:
		button.add_theme_color_override("font_color", Color(0.83, 0.83, 0.83))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_focus_color", Color.WHITE)
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	choice_editor.add_theme_color_override("font_color", Color.WHITE)
	choice_editor.add_theme_color_override("caret_color", Color.WHITE)
	choice_editor.add_theme_font_size_override("font_size", 20)


func _show_step(step: Dictionary, index: int, total: int) -> void:
	step_revision += 1
	var revision := step_revision
	presentation.call("apply_cue", str(step.get("cue", "none")))
	progress.text = "%02d / %02d" % [index + 1, total]
	current_pause_ms = int(step.get("pause_ms", 0))
	pause_locked = false
	advance_button.disabled = false
	var speaker := str(step.get("speaker", "旁白"))
	var line_text := str(step.get("text", ""))
	if speaker != "旁白":
		line_text = speaker + "：" + line_text
	_append_line(line_text, true)
	var pause_ms := current_pause_ms
	type_tween.finished.connect(func() -> void:
		if revision == step_revision:
			_start_pause(pause_ms)
	)
	hint.text = "点击当前文字继续 · 向上滚动回看"
	advance_button.show()


func _append_line(content: String, animate: bool) -> RichTextLabel:
	if is_instance_valid(current_line):
		current_line.modulate.a = 0.68
	var line := RichTextLabel.new()
	line.bbcode_enabled = false
	line.fit_content = true
	line.scroll_active = false
	line.mouse_filter = Control.MOUSE_FILTER_STOP
	line.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	line.custom_minimum_size = Vector2(0, 32)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_theme_color_override("default_color", Color.WHITE)
	line.add_theme_font_size_override("normal_font_size", 22)
	line.text = content
	story_lines.add_child(line)
	current_line = line
	var line_index: int = runner.current_index
	line.gui_input.connect(func(event: InputEvent) -> void: _on_line_input(event, line_index))
	if is_instance_valid(type_tween) and type_tween.is_running():
		type_tween.kill()
	if animate:
		line.visible_characters = 0
		type_tween = create_tween()
		type_tween.tween_property(line, "visible_characters", content.length(), maxf(0.45, content.length() * 0.055))
	else:
		line.visible_characters = -1
	call_deferred("_scroll_to_latest")
	return line


func _scroll_to_latest() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return
	story_scroll.scroll_vertical = int(story_scroll.get_v_scroll_bar().max_value)


func _on_line_input(event: InputEvent, line_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if line_index == runner.current_index and not choice_bar.visible and not end_panel.visible:
			_advance_story()


func _advance_story() -> void:
	if choice_transitioning or end_panel.visible:
		return
	if is_instance_valid(type_tween) and type_tween.is_running():
		type_tween.kill()
		current_line.visible_characters = -1
		early_reveals += 1
		_start_pause(current_pause_ms)
		return
	if pause_locked:
		return
	if runner.awaiting_choice:
		if choice_stage.visible:
			_continue_after_choice()
		return
	presentation.call("play_paper")
	advance_times_ms.append(Time.get_ticks_msec() - started_ms)
	runner.advance()


func _start_pause(duration_ms: int) -> void:
	if duration_ms <= 0:
		return
	var revision := step_revision
	pause_locked = true
	advance_button.disabled = true
	hint.text = "稍等片刻……"
	await get_tree().create_timer(float(duration_ms) / 1000.0).timeout
	if not is_inside_tree() or revision != step_revision:
		return
	pause_locked = false
	advance_button.disabled = false
	hint.text = "点击当前文字继续 · 向上滚动回看"


func _show_choices(options: Array[Dictionary]) -> void:
	step_revision += 1
	pause_locked = false
	advance_button.disabled = false
	choice_left.text = str(options[0].get("text", ""))
	choice_right.text = str(options[1].get("text", ""))
	choice_left.set_meta("choice_id", str(options[0].get("id", "")))
	choice_right.set_meta("choice_id", str(options[1].get("id", "")))
	advance_button.hide()
	progress.text = "选择"
	hint.text = "选一句你想说的话"
	choice_bar.show()
	call_deferred("_scroll_to_latest")


func _choose(source: Button) -> void:
	if not runner.awaiting_choice or choice_stage.visible:
		return
	var source_position := source.global_position
	var source_size := source.size
	selected_choice_id = str(source.get_meta("choice_id"))
	selected_text = source.text
	current_pause_ms = 0
	presentation.call("play_paper")
	selected_line = _append_line("你：" + selected_text, true)
	selected_line.mouse_default_cursor_shape = Control.CURSOR_ARROW
	choice_bar.hide()
	choice_stage.show()
	scene_area.custom_minimum_size = Vector2(0, 195)
	story_panel.custom_minimum_size = Vector2(0, 170)
	await get_tree().process_frame
	if not is_inside_tree():
		return
	selected_bubble.text = selected_text
	selected_bubble.size = source_size
	selected_bubble.position = source_position - choice_stage.global_position
	selected_bubble.show()
	var target_size := Vector2(390, 125)
	var target_position := (choice_stage.size - target_size) * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(selected_bubble, "position", target_position, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(selected_bubble, "size", target_size, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_scroll_to_latest)
	call_deferred("_scroll_to_latest")
	hint.text = "再次点击可改写，或继续阅读"
	advance_button.show()


func _continue_after_choice() -> void:
	choice_transitioning = true
	advance_button.disabled = true
	_commit_edit()
	presentation.call("play_paper")
	var tween := create_tween()
	tween.tween_property(selected_bubble, "modulate:a", 0.0, 0.22)
	await tween.finished
	if not is_inside_tree():
		return
	choice_stage.hide()
	selected_bubble.modulate.a = 1.0
	scene_area.custom_minimum_size = Vector2(0, 235)
	story_panel.custom_minimum_size = Vector2(0, 190)
	advance_times_ms.append(Time.get_ticks_msec() - started_ms)
	if not runner.choose(selected_choice_id):
		push_error("Could not continue from choice: " + selected_choice_id)
	choice_transitioning = false


func _begin_edit() -> void:
	if choice_editor.visible or choice_transitioning:
		return
	choice_editor.text = selected_text
	selected_bubble.text = ""
	choice_editor.show()
	choice_editor.call_deferred("grab_focus")
	choice_editor.call_deferred("select_all")


func _on_edit_submitted(_new_text: String) -> void:
	_commit_edit()
	selected_bubble.grab_focus()


func _commit_edit() -> void:
	if not choice_editor.visible:
		return
	var edited := choice_editor.text.strip_edges()
	if not edited.is_empty():
		selected_text = edited
		selected_bubble.text = edited
		selected_line.text = "你：" + edited
		selected_line.visible_characters = -1
	else:
		selected_bubble.text = selected_text
	choice_editor.hide()
	call_deferred("_scroll_to_latest")


func _show_end() -> void:
	step_revision += 1
	pause_locked = false
	presentation.call("stop_ambient")
	advance_button.hide()
	choice_bar.hide()
	choice_stage.hide()
	end_panel.show()
	progress.text = "结束"
	hint.text = "这一段结束了。"
	_save_metrics(true)


func _on_back_pressed() -> void:
	_save_metrics(false)
	menu_requested.emit()


func _on_replay_pressed() -> void:
	_save_metrics(true)
	restart_requested.emit()


func _save_metrics(completed: bool) -> void:
	if metrics_saved or started_ms == 0:
		return
	metrics_saved = true
	var record := {
		"chapter": "seventh_awakening",
		"completed": completed,
		"elapsed_seconds": snappedf(float(Time.get_ticks_msec() - started_ms) / 1000.0, 0.1),
		"early_reveals": early_reveals,
		"choice": selected_choice_id,
		"advance_times_ms": advance_times_ms
	}
	var file := FileAccess.open(METRICS_PATH, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(METRICS_PATH, FileAccess.WRITE_READ)
	if file != null:
		file.seek_end()
		file.store_line(JSON.stringify(record))
