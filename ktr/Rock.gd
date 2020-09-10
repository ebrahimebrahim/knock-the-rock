extends RigidBody2D


var vertices : PoolVector2Array
var color = Color(0.6, 0.6, 0.6)


# Called when the node enters the scene tree for the first time.
func _ready():
	vertices = PoolVector2Array([Vector2(-20,-10),Vector2(0,10),Vector2(20,-10),Vector2(0,-100)])
	
	var collision_shape : CollisionShape2D = CollisionShape2D.new()
	add_child(collision_shape)
	
	# make ConcavePolygonShape2D if most rocks concave
	collision_shape.shape = ConvexPolygonShape2D.new()
	
	collision_shape.shape.points =  vertices

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	draw_polygon(vertices,[color])
	draw_polyline(vertices,Color(0.0,0.0,0.0),2.0,true)
	draw_line(vertices[-1],vertices[0],Color(0.0,0.0,0.0),2.0,true)
