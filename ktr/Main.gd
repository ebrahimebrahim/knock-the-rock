extends Node2D

const Rock = preload("res://Rock.gd")

func _ready():
	randomize()
	put_rock(4,Vector2(rand_range(100,900),rand_range(0,300)))

func put_rock(num : int, pos : Vector2) -> void:
		for _i in range(num):
			var rock : Rock = Rock.new()
			add_child(rock)
			rock.set_position(pos)
