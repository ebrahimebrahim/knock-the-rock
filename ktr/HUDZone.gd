extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReturnButton.connect("button_up",self,"_on_return")
	$RestartButton.connect("button_up",self,"_on_restart")
	$HelpButton.connect("button_up",self,"_on_help")

func _on_return():
	pass

func _on_restart():
	pass

func _on_help():
	pass

func _on_close():
	pass
