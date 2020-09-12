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
var timer : Timer

signal knock(impact_vel,impact_pos,lighter_mass)

# Called when the node enters the scene tree for the first time.
func _ready():	
	generate_texture()
	self_modulate = generate_color()
	generate_polygon()
	mass = calculate_area()
	
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
	audio.set_stream(knock_sounds[rand_range(0,len(knock_sounds))])
	
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 0.2 # between audio clips

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
	if state.get_contact_count()!=0:
		var obj = state.get_contact_collider_object(0)
		if (not obj is RigidBody2D) or mass <= obj.mass:
			var impact_vel = abs((state.get_contact_collider_velocity_at_position(0)-linear_velocity).dot(state.get_contact_local_normal(0)))
			if impact_vel > 70 :
#				print(str((state.get_contact_collider_velocity_at_position(0)-linear_velocity).dot(state.get_contact_local_normal(0)))+"   "+str(linear_velocity.y))
				var impact_pos = state.get_contact_collider_position(0)
				knock(impact_vel,impact_pos,mass)

func knock(impact_vel,impact_pos,lighter_mass):
	if timer.is_stopped():
		audio.position = impact_pos
		audio.volume_db = min((impact_vel - 200)/50  -  20 , 18)
		audio.pitch_scale = exp(-lighter_mass/1864  +  0.941944)
		audio.play()
		timer.start()
