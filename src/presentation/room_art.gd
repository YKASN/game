extends Node2D

const INK := Color(0.16, 0.16, 0.16, 1)
const LIGHT := Color(0.16, 0.16, 0.16, 0.34)
const PALE := Color(0.16, 0.16, 0.16, 0.12)

var clock_visible := false


func _ready() -> void:
	get_viewport().size_changed.connect(queue_redraw)


func set_clock_visible(value: bool) -> void:
	clock_visible = value
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	var floor_y := size.y * 0.63
	var left := size.x * 0.18
	var right := size.x * 0.87
	draw_line(Vector2(left, floor_y), Vector2(right, floor_y), INK, 1.4, true)
	draw_line(Vector2(left, floor_y), Vector2(left, size.y * 0.19), LIGHT, 1.2, true)
	draw_line(Vector2(left, size.y * 0.19), Vector2(right, size.y * 0.19), PALE, 1.0, true)
	draw_line(Vector2(right, size.y * 0.19), Vector2(right, floor_y), LIGHT, 1.0, true)
	var door_x := size.x * 0.31
	draw_rect(Rect2(door_x, size.y * 0.31, size.x * 0.13, floor_y - size.y * 0.31), Color.TRANSPARENT, false, 1.4, true)
	draw_circle(Vector2(door_x + size.x * 0.11, size.y * 0.51), 2.4, LIGHT)
	for i in range(2):
		var y := floor_y + 14.0 + i * 18.0
		draw_line(Vector2(left + i * 8.0, y), Vector2(right - i * 15.0, y), PALE, 0.8, true)
	if clock_visible:
		var c := Vector2(size.x * 0.68, size.y * 0.34)
		var r := minf(size.x, size.y) * 0.085
		draw_arc(c, r, 0, TAU, 90, INK, 1.4, true)
		draw_line(c, c + Vector2(0, -r * 0.64), INK, 1.5, true)
		draw_line(c, c + Vector2(r * 0.43, r * 0.12), INK, 1.5, true)
		draw_circle(c, 2.4, INK)
