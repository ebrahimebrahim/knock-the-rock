extends RigidBody2D

const RockPolygon = preload("res://RockPolygon.gd")

var rock_polygon : RockPolygon
var is_held : bool = false setget set_held
var local_hold_point : Vector2

enum KnockType {ROCK, GRASS}
var audio = {} # dict mapping KnockType to AudioStreamPlayer2D
const audio_resources = {
	KnockType.ROCK  : [preload("res://sounds/knock01.wav"),preload("res://sounds/knock02.wav")],
	KnockType.GRASS : [preload("res://sounds/pff01.wav"),preload("res://sounds/pff02.wav")]
}
var audio_timer : Timer



# This is in units of force per distance, like a "spring constant"
# It's the strength of the player holding the rock, in some sense

const hold_strength : float = 2000.0
# This will be determined based on mass to ensure critical damping
# (i.e. put just enough "friction" in the "spring" to stop oscillations)
var hold_damping : float
# A timer that starts when the rock is grabbed
# After the time is up, any collisions will release the rock
var held_collision_immunity_timer : Timer


func _init():
	rock_polygon = generate_rock_polygon()
	add_child(rock_polygon)
	
	mass = pow(rock_polygon.calculate_area()/1000,1.5)
	hold_damping = 2*sqrt(hold_strength * mass)
	held_collision_immunity_timer = Timer.new()
	add_child(held_collision_immunity_timer)
	held_collision_immunity_timer.one_shot = true
	held_collision_immunity_timer.wait_time = 0.5
	
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
	


func generate_rock_polygon():
	return RockPolygon.new()


func generate_collision_shape():
	var triangles : PoolIntArray = Geometry.triangulate_polygon(rock_polygon.vertices)
	assert(len(triangles)%3==0)
	for i in range(len(triangles)/3):
		var triangle = PoolVector2Array([rock_polygon.vertices[triangles[3*i]],
										 rock_polygon.vertices[triangles[3*i+1]],
										 rock_polygon.vertices[triangles[3*i+2]]])
		var c = CollisionShape2D.new()
		add_child(c)
		c.shape = ConvexPolygonShape2D.new()
		c.shape.points = triangle


func _process(delta):
	if position.y > get_tree().get_root().get_size_override().y + 400:
		queue_free()


func set_held(val : bool) -> void:
	is_held = val
	gravity_scale = 0.0 if is_held else 1.0
	if is_held:
		sleeping = false # wake up object if it just got held
		held_collision_immunity_timer.start()


func _input(event):
	_on_input(event) # this step is necessary to allow Boulder to override this function


func _on_input(event):
	# on click, hold rock
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		var vertices_global = PoolVector2Array()
		for v in rock_polygon.vertices:
			vertices_global.push_back(global_transform.xform(v))
		if Geometry.is_point_in_polygon(event.position,vertices_global):
			set_held(true)
			local_hold_point = global_transform.xform_inv(event.position)
	if is_held:
		# on release, release rock
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
			set_held(false)





func _integrate_forces(state):
	if is_held:
#		var target_pos = global_transform.xform(get_viewport().get_mouse_position() - local_hold_point)
		var restore_impulse = state.get_step() * hold_strength * (get_viewport().get_mouse_position() - position)
		var damp_impulse = - state.get_step() * hold_damping * linear_velocity
		apply_central_impulse(restore_impulse + damp_impulse)
	if state.get_contact_count() != 0:
		var obj = state.get_contact_collider_object(0)
		var impact_vel = abs((state.get_contact_collider_velocity_at_position(0)-linear_velocity).dot(state.get_contact_local_normal(0)))
		if impact_vel > 70 :
			if held_collision_immunity_timer.is_stopped(): set_held(false)
			if (obj is RigidBody2D) and (mass <= obj.mass):
				knock(impact_vel,mass,KnockType.ROCK)
			if (obj is StaticBody2D):
				knock(impact_vel,mass,KnockType.GRASS)


func knock(impact_vel : float, lighter_mass : float, knock_type):
	if audio_timer.is_stopped():
		audio[knock_type].volume_db = (20.0/log(10.0)) * log(impact_vel/200.0)
		audio[knock_type].pitch_scale = exp(-lighter_mass/12.7  +  0.48)
		audio[knock_type].play()
		audio_timer.start()


# Rotate the rock so that its bottom is a long flat edge
# Return vertical distance from rock origin to that flat edge
func flat_bottom() -> float:
	var edge_lengths = []
	for i in range(len(rock_polygon.vertices)):
		edge_lengths.push_back((rock_polygon.vertices[i] - rock_polygon.vertices[(i+1)%len(rock_polygon.vertices)]).length_squared())
	var max_edge_length : float = edge_lengths.max()
	var argmax : int = edge_lengths.find(max_edge_length)
	var v : Vector2 = rock_polygon.vertices[argmax] - rock_polygon.vertices[(argmax+1)%len(rock_polygon.vertices)]
	rotation = -v.angle()
	
	var u : Vector2 = v.normalized()
	return (rock_polygon.vertices[argmax] - rock_polygon.vertices[argmax].dot(u)*u).length()


# Returns the global coords of the vertex that is leftmost in global coords
func leftmost_vertex() -> Vector2:
	return rock_polygon.leftmost_vertex()


# Returns the global coords of the vertex that is rightmost in global coords
func rightmost_vertex() -> Vector2:
	return rock_polygon.rightmost_vertex()


# Returns the center of mass, aka centroid, of the rock polygon in local coords
func center_of_mass() -> Vector2:
	return rock_polygon.center_of_mass()
