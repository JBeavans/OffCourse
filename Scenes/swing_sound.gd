extends AudioStreamPlayer2D

var playback # Will hold the AudioStreamGeneratorPlayback.
@onready var sample_hz = self.stream.mix_rate
#@onready var swing_sound: AudioStreamPlayer2D = $"."
var pulse_hz:= 220.0 # The frequency of the sound wave.
var phase = 0.0
var soundSwitch:= false

func _ready():
	play()
	playback = get_stream_playback()
	#fill_buffer()

func fill_buffer():
	
	var frames_available = playback.get_frames_available()
	for i in range(frames_available):
		var increment = pulse_hz / sample_hz
		playback.push_frame(Vector2.ONE * sin(phase * TAU))
		phase = fmod(phase + increment, 1.0)


func _on_club_acc_changed(accleration: int) -> void:
	pulse_hz += accleration/100
	if soundSwitch:
		fill_buffer()


func _on_club_swing_toggled() -> void:
	soundSwitch = !soundSwitch
	#fill_buffer()
