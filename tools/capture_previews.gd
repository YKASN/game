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
	await create_timer(0.4).timeout
	var story: Control = main.active_screen
	await _save("res://docs/opening-preview.png")
	await _move_to(story, "lamp")
	await create_timer(1.2).timeout
	await _save("res://docs/room-preview.png")
	await _move_to(story, "window")
	await create_timer(0.9).timeout
	await _save("res://docs/absence-preview.png")
	await _move_to(story, "voice_breath")
	await create_timer(0.9).timeout
	await _save("res://docs/dialogue-preview.png")
	story.runner.advance()
	await create_timer(0.3).timeout
	await _save("res://docs/choice-preview.png")
	story.get_node("Layout/Column/ChoiceBar/ChoiceLeft").emit_signal("pressed")
	await create_timer(0.7).timeout
	await _save("res://docs/selected-preview.png")
	story.get_node("Layout/Column/StoryPanel/StoryFooter/AdvanceButton").emit_signal("pressed")
	await create_timer(0.4).timeout
	await _move_to(story, "you")
	story.runner.advance()
	await create_timer(1.0).timeout
	await _save("res://docs/ending-preview.png")
	root.remove_child(main)
	main.queue_free()
	await process_frame
	quit()


func _move_to(story: Control, target_id: String) -> void:
	for i in range(50):
		if story.runner.current_step_id() == target_id:
			return
		story.runner.advance()
		await process_frame


func _save(path: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image != null:
		image.save_png(path)
