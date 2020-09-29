extends "res://GameBase.gd"

func _ready():
	
	var rocks_to_spawn = 2
	while rocks_to_spawn > 0:
		if spawn_rock($RockSpawnBox):
			rocks_to_spawn -= 1

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_RIGHT:
			Input.set_custom_mouse_cursor(splayed_hand,Input.CURSOR_ARROW,Vector2(21,27))
			$SplayedHandTimer.start()
			var rock : Rock = Rock.new()
			$RockList.add_child(rock)
			rock.flat_bottom()
			rock.position += event.position  - rock.global_transform.xform(rock.center_of_mass())
		if event.button_index == BUTTON_LEFT:
			$SplayedHandTimer.stop()


func _on_SplayedHandTimer_timeout():
	Input.set_custom_mouse_cursor(open_hand,Input.CURSOR_ARROW,Vector2(21,27))
