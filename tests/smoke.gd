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
	if not _expect(main.active_screen.get_node("Layout/Column/TitleBlock/Title").text == "第七次醒来", "Menu title should match the demo"):
		return
	main.active_screen.get_node("Layout/Column/Footer/StartBlock/StartButton").emit_signal("pressed")
	await process_frame
	var screen: Control = main.active_screen
	var advance: Button = screen.get_node("Layout/Column/StoryPanel/StoryFooter/AdvanceButton")
	var room: Control = screen.get_node("Layout/Column/SceneArea/RoomArt")
	if not _expect(screen.current_line.text == "你醒了。" and room.modulate.a == 0.0, "Opening should start with text on black"):
		return
	if not _expect(screen.get_node("Presentation/BreathSound").playing, "Breathing should begin in the opening"):
		return
	advance.emit_signal("pressed")
	advance.emit_signal("pressed")
	if not _expect(screen.runner.current_step_id() == "seventh", "Clicking should advance to the second line"):
		return
	advance.emit_signal("pressed")
	if not _expect(screen.pause_locked, "A scripted pause should hold the next line"):
		return
	advance.emit_signal("pressed")
	if not _expect(screen.runner.current_step_id() == "seventh", "Clicking during a pause should not advance"):
		return
	await create_timer(0.72).timeout
	advance.emit_signal("pressed")
	if not _expect(screen.runner.current_step_id() == "remember", "Reading should resume after the pause"):
		return
	if not _expect(_move_to(screen, "window"), "Window event should be reachable"):
		return
	await create_timer(1.2).timeout
	if not _expect(float(room.get("window_alpha")) < 0.1 and room.modulate.a > 0.9, "Window should fade after the room appears"):
		return
	if not _expect(_move_to(screen, "voice_breath"), "Dialogue should be reachable without object interaction"):
		return
	screen.runner.advance()
	var choice_bar: HBoxContainer = screen.get_node("Layout/Column/ChoiceBar")
	if not _expect(choice_bar.visible and screen.runner.awaiting_choice, "Two dialogue options should appear"):
		return
	choice_bar.get_node("ChoiceLeft").emit_signal("pressed")
	await create_timer(0.55).timeout
	var stage: Control = screen.get_node("Layout/Column/ChoiceStage")
	if not _expect(stage.visible and not choice_bar.visible, "Selected bubble should move to the middle"):
		return
	var bubble: Button = stage.get_node("SelectedBubble")
	bubble.emit_signal("pressed")
	var editor: LineEdit = bubble.get_node("ChoiceEditor")
	editor.text = "我愿意相信你。"
	editor.emit_signal("text_submitted", editor.text)
	if not _expect(screen.selected_line.text == "你：我愿意相信你。", "Edited text should update the story"):
		return
	advance.emit_signal("pressed")
	await create_timer(0.35).timeout
	if not _expect(screen.runner.current_step_id() == "trust_reply", "Trust should lead to its one changed line"):
		return
	if not _expect(_move_to(screen, "you"), "Both paths should reach the shared ending"):
		return
	screen.runner.advance()
	if not _expect(screen.get_node("Layout/Column/EndPanel").visible and screen.metrics_saved, "Ending should appear and record the session"):
		return
	screen.get_node("Layout/Column/EndPanel/ReplayButton").emit_signal("pressed")
	await process_frame
	screen = main.active_screen
	if not _expect(screen.runner.current_step_id() == "wake", "Replay should start from the opening"):
		return
	if not _expect(_move_to(screen, "voice_breath"), "Replay should reach the choice again"):
		return
	screen.runner.advance()
	screen.get_node("Layout/Column/ChoiceBar/ChoiceRight").emit_signal("pressed")
	await create_timer(0.55).timeout
	advance = screen.get_node("Layout/Column/StoryPanel/StoryFooter/AdvanceButton")
	advance.emit_signal("pressed")
	await create_timer(0.35).timeout
	if not _expect(screen.runner.current_step_id() == "doubt_reply", "Doubt should change exactly the next line"):
		return
	screen.get_node("Layout/Column/Header/BackButton").emit_signal("pressed")
	await process_frame
	if not _expect(main.active_screen.name == "Menu", "Return should open the menu"):
		return
	print("SMOKE PASS: opening -> pauses -> visual cues -> both choices -> shared ending -> replay")
	quit(0)


func _move_to(screen: Control, target_id: String) -> bool:
	for i in range(50):
		if screen.runner.current_step_id() == target_id:
			return true
		screen.runner.advance()
	return false


func _expect(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("SMOKE FAIL: " + message)
	quit(1)
	return false
