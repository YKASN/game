extends Node2D

const INK := Color(0.14, 0.14, 0.14, 0.18)
const FAINT := Color(0.14, 0.14, 0.14, 0.08)


func _ready() -> void:
	get_viewport().size_changed.connect(queue_redraw)


func _draw() -> void:
	var size := get_viewport_rect().size
	var center := Vector2(size.x * 0.75, size.y * 0.49)
	var radius := minf(size.x * 0.21, size.y * 0.36)
	draw_arc(center, radius, -PI * 0.88, PI * 0.53, 100, INK, 1.5, true)
	draw_arc(center + Vector2(4, 2), radius * 0.91, -PI * 0.48, PI * 0.82, 100, FAINT, 1.0, true)
	draw_line(center + Vector2(-radius * 0.15, -radius * 0.74), center + Vector2(radius * 0.22, radius * 0.33), INK, 1.0, true)
	draw_line(center + Vector2(radius * 0.22, radius * 0.33), center + Vector2(radius * 0.47, radius * 0.37), INK, 1.0, true)
	draw_line(Vector2(size.x * 0.57, size.y * 0.14), Vector2(size.x * 0.91, size.y * 0.14), FAINT, 1.0, true)
	draw_line(Vector2(size.x * 0.57, size.y * 0.83), Vector2(size.x * 0.91, size.y * 0.83), FAINT, 1.0, true)
