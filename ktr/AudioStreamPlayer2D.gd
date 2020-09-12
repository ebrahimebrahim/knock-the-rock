extends AudioStreamPlayer2D


func _on_knock(impact_velocity,impact_pos,total_mass):
	position = impact_pos
	print(total_mass)
	volume_db = min((impact_velocity - 200)/50  -  20 , 18)
	pitch_scale = exp(-total_mass/4328  +  1.15525)
	play()
