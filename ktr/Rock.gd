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

var audio : AudioStreamPlayer2D
var knock_sounds = [preload("res://sounds/knock01.wav"),preload("res://sounds/knock02.wav")]
var audio_timer : Timer


# Called when the node enters the scene tree for the first time.
func _ready():	
	generate_texture()
	self_modulate = generate_color()
	generate_polygon()
	mass = pow(calculate_area(),1.5)
	
	continuous_cd = CCD_MODE_CAST_RAY # might make this an option
	var phys = PhysicsMaterial.new()
	phys.bounce = 0.15
	phys.friction = 1
	phys.rough = true
	set_physics_material_override(phys)
	
	var collision_shape : CollisionShape2D = CollisionShape2D.new()
	add_child(collision_shape)
	
	# make ConcavePolygonShape2D if most rocks concave
	collision_shape.shape = ConvexPolygonShape2D.new()
	collision_shape.shape.points = vertices
	
	contact_monitor = true
	contacts_reported = 1
	
	audio = AudioStreamPlayer2D.new()
	add_child(audio)
	audio.set_stream(knock_sounds[randi() % len(knock_sounds)])
	
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

func _draw():
	draw_polygon(vertices, [], texture_uvs, texture)
	draw_polyline(vertices,Color(0.0,0.0,0.0),2.0,true)
	draw_line(vertices[-1],vertices[0],Color(0.0,0.0,0.0),2.0,true)

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
		if ((not obj is RigidBody2D) or mass <= obj.mass) and (obj is RigidBody2D or not is_held):
			var impact_vel = abs((state.get_contact_collider_velocity_at_position(0)-linear_velocity).dot(state.get_contact_local_normal(0)))
			if impact_vel > 70 :
				var impact_pos = state.get_contact_collider_position(0)
				knock(impact_vel,impact_pos,mass)

func knock(impact_vel,impact_pos,lighter_mass):
	if audio_timer.is_stopped():
		audio.position = impact_pos
		audio.volume_db = min((impact_vel - 200)/50  -  20 , 18)
		audio.pitch_scale = exp(-lighter_mass/1864  +  0.941944)
		audio.play()
		audio_timer.start()
