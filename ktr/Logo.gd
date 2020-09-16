extends Control

const LogoPolygon = preload("LogoPolygon.gd")
var logo_polygon : LogoPolygon

func _ready():
	randomize()
	logo_polygon = LogoPolygon.new(abs($xRadius.position.x),abs($yRadius.position.y))
	add_child(logo_polygon)
	move_child(logo_polygon,0) # Move to top to get drawn underneath oher stuff
	$Title.modulate = logo_polygon.self_modulate # set title text to match rock tint 
