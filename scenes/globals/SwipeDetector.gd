extends Node
# Detects swipe gestures and generates InputEventSwipe events
# that are fed back into the engine.


signal swipe_canceled(start_position)
signal swiped(direction)
signal double_tap

@export
var max_diagonal_slope= 1.2
var min_swipe_len= 5

@onready var timer: Timer = $SwipeTimeout
var swipe_start_position: = Vector2()
var first_tap_position: = Vector2()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return
	#print(event)
	if event is InputEventScreenDrag:
		#print(event.velocity)
		var abs_direction = event.relative
		var direction: Vector2 = (abs_direction).normalized()
		if abs(direction.x) + abs(direction.y) >= max_diagonal_slope:
			return
		if abs(abs_direction.x) < min_swipe_len and abs(abs_direction.y) < min_swipe_len:
			return
		var dir
		if abs(abs_direction.x) > abs(abs_direction.y):
			dir = Vector2(-sign(direction.x), 0.0)
		else:
			dir = Vector2(0.0, -sign(direction.y))
		#print (dir)
		emit_signal('swiped', dir)
	
	if not event is InputEventScreenTouch:
		return
	
	if event.pressed and $DoubleTapTimeout.is_stopped():
		$DoubleTapTimeout.start()
		first_tap_position = event.position
	elif event.pressed and not $DoubleTapTimeout.is_stopped():
		if first_tap_position.distance_to(event.position) < min_swipe_len:
			#print ("double tap!!")
			emit_signal('double_tap')
			$DoubleTapTimeout.stop()
		
	#print(event.position)
	#if event.pressed:
	#	_start_detection(event.position)
	#elif not timer.is_stopped():
	#	_end_detection(event.position)


func _start_detection(position: Vector2) -> void:
	swipe_start_position = position
	timer.start()


func _end_detection(position: Vector2) -> void:
	timer.stop()
	var abs_direction = position - swipe_start_position
	var direction: Vector2 = (position - swipe_start_position).normalized()
	
	#print ('swoped lens ',abs(abs_direction.x),' ,', abs(abs_direction.y))
	# Swipe angle is too steep
	if abs(direction.x) + abs(direction.y) >= max_diagonal_slope:
		return
	if abs(abs_direction.x) < min_swipe_len and abs(abs_direction.y) < min_swipe_len:
		return

	var dir
	if abs(direction.x) > abs(direction.y):
		dir = Vector2(-sign(direction.x), 0.0)
	else:
		dir = Vector2(0.0, -sign(direction.y))
	
	emit_signal('swiped', dir)
	#Input.parse_input_event(swipe)


func _on_Timer_timeout() -> void:
	emit_signal('swipe_canceled', swipe_start_position)
