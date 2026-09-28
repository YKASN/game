extends Control

const INK := Color(0.96, 0.96, 0.96, 1.0)
const DIM := Color(0.68, 0.68, 0.68, 0.72)
const FAINT := Color(0.5, 0.5, 0.5, 0.42)

var clock_visible := false
var phase := 0.0


func _process(delta: float) -> void:
	phase += delta
	queue_redraw()


func set_clock_visible(value: bool) -> void:
	clock_visible = value
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var left := size.x * 0.20
	var right := size.x * 0.80
	var ceiling := size.y * 0.12
	var floor_y := size.y * 0.78
	var sway := sin(phase * 1.3) * 1.2
	# A few imperfect strokes keep the room readable against pure black.
	draw_line(Vector2(left, floor_y), Vector2(right, floor_y + sway), INK, 1.7, true)
	draw_line(Vector2(left, ceiling), Vector2(left + sway, floor_y), DIM, 1.5, true)
	draw_line(Vector2(left, ceiling), Vector2(right, ceiling + sway), FAINT, 1.3, true)
	draw_line(Vector2(right, ceiling), Vector2(right, floor_y), DIM, 1.5, true)
	var door_left := size.x * 0.31
	var door_right := size.x * 0.40
	var door_top := size.y * 0.31
	draw_line(Vector2(door_left, floor_y), Vector2(door_left, door_top), INK, 1.8, true)
	draw_line(Vector2(door_left, door_top), Vector2(door_right, door_top + sway), INK, 1.8, true)
	draw_line(Vector2(door_right, door_top + sway), Vector2(door_right, floor_y), INK, 1.8, true)
	draw_circle(Vector2(door_right - 13, floor_y - 44), 2.3, INK)
	# A hanging light gently moves while the narration is still.
	var lamp_x := size.x * 0.55 + sin(phase * 0.9) * 2.0
	draw_line(Vector2(size.x * 0.55, ceiling), Vector2(lamp_x, size.y * 0.32), FAINT, 1.2, true)
	draw_arc(Vector2(lamp_x, size.y * 0.34), size.y * 0.045, 0.0, PI, 20, DIM, 1.6, true)
	draw_line(Vector2(left + 9, floor_y + 18), Vector2(right - 10, floor_y + 18), FAINT, 1.0, true)
	if clock_visible:
		var center := Vector2(size.x * 0.69, size.y * 0.40)
		var radius := minf(size.x, size.y) * 0.13
		draw_arc(center, radius, 0.0, TAU, 72, INK, 2.0, true)
		draw_line(center, center + Vector2(0, -radius * 0.58), INK, 1.7, true)
		draw_line(center, center + Vector2(radius * 0.47, sin(phase * 1.5) * 2.0), INK, 1.7, true)
		draw_circle(center, 2.5, INK)
