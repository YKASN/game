extends Control

const INK := Color(0.96, 0.96, 0.96)
const DIM := Color(0.62, 0.62, 0.62)
const FAINT := Color(0.38, 0.38, 0.38)

var phase := 0.0
var window_alpha := 1.0
var table_alpha := 1.0
var mirror_alpha := 1.0
var empty_alpha := 0.0
var voice_alpha := 0.0
var lamp_alpha := 1.0


func _process(delta: float) -> void:
	phase += delta
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var left := size.x * 0.18
	var right := size.x * 0.82
	var ceiling := size.y * 0.14
	var floor_y := size.y * 0.81
	var sway := sin(phase * 1.0) * 1.5
	draw_line(Vector2(left, floor_y), Vector2(right, floor_y), INK, 1.6, true)
	draw_line(Vector2(left, ceiling), Vector2(left, floor_y), DIM, 1.3, true)
	draw_line(Vector2(left, ceiling), Vector2(right, ceiling), FAINT, 1.3, true)
	draw_line(Vector2(right, ceiling), Vector2(right, floor_y), DIM, 1.3, true)
	draw_line(Vector2(left + 8, floor_y + 15), Vector2(right - 8, floor_y + 15), FAINT, 1.0, true)
	_draw_lamp(ceiling, sway)
	_draw_window()
	_draw_table(floor_y)
	_draw_mirror()
	_draw_empty_bubble()


func _draw_lamp(ceiling: float, sway: float) -> void:
	var center := Vector2(size.x * 0.51 + sway, size.y * 0.34)
	var color := Color(INK.r, INK.g, INK.b, lamp_alpha)
	draw_line(Vector2(size.x * 0.51, ceiling), center, color, 1.3, true)
	draw_arc(center + Vector2(0, 5), size.y * 0.065, 0, PI, 22, color, 1.8, true)
	draw_circle(center + Vector2(0, 5), 2.0, color)


func _draw_window() -> void:
	if window_alpha <= 0.01:
		return
	var color := Color(INK.r, INK.g, INK.b, window_alpha)
	var rect := Rect2(Vector2(size.x * 0.25, size.y * 0.30), Vector2(size.x * 0.12, size.y * 0.24))
	draw_rect(rect, color, false, 1.6, true)
	draw_line(Vector2(rect.get_center().x, rect.position.y), Vector2(rect.get_center().x, rect.end.y), color, 1.1, true)
	draw_line(Vector2(rect.position.x, rect.get_center().y), Vector2(rect.end.x, rect.get_center().y), color, 1.1, true)


func _draw_table(floor_y: float) -> void:
	if table_alpha <= 0.01:
		return
	var color := Color(INK.r, INK.g, INK.b, table_alpha)
	var x := size.x * 0.45
	var width := size.x * 0.16
	var top := floor_y - size.y * 0.15
	draw_line(Vector2(x, top), Vector2(x + width, top), color, 2.0, true)
	draw_line(Vector2(x + 6, top + 6), Vector2(x + width - 6, top + 6), color, 1.2, true)
	draw_line(Vector2(x + 12, top + 6), Vector2(x + 12, floor_y), color, 1.6, true)
	draw_line(Vector2(x + width - 12, top + 6), Vector2(x + width - 12, floor_y), color, 1.6, true)


func _draw_mirror() -> void:
	if mirror_alpha <= 0.01:
		return
	var color := Color(INK.r, INK.g, INK.b, mirror_alpha)
	var center := Vector2(size.x * 0.73, size.y * 0.43)
	var points := PackedVector2Array()
	for i in range(65):
		var angle := TAU * float(i) / 64.0
		points.append(center + Vector2(cos(angle) * size.x * 0.048, sin(angle) * size.y * 0.18))
	draw_polyline(points, color, 1.6, true)
	draw_line(center + Vector2(-12, -12), center + Vector2(11, 15), Color(FAINT.r, FAINT.g, FAINT.b, mirror_alpha), 1.0, true)


func _draw_empty_bubble() -> void:
	var alpha := maxf(empty_alpha, voice_alpha)
	if alpha <= 0.01:
		return
	var center := Vector2(size.x * 0.72, size.y * 0.38)
	var radius := size.y * (0.13 + sin(phase * 1.5) * 0.003)
	var color := Color(INK.r, INK.g, INK.b, alpha)
	draw_arc(center, radius, 0.0, TAU, 48, color, 1.5, true)
	if voice_alpha > 0.01:
		draw_circle(center + Vector2(-9, 0), 1.7, color)
		draw_circle(center, 1.7, color)
		draw_circle(center + Vector2(9, 0), 1.7, color)
