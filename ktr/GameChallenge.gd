extends "res://GameBase.gd"

var target_rock : Rock
var throwing_rocks = [] # list of Rocks that can be thrown-- some items in list will have been deleted at times
var beuld_topmid : Vector2

func _ready():
	for spawn_line in $RockSpawnLines.get_children():
		throwing_rocks += spawn_rocks((10/$RockSpawnLines.get_child_count()),spawn_line)
		
	beuld_topmid = beuld.global_transform.xform(beuld.top_mid())
		
	place_new_target_rock()

func place_new_target_rock():
	target_rock = Rock.new()
	add_child(target_rock)
	target_rock.position += beuld_topmid-target_rock.global_transform.xform(target_rock.center_of_mass())+Vector2(0,-20-target_rock.flat_bottom())
	target_rock.holdable = false
