extends VBoxContainer

var scrolling_bg : bool = false
var change_scene_to : String

var open_hand = preload("res://images/open_hand.png")
var closed_hand = preload("res://images/closed_hand.png")
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
	
	print("Here's a setting that was loaded: ",$Overlays/Settings.get_example_setting())
	

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
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT: update_cursor()

func update_cursor():
	if Input.is_action_pressed("click"): Input.set_custom_mouse_cursor(closed_hand,Input.CURSOR_ARROW,Vector2(21,27))
	else: Input.set_custom_mouse_cursor(open_hand,Input.CURSOR_ARROW,Vector2(21,27))
