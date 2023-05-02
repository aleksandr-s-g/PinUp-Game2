extends Node
#@onready var BlueBox = preload("res://scenes/globals/blocks/blue_box.tscn")
#@onready var RedBox = preload("res://scenes/globals/blocks/red_box.tscn")
const BlueBox = preload("res://scenes/globals/blocks/blue_box.tscn")
const RedBox = preload("res://scenes/globals/blocks/red_box.tscn")
var cur_lab_loaded_level = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_next_lab_part(screen_size, dir_with_maps):
	
	var map = read_json_lab_part(dir_with_maps)
	var block_list = []
	#print(map)
	for line_id in range(20):
		var map_line_id = cur_lab_loaded_level+line_id
		block_list.append(create_block(Vector2(map_line_id,-1), 'blue',screen_size))
		block_list.append(create_block(Vector2(map_line_id,10),'red',screen_size))
	
	for block in map['blocks']:
		block_list.append(create_block(Vector2(block['y']+cur_lab_loaded_level,block['x']), block['colour'],screen_size))
	cur_lab_loaded_level+=20
	return block_list
	
	
func dir_contents(path):
	var dir = DirAccess.open(path)
	var file_list = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
				#print("Found directory: " + file_name)
			else:
				#print("Found file: " + file_name)
				file_list.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return file_list
	
	
func read_json_lab_part(dir_with_maps):
	var lab_parts_file_list = dir_contents(dir_with_maps)
	var lab_part_random_file_name = lab_parts_file_list[randi() % lab_parts_file_list.size()]
	var lab_part_file = FileAccess.open(dir_with_maps+lab_part_random_file_name, FileAccess.READ)
	var json_string = lab_part_file.get_line()
	var json_object = JSON.new()
	json_object.parse(json_string)
	print('loading ',lab_part_random_file_name)
	return json_object.get_data()

func create_block(pos, colour, screen_size):
	var target_bb_size = screen_size.x/10
	var bb
	if colour == 'red':
		bb = RedBox.instantiate()
	elif colour == 'blue':
		bb = BlueBox.instantiate()
	else:
		print(colour, ' IS WRONG COLOUR!')
	#var bb = BlueBox.instantiate()
	#var bb = RedBox.instantiate()
	var bb_size = bb.get_node('Sprite2D').get_rect().size.x
	var s = target_bb_size/bb_size
	bb.scale = Vector2(s,s)
	var r_mob_size = target_bb_size
	var poz_y = screen_size.y - r_mob_size*(pos.x+1)
	#var mob_size = get_viewport().get_visible_rect().size.y/10
	var pos_x = pos.y*target_bb_size
	bb.position = Vector2(pos_x,poz_y)
	return bb
	#add_child(bb)
