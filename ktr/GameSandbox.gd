extends Node2D

const Rock = preload("res://Rock.gd")
const Boulder = preload("res://Boulder.gd")

func random_point_on_line(line : Line2D):
	assert(len(line.points)==2)
	return line.points[0]+randf()*(line.points[1] - line.points[0])

func _ready():
	randomize()
	var beuld : Boulder = Boulder.new()
	add_child(beuld)
	beuld.set_position(random_point_on_line($BoulderBotRight)-beuld.bottom_right)

	for _i in range(5):
		var rock : Rock = Rock.new()
		add_child(rock)
		rock.set_position(random_point_on_line($RockSpawnLine))
