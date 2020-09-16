extends "res://GameBase.gd"

const Rock = preload("res://Rock.gd")
const Boulder = preload("res://Boulder.gd")

func random_point_on_line(line : Line2D):
	assert(len(line.points)==2)
	return line.points[0]+randf()*(line.points[1] - line.points[0])

func _ready():
	randomize()
	var beuld : Boulder = Boulder.new()
	add_child(beuld)
	beuld.set_position(random_point_on_line($BoulderBotRight)-beuld.bottom_right())

	var rocks = []
	for _i in range(2):
		var rock : Rock = Rock.new()
		add_child(rock)
		while true:
			rock.set_position(random_point_on_line($RockSpawnLine))
			var rock_intersects_some_other_rock = false
			for other in rocks:
				var r_l = rock.leftmost_vertex().x
				var r_r = rock.rightmost_vertex().x
				var o_l = other.leftmost_vertex().x
				var o_r = other.rightmost_vertex().x
				if r_r > o_l and o_r > r_l:
					rock_intersects_some_other_rock = true
			if not rock_intersects_some_other_rock:
				break
		rocks.append(rock)

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.is_pressed():
		var rock : Rock = Rock.new()
		add_child(rock)
		rock.flat_bottom()
		rock.position = rock.global_transform.xform(-rock.center_of_mass() + rock.global_transform.xform_inv(event.position))

