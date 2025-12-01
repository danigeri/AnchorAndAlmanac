extends Control

@onready var pointer: TextureRect = $Pointer
@onready var strength_label: Label = $Panel/StrengthLabel

@onready var wind_change_sound_player: AudioStreamPlayer = $WindChangeSoundPlayer

const wind_change_sounds = {
	1: preload("uid://bjmihd3qjm4vd"),
	2: preload("uid://d1mn1g1sw67fj"),
	3: preload("uid://dwfc418q6i1iw"),
	4: preload("uid://ck3se43bxyxwg")
}


func _ready() -> void:
	Wind.update_wind.connect(_on_wind_update_wind)


func _on_wind_update_wind(dir: Variant, strength: Variant) -> void:
	if pointer:
		pointer.rotation = -dir
		strength_label.text = "%s" % strength
		
		wind_change_sound_player.stream = (wind_change_sounds[randi_range(1, 4)])
		wind_change_sound_player.play()
