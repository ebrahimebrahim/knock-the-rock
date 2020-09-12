extends Node2D

const Rock = preload("res://Rock.gd")

onready var audio_player = get_node("AudioStreamPlayer2D")


func _ready():
	randomize()
	for i in range(10):
		var rock : Rock = Rock.new()
		add_child(rock)
		rock.set_position(Vector2(rand_range(100,900),rand_range(0,300)))
		rock.connect("knock",audio_player,"_on_knock")
