extends Node2D

const Rock = preload("res://Rock.gd")

func _ready():
	randomize()
	for _i in range(4):
		var rock : Rock = Rock.new()
		add_child(rock)
		rock.set_position(Vector2(rand_range(100,900),rand_range(0,300)))
