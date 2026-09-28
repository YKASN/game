extends SceneTree

const MAIN: PackedScene = preload("res://scenes/app/main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN.instantiate()
	root.add_child(main)
	await create_timer(0.3).timeout
	await _save("res://docs/menu-preview.png")
	main.active_screen.get_node("Layout/Column/Footer/StartBlock/StartButton").emit_signal("pressed")
	await create_timer(0.3).timeout
	var story: Control = main.active_screen
	var advance: Button = story.get_node("Layout/Column/StoryPanel/StoryFooter/AdvanceButton")
	_advance(advance)
	await create_timer(0.8).timeout
	await _save("res://docs/room-preview.png")
	_advance(advance)
	await create_timer(0.8).timeout
	await _save("res://docs/clock-preview.png")
	for i in range(3):
		_advance(advance)
		await create_timer(0.65).timeout
	await create_timer(1.0).timeout
	await _save("res://docs/choice-preview.png")
	story.get_node("Layout/Column/ChoiceBar/ChoiceLeft").emit_signal("pressed")
	await create_timer(0.7).timeout
	await _save("res://docs/selected-preview.png")
	story.get_node("Presentation/TickSound").stop()
	root.remove_child(main)
	main.queue_free()
	await process_frame
	quit()


func _advance(button: Button) -> void:
	button.emit_signal("pressed")
	button.emit_signal("pressed")


func _save(path: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image != null:
		image.save_png(path)
