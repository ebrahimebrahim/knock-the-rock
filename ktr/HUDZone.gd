extends Control

var scrolling_bg : bool = false
var change_scene_to : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReturnButton.connect("button_up",self,"_on_return")
	$RestartButton.connect("button_up",self,"_on_restart")
	$HelpButton.connect("button_up",self,"_on_help")

func _input(event):
	if event.is_action_pressed("return_to_menu"): _on_return()
	if event.is_action_pressed("restart"): _on_restart()
	if event.is_action_pressed("open_help"): _on_help()
	if event.is_action_pressed("toggle_hud"): _on_toggle()

func _on_return():
	scroll_bg("res://MenuScreen.tscn")

func _on_restart():
	get_tree().reload_current_scene()

func _on_help():
	print("help peup")

func _on_toggle():
	if visible: hide()
	else: show()

func scroll_bg(scene):
	hide()
	scrolling_bg = true
	change_scene_to = scene

func _process(delta):
	if scrolling_bg:
		if get_node("/root/Game/bg").position.y < 494:
			get_node("/root/Game/bg").position.y += 200*delta
		else:
			scrolling_bg = false
			get_tree().change_scene(change_scene_to)
