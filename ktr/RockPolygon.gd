extends Node2D

var vertices = PoolVector2Array()
var texture_uvs = PoolVector2Array()
var texture : ImageTexture

const colors = [Color("565656"),
				Color("ffffff"),
				Color("635353"),
				Color("6f5e3f"),
				Color("7d7e57")]


# The generate_polygons parameter can be optionally set to hold back polygon generation
# This is useful for subclasses of RockPolygon that want to delay polygon generation until
# they are ready. See the weird "_init().(blah)" notation here: 
# https://docs.godotengine.org/en/3.2/getting_started/scripting/gdscript/gdscript_basics.html#class-constructor
func _init(generate_polygons = true):
	generate_texture()
	self_modulate = generate_color()
	if generate_polygons:
		generate_polygon()
	

func generate_texture():
	texture = ImageTexture.new()
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 6
	noise.period = 256
	noise.persistence = 1
	noise.lacunarity = 2.54
	var img = noise.get_image(32,32)
	rockify_image(img)
	texture.create_from_image(img)
	texture.set_flags(texture.FLAGS_DEFAULT & ~(texture.FLAG_REPEAT))


func rockify_image(img : Image) -> void:
	img.convert(img.FORMAT_L8) # convert to grayscale
	for i in range(len(img.data["data"])):
		img.data["data"][i] = (img.data["data"][i]/32)*32


func generate_color() -> Color:
	var output_color = colors[randi()%colors.size()]
	for _i in range(3):
		output_color = output_color.linear_interpolate(colors[randi()%colors.size()],randf())
	return output_color


func random_point_in_disk(center : Vector2, radius : float):
	var output = center+100*Vector2(radius,0)
	while(output.distance_to(center) >= radius):
		output = Vector2(rand_range(center.x-radius,center.x+radius),rand_range(center.y-radius,center.y+radius))
	return output


func generate_polygon():
	var r = rand_range(20,45)
	var n = 5 + randi()%11
	var dt = 2*PI/n
	var mini_r = r*sin(dt/2)
	var stretch = exp(rand_range(-0.5,0.5))
	var rot = rand_range(0,2*PI)
	for i in range(n):
		var new_vert = random_point_in_disk(r*Vector2(cos(dt*i),sin(dt*i)),mini_r)
		new_vert.x *= stretch
		new_vert = new_vert.rotated(rot)
		vertices.push_back(new_vert)
		
		texture_uvs.push_back(0.5*(Vector2(cos(dt*i),sin(dt*i)) + Vector2(1,1)))


func calculate_area():
	var area = 0
	for i in range(len(vertices)):
		area += vertices[i].cross(vertices[(i+1)%len(vertices)])/2
	return area


func _draw():
	draw_polygon(vertices, [], texture_uvs, texture)
	draw_polyline(vertices,Color(0.0,0.0,0.0),2.0,true)
	draw_line(vertices[-1],vertices[0],Color(0.0,0.0,0.0),2.0,true)
	

# Returns the center of mass, aka centroid, of the polygon in local coords
func center_of_mass() -> Vector2:
	var x : float = 0
	var y : float = 0
	for i in range(len(vertices)):
		var vi = vertices[i]
		var vi1 = vertices[(i+1)%len(vertices)]
		x += (vi.x + vi1.x)*(vi.x * vi1.y - vi1.x * vi.y)
		y += (vi.y + vi1.y)*(vi.x * vi1.y - vi1.x * vi.y) 
	return 1/(6 * calculate_area()) * Vector2(x,y)


# Returns the global coords of the vertex that is leftmost in global coords
func leftmost_vertex() -> Vector2:
	var xs = []
	for v in vertices:
		xs.push_back(get_global_transform().xform(v).x)
	var argmin = xs.find(xs.min())
	return get_global_transform().xform(vertices[argmin])


# Returns the global coords of the vertex that is rightmost in global coords
func rightmost_vertex() -> Vector2:
	var xs = []
	for v in vertices:
		xs.push_back(get_global_transform().xform(v).x)
	var argmax = xs.find(xs.max())
	return get_global_transform().xform(vertices[argmax])


# Returns a bounding rectangle in global coords
func bounding_rect() -> Rect2:
	var xs = []
	var ys = []
	for v in vertices:
		var v_global : Vector2 = get_global_transform().xform(v)
		xs.push_back(v_global.x)
		ys.push_back(v_global.y)
	var x_min : float = xs.min()
	var y_min : float = ys.min()
	return Rect2(x_min,y_min,xs.max()-x_min,ys.max()-y_min)


# Return the position and radius of an interior circle of maximal radius centered at the center of mass
# The position is in local coordinates
func get_inner_circle() -> Array:
	var srads = []
	var c = center_of_mass()
	for i in range(len(vertices)):
		var v1 : Vector2 = vertices[i]
		var v2 : Vector2 = vertices[(i+1)%len(vertices)]
		var acute : bool = (c-v1).dot(v2-v1) > 0 and (c-v2).dot(v1-v2) > 0 
		if acute:		
			var l : Vector2 = v2 - v1
			var lnn : Vector2 = (1/l.length_squared()) * l
			srads.push_back(
				((v1 - c) - (l.dot(v1 - c)) * lnn ).length_squared()
			)
		else:
			srads.push_back(c.distance_squared_to(v1))
			srads.push_back(c.distance_squared_to(v2))
	return [c,sqrt(srads.min())]
