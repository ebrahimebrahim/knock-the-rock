extends "res://GameBase.gd"

var target_rock : Rock
var target_rock_has_been_touched : bool
var throwing_rocks = [] # list of Rocks that can be thrown-- some items in list will have been deleted at times
var holdable_throwing_rocks = [] # list of Rocks in ThrowZone
var throwing_rocks_remaining : int = 10
var beuld_topmid : Vector2
var score : int = 0

const splayed_hand = preload("res://images/splayed_hand.png")

func _ready():
	place_new_throwing_rocks(2)
	
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


func place_new_throwing_rocks(num_rocks : int):
	var rocks = spawn_rocks(num_rocks,$RockSpawnLine)
	throwing_rocks += rocks
	holdable_throwing_rocks += rocks

func change_throwing_rocks_remaining(change : int):
	throwing_rocks_remaining += change
	$LabelsLayer/ThrowingRocksRemainingLabel.text = "Throwing Rocks Remaining: " + str(throwing_rocks_remaining)
	if throwing_rocks_remaining <= 0:
		$DelayTillEndGame.start()


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


func _on_DelayTillEndGame_timeout():
	if throwing_rocks_remaining <= 0:
		print("game has ended with score of ",score) # placeholder


func _on_LineOfPebbles_rock_lost(body):
	if scene_shutting_down : return
	change_throwing_rocks_remaining(-1)
	holdable_throwing_rocks.erase(body)
	if len(holdable_throwing_rocks) < 2 and throwing_rocks_remaining > len(holdable_throwing_rocks):
		if len(holdable_throwing_rocks) == 0:
			place_new_throwing_rocks(1) # if no rocks t throw, provide one immediately
		else: # but if there's one rock to throw already, provide the second with delay
			$DelayTillReplaceThrowingRocks.start()


func _on_DelayTillReplaceThrowingRocks_timeout():
	place_new_throwing_rocks(1)


func _on_LineOfPebbles_rock_regained(body):
	change_throwing_rocks_remaining(1)
	holdable_throwing_rocks.append(body)


func _on_ThrowZone_mouse_exited():
	cursor_changeable = false
	Input.set_custom_mouse_cursor(splayed_hand,Input.CURSOR_ARROW,Vector2(21,27))
	for rock in holdable_throwing_rocks:
		if rock.is_held:
			rock.set_held(false)


func _on_ThrowZone_mouse_entered():
	cursor_changeable = true
	Input.set_custom_mouse_cursor(open_hand,Input.CURSOR_ARROW,Vector2(21,27))


func show_message(msg : String, time : float = 4):
	$MsgCenter.text = msg
	$MsgCenter.show()
	$MsgCenter/MsgTimer.wait_time = time
	$MsgCenter/MsgTimer.start()


func _on_MsgTimer_timeout():
	$MsgCenter.hide()
