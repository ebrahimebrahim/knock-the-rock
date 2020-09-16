extends "res://RockPolygon.gd"

var x_radius : float
var y_radius : float


# The ".(false)" thing is explained here:
# https://docs.godotengine.org/en/3.2/getting_started/scripting/gdscript/gdscript_basics.html#class-constructor
# The purpose is to tell RockPolygon's _init method to not generate polygon,
# so that we can do it here instead, after we inititalize x_radius and y_radius
func _init(p_x_radius : float, p_y_radius : float).(false):
	assert(p_x_radius > 0)
	assert(p_y_radius > 0)
	x_radius = p_x_radius
	y_radius = p_y_radius
	generate_polygon()


func random_point_in_disk_and_outside_disk(center_in : Vector2, radius_in : float, center_out : Vector2, radius_out : float):
	var output = center_in+100*Vector2(radius_in,0)
	while(output.distance_to(center_in) >= radius_in  or  output.distance_to(center_out)<radius_out):
		output = Vector2(rand_range(center_in.x-radius_in,center_in.x+radius_in),rand_range(center_in.y-radius_in,center_in.y+radius_in))
	return output


func generate_polygon():
	var r = y_radius
	var n = 9 + randi()%11
	var dt = 2*PI/n
	var mini_r = r*sin(dt/2)
	var stretch = x_radius / y_radius
	for i in range(n):
		var new_vert = random_point_in_disk_and_outside_disk(r*Vector2(cos(dt*i),sin(dt*i)),mini_r,Vector2(0,0),r)
		new_vert.x *= stretch
		vertices.push_back(new_vert)
		
		texture_uvs.push_back(0.5*(Vector2(cos(dt*i),sin(dt*i)) + Vector2(1,1)))
