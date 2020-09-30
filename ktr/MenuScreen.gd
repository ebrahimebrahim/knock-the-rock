extends VBoxContainer

var scrolling_bg : bool = false
var change_scene_to : String

const pointing_hand = preload("res://images/pointing_hand.png")



func _init():
	var cfg : Resource = Globals.load_settings_config()
	Strings.lang = cfg.language


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
	setup_ui_labels()
	
	

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
	$MarginContainer/VersionLabel.hide()
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
	
	# fullscreen
	OS.window_fullscreen = cfg.fullscreen
	
	# music vol
	Music.volume_db = cfg.music_vol
	if cfg.music_vol ==  $Overlays/Settings.music_vol_min:
		Music.really_stop = true
		Music.stop()
	elif not Music.playing:
		Music.really_stop = false
		Music.play()
	
	# gravity
	Physics2DServer.area_set_param(
		get_viewport().find_world_2d().get_space(),
		Physics2DServer.AREA_PARAM_GRAVITY,
		cfg.gravity
	)
	
	# number of thrown rocks to be given
	Globals.total_rocks_given = cfg.challenge_mode_rocks
	
	# corner menu hidden by default
	Globals.corner_menu_hidden_by_default = cfg.corner_menu_hidden_by_default
	
	# language needs to be set earlier-- see _init


func setup_ui_labels():
	$MarginContainer/VersionLabel.text = Strings.version_string()
	$LogoZone/Logo/Title.text = Strings.ui_label("ktr title")
	$MenuZone/Menu/SdbxButton.text = Strings.ui_label("sandbox btn")
	$MenuZone/Menu/ChlgButton.text = Strings.ui_label("challenge btn")
	$MenuZone/Menu/SettingsButton.text = Strings.ui_label("settings btn")
	$MenuZone/Menu/HelpButton.text = Strings.ui_label("help btn")
	$MenuZone/Menu/ExitButton.text = Strings.ui_label("exit btn")
