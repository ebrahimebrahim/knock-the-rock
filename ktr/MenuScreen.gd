extends VBoxContainer

func _ready():
	$MenuZone/Menu/SdbxButton.connect("button_up",self,"_on_sdbx")

func _on_sdbx():
	get_tree().change_scene("res://GameSandbox.tscn")
