extends Node

const PAPER_STREAM: AudioStream = preload("res://assets/audio/paper_click.wav")
const TICK_STREAM: AudioStreamWAV = preload("res://assets/audio/clock_tick.wav")
const PAPER := Color(0.953, 0.949, 0.933, 1)
const DARK := Color(0.085, 0.085, 0.085, 1)

@onready var background: ColorRect = $"../Background"
@onready var room_art: Node2D = $"../RoomArt"
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
	match cue:
		"dark":
			background.color = DARK
			room_art.modulate.a = 0.0
		"reveal_room":
			var tween := create_tween().set_parallel(true)
			tween.tween_property(background, "color", PAPER, 0.6)
			tween.tween_property(room_art, "modulate:a", 1.0, 0.7)
		"start_tick":
			room_art.call("set_clock_visible", true)
			tick_sound.play()
		"stop_tick":
			tick_sound.stop()
			room_art.call("set_clock_visible", false)
