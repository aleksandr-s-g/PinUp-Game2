extends CanvasLayer
var tester_button_pressed_times = [0,0,0,0,0,0,0,0,0,0]
signal send_event
signal become_tester
var analytics

func update_tester_panel(text):
	$TesterInfo.text = text
	
func _on_tester_button_pressed():
	#print('tester_button_pressed!', Time.get_unix_time_from_system())
	tester_button_pressed_times.append(Time.get_unix_time_from_system())
	tester_button_pressed_times.pop_front()
	var last_clicks_lag = tester_button_pressed_times[9]- tester_button_pressed_times[0]
	if last_clicks_lag < 2.0:
		$TesterInfo.visible = !$TesterInfo.visible
		tester_button_pressed_times = [0,0,0,0,0,0,0,0,0,0]
		if $TesterInfo.visible:
			emit_signal("send_event","open_tester_panel", {})
			emit_signal("become_tester")

# Called when the node enters the scene tree for the first time.
func _ready():
	analytics = get_node("/root/Main/Analitycs")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TesterInfo.text = 'FPS: ' +str(Engine.get_frames_per_second())+'\n'+'UID: '+analytics.cur_user_id+'\n'+'Global IP: '+analytics.device_global_ip+'\n'+'All device info: '+JSON.new().stringify(analytics.device_info)
	pass
