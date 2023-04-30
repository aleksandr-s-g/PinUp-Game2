extends HTTPRequest
const uuid_util = preload('res://scenes/globals/analitycs/uuid.gd')
var device_info = {}
var cur_user_id = ''
var device_global_ip = '0.0.0.0'
var is_tester = false

func save_user_info():
	var save_user_info_file = FileAccess.open("user://user_info.save", FileAccess.WRITE)
	var node_data ={
		"user_id" : cur_user_id,
		"is_tester" : is_tester}
	var json_string = JSON.stringify(node_data)
		# Store the save dictionary as a new line in the save file.
	save_user_info_file.store_line(json_string)


func load_user_info():
	if not FileAccess.file_exists("user://user_info.save"):
		cur_user_id = uuid_util.v4()
		save_user_info()
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.

	var save_user_info = FileAccess.open("user://user_info.save", FileAccess.READ)
	while save_user_info.get_position() < save_user_info.get_length():
		var json_string = save_user_info.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		if 'user_id' in node_data:
			cur_user_id = node_data['user_id']
		else:
			cur_user_id = uuid_util.v4()
			save_user_info()
		if 'is_tester' in node_data:
			is_tester = node_data['is_tester']
		else:
			print('There isnt info about tester')
		# Firstly, we need to create the object and add it to the tree and set its position.
		
		
func fill_ip(result, response_code, headers, body):
	var ip = body.get_string_from_utf8()
	device_global_ip = ip
	device_info['global_ip'] = device_global_ip
	#print("Internet IP is: ", ip)
	send_event('ip_recived', '{"ip":"'+ip +'"}')

func get_device_global_ip():
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", fill_ip )
	http.request("https://api.ipify.org")



func fill_device_info(screen_size):
	load_user_info()
	get_device_global_ip()
	device_info = {
		'locale':OS.get_locale(),
		'locale_language':OS.get_locale_language(),
		'model_name': OS.get_model_name(),
		'processor_name':OS.get_processor_name(),
		'os_name' : OS.get_name(),
		'os_version':OS.get_version(),
		'device_id':OS.get_unique_id()
	}
	device_info['screen_h']=str(screen_size.y)
	device_info['screen_w']=str(screen_size.x)
	device_info['user_id'] = cur_user_id
	device_info['global_ip'] = device_global_ip
	device_info['is_tester'] = is_tester



func send_event(event_name, event_details):
	print (event_name, ' ', event_details)
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	var cur_fps = Engine.get_frames_per_second()   
	device_info['fps'] = cur_fps
	var body = JSON.new().stringify({"event_name": event_name,
	"event_details": event_details,
	"device_info":JSON.new().stringify(device_info),
	"user_info":cur_user_id})
	#● Error request(url: String, custom_headers: PackedStringArray = PackedStringArray(), method: Method = 0, request_data: String = "")
	var status = http_request.request("http://asgavril.ru/stat/log_event.php", [], HTTPClient.METHOD_POST, body)
	if status != OK:
		push_error("An error occurred in the HTTP request.")
	pass

func init_info(screen_size):
	print(OS.get_user_data_dir())
	#send_event('alaunch', '{}')
	#print(uuid_util.v4())
	fill_device_info(screen_size)

func _ready():
	#print(OS.get_user_data_dir())
	#send_event('alaunch', '{}')
	#print(uuid_util.v4())
	#fill_device_info()
	pass
	# Create an HTTP request node and connect its completion signal.
	
	# Perform a POST request. The URL below returns JSON as of writing.
	# Note: Don't make simultaneous requests using a single HTTPRequest node.
	# The snippet below is provided for reference only.
	
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	#print(body.get_string_from_utf8())
	pass
	#var json = JSON.new()
	#json.parse(body.get_string_from_utf8())
	#var response = json.get_data()

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	#print(response.headers["User-Agent"])


func _on_hud_become_tester():
	is_tester = true
	device_info['is_tester'] = is_tester
	save_user_info() 
	send_event('open_test_panel', '{}')
