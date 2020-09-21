extends "res://GameBase.gd"

var game_has_ended = false

var target_rock : Rock
var target_rock_has_been_touched : bool

const total_rocks_given : int = 3
var throwing_rocks = [] # list of Rocks that can be thrown-- some items in list will have been deleted at times
var throwzone_rocks = [] # list of Rocks in ThrowZone
var throwing_rocks_remaining : int = total_rocks_given

var beuld_topmid : Vector2
const beuld_top_area_height = 10.0 # height of boulder top detection zone for clearing top
var beuld_top_area : Area2D

var score : int = 0

var mistakes_made : int = 0


func _ready():
	beuld_topmid = beuld.global_transform.xform(beuld.top_mid())
	
	initialize_beuld_top_area()
	
	place_new_throwing_rocks(2)
	
	
		
	place_new_target_rock()
	
	$LabelsLayer/ThrowingRocksRemainingLabel.text = Strings.throwing_remaining(throwing_rocks_remaining)
	$LabelsLayer/ScoreLabel.text = Strings.rocks_knocked(score)


func initialize_beuld_top_area():
	beuld_top_area = Area2D.new()
	beuld_top_area.position = beuld_topmid + Vector2(0,-beuld_top_area_height/2)
	add_child(beuld_top_area)
	var beuld_top_collision_shape = CollisionShape2D.new()
	beuld_top_area.add_child(beuld_top_collision_shape)
	beuld_top_collision_shape.shape = RectangleShape2D.new()
	var beuld_top_width : float = beuld.global_transform.xform(beuld.top_right()).x - beuld.global_transform.xform(beuld.top_left()).x
	beuld_top_collision_shape.shape.extents = Vector2(beuld_top_width/2,beuld_top_area_height/2)


func _process(_delta):
	if scrolling_bg or game_has_ended: return
	if not target_rock_on_boulder() and $DelayTillSpawnTarget.is_stopped():
		if target_rock_has_been_touched:
			increment_score()
			mistakes_made = 0
#			target_rock.mode=RigidBody2D.MODE_STATIC  # Uncomment this to observe the moment a rock is counted as knocked off
		if not target_rock_has_been_touched:
			show_message(Strings.mistake_message(mistakes_made),2)
			mistakes_made += 1
		$DelayTillSpawnTarget.start()


func target_rock_on_boulder() -> bool:
	if not is_instance_valid(target_rock) : 
		return false
	return target_rock.position.y < beuld_topmid.y and\
		   target_rock.rightmost_vertex().x > beuld.global_transform.xform(beuld.top_left()).x and\
		   target_rock.leftmost_vertex().x < beuld.global_transform.xform(beuld.top_right()).x


func increment_score():
	show_message(Strings.knocked(),1.2)
	score += 1
	$LabelsLayer/ScoreLabel.text = Strings.rocks_knocked(score)


func place_new_throwing_rocks(num_rocks : int):
	var rocks = spawn_rocks(num_rocks,$RockSpawnLine)
	for rock in rocks:
		rock.connect("clicked_yet_unholdable",self,"_on_clicked_yet_unholdable")
	throwing_rocks += rocks
	throwzone_rocks += rocks

func change_throwing_rocks_remaining(change : int):
	throwing_rocks_remaining += change
	$LabelsLayer/ThrowingRocksRemainingLabel.text = Strings.throwing_remaining(throwing_rocks_remaining)
	if throwing_rocks_remaining <= 0:
		$DelayTillEndGame.start()


func place_new_target_rock():
	target_rock = Rock.new()
	add_child(target_rock)
	target_rock.position += beuld_topmid-target_rock.global_transform.xform(target_rock.center_of_mass())+Vector2(0,-20-target_rock.flat_bottom())
	target_rock.set_holdable(false,Strings.cant_hold_target())
	target_rock.connect("body_entered",self,"_on_target_rock_contact")
	target_rock.connect("clicked_yet_unholdable",self,"_on_clicked_yet_unholdable")
	target_rock_has_been_touched = false


func _on_TargetRockPlacementTimer_timeout():
	place_new_target_rock()
		

func _on_target_rock_contact(body):
	if body is Boulder or not (body is Rock): return # We only care about non-boulder rocks
	if body in throwing_rocks:
		target_rock_has_been_touched = true


func _on_DelayTillEndGame_timeout():
	if throwing_rocks_remaining <= 0:
		game_has_ended = true
		$EndgameRufflePlayer.play()
		show_message(Strings.endgame_message(score,total_rocks_given),-1)


func _on_LineOfPebbles_rock_lost(body):
	if scene_shutting_down : return
	change_throwing_rocks_remaining(-1)
	throwzone_rocks.erase(body)
	var num_throwzone_rocks_including_incoming : int = len(throwzone_rocks) + (0 if $DelayTillReplaceThrowingRocks.is_stopped() else 1)
	if len(throwzone_rocks) < 2 and throwing_rocks_remaining > num_throwzone_rocks_including_incoming:
		if $DelayTillReplaceThrowingRocks.is_stopped():
			$DelayTillReplaceThrowingRocks.start()
		else:
			place_new_throwing_rocks(1)


func _on_DelayTillReplaceThrowingRocks_timeout():
	place_new_throwing_rocks(1)


func _on_LineOfPebbles_rock_regained(body):
	change_throwing_rocks_remaining(1)
	throwzone_rocks.append(body)


func _on_ThrowZone_mouse_exited():
	cursor_changeable = false
	Input.set_custom_mouse_cursor(splayed_hand,Input.CURSOR_ARROW,Vector2(21,27))
	for rock in throwzone_rocks:
		if rock.is_held:
			rock.set_held(false)


func _on_ThrowZone_mouse_entered():
	cursor_changeable = true
	Input.set_custom_mouse_cursor(open_hand,Input.CURSOR_ARROW,Vector2(21,27))

func _on_clicked_yet_unholdable(reason):
	if not game_has_ended: show_message(reason,2.5)


func show_message(msg : String, time : float = 4):
	$LabelsLayer/MsgCenter.text = msg
	if time > 0: # time <= 0 would cause an indefinite message
		$LabelsLayer/MsgCenter/MsgTimer.wait_time = time
		$LabelsLayer/MsgCenter/MsgTimer.start()
	else:
		$LabelsLayer/MsgCenter/MsgTimer.stop()
	$LabelsLayer/MsgCenter.show()


func _on_MsgTimer_timeout():
	$LabelsLayer/MsgCenter.hide()


func beuld_top_obstructed() -> bool:
	for body in beuld_top_area.get_overlapping_bodies():
		if body is Rock and not body is Boulder: return true
	return false
	
	
	
	
	
	
