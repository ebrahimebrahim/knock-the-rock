extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReturnButton.connect("button_up",self,"_on_return")
	$RestartButton.connect("button_up",self,"_on_restart")
	$HelpButton.connect("button_up",self,"_on_help")

func _input(event):
	if event.is_action_pressed("return_to_menu"): _on_return()
	if event.is_action_pressed("restart"): _on_restart()
	if event.is_action_pressed("open_help"): _on_help()
	if event.is_action_pressed("close_hud"): _on_close()

func _on_return():
	print("return peup")

func _on_restart():
	print("restart peup")

func _on_help():
	print("help peup")

func _on_close():
	print("close peup")
