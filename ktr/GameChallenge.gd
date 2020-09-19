extends "res://GameBase.gd"

var target_rock : Rock
var target_rock_has_been_touched : bool
var throwing_rocks = [] # list of Rocks that can be thrown-- some items in list will have been deleted at times
var throwing_rocks_remaining : int = 10
var beuld_topmid : Vector2
var score : int = 0


func _ready():
	for _i in range(2):
		place_new_throwing_rock()
	
	beuld_topmid = beuld.global_transform.xform(beuld.top_mid())
		
	place_new_target_rock()
	
	$LabelsLayer/ThrowingRocksRemainingLabel.text = "Throwing Rocks Remaining: " + str(throwing_rocks_remaining)
	$LabelsLayer/ScoreLabel.text = "Rocks Knocked: " + str(score)


func _process(delta):
	if scrolling_bg : return
	if not target_rock_on_boulder() and $DelayTillSpawnTarget.is_stopped():
		if target_rock_has_been_touched:
			increment_score()
#			target_rock.mode=RigidBody2D.MODE_STATIC  # Uncomment this to observe the moment a rock is counted as knocked off
		$DelayTillSpawnTarget.start()


func target_rock_on_boulder() -> bool:
	if not is_instance_valid(target_rock) : 
		return false
	return target_rock.position.y < beuld_topmid.y and\
		   target_rock.rightmost_vertex().x > beuld.global_transform.xform(beuld.top_left()).x and\
		   target_rock.leftmost_vertex().x < beuld.global_transform.xform(beuld.top_right()).x


func increment_score():
	score += 1
	$LabelsLayer/ScoreLabel.text = "Rocks Knocked: " + str(score)


func place_new_throwing_rock():
	var rock = spawn_rocks(1,$RockSpawnLine)
	rock[0].connect("tree_exited",self,"check_endgame_condition")
	rock[0].connect("became_unholdable",self,"check_endgame_condition")
	throwing_rocks += rock

func decrement_throwing_rocks_remaining():
	throwing_rocks_remaining -= 1
	$LabelsLayer/ThrowingRocksRemainingLabel.text = "Throwing Rocks Remaining: " + str(throwing_rocks_remaining)


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


func check_endgame_condition():
	if not is_inside_tree(): return false # if check was triggered by a scene restart, for example
	for rock in throwing_rocks:
		if is_instance_valid(rock) and rock.is_inside_tree() and rock.holdable:
			return false
	$DelayTillEndGame.start()
	return true


func _on_DelayTillEndGame_timeout():
	print("game has ended with score of ",score) # placeholder


func _on_LineOfPebbles_rock_lost():
	decrement_throwing_rocks_remaining()
	if throwing_rocks_remaining > 1:
		place_new_throwing_rock()
