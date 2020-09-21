extends Panel

const SettingsConfig = preload("SettingsConfig.gd")
var settings_config : SettingsConfig
export var default_settings : Resource # A SettingsConfig which we set up in editor

signal back
signal apply

var music_vol_min : float

# transfer data from settings panel controls to settings_config
func panel_knobs_to_resource():
	settings_config.fullscreen = $VBoxContainer/Body/Fullscreen/Checkbox.pressed
	settings_config.music_vol = $VBoxContainer/Body/MusicVolume/MarginContainer/HSlider.value


# transfer data from settings_config to settings panel controls
func resource_to_panel_knobs():
	$VBoxContainer/Body/Fullscreen/Checkbox.pressed = settings_config.fullscreen
	$VBoxContainer/Body/MusicVolume/MarginContainer/HSlider.value = settings_config.music_vol


func _init():
	settings_config = ResourceLoader.load("settings.tres","",true) # no_cache = true

func _ready():
	resource_to_panel_knobs()
	music_vol_min = $VBoxContainer/Body/MusicVolume/MarginContainer/HSlider.min_value

func get_example_setting():
	return settings_config.an_example_setting

func _on_BackButton_pressed():
	emit_signal("back")


func _on_ApplyButton_pressed():
	panel_knobs_to_resource()
	apply_settings(settings_config)


func _on_DefaultsButton_pressed():
	apply_settings(default_settings)


func apply_settings(s : SettingsConfig):
	var error : int = ResourceSaver.save("settings.tres",s)
	if error != OK:
		print("There was an error saving settings.")
	emit_signal("apply")
