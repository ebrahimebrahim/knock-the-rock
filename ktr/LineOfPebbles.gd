extends Line2D

const RockPolyon = preload("RockPolygon.gd")
const Rock = preload("Rock.gd")

const pebble_scale = 0.1

var num_pebbles : int


func _ready():
	self_modulate = Color(0,0,0,0) # Make line not visible w/o hiding child pebbles
	
	assert(len(points)==2)
	var line_length = (points[1]-points[0]).length()
	num_pebbles = 3 + randi()%3
	for i in range(num_pebbles):
		var pebble_polygon = RockPolyon.new()
		pebble_polygon.scale = pebble_scale * Vector2(1,1)
		add_child(pebble_polygon)
		pebble_polygon.position = points[0] + float(i)/(num_pebbles-1) * (points[1]-points[0])


func _on_ThrowZone_body_exited(body):
	if body is Rock:
		body.holdable=false
		if body.is_held:
			Input.set_custom_mouse_cursor(preload("res://images/splayed_hand.png"),Input.CURSOR_ARROW,Vector2(21,27))
			body.set_held(false)
