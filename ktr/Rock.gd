extends RigidBody2D

const RockPolygon = preload("res://RockPolygon.gd")

var rock_polygon : RockPolygon
var is_held : bool = false setget set_held
var _holdable : bool = true setget set_holdable, is_holdable
var reason_for_unholdability : String = ""
var local_hold_point : Vector2

var _schwoop_deleting : bool = false
const schwoop_delete_time : float = 3.0

signal became_unholdable
signal clicked_yet_unholdable(reason)

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

# if this is enabled we will sedate the rock when it is jiggling
# and we will awaken it when there is a nearby body
var jiggle_control = false setget set_jiggle_control
var proximity_sensor : Area2D
var recent_positions = []

# if enabled this will maintain a list of recent squared speeds
# and emit the "stopped_or_deleted" signal when velocity is small for a while
#  or when rock gets deleted
var monitor_stopped_or_deleted = false setget set_monitor_stopped_or_deleted
# the following are only used if monitor_stopped_or_deleted is enabled
var recent_sq_speeds = []
var in_motion
signal stopped_or_deleted


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
	#warning-ignore:integer_division
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
	if _schwoop_deleting:
		modulate = Color(modulate.r,modulate.g,modulate.b, max(0.0 , modulate.a - delta*(1.0/schwoop_delete_time) ) )


func set_held(val : bool) -> void:
	if val : assert(_holdable)
	is_held = val
	can_sleep = not val
	gravity_scale = 0.0 if is_held else 1.0
	if is_held:
		sleeping = false # wake up object if it just got held
		held_collision_immunity_timer.start()

func set_holdable(val : bool, reason : String = "") -> void:
	if val == false : assert(reason!="") # you'd better give a reason
	var was_holdable = _holdable
	_holdable = val
	reason_for_unholdability = reason
	if was_holdable and not _holdable : emit_signal("became_unholdable")


func is_holdable():
	return _holdable


func _input(event):
	_on_input(event) # this step is necessary to allow Boulder to override this function


func _on_input(event):
	# on click, hold rock
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		var vertices_global = PoolVector2Array()
		for v in rock_polygon.vertices:
			vertices_global.push_back(global_transform.xform(v))
		if Geometry.is_point_in_polygon(event.position,vertices_global):
			if _holdable:
				set_held(true)
				local_hold_point = global_transform.xform_inv(event.position)
			else:
				emit_signal("clicked_yet_unholdable",reason_for_unholdability)
	if is_held:
		# on release, release rock
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.is_pressed():
			set_held(false)





func _integrate_forces(state):
	if is_held:
#		var target_pos = global_transform.xform(get_viewport().get_mouse_position() - local_hold_point)
		var restore_impulse = state.get_step() * hold_strength * (get_viewport().get_mouse_position() - position)
		var damp_impulse = - state.get_step() * hold_damping * linear_velocity
		var total_impulse = restore_impulse + damp_impulse
		# The following line is a tweak for low masses. Change the 1.0 to change threshold before tweak kicks in.
		# The idea is that when mass is below 1.0, we pass an impulse vector that has been pre-scaled by mass
		# This means we are effectively treating the mass as 1.0 for the sake of determining acceleration
		total_impulse *= min(mass , 1.0) 
		apply_central_impulse(total_impulse)
	if state.get_contact_count() != 0:
		var obj = state.get_contact_collider_object(0)
		var impact_vel = abs((state.get_contact_collider_velocity_at_position(0)-linear_velocity).dot(state.get_contact_local_normal(0)))
		if impact_vel > 70 :
			if held_collision_immunity_timer.is_stopped(): set_held(false)
			if (obj is RigidBody2D) and (mass <= obj.mass):
				knock(impact_vel,mass,KnockType.ROCK)
			if (obj is StaticBody2D):
				knock(impact_vel,mass,KnockType.GRASS)


func set_jiggle_control(val : bool):
	if val and not proximity_sensor:
		proximity_sensor = Area2D.new()
		add_child(proximity_sensor)
		var proximity_collision_shape = CollisionShape2D.new()
		proximity_sensor.add_child(proximity_collision_shape)
		proximity_collision_shape.shape = CircleShape2D.new()
		var dists = []
		for v in rock_polygon.vertices:
			dists.append(rock_polygon.position.distance_squared_to(v))
		proximity_collision_shape.shape.radius = sqrt(dists.max()) + 100
	if val and not jiggle_control:
		proximity_sensor.connect("body_entered",self,"_on_nearby_body")
	if jiggle_control and not val:
		call_deferred("awaken")
		proximity_sensor.disconnect("body_entered",self,"_on_nearby_body")
	jiggle_control = val
	recent_positions = []


func set_monitor_stopped_or_deleted(val : bool):
	monitor_stopped_or_deleted = val
	if val :
		in_motion = true # guarantees that after enabling, signal WILL eventually be emitted
		connect("tree_exiting",self,"_on_delete",[],CONNECT_ONESHOT)
	recent_sq_speeds = []
func _on_delete():
	if monitor_stopped_or_deleted : emit_signal("stopped_or_deleted")


func _physics_process(_delta):
	if jiggle_control and mode==MODE_RIGID:
		recent_positions.push_back(position)
		if len(recent_positions) > 10: recent_positions.pop_front()
		if randi()%20 == 0:
			var num_negs = 0
			for i in range(len(recent_positions)-2):
				var v1 = recent_positions[i+2] - recent_positions[i+1]
				var v2 = recent_positions[i+1] - recent_positions[i]
				if v1.dot(v2) < 0:
					num_negs += 1
			if num_negs > 5: call_deferred("sedate")
	
	if monitor_stopped_or_deleted:
		recent_sq_speeds.push_back(linear_velocity.length_squared())
		if len(recent_sq_speeds) > 5:
			recent_sq_speeds.pop_front()
			var all_sqspeeds_below_lower_threshold = true
			var all_sqspeeds_above_upper_threshold = true
			for sqspeed in recent_sq_speeds:
				if sqspeed > 400 : all_sqspeeds_below_lower_threshold = false
				if sqspeed < 900 : all_sqspeeds_above_upper_threshold = false
			if all_sqspeeds_below_lower_threshold and in_motion :
				in_motion = false
				emit_signal("stopped_or_deleted")
			elif all_sqspeeds_above_upper_threshold and not in_motion:
				in_motion = true
		
		
		

func _on_nearby_body(_body):
	call_deferred("awaken")

func sedate():
	mode = MODE_STATIC
	sleeping = true
#	modulate = Color(1,0,0)


func awaken():
	mode = MODE_RIGID
	sleeping = false
	recent_positions = []
#	modulate = Color(1,1,1,1)




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


# Returns a bounding rectangle in global coords
func bounding_rect() -> Rect2:
	return rock_polygon.bounding_rect()


# Return the position and radius of an interior circle of maximal radius centered at the center of mass
# The position is in global coordinates
func get_inner_circle() -> Array:
	return rock_polygon.get_inner_circle()


# Returns the center of mass, aka centroid, of the rock polygon in local coords
func center_of_mass() -> Vector2:
	return rock_polygon.center_of_mass()


# Vacuum the rock into the sky and then delete it
func schwoop_delete():
	_schwoop_deleting = true
	call_deferred("awaken")
	gravity_scale = 0.0
	set_holdable(false,"Let this rock go, it wants to be free.")
	linear_velocity = Vector2(0,0)
	add_central_force(Vector2(0,-1500.0 * mass))
	yield(get_tree().create_timer(schwoop_delete_time), "timeout")
	queue_free()
