extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/app/main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	if not _expect(main.active_screen.name == "Menu", "The game should start at the menu"):
		return
	main.active_screen.get_node("Layout/Column/Footer/StartBlock/StartButton").emit_signal("pressed")
	await process_frame
	if not _expect(main.active_screen.name == "Narrative", "Start should open the narrative screen"):
		return
	var screen: Control = main.active_screen
	var text_button: Button = screen.get_node("Layout/Column/StoryBlock/TextButton")
	if not _expect(text_button.text == "你醒了。", "The opening line should load from content"):
		return
	for expected in ["房间里很安静。", "除了钟。", "但这里没有钟。", "你听见的，究竟是什么？"]:
		text_button.emit_signal("pressed")
		await create_timer(0.8).timeout
		if not _expect(text_button.text == expected, "Expected story line: " + expected):
			return
		if expected == "除了钟。" and not _expect(screen.get_node("RoomArt").clock_visible, "Clock cue should show the clock"):
			return
		if expected == "除了钟。" and not _expect(screen.get_node("Presentation/TickSound").playing, "Clock cue should keep the tick playing"):
			return
		if expected == "但这里没有钟。" and not _expect(not screen.get_node("RoomArt").clock_visible, "Clock cue should hide the clock"):
			return
		if expected == "但这里没有钟。" and not _expect(not screen.get_node("Presentation/TickSound").playing, "Clock cue should stop the tick"):
			return
	text_button.emit_signal("pressed")
	await create_timer(0.3).timeout
	if not _expect(screen.get_node("Layout/Column/StoryBlock/EndBlock").visible, "The end state should appear"):
		return
	screen.get_node("Layout/Column/StoryBlock/EndBlock/ReturnButton").emit_signal("pressed")
	await process_frame
	if not _expect(main.active_screen.name == "Menu", "Return should open the menu"):
		return
	print("SMOKE PASS: menu -> story -> cues -> ending -> menu")
	quit(0)


func _expect(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("SMOKE FAIL: " + message)
	quit(1)
	return false
