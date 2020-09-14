extends RigidBody2D

var vertices = PoolVector2Array()
var texture_uvs = PoolVector2Array()
var texture : ImageTexture

const colors = [Color("565656"),
				Color("ffffff"),
				Color("635353"),
				Color("6f5e3f"),
				Color("7d7e57")]

var is_held : bool = false setget set_held
var local_hold_point : Vector2

enum KnockType {ROCK, GRASS}
var audio = {} # dict mapping KnockType to AudioStreamPlayer2D
const audio_resources = {
	KnockType.ROCK  : [preload("res://sounds/knock01.wav"),preload("res://sounds/knock02.wav")],
	KnockType.GRASS : [preload("res://sounds/pff01.wav"),preload("res://sounds/pff02.wav")]
}
var audio_timer : Timer


func _init():
	generate_texture()
	self_modulate = generate_color()
	generate_polygon()
	mass = pow(calculate_area()/1000,1.5)
	
	continuous_cd = CCD_MODE_CAST_RAY # might make this an option
	var phys = PhysicsMaterial.new()
	phys.bounce = 0.15
	phys.friction = 1
	phys.rough = true
	set_physics_material_override(phys)
	
	generate_collision_shape()
	
	contact_monitor = true
	contacts_reported = 1
	
	for knock_type in audio_resources.keys():
		var audio_player = AudioStreamPlayer2D.new()
		audio_player.set_stream(audio_resources[knock_type][randi() % len(audio_resources[knock_type])])
		add_child(audio_player)
		audio[knock_type] = audio_player
	
	audio_timer = Timer.new()
	add_child(audio_timer)
	audio_timer.one_shot = true
	audio_timer.wait_time = 0.2 # between audio clips

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


func generate_collision_shape():
	var triangles : PoolIntArray = Geometry.triangulate_polygon(vertices)
	assert(len(triangles)%3==0)
	for i in range(len(triangles)/3):
		var triangle = PoolVector2Array([vertices[triangles[3*i]],vertices[triangles[3*i+1]],vertices[triangles[3*i+2]]])
		var c = CollisionShape2D.new()
		add_child(c)
		c.shape = ConvexPolygonShape2D.new()
		c.shape.points = triangle


func _draw():
	draw_polygon(vertices, [], texture_uvs, texture)
	draw_polyline(vertices,Color(0.0,0.0,0.0),2.0,true)
	draw_line(vertices[-1],vertices[0],Color(0.0,0.0,0.0),2.0,true)


func _process(delta):
	if position.y > get_tree().get_root().get_size_override().y + 400:
		queue_free()


func set_held(val : bool) -> void:
	is_held = val
	mode = MODE_KINEMATIC if is_held else MODE_RIGID


func _input(event):
	_on_input(event) # this step is necessary to allow Boulder to override this function


func _on_input(event):
	# on click, hold rock
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		var vertices_global = PoolVector2Array()
		for v in vertices:
			vertices_global.push_back(global_transform.xform(v))
		if Geometry.is_point_in_polygon(event.position,vertices_global):
			set_held(true)
			local_hold_point = global_transform.xform_inv(event.position)
	if is_held:
		# on release, release rock
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
			set_held(false)
		# on motion, move rock
		if event is InputEventMouseMotion:
			# want global_transform.xform(local_hold_point) == event.position
			position = global_transform.xform(global_transform.xform_inv(event.position) - local_hold_point)


func _integrate_forces(state):
	if state.get_contact_count() != 0:
		var obj = state.get_contact_collider_object(0)
		var impact_vel = abs((state.get_contact_collider_velocity_at_position(0)-linear_velocity).dot(state.get_contact_local_normal(0)))
		var impact_pos = state.get_contact_collider_position(0)
		if impact_vel > 70 :
			if (obj is RigidBody2D) and (mass <= obj.mass):
				knock(impact_vel,impact_pos,mass,KnockType.ROCK)
			if (obj is StaticBody2D) and not is_held:
				knock(impact_vel,impact_pos,mass,KnockType.GRASS)


func knock(impact_vel : float, impact_pos : Vector2, lighter_mass : float, knock_type):
	if audio_timer.is_stopped():
		audio[knock_type].position = impact_pos
		audio[knock_type].volume_db = (20.0/log(10.0)) * log(impact_vel/200.0)
		audio[knock_type].pitch_scale = exp(-lighter_mass/12.7  +  0.48)
		audio[knock_type].play()
		audio_timer.start()


# Rotate the rock so that its bottom is a long flat edge
# Return vertical distance from rock origin to that flat edge
func flat_bottom() -> float:
	var edge_lengths = []
	for i in range(len(vertices)):
		edge_lengths.push_back((vertices[i] - vertices[(i+1)%len(vertices)]).length_squared())
	var max_edge_length : float = edge_lengths.max()
	var argmax : int = edge_lengths.find(max_edge_length)
	var v : Vector2 = vertices[argmax] - vertices[(argmax+1)%len(vertices)]
	rotation = -v.angle()
	
	var u : Vector2 = v.normalized()
	return (vertices[argmax] - vertices[argmax].dot(u)*u).length()
	

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
		xs.push_back(global_transform.xform(v).x)
	var argmin = xs.find(xs.min())
	return global_transform.xform(vertices[argmin])


# Returns the global coords of the vertex that is rightmost in global coords
func rightmost_vertex() -> Vector2:
	var xs = []
	for v in vertices:
		xs.push_back(global_transform.xform(v).x)
	var argmax = xs.find(xs.max())
	return global_transform.xform(vertices[argmax])

