extends Control

@onready var pointer: TextureRect = $Pointer
@onready var strength_label: Label = $Panel/StrengthLabel


func _ready() -> void:
	Wind.update_wind.connect(_on_wind_update_wind)


func _on_wind_update_wind(dir: Variant, strength: Variant) -> void:
	if pointer:
		pointer.rotation = dir.angle()
		strength_label.text = "%s" % strength
