extends RigidBody2D

var vertices : PoolVector2Array
var color = Color(0.6, 0.6, 0.6)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # <~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ this was added so that it's not the SAME random number every time
	vertices = generate_vertices()
	
	var collision_shape : CollisionShape2D = CollisionShape2D.new()
	add_child(collision_shape)
	
	# make ConcavePolygonShape2D if most rocks concave
	collision_shape.shape = ConvexPolygonShape2D.new()
	
	collision_shape.shape.points =  vertices

# Called every frame. 'delta' is the elapsed time since the previous frame. <~~~~~~~~~~~~~~~~~~~~ can we get rid of this?
#func _process(delta):
#	pass

func generate_vertices():
	var r = rand_range(10,50)
	var n = rand_range(3,15)
	var dt = 2*PI/n
	var verts = PoolVector2Array()
	var mini_r = r*sin(dt/2)
	var mini_c : Vector2
	var new_vert = Vector2(0,0)
	for i in range(n):
		mini_c = Vector2(r*cos(dt*i),r*sin(dt*i))
		while(new_vert.distance_to(mini_c) >= mini_r):
			new_vert = Vector2(rand_range(mini_c.x-mini_r,mini_c.x+mini_r),rand_range(mini_c.y-mini_r,mini_c.y+mini_r))
		verts.push_back(new_vert)
	return verts

func _draw():
	draw_polygon(vertices, [color])
	draw_polyline(vertices,Color(0.0,0.0,0.0),2.0,true)
	draw_line(vertices[-1],vertices[0],Color(0.0,0.0,0.0),2.0,true)
