extends Node2D

## todo update mp3 file names if needed
var checkpoint_stories = {
	0: preload("uid://bu80jpfof1bn0"),
	1: preload("uid://clein2ho2iawr"),
	2: preload("uid://dhlxq4yijlgtf"),
	3: preload("uid://be5eblpb72gno"),
	4: preload("uid://b0g84o8m0uge6"),
	5: preload("uid://ddohwvbw7m0rs"),
	6: preload("uid://dwdc6pyk1e4pr"),
	7: preload("uid://dch7jucqu0q2m")
}

# Signal to emit when the last checkpoint audio finishes
signal last_audio_finished

func _ready() -> void:
	## set to always so ship log sound doesn't stop on pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	Globals.checkpoint_collected.connect(on_play_checkpoint_story)


func on_play_checkpoint_story(checkpoint_number: int) -> void:
	if checkpoint_stories.has(checkpoint_number):
		var audio_stream_player = AudioStreamPlayer.new()
		add_child(audio_stream_player)
		audio_stream_player.stream = checkpoint_stories[checkpoint_number]
		audio_stream_player.bus = "ShipLogSounds"
		audio_stream_player.play()
		
		var length = audio_stream_player.stream.get_length()
		await get_tree().create_timer(length).timeout
		
		audio_stream_player.queue_free()
		
		# Emit signal if this was the last checkpoint
		if checkpoint_number == checkpoint_stories.size() - 1:
			Globals.last_audio_finsihed.emit()
