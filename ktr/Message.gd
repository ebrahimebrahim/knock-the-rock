extends Label


var message_lifetime : float

func _init(msg : String, time : float = 4):
	set_theme(preload("message_theme.tres"))
	# set_autowrap(true)  # If you turn this on then you need to set left and right anchors
	set_mouse_filter(MOUSE_FILTER_IGNORE)
	
	text = msg
	message_lifetime = time


func _ready():
	if message_lifetime > 0:
		get_tree().create_timer(message_lifetime).connect("timeout",self,"start_deletion_animation")


func start_deletion_animation():
	queue_free()


func set_topleft_position(pos : Vector2):
	rect_position = pos


func set_botmid_position(pos : Vector2):
	var botmid_to_topleft : Vector2 = Vector2(-rect_size[0]/2,-rect_size[1])
	rect_position = pos + botmid_to_topleft
