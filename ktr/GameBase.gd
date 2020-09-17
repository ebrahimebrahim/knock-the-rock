extends Node2D

const Boulder = preload("res://Boulder.gd")

var scrolling_bg : bool = false
var change_scene_to : String

var open_hand = preload("res://images/open_hand.png")
var closed_hand = preload("res://images/closed_hand.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	$HUDZone/ReturnButton.connect("button_up",self,"_on_return")
	$HUDZone/RestartButton.connect("button_up",self,"_on_restart")
	$HUDZone/HelpButton.connect("button_up",self,"_on_help")
	$HelpOverlay/Help.connect("hide_help",self,"_on_help")
	Input.set_custom_mouse_cursor(open_hand,Input.CURSOR_ARROW,Vector2(21,27))
	
	var beuld : Boulder = Boulder.new()
	add_child(beuld)
	beuld.set_position(random_point_on_line($BoulderBotRight)-beuld.bottom_right())

func _input(event):
	if event.is_action_pressed("return_to_menu"): _on_return()
	if event.is_action_pressed("restart"): _on_restart()
	if event.is_action_pressed("open_help"): _on_help()
	if event.is_action_pressed("toggle_hud"): _on_toggle()
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT: update_cursor()

func random_point_on_line(line : Line2D):
	assert(len(line.points)==2)
	return line.points[0]+randf()*(line.points[1] - line.points[0])

func _on_return():
	if scrolling_bg : get_tree().quit() # allows double tap esc to quit
	scroll_bg("res://MenuScreen.tscn")

func _on_restart():
	get_tree().reload_current_scene()

func _on_help():
	$HelpOverlay.visible = not $HelpOverlay.visible

func _on_toggle():
	if $HUDZone.visible: $HUDZone.hide()
	else: $HUDZone.show()

func scroll_bg(scene):
	for child in get_children():
		if child.name != "bg": child.queue_free()
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
	if Input.is_action_pressed("click"): Input.set_custom_mouse_cursor(closed_hand,Input.CURSOR_ARROW,Vector2(21,27))
	else: Input.set_custom_mouse_cursor(open_hand,Input.CURSOR_ARROW,Vector2(21,27))
