extends Node2D
@onready var MainMenu = preload("res://scenes/globals/main_menu.tscn")
@onready var GameRelax = preload("res://scenes/games/relax/game_relax.tscn")
var main_menu
var game_relax
# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu = MainMenu.instantiate()
	game_relax = GameRelax.instantiate()
	main_menu.connect("start_button_pressed", _on_main_menu_start_button_pressed)
	game_relax.connect("back_to_menu", _on_game_back_to_menu)
	add_child(main_menu)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_main_menu_start_button_pressed():
	print("go!")
	remove_child(main_menu)
	add_child(game_relax)
	#get_tree().change_scene($GameRelax)
	#get_tree().change_scene_to_packed($GameRelax)
	pass # Replace with function body.
	
func _on_game_back_to_menu():
	remove_child(game_relax)
	add_child(main_menu)

