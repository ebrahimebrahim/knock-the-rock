extends Line2D

const RockPolyon = preload("RockPolygon.gd")

const pebble_scale = 0.1

var num_pebbles : int


func _ready():
	assert(len(points)==2)
	var line_length = (points[1]-points[0]).length()
	num_pebbles = 3 + randi()%3
	for i in range(num_pebbles):
		var pebble_polygon = RockPolyon.new()
		pebble_polygon.scale = pebble_scale * Vector2(1,1)
		add_child(pebble_polygon)
		pebble_polygon.position = points[0] + float(i)/(num_pebbles-1) * (points[1]-points[0])