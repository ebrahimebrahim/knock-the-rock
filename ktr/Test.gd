extends Node2D

const Rock = preload("res://Rock.gd")
const Boulder = preload("res://Boulder.gd")

func _ready():
	randomize()
	put_rock(8)
	put_boulder(Vector2(300,400))

func put_rock(num : int, pos = null) -> void:
		for _i in range(num):
			var rock : Rock = Rock.new()
			add_child(rock)
			if pos == null: rock.set_position(Vector2(rand_range(100,900),rand_range(0,300)))
			else: rock.set_position(pos)

func put_boulder(pos : Vector2) -> void:
		var beuld : Boulder = Boulder.new()
		add_child(beuld)
		beuld.set_position(pos)
