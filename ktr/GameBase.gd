extends Node2D

const Boulder = preload("res://Boulder.gd")
const Rock = preload("res://Rock.gd")

var scrolling_bg : bool = false
var change_scene_to : String
var scene_shutting_down : bool = false # true if the scene is about to unload

const open_hand = preload("res://images/open_hand.png")
const closed_hand = preload("res://images/closed_hand.png")
const splayed_hand = preload("res://images/splayed_hand.png")
var cursor_changeable = true

var beuld : Boulder

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	$MenuZone/ReturnButton.connect("button_up",self,"_on_return")
	$MenuZone/RestartButton.connect("button_up",self,"_on_restart")
	$MenuZone/HelpButton.connect("button_up",self,"_on_help")
	$HelpOverlay/Help.connect("hide_help",self,"_on_help")
	Input.set_custom_mouse_cursor(open_hand,Input.CURSOR_ARROW,Vector2(21,27))
	
	beuld = Boulder.new()
	add_child(beuld)
	move_child(beuld, $RockList.get_index())
	beuld.set_position(random_point_on_line($BoulderBotRight)-beuld.bottom_right())
	
	$MenuZone.visible = not Globals.corner_menu_hidden_by_default
	setup_ui_labels()

func _input(event):
	if event.is_action_pressed("return_to_menu"): _on_return()
	if event.is_action_pressed("restart"): _on_restart()
	if event.is_action_pressed("open_help"): _on_help()
	if event.is_action_pressed("toggle_hud"): _on_toggle()
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT: update_cursor()

# Spawn a number of non-intersecting rocks within the given box
# The box should be a node that has two Position2D children
# Returns a list of the spawned rocks
# optionally boundaries can be an Array of two floats: the left and right boundary
# in which the rocks should be spawned
func spawn_rocks(num_rocks : int, spawn_box : Node, boundaries = []):
	assert(spawn_box.get_child_count() == 2)
	var rocks = []
	for _i in range(num_rocks):
		var rock : Rock = Rock.new()
		$RockList.add_child(rock)
		var num_positioning_attempts = 0
		var positioning_failed = false
		while true:
			rock.set_position(random_point_in_box(spawn_box))
			var rock_intersects_some_other_rock = false
			var r_l = rock.leftmost_vertex().x
			var r_r = rock.rightmost_vertex().x
			var r_t = rock.topmost_vertex().y
			var r_b = rock.botmost_vertex().y
			for other in $RockList.get_children():
				if not other == rock:
					var o_l = other.leftmost_vertex().x
					var o_r = other.rightmost_vertex().x
					var o_t = other.topmost_vertex().y
					var o_b = other.botmost_vertex().y
					if r_r > o_l and o_r > r_l and r_b > o_t and o_b > r_t:
						rock_intersects_some_other_rock = true
			var rock_within_boundaries = true
			if not boundaries.empty():
				assert(len(boundaries)==2)
				rock_within_boundaries = r_l > boundaries[0] and r_r < boundaries[1]
			if not rock_intersects_some_other_rock and rock_within_boundaries:
				break
			num_positioning_attempts += 1
			if num_positioning_attempts > 20:
				positioning_failed = true
				break
		rocks.append(rock)
		if positioning_failed:
			for r in rocks:
				r.queue_free()
			yield(get_tree().create_timer(3.0),"timeout")
			return spawn_rocks(num_rocks,spawn_box,boundaries)
	return rocks

# returns a random point in a box, the box being a node which has a "TopLeft" child and a "BotRight" child (their coordinates should be global anyway bc of their ancestry) 
func random_point_in_box(box : Node):
	assert(box.get_child_count() == 2)
	return Vector2(rand_range(box.get_children()[0].position.x,box.get_children()[1].position.x),rand_range(box.get_children()[0].position.y,box.get_children()[1].position.y))

# returns random point on given line, in global coords
func random_point_on_line(line : Line2D):
	assert(len(line.points)==2)
	return (line.points[0]+randf()*(line.points[1] - line.points[0])) + line.global_position

func _on_return():
	scene_shutting_down = true
	if scrolling_bg : get_tree().quit() # allows double tap esc to quit
	scroll_bg("res://MenuScreen.tscn")

func _on_restart():
	scene_shutting_down = true
	get_tree().reload_current_scene()

func _on_help():
	$HelpOverlay.visible = not $HelpOverlay.visible

func _on_toggle():
	if $MenuZone.visible: $MenuZone.hide()
	else: $MenuZone.show()

func scroll_bg(scene):
	for child in get_children():
		if child.name != "bg" and child is Node2D : child.visible = false
	scrolling_bg = true
	change_scene_to = scene

func _process(delta):
	if scrolling_bg:
		if $bg.position.y < 494:
			$bg.position.y += 1200*delta
		else:
			scrolling_bg = false
			get_tree().change_scene(change_scene_to)

func update_cursor():
	if cursor_changeable:
		if Input.is_action_pressed("click"): Input.set_custom_mouse_cursor(closed_hand,Input.CURSOR_ARROW,Vector2(21,27))
		else: Input.set_custom_mouse_cursor(open_hand,Input.CURSOR_ARROW,Vector2(21,27))


func setup_ui_labels():
	$MenuZone/ReturnButton.text = Strings.ui_label("return btn")
	$MenuZone/RestartButton.text = Strings.ui_label("restart btn")
	$MenuZone/HelpButton.text = Strings.ui_label("help btn corner menu")
	$MenuZone/Panel/ToggleMenuLabel.text = Strings.ui_label("toggle corner menu lbl")
