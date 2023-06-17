extends Node2D
signal back_to_menu
signal restart_race
signal send_event
@onready var Ball = preload("res://scenes/globals/ball.tscn")
@onready var MapManager = preload("res://scenes/globals/map_manager.tscn")
@onready var GameSaver = preload("res://scenes/globals/game_saver.tscn")
#@onready var Analytics = preload("res://scenes/globals/analitycs/analitycs.tscn")
var game_bg = preload("res://img/bg_long_clear.png")
var dir_with_maps = "res://lab_parts_ld/coin_race/"
var ball
var map_manager
var block_size
var game_saver
#var analytics
var screen_size #= get_viewport().get_visible_rect().size
var scores = 0
var loaded_scores = 0
var camera_bottom = 0
var camera_speed = 0
var min_camera_speed = 100
var max_camera_speed = 600
var lose_timeout = 3
var coins = 0
var loaded_coins = 0
var losed = false
var going_to_lose = false
var going_to_lose_timer_running = false
var is_skipping = false
var skip_target_place = Vector2()
var ball_skip_price = 5
var ball_relife_price = 10
var going_to_lose_first_time = true
var not_going_to_lose_first_time = false
# Called when the node enters the scene tree for the first time.
var level_labels = []
# Called when the node enters the scene tree for the first time.
var tester_visibility = false

func set_tester_visibility(state):
	tester_visibility = state

# Called when the node enters the scene tree for the first time.
func add_blocks():
	var new_lab_part = map_manager.load_next_lab_part(screen_size, dir_with_maps)
	for b in new_lab_part['blocks']:
		add_child(b)
	for b in new_lab_part['coins']:
		b.collected.connect(_on_collect_coin)
		add_child(b)
	for b in new_lab_part['labels']:
		b.visible = tester_visibility
		level_labels.append(b)
		add_child(b)

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	map_manager = MapManager.instantiate()
	#analytics = Analytics.instantiate()
	#analytics = get_node("/root/Main/Analitycs")
	game_saver = GameSaver.instantiate()
	#add_child(analytics)
	loaded_scores = game_saver.get_race_scores()
	loaded_coins = game_saver.get_coins()
	$HUD.update_coins(coins+loaded_coins)
#	var loaded_data = game_saver.load_game()
#	if loaded_data:
#		if 'relax_scores' in loaded_data:
#			loaded_scores = loaded_data['relax_scores']
	#print ("going_to_game")
	var target_bb_size = get_viewport().get_visible_rect().size.x/10
	block_size = target_bb_size
	$BackGround.set_texture(game_bg)
	$BackGround.position = Vector2(0,0)
	var resize_x = get_viewport().get_visible_rect().size.x/$BackGround.get_rect().size.x
	$BackGround.set_scale(Vector2(resize_x,resize_x))
	for i in range(0,10):
		add_child(map_manager.create_block(Vector2(-1,i), 'red',screen_size))
	add_blocks()
	#$HUD.custom_minimum_size = get_viewport().get_visible_rect().size
	var resize_back_button_x = block_size/$HUD/BackButton.get_rect().size.x
	$HUD/BackButton.set_scale(Vector2(resize_back_button_x,resize_back_button_x))

	ball = Ball.instantiate()
	var ball_size = ball.get_node('Sprite2D').get_rect().size.x
	var s = target_bb_size/ball_size
	ball.set_ball_scale(s)
	ball.transform = Transform2D(0.0, Vector2(target_bb_size*3.5, get_viewport().get_visible_rect().size.y - target_bb_size*0.5))
	ball.skip_up_signal.connect(_on_ball_skip_up)
	$SwipeDetector.swiped.connect(ball._on_swipe_detector_swiped)
	$SwipeDetector.double_tap.connect(ball.skip_up)
	add_child(ball)
	$HUD.update_best_score(loaded_scores)
	#analytics.init_info(screen_size)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ball:
		#print(ball.position.y)
		if ball.position.y < get_viewport().get_visible_rect().size.y-(map_manager.cur_lab_loaded_level-20)*block_size:
			add_blocks()
		if -ball.position.y > (scores+1)*block_size-screen_size.y:#get_viewport().get_visible_rect().size.y-cur_lab_loaded_level*cell_size:
			scores+=1
			if(scores>loaded_scores):
				$HUD.update_best_score(scores)
				game_saver.set_race_scores(scores)
			#var save_data = {"relax_scores":loaded_scores+scores}
			#game_saver.save_game(save_data)
			
			if scores%10 == 0:
				var event_info = {"scores":scores}
				emit_signal('send_event','reach_current_scores',event_info)
				#analytics.send_event('reach_current_scores','{"scores":"'+str(scores)+'"}')
				#analytics.send_event('reach_global_scores','{"scores":"'+str(scores+loaded_scores)+'"}')
		#if(scores >10):
		#print(round(ball.position.y), ', ',ball.get_node("Camera2D").offset, ', ',ball.get_node("Camera2D").position)
		#print(round(camera_bottom),', ', get_viewport_transform().affine_inverse().get_origin().y)
		if camera_bottom < -get_viewport_transform().affine_inverse().get_origin().y:
			camera_bottom = -get_viewport_transform().affine_inverse().get_origin().y
		
#		if camera_bottom<0-ball.position.y+get_viewport().get_visible_rect().size.y*0.5-5/delta:
#			camera_bottom = -ball.position.y+get_viewport().get_visible_rect().size.y*0.5-5/delta
		camera_bottom+= camera_speed*delta
		ball.get_node("Camera2D").limit_bottom = get_viewport().get_visible_rect().size.y - camera_bottom
		
		if round(-ball.position.y+get_viewport().get_visible_rect().size.y) < round(camera_bottom):
			going_to_lose = true
			var event_info = {"scores":scores}
			if going_to_lose_first_time:
				emit_signal('send_event','going_to_lose',event_info)
				going_to_lose_first_time = false
				not_going_to_lose_first_time = true
			if !losed:
				$HUD.show_message('You lose in ' + str(snapped($LoseTimer.time_left,0.00000001)).pad_decimals(2))
				$HUD/DoubleTapImage.show()
		else:
			going_to_lose = false
			going_to_lose_timer_running = false
			$HUD.hide_message()
			$HUD/DoubleTapImage.hide()
			$LoseTimer.stop()
			if not_going_to_lose_first_time:
				emit_signal('send_event','not_going_to_lose',{"scores":scores})
				not_going_to_lose_first_time = false
				going_to_lose_first_time = true
		
		if going_to_lose and not going_to_lose_timer_running:
			print('start_lose_timer')
			$LoseTimer.start(lose_timeout)
			going_to_lose_timer_running = true
		
		if is_skipping:
			var target_x_px = block_size*(skip_target_place.x+1)
			var cur_x_px = ball.position.x + block_size/2
			#print (round(target_x_px),' ', round(cur_x_px),' ', round(target_x_px - cur_x_px))
			var diff_x = target_x_px - cur_x_px
			#print(diff_x, ', ', diff_x*diff_x*sign(diff_x)/block_size)
			var velocity_x = diff_x*diff_x*2/block_size*sign(diff_x)
			var max_x_vel = block_size*10
			var min_x_vel = block_size
			
			if abs(velocity_x) > max_x_vel:
				velocity_x = max_x_vel*sign(diff_x)
			if abs(velocity_x) < min_x_vel and abs(diff_x) > block_size/50:
				velocity_x = min_x_vel*sign(diff_x)
				
			#print(round(velocity_x), ', ',min_x_vel, ', ', max_x_vel)
			
			ball.linear_velocity.x = velocity_x
			var target_y_px = screen_size.y - block_size*(skip_target_place.y+1)
			var cur_y_px = ball.position.y + block_size/2
			var diff_y = target_y_px - cur_y_px
			#print (diff_y)
			if(diff_y) >=0:
				ball_skip_up_finished()
			#if(diff_y) > -3*block_size:
			#	ball.get_node("CollisionShape2D").disabled = false
			##print(ball.position)
		#print(round(-ball.position.y+get_viewport().get_visible_rect().size.y), ', ' , round(camera_bottom)) 
		var camera_limit = get_viewport().get_visible_rect().size.y-(map_manager.cur_lab_loaded_level+10)*block_size
		#print ('fact:',camera_bottom, ' limit:', camera_limit)

	
	camera_speed = scores*2
	if camera_speed<min_camera_speed:
		camera_speed = min_camera_speed
	
	if camera_speed>max_camera_speed:
		camera_speed = max_camera_speed
		
	
	$HUD.update_score(scores)
#	$HUD.update_tester_panel(
#	'FPS: ' +str(Engine.get_frames_per_second())+'\n'+
#	'UID: '+analytics.cur_user_id+'\n'+
#	'Global IP: '+analytics.device_global_ip+'\n'+
#	'All device info: '+JSON.new().stringify(analytics.device_info))
	#pass
	

func _on_lose():
	$HUD.show_message('You lose!'+ '\n' + 'scores: '+str(scores))
	$HUD/DoubleTapImage.hide()
	$HUD/RestartButtons.show()
	$HUD/RelifeTimer.start()
	losed = true
	ball.is_blocked = true
	var event_info = {"scores":scores}
	emit_signal('send_event','lose_race',event_info)


func _on_collect_coin():
	coins = coins + 1
	#print(coins, ' coin collected!')
	game_saver.set_coins(coins+loaded_coins)
	$HUD.update_coins(coins+loaded_coins)
	pass
	
func _on_hud_back_to_menu():
	emit_signal("back_to_menu")
	emit_signal('send_event','back_to_menu_pressed',{"scores":scores})
	pass # Replace with function body.
	
func _on_hud_restart():
	emit_signal("restart_race")
	emit_signal('send_event','restart_pressed',{"scores":scores})
	pass # Replace with function body.
	
	
func ball_skip_up_finished():
	ball.linear_velocity.x = 0
	is_skipping = false
	ball.get_node("CollisionShape2D").disabled = false
	ball.is_skipping = false

	

func _on_ball_skip_up():
	#ball.get_node("CollisionShape2D").disabled = !ball.get_node("CollisionShape2D").disabled
	emit_signal('send_event','skip_up',{"scores":scores})
	if coins+loaded_coins>=ball_skip_price and !losed:
		coins = coins - ball_skip_price
		#print(coins, ' coin collected!')
		game_saver.set_coins(coins+loaded_coins)
		$HUD.update_coins(coins+loaded_coins)
		var target_place = Vector2()
		skip_target_place.x = 3
		skip_target_place.y = (int((scores+20)/20)+1)*20
		#print (target_place)
		ball.is_skipping = true
		ball.get_node("CollisionShape2D").disabled = true
		ball.linear_velocity = Vector2(0, -2000)
		is_skipping = true
	
	


func _on_hud_relife():
	#ball.get_node("CollisionShape2D").disabled = !ball.get_node("CollisionShape2D").disabled
	emit_signal('send_event','relife_pressed',{"scores":scores})
	if coins+loaded_coins>=ball_relife_price:
		$HUD.hide_message()
		$HUD/DoubleTapImage.hide()
		$HUD/RestartButtons.hide()
		$HUD/RelifeTimer.stop()
		ball.is_blocked = false
		var event_info = {"scores":scores}
		losed = false
		coins = coins - ball_relife_price
		#print(coins, ' coin collected!')
		game_saver.set_coins(coins+loaded_coins)
		$HUD.update_coins(coins+loaded_coins)
		var target_place = Vector2()
		skip_target_place.x = 3
		skip_target_place.y = (int((scores+20)/20)+5)*20
		#print (target_place)
		ball.is_skipping = true
		ball.get_node("CollisionShape2D").disabled = true
		ball.linear_velocity = Vector2(0, -5000)
		is_skipping = true
	pass # Replace with function body.

func _on_hud_set_tester_info_visibility(state):
	#print ()
	tester_visibility = state
	for l in level_labels:
		l.visible = state
	pass # Replace with function body.
