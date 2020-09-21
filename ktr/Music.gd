extends AudioStreamPlayer

# calling stop() would not work because it triggers _on_finsihed and loops,
# unless you set really_stop=true
var really_stop = false

func _init():
	stream = load("res://sounds/rocky_tune.ogg")
	stream.loop = false
	connect("finished",self,"_on_finished")
	play()

func _on_finished():
	if not really_stop:
		play(48.032)
