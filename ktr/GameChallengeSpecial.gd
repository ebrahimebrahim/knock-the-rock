extends "res://GameChallenge.gd"

const rock_modulate = Color(0.495, 0.59625, 0.9)

func _ready():
	var x_min : float  = $bg/FirefliesRectTopLeft.position.x
	var x_max : float  = $bg/FirefliesRectBotRight.position.x
	var y_min : float  = $bg/FirefliesRectTopLeft.position.y
	var y_max : float  = $bg/FirefliesRectBotRight.position.y
	$bg/Fireflies.position = Vector2(
		rand_range(x_min,x_max), 
		rand_range(y_min,y_max)
	)

	$bg/Fireflies.play()
	
	beuld.modulate = rock_modulate

	$LineOfPebbles.modulate = rock_modulate
	$RockList.modulate = rock_modulate
