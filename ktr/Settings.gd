extends Panel

const SettingsConfig = preload("SettingsConfig.gd")
var settings_config : SettingsConfig
export var default_settings : Resource # A SettingsConfig which we set up in editor

signal back
signal apply


func _init():
	settings_config = ResourceLoader.load("settings.tres","",true) # no_cache = true
	print("Loaded settings from file, got: ",settings_config.an_example_setting)

func _ready():
	$VBoxContainer/VBoxContainer/HBoxContainer/SpinBox.value = get_example_setting()

func get_example_setting():
	return settings_config.an_example_setting

func _on_BackButton_pressed():
	emit_signal("back")



func _on_ApplyButton_pressed():
	settings_config.an_example_setting = $VBoxContainer/VBoxContainer/HBoxContainer/SpinBox.value
	apply_settings(settings_config)


func _on_DefaultsButton_pressed():
	apply_settings(default_settings)


func apply_settings(s : SettingsConfig):
	var error : int = ResourceSaver.save("settings.tres",s)
	if error != OK:
		print("There was an error saving settings.")
	emit_signal("apply")
