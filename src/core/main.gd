extends Control

const MENU_SCENE: PackedScene = preload("res://scenes/menu/menu.tscn")
const NARRATIVE_SCENE: PackedScene = preload("res://scenes/narrative/narrative.tscn")

var active_screen: Control


func _ready() -> void:
	show_menu()


func show_menu() -> void:
	_replace_screen(MENU_SCENE)
	active_screen.connect("start_requested", show_narrative)


func show_narrative() -> void:
	_replace_screen(NARRATIVE_SCENE)
	active_screen.connect("menu_requested", show_menu)
	active_screen.connect("restart_requested", show_narrative)


func _replace_screen(scene: PackedScene) -> void:
	if is_instance_valid(active_screen):
		remove_child(active_screen)
		active_screen.queue_free()
	active_screen = scene.instantiate() as Control
	add_child(active_screen)
	active_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
