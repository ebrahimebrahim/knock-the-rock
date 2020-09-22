extends Node2D

const Rock = preload("Rock.gd")

func _draw():
	for child in get_parent().get_children():
		if child is Rock:
			for pos in child.recent_positions:
				draw_circle(pos,1.0,Color(1,0,0))

func _process(_delta):
	update()
