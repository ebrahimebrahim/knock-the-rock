extends "res://GameBase.gd"

var target_rock : Rock
var throwing_rocks = [] # list of Rocks that can be thrown-- some items in list will have been deleted at times
var beuld_topmid : Vector2

func _ready():
	for spawn_line in $RockSpawnLines.get_children():
		throwing_rocks += spawn_rocks((10/$RockSpawnLines.get_child_count()),spawn_line)
		
	beuld_topmid = beuld.global_transform.xform(beuld.top_mid())
		
	place_new_target_rock()


func _process(delta):
	if not target_rock_on_boulder() and $Timers/DelayTillSpawnTarget.is_stopped():
		$Timers/DelayTillSpawnTarget.start()
		print("started tiemr!")


func target_rock_on_boulder() -> bool:
	return is_instance_valid(target_rock) and target_rock.position.y < beuld_topmid.y


func set_all_throwing_holdable(holdable : bool):
	for rock in throwing_rocks:
		if is_instance_valid(rock):
			rock.holdable = holdable

func place_new_target_rock():
	spawn_new_target_rock()
	set_all_throwing_holdable(false)
	$Timers/TargetRockPlacement.start()


func spawn_new_target_rock():
	target_rock = Rock.new()
	add_child(target_rock)
	target_rock.position += beuld_topmid-target_rock.global_transform.xform(target_rock.center_of_mass())+Vector2(0,-20-target_rock.flat_bottom())
	target_rock.holdable = false


func _on_TargetRockPlacementTimer_timeout():
	if target_rock_on_boulder():
		set_all_throwing_holdable(true)
	else:
		place_new_target_rock()
		
