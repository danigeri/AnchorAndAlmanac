extends Control

var starting_dialog = preload("res://StartingPopup/0_Fisherman_22sec.mp3")

@onready var texture: TextureRect = $TextureRect


func start() -> void:
	visible = true
	get_tree().paused = true
	texture.modulate.a = 0
	fade_in()


func fade_in():
	show()
	var tween = create_tween()
	tween.tween_property(texture, "modulate:a", 1.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	play_audio()


func play_audio():
	var audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = starting_dialog
	audio_stream_player.bus = "ShipLogSounds"
	audio_stream_player.play()
	Globals.present_opening_subtitle()
	var length = audio_stream_player.stream.get_length()
	await get_tree().create_timer(length).timeout
	audio_stream_player.queue_free()
	fade_out()


func fade_out():
	var tween = create_tween()
	tween.tween_property(texture, "modulate:a", 0.0, 3.0)
	await tween.finished
	get_tree().paused = false
	queue_free()
