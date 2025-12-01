extends Node

# Comprehensive Audio Manager for Godot
# Handles 2D positioned sounds, global sounds, music, and multiple ambient layers

# Audio bus names (configure these in your Audio Bus Layout)
const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"
const AMBIENT_BUS = "Ambient"

# Audio player pools
var sfx_players_2d: Array[AudioStreamPlayer2D] = []
var sfx_players_global: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var ambient_layers: Dictionary = {} # layer_name: AudioStreamPlayer

# Settings
@export var max_2d_players: int = 20
@export var max_global_players: int = 10
@export var music_fade_duration: float = 1.5
@export var ambient_fade_duration: float = 2.0
@export var default_max_distance: float = 2000.0
@export var default_attenuation: float = 1.0

# State tracking
var current_music: AudioStream = null
var is_music_fading: bool = false

# Volume levels (0.0 to 1.0)
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 1.0
var ambient_volume: float = 0.5

func _ready() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	add_child(music_player)
	
	# Pre-create 2D audio players pool
	for i in max_2d_players:
		var player = AudioStreamPlayer2D.new()
		player.bus = SFX_BUS
		player.max_distance = default_max_distance
		player.attenuation = default_attenuation
		add_child(player)
		sfx_players_2d.append(player)
	
	# Pre-create global audio players pool
	for i in max_global_players:
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		sfx_players_global.append(player)
	
	# Apply initial volumes
	_update_volumes()

# ====================
# 2D POSITIONED SOUNDS
# ====================

func play_sound_2d(sound: AudioStream, position: Vector2, volume_db: float = 0.0, 
				   pitch_scale: float = 1.0, max_distance: float = -1.0) -> AudioStreamPlayer2D:
	"""Play a sound at a specific 2D position"""
	var player = _get_available_2d_player()
	if not player:
		push_warning("No available 2D audio players!")
		return null
	
	player.stream = sound
	player.position = position
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	
	if max_distance > 0:
		player.max_distance = max_distance
	else:
		player.max_distance = default_max_distance
	
	player.play()
	return player

func play_sound_2d_at_node(sound: AudioStream, node: Node2D, volume_db: float = 0.0, 
						   pitch_scale: float = 1.0) -> AudioStreamPlayer2D:
	"""Play a sound at a node's position"""
	return play_sound_2d(sound, node.global_position, volume_db, pitch_scale)

# ====================
# GLOBAL SOUNDS
# ====================

func play_sound(sound: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer:
	"""Play a sound globally (not positioned)"""
	var player = _get_available_global_player()
	if not player:
		push_warning("No available global audio players!")
		return null
	
	player.stream = sound
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
	return player

# ====================
# MUSIC
# ====================

func play_music(music: AudioStream, fade_in: bool = true) -> void:
	"""Play background music with optional fade in"""
	if current_music == music and music_player.playing:
		return
	
	current_music = music
	
	if fade_in and music_player.playing:
		await fade_out_music()
	
	music_player.stream = music
	music_player.volume_db = linear_to_db(0.0) if fade_in else linear_to_db(music_volume)
	music_player.play()
	
	if fade_in:
		await fade_in_music()

func stop_music(fade_out: bool = true) -> void:
	"""Stop the current music with optional fade out"""
	if not music_player.playing:
		return
	
	if fade_out:
		await fade_out_music()
	else:
		music_player.stop()
	
	current_music = null

func pause_music() -> void:
	"""Pause the current music"""
	music_player.stream_paused = true

func resume_music() -> void:
	"""Resume paused music"""
	music_player.stream_paused = false

func fade_in_music() -> void:
	"""Fade in the current music"""
	if is_music_fading:
		return
	
	is_music_fading = true
	var tween = create_tween()
	tween.tween_method(_set_music_volume_linear, 0.0, music_volume, music_fade_duration)
	await tween.finished
	is_music_fading = false

func fade_out_music() -> void:
	"""Fade out the current music"""
	if is_music_fading:
		return
	
	is_music_fading = true
	var current_vol = db_to_linear(music_player.volume_db)
	var tween = create_tween()
	tween.tween_method(_set_music_volume_linear, current_vol, 0.0, music_fade_duration)
	await tween.finished
	music_player.stop()
	is_music_fading = false

# ====================
# AMBIENT LAYERS
# ====================

func play_ambient_layer(layer_name: String, ambient: AudioStream, volume: float = 1.0, 
						fade_in: bool = true) -> void:
	"""Play a looping ambient sound on a specific layer"""
	# Create layer if it doesn't exist
	if not ambient_layers.has(layer_name):
		var player = AudioStreamPlayer.new()
		player.bus = AMBIENT_BUS
		add_child(player)
		ambient_layers[layer_name] = player
	
	var player: AudioStreamPlayer = ambient_layers[layer_name]
	
	# If same sound is already playing, just adjust volume
	if player.stream == ambient and player.playing:
		if fade_in:
			await fade_ambient_layer_to_volume(layer_name, volume)
		else:
			player.volume_db = linear_to_db(volume * ambient_volume)
		return
	
	# Stop current sound if playing
	if player.playing and fade_in:
		await fade_out_ambient_layer(layer_name)
	
	player.stream = ambient
	player.volume_db = linear_to_db(0.0) if fade_in else linear_to_db(volume * ambient_volume)
	player.play()
	
	if fade_in:
		await fade_ambient_layer_to_volume(layer_name, volume)

func stop_ambient_layer(layer_name: String, fade_out: bool = true) -> void:
	"""Stop a specific ambient layer"""
	if not ambient_layers.has(layer_name):
		return
	
	var player: AudioStreamPlayer = ambient_layers[layer_name]
	
	if not player.playing:
		return
	
	if fade_out:
		await fade_out_ambient_layer(layer_name)
	else:
		player.stop()

func pause_ambient_layer(layer_name: String) -> void:
	"""Pause a specific ambient layer"""
	if ambient_layers.has(layer_name):
		ambient_layers[layer_name].stream_paused = true

func resume_ambient_layer(layer_name: String) -> void:
	"""Resume a specific ambient layer"""
	if ambient_layers.has(layer_name):
		ambient_layers[layer_name].stream_paused = false

func set_ambient_layer_volume(layer_name: String, volume: float, fade: bool = true) -> void:
	"""Set the volume of a specific ambient layer (0.0 to 1.0)"""
	if not ambient_layers.has(layer_name):
		return
	
	volume = clamp(volume, 0.0, 1.0)
	
	if fade:
		await fade_ambient_layer_to_volume(layer_name, volume)
	else:
		ambient_layers[layer_name].volume_db = linear_to_db(volume * ambient_volume)

func fade_ambient_layer_to_volume(layer_name: String, target_volume: float) -> void:
	"""Fade an ambient layer to a specific volume"""
	if not ambient_layers.has(layer_name):
		return
	
	var player: AudioStreamPlayer = ambient_layers[layer_name]
	var current_vol = db_to_linear(player.volume_db) / ambient_volume
	target_volume = clamp(target_volume, 0.0, 1.0)
	
	var tween = create_tween()
	tween.tween_method(
		func(vol): player.volume_db = linear_to_db(vol * ambient_volume),
		current_vol,
		target_volume,
		ambient_fade_duration
	)
	await tween.finished

func fade_out_ambient_layer(layer_name: String) -> void:
	"""Fade out a specific ambient layer"""
	if not ambient_layers.has(layer_name):
		return
	
	var player: AudioStreamPlayer = ambient_layers[layer_name]
	var current_vol = db_to_linear(player.volume_db) / ambient_volume
	
	var tween = create_tween()
	tween.tween_method(
		func(vol): player.volume_db = linear_to_db(vol * ambient_volume),
		current_vol,
		0.0,
		ambient_fade_duration
	)
	await tween.finished
	player.stop()

func stop_all_ambient_layers(fade_out: bool = true) -> void:
	"""Stop all ambient layers"""
	if fade_out:
		# Fade out all layers simultaneously
		var tweens: Array = []
		for layer_name in ambient_layers.keys():
			var player: AudioStreamPlayer = ambient_layers[layer_name]
			if player.playing:
				var current_vol = db_to_linear(player.volume_db) / ambient_volume
				var tween = create_tween()
				tween.tween_method(
					func(vol): player.volume_db = linear_to_db(vol * ambient_volume),
					current_vol,
					0.0,
					ambient_fade_duration
				)
				tweens.append(tween)
		
		# Wait for all tweens to complete
		for tween in tweens:
			await tween.finished
		
		# Stop all players
		for layer_name in ambient_layers.keys():
			ambient_layers[layer_name].stop()
	else:
		# Stop immediately
		for layer_name in ambient_layers.keys():
			ambient_layers[layer_name].stop()

func get_active_ambient_layers() -> Array:
	"""Get list of currently playing ambient layer names"""
	var active: Array = []
	for layer_name in ambient_layers.keys():
		if ambient_layers[layer_name].playing:
			active.append(layer_name)
	return active

func is_ambient_layer_playing(layer_name: String) -> bool:
	"""Check if a specific ambient layer is playing"""
	if not ambient_layers.has(layer_name):
		return false
	return ambient_layers[layer_name].playing

# ====================
# VOLUME CONTROL
# ====================

func set_master_volume(volume: float) -> void:
	"""Set master volume (0.0 to 1.0)"""
	master_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_music_volume(volume: float) -> void:
	"""Set music volume (0.0 to 1.0)"""
	music_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(volume: float) -> void:
	"""Set SFX volume (0.0 to 1.0)"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_ambient_volume(volume: float) -> void:
	"""Set ambient volume (0.0 to 1.0) - affects all layers"""
	ambient_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

# ====================
# HELPER FUNCTIONS
# ====================

func _get_available_2d_player() -> AudioStreamPlayer2D:
	"""Get an available 2D audio player from the pool"""
	for player in sfx_players_2d:
		if not player.playing:
			return player
	return null

func _get_available_global_player() -> AudioStreamPlayer:
	"""Get an available global audio player from the pool"""
	for player in sfx_players_global:
		if not player.playing:
			return player
	return null

func _set_music_volume_linear(vol: float) -> void:
	"""Helper to set music volume in linear scale"""
	music_player.volume_db = linear_to_db(vol)

func _update_volumes() -> void:
	"""Update all audio bus volumes"""
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), linear_to_db(sfx_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AMBIENT_BUS), linear_to_db(ambient_volume))

func stop_all_sounds() -> void:
	"""Stop all currently playing sounds"""
	for player in sfx_players_2d:
		if player.playing:
			player.stop()
	
	for player in sfx_players_global:
		if player.playing:
			player.stop()

func get_active_sounds_count() -> Dictionary:
	"""Get count of active sounds"""
	var count_2d = 0
	var count_global = 0
	
	for player in sfx_players_2d:
		if player.playing:
			count_2d += 1
	
	for player in sfx_players_global:
		if player.playing:
			count_global += 1
	
	return {
		"2d": count_2d,
		"global": count_global,
		"music": music_player.playing,
		"ambient_layers": get_active_ambient_layers().size()
	}
