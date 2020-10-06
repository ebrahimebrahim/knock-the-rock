extends Node2D

const Boulder = preload("res://Boulder.gd")
const Rock = preload("res://Rock.gd")
const Message = preload("res://Message.gd")

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

# Spawn a rock within the given box that does not intersect with any other rocks
# The box should be a node that has two Position2D children
# Returns the spawned rock or null if spawning failed
func spawn_rock(spawn_box : Node) -> Rock:
	var rock : Rock = Rock.new()
	$RockList.add_child(rock)
	var spawn_box_rect : Rect2 = box_to_rect2(spawn_box)
	for _i in range(20):
		rock.set_position(random_point_in_box(spawn_box))
		var rock_intersects_some_other_rock = false
		var rock_rect : Rect2 = rock.bounding_rect()
		for other in $RockList.get_children():
			if other == rock: continue
			var other_rect : Rect2 = other.bounding_rect()
			if rock_rect.intersects(other_rect):
				rock_intersects_some_other_rock = true
		if not rock_intersects_some_other_rock and spawn_box_rect.encloses(rock_rect):
			return rock
	rock.visible = false
	rock.queue_free()
	return null

# returns a random point in a box with coordinates relative to the box
func random_point_in_box(box : Node):
	var top_left : Position2D = box.get_node("TopLeft")
	var bot_right : Position2D = box.get_node("BotRight")
	return Vector2(rand_range(top_left.position.x,bot_right.position.x),rand_range(top_left.position.y,bot_right.position.y))

func box_to_rect2(box : Node) -> Rect2:
	var top_left : Position2D = box.get_node("TopLeft")
	var bot_right : Position2D = box.get_node("BotRight")
	return Rect2(top_left.position,bot_right.position-top_left.position)

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


# Get game screen rect
func get_screen_rect() -> Rect2:
	return Rect2(Vector2(0,0),get_tree().get_root().get_size_override())
