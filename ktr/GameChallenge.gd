extends "res://GameBase.gd"

func _ready():
	for spawn_line in $RockSpawnLines.get_children():
		spawn_rocks((10/$RockSpawnLines.get_child_count()),spawn_line)
