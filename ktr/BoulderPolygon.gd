extends "res://RockPolygon.gd"

# Ways in which Boulder builds upon Rock:
# * Boulders are static objects
# * Boulders cannot be held (even illegally)
# * Boulders have vertices generated differently (bigger, more elongated, flat top and bottom)


# "top" refers to the "table" at the top of the boulder
# "bottom" refers to the floor of the boulder
# These are in the boulder polygon's local coordinates
var top_left : Vector2
var top_right : Vector2
var bottom_left : Vector2
var bottom_right : Vector2

var debug_circle_centers = [] # DEBUG
var debug_circle_radii = [] # DEBUG
var debug_circle_colors = [] # DEBUG


# For some reason we need to have an _init defined if we want BoulderPolygon's properties to persist
# This doesn't override RockPolygon's init; in fact it does nothing.
# I don't understand why this is needed and it's really bothering me
func _init().(true):
	pass


func generate_polygon():
	var bottom_length = rand_range(100,400)
	var top_length = rand_range(50,bottom_length)/2
	var height = rand_range(80,300)
	
	# How far the top will be shifted to the right
	var top_shift = rand_range(0,bottom_length-top_length)
	
	bottom_left = Vector2(0,0)
	bottom_right = bottom_left + Vector2(bottom_length,0)
	top_left = bottom_left + Vector2(top_shift,-height)
	top_right = top_left + Vector2(top_length,0)
	
	#interior angles of trapezoid in bottom left and right
	var bottom_left_angle = -(top_left - bottom_left).angle()
	var bottom_right_angle = PI + (top_right - bottom_right).angle()
	
	
	vertices.push_back(bottom_left)
	texture_uvs.push_back(Vector2(0,0))
	
	#build left side
	var n = 1+randi()%8
	var left_side_vec : Vector2 = top_left - bottom_left
	var left_side_vec_n : Vector2 = left_side_vec.normalized()
	var step : float = left_side_vec.length()/(2*n)
	var radius : float = min(step*sin(bottom_left_angle) , top_length/2.0 )
	for i in range(n):
		var center : Vector2 = bottom_left + (step + 2*step*i)*left_side_vec_n
		vertices.push_back(random_point_in_disk(center,radius))
		debug_circle_centers.push_back(center) # DEBUG
		debug_circle_radii.push_back(radius) # DEBUG
		debug_circle_colors.push_back(Color(0,1,0)) # DEBUG
		debug_circle_centers.push_back(center) # DEBUG
		debug_circle_radii.push_back(2) # DEBUG
		debug_circle_colors.push_back(Color(1,0,0)) # DEBUG
		texture_uvs.push_back(Vector2(0,float(1+i)/(n+1)))

	vertices.push_back(top_left)
	texture_uvs.push_back(Vector2(0,1))
	vertices.push_back(top_right)
	texture_uvs.push_back(Vector2(1,1))
	
	#build right side
#	n = 1+randi()%8
	var right_side_vec : Vector2 = bottom_right - top_right
	var right_side_vec_n : Vector2 = right_side_vec.normalized()
	step = right_side_vec.length()/(2*n)
	radius = min(step*sin(bottom_right_angle) , top_length/2.0 )
	for i in range(n):
		var center : Vector2 = top_right + (step + 2*step*i)*right_side_vec_n
		vertices.push_back(random_point_in_disk(center,radius))
		debug_circle_centers.push_back(center) # DEBUG
		debug_circle_radii.push_back(radius) # DEBUG
		debug_circle_colors.push_back(Color(0,1,0)) # DEBUG
		debug_circle_centers.push_back(center) # DEBUG
		debug_circle_radii.push_back(2) # DEBUG
		debug_circle_colors.push_back(Color(1,0,0)) # DEBUG
		texture_uvs.push_back(Vector2(1,1-float(1+i)/(n+1)))
	
	vertices.push_back(bottom_right)
	texture_uvs.push_back(Vector2(1,0))
	

