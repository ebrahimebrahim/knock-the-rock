extends "res://Rock.gd"

# Ways in which Boulder builds upon Rock:
# * Boulders are static objects
# * Boulders cannot be held (even illegally)
# * Boulders have vertices generated differently (bigger, more elongated, flat top and bottom)


const BoulderPolygon = preload("res://BoulderPolygon.gd")


func _init():
	mode = MODE_STATIC

func generate_rock_polygon():
	return BoulderPolygon.new()

func _on_input(event):
	pass # this is just to overwrite the Rock input function which deals with Rock holdability


# Return position of bottom right vertex of the boulder trapezoid, in boulder coords
func bottom_right():
	# Note that rock_polygon is a BoulderPolygon
	# We do expect rock_polygon.transform to be identity but juuuust in case...
	return rock_polygon.transform.xform(rock_polygon.bottom_right)

func top_left():
	return rock_polygon.transform.xform(rock_polygon.top_left)

func top_right():
	return rock_polygon.transform.xform(rock_polygon.top_right)


# Return centerpoint of boulder's shelf in boulder coordinates
func top_mid():
	var top_mid_in_rock_polygon_coords = (rock_polygon.top_left + rock_polygon.top_right) / 2
	return rock_polygon.transform.xform(top_mid_in_rock_polygon_coords)
	


