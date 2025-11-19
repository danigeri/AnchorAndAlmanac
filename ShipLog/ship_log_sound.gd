extends Node2D

## todo update mp3 file names if needed
var checkpoint_stories = {
	0: preload("res://ShipLog/1_cp_story.mp3"),
	1: preload("res://ShipLog/2_cp_story.mp3"),
	2: preload("res://ShipLog/3_cp_story.mp3"),
	3: preload("res://ShipLog/4_cp_story.mp3"),
	4: preload("res://ShipLog/5_cp_story.mp3"),
	5: preload("res://ShipLog/6_cp_story.mp3")
}


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
