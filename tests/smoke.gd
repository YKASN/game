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
	if not _expect(main.active_screen.get_node("Background").color == Color.BLACK, "Menu should be black"):
		return
	main.active_screen.get_node("Layout/Column/Footer/StartBlock/StartButton").emit_signal("pressed")
	await process_frame
	if not _expect(main.active_screen.name == "Narrative", "Start should open the narrative screen"):
		return
	var screen: Control = main.active_screen
	var advance: Button = screen.get_node("Layout/Column/StoryPanel/StoryFooter/AdvanceButton")
	if not _expect(screen.get_node("Background").color == Color.BLACK, "Narrative should be black"):
		return
	if not _expect(screen.current_line.text == "你醒了。", "Opening line should load"):
		return
	for expected in ["房间里很安静。", "除了钟。", "但这里没有钟。", "你听见的，究竟是什么？"]:
		advance.emit_signal("pressed")
		advance.emit_signal("pressed")
		await process_frame
		if not _expect(screen.current_line.text == expected, "Expected story line: " + expected):
			return
		if expected == "除了钟。" and not _expect(screen.get_node("Layout/Column/SceneArea/RoomArt").clock_visible, "Clock should appear"):
			return
		if expected == "除了钟。" and not _expect(screen.get_node("Presentation/TickSound").playing, "Tick should play"):
			return
		if expected == "但这里没有钟。" and not _expect(not screen.get_node("Layout/Column/SceneArea/RoomArt").clock_visible, "Clock should disappear"):
			return
		if expected == "但这里没有钟。" and not _expect(not screen.get_node("Presentation/TickSound").playing, "Tick should stop"):
			return
	advance.emit_signal("pressed")
	advance.emit_signal("pressed")
	await process_frame
	var choice_bar: HBoxContainer = screen.get_node("Layout/Column/ChoiceBar")
	if not _expect(choice_bar.visible, "Dialogue options should appear"):
		return
	choice_bar.get_node("ChoiceLeft").emit_signal("pressed")
	await create_timer(0.6).timeout
	var stage: Control = screen.get_node("Layout/Column/ChoiceStage")
	if not _expect(stage.visible and not choice_bar.visible, "Selected bubble should move into the middle"):
		return
	var bubble: Button = stage.get_node("SelectedBubble")
	bubble.emit_signal("pressed")
	var editor: LineEdit = bubble.get_node("ChoiceEditor")
	if not _expect(editor.visible, "The selected bubble should be editable"):
		return
	editor.text = "我听见了风。"
	editor.emit_signal("text_submitted", editor.text)
	if not _expect(bubble.text == "我听见了风。" and screen.selected_line.text == "你：我听见了风。", "Edited dialogue should appear"):
		return
	screen.get_node("Layout/Column/Header/BackButton").emit_signal("pressed")
	await process_frame
	if not _expect(main.active_screen.name == "Menu", "Return should open the menu"):
		return
	print("SMOKE PASS: menu -> story -> cues -> choices -> edit -> menu")
	quit(0)


func _expect(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("SMOKE FAIL: " + message)
	quit(1)
	return false
