extends Control

signal start_requested

@onready var start_button: Button = $Layout/Column/Footer/StartBlock/StartButton
@onready var underline: ColorRect = $Layout/Column/Footer/StartBlock/Underline


func _ready() -> void:
	_style_text()
	start_button.pressed.connect(func() -> void: start_requested.emit())
	start_button.mouse_entered.connect(func() -> void: underline.show())
	start_button.mouse_exited.connect(func() -> void: underline.hide())
	start_button.focus_entered.connect(func() -> void: underline.show())
	start_button.focus_exited.connect(func() -> void: underline.hide())


func _style_text() -> void:
	for label in [
		$Layout/Column/Header/Issue,
		$Layout/Column/Header/Edition,
		$Layout/Column/TitleBlock/Overline,
		$Layout/Column/TitleBlock/Subtitle,
		$Layout/Column/Footer/Hint
	]:
		label.add_theme_color_override("font_color", Color(0.66, 0.66, 0.66))
	$Layout/Column/TitleBlock/Title.add_theme_color_override("font_color", Color.WHITE)
	for color_name in ["font_color", "font_hover_color", "font_focus_color"]:
		start_button.add_theme_color_override(color_name, Color.WHITE)
	start_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
