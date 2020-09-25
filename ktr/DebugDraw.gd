extends Node2D

const Boulder = preload("Boulder.gd")
var beuld : Boulder

func _ready():
	get_parent().connect("ready",self,"_on_game_ready")

func _on_game_ready():
	for child in get_parent().get_children():
		if child is Boulder:
			beuld = child
			print("Found boulder: ",beuld)

func _process(_delta):
	update()

func _draw():
	if is_instance_valid(beuld):
		for i in range(len(beuld.rock_polygon.debug_circle_centers)):
			draw_circle(
				beuld.rock_polygon.global_transform.xform(beuld.rock_polygon.debug_circle_centers[i]),
				beuld.rock_polygon.debug_circle_radii[i],
				beuld.rock_polygon.debug_circle_colors[i]
			)
