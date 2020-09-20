extends AudioStreamPlayer

func _init():
	stream = load("res://sounds/rocky_tune.ogg")
	stream.loop = false
	connect("finished",self,"_on_finished")
	play()

func _on_finished():
	play(48.032)
