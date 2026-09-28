extends Node

const PAPER_STREAM: AudioStream = preload("res://assets/audio/paper_click.wav")
const TICK_STREAM: AudioStreamWAV = preload("res://assets/audio/clock_tick.wav")
const BLACK := Color(0, 0, 0, 1)

@onready var background: ColorRect = $"../Background"
@onready var room_art: Control = $"../Layout/Column/SceneArea/RoomArt"
@onready var paper_sound: AudioStreamPlayer = $PaperSound
@onready var tick_sound: AudioStreamPlayer = $TickSound


func _ready() -> void:
	paper_sound.stream = PAPER_STREAM
	var tick_stream := TICK_STREAM.duplicate() as AudioStreamWAV
	tick_stream.loop_begin = 0
	tick_stream.loop_end = int(tick_stream.get_length() * tick_stream.mix_rate)
	tick_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	tick_sound.stream = tick_stream


func play_paper() -> void:
	paper_sound.play()


func apply_cue(cue: String) -> void:
	background.color = BLACK
	match cue:
		"dark":
			room_art.modulate.a = 0.55
		"reveal_room":
			create_tween().tween_property(room_art, "modulate:a", 1.0, 0.7)
		"start_tick":
			room_art.call("set_clock_visible", true)
			tick_sound.play()
		"stop_tick":
			tick_sound.stop()
			room_art.call("set_clock_visible", false)
