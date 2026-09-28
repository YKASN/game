extends Control

signal menu_requested

const RUNNER_SCRIPT = preload("res://src/narrative/narrative_runner.gd")
const CHAPTER_PATH := "res://content/chapters/prologue.json"

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
@onready var presentation: Node = $Presentation

var runner = RUNNER_SCRIPT.new()
var current_line: RichTextLabel
var selected_line: RichTextLabel
var type_tween: Tween
var selected_text := ""


func _ready() -> void:
	_style_chrome()
	back_button.pressed.connect(func() -> void: menu_requested.emit())
	advance_button.pressed.connect(_advance_story)
	choice_left.pressed.connect(func() -> void: _choose(choice_left))
	choice_right.pressed.connect(func() -> void: _choose(choice_right))
	selected_bubble.pressed.connect(_begin_edit)
	choice_editor.text_submitted.connect(_on_edit_submitted)
	choice_editor.focus_exited.connect(_commit_edit)
	runner.step_changed.connect(_show_step)
	runner.completed.connect(_show_choices)
	if runner.load_chapter(CHAPTER_PATH):
		choice_left.text = runner.choices[0] if runner.choices.size() > 0 else "我听见了钟声。"
		choice_right.text = runner.choices[1] if runner.choices.size() > 1 else "我听见了心跳。"
		runner.start()
	else:
		_append_line("章节载入失败。", false)
		hint.text = "请返回封面。"
		advance_button.hide()


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
	for button in [back_button, advance_button]:
		button.add_theme_color_override("font_color", Color(0.83, 0.83, 0.83))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_focus_color", Color.WHITE)
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	choice_editor.add_theme_color_override("font_color", Color.WHITE)
	choice_editor.add_theme_color_override("caret_color", Color.WHITE)
	choice_editor.add_theme_font_size_override("font_size", 20)


func _show_step(step: Dictionary, index: int, total: int) -> void:
	presentation.call("apply_cue", str(step.get("cue", "none")))
	progress.text = "%02d / %02d" % [index + 1, total]
	_append_line(str(step.get("text", "")), true)
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
	story_scroll.scroll_vertical = int(story_scroll.get_v_scroll_bar().max_value)


func _on_line_input(event: InputEvent, line_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if line_index == runner.current_index and not choice_bar.visible and not choice_stage.visible:
			_advance_story()


func _advance_story() -> void:
	if is_instance_valid(type_tween) and type_tween.is_running():
		type_tween.kill()
		current_line.visible_characters = -1
		return
	presentation.call("play_paper")
	runner.advance()


func _show_choices() -> void:
	advance_button.hide()
	hint.text = "选择一句话，说出你的答案"
	choice_bar.show()
	call_deferred("_scroll_to_latest")


func _choose(source: Button) -> void:
	var source_position := source.global_position
	var source_size := source.size
	selected_text = source.text
	presentation.call("play_paper")
	selected_line = _append_line("你：" + selected_text, true)
	selected_line.mouse_default_cursor_shape = Control.CURSOR_ARROW
	choice_bar.hide()
	choice_stage.show()
	scene_area.custom_minimum_size.y = 195
	story_panel.custom_minimum_size.y = 170
	await get_tree().process_frame
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
	hint.text = "再次点击气泡，可以改写这句话"


func _begin_edit() -> void:
	if choice_editor.visible:
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
