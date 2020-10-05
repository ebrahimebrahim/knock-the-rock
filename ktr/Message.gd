extends Label


var message_lifetime : float

var deletion_animation_playing = false
const deletion_movement_speed = 200.0
var deletion_movement_total_distance : float
var deletion_movement_distance : float = 0.0

func _init(msg : String, time : float = 1, size : int = 40):
	
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
	
	deletion_movement_total_distance = get_line_height() * 2


func _ready():
	if message_lifetime > 0:
		get_tree().create_timer(message_lifetime).connect("timeout",self,"start_deletion_animation")


func start_deletion_animation():
	deletion_animation_playing = true


func _process(delta):
	if deletion_animation_playing:
		var move_dist : float = deletion_movement_speed*delta
		rect_position += move_dist*Vector2(0,-1)
		deletion_movement_distance += move_dist
		modulate.a -= move_dist/deletion_movement_total_distance
		
		if deletion_movement_distance > deletion_movement_total_distance:
			queue_free()
		
		


func set_topleft_position(pos : Vector2):
	rect_position = pos


func set_botmid_position(pos : Vector2):
	var botmid_to_topleft : Vector2 = Vector2(-rect_size[0]/2,-rect_size[1])
	rect_position = pos + botmid_to_topleft
