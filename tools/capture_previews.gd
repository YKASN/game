extends SceneTree
const MAIN = preload("res://scenes/app/main.tscn")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var main = MAIN.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame
    var image = root.get_texture().get_image()
    if image == null:
        quit(1)
        return
    image.save_png("res://docs/menu-preview.png")
    main.active_screen.get_node("Layout/Column/Footer/StartBlock/StartButton").emit_signal("pressed")
    await process_frame
    var story = main.active_screen
    story.get_node("Layout/Column/StoryBlock/TextButton").emit_signal("pressed")
    await create_timer(1.0).timeout
    image = root.get_texture().get_image()
    image.save_png("res://docs/room-preview.png")
    story.get_node("Layout/Column/StoryBlock/TextButton").emit_signal("pressed")
    await create_timer(0.6).timeout
    var tick = story.get_node("Presentation/TickSound")
    image = root.get_texture().get_image()
    image.save_png("res://docs/clock-preview.png")
    tick.stop()
    root.remove_child(main)
    main.queue_free()
    await process_frame
    quit()
