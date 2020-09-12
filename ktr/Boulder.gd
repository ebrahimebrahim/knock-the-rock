extends "res://Rock.gd"

# Ways in which Boulder builds upon Rock:
# * Boulders are static objects
# * Boulders cannot be held (even illegally)
# * Boulders have vertices generated differently (bigger, more elongated, flat top and bottom)

var height_from_center : float # allows boulders to be placed flat on the ground
var center_of_table : float # x coords of center of boulder's "table"

# Called when the node enters the scene tree for the first time.
func _ready():
	mode = MODE_STATIC

func _on_input(event):
	pass # this is just to overwrite the Rock input function which deals with Rock holdability

func generate_polygon():
#	var l = rand_range(45,60)
#	var w = rand_range(20,30)
#	var n = rand_range(2,5)
#	var theta = PI/rand_range(5,8)
#	var mini_r = l/(2*n+2)
#	var new_vert = Vector2(0,0)
#	vertices.push_back(Vector2(-w/2,0))
#	for i in range(n):
#		var mini_c = Vector2(-w/2,-l/(n+1))
#		while(new_vert.distance_to(mini_c) >= mini_r):
#			new_vert = Vector2(rand_range(mini_c.x-mini_r,mini_c.x+mini_r),rand_range(mini_c.y-mini_r,mini_c.y+mini_r))
#	vertices.push_back(Vector2(-w/2,-l))
#	vertices.push_back(Vector2(w/2,0))
#	for i in range(n):
#		var mini_c = Vector2(w/2,-l/(n+1))
#		while(new_vert.distance_to(mini_c) >= mini_r):
#			new_vert = Vector2(rand_range(mini_c.x-mini_r,mini_c.x+mini_r),rand_range(mini_c.y-mini_r,mini_c.y+mini_r))
#	vertices.push_back(Vector2(w/2,-l))
#	for i in range(2*(n+2)):
#		if i < (n+2): vertices[i] = vertices[i].rotated(theta)
#		else: vertices[i] = vertices[i].rotated(-theta)
#
	
	var r = rand_range(45,60) # a larger and narrower range than that of rocks
	var n = 2*rand_range(3,5) # this makes the range effectively 6-14, but only even numbers
	var dt = 2*PI/n
	var mini_r = r*sin(dt/2)
	var new_vert = Vector2(0,0)
#	var rot = rand_range(0,2*PI) -- unlike rocks, boulders do not get a random rotation
	for i in range(n):
		var mini_c = r*Vector2(cos(dt*(i-0.5)+(PI/2)),sin(dt*(i-0.5)+(PI/2))) # the -0.5 on the i rotates the minicircles to put pairs on top and bottom
		while(new_vert.distance_to(mini_c) >= mini_r):
			new_vert = Vector2(rand_range(mini_c.x-mini_r,mini_c.x+mini_r),rand_range(mini_c.y-mini_r,mini_c.y+mini_r))
		vertices.push_back(new_vert)
	
#	vertices[0].y -= 2*mini_r
	vertices[1].y = vertices[0].y
	
#	vertices[0].x += mini_r
#	vertices[1].x -= 3*mini_r
	
#	vertices[n/2+1].y += mini_r
	vertices[n/2].y = vertices[n/2+1].y
	
	var stretch = exp(rand_range(0.5,0.7)) # boulders are always stretched
	for i in range(len(vertices)):
		vertices[i].y *= stretch
	
	for i in range(n):
		texture_uvs.push_back(0.5*(Vector2(cos(dt*(i-0.5)),sin(dt*(i-0.5))) + Vector2(1,1))) # -0.5 on i matches as above
