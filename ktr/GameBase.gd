extends Node2D

var scrolling_bg : bool = false
var change_scene_to : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$HUDZone/ReturnButton.connect("button_up",self,"_on_return")
	$HUDZone/RestartButton.connect("button_up",self,"_on_restart")
	$HUDZone/HelpButton.connect("button_up",self,"_on_help")

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
	if $HUDZone.visible: $HUDZone.hide()
	else: $HUDZone.show()

func scroll_bg(scene):
	for child in get_children():
		if child.name != "bg": child.queue_free()
	scrolling_bg = true
	change_scene_to = scene

func _process(delta):
	if scrolling_bg:
		if $bg.position.y < 494:
			$bg.position.y += 1200*delta
		else:
			scrolling_bg = false
			get_tree().change_scene(change_scene_to)
