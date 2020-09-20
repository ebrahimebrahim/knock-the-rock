extends Line2D

const RockPolyon = preload("RockPolygon.gd")
const Rock = preload("Rock.gd")

const pebble_scale = 0.1

var num_pebbles : int

signal rock_lost(rock)
signal rock_regained(rock)


func _ready():
	self_modulate = Color(0,0,0,0) # Make line not visible w/o hiding child pebbles
	
	assert(len(points)==2)
	num_pebbles = 3 + randi()%3
	for i in range(num_pebbles):
		var pebble_polygon = RockPolyon.new()
		pebble_polygon.scale = pebble_scale * Vector2(1,1)
		add_child(pebble_polygon)
		pebble_polygon.position = points[0] + float(i)/(num_pebbles-1) * (points[1]-points[0])


func _on_ThrowZone_body_exited(body):
	if body is Rock:
		if body.is_holdable():
			body.set_holdable(false,"No picking up rocks beyond the line of pebbles!")
			emit_signal("rock_lost",body)
		if body.is_held:
			body.set_held(false)


func _on_ThrowZone_body_entered(body):
	if body is Rock:
		if not body.is_holdable():
			body.set_holdable(true)
			emit_signal("rock_regained",body)
