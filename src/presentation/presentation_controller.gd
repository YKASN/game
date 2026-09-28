extends Node

const PAPER_STREAM: AudioStream = preload("res://assets/audio/paper_click.wav")
const BREATH_STREAM: AudioStreamWAV = preload("res://assets/audio/breath_loop.wav")
const BRUSH_STREAM: AudioStream = preload("res://assets/audio/brush_stroke.wav")
const BLACK := Color(0, 0, 0, 1)

@onready var background: ColorRect = $"../Background"
@onready var room_art: Control = $"../Layout/Column/SceneArea/RoomArt"
@onready var paper_sound: AudioStreamPlayer = $PaperSound
@onready var breath_sound: AudioStreamPlayer = $BreathSound
@onready var brush_sound: AudioStreamPlayer = $BrushSound


func _ready() -> void:
	paper_sound.stream = PAPER_STREAM
	brush_sound.stream = BRUSH_STREAM
	var breath_stream := BREATH_STREAM.duplicate() as AudioStreamWAV
	breath_stream.loop_begin = 0
	breath_stream.loop_end = int(breath_stream.get_length() * breath_stream.mix_rate)
	breath_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	breath_sound.stream = breath_stream
	room_art.modulate.a = 0.0


func play_paper() -> void:
	paper_sound.play()


func stop_ambient() -> void:
	breath_sound.stop()


func apply_cue(cue: String) -> void:
	background.color = BLACK
	match cue:
		"black":
			room_art.modulate.a = 0.0
			room_art.set("window_alpha", 1.0)
			room_art.set("table_alpha", 1.0)
			room_art.set("mirror_alpha", 1.0)
			room_art.set("empty_alpha", 0.0)
			room_art.set("voice_alpha", 0.0)
			room_art.set("lamp_alpha", 1.0)
			if not breath_sound.playing:
				breath_sound.play()
		"reveal_room":
			brush_sound.play()
			create_tween().tween_property(room_art, "modulate:a", 1.0, 1.1)
		"remove_window":
			brush_sound.play()
			create_tween().tween_property(room_art, "window_alpha", 0.0, 0.85)
		"remove_table":
			brush_sound.play()
			create_tween().tween_property(room_art, "table_alpha", 0.0, 0.85)
		"remove_mirror":
			brush_sound.play()
			create_tween().tween_property(room_art, "mirror_alpha", 0.0, 0.85)
		"empty_bubble":
			brush_sound.play()
			create_tween().tween_property(room_art, "empty_alpha", 1.0, 0.5)
		"voice":
			brush_sound.play()
			var tween := create_tween().set_parallel(true)
			tween.tween_property(room_art, "empty_alpha", 0.0, 0.45)
			tween.tween_property(room_art, "voice_alpha", 1.0, 0.45)
		"lights_out":
			brush_sound.play()
			var tween := create_tween().set_parallel(true)
			tween.tween_property(room_art, "lamp_alpha", 0.0, 0.65)
			tween.tween_property(room_art, "modulate:a", 0.18, 0.85)
		"vanish":
			create_tween().tween_property(room_art, "modulate:a", 0.0, 0.75)
