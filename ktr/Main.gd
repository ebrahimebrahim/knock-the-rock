extends Node2D

const Rock = preload("res://Rock.gd")
const Boulder = preload("res://Boulder.gd")

func _ready():
	randomize()
	put_rock(8)
	put_boulder(1,Vector2(500,300))

func put_rock(num : int, pos = Vector2(0,0)) -> void:
		for _i in range(num):
			var rock : Rock = Rock.new()
			add_child(rock)
			if pos == Vector2(0,0): rock.set_position(Vector2(rand_range(100,900),rand_range(0,300)))
			else: rock.set_position(pos)

func put_boulder(num : int, pos = Vector2(0,0)) -> void:
		for _i in range(num):
			var beuld : Boulder = Boulder.new()
			add_child(beuld)
			if pos == Vector2(0,0): beuld.set_position(Vector2(rand_range(100,900),rand_range(0,300)))
			else: beuld.set_position(pos)
