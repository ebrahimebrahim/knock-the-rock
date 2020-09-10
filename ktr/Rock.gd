extends RigidBody2D

var vertices : PoolVector2Array
var color = Color(0.6, 0.6, 0.6)

# Called when the node enters the scene tree for the first time.
func _ready():
	vertices = generate_vertices()
	
	var collision_shape : CollisionShape2D = CollisionShape2D.new()
	add_child(collision_shape)
	
	# make ConcavePolygonShape2D if most rocks concave
	collision_shape.shape = ConvexPolygonShape2D.new()
	
	collision_shape.shape.points =  vertices

func generate_vertices():
	randomize()
	var r = rand_range(20,45)
	var n = rand_range(5,15)
	var dt = 2*PI/n
	var verts = PoolVector2Array()
	var mini_r = r*sin(dt/2)
	var new_vert = Vector2(0,0)
	for i in range(n):
		var mini_c = Vector2(r*cos(dt*i),r*sin(dt*i))
		while(new_vert.distance_to(mini_c) >= mini_r):
			new_vert = Vector2(rand_range(mini_c.x-mini_r,mini_c.x+mini_r),rand_range(mini_c.y-mini_r,mini_c.y+mini_r))
		verts.push_back(new_vert)
	var stretch = exp(rand_range(-0.5,0.5))
	var rot = rand_range(0,2*PI)
	for i in range(len(verts)):
		verts[i].x *= stretch
		verts[i] = verts[i].rotated(rot)
	return verts

func _draw():
	draw_polygon(vertices, [color])
	draw_polyline(vertices,Color(0.0,0.0,0.0),2.0,true)
	draw_line(vertices[-1],vertices[0],Color(0.0,0.0,0.0),2.0,true)
