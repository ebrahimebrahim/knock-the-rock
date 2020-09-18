extends "res://GameBase.gd"

var target_rock : Rock
var target_rock_has_been_touched : bool
var throwing_rocks = [] # list of Rocks that can be thrown-- some items in list will have been deleted at times
var beuld_topmid : Vector2


func _ready():
	for spawn_line in $RockSpawnLines.get_children():
		throwing_rocks += spawn_rocks((10/$RockSpawnLines.get_child_count()),spawn_line)
		
	beuld_topmid = beuld.global_transform.xform(beuld.top_mid())
		
	place_new_target_rock()


func _process(delta):
	if scrolling_bg : return
	if not target_rock_on_boulder() and $DelayTillSpawnTarget.is_stopped():
		$DelayTillSpawnTarget.start()


func target_rock_on_boulder() -> bool:
	return is_instance_valid(target_rock) and target_rock.position.y < beuld_topmid.y


func place_new_target_rock():
	target_rock = Rock.new()
	add_child(target_rock)
	target_rock.position += beuld_topmid-target_rock.global_transform.xform(target_rock.center_of_mass())+Vector2(0,-20-target_rock.flat_bottom())
	target_rock.holdable = false
	target_rock.connect("body_entered",self,"_on_target_rock_contact")
	target_rock_has_been_touched = false


func _on_TargetRockPlacementTimer_timeout():
	place_new_target_rock()
		

func _on_target_rock_contact(body):
	if body is Boulder or not (body is Rock): return # We only care about non-boulder rocks
	if body in throwing_rocks:
		target_rock_has_been_touched = true
