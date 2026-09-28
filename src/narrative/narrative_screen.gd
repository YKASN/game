extends Control

signal menu_requested

const RUNNER_SCRIPT = preload("res://src/narrative/narrative_runner.gd")
const CHAPTER_PATH := "res://content/chapters/prologue.json"

@onready var text_button: Button = $Layout/Column/StoryBlock/TextButton
@onready var progress: Label = $Layout/Column/StoryBlock/Progress
@onready var hint: Label = $Layout/Column/StoryBlock/Hint
@onready var end_block: VBoxContainer = $Layout/Column/StoryBlock/EndBlock
@onready var back_button: Button = $Layout/Column/Header/BackButton
@onready var return_button: Button = $Layout/Column/StoryBlock/EndBlock/ReturnButton
@onready var scene_label: Label = $Layout/Column/Header/SceneLabel
@onready var presentation: Node = $Presentation

var runner = RUNNER_SCRIPT.new()


func _ready() -> void:
	text_button.pressed.connect(_on_text_pressed)
	back_button.pressed.connect(func() -> void: menu_requested.emit())
	return_button.pressed.connect(func() -> void: menu_requested.emit())
	runner.step_changed.connect(_show_step)
	runner.completed.connect(_show_end)
	if runner.load_chapter(CHAPTER_PATH):
		runner.start()
	else:
		text_button.text = "章节载入失败。点击返回封面。"
		text_button.pressed.connect(func() -> void: menu_requested.emit())


func _on_text_pressed() -> void:
	text_button.disabled = true
	presentation.call("play_paper")
	var tween := create_tween()
	tween.tween_property(text_button, "modulate:a", 0.0, 0.15)
	tween.finished.connect(func() -> void: runner.advance())


func _show_step(step: Dictionary, index: int, total: int) -> void:
	var cue: String = step.get("cue", "none")
	presentation.call("apply_cue", cue)
	text_button.text = str(step.get("text", ""))
	progress.text = "%02d / %02d" % [index + 1, total]
	text_button.modulate.a = 0.0
	text_button.disabled = false
	var on_dark := cue == "dark"
	var main_color := Color(0.96, 0.96, 0.96) if on_dark else Color(0.12, 0.12, 0.12)
	var minor_color := Color(0.7, 0.7, 0.7) if on_dark else Color(0.43, 0.42, 0.40)
	text_button.add_theme_color_override("font_color", main_color)
	text_button.add_theme_color_override("font_hover_color", Color(0.76, 0.76, 0.76) if on_dark else Color(0.36, 0.36, 0.36))
	text_button.add_theme_color_override("font_focus_color", main_color)
	for label in [progress, hint, scene_label]:
		label.add_theme_color_override("font_color", minor_color)
	back_button.add_theme_color_override("font_color", minor_color)
	back_button.add_theme_color_override("font_hover_color", main_color)
	var tween := create_tween()
	tween.tween_property(text_button, "modulate:a", 1.0, 0.3)
	text_button.grab_focus()


func _show_end() -> void:
	text_button.hide()
	hint.hide()
	progress.text = "05 / 05"
	end_block.show()
	return_button.grab_focus()
