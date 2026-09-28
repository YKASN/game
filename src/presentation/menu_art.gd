extends Node2D

const INK := Color(0.96, 0.96, 0.96, 0.82)
const FAINT := Color(0.96, 0.96, 0.96, 0.28)

var phase := 0.0


func _process(delta: float) -> void:
	phase += delta
	queue_redraw()


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	var left := viewport_size.x * 0.60
	var right := viewport_size.x * 0.90
	var top := viewport_size.y * 0.17
	var bottom := viewport_size.y * 0.76
	draw_line(Vector2(left, top), Vector2(right, top), FAINT, 1.2, true)
	draw_line(Vector2(left, bottom), Vector2(right, bottom), INK, 1.3, true)
	draw_line(Vector2(right, top), Vector2(right, bottom), FAINT, 1.2, true)
	var lamp_top := Vector2(viewport_size.x * 0.75, top)
	var lamp_center := Vector2(lamp_top.x + sin(phase * 0.9) * 2.0, viewport_size.y * 0.39)
	draw_line(lamp_top, lamp_center, INK, 1.4, true)
	draw_arc(lamp_center, viewport_size.y * 0.095, 0.0, PI, 42, INK, 1.8, true)
	draw_circle(lamp_center + Vector2(0, 6), 3.0, INK)
	for i in range(7):
		var x := left + 28.0 + i * 44.0
		var ink := INK if i == 6 else FAINT
		draw_line(Vector2(x, bottom + 22), Vector2(x + 16, bottom + 22), ink, 1.6, true)
