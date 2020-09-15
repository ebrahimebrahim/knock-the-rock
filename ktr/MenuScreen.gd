extends VBoxContainer

func _ready():
	$MenuZone/Menu/SdbxButton.connect("button_up",self,"_on_sdbx")
	$MenuZone/Menu/ChlgButton.connect("button_up",self,"_on_chlg")
	$MenuZone/Menu/SettingsButton.connect("button_up",self,"_on_settings")
	$MenuZone/Menu/HelpButton.connect("button_up",self,"_on_help")
	$MenuZone/Menu/ExitButton.connect("button_up",self,"_on_exit")

func _on_sdbx():
	get_tree().change_scene("res://GameSandbox.tscn")

func _on_chlg():
	print("chlg peup")

func _on_settings():
	print("settings peup")

func _on_help():
	print("help peup")

func _on_exit():
	get_tree().quit()
