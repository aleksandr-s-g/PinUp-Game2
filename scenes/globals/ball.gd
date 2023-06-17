extends RigidBody2D
signal skip_up_signal
var speed = 1
var relative_speed = 40
var is_moving_h = false
var is_moving_v = false
var prev_step_moving_side_x = false
var prev_step_moving_side_y = false
var is_skipping = false
var is_blocked = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.limit_right = get_viewport().get_visible_rect().size.x
	$Camera2D.limit_bottom = get_viewport().get_visible_rect().size.y
	speed = relative_speed*get_viewport().get_visible_rect().size.x/10
	pass # Replace with function body.

func check_keyboard_move_command():
	
	if Input.is_action_just_pressed("move_right",true):
		move_command(Vector2(1,0))
	if Input.is_action_just_pressed("move_left",true):
		move_command(Vector2(-1,0))
	if Input.is_action_just_pressed("move_down",true):
		move_command(Vector2(0,1))
	if Input.is_action_just_pressed("move_up",true):
		move_command(Vector2(0,-1))
	if Input.is_action_just_pressed("boost",true):
		skip_up()
		print ('Boost!')

func move_command(direction):
	if is_skipping or is_blocked:
		return
	if abs(linear_velocity.x) > speed/100 or abs(linear_velocity.y) > speed/100:
		return
	#print(direction)
	linear_velocity.x = direction.x*speed
	linear_velocity.y = direction.y*speed
	pass

func skip_up():
	emit_signal('skip_up_signal')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_keyboard_move_command()
#	var impulse_vector = Vector2.ZERO
#	var flag = false
#	if abs(linear_velocity.x) < speed/2 and abs(linear_velocity.y) < speed/2:
#		if Input.is_action_just_pressed("move_right",true):
#			impulse_vector.x += 1*speed
#			flag = true
#		if Input.is_action_just_pressed("move_left",true):
#			impulse_vector.x += -1*speed
#			flag = true
#		if Input.is_action_just_pressed("move_down",true):
#			impulse_vector.y += 1*speed
#			flag = true
#		if Input.is_action_just_pressed("move_up",true):
#			impulse_vector.y += -1*speed
#			flag = true
#	if flag:
#		linear_velocity = impulse_vector



#	if prev_step_moving_side_x:
#		linear_velocity.x=0
#		prev_step_moving_side_x = false
#
#	if prev_step_moving_side_y:
#		linear_velocity.y=0
#		prev_step_moving_side_y = false
#
#	if abs(linear_velocity.x)<speed/2 and abs(linear_velocity.x) > 0 and abs(linear_velocity.y)>abs(linear_velocity.x):
#		prev_step_moving_side_x = true
#	if abs(linear_velocity.y)<speed/2 and abs(linear_velocity.y) > 0 and abs(linear_velocity.y)<abs(linear_velocity.x):
#		prev_step_moving_side_y = true
	pass

func _on_swipe_detector_swiped(direction):
	#print(direction)
	move_command(-direction)
	#velocity.x += direction.x*speed
	#velocity.y += direction.y*speed
func set_ball_scale(scale):
	# Override behaviour only if it is a RigidBody2D and do not touch other nodes
	if true:#self extends RigidBody2D:
		for child in self.get_children():
			if not child.has_meta("original_scale"):
				# save original scale and position as a reference for future modifications
				child.set_meta("original_scale",child.get_scale())
				#child.set_meta("original_pos",child.get_pos())
			var original_scale = child.get_meta("original_scale")
			#var original_pos = child.get_meta("original_pos")
			# When scaled, position also has to be changed to keep offset
			#child.set_pos(original_pos * scale)
			child.set_scale(original_scale * scale)



