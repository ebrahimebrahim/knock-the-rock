extends Label


var message_lifetime : float

func _init(msg : String, time : float = 4, size : int = 40):
	
	# set_autowrap(true)  # If you turn this on then you need to set left and right anchors
	set_mouse_filter(MOUSE_FILTER_IGNORE)
	
	text = msg
	message_lifetime = time
	
	var font : DynamicFont = DynamicFont.new()
	font.size = size
	font.outline_size = 1
	font.outline_color = Color(0,0,0)
	font.font_data = preload("res://fonts/Avara.ttf")
	add_font_override("font",font)
	add_color_override("font_color",Color( 0.74902, 0.678431, 0.627451, 1 ))


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
