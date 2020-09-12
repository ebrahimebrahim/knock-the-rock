extends "res://Rock.gd"

# Ways in which Boulder builds upon Rock:
# * Boulders are static objects
# * Boulders cannot be held (even illegally)
# * Boulders have vertices generated differently (bigger, more elongated, flat top and bottom)


# "top" refers to the "table" at the top of the boulder
# "bottom" refers to the floor of the boulder
# These are in the boulder's local coordinates
var top_left : Vector2
var top_right : Vector2
var bottom_left : Vector2
var bottom_right : Vector2


func _ready():
	mode = MODE_STATIC


func _on_input(event):
	pass # this is just to overwrite the Rock input function which deals with Rock holdability


func generate_polygon():
	var bottom_length = rand_range(100,400)
	var top_length = rand_range(50,bottom_length)/2
	var height = rand_range(200,300)
	
	# How far the top will be shifted to the right
	var top_shift = rand_range(0,bottom_length-top_length)
	
	bottom_left = Vector2(0,0)
	bottom_right = bottom_left + Vector2(bottom_length,0)
	top_left = bottom_left + Vector2(top_shift,-height)
	top_right = top_left + Vector2(top_length,0)
	
	
	vertices.push_back(bottom_left)
	texture_uvs.push_back(Vector2(0,0))
	
	#build left side
	var n = 1+randi()%8
	var left_side_vec : Vector2 = top_left - bottom_left
	var left_side_vec_n : Vector2 = left_side_vec.normalized()
	var rad_size : float = min(left_side_vec.length()/(2*n),top_length/2.0)
	for i in range(n):
		var center : Vector2 = bottom_left + (rad_size + 2*rad_size*i)*left_side_vec_n
		vertices.push_back(random_point_in_disk(center,0.75*rad_size))
		texture_uvs.push_back(Vector2(0,float(1+i)/(n+1)))

	vertices.push_back(top_left)
	texture_uvs.push_back(Vector2(0,1))
	vertices.push_back(top_right)
	texture_uvs.push_back(Vector2(1,1))
	
	#build right side
#	n = 1+randi()%8
	var right_side_vec : Vector2 = bottom_right - top_right
	var right_side_vec_n : Vector2 = right_side_vec.normalized()
	rad_size = right_side_vec.length()/(2*n)
	for i in range(n):
		var center : Vector2 = top_right + (rad_size + 2*rad_size*i)*right_side_vec_n
		vertices.push_back(random_point_in_disk(center,0.75*rad_size))
		texture_uvs.push_back(Vector2(1,1-float(1+i)/(n+1)))
	
	vertices.push_back(bottom_right)
	texture_uvs.push_back(Vector2(1,0))
	

	
