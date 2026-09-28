extends Button

const WHITE := Color(1.0, 1.0, 1.0)
const SOFT_WHITE := Color(0.78, 0.78, 0.78)


func _ready() -> void:
	for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		add_theme_color_override(color_name, WHITE)
	add_theme_font_size_override("font_size", 18)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	resized.connect(queue_redraw)


func _draw() -> void:
	var outline := PackedVector2Array()
	_curve(outline, Vector2(0.17, 0.40), Vector2(0.09, 0.37), Vector2(0.05, 0.48), Vector2(0.10, 0.59))
	_curve(outline, Vector2(0.10, 0.59), Vector2(0.12, 0.65), Vector2(0.15, 0.66), Vector2(0.19, 0.67))
	_curve(outline, Vector2(0.19, 0.67), Vector2(0.20, 0.80), Vector2(0.32, 0.84), Vector2(0.40, 0.76))
	_curve(outline, Vector2(0.40, 0.76), Vector2(0.46, 0.86), Vector2(0.58, 0.86), Vector2(0.63, 0.76))
	_curve(outline, Vector2(0.63, 0.76), Vector2(0.74, 0.83), Vector2(0.84, 0.76), Vector2(0.84, 0.65))
	_curve(outline, Vector2(0.84, 0.65), Vector2(0.96, 0.63), Vector2(0.98, 0.46), Vector2(0.85, 0.40))
	_curve(outline, Vector2(0.85, 0.40), Vector2(0.85, 0.27), Vector2(0.76, 0.22), Vector2(0.65, 0.28))
	_curve(outline, Vector2(0.65, 0.28), Vector2(0.59, 0.15), Vector2(0.46, 0.15), Vector2(0.39, 0.27))
	_curve(outline, Vector2(0.39, 0.27), Vector2(0.30, 0.20), Vector2(0.19, 0.26), Vector2(0.17, 0.40))
	var ink := WHITE if is_hovered() or has_focus() else SOFT_WHITE
	draw_polyline(outline, ink, 2.0, true)


func _curve(points: PackedVector2Array, a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> void:
	for i in range(13):
		var t := float(i) / 12.0
		var one_minus := 1.0 - t
		var point := a * pow(one_minus, 3) + b * 3.0 * pow(one_minus, 2) * t + c * 3.0 * one_minus * t * t + d * pow(t, 3)
		points.append(point * size)
