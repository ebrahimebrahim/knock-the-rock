extends "res://GameBase.gd"

func _ready():
	spawn_rocks(2,$RockSpawnLine)

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.is_pressed():
		var rock : Rock = Rock.new()
		add_child(rock)
		rock.flat_bottom()
		rock.position = rock.global_transform.xform(-rock.center_of_mass() + rock.global_transform.xform_inv(event.position))
