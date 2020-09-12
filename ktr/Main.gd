extends Node2D

const Rock = preload("res://Rock.gd")


func _ready():
	randomize()
	for i in range(2):
		var rock : Rock = Rock.new()
		add_child(rock)
		rock.set_position(Vector2(rand_range(100,900),rand_range(0,300)))
		rock.connect("knock",$AudioStreamPlayer2D,"_on_knock")
