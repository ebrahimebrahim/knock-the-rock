extends Label


var message_lifetime : float

func _init(msg : String, time : float = 4):
	set_theme(preload("message_theme.tres"))
	set_autowrap(true)
	set_mouse_filter(MOUSE_FILTER_IGNORE)
	
	text = msg
	message_lifetime = time
	rect_position = Vector2(200,200)
	rect_size = Vector2(739,175)


func _ready():
	if message_lifetime > 0:
		get_tree().create_timer(message_lifetime).connect("timeout",self,"start_deletion_animation")


func start_deletion_animation():
	queue_free()
