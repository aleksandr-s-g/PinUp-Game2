extends Node2D
signal back_to_menu
signal send_event
@onready var Ball = preload("res://scenes/globals/ball.tscn")
@onready var MapManager = preload("res://scenes/globals/map_manager.tscn")
@onready var GameSaver = preload("res://scenes/globals/game_saver.tscn")
#@onready var Analytics = preload("res://scenes/globals/analitycs/analitycs.tscn")
var game_bg = preload("res://img/bg_long_clear.png")
var dir_with_maps = "res://lab_parts_ld/relax/"
var ball
var map_manager
var block_size
var game_saver
#var analytics
var screen_size #= get_viewport().get_visible_rect().size
var scores = 0
var loaded_scores = 0
# Called when the node enters the scene tree for the first time.
func add_blocks():
	for b in map_manager.load_next_lab_part(screen_size, dir_with_maps):
		add_child(b)

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	map_manager = MapManager.instantiate()
	#analytics = Analytics.instantiate()
	#analytics = get_node("/root/Main/Analitycs")
	game_saver = GameSaver.instantiate()
	#add_child(analytics)
	loaded_scores = game_saver.get_relax_scores()
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
	$SwipeDetector.swiped.connect(ball._on_swipe_detector_swiped)
	add_child(ball)
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
			game_saver.set_relax_scores(loaded_scores+scores)
			#var save_data = {"relax_scores":loaded_scores+scores}
			#game_saver.save_game(save_data)
			
			if int(scores+loaded_scores) == 10:
				var event_info = {"scores":scores+loaded_scores}
				emit_signal('send_event','first_scores',event_info)
				#analytics.send_event('first_scores','{"scores":"'+str(scores+loaded_scores)+'"}')
			if scores%100 == 0:
				var event_info = {"scores":scores}
				emit_signal('send_event','reach_current_scores',event_info)
				#analytics.send_event('reach_current_scores','{"scores":"'+str(scores)+'"}')
			if int(scores+loaded_scores)%100 == 0:
				var event_info = {"scores":scores+loaded_scores}
				emit_signal('send_event','reach_global_scores',event_info)
				#analytics.send_event('reach_global_scores','{"scores":"'+str(scores+loaded_scores)+'"}')
	$HUD.update_score(scores+loaded_scores)
#	$HUD.update_tester_panel(
#	'FPS: ' +str(Engine.get_frames_per_second())+'\n'+
#	'UID: '+analytics.cur_user_id+'\n'+
#	'Global IP: '+analytics.device_global_ip+'\n'+
#	'All device info: '+JSON.new().stringify(analytics.device_info))
	#pass


func _on_hud_back_to_menu():
	emit_signal("back_to_menu")
	pass # Replace with function body.
