extends Control

var vertices = PoolVector2Array()
var texture_uvs = PoolVector2Array()
var texture : ImageTexture

const colors = [Color("565656"),
				Color("ffffff"),
				Color("635353"),
				Color("6f5e3f"),
				Color("7d7e57")]

func _ready():
	randomize()
	generate_texture()
	modulate = generate_color()
	generate_polygon()

func generate_texture():
	texture = ImageTexture.new()
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 6
	noise.period = 256
	noise.persistence = 1
	noise.lacunarity = 2.54
	var img = noise.get_image(64,64)
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


func random_point_in_disk_and_outside_disk(center_in : Vector2, radius_in : float, center_out : Vector2, radius_out : float):
	var output = center_in+100*Vector2(radius_in,0)
	while(output.distance_to(center_in) >= radius_in  or  output.distance_to(center_out)<radius_out):
		output = Vector2(rand_range(center_in.x-radius_in,center_in.x+radius_in),rand_range(center_in.y-radius_in,center_in.y+radius_in))
	return output


func generate_polygon():
	var x_radius = abs($xRadius.position.x)
	var y_radius = abs($yRadius.position.y)
	var r = y_radius
	var n = 5 + randi()%11
	var dt = 2*PI/n
	var mini_r = r*sin(dt/2)
	var stretch = x_radius / y_radius
	for i in range(n):
		var new_vert = random_point_in_disk_and_outside_disk(r*Vector2(cos(dt*i),sin(dt*i)),mini_r,Vector2(0,0),r)
		new_vert.x *= stretch
		vertices.push_back(new_vert)
		
		texture_uvs.push_back(0.5*(Vector2(cos(dt*i),sin(dt*i)) + Vector2(1,1)))


func _draw():
	draw_polygon(vertices, [], texture_uvs, texture)
	draw_polyline(vertices,Color(0.0,0.0,0.0),2.0,true)
	draw_line(vertices[-1],vertices[0],Color(0.0,0.0,0.0),2.0,true)
