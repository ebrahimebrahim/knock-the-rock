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
	# We do expect rock_polygon.position to be (0,0) but juuuust in case...
	return rock_polygon.bottom_right - rock_polygon.position

# Return centerpoint of boulder's shelf
func top_mid():
	return (rock_polygon.top_left + rock_polygon.top_right) / 2
