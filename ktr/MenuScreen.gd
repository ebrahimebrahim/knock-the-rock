extends VBoxContainer

var scrolling_bg : bool = false
var change_scene_to : String

func _ready():
	$MenuZone/Menu/SdbxButton.connect("button_up",self,"_on_sdbx")
	$MenuZone/Menu/ChlgButton.connect("button_up",self,"_on_chlg")
	$MenuZone/Menu/SettingsButton.connect("button_up",self,"_on_settings")
	$MenuZone/Menu/HelpButton.connect("button_up",self,"_on_help")
	$MenuZone/Menu/ExitButton.connect("button_up",self,"_on_exit")

func _on_sdbx():
	scroll_bg("res://GameSandbox.tscn")

func _on_chlg():
	print("chlg peup")

func _on_settings():
	print("settings peup")

func _on_help():
	print("help peup")

func _on_exit():
	get_tree().quit()

func scroll_bg(scene):
	$LogoZone.hide()
	$MenuZone.hide()
	scrolling_bg = true
	change_scene_to = scene

func _process(delta):
	if scrolling_bg:
		if $bg.position.y > 176:
			$bg.position.y -= 400*delta
		else:
			scrolling_bg = false
			get_tree().change_scene(change_scene_to)

func _input(event):
	if event.is_action_pressed("return_to_menu") and not scrolling_bg:
		_on_exit()
