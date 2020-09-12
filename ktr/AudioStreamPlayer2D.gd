extends AudioStreamPlayer2D


func _on_knock(impact_velocity,impact_pos,lighter_mass):
	position = impact_pos
	volume_db = min((impact_velocity - 200)/50  -  20 , 18)
	pitch_scale = exp(-lighter_mass/1864  +  0.941944)
	play()
