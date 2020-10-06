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
		
		

# Sets the position of the top-left of the label rect to pos
func set_topleft_position(pos : Vector2) -> void:
	rect_position = pos


# Sets the position of the bottom-middle of the label rect to pos
# This will not work if the Message is not in the tree yet, since its
# rect gets set once it is in the tree
func set_botmid_position(pos : Vector2) -> void:
	var botmid_to_topleft : Vector2 = Vector2(-rect_size[0]/2,-rect_size[1])
	rect_position = pos + botmid_to_topleft


# Forces the label rect to be inside the given rect
# - Does nothing if the label rect is already inside
# - Otherwise, repositions to put label rect inside
# The Message should be in the scene tree before calling this,
# so that the label rect can be used.
# If the label rect doesn't fit inside the given rect, then we prioritize
# positioning in the top left corner so that it is inside, allowing the
# bottom right corner to overflow.
func force_into_rect(rect : Rect2) -> void:
	if rect.encloses(get_rect()):
		return
	for i in range(2):
		rect_position[i] = min( rect_position[i] , rect.end[i]-rect_size[i] )
		rect_position[i] = max(rect_position[i] , rect.position[i])
