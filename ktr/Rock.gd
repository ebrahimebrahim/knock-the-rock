extends RigidBody2D

var vertices = PoolVector2Array()
var texture_uvs = PoolVector2Array()
var texture : ImageTexture

# Called when the node enters the scene tree for the first time.
func _ready():	
	generate_texture()
	
	generate_polygon()
	
	var collision_shape : CollisionShape2D = CollisionShape2D.new()
	add_child(collision_shape)
	
	# make ConcavePolygonShape2D if most rocks concave
	collision_shape.shape = ConvexPolygonShape2D.new()
	collision_shape.shape.points =  vertices

func generate_texture():
	texture = ImageTexture.new()
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 6
	noise.period = 256
	noise.persistence = 1
	noise.lacunarity = 2.54
	var img = noise.get_image(16,16)
	rockify_image(img)
	texture.create_from_image(img)
	texture.set_flags(texture.FLAGS_DEFAULT & ~(texture.FLAG_REPEAT))

func rockify_image(img : Image) -> void:
	pass

func generate_polygon():
	var r = rand_range(20,45)
	var n = rand_range(5,15)
	var dt = 2*PI/n
	var mini_r = r*sin(dt/2)
	var new_vert = Vector2(0,0)
	var stretch = exp(rand_range(-0.5,0.5))
	var rot = rand_range(0,2*PI)
	for i in range(n):
		var mini_c = r*Vector2(cos(dt*i),sin(dt*i))
		while(new_vert.distance_to(mini_c) >= mini_r):
			new_vert = Vector2(rand_range(mini_c.x-mini_r,mini_c.x+mini_r),rand_range(mini_c.y-mini_r,mini_c.y+mini_r))
		new_vert.x *= stretch
		new_vert = new_vert.rotated(rot)
		vertices.push_back(new_vert)
		
		texture_uvs.push_back(0.5*(Vector2(cos(dt*i),sin(dt*i)) + Vector2(1,1)))

func _draw():
	draw_polygon(vertices, [], texture_uvs, texture)
	draw_polyline(vertices,Color(0.0,0.0,0.0),2.0,true)
	draw_line(vertices[-1],vertices[0],Color(0.0,0.0,0.0),2.0,true)
