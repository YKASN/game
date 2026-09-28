extends Control

signal start_requested

@onready var start_button: Button = $Layout/Column/Footer/StartBlock/StartButton
@onready var underline: ColorRect = $Layout/Column/Footer/StartBlock/Underline


func _ready() -> void:
	start_button.pressed.connect(func() -> void: start_requested.emit())
	start_button.mouse_entered.connect(func() -> void: underline.show())
	start_button.mouse_exited.connect(func() -> void: underline.hide())
	start_button.focus_entered.connect(func() -> void: underline.show())
	start_button.focus_exited.connect(func() -> void: underline.hide())
