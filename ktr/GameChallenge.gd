extends "res://GameBase.gd"

var game_has_ended = false

var target_rock : Rock
var target_rock_has_been_touched : bool

var total_rocks_given : int = Globals.total_rocks_given
var throwing_rocks = [] # list of Rocks that can be thrown-- some items in list will have been deleted at times
var throwzone_rocks = [] # list of Rocks in ThrowZone
var throwing_rocks_remaining : int = total_rocks_given

var beuld_topmid : Vector2
const beuld_top_area_height = 10.0 # height of boulder top detection zone for clearing top
var beuld_top_area : Area2D
var beuld_top_obstructors = []

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
	beuld_top_area.connect("body_entered",self,"_on_beuld_top_body_entered")
	beuld_top_area.connect("body_exited",self,"_on_beuld_top_body_exited")

func _on_beuld_top_body_entered(body):
	if body is Rock and not body is Boulder and not body in beuld_top_obstructors:
		beuld_top_obstructors.append(body)
	
func _on_beuld_top_body_exited(body):
	# when body.mode become MODE_STATIC, that does weirdly triggert he body_exited signal
	# we don't want to count this as a body exiting
	if body in beuld_top_obstructors and body.mode != RigidBody2D.MODE_STATIC:
		beuld_top_obstructors.erase(body)


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
		
		# Relieve old target rock of its targetty duties, if there is one
		if target_rock:
			target_rock.disconnect("body_entered",self,"_on_target_rock_contact")
			target_rock.set_holdable(false,Strings.cant_hold_past_line())
			target_rock.set_jiggle_control(true)
		
		$DelayTillSpawnTarget.start()


func target_rock_on_boulder() -> bool:
	if not is_instance_valid(target_rock) : 
		return false
	return target_rock.position.y < beuld_topmid.y + 5 and\
		   target_rock.rightmost_vertex().x > beuld.global_transform.xform(beuld.top_left()).x and\
		   target_rock.leftmost_vertex().x < beuld.global_transform.xform(beuld.top_right()).x


func increment_score():
	show_message(Strings.knocked(),1.2)
	score += 1
	$LabelsLayer/ScoreLabel.text = Strings.rocks_knocked(score)


func place_new_throwing_rocks(num_rocks : int):
	var rightwall : CollisionShape2D = $LineOfPebbles/ThrowZoneBarrier/RightWall
	var rocks = spawn_rocks(
		num_rocks,
		$RockSpawnLine,
		[ 0 , rightwall.global_position.x - rightwall.shape.extents.x ]
	)
	for rock in rocks:
		rock.connect("clicked_yet_unholdable",self,"_on_clicked_yet_unholdable")
		temporarily_grant_justspawned_collisionness(rock)
	throwing_rocks += rocks
	throwzone_rocks += rocks

func temporarily_grant_justspawned_collisionness(rock : Rock):
	rock.collision_mask = 0b10 # allows rock to be blocked by throwzone barrier
	rock.collision_layer = 0b10 # other just spawned rocks should be blocked by rock
#	rock.modulate = Color(1,0,0) # uncomment for debugging
	
	# This area will be a circle inside the rock
	# It will be used to help decide when we turn off the "justspawned_collisionness"
	# Then it will be deleted
	var a = Area2D.new()
	var c = CollisionShape2D.new()
	c.shape = CircleShape2D.new()
	var posrad = rock.get_inner_circle()
	c.shape.radius = posrad[1]
	a.add_child(c)
	rock.add_child(a)
	c.position = posrad[0]
	
	get_tree().create_timer(0.7).connect("timeout",self,"_on_justspawned_timeout",[rock,a])
func _on_justspawned_timeout(rock : Rock, inner_circle : Area2D):
	if not is_instance_valid(rock): return
	for body in inner_circle.get_overlapping_bodies():
		if body is Rock and body.name != rock.name:
			get_tree().create_timer(0.2).connect("timeout",self,"_on_justspawned_timeout",[rock,inner_circle])
			rock.set_holdable(false,"")
			body.raise()
			return
#	rock.modulate = Color(1,1,1) # uncomment for debugging
	rock.collision_mask = 0b01 # can phase through throwzone barrier again
	rock.collision_layer = 0b11 # will collide with all rocks
	rock.set_holdable(true)
	inner_circle.queue_free()


func change_throwing_rocks_remaining(change : int):
	throwing_rocks_remaining += change
	$LabelsLayer/ThrowingRocksRemainingLabel.text = Strings.throwing_remaining(throwing_rocks_remaining)


func place_new_target_rock():
	if not beuld_top_obstructors.empty():
		show_message(Strings.removing_obstructions(),$DelayTillSpawnTarget.wait_time)
		for rock in beuld_top_obstructors:
			rock.schwoop_delete()
			beuld_top_obstructors.erase(rock)
		$DelayTillSpawnTarget.start()
		return
	
	# Introduce new target rock
	target_rock = Rock.new()
	add_child(target_rock)
	target_rock.position += beuld_topmid-target_rock.global_transform.xform(target_rock.center_of_mass())+Vector2(0,-20-target_rock.flat_bottom())
	target_rock.set_holdable(false,Strings.cant_hold_target())
	target_rock.connect("body_entered",self,"_on_target_rock_contact")
	target_rock.connect("clicked_yet_unholdable",self,"_on_clicked_yet_unholdable")
	target_rock_has_been_touched = false


func _on_target_rock_contact(body):
	if body is Boulder or not (body is Rock): return # We only care about non-boulder rocks
	if body in throwing_rocks:
		target_rock_has_been_touched = true


func _on_DelayTillEndGame_timeout():
	if throwing_rocks_remaining <= 0 and not game_has_ended:
		game_has_ended = true
		$EndgameRufflePlayer.play()
		show_message(Strings.endgame_message(score,total_rocks_given),-1)



func _on_LineOfPebbles_rock_lost(rock : Rock):
	if scene_shutting_down or game_has_ended: return
	change_throwing_rocks_remaining(-1)
	if throwing_rocks_remaining <= 0:
		# initiate possible endgame sequence
		rock.monitor_stopped_or_deleted = true
		rock.connect("stopped_or_deleted",self,"_last_rock_stopped_or_gone",[rock],CONNECT_ONESHOT) 
	throwzone_rocks.erase(rock)
	var num_throwzone_rocks_including_incoming : int = len(throwzone_rocks) + (0 if $DelayTillReplaceThrowingRocks.is_stopped() else 1)
	if len(throwzone_rocks) < 2 and throwing_rocks_remaining > num_throwzone_rocks_including_incoming:
		if $DelayTillReplaceThrowingRocks.is_stopped():
			$DelayTillReplaceThrowingRocks.start()
		else:
			call_deferred("place_new_throwing_rocks",1)


func _on_DelayTillReplaceThrowingRocks_timeout():
	place_new_throwing_rocks(1)


func _last_rock_stopped_or_gone(rock : Rock) -> void:
	rock.monitor_stopped_or_deleted = false
	$DelayTillEndGame.start()


func _on_LineOfPebbles_rock_regained(rock : Rock):
	if game_has_ended: return
	change_throwing_rocks_remaining(1)
	throwzone_rocks.append(rock)
	if not rock in throwing_rocks:
		throwing_rocks.append(rock)


func _on_ThrowZone_mouse_exited():
	cursor_changeable = false
	Input.set_custom_mouse_cursor(splayed_hand,Input.CURSOR_ARROW,Vector2(21,27))
	for rock in throwzone_rocks:
		if rock.is_held:
			rock.set_held(false)


func _on_ThrowZone_mouse_entered():
	cursor_changeable = true
	var some_rock_is_held = false
	for rock in throwing_rocks:
		if is_instance_valid(rock) and rock.is_held:
			some_rock_is_held = true
			break
	Input.set_custom_mouse_cursor(closed_hand if some_rock_is_held else open_hand,Input.CURSOR_ARROW,Vector2(21,27))

func _on_clicked_yet_unholdable(reason):
	if not game_has_ended and reason != "":
		show_message(reason,2.5)


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

	
	
	
	
	
	
