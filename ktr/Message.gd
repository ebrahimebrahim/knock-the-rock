extends Label


var message_lifetime : float

func _init(msg : String, time : float = 4):
	theme = preload("message_theme.tres")
	text = msg
	message_lifetime = time
	rect_position = Vector2(-900,-450)
	rect_size = Vector2(739,175)


func _ready():
	if message_lifetime > 0:
		get_tree().create_timer(message_lifetime).connect("timeout",self,"start_deletion_animation")


func start_deletion_animation():
	queue_free()
