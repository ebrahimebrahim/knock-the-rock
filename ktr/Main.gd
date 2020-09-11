extends Node2D

const Rock = preload("res://Rock.gd")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in range(10):
		var rock : Rock = Rock.new()
		add_child(rock)
		rock.set_position(Vector2(rand_range(100,900),rand_range(0,300)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
