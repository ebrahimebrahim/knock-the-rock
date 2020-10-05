extends "res://GameBase.gd"

var game_has_ended = false # true when game is for sure over
var game_might_end = false # true when last rock was thrown and we are waiting to see if player somehow gets it back or something

var target_rock : Rock
var target_rock_has_been_touched : bool

var total_rocks_given : int = Globals.total_rocks_given

var num_reserve_throwing_rocks : int = total_rocks_given
var num_incoming_throwing_rocks : int = 0
var throwzone_rocks = [] # list of Rocks in ThrowZone

var rocks_with_justspawned_collisionness = []

var beuld_topmid : Vector2
const beuld_top_area_height = 10.0 # height of boulder top detection zone for clearing top
var beuld_top_area : Area2D
var beuld_top_obstructors = []

var score : int = 0

var mistakes_made : int = 0


func _ready():
	beuld_topmid = beuld.global_transform.xform(beuld.top_mid())
	initialize_beuld_top_area()
	
	consider_providing_throwing_rocks(0.05)
	
	place_new_target_rock()
	
	update_throwing_rocks_remaining_label()
	$StatusText/VBoxContainer/ScoreLabel.text = Strings.rocks_knocked(score)


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
	$StatusText/VBoxContainer/ScoreLabel.text = Strings.rocks_knocked(score)


func temporarily_grant_justspawned_collisionness(rock : Rock):
	rocks_with_justspawned_collisionness.append(rock)
	
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
	
	get_tree().create_timer(1.5).connect("timeout",self,"end_justspawned_collisionness",[rock,a])
	rock.connect("got_held",self,"end_justspawned_collisionness",[rock,a],CONNECT_ONESHOT)
	
	
func end_justspawned_collisionness(rock : Rock, inner_circle : Area2D):
	if not is_instance_valid(rock) or not rock in rocks_with_justspawned_collisionness:
		return
	for body in inner_circle.get_overlapping_bodies():
		if body is Rock and body.name != rock.name:
			get_tree().create_timer(0.2).connect("timeout",self,"end_justspawned_collisionness",[rock,inner_circle])
			rock.set_holdable(false,"")
			body.raise()
			return
#	rock.modulate = Color(1,1,1) # uncomment for debugging
	rock.collision_mask = 0b01 # can phase through throwzone barrier again
	rock.collision_layer = 0b11 # will collide with all rocks
	rock.set_holdable(true)
	inner_circle.queue_free()
	rocks_with_justspawned_collisionness.erase(rock)


func update_throwing_rocks_remaining_label() -> void:
	$StatusText/VBoxContainer/ThrowingRocksRemainingLabel.text = Strings.throwing_remaining(throwing_rocks_remaining())


func throwing_rocks_remaining() -> int:
	return num_reserve_throwing_rocks + num_incoming_throwing_rocks + len(throwzone_rocks)


func place_new_target_rock():
	if game_might_end:
		$DelayTillSpawnTarget.start()
		return
	if not beuld_top_obstructors.empty():
		show_message(Strings.removing_obstructions(),$DelayTillSpawnTarget.wait_time)
		for rock in beuld_top_obstructors:
			rock.schwoop_delete()
			beuld_top_obstructors.erase(rock)
		$DelayTillSpawnTarget.start()
		return
	
	# Introduce new target rock
	target_rock = Rock.new()
	$RockList.add_child(target_rock)
	target_rock.position += beuld_topmid-target_rock.global_transform.xform(target_rock.center_of_mass())+Vector2(0,-20-target_rock.flat_bottom())
	target_rock.set_holdable(false,Strings.cant_hold_target())
	target_rock.connect("body_entered",self,"_on_target_rock_contact")
	target_rock.connect("clicked_yet_unholdable",self,"_on_clicked_yet_unholdable",[target_rock])
	target_rock_has_been_touched = false


func _on_target_rock_contact(body):
	if body is Boulder or not (body is Rock): return # We only care about non-boulder rocks
	if body in $RockList.get_children():
		target_rock_has_been_touched = true


func _on_LineOfPebbles_rock_lost(rock : Rock):
	if scene_shutting_down or game_has_ended:
		return
	throwzone_rocks.erase(rock)
	update_throwing_rocks_remaining_label()
	if throwing_rocks_remaining() <= 0:
		# initiate possible endgame sequence
		rock.monitor_stopped = true
		game_might_end = true
		if not rock.is_connected("stopped",self,"_last_rock_stopped"):
			rock.connect("stopped",self,"_last_rock_stopped",[rock],CONNECT_ONESHOT)
		if not rock.is_connected("tree_exited",self,"_last_rock_gone"):
			rock.connect("tree_exited",self,"_last_rock_gone",[],CONNECT_ONESHOT)
		$EndGameFailsafe.start()
	consider_providing_throwing_rocks(1.0)


func consider_providing_throwing_rocks(delay_of_the_second_rock : float) -> void:
	if num_incoming_throwing_rocks + len(throwzone_rocks) == 0 and num_reserve_throwing_rocks > 0:
		num_reserve_throwing_rocks -= 1
		num_incoming_throwing_rocks += 1
		order_throwing_rock(0.05)
	if num_incoming_throwing_rocks + len(throwzone_rocks) == 1 and num_reserve_throwing_rocks > 0:
		num_reserve_throwing_rocks -= 1
		num_incoming_throwing_rocks += 1
		order_throwing_rock(delay_of_the_second_rock)


func order_throwing_rock(delay : float) -> void:
	assert(delay > 0.0)
	var original_delivery_timer = get_tree().create_timer(delay)
	original_delivery_timer.connect("timeout",self,"_on_delivery_timer_timeout")


func _on_delivery_timer_timeout() -> void:
	var rock : Rock = spawn_rock($RockSpawnBox)
	if not rock:
		var retry_delivery_timer = get_tree().create_timer(0.7)
		retry_delivery_timer.connect("timeout",self,"_on_delivery_timer_timeout")
	else:
		rock.connect("clicked_yet_unholdable",self,"_on_clicked_yet_unholdable",[rock])
		temporarily_grant_justspawned_collisionness(rock)
		throwzone_rocks.append(rock)
		num_incoming_throwing_rocks -= 1


func _last_rock_stopped(rock : Rock) -> void:
	rock.monitor_stopped = false
	rock.disconnect("tree_exited",self,"_last_rock_gone")
	$DelayTillEndGame.start()


func _last_rock_gone() -> void:
	if scene_shutting_down or game_has_ended: return # in case game already ended due to EndGameFailsafe
	$DelayTillEndGame.start()


func special_mode_condition_met() -> bool :
	return score > total_rocks_given and total_rocks_given >= 5


func _on_DelayTillEndGame_timeout():
	if throwing_rocks_remaining() <= 0 and not game_has_ended:
		game_has_ended = true
		$EndgameRufflePlayer.play()
		if not special_mode_condition_met():
			show_message(Strings.endgame_message(score,total_rocks_given),-1)
	elif throwing_rocks_remaining() > 0:
		game_might_end = false


func _on_EndgameRufflePlayer_finished():
	if special_mode_condition_met():
		scene_shutting_down = true
		get_tree().change_scene_to(load("GameChallengeSpecial.tscn"))


func _on_LineOfPebbles_rock_regained(rock : Rock):
	if scene_shutting_down or game_has_ended: return
	throwzone_rocks.append(rock)
	update_throwing_rocks_remaining_label()
	$EndGameFailsafe.stop()


func _on_ThrowZone_mouse_exited():
	cursor_changeable = false
	Input.set_custom_mouse_cursor(splayed_hand,Input.CURSOR_ARROW,Vector2(21,27))
	for rock in throwzone_rocks:
		if rock.is_held:
			rock.set_held(false)


func _on_ThrowZone_mouse_entered():
	cursor_changeable = true
	var some_rock_is_held = false
	for rock in $RockList.get_children():
		if rock.is_held:
			some_rock_is_held = true
			break
	Input.set_custom_mouse_cursor(closed_hand if some_rock_is_held else open_hand,Input.CURSOR_ARROW,Vector2(21,27))

func _on_clicked_yet_unholdable(reason : String, rock : Rock):
	if not game_has_ended and reason != "":
		var message = Message.new(reason,1.5,15)
		add_child(message)
		message.set_botmid_position(rock.topmost_vertex())


func show_message(msg : String, time : float = 1, size : int = 40):
	var message = Message.new(msg,time,size)
	message.set_topleft_position(Vector2(200,200))
	add_child(message)
	
	
	
	
	
	
