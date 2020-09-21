extends VBoxContainer

var scrolling_bg : bool = false
var change_scene_to : String

const pointing_hand = preload("res://images/pointing_hand.png")
var settings_config : Resource



func _ready():
	$MenuZone/Menu/SdbxButton.connect("button_up",self,"_on_sdbx")
	$MenuZone/Menu/ChlgButton.connect("button_up",self,"_on_chlg")
	$MenuZone/Menu/SettingsButton.connect("button_up",self,"_on_settings")
	$MenuZone/Menu/HelpButton.connect("button_up",self,"_on_help")
	$MenuZone/Menu/ExitButton.connect("button_up",self,"_on_exit")
	$Overlays/Help.connect("hide_help",self,"_on_help")
	$Overlays/Settings.connect("back",self,"_on_settings")
	$Overlays/Settings.connect("apply",self,"reload_scene")
	Input.set_custom_mouse_cursor(pointing_hand,Input.CURSOR_ARROW,Vector2(16,6))
	process_settings()
	
	

func _on_sdbx():
	scroll_bg("res://GameSandbox.tscn")

func _on_chlg():
	scroll_bg("res://GameChallenge.tscn")

func _on_settings():
	$Overlays/Settings.visible = not $Overlays/Settings.visible

func _on_help():
	$Overlays/Help.visible = not $Overlays/Help.visible

func _on_exit():
	get_tree().quit()

func reload_scene():
	get_tree().reload_current_scene()

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
	if event.is_action_pressed("return_to_menu"):
		if scrolling_bg: get_tree().reload_current_scene()
		else: _on_exit()
	if event.is_action_pressed("open_help") and not scrolling_bg:
		_on_help()


# Go through the game settings that were loaded from file and do stuff with them
func process_settings():
	var cfg : SettingsConfig = $Overlays/Settings.settings_config
	OS.window_fullscreen = cfg.fullscreen
	Music.volume_db = cfg.music_vol
	if cfg.music_vol ==  $Overlays/Settings.music_vol_min:
		Music.really_stop = true
		Music.stop()
