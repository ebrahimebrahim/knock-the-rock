extends Panel

const SettingsConfig = preload("SettingsConfig.gd")
var settings_config : SettingsConfig
export var default_settings : Resource # A SettingsConfig which we set up in editor

signal back
signal apply

var music_vol_min : float


onready var fullscreen_widget = $VBoxContainer/Body/Fullscreen/MarginContainer/Checkbox
onready var music_vol_widget = $VBoxContainer/Body/MusicVolume/MarginContainer/HSlider
onready var gravity_widget = $VBoxContainer/Body/Gravity/MarginContainer/HSlider
onready var challenge_mode_rocks_widget = $VBoxContainer/Body/TotalRocksGiven/MarginContainer/SpinBox
onready var corner_menu_hidden_by_default_widget = $VBoxContainer/Body/CornerMenuHidden/MarginContainer/CheckButton
onready var language_widget = $VBoxContainer/Body/Language/MarginContainer/OptionButton

# transfer data from settings panel controls to settings_config
func panel_knobs_to_resource():
	settings_config.fullscreen = fullscreen_widget.pressed
	settings_config.music_vol = music_vol_widget.value
	settings_config.gravity = gravity_widget.value
	settings_config.challenge_mode_rocks = challenge_mode_rocks_widget.value
	settings_config.corner_menu_hidden_by_default = corner_menu_hidden_by_default_widget.pressed
	settings_config.language = language_widget.get_item_text(language_widget.selected)


# transfer data from settings_config to settings panel controls
func resource_to_panel_knobs():
	fullscreen_widget.pressed = settings_config.fullscreen
	music_vol_widget.value = settings_config.music_vol
	gravity_widget.value = settings_config.gravity
	challenge_mode_rocks_widget.value = settings_config.challenge_mode_rocks
	corner_menu_hidden_by_default_widget.pressed = settings_config.corner_menu_hidden_by_default
	
	for idx in range(language_widget.get_item_count()):
		if language_widget.get_item_text(idx)==settings_config.language:
			language_widget.selected = idx
			break


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
