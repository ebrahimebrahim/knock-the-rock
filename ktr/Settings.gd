extends Panel

const SettingsConfig = preload("SettingsConfig.gd")
var settings_config : SettingsConfig

signal back
signal apply


func _init():
	settings_config = load("settings.tres")
	print("Loaded settings from file, got: ",settings_config.an_example_setting)

func _ready():
	$VBoxContainer/VBoxContainer/HBoxContainer/SpinBox.value = get_example_setting()

func get_example_setting():
	return settings_config.an_example_setting

func _on_BackButton_pressed():
	emit_signal("back")



func _on_ApplyButton_pressed():
	settings_config.an_example_setting = $VBoxContainer/VBoxContainer/HBoxContainer/SpinBox.value
	var error : int = ResourceSaver.save("settings.tres",settings_config)
	if error != OK:
		print("There was an error saving settings.")
	emit_signal("apply")


func _on_DefaultsButton_pressed():
	pass # Replace with function body.
