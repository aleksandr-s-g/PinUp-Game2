extends Node2D

var loaded_game = {}


func set_relax_scores(new_scores):
	loaded_game['relax_scores'] = new_scores
	save_game()

func set_mind_scores(new_scores):
	loaded_game['mind_scores'] = new_scores
	save_game()

func set_race_scores(new_scores):
	loaded_game['race_scores'] = new_scores
	save_game()

func get_relax_scores():
	load_game()
	if 'relax_scores' not in loaded_game:
		loaded_game['relax_scores'] = 0
		save_game()
	return loaded_game['relax_scores']
	
	
func get_mind_scores():
	load_game()
	if 'mind_scores' not in loaded_game:
		loaded_game['mind_scores'] = 0
		save_game()
	return loaded_game['mind_scores']

func get_race_scores():
	load_game()
	if 'race_scores' not in loaded_game:
		loaded_game['race_scores'] = 0
		save_game()
	return loaded_game['race_scores']

func save_game():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var node_data = loaded_game
	var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.

	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		#loaded_scores = node_data['scores']
		loaded_game = node_data
		# Firstly, we need to create the object and add it to the tree and set its position.
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
