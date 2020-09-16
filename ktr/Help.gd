extends Panel

signal hide_help


func _on_HideButton_button_up():
	emit_signal("hide_help")
