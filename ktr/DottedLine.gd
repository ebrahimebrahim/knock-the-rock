extends Position2D

export var line_width : int
export var line_color : Color
export var dash_length : int
export var gap_length : int
export var line_num_dashes : int

func _draw():
	for i in range(line_num_dashes):
		draw_rect(
			Rect2(
				(dash_length + (dash_length+gap_length)*i) * Vector2(0,-1),
				Vector2(line_width,dash_length)
			),
			line_color
		)
